From: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirq-linux@rere.qmqm.pl>
Subject: Re: [net-next 01/11] ixgb: convert to ndo_fix_features
Date: Sat, 17 Sep 2011 15:21:53 +0200
Message-ID: <20110917132153.GA32572@rere.qmqm.pl>
References: <1316225752-1709-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1316225752-1709-2-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, gospo@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:47291 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751929Ab1IQNVz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Sep 2011 09:21:55 -0400
Content-Disposition: inline
In-Reply-To: <1316225752-1709-2-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 16, 2011 at 07:15:42PM -0700, Jeff Kirsher wrote:
> From: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>
> Private rx_csum flags are now duplicate of netdev->features & NETIF_F=
_RXCSUM.
> Removing this needs deeper surgery.
[...]

Hmm. Looks like this patch is not complete: part removing get/set_flags
from ethtool_ops is missing. I don't remember if this was included or n=
ot
in the patch I sent originally. I'm attaching it now, rebased on curren=
t
net-next (not tested).

Best Regards,
Micha=B3 Miros=B3aw=20

---

=46inish conversion to unified ethtool ops: convert get_flags.

Signed-off-by: Micha=B3 Miros=B3aw <mirq-linux@rere.qmqm.pl>

diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c b/drivers/n=
et/ethernet/intel/ixgb/ixgb_ethtool.c
index fdb30cc..ab404e7 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_ethtool.c
@@ -634,43 +634,6 @@ ixgb_get_strings(struct net_device *netdev, u32 st=
ringset, u8 *data)
 	}
 }
=20
-static int ixgb_set_flags(struct net_device *netdev, u32 data)
-{
-	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
-	bool need_reset;
-	int rc;
-
-	/*
-	 * Tx VLAN insertion does not work per HW design when Rx stripping is
-	 * disabled.  Disable txvlan when rxvlan is turned off, and enable
-	 * rxvlan when txvlan is turned on.
-	 */
-	if (!(data & ETH_FLAG_RXVLAN) &&
-	    (netdev->features & NETIF_F_HW_VLAN_TX))
-		data &=3D ~ETH_FLAG_TXVLAN;
-	else if (data & ETH_FLAG_TXVLAN)
-		data |=3D ETH_FLAG_RXVLAN;
-
-	need_reset =3D (data & ETH_FLAG_RXVLAN) !=3D
-		     (netdev->features & NETIF_F_HW_VLAN_RX);
-
-	rc =3D ethtool_op_set_flags(netdev, data, ETH_FLAG_RXVLAN |
-						ETH_FLAG_TXVLAN);
-	if (rc)
-		return rc;
-
-	if (need_reset) {
-		if (netif_running(netdev)) {
-			ixgb_down(adapter, true);
-			ixgb_up(adapter);
-			ixgb_set_speed_duplex(netdev);
-		} else
-			ixgb_reset(adapter);
-	}
-
-	return 0;
-}
-
 static const struct ethtool_ops ixgb_ethtool_ops =3D {
 	.get_settings =3D ixgb_get_settings,
 	.set_settings =3D ixgb_set_settings,
@@ -691,8 +654,6 @@ static const struct ethtool_ops ixgb_ethtool_ops =3D=
 {
 	.set_phys_id =3D ixgb_set_phys_id,
 	.get_sset_count =3D ixgb_get_sset_count,
 	.get_ethtool_stats =3D ixgb_get_ethtool_stats,
-	.get_flags =3D ethtool_op_get_flags,
-	.set_flags =3D ixgb_set_flags,
 };
=20
 void ixgb_set_ethtool_ops(struct net_device *netdev)
diff --git a/drivers/net/ethernet/intel/ixgb/ixgb_main.c b/drivers/net/=
ethernet/intel/ixgb/ixgb_main.c
index b8fb163..1bb794c 100644
--- a/drivers/net/ethernet/intel/ixgb/ixgb_main.c
+++ b/drivers/net/ethernet/intel/ixgb/ixgb_main.c
@@ -325,13 +325,26 @@ ixgb_reset(struct ixgb_adapter *adapter)
 	}
 }
=20
+static u32
+ixgb_fix_features(struct net_device *netdev, u32 features)
+{
+	/*
+	 * Tx VLAN insertion does not work per HW design when Rx stripping is
+	 * disabled.
+	 */
+	if (!(features & NETIF_F_HW_VLAN_RX))
+		features &=3D ~NETIF_F_HW_VLAN_TX;
+
+	return features;
+}
+
 static int
 ixgb_set_features(struct net_device *netdev, u32 features)
 {
 	struct ixgb_adapter *adapter =3D netdev_priv(netdev);
 	u32 changed =3D features ^ netdev->features;
=20
-	if (!(changed & NETIF_F_RXCSUM))
+	if (!(changed & (NETIF_F_RXCSUM|NETIF_F_HW_VLAN_RX)))
 		return 0;
=20
 	adapter->rx_csum =3D !!(features & NETIF_F_RXCSUM);
@@ -362,6 +375,7 @@ static const struct net_device_ops ixgb_netdev_ops =
=3D {
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	.ndo_poll_controller	=3D ixgb_netpoll,
 #endif
+	.ndo_fix_features       =3D ixgb_fix_features,
 	.ndo_set_features       =3D ixgb_set_features,
 };
=20
@@ -464,10 +478,10 @@ ixgb_probe(struct pci_dev *pdev, const struct pci=
_device_id *ent)
=20
 	netdev->hw_features =3D NETIF_F_SG |
 			   NETIF_F_TSO |
-			   NETIF_F_HW_CSUM;
-	netdev->features =3D netdev->hw_features |
+			   NETIF_F_HW_CSUM |
 			   NETIF_F_HW_VLAN_TX |
-			   NETIF_F_HW_VLAN_RX |
+			   NETIF_F_HW_VLAN_RX;
+	netdev->features =3D netdev->hw_features |
 			   NETIF_F_HW_VLAN_FILTER;
 	netdev->hw_features |=3D NETIF_F_RXCSUM;
=20
