From: Somnath Kotur <somnath.kotur@emulex.com>
Subject: [PATCH net-next-2.6] be2net: Schedule/Destroy worker thread in
 probe()/remove() rather than open()/close()
Date: Tue, 26 Oct 2010 14:31:03 +0530
Message-ID: <20101026090102.GA2460@emulex.com>
Reply-To: Somnath Kotur <somnath.kotur@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:3471 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752092Ab0JZJBa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Oct 2010 05:01:30 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When async mcc compls are rcvd on an i/f that is down (and so interrupts are disabled)
they just lie unprocessed in the compl queue.The compl queue can eventually get filled
up and cause the BE to lock up.The fix is to use be_worker to reap mcc compls when the
i/f is down.be_worker is now launched in be_probe() and canceled in be_remove().

Signed-off-by: Somnath Kotur <somnath.kotur@emulex.com>
---
 drivers/net/benet/be_main.c |   22 ++++++++++++++++++----
 1 files changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index 45b1f66..deb546e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -1806,6 +1806,20 @@ static void be_worker(struct work_struct *work)
 	struct be_rx_obj *rxo;
 	int i;
 
+	/* when interrupts are not yet enabled, just reap any pending
+	* mcc completions */
+	if (!netif_running(adapter->netdev)) {
+		int mcc_compl, status = 0;
+
+		mcc_compl = be_process_mcc(adapter, &status);
+
+		if (mcc_compl) {
+			struct be_mcc_obj *mcc_obj = &adapter->mcc_obj;
+			be_cq_notify(adapter, mcc_obj->cq.id, false, mcc_compl);
+		}
+		goto reschedule;
+	}
+
 	if (!adapter->stats_ioctl_sent)
 		be_cmd_get_stats(adapter, &adapter->stats_cmd);
 
@@ -1824,6 +1838,7 @@ static void be_worker(struct work_struct *work)
 	if (!adapter->ue_detected)
 		be_detect_dump_ue(adapter);
 
+reschedule:
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(1000));
 }
 
@@ -2019,8 +2034,6 @@ static int be_close(struct net_device *netdev)
 	struct be_eq_obj *tx_eq = &adapter->tx_eq;
 	int vec, i;
 
-	cancel_delayed_work_sync(&adapter->work);
-
 	be_async_mcc_disable(adapter);
 
 	netif_stop_queue(netdev);
@@ -2085,8 +2098,6 @@ static int be_open(struct net_device *netdev)
 	/* Now that interrupts are on we can process async mcc */
 	be_async_mcc_enable(adapter);
 
-	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
-
 	status = be_cmd_link_status_query(adapter, &link_up, &mac_speed,
 			&link_speed);
 	if (status)
@@ -2715,6 +2726,8 @@ static void __devexit be_remove(struct pci_dev *pdev)
 	if (!adapter)
 		return;
 
+	cancel_delayed_work_sync(&adapter->work);
+
 	unregister_netdev(adapter->netdev);
 
 	be_clear(adapter);
@@ -2870,6 +2883,7 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		goto unsetup;
 
 	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
+	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
 
 unsetup:
-- 
1.5.6.1

