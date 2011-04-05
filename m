From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: netxen: convert to hw_features
Date: Tue,  5 Apr 2011 13:36:58 +0200 (CEST)
Message-ID: <20110405113658.D004D13909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:57349 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753138Ab1DELg7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Apr 2011 07:36:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rather simple conversion to hw_features.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---

[x86 build-tested only, as I don't have the hardware.]

 drivers/net/netxen/netxen_nic.h         |    2 +-
 drivers/net/netxen/netxen_nic_ethtool.c |  102 -----------------------=
--------
 drivers/net/netxen/netxen_nic_init.c    |    3 +-
 drivers/net/netxen/netxen_nic_main.c    |   53 +++++++++++++---
 4 files changed, 46 insertions(+), 114 deletions(-)

diff --git a/drivers/net/netxen/netxen_nic.h b/drivers/net/netxen/netxe=
n_nic.h
index d7299f1..15595b3 100644
--- a/drivers/net/netxen/netxen_nic.h
+++ b/drivers/net/netxen/netxen_nic.h
@@ -1177,7 +1177,7 @@ struct netxen_adapter {
 	u8 max_sds_rings;
 	u8 driver_mismatch;
 	u8 msix_supported;
-	u8 rx_csum;
+	u8 __pad;
 	u8 pci_using_dac;
 	u8 portnum;
 	u8 physical_port;
diff --git a/drivers/net/netxen/netxen_nic_ethtool.c b/drivers/net/netx=
en/netxen_nic_ethtool.c
index 3bdcc80..29f90ba 100644
--- a/drivers/net/netxen/netxen_nic_ethtool.c
+++ b/drivers/net/netxen/netxen_nic_ethtool.c
@@ -676,62 +676,6 @@ netxen_nic_get_ethtool_stats(struct net_device *de=
v,
 	}
 }
=20
-static u32 netxen_nic_get_tx_csum(struct net_device *dev)
-{
-	return dev->features & NETIF_F_IP_CSUM;
-}
-
-static u32 netxen_nic_get_rx_csum(struct net_device *dev)
-{
-	struct netxen_adapter *adapter =3D netdev_priv(dev);
-	return adapter->rx_csum;
-}
-
-static int netxen_nic_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct netxen_adapter *adapter =3D netdev_priv(dev);
-
-	if (data) {
-		adapter->rx_csum =3D data;
-		return 0;
-	}
-
-	if (dev->features & NETIF_F_LRO) {
-		if (netxen_config_hw_lro(adapter, NETXEN_NIC_LRO_DISABLED))
-			return -EIO;
-
-		dev->features &=3D ~NETIF_F_LRO;
-		netxen_send_lro_cleanup(adapter);
-		netdev_info(dev, "disabling LRO as rx_csum is off\n");
-	}
-	adapter->rx_csum =3D data;
-	return 0;
-}
-
-static u32 netxen_nic_get_tso(struct net_device *dev)
-{
-	struct netxen_adapter *adapter =3D netdev_priv(dev);
-
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-		return (dev->features & (NETIF_F_TSO | NETIF_F_TSO6)) !=3D 0;
-
-	return (dev->features & NETIF_F_TSO) !=3D 0;
-}
-
-static int netxen_nic_set_tso(struct net_device *dev, u32 data)
-{
-	if (data) {
-		struct netxen_adapter *adapter =3D netdev_priv(dev);
-
-		dev->features |=3D NETIF_F_TSO;
-		if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
-			dev->features |=3D NETIF_F_TSO6;
-	} else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
 static void
 netxen_nic_get_wol(struct net_device *dev, struct ethtool_wolinfo *wol=
)
 {
@@ -866,43 +810,6 @@ static int netxen_get_intr_coalesce(struct net_dev=
ice *netdev,
 	return 0;
 }
=20
-static int netxen_nic_set_flags(struct net_device *netdev, u32 data)
-{
-	struct netxen_adapter *adapter =3D netdev_priv(netdev);
-	int hw_lro;
-
-	if (ethtool_invalid_flags(netdev, data, ETH_FLAG_LRO))
-		return -EINVAL;
-
-	if (!(adapter->capabilities & NX_FW_CAPABILITY_HW_LRO))
-		return -EINVAL;
-
-	if (!adapter->rx_csum) {
-		netdev_info(netdev, "rx csum is off, cannot toggle LRO\n");
-		return -EINVAL;
-	}
-
-	if (!!(data & ETH_FLAG_LRO) =3D=3D !!(netdev->features & NETIF_F_LRO)=
)
-		return 0;
-
-	if (data & ETH_FLAG_LRO) {
-		hw_lro =3D NETXEN_NIC_LRO_ENABLED;
-		netdev->features |=3D NETIF_F_LRO;
-	} else {
-		hw_lro =3D NETXEN_NIC_LRO_DISABLED;
-		netdev->features &=3D ~NETIF_F_LRO;
-	}
-
-	if (netxen_config_hw_lro(adapter, hw_lro))
-		return -EIO;
-
-	if ((hw_lro =3D=3D 0) && netxen_send_lro_cleanup(adapter))
-		return -EIO;
-
-
-	return 0;
-}
-
 const struct ethtool_ops netxen_nic_ethtool_ops =3D {
 	.get_settings =3D netxen_nic_get_settings,
 	.set_settings =3D netxen_nic_set_settings,
@@ -916,21 +823,12 @@ const struct ethtool_ops netxen_nic_ethtool_ops =3D=
 {
 	.set_ringparam =3D netxen_nic_set_ringparam,
 	.get_pauseparam =3D netxen_nic_get_pauseparam,
 	.set_pauseparam =3D netxen_nic_set_pauseparam,
-	.get_tx_csum =3D netxen_nic_get_tx_csum,
-	.set_tx_csum =3D ethtool_op_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
-	.get_tso =3D netxen_nic_get_tso,
-	.set_tso =3D netxen_nic_set_tso,
 	.get_wol =3D netxen_nic_get_wol,
 	.set_wol =3D netxen_nic_set_wol,
 	.self_test =3D netxen_nic_diag_test,
 	.get_strings =3D netxen_nic_get_strings,
 	.get_ethtool_stats =3D netxen_nic_get_ethtool_stats,
 	.get_sset_count =3D netxen_get_sset_count,
-	.get_rx_csum =3D netxen_nic_get_rx_csum,
-	.set_rx_csum =3D netxen_nic_set_rx_csum,
 	.get_coalesce =3D netxen_get_intr_coalesce,
 	.set_coalesce =3D netxen_set_intr_coalesce,
-	.get_flags =3D ethtool_op_get_flags,
-	.set_flags =3D netxen_nic_set_flags,
 };
diff --git a/drivers/net/netxen/netxen_nic_init.c b/drivers/net/netxen/=
netxen_nic_init.c
index 731077d..7f99967 100644
--- a/drivers/net/netxen/netxen_nic_init.c
+++ b/drivers/net/netxen/netxen_nic_init.c
@@ -1483,7 +1483,8 @@ static struct sk_buff *netxen_process_rxbuf(struc=
t netxen_adapter *adapter,
 	if (!skb)
 		goto no_skb;
=20
-	if (likely(adapter->rx_csum && cksum =3D=3D STATUS_CKSUM_OK)) {
+	if (likely((adapter->netdev->features & NETIF_F_RXCSUM)
+	    && cksum =3D=3D STATUS_CKSUM_OK)) {
 		adapter->stats.csummed++;
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	} else
diff --git a/drivers/net/netxen/netxen_nic_main.c b/drivers/net/netxen/=
netxen_nic_main.c
index 9336715..201b944 100644
--- a/drivers/net/netxen/netxen_nic_main.c
+++ b/drivers/net/netxen/netxen_nic_main.c
@@ -485,6 +485,37 @@ static void netxen_set_multicast_list(struct net_d=
evice *dev)
 	adapter->set_multi(dev);
 }
=20
+static u32 netxen_fix_features(struct net_device *dev, u32 features)
+{
+	if (!(features & NETIF_F_RXCSUM)) {
+		netdev_info(dev, "disabling LRO as RXCSUM is off\n");
+
+		features &=3D ~NETIF_F_LRO;
+	}
+
+	return features;
+}
+
+static int netxen_set_features(struct net_device *dev, u32 features)
+{
+	struct netxen_adapter *adapter =3D netdev_priv(dev);
+	int hw_lro;
+
+	if (!((dev->features ^ features) & NETIF_F_LRO))
+		return 0;
+
+	hw_lro =3D (features & NETIF_F_LRO) ? NETXEN_NIC_LRO_ENABLED
+	         : NETXEN_NIC_LRO_DISABLED;
+
+	if (netxen_config_hw_lro(adapter, hw_lro))
+		return -EIO;
+
+	if (!(features & NETIF_F_LRO) && netxen_send_lro_cleanup(adapter))
+		return -EIO;
+
+	return 0;
+}
+
 static const struct net_device_ops netxen_netdev_ops =3D {
 	.ndo_open	   =3D netxen_nic_open,
 	.ndo_stop	   =3D netxen_nic_close,
@@ -495,6 +526,8 @@ static const struct net_device_ops netxen_netdev_op=
s =3D {
 	.ndo_set_mac_address    =3D netxen_nic_set_mac,
 	.ndo_change_mtu	   =3D netxen_nic_change_mtu,
 	.ndo_tx_timeout	   =3D netxen_tx_timeout,
+	.ndo_fix_features =3D netxen_fix_features,
+	.ndo_set_features =3D netxen_set_features,
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller =3D netxen_nic_poll_controller,
 #endif
@@ -1196,7 +1229,6 @@ netxen_setup_netdev(struct netxen_adapter *adapte=
r,
 	int err =3D 0;
 	struct pci_dev *pdev =3D adapter->pdev;
=20
-	adapter->rx_csum =3D 1;
 	adapter->mc_enabled =3D 0;
 	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
 		adapter->max_mc_count =3D 38;
@@ -1210,14 +1242,13 @@ netxen_setup_netdev(struct netxen_adapter *adap=
ter,
=20
 	SET_ETHTOOL_OPS(netdev, &netxen_nic_ethtool_ops);
=20
-	netdev->features |=3D (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO);
-	netdev->features |=3D (NETIF_F_GRO);
-	netdev->vlan_features |=3D (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TS=
O);
+	netdev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_TSO |
+	                      NETIF_F_RXCSUM;
=20
-	if (NX_IS_REVISION_P3(adapter->ahw.revision_id)) {
-		netdev->features |=3D (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
-		netdev->vlan_features |=3D (NETIF_F_IPV6_CSUM | NETIF_F_TSO6);
-	}
+	if (NX_IS_REVISION_P3(adapter->ahw.revision_id))
+		netdev->hw_features |=3D NETIF_F_IPV6_CSUM | NETIF_F_TSO6;
+
+	netdev->vlan_features |=3D netdev->hw_features;
=20
 	if (adapter->pci_using_dac) {
 		netdev->features |=3D NETIF_F_HIGHDMA;
@@ -1225,10 +1256,12 @@ netxen_setup_netdev(struct netxen_adapter *adap=
ter,
 	}
=20
 	if (adapter->capabilities & NX_FW_CAPABILITY_FVLANTX)
-		netdev->features |=3D (NETIF_F_HW_VLAN_TX);
+		netdev->hw_features |=3D NETIF_F_HW_VLAN_TX;
=20
 	if (adapter->capabilities & NX_FW_CAPABILITY_HW_LRO)
-		netdev->features |=3D NETIF_F_LRO;
+		netdev->hw_features |=3D NETIF_F_LRO;
+
+	netdev->features |=3D netdev->hw_features;
=20
 	netdev->irq =3D adapter->msix_entries[0].vector;
=20
--=20
1.7.2.5

