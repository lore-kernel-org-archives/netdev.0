From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH net-next v2] ipvlan: Initial check-in of the IPVLAN driver.
Date: Sun, 16 Nov 2014 22:27:14 -0800
Message-ID: <1416205634-26611-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>,
	Laurent Chavey <chavey@google.com>,
	Tim Hockin <thockin@google.com>,
	David Miller <davem@davemloft.net>,
	Brandon Philips <brandon.philips@coreos.com>,
	Pavel Emelianov <xemul@parallels.com>,
	Mahesh Bandewar <maheshb@google.com>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f202.google.com ([209.85.192.202]:49476 "EHLO
	mail-pd0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750764AbaKQG1S convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2014 01:27:18 -0500
Received: by mail-pd0-f202.google.com with SMTP id g10so139580pdj.5
        for <netdev@vger.kernel.org>; Sun, 16 Nov 2014 22:27:18 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This driver is very similar to the macvlan driver except that it
uses L3 on the frame to determine the logical interface while
functioning as packet dispatcher. It inherits L2 of the master
device hence the packets on wire will have the same L2 for all
the packets originating from all virtual devices off of the same
master device.

This driver was developed keeping the namespace use-case in
mind. Hence most of the examples given here take that as the
base setup where main-device belongs to the default-ns and
virtual devices are assigned to the additional namespaces.

The device operates in two different modes and the difference
in these two modes in primarily in the TX side.

(a) L2 mode : In this mode, the device behaves as a L2 device.
TX processing upto L2 happens on the stack of the virtual device
associated with (namespace). Packets are switched after that
into the main device (default-ns) and queued for xmit.

RX processing is simple and all multicast, broadcast (if
applicable), and unicast belonging to the address(es) are
delivered to the virtual devices.

(b) L3 mode : In this mode, the device behaves like a L3 device.
TX processing upto L3 happens on the stack of the virtual device
associated with (namespace). Packets are switched to the
main-device (default-ns) for the L2 processing. Hence the routing
table of the default-ns will be used in this mode.

RX processins is somewhat similar to the L2 mode except that in
this mode only Unicast packets are delivered to the virtual device
while main-dev will handle all other packets.

The devices can be added using the "ip" command from the iproute2
package -

	ip link add link <master> <virtual> type ipvlan mode [ l2 | l3 ]

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Laurent Chavey <chavey@google.com>
Cc: Tim Hockin <thockin@google.com>
Cc: Brandon Philips <brandon.philips@coreos.com>
Cc: Pavel Emelianov <xemul@parallels.com>
---
 Documentation/networking/ipvlan.txt | 114 +++++
 drivers/net/Kconfig                 |  18 +
 drivers/net/Makefile                |   1 +
 drivers/net/ipvlan/Makefile         |   7 +
 drivers/net/ipvlan/ipvlan.h         | 157 +++++++
 drivers/net/ipvlan/ipvlan_core.c    | 630 +++++++++++++++++++++++++++
 drivers/net/ipvlan/ipvlan_main.c    | 830 ++++++++++++++++++++++++++++=
++++++++
 drivers/net/ipvlan/ipvlan_sysfs.c   | 119 ++++++
 include/linux/netdevice.h           |   4 +
 include/uapi/linux/if_link.h        |  15 +
 10 files changed, 1895 insertions(+)
 create mode 100644 Documentation/networking/ipvlan.txt
 create mode 100644 drivers/net/ipvlan/Makefile
 create mode 100644 drivers/net/ipvlan/ipvlan.h
 create mode 100644 drivers/net/ipvlan/ipvlan_core.c
 create mode 100644 drivers/net/ipvlan/ipvlan_main.c
 create mode 100644 drivers/net/ipvlan/ipvlan_sysfs.c

diff --git a/Documentation/networking/ipvlan.txt b/Documentation/networ=
king/ipvlan.txt
new file mode 100644
index 000000000000..1f5d34cb4841
--- /dev/null
+++ b/Documentation/networking/ipvlan.txt
@@ -0,0 +1,114 @@
+
+                            IPVLAN Driver HOWTO
+
+Initial Release:
+	Mahesh Bandewar <maheshb AT google.com>
+
+1. Introduction:
+	This is conceptually very similar to the macvlan driver with one majo=
r
+exception of using L3 for mux-ing /demux-ing among slaves. This proper=
ty makes
+the master device share the L2 with it's slave devices. I have develop=
ed this
+driver in conjuntion with network namespaces and not sure if there is =
use case
+outside of it.
+
+
+2. Building and Installation:
+	In order to build the driver, please select the config item CONFIG_IP=
VLAN.
+The driver can be built into the kernel (CONFIG_IPVLAN=3Dy) or as a mo=
dule
+(CONFIG_IPVLAN=3Dm).
+
+
+3. Configuration:
+	There are no module parameters for this driver and it can be configur=
ed
+using IProute2/ip utility.
+
+	ip link add link <master-dev> <slave-dev> type ipvlan mode { l2 | L3 =
}
+
+	e.g. ip link add link ipvl0 eth0 type ipvlan mode l2
+
+
+4. Operating modes:
+	IPvlan has two modes of operation - L2 and L3. For a given master dev=
ice,
+you can select one of these two modes and all slaves on that master wi=
ll
+operate in the same (selected) mode. The RX mode is almost identical e=
xcept
+that in L3 mode the slaves wont receive any multicast / broadcast traf=
fic.
+L3 mode is more restrictive since routing is controlled from the other=
 (mostly)
+default namespace.
+
+4.1 L2 mode:
+	In this mode TX processing happens on the stack instance attached to =
the
+slave device and packets are switched and queued to the master device =
to send
+out. In this mode the slaves will RX/TX multicast and broadcast (if ap=
plicable)
+as well.
+
+4.2 L3 mode:
+	In this mode TX processing upto L3 happens on the stack instance atta=
ched
+to the slave device and packets are switched to the stack instance of =
the
+master device for the L2 processing and routing from that instance wil=
l be
+used before packets are queued on the outbound device. In this mode th=
e slaves
+will not receive nor can send multicast / broadcast traffic.
+
+
+5. Sysfs interface:
+	Currently the mode of operation is available at -
+		 /sys/class/net/<master>/ipvlan/mode
+The value can be 0 or 1; where 0 :=3D> L2, 1 :=3D L3 mode
+
+
+6. What to choose (macvlan vs. ipvlan)?
+	These two devices are very similar in many regards and the specific u=
se
+case could very well define which device to choose. if one of the foll=
owing
+situations defines your use case then you can choose to use ipvlan -
+	(a) The Linux host that is connected to the external switch / router =
has
+policy configured that allows only one mac per port.
+	(b) No of virtual devices created on a master exceed the mac capacity=
 and
+puts the NIC in promiscous mode and degraded performance is a concern.
+	(c) If the slave device is to be put into the hostile / untrusted net=
work
+namespace where L2 on the slave could be changed / misused.
+
+
+7. Example configuration:
+
+  +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+
+  |  Host: host1                                                |
+  |                                                             |
+  |   +----------------------+      +----------------------+    |
+  |   |   NS:ns0             |      |  NS:ns1              |    |
+  |   |                      |      |                      |    |
+  |   |                      |      |                      |    |
+  |   |        ipvl0         |      |         ipvl1        |    |
+  |   +----------#-----------+      +-----------#----------+    |
+  |              #                              #               |
+  |              ################################               |
+  |                              # eth0                         |
+  +=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D#=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D+
+
+
+	(a) Create two network namespaces - ns0, ns1
+		ip netns add ns0
+		ip netns add ns1
+
+	(b) Create two ipvlan slaves on eth0 (master device)
+		ip link add link eth0 ipvl0 type ipvlan mode l2
+		ip link add link eth0 ipvl1 type ipvlan mode l2
+
+	(c) Assign slaves to the respective network namespaces
+		ip link set dev ipvl0 netns ns0
+		ip link set dev ipvl1 netns ns1
+
+	(d) Now switch to the namespace (ns0 or ns1) to configure the slave d=
evices
+		- For ns0
+			(1) ip netns exec ns0 bash
+			(2) ip link set dev ipvl0 up
+			(3) ip link set dev lo up
+			(4) ip -4 addr add 127.0.0.1 dev lo
+			(5) ip -4 addr add $IPADDR dev ipvl0
+			(6) ip -4 route add default via $ROUTER dev ipvl0
+		- For ns1
+			(1) ip netns exec ns1 bash
+			(2) ip link set dev ipvl1 up
+			(3) ip link set dev lo up
+			(4) ip -4 addr add 127.0.0.1 dev lo
+			(5) ip -4 addr add $IPADDR dev ipvl1
+			(6) ip -4 route add default via $ROUTER dev ipvl1
+
diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index f9009be3f307..b6d64f546574 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -145,6 +145,24 @@ config MACVTAP
 	  To compile this driver as a module, choose M here: the module
 	  will be called macvtap.
=20
+
+config IPVLAN
+    tristate "IP-VLAN support"
+    ---help---
+      This allows one to create virtual devices off of a main interfac=
e
+      and packets will be delivered based on the dest L3 (IPv6/IPv4 ad=
dr)
+      on packets. All interfaces (including the main interface) share =
L2
+      making it transparent to the connected L2 switch.
+
+      Ipvlan devices can be added using the "ip" command from the
+      iproute2 package starting with the iproute2-X.Y.ZZ release:
+
+      "ip link add link <main-dev> [ NAME ] type ipvlan"
+
+      To compile this driver as a module, choose M here: the module
+      will be called ipvlan.
+
+
 config VXLAN
        tristate "Virtual eXtensible Local Area Network (VXLAN)"
        depends on INET
diff --git a/drivers/net/Makefile b/drivers/net/Makefile
index 61aefdd1e173..e25fdd7d905e 100644
--- a/drivers/net/Makefile
+++ b/drivers/net/Makefile
@@ -6,6 +6,7 @@
 # Networking Core Drivers
 #
 obj-$(CONFIG_BONDING) +=3D bonding/
+obj-$(CONFIG_IPVLAN) +=3D ipvlan/
 obj-$(CONFIG_DUMMY) +=3D dummy.o
 obj-$(CONFIG_EQUALIZER) +=3D eql.o
 obj-$(CONFIG_IFB) +=3D ifb.o
diff --git a/drivers/net/ipvlan/Makefile b/drivers/net/ipvlan/Makefile
new file mode 100644
index 000000000000..2efff4e9bb40
--- /dev/null
+++ b/drivers/net/ipvlan/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for the Ethernet Ipvlan driver
+#
+
+obj-$(CONFIG_IPVLAN) +=3D ipvlan.o
+
+ipvlan-objs :=3D ipvlan_core.o ipvlan_main.o ipvlan_sysfs.o
diff --git a/drivers/net/ipvlan/ipvlan.h b/drivers/net/ipvlan/ipvlan.h
new file mode 100644
index 000000000000..78bb1ee9bc68
--- /dev/null
+++ b/drivers/net/ipvlan/ipvlan.h
@@ -0,0 +1,157 @@
+/*
+ * Copyright (c) 2014 Mahesh Bandewar <maheshb@google.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ */
+#ifndef __IPVLAN_H
+#define __IPVLAN_H
+
+#include <linux/kernel.h>
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/rculist.h>
+#include <linux/notifier.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+#include <linux/if_link.h>
+#include <linux/if_vlan.h>
+#include <linux/ip.h>
+#include <linux/inetdevice.h>
+#include <net/rtnetlink.h>
+#include <net/gre.h>
+#include <net/route.h>
+#include <net/addrconf.h>
+
+#define IPVLAN_DRV	"ipvlan"
+#define IPV_DRV_VER	"0.1"
+
+#define IPVLAN_HASH_SIZE	(1 << BITS_PER_BYTE)
+#define IPVLAN_HASH_MASK	(IPVLAN_HASH_SIZE - 1)
+
+#define IPVLAN_MAC_FILTER_BITS	8
+#define IPVLAN_MAC_FILTER_SIZE	(1 << IPVLAN_MAC_FILTER_BITS)
+#define IPVLAN_MAC_FILTER_MASK	(IPVLAN_MAC_FILTER_SIZE - 1)
+
+/* Define IPVL_DEBUG and set the appropriate dbg_level for debugging. =
*/
+#ifdef	IPVL_DEBUG
+/*
+ * 1 : non-datapath debugging
+ * 2 : Custom
+ * 3 : function enters and exists.
+ * 4 : printk in data path (be careful!)
+ */
+#define IPVL_DBG_LEVEL 1
+#define ipvlan_dbg(level, msg...)	do { \
+						if (level <=3D IPVL_DBG_LEVEL) \
+						printk(KERN_DEBUG msg); \
+					} while (0)
+#else
+#define ipvlan_dbg(level, msg...) do { ; } while (0)
+#endif
+
+typedef enum {
+	IPVL_IPV6 =3D 0,
+	IPVL_ICMPV6,
+	IPVL_IPV4,
+	IPVL_ARP,
+} ipvl_hdr_type;
+
+struct ipvl_pcpu_stats {
+	u64			rx_pkts;
+	u64			rx_bytes;
+	u64			rx_mcast;
+	u64			tx_pkts;
+	u64			tx_bytes;
+	struct u64_stats_sync	syncp;
+	u32			rx_errs;
+	u32			tx_drps;
+};
+
+/* Forward declaration */
+struct ipvl_port;
+
+struct ipvl_dev {
+	struct net_device	*dev;
+	struct list_head	pnode;
+	struct ipvl_port	*port;
+	struct net_device	*phy_dev;
+	struct list_head	addrs;
+	int			ipv4cnt;
+	int			ipv6cnt;
+	struct ipvl_pcpu_stats	*pcpu_stats;
+	DECLARE_BITMAP(mac_filters, IPVLAN_MAC_FILTER_SIZE);
+	netdev_features_t	sfeatures;
+	u16			mtu_adj;
+};
+
+struct ipvl_addr {
+	struct ipvl_dev		*master; /* Back pointer to master */
+	union {
+		struct in6_addr	ip6;	 /* IPv6 address on logical interface */
+		struct in_addr	ip4;	 /* IPv4 address on logical interface */
+	} ipu;
+#define ip6addr	ipu.ip6
+#define ip4addr ipu.ip4
+	struct hlist_node	hlnode;  /* Hash-table linkage */
+	struct list_head	anode;   /* logical-interface linkage */
+	struct rcu_head		rcu;
+	ipvl_hdr_type		atype;
+};
+
+struct ipvl_port {
+	struct net_device	*dev;
+	struct hlist_head	hlhead[IPVLAN_HASH_SIZE];
+	struct list_head	ipvlans;
+	struct rcu_head		rcu;
+	int			count;
+	struct kobject		kobj;
+	u16			mode;
+};
+
+static inline struct ipvl_port *ipvlan_port_get_rcu(const struct net_d=
evice *d)
+{
+	return rcu_dereference(d->rx_handler_data);
+}
+
+static inline struct ipvl_port *ipvlan_port_get_rtnl(const struct net_=
device *d)
+{
+	return rtnl_dereference(d->rx_handler_data);
+}
+
+static inline bool ipvlan_dev_master(struct net_device *d)
+{
+	return d->priv_flags & IFF_IPVLAN_MASTER;
+}
+
+static inline bool ipvlan_dev_slave(struct net_device *d)
+{
+	return d->priv_flags & IFF_IPVLAN_SLAVE;
+}
+
+/* ---- Prototype declarations ---- */
+/* ---- ipvlan_main.c ---- */
+void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev=
);
+void ipvlan_set_port_mode(struct ipvl_port *port, u32 nval);
+
+/* ---- ipvlan_sysfs.c ---- */
+int ipvlan_add_per_master_sysfs_mode(struct ipvl_port *port,
+				     struct net_device *dev);
+void ipvlan_del_per_master_sysfs_mode(struct ipvl_port *port);
+
+/* ---- ipvlan_core.c ---- */
+void ipvlan_init_secret(void);
+unsigned int ipvlan_mac_hash(const unsigned char *addr);
+rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb);
+int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev);
+void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan, struct ipvl_addr *add=
r);
+bool ipvlan_addr_busy(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6=
);
+struct ipvl_addr *ipvlan_ht_addr_lookup(const struct ipvl_port *port,
+					const void *iaddr, bool is_v6);
+void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync);
+#endif /* __IPVLAN_H */
diff --git a/drivers/net/ipvlan/ipvlan_core.c b/drivers/net/ipvlan/ipvl=
an_core.c
new file mode 100644
index 000000000000..fc814ff311e5
--- /dev/null
+++ b/drivers/net/ipvlan/ipvlan_core.c
@@ -0,0 +1,630 @@
+/* Copyright (c) 2014 Mahesh Bandewar <maheshb@google.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ */
+
+#include "ipvlan.h"
+
+static u32 ipvlan_jhash_secret;
+
+void ipvlan_init_secret(void)
+{
+	net_get_random_once(&ipvlan_jhash_secret, sizeof(ipvlan_jhash_secret)=
);
+}
+
+static void ipvlan_count_rx(const struct ipvl_dev *ipvlan,
+			    unsigned int len, bool success, bool mcast)
+{
+	if (!ipvlan)
+		return;
+
+	if (likely(success)) {
+		struct ipvl_pcpu_stats *pcptr;
+
+		pcptr =3D this_cpu_ptr(ipvlan->pcpu_stats);
+		u64_stats_update_begin(&pcptr->syncp);
+		pcptr->rx_pkts++;
+		pcptr->rx_bytes +=3D len;
+		if (mcast)
+			pcptr->rx_mcast++;
+		u64_stats_update_end(&pcptr->syncp);
+	} else {
+		this_cpu_inc(ipvlan->pcpu_stats->rx_errs);
+	}
+}
+
+static u8 ipvlan_get_v6_hash(const void *iaddr)
+{
+	const struct in6_addr *ip6_addr =3D iaddr;
+
+	return __ipv6_addr_jhash(ip6_addr, ipvlan_jhash_secret)
+	       & IPVLAN_HASH_MASK;
+}
+
+static u8 ipvlan_get_v4_hash(const void *iaddr)
+{
+	const struct in_addr *ip4_addr =3D iaddr;
+	return jhash_1word(ip4_addr->s_addr, ipvlan_jhash_secret)
+	       & IPVLAN_HASH_MASK;
+}
+
+struct ipvl_addr *ipvlan_ht_addr_lookup(const struct ipvl_port *port,
+					const void *iaddr, bool is_v6)
+{
+	struct ipvl_addr *addr;
+	u8 hash =3D is_v6 ? ipvlan_get_v6_hash(iaddr) :
+			    ipvlan_get_v4_hash(iaddr);
+
+	hlist_for_each_entry_rcu(addr, &port->hlhead[hash], hlnode) {
+		if (is_v6 && addr->atype =3D=3D IPVL_IPV6 &&
+			ipv6_addr_equal(&addr->ip6addr, iaddr))
+			return addr;
+		else if (!is_v6 && addr->atype =3D=3D IPVL_IPV4 &&
+			 addr->ip4addr.s_addr =3D=3D
+				((struct in_addr *)iaddr)->s_addr)
+			return addr;
+	}
+	return NULL;
+}
+
+void ipvlan_ht_addr_add(struct ipvl_dev *ipvlan, struct ipvl_addr *add=
r)
+{
+	struct ipvl_port *port =3D ipvlan->port;
+	u8 hash =3D (addr->atype =3D=3D IPVL_IPV6) ?
+		ipvlan_get_v6_hash(&addr->ip6addr) :
+		ipvlan_get_v4_hash(&addr->ip4addr);
+
+	hlist_add_head_rcu(&addr->hlnode, &port->hlhead[hash]);
+}
+
+void ipvlan_ht_addr_del(struct ipvl_addr *addr, bool sync)
+{
+	hlist_del_rcu(&addr->hlnode);
+	if (sync)
+		synchronize_rcu();
+}
+
+bool ipvlan_addr_busy(struct ipvl_dev *ipvlan, void *iaddr, bool is_v6=
)
+{
+	struct ipvl_port *port =3D ipvlan->port;
+	struct ipvl_addr *addr;
+
+	list_for_each_entry(addr, &ipvlan->addrs, anode) {
+		if ((is_v6 && addr->atype =3D=3D IPVL_IPV6 &&
+		     ipv6_addr_equal(&addr->ip6addr, iaddr))
+		   || (!is_v6 && addr->atype =3D=3D IPVL_IPV4 &&
+		      addr->ip4addr.s_addr =3D=3D ((struct in_addr *)iaddr)->s_addr)
+		  )
+			return true;
+	}
+
+	if (ipvlan_ht_addr_lookup(port, iaddr, is_v6))
+		return true;
+
+	return false;
+}
+
+static void *ipvlan_get_L3_hdr(struct sk_buff *skb, int *type)
+{
+	void *lyr3h =3D NULL;
+
+	switch (skb->protocol) {
+	case htons(ETH_P_ARP): {
+		struct arphdr *arph;
+
+		if (unlikely(!pskb_may_pull(skb, sizeof(*arph))))
+			return NULL;
+
+		arph =3D arp_hdr(skb);
+		*type =3D IPVL_ARP;
+		lyr3h =3D arph;
+		break;
+	}
+
+	case htons(ETH_P_IP): {
+		u32 pktlen;
+		struct iphdr *ip4h;
+
+		if (unlikely(!pskb_may_pull(skb, sizeof(*ip4h))))
+			return NULL;
+
+		ip4h =3D ip_hdr(skb);
+		pktlen =3D ntohs(ip4h->tot_len);
+		if (ip4h->ihl < 5 || ip4h->version !=3D 4)
+			return NULL;
+		if (skb->len < pktlen || pktlen < (ip4h->ihl * 4))
+			return NULL;
+
+		*type =3D IPVL_IPV4;
+		lyr3h =3D ip4h;
+		break;
+	}
+	case htons(ETH_P_IPV6): {
+		struct ipv6hdr *ip6h;
+
+		if (unlikely(!pskb_may_pull(skb, sizeof(*ip6h))))
+			return NULL;
+
+		ip6h =3D ipv6_hdr(skb);
+		if (ip6h->version !=3D 6)
+			return NULL;
+
+		*type =3D IPVL_IPV6;
+		lyr3h =3D ip6h;
+		/* Only Neighbour Solicitation pkts need different treatment */
+		if (ipv6_addr_any(&ip6h->saddr) &&
+		    ip6h->nexthdr =3D=3D NEXTHDR_ICMP) {
+			/* Get to the ICMPv6 header */
+			*type =3D IPVL_ICMPV6;
+			lyr3h =3D ip6h + 1;
+		}
+		break;
+	}
+	default:
+		return NULL;
+	}
+
+	return lyr3h;
+}
+
+unsigned int ipvlan_mac_hash(const unsigned char *addr)
+{
+	u32 hash =3D jhash_1word(__get_unaligned_cpu32(addr+2),
+			       ipvlan_jhash_secret);
+	return hash & IPVLAN_MAC_FILTER_MASK;
+}
+
+static void ipvlan_multicast_frame(struct ipvl_port *port, struct sk_b=
uff *skb,
+				   const struct ipvl_dev *in_dev, bool local)
+{
+	struct ethhdr *eth =3D eth_hdr(skb);
+	struct ipvl_dev *ipvlan;
+	struct sk_buff *nskb;
+	unsigned int len;
+	unsigned int mac_hash;
+	int ret;
+
+	/* If it's a PAUSE frame discard it! */
+	if (skb->protocol =3D=3D htons(ETH_P_PAUSE))
+		return;
+
+	list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
+		if (local && (ipvlan =3D=3D in_dev))
+			continue;
+
+		mac_hash =3D ipvlan_mac_hash(eth->h_dest);
+		if (!test_bit(mac_hash, ipvlan->mac_filters))
+			continue;
+
+		ret =3D NET_RX_DROP;
+		len =3D skb->len + ETH_HLEN;
+		nskb =3D skb_clone(skb, GFP_ATOMIC);
+		if (!nskb)
+			goto mcast_acct;
+
+		if (ether_addr_equal(eth->h_dest, ipvlan->phy_dev->broadcast))
+			nskb->pkt_type =3D PACKET_BROADCAST;
+		else
+			nskb->pkt_type =3D PACKET_MULTICAST;
+
+		nskb->dev =3D ipvlan->dev;
+		if (local)
+			ret =3D dev_forward_skb(ipvlan->dev, nskb);
+		else
+			ret =3D netif_rx(nskb);
+mcast_acct:
+		ipvlan_count_rx(ipvlan, len, ret =3D=3D NET_RX_SUCCESS, true);
+	}
+
+	/* Locally generated? ...Forward a copy to the main-device as
+	 * well. On the RX side we'll ignore it (wont give it to any
+	 * of the virtual devices.
+	 */
+	if (local) {
+		nskb =3D skb_clone(skb, GFP_ATOMIC);
+		if (nskb) {
+			if (ether_addr_equal(eth->h_dest, port->dev->broadcast))
+				nskb->pkt_type =3D PACKET_BROADCAST;
+			else
+				nskb->pkt_type =3D PACKET_MULTICAST;
+
+			dev_forward_skb(port->dev, nskb);
+		}
+	}
+}
+
+static int ipvlan_rcv_frame(struct ipvl_addr *addr, struct sk_buff *sk=
b,
+			    bool local)
+{
+	struct ipvl_dev *ipvlan =3D addr->master;
+	struct net_device *dev =3D ipvlan->dev;
+	unsigned int len;
+	rx_handler_result_t ret =3D RX_HANDLER_CONSUMED;
+	bool success =3D false;
+
+	len =3D skb->len + ETH_HLEN;
+	if (unlikely(!(dev->flags & IFF_UP))) {
+		kfree_skb(skb);
+		goto out;
+	}
+
+	skb =3D skb_share_check(skb, GFP_ATOMIC);
+	if (!skb)
+		goto out;
+
+	skb->dev =3D dev;
+	skb->pkt_type =3D PACKET_HOST;
+
+	if (local) {
+		if (dev_forward_skb(ipvlan->dev, skb) =3D=3D NET_RX_SUCCESS)
+			success =3D true;
+	} else {
+		ret =3D RX_HANDLER_ANOTHER;
+		success =3D true;
+	}
+
+out:
+	ipvlan_count_rx(ipvlan, len, success, false);
+	return ret;
+}
+
+static struct ipvl_addr *ipvlan_addr_lookup(struct ipvl_port *port,
+					    void *lyr3h, int addr_type,
+					    bool use_dest)
+{
+	struct ipvl_addr *addr =3D NULL;
+
+	if (addr_type =3D=3D IPVL_IPV6) {
+		struct ipv6hdr *ip6h;
+		struct in6_addr *i6addr;
+
+		ip6h =3D (struct ipv6hdr *)lyr3h;
+		i6addr =3D use_dest ? &ip6h->daddr : &ip6h->saddr;
+		addr =3D ipvlan_ht_addr_lookup(port, i6addr, true);
+	} else if (addr_type =3D=3D IPVL_ICMPV6) {
+		struct nd_msg *ndmh;
+		struct in6_addr *i6addr;
+		ndmh =3D (struct nd_msg *)lyr3h;
+
+		/* Make sure that the NeighborSolicitation ICMPv6 packets
+		 * are handled to avoid DAD issue.
+		 */
+		if (ndmh->icmph.icmp6_type =3D=3D NDISC_NEIGHBOUR_SOLICITATION) {
+			/* Reach the target address */
+			i6addr =3D &ndmh->target;
+			addr =3D ipvlan_ht_addr_lookup(port, i6addr, true);
+		}
+	} else if (addr_type =3D=3D IPVL_IPV4) {
+		struct iphdr *ip4h;
+		__be32 *i4addr;
+
+		ip4h =3D (struct iphdr *)lyr3h;
+		i4addr =3D use_dest ? &ip4h->daddr : &ip4h->saddr;
+		addr =3D ipvlan_ht_addr_lookup(port, i4addr, false);
+	} else if (addr_type =3D=3D IPVL_ARP) {
+		struct arphdr *arph;
+		unsigned char *arp_ptr;
+		__be32 dip;
+
+		arph =3D (struct arphdr *)lyr3h;
+		arp_ptr =3D (unsigned char *)(arph + 1);
+		if (use_dest)
+			/* Skip 2 L2 headers + 1 src L3 (IPv4) header */
+			arp_ptr +=3D (2 * port->dev->addr_len) + 4;
+		else
+			/* Skip L2 header to get to src L3 (IPv4) */
+			arp_ptr +=3D port->dev->addr_len;
+
+		memcpy(&dip, arp_ptr, 4); /* Get the dst IPv4 */
+		addr =3D ipvlan_ht_addr_lookup(port, &dip, false);
+	}
+
+	return addr;
+}
+
+static int ipvlan_process_v4_outbound(struct sk_buff *skb)
+{
+	const struct iphdr *ip4h =3D ip_hdr(skb);
+	struct net_device *dev =3D skb->dev;
+	struct rtable *rt;
+	int err, ret =3D NET_XMIT_DROP;
+	struct flowi4 fl4 =3D {
+		.flowi4_oif =3D dev->iflink,
+		.flowi4_tos =3D RT_TOS(ip4h->tos),
+		.flowi4_flags =3D FLOWI_FLAG_ANYSRC,
+		.daddr =3D ip4h->daddr,
+		.saddr =3D ip4h->saddr,
+	};
+
+	rt =3D ip_route_output_flow(dev_net(dev), &fl4, NULL);
+	if (IS_ERR(rt))
+		goto err;
+
+	if (rt->rt_type !=3D RTN_UNICAST && rt->rt_type !=3D RTN_LOCAL) {
+		ip_rt_put(rt);
+		goto err;
+	}
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
+	err =3D ip_local_out(skb);
+	if (unlikely(net_xmit_eval(err)))
+		dev->stats.tx_errors++;
+	else
+		ret =3D NET_XMIT_SUCCESS;
+	goto out;
+err:
+	dev->stats.tx_errors++;
+	kfree_skb(skb);
+out:
+	return ret;
+}
+
+static int ipvlan_process_v6_outbound(struct sk_buff *skb)
+{
+	const struct ipv6hdr *ip6h =3D ipv6_hdr(skb);
+	struct net_device *dev =3D skb->dev;
+	struct dst_entry *dst;
+	int err, ret =3D NET_XMIT_DROP;
+	struct flowi6 fl6 =3D {
+		.flowi6_iif =3D skb->dev->ifindex,
+		.daddr =3D ip6h->daddr,
+		.saddr =3D ip6h->saddr,
+		.flowi6_flags =3D FLOWI_FLAG_ANYSRC,
+		.flowlabel =3D ip6_flowinfo(ip6h),
+		.flowi6_mark =3D skb->mark,
+		.flowi6_proto =3D ip6h->nexthdr,
+	};
+
+	dst =3D ip6_route_output(dev_net(dev), NULL, &fl6);
+	if (IS_ERR(dst))
+		goto err;
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
+	err =3D ip6_local_out(skb);
+	if (unlikely(net_xmit_eval(err)))
+		dev->stats.tx_errors++;
+	else
+		ret =3D NET_XMIT_SUCCESS;
+	goto out;
+err:
+	dev->stats.tx_errors++;
+	kfree_skb(skb);
+out:
+	return ret;
+}
+
+static int ipvlan_process_outbound(struct sk_buff *skb,
+				   const struct ipvl_dev *ipvlan)
+{
+	struct ethhdr *ethh =3D eth_hdr(skb);
+	int ret =3D NET_XMIT_DROP;
+
+	/* In this mode we dont care about multicast and broadcast traffic */
+	if (is_multicast_ether_addr(ethh->h_dest)) {
+		pr_warn_ratelimited("Dropped {multi|broad}cast of type=3D [%x]\n",
+				    ntohs(skb->protocol));
+		kfree_skb(skb);
+		goto out;
+	}
+
+	/* The ipvlan is a pseudo-L2 device, so the packets that we receive
+	 * will have L2; which need to discarded and processed further
+	 * in the net-ns of the main-device.
+	 */
+	if (skb_mac_header_was_set(skb)) {
+		skb_pull(skb, sizeof(*ethh));
+		skb->mac_header =3D (typeof(skb->mac_header))~0U;
+		skb_reset_network_header(skb);
+	}
+
+	if (skb->protocol =3D=3D htons(ETH_P_IPV6))
+		ret =3D ipvlan_process_v6_outbound(skb);
+	else if (skb->protocol =3D=3D htons(ETH_P_IP))
+		ret =3D ipvlan_process_v4_outbound(skb);
+	else {
+		pr_warn_ratelimited("Dropped outbound packet type=3D%x\n",
+				    ntohs(skb->protocol));
+		kfree_skb(skb);
+	}
+out:
+	return ret;
+}
+
+static int ipvlan_xmit_mode_l3(struct sk_buff *skb, struct net_device =
*dev)
+{
+	const struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	void *lyr3h;
+	struct ipvl_addr *addr;
+	int addr_type;
+
+	ipvlan_dbg(4, "L3:Xmit on dev %s,PROT=3D%x\n", dev->name,
+		   ntohs(skb->protocol));
+	lyr3h =3D ipvlan_get_L3_hdr(skb, &addr_type);
+	if (!lyr3h)
+		goto out;
+
+	addr =3D ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
+	if (addr)
+		return ipvlan_rcv_frame(addr, skb, true);
+
+out:
+	/* Send it out */
+	skb->dev =3D ipvlan->phy_dev;
+	return ipvlan_process_outbound(skb, ipvlan);
+}
+
+static int ipvlan_xmit_mode_l2(struct sk_buff *skb, struct net_device =
*dev)
+{
+	const struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct ethhdr *eth =3D eth_hdr(skb);
+	struct ipvl_addr *addr;
+	void *lyr3h;
+	int addr_type;
+
+	ipvlan_dbg(4, "L2:Xmit on dev %s,PROT=3D%x\n", dev->name,
+		   ntohs(skb->protocol));
+	if (ether_addr_equal(eth->h_dest, eth->h_source)) {
+		ipvlan_dbg(4, "Comm betn 2 virt devs PROT=3D%x\n",
+			   ntohs(skb->protocol));
+		if ((lyr3h =3D ipvlan_get_L3_hdr(skb, &addr_type)) =3D=3D NULL)
+			goto to_default;
+
+		addr =3D ipvlan_addr_lookup(ipvlan->port, lyr3h, addr_type, true);
+		if (addr)
+			return ipvlan_rcv_frame(addr, skb, true);
+
+		/* No matching ipvlan dev! Must be on the Physical device */
+to_default:
+		skb =3D skb_share_check(skb, GFP_ATOMIC);
+		if (!skb)
+			return NET_XMIT_DROP;
+
+		/* Packet definitely does not belong to any of the
+		 * virtual devices, but the dest is local. So forward
+		 * the skb for the main-dev. At the RX side we just return
+		 * RX_PASS for it to be processed further on the stack.
+		 */
+		return dev_forward_skb(ipvlan->phy_dev, skb);
+
+	} else if (is_multicast_ether_addr(eth->h_dest)) {
+		u8 ip_summed =3D skb->ip_summed;
+		/* Packet needs to be multicast-ed. */
+		skb->ip_summed =3D CHECKSUM_UNNECESSARY;
+		ipvlan_dbg(4, "%s[%d] Mcast Xmit on [%s], PROT=3D[%x]\n",
+			   __func__, __LINE__, dev->name,
+			   ntohs(skb->protocol));
+		ipvlan_multicast_frame(ipvlan->port, skb, ipvlan, true);
+		skb->ip_summed =3D ip_summed;
+	}
+
+	/* Send it out */
+	skb->dev =3D ipvlan->phy_dev;
+	return dev_queue_xmit(skb);
+}
+
+int ipvlan_queue_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct ipvl_port *port =3D ipvlan_port_get_rcu(ipvlan->phy_dev);
+
+	if (!port)
+		goto out;
+
+	if (unlikely(!pskb_may_pull(skb, sizeof(struct ethhdr))))
+		goto out;
+
+	switch(port->mode) {
+	case IPVLAN_MODE_L2:
+		return ipvlan_xmit_mode_l2(skb, dev);
+	case IPVLAN_MODE_L3:
+		return ipvlan_xmit_mode_l3(skb, dev);
+	}
+
+	/* Should not reach here */
+	BUG();
+out:
+	kfree_skb(skb);
+	return NET_XMIT_DROP;
+}
+
+static bool ipvlan_external_frame(struct sk_buff *skb, struct ipvl_por=
t *port)
+{
+	struct ethhdr *eth =3D eth_hdr(skb);
+	struct ipvl_addr *addr;
+	void *lyr3h;
+	int addr_type;
+
+	if (ether_addr_equal(eth->h_source, skb->dev->dev_addr)) {
+		if ((lyr3h =3D ipvlan_get_L3_hdr(skb, &addr_type)) =3D=3D NULL)
+			return true;
+
+		addr =3D ipvlan_addr_lookup(port, lyr3h, addr_type, false);
+		if (addr)
+			return false;
+	}
+
+	return true;
+}
+
+static rx_handler_result_t ipvlan_handle_mode_l3(struct sk_buff **pskb=
,
+						 struct ipvl_port *port)
+{
+	void *lyr3h;
+	int addr_type;
+	struct ipvl_addr *addr;
+	struct sk_buff *skb =3D *pskb;
+	rx_handler_result_t ret =3D RX_HANDLER_PASS;
+
+	lyr3h =3D ipvlan_get_L3_hdr(skb, &addr_type);
+	if (!lyr3h)
+		goto out;
+
+	addr =3D ipvlan_addr_lookup(port, lyr3h, addr_type, true);
+	if (addr) {
+		ipvlan_dbg(4, "%s[%d]L3:Ucast Recv for [%s], PROT=3D[%x]\n",
+			   __func__, __LINE__, addr->master->dev->name,
+			   ntohs(skb->protocol));
+		ret =3D ipvlan_rcv_frame(addr, skb, false);
+	}
+out:
+	return ret;
+}
+
+static rx_handler_result_t ipvlan_handle_mode_l2(struct sk_buff **pskb=
,
+						 struct ipvl_port *port)
+{
+	struct sk_buff *skb =3D *pskb;
+	struct ethhdr *eth =3D eth_hdr(skb);
+	rx_handler_result_t ret =3D RX_HANDLER_PASS;
+	void *lyr3h;
+	int addr_type;
+
+	/* First Handle broadcast/multicast frames */
+	if (is_multicast_ether_addr(eth->h_dest)) {
+		/* Pass to virtual devs only if they haven't seen the frame. */
+		if (ipvlan_external_frame(skb, port)) {
+			ipvlan_dbg(4, "%s[%d]L2:Mcast Recv:[%s], PROT=3D[%x]\n",
+				   __func__, __LINE__, port->dev->name,
+				   ntohs(skb->protocol));
+			ipvlan_multicast_frame(port, skb, NULL, false);
+		}
+	} else if ((lyr3h =3D ipvlan_get_L3_hdr(skb, &addr_type)) !=3D NULL) =
{
+		struct ipvl_addr *addr;
+
+		addr =3D ipvlan_addr_lookup(port, lyr3h, addr_type, true);
+		if (addr) {
+			ipvlan_dbg(4, "%s[%d]L2:Ucast Recv:[%s], PROT=3D[%x]\n",
+				   __func__, __LINE__, addr->master->dev->name,
+				   ntohs(skb->protocol));
+			ret =3D ipvlan_rcv_frame(addr, skb, false);
+		}
+	}
+
+	return ret;
+}
+
+rx_handler_result_t ipvlan_handle_frame(struct sk_buff **pskb)
+{
+	struct sk_buff *skb =3D *pskb;
+	struct ipvl_port *port =3D ipvlan_port_get_rcu(skb->dev);
+
+	if (!port)
+		goto out;
+
+	switch (port->mode) {
+	case IPVLAN_MODE_L2:
+		return ipvlan_handle_mode_l2(pskb, port);
+	case IPVLAN_MODE_L3:
+		return ipvlan_handle_mode_l3(pskb, port);
+	}
+
+	/* Should not reach here */
+	BUG();
+out:
+	return RX_HANDLER_PASS;
+}
diff --git a/drivers/net/ipvlan/ipvlan_main.c b/drivers/net/ipvlan/ipvl=
an_main.c
new file mode 100644
index 000000000000..e81b3ed79fdf
--- /dev/null
+++ b/drivers/net/ipvlan/ipvlan_main.c
@@ -0,0 +1,830 @@
+/* Copyright (c) 2014 Mahesh Bandewar <maheshb@google.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ */
+
+#include "ipvlan.h"
+
+void ipvlan_adjust_mtu(struct ipvl_dev *ipvlan, struct net_device *dev=
)
+{
+	ipvlan->dev->mtu =3D dev->mtu - ipvlan->mtu_adj;
+}
+
+void ipvlan_set_port_mode(struct ipvl_port *port, u32 nval)
+{
+	struct ipvl_dev *ipvlan;
+
+	if (port->mode !=3D nval) {
+		list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
+			if (nval =3D=3D IPVLAN_MODE_L3)
+				ipvlan->dev->flags |=3D IFF_NOARP;
+			else
+				ipvlan->dev->flags &=3D ~IFF_NOARP;
+		}
+		port->mode =3D nval;
+	}
+}
+
+static int ipvlan_port_create(struct net_device *dev)
+{
+	struct ipvl_port *port;
+	int err, idx;
+
+	ipvlan_dbg(3, "%s[%d]: Entering...\n", __func__, __LINE__);
+	if (dev->type !=3D ARPHRD_ETHER || dev->flags & IFF_LOOPBACK) {
+		pr_warn("%s[%d]: Returning -EINVAL...\n",
+			__func__, __LINE__);
+		return -EINVAL;
+	}
+	if ((port =3D kzalloc(sizeof(struct ipvl_port), GFP_KERNEL)) =3D=3D N=
ULL) {
+		pr_warn("%s[%d]: Returning -ENOMEM...\n",
+			__func__, __LINE__);
+		return -ENOMEM;
+	}
+	port->dev =3D dev;
+	port->mode =3D IPVLAN_MODE_L3;
+	INIT_LIST_HEAD(&port->ipvlans);
+	for (idx =3D 0; idx < IPVLAN_HASH_SIZE; idx++)
+		INIT_HLIST_HEAD(&port->hlhead[idx]);
+
+	err =3D ipvlan_add_per_master_sysfs_mode(port, dev);
+	if (err)
+		goto err;
+
+	err =3D netdev_rx_handler_register(dev, ipvlan_handle_frame, port);
+	if (err)
+		goto err;
+
+	dev->priv_flags |=3D IFF_IPVLAN_MASTER;
+	ipvlan_dbg(3, "%s[%d]: Returning (%d)...\n", __func__, __LINE__, err)=
;
+	return 0;
+
+err:
+	kfree_rcu(port, rcu);
+	return err;
+}
+
+static void ipvlan_port_destroy(struct net_device *dev)
+{
+	struct ipvl_port *port =3D ipvlan_port_get_rtnl(dev);
+
+	dev->priv_flags &=3D ~IFF_IPVLAN_MASTER;
+	ipvlan_del_per_master_sysfs_mode(port);
+	netdev_rx_handler_unregister(dev);
+	kfree_rcu(port, rcu);
+}
+
+/* ipvlan network devices have devices nesting below it and are a spec=
ial
+ * "super class" of normal network devices; split their locks off into=
 a
+ * separate class since they always nest.
+ */
+static struct lock_class_key ipvlan_netdev_xmit_lock_key;
+static struct lock_class_key ipvlan_netdev_addr_lock_key;
+
+#define IPVLAN_FEATURES \
+	(NETIF_F_SG | NETIF_F_ALL_CSUM | NETIF_F_HIGHDMA | NETIF_F_FRAGLIST |=
 \
+	 NETIF_F_GSO | NETIF_F_TSO | NETIF_F_UFO | NETIF_F_GSO_ROBUST | \
+	 NETIF_F_TSO_ECN | NETIF_F_TSO6 | NETIF_F_GRO | NETIF_F_RXCSUM | \
+	 NETIF_F_HW_VLAN_CTAG_FILTER | NETIF_F_HW_VLAN_STAG_FILTER)
+
+#define IPVLAN_STATE_MASK \
+	((1<<__LINK_STATE_NOCARRIER) | (1<<__LINK_STATE_DORMANT))
+
+static void ipvlan_set_lockdep_class_one(struct net_device *dev,
+					 struct netdev_queue *txq,
+					 void *_unused)
+{
+	lockdep_set_class(&txq->_xmit_lock, &ipvlan_netdev_xmit_lock_key);
+}
+
+static void ipvlan_set_lockdep_class(struct net_device *dev)
+{
+	lockdep_set_class(&dev->addr_list_lock, &ipvlan_netdev_addr_lock_key)=
;
+	netdev_for_each_tx_queue(dev, ipvlan_set_lockdep_class_one, NULL);
+}
+
+/* ---- IPVLAN Netdev Ops ---- */
+static int ipvlan_init(struct net_device *dev)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	const struct net_device *phy_dev =3D ipvlan->phy_dev;
+
+	dev->state =3D (dev->state & ~IPVLAN_STATE_MASK) |
+		     (phy_dev->state & IPVLAN_STATE_MASK);
+	dev->features =3D phy_dev->features & IPVLAN_FEATURES;
+	dev->features |=3D NETIF_F_LLTX;
+	dev->gso_max_size =3D phy_dev->gso_max_size;
+	dev->iflink =3D phy_dev->ifindex;
+	dev->hard_header_len =3D phy_dev->hard_header_len;
+
+	ipvlan_set_lockdep_class(dev);
+
+	ipvlan->pcpu_stats =3D alloc_percpu(struct ipvl_pcpu_stats);
+	if (!ipvlan->pcpu_stats)
+		return -ENOMEM;
+
+	return 0;
+}
+
+static void ipvlan_uninit(struct net_device *dev)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct ipvl_port *port =3D ipvlan->port;
+
+	if (ipvlan->pcpu_stats)
+		free_percpu(ipvlan->pcpu_stats);
+
+	port->count -=3D 1;
+	if (!port->count)
+		ipvlan_port_destroy(port->dev);
+}
+
+static int ipvlan_open(struct net_device *dev)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct net_device *phy_dev =3D ipvlan->phy_dev;
+	struct ipvl_addr *addr;
+
+	if (ipvlan->port->mode =3D=3D IPVLAN_MODE_L3)
+		dev->flags |=3D IFF_NOARP;
+	else
+		dev->flags &=3D ~IFF_NOARP;
+
+	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
+		list_for_each_entry(addr, &ipvlan->addrs, anode) {
+			ipvlan_ht_addr_add(ipvlan, addr);
+		}
+	}
+	return dev_uc_add(phy_dev, phy_dev->dev_addr);
+}
+
+static int ipvlan_stop(struct net_device *dev)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct net_device *phy_dev =3D ipvlan->phy_dev;
+	struct ipvl_addr *addr;
+
+	dev_uc_unsync(phy_dev, dev);
+	dev_mc_unsync(phy_dev, dev);
+
+	dev_uc_del(phy_dev, phy_dev->dev_addr);
+
+	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
+		list_for_each_entry(addr, &ipvlan->addrs, anode) {
+			ipvlan_ht_addr_del(addr, !dev->dismantle);
+		}
+	}
+	return 0;
+}
+
+netdev_tx_t ipvlan_start_xmit(struct sk_buff *skb, struct net_device *=
dev)
+{
+	const struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	int skblen =3D skb->len;
+	int ret;
+
+	ret =3D ipvlan_queue_xmit(skb, dev);
+	if (likely(ret =3D=3D NET_XMIT_SUCCESS || ret =3D=3D NET_XMIT_CN)) {
+		struct ipvl_pcpu_stats *pcptr;
+
+		pcptr =3D this_cpu_ptr(ipvlan->pcpu_stats);
+
+		u64_stats_update_begin(&pcptr->syncp);
+		pcptr->tx_pkts++;
+		pcptr->tx_bytes +=3D skblen;
+		u64_stats_update_end(&pcptr->syncp);
+	} else {
+		this_cpu_inc(ipvlan->pcpu_stats->tx_drps);
+	}
+	return ret;
+}
+
+static netdev_features_t ipvlan_fix_features(struct net_device *dev,
+					     netdev_features_t features)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	return features & (ipvlan->sfeatures | ~IPVLAN_FEATURES);
+}
+
+static void ipvlan_change_rx_flags(struct net_device *dev, int change)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct net_device *phy_dev =3D ipvlan->phy_dev;
+
+	if (change & IFF_ALLMULTI)
+		dev_set_allmulti(phy_dev, dev->flags & IFF_ALLMULTI? 1 : -1);
+}
+
+static void ipvlan_set_broadcast_mac_filter(struct ipvl_dev *ipvlan, b=
ool set)
+{
+	struct net_device *dev =3D ipvlan->dev;
+	unsigned int hashbit =3D ipvlan_mac_hash(dev->broadcast);
+
+	if (set && !test_bit(hashbit, ipvlan->mac_filters)) {
+		/* Set broadcast hash-bit (for IPv4) */
+		__set_bit(hashbit, ipvlan->mac_filters);
+	} else if (!set && test_bit(hashbit, ipvlan->mac_filters)) {
+		/* Reset broadcast hash-bit */
+		__clear_bit(hashbit, ipvlan->mac_filters);
+	}
+}
+
+static void ipvlan_set_multicast_mac_filter(struct net_device *dev)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+
+	if (dev->flags & (IFF_PROMISC | IFF_ALLMULTI)) {
+		bitmap_fill(ipvlan->mac_filters, IPVLAN_MAC_FILTER_SIZE);
+	} else {
+		struct netdev_hw_addr *ha;
+		DECLARE_BITMAP(mc_filters, IPVLAN_MAC_FILTER_SIZE);
+
+		bitmap_zero(mc_filters, IPVLAN_MAC_FILTER_SIZE);
+		netdev_for_each_mc_addr(ha, dev) {
+			__set_bit(ipvlan_mac_hash(ha->addr), mc_filters);
+		}
+		bitmap_copy(ipvlan->mac_filters, mc_filters,
+			    IPVLAN_MAC_FILTER_SIZE);
+	}
+	dev_uc_sync(ipvlan->phy_dev, dev);
+	dev_mc_sync(ipvlan->phy_dev, dev);
+}
+
+static struct rtnl_link_stats64 *ipvlan_get_stats64(struct net_device =
*dev,
+						struct rtnl_link_stats64 *stats)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+
+	if (ipvlan->pcpu_stats) {
+		struct ipvl_pcpu_stats *pcptr;
+		u64 rx_pkts, rx_bytes, rx_mcast, tx_pkts, tx_bytes;
+		u32 rx_errs =3D 0, tx_drps =3D 0;
+		u32 strt;
+		int idx;
+
+		for_each_possible_cpu(idx) {
+			pcptr =3D per_cpu_ptr(ipvlan->pcpu_stats, idx);
+			do {
+				strt=3D u64_stats_fetch_begin_irq(&pcptr->syncp);
+				rx_pkts =3D pcptr->rx_pkts;
+				rx_bytes =3D pcptr->rx_bytes;
+				rx_mcast =3D pcptr->rx_mcast;
+				tx_pkts =3D pcptr->tx_pkts;
+				tx_bytes =3D pcptr->tx_bytes;
+			} while(u64_stats_fetch_retry_irq(&pcptr->syncp, strt));
+
+			stats->rx_packets +=3D rx_pkts;
+			stats->rx_bytes +=3D rx_bytes;
+			stats->multicast +=3D rx_mcast;
+			stats->tx_packets +=3D tx_pkts;
+			stats->tx_bytes +=3D tx_bytes;
+
+			/* u32 values are updated without syncp protection. */
+			rx_errs +=3D pcptr->rx_errs;
+			tx_drps +=3D pcptr->tx_drps;
+		}
+		stats->rx_errors =3D rx_errs;
+		stats->rx_dropped =3D rx_errs;
+		stats->tx_dropped =3D tx_drps;
+	}
+	return stats;
+}
+
+static int ipvlan_vlan_rx_add_vid(struct net_device *dev,
+				   __be16 proto, u16 vid)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct net_device *phy_dev =3D ipvlan->phy_dev;
+
+	return vlan_vid_add(phy_dev, proto, vid);
+}
+
+static int ipvlan_vlan_rx_kill_vid(struct net_device *dev,
+				   __be16 proto, u16 vid)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct net_device *phy_dev =3D ipvlan->phy_dev;
+
+	vlan_vid_del(phy_dev, proto, vid);
+	return 0;
+}
+
+static const struct net_device_ops ipvlan_netdev_ops =3D {
+	.ndo_init		=3D ipvlan_init,
+	.ndo_uninit		=3D ipvlan_uninit,
+	.ndo_open		=3D ipvlan_open,
+	.ndo_stop		=3D ipvlan_stop,
+	.ndo_start_xmit		=3D ipvlan_start_xmit,
+	.ndo_fix_features	=3D ipvlan_fix_features,
+	.ndo_change_rx_flags	=3D ipvlan_change_rx_flags,
+	.ndo_set_rx_mode	=3D ipvlan_set_multicast_mac_filter,
+	.ndo_get_stats64	=3D ipvlan_get_stats64,
+	.ndo_vlan_rx_add_vid	=3D ipvlan_vlan_rx_add_vid,
+	.ndo_vlan_rx_kill_vid	=3D ipvlan_vlan_rx_kill_vid,
+};
+
+/* ---- Ethernet Header Ops ---- */
+static int ipvlan_hard_header(struct sk_buff *skb, struct net_device *=
dev,
+			      unsigned short type, const void *daddr,
+			      const void *saddr, unsigned len)
+{
+	const struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct net_device *phy_dev =3D ipvlan->phy_dev;
+
+	/* TODO Probably use a different field than dev_addr so that the
+	 * mac-address on the virtual device is portable and can be carried
+	 * while the packets use the mac-addr on the physical device.
+	 */
+	return dev_hard_header(skb, phy_dev, type, daddr,
+			       saddr ? : dev->dev_addr, len);
+}
+
+static const struct header_ops ipvlan_header_ops =3D {
+	.create  	=3D ipvlan_hard_header,
+	.rebuild	=3D eth_rebuild_header,
+	.parse		=3D eth_header_parse,
+	.cache		=3D eth_header_cache,
+	.cache_update	=3D eth_header_cache_update,
+};
+
+/* ---- Ethtool ops ---- */
+static int ipvlan_ethtool_get_settings(struct net_device *dev,
+				       struct ethtool_cmd *cmd)
+{
+	const struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	return __ethtool_get_settings(ipvlan->phy_dev, cmd);
+}
+
+static void ipvlan_ethtool_get_drvinfo(struct net_device *dev,
+				       struct ethtool_drvinfo *drvinfo)
+{
+	strlcpy(drvinfo->driver, IPVLAN_DRV, sizeof(drvinfo->driver));
+	strlcpy(drvinfo->version, IPV_DRV_VER, sizeof(drvinfo->version));
+}
+
+static const struct ethtool_ops ipvlan_ethtool_ops =3D {
+	.get_link	=3D ethtool_op_get_link,
+	.get_settings	=3D ipvlan_ethtool_get_settings,
+	.get_drvinfo	=3D ipvlan_ethtool_get_drvinfo,
+};
+
+/* ---- Link-ops ---- */
+static int ipvlan_nl_changelink(struct net_device *dev,
+				struct nlattr *tb[], struct nlattr *data[])
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct ipvl_port *port =3D ipvlan_port_get_rtnl(ipvlan->phy_dev);
+
+	if (data && data[IFLA_IPVLAN_MODE]) {
+		u16 nmode =3D nla_get_u16(data[IFLA_IPVLAN_MODE]);
+		ipvlan_set_port_mode(port, nmode);
+	}
+
+	return 0;
+}
+
+static size_t ipvlan_nl_getsize(const struct net_device *dev)
+{
+	return (0
+		+ nla_total_size(2) /* IFLA_IPVLAN_MODE */
+		);
+}
+
+static int ipvlan_nl_validate(struct nlattr *tb[], struct nlattr *data=
[])
+{
+	if (data && data[IFLA_IPVLAN_MODE]) {
+		u16 mode =3D nla_get_u16(data[IFLA_IPVLAN_MODE]);
+
+		if (mode < IPVLAN_MODE_L2 || mode >=3D IPVLAN_MODE_MAX)
+			return -EINVAL;
+	}
+
+	return 0;
+}
+
+static int ipvlan_nl_fillinfo(struct sk_buff *skb,
+			      const struct net_device *dev)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct ipvl_port *port =3D ipvlan_port_get_rtnl(ipvlan->phy_dev);
+	int ret =3D -EINVAL;
+
+	if (!port)
+		goto err;
+
+	ret =3D -EMSGSIZE;
+	if (nla_put_u16(skb, IFLA_IPVLAN_MODE, port->mode))
+		goto err;
+
+	return 0;
+
+err:
+	return ret;
+}
+
+static int ipvlan_link_new(struct net *src_net, struct net_device *dev=
,
+			   struct nlattr *tb[], struct nlattr *data[])
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct ipvl_port *port;
+	struct net_device *phy_dev;
+	int err;
+
+	ipvlan_dbg(3, "%s[%d]: Entering...\n", __func__, __LINE__);
+	if (!tb[IFLA_LINK]) {
+		ipvlan_dbg(3, "%s[%d]: Returning -EINVAL...\n",
+			   __func__, __LINE__);
+		return -EINVAL;
+	}
+
+	phy_dev =3D __dev_get_by_index(src_net, nla_get_u32(tb[IFLA_LINK]));
+	if (phy_dev =3D=3D NULL) {
+		ipvlan_dbg(3, "%s[%d]: Returning -ENODEV...\n",
+			   __func__, __LINE__);
+		return -ENODEV;
+	}
+
+	if (ipvlan_dev_slave(phy_dev)) {
+		struct ipvl_dev *tmp =3D netdev_priv(phy_dev);
+
+		phy_dev =3D tmp->phy_dev;
+	} else if (!ipvlan_dev_master(phy_dev)) {
+		err =3D ipvlan_port_create(phy_dev);
+		if (err < 0) {
+			ipvlan_dbg(3, "%s[%d]: Returning error (%d)...\n",
+				   __func__, __LINE__, err);
+			return err;
+		}
+	}
+
+	port =3D ipvlan_port_get_rtnl(phy_dev);
+	/* Get the mode if specified. */
+	if (data && data[IFLA_IPVLAN_MODE])
+		port->mode =3D nla_get_u16(data[IFLA_IPVLAN_MODE]);
+
+	ipvlan->phy_dev =3D phy_dev;
+	ipvlan->dev =3D dev;
+	ipvlan->port =3D port;
+	ipvlan->sfeatures =3D IPVLAN_FEATURES;
+	INIT_LIST_HEAD(&ipvlan->addrs);
+	ipvlan->ipv4cnt =3D 0;
+	ipvlan->ipv6cnt =3D 0;
+
+	/* Probably put a random address here to be presented to the
+	 * world but keep using the physical-dev address for the outgoing
+	 * packets.
+	 */
+	memcpy(dev->dev_addr, phy_dev->dev_addr, ETH_ALEN);
+
+	/* Mark this as a IPVLAN secondary device. */
+	dev->priv_flags |=3D IFF_IPVLAN_SLAVE;
+
+	port->count +=3D 1;
+	err =3D register_netdevice(dev);
+	if (err < 0) {
+		ipvlan_dbg(3, "%s[%d]: Returning error...\n",
+			   __func__, __LINE__);
+		goto ipvlan_destroy_port;
+	}
+	err =3D netdev_upper_dev_link(phy_dev, dev);
+	if (err) {
+		ipvlan_dbg(3, "%s[%d]: Returning error (%d)\n",
+			   __func__, __LINE__, err);
+		goto ipvlan_destroy_port;
+	}
+
+	list_add_tail_rcu(&ipvlan->pnode, &port->ipvlans);
+	netif_stacked_transfer_operstate(phy_dev, dev);
+	ipvlan_dbg(3, "%s[%d]: Returning success...\n", __func__, __LINE__);
+	return 0;
+
+ipvlan_destroy_port:
+	port->count -=3D 1;
+	if (!port->count)
+		ipvlan_port_destroy(phy_dev);
+
+	ipvlan_dbg(3, "%s[%d]: Return (after Destroying Port)",
+		   __func__, __LINE__);
+	return err;
+}
+
+static void ipvlan_link_delete(struct net_device *dev, struct list_hea=
d *head)
+{
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct ipvl_addr *addr, *next;
+
+	if (ipvlan->ipv6cnt > 0 || ipvlan->ipv4cnt > 0) {
+		list_for_each_entry_safe(addr, next, &ipvlan->addrs, anode) {
+			ipvlan_ht_addr_del(addr, !dev->dismantle);
+			list_del_rcu(&addr->anode);
+		}
+	}
+	list_del_rcu(&ipvlan->pnode);
+	unregister_netdevice_queue(dev, head);
+	netdev_upper_dev_unlink(ipvlan->phy_dev, dev);
+}
+
+static void ipvlan_link_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+
+	dev->priv_flags &=3D ~(IFF_XMIT_DST_RELEASE | IFF_TX_SKB_SHARING);
+	dev->priv_flags |=3D IFF_UNICAST_FLT;
+	dev->netdev_ops =3D &ipvlan_netdev_ops;
+	dev->destructor =3D free_netdev;
+	dev->header_ops =3D &ipvlan_header_ops;
+	dev->ethtool_ops =3D &ipvlan_ethtool_ops;
+	dev->tx_queue_len =3D 0;
+}
+
+static const struct nla_policy ipvlan_nl_policy[IFLA_IPVLAN_MAX + 1] =3D
+{
+	[IFLA_IPVLAN_MODE] =3D { .type =3D NLA_U16 },
+};
+
+static struct rtnl_link_ops ipvlan_link_ops =3D {
+	.kind		=3D "ipvlan",
+	.priv_size	=3D sizeof(struct ipvl_dev),
+
+	.get_size	=3D ipvlan_nl_getsize,
+	.policy		=3D ipvlan_nl_policy,
+	.validate	=3D ipvlan_nl_validate,
+	.fill_info	=3D ipvlan_nl_fillinfo,
+	.changelink	=3D ipvlan_nl_changelink,
+	.maxtype	=3D IFLA_IPVLAN_MAX,
+
+	.setup		=3D ipvlan_link_setup,
+	.newlink	=3D ipvlan_link_new,
+	.dellink	=3D ipvlan_link_delete,
+};
+
+int ipvlan_link_register(struct rtnl_link_ops *ops)
+{
+	return rtnl_link_register(ops);
+}
+
+/* ---- IPVLAN event handling ---- */
+static int ipvlan_device_event(struct notifier_block *unused,
+			       unsigned long event, void *ptr)
+{
+	struct net_device *dev =3D netdev_notifier_info_to_dev(ptr);
+	struct ipvl_dev *ipvlan, *next;
+	struct ipvl_port *port;
+	LIST_HEAD(lst_kill);
+
+	if (!ipvlan_dev_master(dev))
+		return NOTIFY_DONE;
+
+	port =3D ipvlan_port_get_rtnl(dev);
+
+	switch (event) {
+	case NETDEV_CHANGE:
+		list_for_each_entry(ipvlan, &port->ipvlans, pnode)
+			netif_stacked_transfer_operstate(ipvlan->phy_dev,
+							 ipvlan->dev);
+		break;
+
+	case NETDEV_UNREGISTER:
+		if (dev->reg_state !=3D NETREG_UNREGISTERING)
+			break;
+
+		list_for_each_entry_safe(ipvlan, next, &port->ipvlans,
+					 pnode)
+			ipvlan->dev->rtnl_link_ops->dellink(ipvlan->dev,
+							    &lst_kill);
+		unregister_netdevice_many(&lst_kill);
+		break;
+
+	case NETDEV_FEAT_CHANGE:
+		list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
+			ipvlan->dev->features =3D dev->features & IPVLAN_FEATURES;
+			ipvlan->dev->gso_max_size =3D dev->gso_max_size;
+			netdev_features_change(ipvlan->dev);
+		}
+		break;
+
+	case NETDEV_CHANGEMTU:
+		list_for_each_entry(ipvlan, &port->ipvlans, pnode) {
+			ipvlan_adjust_mtu(ipvlan, dev);
+		}
+		break;
+
+	case NETDEV_PRE_TYPE_CHANGE:
+		/* Forbid underlying device to change its type. */
+		return NOTIFY_BAD;
+	}
+	return NOTIFY_DONE;
+}
+
+static int ipvlan_add_addr6(struct ipvl_dev *ipvlan, struct in6_addr *=
ip6_addr)
+{
+	struct ipvl_addr *addr;
+
+	if (ipvlan_addr_busy(ipvlan, ip6_addr, true)) {
+		pr_warn("%s[%d]: Failed IPv6=3D%x:%x:%x:%x address for %s intf\n",
+			__func__, __LINE__, ip6_addr->s6_addr32[0],
+			ip6_addr->s6_addr32[1], ip6_addr->s6_addr32[2],
+			ip6_addr->s6_addr32[3], ipvlan->dev->name);
+		return -EINVAL;
+	}
+	if ((addr =3D kzalloc(sizeof(struct ipvl_addr), GFP_KERNEL)) =3D=3D N=
ULL)
+		return -ENOMEM;
+
+	ipvlan_dbg(1, "%s[%d]: Adding IPv6=3D%x:%x:%x:%x address for %s intf\=
n",
+		   __func__, __LINE__, ip6_addr->s6_addr32[0],
+		   ip6_addr->s6_addr32[1], ip6_addr->s6_addr32[2],
+		   ip6_addr->s6_addr32[3], ipvlan->dev->name);
+	addr->master =3D ipvlan;
+	memcpy(&addr->ip6addr, ip6_addr, sizeof(struct in6_addr));
+	addr->atype =3D IPVL_IPV6;
+	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
+	ipvlan->ipv6cnt++;
+	ipvlan_ht_addr_add(ipvlan, addr);
+
+	return 0;
+}
+
+static void ipvlan_del_addr6(struct ipvl_dev *ipvlan, struct in6_addr =
*ip6_addr)
+{
+	struct ipvl_addr *addr;
+
+	if ((addr =3D ipvlan_ht_addr_lookup(ipvlan->port, ip6_addr, true)) =3D=
=3DNULL)
+		return;
+
+	ipvlan_dbg(1,
+		   "%s[%d]: Deleting IPv6=3D%x:%x:%x:%x address for %s intf.\n",
+		   __func__, __LINE__, ip6_addr->s6_addr32[0],
+		   ip6_addr->s6_addr32[1], ip6_addr->s6_addr32[2],
+		   ip6_addr->s6_addr32[3], ipvlan->dev->name);
+	/* Delete from the hash-table */
+	ipvlan_ht_addr_del(addr, true);
+	/* Delete from the logical's addr list */
+	list_del_rcu(&addr->anode);
+	ipvlan->ipv6cnt--;
+	WARN_ON(ipvlan->ipv6cnt < 0);
+	kfree_rcu(addr, rcu);
+
+	return;
+}
+
+static int ipvlan_addr6_event(struct notifier_block *unused,
+			      unsigned long event, void *ptr)
+{
+	struct inet6_ifaddr *if6 =3D (struct inet6_ifaddr *)ptr;
+	struct net_device *dev =3D (struct net_device *)if6->idev->dev;
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+
+	ipvlan_dbg(3, "%s[%d]: Entering...\n", __func__, __LINE__);
+	if (!ipvlan_dev_slave(dev))
+		return NOTIFY_DONE;
+
+	if (!ipvlan || !ipvlan->port)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_UP:
+		if (ipvlan_add_addr6(ipvlan, &if6->addr))
+			return NOTIFY_BAD;
+		break;
+
+	case NETDEV_DOWN:
+		ipvlan_del_addr6(ipvlan, &if6->addr);
+		break;
+	}
+
+	ipvlan_dbg(3, "%s[%d]: Leaving...\n", __func__, __LINE__);
+	return NOTIFY_OK;
+}
+
+static int ipvlan_add_addr4(struct ipvl_dev *ipvlan, struct in_addr *i=
p4_addr)
+{
+	struct ipvl_addr *addr;
+
+	if (ipvlan_addr_busy(ipvlan, ip4_addr, false)) {
+		pr_warn("%s[%d]: Failed to add IPv4=3D%x on %s intf.\n",
+			__func__, __LINE__, ntohl(ip4_addr->s_addr),
+			   ipvlan->dev->name);
+		return -EINVAL;
+	}
+	if ((addr =3D kzalloc(sizeof(struct ipvl_addr), GFP_KERNEL)) =3D=3D N=
ULL)
+		return -ENOMEM;
+
+	ipvlan_dbg(1, "%s[%d]: Adding IPv4=3D%x address for %s intf.\n",
+		   __func__, __LINE__, ip4_addr->s_addr, ipvlan->dev->name);
+	addr->master =3D ipvlan;
+	memcpy(&addr->ip4addr, ip4_addr, sizeof(struct in_addr));
+	addr->atype =3D IPVL_IPV4;
+	list_add_tail_rcu(&addr->anode, &ipvlan->addrs);
+	ipvlan->ipv4cnt++;
+	ipvlan_ht_addr_add(ipvlan, addr);
+	ipvlan_set_broadcast_mac_filter(ipvlan, true);
+
+	return 0;
+}
+
+static void ipvlan_del_addr4(struct ipvl_dev *ipvlan, struct in_addr *=
ip4_addr)
+{
+	struct ipvl_addr *addr;
+
+	if ((addr=3D ipvlan_ht_addr_lookup(ipvlan->port, ip4_addr, false)) =3D=
=3DNULL)
+		return;
+
+	ipvlan_dbg(1, "%s[%d]: Deleting IPv4=3D%x address for %s intf.\n",
+		   __func__, __LINE__, ip4_addr->s_addr, ipvlan->dev->name);
+	/* Delete from the hash-table */
+	ipvlan_ht_addr_del(addr, true);
+	/* Delete from the logical's addr list */
+	list_del_rcu(&addr->anode);
+	ipvlan->ipv4cnt--;
+	WARN_ON(ipvlan->ipv4cnt < 0);
+	if (!ipvlan->ipv4cnt)
+	    ipvlan_set_broadcast_mac_filter(ipvlan, false);
+	kfree_rcu(addr, rcu);
+
+	return;
+}
+
+static int ipvlan_addr4_event(struct notifier_block *unused,
+			      unsigned long event, void *ptr)
+{
+	struct in_ifaddr *if4 =3D (struct in_ifaddr *)ptr;
+	struct net_device *dev =3D (struct net_device *)if4->ifa_dev->dev;
+	struct ipvl_dev *ipvlan =3D netdev_priv(dev);
+	struct in_addr ip4_addr;
+
+	ipvlan_dbg(3, "%s[%d]: Entering...\n", __func__, __LINE__);
+	if (!ipvlan_dev_slave(dev))
+		return NOTIFY_DONE;
+
+	if (!ipvlan || !ipvlan->port)
+		return NOTIFY_DONE;
+
+	switch (event) {
+	case NETDEV_UP:
+		ip4_addr.s_addr =3D if4->ifa_address;
+		if (ipvlan_add_addr4(ipvlan, &ip4_addr))
+			return NOTIFY_BAD;
+		break;
+
+	case NETDEV_DOWN:
+		ip4_addr.s_addr =3D if4->ifa_address;
+		ipvlan_del_addr4(ipvlan, &ip4_addr);
+		break;
+	}
+
+	ipvlan_dbg(3, "%s[%d]: Leaving...\n", __func__, __LINE__);
+	return NOTIFY_OK;
+}
+
+static struct notifier_block ipvlan_addr4_notifier_block __read_mostly=
 =3D {
+	.notifier_call =3D ipvlan_addr4_event,
+};
+
+static struct notifier_block ipvlan_notifier_block __read_mostly =3D {
+	.notifier_call =3D ipvlan_device_event,
+};
+
+static struct notifier_block ipvlan_addr6_notifier_block __read_mostly=
 =3D {
+	.notifier_call =3D ipvlan_addr6_event,
+};
+
+static int __init ipvlan_init_module(void)
+{
+	int err;
+
+	ipvlan_init_secret();
+	register_netdevice_notifier(&ipvlan_notifier_block);
+	register_inet6addr_notifier(&ipvlan_addr6_notifier_block);
+	register_inetaddr_notifier(&ipvlan_addr4_notifier_block);
+
+	err =3D ipvlan_link_register(&ipvlan_link_ops);
+	if (err < 0)
+		goto error;
+
+	return 0;
+error:
+	unregister_inetaddr_notifier(&ipvlan_addr4_notifier_block);
+	unregister_inet6addr_notifier(&ipvlan_addr6_notifier_block);
+	unregister_netdevice_notifier(&ipvlan_notifier_block);
+	return err;
+}
+
+static void __exit ipvlan_cleanup_module(void)
+{
+	rtnl_link_unregister(&ipvlan_link_ops);
+	unregister_netdevice_notifier(&ipvlan_notifier_block);
+	unregister_inetaddr_notifier(&ipvlan_addr4_notifier_block);
+	unregister_inet6addr_notifier(&ipvlan_addr6_notifier_block);
+}
+
+module_init(ipvlan_init_module);
+module_exit(ipvlan_cleanup_module);
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Mahesh Bandewar <maheshb@google.com>");
+MODULE_DESCRIPTION("Driver for L3 (IPv6/IPv4) based VLANs");
+MODULE_ALIAS_RTNL_LINK("ipvlan");
diff --git a/drivers/net/ipvlan/ipvlan_sysfs.c b/drivers/net/ipvlan/ipv=
lan_sysfs.c
new file mode 100644
index 000000000000..ce0a6378d435
--- /dev/null
+++ b/drivers/net/ipvlan/ipvlan_sysfs.c
@@ -0,0 +1,119 @@
+/* Copyright (c) 2014 Mahesh Bandewar <maheshb@google.com>
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation; either version 2 of
+ * the License, or (at your option) any later version.
+ *
+ */
+
+#include "ipvlan.h"
+
+/* ---- SysFS entries ---- */
+#define port_of(ko)		container_of(ko, struct ipvl_port, kobj)
+#define ipvl_mode_attr_of(_a)	container_of(_a, struct ipvl_mode_attr, =
attr)
+
+
+/* -- For Master mode -- */
+struct ipvl_mode_attr {
+	struct attribute attr;
+	ssize_t (*show)(struct ipvl_port *port, char *buf);
+	ssize_t (*store)(struct ipvl_port *port, const char *buf, size_t len)=
;
+};
+
+static ssize_t ipvlan_show_mode(struct ipvl_port *port, char *buf)
+{
+	return sprintf(buf, "%hu\n", port->mode);
+}
+
+static ssize_t ipvlan_store_mode(struct ipvl_port *port,
+				 const char *buf, size_t count)
+{
+	int ret =3D count;
+	u16 nval;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (!port) {
+		ret =3D -EINVAL;
+		goto out;
+	}
+
+	if (sscanf(buf, "%hu", &nval) !=3D 1) {
+		pr_warn("%s: no mode specified.\n", port->dev->name);
+		ret =3D -EINVAL;
+		goto out;
+	}
+
+	if (nval !=3D 0 && nval !=3D 1) {
+		pr_warn("%s: mode value can only be 0 or 1.\n",
+			   port->dev->name);
+		ret =3D -EINVAL;
+		goto out;
+	}
+
+	ipvlan_set_port_mode(port, nval);
+
+out:
+	rtnl_unlock();
+	return ret;
+}
+
+static struct ipvl_mode_attr mode_attr =3D
+	__ATTR(mode, S_IRUGO | S_IWUSR, ipvlan_show_mode, ipvlan_store_mode);
+
+static struct attribute *ipvl_mode_attrs[] =3D {
+	&mode_attr.attr,
+	NULL
+};
+
+static ssize_t ipvlan_sysfs_show_mode(struct kobject *kobj,
+				      struct attribute *attr, char *buf)
+{
+	struct ipvl_mode_attr *attribute =3D ipvl_mode_attr_of(attr);
+	struct ipvl_port *port =3D port_of(kobj);
+
+	if (!attribute->show)
+		return -EIO;
+
+	return attribute->show(port, buf);
+}
+
+static ssize_t ipvlan_sysfs_store_mode(struct kobject *kobj,
+				       struct attribute *attr,
+				       const char *buf, size_t count)
+{
+	struct ipvl_mode_attr *attribute =3D ipvl_mode_attr_of(attr);
+	struct ipvl_port *port =3D port_of(kobj);
+
+	if (!attribute->store)
+		return -EIO;
+
+	return attribute->store(port, buf, count);
+}
+
+static struct sysfs_ops ipvl_mode_sysfs_ops =3D {
+	.show  =3D ipvlan_sysfs_show_mode,
+	.store =3D ipvlan_sysfs_store_mode,
+};
+
+static struct kobj_type ipvl_master_ktype =3D {
+#ifdef CONFIG_SYSFS
+	.sysfs_ops =3D &ipvl_mode_sysfs_ops,
+#endif
+	.default_attrs =3D ipvl_mode_attrs,
+};
+
+int ipvlan_add_per_master_sysfs_mode(struct ipvl_port *port,
+				     struct net_device *dev)
+{
+	return kobject_init_and_add(&port->kobj, &ipvl_master_ktype,
+			&(dev->dev.kobj), "ipvlan");
+}
+
+void ipvlan_del_per_master_sysfs_mode(struct ipvl_port *port)
+{
+		kobject_put(&port->kobj);
+}
+/* ---- END SysFS entries ---- */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index db63cf459ba1..c6bbc8d4b4f8 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1228,6 +1228,8 @@ enum netdev_priv_flags {
 	IFF_LIVE_ADDR_CHANGE		=3D 1<<20,
 	IFF_MACVLAN			=3D 1<<21,
 	IFF_XMIT_DST_RELEASE_PERM	=3D 1<<22,
+	IFF_IPVLAN_MASTER		=3D 1<<23,
+	IFF_IPVLAN_SLAVE		=3D 1<<24,
 };
=20
 #define IFF_802_1Q_VLAN			IFF_802_1Q_VLAN
@@ -1253,6 +1255,8 @@ enum netdev_priv_flags {
 #define IFF_LIVE_ADDR_CHANGE		IFF_LIVE_ADDR_CHANGE
 #define IFF_MACVLAN			IFF_MACVLAN
 #define IFF_XMIT_DST_RELEASE_PERM	IFF_XMIT_DST_RELEASE_PERM
+#define IFF_IPVLAN_MASTER		IFF_IPVLAN_MASTER
+#define IFF_IPVLAN_SLAVE		IFF_IPVLAN_SLAVE
=20
 /**
  *	struct net_device - The DEVICE structure.
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.=
h
index 7072d8325016..36bddc233633 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -330,6 +330,21 @@ enum macvlan_macaddr_mode {
=20
 #define MACVLAN_FLAG_NOPROMISC	1
=20
+/* IPVLAN section */
+enum {
+	IFLA_IPVLAN_UNSPEC,
+	IFLA_IPVLAN_MODE,
+	__IFLA_IPVLAN_MAX
+};
+
+#define IFLA_IPVLAN_MAX (__IFLA_IPVLAN_MAX - 1)
+
+enum ipvlan_mode {
+	IPVLAN_MODE_L2 =3D 0,
+	IPVLAN_MODE_L3,
+	IPVLAN_MODE_MAX
+};
+
 /* VXLAN section */
 enum {
 	IFLA_VXLAN_UNSPEC,
--=20
2.1.0.rc2.206.gedb03e5
