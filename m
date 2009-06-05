From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 2/5] net: add IEEE 802.15.4 socket family implementation
Date: Fri,  5 Jun 2009 06:29:47 +0400
Message-ID: <1244168990-28355-3-git-send-email-dbaryshkov@gmail.com>
References: <1244168990-28355-1-git-send-email-dbaryshkov@gmail.com>
 <1244168990-28355-2-git-send-email-dbaryshkov@gmail.com>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org,
	Stephen Rothwell <sfr-3FnU+UHB4dNDw9hX6IcOSA@public.gmane.org>,
	Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1244168990-28355-2-git-send-email-dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Add support for communication over IEEE 802.15.4 networks. This implementation
is neither certified nor complete, but aims to that goal. This commit contains
only the socket interface for communication over IEEE 802.15.4 networks.
One can either send RAW datagrams or use SOCK_DGRAM to encapsulate data
inside normal IEEE 802.15.4 packets.

Configuration interface, drivers and software MAC 802.15.4 implementation will
follow.

Initial implementation was done by Maxim Gorbachyov, Maxim Osipov and Pavel
Smolensky as a research project at Siemens AG. Later the stack was heavily
reworked to better suit the linux networking model, and is now maitained
as an open project partially sponsored by Siemens.

Signed-off-by: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Signed-off-by: Sergey Lapin <slapin-9cOl001CZnBAfugRpC6u6w@public.gmane.org>
---
 include/net/ieee802154/af_ieee802154.h |   60 +++++
 include/net/ieee802154/mac_def.h       |  160 +++++++++++++
 include/net/ieee802154/netdevice.h     |  115 +++++++++
 net/Kconfig                            |    1 +
 net/Makefile                           |    1 +
 net/ieee802154/Kconfig                 |   12 +
 net/ieee802154/Makefile                |    4 +
 net/ieee802154/af802154.h              |   36 +++
 net/ieee802154/af_ieee802154.c         |  372 ++++++++++++++++++++++++++++++
 net/ieee802154/dgram.c                 |  394 ++++++++++++++++++++++++++++++++
 net/ieee802154/raw.c                   |  254 ++++++++++++++++++++
 11 files changed, 1409 insertions(+), 0 deletions(-)
 create mode 100644 include/net/ieee802154/af_ieee802154.h
 create mode 100644 include/net/ieee802154/mac_def.h
 create mode 100644 include/net/ieee802154/netdevice.h
 create mode 100644 net/ieee802154/Kconfig
 create mode 100644 net/ieee802154/Makefile
 create mode 100644 net/ieee802154/af802154.h
 create mode 100644 net/ieee802154/af_ieee802154.c
 create mode 100644 net/ieee802154/dgram.c
 create mode 100644 net/ieee802154/raw.c

diff --git a/include/net/ieee802154/af_ieee802154.h b/include/net/ieee802154/af_ieee802154.h
new file mode 100644
index 0000000..874f1e7
--- /dev/null
+++ b/include/net/ieee802154/af_ieee802154.h
@@ -0,0 +1,60 @@
+/*
+ * IEEE 802.15.4 inteface for userspace
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#ifndef _AF_IEEE802154_H
+#define _AF_IEEE802154_H
+
+#include <linux/socket.h> /* for sa_family_t */
+
+enum {
+	IEEE802154_ADDR_NONE = 0x0,
+	/* RESERVED = 0x01, */
+	IEEE802154_ADDR_SHORT = 0x2, /* 16-bit address + PANid */
+	IEEE802154_ADDR_LONG = 0x3, /* 64-bit address + PANid */
+};
+
+/* address length, octets */
+#define IEEE802154_ADDR_LEN	8
+
+struct ieee802154_addr {
+	int addr_type;
+	u16 pan_id;
+	union {
+		u8 hwaddr[IEEE802154_ADDR_LEN];
+		u16 short_addr;
+	};
+};
+
+#define IEEE802154_PANID_BROADCAST	0xffff
+#define IEEE802154_ADDR_BROADCAST	0xffff
+#define IEEE802154_ADDR_UNDEF		0xfffe
+
+struct sockaddr_ieee802154 {
+	sa_family_t family; /* AF_IEEE802154 */
+	struct ieee802154_addr addr;
+};
+
+/* master device */
+#define IEEE802154_SIOC_ADD_SLAVE		(SIOCDEVPRIVATE + 0)
+
+#endif
diff --git a/include/net/ieee802154/mac_def.h b/include/net/ieee802154/mac_def.h
new file mode 100644
index 0000000..8cb6846
--- /dev/null
+++ b/include/net/ieee802154/mac_def.h
@@ -0,0 +1,160 @@
+/*
+ * IEEE802.15.4-2003 specification
+ *
+ * Copyright (C) 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Pavel Smolenskiy <pavel.smolenskiy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ * Maxim Gorbachyov <maxim.gorbachev-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Maxim Osipov <maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#ifndef IEEE802154_MAC_DEF_H
+#define IEEE802154_MAC_DEF_H
+
+#define IEEE802154_FC_TYPE_BEACON	0x0	/* Frame is beacon */
+#define	IEEE802154_FC_TYPE_DATA		0x1	/* Frame is data */
+#define IEEE802154_FC_TYPE_ACK		0x2	/* Frame is acknowledgment */
+#define IEEE802154_FC_TYPE_MAC_CMD	0x3	/* Frame is MAC command */
+
+#define IEEE802154_FC_TYPE_SHIFT		0
+#define IEEE802154_FC_TYPE_MASK		((1 << 3) - 1)
+#define IEEE802154_FC_TYPE(x)		((x & IEEE802154_FC_TYPE_MASK) >> IEEE802154_FC_TYPE_SHIFT)
+#define IEEE802154_FC_SET_TYPE(v, x)	do {	\
+	v = (((v) & ~IEEE802154_FC_TYPE_MASK) | \
+	    (((x) << IEEE802154_FC_TYPE_SHIFT) & IEEE802154_FC_TYPE_MASK)); \
+	} while (0)
+
+#define IEEE802154_FC_SECEN		(1 << 3)
+#define IEEE802154_FC_FRPEND		(1 << 4)
+#define IEEE802154_FC_ACK_REQ		(1 << 5)
+#define IEEE802154_FC_INTRA_PAN		(1 << 6)
+
+#define IEEE802154_FC_SAMODE_SHIFT	14
+#define IEEE802154_FC_SAMODE_MASK	(3 << IEEE802154_FC_SAMODE_SHIFT)
+#define IEEE802154_FC_DAMODE_SHIFT	10
+#define IEEE802154_FC_DAMODE_MASK	(3 << IEEE802154_FC_DAMODE_SHIFT)
+
+#define IEEE802154_FC_SAMODE(x)		\
+	(((x) & IEEE802154_FC_SAMODE_MASK) >> IEEE802154_FC_SAMODE_SHIFT)
+
+#define IEEE802154_FC_DAMODE(x)		\
+	(((x) & IEEE802154_FC_DAMODE_MASK) >> IEEE802154_FC_DAMODE_SHIFT)
+
+
+/* MAC's Command Frames Identifiers */
+#define IEEE802154_CMD_ASSOCIATION_REQ		0x01
+#define IEEE802154_CMD_ASSOCIATION_RESP		0x02
+#define IEEE802154_CMD_DISASSOCIATION_NOTIFY	0x03
+#define IEEE802154_CMD_DATA_REQ			0x04
+#define IEEE802154_CMD_PANID_CONFLICT_NOTIFY	0x05
+#define IEEE802154_CMD_ORPHAN_NOTIFY		0x06
+#define IEEE802154_CMD_BEACON_REQ		0x07
+#define IEEE802154_CMD_COORD_REALIGN_NOTIFY	0x08
+#define IEEE802154_CMD_GTS_REQ			0x09
+
+/*
+ * The return values of MAC operations
+ */
+enum {
+	/*
+	 * The requested operation was completed successfully.
+	 * For a transmission request, this value indicates
+	 * a successful transmission.
+	 */
+	IEEE802154_SUCCESS = 0x0,
+
+	/* The beacon was lost following a synchronization request. */
+	IEEE802154_BEACON_LOSS = 0xe0,
+	/*
+	 * A transmission could not take place due to activity on the
+	 * channel, i.e., the CSMA-CA mechanism has failed.
+	 */
+	IEEE802154_CHNL_ACCESS_FAIL = 0xe1,
+	/* The GTS request has been denied by the PAN coordinator. */
+	IEEE802154_DENINED = 0xe2,
+	/* The attempt to disable the transceiver has failed. */
+	IEEE802154_DISABLE_TRX_FAIL = 0xe3,
+	/*
+	 * The received frame induces a failed security check according to
+	 * the security suite.
+	 */
+	IEEE802154_FAILED_SECURITY_CHECK = 0xe4,
+	/*
+	 * The frame resulting from secure processing has a length that is
+	 * greater than aMACMaxFrameSize.
+	 */
+	IEEE802154_FRAME_TOO_LONG = 0xe5,
+	/*
+	 * The requested GTS transmission failed because the specified GTS
+	 * either did not have a transmit GTS direction or was not defined.
+	 */
+	IEEE802154_INVALID_GTS = 0xe6,
+	/*
+	 * A request to purge an MSDU from the transaction queue was made using
+	 * an MSDU handle that was not found in the transaction table.
+	 */
+	IEEE802154_INVALID_HANDLE = 0xe7,
+	/* A parameter in the primitive is out of the valid range.*/
+	IEEE802154_INVALID_PARAMETER = 0xe8,
+	/* No acknowledgment was received after aMaxFrameRetries. */
+	IEEE802154_NO_ACK = 0xe9,
+	/* A scan operation failed to find any network beacons.*/
+	IEEE802154_NO_BEACON = 0xea,
+	/* No response data were available following a request. */
+	IEEE802154_NO_DATA = 0xeb,
+	/* The operation failed because a short address was not allocated. */
+	IEEE802154_NO_SHORT_ADDRESS = 0xec,
+	/*
+	 * A receiver enable request was unsuccessful because it could not be
+	 * completed within the CAP.
+	 */
+	IEEE802154_OUT_OF_CAP = 0xed,
+	/*
+	 * A PAN identifier conflict has been detected and communicated to the
+	 * PAN coordinator.
+	 */
+	IEEE802154_PANID_CONFLICT = 0xee,
+	/* A coordinator realignment command has been received. */
+	IEEE802154_REALIGMENT = 0xef,
+	/* The transaction has expired and its information discarded. */
+	IEEE802154_TRANSACTION_EXPIRED = 0xf0,
+	/* There is no capacity to store the transaction. */
+	IEEE802154_TRANSACTION_OVERFLOW = 0xf1,
+	/*
+	 * The transceiver was in the transmitter enabled state when the
+	 * receiver was requested to be enabled.
+	 */
+	IEEE802154_TX_ACTIVE = 0xf2,
+	/* The appropriate key is not available in the ACL. */
+	IEEE802154_UNAVAILABLE_KEY = 0xf3,
+	/*
+	 * A SET/GET request was issued with the identifier of a PIB attribute
+	 * that is not supported.
+	 */
+	IEEE802154_UNSUPPORTED_ATTR = 0xf4,
+	/*
+	 * A request to perform a scan operation failed because the MLME was
+	 * in the process of performing a previously initiated scan operation.
+	 */
+	IEEE802154_SCAN_IN_PROGRESS = 0xfc,
+};
+
+
+#endif
+
+
diff --git a/include/net/ieee802154/netdevice.h b/include/net/ieee802154/netdevice.h
new file mode 100644
index 0000000..e2506af
--- /dev/null
+++ b/include/net/ieee802154/netdevice.h
@@ -0,0 +1,115 @@
+/*
+ * An interface between IEEE802.15.4 device and rest of the kernel.
+ *
+ * Copyright (C) 2007, 2008, 2009 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Pavel Smolenskiy <pavel.smolenskiy-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ * Maxim Gorbachyov <maxim.gorbachev-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Maxim Osipov <maxim.osipov-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#ifndef IEEE802154_NETDEVICE_H
+#define IEEE802154_NETDEVICE_H
+
+/*
+ * A control block of skb passed between the ARPHRD_IEEE802154 device
+ * and other stack parts.
+ */
+struct ieee802154_mac_cb {
+	u8 lqi;
+	struct ieee802154_addr sa;
+	struct ieee802154_addr da;
+	u8 flags;
+	u8 seq;
+};
+
+static inline struct ieee802154_mac_cb *mac_cb(struct sk_buff *skb)
+{
+	return (struct ieee802154_mac_cb *)skb->cb;
+}
+
+#define MAC_CB_FLAG_TYPEMASK		((1 << 3) - 1)
+
+#define MAC_CB_FLAG_ACKREQ		(1 << 3)
+#define MAC_CB_FLAG_SECEN		(1 << 4)
+#define MAC_CB_FLAG_INTRAPAN		(1 << 5)
+
+static inline int mac_cb_is_ackreq(struct sk_buff *skb)
+{
+	return mac_cb(skb)->flags & MAC_CB_FLAG_ACKREQ;
+}
+
+static inline int mac_cb_is_secen(struct sk_buff *skb)
+{
+	return mac_cb(skb)->flags & MAC_CB_FLAG_SECEN;
+}
+
+static inline int mac_cb_is_intrapan(struct sk_buff *skb)
+{
+	return mac_cb(skb)->flags & MAC_CB_FLAG_INTRAPAN;
+}
+
+static inline int mac_cb_type(struct sk_buff *skb)
+{
+	return mac_cb(skb)->flags & MAC_CB_FLAG_TYPEMASK;
+}
+
+#define IEEE802154_MAC_SCAN_ED		0
+#define IEEE802154_MAC_SCAN_ACTIVE	1
+#define IEEE802154_MAC_SCAN_PASSIVE	2
+#define IEEE802154_MAC_SCAN_ORPHAN	3
+
+/*
+ * This should be located at net_device->ml_priv
+ */
+struct ieee802154_mlme_ops {
+	int (*assoc_req)(struct net_device *dev,
+			struct ieee802154_addr *addr,
+			u8 channel, u8 cap);
+	int (*assoc_resp)(struct net_device *dev,
+			struct ieee802154_addr *addr,
+			u16 short_addr, u8 status);
+	int (*disassoc_req)(struct net_device *dev,
+			struct ieee802154_addr *addr,
+			u8 reason);
+	int (*start_req)(struct net_device *dev,
+			struct ieee802154_addr *addr,
+			u8 channel, u8 bcn_ord, u8 sf_ord,
+			u8 pan_coord, u8 blx, u8 coord_realign);
+	int (*scan_req)(struct net_device *dev,
+			u8 type, u32 channels, u8 duration);
+
+	/*
+	 * FIXME: these should become the part of PIB/MIB interface.
+	 * However we still don't have IB interface of any kind
+	 */
+	u16 (*get_pan_id)(struct net_device *dev);
+	u16 (*get_short_addr)(struct net_device *dev);
+	u8 (*get_dsn)(struct net_device *dev);
+	u8 (*get_bsn)(struct net_device *dev);
+};
+
+static inline struct ieee802154_mlme_ops *ieee802154_mlme_ops(
+		struct net_device *dev)
+{
+	return dev->ml_priv;
+}
+
+#endif
+
+
diff --git a/net/Kconfig b/net/Kconfig
index c19f549..7051b97 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -179,6 +179,7 @@ source "net/lapb/Kconfig"
 source "net/econet/Kconfig"
 source "net/wanrouter/Kconfig"
 source "net/phonet/Kconfig"
+source "net/ieee802154/Kconfig"
 source "net/sched/Kconfig"
 source "net/dcb/Kconfig"
 
diff --git a/net/Makefile b/net/Makefile
index 9e00a55..ba324ae 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -60,6 +60,7 @@ obj-$(CONFIG_NET_9P)		+= 9p/
 ifneq ($(CONFIG_DCB),)
 obj-y				+= dcb/
 endif
+obj-y				+= ieee802154/
 
 ifeq ($(CONFIG_NET),y)
 obj-$(CONFIG_SYSCTL)		+= sysctl_net.o
diff --git a/net/ieee802154/Kconfig b/net/ieee802154/Kconfig
new file mode 100644
index 0000000..1c1de97
--- /dev/null
+++ b/net/ieee802154/Kconfig
@@ -0,0 +1,12 @@
+config IEEE802154
+	tristate "IEEE Std 802.15.4 Low-Rate Wireless Personal Area Networks support (EXPERIMENTAL)"
+	depends on EXPERIMENTAL
+	---help---
+	  IEEE Std 802.15.4 defines a low data rate, low power and low
+	  complexity short range wireless personal area networks. It was
+	  designed to organise networks of sensors, switches, etc automation
+	  devices. Maximum allowed data rate is 250 kb/s and typical personal
+	  operating space around 10m.
+
+	  Say Y here to compile LR-WPAN support into the kernel or say M to
+	  compile it as modules.
diff --git a/net/ieee802154/Makefile b/net/ieee802154/Makefile
new file mode 100644
index 0000000..cb88054
--- /dev/null
+++ b/net/ieee802154/Makefile
@@ -0,0 +1,4 @@
+obj-$(CONFIG_IEEE802154) +=	af_802154.o
+af_802154-objs		:= af_ieee802154.o raw.o dgram.o
+
+EXTRA_CFLAGS += -Wall -DDEBUG
diff --git a/net/ieee802154/af802154.h b/net/ieee802154/af802154.h
new file mode 100644
index 0000000..0ee663d
--- /dev/null
+++ b/net/ieee802154/af802154.h
@@ -0,0 +1,36 @@
+/*
+ * Internal interfaces for ieee 802.15.4 address family.
+ *
+ * Copyright 2007, 2008, 2009 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#ifndef AF802154_H
+#define AF802154_H
+
+struct sk_buff;
+struct net_devce;
+extern struct proto ieee802154_raw_prot;
+extern struct proto ieee802154_dgram_prot;
+void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb);
+int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb);
+struct net_device *ieee802154_get_dev(struct net *net,
+		struct ieee802154_addr *addr);
+
+#endif
diff --git a/net/ieee802154/af_ieee802154.c b/net/ieee802154/af_ieee802154.c
new file mode 100644
index 0000000..e8ec83c
--- /dev/null
+++ b/net/ieee802154/af_ieee802154.c
@@ -0,0 +1,372 @@
+/*
+ * IEEE802154.4 socket interface
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Maxim Gorbachyov <maxim.gorbachev-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ */
+
+#include <linux/net.h>
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/if.h>
+#include <linux/termios.h>	/* For TIOCOUTQ/INQ */
+#include <linux/list.h>
+#include <net/datalink.h>
+#include <net/psnap.h>
+#include <net/sock.h>
+#include <net/tcp_states.h>
+#include <net/route.h>
+
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/netdevice.h>
+
+#include "af802154.h"
+
+#define DBG_DUMP(data, len) { \
+	int i; \
+	pr_debug("function: %s: data: len %d:\n", __func__, len); \
+	for (i = 0; i < len; i++) {\
+		pr_debug("%02x: %02x\n", i, (data)[i]); \
+	} \
+}
+
+/*
+ * Utility function for families
+ */
+struct net_device *ieee802154_get_dev(struct net *net,
+		struct ieee802154_addr *addr)
+{
+	struct net_device *dev = NULL;
+	struct net_device *tmp;
+	u16 pan_id, short_addr;
+
+	switch (addr->addr_type) {
+	case IEEE802154_ADDR_LONG:
+		rtnl_lock();
+		dev = dev_getbyhwaddr(net, ARPHRD_IEEE802154, addr->hwaddr);
+		if (dev)
+			dev_hold(dev);
+		rtnl_unlock();
+		break;
+	case IEEE802154_ADDR_SHORT:
+		if (addr->pan_id == 0xffff ||
+		    addr->short_addr == IEEE802154_ADDR_UNDEF ||
+		    addr->short_addr == 0xffff)
+			break;
+
+		rtnl_lock();
+
+		for_each_netdev(net, tmp) {
+			if (tmp->type != ARPHRD_IEEE802154)
+				continue;
+
+			pan_id = ieee802154_mlme_ops(tmp)->get_pan_id(tmp);
+			short_addr =
+				ieee802154_mlme_ops(tmp)->get_short_addr(tmp);
+
+			if (pan_id == addr->pan_id &&
+			    short_addr == addr->short_addr) {
+				dev = tmp;
+				dev_hold(dev);
+				break;
+			}
+		}
+
+		rtnl_unlock();
+		break;
+	default:
+		pr_warning("Unsupported ieee802154 address type: %d\n",
+				addr->addr_type);
+		break;
+	}
+
+	return dev;
+}
+
+static int ieee802154_sock_release(struct socket *sock)
+{
+	struct sock *sk = sock->sk;
+
+	if (sk) {
+		sock->sk = NULL;
+		sk->sk_prot->close(sk, 0);
+	}
+	return 0;
+}
+static int ieee802154_sock_sendmsg(struct kiocb *iocb, struct socket *sock,
+		struct msghdr *msg, size_t len)
+{
+	struct sock *sk = sock->sk;
+
+	return sk->sk_prot->sendmsg(iocb, sk, msg, len);
+}
+
+static int ieee802154_sock_bind(struct socket *sock, struct sockaddr *uaddr,
+		int addr_len)
+{
+	struct sock *sk = sock->sk;
+
+	if (sk->sk_prot->bind)
+		return sk->sk_prot->bind(sk, uaddr, addr_len);
+
+	return sock_no_bind(sock, uaddr, addr_len);
+}
+
+static int ieee802154_sock_connect(struct socket *sock, struct sockaddr *uaddr,
+			int addr_len, int flags)
+{
+	struct sock *sk = sock->sk;
+
+	if (uaddr->sa_family == AF_UNSPEC)
+		return sk->sk_prot->disconnect(sk, flags);
+
+	return sk->sk_prot->connect(sk, uaddr, addr_len);
+}
+
+static int ieee802154_dev_ioctl(struct sock *sk, struct ifreq __user *arg,
+		unsigned int cmd)
+{
+	struct ifreq ifr;
+	int ret = -EINVAL;
+	struct net_device *dev;
+
+	if (copy_from_user(&ifr, arg, sizeof(struct ifreq)))
+		return -EFAULT;
+
+	ifr.ifr_name[IFNAMSIZ-1] = 0;
+
+	dev_load(sock_net(sk), ifr.ifr_name);
+	dev = dev_get_by_name(sock_net(sk), ifr.ifr_name);
+	if (dev->type == ARPHRD_IEEE802154 ||
+	    dev->type == ARPHRD_IEEE802154_PHY)
+		ret = dev->netdev_ops->ndo_do_ioctl(dev, &ifr, cmd);
+
+	if (!ret && copy_to_user(arg, &ifr, sizeof(struct ifreq)))
+		ret = -EFAULT;
+	dev_put(dev);
+
+	return ret;
+}
+
+static int ieee802154_sock_ioctl(struct socket *sock, unsigned int cmd,
+		unsigned long arg)
+{
+	struct sock *sk = sock->sk;
+
+	switch (cmd) {
+	case SIOCGSTAMP:
+		return sock_get_timestamp(sk, (struct timeval __user *)arg);
+	case SIOCGSTAMPNS:
+		return sock_get_timestampns(sk, (struct timespec __user *)arg);
+	case SIOCGIFADDR:
+	case SIOCSIFADDR:
+		return ieee802154_dev_ioctl(sk, (struct ifreq __user *)arg,
+				cmd);
+	default:
+		if (!sk->sk_prot->ioctl)
+			return -ENOIOCTLCMD;
+		return sk->sk_prot->ioctl(sk, cmd, arg);
+	}
+}
+
+static const struct proto_ops ieee802154_raw_ops = {
+	.family		   = PF_IEEE802154,
+	.owner		   = THIS_MODULE,
+	.release	   = ieee802154_sock_release,
+	.bind		   = ieee802154_sock_bind,
+	.connect	   = ieee802154_sock_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = sock_no_accept,
+	.getname	   = sock_no_getname,
+	.poll		   = datagram_poll,
+	.ioctl		   = ieee802154_sock_ioctl,
+	.listen		   = sock_no_listen,
+	.shutdown	   = sock_no_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = ieee802154_sock_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
+#endif
+};
+
+static const struct proto_ops ieee802154_dgram_ops = {
+	.family		   = PF_IEEE802154,
+	.owner		   = THIS_MODULE,
+	.release	   = ieee802154_sock_release,
+	.bind		   = ieee802154_sock_bind,
+	.connect	   = ieee802154_sock_connect,
+	.socketpair	   = sock_no_socketpair,
+	.accept		   = sock_no_accept,
+	.getname	   = sock_no_getname,
+	.poll		   = datagram_poll,
+	.ioctl		   = ieee802154_sock_ioctl,
+	.listen		   = sock_no_listen,
+	.shutdown	   = sock_no_shutdown,
+	.setsockopt	   = sock_common_setsockopt,
+	.getsockopt	   = sock_common_getsockopt,
+	.sendmsg	   = ieee802154_sock_sendmsg,
+	.recvmsg	   = sock_common_recvmsg,
+	.mmap		   = sock_no_mmap,
+	.sendpage	   = sock_no_sendpage,
+#ifdef CONFIG_COMPAT
+	.compat_setsockopt = compat_sock_common_setsockopt,
+	.compat_getsockopt = compat_sock_common_getsockopt,
+#endif
+};
+
+
+/*
+ * Create a socket. Initialise the socket, blank the addresses
+ * set the state.
+ */
+static int ieee802154_create(struct net *net, struct socket *sock,
+		int protocol)
+{
+	struct sock *sk;
+	int rc;
+	struct proto *proto;
+	const struct proto_ops *ops;
+
+	if (net != &init_net)
+		return -EAFNOSUPPORT;
+
+	switch (sock->type) {
+	case SOCK_RAW:
+		proto = &ieee802154_raw_prot;
+		ops = &ieee802154_raw_ops;
+		break;
+	case SOCK_DGRAM:
+		proto = &ieee802154_dgram_prot;
+		ops = &ieee802154_dgram_ops;
+		break;
+	default:
+		rc = -ESOCKTNOSUPPORT;
+		goto out;
+	}
+
+	rc = -ENOMEM;
+	sk = sk_alloc(net, PF_IEEE802154, GFP_KERNEL, proto);
+	if (!sk)
+		goto out;
+	rc = 0;
+
+	sock->ops = ops;
+
+	sock_init_data(sock, sk);
+	/* FIXME: sk->sk_destruct */
+	sk->sk_family = PF_IEEE802154;
+
+	/* Checksums on by default */
+	sock_set_flag(sk, SOCK_ZAPPED);
+
+	if (sk->sk_prot->hash)
+		sk->sk_prot->hash(sk);
+
+	if (sk->sk_prot->init) {
+		rc = sk->sk_prot->init(sk);
+		if (rc)
+			sk_common_release(sk);
+	}
+out:
+	return rc;
+}
+
+static struct net_proto_family ieee802154_family_ops = {
+	.family		= PF_IEEE802154,
+	.create		= ieee802154_create,
+	.owner		= THIS_MODULE,
+};
+
+static int ieee802154_rcv(struct sk_buff *skb, struct net_device *dev,
+	struct packet_type *pt, struct net_device *orig_dev)
+{
+	DBG_DUMP(skb->data, skb->len);
+	if (!netif_running(dev))
+		return -ENODEV;
+	pr_debug("got frame, type %d, dev %p\n", dev->type, dev);
+
+	if (!net_eq(dev_net(dev), &init_net))
+		goto drop;
+
+	ieee802154_raw_deliver(dev, skb);
+
+	if (dev->type != ARPHRD_IEEE802154)
+		goto drop;
+
+	if (skb->pkt_type != PACKET_OTHERHOST)
+		return ieee802154_dgram_deliver(dev, skb);
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+
+static struct packet_type ieee802154_packet_type = {
+	.type = __constant_htons(ETH_P_IEEE802154),
+	.func = ieee802154_rcv,
+};
+
+static int __init af_ieee802154_init(void)
+{
+	int rc = -EINVAL;
+
+	rc = proto_register(&ieee802154_raw_prot, 1);
+	if (rc)
+		goto out;
+
+	rc = proto_register(&ieee802154_dgram_prot, 1);
+	if (rc)
+		goto err_dgram;
+
+	/* Tell SOCKET that we are alive */
+	rc = sock_register(&ieee802154_family_ops);
+	if (rc)
+		goto err_sock;
+	dev_add_pack(&ieee802154_packet_type);
+
+	rc = 0;
+	goto out;
+
+err_sock:
+	proto_unregister(&ieee802154_dgram_prot);
+err_dgram:
+	proto_unregister(&ieee802154_raw_prot);
+out:
+	return rc;
+}
+static void __exit af_ieee802154_remove(void)
+{
+	dev_remove_pack(&ieee802154_packet_type);
+	sock_unregister(PF_IEEE802154);
+	proto_unregister(&ieee802154_dgram_prot);
+	proto_unregister(&ieee802154_raw_prot);
+}
+
+module_init(af_ieee802154_init);
+module_exit(af_ieee802154_remove);
+
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_NETPROTO(PF_IEEE802154);
diff --git a/net/ieee802154/dgram.c b/net/ieee802154/dgram.c
new file mode 100644
index 0000000..0d1e7b2
--- /dev/null
+++ b/net/ieee802154/dgram.c
@@ -0,0 +1,394 @@
+/*
+ * ZigBee socket interface
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/net.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/list.h>
+#include <net/sock.h>
+#include <net/ieee802154/af_ieee802154.h>
+#include <net/ieee802154/mac_def.h>
+#include <net/ieee802154/netdevice.h>
+
+#include <asm/ioctls.h>
+
+#include "af802154.h"
+
+static HLIST_HEAD(dgram_head);
+static DEFINE_RWLOCK(dgram_lock);
+
+struct dgram_sock {
+	struct sock sk;
+
+	int bound;
+	struct ieee802154_addr src_addr;
+	struct ieee802154_addr dst_addr;
+};
+
+static inline struct dgram_sock *dgram_sk(const struct sock *sk)
+{
+	return container_of(sk, struct dgram_sock, sk);
+}
+
+
+static void dgram_hash(struct sock *sk)
+{
+	write_lock_bh(&dgram_lock);
+	sk_add_node(sk, &dgram_head);
+	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	write_unlock_bh(&dgram_lock);
+}
+
+static void dgram_unhash(struct sock *sk)
+{
+	write_lock_bh(&dgram_lock);
+	if (sk_del_node_init(sk))
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	write_unlock_bh(&dgram_lock);
+}
+
+static int dgram_init(struct sock *sk)
+{
+	struct dgram_sock *ro = dgram_sk(sk);
+
+	ro->dst_addr.addr_type = IEEE802154_ADDR_LONG;
+	ro->dst_addr.pan_id = 0xffff;
+	memset(&ro->dst_addr.hwaddr, 0xff, sizeof(ro->dst_addr.hwaddr));
+	return 0;
+}
+
+static void dgram_close(struct sock *sk, long timeout)
+{
+	sk_common_release(sk);
+}
+
+static int dgram_bind(struct sock *sk, struct sockaddr *uaddr, int len)
+{
+	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
+	struct dgram_sock *ro = dgram_sk(sk);
+	int err = 0;
+	struct net_device *dev;
+
+	ro->bound = 0;
+
+	if (len < sizeof(*addr))
+		return -EINVAL;
+
+	if (addr->family != AF_IEEE802154)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	dev = ieee802154_get_dev(sock_net(sk), &addr->addr);
+	if (!dev) {
+		err = -ENODEV;
+		goto out;
+	}
+
+	if (dev->type != ARPHRD_IEEE802154) {
+		err = -ENODEV;
+		goto out_put;
+	}
+
+	memcpy(&ro->src_addr, &addr->addr, sizeof(struct ieee802154_addr));
+
+	ro->bound = 1;
+out_put:
+	dev_put(dev);
+out:
+	release_sock(sk);
+
+	return err;
+}
+
+static int dgram_ioctl(struct sock *sk, int cmd, unsigned long arg)
+{
+	switch (cmd) {
+	case SIOCOUTQ:
+	{
+		int amount = atomic_read(&sk->sk_wmem_alloc);
+		return put_user(amount, (int __user *)arg);
+	}
+
+	case SIOCINQ:
+	{
+		struct sk_buff *skb;
+		unsigned long amount;
+
+		amount = 0;
+		spin_lock_bh(&sk->sk_receive_queue.lock);
+		skb = skb_peek(&sk->sk_receive_queue);
+		if (skb != NULL) {
+			/*
+			 * We will only return the amount
+			 * of this packet since that is all
+			 * that will be read.
+			 */
+			/* FIXME: parse the header for more correct value */
+			amount = skb->len - (3+8+8);
+		}
+		spin_unlock_bh(&sk->sk_receive_queue.lock);
+		return put_user(amount, (int __user *)arg);
+	}
+
+	}
+	return -ENOIOCTLCMD;
+}
+
+/* FIXME: autobind */
+static int dgram_connect(struct sock *sk, struct sockaddr *uaddr,
+			int len)
+{
+	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
+	struct dgram_sock *ro = dgram_sk(sk);
+	int err = 0;
+
+	if (len < sizeof(*addr))
+		return -EINVAL;
+
+	if (addr->family != AF_IEEE802154)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	if (!ro->bound) {
+		err = -ENETUNREACH;
+		goto out;
+	}
+
+	memcpy(&ro->dst_addr, &addr->addr, sizeof(struct ieee802154_addr));
+
+out:
+	release_sock(sk);
+	return err;
+}
+
+static int dgram_disconnect(struct sock *sk, int flags)
+{
+	struct dgram_sock *ro = dgram_sk(sk);
+
+	lock_sock(sk);
+
+	ro->dst_addr.addr_type = IEEE802154_ADDR_LONG;
+	memset(&ro->dst_addr.hwaddr, 0xff, sizeof(ro->dst_addr.hwaddr));
+
+	release_sock(sk);
+
+	return 0;
+}
+
+static int dgram_sendmsg(struct kiocb *iocb, struct sock *sk,
+		struct msghdr *msg, size_t size)
+{
+	struct net_device *dev;
+	unsigned mtu;
+	struct sk_buff *skb;
+	struct dgram_sock *ro = dgram_sk(sk);
+	int err;
+
+	if (msg->msg_flags & MSG_OOB) {
+		pr_debug("msg->msg_flags = 0x%x\n", msg->msg_flags);
+		return -EOPNOTSUPP;
+	}
+
+	if (!ro->bound)
+		dev = dev_getfirstbyhwtype(sock_net(sk), ARPHRD_IEEE802154);
+	else
+		dev = ieee802154_get_dev(sock_net(sk), &ro->src_addr);
+
+	if (!dev) {
+		pr_debug("no dev\n");
+		err = -ENXIO;
+		goto out;
+	}
+	mtu = dev->mtu;
+	pr_debug("name = %s, mtu = %u\n", dev->name, mtu);
+
+	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + size,
+			msg->msg_flags & MSG_DONTWAIT,
+			&err);
+	if (!skb)
+		goto out_dev;
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb_reset_network_header(skb);
+
+	mac_cb(skb)->flags = IEEE802154_FC_TYPE_DATA | MAC_CB_FLAG_ACKREQ;
+	mac_cb(skb)->seq = ieee802154_mlme_ops(dev)->get_dsn(dev);
+	err = dev_hard_header(skb, dev, ETH_P_IEEE802154, &ro->dst_addr,
+			ro->bound ? &ro->src_addr : NULL, size);
+	if (err < 0)
+		goto out_skb;
+
+	skb_reset_mac_header(skb);
+
+	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+	if (err < 0)
+		goto out_skb;
+
+	if (size > mtu) {
+		pr_debug("size = %u, mtu = %u\n", size, mtu);
+		err = -EINVAL;
+		goto out_skb;
+	}
+
+	skb->dev = dev;
+	skb->sk  = sk;
+	skb->protocol = htons(ETH_P_IEEE802154);
+
+	dev_put(dev);
+
+	err = dev_queue_xmit(skb);
+	if (err > 0)
+		err = net_xmit_errno(err);
+
+	return err ?: size;
+
+out_skb:
+	kfree_skb(skb);
+out_dev:
+	dev_put(dev);
+out:
+	return err;
+}
+
+static int dgram_recvmsg(struct kiocb *iocb, struct sock *sk,
+		struct msghdr *msg, size_t len, int noblock, int flags,
+		int *addr_len)
+{
+	size_t copied = 0;
+	int err = -EOPNOTSUPP;
+	struct sk_buff *skb;
+
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (!skb)
+		goto out;
+
+	copied = skb->len;
+	if (len < copied) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+
+	/* FIXME: skip headers if necessary ?! */
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (err)
+		goto done;
+
+	sock_recv_timestamp(msg, sk, skb);
+
+	if (flags & MSG_TRUNC)
+		copied = skb->len;
+done:
+	skb_free_datagram(sk, skb);
+out:
+	if (err)
+		return err;
+	return copied;
+}
+
+static int dgram_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	if (sock_queue_rcv_skb(sk, skb) < 0) {
+		atomic_inc(&sk->sk_drops);
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
+	return NET_RX_SUCCESS;
+}
+
+static inline int ieee802154_match_sock(u8 *hw_addr, u16 pan_id,
+		u16 short_addr, struct dgram_sock *ro)
+{
+	if (!ro->bound)
+		return 1;
+
+	if (ro->src_addr.addr_type == IEEE802154_ADDR_LONG &&
+	    !memcmp(ro->src_addr.hwaddr, hw_addr, IEEE802154_ADDR_LEN))
+		return 1;
+
+	if (ro->src_addr.addr_type == IEEE802154_ADDR_SHORT &&
+		     pan_id == ro->src_addr.pan_id &&
+		     short_addr == ro->src_addr.short_addr)
+		return 1;
+
+	return 0;
+}
+
+int ieee802154_dgram_deliver(struct net_device *dev, struct sk_buff *skb)
+{
+	struct sock *sk, *prev = NULL;
+	struct hlist_node *node;
+	int ret = NET_RX_SUCCESS;
+	u16 pan_id, short_addr;
+
+	/* Data frame processing */
+	BUG_ON(dev->type != ARPHRD_IEEE802154);
+
+	pan_id = ieee802154_mlme_ops(dev)->get_pan_id(dev);
+	short_addr = ieee802154_mlme_ops(dev)->get_short_addr(dev);
+
+	read_lock(&dgram_lock);
+	sk_for_each(sk, node, &dgram_head) {
+		if (ieee802154_match_sock(dev->dev_addr, pan_id, short_addr,
+					dgram_sk(sk))) {
+			if (prev) {
+				struct sk_buff *clone;
+				clone = skb_clone(skb, GFP_ATOMIC);
+				if (clone)
+					dgram_rcv_skb(prev, clone);
+			}
+
+			prev = sk;
+		}
+	}
+
+	if (prev)
+		dgram_rcv_skb(prev, skb);
+	else {
+		kfree_skb(skb);
+		ret = NET_RX_DROP;
+	}
+	read_unlock(&dgram_lock);
+
+	return ret;
+}
+
+struct proto ieee802154_dgram_prot = {
+	.name		= "IEEE-802.15.4-MAC",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct dgram_sock),
+	.init		= dgram_init,
+	.close		= dgram_close,
+	.bind		= dgram_bind,
+	.sendmsg	= dgram_sendmsg,
+	.recvmsg	= dgram_recvmsg,
+	.hash		= dgram_hash,
+	.unhash		= dgram_unhash,
+	.connect	= dgram_connect,
+	.disconnect	= dgram_disconnect,
+	.ioctl		= dgram_ioctl,
+};
+
diff --git a/net/ieee802154/raw.c b/net/ieee802154/raw.c
new file mode 100644
index 0000000..df16f2e
--- /dev/null
+++ b/net/ieee802154/raw.c
@@ -0,0 +1,254 @@
+/*
+ * Raw IEEE 802.15.4 sockets
+ *
+ * Copyright 2007, 2008 Siemens AG
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2
+ * as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License along
+ * with this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
+ *
+ * Written by:
+ * Sergey Lapin <sergey.lapin-kv7WeFo6aLtBDgjK7y7TUQ@public.gmane.org>
+ * Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
+ */
+
+#include <linux/net.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/list.h>
+#include <net/sock.h>
+#include <net/ieee802154/af_ieee802154.h>
+
+#include "af802154.h"
+
+static HLIST_HEAD(raw_head);
+static DEFINE_RWLOCK(raw_lock);
+
+static void raw_hash(struct sock *sk)
+{
+	write_lock_bh(&raw_lock);
+	sk_add_node(sk, &raw_head);
+	sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
+	write_unlock_bh(&raw_lock);
+}
+
+static void raw_unhash(struct sock *sk)
+{
+	write_lock_bh(&raw_lock);
+	if (sk_del_node_init(sk))
+		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
+	write_unlock_bh(&raw_lock);
+}
+
+static void raw_close(struct sock *sk, long timeout)
+{
+	sk_common_release(sk);
+}
+
+static int raw_bind(struct sock *sk, struct sockaddr *uaddr, int len)
+{
+	struct sockaddr_ieee802154 *addr = (struct sockaddr_ieee802154 *)uaddr;
+	int err = 0;
+	struct net_device *dev = NULL;
+
+	if (len < sizeof(*addr))
+		return -EINVAL;
+
+	if (addr->family != AF_IEEE802154)
+		return -EINVAL;
+
+	lock_sock(sk);
+
+	dev = ieee802154_get_dev(sock_net(sk), &addr->addr);
+	if (!dev) {
+		err = -ENODEV;
+		goto out;
+	}
+
+	if (dev->type != ARPHRD_IEEE802154_PHY &&
+	    dev->type != ARPHRD_IEEE802154) {
+		err = -ENODEV;
+		goto out_put;
+	}
+
+	sk->sk_bound_dev_if = dev->ifindex;
+	sk_dst_reset(sk);
+
+out_put:
+	dev_put(dev);
+out:
+	release_sock(sk);
+
+	return err;
+}
+
+static int raw_connect(struct sock *sk, struct sockaddr *uaddr,
+			int addr_len)
+{
+	return -ENOTSUPP;
+}
+
+static int raw_disconnect(struct sock *sk, int flags)
+{
+	return 0;
+}
+
+static int raw_sendmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       size_t size)
+{
+	struct net_device *dev;
+	unsigned mtu;
+	struct sk_buff *skb;
+	int err;
+
+	if (msg->msg_flags & MSG_OOB) {
+		pr_debug("msg->msg_flags = 0x%x\n", msg->msg_flags);
+		return -EOPNOTSUPP;
+	}
+
+	lock_sock(sk);
+	if (!sk->sk_bound_dev_if)
+		dev = dev_getfirstbyhwtype(sock_net(sk), ARPHRD_IEEE802154);
+	else
+		dev = dev_get_by_index(sock_net(sk), sk->sk_bound_dev_if);
+	release_sock(sk);
+
+	if (!dev) {
+		pr_debug("no dev\n");
+		err = -ENXIO;
+		goto out;
+	}
+
+	mtu = dev->mtu;
+	pr_debug("name = %s, mtu = %u\n", dev->name, mtu);
+
+	if (size > mtu) {
+		pr_debug("size = %u, mtu = %u\n", size, mtu);
+		err = -EINVAL;
+		goto out_dev;
+	}
+
+	skb = sock_alloc_send_skb(sk, LL_ALLOCATED_SPACE(dev) + size,
+			msg->msg_flags & MSG_DONTWAIT, &err);
+	if (!skb)
+		goto out_dev;
+
+	skb_reserve(skb, LL_RESERVED_SPACE(dev));
+
+	skb_reset_mac_header(skb);
+	skb_reset_network_header(skb);
+
+	err = memcpy_fromiovec(skb_put(skb, size), msg->msg_iov, size);
+	if (err < 0)
+		goto out_skb;
+
+	skb->dev = dev;
+	skb->sk  = sk;
+	skb->protocol = htons(ETH_P_IEEE802154);
+
+	dev_put(dev);
+
+	err = dev_queue_xmit(skb);
+	if (err > 0)
+		err = net_xmit_errno(err);
+
+	return err ?: size;
+
+out_skb:
+	kfree_skb(skb);
+out_dev:
+	dev_put(dev);
+out:
+	return err;
+}
+
+static int raw_recvmsg(struct kiocb *iocb, struct sock *sk, struct msghdr *msg,
+		       size_t len, int noblock, int flags, int *addr_len)
+{
+	size_t copied = 0;
+	int err = -EOPNOTSUPP;
+	struct sk_buff *skb;
+
+	skb = skb_recv_datagram(sk, flags, noblock, &err);
+	if (!skb)
+		goto out;
+
+	copied = skb->len;
+	if (len < copied) {
+		msg->msg_flags |= MSG_TRUNC;
+		copied = len;
+	}
+
+	err = skb_copy_datagram_iovec(skb, 0, msg->msg_iov, copied);
+	if (err)
+		goto done;
+
+	sock_recv_timestamp(msg, sk, skb);
+
+	if (flags & MSG_TRUNC)
+		copied = skb->len;
+done:
+	skb_free_datagram(sk, skb);
+out:
+	if (err)
+		return err;
+	return copied;
+}
+
+static int raw_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	if (sock_queue_rcv_skb(sk, skb) < 0) {
+		atomic_inc(&sk->sk_drops);
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
+	return NET_RX_SUCCESS;
+}
+
+
+void ieee802154_raw_deliver(struct net_device *dev, struct sk_buff *skb)
+{
+	struct sock *sk;
+	struct hlist_node *node;
+
+	read_lock(&raw_lock);
+	sk_for_each(sk, node, &raw_head) {
+		bh_lock_sock(sk);
+		if (!sk->sk_bound_dev_if ||
+		    sk->sk_bound_dev_if == dev->ifindex) {
+
+			struct sk_buff *clone;
+
+			clone = skb_clone(skb, GFP_ATOMIC);
+			if (clone)
+				raw_rcv_skb(sk, clone);
+		}
+		bh_unlock_sock(sk);
+	}
+	read_unlock(&raw_lock);
+}
+
+struct proto ieee802154_raw_prot = {
+	.name		= "IEEE-802.15.4-RAW",
+	.owner		= THIS_MODULE,
+	.obj_size	= sizeof(struct sock),
+	.close		= raw_close,
+	.bind		= raw_bind,
+	.sendmsg	= raw_sendmsg,
+	.recvmsg	= raw_recvmsg,
+	.hash		= raw_hash,
+	.unhash		= raw_unhash,
+	.connect	= raw_connect,
+	.disconnect	= raw_disconnect,
+};
+
-- 
1.6.3.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
