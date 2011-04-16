From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v3] net: cxgb4{,vf}: convert to hw_features
Date: Sun, 17 Apr 2011 01:05:08 +0200 (CEST)
Message-ID: <20110416230508.38A6113A65@rere.qmqm.pl>
References: <20110415145050.6A43913A6A@rere.qmqm.pl> <20110416165226.B881F13A65@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dimitris Michailidis <dm@chelsio.com>,
	Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:58791 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753943Ab1DPXFJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Apr 2011 19:05:09 -0400
In-Reply-To: <20110416165226.B881F13A65@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
v3: cxgb4vf: fix hw/vlan_features values again
v2: cxgb4: remove now unneeded variable in t4_ethrx_handler()
    cxgb4vf: fix hw/vlan_features values

 drivers/net/cxgb4/cxgb4.h          |    6 ---
 drivers/net/cxgb4/cxgb4_main.c     |   72 ++++++++--------------------=
-------
 drivers/net/cxgb4/sge.c            |    4 +-
 drivers/net/cxgb4vf/adapter.h      |    6 ---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   57 ++++------------------------
 drivers/net/cxgb4vf/sge.c          |    4 +-
 6 files changed, 28 insertions(+), 121 deletions(-)

diff --git a/drivers/net/cxgb4/cxgb4.h b/drivers/net/cxgb4/cxgb4.h
index 01d49ea..bc9982a 100644
--- a/drivers/net/cxgb4/cxgb4.h
+++ b/drivers/net/cxgb4/cxgb4.h
@@ -290,7 +290,6 @@ struct port_info {
 	u8     port_id;
 	u8     tx_chan;
 	u8     lport;                 /* associated offload logical port */
-	u8     rx_offload;            /* CSO, etc */
 	u8     nqsets;                /* # of qsets */
 	u8     first_qset;            /* index of first qset */
 	u8     rss_mode;
@@ -298,11 +297,6 @@ struct port_info {
 	u16   *rss;
 };
=20
-/* port_info.rx_offload flags */
-enum {
-	RX_CSO =3D 1 << 0,
-};
-
 struct dentry;
 struct work_struct;
=20
diff --git a/drivers/net/cxgb4/cxgb4_main.c b/drivers/net/cxgb4/cxgb4_m=
ain.c
index 0af9c9f..bdc868c 100644
--- a/drivers/net/cxgb4/cxgb4_main.c
+++ b/drivers/net/cxgb4/cxgb4_main.c
@@ -1531,24 +1531,6 @@ static int set_pauseparam(struct net_device *dev=
,
 	return 0;
 }
=20
-static u32 get_rx_csum(struct net_device *dev)
-{
-	struct port_info *p =3D netdev_priv(dev);
-
-	return p->rx_offload & RX_CSO;
-}
-
-static int set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct port_info *p =3D netdev_priv(dev);
-
-	if (data)
-		p->rx_offload |=3D RX_CSO;
-	else
-		p->rx_offload &=3D ~RX_CSO;
-	return 0;
-}
-
 static void get_sge_param(struct net_device *dev, struct ethtool_ringp=
aram *e)
 {
 	const struct port_info *pi =3D netdev_priv(dev);
@@ -1870,36 +1852,20 @@ static int set_wol(struct net_device *dev, stru=
ct ethtool_wolinfo *wol)
 	return err;
 }
=20
-#define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
-
-static int set_tso(struct net_device *dev, u32 value)
-{
-	if (value)
-		dev->features |=3D TSO_FLAGS;
-	else
-		dev->features &=3D ~TSO_FLAGS;
-	return 0;
-}
-
-static int set_flags(struct net_device *dev, u32 flags)
+static int cxgb_set_features(struct net_device *dev, u32 features)
 {
+	const struct port_info *pi =3D netdev_priv(dev);
+	u32 changed =3D dev->features ^ features;
 	int err;
-	unsigned long old_feat =3D dev->features;
=20
-	err =3D ethtool_op_set_flags(dev, flags, ETH_FLAG_RXHASH |
-				   ETH_FLAG_RXVLAN | ETH_FLAG_TXVLAN);
-	if (err)
-		return err;
+	if (!(changed & NETIF_F_HW_VLAN_RX))
+		return 0;
=20
-	if ((old_feat ^ dev->features) & NETIF_F_HW_VLAN_RX) {
-		const struct port_info *pi =3D netdev_priv(dev);
-
-		err =3D t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, -1,
-				    -1, -1, -1, !!(flags & ETH_FLAG_RXVLAN),
-				    true);
-		if (err)
-			dev->features =3D old_feat;
-	}
+	err =3D t4_set_rxmode(pi->adapter, pi->adapter->fn, pi->viid, -1,
+			    -1, -1, -1,
+			    !!(features & NETIF_F_HW_VLAN_RX), true);
+	if (unlikely(err))
+		dev->features =3D features ^ NETIF_F_HW_VLAN_RX;
 	return err;
 }
=20
@@ -2010,10 +1976,6 @@ static struct ethtool_ops cxgb_ethtool_ops =3D {
 	.set_eeprom        =3D set_eeprom,
 	.get_pauseparam    =3D get_pauseparam,
 	.set_pauseparam    =3D set_pauseparam,
-	.get_rx_csum       =3D get_rx_csum,
-	.set_rx_csum       =3D set_rx_csum,
-	.set_tx_csum       =3D ethtool_op_set_tx_ipv6_csum,
-	.set_sg            =3D ethtool_op_set_sg,
 	.get_link          =3D ethtool_op_get_link,
 	.get_strings       =3D get_strings,
 	.set_phys_id       =3D identify_port,
@@ -2024,8 +1986,6 @@ static struct ethtool_ops cxgb_ethtool_ops =3D {
 	.get_regs          =3D get_regs,
 	.get_wol           =3D get_wol,
 	.set_wol           =3D set_wol,
-	.set_tso           =3D set_tso,
-	.set_flags         =3D set_flags,
 	.get_rxnfc         =3D get_rxnfc,
 	.get_rxfh_indir    =3D get_rss_table,
 	.set_rxfh_indir    =3D set_rss_table,
@@ -2882,6 +2842,7 @@ static const struct net_device_ops cxgb4_netdev_o=
ps =3D {
 	.ndo_get_stats64      =3D cxgb_get_stats,
 	.ndo_set_rx_mode      =3D cxgb_set_rxmode,
 	.ndo_set_mac_address  =3D cxgb_set_mac_addr,
+	.ndo_set_features     =3D cxgb_set_features,
 	.ndo_validate_addr    =3D eth_validate_addr,
 	.ndo_do_ioctl         =3D cxgb_ioctl,
 	.ndo_change_mtu       =3D cxgb_change_mtu,
@@ -3564,6 +3525,7 @@ static void free_some_resources(struct adapter *a=
dapter)
 		t4_fw_bye(adapter, adapter->fn);
 }
=20
+#define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
 #define VLAN_FEAT (NETIF_F_SG | NETIF_F_IP_CSUM | TSO_FLAGS | \
 		   NETIF_F_IPV6_CSUM | NETIF_F_HIGHDMA)
=20
@@ -3665,14 +3627,14 @@ static int __devinit init_one(struct pci_dev *p=
dev,
 		pi =3D netdev_priv(netdev);
 		pi->adapter =3D adapter;
 		pi->xact_addr_filt =3D -1;
-		pi->rx_offload =3D RX_CSO;
 		pi->port_id =3D i;
 		netdev->irq =3D pdev->irq;
=20
-		netdev->features |=3D NETIF_F_SG | TSO_FLAGS;
-		netdev->features |=3D NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM;
-		netdev->features |=3D NETIF_F_GRO | NETIF_F_RXHASH | highdma;
-		netdev->features |=3D NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		netdev->hw_features =3D NETIF_F_SG | TSO_FLAGS |
+			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+			NETIF_F_RXCSUM | NETIF_F_RXHASH |
+			NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX;
+		netdev->features |=3D netdev->hw_features | highdma;
 		netdev->vlan_features =3D netdev->features & VLAN_FEAT;
=20
 		netdev->netdev_ops =3D &cxgb4_netdev_ops;
diff --git a/drivers/net/cxgb4/sge.c b/drivers/net/cxgb4/sge.c
index 311471b..75a4b0f 100644
--- a/drivers/net/cxgb4/sge.c
+++ b/drivers/net/cxgb4/sge.c
@@ -1556,7 +1556,6 @@ int t4_ethrx_handler(struct sge_rspq *q, const __=
be64 *rsp,
 {
 	bool csum_ok;
 	struct sk_buff *skb;
-	struct port_info *pi;
 	const struct cpl_rx_pkt *pkt;
 	struct sge_eth_rxq *rxq =3D container_of(q, struct sge_eth_rxq, rspq)=
;
=20
@@ -1584,10 +1583,9 @@ int t4_ethrx_handler(struct sge_rspq *q, const _=
_be64 *rsp,
 	if (skb->dev->features & NETIF_F_RXHASH)
 		skb->rxhash =3D (__force u32)pkt->rsshdr.hash_val;
=20
-	pi =3D netdev_priv(skb->dev);
 	rxq->stats.pkts++;
=20
-	if (csum_ok && (pi->rx_offload & RX_CSO) &&
+	if (csum_ok && (q->netdev->features & NETIF_F_RXCSUM) &&
 	    (pkt->l2info & htonl(RXF_UDP | RXF_TCP))) {
 		if (!pkt->ip_frag) {
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
diff --git a/drivers/net/cxgb4vf/adapter.h b/drivers/net/cxgb4vf/adapte=
r.h
index 4766b41..4fd821a 100644
--- a/drivers/net/cxgb4vf/adapter.h
+++ b/drivers/net/cxgb4vf/adapter.h
@@ -97,17 +97,11 @@ struct port_info {
 	u16 rss_size;			/* size of VI's RSS table slice */
 	u8 pidx;			/* index into adapter port[] */
 	u8 port_id;			/* physical port ID */
-	u8 rx_offload;			/* CSO, etc. */
 	u8 nqsets;			/* # of "Queue Sets" */
 	u8 first_qset;			/* index of first "Queue Set" */
 	struct link_config link_cfg;	/* physical port configuration */
 };
=20
-/* port_info.rx_offload flags */
-enum {
-	RX_CSO =3D 1 << 0,
-};
-
 /*
  * Scatter Gather Engine resources for the "adapter".  Our ingress and=
 egress
  * queues are organized into "Queue Sets" with one ingress and one egr=
ess
diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/c=
xgb4vf_main.c
index c662679..8cf9890 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -1326,30 +1326,6 @@ static void cxgb4vf_get_pauseparam(struct net_de=
vice *dev,
 }
=20
 /*
- * Return whether RX Checksum Offloading is currently enabled for the =
device.
- */
-static u32 cxgb4vf_get_rx_csum(struct net_device *dev)
-{
-	struct port_info *pi =3D netdev_priv(dev);
-
-	return (pi->rx_offload & RX_CSO) !=3D 0;
-}
-
-/*
- * Turn RX Checksum Offloading on or off for the device.
- */
-static int cxgb4vf_set_rx_csum(struct net_device *dev, u32 csum)
-{
-	struct port_info *pi =3D netdev_priv(dev);
-
-	if (csum)
-		pi->rx_offload |=3D RX_CSO;
-	else
-		pi->rx_offload &=3D ~RX_CSO;
-	return 0;
-}
-
-/*
  * Identify the port by blinking the port's LED.
  */
 static int cxgb4vf_phys_id(struct net_device *dev,
@@ -1569,18 +1545,6 @@ static void cxgb4vf_get_wol(struct net_device *d=
ev,
  */
 #define TSO_FLAGS (NETIF_F_TSO | NETIF_F_TSO6 | NETIF_F_TSO_ECN)
=20
-/*
- * Set TCP Segmentation Offloading feature capabilities.
- */
-static int cxgb4vf_set_tso(struct net_device *dev, u32 tso)
-{
-	if (tso)
-		dev->features |=3D TSO_FLAGS;
-	else
-		dev->features &=3D ~TSO_FLAGS;
-	return 0;
-}
-
 static struct ethtool_ops cxgb4vf_ethtool_ops =3D {
 	.get_settings		=3D cxgb4vf_get_settings,
 	.get_drvinfo		=3D cxgb4vf_get_drvinfo,
@@ -1591,10 +1555,6 @@ static struct ethtool_ops cxgb4vf_ethtool_ops =3D=
 {
 	.get_coalesce		=3D cxgb4vf_get_coalesce,
 	.set_coalesce		=3D cxgb4vf_set_coalesce,
 	.get_pauseparam		=3D cxgb4vf_get_pauseparam,
-	.get_rx_csum		=3D cxgb4vf_get_rx_csum,
-	.set_rx_csum		=3D cxgb4vf_set_rx_csum,
-	.set_tx_csum		=3D ethtool_op_set_tx_ipv6_csum,
-	.set_sg			=3D ethtool_op_set_sg,
 	.get_link		=3D ethtool_op_get_link,
 	.get_strings		=3D cxgb4vf_get_strings,
 	.set_phys_id		=3D cxgb4vf_phys_id,
@@ -1603,7 +1563,6 @@ static struct ethtool_ops cxgb4vf_ethtool_ops =3D=
 {
 	.get_regs_len		=3D cxgb4vf_get_regs_len,
 	.get_regs		=3D cxgb4vf_get_regs,
 	.get_wol		=3D cxgb4vf_get_wol,
-	.set_tso		=3D cxgb4vf_set_tso,
 };
=20
 /*
@@ -2638,19 +2597,19 @@ static int __devinit cxgb4vf_pci_probe(struct p=
ci_dev *pdev,
 		 * it.
 		 */
 		pi->xact_addr_filt =3D -1;
-		pi->rx_offload =3D RX_CSO;
 		netif_carrier_off(netdev);
 		netdev->irq =3D pdev->irq;
=20
-		netdev->features =3D (NETIF_F_SG | TSO_FLAGS |
-				    NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
-				    NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX |
-				    NETIF_F_GRO);
+		netdev->hw_features =3D NETIF_F_SG | TSO_FLAGS |
+			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+			NETIF_F_HW_VLAN_TX | NETIF_F_RXCSUM;
+		netdev->vlan_features =3D NETIF_F_SG | TSO_FLAGS |
+			NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM |
+			NETIF_F_HIGHDMA;
+		netdev->features =3D netdev->hw_features |
+			NETIF_F_HW_VLAN_RX;
 		if (pci_using_dac)
 			netdev->features |=3D NETIF_F_HIGHDMA;
-		netdev->vlan_features =3D
-			(netdev->features &
-			 ~(NETIF_F_HW_VLAN_TX | NETIF_F_HW_VLAN_RX));
=20
 #ifdef HAVE_NET_DEVICE_OPS
 		netdev->netdev_ops =3D &cxgb4vf_netdev_ops;
diff --git a/drivers/net/cxgb4vf/sge.c b/drivers/net/cxgb4vf/sge.c
index bb65121..5182960 100644
--- a/drivers/net/cxgb4vf/sge.c
+++ b/drivers/net/cxgb4vf/sge.c
@@ -1555,8 +1555,8 @@ int t4vf_ethrx_handler(struct sge_rspq *rspq, con=
st __be64 *rsp,
 	pi =3D netdev_priv(skb->dev);
 	rxq->stats.pkts++;
=20
-	if (csum_ok && (pi->rx_offload & RX_CSO) && !pkt->err_vec &&
-	    (be32_to_cpu(pkt->l2info) & (RXF_UDP|RXF_TCP))) {
+	if (csum_ok && (rspq->netdev->features & NETIF_F_RXCSUM) &&
+	    !pkt->err_vec && (be32_to_cpu(pkt->l2info) & (RXF_UDP|RXF_TCP))) =
{
 		if (!pkt->ip_frag)
 			skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 		else {
--=20
1.7.2.5

