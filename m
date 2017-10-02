From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 11/13] fm10k: avoid divide by zero in rare cases when device is resetting
Date: Mon,  2 Oct 2017 08:42:34 -0700
Message-ID: <20171002154236.84043-12-jeffrey.t.kirsher@intel.com>
References: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Cc: Jacob Keller <jacob.e.keller@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:24370 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751797AbdJBPnA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 2 Oct 2017 11:43:00 -0400
In-Reply-To: <20171002154236.84043-1-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jacob Keller <jacob.e.keller@intel.com>

It is possible that under rare circumstances the device is undergoing
a reset, such as when a PFLR occurs, and the device may be transmitting
simultaneously. In this case, we might attempt to divide by zero when
finding the proper r_idx. Instead, lets read the num_tx_queues once,
and make sure it's non-zero.

Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
Tested-by: Krishneil Singh <krishneil.k.singh@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---
 drivers/net/ethernet/intel/fm10k/fm10k_netdev.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
index e69d49d91d67..77d495fedced 100644
--- a/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
+++ b/drivers/net/ethernet/intel/fm10k/fm10k_netdev.c
@@ -643,9 +643,13 @@ int fm10k_close(struct net_device *netdev)
 static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 {
 	struct fm10k_intfc *interface = netdev_priv(dev);
+	int num_tx_queues = READ_ONCE(interface->num_tx_queues);
 	unsigned int r_idx = skb->queue_mapping;
 	int err;
 
+	if (!num_tx_queues)
+		return NETDEV_TX_BUSY;
+
 	if ((skb->protocol == htons(ETH_P_8021Q)) &&
 	    !skb_vlan_tag_present(skb)) {
 		/* FM10K only supports hardware tagging, any tags in frame
@@ -698,8 +702,8 @@ static netdev_tx_t fm10k_xmit_frame(struct sk_buff *skb, struct net_device *dev)
 		__skb_put(skb, pad_len);
 	}
 
-	if (r_idx >= interface->num_tx_queues)
-		r_idx %= interface->num_tx_queues;
+	if (r_idx >= num_tx_queues)
+		r_idx %= num_tx_queues;
 
 	err = fm10k_xmit_frame_ring(skb, interface->tx_ring[r_idx]);
 
-- 
2.14.2
