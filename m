From: roy.qing.li@gmail.com
Subject: [PATCH][net-next] ipv6: rework the lock in addrconf_permanent_addr
Date: Thu, 17 Mar 2016 11:39:15 +0800
Message-ID: <1458185955-7173-1-git-send-email-roy.qing.li@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:51275 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754035AbcCQDjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 23:39:17 -0400
Received: from localhost (lrq.corp.ad.wrs.com [128.224.162.186])
	by mail.windriver.com (8.15.2/8.15.1) with ESMTP id u2H3dGjl010088
	for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 20:39:16 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Li RongQing <roy.qing.li@gmail.com>

1. nothing of idev is changed, so read lock is enough
2. ifp is changed, so used ifp->lock or cmpxchg to protect it

Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
---
 net/ipv6/addrconf.c | 26 ++++++++++++++++++++------
 1 file changed, 20 insertions(+), 6 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 8c0dab2..08a9ee9 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3178,14 +3178,21 @@ static void addrconf_gre_config(struct net_device *dev)
 static void l3mdev_check_host_rt(struct inet6_dev *idev,
 				  struct inet6_ifaddr *ifp)
 {
+	struct rt6_info *rt = NULL;
+
+	spin_lock(&ifp->lock);
 	if (ifp->rt) {
 		u32 tb_id = l3mdev_fib_table(idev->dev) ? : RT6_TABLE_LOCAL;
 
 		if (tb_id != ifp->rt->rt6i_table->tb6_id) {
-			ip6_del_rt(ifp->rt);
+			rt = ifp->rt;
 			ifp->rt = NULL;
 		}
 	}
+	spin_unlock(&ifp->lock);
+
+	if (rt)
+		ip6_del_rt(rt);
 }
 #else
 static void l3mdev_check_host_rt(struct inet6_dev *idev,
@@ -3197,6 +3204,8 @@ static void l3mdev_check_host_rt(struct inet6_dev *idev,
 static int fixup_permanent_addr(struct inet6_dev *idev,
 				struct inet6_ifaddr *ifp)
 {
+	struct rt6_info *prev;
+
 	l3mdev_check_host_rt(idev, ifp);
 
 	if (!ifp->rt) {
@@ -3206,7 +3215,12 @@ static int fixup_permanent_addr(struct inet6_dev *idev,
 		if (unlikely(IS_ERR(rt)))
 			return PTR_ERR(rt);
 
-		ifp->rt = rt;
+		prev = cmpxchg(&ifp->rt, NULL, rt);
+
+		/*if cmpxchg failed*/
+		if (prev) {
+			ip6_rt_put(rt);
+		}
 	}
 
 	if (!(ifp->flags & IFA_F_NOPREFIXROUTE)) {
@@ -3228,21 +3242,21 @@ static void addrconf_permanent_addr(struct net_device *dev)
 	if (!idev)
 		return;
 
-	write_lock_bh(&idev->lock);
+	read_lock_bh(&idev->lock);
 
 	list_for_each_entry_safe(ifp, tmp, &idev->addr_list, if_list) {
 		if ((ifp->flags & IFA_F_PERMANENT) &&
 		    fixup_permanent_addr(idev, ifp) < 0) {
-			write_unlock_bh(&idev->lock);
+			read_unlock_bh(&idev->lock);
 			ipv6_del_addr(ifp);
-			write_lock_bh(&idev->lock);
+			read_lock_bh(&idev->lock);
 
 			net_info_ratelimited("%s: Failed to add prefix route for address %pI6c; dropping\n",
 					     idev->dev->name, &ifp->addr);
 		}
 	}
 
-	write_unlock_bh(&idev->lock);
+	read_unlock_bh(&idev->lock);
 }
 
 static int addrconf_notify(struct notifier_block *this, unsigned long event,
-- 
2.1.4
