From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ipv4: fix a potential deadlock in mcast getsockopt() path
Date: Tue,  3 Nov 2015 13:55:10 -0800
Message-ID: <1446587710-23642-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: sasha.levin@oracle.com, Cong Wang <xiyou.wangcong@gmail.com>,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34252 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755209AbbKCVzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 16:55:18 -0500
Received: by padhx2 with SMTP id hx2so22060511pad.1
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 13:55:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sasha reported the following lockdep warning:

  Possible unsafe locking scenario:

        CPU0                    CPU1
        ----                    ----
   lock(sk_lock-AF_INET);
                                lock(rtnl_mutex);
                                lock(sk_lock-AF_INET);
   lock(rtnl_mutex);

This is due to that for IP_MSFILTER and MCAST_MSFILTER, we take
rtnl lock before the socket lock in setsockopt() path, but take
the socket lock before rtnl lock in getsockopt() path. All the
rest optnames are setsockopt()-only.

Fix this by aligning the getsockopt() path with the setsockopt()
path, so that all mcast socket path would be locked in the same
order.

Note, IPv6 part is different where rtnl lock is not held.

Fixes: 54ff9ef36bdf ("ipv4, ipv6: kill ip_mc_{join, leave}_group and ipv6_sock_mc_{join, drop}")
Reported-by: Sasha Levin <sasha.levin@oracle.com>
Cc: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv4/igmp.c        | 12 ++++--------
 net/ipv4/ip_sockglue.c | 43 ++++++++++++++++++++++++++++++-------------
 2 files changed, 34 insertions(+), 21 deletions(-)

diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index d38b8b6..a2429b7 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -2392,11 +2392,11 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 	struct ip_sf_socklist *psl;
 	struct net *net = sock_net(sk);
 
+	ASSERT_RTNL();
+
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
-
 	imr.imr_multiaddr.s_addr = msf->imsf_multiaddr;
 	imr.imr_address.s_addr = msf->imsf_interface;
 	imr.imr_ifindex = 0;
@@ -2417,7 +2417,6 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 		goto done;
 	msf->imsf_fmode = pmc->sfmode;
 	psl = rtnl_dereference(pmc->sflist);
-	rtnl_unlock();
 	if (!psl) {
 		len = 0;
 		count = 0;
@@ -2436,7 +2435,6 @@ int ip_mc_msfget(struct sock *sk, struct ip_msfilter *msf,
 		return -EFAULT;
 	return 0;
 done:
-	rtnl_unlock();
 	return err;
 }
 
@@ -2450,6 +2448,8 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_sf_socklist *psl;
 
+	ASSERT_RTNL();
+
 	psin = (struct sockaddr_in *)&gsf->gf_group;
 	if (psin->sin_family != AF_INET)
 		return -EINVAL;
@@ -2457,8 +2457,6 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
-
 	err = -EADDRNOTAVAIL;
 
 	for_each_pmc_rtnl(inet, pmc) {
@@ -2470,7 +2468,6 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 		goto done;
 	gsf->gf_fmode = pmc->sfmode;
 	psl = rtnl_dereference(pmc->sflist);
-	rtnl_unlock();
 	count = psl ? psl->sl_count : 0;
 	copycount = count < gsf->gf_numsrc ? count : gsf->gf_numsrc;
 	gsf->gf_numsrc = count;
@@ -2490,7 +2487,6 @@ int ip_mc_gsfget(struct sock *sk, struct group_filter *gsf,
 	}
 	return 0;
 done:
-	rtnl_unlock();
 	return err;
 }
 
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index c3c359a..2b12ed2 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -1251,11 +1251,22 @@ EXPORT_SYMBOL(compat_ip_setsockopt);
  *	the _received_ ones. The set sets the _sent_ ones.
  */
 
+static bool getsockopt_needs_rtnl(int optname)
+{
+	switch (optname) {
+	case IP_MSFILTER:
+	case MCAST_MSFILTER:
+		return true;
+	}
+	return false;
+}
+
 static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 			    char __user *optval, int __user *optlen, unsigned int flags)
 {
 	struct inet_sock *inet = inet_sk(sk);
-	int val;
+	bool needs_rtnl = getsockopt_needs_rtnl(optname);
+	int val, err;
 	int len;
 
 	if (level != SOL_IP)
@@ -1269,6 +1280,8 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 	if (len < 0)
 		return -EINVAL;
 
+	if (needs_rtnl)
+		rtnl_lock();
 	lock_sock(sk);
 
 	switch (optname) {
@@ -1389,17 +1402,16 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		int err;
 
 		if (len < IP_MSFILTER_SIZE(0)) {
-			release_sock(sk);
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 		if (copy_from_user(&msf, optval, IP_MSFILTER_SIZE(0))) {
-			release_sock(sk);
-			return -EFAULT;
+			err = -EFAULT;
+			goto out;
 		}
 		err = ip_mc_msfget(sk, &msf,
 				   (struct ip_msfilter __user *)optval, optlen);
-		release_sock(sk);
-		return err;
+		goto out;
 	}
 	case MCAST_MSFILTER:
 	{
@@ -1407,18 +1419,17 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 		int err;
 
 		if (len < GROUP_FILTER_SIZE(0)) {
-			release_sock(sk);
-			return -EINVAL;
+			err = -EINVAL;
+			goto out;
 		}
 		if (copy_from_user(&gsf, optval, GROUP_FILTER_SIZE(0))) {
-			release_sock(sk);
-			return -EFAULT;
+			err = -EFAULT;
+			goto out;
 		}
 		err = ip_mc_gsfget(sk, &gsf,
 				   (struct group_filter __user *)optval,
 				   optlen);
-		release_sock(sk);
-		return err;
+		goto out;
 	}
 	case IP_MULTICAST_ALL:
 		val = inet->mc_all;
@@ -1485,6 +1496,12 @@ static int do_ip_getsockopt(struct sock *sk, int level, int optname,
 			return -EFAULT;
 	}
 	return 0;
+
+out:
+	release_sock(sk);
+	if (needs_rtnl)
+		rtnl_unlock();
+	return err;
 }
 
 int ip_getsockopt(struct sock *sk, int level,
-- 
1.8.3.1
