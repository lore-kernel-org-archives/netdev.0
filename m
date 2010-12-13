From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: [PATCH net-next 3/9] bnx2x: add a select queue callback
Date: Mon, 13 Dec 2010 17:44:09 +0200
Message-ID: <1292255049.631.51.camel@lb-tlvb-vladz>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "netdev list" <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"Shmulik Ravid-Rabinovitz" <shmulikr@broadcom.com>,
	"Dmitry Kravkov" <dmitry@broadcom.com>
To: "Dave Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4162 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114Ab0LMPoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Dec 2010 10:44:19 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This callback required to allow FCoE traffic to be
sent on separate priority queue from other L2 traffic,
which is managed by PFC in HW.

Signed-off-by: Vladislav Zolotarov <vladz@broadcom.com>
Signed-off-by: Shmulik Ravid-Rabinovitz <shmulikr@broadcom.com>
Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/bnx2x/bnx2x_cmn.c  |   29 +++++++++++++++++++++++++++++
 drivers/net/bnx2x/bnx2x_cmn.h  |    3 +++
 drivers/net/bnx2x/bnx2x_main.c |    1 +
 3 files changed, 37 insertions(+), 0 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c b/drivers/net/bnx2x/bnx2x_cmn.c
index fa12365..e698b07 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -1167,6 +1167,35 @@ void bnx2x_netif_stop(struct bnx2x *bp, int disable_hw)
 	netif_tx_disable(bp->dev);
 }
 
+u16 bnx2x_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
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
+	/* Select a none-FCoE queue:  if FCoE is enabled, exclude FCoE L2 ring
+	 */
+	return __skb_tx_hash(dev, skb,
+			dev->real_num_tx_queues - FCOE_CONTEXT_USE);
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
index e6e2746..563b2cb 100644
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
1.7.0.4




