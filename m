From: Arvid Brodin <Arvid.Brodin@xdin.com>
Subject: [RFC v4 1/1] net/hsr: Support for the HSR protocol (IEC:2010 / HSR
 v0)
Date: Fri, 12 Oct 2012 17:11:12 +0000
Message-ID: <50784F2D.1060200@xdin.com>
References: <4FF38A5C.9000802@xdin.com>
 <1341361824.1993.16.camel@joe2Laptop> <502D475C.9090208@xdin.com>
 <20120816.133036.1422214989121265534.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "joe@perches.com" <joe@perches.com>,
	"shemminger@vyatta.com" <shemminger@vyatta.com>,
	"jboticario@gmail.com" <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>,
	Arvid Brodin <Arvid.Brodin@xdin.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:62315 "EHLO spam2.webland.se"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932587Ab2JLRUz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Oct 2012 13:20:55 -0400
In-Reply-To: <20120816.133036.1422214989121265534.davem@davemloft.net>
Content-Language: en-US
Content-ID: <E4359F4652757C45A284EB8CF2838EEE@redbull.xdin.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This would add support for the High-availability Seamless Redundancy ne=
twork
protocol, version 0 (2010).

This RFC is NOT meant for mainline inclusion at the moment since we're =
trying
to figure out how to handle a probable incompatibility with the newer
HSR v1 (2012) standard.

---

This RFC is mainly to let you know that I'm still working on this patch=
=2E This
is now a pretty complete implementation of the HSR v0 (2010) protocol. =
As
explained above, the main reason I'm still not sending this as a real p=
atch
meant for mainline inclusion, is the fact that IEC recently released an=
 updated
standard (HSR v1 / 2012) which as far as I can tell is not backwards co=
mpatible
with the 2010 standard implemented by this patch.

At the moment we're trying to figure out what to do about this.

Changes from RFC v3:

	* Fixed style issues.
	* More thorough device stats updates.
	* Fixed bug where node that is downed and restarted within
	  NODE_FORGET_TIME is never seen by other nodes.
	* In RFC v3, a slave that was unregistered (e.g. USB network device th=
at
	  was unplugged) would crash the kernel. Works OK now.
	* Slave envent handling: MTU change, MAC address change, unregister,
	  type change.
	* Master event handling: MTU change.
	* Removed NONSTANDARD_HSR config option.
	* Guards for VLAN/HSR combo (allowed by the HSR standard, but not yet
	  implemented).

The patch has mostly been tested on 2.6.37, then modified to apply and =
compile
on 3.6.1.


 Documentation/networking/hsr/hsr_genl.c |  221 ++++++++++++
 include/linux/if_ether.h                |    1 +
 include/linux/if_link.h                 |   11 +
 net/Kconfig                             |    1 +
 net/Makefile                            |    1 +
 net/hsr/Kconfig                         |   33 ++
 net/hsr/Makefile                        |    7 +
 net/hsr/hsr_device.c                    |  576 +++++++++++++++++++++++=
++++++++
 net/hsr/hsr_device.h                    |   28 ++
 net/hsr/hsr_framereg.c                  |  338 ++++++++++++++++++
 net/hsr/hsr_framereg.h                  |   51 +++
 net/hsr/hsr_main.c                      |  468 +++++++++++++++++++++++=
++
 net/hsr/hsr_main.h                      |  157 +++++++++
 net/hsr/hsr_netlink.c                   |  305 ++++++++++++++++
 net/hsr/hsr_netlink.h                   |   64 ++++
 15 files changed, 2262 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/networking/hsr/hsr_genl.c
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

diff --git a/Documentation/networking/hsr/hsr_genl.c b/Documentation/ne=
tworking/hsr/hsr_genl.c
new file mode 100644
index 0000000..cb384d5
--- /dev/null
+++ b/Documentation/networking/hsr/hsr_genl.c
@@ -0,0 +1,221 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
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
+ *	2011-2012 Arvid Brodin, arvid.brodin@xdin.com
+ *
+ * Userspace example of using Generic Netlink to get HSR
+ * ("High-availability Seamless Redundancy") link/network status.
+ *
+ * Needs userspace libnl-3. Current as of 2012-08-07.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <netlink/netlink.h>
+#include <netlink/socket.h>
+#include <netlink/attr.h>
+#include <netlink/genl/genl.h>
+#include <netlink/genl/ctrl.h>
+/**** insert path to hsr_netlink from your kernel below: ****/
+#include "<path>/net/hsr/hsr_netlink.h"
+
+
+static struct nla_policy hsr_genl_policy[HSR_A_MAX + 1] =3D {
+	[HSR_A_NODE_ADDR] =3D { .type =3D NLA_UNSPEC },
+	[HSR_A_IFINDEX] =3D { .type =3D NLA_U32 },
+	[HSR_A_IF1AGE] =3D { .type =3D NLA_U32 },
+	[HSR_A_IF2AGE] =3D { .type =3D NLA_U32 },
+};
+
+#define ETH_ALEN	6
+
+void print_mac(const unsigned char *addr)
+{
+	int i;
+
+	for (i =3D 0; i < ETH_ALEN; i++)
+		printf("%02x ", addr[i]);
+}
+
+
+int parse_genlmsg(struct nl_msg *msg, void *arg)
+{
+	struct nlattr *attrs[HSR_A_MAX + 1];
+	int rc;
+	struct genlmsghdr *hdr;
+	int i;
+
+	rc =3D genlmsg_parse(nlmsg_hdr(msg), 0, attrs, HSR_A_MAX, hsr_genl_po=
licy);
+	if (rc < 0) {
+		printf("Error parsing genlmsg: %d\n", rc);
+		return rc;
+	}
+
+
+	/*
+	 * Extract command ID from "message" -> "netlink header" ->
+	 * "generic netlink header".
+	 *
+	 * These are the command enums used when creating a genl msg header
+	 * in the kernel with genlmsg_put().
+	 */
+	hdr =3D genlmsg_hdr(nlmsg_hdr(msg));
+
+	switch (hdr->cmd) {
+	case HSR_C_RING_ERROR:
+		printf("Ring error: \n");
+		break;
+	case HSR_C_NODE_DOWN:
+		printf("Node down: \n");
+		break;
+	case HSR_C_SET_NODE_STATUS:
+		printf("Node status: \n");
+		break;
+	default:
+		printf("Unknown genl message (%d)\n", hdr->cmd);
+	}
+
+
+	/*
+	 * Extract the attached data (the "attributes").
+	 */
+	for (i =3D 0; i < HSR_A_MAX + 1; i++)
+		if (attrs[i]) {
+			switch (attrs[i]->nla_type) {
+			case HSR_A_NODE_ADDR:
+				printf("    node address ");
+				print_mac(nla_data(attrs[i]));
+				printf("\n");
+				break;
+			case HSR_A_IFINDEX:
+				printf("    interface index %d\n",
+						nla_get_u32(attrs[i]));
+				break;
+			case HSR_A_IF1AGE:
+				printf("    last frame over slave #1 %d ms ago\n",
+						(int) nla_get_u32(attrs[i]));
+				break;
+			case HSR_A_IF2AGE:
+				printf("    last frame over slave #2 %d ms ago\n",
+						(int) nla_get_u32(attrs[i]));
+				break;
+			default:
+				printf("    unknown attribute type: %d\n",
+						attrs[i]->nla_type);
+			}
+		}
+
+	return 0;
+}
+
+/*
+ * Send a "simple" (header only) Generic Netlink message
+int query_link_status(int family)
+{
+	return (genl_send_simple(nlsk, family, HSR_C_GET_STATUS, 1, 0));
+}
+ */
+
+int query_node_status(struct nl_sock *nlsk, int family, int ifindex,
+		      const unsigned char node_addr[ETH_ALEN])
+{
+	struct nl_msg *msg;
+	void *user_hdr;
+
+	msg =3D nlmsg_alloc();
+	if (!msg)
+		return -1;
+
+	user_hdr =3D genlmsg_put(msg, NL_AUTO_PORT, NL_AUTO_SEQ, family,
+						0, 0, HSR_C_GET_NODE_STATUS, 1);
+	if (!user_hdr)
+		goto nla_put_failure;
+
+/*
+ * Query by interface name could be implemented in the kernel if neede=
d:
+ *	NLA_PUT_STRING(msg, HSR_A_IFNAME, ifname);
+ */
+	NLA_PUT_U32(msg, HSR_A_IFINDEX, ifindex);
+	NLA_PUT(msg, HSR_A_NODE_ADDR, ETH_ALEN, node_addr);
+
+	printf("Querying if %d for status of node ", ifindex);
+	print_mac(node_addr);
+	printf("\n");
+
+	return nl_send_auto(nlsk, msg);
+
+nla_put_failure:
+	nlmsg_free(msg);
+	return -1;
+}
+
+
+int main()
+{
+	struct nl_sock *nlsk;
+	int hsr_mgroup;
+	int rc;
+
+	nlsk =3D nl_socket_alloc();
+	if (!nlsk) {
+		printf("nl_socket_alloc() failed\n");
+		return EXIT_FAILURE;
+	}
+	nl_socket_disable_seq_check(nlsk);
+	nl_socket_modify_cb(nlsk, NL_CB_VALID, NL_CB_CUSTOM, parse_genlmsg, N=
ULL);
+	genl_connect(nlsk);
+
+	/*
+	 * Sign up for HSR messages
+	 */
+	hsr_mgroup =3D genl_ctrl_resolve_grp(nlsk, "HSR", "hsr-network");
+	if (hsr_mgroup < 0) {
+		printf("genl_ctrl_resolve_grp() failed: %d\n", hsr_mgroup);
+		rc =3D EXIT_FAILURE;
+		goto out;
+	}
+
+	printf("Registering for multicast group %d\n", hsr_mgroup);
+	rc =3D nl_socket_add_memberships(nlsk, hsr_mgroup, 0);
+	if (rc < 0) {
+		printf("nl_socket_add_memberships() failed: %d\n", rc);
+		goto out;
+	}
+
+	/*
+	 * Send a query about the status of another node on the HSR network:
+	 */
+	int hsr_family;
+	/* The hsr if we send the enquiry to (get it with e.g.
+	 * 'cat /sys/class/net/hsr0/ifindex'): */
+	const int hsr_ifindex =3D 4;
+	/* The node to enquire about: */
+	const unsigned char node[ETH_ALEN] =3D {0x00, 0x24, 0x74, 0x00, 0x17,=
 0xAD};
+
+	hsr_family =3D genl_ctrl_resolve(nlsk, "HSR");
+	if (hsr_family < 0) {
+		printf("genl_ctrl_resolve() failed: %d\n", hsr_family);
+		goto receive;
+	}
+	rc =3D query_node_status(nlsk, hsr_family, hsr_ifindex, node);
+	printf("query_node_status() returned %d\n", rc);
+
+	/*
+	 * Receive messages
+	 */
+receive:
+	while (1)
+		nl_recvmsgs_default(nlsk);
+
+	rc =3D EXIT_SUCCESS;
+out:
+	nl_close(nlsk);
+	nl_socket_free(nlsk);
+	return rc;
+}
diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 167ce5b..a03334a 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -83,6 +83,7 @@
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
 #define ETH_P_8021AH	0x88E7          /* 802.1ah Backbone Service Tag *=
/
 #define ETH_P_1588	0x88F7		/* IEEE 1588 Timesync */
+#define ETH_P_HSR	0x88FB		/* IEC 62439-3 HSR/PRP		*/
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_TDLS	0x890D          /* TDLS */
 #define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index e4dad4d..24766c1 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -432,4 +432,15 @@ enum {

 #define IFLA_IPOIB_MAX (__IFLA_IPOIB_MAX - 1)

+/* HSR section */
+
+enum {
+	IFLA_HSR_UNSPEC,
+	IFLA_HSR_SLAVE1,
+	IFLA_HSR_SLAVE2,
+	__IFLA_HSR_MAX,
+};
+
+#define IFLA_HSR_MAX (__IFLA_HSR_MAX - 1)
+
 #endif /* _LINUX_IF_LINK_H */
diff --git a/net/Kconfig b/net/Kconfig
index 30b48f5..15e8ce1 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -218,6 +218,7 @@ source "net/dcb/Kconfig"
 source "net/dns_resolver/Kconfig"
 source "net/batman-adv/Kconfig"
 source "net/openvswitch/Kconfig"
+source "net/hsr/Kconfig"

 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index 4f4ee08..adbf1de 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -70,3 +70,4 @@ obj-$(CONFIG_CEPH_LIB)		+=3D ceph/
 obj-$(CONFIG_BATMAN_ADV)	+=3D batman-adv/
 obj-$(CONFIG_NFC)		+=3D nfc/
 obj-$(CONFIG_OPENVSWITCH)	+=3D openvswitch/
+obj-$(CONFIG_HSR)		+=3D hsr/
diff --git a/net/hsr/Kconfig b/net/hsr/Kconfig
new file mode 100644
index 0000000..a9ed304
--- /dev/null
+++ b/net/hsr/Kconfig
@@ -0,0 +1,33 @@
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
+	  and you need to enslave these to a virtual hsr interface using the
+	  appropriate user space tool, i.e.:
+
+	  # ip link add name hsr0 type hsr dev1 dev2
+
+	  Your Linux box must be connected as a node in a ring network
+	  together with other HSR capable nodes.
+
+	  All Ethernet frames sent over the hsr device will be sent in both
+	  directions on the ring (over both slave ports), giving a redundant,
+	  instant fail-over network.
+
+	  Each HSR node in the ring acts like a bridge for HSR frames, but
+	  filters frames that have been forwarded earlier.
+
+	  This code is a "best effort" to comply with the HSR standard as
+	  described in IEC 62439-3, but no compliancy tests have been made.
+	  You need to perform any and all necessary tests yourself before
+	  relying on this code in a safety critical system. In particular, th=
e
+	  standard is very diffuse on how to use the Ring ID field in the HSR
+	  tag, and it's probable that this code does not do the right thing.
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
index 0000000..cd1efa2
--- /dev/null
+++ b/net/hsr/hsr_device.c
@@ -0,0 +1,576 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
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
+ *	2011-2012 Arvid Brodin, arvid.brodin@xdin.com
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
+#include "hsr_framereg.h"
+#include "hsr_main.h"
+
+
+static bool is_admin_up(struct net_device *dev)
+{
+	return (dev && (dev->flags & IFF_UP));
+}
+
+static bool is_operstate_up(struct net_device *dev)
+{
+	return (dev && (dev->operstate =3D=3D IF_OPER_UP));
+}
+
+static void __hsr_set_operstate(struct net_device *dev, int transition=
)
+{
+	if (dev->operstate !=3D transition) {
+		write_lock_bh(&dev_base_lock);
+		dev->operstate =3D transition;
+		write_unlock_bh(&dev_base_lock);
+		netdev_state_change(dev);
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
+	if (is_operstate_up(slave1) || is_operstate_up(slave2))
+		__hsr_set_operstate(hsr_dev, IF_OPER_UP);
+	else
+		__hsr_set_operstate(hsr_dev, IF_OPER_LOWERLAYERDOWN);
+}
+
+void hsr_set_carrier(struct net_device *hsr_dev, struct net_device *sl=
ave1,
+		     struct net_device *slave2)
+{
+	if (is_operstate_up(slave1) || is_operstate_up(slave2))
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
+		netdev_info(hsr_priv->dev, "A HSR master's MTU cannot be "
+			"greater than the smallest MTU of its slaves minus the "
+			"HSR Tag length (%d octets).\n", HSR_TAGLEN);
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
+
+	hsr_priv =3D netdev_priv(dev);
+
+	if (hsr_priv->slave[0])
+		dev_open(hsr_priv->slave[0]);
+	if (hsr_priv->slave[1])
+		dev_open(hsr_priv->slave[1]);
+
+	return 0;
+}
+
+static int hsr_dev_close(struct net_device *dev)
+{
+	/*
+	 * Nothing to do here. We could try to restore the state of the slave=
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
+	/*
+	 * IEC 62439-1:2010, p 48, says the 4-bit "path" field can take value=
s
+	 * between 0001-1001 ("ring identifier", for regular HSR frames),
+	 * or 1111 ("HSR management", supervision frames). Unfortunately, the
+	 * spec writers forgot to explain what a "ring identifier" is, or
+	 * how it is used. So we just set this to 0001 for regular frames,
+	 * and 1111 for supervision frames.
+	 */
+	set_hsr_tag_path(&hsr_ethhdr->hsr_tag, 0x1);
+
+	/*
+	 * IEC 62439-1:2010, p 12: "The link service data unit in an Ethernet
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
+	hsr_ethhdr->ethhdr.h_proto =3D htons(ETH_P_HSR);
+}
+
+static int slave_xmit(struct sk_buff *skb, struct net_device *dev,
+		      struct net_device *hsr_dev)
+{
+	skb->dev =3D dev;
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
+	if ((ntohs(skb->protocol) !=3D ETH_P_HSR) ||
+			(ntohs(hsr_ethhdr->ethhdr.h_proto) !=3D ETH_P_HSR)) {
+
+		hsr_fill_tag(hsr_ethhdr, hsr_priv);
+		skb->protocol =3D htons(ETH_P_HSR);
+	}
+
+	skb2 =3D skb_clone(skb, GFP_ATOMIC);
+
+	res1 =3D NET_XMIT_DROP;
+	if (likely(hsr_priv->slave[0]))
+		res1 =3D slave_xmit(skb, hsr_priv->slave[0], dev);
+	res2 =3D NET_XMIT_DROP;
+	if (skb2 && likely(hsr_priv->slave[1])) {
+		/*
+		 * Address substitution (IEC62439-3 pp 26, 50): replace mac
+		 * address of outgoing frame with that of the outgoing slave's.
+		 */
+		memcpy(hsr_ethhdr->ethhdr.h_source,
+					hsr_priv->slave[1]->dev_addr, ETH_ALEN);
+		res2 =3D slave_xmit(skb2, hsr_priv->slave[1], dev);
+	}
+
+	if (likely(res1 =3D=3D NET_XMIT_SUCCESS || res1 =3D=3D NET_XMIT_CN ||
+			res2 =3D=3D NET_XMIT_SUCCESS || res2 =3D=3D NET_XMIT_CN)) {
+		hsr_priv->dev->stats.tx_packets++;
+		hsr_priv->dev->stats.tx_bytes +=3D skb->len;
+	} else
+		hsr_priv->dev->stats.tx_dropped++;
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
+	   hsr_dev_xmit) */
+	if (skb_headroom(skb) < HSR_TAGLEN + ETH_HLEN)
+		return -ENOBUFS;
+	skb_push(skb, HSR_TAGLEN);
+	/*
+	 * To allow VLAN/HSR combos we should probably use
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
+/*
+ * HSR:2010 supervision frames should be padded so that the whole fram=
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
+				GFP_ATOMIC);
+	if (skb =3D=3D NULL)
+		return;
+
+	hsr_priv =3D netdev_priv(hsr_dev);
+
+	skb_reserve(skb, hlen);
+
+	skb->dev =3D hsr_dev;
+	skb->protocol =3D htons(ETH_P_HSR);
+	skb->priority =3D TC_PRIO_CONTROL;
+
+	if (dev_hard_header(skb, skb->dev, ETH_P_HSR, hsr_multicast_addr,
+					skb->dev->dev_addr, skb->len) < 0)
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
+/*
+ * Announce (supervision frame) timer function
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
+	} else
+		send_hsr_supervision_frame(hsr_priv->dev, HSR_TLV_LIFE_CHECK);
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
+			netdev_info(hsr_dev, "HSR: Cannot restore slave "
+						"promiscuity (%s, %d)\n",
+						hsr_priv->slave[i]->name, res);
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
+/*
+ * According to comments in the declaration of struct net_device, this=
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
+/*
+ * If dev is a HSR master, return 1; otherwise, return 0.
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
+						(dev->addr_len !=3D ETH_ALEN)) {
+		netdev_info(dev, "Cannot use loopback or non-ethernet "
+						"device as HSR slave.\n");
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
+		netdev_info(dev, "HSR on top of VLAN is not yet supported in "
+							"this driver.\n");
+		return -EINVAL;
+	}
+
+	/* HSR over bonded devices has not been tested, but I'm not sure it
+	 * won't work... */
+
+	return 0;
+}
+
+int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *sl=
ave[2])
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
+	hsr_priv->sequence_nr =3D 0;
+
+	init_timer(&hsr_priv->announce_timer);
+	hsr_priv->announce_timer.function =3D hsr_announce;
+	hsr_priv->announce_timer.data =3D (unsigned long) hsr_priv;
+
+
+/*
+ * FIXME: should I modify the value of these?
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
+	 * hsr_header_create() etc. */
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
+			netdev_info(hsr_dev, "HSR: Cannot set slave "
+						"promiscuity (%s, %d)\n",
+						slave[i]->name, res);
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
index 0000000..419ee23
--- /dev/null
+++ b/net/hsr/hsr_device.h
@@ -0,0 +1,28 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
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
+ *	2011-2012 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef __HSR_DEVICE_H
+#define __HSR_DEVICE_H
+
+#include <linux/netdevice.h>
+
+void hsr_dev_setup(struct net_device *dev);
+int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *sl=
ave[2]);
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
index 0000000..09baedb
--- /dev/null
+++ b/net/hsr/hsr_framereg.c
@@ -0,0 +1,338 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
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
+ *	2011-2012 Arvid Brodin, arvid.brodin@xdin.com
+ *
+ * The HSR spec says never to forward the same frame twice on the same
+ * interface. A frame is identified by its source MAC address and its =
HSR
+ * sequence number. This code keeps track of senders and their sequenc=
e numbers
+ * to allow filtering of duplicate frames.
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
+/*
+	TODO: use hash lists for mac addresses (linux/jhash.h)?
+*/
+
+struct node_entry {
+	struct list_head mac_list;
+	unsigned char	MacAddressA[ETH_ALEN];
+	unsigned char	MacAddressB[ETH_ALEN];
+	unsigned long	time_in[HSR_MAX_SLAVE];
+	u16		seq_out[HSR_MAX_DEV];
+	struct rcu_head rcu_head;
+};
+
+
+/*
+ * Search for mac entry. Caller must hold rcu read lock.
+ */
+static struct node_entry *find_node_by_AddrA(struct list_head *node_db=
,
+					     unsigned char addr[ETH_ALEN])
+{
+	struct node_entry *node;
+
+	list_for_each_entry_rcu(node, node_db, mac_list)
+		if (!compare_ether_addr(node->MacAddressA, addr))
+			return node;
+
+	return NULL;
+}
+
+/*
+ * Search for mac entry. Caller must hold rcu read lock.
+ */
+static struct node_entry *find_node_by_AddrB(struct list_head *node_db=
,
+					     unsigned char addr[ETH_ALEN])
+{
+	struct node_entry *node;
+
+	list_for_each_entry_rcu(node, node_db, mac_list)
+		if (!compare_ether_addr(node->MacAddressB, addr))
+			return node;
+
+	return NULL;
+}
+
+/*
+ * Search for mac entry. Caller must hold rcu read lock.
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
+/*
+ * Helper for device init; the self_node_db is used in hsr_rcv() to re=
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
+/*
+ * Add/merge node to the database of nodes. 'skb' must contain an HSR
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
+ * - (AddrB, SlaveB): the new AddrB will be recorded by PICS_SUBS code=
 since
+ *		      node =3D=3D NULL.
+ * - (AddrB, SlaveA): will work as usual.
+ *
+ * - (AddrA, SlaveB): The old node will be found. We need to detect th=
is and
+ *		      remove the node.
+ * - (AddrA, SlaveA): A new node will be registered (non-PICS_SUBS at =
first).
+ */
+struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
+				  struct node_entry *node,
+				  struct sk_buff *skb)
+{
+	struct ethhdr *ethhdr;
+	struct hsr_sup_payload *hsr_sp;
+	int i;
+
+	ethhdr =3D (struct ethhdr *) skb_mac_header(skb);
+	hsr_sp =3D (struct hsr_sup_payload *) skb->data;
+
+	if (node && compare_ether_addr(node->MacAddressA, hsr_sp->MacAddressA=
)) {
+		/* node has changed its AddrA, frame was received from SlaveB */
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
+		/* Node is PICS_SUBS capable; merge it */
+		memcpy(node->MacAddressB, ethhdr->h_source, ETH_ALEN);
+		return node;
+	}
+
+	node =3D kmalloc(sizeof(*node), GFP_ATOMIC);
+	if (!node)
+		return NULL;
+
+	memcpy(node->MacAddressA, hsr_sp->MacAddressA, ETH_ALEN);
+	memcpy(node->MacAddressB, ethhdr->h_source, ETH_ALEN);
+
+	for (i =3D 0; i < HSR_MAX_SLAVE; i++)
+		node->time_in[i] =3D 0;
+	for (i =3D 0; i < HSR_MAX_DEV; i++)
+		node->seq_out[i] =3D 0;
+
+	list_add_tail_rcu(&node->mac_list, &hsr_priv->node_db);
+
+	return node;
+}
+
+/*
+ * 'skb' is a frame meant for this host, that is to be passed to upper=
 layers.
+ *
+ * If the frame was sent by a node's B interface, replace the sender
+ * address with that node's "official" address (MacAddressA) so that u=
pper
+ * layers recognize where it came from.
+ */
+void hsr_addr_subst(struct hsr_priv *hsr_priv, struct sk_buff *skb)
+{
+	struct ethhdr *ethhdr;
+	struct node_entry *node;
+
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
+
+/*
+ * above(a, b) - return 1 if a > b, 0 otherwise.
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
+		WARN_ON(1);
+		return;
+	}
+	node->time_in[dev_idx] =3D jiffies;
+}
+
+/*
+ * 'skb' is a HSR Ethernet frame (with a HSR tag inserted), with a val=
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
+
+	if ((dev_idx < 0) || (dev_idx >=3D HSR_MAX_DEV)) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	if (!skb_mac_header_was_set(skb)) {
+		WARN_ON(1);
+		return -EINVAL;
+	}
+	hsr_ethhdr =3D (struct hsr_ethhdr *) skb_mac_header(skb);
+
+	if (below_or_eq(hsr_ethhdr->hsr_tag.sequence_nr,
+							node->seq_out[dev_idx]))
+		return 1;
+
+	node->seq_out[dev_idx] =3D hsr_ethhdr->hsr_tag.sequence_nr;
+	return 0;
+}
+
+
+/*
+ * Remove stale sequence_nr records. Called by timer every
+ * HSR_LIFE_CHECK_INTERVAL (two seconds or so).
+ */
+void hsr_prune_nodes(struct list_head *node_db)
+{
+	struct node_entry *node;
+	unsigned long timestamp;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(node, node_db, mac_list) {
+
+		timestamp =3D max(node->time_in[HSR_DEV_SLAVE1],
+				node->time_in[HSR_DEV_SLAVE2]);
+
+		/* Warn only as long as we get frames at all */
+		if (time_is_after_jiffies(timestamp +
+					msecs_to_jiffies(1.5*MAX_SLAVE_DIFF))) {
+
+			/* Check for open ring */
+			if (time_after(node->time_in[HSR_DEV_SLAVE2],
+					node->time_in[HSR_DEV_SLAVE1] +
+					msecs_to_jiffies(MAX_SLAVE_DIFF)))
+				hsr_nl_ringerror(node->MacAddressA, HSR_DEV_SLAVE1);
+			else if (time_after(node->time_in[HSR_DEV_SLAVE1],
+					node->time_in[HSR_DEV_SLAVE2] +
+					msecs_to_jiffies(MAX_SLAVE_DIFF)))
+				hsr_nl_ringerror(node->MacAddressA, HSR_DEV_SLAVE2);
+		}
+
+		/* Prune old entries */
+		if (time_is_before_jiffies(timestamp +
+					msecs_to_jiffies(HSR_NODE_FORGET_TIME))) {
+			hsr_nl_nodedown(node->MacAddressA);
+			list_del_rcu(&node->mac_list);
+			call_rcu(&node->rcu_head, node_entry_reclaim);
+		}
+	}
+	rcu_read_unlock();
+}
+
+
+void hsr_get_node_times(struct hsr_priv *hsr_priv, unsigned char addr[=
ETH_ALEN],
+			unsigned long *time1, unsigned long *time2)
+{
+	struct node_entry *node;
+
+	rcu_read_lock();
+	node =3D find_node_by_AddrA(&hsr_priv->node_db, addr);
+	if (!node) {
+		*time1 =3D 0;
+		*time2 =3D 0;
+	} else {
+		*time1 =3D node->time_in[HSR_DEV_SLAVE1];
+		*time2 =3D node->time_in[HSR_DEV_SLAVE2];
+	}
+	rcu_read_unlock();
+}
diff --git a/net/hsr/hsr_framereg.h b/net/hsr/hsr_framereg.h
new file mode 100644
index 0000000..e579569
--- /dev/null
+++ b/net/hsr/hsr_framereg.h
@@ -0,0 +1,51 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
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
+ *	2011-2012 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef _HSR_FRAMEREG_H
+#define _HSR_FRAMEREG_H
+
+#include "hsr_main.h"
+
+enum hsr_dev_idx {
+	HSR_DEV_SLAVE1 =3D 0,
+	HSR_DEV_SLAVE2,
+	HSR_DEV_MASTER,
+};
+
+struct node_entry;
+
+#define HSR_MAX_SLAVE	(HSR_DEV_SLAVE2 + 1)
+#define HSR_MAX_DEV	(HSR_DEV_MASTER + 1)
+
+struct node_entry *hsr_find_node(struct list_head *node_db, struct sk_=
buff *skb);
+
+struct node_entry *hsr_merge_node(struct hsr_priv *hsr_priv,
+				  struct node_entry *node,
+				  struct sk_buff *skb);
+
+void hsr_addr_subst(struct hsr_priv *hsr_priv, struct sk_buff *skb);
+
+void hsr_register_frame_in(struct node_entry *node, enum hsr_dev_idx);
+
+int hsr_register_frame_out(struct node_entry *node, enum hsr_dev_idx,
+			   struct sk_buff *skb);
+
+void hsr_prune_nodes(struct list_head *node_db);
+
+void hsr_get_node_times(struct hsr_priv *hsr_priv, unsigned char addr[=
ETH_ALEN],
+			unsigned long *time1, unsigned long *time2);
+
+int hsr_create_self_node(struct list_head *self_node_db,
+			 unsigned char addr_a[ETH_ALEN],
+			 unsigned char addr_b[ETH_ALEN]);
+
+#endif /* _HSR_FRAMEREG_H */
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
new file mode 100644
index 0000000..11747b3
--- /dev/null
+++ b/net/hsr/hsr_main.c
@@ -0,0 +1,468 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
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
+ *	2011-2012 Arvid Brodin, arvid.brodin@xdin.com
+ *
+ * In addition to routines for registering and unregistering HSR suppo=
rt, this
+ * file also contains the receive routine that handles all incoming fr=
ames with
+ * Ethertype (protocol) ETH_P_HSR.
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
+/* Multicast address for HSR Supervision frames */
+const u8 hsr_multicast_addr[ETH_ALEN] =3D {0x01, 0x15, 0x4e, 0x00, 0x0=
1, 0x00};
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
+/*
+ * If dev is a HSR slave device, return the virtual master device. Ret=
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
+						(dev =3D=3D hsr_priv->slave[1])) {
+			rcu_read_unlock();
+			return hsr_priv;
+		}
+
+	rcu_read_unlock();
+	return NULL;
+}
+
+/*
+ * If dev is a HSR slave device, return the other slave device. Return=
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
+/*
+ *	Slave NETDEV_GOING_DOWN - disallow for slaves? No use really, let's
+ * 		assume the admin user knows what he/she is doing...
+ */
+
+	struct net_device *slave, *other_slave;
+	struct hsr_priv *hsr_priv;
+	int old_operstate;
+	int mtu_max;
+	int res;
+
+	hsr_priv =3D get_hsr_master(ptr);
+	if (hsr_priv) { 	/* Is ptr a slave device? */
+		slave =3D ptr;
+		other_slave =3D get_other_slave(hsr_priv, slave);
+	} else {
+		if (!is_hsr_master(ptr))
+			return NOTIFY_DONE;
+		hsr_priv =3D netdev_priv(ptr);
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
+		 * it doesn't set IF_OPER_LOWERLAYERDOWN (?) */
+		hsr_set_operstate(hsr_priv->dev, slave, other_slave);
+		hsr_check_announce(hsr_priv->dev, old_operstate);
+		break;
+	case NETDEV_CHANGEADDR:
+		/* This should not happen since there's no ndo_set_mac_address()
+		 * for HSR devices - i.e. not supported. */
+		if (ptr =3D=3D hsr_priv->dev)
+			break;
+		if (ptr =3D=3D hsr_priv->slave[0])
+			memcpy(hsr_priv->dev->dev_addr,
+					hsr_priv->slave[0]->dev_addr, ETH_ALEN);
+
+		/* Make sure we recognize frames from ourselves in hsr_rcv() */
+		res =3D hsr_create_self_node(&hsr_priv->self_node_db,
+					hsr_priv->dev->dev_addr,
+					hsr_priv->slave[1] ?
+						hsr_priv->slave[1]->dev_addr :
+						hsr_priv->dev->dev_addr);
+		if (res)
+			netdev_warn(hsr_priv->dev,
+					"Could not update HSR node address.\n");
+
+		if (ptr =3D=3D hsr_priv->slave[0])
+			call_netdevice_notifiers(NETDEV_CHANGEADDR, hsr_priv->dev);
+		break;
+	case NETDEV_CHANGEMTU:
+		if (ptr =3D=3D hsr_priv->dev)
+			break; /* Handled in ndo_change_mtu() */
+		mtu_max =3D hsr_get_max_mtu(hsr_priv);
+		if (hsr_priv->dev->mtu > mtu_max)
+			dev_set_mtu(hsr_priv->dev, mtu_max);
+		break;
+	case NETDEV_UNREGISTER:
+		if (ptr =3D=3D hsr_priv->slave[0])
+			hsr_priv->slave[0] =3D NULL;
+		if (ptr =3D=3D hsr_priv->slave[1])
+			hsr_priv->slave[1] =3D NULL;
+
+		/* There should really be a way to set a new slave device... */
+
+		break;
+	case NETDEV_PRE_TYPE_CHANGE:
+		/* HSR works only on Ethernet devices. Refuse slave to change
+		 * its type. */
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
+		hsr_prune_nodes(&hsr_priv->node_db);
+	rcu_read_unlock();
+
+	prune_timer.expires =3D jiffies + msecs_to_jiffies(PRUNE_PERIOD);
+	add_timer(&prune_timer);
+}
+
+
+static struct sk_buff *strip_hsr_tag(struct sk_buff *skb)
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
+/*
+ * The uses I can see for these HSR supervision frames are:
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
+static bool is_supervision_frame(struct sk_buff *skb)
+{
+	struct hsr_sup_tag *hsr_stag;
+
+	if (compare_ether_addr(eth_hdr(skb)->h_dest, hsr_multicast_addr))
+		return 0;
+
+	hsr_stag =3D (struct hsr_sup_tag *) skb->data;
+	if (get_hsr_stag_path(hsr_stag) !=3D 0x0f)
+		return 0;
+	if ((hsr_stag->HSR_TLV_Type !=3D HSR_TLV_ANNOUNCE) &&
+				(hsr_stag->HSR_TLV_Type !=3D HSR_TLV_LIFE_CHECK))
+		return 0;
+	if (hsr_stag->HSR_TLV_Length !=3D 12)
+		return 0;
+
+	return 1;
+}
+
+
+/*
+ * Implementation somewhat according to IEC-62439-3, p. 43
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
+		dev_in_idx =3D HSR_DEV_SLAVE1;
+		dev_other_idx =3D HSR_DEV_SLAVE2;
+	} else {
+		dev_in_idx =3D HSR_DEV_SLAVE2;
+		dev_other_idx =3D HSR_DEV_SLAVE1;
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
+				(skb->pkt_type =3D=3D PACKET_MULTICAST) ||
+				(skb->pkt_type =3D=3D PACKET_BROADCAST))
+		deliver_to_self =3D 1;
+	else if (!compare_ether_addr(eth_hdr(skb)->h_dest,
+						hsr_priv->dev->dev_addr)) {
+		skb->pkt_type =3D PACKET_HOST;
+		deliver_to_self =3D 1;
+	}
+
+
+	rcu_read_lock(); /* node_db */
+	node =3D hsr_find_node(&hsr_priv->node_db, skb);
+
+	if (is_supervision_frame(skb)) {
+		skb_pull(skb, sizeof(struct hsr_sup_tag));
+		node =3D hsr_merge_node(hsr_priv, node, skb);
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
+		/* Source node unknown; don't create a network loop */
+		rcu_read_unlock(); /* node_db */
+		netdev_info(dev, "HSR: Got HSR frame from unknown node %pM: "
+				 "dropping it.\n",
+				 eth_hdr(skb)->h_source);
+		kfree_skb(skb);
+		hsr_priv->dev->stats.rx_errors++;
+		return NET_RX_SUCCESS;
+	}
+
+	/*
+	 * Register ALL incoming frames as outgoing through the other interfa=
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
+#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+		/* We have to memmove the whole payload below */
+		skb_deliver =3D skb_copy(skb, GFP_ATOMIC);
+#else
+		skb_deliver =3D skb_clone(skb, GFP_ATOMIC);
+#endif
+		if (!skb_deliver) {
+			deliver_to_self =3D 0;
+			hsr_priv->dev->stats.rx_dropped++;
+		}
+	}
+
+	if (deliver_to_self) {
+		bool multicast_frame;
+
+		skb_deliver =3D strip_hsr_tag(skb_deliver);
+		if (!skb_deliver) {
+			hsr_priv->dev->stats.rx_dropped++;
+			goto forward;
+		}
+#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS)
+		/*
+		 * skb_deliver should be linear here, after the call to
+		 * skb_copy() above. We need to memmove the whole payload to
+		 * work around alignment problems caused by the 6-byte HSR tag.
+		 */
+		memmove(skb_deliver->data - HSR_TAGLEN, skb_deliver->data,
+							skb_deliver->len);
+		skb_deliver->data -=3D HSR_TAGLEN;
+		skb_deliver->tail -=3D HSR_TAGLEN;
+#endif
+		skb_deliver->dev =3D hsr_priv->dev;
+		hsr_addr_subst(hsr_priv, skb_deliver);
+		multicast_frame =3D (skb_deliver->pkt_type =3D=3D PACKET_MULTICAST);
+		ret =3D netif_rx(skb_deliver);
+		if (ret =3D=3D NET_RX_DROP)
+			hsr_priv->dev->stats.rx_dropped++;
+		else {
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
+	.type =3D htons(ETH_P_HSR),
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
index 0000000..e2a4c6d
--- /dev/null
+++ b/net/hsr/hsr_main.h
@@ -0,0 +1,157 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
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
+ *	2011-2012 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef _HSR_PRIVATE_H
+#define _HSR_PRIVATE_H
+
+#include <linux/netdevice.h>
+#include <linux/list.h>
+
+
+/*
+ * Time constants as specified in the HSR specification (IEC-62439-3 2=
010)
+ * Table 8.
+ * All values in milliseconds.
+ */
+#define HSR_LIFE_CHECK_INTERVAL		 2000 /* ms */
+#define HSR_NODE_FORGET_TIME		60000 /* ms */
+#define HSR_ANNOUNCE_INTERVAL		  100 /* ms */
+
+/*
+ * By how much may slave1 and slave2 timestamps of latest received fra=
me from
+ * each node differ before we notify of communication problem?
+ */
+#define MAX_SLAVE_DIFF			 3000 /* ms */
+
+/*
+ * How often shall we check for broken ring and remove node entries ol=
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
+/*
+ * HSR Tag.
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
+/*
+ * The helper functions below assumes that 'path' occupies the 4 most
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
+/*
+ * HSR Supervision Frame data types.
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
+
+struct hsr_priv {
+	struct list_head	hsr_list;	/* List of hsr devices */
+	struct rcu_head		rcu_head;
+	struct net_device	*dev;
+	struct net_device	*slave[2];
+	struct list_head	node_db;	/* Other HSR nodes */
+	struct list_head	self_node_db;	/* MACs of slaves */
+	struct timer_list	announce_timer;	/* Supervision frame dispatch */
+	int announce_count;
+	u16 sequence_nr;
+	spinlock_t seqnr_lock;			/* locking for sequence_nr */
+};
+
+extern const u8 hsr_multicast_addr[ETH_ALEN];
+
+void register_hsr_master(struct hsr_priv *hsr_priv);
+void unregister_hsr_master(struct hsr_priv *hsr_priv);
+bool is_hsr_slave(struct net_device *dev);
+
+#endif /*  _HSR_PRIVATE_H */
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
new file mode 100644
index 0000000..877268b
--- /dev/null
+++ b/net/hsr/hsr_netlink.c
@@ -0,0 +1,305 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
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
+ *	2011-2012 Arvid Brodin, arvid.brodin@xdin.com
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
+	[IFLA_HSR_SLAVE1]	=3D { .type =3D NLA_U32 },
+	[IFLA_HSR_SLAVE2]	=3D { .type =3D NLA_U32 },
+};
+
+
+/*
+ * Here, it seems a netdevice has already been allocated for us, and t=
he
+ * hsr_dev_setup routine has been executed. Nice!
+ */
+static int hsr_newlink(struct net *src_net, struct net_device *dev,
+		       struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net_device *link[2];
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
+	return hsr_dev_finalize(dev, link);
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
+	[HSR_A_IFINDEX] =3D { .type =3D NLA_U32 },
+	[HSR_A_IF1AGE] =3D { .type =3D NLA_U32 }, /* 32-bit int */
+	[HSR_A_IF2AGE] =3D { .type =3D NLA_U32 }, /* 32-bit int */
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
+static int hsr_genl_seq =3D 0;
+
+
+
+static struct sk_buff *hsr_create_genl_msg(void **pmsg_head, unsigned =
gfp,
+					   int cmd)
+{
+	struct sk_buff *skb;
+
+	skb =3D genlmsg_new(NLMSG_GOODSIZE, gfp);
+	if (!skb)
+		return NULL;
+
+	*pmsg_head =3D genlmsg_put(skb, 0, hsr_genl_seq++, &hsr_genl_family, =
0,
+									cmd);
+	if (!pmsg_head) {
+		kfree_skb(skb);
+		return NULL;
+	}
+
+	return skb;
+}
+
+
+/*
+ * This is called if for some node with MAC address addr, we only get =
frames
+ * over one of the slave interfaces. This would indicate an open netwo=
rk ring
+ * (i.e. a link has failed somewhere).
+ */
+void hsr_nl_ringerror(unsigned char addr[ETH_ALEN], int dev_idx)
+{
+	struct sk_buff *skb;
+	void *msg_head;
+	int res;
+
+	skb =3D hsr_create_genl_msg(&msg_head, GFP_ATOMIC, HSR_C_RING_ERROR);
+	if (!skb)
+		return;
+
+	res =3D nla_put(skb, HSR_A_NODE_ADDR, ETH_ALEN, addr);
+	if (res < 0)
+		goto nla_put_failure;
+	res =3D nla_put_u32(skb, HSR_A_IFINDEX, dev_idx);
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
+}
+
+/*
+ * This is called when we haven't heard from the node with MAC address=
 addr for
+ * some time (just before the node is removed from the node table/list=
).
+ */
+void hsr_nl_nodedown(unsigned char addr[ETH_ALEN])
+{
+	struct sk_buff *skb;
+	void *msg_head;
+	int res;
+
+	skb =3D hsr_create_genl_msg(&msg_head, GFP_ATOMIC, HSR_C_NODE_DOWN);
+	if (!skb)
+		return;
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
+}
+
+/*
+ * HSR_C_GET_NODE_STATUS lets userspace query the internal HSR node ta=
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
+	char *node_addr;
+	struct net_device *hsr_dev;
+
+	/* For sending */
+	struct sk_buff *skb_out;
+	void *msg_head;
+	struct hsr_priv *hsr_priv;
+	unsigned long time1, time2;
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
+	skb_out =3D hsr_create_genl_msg(&msg_head, GFP_ATOMIC,
+							HSR_C_SET_NODE_STATUS);
+	if (!skb_out)
+		return -ENOMEM;
+
+	res =3D nla_put_u32(skb_out, HSR_A_IFINDEX, hsr_dev->ifindex);
+	if (res < 0)
+		goto nla_put_failure;
+
+	node_addr =3D nla_data(info->attrs[HSR_A_NODE_ADDR]);
+	res =3D nla_put(skb_out, HSR_A_NODE_ADDR, ETH_ALEN, node_addr);
+	if (res < 0)
+		goto nla_put_failure;
+
+	hsr_priv =3D netdev_priv(hsr_dev);
+	hsr_get_node_times(hsr_priv, node_addr, &time1, &time2);
+
+	res =3D nla_put_u32(skb_out, HSR_A_IF1AGE, time1 ?
+					jiffies_to_msecs(jiffies - time1) : -1);
+	if (res < 0)
+		goto nla_put_failure;
+	res =3D nla_put_u32(skb_out, HSR_A_IF2AGE, time2 ?
+					jiffies_to_msecs(jiffies - time2) : -1);
+	if (res < 0)
+		goto nla_put_failure;
+
+	genlmsg_end(skb_out, msg_head);
+	genlmsg_unicast(genl_info_net(info), skb_out, info->snd_pid);
+
+	return 0;
+
+nla_put_failure:
+	kfree_skb(skb_out);
+
+	return -ENOMEM;
+
+invalid:
+	return -EINVAL;
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
+	rc =3D genl_register_mc_group(&hsr_genl_family, &hsr_network_genl_mcg=
rp);
+	if (rc)
+		goto fail_genl_register_mc_group;
+
+	return 0;
+
+fail_genl_register_mc_group:
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
index 0000000..4282d9f
--- /dev/null
+++ b/net/hsr/hsr_netlink.h
@@ -0,0 +1,64 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
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
+ *	2011-2012 Arvid Brodin, arvid.brodin@xdin.com
+ */
+
+#ifndef __HSR_NETLINK_H
+#define __HSR_NETLINK_H
+
+/* attributes */
+enum {
+	HSR_A_UNSPEC,
+	HSR_A_NODE_ADDR,
+	HSR_A_IFINDEX,
+	HSR_A_IF1AGE,
+	HSR_A_IF2AGE,
+	__HSR_A_MAX,
+};
+#define HSR_A_MAX (__HSR_A_MAX - 1)
+
+
+#ifdef __KERNEL__
+
+#include <linux/if_ether.h>
+#include <linux/module.h>
+
+int __init hsr_netlink_init(void);
+void __exit hsr_netlink_exit(void);
+
+void hsr_nl_ringerror(unsigned char addr[ETH_ALEN], int dev_idx);
+void hsr_nl_nodedown(unsigned char addr[ETH_ALEN]);
+void hsr_nl_framedrop(int dropcount, int dev_idx);
+void hsr_nl_linkdown(int dev_idx);
+
+
+/*
+ * Generic Netlink HSR family definition
+ */
+
+
+#endif /* __KERNEL__ */
+
+
+
+/* commands */
+enum {
+	HSR_C_UNSPEC,
+	HSR_C_RING_ERROR,
+	HSR_C_NODE_DOWN,
+	HSR_C_GET_NODE_STATUS,
+	HSR_C_SET_NODE_STATUS,
+	__HSR_C_MAX,
+};
+#define HSR_C_MAX (__HSR_C_MAX - 1)
+
+
+
+#endif /* __HSR_NETLINK_H */
