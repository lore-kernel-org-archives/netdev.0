From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: [RFC PATCH 1/3] net: add simplified 16 bit Toeplitz hash function for
	transmit side hashing
Date: Fri, 17 Dec 2010 17:00:38 -0800
Message-ID: <20101218010038.28602.50399.stgit@gitlad.jf.intel.com>
References: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:61152 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756381Ab0LRBBB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Dec 2010 20:01:01 -0500
Received: from gitlad.jf.intel.com (gitlad.jf.intel.com [127.0.0.1])
	by gitlad.jf.intel.com (8.14.2/8.14.2) with ESMTP id oBI10c0g028765
	for <netdev@vger.kernel.org>; Fri, 17 Dec 2010 17:00:38 -0800
In-Reply-To: <20101218004210.28602.18499.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This change provides transmit side scaling functionality by providing a
hash function that uses the 16 bit key to determine the queue number
that should be used for transmit.

The advantages of the 16 bit key are two fold.  First it allows for a much
simpler computation as the number of outcomes are reduced to 64K, and
generation of the hash can be done using only 64bytes of data with 4
lookups in said data.  The second advantage is that both TX and RX sides
will generate the same hash while using the same function.  This is due the
fact that both source and destination will see the same key even though the
destination port is offset 16 bits from the source.  The downside of this
is that the resultant hash is only 16 bits wide itself.  It can be expanded
to 32 bits, but the 2nd 16 bits will be identical to the first.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
---

 include/linux/netdevice.h |    2 +
 include/linux/toeplitz.h  |   89 +++++++++++++++++++++++++++++++++++++++++++++
 net/core/dev.c            |   68 ++++++++++++++++++++++++++++++++++
 3 files changed, 159 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/toeplitz.h

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index cc916c5..01b5989 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2370,6 +2370,8 @@ static inline u32 dev_ethtool_get_flags(struct net_device *dev)
 	return dev->ethtool_ops->get_flags(dev);
 }
 
+extern u16 toeplitz_select_queue(struct net_device *dev, struct sk_buff *skb);
+
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
 
 /* netdev_printk helpers, similar to dev_printk */
diff --git a/include/linux/toeplitz.h b/include/linux/toeplitz.h
new file mode 100644
index 0000000..2360cf4
--- /dev/null
+++ b/include/linux/toeplitz.h
@@ -0,0 +1,89 @@
+/*
+ * Copyright (c) 2010, Intel Corporation.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
+ * Place - Suite 330, Boston, MA 02111-1307 USA.
+ *
+ * Author: Alexander Duyck <alexander.h.duyck@intel.com>
+ */
+
+#ifndef _LINUX_TOEPLITZ_H
+#define _LINUX_TOEPLITZ_H
+
+/*
+ * The code below implements a simplified version of toeplitz hashing.  To
+ * simplify it I have reduced the key size from 40 bytes to a repeating
+ * pattern of 2 bytes.  Doing this does two things.  First it reduces the
+ * computation complexity significantly since I can XOR together all of the
+ * input into a single 16 bit value when computing the hash.  Secondly it
+ * allows both directions of a flow to generate the same hash since now we
+ * are looking at the XORed result of the source against the destination as
+ * input.
+ */
+#define TOEPLITZ_KEY_0 0xE3
+#define TOEPLITZ_KEY_1 0xAF
+
+static inline u8 toeplitz_get_key_byte(int byte_number)
+{
+	if (byte_number & 0x1)
+		return TOEPLITZ_KEY_1;
+	else
+		return TOEPLITZ_KEY_0;
+}
+
+#define TOEPLITZ_KEY (((u64)(TOEPLITZ_KEY_1) << 32) | \
+		      ((u64)(TOEPLITZ_KEY_0) << 24) | \
+		      ((u64)(TOEPLITZ_KEY_1) << 16) | \
+		      ((u64)(TOEPLITZ_KEY_0) <<  8) | \
+		      ((u64)(TOEPLITZ_KEY_1)))
+
+#define TOEPLITZ_PRECOMPUTED_VALUE(_input) ( \
+	((((~_input >>  0) & 0x1) - 1) & ((TOEPLITZ_KEY >> 1) & 0xFFFFFFFF)) ^ \
+	((((~_input >>  1) & 0x1) - 1) & ((TOEPLITZ_KEY >> 2) & 0xFFFFFFFF)) ^ \
+	((((~_input >>  2) & 0x1) - 1) & ((TOEPLITZ_KEY >> 3) & 0xFFFFFFFF)) ^ \
+	((((~_input >>  3) & 0x1) - 1) & ((TOEPLITZ_KEY >> 4) & 0xFFFFFFFF)))
+
+static const u32 toeplitz_input_values[16] = {
+	TOEPLITZ_PRECOMPUTED_VALUE(0x0),
+	TOEPLITZ_PRECOMPUTED_VALUE(0x1),
+	TOEPLITZ_PRECOMPUTED_VALUE(0x2),
+	TOEPLITZ_PRECOMPUTED_VALUE(0x3),
+	TOEPLITZ_PRECOMPUTED_VALUE(0x4),
+	TOEPLITZ_PRECOMPUTED_VALUE(0x5),
+	TOEPLITZ_PRECOMPUTED_VALUE(0x6),
+	TOEPLITZ_PRECOMPUTED_VALUE(0x7),
+	TOEPLITZ_PRECOMPUTED_VALUE(0x8),
+	TOEPLITZ_PRECOMPUTED_VALUE(0x9),
+	TOEPLITZ_PRECOMPUTED_VALUE(0xA),
+	TOEPLITZ_PRECOMPUTED_VALUE(0xB),
+	TOEPLITZ_PRECOMPUTED_VALUE(0xC),
+	TOEPLITZ_PRECOMPUTED_VALUE(0xD),
+	TOEPLITZ_PRECOMPUTED_VALUE(0xE),
+	TOEPLITZ_PRECOMPUTED_VALUE(0xF)
+};
+
+static inline u16 toeplitz_compute_hash(u32 input)
+{
+	u16 result = 0;
+
+	input ^= input >> 16;
+
+	result ^= toeplitz_input_values[(input & 0x000F)];
+	result ^= toeplitz_input_values[(input & 0x00F0) >>  4] >>  4;
+	result ^= toeplitz_input_values[(input & 0x0F00) >>  8] >>  8;
+	result ^= toeplitz_input_values[(input & 0xF000) >> 12] >> 12;
+
+	return result;
+}
+
+#endif /* _LINUX_TOEPLITZ_H */
diff --git a/net/core/dev.c b/net/core/dev.c
index 92d414a..8b4e4d3 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -132,6 +132,7 @@
 #include <trace/events/skb.h>
 #include <linux/pci.h>
 #include <linux/inetdevice.h>
+#include <linux/toeplitz.h>
 
 #include "net-sysfs.h"
 
@@ -2170,6 +2171,73 @@ u16 __skb_tx_hash(const struct net_device *dev, const struct sk_buff *skb,
 }
 EXPORT_SYMBOL(__skb_tx_hash);
 
+static inline u16 toeplitz_hash_skb(const struct net_device *dev,
+				    const struct sk_buff *skb)
+{
+	union {
+		unsigned char *network;
+		struct iphdr *ipv4;
+		struct ipv6hdr *ipv6;
+	} hdr;
+	__be32 input;
+	u16 hash;
+	__be16 protocol = vlan_get_protocol(skb);
+
+	/* snag network header to get L4 type and address */
+	hdr.network = skb_network_header(skb);
+
+	/* Currently only IPv4/IPv6 with TCP is supported */
+	switch (protocol) {
+	case __constant_htons(ETH_P_IP):
+		input = hdr.ipv4->saddr ^ hdr.ipv4->daddr;
+		if (hdr.ipv4->protocol == IPPROTO_TCP)
+			input ^= *(__be32 *)tcp_hdr(skb);
+		break;
+	case __constant_htons(ETH_P_IPV6):
+		input = hdr.ipv6->saddr.s6_addr32[0] ^
+			hdr.ipv6->saddr.s6_addr32[1] ^
+			hdr.ipv6->saddr.s6_addr32[2] ^
+			hdr.ipv6->saddr.s6_addr32[3] ^
+			hdr.ipv6->daddr.s6_addr32[0] ^
+			hdr.ipv6->daddr.s6_addr32[1] ^
+			hdr.ipv6->daddr.s6_addr32[2] ^
+			hdr.ipv6->daddr.s6_addr32[3];
+		if (hdr.ipv6->nexthdr == IPPROTO_TCP)
+			input ^= *(__be32 *)tcp_hdr(skb);
+		break;
+	default:
+		return 0;
+	}
+
+	hash = toeplitz_compute_hash(ntohl(input)) & 0x7F;
+
+	return (dev->real_num_tx_queues * hash) >> 7;
+}
+
+u16 toeplitz_select_queue(struct net_device *dev, struct sk_buff *skb)
+{
+	struct sock *sk = skb->sk;
+	int queue_index = sk_tx_queue_get(sk);
+
+	if (queue_index >= 0 && queue_index < dev->real_num_tx_queues)
+		return queue_index;
+
+	queue_index = 0;
+
+	if (dev->real_num_tx_queues > 1)
+		queue_index = toeplitz_hash_skb(dev, skb);
+
+	if (sk) {
+		struct dst_entry *dst =
+			rcu_dereference_check(sk->sk_dst_cache, 1);
+		if (dst && skb_dst(skb) == dst)
+			sk_tx_queue_set(sk, queue_index);
+	}
+
+	return queue_index;
+}
+EXPORT_SYMBOL(toeplitz_select_queue);
+
 static inline u16 dev_cap_txqueue(struct net_device *dev, u16 queue_index)
 {
 	if (unlikely(queue_index >= dev->real_num_tx_queues)) {

