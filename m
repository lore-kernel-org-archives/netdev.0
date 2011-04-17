From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: chelsio: convert to hw_features
Date: Sun, 17 Apr 2011 12:15:46 +0200 (CEST)
Message-ID: <20110417101546.EE73713A67@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:48100 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490Ab1DQKPs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 17 Apr 2011 06:15:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Also remove flags that were not used or are now redundant to hw_feature=
s bits.
No device had UDP_CSUM_CAPABLE set.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/chelsio/common.h |    5 ----
 drivers/net/chelsio/cxgb2.c  |   48 ++++++----------------------------=
-------
 drivers/net/chelsio/sge.c    |   12 +++++-----
 drivers/net/chelsio/tp.c     |    5 ----
 drivers/net/chelsio/tp.h     |    1 -
 5 files changed, 13 insertions(+), 58 deletions(-)

diff --git a/drivers/net/chelsio/common.h b/drivers/net/chelsio/common.=
h
index 092f31a..c26d863 100644
--- a/drivers/net/chelsio/common.h
+++ b/drivers/net/chelsio/common.h
@@ -264,11 +264,6 @@ struct adapter {
=20
 enum {                                           /* adapter flags */
 	FULL_INIT_DONE        =3D 1 << 0,
-	TSO_CAPABLE           =3D 1 << 2,
-	TCP_CSUM_CAPABLE      =3D 1 << 3,
-	UDP_CSUM_CAPABLE      =3D 1 << 4,
-	VLAN_ACCEL_CAPABLE    =3D 1 << 5,
-	RX_CSUM_ENABLED       =3D 1 << 6,
 };
=20
 struct mdio_ops;
diff --git a/drivers/net/chelsio/cxgb2.c b/drivers/net/chelsio/cxgb2.c
index 0f71304..5f82c9c 100644
--- a/drivers/net/chelsio/cxgb2.c
+++ b/drivers/net/chelsio/cxgb2.c
@@ -192,10 +192,8 @@ static void link_start(struct port_info *p)
=20
 static void enable_hw_csum(struct adapter *adapter)
 {
-	if (adapter->flags & TSO_CAPABLE)
+	if (adapter->port[0].dev->hw_features & NETIF_F_TSO)
 		t1_tp_set_ip_checksum_offload(adapter->tp, 1);	/* for TSO only */
-	if (adapter->flags & UDP_CSUM_CAPABLE)
-		t1_tp_set_udp_checksum_offload(adapter->tp, 1);
 	t1_tp_set_tcp_checksum_offload(adapter->tp, 1);
 }
=20
@@ -705,33 +703,6 @@ static int set_pauseparam(struct net_device *dev,
 	return 0;
 }
=20
-static u32 get_rx_csum(struct net_device *dev)
-{
-	struct adapter *adapter =3D dev->ml_priv;
-
-	return (adapter->flags & RX_CSUM_ENABLED) !=3D 0;
-}
-
-static int set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct adapter *adapter =3D dev->ml_priv;
-
-	if (data)
-		adapter->flags |=3D RX_CSUM_ENABLED;
-	else
-		adapter->flags &=3D ~RX_CSUM_ENABLED;
-	return 0;
-}
-
-static int set_tso(struct net_device *dev, u32 value)
-{
-	struct adapter *adapter =3D dev->ml_priv;
-
-	if (!(adapter->flags & TSO_CAPABLE))
-		return value ? -EOPNOTSUPP : 0;
-	return ethtool_op_set_tso(dev, value);
-}
-
 static void get_sge_param(struct net_device *dev, struct ethtool_ringp=
aram *e)
 {
 	struct adapter *adapter =3D dev->ml_priv;
@@ -831,17 +802,12 @@ static const struct ethtool_ops t1_ethtool_ops =3D=
 {
 	.get_eeprom        =3D get_eeprom,
 	.get_pauseparam    =3D get_pauseparam,
 	.set_pauseparam    =3D set_pauseparam,
-	.get_rx_csum       =3D get_rx_csum,
-	.set_rx_csum       =3D set_rx_csum,
-	.set_tx_csum       =3D ethtool_op_set_tx_csum,
-	.set_sg            =3D ethtool_op_set_sg,
 	.get_link          =3D ethtool_op_get_link,
 	.get_strings       =3D get_strings,
 	.get_sset_count	   =3D get_sset_count,
 	.get_ethtool_stats =3D get_stats,
 	.get_regs_len      =3D get_regs_len,
 	.get_regs          =3D get_regs,
-	.set_tso           =3D set_tso,
 };
=20
 static int t1_ioctl(struct net_device *dev, struct ifreq *req, int cmd=
)
@@ -1105,28 +1071,28 @@ static int __devinit init_one(struct pci_dev *p=
dev,
 		netdev->mem_start =3D mmio_start;
 		netdev->mem_end =3D mmio_start + mmio_len - 1;
 		netdev->ml_priv =3D adapter;
-		netdev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM;
-		netdev->features |=3D NETIF_F_LLTX;
+		netdev->hw_features |=3D NETIF_F_SG | NETIF_F_IP_CSUM |
+			NETIF_F_RXCSUM;
+		netdev->features |=3D NETIF_F_SG | NETIF_F_IP_CSUM |
+			NETIF_F_RXCSUM | NETIF_F_LLTX;
=20
-		adapter->flags |=3D RX_CSUM_ENABLED | TCP_CSUM_CAPABLE;
 		if (pci_using_dac)
 			netdev->features |=3D NETIF_F_HIGHDMA;
 		if (vlan_tso_capable(adapter)) {
 #if defined(CONFIG_VLAN_8021Q) || defined(CONFIG_VLAN_8021Q_MODULE)
-			adapter->flags |=3D VLAN_ACCEL_CAPABLE;
 			netdev->features |=3D
 				NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
 #endif
=20
 			/* T204: disable TSO */
 			if (!(is_T2(adapter)) || bi->port_number !=3D 4) {
-				adapter->flags |=3D TSO_CAPABLE;
+				netdev->hw_features |=3D NETIF_F_TSO;
 				netdev->features |=3D NETIF_F_TSO;
 			}
 		}
=20
 		netdev->netdev_ops =3D &cxgb_netdev_ops;
-		netdev->hard_header_len +=3D (adapter->flags & TSO_CAPABLE) ?
+		netdev->hard_header_len +=3D (netdev->hw_features & NETIF_F_TSO) ?
 			sizeof(struct cpl_tx_pkt_lso) : sizeof(struct cpl_tx_pkt);
=20
 		netif_napi_add(netdev, &adapter->napi, t1_poll, 64);
diff --git a/drivers/net/chelsio/sge.c b/drivers/net/chelsio/sge.c
index 8754d44..f225528 100644
--- a/drivers/net/chelsio/sge.c
+++ b/drivers/net/chelsio/sge.c
@@ -929,7 +929,7 @@ void t1_sge_intr_enable(struct sge *sge)
 	u32 en =3D SGE_INT_ENABLE;
 	u32 val =3D readl(sge->adapter->regs + A_PL_ENABLE);
=20
-	if (sge->adapter->flags & TSO_CAPABLE)
+	if (sge->adapter->port[0].dev->hw_features & NETIF_F_TSO)
 		en &=3D ~F_PACKET_TOO_BIG;
 	writel(en, sge->adapter->regs + A_SG_INT_ENABLE);
 	writel(val | SGE_PL_INTR_MASK, sge->adapter->regs + A_PL_ENABLE);
@@ -952,7 +952,7 @@ int t1_sge_intr_error_handler(struct sge *sge)
 	struct adapter *adapter =3D sge->adapter;
 	u32 cause =3D readl(adapter->regs + A_SG_INT_CAUSE);
=20
-	if (adapter->flags & TSO_CAPABLE)
+	if (adapter->port[0].dev->hw_features & NETIF_F_TSO)
 		cause &=3D ~F_PACKET_TOO_BIG;
 	if (cause & F_RESPQ_EXHAUSTED)
 		sge->stats.respQ_empty++;
@@ -1369,6 +1369,7 @@ static void sge_rx(struct sge *sge, struct freelQ=
 *fl, unsigned int len)
 	const struct cpl_rx_pkt *p;
 	struct adapter *adapter =3D sge->adapter;
 	struct sge_port_stats *st;
+	struct net_device *dev =3D adapter->port[p->iff].dev;
=20
 	skb =3D get_packet(adapter->pdev, fl, len - sge->rx_pkt_pad);
 	if (unlikely(!skb)) {
@@ -1385,8 +1386,8 @@ static void sge_rx(struct sge *sge, struct freelQ=
 *fl, unsigned int len)
=20
 	st =3D this_cpu_ptr(sge->port_stats[p->iff]);
=20
-	skb->protocol =3D eth_type_trans(skb, adapter->port[p->iff].dev);
-	if ((adapter->flags & RX_CSUM_ENABLED) && p->csum =3D=3D 0xffff &&
+	skb->protocol =3D eth_type_trans(skb, dev);
+	if ((dev->features & NETIF_F_RXCSUM) && p->csum =3D=3D 0xffff &&
 	    skb->protocol =3D=3D htons(ETH_P_IP) &&
 	    (skb->data[9] =3D=3D IPPROTO_TCP || skb->data[9] =3D=3D IPPROTO_U=
DP)) {
 		++st->rx_cso_good;
@@ -1838,8 +1839,7 @@ netdev_tx_t t1_start_xmit(struct sk_buff *skb, st=
ruct net_device *dev)
 			return NETDEV_TX_OK;
 		}
=20
-		if (!(adapter->flags & UDP_CSUM_CAPABLE) &&
-		    skb->ip_summed =3D=3D CHECKSUM_PARTIAL &&
+		if (skb->ip_summed =3D=3D CHECKSUM_PARTIAL &&
 		    ip_hdr(skb)->protocol =3D=3D IPPROTO_UDP) {
 			if (unlikely(skb_checksum_help(skb))) {
 				pr_debug("%s: unable to do udp checksum\n", dev->name);
diff --git a/drivers/net/chelsio/tp.c b/drivers/net/chelsio/tp.c
index 6222d58..8bed4a5 100644
--- a/drivers/net/chelsio/tp.c
+++ b/drivers/net/chelsio/tp.c
@@ -152,11 +152,6 @@ void t1_tp_set_ip_checksum_offload(struct petp *tp=
, int enable)
 	set_csum_offload(tp, F_IP_CSUM, enable);
 }
=20
-void t1_tp_set_udp_checksum_offload(struct petp *tp, int enable)
-{
-	set_csum_offload(tp, F_UDP_CSUM, enable);
-}
-
 void t1_tp_set_tcp_checksum_offload(struct petp *tp, int enable)
 {
 	set_csum_offload(tp, F_TCP_CSUM, enable);
diff --git a/drivers/net/chelsio/tp.h b/drivers/net/chelsio/tp.h
index 32fc71e..dfd8ce2 100644
--- a/drivers/net/chelsio/tp.h
+++ b/drivers/net/chelsio/tp.h
@@ -65,7 +65,6 @@ void t1_tp_intr_clear(struct petp *tp);
 int t1_tp_intr_handler(struct petp *tp);
=20
 void t1_tp_get_mib_statistics(adapter_t *adap, struct tp_mib_statistic=
s *tps);
-void t1_tp_set_udp_checksum_offload(struct petp *tp, int enable);
 void t1_tp_set_tcp_checksum_offload(struct petp *tp, int enable);
 void t1_tp_set_ip_checksum_offload(struct petp *tp, int enable);
 int t1_tp_set_coalescing_size(struct petp *tp, unsigned int size);
--=20
1.7.2.5

