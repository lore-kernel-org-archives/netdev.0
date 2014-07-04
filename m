From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH net-next 04/10] net/hsr: Operstate handling cleanup.
Date: Fri, 4 Jul 2014 23:36:40 +0200
Message-ID: <53B71E68.30809@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:62401 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753000AbaGDVpy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jul 2014 17:45:54 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_device.c | 37 ++++++++++++++++++++++++++++---------
 net/hsr/hsr_device.h |  6 +-----
 net/hsr/hsr_main.c   |  9 +--------
 3 files changed, 30 insertions(+), 22 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index f224067..8936b3c 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -46,31 +46,36 @@ static void __hsr_set_operstate(struct net_device *=
dev, int transition)
 	}
 }
=20
-void hsr_set_operstate(struct net_device *hsr_dev, struct net_device *=
slave1,
-		       struct net_device *slave2)
+static void hsr_set_operstate(struct net_device *hsr_dev, bool has_car=
rier)
 {
 	if (!is_admin_up(hsr_dev)) {
 		__hsr_set_operstate(hsr_dev, IF_OPER_DOWN);
 		return;
 	}
=20
-	if (is_slave_up(slave1) || is_slave_up(slave2))
+	if (has_carrier)
 		__hsr_set_operstate(hsr_dev, IF_OPER_UP);
 	else
 		__hsr_set_operstate(hsr_dev, IF_OPER_LOWERLAYERDOWN);
 }
=20
-void hsr_set_carrier(struct net_device *hsr_dev, struct net_device *sl=
ave1,
-		     struct net_device *slave2)
+static bool hsr_check_carrier(struct hsr_priv *hsr)
 {
-	if (is_slave_up(slave1) || is_slave_up(slave2))
-		netif_carrier_on(hsr_dev);
+	bool has_carrier;
+
+	has_carrier =3D (is_slave_up(hsr->slave[0]) || is_slave_up(hsr->slave=
[1]));
+
+	if (has_carrier)
+		netif_carrier_on(hsr->dev);
 	else
-		netif_carrier_off(hsr_dev);
+		netif_carrier_off(hsr->dev);
+
+	return has_carrier;
 }
=20
=20
-void hsr_check_announce(struct net_device *hsr_dev, int old_operstate)
+static void hsr_check_announce(struct net_device *hsr_dev,
+			       unsigned char old_operstate)
 {
 	struct hsr_priv *hsr;
=20
@@ -89,6 +94,20 @@ void hsr_check_announce(struct net_device *hsr_dev, =
int old_operstate)
 		del_timer(&hsr->announce_timer);
 }
=20
+void hsr_check_carrier_and_operstate(struct hsr_priv *hsr)
+{
+	unsigned char old_operstate;
+	bool has_carrier;
+
+	/* netif_stacked_transfer_operstate() cannot be used here since
+	 * it doesn't set IF_OPER_LOWERLAYERDOWN (?)
+	 */
+	old_operstate =3D hsr->dev->operstate;
+	has_carrier =3D hsr_check_carrier(hsr);
+	hsr_set_operstate(hsr->dev, has_carrier);
+	hsr_check_announce(hsr->dev, old_operstate);
+}
+
=20
 int hsr_get_max_mtu(struct hsr_priv *hsr)
 {
diff --git a/net/hsr/hsr_device.h b/net/hsr/hsr_device.h
index feb744f..108a5d5 100644
--- a/net/hsr/hsr_device.h
+++ b/net/hsr/hsr_device.h
@@ -18,11 +18,7 @@
 void hsr_dev_setup(struct net_device *dev);
 int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *sl=
ave[2],
 		     unsigned char multicast_spec);
-void hsr_set_operstate(struct net_device *hsr_dev, struct net_device *=
slave1,
-		       struct net_device *slave2);
-void hsr_set_carrier(struct net_device *hsr_dev, struct net_device *sl=
ave1,
-		     struct net_device *slave2);
-void hsr_check_announce(struct net_device *hsr_dev, int old_operstate)=
;
+void hsr_check_carrier_and_operstate(struct hsr_priv *hsr);
 bool is_hsr_master(struct net_device *dev);
 int hsr_get_max_mtu(struct hsr_priv *hsr);
=20
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index 5f9cd7f..431b528 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -91,7 +91,6 @@ static int hsr_netdev_notify(struct notifier_block *n=
b, unsigned long event,
 {
 	struct net_device *slave, *other_slave;
 	struct hsr_priv *hsr;
-	int old_operstate;
 	int mtu_max;
 	int res;
 	struct net_device *dev;
@@ -115,13 +114,7 @@ static int hsr_netdev_notify(struct notifier_block=
 *nb, unsigned long event,
 	case NETDEV_UP:		/* Administrative state DOWN */
 	case NETDEV_DOWN:	/* Administrative state UP */
 	case NETDEV_CHANGE:	/* Link (carrier) state changes */
-		old_operstate =3D hsr->dev->operstate;
-		hsr_set_carrier(hsr->dev, slave, other_slave);
-		/* netif_stacked_transfer_operstate() cannot be used here since
-		 * it doesn't set IF_OPER_LOWERLAYERDOWN (?)
-		 */
-		hsr_set_operstate(hsr->dev, slave, other_slave);
-		hsr_check_announce(hsr->dev, old_operstate);
+		hsr_check_carrier_and_operstate(hsr);
 		break;
 	case NETDEV_CHANGEADDR:
=20
--=20
1.8.3.2

--=20
Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
