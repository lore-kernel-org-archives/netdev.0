From: Florian Westphal <fw@strlen.de>
Subject: [PATCH net-next 1/6] RDMA/nes: remove use of NETDEV_TX_LOCKED
Date: Sun, 24 Apr 2016 21:38:09 +0200
Message-ID: <1461526694-11367-2-git-send-email-fw@strlen.de>
References: <1461526694-11367-1-git-send-email-fw@strlen.de>
Cc: linux-kernel@vger.kernel.org, Florian Westphal <fw@strlen.de>,
	linux-rdma@vger.kernel.org
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:59109 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753195AbcDXTiN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Apr 2016 15:38:13 -0400
In-Reply-To: <1461526694-11367-1-git-send-email-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ndo_start_xmit never returns it to stack, but nes_nic_send helper used it if
skb could not be queued to hardware.  Switch to bool instead.

Cc: <linux-rdma@vger.kernel.org>
Signed-off-by: Florian Westphal <fw@strlen.de>
---
 drivers/infiniband/hw/nes/nes_nic.c | 13 +++++--------
 1 file changed, 5 insertions(+), 8 deletions(-)

diff --git a/drivers/infiniband/hw/nes/nes_nic.c b/drivers/infiniband/hw/nes/nes_nic.c
index 3ea9e05..b09a6db 100644
--- a/drivers/infiniband/hw/nes/nes_nic.c
+++ b/drivers/infiniband/hw/nes/nes_nic.c
@@ -356,7 +356,7 @@ static int nes_netdev_stop(struct net_device *netdev)
 /**
  * nes_nic_send
  */
-static int nes_nic_send(struct sk_buff *skb, struct net_device *netdev)
+static bool nes_nic_send(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct nes_vnic *nesvnic = netdev_priv(netdev);
 	struct nes_device *nesdev = nesvnic->nesdev;
@@ -413,7 +413,7 @@ static int nes_nic_send(struct sk_buff *skb, struct net_device *netdev)
 					netdev->name, skb_shinfo(skb)->nr_frags + 2, skb_headlen(skb));
 			kfree_skb(skb);
 			nesvnic->tx_sw_dropped++;
-			return NETDEV_TX_LOCKED;
+			return false;
 		}
 		set_bit(nesnic->sq_head, nesnic->first_frag_overflow);
 		bus_address = pci_map_single(nesdev->pcidev, skb->data + NES_FIRST_FRAG_SIZE,
@@ -454,8 +454,7 @@ static int nes_nic_send(struct sk_buff *skb, struct net_device *netdev)
 	set_wqe_32bit_value(nic_sqe->wqe_words, NES_NIC_SQ_WQE_MISC_IDX, wqe_misc);
 	nesnic->sq_head++;
 	nesnic->sq_head &= nesnic->sq_size - 1;
-
-	return NETDEV_TX_OK;
+	return true;
 }
 
 
@@ -673,13 +672,11 @@ tso_sq_no_longer_full:
 			skb_linearize(skb);
 			skb_set_transport_header(skb, hoffset);
 			skb_set_network_header(skb, nhoffset);
-			send_rc = nes_nic_send(skb, netdev);
-			if (send_rc != NETDEV_TX_OK)
+			if (!nes_nic_send(skb, netdev))
 				return NETDEV_TX_OK;
 		}
 	} else {
-		send_rc = nes_nic_send(skb, netdev);
-		if (send_rc != NETDEV_TX_OK)
+		if (!nes_nic_send(skb, netdev))
 			return NETDEV_TX_OK;
 	}
 
-- 
2.7.3
