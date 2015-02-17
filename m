From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] igmp: add __ip_mc_{join|leave}_group()
Date: Tue, 17 Feb 2015 03:19:24 -0800
Message-ID: <1424171964.4942.78.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1424125238-4505-1-git-send-email-challa@noironetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Madhu Challa <challa@noironetworks.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f43.google.com ([209.85.216.43]:43741 "EHLO
	mail-qa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753976AbbBQLT1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2015 06:19:27 -0500
Received: by mail-qa0-f43.google.com with SMTP id bm13so25848120qab.2
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2015 03:19:26 -0800 (PST)
In-Reply-To: <1424125238-4505-1-git-send-email-challa@noironetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

There is a need to perform igmp join/leave operations while RTNL is
held.

Make ip_mc_{join|leave}_group() wrappers around 
__ip_mc_{join|leave}_group() to avoid the proliferation of work queues.

For example, vxlan_igmp_join() could possibly be removed.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/igmp.h |    2 +
 net/ipv4/igmp.c      |   52 ++++++++++++++++++++++++++---------------
 2 files changed, 36 insertions(+), 18 deletions(-)

diff --git a/include/linux/igmp.h b/include/linux/igmp.h
index 2c677afeea4782c96b79d0d8ede4846d87783b99..b5a6470e686c436f619ee086cbdfc3ece389db35 100644
--- a/include/linux/igmp.h
+++ b/include/linux/igmp.h
@@ -111,7 +111,9 @@ struct ip_mc_list {
 
 extern int ip_check_mc_rcu(struct in_device *dev, __be32 mc_addr, __be32 src_addr, u16 proto);
 extern int igmp_rcv(struct sk_buff *);
+extern int __ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
 extern int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr);
+extern int __ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
 extern int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr);
 extern void ip_mc_drop_socket(struct sock *sk);
 extern int ip_mc_source(int add, int omode, struct sock *sk,
diff --git a/net/ipv4/igmp.c b/net/ipv4/igmp.c
index 666cf364df86dffbab3cd2b7b1ea66e72d3ac7a8..4b1172d73e0309766d6d1a70473dd4c14d2c6fc0 100644
--- a/net/ipv4/igmp.c
+++ b/net/ipv4/igmp.c
@@ -1849,30 +1849,25 @@ static void ip_mc_clear_src(struct ip_mc_list *pmc)
 	pmc->sfcount[MCAST_EXCLUDE] = 1;
 }
 
-
-/*
- * Join a multicast group
- */
-int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
+int __ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
 {
-	int err;
 	__be32 addr = imr->imr_multiaddr.s_addr;
-	struct ip_mc_socklist *iml = NULL, *i;
+	struct ip_mc_socklist *iml, *i;
 	struct in_device *in_dev;
 	struct inet_sock *inet = inet_sk(sk);
 	struct net *net = sock_net(sk);
 	int ifindex;
 	int count = 0;
+	int err;
+
+	ASSERT_RTNL();
 
 	if (!ipv4_is_multicast(addr))
 		return -EINVAL;
 
-	rtnl_lock();
-
 	in_dev = ip_mc_find_dev(net, imr);
 
 	if (!in_dev) {
-		iml = NULL;
 		err = -ENODEV;
 		goto done;
 	}
@@ -1900,9 +1895,22 @@ int ip_mc_join_group(struct sock *sk , struct ip_mreqn *imr)
 	ip_mc_inc_group(in_dev, addr);
 	err = 0;
 done:
-	rtnl_unlock();
 	return err;
 }
+EXPORT_SYMBOL(__ip_mc_join_group);
+
+/* Join a multicast group
+ */
+int ip_mc_join_group(struct sock *sk, struct ip_mreqn *imr)
+{
+	int ret;
+
+	rtnl_lock();
+	ret = __ip_mc_join_group(sk, imr);
+	rtnl_unlock();
+
+	return ret;
+}
 EXPORT_SYMBOL(ip_mc_join_group);
 
 static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
@@ -1925,11 +1933,7 @@ static int ip_mc_leave_src(struct sock *sk, struct ip_mc_socklist *iml,
 	return err;
 }
 
-/*
- *	Ask a socket to leave a group.
- */
-
-int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
+int __ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 {
 	struct inet_sock *inet = inet_sk(sk);
 	struct ip_mc_socklist *iml;
@@ -1940,7 +1944,8 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 	u32 ifindex;
 	int ret = -EADDRNOTAVAIL;
 
-	rtnl_lock();
+	ASSERT_RTNL();
+
 	in_dev = ip_mc_find_dev(net, imr);
 	if (!in_dev) {
 		ret = -ENODEV;
@@ -1964,14 +1969,25 @@ int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
 		*imlp = iml->next_rcu;
 
 		ip_mc_dec_group(in_dev, group);
-		rtnl_unlock();
+
 		/* decrease mem now to avoid the memleak warning */
 		atomic_sub(sizeof(*iml), &sk->sk_omem_alloc);
 		kfree_rcu(iml, rcu);
 		return 0;
 	}
 out:
+	return ret;
+}
+EXPORT_SYMBOL(__ip_mc_leave_group);
+
+int ip_mc_leave_group(struct sock *sk, struct ip_mreqn *imr)
+{
+	int ret;
+
+	rtnl_lock();
+	ret = __ip_mc_leave_group(sk, imr);
 	rtnl_unlock();
+
 	return ret;
 }
 EXPORT_SYMBOL(ip_mc_leave_group);
