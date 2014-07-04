From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 07/10] net/hsr: Implemented .ndo_fix_features (better
 device features handling).
Date: Fri, 4 Jul 2014 23:38:57 +0200
Message-ID: <53B71EF1.5010400@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:53628 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751939AbaGDVic (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:38:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_device.c | 55 ++++++++++++++++++++++++++++++++++++++++++++=
--------
 net/hsr/hsr_slave.c  |  2 ++
 2 files changed, 49 insertions(+), 8 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index 1fc4ea2..c489aed 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -198,6 +198,39 @@ static int hsr_dev_close(struct net_device *dev)
 }
=20
=20
+static netdev_features_t hsr_features_recompute(struct hsr_priv *hsr,
+						netdev_features_t features)
+{
+	netdev_features_t mask;
+	struct hsr_port *port;
+
+	mask =3D features;
+
+	/* Mask out all features that, if supported by one device, should be
+	 * enabled for all devices (see NETIF_F_ONE_FOR_ALL).
+	 *
+	 * Anything that's off in mask will not be enabled - so only things
+	 * that were in features originally, and also is in NETIF_F_ONE_FOR_A=
LL,
+	 * may become enabled.
+	 */
+	features &=3D ~NETIF_F_ONE_FOR_ALL;
+	hsr_for_each_port(hsr, port)
+		features =3D netdev_increment_features(features,
+						     port->dev->features,
+						     mask);
+
+	return features;
+}
+
+static netdev_features_t hsr_fix_features(struct net_device *dev,
+					  netdev_features_t features)
+{
+	struct hsr_priv *hsr =3D netdev_priv(dev);
+
+	return hsr_features_recompute(hsr, features);
+}
+
+
 static void hsr_fill_tag(struct hsr_ethhdr *hsr_ethhdr, struct hsr_pri=
v *hsr)
 {
 	unsigned long irqflags;
@@ -465,6 +498,7 @@ static const struct net_device_ops hsr_device_ops =3D=
 {
 	.ndo_open =3D hsr_dev_open,
 	.ndo_stop =3D hsr_dev_close,
 	.ndo_start_xmit =3D hsr_dev_xmit,
+	.ndo_fix_features =3D hsr_fix_features,
 };
=20
=20
@@ -478,6 +512,19 @@ void hsr_dev_setup(struct net_device *dev)
 	dev->tx_queue_len	 =3D 0;
=20
 	dev->destructor =3D hsr_dev_destroy;
+
+	dev->hw_features =3D NETIF_F_SG | NETIF_F_FRAGLIST | NETIF_F_HIGHDMA =
|
+			   NETIF_F_GSO_MASK | NETIF_F_HW_CSUM |
+			   NETIF_F_HW_VLAN_CTAG_TX;
+
+	dev->features =3D dev->hw_features;
+
+	/* Prevent recursive tx locking */
+	dev->features |=3D NETIF_F_LLTX;
+	/* VLAN on top of HSR needs testing and probably some work on
+	 * hsr_header_create() etc.
+	 */
+	dev->features |=3D NETIF_F_VLAN_CHALLENGED;
 }
=20
=20
@@ -513,14 +560,6 @@ int hsr_dev_finalize(struct net_device *hsr_dev, s=
truct net_device *slave[2],
 	if (res < 0)
 		return res;
=20
-	hsr_dev->features =3D slave[0]->features & slave[1]->features;
-	/* Prevent recursive tx locking */
-	hsr_dev->features |=3D NETIF_F_LLTX;
-	/* VLAN on top of HSR needs testing and probably some work on
-	 * hsr_header_create() etc.
-	 */
-	hsr_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
-
 	spin_lock_init(&hsr->seqnr_lock);
 	/* Overflow soon to find bugs easier: */
 	hsr->sequence_nr =3D USHRT_MAX - 1024;
diff --git a/net/hsr/hsr_slave.c b/net/hsr/hsr_slave.c
index fffd692..23817d0 100644
--- a/net/hsr/hsr_slave.c
+++ b/net/hsr/hsr_slave.c
@@ -344,6 +344,7 @@ int hsr_add_port(struct hsr_priv *hsr, struct net_d=
evice *dev,
 	if (dev->hard_header_len + HSR_HLEN > master->dev->hard_header_len)
 		master->dev->hard_header_len =3D dev->hard_header_len + HSR_HLEN;
=20
+	netdev_update_features(master->dev);
 	dev_set_mtu(master->dev, hsr_get_max_mtu(hsr));
=20
 	return 0;
@@ -363,6 +364,7 @@ void hsr_del_port(struct hsr_port *port)
 	list_del_rcu(&port->port_list);
=20
 	if (port !=3D master) {
+		netdev_update_features(master->dev);
 		dev_set_mtu(master->dev, hsr_get_max_mtu(hsr));
 		netdev_rx_handler_unregister(port->dev);
 		dev_set_promiscuity(port->dev, -1);
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
