From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next v2 7/7] 6lowpan: rework fragment-deleting routine
Date: Wed, 11 Jul 2012 11:22:48 +0400
Message-ID: <1341991368-11800-8-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:32780 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932078Ab2GKH1J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Jul 2012 03:27:09 -0400
Received: by mail-wg0-f44.google.com with SMTP id dr13so745049wgb.1
        for <netdev@vger.kernel.org>; Wed, 11 Jul 2012 00:27:08 -0700 (PDT)
In-Reply-To: <1341991368-11800-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

6lowpan module starts collecting incomming frames and fragments
right after lowpan_module_init() therefor it will be better to
clean unfinished fragments in lowpan_cleanup_module() function
instead of doing it when link goes down.

Changed spinlocks type to prevent deadlock with expired timer event
and removed unused one.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |   39 ++++++++++++++++++++-------------------
 1 files changed, 20 insertions(+), 19 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 2e790fb..6871ec1 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -113,7 +113,6 @@ struct lowpan_dev_record {
 
 struct lowpan_fragment {
 	struct sk_buff		*skb;		/* skb to be assembled */
-	spinlock_t		lock;		/* concurency lock */
 	u16			length;		/* length to be assemled */
 	u32			bytes_rcv;	/* bytes received */
 	u16			tag;		/* current fragment tag */
@@ -637,10 +636,7 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
 
 	pr_debug("timer expired for frame with tag %d\n", entry->tag);
 
-	spin_lock(&flist_lock);
 	list_del(&entry->list);
-	spin_unlock(&flist_lock);
-
 	dev_kfree_skb(entry->skb);
 	kfree(entry);
 }
@@ -727,7 +723,7 @@ lowpan_process_data(struct sk_buff *skb)
 		 * check if frame assembling with the same tag is
 		 * already in progress
 		 */
-		spin_lock(&flist_lock);
+		spin_lock_bh(&flist_lock);
 
 		list_for_each_entry(frame, &lowpan_fragments, list)
 			if (frame->tag == tag) {
@@ -761,9 +757,9 @@ lowpan_process_data(struct sk_buff *skb)
 		if ((frame->bytes_rcv == frame->length) &&
 		     frame->timer.expires > jiffies) {
 			/* if timer haven't expired - first of all delete it */
-			del_timer(&frame->timer);
+			del_timer_sync(&frame->timer);
 			list_del(&frame->list);
-			spin_unlock(&flist_lock);
+			spin_unlock_bh(&flist_lock);
 
 			dev_kfree_skb(skb);
 			skb = frame->skb;
@@ -774,7 +770,7 @@ lowpan_process_data(struct sk_buff *skb)
 
 			break;
 		}
-		spin_unlock(&flist_lock);
+		spin_unlock_bh(&flist_lock);
 
 		return kfree_skb(skb), 0;
 	}
@@ -929,7 +925,7 @@ lowpan_process_data(struct sk_buff *skb)
 	return lowpan_skb_deliver(skb, &hdr);
 
 unlock_and_drop:
-	spin_unlock(&flist_lock);
+	spin_unlock_bh(&flist_lock);
 drop:
 	kfree_skb(skb);
 	return -EINVAL;
@@ -1196,19 +1192,9 @@ static void lowpan_dellink(struct net_device *dev, struct list_head *head)
 	struct lowpan_dev_info *lowpan_dev = lowpan_dev_info(dev);
 	struct net_device *real_dev = lowpan_dev->real_dev;
 	struct lowpan_dev_record *entry, *tmp;
-	struct lowpan_fragment *frame, *tframe;
 
 	ASSERT_RTNL();
 
-	spin_lock(&flist_lock);
-	list_for_each_entry_safe(frame, tframe, &lowpan_fragments, list) {
-		del_timer(&frame->timer);
-		list_del(&frame->list);
-		dev_kfree_skb(frame->skb);
-		kfree(frame);
-	}
-	spin_unlock(&flist_lock);
-
 	mutex_lock(&lowpan_dev_info(dev)->dev_list_mtx);
 	list_for_each_entry_safe(entry, tmp, &lowpan_devices, list) {
 		if (entry->ldev == dev) {
@@ -1264,9 +1250,24 @@ out:
 
 static void __exit lowpan_cleanup_module(void)
 {
+	struct lowpan_fragment *frame, *tframe;
+
 	lowpan_netlink_fini();
 
 	dev_remove_pack(&lowpan_packet_type);
+
+	/* Now 6lowpan packet_type is removed, so no new fragments are
+	 * expected on RX, therefore that's the time to clean incomplete
+	 * fragments.
+	 */
+	spin_lock_bh(&flist_lock);
+	list_for_each_entry_safe(frame, tframe, &lowpan_fragments, list) {
+		del_timer_sync(&frame->timer);
+		list_del(&frame->list);
+		dev_kfree_skb(frame->skb);
+		kfree(frame);
+	}
+	spin_unlock_bh(&flist_lock);
 }
 
 module_init(lowpan_init_module);
-- 
1.7.2.3
