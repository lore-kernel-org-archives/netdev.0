From: Vasanthy Kolluri <vkolluri@cisco.com>
Subject: [net-next-2.6 PATCH 01/10] enic: Feature Add: Replace LRO with GRO
Date: Thu, 24 Jun 2010 13:49:25 -0700
Message-ID: <20100624204915.22595.20460.stgit@savbu-pc100.cisco.com>
References: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scofeldm@cisco.com, vkolluri@cisco.com,
	roprabhu@cisco.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-5.cisco.com ([171.68.10.87]:57326 "EHLO
	sj-iport-5.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754946Ab0FXUt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 16:49:27 -0400
In-Reply-To: <20100624204723.22595.42990.stgit@savbu-pc100.cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vasanthy Kolluri <vkolluri@cisco.com>

enic now uses the GRO mechanism instead of LRO to pass skbs to upper
layers.

Signed-off-by: Scott Feldman <scofeldm@cisco.com>
Signed-off-by: Vasanthy Kolluri <vkolluri@cisco.com>
Signed-off-by: Roopa Prabhu <roprabhu@cisco.com>
---
 drivers/net/Kconfig          |    1 -
 drivers/net/enic/enic.h      |    9 +----
 drivers/net/enic/enic_main.c |   79 ++++--------------------------------------
 3 files changed, 9 insertions(+), 80 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index fe113d0..a0182a2 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -2615,7 +2615,6 @@ config EHEA
 config ENIC
 	tristate "Cisco VIC Ethernet NIC Support"
 	depends on PCI && INET
-	select INET_LRO
 	help
 	  This enables the support for the Cisco VIC Ethernet card.
 
diff --git a/drivers/net/enic/enic.h b/drivers/net/enic/enic.h
index 45e86d1..81c2ade 100644
--- a/drivers/net/enic/enic.h
+++ b/drivers/net/enic/enic.h
@@ -20,8 +20,6 @@
 #ifndef _ENIC_H_
 #define _ENIC_H_
 
-#include <linux/inet_lro.h>
-
 #include "vnic_enet.h"
 #include "vnic_dev.h"
 #include "vnic_wq.h"
@@ -34,13 +32,10 @@
 
 #define DRV_NAME		"enic"
 #define DRV_DESCRIPTION		"Cisco VIC Ethernet NIC Driver"
-#define DRV_VERSION		"1.3.1.1-pp"
+#define DRV_VERSION		"1.4.1.1"
 #define DRV_COPYRIGHT		"Copyright 2008-2009 Cisco Systems, Inc"
 #define PFX			DRV_NAME ": "
 
-#define ENIC_LRO_MAX_DESC	8
-#define ENIC_LRO_MAX_AGGR	64
-
 #define ENIC_BARS_MAX		6
 
 #define ENIC_WQ_MAX		8
@@ -124,8 +119,6 @@ struct enic {
 	u64 rq_truncated_pkts;
 	u64 rq_bad_fcs;
 	struct napi_struct napi;
-	struct net_lro_mgr lro_mgr;
-	struct net_lro_desc lro_desc[ENIC_LRO_MAX_DESC];
 
 	/* interrupt resource cache line section */
 	____cacheline_aligned struct vnic_intr intr[ENIC_INTR_MAX];
diff --git a/drivers/net/enic/enic_main.c b/drivers/net/enic/enic_main.c
index bc7d6b9..c2b848f 100644
--- a/drivers/net/enic/enic_main.c
+++ b/drivers/net/enic/enic_main.c
@@ -1287,51 +1287,6 @@ static int enic_set_rq_alloc_buf(struct enic *enic)
 	return 0;
 }
 
-static int enic_get_skb_header(struct sk_buff *skb, void **iphdr,
-	void **tcph, u64 *hdr_flags, void *priv)
-{
-	struct cq_enet_rq_desc *cq_desc = priv;
-	unsigned int ip_len;
-	struct iphdr *iph;
-
-	u8 type, color, eop, sop, ingress_port, vlan_stripped;
-	u8 fcoe, fcoe_sof, fcoe_fc_crc_ok, fcoe_enc_error, fcoe_eof;
-	u8 tcp_udp_csum_ok, udp, tcp, ipv4_csum_ok;
-	u8 ipv6, ipv4, ipv4_fragment, fcs_ok, rss_type, csum_not_calc;
-	u8 packet_error;
-	u16 q_number, completed_index, bytes_written, vlan, checksum;
-	u32 rss_hash;
-
-	cq_enet_rq_desc_dec(cq_desc,
-		&type, &color, &q_number, &completed_index,
-		&ingress_port, &fcoe, &eop, &sop, &rss_type,
-		&csum_not_calc, &rss_hash, &bytes_written,
-		&packet_error, &vlan_stripped, &vlan, &checksum,
-		&fcoe_sof, &fcoe_fc_crc_ok, &fcoe_enc_error,
-		&fcoe_eof, &tcp_udp_csum_ok, &udp, &tcp,
-		&ipv4_csum_ok, &ipv6, &ipv4, &ipv4_fragment,
-		&fcs_ok);
-
-	if (!(ipv4 && tcp && !ipv4_fragment))
-		return -1;
-
-	skb_reset_network_header(skb);
-	iph = ip_hdr(skb);
-
-	ip_len = ip_hdrlen(skb);
-	skb_set_transport_header(skb, ip_len);
-
-	/* check if ip header and tcp header are complete */
-	if (ntohs(iph->tot_len) < ip_len + tcp_hdrlen(skb))
-		return -1;
-
-	*hdr_flags = LRO_IPV4 | LRO_TCP;
-	*tcph = tcp_hdr(skb);
-	*iphdr = iph;
-
-	return 0;
-}
-
 static void enic_rq_indicate_buf(struct vnic_rq *rq,
 	struct cq_desc *cq_desc, struct vnic_rq_buf *buf,
 	int skipped, void *opaque)
@@ -1397,18 +1352,17 @@ static void enic_rq_indicate_buf(struct vnic_rq *rq,
 
 		if (enic->vlan_group && vlan_stripped) {
 
-			if ((netdev->features & NETIF_F_LRO) && ipv4)
-				lro_vlan_hwaccel_receive_skb(&enic->lro_mgr,
-					skb, enic->vlan_group,
-					vlan, cq_desc);
+			if (netdev->features & NETIF_F_GRO)
+				vlan_gro_receive(&enic->napi, enic->vlan_group,
+					vlan, skb);
 			else
 				vlan_hwaccel_receive_skb(skb,
 					enic->vlan_group, vlan);
 
 		} else {
 
-			if ((netdev->features & NETIF_F_LRO) && ipv4)
-				lro_receive_skb(&enic->lro_mgr, skb, cq_desc);
+			if (netdev->features & NETIF_F_GRO)
+				napi_gro_receive(&enic->napi, skb);
 			else
 				netif_receive_skb(skb);
 
@@ -1438,7 +1392,6 @@ static int enic_rq_service(struct vnic_dev *vdev, struct cq_desc *cq_desc,
 static int enic_poll(struct napi_struct *napi, int budget)
 {
 	struct enic *enic = container_of(napi, struct enic, napi);
-	struct net_device *netdev = enic->netdev;
 	unsigned int rq_work_to_do = budget;
 	unsigned int wq_work_to_do = -1; /* no limit */
 	unsigned int  work_done, rq_work_done, wq_work_done;
@@ -1478,12 +1431,9 @@ static int enic_poll(struct napi_struct *napi, int budget)
 	if (rq_work_done < rq_work_to_do) {
 
 		/* Some work done, but not enough to stay in polling,
-		 * flush all LROs and exit polling
+		 * exit polling
 		 */
 
-		if (netdev->features & NETIF_F_LRO)
-			lro_flush_all(&enic->lro_mgr);
-
 		napi_complete(napi);
 		vnic_intr_unmask(&enic->intr[ENIC_INTX_WQ_RQ]);
 	}
@@ -1494,7 +1444,6 @@ static int enic_poll(struct napi_struct *napi, int budget)
 static int enic_poll_msix(struct napi_struct *napi, int budget)
 {
 	struct enic *enic = container_of(napi, struct enic, napi);
-	struct net_device *netdev = enic->netdev;
 	unsigned int work_to_do = budget;
 	unsigned int work_done;
 	int err;
@@ -1528,12 +1477,9 @@ static int enic_poll_msix(struct napi_struct *napi, int budget)
 	if (work_done < work_to_do) {
 
 		/* Some work done, but not enough to stay in polling,
-		 * flush all LROs and exit polling
+		 * exit polling
 		 */
 
-		if (netdev->features & NETIF_F_LRO)
-			lro_flush_all(&enic->lro_mgr);
-
 		napi_complete(napi);
 		vnic_intr_unmask(&enic->intr[ENIC_MSIX_RQ]);
 	}
@@ -2378,21 +2324,12 @@ static int __devinit enic_probe(struct pci_dev *pdev,
 		netdev->features |= NETIF_F_TSO |
 			NETIF_F_TSO6 | NETIF_F_TSO_ECN;
 	if (ENIC_SETTING(enic, LRO))
-		netdev->features |= NETIF_F_LRO;
+		netdev->features |= NETIF_F_GRO;
 	if (using_dac)
 		netdev->features |= NETIF_F_HIGHDMA;
 
 	enic->csum_rx_enabled = ENIC_SETTING(enic, RXCSUM);
 
-	enic->lro_mgr.max_aggr = ENIC_LRO_MAX_AGGR;
-	enic->lro_mgr.max_desc = ENIC_LRO_MAX_DESC;
-	enic->lro_mgr.lro_arr = enic->lro_desc;
-	enic->lro_mgr.get_skb_header = enic_get_skb_header;
-	enic->lro_mgr.features	= LRO_F_NAPI | LRO_F_EXTRACT_VLAN_ID;
-	enic->lro_mgr.dev = netdev;
-	enic->lro_mgr.ip_summed = CHECKSUM_COMPLETE;
-	enic->lro_mgr.ip_summed_aggr = CHECKSUM_UNNECESSARY;
-
 	err = register_netdev(netdev);
 	if (err) {
 		printk(KERN_ERR PFX

