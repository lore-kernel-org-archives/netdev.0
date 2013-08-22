From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH net-next 1/2] qlge: Enhance nested VLAN (Q-in-Q) handling.
Date: Thu, 22 Aug 2013 15:54:11 -0400
Message-ID: <1377201252-9283-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1377201252-9283-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept_NX_Linux_NIC_Driver@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:62064 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753763Ab3HVUgg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Aug 2013 16:36:36 -0400
In-Reply-To: <1377201252-9283-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

Adapter doesn=E2=80=99t handle packets with nested VLAN tags in
Rx path. Turn off VLAN tag stripping in the hardware and
let the stack handle stripping of VLAN tags in the Rx path.

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |   79 ++++++++++++++++++=
+-------
 1 files changed, 59 insertions(+), 20 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net=
/ethernet/qlogic/qlge/qlge_main.c
index 2553cf4..f6f2c5f 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -87,6 +87,12 @@ MODULE_PARM_DESC(qlge_force_coredump,
 		"Option to allow force of firmware core dump. "
 		"Default is OFF - Do not allow.");
=20
+static int qlge_hw_strip_vlan;
+module_param(qlge_hw_strip_vlan, int, 0);
+MODULE_PARM_DESC(qlge_hw_strip_vlan,
+		"Option to enable hardware to strip vlan tag. "
+		"Default is OFF - Hardware will not strip.");
+
 static DEFINE_PCI_DEVICE_TABLE(qlge_pci_tbl) =3D {
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8012)},
 	{PCI_DEVICE(PCI_VENDOR_ID_QLOGIC, QLGE_DEVICE_ID_8000)},
@@ -1464,6 +1470,25 @@ static void ql_categorize_rx_err(struct ql_adapt=
er *qdev, u8 rx_err,
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
+	if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) && !qlge_hw_strip_vlan) =
{
+		tags =3D (u16 *)page;
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
@@ -1523,6 +1548,7 @@ static void ql_process_mac_rx_page(struct ql_adap=
ter *qdev,
 	void *addr;
 	struct bq_desc *lbq_desc =3D ql_get_curr_lchunk(qdev, rx_ring);
 	struct napi_struct *napi =3D &rx_ring->napi;
+	size_t hlen =3D ETH_HLEN;
=20
 	skb =3D netdev_alloc_skb(ndev, length);
 	if (!skb) {
@@ -1540,25 +1566,28 @@ static void ql_process_mac_rx_page(struct ql_ad=
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
@@ -1576,7 +1605,7 @@ static void ql_process_mac_rx_page(struct ql_adap=
ter *qdev,
 				(ib_mac_rsp->flags3 & IB_MAC_IOCB_RSP_V4)) {
 			/* Unfragmented ipv4 UDP frame. */
 			struct iphdr *iph =3D
-				(struct iphdr *) ((u8 *)addr + ETH_HLEN);
+				(struct iphdr *) ((u8 *)addr + hlen);
 			if (!(iph->frag_off &
 				htons(IP_MF|IP_OFFSET))) {
 				skb->ip_summed =3D CHECKSUM_UNNECESSARY;
@@ -1726,7 +1755,8 @@ static struct sk_buff *ql_build_rx_skb(struct ql_=
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
@@ -1853,9 +1883,10 @@ static struct sk_buff *ql_build_rx_skb(struct ql=
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
@@ -1910,8 +1941,9 @@ static struct sk_buff *ql_build_rx_skb(struct ql_=
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
@@ -2003,7 +2035,7 @@ static void ql_process_mac_split_rx_intr(struct q=
l_adapter *qdev,
 	rx_ring->rx_packets++;
 	rx_ring->rx_bytes +=3D skb->len;
 	skb_record_rx_queue(skb, rx_ring->cq_id);
-	if ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) && (vlan_id !=3D 0))
+	if (vlan_id !=3D 0xffff)
 		__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), vlan_id);
 	if (skb->ip_summed =3D=3D CHECKSUM_UNNECESSARY)
 		napi_gro_receive(&rx_ring->napi, skb);
@@ -2017,7 +2049,8 @@ static unsigned long ql_process_mac_rx_intr(struc=
t ql_adapter *qdev,
 					struct ib_mac_iocb_rsp *ib_mac_rsp)
 {
 	u32 length =3D le32_to_cpu(ib_mac_rsp->data_len);
-	u16 vlan_id =3D (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) ?
+	u16 vlan_id =3D ((ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) &&
+			qlge_hw_strip_vlan) ?
 			((le16_to_cpu(ib_mac_rsp->vlan_id) &
 			IB_MAC_IOCB_RSP_VLAN_MASK)) : 0xffff;
=20
@@ -3704,8 +3737,12 @@ static int ql_adapter_initialize(struct ql_adapt=
er *qdev)
 	ql_write32(qdev, SYS, mask | value);
=20
 	/* Set the default queue, and VLAN behavior. */
-	value =3D NIC_RCV_CFG_DFQ | NIC_RCV_CFG_RV;
-	mask =3D NIC_RCV_CFG_DFQ_MASK | (NIC_RCV_CFG_RV << 16);
+	value =3D NIC_RCV_CFG_DFQ;
+	mask =3D NIC_RCV_CFG_DFQ_MASK;
+	if (qdev->ndev->features & NETIF_F_HW_VLAN_CTAG_RX) {
+		value |=3D NIC_RCV_CFG_RV;
+		mask |=3D (NIC_RCV_CFG_RV << 16);
+	}
 	ql_write32(qdev, NIC_RCV_CFG, (mask | value));
=20
 	/* Set the MPI interrupt to enabled. */
@@ -4695,10 +4732,12 @@ static int qlge_probe(struct pci_dev *pdev,
 	ndev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM |
 		NETIF_F_TSO | NETIF_F_TSO_ECN |
 		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_RXCSUM;
-	ndev->features =3D ndev->hw_features |
-		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
+	ndev->features =3D ndev->hw_features | NETIF_F_HW_VLAN_CTAG_FILTER;
 	ndev->vlan_features =3D ndev->hw_features;
=20
+	if (qlge_hw_strip_vlan)
+		ndev->features |=3D NETIF_F_HW_VLAN_CTAG_RX;
+
 	if (test_bit(QL_DMA64, &qdev->flags))
 		ndev->features |=3D NETIF_F_HIGHDMA;
=20
--=20
1.7.1
