From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Subject: [PATCH net 2/3] 6lowpan: clean up fragments list if module unloaded
Date: Thu, 26 Apr 2012 13:24:57 +0400
Message-ID: <1335432298-17161-3-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1335432298-17161-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Cc: davem@davemloft.net, linux-zigbee-devel@lists.sourceforge.net,
	Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:53340 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754882Ab2DZJbJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2012 05:31:09 -0400
Received: by wgbdr13 with SMTP id dr13so1014313wgb.1
        for <netdev@vger.kernel.org>; Thu, 26 Apr 2012 02:31:08 -0700 (PDT)
In-Reply-To: <1335432298-17161-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Clean all the pending fragments and relative timers if 6lowpan link
is going to be deleted.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
---
 net/ieee802154/6lowpan.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 7ce508f..a21ca6e 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1177,11 +1177,20 @@ static void lowpan_dellink(struct net_device *dev, struct list_head *head)
 {
 	struct lowpan_dev_info *lowpan_dev = lowpan_dev_info(dev);
 	struct net_device *real_dev = lowpan_dev->real_dev;
-	struct lowpan_dev_record *entry;
-	struct lowpan_dev_record *tmp;
+	struct lowpan_dev_record *entry, *tmp;
+	struct lowpan_fragment *frame, *tframe;
 
 	ASSERT_RTNL();
 
+	spin_lock(&flist_lock);
+	list_for_each_entry_safe(frame, tframe, &lowpan_fragments, list) {
+		del_timer(&frame->timer);
+		list_del(&frame->list);
+		dev_kfree_skb(frame->skb);
+		kfree(frame);
+	}
+	spin_unlock(&flist_lock);
+
 	mutex_lock(&lowpan_dev_info(dev)->dev_list_mtx);
 	list_for_each_entry_safe(entry, tmp, &lowpan_devices, list) {
 		if (entry->ldev == dev) {
-- 
1.7.2.3
