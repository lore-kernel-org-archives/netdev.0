From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net 1/2] net/mlx4_en: Fix bridged vSwitch configuration for non SRIOV mode
Date: Thu, 17 Jan 2013 17:30:42 +0200
Message-ID: <1358436643-1326-2-git-send-email-ogerlitz@mellanox.com>
References: <1358436643-1326-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, amirv@mellanox.com,
	jackm@dev.mellanox.co.il, yevgenyp@mellanox.com,
	Yan Burman <yanb@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog112.obsmtp.com ([207.126.144.133]:46185 "HELO
	eu1sys200aog112.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1756558Ab3AQPa6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 10:30:58 -0500
In-Reply-To: <1358436643-1326-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

Commit 5b4c4d36860e "mlx4_en: Allow communication between functions on
same host" introduced a regression under which a bridge acting as vSwitch
whose uplink is an mlx4 Ethernet device become non-operative in native
(non sriov) mode. This happens since broadcast ARP requests sent by VMs
were loopback-ed by the HW and hence the bridge learned VM source MACs
on both the VM and the uplink ports.

The fix is to place the DMAC in the send WQE only under SRIOV/eSwitch
configuration or when the device is in selftest.

Reviewed-by: Or Gerlitz <ogerlitz@mellanox.com>
Signed-off-by: Yan Burman <yanb@mellanox.com>
Signed-off-by: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/en_tx.c |   13 +++++++++----
 1 files changed, 9 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
index 2b799f4..6771b69 100644
--- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
+++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
@@ -630,10 +630,15 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct net_device *dev)
 		ring->tx_csum++;
 	}
 
-	/* Copy dst mac address to wqe */
-	ethh = (struct ethhdr *)skb->data;
-	tx_desc->ctrl.srcrb_flags16[0] = get_unaligned((__be16 *)ethh->h_dest);
-	tx_desc->ctrl.imm = get_unaligned((__be32 *)(ethh->h_dest + 2));
+	if (mlx4_is_mfunc(mdev->dev) || priv->validate_loopback) {
+		/* Copy dst mac address to wqe. This allows loopback in eSwitch,
+		 * so that VFs and PF can communicate with each other
+		 */
+		ethh = (struct ethhdr *)skb->data;
+		tx_desc->ctrl.srcrb_flags16[0] = get_unaligned((__be16 *)ethh->h_dest);
+		tx_desc->ctrl.imm = get_unaligned((__be32 *)(ethh->h_dest + 2));
+	}
+
 	/* Handle LSO (TSO) packets */
 	if (lso_header_size) {
 		/* Mark opcode as LSO */
-- 
1.7.1
