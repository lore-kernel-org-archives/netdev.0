From: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 3/5] 6lowpan: clean up fragments list
	if module unloaded
Date: Tue, 24 Apr 2012 14:51:09 +0400
Message-ID: <1335264671-27127-4-git-send-email-alex.bluesman.smirnov@gmail.com>
References: <1335264671-27127-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <1335264671-27127-1-git-send-email-alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Clean all the pending fragments and timers if 6lowpan link
is going to be deleted.

Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 net/ieee802154/6lowpan.c |   13 +++++++++++--
 1 files changed, 11 insertions(+), 2 deletions(-)

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index d440233..a57174e 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -1192,11 +1192,20 @@ static void lowpan_dellink(struct net_device *dev, struct list_head *head)
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


------------------------------------------------------------------------------
Live Security Virtual Conference
Exclusive live event will cover all the ways today's security and 
threat landscape has changed and how IT managers can respond. Discussions 
will include endpoint security, mobile security and the latest in malware 
threats. http://www.accelacomm.com/jaw/sfrnl04242012/114/50122263/
