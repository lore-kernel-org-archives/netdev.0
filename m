From: Dimitris Michailidis <dm@chelsio.com>
Subject: [PATCH 1/2] cxgb4: fix crash due to manipulating queues before registration
Date: Thu, 21 Oct 2010 14:29:55 -0700
Message-ID: <1287696596-15175-2-git-send-email-dm@chelsio.com>
References: <1287696596-15175-1-git-send-email-dm@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26716 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756871Ab0JUV35 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 17:29:57 -0400
Received: from maui.asicdesigners.com (maui.asicdesigners.com [10.192.180.15])
	by stargate.chelsio.com (8.13.1/8.13.1) with SMTP id o9LLTu3N029217
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:29:56 -0700
Received: from darkside.asicdesigners.com (localhost.localdomain [127.0.0.1])
	by darkside.asicdesigners.com (8.13.4/8.13.4) with ESMTP id o9LLTujF015446
	for <netdev@vger.kernel.org>; Thu, 21 Oct 2010 14:29:56 -0700
Received: (from dm@localhost)
	by darkside.asicdesigners.com (8.13.4/8.13.4/Submit) id o9LLTulo015445
	for netdev@vger.kernel.org; Thu, 21 Oct 2010 14:29:56 -0700
In-Reply-To: <1287696596-15175-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before commit "net: allocate tx queues in register_netdevice"
netif_tx_stop_all_queues and related functions could be used between
device allocation and registration but now only after registration.
cxgb4 has such a call before registration and crashes now.  Move it
after register_netdev.

Signed-off-by: Dimitris Michailidis <dm@chelsio.com>
---
 drivers/net/cxgb4/cxgb4_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_main.c
index 930bd07..bc354ee 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -3657,7 +3657,6 @@ static int __devinit init_one(struct pci_dev *pdev,
 		pi->rx_offload = RX_CSO;
 		pi->port_id = i;
 		netif_carrier_off(netdev);
-		netif_tx_stop_all_queues(netdev);
 		netdev->irq = pdev->irq;
 
 		netdev->features |= NETIF_F_SG | TSO_FLAGS;
@@ -3729,6 +3728,7 @@ static int __devinit init_one(struct pci_dev *pdev,
 
 			__set_bit(i, &adapter->registered_device_map);
 			adapter->chan_map[adap2pinfo(adapter, i)->tx_chan] = i;
+			netif_tx_stop_all_queues(adapter->port[i]);
 		}
 	}
 	if (!adapter->registered_device_map) {
-- 
1.5.4

