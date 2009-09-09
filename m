From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?= <remi@remlab.net>
Subject: [PATCH 1/2] Phonet: back-end for autoconfigured addresses
Date: Wed,  9 Sep 2009 13:00:05 +0300
Message-ID: <1252490406-27951-1-git-send-email-remi@remlab.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:45983 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752035AbZIIKKt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Sep 2009 06:10:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>

In some cases, the network device driver knows what layer-3 address the
device should have. This adds support for the Phonet stack to
automatically request from the driver and add that address to the
network device.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/linux/phonet.h |   17 +++++++++++++++++
 net/phonet/pn_dev.c    |   26 +++++++++++++++++++++++++-
 2 files changed, 42 insertions(+), 1 deletions(-)

diff --git a/include/linux/phonet.h b/include/linux/phonet.h
index ee5e3c9..82b45d1 100644
--- a/include/linux/phonet.h
+++ b/include/linux/phonet.h
@@ -170,4 +170,21 @@ static inline __u8 pn_sockaddr_get_resource(const =
struct sockaddr_pn *spn)
 	return spn->spn_resource;
 }
=20
+/* Phonet device ioctl requests */
+#ifdef __KERNEL__
+#define SIOCPNGAUTOCONF		(SIOCDEVPRIVATE + 0)
+
+struct if_phonet_autoconf {
+	uint8_t device;
+};
+
+struct if_phonet_req {
+	char ifr_phonet_name[16];
+	union {
+		struct if_phonet_autoconf ifru_phonet_autoconf;
+	} ifr_ifru;
+};
+#define ifr_phonet_autoconf ifr_ifru.ifru_phonet_autoconf
+#endif /* __KERNEL__ */
+
 #endif
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
index 5ae4c01..2f65dca 100644
--- a/net/phonet/pn_dev.c
+++ b/net/phonet/pn_dev.c
@@ -28,6 +28,7 @@
 #include <linux/netdevice.h>
 #include <linux/phonet.h>
 #include <linux/proc_fs.h>
+#include <linux/if_arp.h>
 #include <net/sock.h>
 #include <net/netns/generic.h>
 #include <net/phonet/pn_dev.h>
@@ -195,14 +196,37 @@ found:
 	return err;
 }
=20
+/* automatically configure a Phonet device, if supported */
+static int phonet_device_autoconf(struct net_device *dev)
+{
+	struct if_phonet_req req;
+	int ret;
+
+	if (!dev->netdev_ops->ndo_do_ioctl)
+		return -EOPNOTSUPP;
+
+	ret =3D dev->netdev_ops->ndo_do_ioctl(dev, (struct ifreq *)&req,
+						SIOCPNGAUTOCONF);
+	if (ret < 0)
+		return ret;
+	return phonet_address_add(dev, req.ifr_phonet_autoconf.device);
+}
+
 /* notify Phonet of device events */
 static int phonet_device_notify(struct notifier_block *me, unsigned lo=
ng what,
 				void *arg)
 {
 	struct net_device *dev =3D arg;
=20
-	if (what =3D=3D NETDEV_UNREGISTER)
+	switch (what) {
+	case NETDEV_REGISTER:
+		if (dev->type =3D=3D ARPHRD_PHONET)
+			phonet_device_autoconf(dev);
+		break;
+	case NETDEV_UNREGISTER:
 		phonet_device_destroy(dev);
+		break;
+	}
 	return 0;
=20
 }
--=20
1.6.0.4

