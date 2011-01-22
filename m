From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 09/16] bridge: convert br_features_recompute() to ndo_fix_features
Date: Sat, 22 Jan 2011 23:14:13 +0100 (CET)
Message-ID: <b8d0e67684260bb732c2aecc086358da4d0a82b9.1295734271.git.mirq-linux@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43061 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752738Ab1AVWOQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 17:14:16 -0500
In-Reply-To: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 net/bridge/br_device.c  |   56 +++++----------------------------------=
-------
 net/bridge/br_if.c      |   16 ++++++-------
 net/bridge/br_notify.c  |    2 +-
 net/bridge/br_private.h |    3 +-
 4 files changed, 15 insertions(+), 62 deletions(-)

diff --git a/net/bridge/br_device.c b/net/bridge/br_device.c
index 5564435..cc29fcf 100644
--- a/net/bridge/br_device.c
+++ b/net/bridge/br_device.c
@@ -78,7 +78,7 @@ static int br_dev_open(struct net_device *dev)
 {
 	struct net_bridge *br =3D netdev_priv(dev);
=20
-	br_features_recompute(br);
+	netdev_update_features(dev);
 	netif_start_queue(dev);
 	br_stp_enable_bridge(br);
 	br_multicast_open(br);
@@ -173,48 +173,11 @@ static void br_getinfo(struct net_device *dev, st=
ruct ethtool_drvinfo *info)
 	strcpy(info->bus_info, "N/A");
 }
=20
-static int br_set_sg(struct net_device *dev, u32 data)
+static u32 br_fix_features(struct net_device *dev, u32 features)
 {
 	struct net_bridge *br =3D netdev_priv(dev);
=20
-	if (data)
-		br->feature_mask |=3D NETIF_F_SG;
-	else
-		br->feature_mask &=3D ~NETIF_F_SG;
-
-	br_features_recompute(br);
-	return 0;
-}
-
-static int br_set_tso(struct net_device *dev, u32 data)
-{
-	struct net_bridge *br =3D netdev_priv(dev);
-
-	if (data)
-		br->feature_mask |=3D NETIF_F_TSO;
-	else
-		br->feature_mask &=3D ~NETIF_F_TSO;
-
-	br_features_recompute(br);
-	return 0;
-}
-
-static int br_set_tx_csum(struct net_device *dev, u32 data)
-{
-	struct net_bridge *br =3D netdev_priv(dev);
-
-	if (data)
-		br->feature_mask |=3D NETIF_F_NO_CSUM;
-	else
-		br->feature_mask &=3D ~NETIF_F_ALL_CSUM;
-
-	br_features_recompute(br);
-	return 0;
-}
-
-static int br_set_flags(struct net_device *netdev, u32 data)
-{
-	return ethtool_op_set_flags(netdev, data, ETH_FLAG_TXVLAN);
+	return br_features_recompute(br, features);
 }
=20
 #ifdef CONFIG_NET_POLL_CONTROLLER
@@ -300,16 +263,6 @@ void br_netpoll_disable(struct net_bridge_port *p)
 static const struct ethtool_ops br_ethtool_ops =3D {
 	.get_drvinfo    =3D br_getinfo,
 	.get_link	=3D ethtool_op_get_link,
-	.get_tx_csum	=3D ethtool_op_get_tx_csum,
-	.set_tx_csum 	=3D br_set_tx_csum,
-	.get_sg		=3D ethtool_op_get_sg,
-	.set_sg		=3D br_set_sg,
-	.get_tso	=3D ethtool_op_get_tso,
-	.set_tso	=3D br_set_tso,
-	.get_ufo	=3D ethtool_op_get_ufo,
-	.set_ufo	=3D ethtool_op_set_ufo,
-	.get_flags	=3D ethtool_op_get_flags,
-	.set_flags	=3D br_set_flags,
 };
=20
 static const struct net_device_ops br_netdev_ops =3D {
@@ -326,6 +279,7 @@ static const struct net_device_ops br_netdev_ops =3D=
 {
 	.ndo_netpoll_cleanup	 =3D br_netpoll_cleanup,
 	.ndo_poll_controller	 =3D br_poll_controller,
 #endif
+	.ndo_fix_features        =3D br_fix_features,
 };
=20
 static void br_dev_free(struct net_device *dev)
@@ -350,4 +304,6 @@ void br_dev_setup(struct net_device *dev)
 	dev->features =3D NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA |
 			NETIF_F_GSO_MASK | NETIF_F_NO_CSUM | NETIF_F_LLTX |
 			NETIF_F_NETNS_LOCAL | NETIF_F_GSO | NETIF_F_HW_VLAN_TX;
+	dev->hw_features =3D NETIF_F_NO_CSUM | NETIF_F_SG | NETIF_F_GSO_MASK =
|
+			   NETIF_F_HW_VLAN_TX;
 }
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 2a6801d..cad638f 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -203,7 +203,6 @@ static struct net_device *new_bridge_dev(struct net=
 *net, const char *name)
=20
 	memcpy(br->group_addr, br_group_address, ETH_ALEN);
=20
-	br->feature_mask =3D dev->features;
 	br->stp_enabled =3D BR_NO_STP;
 	br->designated_root =3D br->bridge_id;
 	br->root_path_cost =3D 0;
@@ -362,15 +361,15 @@ int br_min_mtu(const struct net_bridge *br)
 /*
  * Recomputes features using slave's features
  */
-void br_features_recompute(struct net_bridge *br)
+u32 br_features_recompute(struct net_bridge *br, u32 features)
 {
 	struct net_bridge_port *p;
-	u32 features, mask;
+	u32 mask;
=20
-	features =3D mask =3D br->feature_mask;
 	if (list_empty(&br->port_list))
-		goto done;
+		return features;
=20
+	mask =3D features;
 	features &=3D ~NETIF_F_ONE_FOR_ALL;
=20
 	list_for_each_entry(p, &br->port_list, list) {
@@ -378,8 +377,7 @@ void br_features_recompute(struct net_bridge *br)
 						     p->dev->features, mask);
 	}
=20
-done:
-	br->dev->features =3D netdev_fix_features(br->dev, features);
+	return features;
 }
=20
 /* called with RTNL */
@@ -441,7 +439,7 @@ int br_add_if(struct net_bridge *br, struct net_dev=
ice *dev)
=20
 	spin_lock_bh(&br->lock);
 	br_stp_recalculate_bridge_id(br);
-	br_features_recompute(br);
+	netdev_update_features(br->dev);
=20
 	if ((dev->flags & IFF_UP) && netif_carrier_ok(dev) &&
 	    (br->dev->flags & IFF_UP))
@@ -483,7 +481,7 @@ int br_del_if(struct net_bridge *br, struct net_dev=
ice *dev)
=20
 	spin_lock_bh(&br->lock);
 	br_stp_recalculate_bridge_id(br);
-	br_features_recompute(br);
+	netdev_update_features(br->dev);
 	spin_unlock_bh(&br->lock);
=20
 	return 0;
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 7d337c9..274ef4a 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -62,7 +62,7 @@ static int br_device_event(struct notifier_block *unu=
sed, unsigned long event, v
 	case NETDEV_FEAT_CHANGE:
 		spin_lock_bh(&br->lock);
 		if (netif_running(br->dev))
-			br_features_recompute(br);
+			netdev_update_features(br->dev);
 		spin_unlock_bh(&br->lock);
 		break;
=20
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 9f22898..c24bd1e 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -182,7 +182,6 @@ struct net_bridge
 	struct br_cpu_netstats __percpu *stats;
 	spinlock_t			hash_lock;
 	struct hlist_head		hash[BR_HASH_SIZE];
-	u32				feature_mask;
 #ifdef CONFIG_BRIDGE_NETFILTER
 	struct rtable 			fake_rtable;
 	bool				nf_call_iptables;
@@ -376,7 +375,7 @@ extern int br_add_if(struct net_bridge *br,
 extern int br_del_if(struct net_bridge *br,
 	      struct net_device *dev);
 extern int br_min_mtu(const struct net_bridge *br);
-extern void br_features_recompute(struct net_bridge *br);
+extern u32 br_features_recompute(struct net_bridge *br, u32 features);
=20
 /* br_input.c */
 extern int br_handle_frame_finish(struct sk_buff *skb);
--=20
1.7.2.3

