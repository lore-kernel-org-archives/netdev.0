From: =?UTF-8?q?Micha=C5=82=20Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Subject: [PATCH] net: tun: convert to hw_features
Date: Tue, 19 Apr 2011 18:13:10 +0200 (CEST)
Message-ID: <20110419161310.7508513909@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rusty Russell <rusty@rustcorp.com.au>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rere.qmqm.pl ([89.167.52.164]:60466 "EHLO rere.qmqm.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752384Ab1DSQNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Apr 2011 12:13:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This changes offload setting behaviour to what I think is correct:
 - offloads set via ethtool mean what admin wants to use (by default
   he wants 'em all)
 - offloads set via ioctl() mean what userspace is expecting to get
   (this limits which admin wishes are granted)
 - TUN_NOCHECKSUM is ignored, as it might cause broken packets when
   forwarded (ip_summed =3D=3D CHECKSUM_UNNECESSARY means that checksum
   was verified, not that it can be ignored)

If TUN_NOCHECKSUM is implemented, it should set skb->csum_* and
skb->ip_summed (=3D CHECKSUM_PARTIAL) for known protocols and let other=
s
be verified by kernel when necessary.

TUN_NOCHECKSUM handling was introduced by commit
f43798c27684ab925adde7d8acc34c78c6e50df8:

    tun: Allow GSO using virtio_net_hdr
   =20
Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
---
 drivers/net/tun.c |   63 +++++++++++++++++++++------------------------=
--------
 1 files changed, 25 insertions(+), 38 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index f5e9ac0..ade3cf9 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -123,6 +123,9 @@ struct tun_struct {
 	gid_t			group;
=20
 	struct net_device	*dev;
+	u32			set_features;
+#define TUN_USER_FEATURES (NETIF_F_HW_CSUM|NETIF_F_TSO_ECN|NETIF_F_TSO=
| \
+			  NETIF_F_TSO6|NETIF_F_UFO)
 	struct fasync_struct	*fasync;
=20
 	struct tap_filter       txflt;
@@ -451,12 +454,20 @@ tun_net_change_mtu(struct net_device *dev, int ne=
w_mtu)
 	return 0;
 }
=20
+static u32 tun_net_fix_features(struct net_device *dev, u32 features)
+{
+	struct tun_struct *tun =3D netdev_priv(dev);
+
+	return (features & tun->set_features) | (features & ~TUN_USER_FEATURE=
S);
+}
+
 static const struct net_device_ops tun_netdev_ops =3D {
 	.ndo_uninit		=3D tun_net_uninit,
 	.ndo_open		=3D tun_net_open,
 	.ndo_stop		=3D tun_net_close,
 	.ndo_start_xmit		=3D tun_net_xmit,
 	.ndo_change_mtu		=3D tun_net_change_mtu,
+	.ndo_fix_features	=3D tun_net_fix_features,
 };
=20
 static const struct net_device_ops tap_netdev_ops =3D {
@@ -465,6 +476,7 @@ static const struct net_device_ops tap_netdev_ops =3D=
 {
 	.ndo_stop		=3D tun_net_close,
 	.ndo_start_xmit		=3D tun_net_xmit,
 	.ndo_change_mtu		=3D tun_net_change_mtu,
+	.ndo_fix_features	=3D tun_net_fix_features,
 	.ndo_set_multicast_list	=3D tun_net_mclist,
 	.ndo_set_mac_address	=3D eth_mac_addr,
 	.ndo_validate_addr	=3D eth_validate_addr,
@@ -628,8 +640,7 @@ static __inline__ ssize_t tun_get_user(struct tun_s=
truct *tun,
 			kfree_skb(skb);
 			return -EINVAL;
 		}
-	} else if (tun->flags & TUN_NOCHECKSUM)
-		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+	}
=20
 	switch (tun->flags & TUN_TYPE_MASK) {
 	case TUN_TUN_DEV:
@@ -1094,6 +1105,10 @@ static int tun_set_iff(struct net *net, struct f=
ile *file, struct ifreq *ifr)
 				goto err_free_sk;
 		}
=20
+		dev->hw_features =3D NETIF_F_SG | NETIF_F_FRAGLIST |
+			TUN_USER_FEATURES;
+		dev->features =3D dev->hw_features;
+
 		err =3D register_netdevice(tun->dev);
 		if (err < 0)
 			goto err_free_sk;
@@ -1158,18 +1173,12 @@ static int tun_get_iff(struct net *net, struct =
tun_struct *tun,
=20
 /* This is like a cut-down ethtool ops, except done via tun fd so no
  * privs required. */
-static int set_offload(struct net_device *dev, unsigned long arg)
+static int set_offload(struct tun_struct *tun, unsigned long arg)
 {
-	u32 old_features, features;
-
-	old_features =3D dev->features;
-	/* Unset features, set them as we chew on the arg. */
-	features =3D (old_features & ~(NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRA=
GLIST
-				    |NETIF_F_TSO_ECN|NETIF_F_TSO|NETIF_F_TSO6
-				    |NETIF_F_UFO));
+	u32 features =3D 0;
=20
 	if (arg & TUN_F_CSUM) {
-		features |=3D NETIF_F_HW_CSUM|NETIF_F_SG|NETIF_F_FRAGLIST;
+		features |=3D NETIF_F_HW_CSUM;
 		arg &=3D ~TUN_F_CSUM;
=20
 		if (arg & (TUN_F_TSO4|TUN_F_TSO6)) {
@@ -1195,9 +1204,8 @@ static int set_offload(struct net_device *dev, un=
signed long arg)
 	if (arg)
 		return -EINVAL;
=20
-	dev->features =3D features;
-	if (old_features !=3D dev->features)
-		netdev_features_change(dev);
+	tun->set_features =3D features;
+	netdev_update_features(tun->dev);
=20
 	return 0;
 }
@@ -1262,12 +1270,9 @@ static long __tun_chr_ioctl(struct file *file, u=
nsigned int cmd,
=20
 	case TUNSETNOCSUM:
 		/* Disable/Enable checksum */
-		if (arg)
-			tun->flags |=3D TUN_NOCHECKSUM;
-		else
-			tun->flags &=3D ~TUN_NOCHECKSUM;
=20
-		tun_debug(KERN_INFO, tun, "checksum %s\n",
+		/* [unimplemented] */
+		tun_debug(KERN_INFO, tun, "ignored: set checksum %s\n",
 			  arg ? "disabled" : "enabled");
 		break;
=20
@@ -1316,7 +1321,7 @@ static long __tun_chr_ioctl(struct file *file, un=
signed int cmd,
 		break;
 #endif
 	case TUNSETOFFLOAD:
-		ret =3D set_offload(tun->dev, arg);
+		ret =3D set_offload(tun, arg);
 		break;
=20
 	case TUNSETTXFILTER:
@@ -1595,30 +1600,12 @@ static void tun_set_msglevel(struct net_device =
*dev, u32 value)
 #endif
 }
=20
-static u32 tun_get_rx_csum(struct net_device *dev)
-{
-	struct tun_struct *tun =3D netdev_priv(dev);
-	return (tun->flags & TUN_NOCHECKSUM) =3D=3D 0;
-}
-
-static int tun_set_rx_csum(struct net_device *dev, u32 data)
-{
-	struct tun_struct *tun =3D netdev_priv(dev);
-	if (data)
-		tun->flags &=3D ~TUN_NOCHECKSUM;
-	else
-		tun->flags |=3D TUN_NOCHECKSUM;
-	return 0;
-}
-
 static const struct ethtool_ops tun_ethtool_ops =3D {
 	.get_settings	=3D tun_get_settings,
 	.get_drvinfo	=3D tun_get_drvinfo,
 	.get_msglevel	=3D tun_get_msglevel,
 	.set_msglevel	=3D tun_set_msglevel,
 	.get_link	=3D ethtool_op_get_link,
-	.get_rx_csum	=3D tun_get_rx_csum,
-	.set_rx_csum	=3D tun_set_rx_csum
 };
=20
=20
--=20
1.7.2.5

