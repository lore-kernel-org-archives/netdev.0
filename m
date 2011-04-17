From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: cxgb3: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:46 +0200 (CEST)
Message-ID: <20110417101546.7EDF613A66@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Divy Le Ray <divy@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48095 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752112Ab1DQKPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This removes some of the remnants of LRO -> GRO conversion.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/cxgb3/adapter.h    |    7 ----
 drivers/net/cxgb3/common.h     |    1 -
 drivers/net/cxgb3/cxgb3_main.c |   78 +++++++-------------------------=
--------
 drivers/net/cxgb3/sge.c        |    7 ++--
 4 files changed, 17 insertions(+), 76 deletions(-)

diff --git a/drivers/net/cxgb3/adapter.h b/drivers/net/cxgb3/adapter.h
index ef67be5..7300de5 100644
--- a/drivers/net/cxgb3/adapter.h
+++ b/drivers/net/cxgb3/adapter.h
@@ -50,11 +50,6 @@ struct adapter;
 struct sge_qset;
 struct port_info;
=20
-enum {			/* rx_offload flags */
-	T3_RX_CSUM	=3D 1 << 0,
-	T3_LRO		=3D 1 << 1,
-};
-
 enum mac_idx_types {
 	LAN_MAC_IDX	=3D 0,
 	SAN_MAC_IDX,
@@ -74,7 +69,6 @@ struct port_info {
 	struct vlan_group *vlan_grp;
 	struct sge_qset *qs;
 	u8 port_id;
-	u8 rx_offload;
 	u8 nqsets;
 	u8 first_qset;
 	struct cphy phy;
@@ -212,7 +206,6 @@ struct sge_qset {		/* an SGE queue set */
 	struct sge_fl fl[SGE_RXQ_PER_SET];
 	struct sge_txq txq[SGE_TXQ_PER_SET];
 	int nomem;
-	int lro_enabled;
 	void *lro_va;
 	struct net_device *netdev;
 	struct netdev_queue *tx_q;	/* associated netdev TX queue */
diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index 5ccb77d..056ee8c 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -317,7 +317,6 @@ struct tp_params {
=20
 struct qset_params {		/* SGE queue set parameters */
 	unsigned int polling;	/* polling/interrupt service for rspq */
-	unsigned int lro;	/* large receive offload */
 	unsigned int coalesce_usecs;	/* irq coalescing timer */
 	unsigned int rspq_size;	/* # of entries in response queue */
 	unsigned int fl_size;	/* # of entries in regular free list */
diff --git a/drivers/net/cxgb3/cxgb3_main.c b/drivers/net/cxgb3/cxgb3_m=
ain.c
index a087e06..0404918 100644
--- a/drivers/net/cxgb3/cxgb3_main.c
+++ b/drivers/net/cxgb3/cxgb3_main.c
@@ -644,26 +644,6 @@ static void enable_all_napi(struct adapter *adap)
 }
=20
 /**
- *	set_qset_lro - Turn a queue set's LRO capability on and off
- *	@dev: the device the qset is attached to
- *	@qset_idx: the queue set index
- *	@val: the LRO switch
- *
- *	Sets LRO on or off for a particular queue set.
- *	the device's features flag is updated to reflect the LRO
- *	capability when all queues belonging to the device are
- *	in the same state.
- */
-static void set_qset_lro(struct net_device *dev, int qset_idx, int val=
)
-{
-	struct port_info *pi =3D netdev_priv(dev);
-	struct adapter *adapter =3D pi->adapter;
-
-	adapter->params.sge.qset[qset_idx].lro =3D !!val;
-	adapter->sge.qs[qset_idx].lro_enabled =3D !!val;
-}
-
-/**
  *	setup_sge_qsets - configure SGE Tx/Rx/response queues
  *	@adap: the adapter
  *
@@ -685,7 +665,6 @@ static int setup_sge_qsets(struct adapter *adap)
=20
 		pi->qs =3D &adap->sge.qs[pi->first_qset];
 		for (j =3D 0; j < pi->nqsets; ++j, ++qset_idx) {
-			set_qset_lro(dev, qset_idx, pi->rx_offload & T3_LRO);
 			err =3D t3_sge_alloc_qset(adap, qset_idx, 1,
 				(adap->flags & USING_MSIX) ? qset_idx + 1 :
 							     irq_idx,
@@ -1910,29 +1889,6 @@ static int set_pauseparam(struct net_device *dev=
,
 	return 0;
 }
=20
-static u32 get_rx_csum(struct net_device *dev)
-{
-	struct port_info *p =3D netdev_priv(dev);
-
-	return p->rx_offload & T3_RX_CSUM;
-}
-
-static int set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct port_info *p =3D netdev_priv(dev);
-
-	if (data) {
-		p->rx_offload |=3D T3_RX_CSUM;
-	} else {
-		int i;
-
-		p->rx_offload &=3D ~(T3_RX_CSUM | T3_LRO);
-		for (i =3D p->first_qset; i < p->first_qset + p->nqsets; i++)
-			set_qset_lro(dev, i, 0);
-	}
-	return 0;
-}
-
 static void get_sge_param(struct net_device *dev, struct ethtool_ringp=
aram *e)
 {
 	struct port_info *pi =3D netdev_priv(dev);
@@ -2104,10 +2060,6 @@ static const struct ethtool_ops cxgb_ethtool_ops=
 =3D {
 	.set_eeprom =3D set_eeprom,
 	.get_pauseparam =3D get_pauseparam,
 	.set_pauseparam =3D set_pauseparam,
-	.get_rx_csum =3D get_rx_csum,
-	.set_rx_csum =3D set_rx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
 	.get_link =3D ethtool_op_get_link,
 	.get_strings =3D get_strings,
 	.set_phys_id =3D set_phys_id,
@@ -2117,7 +2069,6 @@ static const struct ethtool_ops cxgb_ethtool_ops =
=3D {
 	.get_regs_len =3D get_regs_len,
 	.get_regs =3D get_regs,
 	.get_wol =3D get_wol,
-	.set_tso =3D ethtool_op_set_tso,
 };
=20
 static int in_range(int val, int lo, int hi)
@@ -2165,15 +2116,6 @@ static int cxgb_extension_ioctl(struct net_devic=
e *dev, void __user *useraddr)
 			      MAX_RSPQ_ENTRIES))
 			return -EINVAL;
=20
-		if ((adapter->flags & FULL_INIT_DONE) && t.lro > 0)
-			for_each_port(adapter, i) {
-				pi =3D adap2pinfo(adapter, i);
-				if (t.qset_idx >=3D pi->first_qset &&
-				    t.qset_idx < pi->first_qset + pi->nqsets &&
-				    !(pi->rx_offload & T3_RX_CSUM))
-					return -EINVAL;
-			}
-
 		if ((adapter->flags & FULL_INIT_DONE) &&
 			(t.rspq_size >=3D 0 || t.fl_size[0] >=3D 0 ||
 			t.fl_size[1] >=3D 0 || t.txq_size[0] >=3D 0 ||
@@ -2234,8 +2176,14 @@ static int cxgb_extension_ioctl(struct net_devic=
e *dev, void __user *useraddr)
 				}
 			}
 		}
-		if (t.lro >=3D 0)
-			set_qset_lro(dev, t.qset_idx, t.lro);
+
+		if (t.lro >=3D 0) {
+			if (t.lro)
+				dev->wanted_features |=3D NETIF_F_GRO;
+			else
+				dev->wanted_features &=3D ~NETIF_F_GRO;
+			netdev_update_features(dev);
+		}
=20
 		break;
 	}
@@ -2269,7 +2217,7 @@ static int cxgb_extension_ioctl(struct net_device=
 *dev, void __user *useraddr)
 		t.fl_size[0] =3D q->fl_size;
 		t.fl_size[1] =3D q->jumbo_size;
 		t.polling =3D q->polling;
-		t.lro =3D q->lro;
+		t.lro =3D !!(dev->features & NETIF_F_GRO);
 		t.intr_lat =3D q->coalesce_usecs;
 		t.cong_thres =3D q->cong_thres;
 		t.qnum =3D q1;
@@ -3307,18 +3255,18 @@ static int __devinit init_one(struct pci_dev *p=
dev,
 		adapter->port[i] =3D netdev;
 		pi =3D netdev_priv(netdev);
 		pi->adapter =3D adapter;
-		pi->rx_offload =3D T3_RX_CSUM | T3_LRO;
 		pi->port_id =3D i;
 		netif_carrier_off(netdev);
 		netdev->irq =3D pdev->irq;
 		netdev->mem_start =3D mmio_start;
 		netdev->mem_end =3D mmio_start + mmio_len - 1;
-		netdev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO;
-		netdev->features |=3D NETIF_F_GRO;
+		netdev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM |
+			NETIF_F_TSO | NETIF_F_RXCSUM;
+		netdev->features |=3D netdev->hw_features |
+			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		if (pci_using_dac)
 			netdev->features |=3D NETIF_F_HIGHDMA;
=20
-		netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 		netdev->netdev_ops =3D &cxgb_netdev_ops;
 		SET_ETHTOOL_OPS(netdev, &cxgb_ethtool_ops);
 	}
diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index bfa2d56..cba1401 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2019,7 +2019,7 @@ static void rx_eth(struct adapter *adap, struct s=
ge_rspq *rq,
 	skb_pull(skb, sizeof(*p) + pad);
 	skb->protocol =3D eth_type_trans(skb, adap->port[p->iff]);
 	pi =3D netdev_priv(skb->dev);
-	if ((pi->rx_offload & T3_RX_CSUM) && p->csum_valid &&
+	if ((skb->dev->features & NETIF_F_RXCSUM) && p->csum_valid &&
 	    p->csum =3D=3D htons(0xffff) && !p->fragment) {
 		qs->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
@@ -2120,7 +2120,7 @@ static void lro_add_page(struct adapter *adap, st=
ruct sge_qset *qs,
 		offset =3D 2 + sizeof(struct cpl_rx_pkt);
 		cpl =3D qs->lro_va =3D sd->pg_chunk.va + 2;
=20
-		if ((pi->rx_offload & T3_RX_CSUM) &&
+		if ((qs->netdev->features & NETIF_F_RXCSUM) &&
 		     cpl->csum_valid && cpl->csum =3D=3D htons(0xffff)) {
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 			qs->port_stats[SGE_PSTAT_RX_CSUM_GOOD]++;
@@ -2285,7 +2285,8 @@ static int process_responses(struct adapter *adap=
, struct sge_qset *qs,
 	q->next_holdoff =3D q->holdoff_tmr;
=20
 	while (likely(budget_left && is_new_response(r, q))) {
-		int packet_complete, eth, ethpad =3D 2, lro =3D qs->lro_enabled;
+		int packet_complete, eth, ethpad =3D 2;
+		int lro =3D !!(qs->netdev->features & NETIF_F_GRO);
 		struct sk_buff *skb =3D NULL;
 		u32 len, flags;
 		__be32 rss_hi, rss_lo;
--=20
1.7.2.5

