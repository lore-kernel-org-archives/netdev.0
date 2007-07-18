From: Denis Cheng <crquan@gmail.com>
Subject: [PATCH 1/3] [net/core] move dev_mc_discard from dev_mcast.c to dev.c
Date: Wed, 18 Jul 2007 10:41:03 +0800
Message-ID: <11847264651509-git-send-email-crquan@gmail.com>
References: <11846606051099-git-send-email-crquan@gmail.com>
Cc: Pekka Savola <pekkas@netcore.fi>, James Morris <jmorris@namei.org>,
	Patrick McHardy <kaber@coreworks.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Denis Cheng <crquan@gmail.com>
To: "David S. Miller" <davem@davemloft.net>,
	Networking Team <netdev@vger.kernel.org>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from qb-out-0506.google.com ([72.14.204.234]:63963 "EHLO
	qb-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760746AbXGRCk5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2007 22:40:57 -0400
Received: by qb-out-0506.google.com with SMTP id e11so42986qbe
        for <netdev@vger.kernel.org>; Tue, 17 Jul 2007 19:40:56 -0700 (PDT)
In-Reply-To: <11846606051099-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because this function is only called by unregister_netdevice,
this moving could make this non-global function static,
and also remove its declaration in netdevice.h;

Any further, function __dev_addr_discard is also just called by
dev_mc_discard and dev_unicast_discard, keeping this two functions
both in one c file could make __dev_addr_discard also static
and remove its declaration in netdevice.h;

Futhermore, the sequential call to dev_unicast_discard and then
dev_mc_discard in unregister_netdevice have a similar mechanism that:
(netif_tx_lock_bh / __dev_addr_discard / netif_tx_unlock_bh),
they should merged into one to eliminate duplicates in acquiring and
releasing the dev->_xmit_lock, this would be done in my following patch.

Signed-off-by: Denis Cheng <crquan@gmail.com>
---
 include/linux/netdevice.h |    2 --
 net/core/dev.c            |   14 +++++++++++++-
 net/core/dev_mcast.c      |   12 ------------
 3 files changed, 13 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index da7a13c..9820ca1 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1098,10 +1098,8 @@ extern int 		dev_mc_delete(struct net_device *dev, void *addr, int alen, int all
 extern int		dev_mc_add(struct net_device *dev, void *addr, int alen, int newonly);
 extern int		dev_mc_sync(struct net_device *to, struct net_device *from);
 extern void		dev_mc_unsync(struct net_device *to, struct net_device *from);
-extern void		dev_mc_discard(struct net_device *dev);
 extern int 		__dev_addr_delete(struct dev_addr_list **list, int *count, void *addr, int alen, int all);
 extern int		__dev_addr_add(struct dev_addr_list **list, int *count, void *addr, int alen, int newonly);
-extern void		__dev_addr_discard(struct dev_addr_list **list);
 extern void		dev_set_promiscuity(struct net_device *dev, int inc);
 extern void		dev_set_allmulti(struct net_device *dev, int inc);
 extern void		netdev_state_change(struct net_device *dev);
diff --git a/net/core/dev.c b/net/core/dev.c
index 13a0d9f..3ba63aa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2715,7 +2715,7 @@ int __dev_addr_add(struct dev_addr_list **list, int *count,
 	return 0;
 }
 
-void __dev_addr_discard(struct dev_addr_list **list)
+static void __dev_addr_discard(struct dev_addr_list **list)
 {
 	struct dev_addr_list *tmp;
 
@@ -2785,6 +2785,18 @@ static void dev_unicast_discard(struct net_device *dev)
 	netif_tx_unlock_bh(dev);
 }
 
+/*
+ *	Discard multicast list when a device is downed
+ */
+
+static void dev_mc_discard(struct net_device *dev)
+{
+	netif_tx_lock_bh(dev);
+	__dev_addr_discard(&dev->mc_list);
+	dev->mc_count = 0;
+	netif_tx_unlock_bh(dev);
+}
+
 unsigned dev_get_flags(const struct net_device *dev)
 {
 	unsigned flags;
diff --git a/net/core/dev_mcast.c b/net/core/dev_mcast.c
index 235a2a8..99aece1 100644
--- a/net/core/dev_mcast.c
+++ b/net/core/dev_mcast.c
@@ -177,18 +177,6 @@ void dev_mc_unsync(struct net_device *to, struct net_device *from)
 }
 EXPORT_SYMBOL(dev_mc_unsync);
 
-/*
- *	Discard multicast list when a device is downed
- */
-
-void dev_mc_discard(struct net_device *dev)
-{
-	netif_tx_lock_bh(dev);
-	__dev_addr_discard(&dev->mc_list);
-	dev->mc_count = 0;
-	netif_tx_unlock_bh(dev);
-}
-
 #ifdef CONFIG_PROC_FS
 static void *dev_mc_seq_start(struct seq_file *seq, loff_t *pos)
 {
-- 
1.5.2.2

