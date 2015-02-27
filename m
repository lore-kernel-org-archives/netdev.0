From: Arvid Brodin <arvid.brodin@alten.se>
Subject: [PATCH v2 net] net/hsr: Fix NULL pointer dereference and refcnt bugs
 when deleting a HSR interface.
Date: Fri, 27 Feb 2015 21:26:03 +0100
Message-ID: <54F0D2DB.2020302@alten.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>
To: Arvid Brodin <arvid.brodin@alten.se>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:35178 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbbB0UgD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2015 15:36:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To repeat:

$ sudo ip link del hsr0
BUG: unable to handle kernel NULL pointer dereference at 00000000000000=
18
IP: [<ffffffff8187f495>] hsr_del_port+0x15/0xa0
etc...

Bug description:

As part of the hsr master device destruction, hsr_del_port() is called =
for each of
the hsr ports. At each such call, the master device is updated regardin=
g features
and mtu. When the master device is freed before the slave interfaces, m=
aster will
be NULL in hsr_del_port(), which led to a NULL pointer dereference.

Additionally, dev_put() was called on the master device itself in hsr_d=
el_port(),
causing a refcnt error.

A third bug in the same code path was that the rtnl lock was not taken =
before
hsr_del_port() was called as part of hsr_dev_destroy().

The reporter (Nicolas Dichtel) also said: "hsr_netdev_notify() supposes=
 that the
port will always be available when the notification is for an hsr inter=
face. It's
wrong. For example, netdev_wait_allrefs() may resend NETDEV_UNREGISTER.=
". As a
precaution against this, a check for port =3D=3D NULL was added in hsr_=
dev_notify().

Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
=46ixes: 51f3c605318b056a ("net/hsr: Move slave init to hsr_slave.c.")
Signed-off-by: Arvid Brodin <arvid.brodin@alten.se>
---
 net/hsr/hsr_device.c |  3 +++
 net/hsr/hsr_main.c   |  4 ++++
 net/hsr/hsr_slave.c  | 10 +++++++---
 3 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
index a138d75..44d2746 100644
--- a/net/hsr/hsr_device.c
+++ b/net/hsr/hsr_device.c
@@ -359,8 +359,11 @@ static void hsr_dev_destroy(struct net_device *hsr=
_dev)
 	struct hsr_port *port;
=20
 	hsr =3D netdev_priv(hsr_dev);
+
+	rtnl_lock();
 	hsr_for_each_port(hsr, port)
 		hsr_del_port(port);
+	rtnl_unlock();
=20
 	del_timer_sync(&hsr->prune_timer);
 	del_timer_sync(&hsr->announce_timer);
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
index 779d28b..cd37d00 100644
--- a/net/hsr/hsr_main.c
+++ b/net/hsr/hsr_main.c
@@ -36,6 +36,10 @@ static int hsr_netdev_notify(struct notifier_block *=
nb, unsigned long event,
 			return NOTIFY_DONE;	/* Not an HSR device */
 		hsr =3D netdev_priv(dev);
 		port =3D hsr_port_get_hsr(hsr, HSR_PT_MASTER);
+		if (port =3D=3D NULL) {
+			/* Resend of notification concerning removed device? */
+			return NOTIFY_DONE;
+		}
 	} else {
 		hsr =3D port->hsr;
 	}
diff --git a/net/hsr/hsr_slave.c b/net/hsr/hsr_slave.c
index a348dcb..7d37366 100644
--- a/net/hsr/hsr_slave.c
+++ b/net/hsr/hsr_slave.c
@@ -181,8 +181,10 @@ void hsr_del_port(struct hsr_port *port)
 	list_del_rcu(&port->port_list);
=20
 	if (port !=3D master) {
-		netdev_update_features(master->dev);
-		dev_set_mtu(master->dev, hsr_get_max_mtu(hsr));
+		if (master !=3D NULL) {
+			netdev_update_features(master->dev);
+			dev_set_mtu(master->dev, hsr_get_max_mtu(hsr));
+		}
 		netdev_rx_handler_unregister(port->dev);
 		dev_set_promiscuity(port->dev, -1);
 	}
@@ -192,5 +194,7 @@ void hsr_del_port(struct hsr_port *port)
 	 */
=20
 	synchronize_rcu();
-	dev_put(port->dev);
+
+	if (port !=3D master)
+		dev_put(port->dev);
 }
--=20
2.0.5

Arvid Brodin | Consultant (Linux)
ALTEN | Knarrarn=C3=A4sgatan 7 | SE-164 40 Kista | Sweden
arvid.brodin@alten.se | www.alten.se/en/
