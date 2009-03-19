From: Sathya Perla <sathyap@serverengines.com>
Subject: [PATCH 1/2] be2net: replenish when posting to rx-queue is starved
 in out of mem conditions
Date: Thu, 19 Mar 2009 14:43:01 +0530
Message-ID: <1237453981.6210.21.camel@sperla-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail142.messagelabs.com ([216.82.249.99]:21371 "EHLO
	mail142.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755023AbZCSJNJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 05:13:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi, this is a patch to replenish the rx-queue when it is in a starved
state (due to out-of-mem conditions)

thanks,
-Sathya
P.S: Pls ignore the "company confidential" warning at the end of the
patch emails.


Signed-off-by: Sathya Perla <sathyap@serverengines.com>
---
 drivers/net/benet/be.h      |    1 +
 drivers/net/benet/be_main.c |   50 +++++++++++++++++++++++++------------------
 2 files changed, 30 insertions(+), 21 deletions(-)

diff --git a/drivers/net/benet/be.h b/drivers/net/benet/be.h
index 63d593d..f327be5 100644
--- a/drivers/net/benet/be.h
+++ b/drivers/net/benet/be.h
@@ -194,6 +194,7 @@ struct be_adapter {
 	struct be_eq_obj rx_eq;
 	struct be_rx_obj rx_obj;
 	u32 big_page_size;	/* Compounded page size shared by rx wrbs */
+	bool rx_post_starved;	/* Zero rx frags have been posted to BE */
 
 	struct vlan_group *vlan_grp;
 	u16 num_vlans;
diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 897a63d..80fe1e0 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -273,26 +273,6 @@ static void be_rx_eqd_update(struct be_adapter *adapter)
 	rx_eq->cur_eqd = eqd;
 }
 
-static void be_worker(struct work_struct *work)
-{
-	struct be_adapter *adapter =
-		container_of(work, struct be_adapter, work.work);
-	int status;
-
-	/* Check link */
-	be_link_status_update(adapter);
-
-	/* Get Stats */
-	status = be_cmd_get_stats(&adapter->ctrl, &adapter->stats.cmd);
-	if (!status)
-		netdev_stats_update(adapter);
-
-	/* Set EQ delay */
-	be_rx_eqd_update(adapter);
-
-	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
-}
-
 static struct net_device_stats *be_get_stats(struct net_device *dev)
 {
 	struct be_adapter *adapter = netdev_priv(dev);
@@ -900,8 +880,11 @@ static void be_post_rx_frags(struct be_adapter *adapter)
 		page_info->last_page_user = true;
 
 	if (posted) {
-		be_rxq_notify(&adapter->ctrl, rxq->id, posted);
 		atomic_add(posted, &rxq->used);
+		be_rxq_notify(&adapter->ctrl, rxq->id, posted);
+	} else if (atomic_read(&rxq->used) == 0) {
+		/* Let be_worker replenish when memory is available */
+		adapter->rx_post_starved = true;
 	}
 
 	return;
@@ -1305,6 +1288,31 @@ int be_poll_tx(struct napi_struct *napi, int budget)
 	return 1;
 }
 
+static void be_worker(struct work_struct *work)
+{
+	struct be_adapter *adapter =
+		container_of(work, struct be_adapter, work.work);
+	int status;
+
+	/* Check link */
+	be_link_status_update(adapter);
+
+	/* Get Stats */
+	status = be_cmd_get_stats(&adapter->ctrl, &adapter->stats.cmd);
+	if (!status)
+		netdev_stats_update(adapter);
+
+	/* Set EQ delay */
+	be_rx_eqd_update(adapter);
+
+	if (adapter->rx_post_starved) {
+		adapter->rx_post_starved = false;
+		be_post_rx_frags(adapter);
+	}
+
+	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
+}
+
 static void be_msix_enable(struct be_adapter *adapter)
 {
 	int i, status;
-- 
1.5.6.3





___________________________________________________________________________________
This message, together with any attachment(s), contains confidential and proprietary information of
ServerEngines Corporation and is intended only for the designated recipient(s) named above. Any unauthorized
review, printing, retention, copying, disclosure or distribution is strictly prohibited.  If you are not the
intended recipient of this message, please immediately advise the sender by reply email message and
delete all copies of this message and any attachment(s). Thank you.

