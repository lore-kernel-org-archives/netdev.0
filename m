From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 03/12] cxgb4: set the number of queues before device registration
Date: Tue, 14 Dec 2010 23:36:46 -0800
Message-ID: <1292398615-26527-4-git-send-email-dm@chelsio.com>
References: <1292398615-26527-1-git-send-email-dm@chelsio.com>
 <1292398615-26527-2-git-send-email-dm@chelsio.com>
 <1292398615-26527-3-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:4752 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754115Ab0LOHpT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 02:45:19 -0500
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id oBF7jICM004129
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:45:19 -0800
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id oBF7aum4026585
	for <netdev@vger.kernel.org>; Tue, 14 Dec 2010 23:36:56 -0800
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id oBF7auJt026584
	for netdev@vger.kernel.org; Tue, 14 Dec 2010 23:36:56 -0800
In-Reply-To: <1292398615-26527-3-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The number of queues is known early, move the calls to
netif_set_real_num_[rt]x_queues before register_netdev.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |   10 +++++-----
 1 files changed, 5 insertions(+), 5 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 953d62a..3012a8a 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -2717,10 +2717,6 @@ static int cxgb_open(struct net_device *dev)
 			return err;
 	}
 
-	netif_set_real_num_tx_queues(dev, pi->nqsets);
-	err = netif_set_real_num_rx_queues(dev, pi->nqsets);
-	if (err)
-		return err;
 	err = link_start(dev);
 	if (!err)
 		netif_tx_start_all_queues(dev);
@@ -3733,6 +3729,10 @@ static int __devinit init_one(struct pci_dev *pdev,
 	 * register at least one net device.
 	 */
 	for_each_port(adapter, i) {
+		pi = adap2pinfo(adapter, i);
+		netif_set_real_num_tx_queues(adapter->port[i], pi->nqsets);
+		netif_set_real_num_rx_queues(adapter->port[i], pi->nqsets);
+
 		err = register_netdev(adapter->port[i]);
 		if (err)
 			dev_warn(&pdev->dev,
@@ -3747,7 +3747,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 				adapter->name = adapter->port[i]->name;
 
 			__set_bit(i, &adapter->registered_device_map);
-			adapter->chan_map[adap2pinfo(adapter, i)->tx_chan] = i;
+			adapter->chan_map[pi->tx_chan] = i;
 		}
 	}
 	if (!adapter->registered_device_map) {
-- 
1.5.4

