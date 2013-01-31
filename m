From: Tom Parkin <tparkin@katalix.com>
Subject: [PATCH v3 1/3] ipv6: rename datagram_send_ctl and datagram_recv_ctl
Date: Thu, 31 Jan 2013 11:02:24 +0000
Message-ID: <1359630146-8305-2-git-send-email-tparkin@katalix.com>
References: <1359630146-8305-1-git-send-email-tparkin@katalix.com>
Cc: jchapman@katalix.com, celston@katalix.com,
	Tom Parkin <tparkin@katalix.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:41547 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751339Ab3AaLCt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2013 06:02:49 -0500
In-Reply-To: <1359630146-8305-1-git-send-email-tparkin@katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The datagram_*_ctl functions in net/ipv6/datagram.c are IPv6-specific.  Since
datagram_send_ctl is publicly exported it should be appropriately named to
reflect the fact that it's for IPv6 only.

Signed-off-by: Tom Parkin <tparkin@katalix.com>
Signed-off-by: James Chapman <jchapman@katalix.com>
---
 include/net/transp_v6.h  |   22 +++++++++++-----------
 net/ipv6/datagram.c      |   15 ++++++++-------
 net/ipv6/ip6_flowlabel.c |    4 ++--
 net/ipv6/ipv6_sockglue.c |    6 +++---
 net/ipv6/raw.c           |    6 +++---
 net/ipv6/udp.c           |    6 +++---
 net/l2tp/l2tp_ip6.c      |    4 ++--
 net/sunrpc/svcsock.c     |    2 +-
 8 files changed, 33 insertions(+), 32 deletions(-)

diff --git a/include/net/transp_v6.h b/include/net/transp_v6.h
index 498433d..938b7fd 100644
--- a/include/net/transp_v6.h
+++ b/include/net/transp_v6.h
@@ -34,17 +34,17 @@ extern int				udpv6_connect(struct sock *sk,
 						      struct sockaddr *uaddr,
 						      int addr_len);
 
-extern int			datagram_recv_ctl(struct sock *sk,
-						  struct msghdr *msg,
-						  struct sk_buff *skb);
-
-extern int			datagram_send_ctl(struct net *net,
-						  struct sock *sk,
-						  struct msghdr *msg,
-						  struct flowi6 *fl6,
-						  struct ipv6_txoptions *opt,
-						  int *hlimit, int *tclass,
-						  int *dontfrag);
+extern int			ip6_datagram_recv_ctl(struct sock *sk,
+						      struct msghdr *msg,
+						      struct sk_buff *skb);
+
+extern int			ip6_datagram_send_ctl(struct net *net,
+						      struct sock *sk,
+						      struct msghdr *msg,
+						      struct flowi6 *fl6,
+						      struct ipv6_txoptions *opt,
+						      int *hlimit, int *tclass,
+						      int *dontfrag);
 
 #define		LOOPBACK4_IPV6		cpu_to_be32(0x7f000006)
 
diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 33be363..be6f49e 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -380,7 +380,7 @@ int ipv6_recv_error(struct sock *sk, struct msghdr *msg, int len)
 		if (skb->protocol == htons(ETH_P_IPV6)) {
 			sin->sin6_addr = ipv6_hdr(skb)->saddr;
 			if (np->rxopt.all)
-				datagram_recv_ctl(sk, msg, skb);
+				ip6_datagram_recv_ctl(sk, msg, skb);
 			if (ipv6_addr_type(&sin->sin6_addr) & IPV6_ADDR_LINKLOCAL)
 				sin->sin6_scope_id = IP6CB(skb)->iif;
 		} else {
@@ -468,7 +468,8 @@ out:
 }
 
 
-int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
+int ip6_datagram_recv_ctl(struct sock *sk, struct msghdr *msg,
+			  struct sk_buff *skb)
 {
 	struct ipv6_pinfo *np = inet6_sk(sk);
 	struct inet6_skb_parm *opt = IP6CB(skb);
@@ -599,10 +600,10 @@ int datagram_recv_ctl(struct sock *sk, struct msghdr *msg, struct sk_buff *skb)
 	return 0;
 }
 
-int datagram_send_ctl(struct net *net, struct sock *sk,
-		      struct msghdr *msg, struct flowi6 *fl6,
-		      struct ipv6_txoptions *opt,
-		      int *hlimit, int *tclass, int *dontfrag)
+int ip6_datagram_send_ctl(struct net *net, struct sock *sk,
+			  struct msghdr *msg, struct flowi6 *fl6,
+			  struct ipv6_txoptions *opt,
+			  int *hlimit, int *tclass, int *dontfrag)
 {
 	struct in6_pktinfo *src_info;
 	struct cmsghdr *cmsg;
@@ -872,4 +873,4 @@ int datagram_send_ctl(struct net *net, struct sock *sk,
 exit_f:
 	return err;
 }
-EXPORT_SYMBOL_GPL(datagram_send_ctl);
+EXPORT_SYMBOL_GPL(ip6_datagram_send_ctl);
diff --git a/net/ipv6/ip6_flowlabel.c b/net/ipv6/ip6_flowlabel.c
index 29124b7..d6de4b4 100644
--- a/net/ipv6/ip6_flowlabel.c
+++ b/net/ipv6/ip6_flowlabel.c
@@ -365,8 +365,8 @@ fl_create(struct net *net, struct sock *sk, struct in6_flowlabel_req *freq,
 		msg.msg_control = (void*)(fl->opt+1);
 		memset(&flowi6, 0, sizeof(flowi6));
 
-		err = datagram_send_ctl(net, sk, &msg, &flowi6, fl->opt, &junk,
-					&junk, &junk);
+		err = ip6_datagram_send_ctl(net, sk, &msg, &flowi6, fl->opt,
+					    &junk, &junk, &junk);
 		if (err)
 			goto done;
 		err = -EINVAL;
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index ee94d31..d1e2e8e 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -476,8 +476,8 @@ sticky_done:
 		msg.msg_controllen = optlen;
 		msg.msg_control = (void*)(opt+1);
 
-		retv = datagram_send_ctl(net, sk, &msg, &fl6, opt, &junk, &junk,
-					 &junk);
+		retv = ip6_datagram_send_ctl(net, sk, &msg, &fl6, opt, &junk,
+					     &junk, &junk);
 		if (retv)
 			goto done;
 update:
@@ -1002,7 +1002,7 @@ static int do_ipv6_getsockopt(struct sock *sk, int level, int optname,
 		release_sock(sk);
 
 		if (skb) {
-			int err = datagram_recv_ctl(sk, &msg, skb);
+			int err = ip6_datagram_recv_ctl(sk, &msg, skb);
 			kfree_skb(skb);
 			if (err)
 				return err;
diff --git a/net/ipv6/raw.c b/net/ipv6/raw.c
index 6cd29b1..70fa814 100644
--- a/net/ipv6/raw.c
+++ b/net/ipv6/raw.c
@@ -507,7 +507,7 @@ static int rawv6_recvmsg(struct kiocb *iocb, struct sock *sk,
 	sock_recv_ts_and_drops(msg, sk, skb);
 
 	if (np->rxopt.all)
-		datagram_recv_ctl(sk, msg, skb);
+		ip6_datagram_recv_ctl(sk, msg, skb);
 
 	err = copied;
 	if (flags & MSG_TRUNC)
@@ -822,8 +822,8 @@ static int rawv6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
-		err = datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					&hlimit, &tclass, &dontfrag);
+		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
+					    &hlimit, &tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
diff --git a/net/ipv6/udp.c b/net/ipv6/udp.c
index cb5bf49..599e1ba6 100644
--- a/net/ipv6/udp.c
+++ b/net/ipv6/udp.c
@@ -467,7 +467,7 @@ try_again:
 			ip_cmsg_recv(msg, skb);
 	} else {
 		if (np->rxopt.all)
-			datagram_recv_ctl(sk, msg, skb);
+			ip6_datagram_recv_ctl(sk, msg, skb);
 	}
 
 	err = copied;
@@ -1143,8 +1143,8 @@ do_udp_sendmsg:
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(*opt);
 
-		err = datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					&hlimit, &tclass, &dontfrag);
+		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
+					    &hlimit, &tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
diff --git a/net/l2tp/l2tp_ip6.c b/net/l2tp/l2tp_ip6.c
index 9275471..2316947 100644
--- a/net/l2tp/l2tp_ip6.c
+++ b/net/l2tp/l2tp_ip6.c
@@ -554,8 +554,8 @@ static int l2tp_ip6_sendmsg(struct kiocb *iocb, struct sock *sk,
 		memset(opt, 0, sizeof(struct ipv6_txoptions));
 		opt->tot_len = sizeof(struct ipv6_txoptions);
 
-		err = datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
-					&hlimit, &tclass, &dontfrag);
+		err = ip6_datagram_send_ctl(sock_net(sk), sk, msg, &fl6, opt,
+					    &hlimit, &tclass, &dontfrag);
 		if (err < 0) {
 			fl6_sock_release(flowlabel);
 			return err;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index 0a148c9..0f679df 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -465,7 +465,7 @@ static int svc_udp_get_dest_address4(struct svc_rqst *rqstp,
 }
 
 /*
- * See net/ipv6/datagram.c : datagram_recv_ctl
+ * See net/ipv6/datagram.c : ip6_datagram_recv_ctl
  */
 static int svc_udp_get_dest_address6(struct svc_rqst *rqstp,
 				     struct cmsghdr *cmh)
-- 
1.7.9.5
