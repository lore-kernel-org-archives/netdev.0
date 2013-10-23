From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: [PATCH v5] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Wed, 23 Oct 2013 18:09:33 +0200
Message-ID: <5267F4BD.70409@xdin.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arvid Brodin <arvid.brodin@xdin.com>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Joe Perches <joe@perches.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>,
	=?ISO-8859-1?Q?El=EDas_Molina_Mu=F1oz?= <elias.molina@ehu.es>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:55678 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751294Ab3JWQJj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Oct 2013 12:09:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

High-availability Seamless Redundancy ("HSR") provides instant failover
redundancy for Ethernet networks. It requires a special network topolog=
y where
all nodes are connected in a ring (each node having two physical networ=
k
interfaces). It is suited for applications that demand high availabilit=
y and
very short reaction time.

HSR acts on the Ethernet layer, using a registered Ethernet protocol ty=
pe to
send special HSR frames in both directions over the ring. The driver cr=
eates
virtual network interfaces that can be used just like any ordinary Linu=
x
network interface, for IP/TCP/UDP traffic etc. All nodes in the network=
 ring
must be HSR capable.

This code is a "best effort" to comply with the HSR standard as describ=
ed in
IEC 62439-3:2010 (HSRv0).

Signed-off-by: Arvid Brodin <arvid.brodin@xdin.com>
---

This is a patch against net-next (2013-10-23).

The code has been statically analysed using sparse (no problems detecte=
d).

kmemleak has been used to detect memory leaks (no known leaks exist).

The code passes checkpatch.pl with the options --strict --max-line-leng=
th=3D83
except for CHECKs, which are all intentional; e.g. CamelCase is used in=
 the
IEC standard to describe field names, and these names have been used in=
 the
code.

The code has been tested extensively on rings of up to 32 avr32-based n=
odes.
Less intense testing has included an x86_64 (SMP) system, and running H=
SR
over a USB-to-Ethernet device.

Changes in v5:

* Tried to address the issues with aligning the skb header that was bro=
ught=20
  up by David Miller in v4. Fixed comment where true/false was called 1=
/0.

Changes in v4:

* Fixed racy test-and-modify lock for device operstate in __hsr_set_ope=
rstate().

Changes in v3:

* hsr_dev_open() no longer calls dev_open() on the HSR slave interfaces=
=2E
  This is to let user space decide how to treat any errors on slave ope=
n.
* is_operstate_up() is now called is_slave_up() and checks both admin
  state and operational state. Slaves going DOWN could otherwise be
  detected as still UP when HSR decided its own state.
* Files under net/ now have header comments that follow the network cod=
e
  standard.

Changes in v2:

* Aligned newlines with open parenthesis (Joe Perches)
* Removed unneccessary WARN_ON_ONCE from is_hsr_master() (Joe Perches)
* Removed deprecated comments about "actually signed" for HSR_A_IFn_AGE=
 (Joe Perches)
* Broke out userspace hsr_netlink.h into include/uapi/linux/ (Joe Perch=
es)
* Use netif_oper_up() to check for operational state UP (Stephen Hemmin=
ger)

Possibly unresolved:

* dev_base_lock vs rtnl_mutex when setting operstate? (Stephen Hemminge=
r)
  David Miller asked about this on 2013-09-03; no response.
* Move more (local) header files into include/net/? (checkpatch still w=
arns
  about CamelCase) (Joe Perches / with help from David Miller?)

Earlier RFC:s:
RFC v1: http://www.spinics.net/lists/netdev/msg192817.html
RFC v2: http://www.spinics.net/lists/netdev/msg203397.html
RFC v3: http://www.spinics.net/lists/netdev/msg207816.html
RFC v4: http://www.spinics.net/lists/netdev/msg213309.html

Thanks to Stephen Hemminger, Joe Perches, and others for their comments=
 on
these RFC:s.


 include/uapi/linux/hsr_netlink.h |  50 ++++
 include/uapi/linux/if_ether.h    |   1 +
 include/uapi/linux/if_link.h     |  13 +
 net/Kconfig                      |   1 +
 net/Makefile                     |   1 +
 net/hsr/Kconfig                  |  27 ++
 net/hsr/Makefile                 |   7 +
 net/hsr/hsr_device.c             | 594 +++++++++++++++++++++++++++++++=
++++++++
 net/hsr/hsr_device.h             |  29 ++
 net/hsr/hsr_framereg.c           | 501 +++++++++++++++++++++++++++++++=
++
 net/hsr/hsr_framereg.h           |  53 ++++
 net/hsr/hsr_main.c               | 469 +++++++++++++++++++++++++++++++
 net/hsr/hsr_main.h               | 166 +++++++++++
 net/hsr/hsr_netlink.c            | 457 ++++++++++++++++++++++++++++++
 net/hsr/hsr_netlink.h            |  30 ++
 15 files changed, 2399 insertions(+)
 create mode 100644 include/uapi/linux/hsr_netlink.h
 create mode 100644 net/hsr/Kconfig
 create mode 100644 net/hsr/Makefile
 create mode 100644 net/hsr/hsr_device.c
 create mode 100644 net/hsr/hsr_device.h
 create mode 100644 net/hsr/hsr_framereg.c
 create mode 100644 net/hsr/hsr_framereg.h
 create mode 100644 net/hsr/hsr_main.c
 create mode 100644 net/hsr/hsr_main.h
 create mode 100644 net/hsr/hsr_netlink.c
 create mode 100644 net/hsr/hsr_netlink.h

diff --git a/include/uapi/linux/hsr_netlink.h b/include/uapi/linux/hsr_=
netlink.h
new file mode 100644
index 0000000..2475cb8
--- /dev/null
+++ b/include/uapi/linux/hsr_netlink.h
@@ -0,0 +1,50 @@
+/*
+ * Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef __UAPI_HSR_NETLINK_H
+#define __UAPI_HSR_NETLINK_H
+
+/* Generic Netlink HSR family definition
+ */
+
+/* attributes */
+enum {
+	HSR_A_UNSPEC,
+	HSR_A_NODE_ADDR,
+	HSR_A_IFINDEX,
+	HSR_A_IF1_AGE,
+	HSR_A_IF2_AGE,
+	HSR_A_NODE_ADDR_B,
+	HSR_A_IF1_SEQ,
+	HSR_A_IF2_SEQ,
+	HSR_A_IF1_IFINDEX,
+	HSR_A_IF2_IFINDEX,
+	HSR_A_ADDR_B_IFINDEX,
+	__HSR_A_MAX,
+};
+#define HSR_A_MAX (__HSR_A_MAX - 1)
+
+
+/* commands */
+enum {
+	HSR_C_UNSPEC,
+	HSR_C_RING_ERROR,
+	HSR_C_NODE_DOWN,
+	HSR_C_GET_NODE_STATUS,
+	HSR_C_SET_NODE_STATUS,
+	HSR_C_GET_NODE_LIST,
+	HSR_C_SET_NODE_LIST,
+	__HSR_C_MAX,
+};
+#define HSR_C_MAX (__HSR_C_MAX - 1)
+
+#endif /* __UAPI_HSR_NETLINK_H */
diff --git a/include/uapi/linux/if_ether.h b/include/uapi/linux/if_ethe=
r.h
index ade07f1..2ce0f6a 100644
--- a/include/uapi/linux/if_ether.h
+++ b/include/uapi/linux/if_ether.h
@@ -85,6 +85,7 @@
 #define ETH_P_8021AH	0x88E7          /* 802.1ah Backbone Service Tag *=
/
 #define ETH_P_MVRP	0x88F5          /* 802.1Q MVRP                  */
 #define ETH_P_1588	0x88F7		/* IEEE 1588 Timesync */
+#define ETH_P_PRP	0x88FB		/* IEC 62439-3 PRP/HSRv0	*/
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_TDLS	0x890D          /* TDLS */
 #define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.=
h
index 8a1e346..b78566f 100644
--- a/include/uapi/linux/if_link.h
+++ b/include/uapi/linux/if_link.h
@@ -481,4 +481,17 @@ enum {
=20
 #define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)
=20
+
+/* HSR section */
+
+enum {
+	IFLA_HSR_UNSPEC,
+	IFLA_HSR_SLAVE1,
+	IFLA_HSR_SLAVE2,
+	IFLA_HSR_MULTICAST_SPEC,
+	__IFLA_HSR_MAX,
+};
+
+#define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
+
 #endif /* _UAPI_LINUX_IF_LINK_H */
diff --git a/net/Kconfig b/net/Kconfig
index b50dacc..0715db6 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -220,6 +220,7 @@ source "net/openvswitch/Kconfig"
 source "net/vmw_vsock/Kconfig"
 source "net/netlink/Kconfig"
 source "net/mpls/Kconfig"
+source "net/hsr/Kconfig"
=20
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index 9492e8c..8fa2f91 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -71,3 +71,4 @@ obj-$(CONFIG_NFC)		+=3D nfc/
 obj-$(CONFIG_OPENVSWITCH)	+=3D openvswitch/
 obj-$(CONFIG_VSOCKETS)	+=3D vmw_vsock/
 obj-$(CONFIG_NET_MPLS_GSO)	+=3D mpls/
+obj-$(CONFIG_HSR)		+=3D hsr/
diff --git a/net/hsr/Kconfig b/net/hsr/Kconfig
new file mode 100644
index 0000000..0d3d709
--- /dev/null
+++ b/net/hsr/Kconfig
@@ -0,0 +1,27 @@
+#
+# IEC 62439-3 High-availability Seamless Redundancy
+#
+
+config HSR
+	tristate "High-availability Seamless Redundancy (HSR)"
+	---help---
+	  If you say Y here, then your Linux box will be able to act as a
+	  DANH ("Doubly attached node implementing HSR"). For this to work,
+	  your Linux box needs (at least) two physical Ethernet interfaces,
+	  and it must be connected as a node in a ring network together with
+	  other HSR capable nodes.
+
+	  All Ethernet frames sent over the hsr device will be sent in both
+	  directions on the ring (over both slave ports), giving a redundant,
+	  instant fail-over network. Each HSR node in the ring acts like a
+	  bridge for HSR frames, but filters frames that have been forwarded
+	  earlier.
+
+	  This code is a "best effort" to comply with the HSR standard as
+	  described in IEC 62439-3:2010 (HSRv0), but no compliancy tests have
+	  been made.
+
+	  You need to perform any and all necessary tests yourself before
+	  relying on this code in a safety critical system!
+
+	  If unsure, say N.
diff --git a/net/hsr/Makefile b/net/hsr/Makefile
new file mode 100644
index 0000000..b68359f
--- /dev/null
+++ b/net/hsr/Makefile
@@ -0,0 +1,7 @@
+#
+# Makefile for HSR
+#
+
+obj-$(CONFIG_HSR)	+=3D hsr.o
+
+hsr-y			:=3D hsr_main.o hsr_framereg.o hsr_device.o hsr_netlink.o
diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
new file mode 100644
index 0000000..636d79d
--- /dev/null
+++ b/net/hsr/hsr_device.c
@@ -0,0 +1,594 @@
+/* Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *
+ * This file contains device methods for creating, using and destroyin=
g
+ * virtual HSR devices.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+#include <linux/rtnetlink.h>
+#include <linux/pkt_sched.h>
+#include "hsr_device.h"
+#include "hsr_framereg.h"
+#include "hsr_main.h"
+
+
+static bool is_admin_up(struct net_device *dev)
+{
+	return dev && (dev->flags & IFF_UP);
+}
+
+static bool is_slave_up(struct net_device *dev)
+{
+	return dev && is_admin_up(dev) && netif_oper_up(dev);
+}
+
+static void __hsr_set_operstate(struct net_device *dev, int transition=
)
+{
+	write_lock_bh(&dev_base_lock);
+	if (dev->operstate !=3D transition) {
+		dev->operstate =3D transition;
+		write_unlock_bh(&dev_base_lock);
+		netdev_state_change(dev);
+	} else {
+		write_unlock_bh(&dev_base_lock);
+	}
+}
+
+void hsr_set_operstate(struct net_device *hsr_dev, struct net_device *=
slave1,
+		       struct net_device *slave2)
+{
+	if (!is_admin_up(hsr_dev)) {
+		__hsr_set_operstate(hsr_dev, IF_OPER_DOWN);
+		return;
+	}
+
+	if (is_slave_up(slave1) || is_slave_up(slave2))
+		__hsr_set_operstate(hsr_dev, IF_OPER_UP);
+	else
+		__hsr_set_operstate(hsr_dev, IF_OPER_LOWERLAYERDOWN);
+}
+
+void hsr_set_carrier(struct net_device *hsr_dev, struct net_device *sl=
ave1,
+		     struct net_device *slave2)
+{
+	if (is_slave_up(slave1) || is_slave_up(slave2))
+		netif_carrier_on(hsr_dev);
+	else
+		netif_carrier_off(hsr_dev);
+}
+
+
+void hsr_check_announce(struct net_device *hsr_dev, int old_operstate)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv =3D netdev_priv(hsr_dev);
+
+	if ((hsr_dev->operstate =3D=3D IF_OPER_UP) && (old_operstate !=3D IF_=
OPER_UP)) {
+		/* Went up */
+		hsr_priv->announce_count =3D 0;
+		hsr_priv->announce_timer.expires =3D jiffies +
+				msecs_to_jiffies(HSR_ANNOUNCE_INTERVAL);
+		add_timer(&hsr_priv->announce_timer);
+	}
+
+	if ((hsr_dev->operstate !=3D IF_OPER_UP) && (old_operstate =3D=3D IF_=
OPER_UP))
+		/* Went down */
+		del_timer(&hsr_priv->announce_timer);
+}
+
+
+int hsr_get_max_mtu(struct hsr_priv *hsr_priv)
+{
+	int mtu_max;
+
+	if (hsr_priv->slave[0] && hsr_priv->slave[1])
+		mtu_max =3D min(hsr_priv->slave[0]->mtu, hsr_priv->slave[1]->mtu);
+	else if (hsr_priv->slave[0])
+		mtu_max =3D hsr_priv->slave[0]->mtu;
+	else if (hsr_priv->slave[1])
+		mtu_max =3D hsr_priv->slave[1]->mtu;
+	else
+		mtu_max =3D HSR_TAGLEN;
+
+	return mtu_max - HSR_TAGLEN;
+}
+
+static int hsr_dev_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv =3D netdev_priv(dev);
+
+	if (new_mtu > hsr_get_max_mtu(hsr_priv)) {
+		netdev_info(hsr_priv->dev, "A HSR master's MTU cannot be greater tha=
n the smallest MTU of its slaves minus the HSR Tag length (%d octets).\=
n",
+			    HSR_TAGLEN);
+		return -EINVAL;
+	}
+
+	dev->mtu =3D new_mtu;
+
+	return 0;
+}
+
+static int hsr_dev_open(struct net_device *dev)
+{
+	struct hsr_priv *hsr_priv;
+	int i;
+	char *slave_name;
+
+	hsr_priv =3D netdev_priv(dev);
+
+	for (i =3D 0; i < HSR_MAX_SLAVE; i++) {
+		if (hsr_priv->slave[i])
+			slave_name =3D hsr_priv->slave[i]->name;
+		else
+			slave_name =3D "null";
+
+		if (!is_slave_up(hsr_priv->slave[i]))
+			netdev_warn(dev, "Slave %c (%s) is not up; please bring it up to ge=
t a working HSR network\n",
+				    'A' + i, slave_name);
+	}
+
+	return 0;
+}
+
+static int hsr_dev_close(struct net_device *dev)
+{
+	/* Nothing to do here. We could try to restore the state of the slave=
s
+	 * to what they were before being changed by the hsr master dev's sta=
te,
+	 * but they might have been changed manually in the mean time too, so
+	 * taking them up or down here might be confusing and is probably not=
 a
+	 * good idea.
+	 */
+	return 0;
+}
+
+
+static void hsr_fill_tag(struct hsr_ethhdr *hsr_ethhdr, struct hsr_pri=
v *hsr_priv)
+{
+	unsigned long irqflags;
+
+	/* IEC 62439-1:2010, p 48, says the 4-bit "path" field can take value=
s
+	 * between 0001-1001 ("ring identifier", for regular HSR frames),
+	 * or 1111 ("HSR management", supervision frames). Unfortunately, the
+	 * spec writers forgot to explain what a "ring identifier" is, or
+	 * how it is used. So we just set this to 0001 for regular frames,
+	 * and 1111 for supervision frames.
+	 */
+	set_hsr_tag_path(&hsr_ethhdr->hsr_tag, 0x1);
+
+	/* IEC 62439-1:2010, p 12: "The link service data unit in an Ethernet
+	 * frame is the content of the frame located between the Length/Type
+	 * field and the Frame Check Sequence."
+	 *
+	 * IEC 62439-3, p 48, specifies the "original LPDU" to include the
+	 * original "LT" field (what "LT" means is not explained anywhere as
+	 * far as I can see - perhaps "Length/Type"?). So LSDU_size might
+	 * equal original length + 2.
+	 *   Also, the fact that this field is not used anywhere (might be us=
ed
+	 * by a RedBox connecting HSR and PRP nets?) means I cannot test its
+	 * correctness. Instead of guessing, I set this to 0 here, to make an=
y
+	 * problems immediately apparent. Anyone using this driver with PRP/H=
SR
+	 * RedBoxes might need to fix this...
+	 */
+	set_hsr_tag_LSDU_size(&hsr_ethhdr->hsr_tag, 0);
+
+	spin_lock_irqsave(&hsr_priv->seqnr_lock, irqflags);
+	hsr_ethhdr->hsr_tag.sequence_nr =3D htons(hsr_priv->sequence_nr);
+	hsr_priv->sequence_nr++;
+	spin_unlock_irqrestore(&hsr_priv->seqnr_lock, irqflags);
+
+	hsr_ethhdr->hsr_tag.encap_proto =3D hsr_ethhdr->ethhdr.h_proto;
+
+	hsr_ethhdr->ethhdr.h_proto =3D htons(ETH_P_PRP);
+}
+
+static int slave_xmit(struct sk_buff *skb, struct hsr_priv *hsr_priv,
+		      enum hsr_dev_idx dev_idx)
+{
+	struct hsr_ethhdr *hsr_ethhdr;
+
+	hsr_ethhdr =3D (struct hsr_ethhdr *) skb->data;
+
+	skb->dev =3D hsr_priv->slave[dev_idx];
+
+	hsr_addr_subst_dest(hsr_priv, &hsr_ethhdr->ethhdr, dev_idx);
+
+	/* Address substitution (IEC62439-3 pp 26, 50): replace mac
+	 * address of outgoing frame with that of the outgoing slave's.
+	 */
+	memcpy(hsr_ethhdr->ethhdr.h_source, skb->dev->dev_addr, ETH_ALEN);
+
+	return dev_queue_xmit(skb);
+}
+
+
+static int hsr_dev_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct hsr_priv *hsr_priv;
+	struct hsr_ethhdr *hsr_ethhdr;
+	struct sk_buff *skb2;
+	int res1, res2;
+
+	hsr_priv =3D netdev_priv(dev);
+	hsr_ethhdr =3D (struct hsr_ethhdr *) skb->data;
+
+	if ((skb->protocol !=3D htons(ETH_P_PRP)) ||
+	    (hsr_ethhdr->ethhdr.h_proto !=3D htons(ETH_P_PRP))) {
+		hsr_fill_tag(hsr_ethhdr, hsr_priv);
+		skb->protocol =3D htons(ETH_P_PRP);
+	}
+
+	skb2 =3D pskb_copy(skb, GFP_ATOMIC);
+
+	res1 =3D NET_XMIT_DROP;
+	if (likely(hsr_priv->slave[HSR_DEV_SLAVE_A]))
+		res1 =3D slave_xmit(skb, hsr_priv, HSR_DEV_SLAVE_A);
+
+	res2 =3D NET_XMIT_DROP;
+	if (likely(skb2 && hsr_priv->slave[HSR_DEV_SLAVE_B]))
+		res2 =3D slave_xmit(skb2, hsr_priv, HSR_DEV_SLAVE_B);
+
+	if (likely(res1 =3D=3D NET_XMIT_SUCCESS || res1 =3D=3D NET_XMIT_CN ||
+		   res2 =3D=3D NET_XMIT_SUCCESS || res2 =3D=3D NET_XMIT_CN)) {
+		hsr_priv->dev->stats.tx_packets++;
+		hsr_priv->dev->stats.tx_bytes +=3D skb->len;
+	} else {
+		hsr_priv->dev->stats.tx_dropped++;
+	}
+
+	return NETDEV_TX_OK;
+}
+
+
+static int hsr_header_create(struct sk_buff *skb, struct net_device *d=
ev,
+			     unsigned short type, const void *daddr,
+			     const void *saddr, unsigned int len)
+{
+	int res;
+
+	/* Make room for the HSR tag now. We will fill it in later (in
+	 * hsr_dev_xmit)
+	 */
+	if (skb_headroom(skb) < HSR_TAGLEN + ETH_HLEN)
+		return -ENOBUFS;
+	skb_push(skb, HSR_TAGLEN);
+
+	/* To allow VLAN/HSR combos we should probably use
+	 * res =3D dev_hard_header(skb, dev, type, daddr, saddr, len + HSR_TA=
GLEN);
+	 * here instead. It would require other changes too, though - e.g.
+	 * separate headers for each slave etc...
+	 */
+	res =3D eth_header(skb, dev, type, daddr, saddr, len + HSR_TAGLEN);
+	if (res <=3D 0)
+		return res;
+	skb_reset_mac_header(skb);
+
+	return res + HSR_TAGLEN;
+}
+
+
+static const struct header_ops hsr_header_ops =3D {
+	.create	 =3D hsr_header_create,
+	.parse	 =3D eth_header_parse,
+};
+
+
+/* HSR:2010 supervision frames should be padded so that the whole fram=
e,
+ * including headers and FCS, is 64 bytes (without VLAN).
+ */
+static int hsr_pad(int size)
+{
+	const int min_size =3D ETH_ZLEN - HSR_TAGLEN - ETH_HLEN;
+
+	if (size >=3D min_size)
+		return size;
+	return min_size;
+}
+
+static void send_hsr_supervision_frame(struct net_device *hsr_dev, u8 =
type)
+{
+	struct hsr_priv *hsr_priv;
+	struct sk_buff *skb;
+	int hlen, tlen;
+	struct hsr_sup_tag *hsr_stag;
+	struct hsr_sup_payload *hsr_sp;
+	unsigned long irqflags;
+
+	hlen =3D LL_RESERVED_SPACE(hsr_dev);
+	tlen =3D hsr_dev->needed_tailroom;
+	skb =3D alloc_skb(hsr_pad(sizeof(struct hsr_sup_payload)) + hlen + tl=
en,
+			GFP_ATOMIC);
+
+	if (skb =3D=3D NULL)
+		return;
+
+	hsr_priv =3D netdev_priv(hsr_dev);
+
+	skb_reserve(skb, hlen);
+
+	skb->dev =3D hsr_dev;
+	skb->protocol =3D htons(ETH_P_PRP);
+	skb->priority =3D TC_PRIO_CONTROL;
+
+	if (dev_hard_header(skb, skb->dev, ETH_P_PRP,
+			    hsr_priv->sup_multicast_addr,
+			    skb->dev->dev_addr, skb->len) < 0)
+		goto out;
+
+	skb_pull(skb, sizeof(struct ethhdr));
+	hsr_stag =3D (typeof(hsr_stag)) skb->data;
+
+	set_hsr_stag_path(hsr_stag, 0xf);
+	set_hsr_stag_HSR_Ver(hsr_stag, 0);
+
+	spin_lock_irqsave(&hsr_priv->seqnr_lock, irqflags);
+	hsr_stag->sequence_nr =3D htons(hsr_priv->sequence_nr);
+	hsr_priv->sequence_nr++;
+	spin_unlock_irqrestore(&hsr_priv->seqnr_lock, irqflags);
+
+	hsr_stag->HSR_TLV_Type =3D type;
+	hsr_stag->HSR_TLV_Length =3D 12;
+
+	skb_push(skb, sizeof(struct ethhdr));
+
+	/* Payload: MacAddressA */
+	hsr_sp =3D (typeof(hsr_sp)) skb_put(skb, sizeof(*hsr_sp));
+	memcpy(hsr_sp->MacAddressA, hsr_dev->dev_addr, ETH_ALEN);
+
+	dev_queue_xmit(skb);
+	return;
+
+out:
+	kfree_skb(skb);
+}
+
+
+/* Announce (supervision frame) timer function
+ */
+static void hsr_announce(unsigned long data)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv =3D (struct hsr_priv *) data;
+
+	if (hsr_priv->announce_count < 3) {
+		send_hsr_supervision_frame(hsr_priv->dev, HSR_TLV_ANNOUNCE);
+		hsr_priv->announce_count++;
+	} else {
+		send_hsr_supervision_frame(hsr_priv->dev, HSR_TLV_LIFE_CHECK);
+	}
+
+	if (hsr_priv->announce_count < 3)
+		hsr_priv->announce_timer.expires =3D jiffies +
+				msecs_to_jiffies(HSR_ANNOUNCE_INTERVAL);
+	else
+		hsr_priv->announce_timer.expires =3D jiffies +
+				msecs_to_jiffies(HSR_LIFE_CHECK_INTERVAL);
+
+	if (is_admin_up(hsr_priv->dev))
+		add_timer(&hsr_priv->announce_timer);
+}
+
+
+static void restore_slaves(struct net_device *hsr_dev)
+{
+	struct hsr_priv *hsr_priv;
+	int i;
+	int res;
+
+	hsr_priv =3D netdev_priv(hsr_dev);
+
+	rtnl_lock();
+
+	/* Restore promiscuity */
+	for (i =3D 0; i < 2; i++) {
+		if (!hsr_priv->slave[i])
+			continue;
+		res =3D dev_set_promiscuity(hsr_priv->slave[i], -1);
+		if (res)
+			netdev_info(hsr_dev, "Cannot restore slave promiscuity (%s, %d)\n",
+				    hsr_priv->slave[i]->name, res);
+	}
+
+	rtnl_unlock();
+}
+
+static void reclaim_hsr_dev(struct rcu_head *rh)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv =3D container_of(rh, struct hsr_priv, rcu_head);
+	free_netdev(hsr_priv->dev);
+}
+
+
+/* According to comments in the declaration of struct net_device, this=
 function
+ * is "Called from unregister, can be used to call free_netdev". Ok th=
en...
+ */
+static void hsr_dev_destroy(struct net_device *hsr_dev)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv =3D netdev_priv(hsr_dev);
+
+	del_timer(&hsr_priv->announce_timer);
+	unregister_hsr_master(hsr_priv);    /* calls list_del_rcu on hsr_priv=
 */
+	restore_slaves(hsr_dev);
+	call_rcu(&hsr_priv->rcu_head, reclaim_hsr_dev);   /* reclaim hsr_priv=
 */
+}
+
+static const struct net_device_ops hsr_device_ops =3D {
+	.ndo_change_mtu =3D hsr_dev_change_mtu,
+	.ndo_open =3D hsr_dev_open,
+	.ndo_stop =3D hsr_dev_close,
+	.ndo_start_xmit =3D hsr_dev_xmit,
+};
+
+
+void hsr_dev_setup(struct net_device *dev)
+{
+	random_ether_addr(dev->dev_addr);
+
+	ether_setup(dev);
+	dev->header_ops		 =3D &hsr_header_ops;
+	dev->netdev_ops		 =3D &hsr_device_ops;
+	dev->tx_queue_len	 =3D 0;
+
+	dev->destructor =3D hsr_dev_destroy;
+}
+
+
+/* Return true if dev is a HSR master; return false otherwise.
+ */
+bool is_hsr_master(struct net_device *dev)
+{
+	return (dev->netdev_ops->ndo_start_xmit =3D=3D hsr_dev_xmit);
+}
+
+static int check_slave_ok(struct net_device *dev)
+{
+	/* Don't allow HSR on non-ethernet like devices */
+	if ((dev->flags & IFF_LOOPBACK) || (dev->type !=3D ARPHRD_ETHER) ||
+	    (dev->addr_len !=3D ETH_ALEN)) {
+		netdev_info(dev, "Cannot use loopback or non-ethernet device as HSR =
slave.\n");
+		return -EINVAL;
+	}
+
+	/* Don't allow enslaving hsr devices */
+	if (is_hsr_master(dev)) {
+		netdev_info(dev, "Cannot create trees of HSR devices.\n");
+		return -EINVAL;
+	}
+
+	if (is_hsr_slave(dev)) {
+		netdev_info(dev, "This device is already a HSR slave.\n");
+		return -EINVAL;
+	}
+
+	if (dev->priv_flags & IFF_802_1Q_VLAN) {
+		netdev_info(dev, "HSR on top of VLAN is not yet supported in this dr=
iver.\n");
+		return -EINVAL;
+	}
+
+	/* HSR over bonded devices has not been tested, but I'm not sure it
+	 * won't work...
+	 */
+
+	return 0;
+}
+
+
+/* Default multicast address for HSR Supervision frames */
+static const unsigned char def_multicast_addr[ETH_ALEN] =3D {
+	0x01, 0x15, 0x4e, 0x00, 0x01, 0x00
+};
+
+int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *sl=
ave[2],
+		     unsigned char multicast_spec)
+{
+	struct hsr_priv *hsr_priv;
+	int i;
+	int res;
+
+	hsr_priv =3D netdev_priv(hsr_dev);
+	hsr_priv->dev =3D hsr_dev;
+	INIT_LIST_HEAD(&hsr_priv->node_db);
+	INIT_LIST_HEAD(&hsr_priv->self_node_db);
+	for (i =3D 0; i < 2; i++)
+		hsr_priv->slave[i] =3D slave[i];
+
+	spin_lock_init(&hsr_priv->seqnr_lock);
+	/* Overflow soon to find bugs easier: */
+	hsr_priv->sequence_nr =3D USHRT_MAX - 1024;
+
+	init_timer(&hsr_priv->announce_timer);
+	hsr_priv->announce_timer.function =3D hsr_announce;
+	hsr_priv->announce_timer.data =3D (unsigned long) hsr_priv;
+
+	memcpy(hsr_priv->sup_multicast_addr, def_multicast_addr, ETH_ALEN);
+	hsr_priv->sup_multicast_addr[ETH_ALEN - 1] =3D multicast_spec;
+
+/* FIXME: should I modify the value of these?
+ *
+ * - hsr_dev->flags - i.e.
+ *			IFF_MASTER/SLAVE?
+ * - hsr_dev->priv_flags - i.e.
+ *			IFF_EBRIDGE?
+ *			IFF_TX_SKB_SHARING?
+ *			IFF_HSR_MASTER/SLAVE?
+ */
+
+	for (i =3D 0; i < 2; i++) {
+		res =3D check_slave_ok(slave[i]);
+		if (res)
+			return res;
+	}
+
+	hsr_dev->features =3D slave[0]->features & slave[1]->features;
+	/* Prevent recursive tx locking */
+	hsr_dev->features |=3D NETIF_F_LLTX;
+	/* VLAN on top of HSR needs testing and probably some work on
+	 * hsr_header_create() etc.
+	 */
+	hsr_dev->features |=3D NETIF_F_VLAN_CHALLENGED;
+
+	/* Set hsr_dev's MAC address to that of mac_slave1 */
+	memcpy(hsr_dev->dev_addr, hsr_priv->slave[0]->dev_addr, ETH_ALEN);
+
+	/* Set required header length */
+	for (i =3D 0; i < 2; i++)
+		if (slave[i]->hard_header_len + HSR_TAGLEN >
+						hsr_dev->hard_header_len)
+			hsr_dev->hard_header_len =3D
+					slave[i]->hard_header_len + HSR_TAGLEN;
+
+	/* MTU */
+	for (i =3D 0; i < 2; i++)
+		if (slave[i]->mtu - HSR_TAGLEN < hsr_dev->mtu)
+			hsr_dev->mtu =3D slave[i]->mtu - HSR_TAGLEN;
+
+	/* Make sure the 1st call to netif_carrier_on() gets through */
+	netif_carrier_off(hsr_dev);
+
+	/* Promiscuity */
+	for (i =3D 0; i < 2; i++) {
+		res =3D dev_set_promiscuity(slave[i], 1);
+		if (res) {
+			netdev_info(hsr_dev, "Cannot set slave promiscuity (%s, %d)\n",
+				    slave[i]->name, res);
+			goto fail;
+		}
+	}
+
+	/* Make sure we recognize frames from ourselves in hsr_rcv() */
+	res =3D hsr_create_self_node(&hsr_priv->self_node_db,
+					hsr_dev->dev_addr,
+					hsr_priv->slave[1]->dev_addr);
+	if (res < 0)
+		goto fail;
+
+	res =3D register_netdevice(hsr_dev);
+	if (res)
+		goto fail;
+
+	register_hsr_master(hsr_priv);
+
+	return 0;
+
+fail:
+	restore_slaves(hsr_dev);
+	return res;
+}
diff --git a/net/hsr/hsr_device.h b/net/hsr/hsr_device.h
new file mode 100644
index 0000000..2c7148e
--- /dev/null
+++ b/net/hsr/hsr_device.h
@@ -0,0 +1,29 @@
+/* Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef __HSR_DEVICE_H
+#define __HSR_DEVICE_H
+
+#include <linux/netdevice.h>
+#include "hsr_main.h"
+
+void hsr_dev_setup(struct net_device *dev);
+int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *sl=
ave[2],
+		     unsigned char multicast_spec);
+void hsr_set_operstate(struct net_device *hsr_dev, struct net_device *=
slave1,
+		       struct net_device *slave2);
+void hsr_set_carrier(struct net_device *hsr_dev, struct net_device *sl=
ave1,
+		     struct net_device *slave2);
+void hsr_check_announce(struct net_device *hsr_dev, int old_operstate)=
;
+bool is_hsr_master(struct net_device *dev);
+int hsr_get_max_mtu(struct hsr_priv *hsr_priv);
+
+#endif /* __HSR_DEVICE_H */
diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
new file mode 100644
index 0000000..fbcd7fc
--- /dev/null
+++ b/net/hsr/hsr_framereg.c
@@ -0,0 +1,501 @@
+/* Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *
+ * The HSR spec says never to forward the same frame twice on the same
+ * interface. A frame is identified by its source MAC address and its =
HSR
+ * sequence number. This code keeps track of senders and their sequenc=
e numbers
+ * to allow filtering of duplicate frames, and to detect HSR ring erro=
rs.
+ */
+
+#include <linux/if_ether.h>
+#include <linux/etherdevice.h>
+#include <linux/slab.h>
+#include <linux/rculist.h>
+#include "hsr_main.h"
+#include "hsr_framereg.h"
+#include "hsr_netlink.h"
+
+
+struct node_entry {
+	struct list_head mac_list;
+	unsigned char	MacAddressA[ETH_ALEN];
+	unsigned char	MacAddressB[ETH_ALEN];
+	enum hsr_dev_idx   AddrB_if;	/* The local slave through which AddrB
+					 * frames are received from this node
+					 */
+	unsigned long	time_in[HSR_MAX_SLAVE];
+	bool		time_in_stale[HSR_MAX_SLAVE];
+	u16		seq_out[HSR_MAX_DEV];
+	struct rcu_head rcu_head;
+};
+
+/*	TODO: use hash lists for mac addresses (linux/jhash.h)?    */
+
+
+
+/* Search for mac entry. Caller must hold rcu read lock.
+ */
+static struct node_entry *find_node_by_AddrA(struct list_head *node_db=
,
+					     const unsigned char addr[ETH_ALEN])
+{
+	struct node_entry *node;
+
+	list_for_each_entry_rcu(node, node_db, mac_list) {
+		if (!compare_ether_addr(node->MacAddressA, addr))
+			return node;
+	}
+
+	return NULL;
+}
+
+
+/* Search for mac entry. Caller must hold rcu read lock.
+ */
+static struct node_entry *find_node_by_AddrB(struct list_head *node_db=
,
+					     const unsigned char addr[ETH_ALEN])
+{
+	struct node_entry *node;
+
+	list_for_each_entry_rcu(node, node_db, mac_list) {
+		if (!compare_ether_addr(node->MacAddressB, addr))
+			return node;
+	}
+
+	return NULL;
+}
+
+
+/* Search for mac entry. Caller must hold rcu read lock.
+ */
+struct node_entry *hsr_find_node(struct list_head *node_db, struct sk_=
buff *skb)
+{
+	struct node_entry *node;
+	struct ethhdr *ethhdr;
+
+	if (!skb_mac_header_was_set(skb))
+		return NULL;
+
+	ethhdr =3D (struct ethhdr *) skb_mac_header(skb);
+
+	list_for_each_entry_rcu(node, node_db, mac_list) {
+		if (!compare_ether_addr(node->MacAddressA, ethhdr->h_source))
+			return node;
+		if (!compare_ether_addr(node->MacAddressB, ethhdr->h_source))
+			return node;
+	}
+
+	return NULL;
+}
+
+
+/* Helper for device init; the self_node_db is used in hsr_rcv() to re=
cognize
+ * frames from self that's been looped over the HSR ring.
+ */
+int hsr_create_self_node(struct list_head *self_node_db,
+			 unsigned char addr_a[ETH_ALEN],
+			 unsigned char addr_b[ETH_ALEN])
+{
+	struct node_entry *node, *oldnode;
+
+	node =3D kmalloc(sizeof(*node), GFP_KERNEL);
+	if (!node)
+		return -ENOMEM;
+
+	memcpy(node->MacAddressA, addr_a, ETH_ALEN);
+	memcpy(node->MacAddressB, addr_b, ETH_ALEN);
+
+	rcu_read_lock();
+	oldnode =3D list_first_or_null_rcu(self_node_db,
+						struct node_entry, mac_list);
+	if (oldnode) {
+		list_replace_rcu(&oldnode->mac_list, &node->mac_list);
+		rcu_read_unlock();
+		synchronize_rcu();
+		kfree(oldnode);
+	} else {
+		rcu_read_unlock();
+		list_add_tail_rcu(&node->mac_list, self_node_db);
+	}
+
+	return 0;
+}
+
+static void node_entry_reclaim(struct rcu_head *rh)
+{
+	kfree(container_of(rh, struct node_entry, rcu_head));
+}
+
+
+/* Add/merge node to the database of nodes. 'skb' must contain an HSR
+ * supervision frame.
+ * - If the supervision header's MacAddressA field is not yet in the d=
atabase,
+ * this frame is from an hitherto unknown node - add it to the databas=
e.
+ * - If the sender's MAC address is not the same as its MacAddressA ad=
dress,
+ * the node is using PICS_SUBS (address substitution). Record the send=
er's
+ * address as the node's MacAddressB.
+ *
+ * This function needs to work even if the sender node has changed one=
 of its
+ * slaves' MAC addresses. In this case, there are four different cases=
 described
+ * by (Addr-changed, received-from) pairs as follows. Note that changi=
ng the
+ * SlaveA address is equal to changing the node's own address:
+ *
+ * - (AddrB, SlaveB): The new AddrB will be recorded by PICS_SUBS code=
 since
+ *		      node =3D=3D NULL.
+ * - (AddrB, SlaveA): Will work as usual (the AddrB change won't be de=
tected
+ *		      from this frame).
+ *
+ * - (AddrA, SlaveB): The old node will be found. We need to detect th=
is and
+ *		      remove the node.
+ * - (AddrA, SlaveA): A new node will be registered (non-PICS_SUBS at =
first).
+ *		      The old one will be pruned after HSR_NODE_FORGET_TIME.
+ *
+ * We also need to detect if the sender's SlaveA and SlaveB cables hav=
e been
+ * swapped.
+ */
+struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
+				  struct node_entry *node,
+				  struct sk_buff *skb,
+				  enum hsr_dev_idx dev_idx)
+{
+	struct hsr_sup_payload *hsr_sp;
+	struct hsr_ethhdr_sp *hsr_ethsup;
+	int i;
+	unsigned long now;
+
+	hsr_ethsup =3D (struct hsr_ethhdr_sp *) skb_mac_header(skb);
+	hsr_sp =3D (struct hsr_sup_payload *) skb->data;
+
+	if (node && compare_ether_addr(node->MacAddressA, hsr_sp->MacAddressA=
)) {
+		/* Node has changed its AddrA, frame was received from SlaveB */
+		list_del_rcu(&node->mac_list);
+		call_rcu(&node->rcu_head, node_entry_reclaim);
+		node =3D NULL;
+	}
+
+	if (node && (dev_idx =3D=3D node->AddrB_if) &&
+	    compare_ether_addr(node->MacAddressB, hsr_ethsup->ethhdr.h_source=
)) {
+		/* Cables have been swapped */
+		list_del_rcu(&node->mac_list);
+		call_rcu(&node->rcu_head, node_entry_reclaim);
+		node =3D NULL;
+	}
+
+	if (node && (dev_idx !=3D node->AddrB_if) &&
+	    (node->AddrB_if !=3D HSR_DEV_NONE) &&
+	    compare_ether_addr(node->MacAddressA, hsr_ethsup->ethhdr.h_source=
)) {
+		/* Cables have been swapped */
+		list_del_rcu(&node->mac_list);
+		call_rcu(&node->rcu_head, node_entry_reclaim);
+		node =3D NULL;
+	}
+
+	if (node)
+		return node;
+
+	node =3D find_node_by_AddrA(&hsr_priv->node_db, hsr_sp->MacAddressA);
+	if (node) {
+		/* Node is known, but frame was received from an unknown
+		 * address. Node is PICS_SUBS capable; merge its AddrB.
+		 */
+		memcpy(node->MacAddressB, hsr_ethsup->ethhdr.h_source, ETH_ALEN);
+		node->AddrB_if =3D dev_idx;
+		return node;
+	}
+
+	node =3D kzalloc(sizeof(*node), GFP_ATOMIC);
+	if (!node)
+		return NULL;
+
+	memcpy(node->MacAddressA, hsr_sp->MacAddressA, ETH_ALEN);
+	memcpy(node->MacAddressB, hsr_ethsup->ethhdr.h_source, ETH_ALEN);
+	if (compare_ether_addr(hsr_sp->MacAddressA, hsr_ethsup->ethhdr.h_sour=
ce))
+		node->AddrB_if =3D dev_idx;
+	else
+		node->AddrB_if =3D HSR_DEV_NONE;
+
+	/* We are only interested in time diffs here, so use current jiffies
+	 * as initialization. (0 could trigger an spurious ring error warning=
).
+	 */
+	now =3D jiffies;
+	for (i =3D 0; i < HSR_MAX_SLAVE; i++)
+		node->time_in[i] =3D now;
+	for (i =3D 0; i < HSR_MAX_DEV; i++)
+		node->seq_out[i] =3D ntohs(hsr_ethsup->hsr_sup.sequence_nr) - 1;
+
+	list_add_tail_rcu(&node->mac_list, &hsr_priv->node_db);
+
+	return node;
+}
+
+
+/* 'skb' is a frame meant for this host, that is to be passed to upper=
 layers.
+ *
+ * If the frame was sent by a node's B interface, replace the sender
+ * address with that node's "official" address (MacAddressA) so that u=
pper
+ * layers recognize where it came from.
+ */
+void hsr_addr_subst_source(struct hsr_priv *hsr_priv, struct sk_buff *=
skb)
+{
+	struct ethhdr *ethhdr;
+	struct node_entry *node;
+
+	if (!skb_mac_header_was_set(skb)) {
+		WARN_ONCE(1, "%s: Mac header not set\n", __func__);
+		return;
+	}
+	ethhdr =3D (struct ethhdr *) skb_mac_header(skb);
+
+	rcu_read_lock();
+	node =3D find_node_by_AddrB(&hsr_priv->node_db, ethhdr->h_source);
+	if (node)
+		memcpy(ethhdr->h_source, node->MacAddressA, ETH_ALEN);
+	rcu_read_unlock();
+}
+
+
+/* 'skb' is a frame meant for another host.
+ * 'hsr_dev_idx' is the HSR index of the outgoing device
+ *
+ * Substitute the target (dest) MAC address if necessary, so the it ma=
tches the
+ * recipient interface MAC address, regardless of whether that is the
+ * recipient's A or B interface.
+ * This is needed to keep the packets flowing through switches that le=
arn on
+ * which "side" the different interfaces are.
+ */
+void hsr_addr_subst_dest(struct hsr_priv *hsr_priv, struct ethhdr *eth=
hdr,
+			 enum hsr_dev_idx dev_idx)
+{
+	struct node_entry *node;
+
+	rcu_read_lock();
+	node =3D find_node_by_AddrA(&hsr_priv->node_db, ethhdr->h_dest);
+	if (node && (node->AddrB_if =3D=3D dev_idx))
+		memcpy(ethhdr->h_dest, node->MacAddressB, ETH_ALEN);
+	rcu_read_unlock();
+}
+
+
+/* above(a, b) - return 1 if a > b, 0 otherwise.
+ */
+static bool above(u16 a, u16 b)
+{
+	/* Remove inconsistency where above(a, b) =3D=3D below(a, b) */
+	if ((int) b - a =3D=3D 32768)
+		return 0;
+
+	return (((s16) (b - a)) < 0);
+}
+#define below(a, b)		above((b), (a))
+#define above_or_eq(a, b)	(!below((a), (b)))
+#define below_or_eq(a, b)	(!above((a), (b)))
+
+
+void hsr_register_frame_in(struct node_entry *node, enum hsr_dev_idx d=
ev_idx)
+{
+	if ((dev_idx < 0) || (dev_idx >=3D HSR_MAX_DEV)) {
+		WARN_ONCE(1, "%s: Invalid dev_idx (%d)\n", __func__, dev_idx);
+		return;
+	}
+	node->time_in[dev_idx] =3D jiffies;
+	node->time_in_stale[dev_idx] =3D 0;
+}
+
+
+/* 'skb' is a HSR Ethernet frame (with a HSR tag inserted), with a val=
id
+ * ethhdr->h_source address and skb->mac_header set.
+ *
+ * Return:
+ *	 1 if frame can be shown to have been sent recently on this interfa=
ce,
+ *	 0 otherwise, or
+ *	 negative error code on error
+ */
+int hsr_register_frame_out(struct node_entry *node, enum hsr_dev_idx d=
ev_idx,
+			   struct sk_buff *skb)
+{
+	struct hsr_ethhdr *hsr_ethhdr;
+	u16 sequence_nr;
+
+	if ((dev_idx < 0) || (dev_idx >=3D HSR_MAX_DEV)) {
+		WARN_ONCE(1, "%s: Invalid dev_idx (%d)\n", __func__, dev_idx);
+		return -EINVAL;
+	}
+	if (!skb_mac_header_was_set(skb)) {
+		WARN_ONCE(1, "%s: Mac header not set\n", __func__);
+		return -EINVAL;
+	}
+	hsr_ethhdr =3D (struct hsr_ethhdr *) skb_mac_header(skb);
+
+	sequence_nr =3D ntohs(hsr_ethhdr->hsr_tag.sequence_nr);
+	if (below_or_eq(sequence_nr, node->seq_out[dev_idx]))
+		return 1;
+
+	node->seq_out[dev_idx] =3D sequence_nr;
+	return 0;
+}
+
+
+
+static bool is_late(struct node_entry *node, enum hsr_dev_idx dev_idx)
+{
+	enum hsr_dev_idx other;
+
+	if (node->time_in_stale[dev_idx])
+		return 1;
+
+	if (dev_idx =3D=3D HSR_DEV_SLAVE_A)
+		other =3D HSR_DEV_SLAVE_B;
+	else
+		other =3D HSR_DEV_SLAVE_A;
+
+	if (node->time_in_stale[other])
+		return 0;
+
+	if (time_after(node->time_in[other], node->time_in[dev_idx] +
+		       msecs_to_jiffies(MAX_SLAVE_DIFF)))
+		return 1;
+
+	return 0;
+}
+
+
+/* Remove stale sequence_nr records. Called by timer every
+ * HSR_LIFE_CHECK_INTERVAL (two seconds or so).
+ */
+void hsr_prune_nodes(struct hsr_priv *hsr_priv)
+{
+	struct node_entry *node;
+	unsigned long timestamp;
+	unsigned long time_a, time_b;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(node, &hsr_priv->node_db, mac_list) {
+		/* Shorthand */
+		time_a =3D node->time_in[HSR_DEV_SLAVE_A];
+		time_b =3D node->time_in[HSR_DEV_SLAVE_B];
+
+		/* Check for timestamps old enough to risk wrap-around */
+		if (time_after(jiffies, time_a + MAX_JIFFY_OFFSET/2))
+			node->time_in_stale[HSR_DEV_SLAVE_A] =3D 1;
+		if (time_after(jiffies, time_b + MAX_JIFFY_OFFSET/2))
+			node->time_in_stale[HSR_DEV_SLAVE_B] =3D 1;
+
+		/* Get age of newest frame from node.
+		 * At least one time_in is OK here; nodes get pruned long
+		 * before both time_ins can get stale
+		 */
+		timestamp =3D time_a;
+		if (node->time_in_stale[HSR_DEV_SLAVE_A] ||
+		    (!node->time_in_stale[HSR_DEV_SLAVE_B] &&
+		    time_after(time_b, time_a)))
+			timestamp =3D time_b;
+
+		/* Warn of ring error only as long as we get frames at all */
+		if (time_is_after_jiffies(timestamp +
+					msecs_to_jiffies(1.5*MAX_SLAVE_DIFF))) {
+
+			if (is_late(node, HSR_DEV_SLAVE_A))
+				hsr_nl_ringerror(hsr_priv, node->MacAddressA,
+						 HSR_DEV_SLAVE_A);
+			else if (is_late(node, HSR_DEV_SLAVE_B))
+				hsr_nl_ringerror(hsr_priv, node->MacAddressA,
+						 HSR_DEV_SLAVE_B);
+		}
+
+		/* Prune old entries */
+		if (time_is_before_jiffies(timestamp +
+					msecs_to_jiffies(HSR_NODE_FORGET_TIME))) {
+			hsr_nl_nodedown(hsr_priv, node->MacAddressA);
+			list_del_rcu(&node->mac_list);
+			/* Note that we need to free this entry later: */
+			call_rcu(&node->rcu_head, node_entry_reclaim);
+		}
+	}
+	rcu_read_unlock();
+}
+
+
+void *hsr_get_next_node(struct hsr_priv *hsr_priv, void *_pos,
+			unsigned char addr[ETH_ALEN])
+{
+	struct node_entry *node;
+
+	if (!_pos) {
+		node =3D list_first_or_null_rcu(&hsr_priv->node_db,
+						struct node_entry, mac_list);
+		if (node)
+			memcpy(addr, node->MacAddressA, ETH_ALEN);
+		return node;
+	}
+
+	node =3D _pos;
+	list_for_each_entry_continue_rcu(node, &hsr_priv->node_db, mac_list) =
{
+		memcpy(addr, node->MacAddressA, ETH_ALEN);
+		return node;
+	}
+
+	return NULL;
+}
+
+
+int hsr_get_node_data(struct hsr_priv *hsr_priv,
+		      const unsigned char *addr,
+		      unsigned char addr_b[ETH_ALEN],
+		      unsigned int *addr_b_ifindex,
+		      int *if1_age,
+		      u16 *if1_seq,
+		      int *if2_age,
+		      u16 *if2_seq)
+{
+	struct node_entry *node;
+	unsigned long tdiff;
+
+
+	rcu_read_lock();
+	node =3D find_node_by_AddrA(&hsr_priv->node_db, addr);
+	if (!node) {
+		rcu_read_unlock();
+		return -ENOENT;	/* No such entry */
+	}
+
+	memcpy(addr_b, node->MacAddressB, ETH_ALEN);
+
+	tdiff =3D jiffies - node->time_in[HSR_DEV_SLAVE_A];
+	if (node->time_in_stale[HSR_DEV_SLAVE_A])
+		*if1_age =3D INT_MAX;
+#if HZ <=3D MSEC_PER_SEC
+	else if (tdiff > msecs_to_jiffies(INT_MAX))
+		*if1_age =3D INT_MAX;
+#endif
+	else
+		*if1_age =3D jiffies_to_msecs(tdiff);
+
+	tdiff =3D jiffies - node->time_in[HSR_DEV_SLAVE_B];
+	if (node->time_in_stale[HSR_DEV_SLAVE_B])
+		*if2_age =3D INT_MAX;
+#if HZ <=3D MSEC_PER_SEC
+	else if (tdiff > msecs_to_jiffies(INT_MAX))
+		*if2_age =3D INT_MAX;
+#endif
+	else
+		*if2_age =3D jiffies_to_msecs(tdiff);
+
+	/* Present sequence numbers as if they were incoming on interface */
+	*if1_seq =3D node->seq_out[HSR_DEV_SLAVE_B];
+	*if2_seq =3D node->seq_out[HSR_DEV_SLAVE_A];
+
+	if ((node->AddrB_if !=3D HSR_DEV_NONE) && hsr_priv->slave[node->AddrB=
_if])
+		*addr_b_ifindex =3D hsr_priv->slave[node->AddrB_if]->ifindex;
+	else
+		*addr_b_ifindex =3D -1;
+
+	rcu_read_unlock();
+
+	return 0;
+}
diff --git a/net/hsr/hsr_framereg.h b/net/hsr/hsr_framereg.h
new file mode 100644
index 0000000..e6c4022
--- /dev/null
+++ b/net/hsr/hsr_framereg.h
@@ -0,0 +1,53 @@
+/* Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef _HSR_FRAMEREG_H
+#define _HSR_FRAMEREG_H
+
+#include "hsr_main.h"
+
+struct node_entry;
+
+struct node_entry *hsr_find_node(struct list_head *node_db, struct sk_=
buff *skb);
+
+struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
+				  struct node_entry *node,
+				  struct sk_buff *skb,
+				  enum hsr_dev_idx dev_idx);
+
+void hsr_addr_subst_source(struct hsr_priv *hsr_priv, struct sk_buff *=
skb);
+void hsr_addr_subst_dest(struct hsr_priv *hsr_priv, struct ethhdr *eth=
hdr,
+			 enum hsr_dev_idx dev_idx);
+
+void hsr_register_frame_in(struct node_entry *node, enum hsr_dev_idx d=
ev_idx);
+
+int hsr_register_frame_out(struct node_entry *node, enum hsr_dev_idx d=
ev_idx,
+			   struct sk_buff *skb);
+
+void hsr_prune_nodes(struct hsr_priv *hsr_priv);
+
+int hsr_create_self_node(struct list_head *self_node_db,
+			 unsigned char addr_a[ETH_ALEN],
+			 unsigned char addr_b[ETH_ALEN]);
+
+void *hsr_get_next_node(struct hsr_priv *hsr_priv, void *_pos,
+			unsigned char addr[ETH_ALEN]);
+
+int hsr_get_node_data(struct hsr_priv *hsr_priv,
+		      const unsigned char *addr,
+		      unsigned char addr_b[ETH_ALEN],
+		      unsigned int *addr_b_ifindex,
+		      int *if1_age,
+		      u16 *if1_seq,
+		      int *if2_age,
+		      u16 *if2_seq);
+
+#endif /* _HSR_FRAMEREG_H */
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
new file mode 100644
index 0000000..b08197d
--- /dev/null
+++ b/net/hsr/hsr_main.c
@@ -0,0 +1,469 @@
+/* Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *
+ * In addition to routines for registering and unregistering HSR suppo=
rt, this
+ * file also contains the receive routine that handles all incoming fr=
ames with
+ * Ethertype (protocol) ETH_P_PRP (HSRv0), and network device event ha=
ndling.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/rculist.h>
+#include <linux/timer.h>
+#include <linux/etherdevice.h>
+#include "hsr_main.h"
+#include "hsr_device.h"
+#include "hsr_netlink.h"
+#include "hsr_framereg.h"
+
+
+/* List of all registered virtual HSR devices */
+static LIST_HEAD(hsr_list);
+
+void register_hsr_master(struct hsr_priv *hsr_priv)
+{
+	list_add_tail_rcu(&hsr_priv->hsr_list, &hsr_list);
+}
+
+void unregister_hsr_master(struct hsr_priv *hsr_priv)
+{
+	struct hsr_priv *hsr_priv_it;
+
+	list_for_each_entry(hsr_priv_it, &hsr_list, hsr_list)
+		if (hsr_priv_it =3D=3D hsr_priv) {
+			list_del_rcu(&hsr_priv_it->hsr_list);
+			return;
+		}
+}
+
+bool is_hsr_slave(struct net_device *dev)
+{
+	struct hsr_priv *hsr_priv_it;
+
+	list_for_each_entry_rcu(hsr_priv_it, &hsr_list, hsr_list) {
+		if (dev =3D=3D hsr_priv_it->slave[0])
+			return true;
+		if (dev =3D=3D hsr_priv_it->slave[1])
+			return true;
+	}
+
+	return false;
+}
+
+
+/* If dev is a HSR slave device, return the virtual master device. Ret=
urn NULL
+ * otherwise.
+ */
+static struct hsr_priv *get_hsr_master(struct net_device *dev)
+{
+	struct hsr_priv *hsr_priv;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hsr_priv, &hsr_list, hsr_list)
+		if ((dev =3D=3D hsr_priv->slave[0]) ||
+		    (dev =3D=3D hsr_priv->slave[1])) {
+			rcu_read_unlock();
+			return hsr_priv;
+		}
+
+	rcu_read_unlock();
+	return NULL;
+}
+
+
+/* If dev is a HSR slave device, return the other slave device. Return=
 NULL
+ * otherwise.
+ */
+static struct net_device *get_other_slave(struct hsr_priv *hsr_priv,
+					  struct net_device *dev)
+{
+	if (dev =3D=3D hsr_priv->slave[0])
+		return hsr_priv->slave[1];
+	if (dev =3D=3D hsr_priv->slave[1])
+		return hsr_priv->slave[0];
+
+	return NULL;
+}
+
+
+static int hsr_netdev_notify(struct notifier_block *nb, unsigned long =
event,
+			     void *ptr)
+{
+	struct net_device *slave, *other_slave;
+	struct hsr_priv *hsr_priv;
+	int old_operstate;
+	int mtu_max;
+	int res;
+	struct net_device *dev;
+
+	dev =3D netdev_notifier_info_to_dev(ptr);
+
+	hsr_priv =3D get_hsr_master(dev);
+	if (hsr_priv) {
+		/* dev is a slave device */
+		slave =3D dev;
+		other_slave =3D get_other_slave(hsr_priv, slave);
+	} else {
+		if (!is_hsr_master(dev))
+			return NOTIFY_DONE;
+		hsr_priv =3D netdev_priv(dev);
+		slave =3D hsr_priv->slave[0];
+		other_slave =3D hsr_priv->slave[1];
+	}
+
+	switch (event) {
+	case NETDEV_UP:		/* Administrative state DOWN */
+	case NETDEV_DOWN:	/* Administrative state UP */
+	case NETDEV_CHANGE:	/* Link (carrier) state changes */
+		old_operstate =3D hsr_priv->dev->operstate;
+		hsr_set_carrier(hsr_priv->dev, slave, other_slave);
+		/* netif_stacked_transfer_operstate() cannot be used here since
+		 * it doesn't set IF_OPER_LOWERLAYERDOWN (?)
+		 */
+		hsr_set_operstate(hsr_priv->dev, slave, other_slave);
+		hsr_check_announce(hsr_priv->dev, old_operstate);
+		break;
+	case NETDEV_CHANGEADDR:
+
+		/* This should not happen since there's no ndo_set_mac_address()
+		 * for HSR devices - i.e. not supported.
+		 */
+		if (dev =3D=3D hsr_priv->dev)
+			break;
+
+		if (dev =3D=3D hsr_priv->slave[0])
+			memcpy(hsr_priv->dev->dev_addr,
+			       hsr_priv->slave[0]->dev_addr, ETH_ALEN);
+
+		/* Make sure we recognize frames from ourselves in hsr_rcv() */
+		res =3D hsr_create_self_node(&hsr_priv->self_node_db,
+					   hsr_priv->dev->dev_addr,
+					   hsr_priv->slave[1] ?
+						hsr_priv->slave[1]->dev_addr :
+						hsr_priv->dev->dev_addr);
+		if (res)
+			netdev_warn(hsr_priv->dev,
+				    "Could not update HSR node address.\n");
+
+		if (dev =3D=3D hsr_priv->slave[0])
+			call_netdevice_notifiers(NETDEV_CHANGEADDR, hsr_priv->dev);
+		break;
+	case NETDEV_CHANGEMTU:
+		if (dev =3D=3D hsr_priv->dev)
+			break; /* Handled in ndo_change_mtu() */
+		mtu_max =3D hsr_get_max_mtu(hsr_priv);
+		if (hsr_priv->dev->mtu > mtu_max)
+			dev_set_mtu(hsr_priv->dev, mtu_max);
+		break;
+	case NETDEV_UNREGISTER:
+		if (dev =3D=3D hsr_priv->slave[0])
+			hsr_priv->slave[0] =3D NULL;
+		if (dev =3D=3D hsr_priv->slave[1])
+			hsr_priv->slave[1] =3D NULL;
+
+		/* There should really be a way to set a new slave device... */
+
+		break;
+	case NETDEV_PRE_TYPE_CHANGE:
+		/* HSR works only on Ethernet devices. Refuse slave to change
+		 * its type.
+		 */
+		return NOTIFY_BAD;
+	}
+
+	return NOTIFY_DONE;
+}
+
+
+static struct timer_list prune_timer;
+
+static void prune_nodes_all(unsigned long data)
+{
+	struct hsr_priv *hsr_priv;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hsr_priv, &hsr_list, hsr_list)
+		hsr_prune_nodes(hsr_priv);
+	rcu_read_unlock();
+
+	prune_timer.expires =3D jiffies + msecs_to_jiffies(PRUNE_PERIOD);
+	add_timer(&prune_timer);
+}
+
+
+static struct sk_buff *hsr_pull_tag(struct sk_buff *skb)
+{
+	struct hsr_tag *hsr_tag;
+	struct sk_buff *skb2;
+
+	skb2 =3D skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb2))
+		goto err_free;
+	skb =3D skb2;
+
+	if (unlikely(!pskb_may_pull(skb, HSR_TAGLEN)))
+		goto err_free;
+
+	hsr_tag =3D (struct hsr_tag *) skb->data;
+	skb->protocol =3D hsr_tag->encap_proto;
+	skb_pull(skb, HSR_TAGLEN);
+
+	return skb;
+
+err_free:
+	kfree_skb(skb);
+	return NULL;
+}
+
+
+/* The uses I can see for these HSR supervision frames are:
+ * 1) Use the frames that are sent after node initialization ("HSR_TLV=
=2EType =3D
+ *    22") to reset any sequence_nr counters belonging to that node. U=
seful if
+ *    the other node's counter has been reset for some reason.
+ *    --
+ *    Or not - resetting the counter and bridging the frame would crea=
te a
+ *    loop, unfortunately.
+ *
+ * 2) Use the LifeCheck frames to detect ring breaks. I.e. if no LifeC=
heck
+ *    frame is received from a particular node, we know something is w=
rong.
+ *    We just register these (as with normal frames) and throw them aw=
ay.
+ *
+ * 3) Allow different MAC addresses for the two slave interfaces, usin=
g the
+ *    MacAddressA field.
+ */
+static bool is_supervision_frame(struct hsr_priv *hsr_priv, struct sk_=
buff *skb)
+{
+	struct hsr_sup_tag *hsr_stag;
+
+	if (compare_ether_addr(eth_hdr(skb)->h_dest,
+			       hsr_priv->sup_multicast_addr))
+		return 0;
+
+	hsr_stag =3D (struct hsr_sup_tag *) skb->data;
+	if (get_hsr_stag_path(hsr_stag) !=3D 0x0f)
+		return 0;
+	if ((hsr_stag->HSR_TLV_Type !=3D HSR_TLV_ANNOUNCE) &&
+	    (hsr_stag->HSR_TLV_Type !=3D HSR_TLV_LIFE_CHECK))
+		return 0;
+	if (hsr_stag->HSR_TLV_Length !=3D 12)
+		return 0;
+
+	return 1;
+}
+
+
+/* Implementation somewhat according to IEC-62439-3, p. 43
+ */
+static int hsr_rcv(struct sk_buff *skb, struct net_device *dev,
+		   struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct hsr_priv *hsr_priv;
+	struct net_device *other_slave;
+	struct node_entry *node;
+	int deliver_to_self;
+	struct sk_buff *skb_deliver;
+	enum hsr_dev_idx dev_in_idx, dev_other_idx;
+	bool dup_out;
+	int ret;
+
+	hsr_priv =3D get_hsr_master(dev);
+
+	if (!hsr_priv) {
+		/* Non-HSR-slave device 'dev' is connected to a HSR network */
+		kfree_skb(skb);
+		dev->stats.rx_errors++;
+		return NET_RX_SUCCESS;
+	}
+
+	if (dev =3D=3D hsr_priv->slave[0]) {
+		dev_in_idx =3D HSR_DEV_SLAVE_A;
+		dev_other_idx =3D HSR_DEV_SLAVE_B;
+	} else {
+		dev_in_idx =3D HSR_DEV_SLAVE_B;
+		dev_other_idx =3D HSR_DEV_SLAVE_A;
+	}
+
+	node =3D hsr_find_node(&hsr_priv->self_node_db, skb);
+	if (node) {
+		/* Always kill frames sent by ourselves */
+		kfree_skb(skb);
+		return NET_RX_SUCCESS;
+	}
+
+	/* Is this frame a candidate for local reception? */
+	deliver_to_self =3D 0;
+	if ((skb->pkt_type =3D=3D PACKET_HOST) ||
+	    (skb->pkt_type =3D=3D PACKET_MULTICAST) ||
+	    (skb->pkt_type =3D=3D PACKET_BROADCAST))
+		deliver_to_self =3D 1;
+	else if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+				     hsr_priv->dev->dev_addr)) {
+		skb->pkt_type =3D PACKET_HOST;
+		deliver_to_self =3D 1;
+	}
+
+
+	rcu_read_lock(); /* node_db */
+	node =3D hsr_find_node(&hsr_priv->node_db, skb);
+
+	if (is_supervision_frame(hsr_priv, skb)) {
+		skb_pull(skb, sizeof(struct hsr_sup_tag));
+		node =3D hsr_merge_node(hsr_priv, node, skb, dev_in_idx);
+		if (!node) {
+			rcu_read_unlock(); /* node_db */
+			kfree_skb(skb);
+			hsr_priv->dev->stats.rx_dropped++;
+			return NET_RX_DROP;
+		}
+		skb_push(skb, sizeof(struct hsr_sup_tag));
+		deliver_to_self =3D 0;
+	}
+
+	if (!node) {
+		/* Source node unknown; this might be a HSR frame from
+		 * another net (different multicast address). Ignore it.
+		 */
+		rcu_read_unlock(); /* node_db */
+		kfree_skb(skb);
+		return NET_RX_SUCCESS;
+	}
+
+	/* Register ALL incoming frames as outgoing through the other interfa=
ce.
+	 * This allows us to register frames as incoming only if they are val=
id
+	 * for the receiving interface, without using a specific counter for
+	 * incoming frames.
+	 */
+	dup_out =3D hsr_register_frame_out(node, dev_other_idx, skb);
+	if (!dup_out)
+		hsr_register_frame_in(node, dev_in_idx);
+
+	/* Forward this frame? */
+	if (!dup_out && (skb->pkt_type !=3D PACKET_HOST))
+		other_slave =3D get_other_slave(hsr_priv, dev);
+	else
+		other_slave =3D NULL;
+
+	if (hsr_register_frame_out(node, HSR_DEV_MASTER, skb))
+		deliver_to_self =3D 0;
+
+	rcu_read_unlock(); /* node_db */
+
+	if (!deliver_to_self && !other_slave) {
+		kfree_skb(skb);
+		/* Circulated frame; silently remove it. */
+		return NET_RX_SUCCESS;
+	}
+
+	skb_deliver =3D skb;
+	if (deliver_to_self && other_slave) {
+		/* skb_clone() is not enough since we will strip the hsr tag
+		 * and do address substitution below
+		 */
+		skb_deliver =3D pskb_copy(skb, GFP_ATOMIC);
+		if (!skb_deliver) {
+			deliver_to_self =3D 0;
+			hsr_priv->dev->stats.rx_dropped++;
+		}
+	}
+
+	if (deliver_to_self) {
+		bool multicast_frame;
+
+		skb_deliver =3D hsr_pull_tag(skb_deliver);
+		if (!skb_deliver) {
+			hsr_priv->dev->stats.rx_dropped++;
+			goto forward;
+		}
+#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+		/* Move everything in the header that is after the HSR tag,
+		 * to work around alignment problems caused by the 6-byte HSR
+		 * tag. In practice, this removes/overwrites the HSR tag in
+		 * the header and restores a "standard" packet.
+		 */
+		memmove(skb_deliver->data - HSR_TAGLEN, skb_deliver->data,
+			skb_headlen(skb_deliver));
+
+		/* Adjust skb members so they correspond with the move above.
+		 * This cannot possibly underflow skb->data since hsr_pull_tag()
+		 * above succeeded.
+		 * At this point in the protocol stack, the transport and
+		 * network headers have not been set yet, and we haven't touched
+		 * the mac header nor the head. So we only need to adjust data
+		 * and tail:
+		 */
+		skb_deliver->data -=3D HSR_TAGLEN;
+		skb_deliver->tail -=3D HSR_TAGLEN;
+#endif
+		skb_deliver->dev =3D hsr_priv->dev;
+		hsr_addr_subst_source(hsr_priv, skb_deliver);
+		multicast_frame =3D (skb_deliver->pkt_type =3D=3D PACKET_MULTICAST);
+		ret =3D netif_rx(skb_deliver);
+		if (ret =3D=3D NET_RX_DROP) {
+			hsr_priv->dev->stats.rx_dropped++;
+		} else {
+			hsr_priv->dev->stats.rx_packets++;
+			hsr_priv->dev->stats.rx_bytes +=3D skb->len;
+			if (multicast_frame)
+				hsr_priv->dev->stats.multicast++;
+		}
+	}
+
+forward:
+	if (other_slave) {
+		skb_push(skb, ETH_HLEN);
+		skb->dev =3D other_slave;
+		dev_queue_xmit(skb);
+	}
+
+	return NET_RX_SUCCESS;
+}
+
+
+static struct packet_type hsr_pt __read_mostly =3D {
+	.type =3D htons(ETH_P_PRP),
+	.func =3D hsr_rcv,
+};
+
+static struct notifier_block hsr_nb =3D {
+	.notifier_call =3D hsr_netdev_notify,	/* Slave event notifications */
+};
+
+
+static int __init hsr_init(void)
+{
+	int res;
+
+	BUILD_BUG_ON(sizeof(struct hsr_tag) !=3D HSR_TAGLEN);
+
+	dev_add_pack(&hsr_pt);
+
+	init_timer(&prune_timer);
+	prune_timer.function =3D prune_nodes_all;
+	prune_timer.data =3D 0;
+	prune_timer.expires =3D jiffies + msecs_to_jiffies(PRUNE_PERIOD);
+	add_timer(&prune_timer);
+
+	register_netdevice_notifier(&hsr_nb);
+
+	res =3D hsr_netlink_init();
+
+	return res;
+}
+
+static void __exit hsr_exit(void)
+{
+	unregister_netdevice_notifier(&hsr_nb);
+	del_timer(&prune_timer);
+	hsr_netlink_exit();
+	dev_remove_pack(&hsr_pt);
+}
+
+module_init(hsr_init);
+module_exit(hsr_exit);
+MODULE_LICENSE("GPL");
diff --git a/net/hsr/hsr_main.h b/net/hsr/hsr_main.h
new file mode 100644
index 0000000..56fe060
--- /dev/null
+++ b/net/hsr/hsr_main.h
@@ -0,0 +1,166 @@
+/* Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef _HSR_PRIVATE_H
+#define _HSR_PRIVATE_H
+
+#include <linux/netdevice.h>
+#include <linux/list.h>
+
+
+/* Time constants as specified in the HSR specification (IEC-62439-3 2=
010)
+ * Table 8.
+ * All values in milliseconds.
+ */
+#define HSR_LIFE_CHECK_INTERVAL		 2000 /* ms */
+#define HSR_NODE_FORGET_TIME		60000 /* ms */
+#define HSR_ANNOUNCE_INTERVAL		  100 /* ms */
+
+
+/* By how much may slave1 and slave2 timestamps of latest received fra=
me from
+ * each node differ before we notify of communication problem?
+ */
+#define MAX_SLAVE_DIFF			 3000 /* ms */
+
+
+/* How often shall we check for broken ring and remove node entries ol=
der than
+ * HSR_NODE_FORGET_TIME?
+ */
+#define PRUNE_PERIOD			 3000 /* ms */
+
+
+#define HSR_TLV_ANNOUNCE		   22
+#define HSR_TLV_LIFE_CHECK		   23
+
+
+/* HSR Tag.
+ * As defined in IEC-62439-3:2010, the HSR tag is really { ethertype =3D=
 0x88FB,
+ * path, LSDU_size, sequence Nr }. But we let eth_header() create { h_=
dest,
+ * h_source, h_proto =3D 0x88FB }, and add { path, LSDU_size, sequence=
 Nr,
+ * encapsulated protocol } instead.
+ */
+#define HSR_TAGLEN	6
+
+/* Field names below as defined in the IEC:2010 standard for HSR. */
+struct hsr_tag {
+	__be16		path_and_LSDU_size;
+	__be16		sequence_nr;
+	__be16		encap_proto;
+} __packed;
+
+
+/* The helper functions below assumes that 'path' occupies the 4 most
+ * significant bits of the 16-bit field shared by 'path' and 'LSDU_siz=
e' (or
+ * equivalently, the 4 most significant bits of HSR tag byte 14).
+ *
+ * This is unclear in the IEC specification; its definition of MAC add=
resses
+ * indicates the spec is written with the least significant bit first =
(to the
+ * left). This, however, would mean that the LSDU field would be split=
 in two
+ * with the path field in-between, which seems strange. I'm guessing t=
he MAC
+ * address definition is in error.
+ */
+static inline u16 get_hsr_tag_path(struct hsr_tag *ht)
+{
+	return ntohs(ht->path_and_LSDU_size) >> 12;
+}
+
+static inline u16 get_hsr_tag_LSDU_size(struct hsr_tag *ht)
+{
+	return ntohs(ht->path_and_LSDU_size) & 0x0FFF;
+}
+
+static inline void set_hsr_tag_path(struct hsr_tag *ht, u16 path)
+{
+	ht->path_and_LSDU_size =3D htons(
+			(ntohs(ht->path_and_LSDU_size) & 0x0FFF) | (path << 12));
+}
+
+static inline void set_hsr_tag_LSDU_size(struct hsr_tag *ht, u16 LSDU_=
size)
+{
+	ht->path_and_LSDU_size =3D htons(
+			(ntohs(ht->path_and_LSDU_size) & 0xF000) |
+			(LSDU_size & 0x0FFF));
+}
+
+struct hsr_ethhdr {
+	struct ethhdr	ethhdr;
+	struct hsr_tag	hsr_tag;
+} __packed;
+
+
+/* HSR Supervision Frame data types.
+ * Field names as defined in the IEC:2010 standard for HSR.
+ */
+struct hsr_sup_tag {
+	__be16		path_and_HSR_Ver;
+	__be16		sequence_nr;
+	__u8		HSR_TLV_Type;
+	__u8		HSR_TLV_Length;
+} __packed;
+
+struct hsr_sup_payload {
+	unsigned char	MacAddressA[ETH_ALEN];
+} __packed;
+
+static inline u16 get_hsr_stag_path(struct hsr_sup_tag *hst)
+{
+	return get_hsr_tag_path((struct hsr_tag *) hst);
+}
+
+static inline u16 get_hsr_stag_HSR_ver(struct hsr_sup_tag *hst)
+{
+	return get_hsr_tag_LSDU_size((struct hsr_tag *) hst);
+}
+
+static inline void set_hsr_stag_path(struct hsr_sup_tag *hst, u16 path=
)
+{
+	set_hsr_tag_path((struct hsr_tag *) hst, path);
+}
+
+static inline void set_hsr_stag_HSR_Ver(struct hsr_sup_tag *hst, u16 H=
SR_Ver)
+{
+	set_hsr_tag_LSDU_size((struct hsr_tag *) hst, HSR_Ver);
+}
+
+struct hsr_ethhdr_sp {
+	struct ethhdr		ethhdr;
+	struct hsr_sup_tag	hsr_sup;
+} __packed;
+
+
+enum hsr_dev_idx {
+	HSR_DEV_NONE =3D -1,
+	HSR_DEV_SLAVE_A =3D 0,
+	HSR_DEV_SLAVE_B,
+	HSR_DEV_MASTER,
+};
+#define HSR_MAX_SLAVE	(HSR_DEV_SLAVE_B + 1)
+#define HSR_MAX_DEV	(HSR_DEV_MASTER + 1)
+
+struct hsr_priv {
+	struct list_head	hsr_list;	/* List of hsr devices */
+	struct rcu_head		rcu_head;
+	struct net_device	*dev;
+	struct net_device	*slave[HSR_MAX_SLAVE];
+	struct list_head	node_db;	/* Other HSR nodes */
+	struct list_head	self_node_db;	/* MACs of slaves */
+	struct timer_list	announce_timer;	/* Supervision frame dispatch */
+	int announce_count;
+	u16 sequence_nr;
+	spinlock_t seqnr_lock;			/* locking for sequence_nr */
+	unsigned char		sup_multicast_addr[ETH_ALEN];
+};
+
+void register_hsr_master(struct hsr_priv *hsr_priv);
+void unregister_hsr_master(struct hsr_priv *hsr_priv);
+bool is_hsr_slave(struct net_device *dev);
+
+#endif /*  _HSR_PRIVATE_H */
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
new file mode 100644
index 0000000..4e66bf6
--- /dev/null
+++ b/net/hsr/hsr_netlink.c
@@ -0,0 +1,457 @@
+/* Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ *
+ * Routines for handling Netlink messages for HSR.
+ */
+
+#include "hsr_netlink.h"
+#include <linux/kernel.h>
+#include <net/rtnetlink.h>
+#include <net/genetlink.h>
+#include "hsr_main.h"
+#include "hsr_device.h"
+#include "hsr_framereg.h"
+
+static const struct nla_policy hsr_policy[IFLA_HSR_MAX + 1] =3D {
+	[IFLA_HSR_SLAVE1]		=3D { .type =3D NLA_U32 },
+	[IFLA_HSR_SLAVE2]		=3D { .type =3D NLA_U32 },
+	[IFLA_HSR_MULTICAST_SPEC]	=3D { .type =3D NLA_U8 },
+};
+
+
+/* Here, it seems a netdevice has already been allocated for us, and t=
he
+ * hsr_dev_setup routine has been executed. Nice!
+ */
+static int hsr_newlink(struct net *src_net, struct net_device *dev,
+		       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net_device *link[2];
+	unsigned char multicast_spec;
+
+	if (!data[IFLA_HSR_SLAVE1]) {
+		netdev_info(dev, "IFLA_HSR_SLAVE1 missing!\n");
+		return -EINVAL;
+	}
+	link[0] =3D __dev_get_by_index(src_net, nla_get_u32(data[IFLA_HSR_SLA=
VE1]));
+	if (!data[IFLA_HSR_SLAVE2]) {
+		netdev_info(dev, "IFLA_HSR_SLAVE2 missing!\n");
+		return -EINVAL;
+	}
+	link[1] =3D __dev_get_by_index(src_net, nla_get_u32(data[IFLA_HSR_SLA=
VE2]));
+
+	if (!link[0] || !link[1])
+		return -ENODEV;
+	if (link[0] =3D=3D link[1])
+		return -EINVAL;
+
+	if (!data[IFLA_HSR_MULTICAST_SPEC])
+		multicast_spec =3D 0;
+	else
+		multicast_spec =3D nla_get_u8(data[IFLA_HSR_MULTICAST_SPEC]);
+
+	return hsr_dev_finalize(dev, link, multicast_spec);
+}
+
+static struct rtnl_link_ops hsr_link_ops __read_mostly =3D {
+	.kind		=3D "hsr",
+	.maxtype	=3D IFLA_HSR_MAX,
+	.policy		=3D hsr_policy,
+	.priv_size	=3D sizeof(struct hsr_priv),
+	.setup		=3D hsr_dev_setup,
+	.newlink	=3D hsr_newlink,
+};
+
+
+
+/* attribute policy */
+/* NLA_BINARY missing in libnl; use NLA_UNSPEC in userspace instead. *=
/
+static const struct nla_policy hsr_genl_policy[HSR_A_MAX + 1] =3D {
+	[HSR_A_NODE_ADDR] =3D { .type =3D NLA_BINARY, .len =3D ETH_ALEN },
+	[HSR_A_NODE_ADDR_B] =3D { .type =3D NLA_BINARY, .len =3D ETH_ALEN },
+	[HSR_A_IFINDEX] =3D { .type =3D NLA_U32 },
+	[HSR_A_IF1_AGE] =3D { .type =3D NLA_U32 },
+	[HSR_A_IF2_AGE] =3D { .type =3D NLA_U32 },
+	[HSR_A_IF1_SEQ] =3D { .type =3D NLA_U16 },
+	[HSR_A_IF2_SEQ] =3D { .type =3D NLA_U16 },
+};
+
+static struct genl_family hsr_genl_family =3D {
+	.id =3D GENL_ID_GENERATE,
+	.hdrsize =3D 0,
+	.name =3D "HSR",
+	.version =3D 1,
+	.maxattr =3D HSR_A_MAX,
+};
+
+static struct genl_multicast_group hsr_network_genl_mcgrp =3D {
+	.name =3D "hsr-network",
+};
+
+
+
+/* This is called if for some node with MAC address addr, we only get =
frames
+ * over one of the slave interfaces. This would indicate an open netwo=
rk ring
+ * (i.e. a link has failed somewhere).
+ */
+void hsr_nl_ringerror(struct hsr_priv *hsr_priv, unsigned char addr[ET=
H_ALEN],
+		      enum hsr_dev_idx dev_idx)
+{
+	struct sk_buff *skb;
+	void *msg_head;
+	int res;
+	int ifindex;
+
+	skb =3D genlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		goto fail;
+
+	msg_head =3D genlmsg_put(skb, 0, 0, &hsr_genl_family, 0, HSR_C_RING_E=
RROR);
+	if (!msg_head)
+		goto nla_put_failure;
+
+	res =3D nla_put(skb, HSR_A_NODE_ADDR, ETH_ALEN, addr);
+	if (res < 0)
+		goto nla_put_failure;
+
+	if (hsr_priv->slave[dev_idx])
+		ifindex =3D hsr_priv->slave[dev_idx]->ifindex;
+	else
+		ifindex =3D -1;
+	res =3D nla_put_u32(skb, HSR_A_IFINDEX, ifindex);
+	if (res < 0)
+		goto nla_put_failure;
+
+	genlmsg_end(skb, msg_head);
+	genlmsg_multicast(skb, 0, hsr_network_genl_mcgrp.id, GFP_ATOMIC);
+
+	return;
+
+nla_put_failure:
+	kfree_skb(skb);
+
+fail:
+	netdev_warn(hsr_priv->dev, "Could not send HSR ring error message\n")=
;
+}
+
+/* This is called when we haven't heard from the node with MAC address=
 addr for
+ * some time (just before the node is removed from the node table/list=
).
+ */
+void hsr_nl_nodedown(struct hsr_priv *hsr_priv, unsigned char addr[ETH=
_ALEN])
+{
+	struct sk_buff *skb;
+	void *msg_head;
+	int res;
+
+	skb =3D genlmsg_new(NLMSG_GOODSIZE, GFP_ATOMIC);
+	if (!skb)
+		goto fail;
+
+	msg_head =3D genlmsg_put(skb, 0, 0, &hsr_genl_family, 0, HSR_C_NODE_D=
OWN);
+	if (!msg_head)
+		goto nla_put_failure;
+
+
+	res =3D nla_put(skb, HSR_A_NODE_ADDR, ETH_ALEN, addr);
+	if (res < 0)
+		goto nla_put_failure;
+
+	genlmsg_end(skb, msg_head);
+	genlmsg_multicast(skb, 0, hsr_network_genl_mcgrp.id, GFP_ATOMIC);
+
+	return;
+
+nla_put_failure:
+	kfree_skb(skb);
+
+fail:
+	netdev_warn(hsr_priv->dev, "Could not send HSR node down\n");
+}
+
+
+/* HSR_C_GET_NODE_STATUS lets userspace query the internal HSR node ta=
ble
+ * about the status of a specific node in the network, defined by its =
MAC
+ * address.
+ *
+ * Input: hsr ifindex, node mac address
+ * Output: hsr ifindex, node mac address (copied from request),
+ *	   age of latest frame from node over slave 1, slave 2 [ms]
+ */
+static int hsr_get_node_status(struct sk_buff *skb_in, struct genl_inf=
o *info)
+{
+	/* For receiving */
+	struct nlattr *na;
+	struct net_device *hsr_dev;
+
+	/* For sending */
+	struct sk_buff *skb_out;
+	void *msg_head;
+	struct hsr_priv *hsr_priv;
+	unsigned char hsr_node_addr_b[ETH_ALEN];
+	int hsr_node_if1_age;
+	u16 hsr_node_if1_seq;
+	int hsr_node_if2_age;
+	u16 hsr_node_if2_seq;
+	int addr_b_ifindex;
+	int res;
+
+	if (!info)
+		goto invalid;
+
+	na =3D info->attrs[HSR_A_IFINDEX];
+	if (!na)
+		goto invalid;
+	na =3D info->attrs[HSR_A_NODE_ADDR];
+	if (!na)
+		goto invalid;
+
+	hsr_dev =3D __dev_get_by_index(genl_info_net(info),
+					nla_get_u32(info->attrs[HSR_A_IFINDEX]));
+	if (!hsr_dev)
+		goto invalid;
+	if (!is_hsr_master(hsr_dev))
+		goto invalid;
+
+
+	/* Send reply */
+
+	skb_out =3D genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb_out) {
+		res =3D -ENOMEM;
+		goto fail;
+	}
+
+	msg_head =3D genlmsg_put(skb_out, NETLINK_CB(skb_in).portid,
+				info->snd_seq, &hsr_genl_family, 0,
+				HSR_C_SET_NODE_STATUS);
+	if (!msg_head) {
+		res =3D -ENOMEM;
+		goto nla_put_failure;
+	}
+
+	res =3D nla_put_u32(skb_out, HSR_A_IFINDEX, hsr_dev->ifindex);
+	if (res < 0)
+		goto nla_put_failure;
+
+	hsr_priv =3D netdev_priv(hsr_dev);
+	res =3D hsr_get_node_data(hsr_priv,
+			(unsigned char *) nla_data(info->attrs[HSR_A_NODE_ADDR]),
+			hsr_node_addr_b,
+			&addr_b_ifindex,
+			&hsr_node_if1_age,
+			&hsr_node_if1_seq,
+			&hsr_node_if2_age,
+			&hsr_node_if2_seq);
+	if (res < 0)
+		goto fail;
+
+	res =3D nla_put(skb_out, HSR_A_NODE_ADDR, ETH_ALEN,
+					nla_data(info->attrs[HSR_A_NODE_ADDR]));
+	if (res < 0)
+		goto nla_put_failure;
+
+	if (addr_b_ifindex > -1) {
+		res =3D nla_put(skb_out, HSR_A_NODE_ADDR_B, ETH_ALEN,
+								hsr_node_addr_b);
+		if (res < 0)
+			goto nla_put_failure;
+
+		res =3D nla_put_u32(skb_out, HSR_A_ADDR_B_IFINDEX, addr_b_ifindex);
+		if (res < 0)
+			goto nla_put_failure;
+	}
+
+	res =3D nla_put_u32(skb_out, HSR_A_IF1_AGE, hsr_node_if1_age);
+	if (res < 0)
+		goto nla_put_failure;
+	res =3D nla_put_u16(skb_out, HSR_A_IF1_SEQ, hsr_node_if1_seq);
+	if (res < 0)
+		goto nla_put_failure;
+	if (hsr_priv->slave[0])
+		res =3D nla_put_u32(skb_out, HSR_A_IF1_IFINDEX,
+						hsr_priv->slave[0]->ifindex);
+	if (res < 0)
+		goto nla_put_failure;
+
+	res =3D nla_put_u32(skb_out, HSR_A_IF2_AGE, hsr_node_if2_age);
+	if (res < 0)
+		goto nla_put_failure;
+	res =3D nla_put_u16(skb_out, HSR_A_IF2_SEQ, hsr_node_if2_seq);
+	if (res < 0)
+		goto nla_put_failure;
+	if (hsr_priv->slave[1])
+		res =3D nla_put_u32(skb_out, HSR_A_IF2_IFINDEX,
+						hsr_priv->slave[1]->ifindex);
+
+	genlmsg_end(skb_out, msg_head);
+	genlmsg_unicast(genl_info_net(info), skb_out, info->snd_portid);
+
+	return 0;
+
+invalid:
+	netlink_ack(skb_in, nlmsg_hdr(skb_in), -EINVAL);
+	return 0;
+
+nla_put_failure:
+	kfree_skb(skb_out);
+	/* Fall through */
+
+fail:
+	return res;
+}
+
+static struct genl_ops hsr_ops_get_node_status =3D {
+	.cmd =3D HSR_C_GET_NODE_STATUS,
+	.flags =3D 0,
+	.policy =3D hsr_genl_policy,
+	.doit =3D hsr_get_node_status,
+	.dumpit =3D NULL,
+};
+
+
+/* Get a list of MacAddressA of all nodes known to this node (other th=
an self).
+ */
+static int hsr_get_node_list(struct sk_buff *skb_in, struct genl_info =
*info)
+{
+	/* For receiving */
+	struct nlattr *na;
+	struct net_device *hsr_dev;
+
+	/* For sending */
+	struct sk_buff *skb_out;
+	void *msg_head;
+	struct hsr_priv *hsr_priv;
+	void *pos;
+	unsigned char addr[ETH_ALEN];
+	int res;
+
+	if (!info)
+		goto invalid;
+
+	na =3D info->attrs[HSR_A_IFINDEX];
+	if (!na)
+		goto invalid;
+
+	hsr_dev =3D __dev_get_by_index(genl_info_net(info),
+				     nla_get_u32(info->attrs[HSR_A_IFINDEX]));
+	if (!hsr_dev)
+		goto invalid;
+	if (!is_hsr_master(hsr_dev))
+		goto invalid;
+
+
+	/* Send reply */
+
+	skb_out =3D genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (!skb_out) {
+		res =3D -ENOMEM;
+		goto fail;
+	}
+
+	msg_head =3D genlmsg_put(skb_out, NETLINK_CB(skb_in).portid,
+				info->snd_seq, &hsr_genl_family, 0,
+				HSR_C_SET_NODE_LIST);
+	if (!msg_head) {
+		res =3D -ENOMEM;
+		goto nla_put_failure;
+	}
+
+	res =3D nla_put_u32(skb_out, HSR_A_IFINDEX, hsr_dev->ifindex);
+	if (res < 0)
+		goto nla_put_failure;
+
+	hsr_priv =3D netdev_priv(hsr_dev);
+
+	rcu_read_lock();
+	pos =3D hsr_get_next_node(hsr_priv, NULL, addr);
+	while (pos) {
+		res =3D nla_put(skb_out, HSR_A_NODE_ADDR, ETH_ALEN, addr);
+		if (res < 0) {
+			rcu_read_unlock();
+			goto nla_put_failure;
+		}
+		pos =3D hsr_get_next_node(hsr_priv, pos, addr);
+	}
+	rcu_read_unlock();
+
+	genlmsg_end(skb_out, msg_head);
+	genlmsg_unicast(genl_info_net(info), skb_out, info->snd_portid);
+
+	return 0;
+
+invalid:
+	netlink_ack(skb_in, nlmsg_hdr(skb_in), -EINVAL);
+	return 0;
+
+nla_put_failure:
+	kfree_skb(skb_out);
+	/* Fall through */
+
+fail:
+	return res;
+}
+
+
+static struct genl_ops hsr_ops_get_node_list =3D {
+	.cmd =3D HSR_C_GET_NODE_LIST,
+	.flags =3D 0,
+	.policy =3D hsr_genl_policy,
+	.doit =3D hsr_get_node_list,
+	.dumpit =3D NULL,
+};
+
+int __init hsr_netlink_init(void)
+{
+	int rc;
+
+	rc =3D rtnl_link_register(&hsr_link_ops);
+	if (rc)
+		goto fail_rtnl_link_register;
+
+	rc =3D genl_register_family(&hsr_genl_family);
+	if (rc)
+		goto fail_genl_register_family;
+
+	rc =3D genl_register_ops(&hsr_genl_family, &hsr_ops_get_node_status);
+	if (rc)
+		goto fail_genl_register_ops;
+
+	rc =3D genl_register_ops(&hsr_genl_family, &hsr_ops_get_node_list);
+	if (rc)
+		goto fail_genl_register_ops_node_list;
+
+	rc =3D genl_register_mc_group(&hsr_genl_family, &hsr_network_genl_mcg=
rp);
+	if (rc)
+		goto fail_genl_register_mc_group;
+
+	return 0;
+
+fail_genl_register_mc_group:
+	genl_unregister_ops(&hsr_genl_family, &hsr_ops_get_node_list);
+fail_genl_register_ops_node_list:
+	genl_unregister_ops(&hsr_genl_family, &hsr_ops_get_node_status);
+fail_genl_register_ops:
+	genl_unregister_family(&hsr_genl_family);
+fail_genl_register_family:
+	rtnl_link_unregister(&hsr_link_ops);
+fail_rtnl_link_register:
+
+	return rc;
+}
+
+void __exit hsr_netlink_exit(void)
+{
+	genl_unregister_mc_group(&hsr_genl_family, &hsr_network_genl_mcgrp);
+	genl_unregister_ops(&hsr_genl_family, &hsr_ops_get_node_status);
+	genl_unregister_family(&hsr_genl_family);
+
+	rtnl_link_unregister(&hsr_link_ops);
+}
+
+MODULE_ALIAS_RTNL_LINK("hsr");
diff --git a/net/hsr/hsr_netlink.h b/net/hsr/hsr_netlink.h
new file mode 100644
index 0000000..d4579dc
--- /dev/null
+++ b/net/hsr/hsr_netlink.h
@@ -0,0 +1,30 @@
+/* Copyright 2011-2013 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modif=
y it
+ * under the terms of the GNU General Public License as published by t=
he Free
+ * Software Foundation; either version 2 of the License, or (at your o=
ption)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2013 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef __HSR_NETLINK_H
+#define __HSR_NETLINK_H
+
+#include <linux/if_ether.h>
+#include <linux/module.h>
+#include <uapi/linux/hsr_netlink.h>
+
+struct hsr_priv;
+
+int __init hsr_netlink_init(void);
+void __exit hsr_netlink_exit(void);
+
+void hsr_nl_ringerror(struct hsr_priv *hsr_priv, unsigned char addr[ET=
H_ALEN],
+		      int dev_idx);
+void hsr_nl_nodedown(struct hsr_priv *hsr_priv, unsigned char addr[ETH=
_ALEN]);
+void hsr_nl_framedrop(int dropcount, int dev_idx);
+void hsr_nl_linkdown(int dev_idx);
+
+#endif /* __HSR_NETLINK_H */
--=20
1.8.1.5



--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
