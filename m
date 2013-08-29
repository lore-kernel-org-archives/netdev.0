From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH v2 net-next 1/2] qlge: Enhance nested VLAN (Q-in-Q) handling.
Date: Thu, 29 Aug 2013 00:51:07 -0400
Message-ID: <1377751868-1367-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1377751868-1367-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:49079 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753289Ab3H2FUA convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Aug 2013 01:20:00 -0400
In-Reply-To: <1377751868-1367-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Adapter doesn=E2=80=99t handle packets with nested VLAN tags in
Rx path. Turn off VLAN tag stripping in the hardware and
let the stack handle stripping of VLAN tags in the Rx path.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |  142 ++++++++++--------=
--------
 1 files changed, 53 insertions(+), 89 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net=
/ethernet/qlogic/qlge/qlge_main.c
index 2553cf4..332cdc9 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -409,8 +409,6 @@ static int ql_set_mac_addr_reg(struct ql_adapter *q=
dev, u8 *addr, u32 type,
 				      (qdev->
 				       func << CAM_OUT_FUNC_SHIFT) |
 					(0 << CAM_OUT_CQ_ID_SHIFT));
-			if (qdev->ndev->features & NETIF_F_HW_VLAN_CTAG_RX)
-				cam_output |=3D CAM_OUT_RV;
 			/* route to NIC core */
 			ql_write32(qdev, MAC_ADDR_DATA, cam_output);
 			break;
@@ -1464,12 +1462,31 @@ static void ql_categorize_rx_err(struct ql_adap=
ter *qdev, u8 rx_err,
 	}
 }
=20
+/*
+ * This routine will update the mac header length based on
+ * single or nested vlan tags if present
+ */
+static void ql_update_mac_hdr_len(struct ib_mac_iocb_rsp *ib_mac_rsp,
+				  void *page, size_t *len)
+{
+	u16 *tags;
+
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) {
+		tags =3D (u16 *)page;
+		/* Look for stacked vlan tags in ethertype field */
+		if (tags[6] =3D=3D htons(ETH_P_8021Q) &&
+		    tags[8] =3D=3D htons(ETH_P_8021Q))
+			*len +=3D 2 * VLAN_HLEN;
+		else
+			*len +=3D VLAN_HLEN;
+	}
+}
+
 /* Process an inbound completion from an rx ring. */
 static void ql_process_mac_rx_gro_page(struct ql_adapter *qdev,
 					struct rx_ring *rx_ring,
 					struct ib_mac_iocb_rsp *ib_mac_rsp,
-					u32 length,
-					u16 vlan_id)
+					u32 length)
 {
 	struct sk_buff *skb;
 	struct bq_desc *lbq_desc =3D ql_get_curr_lchunk(qdev, rx_ring);
@@ -1506,8 +1523,6 @@ static void ql_process_mac_rx_gro_page(struct ql_=
adapter *qdev,
 	rx_ring->rx_bytes +=3D length;
 	skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	skb_record_rx_queue(skb, rx_ring->cq_id);
-	if (vlan_id !=3D 0xffff)
-		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 	napi_gro_frags(napi);
 }
=20
@@ -1515,14 +1530,14 @@ static void ql_process_mac_rx_gro_page(struct q=
l_adapter *qdev,
 static void ql_process_mac_rx_page(struct ql_adapter *qdev,
 					struct rx_ring *rx_ring,
 					struct ib_mac_iocb_rsp *ib_mac_rsp,
-					u32 length,
-					u16 vlan_id)
+					u32 length)
 {
 	struct net_device *ndev =3D qdev->ndev;
 	struct sk_buff *skb =3D NULL;
 	void *addr;
 	struct bq_desc *lbq_desc =3D ql_get_curr_lchunk(qdev, rx_ring);
 	struct napi_struct *napi =3D &rx_ring->napi;
+	size_t hlen =3D ETH_HLEN;
=20
 	skb =3D netdev_alloc_skb(ndev, length);
 	if (!skb) {
@@ -1540,25 +1555,28 @@ static void ql_process_mac_rx_page(struct ql_ad=
apter *qdev,
 		goto err_out;
 	}
=20
+	/* Update the MAC header length*/
+	ql_update_mac_hdr_len(ib_mac_rsp, addr, &hlen);
+
 	/* The max framesize filter on this chip is set higher than
 	 * MTU since FCoE uses 2k frames.
 	 */
-	if (skb->len > ndev->mtu + ETH_HLEN) {
+	if (skb->len > ndev->mtu + hlen) {
 		netif_err(qdev, drv, qdev->ndev,
 			  "Segment too small, dropping.\n");
 		rx_ring->rx_dropped++;
 		goto err_out;
 	}
-	memcpy(skb_put(skb, ETH_HLEN), addr, ETH_HLEN);
+	memcpy(skb_put(skb, hlen), addr, hlen);
 	netif_printk(qdev, rx_status, KERN_DEBUG, qdev->ndev,
 		     "%d bytes of headers and data in large. Chain page to new skb a=
nd pull tail.\n",
 		     length);
 	skb_fill_page_desc(skb, 0, lbq_desc->p.pg_chunk.page,
-				lbq_desc->p.pg_chunk.offset+ETH_HLEN,
-				length-ETH_HLEN);
-	skb->len +=3D length-ETH_HLEN;
-	skb->data_len +=3D length-ETH_HLEN;
-	skb->truesize +=3D length-ETH_HLEN;
+				lbq_desc->p.pg_chunk.offset + hlen,
+				length - hlen);
+	skb->len +=3D length - hlen;
+	skb->data_len +=3D length - hlen;
+	skb->truesize +=3D length - hlen;
=20
 	rx_ring->rx_packets++;
 	rx_ring->rx_bytes +=3D skb->len;
@@ -1576,7 +1594,7 @@ static void ql_process_mac_rx_page(struct ql_adap=
ter *qdev,
 				(ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_V4)) {
 			/* Unfragmented ipv4 UDP frame. */
 			struct iphdr *iph =3D
-				(struct iphdr *) ((u8 *)addr + ETH_HLEN);
+				(struct iphdr *) ((u8 *)addr + hlen);
 			if (!(iph->frag_off &
 				htons(IP_MF|IP_OFFSET))) {
 				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
@@ -1588,8 +1606,6 @@ static void ql_process_mac_rx_page(struct ql_adap=
ter *qdev,
 	}
=20
 	skb_record_rx_queue(skb, rx_ring->cq_id);
-	if (vlan_id !=3D 0xffff)
-		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 	if (skb->ip_summed =3D=3D CHECKSUM_UNNECESSARY)
 		napi_gro_receive(napi, skb);
 	else
@@ -1604,8 +1620,7 @@ err_out:
 static void ql_process_mac_rx_skb(struct ql_adapter *qdev,
 					struct rx_ring *rx_ring,
 					struct ib_mac_iocb_rsp *ib_mac_rsp,
-					u32 length,
-					u16 vlan_id)
+					u32 length)
 {
 	struct net_device *ndev =3D qdev->ndev;
 	struct sk_buff *skb =3D NULL;
@@ -1691,8 +1706,6 @@ static void ql_process_mac_rx_skb(struct ql_adapt=
er *qdev,
 	}
=20
 	skb_record_rx_queue(skb, rx_ring->cq_id);
-	if (vlan_id !=3D 0xffff)
-		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 	if (skb->ip_summed =3D=3D CHECKSUM_UNNECESSARY)
 		napi_gro_receive(&rx_ring->napi, skb);
 	else
@@ -1726,7 +1739,8 @@ static struct sk_buff *ql_build_rx_skb(struct ql_=
adapter *qdev,
 	struct bq_desc *sbq_desc;
 	struct sk_buff *skb =3D NULL;
 	u32 length =3D le32_to_cpu(ib_mac_rsp->data_len);
-       u32 hdr_len =3D le32_to_cpu(ib_mac_rsp->hdr_len);
+	u32 hdr_len =3D le32_to_cpu(ib_mac_rsp->hdr_len);
+	size_t hlen =3D ETH_HLEN;
=20
 	/*
 	 * Handle the header buffer if present.
@@ -1853,9 +1867,10 @@ static struct sk_buff *ql_build_rx_skb(struct ql=
_adapter *qdev,
 			skb->data_len +=3D length;
 			skb->truesize +=3D length;
 			length -=3D length;
-			__pskb_pull_tail(skb,
-				(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) ?
-				VLAN_ETH_HLEN : ETH_HLEN);
+			ql_update_mac_hdr_len(ib_mac_rsp,
+					      lbq_desc->p.pg_chunk.va,
+					      &hlen);
+			__pskb_pull_tail(skb, hlen);
 		}
 	} else {
 		/*
@@ -1910,8 +1925,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_=
adapter *qdev,
 			length -=3D size;
 			i++;
 		}
-		__pskb_pull_tail(skb, (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) ?
-				VLAN_ETH_HLEN : ETH_HLEN);
+		ql_update_mac_hdr_len(ib_mac_rsp, lbq_desc->p.pg_chunk.va,
+				      &hlen);
+		__pskb_pull_tail(skb, hlen);
 	}
 	return skb;
 }
@@ -1919,8 +1935,7 @@ static struct sk_buff *ql_build_rx_skb(struct ql_=
adapter *qdev,
 /* Process an inbound completion from an rx ring. */
 static void ql_process_mac_split_rx_intr(struct ql_adapter *qdev,
 				   struct rx_ring *rx_ring,
-				   struct ib_mac_iocb_rsp *ib_mac_rsp,
-				   u16 vlan_id)
+				   struct ib_mac_iocb_rsp *ib_mac_rsp)
 {
 	struct net_device *ndev =3D qdev->ndev;
 	struct sk_buff *skb =3D NULL;
@@ -2003,8 +2018,6 @@ static void ql_process_mac_split_rx_intr(struct q=
l_adapter *qdev,
 	rx_ring->rx_packets++;
 	rx_ring->rx_bytes +=3D skb->len;
 	skb_record_rx_queue(skb, rx_ring->cq_id);
-	if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) && (vlan_id !=3D 0))
-		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 	if (skb->ip_summed =3D=3D CHECKSUM_UNNECESSARY)
 		napi_gro_receive(&rx_ring->napi, skb);
 	else
@@ -2017,9 +2030,6 @@ static unsigned long ql_process_mac_rx_intr(struc=
t ql_adapter *qdev,
 					struct ib_mac_iocb_rsp *ib_mac_rsp)
 {
 	u32 length =3D le32_to_cpu(ib_mac_rsp->data_len);
-	u16 vlan_id =3D (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) ?
-			((le16_to_cpu(ib_mac_rsp->vlan_id) &
-			IB_MAC_IOCB_RSP_VLAN_MASK)) : 0xffff;
=20
 	QL_DUMP_IB_MAC_RSP(ib_mac_rsp);
=20
@@ -2027,35 +2037,30 @@ static unsigned long ql_process_mac_rx_intr(str=
uct ql_adapter *qdev,
 		/* The data and headers are split into
 		 * separate buffers.
 		 */
-		ql_process_mac_split_rx_intr(qdev, rx_ring, ib_mac_rsp,
-						vlan_id);
+		ql_process_mac_split_rx_intr(qdev, rx_ring, ib_mac_rsp);
 	} else if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DS) {
 		/* The data fit in a single small buffer.
 		 * Allocate a new skb, copy the data and
 		 * return the buffer to the free pool.
 		 */
-		ql_process_mac_rx_skb(qdev, rx_ring, ib_mac_rsp,
-						length, vlan_id);
+		ql_process_mac_rx_skb(qdev, rx_ring, ib_mac_rsp, length);
 	} else if ((ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DL) &&
 		!(ib_mac_rsp->flags1 & IB_MAC_CSUM_ERR_MASK) &&
 		(ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_T)) {
 		/* TCP packet in a page chunk that's been checksummed.
 		 * Tack it on to our GRO skb and let it go.
 		 */
-		ql_process_mac_rx_gro_page(qdev, rx_ring, ib_mac_rsp,
-						length, vlan_id);
+		ql_process_mac_rx_gro_page(qdev, rx_ring, ib_mac_rsp, length);
 	} else if (ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_DL) {
 		/* Non-TCP packet in a page chunk. Allocate an
 		 * skb, tack it on frags, and send it up.
 		 */
-		ql_process_mac_rx_page(qdev, rx_ring, ib_mac_rsp,
-						length, vlan_id);
+		ql_process_mac_rx_page(qdev, rx_ring, ib_mac_rsp, length);
 	} else {
 		/* Non-TCP/UDP large frames that span multiple buffers
 		 * can be processed corrrectly by the split frame logic.
 		 */
-		ql_process_mac_split_rx_intr(qdev, rx_ring, ib_mac_rsp,
-						vlan_id);
+		ql_process_mac_split_rx_intr(qdev, rx_ring, ib_mac_rsp);
 	}
=20
 	return (unsigned long)length;
@@ -2298,44 +2303,6 @@ static int ql_napi_poll_msix(struct napi_struct =
*napi, int budget)
 	return work_done;
 }
=20
-static void qlge_vlan_mode(struct net_device *ndev, netdev_features_t =
features)
-{
-	struct ql_adapter *qdev =3D netdev_priv(ndev);
-
-	if (features & NETIF_F_HW_VLAN_CTAG_RX) {
-		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK |
-				 NIC_RCV_CFG_VLAN_MATCH_AND_NON);
-	} else {
-		ql_write32(qdev, NIC_RCV_CFG, NIC_RCV_CFG_VLAN_MASK);
-	}
-}
-
-static netdev_features_t qlge_fix_features(struct net_device *ndev,
-	netdev_features_t features)
-{
-	/*
-	 * Since there is no support for separate rx/tx vlan accel
-	 * enable/disable make sure tx flag is always in same state as rx.
-	 */
-	if (features & NETIF_F_HW_VLAN_CTAG_RX)
-		features |=3D NETIF_F_HW_VLAN_CTAG_TX;
-	else
-		features &=3D ~NETIF_F_HW_VLAN_CTAG_TX;
-
-	return features;
-}
-
-static int qlge_set_features(struct net_device *ndev,
-	netdev_features_t features)
-{
-	netdev_features_t changed =3D ndev->features ^ features;
-
-	if (changed & NETIF_F_HW_VLAN_CTAG_RX)
-		qlge_vlan_mode(ndev, features);
-
-	return 0;
-}
-
 static int __qlge_vlan_rx_add_vid(struct ql_adapter *qdev, u16 vid)
 {
 	u32 enable_bit =3D MAC_ADDR_E;
@@ -3704,8 +3671,8 @@ static int ql_adapter_initialize(struct ql_adapte=
r *qdev)
 	ql_write32(qdev, SYS, mask | value);
=20
 	/* Set the default queue, and VLAN behavior. */
-	value =3D NIC_RCV_CFG_DFQ | NIC_RCV_CFG_RV;
-	mask =3D NIC_RCV_CFG_DFQ_MASK | (NIC_RCV_CFG_RV << 16);
+	value =3D NIC_RCV_CFG_DFQ;
+	mask =3D NIC_RCV_CFG_DFQ_MASK;
 	ql_write32(qdev, NIC_RCV_CFG, (mask | value));
=20
 	/* Set the MPI interrupt to enabled. */
@@ -4651,8 +4618,6 @@ static const struct net_device_ops qlge_netdev_op=
s =3D {
 	.ndo_set_mac_address	=3D qlge_set_mac_address,
 	.ndo_validate_addr	=3D eth_validate_addr,
 	.ndo_tx_timeout		=3D qlge_tx_timeout,
-	.ndo_fix_features	=3D qlge_fix_features,
-	.ndo_set_features	=3D qlge_set_features,
 	.ndo_vlan_rx_add_vid	=3D qlge_vlan_rx_add_vid,
 	.ndo_vlan_rx_kill_vid	=3D qlge_vlan_rx_kill_vid,
 };
@@ -4695,8 +4660,7 @@ static int qlge_probe(struct pci_dev *pdev,
 	ndev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN |
 		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_RXCSUM;
-	ndev->features =3D ndev->hw_features |
-		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
+	ndev->features =3D ndev->hw_features | NETIF_F_HW_VLAN_CTAG_FILTER;
 	ndev->vlan_features =3D ndev->hw_features;
=20
 	if (test_bit(QL_DMA64, &qdev->flags))
--=20
1.7.1
