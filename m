From: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
Subject: [PATCH v3 net-next 1/2] qlge: Enhance nested VLAN (Q-in-Q) handling.
Date: Fri, 27 Sep 2013 13:17:46 -0400
Message-ID: <1380302267-27843-2-git-send-email-jitendra.kalsaria@qlogic.com>
References: <1380302267-27843-1-git-send-email-jitendra.kalsaria@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <ron.mercer@qlogic.com>,
	<Dept-HSGLinuxNICDev@qlogic.com>,
	Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:61938 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753513Ab3I0Rri convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Sep 2013 13:47:38 -0400
In-Reply-To: <1380302267-27843-1-git-send-email-jitendra.kalsaria@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>

o Adapter doesn=E2=80=99t handle packets with nested VLAN tags in
Rx path. User can turn off VLAN tag stripping in the hardware
and let the stack handle stripping of VLAN tags in the Rx path.

o Users can enable or disable hardware VLAN acceleration using ethtool

Signed-off-by: Jitendra Kalsaria <jitendra.kalsaria@qlogic.com>
---
 drivers/net/ethernet/qlogic/qlge/qlge_main.c |  126 ++++++++++++++++++=
+++-----
 1 files changed, 101 insertions(+), 25 deletions(-)

diff --git a/drivers/net/ethernet/qlogic/qlge/qlge_main.c b/drivers/net=
/ethernet/qlogic/qlge/qlge_main.c
index 2553cf4..64f9409 100644
--- a/drivers/net/ethernet/qlogic/qlge/qlge_main.c
+++ b/drivers/net/ethernet/qlogic/qlge/qlge_main.c
@@ -96,8 +96,10 @@ static DEFINE_PCI_DEVICE_TABLE(qlge_pci_tbl) =3D {
=20
 MODULE_DEVICE_TABLE(pci, qlge_pci_tbl);
=20
-static int ql_wol(struct ql_adapter *qdev);
-static void qlge_set_multicast_list(struct net_device *ndev);
+static int ql_wol(struct ql_adapter *);
+static void qlge_set_multicast_list(struct net_device *);
+static int ql_adapter_down(struct ql_adapter *);
+static int ql_adapter_up(struct ql_adapter *);
=20
 /* This hardware semaphore causes exclusive access to
  * resources shared between the NIC driver, MPI firmware,
@@ -1464,6 +1466,29 @@ static void ql_categorize_rx_err(struct ql_adapt=
er *qdev, u8 rx_err,
 	}
 }
=20
+/**
+ * ql_update_mac_hdr_len - helper routine to update the mac header len=
gth
+ * based on vlan tags if present
+ */
+static void ql_update_mac_hdr_len(struct ql_adapter *qdev,
+				  struct ib_mac_iocb_rsp *ib_mac_rsp,
+				  void *page, size_t *len)
+{
+	u16 *tags;
+
+	if (qdev->ndev->features & NETIF_F_HW_VLAN_CTAG_RX)
+		return;
+	if (ib_mac_rsp->flags2 & IB_MAC_IOCB_RSP_V) {
+		tags =3D (u16 *)page;
+		/* Look for stacked vlan tags in ethertype field */
+		if (tags[6] =3D=3D ETH_P_8021Q &&
+		    tags[8] =3D=3D ETH_P_8021Q)
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
+	ql_update_mac_hdr_len(qdev, ib_mac_rsp, addr, &hlen);
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
+				(struct iphdr *)((u8 *)addr + hlen);
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
+			ql_update_mac_hdr_len(qdev, ib_mac_rsp,
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
+		ql_update_mac_hdr_len(qdev, ib_mac_rsp, lbq_desc->p.pg_chunk.va,
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
+			(qdev->ndev->features & NETIF_F_HW_VLAN_CTAG_RX)) ?
 			((le16_to_cpu(ib_mac_rsp->vlan_id) &
 			IB_MAC_IOCB_RSP_VLAN_MASK)) : 0xffff;
=20
@@ -2310,9 +2343,39 @@ static void qlge_vlan_mode(struct net_device *nd=
ev, netdev_features_t features)
 	}
 }
=20
+/**
+ * qlge_update_hw_vlan_features - helper routine to reinitialize the a=
dapter
+ * based on the features to enable/disable hardware vlan accel
+ */
+static int qlge_update_hw_vlan_features(struct net_device *ndev,
+					netdev_features_t features)
+{
+	struct ql_adapter *qdev =3D netdev_priv(ndev);
+	int status =3D 0;
+
+	status =3D ql_adapter_down(qdev);
+	if (status) {
+		netif_err(qdev, link, qdev->ndev,
+			  "Failed to bring down the adapter\n");
+		return status;
+	}
+
+	/* update the features with resent change */
+	ndev->features =3D features;
+
+	status =3D ql_adapter_up(qdev);
+	if (status) {
+		netif_err(qdev, link, qdev->ndev,
+			  "Failed to bring up the adapter\n");
+		return status;
+	}
+	return status;
+}
+
 static netdev_features_t qlge_fix_features(struct net_device *ndev,
 	netdev_features_t features)
 {
+	int err;
 	/*
 	 * Since there is no support for separate rx/tx vlan accel
 	 * enable/disable make sure tx flag is always in same state as rx.
@@ -2322,6 +2385,11 @@ static netdev_features_t qlge_fix_features(struc=
t net_device *ndev,
 	else
 		features &=3D ~NETIF_F_HW_VLAN_CTAG_TX;
=20
+	/* Update the behavior of vlan accel in the adapter */
+	err =3D qlge_update_hw_vlan_features(ndev, features);
+	if (err)
+		return err;
+
 	return features;
 }
=20
@@ -3704,8 +3772,12 @@ static int ql_adapter_initialize(struct ql_adapt=
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
@@ -4692,11 +4764,15 @@ static int qlge_probe(struct pci_dev *pdev,
=20
 	qdev =3D netdev_priv(ndev);
 	SET_NETDEV_DEV(ndev, &pdev->dev);
-	ndev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_TSO | NETIF_F_TSO_ECN |
-		NETIF_F_HW_VLAN_CTAG_TX | NETIF_F_RXCSUM;
-	ndev->features =3D ndev->hw_features |
-		NETIF_F_HW_VLAN_CTAG_RX | NETIF_F_HW_VLAN_CTAG_FILTER;
+	ndev->hw_features =3D NETIF_F_SG |
+			    NETIF_F_IP_CSUM |
+			    NETIF_F_TSO |
+			    NETIF_F_TSO_ECN |
+			    NETIF_F_HW_VLAN_CTAG_TX |
+			    NETIF_F_HW_VLAN_CTAG_RX |
+			    NETIF_F_HW_VLAN_CTAG_FILTER |
+			    NETIF_F_RXCSUM;
+	ndev->features =3D ndev->hw_features;
 	ndev->vlan_features =3D ndev->hw_features;
=20
 	if (test_bit(QL_DMA64, &qdev->flags))
--=20
1.7.6.rc1.1.g2c162b
