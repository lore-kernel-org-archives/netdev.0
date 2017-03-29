From: Tushar Dave <tushar.n.dave@oracle.com>
Subject: [PATCH] i40e: Check for skb->queue_mapping
Date: Wed, 29 Mar 2017 16:57:54 -0700
Message-ID: <1490831874-6396-1-git-send-email-tushar.n.dave@oracle.com>
To: jeffrey.t.kirsher@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:36065 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932927AbdC3ABX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 29 Mar 2017 20:01:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There are events seen where skb->queue_mapping value is greater than
vsi->num_queue_pairs. In such cases, vsi->tx_ring becomes invalid
(null) and xmit results in kernel panic.

One such event is running netconsole and enabling VF on the same
device. Or running netconsole and changing number of tx queues via
ethtool on same device.

This patch adds check for skb->queue_mapping and uses simple arithmetic
to select available tx queue from driver.

Signed-off-by: Tushar Dave <tushar.n.dave@oracle.com>
---
 drivers/net/ethernet/intel/i40e/i40e_txrx.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/i40e/i40e_txrx.c b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
index 97d4605..af73675 100644
--- a/drivers/net/ethernet/intel/i40e/i40e_txrx.c
+++ b/drivers/net/ethernet/intel/i40e/i40e_txrx.c
@@ -3008,6 +3008,16 @@ static netdev_tx_t i40e_xmit_frame_ring(struct sk_buff *skb,
 	return NETDEV_TX_OK;
 }
 
+static inline struct i40e_ring *i40e_get_txq(struct i40e_vsi *vsi,
+					     struct sk_buff *skb)
+{
+	unsigned int txq = skb->queue_mapping;
+
+	if (txq >= vsi->num_queue_pairs)
+		txq = txq % vsi->num_queue_pairs;
+
+	return vsi->tx_rings[txq];
+}
 /**
  * i40e_lan_xmit_frame - Selects the correct VSI and Tx queue to send buffer
  * @skb:    send buffer
@@ -3019,7 +3029,6 @@ netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 {
 	struct i40e_netdev_priv *np = netdev_priv(netdev);
 	struct i40e_vsi *vsi = np->vsi;
-	struct i40e_ring *tx_ring = vsi->tx_rings[skb->queue_mapping];
 
 	/* hardware can't handle really short frames, hardware padding works
 	 * beyond this point
@@ -3027,5 +3036,5 @@ netdev_tx_t i40e_lan_xmit_frame(struct sk_buff *skb, struct net_device *netdev)
 	if (skb_put_padto(skb, I40E_MIN_TX_LEN))
 		return NETDEV_TX_OK;
 
-	return i40e_xmit_frame_ring(skb, tx_ring);
+	return i40e_xmit_frame_ring(skb, i40e_get_txq(vsi, skb));
 }
-- 
1.9.1
