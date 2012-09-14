From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/2] net: provide a default dev->ethtool_ops
Date: Fri, 14 Sep 2012 09:24:01 +0200
Message-ID: <1347607441.8555.265.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36569 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755647Ab2INHYI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Sep 2012 03:24:08 -0400
Received: by bkwj10 with SMTP id j10so1000310bkw.19
        for <netdev@vger.kernel.org>; Fri, 14 Sep 2012 00:24:06 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <edumazet@google.com>

Instead of forcing device drivers to provide empty ethtool_ops or tweak
net/core/ethtool.c again, we could provide a generic ethtool_ops.

This occurred to me when I wanted to add GSO support to GRE tunnels.
ethtool -k support should be generic for all drivers.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
---
 net/core/dev.c     |    5 +++
 net/core/ethtool.c |   54 +++++++++++++++++--------------------------
 2 files changed, 27 insertions(+), 32 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b1e6d63..ff8dcfc 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6045,6 +6045,11 @@ struct net_device *alloc_netdev_mqs(int sizeof_p=
riv, const char *name,
=20
 	strcpy(dev->name, name);
 	dev->group =3D INIT_NETDEV_GROUP;
+	if (!dev->ethtool_ops) {
+		static const struct ethtool_ops default_ethtool_ops;
+
+		dev->ethtool_ops =3D &default_ethtool_ops;
+	}
 	return dev;
=20
 free_all:
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index cbf033d..aef0162 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -175,7 +175,7 @@ static int __ethtool_get_sset_count(struct net_devi=
ce *dev, int sset)
 	if (sset =3D=3D ETH_SS_FEATURES)
 		return ARRAY_SIZE(netdev_features_strings);
=20
-	if (ops && ops->get_sset_count && ops->get_strings)
+	if (ops->get_sset_count && ops->get_strings)
 		return ops->get_sset_count(dev, sset);
 	else
 		return -EOPNOTSUPP;
@@ -311,7 +311,7 @@ int __ethtool_get_settings(struct net_device *dev, =
struct ethtool_cmd *cmd)
 {
 	ASSERT_RTNL();
=20
-	if (!dev->ethtool_ops || !dev->ethtool_ops->get_settings)
+	if (!dev->ethtool_ops->get_settings)
 		return -EOPNOTSUPP;
=20
 	memset(cmd, 0, sizeof(struct ethtool_cmd));
@@ -355,7 +355,7 @@ static noinline_for_stack int ethtool_get_drvinfo(s=
truct net_device *dev,
=20
 	memset(&info, 0, sizeof(info));
 	info.cmd =3D ETHTOOL_GDRVINFO;
-	if (ops && ops->get_drvinfo) {
+	if (ops->get_drvinfo) {
 		ops->get_drvinfo(dev, &info);
 	} else if (dev->dev.parent && dev->dev.parent->driver) {
 		strlcpy(info.bus_info, dev_name(dev->dev.parent),
@@ -370,7 +370,7 @@ static noinline_for_stack int ethtool_get_drvinfo(s=
truct net_device *dev,
 	 * this method of obtaining string set info is deprecated;
 	 * Use ETHTOOL_GSSET_INFO instead.
 	 */
-	if (ops && ops->get_sset_count) {
+	if (ops->get_sset_count) {
 		int rc;
=20
 		rc =3D ops->get_sset_count(dev, ETH_SS_TEST);
@@ -383,9 +383,9 @@ static noinline_for_stack int ethtool_get_drvinfo(s=
truct net_device *dev,
 		if (rc >=3D 0)
 			info.n_priv_flags =3D rc;
 	}
-	if (ops && ops->get_regs_len)
+	if (ops->get_regs_len)
 		info.regdump_len =3D ops->get_regs_len(dev);
-	if (ops && ops->get_eeprom_len)
+	if (ops->get_eeprom_len)
 		info.eedump_len =3D ops->get_eeprom_len(dev);
=20
 	if (copy_to_user(useraddr, &info, sizeof(info)))
@@ -1275,7 +1275,7 @@ static int ethtool_get_dump_flag(struct net_devic=
e *dev,
 	struct ethtool_dump dump;
 	const struct ethtool_ops *ops =3D dev->ethtool_ops;
=20
-	if (!dev->ethtool_ops->get_dump_flag)
+	if (!ops->get_dump_flag)
 		return -EOPNOTSUPP;
=20
 	if (copy_from_user(&dump, useraddr, sizeof(dump)))
@@ -1299,8 +1299,7 @@ static int ethtool_get_dump_data(struct net_devic=
e *dev,
 	const struct ethtool_ops *ops =3D dev->ethtool_ops;
 	void *data =3D NULL;
=20
-	if (!dev->ethtool_ops->get_dump_data ||
-		!dev->ethtool_ops->get_dump_flag)
+	if (!ops->get_dump_data || !ops->get_dump_flag)
 		return -EOPNOTSUPP;
=20
 	if (copy_from_user(&dump, useraddr, sizeof(dump)))
@@ -1349,7 +1348,7 @@ static int ethtool_get_ts_info(struct net_device =
*dev, void __user *useraddr)
=20
 		err =3D phydev->drv->ts_info(phydev, &info);
=20
-	} else if (dev->ethtool_ops && dev->ethtool_ops->get_ts_info) {
+	} else if (ops->get_ts_info) {
=20
 		err =3D ops->get_ts_info(dev, &info);
=20
@@ -1410,8 +1409,9 @@ static int ethtool_get_module_eeprom(struct net_d=
evice *dev,
 				      modinfo.eeprom_len);
 }
=20
-/* The main entry point in this file.  Called from net/core/dev.c */
-
+/* The main entry point in this file.  Called from net/core/dev.c
+ * with RTNL held.
+ */
 int dev_ethtool(struct net *net, struct ifreq *ifr)
 {
 	struct net_device *dev =3D __dev_get_by_name(net, ifr->ifr_name);
@@ -1419,25 +1419,15 @@ int dev_ethtool(struct net *net, struct ifreq *=
ifr)
 	u32 ethcmd;
 	int rc;
 	u32 old_features;
+	const struct ethtool_ops *ops;
=20
 	if (!dev || !netif_device_present(dev))
 		return -ENODEV;
=20
+	ops =3D dev->ethtool_ops;
 	if (copy_from_user(&ethcmd, useraddr, sizeof(ethcmd)))
 		return -EFAULT;
=20
-	if (!dev->ethtool_ops) {
-		/* A few commands do not require any driver support,
-		 * are unprivileged, and do not change anything, so we
-		 * can take a shortcut to them. */
-		if (ethcmd =3D=3D ETHTOOL_GDRVINFO)
-			return ethtool_get_drvinfo(dev, useraddr);
-		else if (ethcmd =3D=3D ETHTOOL_GET_TS_INFO)
-			return ethtool_get_ts_info(dev, useraddr);
-		else
-			return -EOPNOTSUPP;
-	}
-
 	/* Allow some commands to be done by anyone */
 	switch (ethcmd) {
 	case ETHTOOL_GSET:
@@ -1476,8 +1466,8 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 			return -EPERM;
 	}
=20
-	if (dev->ethtool_ops->begin) {
-		rc =3D dev->ethtool_ops->begin(dev);
+	if (ops->begin) {
+		rc =3D ops->begin(dev);
 		if (rc  < 0)
 			return rc;
 	}
@@ -1504,11 +1494,11 @@ int dev_ethtool(struct net *net, struct ifreq *=
ifr)
 		break;
 	case ETHTOOL_GMSGLVL:
 		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       dev->ethtool_ops->get_msglevel);
+				       ops->get_msglevel);
 		break;
 	case ETHTOOL_SMSGLVL:
 		rc =3D ethtool_set_value_void(dev, useraddr,
-				       dev->ethtool_ops->set_msglevel);
+					    ops->set_msglevel);
 		break;
 	case ETHTOOL_GEEE:
 		rc =3D ethtool_get_eee(dev, useraddr);
@@ -1570,11 +1560,11 @@ int dev_ethtool(struct net *net, struct ifreq *=
ifr)
 		break;
 	case ETHTOOL_GPFLAGS:
 		rc =3D ethtool_get_value(dev, useraddr, ethcmd,
-				       dev->ethtool_ops->get_priv_flags);
+				       ops->get_priv_flags);
 		break;
 	case ETHTOOL_SPFLAGS:
 		rc =3D ethtool_set_value(dev, useraddr,
-				       dev->ethtool_ops->set_priv_flags);
+				       ops->set_priv_flags);
 		break;
 	case ETHTOOL_GRXFH:
 	case ETHTOOL_GRXRINGS:
@@ -1655,8 +1645,8 @@ int dev_ethtool(struct net *net, struct ifreq *if=
r)
 		rc =3D -EOPNOTSUPP;
 	}
=20
-	if (dev->ethtool_ops->complete)
-		dev->ethtool_ops->complete(dev);
+	if (ops->complete)
+		ops->complete(dev);
=20
 	if (old_features !=3D dev->features)
 		netdev_features_change(dev);
