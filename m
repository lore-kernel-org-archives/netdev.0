From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2] net: qlcnic: convert to hw_features
Date: Tue, 19 Apr 2011 15:03:57 +0200 (CEST)
Message-ID: <20110419130357.40FA813909@rere.qmqm.pl>
References: <20110419124238.AECB513909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Amit Kumar Salecha <amit.salecha@qlogic.com>,
	Anirban Chakraborty <anirban.chakraborty@qlogic.com>,
	linux-driver@qlogic.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60628 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754317Ab1DSND7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 09:03:59 -0400
In-Reply-To: <20110419124238.AECB513909@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bit more than minimal conversion. There might be some issues because
of qlcnic_set_netdev_features() if it's called after netdev init.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
v2: fix compilation issues (I forgot to 'stg refresh' before sending v1=
)

 drivers/net/qlcnic/qlcnic.h         |    3 +-
 drivers/net/qlcnic/qlcnic_ethtool.c |  120 ---------------------------=
--------
 drivers/net/qlcnic/qlcnic_hw.c      |   37 +++++++++++
 drivers/net/qlcnic/qlcnic_init.c    |    4 +-
 drivers/net/qlcnic/qlcnic_main.c    |   35 +++++------
 5 files changed, 57 insertions(+), 142 deletions(-)

diff --git a/drivers/net/qlcnic/qlcnic.h b/drivers/net/qlcnic/qlcnic.h
index e5d3053..fa5b15c 100644
--- a/drivers/net/qlcnic/qlcnic.h
+++ b/drivers/net/qlcnic/qlcnic.h
@@ -926,7 +926,6 @@ struct qlcnic_adapter {
 	u8 max_rds_rings;
 	u8 max_sds_rings;
 	u8 msix_supported;
-	u8 rx_csum;
 	u8 portnum;
 	u8 physical_port;
 	u8 reset_context;
@@ -1247,6 +1246,8 @@ void qlcnic_advert_link_change(struct qlcnic_adap=
ter *adapter, int linkup);
=20
 int qlcnic_fw_cmd_set_mtu(struct qlcnic_adapter *adapter, int mtu);
 int qlcnic_change_mtu(struct net_device *netdev, int new_mtu);
+u32 qlcnic_fix_features(struct net_device *netdev, u32 features);
+int qlcnic_set_features(struct net_device *netdev, u32 features);
 int qlcnic_config_hw_lro(struct qlcnic_adapter *adapter, int enable);
 int qlcnic_config_bridged_mode(struct qlcnic_adapter *adapter, u32 ena=
ble);
 int qlcnic_send_lro_cleanup(struct qlcnic_adapter *adapter);
diff --git a/drivers/net/qlcnic/qlcnic_ethtool.c b/drivers/net/qlcnic/q=
lcnic_ethtool.c
index 3cd8a16..615a5ab 100644
--- a/drivers/net/qlcnic/qlcnic_ethtool.c
+++ b/drivers/net/qlcnic/qlcnic_ethtool.c
@@ -764,73 +764,6 @@ qlcnic_get_ethtool_stats(struct net_device *dev,
 	qlcnic_fill_device_stats(&index, data, &port_stats.tx);
 }
=20
-static int qlcnic_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct qlcnic_adapter *adapter =3D netdev_priv(dev);
-
-	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED))
-		return -EOPNOTSUPP;
-	if (data)
-		dev->features |=3D (NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-	else
-		dev->features &=3D ~(NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM);
-
-	return 0;
-
-}
-static u32 qlcnic_get_tx_csum(struct net_device *dev)
-{
-	return dev->features & NETIF_F_IP_CSUM;
-}
-
-static u32 qlcnic_get_rx_csum(struct net_device *dev)
-{
-	struct qlcnic_adapter *adapter =3D netdev_priv(dev);
-	return adapter->rx_csum;
-}
-
-static int qlcnic_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct qlcnic_adapter *adapter =3D netdev_priv(dev);
-
-	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED))
-		return -EOPNOTSUPP;
-	if (!!data) {
-		adapter->rx_csum =3D !!data;
-		return 0;
-	}
-
-	if (dev->features & NETIF_F_LRO) {
-		if (qlcnic_config_hw_lro(adapter, QLCNIC_LRO_DISABLED))
-			return -EIO;
-
-		dev->features &=3D ~NETIF_F_LRO;
-		qlcnic_send_lro_cleanup(adapter);
-		dev_info(&adapter->pdev->dev,
-					"disabling LRO as rx_csum is off\n");
-	}
-	adapter->rx_csum =3D !!data;
-	return 0;
-}
-
-static u32 qlcnic_get_tso(struct net_device *dev)
-{
-	return (dev->features & (NETIF_F_TSO | NETIF_F_TSO6)) !=3D 0;
-}
-
-static int qlcnic_set_tso(struct net_device *dev, u32 data)
-{
-	struct qlcnic_adapter *adapter =3D netdev_priv(dev);
-	if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO))
-		return -EOPNOTSUPP;
-	if (data)
-		dev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-	else
-		dev->features &=3D ~(NETIF_F_TSO | NETIF_F_TSO6);
-
-	return 0;
-}
-
 static int qlcnic_set_led(struct net_device *dev,
 			  enum ethtool_phys_id_state state)
 {
@@ -993,50 +926,6 @@ static int qlcnic_get_intr_coalesce(struct net_dev=
ice *netdev,
 	return 0;
 }
=20
-static int qlcnic_set_flags(struct net_device *netdev, u32 data)
-{
-	struct qlcnic_adapter *adapter =3D netdev_priv(netdev);
-	int hw_lro;
-
-	if (ethtool_invalid_flags(netdev, data, ETH_FLAG_LRO))
-		return -EINVAL;
-
-	if (data & ETH_FLAG_LRO) {
-
-		if (netdev->features & NETIF_F_LRO)
-			return 0;
-
-		if (!(adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO))
-			return -EINVAL;
-
-		if (!adapter->rx_csum) {
-			dev_info(&adapter->pdev->dev, "rx csum is off, "
-				"cannot toggle lro\n");
-			return -EINVAL;
-		}
-
-		hw_lro =3D QLCNIC_LRO_ENABLED;
-		netdev->features |=3D NETIF_F_LRO;
-
-	} else {
-
-		if (!(netdev->features & NETIF_F_LRO))
-			return 0;
-
-		hw_lro =3D 0;
-		netdev->features &=3D ~NETIF_F_LRO;
-	}
-
-	if (qlcnic_config_hw_lro(adapter, hw_lro))
-		return -EIO;
-
-	if ((hw_lro =3D=3D 0) && qlcnic_send_lro_cleanup(adapter))
-		return -EIO;
-
-
-	return 0;
-}
-
 static u32 qlcnic_get_msglevel(struct net_device *netdev)
 {
 	struct qlcnic_adapter *adapter =3D netdev_priv(netdev);
@@ -1064,23 +953,14 @@ const struct ethtool_ops qlcnic_ethtool_ops =3D =
{
 	.set_ringparam =3D qlcnic_set_ringparam,
 	.get_pauseparam =3D qlcnic_get_pauseparam,
 	.set_pauseparam =3D qlcnic_set_pauseparam,
-	.get_tx_csum =3D qlcnic_get_tx_csum,
-	.set_tx_csum =3D qlcnic_set_tx_csum,
-	.set_sg =3D ethtool_op_set_sg,
-	.get_tso =3D qlcnic_get_tso,
-	.set_tso =3D qlcnic_set_tso,
 	.get_wol =3D qlcnic_get_wol,
 	.set_wol =3D qlcnic_set_wol,
 	.self_test =3D qlcnic_diag_test,
 	.get_strings =3D qlcnic_get_strings,
 	.get_ethtool_stats =3D qlcnic_get_ethtool_stats,
 	.get_sset_count =3D qlcnic_get_sset_count,
-	.get_rx_csum =3D qlcnic_get_rx_csum,
-	.set_rx_csum =3D qlcnic_set_rx_csum,
 	.get_coalesce =3D qlcnic_get_intr_coalesce,
 	.set_coalesce =3D qlcnic_set_intr_coalesce,
-	.get_flags =3D ethtool_op_get_flags,
-	.set_flags =3D qlcnic_set_flags,
 	.set_phys_id =3D qlcnic_set_led,
 	.set_msglevel =3D qlcnic_set_msglevel,
 	.get_msglevel =3D qlcnic_get_msglevel,
diff --git a/drivers/net/qlcnic/qlcnic_hw.c b/drivers/net/qlcnic/qlcnic=
_hw.c
index 498cca9..cbb27f2 100644
--- a/drivers/net/qlcnic/qlcnic_hw.c
+++ b/drivers/net/qlcnic/qlcnic_hw.c
@@ -758,6 +758,43 @@ int qlcnic_change_mtu(struct net_device *netdev, i=
nt mtu)
 	return rc;
 }
=20
+
+u32 qlcnic_fix_features(struct net_device *netdev, u32 features)
+{
+	struct qlcnic_adapter *adapter =3D netdev_priv(netdev);
+
+	if ((adapter->flags & QLCNIC_ESWITCH_ENABLED)) {
+		u32 changed =3D features ^ netdev->features;
+		features ^=3D changed & (NETIF_F_ALL_CSUM | NETIF_F_RXCSUM);
+	}
+
+	if (!(features & NETIF_F_RXCSUM))
+		features &=3D ~NETIF_F_LRO;
+
+	return features;
+}
+
+
+int qlcnic_set_features(struct net_device *netdev, u32 features)
+{
+	struct qlcnic_adapter *adapter =3D netdev_priv(netdev);
+	u32 changed =3D netdev->features ^ features;
+	int hw_lro =3D (features & NETIF_F_LRO) ? QLCNIC_LRO_ENABLED : 0;
+
+	if (!(changed & NETIF_F_LRO))
+		return 0;
+
+	netdev->features =3D features ^ NETIF_F_LRO;
+
+	if (qlcnic_config_hw_lro(adapter, hw_lro))
+		return -EIO;
+
+	if ((hw_lro =3D=3D 0) && qlcnic_send_lro_cleanup(adapter))
+		return -EIO;
+
+	return 0;
+}
+
 /*
  * Changes the CRB window to the specified window.
  */
diff --git a/drivers/net/qlcnic/qlcnic_init.c b/drivers/net/qlcnic/qlcn=
ic_init.c
index 4ec0eeb..d0f338b 100644
--- a/drivers/net/qlcnic/qlcnic_init.c
+++ b/drivers/net/qlcnic/qlcnic_init.c
@@ -1390,8 +1390,8 @@ static struct sk_buff *qlcnic_process_rxbuf(struc=
t qlcnic_adapter *adapter,
=20
 	skb =3D buffer->skb;
=20
-	if (likely(adapter->rx_csum && (cksum =3D=3D STATUS_CKSUM_OK ||
-						cksum =3D=3D STATUS_CKSUM_LOOP))) {
+	if (likely((adapter->netdev->features & NETIF_F_RXCSUM) &&
+	    (cksum =3D=3D STATUS_CKSUM_OK || cksum =3D=3D STATUS_CKSUM_LOOP))=
) {
 		adapter->stats.csummed++;
 		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
 	} else {
diff --git a/drivers/net/qlcnic/qlcnic_main.c b/drivers/net/qlcnic/qlcn=
ic_main.c
index e9e9ba6..6e61951 100644
--- a/drivers/net/qlcnic/qlcnic_main.c
+++ b/drivers/net/qlcnic/qlcnic_main.c
@@ -328,6 +328,8 @@ static const struct net_device_ops qlcnic_netdev_op=
s =3D {
 	.ndo_set_multicast_list =3D qlcnic_set_multi,
 	.ndo_set_mac_address    =3D qlcnic_set_mac,
 	.ndo_change_mtu	   =3D qlcnic_change_mtu,
+	.ndo_fix_features  =3D qlcnic_fix_features,
+	.ndo_set_features  =3D qlcnic_set_features,
 	.ndo_tx_timeout	   =3D qlcnic_tx_timeout,
 	.ndo_vlan_rx_add_vid	=3D qlcnic_vlan_rx_add,
 	.ndo_vlan_rx_kill_vid	=3D qlcnic_vlan_rx_del,
@@ -764,7 +766,7 @@ qlcnic_set_netdev_features(struct qlcnic_adapter *a=
dapter,
 	struct net_device *netdev =3D adapter->netdev;
 	unsigned long features, vlan_features;
=20
-	features =3D (NETIF_F_SG | NETIF_F_IP_CSUM |
+	features =3D (NETIF_F_SG | NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_GRO);
 	vlan_features =3D (NETIF_F_SG | NETIF_F_IP_CSUM |
 			NETIF_F_IPV6_CSUM | NETIF_F_HW_VLAN_FILTER);
@@ -779,14 +781,12 @@ qlcnic_set_netdev_features(struct qlcnic_adapter =
*adapter,
=20
 	if (esw_cfg->offload_flags & BIT_0) {
 		netdev->features |=3D features;
-		adapter->rx_csum =3D 1;
 		if (!(esw_cfg->offload_flags & BIT_1))
 			netdev->features &=3D ~NETIF_F_TSO;
 		if (!(esw_cfg->offload_flags & BIT_2))
 			netdev->features &=3D ~NETIF_F_TSO6;
 	} else {
 		netdev->features &=3D ~features;
-		adapter->rx_csum =3D 0;
 	}
=20
 	netdev->vlan_features =3D (features & vlan_features);
@@ -1436,7 +1436,6 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adapte=
r,
 	int err;
 	struct pci_dev *pdev =3D adapter->pdev;
=20
-	adapter->rx_csum =3D 1;
 	adapter->mc_enabled =3D 0;
 	adapter->max_mc_count =3D 38;
=20
@@ -1447,26 +1446,24 @@ qlcnic_setup_netdev(struct qlcnic_adapter *adap=
ter,
=20
 	SET_ETHTOOL_OPS(netdev, &qlcnic_ethtool_ops);
=20
-	netdev->features |=3D (NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_GRO | NETIF_F_HW_VLAN_RX);
-	netdev->vlan_features |=3D (NETIF_F_SG | NETIF_F_IP_CSUM |
-		NETIF_F_IPV6_CSUM | NETIF_F_HW_VLAN_FILTER);
+	netdev->hw_features =3D NETIF_F_SG | NETIF_F_IP_CSUM |
+		NETIF_F_IPV6_CSUM | NETIF_F_RXCSUM;
=20
-	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO) {
-		netdev->features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-		netdev->vlan_features |=3D (NETIF_F_TSO | NETIF_F_TSO6);
-	}
+	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_TSO)
+		netdev->hw_features |=3D NETIF_F_TSO | NETIF_F_TSO6;
+	if (pci_using_dac)
+		netdev->hw_features |=3D NETIF_F_HIGHDMA;
=20
-	if (pci_using_dac) {
-		netdev->features |=3D NETIF_F_HIGHDMA;
-		netdev->vlan_features |=3D NETIF_F_HIGHDMA;
-	}
+	netdev->vlan_features =3D netdev->hw_features;
=20
 	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_FVLANTX)
-		netdev->features |=3D (NETIF_F_HW_VLAN_TX);
-
+		netdev->hw_features |=3D NETIF_F_HW_VLAN_TX;
 	if (adapter->capabilities & QLCNIC_FW_CAPABILITY_HW_LRO)
-		netdev->features |=3D NETIF_F_LRO;
+		netdev->hw_features |=3D NETIF_F_LRO;
+
+	netdev->features |=3D netdev->hw_features |
+		NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER;
+
 	netdev->irq =3D adapter->msix_entries[0].vector;
=20
 	netif_carrier_off(netdev);
--=20
1.7.2.5

