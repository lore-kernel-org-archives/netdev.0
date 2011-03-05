From: Sven Eckelmann <sven@narfation.org>
Subject: [PATCH 28/28] batman-adv: Disallow regular interface as mesh device
Date: Sat,  5 Mar 2011 13:28:42 +0100
Message-ID: <1299328122-21468-29-git-send-email-sven@narfation.org>
References: <1299328122-21468-1-git-send-email-sven@narfation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Sven Eckelmann <sven@narfation.org>,
	Marek Lindner <lindner_marek@yahoo.de>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from narfation.org ([79.140.41.39]:36367 "EHLO v3-1039.vlinux.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753423Ab1CEMac (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 5 Mar 2011 07:30:32 -0500
In-Reply-To: <1299328122-21468-1-git-send-email-sven@narfation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to associate a net_device with another net_device which
already exists, batman-adv assumes that this interface is a fully
initialized batman mesh interface without checking it. The behaviour
when accessing data behind netdev_priv of a random net_device is
undefined and potentially dangerous.

Reported-by: Linus L=C3=BCssing <linus.luessing@ascom.ch>
Signed-off-by: Marek Lindner <lindner_marek@yahoo.de>
---
 net/batman-adv/hard-interface.c |   34 ++++++++++++++++++++++---------=
---
 net/batman-adv/soft-interface.c |   13 +++++++++++++
 net/batman-adv/soft-interface.h |    1 +
 3 files changed, 36 insertions(+), 12 deletions(-)

diff --git a/net/batman-adv/hard-interface.c b/net/batman-adv/hard-inte=
rface.c
index 95a35b6..b3058e4 100644
--- a/net/batman-adv/hard-interface.c
+++ b/net/batman-adv/hard-interface.c
@@ -79,13 +79,8 @@ static int is_valid_iface(struct net_device *net_dev=
)
 		return 0;
=20
 	/* no batman over batman */
-#ifdef HAVE_NET_DEVICE_OPS
-	if (net_dev->netdev_ops->ndo_start_xmit =3D=3D interface_tx)
+	if (softif_is_valid(net_dev))
 		return 0;
-#else
-	if (net_dev->hard_start_xmit =3D=3D interface_tx)
-		return 0;
-#endif
=20
 	/* Device is being bridged */
 	/* if (net_dev->priv_flags & IFF_BRIDGE_PORT)
@@ -282,6 +277,8 @@ int hardif_enable_interface(struct hard_iface *hard=
_iface, char *iface_name)
 {
 	struct bat_priv *bat_priv;
 	struct batman_packet *batman_packet;
+	struct net_device *soft_iface;
+	int ret;
=20
 	if (hard_iface->if_status !=3D IF_NOT_IN_USE)
 		goto out;
@@ -289,18 +286,30 @@ int hardif_enable_interface(struct hard_iface *ha=
rd_iface, char *iface_name)
 	if (!atomic_inc_not_zero(&hard_iface->refcount))
 		goto out;
=20
-	hard_iface->soft_iface =3D dev_get_by_name(&init_net, iface_name);
+	soft_iface =3D dev_get_by_name(&init_net, iface_name);
=20
-	if (!hard_iface->soft_iface) {
-		hard_iface->soft_iface =3D softif_create(iface_name);
+	if (!soft_iface) {
+		soft_iface =3D softif_create(iface_name);
=20
-		if (!hard_iface->soft_iface)
+		if (!soft_iface) {
+			ret =3D -ENOMEM;
 			goto err;
+		}
=20
 		/* dev_get_by_name() increases the reference counter for us */
-		dev_hold(hard_iface->soft_iface);
+		dev_hold(soft_iface);
+	}
+
+	if (!softif_is_valid(soft_iface)) {
+		pr_err("Can't create batman mesh interface %s: "
+		       "already exists as regular interface\n",
+		       soft_iface->name);
+		dev_put(soft_iface);
+		ret =3D -EINVAL;
+		goto err;
 	}
=20
+	hard_iface->soft_iface =3D soft_iface;
 	bat_priv =3D netdev_priv(hard_iface->soft_iface);
 	hard_iface->packet_len =3D BAT_PACKET_LEN;
 	hard_iface->packet_buff =3D kmalloc(hard_iface->packet_len, GFP_ATOMI=
C);
@@ -308,6 +317,7 @@ int hardif_enable_interface(struct hard_iface *hard=
_iface, char *iface_name)
 	if (!hard_iface->packet_buff) {
 		bat_err(hard_iface->soft_iface, "Can't add interface packet "
 			"(%s): out of memory\n", hard_iface->net_dev->name);
+		ret =3D -ENOMEM;
 		goto err;
 	}
=20
@@ -370,7 +380,7 @@ out:
=20
 err:
 	hardif_free_ref(hard_iface);
-	return -ENOMEM;
+	return ret;
 }
=20
 void hardif_disable_interface(struct hard_iface *hard_iface)
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-inte=
rface.c
index 6b514ec..9ed2614 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -622,6 +622,19 @@ void softif_destroy(struct net_device *soft_iface)
 	unregister_netdevice(soft_iface);
 }
=20
+int softif_is_valid(struct net_device *net_dev)
+{
+#ifdef HAVE_NET_DEVICE_OPS
+	if (net_dev->netdev_ops->ndo_start_xmit =3D=3D interface_tx)
+		return 1;
+#else
+	if (net_dev->hard_start_xmit =3D=3D interface_tx)
+		return 1;
+#endif
+
+	return 0;
+}
+
 /* ethtool */
 static int bat_get_settings(struct net_device *dev, struct ethtool_cmd=
 *cmd)
 {
diff --git a/net/batman-adv/soft-interface.h b/net/batman-adv/soft-inte=
rface.h
index 80a3607..4789b6f 100644
--- a/net/batman-adv/soft-interface.h
+++ b/net/batman-adv/soft-interface.h
@@ -31,5 +31,6 @@ void interface_rx(struct net_device *soft_iface,
 		  int hdr_size);
 struct net_device *softif_create(char *name);
 void softif_destroy(struct net_device *soft_iface);
+int softif_is_valid(struct net_device *net_dev);
=20
 #endif /* _NET_BATMAN_ADV_SOFT_INTERFACE_H_ */
--=20
1.7.2.3

