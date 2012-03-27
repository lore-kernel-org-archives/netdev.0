From: Arvid Brodin <arvid.brodin@enea.com>
Subject: [RFC] net/hsr: Add support for IEC 62439-3 High-availability Seamless
 Redundancy
Date: Tue, 27 Mar 2012 15:20:45 +0200
Message-ID: <4F71BEAD.5080605@enea.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Bruno Ferreira <balferreira@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sestofw01.enea.se ([192.36.1.252]:26099 "HELO mx-3.enea.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1751037Ab2C0NUu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Mar 2012 09:20:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

This is a patch-in-progress for adding support for instant-failover
redundant Ethernet networks using less and easier cabling than what's
required by e.g. bonding/pairing. General info about HSR can be
found at

http://en.wikipedia.org/wiki/High-availability_Seamless_Redundancy

but basically, HSR is a network topology where all nodes are equipped
with (at least) two physical Ethernet interfaces, and are daisy-
chained together to form a ring. Each node forwards all frames that
are not exclusively destined to itself, except for frames that have
been forwarded before. Each frame is sent in both directions on the
ring by the source node.


I have two wishes with this RFC:

1) General code review. I haven't worked with neither kernel network code nor
   used rcu locking before, so I feel I need a sanity check of the code. Am I
   doing things in a sane way?

   There are some debug printouts and "//" comments in this code. These will be
   removed in the final patch, please ignore them.

   Missing in this patch are mechanisms for detecting and reporting network
   problems to user space (via Netlink), which I'm working on now.


2) I have a locking problem that I haven't managed to figure out. This happens
   the first time I send any packet (hsr_dev_xmit() in hsr_device.c:121, called
   from hsr_device.c:147). It happens even if I set skb2 to NULL (i.e. only send
   one copy):

=============================================
[ INFO: possible recursive locking detected ]
2.6.37 #118
---------------------------------------------
swapper/0 is trying to acquire lock:
 (_xmit_ETHER#2){+.-...}, at: [<901bf38e>] sch_direct_xmit+0x24/0x152

but task is already holding lock:
 (_xmit_ETHER#2){+.-...}, at: [<901b4d1a>] dev_queue_xmit+0x31e/0x3cc

other info that might help us debug this:
4 locks held by swapper/0:
 #0:  (&n->timer){+.-...}, at: [<9002bc20>] run_timer_softirq+0x98/0x184
 #1:  (rcu_read_lock_bh){.+....}, at: [<901b49fc>] dev_queue_xmit+0x0/0x3cc
 #2:  (_xmit_ETHER#2){+.-...}, at: [<901b4d1a>] dev_queue_xmit+0x31e/0x3cc
 #3:  (rcu_read_lock_bh){.+....}, at: [<901b49fc>] dev_queue_xmit+0x0/0x3cc

stack backtrace:
Call trace:
 [<9001c640>] dump_stack+0x18/0x20
 [<90040eac>] validate_chain+0x40c/0x9ac
 [<90041a58>] __lock_acquire+0x60c/0x670
 [<90042f32>] lock_acquire+0x3a/0x48
 [<902201a4>] _raw_spin_lock+0x20/0x44
 [<901bf38e>] sch_direct_xmit+0x24/0x152
 [<901b4c14>] dev_queue_xmit+0x218/0x3cc
 [<9021c2e0>] slave_xmit+0x10/0x14
 [<9021c540>] hsr_dev_xmit+0x88/0x8c
 [<901b4942>] dev_hard_start_xmit+0x3c6/0x480
 [<901b4d34>] dev_queue_xmit+0x338/0x3cc
 [<901e3cd8>] arp_xmit+0x8/0xc
 [<901e4436>] arp_send+0x2a/0x2c
 [<901e4e74>] arp_solicit+0x15c/0x170
 [<901bad0c>] neigh_timer_handler+0x1c0/0x204
 [<9002bc8a>] run_timer_softirq+0x102/0x184
 [<900287d8>] __do_softirq+0x64/0xe0
 [<9002896a>] do_softirq+0x26/0x48
 [<90028a66>] irq_exit+0x2e/0x64
 [<90019f16>] do_IRQ+0x46/0x5c
 [<90018428>] irq_level0+0x18/0x60
 [<9021cc16>] rest_init+0x72/0x98
 [<9000063c>] start_kernel+0x21c/0x258
 [<00000000>] 0x0

   Any idea why this happens? I need help!


And here's the actual patch (against linux-next-20120306):

---
 include/linux/if_ether.h |    1 +
 include/linux/if_link.h  |   11 +
 net/Kconfig              |    1 +
 net/Makefile             |    1 +
 net/hsr/Kconfig          |   84 ++++++++
 net/hsr/Makefile         |    7 +
 net/hsr/hsr_device.c     |  518 ++++++++++++++++++++++++++++++++++++++++++++++
 net/hsr/hsr_device.h     |   22 ++
 net/hsr/hsr_framereg.c   |  157 ++++++++++++++
 net/hsr/hsr_framereg.h   |   23 ++
 net/hsr/hsr_main.c       |  383 ++++++++++++++++++++++++++++++++++
 net/hsr/hsr_netlink.c    |   78 +++++++
 net/hsr/hsr_netlink.h    |   21 ++
 net/hsr/hsr_private.h    |  114 ++++++++++
 14 files changed, 1418 insertions(+), 0 deletions(-)

diff --git a/include/linux/if_ether.h b/include/linux/if_ether.h
index 56d907a..0d0e2f9 100644
--- a/include/linux/if_ether.h
+++ b/include/linux/if_ether.h
@@ -83,6 +83,7 @@
 #define ETH_P_TIPC	0x88CA		/* TIPC 			*/
 #define ETH_P_8021AH	0x88E7          /* 802.1ah Backbone Service Tag */
 #define ETH_P_1588	0x88F7		/* IEEE 1588 Timesync */
+#define ETH_P_HSR	0x88FB		/* IEC 62439-3 HSR/PRP		*/
 #define ETH_P_FCOE	0x8906		/* Fibre Channel over Ethernet  */
 #define ETH_P_TDLS	0x890D          /* TDLS */
 #define ETH_P_FIP	0x8914		/* FCoE Initialization Protocol */
diff --git a/include/linux/if_link.h b/include/linux/if_link.h
index 4b24ff4..3e3efb4 100644
--- a/include/linux/if_link.h
+++ b/include/linux/if_link.h
@@ -391,4 +391,15 @@ struct ifla_port_vsi {
 	__u8 pad[3];
 };
 
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
index e07272d..99d666d 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -216,6 +216,7 @@ source "net/dcb/Kconfig"
 source "net/dns_resolver/Kconfig"
 source "net/batman-adv/Kconfig"
 source "net/openvswitch/Kconfig"
+source "net/hsr/Kconfig"
 
 config RPS
 	boolean
diff --git a/net/Makefile b/net/Makefile
index ad432fa..7d8787f 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -70,3 +70,4 @@ obj-$(CONFIG_CEPH_LIB)		+= ceph/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
 obj-$(CONFIG_NFC)		+= nfc/
 obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
+obj-$(CONFIG_HSR)		+= hsr/
diff --git a/net/hsr/Kconfig b/net/hsr/Kconfig
new file mode 100644
index 0000000..895afda
--- /dev/null
+++ b/net/hsr/Kconfig
@@ -0,0 +1,84 @@
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
+	  relying on this code in a safety critical system. In particular, the
+	  standard is very diffuse on how to use the Ring ID field in the HSR
+	  tag, and it's probable that this code does not do the right thing.
+
+	  If unsure, say N.
+
+if HAVE_EFFICIENT_UNALIGNED_ACCESS
+
+config NONSTANDARD_HSR
+	bool "HSR: Use efficient tag (breaks HSR standard, read help!)"
+	depends on HSR
+	---help---
+	  The HSR standard specifies a 6-byte HSR tag to be inserted into the
+	  transmitted network frames. This breaks the 32-bit alignment that the
+	  Linux network stack relies on, and would cause kernel panics on
+	  certain architectures. To avoid this, the whole frame payload is
+	  memmoved 2 bytes on reception on these architectures - which is very
+	  inefficient!
+
+	  If you select Y here, 2 bytes of padding is inserted into the HSR tag,
+	  which makes it possible to skip the memmove. This however breaks
+	  compatibility with compliant HSR devices. I.e., either all or none of
+	  the devices in your HSR ring needs to have this option set.
+
+	  Your architecture has HAVE_EFFICIENT_UNALIGNED_ACCESS, so you do not
+	  need this unless you have other nodes in your ring which have this
+	  option set.
+
+	  If unsure, say N.
+
+endif # HAVE_EFFICIENT_UNALIGNED_ACCESS
+if !HAVE_EFFICIENT_UNALIGNED_ACCESS
+
+config NONSTANDARD_HSR
+	bool "HSR: Use efficient tag (breaks HSR standard, read help!)"
+	depends on HSR
+	---help---
+	  The HSR standard specifies a 6-byte HSR tag to be inserted into the
+	  transmitted network frames. This breaks the 32-bit alignment that the
+	  Linux network stack relies on, and would cause kernel panics on
+	  certain architectures. To avoid this, the whole frame payload is
+	  memmoved 2 bytes on reception on these architectures - which is very
+	  inefficient!
+
+	  If you select Y here, 2 bytes of padding is inserted into the HSR tag,
+	  which makes it possible to skip the memmove. This however breaks
+	  compatibility with compliant HSR devices. I.e., either all or none of
+	  the devices in your HSR ring needs to have this option set.
+
+	  Your architecture does not have HAVE_EFFICIENT_UNALIGNED_ACCESS, so
+	  you should seriously consider saying Y here if performance is at all
+	  important to you.
+
+	  If unsure, say N.
+
+endif # !HAVE_EFFICIENT_UNALIGNED_ACCESS
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
+obj-$(CONFIG_HSR)	+= hsr.o
+
+hsr-y			:= hsr_main.o hsr_framereg.o hsr_device.o hsr_netlink.o
diff --git a/net/hsr/hsr_device.c b/net/hsr/hsr_device.c
new file mode 100644
index 0000000..f83bdf5
--- /dev/null
+++ b/net/hsr/hsr_device.c
@@ -0,0 +1,518 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2012 Arvid Brodin, arvid.brodin@enea.com
+ *
+ * This file contains device methods for creating, using and destroying
+ * virtual HSR devices.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/etherdevice.h>
+#include <linux/if_arp.h>
+#include <linux/rtnetlink.h>
+#include <linux/netfilter.h>
+#include "hsr_framereg.h"
+#include "hsr_private.h"
+
+
+static int is_up(struct net_device *dev)
+{
+	return (dev->flags & IFF_UP);
+}
+
+
+void hsr_check_announce(struct net_device *hsr_dev, struct net_device *slave1,
+						struct net_device *slave2)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv = netdev_priv(hsr_dev);
+
+	if (!hsr_priv->online && is_up(hsr_dev) &&
+					(is_up(slave1) || is_up(slave2))) {
+		hsr_priv->online = 1;
+		hsr_priv->announce_count = 0;
+		hsr_priv->announce_timer.expires = jiffies +
+					HSR_ANNOUNCE_INTERVAL * HZ / 1000;
+		add_timer(&hsr_priv->announce_timer);
+	} else {
+		hsr_priv->online = 0;
+		del_timer(&hsr_priv->announce_timer);
+	}
+}
+
+static int hsr_dev_open(struct net_device *dev)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv = netdev_priv(dev);
+
+	dev_open(hsr_priv->slave_data[0].dev_data.dev);
+	dev_open(hsr_priv->slave_data[1].dev_data.dev);
+
+	return 0;
+}
+
+static int hsr_dev_close(struct net_device *dev)
+{
+	// FIXME: reset status of slaves
+	return 0;
+}
+
+
+static void hsr_fill_tag(struct hsr_ethhdr *hsr_ethhdr, struct hsr_priv *hsr_priv)
+{
+	u16 path;
+	u16 LSDU_size;
+	unsigned long irqflags;
+
+	/*
+	 * IEC 62439-1, p 48, says the 4-bit "path" field can take values
+	 * between 0001-1001 ("ring identifier", for regular HSR frames),
+	 * or 1111 ("HSR management", supervision frames). Unfortunately, the
+	 * spec writers forgot to explain what a "ring identifier" is, or
+	 * how it is used. So we just set this to 0001 for regular frames,
+	 * and 1111 for supervision frames.
+	 */
+	path = 0x1;
+
+	/*
+	 * IEC 62439-1, p 12: "The link service data unit in an Ethernet frame
+	 * is the content of the frame located between the Length/Type field
+	 * and the Frame Check Sequence."
+	 *
+	 * IEC 62439-3, p 48, specifies the "original LPDU" to include the
+	 * original "LT" field (what "LT" means is not explained anywhere as
+	 * far as I can see - perhaps "Length/Type"?). So LSDU_size might
+	 * equal original length + 2.
+	 *   Also, the fact that this field is not used anywhere (might be used
+	 * by a RedBox connecting HSR and PRP nets?) means I cannot test its
+	 * correctness. Instead of guessing, I set this to 0 here, to make any
+	 * problems immediately apparent. Anyone using this driver with PRP/HSR
+	 * RedBoxes might need to fix this...
+	 */
+	LSDU_size = 0;
+	hsr_ethhdr->hsr_tag.path_and_LSDU_size =
+					htons((u16) (path << 12) | LSDU_size);
+
+	spin_lock_irqsave(&hsr_priv->seqlock, irqflags);
+	hsr_ethhdr->hsr_tag.sequence_nr = htons(hsr_priv->sequence_nr);
+	hsr_priv->sequence_nr++;
+	spin_unlock_irqrestore(&hsr_priv->seqlock, irqflags);
+
+	hsr_ethhdr->hsr_tag.encap_proto = hsr_ethhdr->ethhdr.h_proto;
+
+	hsr_ethhdr->ethhdr.h_proto = htons(ETH_P_HSR);
+}
+
+static int slave_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	skb->dev = dev;
+	skb->priority = 1; // FIXME: what does this mean?
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
+	hsr_priv = netdev_priv(dev);
+	hsr_ethhdr = (struct hsr_ethhdr *) skb->data;
+
+	if ((ntohs(skb->protocol) != ETH_P_HSR) ||
+			(ntohs(hsr_ethhdr->ethhdr.h_proto) != ETH_P_HSR)) {
+
+		hsr_fill_tag(hsr_ethhdr, hsr_priv);
+		skb->protocol = htons(ETH_P_HSR);
+	}
+
+	skb2 = skb_clone(skb, GFP_ATOMIC);
+
+	res1 = NET_XMIT_DROP;
+	res2 = NET_XMIT_DROP;
+	if (!register_frame(&hsr_priv->slave_data[0].dev_data, skb))
+		res1 = slave_xmit(skb, hsr_priv->slave_data[0].dev_data.dev);
+	if (skb2 && !register_frame(&hsr_priv->slave_data[1].dev_data, skb2))
+		res2 = slave_xmit(skb2, hsr_priv->slave_data[1].dev_data.dev);
+
+	if (likely(res1 == NET_XMIT_SUCCESS || res1 == NET_XMIT_CN ||
+			res2 == NET_XMIT_SUCCESS || res2 == NET_XMIT_CN)) {
+		hsr_priv->dev_data.dev->stats.tx_packets++;
+		hsr_priv->dev_data.dev->stats.tx_bytes += skb->len;
+	} else
+		hsr_priv->dev_data.dev->stats.tx_dropped++;
+
+	return NETDEV_TX_OK;
+}
+
+
+static int hsr_header_create(struct sk_buff *skb, struct net_device *dev,
+					unsigned short type,
+					const void *daddr, const void *saddr,
+					unsigned int len)
+{
+	int res;
+
+	/* Make room for the HSR tag now. We will fill it in later (in
+	   hsr_dev_xmit) */
+	skb_push(skb, HSR_TAGLEN);
+	res = eth_header(skb, dev, type, daddr, saddr, len + HSR_TAGLEN);
+	if (res <= 0)
+		return res;
+	skb_reset_mac_header(skb);
+
+	return res + HSR_TAGLEN;
+}
+
+
+static const struct header_ops hsr_header_ops = {
+	.create	 = hsr_header_create,
+	.parse	 = eth_header_parse,
+};
+
+
+static int set_mac_address(struct net_device *dev, const char new_mac[ETH_ALEN])
+{
+	struct sockaddr sockaddr;
+	int res;
+
+	memcpy(sockaddr.sa_data, new_mac, dev->addr_len);
+	sockaddr.sa_family = dev->type;
+	res = dev_set_mac_address(dev, &sockaddr);
+
+	return res;
+}
+
+
+static void send_hsr_supervision_frame(struct net_device *hsr_dev, u8 type)
+{
+	struct hsr_priv *hsr_priv;
+	struct sk_buff *skb;
+	struct hsr_ethhdr *hsr_ethhdr;
+	unsigned char *MacAddressA;
+	u16 path, HSR_Ver, HSR_TLV_Length;
+	unsigned long irqflags;
+
+	skb = alloc_skb(sizeof(struct ethhdr) +
+				sizeof(struct hsr_supervision_tag) +
+				LL_RESERVED_SPACE(hsr_dev) +
+				hsr_dev->needed_tailroom, GFP_ATOMIC);
+	if (skb == NULL)
+		return;
+
+	hsr_priv = netdev_priv(hsr_dev);
+
+	skb_reserve(skb, LL_RESERVED_SPACE(hsr_dev));
+	skb_reset_network_header(skb);
+	MacAddressA = (unsigned char *) skb_put(skb, ETH_ALEN);
+	memcpy(MacAddressA, hsr_dev->dev_addr, ETH_ALEN);
+	*MacAddressA = 0xff;
+
+	skb->dev = hsr_dev;
+	skb->protocol = htons(ETH_P_HSR);
+
+	if (dev_hard_header(skb, skb->dev, ETH_P_HSR, hsr_multicast_addr,
+					skb->dev->dev_addr, skb->len) < 0)
+		goto out;
+
+	hsr_ethhdr = (struct hsr_ethhdr *) skb->data;
+
+	path = 0x0f;
+	HSR_Ver = 0;
+	hsr_ethhdr->hsr_tag.path_and_LSDU_size = htons(path << 12 | HSR_Ver);
+
+	spin_lock_irqsave(&hsr_priv->seqlock, irqflags);
+	hsr_ethhdr->hsr_tag.sequence_nr = htons(hsr_priv->sequence_nr);
+	hsr_priv->sequence_nr++;
+	spin_unlock_irqrestore(&hsr_priv->seqlock, irqflags);
+
+	HSR_TLV_Length = 12;
+	hsr_ethhdr->hsr_tag.encap_proto = htons(type << 8 | HSR_TLV_Length);
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
+	hsr_priv = (struct hsr_priv *) data;
+
+	if (hsr_priv->announce_count < 3) {
+		send_hsr_supervision_frame(hsr_priv->dev_data.dev, 22);
+		hsr_priv->announce_count++;
+	} else
+		send_hsr_supervision_frame(hsr_priv->dev_data.dev, 23);
+
+	if (hsr_priv->announce_count < 3)
+		hsr_priv->announce_timer.expires = jiffies +
+					HSR_ANNOUNCE_INTERVAL * HZ / 1000;
+	else
+		hsr_priv->announce_timer.expires = jiffies +
+					HSR_LIFE_CHECK_INTERVAL * HZ / 1000;
+
+	if (hsr_priv->online)
+		add_timer(&hsr_priv->announce_timer);
+}
+
+
+
+
+static void restore_slaves(struct net_device *hsr_dev)
+{
+	struct hsr_priv *hsr_priv;
+	struct net_device *slave[2];
+	int i;
+	int res;
+
+	hsr_priv = netdev_priv(hsr_dev);
+	for (i = 0; i < 2; i++)
+		slave[i] = hsr_priv->slave_data[i].dev_data.dev;
+
+	rtnl_lock();
+
+	/* Restore promiscuity */
+	for (i = 0; i < 2; i++) {
+		if (!hsr_priv->slave_data[i].promisc)
+			continue;
+		res = dev_set_promiscuity(slave[i],
+					-hsr_priv->slave_data[i].promisc);
+		if (res)
+			pr_info("HSR: Cannot restore promiscuity (%s, %d)\n",
+							slave[i]->name,
+							res);
+	}
+
+	/* Restore MAC addresses */
+	for (i = 0; i < 2; i++) {
+		if (!memcmp(hsr_priv->slave_data[i].orig_mac,
+							slave[i]->dev_addr,
+							slave[i]->addr_len))
+			continue;
+		dev_close(slave[i]);
+		res = set_mac_address(slave[i],
+					hsr_priv->slave_data[i].orig_mac);
+		if (res)
+			pr_info("HSR: Could not restore MAC address "
+							"(%s, %d)\n",
+							slave[i]->name,
+							res);
+		}
+
+	/* Restore up state */
+	for (i = 0; i < 2; i++)
+		if (hsr_priv->slave_data[i].was_up)
+			dev_open(slave[i]);
+		else
+			dev_close(slave[i]);
+
+	rtnl_unlock();
+}
+
+static void reclaim_hsr_dev(struct rcu_head *rh)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv = container_of(rh, struct hsr_priv, rcu_head);
+	free_netdev(hsr_priv->dev_data.dev);
+}
+
+/*
+ * According to comments in the declaration of struct net_device, this function
+ * is "Called from unregister, can be used to call free_netdev". Ok then...
+ */
+static void hsr_dev_destroy(struct net_device *hsr_dev)
+{
+	struct hsr_priv *hsr_priv;
+
+	hsr_priv = netdev_priv(hsr_dev);
+
+	unregister_hsr_master(hsr_priv);    /* calls list_del_rcu on hsr_priv */
+	restore_slaves(hsr_dev);
+	call_rcu(&hsr_priv->rcu_head, reclaim_hsr_dev);   /* reclaim hsr_priv */
+}
+
+static struct net_device_ops hsr_device_ops = {
+	.ndo_open = hsr_dev_open,
+	.ndo_stop = hsr_dev_close,
+	.ndo_start_xmit = hsr_dev_xmit,
+};
+
+
+void hsr_dev_setup(struct net_device *dev)
+{
+	random_ether_addr(dev->dev_addr);
+
+	ether_setup(dev);
+	dev->header_ops		 = &hsr_header_ops;
+	dev->netdev_ops		 = &hsr_device_ops;
+	dev->hard_header_len	+= HSR_TAGLEN;
+	dev->mtu		-= HSR_TAGLEN;
+	dev->tx_queue_len	 = 0;
+
+	dev->destructor = hsr_dev_destroy;
+}
+
+
+/*
+ * If dev is a HSR master, return 1; otherwise, return 0.
+ */
+int is_hsr_master(struct net_device *dev)
+{
+	return (dev->netdev_ops->ndo_start_xmit == hsr_dev_xmit);
+}
+
+static int check_slave_ok(struct net_device *dev)
+{
+	/* Don't allow HSR on non-ethernet like devices */
+	if ((dev->flags & IFF_LOOPBACK) || (dev->type != ARPHRD_ETHER) ||
+						(dev->addr_len != ETH_ALEN)) {
+		pr_info("%s: Cannot enslave loopback or non-ethernet device\n",
+								dev->name);
+		return -EINVAL;
+	}
+
+	/* Don't allow enslaving hsr devices */
+	if (is_hsr_master(dev)) {
+		pr_info("%s: Don't try to create trees of hsr devices!\n",
+								dev->name);
+		return -ELOOP;
+	}
+
+	/* FIXME: What about VLAN devices, bonded devices, etc? */
+
+	return 0;
+}
+
+static void init_dev_data(struct hsr_dev_data *dev_data, struct net_device *dev)
+{
+	dev_data->dev = dev;
+	INIT_LIST_HEAD(&dev_data->frame_db);
+}
+
+int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *slave[2])
+{
+	struct hsr_priv *hsr_priv;
+	struct hsr_slave_data *mac_slave_data1, *mac_slave_data2;
+	int i;
+	int res;
+
+	hsr_priv = netdev_priv(hsr_dev);
+	init_dev_data(&hsr_priv->dev_data, hsr_dev);
+	for (i = 0; i < 2; i++)
+		init_dev_data(&hsr_priv->slave_data[i].dev_data, slave[i]);
+
+	spin_lock_init(&hsr_priv->seqlock);
+	hsr_priv->sequence_nr = 0;
+
+	init_timer(&hsr_priv->announce_timer);
+	hsr_priv->announce_timer.function = hsr_announce;
+	hsr_priv->announce_timer.data = (unsigned long) hsr_priv;
+
+
+/*
+ * FIXME: do I need to set the value of these?
+ *
+ * - hsr_dev->flags
+ * - hsr_dev->priv_flags
+ */
+
+	for (i = 0; i < 2; i++) {
+		res = check_slave_ok(slave[i]);
+		if (res)
+			return res;
+	}
+
+	hsr_dev->features = slave[0]->features & slave[1]->features;
+
+	/* Save/init data needed for restore */
+	for (i = 0; i < 2; i++) {
+		hsr_priv->slave_data[i].was_up = slave[i]->flags & IFF_UP;
+		memcpy(hsr_priv->slave_data[i].orig_mac, slave[i]->dev_addr,
+								ETH_ALEN);
+		hsr_priv->slave_data[i].promisc = 0;
+	}
+
+	/* MAC addresses */
+	if ((!slave[1]->netdev_ops->ndo_set_mac_address) &&
+				(slave[0]->netdev_ops->ndo_set_mac_address)) {
+		mac_slave_data1 = &hsr_priv->slave_data[1];
+		mac_slave_data2 = &hsr_priv->slave_data[0];
+	} else {
+		mac_slave_data1 = &hsr_priv->slave_data[0];
+		mac_slave_data2 = &hsr_priv->slave_data[1];
+	}
+
+	/* Set hsr_dev's MAC address to that of mac_slave1 */
+	memcpy(hsr_dev->dev_addr, mac_slave_data1->dev_data.dev->dev_addr,
+							hsr_dev->addr_len);
+
+	/* Set mac_slave2's MAC address to that of the hsr device and slave1 */
+	if (!mac_slave_data2->dev_data.dev->netdev_ops->ndo_set_mac_address) {
+		pr_info("None of the slaves support changing MAC address; at "
+			 "least one slave must support this for HSR\n");
+		return -EOPNOTSUPP;
+	}
+	dev_close(mac_slave_data2->dev_data.dev);
+	res = set_mac_address(mac_slave_data2->dev_data.dev, hsr_dev->dev_addr);
+	if (res) {
+		pr_info("HSR: dev_set_mac_address failed (%s, %d)\n",
+					mac_slave_data2->dev_data.dev->name,
+					res);
+		goto fail;
+	}
+	if (mac_slave_data2->was_up)
+		dev_open(mac_slave_data2->dev_data.dev);
+
+	/* MTU */
+	for (i = 0; i < 2; i++)
+		if (slave[i]->mtu < hsr_dev->mtu)
+			hsr_dev->mtu = slave[i]->mtu;
+
+
+	/* Promiscuity */
+	for (i = 0; i < 2; i++) {
+		res = dev_set_promiscuity(slave[i], 1);
+		if (res) {
+			pr_info("HSR: Cannot set promiscuous mode (%s, %d)\n",
+								slave[i]->name,
+								res);
+			goto fail;
+		}
+		/* Remember what we have done so we can restore it later */
+		hsr_priv->slave_data[i].promisc = 1;
+	}
+
+	res = register_netdevice(hsr_dev);
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
index 0000000..a1adab4
--- /dev/null
+++ b/net/hsr/hsr_device.h
@@ -0,0 +1,22 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2012 Arvid Brodin, arvid.brodin@enea.com
+ */
+
+#ifndef __HSR_DEVICE_H
+#define __HSR_DEVICE_H
+
+#include <linux/netdevice.h>
+
+void hsr_dev_setup(struct net_device *dev);
+int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *dev1,
+						struct net_device *dev2);
+
+#endif /* __HSR_DEVICE_H */
diff --git a/net/hsr/hsr_framereg.c b/net/hsr/hsr_framereg.c
new file mode 100644
index 0000000..8747242
--- /dev/null
+++ b/net/hsr/hsr_framereg.c
@@ -0,0 +1,157 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2012 Arvid Brodin, arvid.brodin@enea.com
+ *
+ * The HSR spec says never to forward the same frame twice on the same
+ * interface. A frame is identified by its source MAC address and its HSR
+ * sequence number. This code keeps track of senders and their sequence numbers
+ * to allow filtering of duplicate frames.
+ */
+
+#include <linux/if_ether.h>
+#include <linux/etherdevice.h>
+#include <linux/slab.h>
+#include <linux/rculist.h>
+#include "hsr_private.h"
+#include "hsr_framereg.h"
+
+
+/*
+	TODO: use hash lists for mac addresses (linux/jhash.h)?
+*/
+
+struct mac_entry {
+	struct list_head mac_list;
+	unsigned char addr[ETH_ALEN];
+	unsigned long timestamp;
+	u16 last_seq;
+	struct rcu_head rcu_head;
+};
+
+/*
+ * Search for mac entry. Caller must hold rcu read lock.
+ */
+static struct mac_entry *find_mac_entry(struct list_head *frame_db,
+						unsigned char addr[ETH_ALEN])
+{
+	struct mac_entry *mac_entry;
+
+	list_for_each_entry_rcu(mac_entry, frame_db, mac_list)
+		if (!compare_ether_addr(mac_entry->addr, addr))
+			return mac_entry;
+
+	return NULL;
+}
+
+
+/*
+ * above(a, b) - return 1 if a > b, 0 otherwise.
+ * Uses C 16-bit unsigned arithmetic, with differences > (1 << 15) interpreted
+ * as negative.
+ */
+#define	MAX_RANGE_DIFF	(1 << 15)
+static int above(u16 a, u16 b)
+{
+	if ((u16) (a - b) == (u16) (b - a))
+		return (a > b);
+	return (((u16) (a - b) > (u16) 0) &&
+		((u16) (a - b) <= (u16) MAX_RANGE_DIFF));
+}
+#define below(a, b)		above((b), (a))
+#define above_or_equal(a, b)	(!below((a), (b)))
+#define below_or_equal(a, b)	(!above((a), (b)))
+
+
+/*
+ * Parameters:
+ *	'skb' is a HSR Ethernet frame (with a HSR tag inserted), with a valid
+ *	ethhdr->h_source address and skb->mac_header set.
+ *
+ * Return:
+ *	 1 if frame can be shown to have been sent recently on this interface,
+ *	 0 otherwise, or
+ *	-1 on error
+ */
+int register_frame(struct hsr_dev_data *dev_data, struct sk_buff *skb)
+{
+	struct mac_entry *mac_entry;
+	struct hsr_ethhdr *hsr_ethhdr;
+
+	if (!skb_mac_header_was_set(skb)) {
+		printk(KERN_INFO "%s:%d: MAC header not set\n", __func__, __LINE__);
+		return -1;
+	}
+	hsr_ethhdr = (struct hsr_ethhdr *) skb_mac_header(skb);
+
+	rcu_read_lock();
+	mac_entry = find_mac_entry(&dev_data->frame_db, hsr_ethhdr->ethhdr.h_source);
+	if (!mac_entry) {
+		rcu_read_unlock();
+
+		mac_entry = kmalloc(sizeof(*mac_entry), GFP_ATOMIC);
+		if (!mac_entry)
+			return -1;
+
+		memcpy(mac_entry->addr, hsr_ethhdr->ethhdr.h_source, ETH_ALEN);
+		mac_entry->last_seq = hsr_ethhdr->hsr_tag.sequence_nr;
+		mac_entry->timestamp = jiffies;
+		list_add_tail_rcu(&mac_entry->mac_list, &dev_data->frame_db);
+
+		return 0;
+	}
+
+	if (below_or_equal(hsr_ethhdr->hsr_tag.sequence_nr, mac_entry->last_seq)) {
+		rcu_read_unlock();
+		return 1;
+	}
+
+	mac_entry->last_seq = hsr_ethhdr->hsr_tag.sequence_nr;
+	mac_entry->timestamp = jiffies;
+	rcu_read_unlock();
+	return 0;
+}
+
+/*
+ * Caller must hold rcu read lock.
+ */
+void update_node_seqnr(struct list_head *frame_db, u8 ethaddr[ETH_ALEN],
+							u16 sequence_nr)
+{
+	struct mac_entry *mac_entry;
+
+	mac_entry = find_mac_entry(frame_db, ethaddr);
+	if (mac_entry) {
+		mac_entry->last_seq = sequence_nr;
+		mac_entry->timestamp = jiffies;
+	}
+}
+
+
+static void mac_entry_reclaim(struct rcu_head *rh)
+{
+	kfree(container_of(rh, struct mac_entry, rcu_head));
+}
+
+/*
+ * Remove stale sequence_nr records. Called by timer every
+ * HSR_LIFE_CHECK_INTERVAL (two seconds or so). This is also the only function
+ * that removes mac_entries; it shouldn't need to be rcu_read_lock():ed.
+ */
+void prune_mac_entries(struct list_head *frame_db)
+{
+	struct mac_entry *mac_entry, *mac_entry_next;
+
+	list_for_each_entry_safe(mac_entry, mac_entry_next, frame_db, mac_list)
+		if (time_after(jiffies, mac_entry->timestamp +
+					HSR_NODE_FORGET_TIME * HZ / 1000)) {
+			list_del_rcu(&mac_entry->mac_list);
+			call_rcu(&mac_entry->rcu_head, mac_entry_reclaim);
+		}
+}
diff --git a/net/hsr/hsr_framereg.h b/net/hsr/hsr_framereg.h
new file mode 100644
index 0000000..970181e
--- /dev/null
+++ b/net/hsr/hsr_framereg.h
@@ -0,0 +1,23 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2012 Arvid Brodin, arvid.brodin@enea.com
+ */
+
+#ifndef _HSR_FRAMEREG_H
+#define _HSR_FRAMEREG_H
+
+#include "hsr_private.h"
+
+int register_frame(struct hsr_dev_data *dev_data, struct sk_buff *skb);
+void update_node_seqnr(struct list_head *frame_db, u8 ethaddr[ETH_ALEN],
+							u16 sequence_nr);
+void prune_mac_entries(struct list_head *frame_db);
+
+#endif /* _HSR_FRAMEREG_H */
diff --git a/net/hsr/hsr_main.c b/net/hsr/hsr_main.c
new file mode 100644
index 0000000..dda5062
--- /dev/null
+++ b/net/hsr/hsr_main.c
@@ -0,0 +1,383 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2012 Arvid Brodin, arvid.brodin@enea.com
+ *
+ * In addition to routines for registering and unregistering HSR support, this
+ * file also contains the receive routine that handles all incoming frames with
+ * Ethertype (protocol) ETH_P_HSR.
+ */
+
+#include <linux/netdevice.h>
+#include <linux/rculist.h>
+#include <linux/timer.h>
+#include <linux/etherdevice.h>
+#include "hsr_private.h"
+#include "hsr_framereg.h"
+#include "hsr_netlink.h"
+
+
+/* Multicast address for HSR Supervision frames */
+const u8 hsr_multicast_addr[ETH_ALEN] = {0x01, 0x15, 0x4e, 0x00, 0x01, 0x00};
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
+		if (hsr_priv_it == hsr_priv) {
+			list_del_rcu(&hsr_priv_it->hsr_list);
+			return;
+		}
+}
+
+
+/*
+ * If dev is a HSR slave device, return the virtual master device. Return NULL
+ * otherwise.
+ */
+static struct hsr_priv *get_hsr_master(struct net_device *dev)
+{
+	struct hsr_priv *hsr_priv;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hsr_priv, &hsr_list, hsr_list)
+		if ((dev == hsr_priv->slave_data[0].dev_data.dev) ||
+				(dev == hsr_priv->slave_data[1].dev_data.dev)) {
+			rcu_read_unlock();
+			return hsr_priv;
+		}
+
+	rcu_read_unlock();
+	return NULL;
+}
+
+/*
+ * If dev is a HSR slave device, return the other slave device. Return NULL
+ * otherwise.
+ */
+static struct hsr_slave_data *get_other_slave(struct hsr_priv *hsr_priv,
+							struct net_device *dev)
+{
+	if (dev == hsr_priv->slave_data[0].dev_data.dev)
+		return (&hsr_priv->slave_data[1]);
+	if (dev == hsr_priv->slave_data[1].dev_data.dev)
+		return (&hsr_priv->slave_data[0]);
+
+	return NULL;
+}
+
+
+static int hsr_netdev_notify(struct notifier_block *nb, unsigned long event, void *ptr)
+{
+
+/*
+ * Should do:
+ *
+ * - error monitoring (broken link)
+ * - slave monitoring (disallow down, reconfiguring ?)
+
+	register_netdevice_notifier(...);
+	NETDEV_GOING_DOWN
+	NETDEV_CHANGEADDR
+	NETDEV_CHANGE (dev->flags)
+	NETDEV_UNREGISTER
+ */
+
+	struct net_device *slave, *other_slave;
+	struct hsr_priv *hsr_priv;
+	struct hsr_slave_data *other_data;
+
+	hsr_priv = get_hsr_master(ptr);
+	if (hsr_priv) {
+		slave = ptr;
+		other_data = get_other_slave(hsr_priv, slave);
+		other_slave = other_data->dev_data.dev;
+	} else {
+		if (!is_hsr_master(ptr))
+			return NOTIFY_DONE;
+		hsr_priv = netdev_priv(ptr);
+		slave = hsr_priv->slave_data[0].dev_data.dev;
+		other_slave = hsr_priv->slave_data[1].dev_data.dev;
+	}
+
+	switch (event) {
+	case NETDEV_UP:
+	case NETDEV_DOWN:
+//		printk(KERN_INFO "Got %s event\n", ((struct net_device *) ptr)->name);
+		hsr_check_announce(hsr_priv->dev_data.dev, slave, other_slave);
+	}
+
+	return NOTIFY_DONE;
+}
+
+
+static struct timer_list prune_timer;
+
+static void hsr_prune_nodes(unsigned long data)
+{
+	struct hsr_priv *hsr_priv;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hsr_priv, &hsr_list, hsr_list) {
+		prune_mac_entries(&hsr_priv->dev_data.frame_db);
+		prune_mac_entries(&hsr_priv->slave_data[0].dev_data.frame_db);
+		prune_mac_entries(&hsr_priv->slave_data[1].dev_data.frame_db);
+	}
+	rcu_read_unlock();
+
+	prune_timer.expires = jiffies + PRUNE_PERIOD * HZ / 1000;
+	add_timer(&prune_timer);
+}
+
+/*
+ * Find all occurences of node with source addr ethaddr, and set their
+ * sequence number to sequence_nr. Used e.g. when a node re-announces itself
+ * after a reboot. Without this, its frames might get filtered until its
+ * entry expires.
+ */
+static void hsr_update_nodes(u8 ethaddr[ETH_ALEN], u16 sequence_nr)
+{
+	struct hsr_priv *hsr_priv;
+
+	rcu_read_lock();
+	list_for_each_entry_rcu(hsr_priv, &hsr_list, hsr_list) {
+		update_node_seqnr(&hsr_priv->dev_data.frame_db,
+							ethaddr, sequence_nr);
+		update_node_seqnr(&hsr_priv->slave_data[0].dev_data.frame_db,
+							ethaddr, sequence_nr);
+		update_node_seqnr(&hsr_priv->slave_data[1].dev_data.frame_db,
+							ethaddr, sequence_nr);
+	}
+	rcu_read_unlock();
+}
+
+
+static struct sk_buff *strip_hsr_tag(struct sk_buff *skb)
+{
+	struct hsr_tag *hsr_tag;
+	struct sk_buff *skb2;
+
+	skb2 = skb_share_check(skb, GFP_ATOMIC);
+	if (unlikely(!skb2))
+		goto err_free;
+	skb = skb2;
+
+	if (unlikely(!pskb_may_pull(skb, HSR_TAGLEN)))
+		goto err_free;
+
+	hsr_tag = (struct hsr_tag *) skb->data;
+	skb->protocol = hsr_tag->encap_proto;
+	skb_reset_network_header(skb);  // Huh???
+	skb_pull_rcsum(skb, HSR_TAGLEN);
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
+ * The only uses I can see for these HSR supervision frames are:
+ * 1) Use the frames that are sent after node initialization ("HSR_TLV.Type =
+ *    22") to reset any sequence_nr counters belonging to that node.
+ * 2) Perhaps use the LifeCheck frames to detect ring breaks? I.e., the
+ *    LifeCheck frames, since they are periodically sent, will make sure broken
+ *    connections are detected even if the network is completely silent
+ *    otherwise. They don't need any special treatment for this though; just
+ *    register them as normal frames and throw them away.
+ */
+static int handle_supervision_frame(struct hsr_priv *hsr_priv,
+							struct sk_buff *skb)
+{
+	struct hsr_supervision_tag *hsr_stag;
+
+	if (compare_ether_addr(eth_hdr(skb)->h_dest, hsr_multicast_addr))
+		return 0;
+
+	hsr_stag = (struct hsr_supervision_tag *) skb->data;
+	if (ntohs(hsr_stag->path_and_HSR_ver) >> 12 != 0x0f)
+		return 0;
+	if ((hsr_stag->HSR_TLV_Type != 22) && (hsr_stag->HSR_TLV_Type != 23))
+		return 0;
+	if (hsr_stag->HSR_TLV_Length != 12)
+		return 0;
+
+//	printk("%s:%d: got HSR supervision frame (type %d)\n", __FILE__, __LINE__, hsr_stag->HSR_TLV_Type);
+
+	/* Ok, we have a valid HSR supervision frame. */
+	if (hsr_stag->HSR_TLV_Type == 23)
+		hsr_update_nodes(hsr_stag->MacAddressA, hsr_stag->sequence_nr);
+
+	return 1;
+}
+
+
+/*
+ * Implementation somewhat according to IEC-62439-3, p. 43
+ */
+static int hsr_rcv(struct sk_buff *skb, struct net_device *dev,
+			struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct hsr_priv *hsr_priv;
+	struct hsr_slave_data *other_slave_data;
+	int deliver_to_self;
+	struct sk_buff *skb_deliver;
+	int ret;
+
+	hsr_priv = get_hsr_master(dev);
+
+	if (!hsr_priv) {
+		printk(KERN_INFO "HSR: Got HSR frame on non-HSR device; dropping it.\n");
+		kfree_skb(skb);
+		return NET_RX_DROP;
+	}
+
+	/* Receive this frame? */
+	deliver_to_self = 0;
+// ???	if (is_etherdev_addr(hsr_dev, eth_hdr(skb)->h_dest)) {
+	if ((skb->pkt_type == PACKET_HOST) ||
+				(skb->pkt_type == PACKET_MULTICAST) ||
+				(skb->pkt_type == PACKET_BROADCAST))
+		if (register_frame(&hsr_priv->dev_data, skb) == 0)
+			deliver_to_self = 1;
+
+	if (handle_supervision_frame(hsr_priv, skb))
+		deliver_to_self = 0;
+
+	/* Forward this frame? */
+	other_slave_data = NULL;
+	if (skb->pkt_type != PACKET_HOST) {
+		other_slave_data = get_other_slave(hsr_priv, dev);
+		if (register_frame(&other_slave_data->dev_data, skb) == 1)
+			other_slave_data = NULL;
+	}
+
+	if (!deliver_to_self && !other_slave_data) {
+		kfree_skb(skb);
+		return NET_RX_SUCCESS;
+	}
+
+	skb_deliver = skb;
+	if (deliver_to_self && other_slave_data) {
+#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && \
+						!defined(CONFIG_NONSTANDARD_HSR)
+		/* We have to memmove the whole payload below */
+		skb_deliver = skb_copy(skb, GFP_ATOMIC);
+#else
+		skb_deliver = skb_clone(skb, GFP_ATOMIC);
+#endif
+		if (!skb_deliver) {
+			deliver_to_self = 0;
+			hsr_priv->dev_data.dev->stats.rx_dropped++;
+		}
+	}
+
+	if (deliver_to_self) {
+		skb_deliver = strip_hsr_tag(skb_deliver);
+		if (!skb_deliver) {
+			hsr_priv->dev_data.dev->stats.rx_dropped++;
+			goto forward;
+		}
+#if !defined(CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS) && \
+						!defined(CONFIG_NONSTANDARD_HSR)
+		/*
+		 * skb_deliver should be linear here, after the call to
+		 * skb_copy() in the block above. We need to memmove the
+		 * whole payload to work around alignment problems caused by
+		 * the 6-byte HSR tag.
+		 */
+		memmove(skb_deliver->data - HSR_TAGLEN, skb_deliver->data,
+							skb_deliver->len);
+		skb_deliver->data -= HSR_TAGLEN;
+		skb_deliver->tail -= HSR_TAGLEN;
+		skb_reset_network_header(skb_deliver);
+#endif
+		skb_deliver->dev = hsr_priv->dev_data.dev;
+		ret = netif_rx(skb_deliver);
+		// ^^ Pass frame to hsrX (receive);
+		/*	netif_rx(skb)? VLAN code does this...
+			dev_forward_skb(hsr_dev, skb)? (loopback)
+			netif_receive_skb(skb)? bridge code does this:
+				NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, indev, NULL, netif_receive_skb);
+			What's the "right way"?
+		 */
+		if (ret == NET_RX_DROP)
+			hsr_priv->dev_data.dev->stats.rx_dropped++;
+		else {
+			hsr_priv->dev_data.dev->stats.rx_packets++;
+			hsr_priv->dev_data.dev->stats.rx_bytes += skb->len;
+		}
+	}
+
+forward:
+	if (other_slave_data) {
+		skb_push(skb, ETH_HLEN);
+		skb->dev = other_slave_data->dev_data.dev;
+		dev_queue_xmit(skb);
+	}
+
+	return NET_RX_SUCCESS;
+}
+
+
+static struct packet_type hsr_pt __read_mostly = {
+	.type = htons(ETH_P_HSR),
+	.func = hsr_rcv,
+};
+
+static struct notifier_block hsr_nb = {
+	.notifier_call = hsr_netdev_notify,	/* Slave event notifications */
+};
+
+
+static int __init hsr_init(void)
+{
+	int res;
+
+	BUG_ON(sizeof(struct hsr_tag) != HSR_TAGLEN);
+	BUG_ON(sizeof(struct hsr_ethhdr) != ETH_HLEN + HSR_TAGLEN);
+
+	dev_add_pack(&hsr_pt);
+
+	init_timer(&prune_timer);
+	prune_timer.function = hsr_prune_nodes;
+	prune_timer.data = 0;
+	prune_timer.expires = jiffies + PRUNE_PERIOD * HZ / 1000;
+	add_timer(&prune_timer);
+
+	register_netdevice_notifier(&hsr_nb);
+
+	res = hsr_netlink_init();
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
diff --git a/net/hsr/hsr_netlink.c b/net/hsr/hsr_netlink.c
new file mode 100644
index 0000000..f391a12
--- /dev/null
+++ b/net/hsr/hsr_netlink.c
@@ -0,0 +1,78 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2012 Arvid Brodin, arvid.brodin@enea.com
+ *
+ * Routines for handling Netlink messages for HSR.
+ */
+
+#include "hsr_netlink.h"
+#include <linux/kernel.h>
+#include <net/rtnetlink.h>
+#include "hsr_private.h"
+
+static const struct nla_policy hsr_policy[IFLA_HSR_MAX + 1] = {
+	[IFLA_HSR_SLAVE1]	= { .type = NLA_U32 },
+	[IFLA_HSR_SLAVE2]	= { .type = NLA_U32 },
+};
+
+
+/*
+ * Here, it seems a netdevice has already been allocated for us, and the
+ * hsr_dev_setup routine has been executed. Nice!
+ */
+static int hsr_newlink(struct net *src_net, struct net_device *dev,
+				struct nlattr *tb[], struct nlattr *data[])
+{
+	struct net_device *link[2];
+
+	if (!data[IFLA_HSR_SLAVE1]) {
+		printk(KERN_INFO "IFLA_HSR_SLAVE1 missing!\n");
+		return -EINVAL;
+	}
+	link[0] = __dev_get_by_index(src_net, nla_get_u32(data[IFLA_HSR_SLAVE1]));
+	if (!data[IFLA_HSR_SLAVE2]) {
+		printk(KERN_INFO "IFLA_HSR_SLAVE2 missing!\n");
+		return -EINVAL;
+	}
+	link[1] = __dev_get_by_index(src_net, nla_get_u32(data[IFLA_HSR_SLAVE2]));
+
+	if (!link[0] || !link[1])
+		return -ENODEV;
+	if (link[0] == link[1])
+		return -EINVAL;
+
+	return hsr_dev_finalize(dev, link);
+}
+
+static struct rtnl_link_ops hsr_link_ops __read_mostly = {
+	.kind		= "hsr",
+	.maxtype	= IFLA_HSR_MAX,
+	.policy		= hsr_policy,
+	.priv_size	= sizeof(struct hsr_priv),
+	.setup		= hsr_dev_setup,
+//	.validate	= vlan_validate,
+	.newlink	= hsr_newlink,
+//	.changelink	= vlan_changelink,
+//	.dellink	= hsr_dellink,  dev->destructor() called automatically?
+//	.get_size	= vlan_get_size,
+//	.fill_info	= vlan_fill_info,
+};
+
+int __init hsr_netlink_init(void)
+{
+	return rtnl_link_register(&hsr_link_ops);
+}
+
+void __exit hsr_netlink_exit(void)
+{
+	rtnl_link_unregister(&hsr_link_ops);
+}
+
+MODULE_ALIAS_RTNL_LINK("hsr");
diff --git a/net/hsr/hsr_netlink.h b/net/hsr/hsr_netlink.h
new file mode 100644
index 0000000..9d8a14d
--- /dev/null
+++ b/net/hsr/hsr_netlink.h
@@ -0,0 +1,21 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2012 Arvid Brodin, arvid.brodin@enea.com
+ */
+
+#ifndef __HSR_NETLINK_H
+#define __HSR_NETLINK_H
+
+#include <linux/module.h>
+
+int __init hsr_netlink_init(void);
+void __exit hsr_netlink_exit(void);
+
+#endif /* __HSR_NETLINK_H */
diff --git a/net/hsr/hsr_private.h b/net/hsr/hsr_private.h
new file mode 100644
index 0000000..2bab99e
--- /dev/null
+++ b/net/hsr/hsr_private.h
@@ -0,0 +1,114 @@
+/*
+ * Copyright 2011-2012 Autronica Fire and Security AS
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * Author(s):
+ *	2011-2012 Arvid Brodin, arvid.brodin@enea.com
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
+ * Time constants as specified in the HSR specification (IEC-62439-3) Table 8.
+ * All values in milliseconds.
+ */
+#define HSR_LIFE_CHECK_INTERVAL		 2000
+#define HSR_NODE_FORGET_TIME		60000
+#define HSR_ANNOUNCE_INTERVAL		  100
+
+/* How often shall we check if node entry is older than HSR_NODE_FORGET_TIME? */
+#define PRUNE_PERIOD			 5000
+
+/*
+ * HSR Tag.
+ * As defined in IEC-62439-3, the HSR tag is really { ethertype = 0x88FB, path,
+ * LSDU_size, sequence Nr }. But we let eth_header() create { h_dest, h_source,
+ * h_proto = 0x88FB }, and add { path, LSDU_size, sequence Nr, encapsulated
+ * protocol } instead.
+ */
+#ifdef CONFIG_NONSTANDARD_HSR
+#define HSR_TAGLEN	8
+#else
+#define HSR_TAGLEN	6
+#endif
+struct hsr_tag {
+/*
+	This is nice but I'm not sure it is "portably compatible" with
+	endianness swaps:
+	__be16		path:4;
+	__be16		LSDU_size:12;
+*/
+	__be16		path_and_LSDU_size;
+	__be16		sequence_nr;
+	__be16		encap_proto;
+#ifdef CONFIG_NONSTANDARD_HSR
+	__be16		padding;
+#endif
+} __attribute__((packed));
+
+struct hsr_ethhdr {
+	struct ethhdr	ethhdr;
+	struct hsr_tag	hsr_tag;
+} __attribute__((packed));
+
+
+struct hsr_supervision_tag {
+	__be16		path_and_HSR_ver;
+	__be16		sequence_nr;
+	__u8		HSR_TLV_Type;
+	__u8		HSR_TLV_Length;
+#ifdef CONFIG_NONSTANDARD_HSR
+	__be16		padding;
+#endif
+	unsigned char	MacAddressA[ETH_ALEN];
+} __attribute__((packed));
+
+
+struct hsr_dev_data {
+	struct net_device *dev;
+	struct list_head frame_db;
+};
+
+struct hsr_slave_data {
+	struct hsr_dev_data dev_data;
+	unsigned char orig_mac[ETH_ALEN];
+	int promisc;
+	int was_up;
+};
+
+struct hsr_priv {
+	struct list_head hsr_list;		/* List of hsr devices */
+	struct rcu_head rcu_head;
+	struct hsr_dev_data dev_data;
+	struct hsr_slave_data slave_data[2];
+	struct timer_list announce_timer;	/* Supervision frame dispatch */
+	int announce_count;
+	int online;
+	u16 sequence_nr;
+	spinlock_t seqlock;
+};
+
+extern const u8 hsr_multicast_addr[ETH_ALEN];
+
+void register_hsr_master(struct hsr_priv *hsr_priv);
+void unregister_hsr_master(struct hsr_priv *hsr_priv);
+
+void hsr_dev_setup(struct net_device *dev);
+int hsr_dev_finalize(struct net_device *hsr_dev, struct net_device *slave[2]);
+
+void hsr_check_announce(struct net_device *hsr_dev, struct net_device *slave1,
+						struct net_device *slave2);
+int is_hsr_master(struct net_device *dev);
+
+void skb_print(struct sk_buff *skb, const char *file, const int line);
+
+#endif /*  _HSR_PRIVATE_H */


-- 
Arvid Brodin
Enea Services Stockholm AB - since February 16 a part of Xdin in the Alten
Group. Soon we will be working under the common brand Xdin. Read more at
www.xdin.com.
