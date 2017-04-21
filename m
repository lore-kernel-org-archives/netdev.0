From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: [Patch net] ip6mr: avoid double unregister of pim6reg device
Date: Fri, 21 Apr 2017 12:27:19 -0700
Message-ID: <1492802839-16851-1-git-send-email-xiyou.wangcong@gmail.com>
Cc: andreyknvl@google.com, Cong Wang <xiyou.wangcong@gmail.com>,
        Linus Torvalds <torvalds@linux-foundation.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:34802 "EHLO
        mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162297AbdDUT1a (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:27:30 -0400
Received: by mail-oi0-f68.google.com with SMTP id y11so20850017oie.1
        for <netdev@vger.kernel.org>; Fri, 21 Apr 2017 12:27:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If we unregister the pim6reg device via default_device_exit_batch(),
we will receive a notification and ip6mr_device_event() will
unregister it again. This causes a kernel BUG at net/core/dev.c:6813.

Like commit 7dc00c82cbb0 ("ipv4: Fix ipmr unregister device oops")
we should avoid double-unregister in netdevice notifier.

Reported-by: Andrey Konovalov <andreyknvl@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
---
 net/ipv6/ip6mr.c | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ip6mr.c b/net/ipv6/ip6mr.c
index 6ba6c90..72bee6d 100644
--- a/net/ipv6/ip6mr.c
+++ b/net/ipv6/ip6mr.c
@@ -774,7 +774,8 @@ static struct net_device *ip6mr_reg_vif(struct net *net, struct mr6_table *mrt)
  *	Delete a VIF entry
  */
 
-static int mif6_delete(struct mr6_table *mrt, int vifi, struct list_head *head)
+static int mif6_delete(struct mr6_table *mrt, int vifi, struct list_head *head,
+		       bool unreg)
 {
 	struct mif_device *v;
 	struct net_device *dev;
@@ -820,7 +821,7 @@ static int mif6_delete(struct mr6_table *mrt, int vifi, struct list_head *head)
 					     dev->ifindex, &in6_dev->cnf);
 	}
 
-	if (v->flags & MIFF_REGISTER)
+	if ((v->flags & MIFF_REGISTER) && unreg)
 		unregister_netdevice_queue(dev, head);
 
 	dev_put(dev);
@@ -1340,7 +1341,7 @@ static int ip6mr_device_event(struct notifier_block *this,
 		v = &mrt->vif6_table[0];
 		for (ct = 0; ct < mrt->maxvif; ct++, v++) {
 			if (v->dev == dev)
-				mif6_delete(mrt, ct, &list);
+				mif6_delete(mrt, ct, &list, false);
 		}
 	}
 	unregister_netdevice_many(&list);
@@ -1552,7 +1553,7 @@ static void mroute_clean_tables(struct mr6_table *mrt, bool all)
 	for (i = 0; i < mrt->maxvif; i++) {
 		if (!all && (mrt->vif6_table[i].flags & VIFF_STATIC))
 			continue;
-		mif6_delete(mrt, i, &list);
+		mif6_delete(mrt, i, &list, true);
 	}
 	unregister_netdevice_many(&list);
 
@@ -1707,7 +1708,7 @@ int ip6_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, uns
 		if (copy_from_user(&mifi, optval, sizeof(mifi_t)))
 			return -EFAULT;
 		rtnl_lock();
-		ret = mif6_delete(mrt, mifi, NULL);
+		ret = mif6_delete(mrt, mifi, NULL, true);
 		rtnl_unlock();
 		return ret;
 
-- 
2.5.5
