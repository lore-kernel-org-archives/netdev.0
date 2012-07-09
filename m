From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net-next 4/6] 6lowpan: rework fragment-deleting routine
Date: Mon,  9 Jul 2012 14:22:29 +0400
Message-ID: <1341829351-18485-5-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: netdev@vger.kernel.org,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: davem@davemloft.net, eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33420 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752996Ab2GIK0m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 06:26:42 -0400
Received: by mail-bk0-f46.google.com with SMTP id j10so5787740bkw.19
        for <netdev@vger.kernel.org>; Mon, 09 Jul 2012 03:26:41 -0700 (PDT)
In-Reply-To: <1341829351-18485-1-git-send-email-alex.bluesman.smirnov@gmail.com>
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
 net/ieee802154/6lowpan.c |   28 ++++++++++++++++------------
 1 files changed, 16 insertions(+), 12 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index b872515..e7de085 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -113,7 +113,6 @@ struct lowpan_dev_record {
 
 struct lowpan_fragment {
 	struct sk_buff		*skb;		/* skb to be assembled */
-	spinlock_t		lock;		/* concurency lock */
 	u16			length;		/* length to be assemled */
 	u32			bytes_rcv;	/* bytes received */
 	u16			tag;		/* current fragment tag */
@@ -761,7 +760,7 @@ lowpan_process_data(struct sk_buff *skb)
 		if ((frame->bytes_rcv == frame->length) &&
 		     frame->timer.expires > jiffies) {
 			/* if timer haven't expired - first of all delete it */
-			del_timer(&frame->timer);
+			del_timer_sync(&frame->timer);
 			list_del(&frame->list);
 			spin_unlock(&flist_lock);
 
@@ -1196,19 +1195,9 @@ static void lowpan_dellink(struct net_device *dev, struct list_head *head)
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
@@ -1264,9 +1253,24 @@ out:
 
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
