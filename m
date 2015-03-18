From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH 1/3] ipv4,ipv6: grab rtnl before locking the socket
Date: Wed, 18 Mar 2015 14:50:42 -0300
Message-ID: <9605dd2faf9e0aae8c3f6ce9f255760dd4856c91.1426700794.git.marcelo.leitner@gmail.com>
Cc: hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33861 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755821AbbCRRvX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 18 Mar 2015 13:51:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are some setsockopt operations in ipv4 and ipv6 that are grabbing
rtnl after having grabbed the socket lock. Yet this makes it impossible
to do operations that have to lock the socket when already within a rtnl
protected scope, like ndo dev_open and dev_stop.

We normally take coarse grained locks first but setsockopt inverted that.

So this patch invert the lock logic for these operations and makes
setsockopt grab rtnl if it will be needed prior to grabbing socket lock.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---

Notes:
    With CONFIG_LOCKDEP enabled, no splats were observed after this series.

 net/ipv4/ip_sockglue.c   | 31 +++++++++++++++++++++++++------
 net/ipv6/ipv6_sockglue.c | 35 +++++++++++++++++++++++++++--------
 2 files changed, 52 insertions(+), 14 deletions(-)

diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 5cd99271d3a6a07c17a915fddde7a5a0c8a86618..5171709199f48588b7ba0f733b72ba2234d4c100 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -536,12 +536,25 @@ out:
  *	Socket option code for IP. This is the end of the line after any
  *	TCP,UDP etc options on an IP socket.
  */
+static bool setsockopt_needs_rtnl(int optname)
+{
+	switch (optname) {
+	case IP_ADD_MEMBERSHIP:
+	case IP_ADD_SOURCE_MEMBERSHIP:
+	case IP_DROP_MEMBERSHIP:
+	case MCAST_JOIN_GROUP:
+	case MCAST_LEAVE_GROUP:
+		return true;
+	}
+	return false;
+}
 
 static int do_ip_setsockopt(struct sock *sk, int level,
 			    int optname, char __user *optval, unsigned int optlen)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	int val = 0, err;
+	bool needs_rtnl = setsockopt_needs_rtnl(optname);
 
 	switch (optname) {
 	case IP_PKTINFO:
@@ -584,6 +597,8 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		return ip_mroute_setsockopt(sk, optname, optval, optlen);
 
 	err = 0;
+	if (needs_rtnl)
+		rtnl_lock();
 	lock_sock(sk);
 
 	switch (optname) {
@@ -846,9 +861,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		}
 
 		if (optname == IP_ADD_MEMBERSHIP)
-			err = ip_mc_join_group(sk, &mreq);
+			err = __ip_mc_join_group(sk, &mreq);
 		else
-			err = ip_mc_leave_group(sk, &mreq);
+			err = __ip_mc_leave_group(sk, &mreq);
 		break;
 	}
 	case IP_MSFILTER:
@@ -913,7 +928,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			mreq.imr_multiaddr.s_addr = mreqs.imr_multiaddr;
 			mreq.imr_address.s_addr = mreqs.imr_interface;
 			mreq.imr_ifindex = 0;
-			err = ip_mc_join_group(sk, &mreq);
+			err = __ip_mc_join_group(sk, &mreq);
 			if (err && err != -EADDRINUSE)
 				break;
 			omode = MCAST_INCLUDE;
@@ -945,9 +960,9 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 		mreq.imr_ifindex = greq.gr_interface;
 
 		if (optname == MCAST_JOIN_GROUP)
-			err = ip_mc_join_group(sk, &mreq);
+			err = __ip_mc_join_group(sk, &mreq);
 		else
-			err = ip_mc_leave_group(sk, &mreq);
+			err = __ip_mc_leave_group(sk, &mreq);
 		break;
 	}
 	case MCAST_JOIN_SOURCE_GROUP:
@@ -990,7 +1005,7 @@ static int do_ip_setsockopt(struct sock *sk, int level,
 			mreq.imr_multiaddr = psin->sin_addr;
 			mreq.imr_address.s_addr = 0;
 			mreq.imr_ifindex = greqs.gsr_interface;
-			err = ip_mc_join_group(sk, &mreq);
+			err = __ip_mc_join_group(sk, &mreq);
 			if (err && err != -EADDRINUSE)
 				break;
 			greqs.gsr_interface = mreq.imr_ifindex;
@@ -1118,10 +1133,14 @@ mc_msf_out:
 		break;
 	}
 	release_sock(sk);
+	if (needs_rtnl)
+		rtnl_unlock();
 	return err;
 
 e_inval:
 	release_sock(sk);
+	if (needs_rtnl)
+		rtnl_unlock();
 	return -EINVAL;
 }
 
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 8d766d9100cba408525faf5818b7b0c6b6bc543c..f2b731df8d7735a129a8619a4753dd0ab2c76d0d 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -117,6 +117,18 @@ struct ipv6_txoptions *ipv6_update_options(struct sock *sk,
 	return opt;
 }
 
+static bool setsockopt_needs_rtnl(int optname)
+{
+	switch (optname) {
+	case IPV6_ADD_MEMBERSHIP:
+	case IPV6_DROP_MEMBERSHIP:
+	case MCAST_JOIN_GROUP:
+	case MCAST_LEAVE_GROUP:
+		return true;
+	}
+	return false;
+}
+
 static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 		    char __user *optval, unsigned int optlen)
 {
@@ -124,6 +136,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	struct net *net = sock_net(sk);
 	int val, valbool;
 	int retv = -ENOPROTOOPT;
+	bool needs_rtnl = setsockopt_needs_rtnl(optname);
 
 	if (optval == NULL)
 		val = 0;
@@ -140,6 +153,8 @@ static int do_ipv6_setsockopt(struct sock *sk, int level, int optname,
 	if (ip6_mroute_opt(optname))
 		return ip6_mroute_setsockopt(sk, optname, optval, optlen);
 
+	if (needs_rtnl)
+		rtnl_lock();
 	lock_sock(sk);
 
 	switch (optname) {
@@ -582,9 +597,9 @@ done:
 			break;
 
 		if (optname == IPV6_ADD_MEMBERSHIP)
-			retv = ipv6_sock_mc_join(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_multiaddr);
+			retv = __ipv6_sock_mc_join(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_multiaddr);
 		else
-			retv = ipv6_sock_mc_drop(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_multiaddr);
+			retv = __ipv6_sock_mc_drop(sk, mreq.ipv6mr_ifindex, &mreq.ipv6mr_multiaddr);
 		break;
 	}
 	case IPV6_JOIN_ANYCAST:
@@ -623,11 +638,11 @@ done:
 		}
 		psin6 = (struct sockaddr_in6 *)&greq.gr_group;
 		if (optname == MCAST_JOIN_GROUP)
-			retv = ipv6_sock_mc_join(sk, greq.gr_interface,
-				&psin6->sin6_addr);
+			retv = __ipv6_sock_mc_join(sk, greq.gr_interface,
+						   &psin6->sin6_addr);
 		else
-			retv = ipv6_sock_mc_drop(sk, greq.gr_interface,
-				&psin6->sin6_addr);
+			retv = __ipv6_sock_mc_drop(sk, greq.gr_interface,
+						   &psin6->sin6_addr);
 		break;
 	}
 	case MCAST_JOIN_SOURCE_GROUP:
@@ -659,8 +674,8 @@ done:
 			struct sockaddr_in6 *psin6;
 
 			psin6 = (struct sockaddr_in6 *)&greqs.gsr_group;
-			retv = ipv6_sock_mc_join(sk, greqs.gsr_interface,
-				&psin6->sin6_addr);
+			retv = __ipv6_sock_mc_join(sk, greqs.gsr_interface,
+						   &psin6->sin6_addr);
 			/* prior join w/ different source is ok */
 			if (retv && retv != -EADDRINUSE)
 				break;
@@ -837,11 +852,15 @@ pref_skip_coa:
 	}
 
 	release_sock(sk);
+	if (needs_rtnl)
+		rtnl_unlock();
 
 	return retv;
 
 e_inval:
 	release_sock(sk);
+	if (needs_rtnl)
+		rtnl_unlock();
 	return -EINVAL;
 }
 
-- 
1.9.3
