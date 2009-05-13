From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 7/8] ixgbe: Implement FCoE Rx side large receive
	offload feature to 82599
Date: Wed, 13 May 2009 16:11:53 -0700
Message-ID: <20090513231152.11416.40697.stgit@localhost.localdomain>
References: <20090513230924.11416.68752.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-scsi@vger.kernel.org,
	Yi Zou <yi.zou@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta03.westchester.pa.mail.comcast.net ([76.96.62.32]:47356
	"EHLO QMTA03.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753998AbZEMXMO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 19:12:14 -0400
In-Reply-To: <20090513230924.11416.68752.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

This patch implements the FCoE Rx side offload feature in ixgbe_main.c
to 82599 using the Rx offload infrastructure code added in the previous
patch. The large receive offload by Direct Data Placement (DDP) for
FCoE is achieved by implementing the ndo_fcoe_ddp_setup and ndo_fcoe_ddp_done
in net_device_ops via netdev. It is up to the ULD, i.e., fcoe and libfc
to query and setup large receive offload accordingly through the corresponding
netdev upon creating fcoe instances.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Acked-by: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe.h      |    7 +++++++
 drivers/net/ixgbe/ixgbe_main.c |   16 ++++++++++++++++
 2 files changed, 23 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe.h b/drivers/net/ixgbe/ixgbe.h
index 5581fa3..db6d3ea 100644
--- a/drivers/net/ixgbe/ixgbe.h
+++ b/drivers/net/ixgbe/ixgbe.h
@@ -386,6 +386,13 @@ extern void ixgbe_configure_fcoe(struct ixgbe_adapter *adapter);
 extern int ixgbe_fso(struct ixgbe_adapter *adapter,
                      struct ixgbe_ring *tx_ring, struct sk_buff *skb,
                      u32 tx_flags, u8 *hdr_len);
+extern void ixgbe_cleanup_fcoe(struct ixgbe_adapter *adapter);
+extern int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
+                          union ixgbe_adv_rx_desc *rx_desc,
+                          struct sk_buff *skb);
+extern int ixgbe_fcoe_ddp_get(struct net_device *netdev, u16 xid,
+                              struct scatterlist *sgl, unsigned int sgc);
+extern int ixgbe_fcoe_ddp_put(struct net_device *netdev, u16 xid);
 #endif /* IXGBE_FCOE */
 
 #endif /* _IXGBE_H_ */
diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index ee80f6f..e7c44a3 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -784,6 +784,12 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 		total_rx_packets++;
 
 		skb->protocol = eth_type_trans(skb, adapter->netdev);
+#ifdef IXGBE_FCOE
+		/* if ddp, not passing to ULD unless for FCP_RSP or error */
+		if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+			if (!ixgbe_fcoe_ddp(adapter, rx_desc, skb))
+				goto next_desc;
+#endif /* IXGBE_FCOE */
 		ixgbe_receive_skb(q_vector, skb, staterr, rx_ring, rx_desc);
 
 next_desc:
@@ -4822,6 +4828,10 @@ static const struct net_device_ops ixgbe_netdev_ops = {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	= ixgbe_netpoll,
 #endif
+#ifdef IXGBE_FCOE
+	.ndo_fcoe_ddp_setup = ixgbe_fcoe_ddp_get,
+	.ndo_fcoe_ddp_done = ixgbe_fcoe_ddp_put,
+#endif /* IXGBE_FCOE */
 };
 
 /**
@@ -5036,6 +5046,7 @@ static int __devinit ixgbe_probe(struct pci_dev *pdev,
 			if (!(device_caps & IXGBE_DEVICE_CAPS_FCOE_OFFLOADS)) {
 				netdev->features |= NETIF_F_FCOE_CRC;
 				netdev->features |= NETIF_F_FSO;
+				netdev->fcoe_ddp_xid = IXGBE_FCOE_DDP_MAX - 1;
 			} else {
 				adapter->flags &= ~IXGBE_FLAG_FCOE_ENABLED;
 			}
@@ -5205,6 +5216,11 @@ static void __devexit ixgbe_remove(struct pci_dev *pdev)
 	}
 
 #endif
+#ifdef IXGBE_FCOE
+	if (adapter->flags & IXGBE_FLAG_FCOE_ENABLED)
+		ixgbe_cleanup_fcoe(adapter);
+
+#endif /* IXGBE_FCOE */
 	if (netdev->reg_state == NETREG_REGISTERED)
 		unregister_netdev(netdev);
 

