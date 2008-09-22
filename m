From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 04/11] Phonet: network device and address handling
Date: Mon, 22 Sep 2008 18:47:18 +0300
Message-ID: <1222098445-26175-4-git-send-email-remi.denis-courmont@nokia.com>
References: <200809221845.54736.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.105.134]:34623 "EHLO
	mgw-mx09.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753419AbYIVPrn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Sep 2008 11:47:43 -0400
Received: from vaebh105.NOE.Nokia.com (vaebh105.europe.nokia.com [10.160.244.31])
	by mgw-mx09.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8MFlIhZ008928
	for <netdev@vger.kernel.org>; Mon, 22 Sep 2008 10:47:41 -0500
In-Reply-To: <200809221845.54736.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides support for adding Phonet addresses to and removing
Phonet addresses from network devices.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |   50 ++++++++++
 net/phonet/Makefile         |    1 +
 net/phonet/af_phonet.c      |    3 +
 net/phonet/pn_dev.c         |  208 +++++++++++++++++++++++++++++++++++=
++++++++
 4 files changed, 262 insertions(+), 0 deletions(-)
 create mode 100644 include/net/phonet/pn_dev.h
 create mode 100644 net/phonet/pn_dev.c

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
new file mode 100644
index 0000000..bbd2a83
--- /dev/null
+++ b/include/net/phonet/pn_dev.h
@@ -0,0 +1,50 @@
+/*
+ * File: pn_dev.h
+ *
+ * Phonet network device
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#ifndef PN_DEV_H
+#define PN_DEV_H
+
+struct phonet_device_list {
+	struct list_head list;
+	spinlock_t lock;
+};
+
+extern struct phonet_device_list pndevs;
+
+struct phonet_device {
+	struct list_head list;
+	struct net_device *netdev;
+	DECLARE_BITMAP(addrs, 64);
+};
+
+void phonet_device_init(void);
+void phonet_device_exit(void);
+struct net_device *phonet_device_get(struct net *net);
+
+int phonet_address_add(struct net_device *dev, u8 addr);
+int phonet_address_del(struct net_device *dev, u8 addr);
+u8 phonet_address_get(struct net_device *dev, u8 addr);
+int phonet_address_lookup(u8 addr);
+
+#define PN_NO_ADDR	0xff
+
+#endif
diff --git a/net/phonet/Makefile b/net/phonet/Makefile
index 5dbff68..980a386 100644
--- a/net/phonet/Makefile
+++ b/net/phonet/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_PHONET) +=3D phonet.o
=20
 phonet-objs :=3D \
+	pn_dev.o \
 	af_phonet.o
diff --git a/net/phonet/af_phonet.c b/net/phonet/af_phonet.c
index 0cfea9b..a8ba6f1 100644
--- a/net/phonet/af_phonet.c
+++ b/net/phonet/af_phonet.c
@@ -31,6 +31,7 @@
 #include <linux/if_phonet.h>
 #include <linux/phonet.h>
 #include <net/phonet/phonet.h>
+#include <net/phonet/pn_dev.h>
=20
 static struct net_proto_family phonet_proto_family;
 static struct phonet_protocol *phonet_proto_get(int protocol);
@@ -200,6 +201,7 @@ static int __init phonet_init(void)
 		return err;
 	}
=20
+	phonet_device_init();
 	dev_add_pack(&phonet_packet_type);
 	return 0;
 }
@@ -208,6 +210,7 @@ static void __exit phonet_exit(void)
 {
 	sock_unregister(AF_PHONET);
 	dev_remove_pack(&phonet_packet_type);
+	phonet_device_exit();
 }
=20
 module_init(phonet_init);
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
new file mode 100644
index 0000000..53be9fc
--- /dev/null
+++ b/net/phonet/pn_dev.c
@@ -0,0 +1,208 @@
+/*
+ * File: pn_dev.c
+ *
+ * Phonet network device
+ *
+ * Copyright (C) 2008 Nokia Corporation.
+ *
+ * Contact: Remi Denis-Courmont <remi.denis-courmont@nokia.com>
+ * Original author: Sakari Ailus <sakari.ailus@nokia.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * version 2 as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
+ * 02110-1301 USA
+ */
+
+#include <linux/kernel.h>
+#include <linux/net.h>
+#include <linux/netdevice.h>
+#include <linux/phonet.h>
+#include <net/sock.h>
+#include <net/phonet/pn_dev.h>
+
+/* when accessing, remember to lock with spin_lock(&pndevs.lock); */
+struct phonet_device_list pndevs =3D {
+	.list =3D LIST_HEAD_INIT(pndevs.list),
+	.lock =3D __SPIN_LOCK_UNLOCKED(pndevs.lock),
+};
+
+/* Allocate new Phonet device. */
+static struct phonet_device *__phonet_device_alloc(struct net_device *=
dev)
+{
+	struct phonet_device *pnd =3D kmalloc(sizeof(*pnd), GFP_ATOMIC);
+	if (pnd =3D=3D NULL)
+		return NULL;
+	pnd->netdev =3D dev;
+	bitmap_zero(pnd->addrs, 64);
+
+	list_add(&pnd->list, &pndevs.list);
+	return pnd;
+}
+
+static struct phonet_device *__phonet_get(struct net_device *dev)
+{
+	struct phonet_device *pnd;
+
+	list_for_each_entry(pnd, &pndevs.list, list) {
+		if (pnd->netdev =3D=3D dev)
+			return pnd;
+	}
+	return NULL;
+}
+
+static void __phonet_device_free(struct phonet_device *pnd)
+{
+	list_del(&pnd->list);
+	kfree(pnd);
+}
+
+struct net_device *phonet_device_get(struct net *net)
+{
+	struct phonet_device *pnd;
+	struct net_device *dev;
+
+	spin_lock_bh(&pndevs.lock);
+	list_for_each_entry(pnd, &pndevs.list, list) {
+		dev =3D pnd->netdev;
+		BUG_ON(!dev);
+
+		if (dev_net(dev) =3D=3D net &&
+			(dev->reg_state =3D=3D NETREG_REGISTERED) &&
+			((pnd->netdev->flags & IFF_UP)) =3D=3D IFF_UP)
+			break;
+		dev =3D NULL;
+	}
+	if (dev)
+		dev_hold(dev);
+	spin_unlock_bh(&pndevs.lock);
+	return dev;
+}
+
+int phonet_address_add(struct net_device *dev, u8 addr)
+{
+	struct phonet_device *pnd;
+	int err =3D 0;
+
+	spin_lock_bh(&pndevs.lock);
+	/* Find or create Phonet-specific device data */
+	pnd =3D __phonet_get(dev);
+	if (pnd =3D=3D NULL)
+		pnd =3D __phonet_device_alloc(dev);
+	if (unlikely(pnd =3D=3D NULL))
+		err =3D -ENOMEM;
+	else if (test_and_set_bit(addr >> 2, pnd->addrs))
+		err =3D -EEXIST;
+	spin_unlock_bh(&pndevs.lock);
+	return err;
+}
+
+int phonet_address_del(struct net_device *dev, u8 addr)
+{
+	struct phonet_device *pnd;
+	int err =3D 0;
+
+	spin_lock_bh(&pndevs.lock);
+	pnd =3D __phonet_get(dev);
+	if (!pnd || !test_and_clear_bit(addr >> 2, pnd->addrs))
+		err =3D -EADDRNOTAVAIL;
+	if (bitmap_empty(pnd->addrs, 64))
+		__phonet_device_free(pnd);
+	spin_unlock_bh(&pndevs.lock);
+	return err;
+}
+
+/* Gets a source address toward a destination, through a interface. */
+u8 phonet_address_get(struct net_device *dev, u8 addr)
+{
+	struct phonet_device *pnd;
+
+	spin_lock_bh(&pndevs.lock);
+	pnd =3D __phonet_get(dev);
+	if (pnd) {
+		BUG_ON(bitmap_empty(pnd->addrs, 64));
+
+		/* Use same source address as destination, if possible */
+		if (!test_bit(addr >> 2, pnd->addrs))
+			addr =3D find_first_bit(pnd->addrs, 64) << 2;
+	} else
+		addr =3D PN_NO_ADDR;
+	spin_unlock_bh(&pndevs.lock);
+	return addr;
+}
+
+int phonet_address_lookup(u8 addr)
+{
+	struct phonet_device *pnd;
+
+	spin_lock_bh(&pndevs.lock);
+	list_for_each_entry(pnd, &pndevs.list, list) {
+		/* Don't allow unregistering devices! */
+		if ((pnd->netdev->reg_state !=3D NETREG_REGISTERED) ||
+				((pnd->netdev->flags & IFF_UP)) !=3D IFF_UP)
+			continue;
+
+		if (test_bit(addr >> 2, pnd->addrs)) {
+			spin_unlock_bh(&pndevs.lock);
+			return 0;
+		}
+	}
+	spin_unlock_bh(&pndevs.lock);
+	return -EADDRNOTAVAIL;
+}
+
+/* notify Phonet of device events */
+static int phonet_device_notify(struct notifier_block *me, unsigned lo=
ng what,
+				void *arg)
+{
+	struct net_device *dev =3D arg;
+
+	if (what =3D=3D NETDEV_UNREGISTER) {
+		struct phonet_device *pnd;
+
+		/* Destroy phonet-specific device data */
+		spin_lock_bh(&pndevs.lock);
+		pnd =3D __phonet_get(dev);
+		if (pnd)
+			__phonet_device_free(pnd);
+		spin_unlock_bh(&pndevs.lock);
+	}
+	return 0;
+
+}
+
+static struct notifier_block phonet_device_notifier =3D {
+	.notifier_call =3D phonet_device_notify,
+	.priority =3D 0,
+};
+
+/* Initialize Phonet devices list */
+void phonet_device_init(void)
+{
+	register_netdevice_notifier(&phonet_device_notifier);
+}
+
+void phonet_device_exit(void)
+{
+	struct phonet_device *pnd, *n;
+
+	rtnl_unregister_all(PF_PHONET);
+	rtnl_lock();
+	spin_lock_bh(&pndevs.lock);
+
+	list_for_each_entry_safe(pnd, n, &pndevs.list, list)
+		__phonet_device_free(pnd);
+
+	spin_unlock_bh(&pndevs.lock);
+	rtnl_unlock();
+	unregister_netdevice_notifier(&phonet_device_notifier);
+}
--=20
1.5.4.3

