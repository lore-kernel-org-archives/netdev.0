From: =?utf-8?q?R=C3=A9mi=20Denis-Courmont?=
	<remi.denis-courmont@nokia.com>
Subject: [PATCH 05/14] Phonet: network device and address handling
Date: Tue, 16 Sep 2008 18:08:05 +0300
Message-ID: <1221577694-4513-5-git-send-email-remi.denis-courmont@nokia.com>
References: <200809161757.38571.remi.denis-courmont@nokia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.nokia.com ([192.100.122.230]:52811 "EHLO
	mgw-mx03.nokia.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752721AbYIPPI0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2008 11:08:26 -0400
Received: from esebh105.NOE.Nokia.com (esebh105.ntc.nokia.com [172.21.138.211])
	by mgw-mx03.nokia.com (Switch-3.2.6/Switch-3.2.6) with ESMTP id m8GF8AVq031651
	for <netdev@vger.kernel.org>; Tue, 16 Sep 2008 18:08:23 +0300
In-Reply-To: <200809161757.38571.remi.denis-courmont@nokia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This provides support for adding Phonet addresses to and removing
Phonet addresses from network devices.

Signed-off-by: R=C3=A9mi Denis-Courmont <remi.denis-courmont@nokia.com>
---
 include/net/phonet/pn_dev.h |   63 ++++++++++++
 net/phonet/Makefile         |    1 +
 net/phonet/af_phonet.c      |   12 ++
 net/phonet/pn_dev.c         |  233 +++++++++++++++++++++++++++++++++++=
++++++++
 4 files changed, 309 insertions(+), 0 deletions(-)
 create mode 100644 include/net/phonet/pn_dev.h
 create mode 100644 net/phonet/pn_dev.c

diff --git a/include/net/phonet/pn_dev.h b/include/net/phonet/pn_dev.h
new file mode 100644
index 0000000..c53d364
--- /dev/null
+++ b/include/net/phonet/pn_dev.h
@@ -0,0 +1,63 @@
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
+	struct list_head own;
+};
+
+struct phonet_address {
+	struct list_head list;
+	struct phonet_device *pnd;
+	uint8_t addr;
+	unsigned char prefix;
+};
+
+int phonet_device_init(void);
+void phonet_device_exit(void);
+struct phonet_device *phonet_device_alloc(struct net_device *dev);
+struct phonet_device *__phonet_get_by_index(unsigned ifindex);
+void phonet_device_free(struct phonet_device *pnd);
+
+struct phonet_address *phonet_address_alloc(void);
+void phonet_address_add(struct list_head *list, struct phonet_address =
*pna);
+void phonet_address_free(struct phonet_address *pna);
+struct phonet_address *phonet_addr2addr(uint8_t addr, int mode);
+struct phonet_address *phonet_dev2addr(struct phonet_device *pnd, uint=
8_t addr,
+					int mode);
+
+#define PN_FIND_EXACT	(1 << 0)
+
+#define MKMASK(a)	((1 << (a)) - 1)
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
index ed66a81..744b47f 100644
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
@@ -202,14 +203,25 @@ static int __init phonet_init(void)
 		return err;
 	}
=20
+	err =3D phonet_device_init();
+	if (err) {
+		printk(KERN_ALERT "phonet devices initialization failed\n");
+		goto unregister;
+	}
+
 	dev_add_pack(&phonet_packet_type);
 	return 0;
+
+unregister:
+	sock_unregister(AF_PHONET);
+	return err;
 }
=20
 static void __exit phonet_exit(void)
 {
 	sock_unregister(AF_PHONET);
 	dev_remove_pack(&phonet_packet_type);
+	phonet_device_exit();
 }
=20
 module_init(phonet_init);
diff --git a/net/phonet/pn_dev.c b/net/phonet/pn_dev.c
new file mode 100644
index 0000000..cae37a6
--- /dev/null
+++ b/net/phonet/pn_dev.c
@@ -0,0 +1,233 @@
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
+static int phonet_device_notify(struct notifier_block *self, unsigned =
long what,
+				void *dev);
+
+/* when accessing, remember to lock with spin_lock(&pndevs.lock); */
+struct phonet_device_list pndevs;
+
+static struct notifier_block phonet_device_notifier =3D {
+	.notifier_call =3D &phonet_device_notify,
+	.priority =3D 0,
+};
+
+/* initialise Phonet device list */
+int phonet_device_init(void)
+{
+	INIT_LIST_HEAD(&pndevs.list);
+	spin_lock_init(&pndevs.lock);
+	register_netdevice_notifier(&phonet_device_notifier);
+
+	return 0;
+}
+
+void phonet_device_exit(void)
+{
+	struct list_head *ptr;
+
+	rtnl_unregister_all(PF_PHONET);
+	rtnl_lock();
+	spin_lock_bh(&pndevs.lock);
+
+	for (ptr =3D pndevs.list.next; ptr !=3D &pndevs.list;
+		ptr =3D pndevs.list.next) {
+		struct phonet_device *pnd =3D list_entry(ptr,
+						struct phonet_device, list);
+		phonet_device_free(pnd);
+	}
+
+	spin_unlock_bh(&pndevs.lock);
+	rtnl_unlock();
+	unregister_netdevice_notifier(&phonet_device_notifier);
+}
+
+struct phonet_address *phonet_address_alloc(void)
+{
+	struct phonet_address *pna;
+
+	pna =3D kmalloc(sizeof(struct phonet_address), GFP_KERNEL);
+
+	if (pna =3D=3D NULL)
+		return NULL;
+
+	INIT_LIST_HEAD(&pna->list);
+
+	return pna;
+}
+
+/* add Phonet address to list */
+void phonet_address_add(struct list_head *list, struct phonet_address =
*pna)
+{
+	list_add(&pna->list, list);
+}
+
+/* remove Phonet address from list and free it */
+void phonet_address_free(struct phonet_address *pna)
+{
+	list_del(&pna->list);
+	kfree(pna);
+}
+
+/* Allocate new Phonet device. */
+struct phonet_device *phonet_device_alloc(struct net_device *dev)
+{
+	struct phonet_device *pnd;
+
+	pnd =3D kmalloc(sizeof(struct phonet_device), GFP_ATOMIC);
+
+	if (pnd =3D=3D NULL)
+		return NULL;
+
+	INIT_LIST_HEAD(&pnd->own);
+	pnd->netdev =3D dev;
+	list_add(&pnd->list, &pndevs.list);
+	return pnd;
+}
+
+struct phonet_device *__phonet_get_by_index(unsigned ifindex)
+{
+	struct list_head *p;
+
+	list_for_each(p, &pndevs.list) {
+		struct phonet_device *pnd;
+
+		pnd =3D list_entry(p, struct phonet_device, list);
+		BUG_ON(!pnd->netdev);
+
+		if (pnd->netdev->ifindex =3D=3D ifindex)
+			return pnd;
+	}
+	return NULL;
+}
+
+void phonet_device_free(struct phonet_device *pnd)
+{
+	struct list_head *ptr;
+
+	/* remove device from list */
+	list_del(&pnd->list);
+
+	for (ptr =3D pnd->own.next; ptr !=3D &pnd->own; ptr =3D pnd->own.next=
) {
+		struct phonet_address *pna =3D
+			list_entry(ptr, struct phonet_address, list);
+		phonet_address_free(pna);
+	}
+
+	kfree(pnd);
+}
+
+/*
+ * Find the address from the device's address list having the given ad=
dress
+ */
+struct phonet_address *phonet_dev2addr(struct phonet_device *pnd,
+					uint8_t addr, int mode)
+{
+	struct list_head *list =3D &pnd->own, *ptr;
+	struct phonet_address *best =3D NULL;
+
+	for (ptr =3D list->next; ptr !=3D list; ptr =3D ptr->next) {
+		struct phonet_address *pna =3D
+			list_entry(ptr, struct phonet_address, list);
+
+		if (mode & PN_FIND_EXACT) {
+			/* try to find exact address */
+			if (pna->addr =3D=3D addr) {
+				best =3D pna;
+				break;
+			}
+		} else if (best =3D=3D NULL ||
+			   best->prefix < pna->prefix) {
+			if ((pna->addr & MKMASK(pna->prefix)) =3D=3D
+					(addr & MKMASK(pna->prefix))) {
+				best =3D pna;
+			}
+		}
+	}
+
+	return best;
+}
+
+/*
+ * Find the device having a given address (remember locking!!)
+ */
+struct phonet_address *phonet_addr2addr(uint8_t addr, int mode)
+{
+	struct list_head *ptr;
+	struct phonet_address *best =3D NULL;
+
+	for (ptr =3D pndevs.list.next; ptr !=3D &pndevs.list; ptr =3D ptr->ne=
xt) {
+		struct phonet_address *pna =3D NULL;
+		struct phonet_device *pnd =3D
+		    list_entry(ptr, struct phonet_device, list);
+
+		/* Don't allow unregistering devices! */
+		if ((pnd->netdev->reg_state !=3D NETREG_REGISTERED) ||
+			((pnd->netdev->flags & IFF_UP)) !=3D IFF_UP)
+			continue;
+
+		pna =3D phonet_dev2addr(pnd, addr, mode);
+
+		if (pna !=3D NULL) {
+			if (best =3D=3D NULL || best->prefix < pna->prefix)
+				best =3D pna;
+		}
+	}
+
+	return best;
+}
+
+/* notify Phonet of device events */
+static int phonet_device_notify(struct notifier_block *self, unsigned =
long what,
+				void *_dev)
+{
+	struct net_device *dev =3D _dev;
+	struct phonet_device *pnd;
+
+	spin_lock_bh(&pndevs.lock);
+	pnd =3D __phonet_get_by_index(dev->ifindex);
+
+	switch (what) {
+	case NETDEV_UNREGISTER:
+		if (pnd =3D=3D NULL)
+			break;
+		phonet_device_free(pnd);
+		break;
+	default:
+		break;
+	}
+
+	spin_unlock_bh(&pndevs.lock);
+
+	return 0;
+
+}
--=20
1.5.4.3

