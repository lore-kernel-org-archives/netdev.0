From: Scott Feldman <scofeldm@cisco.com>
Subject: [PATCH 1/5] enic: enable ethtool LRO support
Date: Fri, 21 Nov 2008 16:33:57 -0800
Message-ID: <20081122003357.15540.89885.stgit@palito_client100.nuovasystems.com>
References: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jgarzik@pobox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-3.cisco.com ([171.71.176.72]:57352 "EHLO
	sj-iport-3.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754624AbYKVAla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Nov 2008 19:41:30 -0500
In-Reply-To: <20081122003219.15540.26759.stgit@palito_client100.nuovasystems.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

enic: enable ethtool LRO support

Enable ethtool support for get/set_flags so LRO can be turned on/off by fwding drivers such as the bridge driver.  LRO is not compatible with fwding drivers.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
---
 drivers/net/enic/enic.h      |    2 +-
 drivers/net/enic/enic_main.c |   44 +++++++++++++++++++++++-------------------
 2 files changed, 25 insertions(+), 21 deletions(-)

diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 7f677e8..a832cc5 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -33,7 +33,7 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco 10G Ethernet Driver"
-#define DRV_VERSION		"0.0.1-18163.472-k1"
+#define DRV_VERSION		"1.0.0.648"
 #define DRV_COPYRIGHT		"Copyright 2008 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index 180e968..68d1032 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -273,6 +273,8 @@ static struct ethtool_ops enic_ethtool_ops = {
 	.set_sg = ethtool_op_set_sg,
 	.get_tso = ethtool_op_get_tso,
 	.set_tso = enic_set_tso,
+	.get_flags = ethtool_op_get_flags,
+	.set_flags = ethtool_op_set_flags,
 };
 
 static void enic_free_wq_buf(struct vnic_wq *wq, struct vnic_wq_buf *buf)
@@ -895,6 +897,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 	int skipped, void *opaque)
 {
 	struct enic *enic = vnic_dev_priv(rq->vdev);
+	struct net_device *netdev = enic->netdev;
 	struct sk_buff *skb;
 
 	u8 type, color, eop, sop, ingress_port, vlan_stripped;
@@ -929,7 +932,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 			if (net_ratelimit())
 				printk(KERN_ERR PFX
 					"%s: packet error: bad FCS\n",
-					enic->netdev->name);
+					netdev->name);
 		}
 
 		dev_kfree_skb_any(skb);
@@ -943,19 +946,19 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 		 */
 
 		skb_put(skb, bytes_written);
-		skb->protocol = eth_type_trans(skb, enic->netdev);
+		skb->protocol = eth_type_trans(skb, netdev);
 
 		if (enic->csum_rx_enabled && !csum_not_calc) {
 			skb->csum = htons(checksum);
 			skb->ip_summed = CHECKSUM_COMPLETE;
 		}
 
-		skb->dev = enic->netdev;
-		enic->netdev->last_rx = jiffies;
+		skb->dev = netdev;
+		netdev->last_rx = jiffies;
 
 		if (enic->vlan_group && vlan_stripped) {
 
-			if (ENIC_SETTING(enic, LRO) && ipv4)
+			if ((netdev->features & NETIF_F_LRO) && ipv4)
 				lro_vlan_hwaccel_receive_skb(&enic->lro_mgr,
 					skb, enic->vlan_group,
 					vlan, cq_desc);
@@ -965,7 +968,7 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		} else {
 
-			if (ENIC_SETTING(enic, LRO) && ipv4)
+			if ((netdev->features & NETIF_F_LRO) && ipv4)
 				lro_receive_skb(&enic->lro_mgr, skb, cq_desc);
 			else
 				netif_receive_skb(skb);
@@ -1063,7 +1066,7 @@ static int enic_poll(struct napi_struct *napi, int budget)
 		/* If no work done, flush all LROs and exit polling
 		 */
 
-		if (ENIC_SETTING(enic, LRO))
+		if (netdev->features & NETIF_F_LRO)
 			lro_flush_all(&enic->lro_mgr);
 
 		netif_rx_complete(netdev, napi);
@@ -1107,7 +1110,7 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 		/* If no work done, flush all LROs and exit polling
 		 */
 
-		if (ENIC_SETTING(enic, LRO))
+		if (netdev->features & NETIF_F_LRO)
 			lro_flush_all(&enic->lro_mgr);
 
 		netif_rx_complete(netdev, napi);
@@ -1746,13 +1749,13 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	}
 
 	/* Get available resource counts
-	*/
+	 */
 
 	enic_get_res_counts(enic);
 
 	/* Set interrupt mode based on resource counts and system
 	 * capabilities
-	*/
+	 */
 
 	err = enic_set_intr_mode(enic);
 	if (err) {
@@ -1845,22 +1848,23 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 	if (ENIC_SETTING(enic, TSO))
 		netdev->features |= NETIF_F_TSO |
 			NETIF_F_TSO6 | NETIF_F_TSO_ECN;
+	if (ENIC_SETTING(enic, LRO))
+		netdev->features |= NETIF_F_LRO;
 	if (using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
 
 	enic->csum_rx_enabled = ENIC_SETTING(enic, RXCSUM);
 
-	if (ENIC_SETTING(enic, LRO)) {
-		enic->lro_mgr.max_aggr = ENIC_LRO_MAX_AGGR;
-		enic->lro_mgr.max_desc = ENIC_LRO_MAX_DESC;
-		enic->lro_mgr.lro_arr = enic->lro_desc;
-		enic->lro_mgr.get_skb_header = enic_get_skb_header;
-		enic->lro_mgr.features	= LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
-		enic->lro_mgr.dev = netdev;
-		enic->lro_mgr.ip_summed = CHECKSUM_COMPLETE;
-		enic->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
-	}
+	enic->lro_mgr.max_aggr = ENIC_LRO_MAX_AGGR;
+	enic->lro_mgr.max_desc = ENIC_LRO_MAX_DESC;
+	enic->lro_mgr.lro_arr = enic->lro_desc;
+	enic->lro_mgr.get_skb_header = enic_get_skb_header;
+	enic->lro_mgr.features	= LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
+	enic->lro_mgr.dev = netdev;
+	enic->lro_mgr.ip_summed = CHECKSUM_COMPLETE;
+	enic->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
+
 
 	err = register_netdev(netdev);
 	if (err) {

