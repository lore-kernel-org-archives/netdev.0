From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] Alternative hidden netwirk device interface
Date: Mon, 29 Jan 2007 14:09:58 -0800
Message-ID: <20070129140958.0cf6880f@freekitty>
References: <20070129184707.885764375.midnight@suse.cz>
	<20070129102814.6385ad2d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Stephen Hemminger <shemminger@osdl.org>,
	David Miller <davem@davemloft.net>
To: Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:59109 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614AbXA2WNA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 17:13:00 -0500
In-Reply-To: <20070129102814.6385ad2d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Change to allow register_netdevice() to be called with a blank name.
If name is blank, it is not put in name hash list, and doesn't
show up in /sys or /proc

Compile tested only...

---
 net/core/dev.c |   56 +++++++++++++++++++++++++++++++++-----------------------
 1 files changed, 33 insertions(+), 23 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index e660cb5..91f64e7 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -737,7 +737,7 @@ int dev_change_name(struct net_device *d
 	if (dev->flags & IFF_UP)
 		return -EBUSY;
 
-	if (!dev_valid_name(newname))
+	if (hlist_unhashed(&dev->name_hlist) || !dev_valid_name(newname))
 		return -EINVAL;
 
 	if (strchr(newname, '%')) {
@@ -2108,6 +2108,10 @@ void dev_seq_stop(struct seq_file *seq, 
 
 static void dev_seq_printf_stats(struct seq_file *seq, struct net_device *dev)
 {
+	/* hidden device */
+	if (hlist_unhashed(&dev->name_hlist))
+		return;
+
 	if (dev->get_stats) {
 		struct net_device_stats *stats = dev->get_stats(dev);
 
@@ -2868,10 +2872,6 @@ static inline void net_set_todo(struct n
  *
  *	Callers must hold the rtnl semaphore. You may want
  *	register_netdev() instead of this.
- *
- *	BUGS:
- *	The locking appears insufficient to guarantee two parallel registers
- *	will not get the same name.
  */
 
 int register_netdevice(struct net_device *dev)
@@ -2907,7 +2907,7 @@ #endif
 		}
 	}
  
-	if (!dev_valid_name(dev->name)) {
+	if (dev->name[0] && !dev_valid_name(dev->name)) {
 		ret = -EINVAL;
 		goto out;
 	}
@@ -2917,15 +2917,18 @@ #endif
 		dev->iflink = dev->ifindex;
 
 	/* Check for existence of name */
-	head = dev_name_hash(dev->name);
-	hlist_for_each(p, head) {
-		struct net_device *d
-			= hlist_entry(p, struct net_device, name_hlist);
-		if (!strncmp(d->name, dev->name, IFNAMSIZ)) {
-			ret = -EEXIST;
- 			goto out;
+	if (dev->name[0]) {
+		head = dev_name_hash(dev->name);
+		hlist_for_each(p, head) {
+			struct net_device *d
+				= hlist_entry(p, struct net_device, name_hlist);
+			if (!strncmp(d->name, dev->name, IFNAMSIZ)) {
+				ret = -EEXIST;
+				goto out;
+			}
 		}
- 	}
+	} else
+		head = NULL;
 
 	/* Fix illegal SG+CSUM combinations. */
 	if ((dev->features & NETIF_F_SG) &&
@@ -2945,14 +2948,14 @@ #endif
 	if (dev->features & NETIF_F_UFO) {
 		if (!(dev->features & NETIF_F_HW_CSUM)) {
 			printk(KERN_ERR "%s: Dropping NETIF_F_UFO since no "
-					"NETIF_F_HW_CSUM feature.\n",
-							dev->name);
+			       "NETIF_F_HW_CSUM feature.\n",
+			       dev->name);
 			dev->features &= ~NETIF_F_UFO;
 		}
 		if (!(dev->features & NETIF_F_SG)) {
 			printk(KERN_ERR "%s: Dropping NETIF_F_UFO since no "
-					"NETIF_F_SG feature.\n",
-					dev->name);
+			       "NETIF_F_SG feature.\n",
+			       dev->name);
 			dev->features &= ~NETIF_F_UFO;
 		}
 	}
@@ -2965,8 +2968,7 @@ #endif
 	if (!dev->rebuild_header)
 		dev->rebuild_header = default_rebuild_header;
 
-	ret = netdev_register_sysfs(dev);
-	if (ret)
+	if (head && (ret = netdev_register_sysfs(dev)))
 		goto out;
 	dev->reg_state = NETREG_REGISTERED;
 
@@ -2982,7 +2984,12 @@ #endif
 	write_lock_bh(&dev_base_lock);
 	*dev_tail = dev;
 	dev_tail = &dev->next;
-	hlist_add_head(&dev->name_hlist, head);
+
+	if (head) 
+		hlist_add_head(&dev->name_hlist, head);
+	else
+		INIT_HLIST_NODE(&dev->name_hlist);
+		
 	hlist_add_head(&dev->index_hlist, dev_index_hash(dev->ifindex));
 	dev_hold(dev);
 	write_unlock_bh(&dev_base_lock);
@@ -3013,8 +3020,10 @@ int register_netdev(struct net_device *d
 {
 	int err;
 
-	rtnl_lock();
+	if (!dev->name[0])
+		return -EINVAL;
 
+	rtnl_lock();
 	/*
 	 * If the name is a format string the caller wants us to do a
 	 * name allocation.
@@ -3271,7 +3280,8 @@ int unregister_netdevice(struct net_devi
 	for (dp = &dev_base; (d = *dp) != NULL; dp = &d->next) {
 		if (d == dev) {
 			write_lock_bh(&dev_base_lock);
-			hlist_del(&dev->name_hlist);
+			if (!hlist_unhashed(&dev->name_hlist))
+				hlist_del(&dev->name_hlist);
 			hlist_del(&dev->index_hlist);
 			if (dev_tail == &dev->next)
 				dev_tail = dp;
-- 
1.4.1

