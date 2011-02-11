From: Ajit Khaparde <ajit.khaparde@emulex.com>
Subject: [PATCH net-next 05/15] be2net: call be_vf_eth_addr_config() after
 register_netdev
Date: Fri, 11 Feb 2011 17:35:41 -0600
Message-ID: <20110211233540.GA18355@akhaparde-VBox>
Reply-To: Ajit Khaparde <ajit.khaparde@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exht1.emulex.com ([138.239.113.183]:51184 "EHLO
	exht1.ad.emulex.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1757118Ab1BKXgD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Feb 2011 18:36:03 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to avoid the completion processing for be_vf_eth_addr_config
to consume the link status notification before netdev_register.
Otherwise this causes the PF miss its first link status update.

Signed-off-by: Ajit Khaparde <ajit.khaparde@emulex.com>
---
 drivers/net/benet/be_main.c |   17 ++++++++---------
 1 files changed, 8 insertions(+), 9 deletions(-)

diff --git a/drivers/net/benet/be_main.c b/drivers/net/benet/be_main.c
index c8075c1..48eef9e 100644
--- a/drivers/net/benet/be_main.c
+++ b/drivers/net/benet/be_main.c
@@ -2317,19 +2317,10 @@ static int be_setup(struct be_adapter *adapter)
 	if (status != 0)
 		goto rx_qs_destroy;
 
-	if (be_physfn(adapter) && adapter->sriov_enabled) {
-		status = be_vf_eth_addr_config(adapter);
-		if (status)
-			goto mcc_q_destroy;
-	}
-
 	adapter->link_speed = -1;
 
 	return 0;
 
-mcc_q_destroy:
-	if (be_physfn(adapter))
-		be_vf_eth_addr_rem(adapter);
 	be_mcc_queues_destroy(adapter);
 rx_qs_destroy:
 	be_rx_queues_destroy(adapter);
@@ -2985,10 +2976,18 @@ static int __devinit be_probe(struct pci_dev *pdev,
 		goto unsetup;
 	netif_carrier_off(netdev);
 
+	if (be_physfn(adapter) && adapter->sriov_enabled) {
+		status = be_vf_eth_addr_config(adapter);
+		if (status)
+			goto unreg_netdev;
+	}
+
 	dev_info(&pdev->dev, "%s port %d\n", nic_name(pdev), adapter->port_num);
 	schedule_delayed_work(&adapter->work, msecs_to_jiffies(100));
 	return 0;
 
+unreg_netdev:
+	unregister_netdev(netdev);
 unsetup:
 	be_clear(adapter);
 msix_disable:
-- 
1.7.1

