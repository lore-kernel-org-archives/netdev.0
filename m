From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 3/2] cxgb3 - Fix EEH, missing softirq blocking
Date: Thu, 06 Dec 2007 18:47:53 -0800
Message-ID: <20071207024753.15931.12103.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:21156 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752576AbXLGCr6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2007 21:47:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Divy Le Ray <divy@chelsio.com>

set_pci_drvdata() stores a pointer to the adapter,
not the net device.
Add missing softirq blocking in t3_mgmt_tx.

Signed-off-by: Divy Le Ray <divy@chlelsio.com>
---

 drivers/net/cxgb3/cxgb3_main.c |   14 ++++----------
 drivers/net/cxgb3/sge.c        |    7 ++++++-
 2 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_main.c
index d1aa777..0e3dcbf 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -2408,9 +2408,7 @@ void t3_fatal_err(struct adapter *adapter)
 static pci_ers_result_t t3_io_error_detected(struct pci_dev *pdev,
 					     pci_channel_state_t state)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct port_info *pi = netdev_priv(dev);
-	struct adapter *adapter = pi->adapter;
+	struct adapter *adapter = pci_get_drvdata(pdev);
 	int i;
 
 	/* Stop all ports */
@@ -2444,9 +2442,7 @@ static pci_ers_result_t t3_io_error_detected(struct pci_dev *pdev,
  */
 static pci_ers_result_t t3_io_slot_reset(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct port_info *pi = netdev_priv(dev);
-	struct adapter *adapter = pi->adapter;
+	struct adapter *adapter = pci_get_drvdata(pdev);
 
 	if (pci_enable_device(pdev)) {
 		dev_err(&pdev->dev,
@@ -2469,9 +2465,7 @@ static pci_ers_result_t t3_io_slot_reset(struct pci_dev *pdev)
  */
 static void t3_io_resume(struct pci_dev *pdev)
 {
-	struct net_device *dev = pci_get_drvdata(pdev);
-	struct port_info *pi = netdev_priv(dev);
-	struct adapter *adapter = pi->adapter;
+	struct adapter *adapter = pci_get_drvdata(pdev);
 	int i;
 
 	/* Restart the ports */
@@ -2491,7 +2485,7 @@ static void t3_io_resume(struct pci_dev *pdev)
 
 	if (is_offload(adapter)) {
 		__set_bit(OFFLOAD_DEVMAP_BIT, &adapter->registered_device_map);
-		if (offload_open(dev))
+		if (offload_open(adapter->port[0]))
 			printk(KERN_WARNING
 			       "Could not bring back offload capabilities\n");
 	}
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index cef153d..6367cee 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1364,7 +1364,12 @@ static void restart_ctrlq(unsigned long data)
  */
 int t3_mgmt_tx(struct adapter *adap, struct sk_buff *skb)
 {
-	return ctrl_xmit(adap, &adap->sge.qs[0].txq[TXQ_CTRL], skb);
+	int ret; 
+	local_bh_disable();
+	ret = ctrl_xmit(adap, &adap->sge.qs[0].txq[TXQ_CTRL], skb);
+	local_bh_enable();
+
+	return ret;
 }
 
 /**
