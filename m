From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [net-next 2/8] bnx2x: add select queue callback
Date: Thu, 9 Dec 2010 14:09:16 +0200
Message-ID: <1291896556.8745.7.camel@lb-tlvb-dmitry>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1999 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755211Ab0LIMV1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Dec 2010 07:21:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


The callback required to allow FCoE traffic to be
sent on separate priority queue from other L2 traffic,
which is managed by PFC in HW.

Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
---
 drivers/net/bnx2x/bnx2x_cmn.c  |   31 +++++++++++++++++++++++++++++++
 drivers/net/bnx2x/bnx2x_cmn.h  |    3 +++
 drivers/net/bnx2x/bnx2x_main.c |    1 +
 3 files changed, 35 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index a553fba..862b29e 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1167,6 +1167,37 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 	netif_tx_disable(bp->dev);
 }
 
+u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	int fp_index = 0;
+
+#ifdef BCM_CNIC
+	struct bnx2x *bp = netdev_priv(dev);
+	if (NO_FCOE(bp))
+		return skb_tx_hash(dev, skb);
+	else {
+		struct ethhdr *hdr = (struct ethhdr *)skb->data;
+		u16 ether_type = ntohs(hdr->h_proto);
+
+		/* Skip VLAN tag if present */
+		if (ether_type == ETH_P_8021Q) {
+			struct vlan_ethhdr *vhdr =
+				(struct vlan_ethhdr *)skb->data;
+
+			ether_type = ntohs(vhdr->h_vlan_encapsulated_proto);
+		}
+
+		/* If ethertype is FCoE or FIP - use FCoE ring */
+		if ((ether_type == ETH_P_FCOE) || (ether_type == ETH_P_FIP))
+			return bnx2x_fcoe(bp, index);
+	}
+#endif
+	/* Select queue (if defined) adjust for fcoe */
+	fp_index = skb_tx_hash(dev, skb) - FCOE_CONTEXT_USE;
+
+	return (fp_index >= 0 ? fp_index : 0);
+}
+
 void bnx2x_set_num_queues(struct bnx2x *bp)
 {
 	switch (bp->multi_mode) {
diff --git a/drivers/net/bnx2x/bnx2x_cmn.h b/drivers/net/bnx2x/bnx2x_cmn.h
index 4bb0113..258f0c0 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.h
+++ b/drivers/net/bnx2x/bnx2x_cmn.h
@@ -343,6 +343,9 @@ int bnx2x_nic_load(struct bnx2x *bp, int load_mode);
 /* hard_xmit callback */
 netdev_tx_t bnx2x_start_xmit(struct sk_buff *skb, struct net_device *dev);
 
+/* select_queue callback */
+u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb);
+
 int bnx2x_change_mac_addr(struct net_device *dev, void *p);
 
 /* NAPI poll Rx part */
diff --git a/drivers/net/bnx2x/bnx2x_main.c b/drivers/net/bnx2x/bnx2x_main.c
index 6c70ee5..c4dfb42 100644
--- a/drivers/net/bnx2x/bnx2x_main.c
+++ b/drivers/net/bnx2x/bnx2x_main.c
@@ -8977,6 +8977,7 @@ static const struct net_device_ops bnx2x_netdev_ops = {
 	.ndo_open		= bnx2x_open,
 	.ndo_stop		= bnx2x_close,
 	.ndo_start_xmit		= bnx2x_start_xmit,
+	.ndo_select_queue	= bnx2x_select_queue,
 	.ndo_set_multicast_list	= bnx2x_set_rx_mode,
 	.ndo_set_mac_address	= bnx2x_change_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
-- 
1.7.1




