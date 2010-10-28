From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH] cxgb4vf: fix crash due to manipulating queues before registration
Date: Thu, 28 Oct 2010 13:16:47 -0700
Message-ID: <1288297007-663-1-git-send-email-leedom@chelsio.com>
Cc: netdev@vger.kernel.org, Casey Leedom <leedom@chelsio.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:9160 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754495Ab0J1UQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Oct 2010 16:16:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before commit "net: allocate tx queues in register_netdevice"
netif_tx_stop_all_queues and related functions could be used between
device allocation and registration but now only after registration.
cxgb4 has such a call before registration and crashes now.  Move it
after register_netdev.

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 555ecc5..b9d92a5 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -2600,7 +2600,6 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 		pi->xact_addr_filt = -1;
 		pi->rx_offload = RX_CSO;
 		netif_carrier_off(netdev);
-		netif_tx_stop_all_queues(netdev);
 		netdev->irq = pdev->irq;
 
 		netdev->features = (NETIF_F_SG | NETIF_F_TSO | NETIF_F_TSO6 |
@@ -2661,6 +2660,7 @@ static int __devinit cxgb4vf_pci_probe(struct pci_dev *pdev,
 			continue;
 		}
 
+		netif_tx_stop_all_queues(netdev);
 		set_bit(pidx, &adapter->registered_device_map);
 	}
 	if (adapter->registered_device_map == 0) {
-- 
1.7.0.4

