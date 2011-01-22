From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH v2 03/16] net: reduce and unify printk level in netdev_fix_features()
Date: Sat, 22 Jan 2011 23:14:12 +0100 (CET)
Message-ID: <29e476c368b6580f7ff5215ca759b69c75d0e021.1295734271.git.mirq-linux@rere.qmqm.pl>
References: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <bhutchings@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:43050 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752422Ab1AVWOO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 22 Jan 2011 17:14:14 -0500
In-Reply-To: <cover.1295734270.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reduce printk() levels to KERN_INFO in netdev_fix_features() as this wi=
ll
be used by ethtool and might spam dmesg unnecessarily.

This converts the function to use netdev_info() instead of plain printk=
().

As a side effect, bonding and bridge devices will now log dropped featu=
res
on every slave device change.

Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/bonding/bond_main.c |    4 ++--
 include/linux/netdevice.h       |    2 +-
 net/bridge/br_if.c              |    2 +-
 net/core/dev.c                  |   36 +++++++++++++++----------------=
-----
 4 files changed, 19 insertions(+), 25 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond=
_main.c
index 8d10aff..f4373e8 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -1400,8 +1400,8 @@ static int bond_compute_features(struct bonding *=
bond)
=20
 done:
 	features |=3D (bond_dev->features & BOND_VLAN_FEATURES);
-	bond_dev->features =3D netdev_fix_features(features, NULL);
-	bond_dev->vlan_features =3D netdev_fix_features(vlan_features, NULL);
+	bond_dev->features =3D netdev_fix_features(bond_dev, features);
+	bond_dev->vlan_features =3D netdev_fix_features(bond_dev, vlan_featur=
es);
 	bond_dev->hard_header_len =3D max_hard_header_len;
=20
 	return 0;
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index c73d63d..04b65b7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2371,7 +2371,7 @@ extern char *netdev_drivername(const struct net_d=
evice *dev, char *buffer, int l
 extern void linkwatch_run_queue(void);
=20
 u32 netdev_increment_features(u32 all, u32 one, u32 mask);
-u32 netdev_fix_features(u32 features, const char *name);
+u32 netdev_fix_features(struct net_device *dev, u32 features);
=20
 void netif_stacked_transfer_operstate(const struct net_device *rootdev=
,
 					struct net_device *dev);
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index 52ce4a3..2a6801d 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -379,7 +379,7 @@ void br_features_recompute(struct net_bridge *br)
 	}
=20
 done:
-	br->dev->features =3D netdev_fix_features(features, NULL);
+	br->dev->features =3D netdev_fix_features(br->dev, features);
 }
=20
 /* called with RTNL */
diff --git a/net/core/dev.c b/net/core/dev.c
index 01d7ce2..168588f 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5127,58 +5127,52 @@ static void rollback_registered(struct net_devi=
ce *dev)
 	rollback_registered_many(&single);
 }
=20
-u32 netdev_fix_features(u32 features, const char *name)
+u32 netdev_fix_features(struct net_device *dev, u32 features)
 {
 	/* Fix illegal checksum combinations */
 	if ((features & NETIF_F_HW_CSUM) &&
 	    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
-		if (name)
-			printk(KERN_NOTICE "%s: mixed HW and IP checksum settings.\n",
-				name);
+		netdev_info(dev,
+			"mixed HW and IP checksum settings.\n");
 		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM);
 	}
=20
 	if ((features & NETIF_F_NO_CSUM) &&
 	    (features & (NETIF_F_HW_CSUM|NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM)))=
 {
-		if (name)
-			printk(KERN_NOTICE "%s: mixed no checksumming and other settings.\n=
",
-				name);
+		netdev_info(dev,
+			"mixed no checksumming and other settings.\n");
 		features &=3D ~(NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM|NETIF_F_HW_CSUM);
 	}
=20
 	/* Fix illegal SG+CSUM combinations. */
 	if ((features & NETIF_F_SG) &&
 	    !(features & NETIF_F_ALL_CSUM)) {
-		if (name)
-			printk(KERN_NOTICE "%s: Dropping NETIF_F_SG since no "
-			       "checksum feature.\n", name);
+		netdev_info(dev,
+			"Dropping NETIF_F_SG since no checksum feature.\n");
 		features &=3D ~NETIF_F_SG;
 	}
=20
 	/* TSO requires that SG is present as well. */
 	if ((features & NETIF_F_TSO) && !(features & NETIF_F_SG)) {
-		if (name)
-			printk(KERN_NOTICE "%s: Dropping NETIF_F_TSO since no "
-			       "SG feature.\n", name);
+		netdev_info(dev,
+			"Dropping NETIF_F_TSO since no SG feature.\n");
 		features &=3D ~NETIF_F_TSO;
 	}
=20
+	/* UFO needs SG and checksumming */
 	if (features & NETIF_F_UFO) {
 		/* maybe split UFO into V4 and V6? */
 		if (!((features & NETIF_F_GEN_CSUM) ||
 		    (features & (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))
 			    =3D=3D (NETIF_F_IP_CSUM|NETIF_F_IPV6_CSUM))) {
-			if (name)
-				printk(KERN_ERR "%s: Dropping NETIF_F_UFO "
-				       "since no checksum offload features.\n",
-				       name);
+			netdev_info(dev,
+				"Dropping NETIF_F_UFO since no checksum offload features.\n");
 			features &=3D ~NETIF_F_UFO;
 		}
=20
 		if (!(features & NETIF_F_SG)) {
-			if (name)
-				printk(KERN_ERR "%s: Dropping NETIF_F_UFO "
-				       "since no NETIF_F_SG feature.\n", name);
+			netdev_info(dev,
+				"Dropping NETIF_F_UFO since no NETIF_F_SG feature.\n");
 			features &=3D ~NETIF_F_UFO;
 		}
 	}
@@ -5321,7 +5315,7 @@ int register_netdevice(struct net_device *dev)
 	if (dev->iflink =3D=3D -1)
 		dev->iflink =3D dev->ifindex;
=20
-	dev->features =3D netdev_fix_features(dev->features, dev->name);
+	dev->features =3D netdev_fix_features(dev, dev->features);
=20
 	/* Enable software GSO if SG is supported. */
 	if (dev->features & NETIF_F_SG)
--=20
1.7.2.3

