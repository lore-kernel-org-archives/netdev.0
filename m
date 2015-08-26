From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next] cxgb4: continue in debug mode, if probe fails
Date: Wed, 26 Aug 2015 22:30:35 +0530
Message-ID: <1440608435-12039-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:21838 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932084AbbHZRAk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Aug 2015 13:00:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If adapter is flashed with incorrect firmware, probe can fail.
If probe fails, continue in debug mode, so one can also use the debug
interface to update the firmware via ethtool.

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 9 ++++++---
 1 file changed, 6 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index f35dd22..422765d 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -4726,12 +4726,13 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 
 	setup_memwin(adapter);
 	err = adap_init0(adapter);
+	if (err)
+		dev_err(&pdev->dev, "Adapter initialization failed, error %d.  "
+			"Continuing in debug mode\n", -err);
 #ifdef CONFIG_DEBUG_FS
 	bitmap_zero(adapter->sge.blocked_fl, adapter->sge.egr_sz);
 #endif
 	setup_memwin_rdma(adapter);
-	if (err)
-		goto out_unmap_bar;
 
 	for_each_port(adapter, i) {
 		struct net_device *netdev;
@@ -4799,6 +4800,8 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	 * soon as the first register_netdev completes.
 	 */
 	cfg_queues(adapter);
+	if (!(adapter->flags & FW_OK))
+		goto fw_attach_fail;
 
 	adapter->l2t = t4_init_l2t(adapter->l2t_start, adapter->l2t_end);
 	if (!adapter->l2t) {
@@ -4851,6 +4854,7 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 	if (err)
 		goto out_free_dev;
 
+fw_attach_fail:
 	/*
 	 * The card is now ready to go.  If any errors occur during device
 	 * registration we do not fail the whole card but rather proceed only
@@ -4901,7 +4905,6 @@ sriov:
 
  out_free_dev:
 	free_some_resources(adapter);
- out_unmap_bar:
 	if (!is_t4(adapter->params.chip))
 		iounmap(adapter->bar2);
  out_free_adapter:
-- 
2.3.4
