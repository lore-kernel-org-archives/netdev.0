From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH net-next 2/8] mpls: Basic routing support
Date: Wed, 25 Feb 2015 11:14:25 -0600
Message-ID: <87egpdx6a6.fsf@x220.int.ebiederm.org>
References: <87pp8xx6ik.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, roopa <roopa@cumulusnetworks.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	santiago@crfreenet.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:53640 "EHLO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549AbbBYRRz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Feb 2015 12:17:55 -0500
In-Reply-To: <87pp8xx6ik.fsf@x220.int.ebiederm.org> (Eric W. Biederman's
	message of "Wed, 25 Feb 2015 11:09:23 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


This change adds a new Kconfig option MPLS_ROUTING.

The core of this change is the code to look at an mpls
packet received from another machine.  Look that packet
up in a routing table and forward the packet on.

Support of MPLS over ATM is not considered or attempted here.
This implemntation follows RFC3032 and implements the MPLS
shim header that can pass over essentially any network.

What RFC3021 refers to as the as the Incoming Label Map (ILM)
I call net->mpls.platform_label[].  What RFC3031 refers to
as the Next Label Hop Forwarding Entry (NHLFE) I call mpls_route.
Though calling it the label fordwarding information base (lfib)
might also be valid.

Further the implemntation forwards packets as described in RFC3032.
There is no need and given the original motivation for MPLS a strong
discincentive to have a flexible label forwarding path.  In essence
the logic is the topmost label is read, looked up, removed, and
replaced by 0 or more new lables and the sent out the specified
interface to it's next hop.

Quite a few optional features are not implemented here.  Among them
are generation of ICMP errors when the TTL is exceeded or the packet
is larger than the next hop MTU (those conditions are detected and the
packets are dropped instead of generating an icmp error).  The traffic
class field is always set to 0.  The implementation focuses on IP over
MPLS and does not handle egress of other kinds of protocols.

Instead of implementing coordination with the neighbour table and
sorting out how to input next hops in a different address family (for
which there is value).  I was lazy and implemented a next hop mac
address instead.  The code is simpler and there are flavor of MPLS
such as MPLS-TP where neither an IPv4 nor an IPv6 next hop is
appropriate so a next hop by mac address would need to be implemented
at some point.

Two new definitions AF_MPLS and PF_MPLS are exposed to userspace.

Decoding the mpls header must be done by first byeswapping a 32bit bit
endian word into the local cpu endian and then bit shifting to extract
the pieces.  There is no C bit-field that can represent a wire format
mpls header on a little endian machine as the low bits of the 20bit
label wind up in the wrong half of third byte.  Therefore internally
everything is deal with in cpu native byte order except when writing
to and reading from a packet.

Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
---
 include/linux/socket.h      |   2 +
 include/net/net_namespace.h |   4 +
 include/net/netns/mpls.h    |  15 ++
 net/mpls/Kconfig            |   5 +
 net/mpls/Makefile           |   1 +
 net/mpls/af_mpls.c          | 336 ++++++++++++++++++++++++++++++++++++++++++++
 net/mpls/internal.h         |  56 ++++++++
 7 files changed, 419 insertions(+)
 create mode 100644 include/net/netns/mpls.h
 create mode 100644 net/mpls/af_mpls.c
 create mode 100644 net/mpls/internal.h

diff --git a/include/linux/socket.h b/include/linux/socket.h
index 5c19cba34dce..fab4d0ddf4ed 100644
--- a/include/linux/socket.h
+++ b/include/linux/socket.h
@@ -181,6 +181,7 @@ struct ucred {
 #define AF_WANPIPE	25	/* Wanpipe API Sockets */
 #define AF_LLC		26	/* Linux LLC			*/
 #define AF_IB		27	/* Native InfiniBand address	*/
+#define AF_MPLS		28	/* MPLS */
 #define AF_CAN		29	/* Controller Area Network      */
 #define AF_TIPC		30	/* TIPC sockets			*/
 #define AF_BLUETOOTH	31	/* Bluetooth sockets 		*/
@@ -226,6 +227,7 @@ struct ucred {
 #define PF_WANPIPE	AF_WANPIPE
 #define PF_LLC		AF_LLC
 #define PF_IB		AF_IB
+#define PF_MPLS		AF_MPLS
 #define PF_CAN		AF_CAN
 #define PF_TIPC		AF_TIPC
 #define PF_BLUETOOTH	AF_BLUETOOTH
diff --git a/include/net/net_namespace.h b/include/net/net_namespace.h
index 36faf4990c4b..2cb9acb618e9 100644
--- a/include/net/net_namespace.h
+++ b/include/net/net_namespace.h
@@ -26,6 +26,7 @@
 #endif
 #include <net/netns/nftables.h>
 #include <net/netns/xfrm.h>
+#include <net/netns/mpls.h>
 #include <linux/ns_common.h>
 
 struct user_namespace;
@@ -130,6 +131,9 @@ struct net {
 #if IS_ENABLED(CONFIG_IP_VS)
 	struct netns_ipvs	*ipvs;
 #endif
+#if IS_ENABLED(CONFIG_MPLS)
+	struct netns_mpls	mpls;
+#endif
 	struct sock		*diag_nlsk;
 	atomic_t		fnhe_genid;
 };
diff --git a/include/net/netns/mpls.h b/include/net/netns/mpls.h
new file mode 100644
index 000000000000..f90aaf8d4f89
--- /dev/null
+++ b/include/net/netns/mpls.h
@@ -0,0 +1,15 @@
+/*
+ * mpls in net namespaces
+ */
+
+#ifndef __NETNS_MPLS_H__
+#define __NETNS_MPLS_H__
+
+struct mpls_route;
+
+struct netns_mpls {
+	size_t platform_labels;
+	struct mpls_route __rcu * __rcu *platform_label;
+};
+
+#endif /* __NETNS_MPLS_H__ */
diff --git a/net/mpls/Kconfig b/net/mpls/Kconfig
index a77fbcdd04ee..f4286ee7e2b0 100644
--- a/net/mpls/Kconfig
+++ b/net/mpls/Kconfig
@@ -22,4 +22,9 @@ config NET_MPLS_GSO
 	 that have had MPLS stack entries pushed onto them and thus
 	 become MPLS GSO packets.
 
+config MPLS_ROUTING
+	bool "MPLS: routing support"
+	help
+	 Add support for forwarding of mpls packets.
+
 endif # MPLS
diff --git a/net/mpls/Makefile b/net/mpls/Makefile
index 6dec088c2d0f..60af15f1960e 100644
--- a/net/mpls/Makefile
+++ b/net/mpls/Makefile
@@ -2,3 +2,4 @@
 # Makefile for MPLS.
 #
 obj-$(CONFIG_NET_MPLS_GSO) += mpls_gso.o
+obj-$(CONFIG_MPLS_ROUTING) += af_mpls.o
diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
new file mode 100644
index 000000000000..c84c8057d3df
--- /dev/null
+++ b/net/mpls/af_mpls.c
@@ -0,0 +1,336 @@
+#include <linux/types.h>
+#include <linux/skbuff.h>
+#include <linux/socket.h>
+#include <linux/net.h>
+#include <linux/module.h>
+#include <linux/if_arp.h>
+#include <linux/ipv6.h>
+#include <linux/mpls.h>
+#include <net/ip.h>
+#include <net/dst.h>
+#include <net/sock.h>
+#include <net/arp.h>
+#include <net/ip_fib.h>
+#include <net/netevent.h>
+#include <net/netns/generic.h>
+#include "internal.h"
+
+#define MAX_NEW_LABELS 2
+
+/* This maximum ha length copied from the definition of struct neighbour */
+#define MAX_HA_LEN (ALIGN(MAX_ADDR_LEN, sizeof(unsigned long)))
+
+struct mpls_route { /* next hop label forwarding entry */
+	struct net_device 	*rt_dev;
+	unsigned char		rt_ha[MAX_HA_LEN];
+	u8			rt_protocol; /* routing protocol that set this entry */
+	u8			rt_labels;
+	u32			rt_label[MAX_NEW_LABELS];
+	struct rcu_head		rt_rcu;
+};
+
+static struct mpls_route *mpls_route_input_rcu(struct net *net, unsigned index)
+{
+	struct mpls_route *rt = NULL;
+
+	if (index < net->mpls.platform_labels) {
+		struct mpls_route __rcu **platform_label =
+			rcu_dereference(net->mpls.platform_label);
+		rt = rcu_dereference(platform_label[index]);
+	}
+	return rt;
+}
+
+static unsigned int mpls_rt_header_size(const struct mpls_route *rt)
+{
+	/* The size of the layer 2.5 labels to be added for this route */
+	return rt->rt_labels * sizeof(struct mpls_shim_hdr);
+}
+
+static unsigned int mpls_rt_mtu(const struct mpls_route *rt)
+{
+	/* The amount of data the layer 2 frame can hold */
+	return rt->rt_dev->mtu;
+}
+
+static bool mpls_pkt_too_big(const struct sk_buff *skb, unsigned int mtu)
+{
+	if (skb->len <= mtu)
+		return false;
+
+	if (skb_is_gso(skb) && skb_gso_network_seglen(skb) <= mtu)
+		return false;
+
+	return true;
+}
+
+static bool mpls_egress(struct mpls_route *rt, struct sk_buff *skb,
+			struct mpls_entry_decoded dec)
+{
+	/* RFC4385 and RFC5586 encode other packets in mpls such that
+	 * they don't conflict with the ip version number, making
+	 * decoding by examining the ip version correct in everything
+	 * except for the strangest cases.
+	 *
+	 * The strange cases if we choose to support them will require
+	 * manual configuration.
+	 */
+	struct iphdr *hdr4 = ip_hdr(skb);
+	bool success = true;
+
+	if (hdr4->version == 4) {
+		skb->protocol = htons(ETH_P_IP);
+		csum_replace2(&hdr4->check,
+			      htons(hdr4->ttl << 8),
+			      htons(dec.ttl << 8));
+		hdr4->ttl = dec.ttl;
+	}
+	else if (hdr4->version == 6) {
+		struct ipv6hdr *hdr6 = ipv6_hdr(skb);
+		skb->protocol = htons(ETH_P_IPV6);
+		hdr6->hop_limit = dec.ttl;
+	}
+	else
+		/* version 0 and version 1 are used by pseudo wires */
+		success = false;
+	return success;
+}
+
+static int mpls_forward(struct sk_buff *skb, struct net_device *dev,
+			struct packet_type *pt, struct net_device *orig_dev)
+{
+	struct net *net = dev_net(dev);
+	struct mpls_shim_hdr *hdr;
+	struct mpls_route *rt;
+	struct mpls_entry_decoded dec;
+	struct net_device *out_dev;
+	unsigned int hh_len;
+	unsigned int new_header_size;
+	unsigned int mtu;
+	int err;
+
+	/* Careful this entire function runs inside of an rcu critical section */
+
+	if (skb->pkt_type != PACKET_HOST)
+		goto drop;
+
+	if ((skb = skb_share_check(skb, GFP_ATOMIC)) == NULL)
+		goto drop;
+
+	if (!pskb_may_pull(skb, sizeof(*hdr)))
+		goto drop;
+
+	/* Read and decode the label */
+	hdr = mpls_hdr(skb);
+	dec = mpls_entry_decode(hdr);
+
+	/* Pop the label */
+	skb_pull(skb, sizeof(*hdr));
+	skb_reset_network_header(skb);
+
+	skb_orphan(skb);
+
+	rt = mpls_route_input_rcu(net, dec.label);
+	if (!rt)
+		goto drop;
+
+	if (skb_warn_if_lro(skb))
+		goto drop;
+
+	skb_forward_csum(skb);
+
+	/* Verify ttl is valid */
+	if (dec.ttl <= 2)
+		goto drop;
+	dec.ttl -= 1;
+
+	/* Verify the destination can hold the packet */
+	new_header_size = mpls_rt_header_size(rt);
+	mtu = mpls_rt_mtu(rt);
+	if (mpls_pkt_too_big(skb, mtu - new_header_size))
+		goto drop;
+
+	out_dev = rt->rt_dev;
+	hh_len = LL_RESERVED_SPACE(out_dev);
+	if (!out_dev->header_ops)
+		hh_len = 0;
+
+	/* Ensure there is enough space for the headers in the skb */
+	if (skb_cow(skb, hh_len + new_header_size))
+		goto drop;
+
+	skb->dev = out_dev;
+	skb->protocol = htons(ETH_P_MPLS_UC);
+
+	if (unlikely(!new_header_size && dec.bos)) {
+		/* Penultimate hop popping */
+		if (!mpls_egress(rt, skb, dec))
+			goto drop;
+	} else {
+		bool bos;
+		int i;
+		skb_push(skb, new_header_size);
+		skb_reset_network_header(skb);
+		/* Push the new labels */
+		hdr = mpls_hdr(skb);
+		bos = dec.bos;
+		for (i = rt->rt_labels - 1; i >= 0; i--) {
+			hdr[i] = mpls_entry_encode(rt->rt_label[i], dec.ttl, 0, bos);
+			bos = false;
+		}
+	}
+
+	err = dev_hard_header(skb, out_dev, ntohs(skb->protocol),
+				rt->rt_ha, NULL, skb->len);
+	if (err >= 0)
+		err = dev_queue_xmit(skb);
+	if (err) {
+		net_dbg_ratelimited("%s: packet transmission failed: %d\n",
+				    __func__, err);
+		goto drop;
+	}
+	return 0;
+
+drop:
+	kfree_skb(skb);
+	return NET_RX_DROP;
+}
+
+static struct packet_type mpls_packet_type __read_mostly = {
+	.type = cpu_to_be16(ETH_P_MPLS_UC),
+	.func = mpls_forward,
+};
+
+static struct mpls_route *mpls_rt_alloc(void)
+{
+	struct mpls_route *rt;
+
+	rt = kzalloc(GFP_KERNEL, sizeof(*rt));
+	return rt;
+}
+
+static void mpls_rt_free(struct mpls_route *rt)
+{
+	if (rt)
+		kfree_rcu(rt, rt_rcu);
+}
+
+static void mpls_route_update(struct net *net, unsigned index,
+			      struct net_device *dev, struct mpls_route *new,
+			      const struct nl_info *info)
+{
+	struct mpls_route *rt, *old = NULL;
+
+	ASSERT_RTNL();
+
+	rt = net->mpls.platform_label[index];
+	if (!dev || (rt && (rt->rt_dev == dev))) {
+		rcu_assign_pointer(net->mpls.platform_label[index], new);
+		old = rt;
+	}
+
+	/* If we removed a route free it now */
+	mpls_rt_free(old);
+}
+
+static void mpls_ifdown(struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+	unsigned index;
+
+	for (index = 16; index < net->mpls.platform_labels; index++)
+		mpls_route_update(net, index, dev, NULL, NULL);
+}
+
+static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
+			   void *ptr)
+{
+	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
+
+	switch(event) {
+	case NETDEV_DOWN:
+	case NETDEV_UNREGISTER:
+		mpls_ifdown(dev);
+		break;
+	}
+	return NOTIFY_OK;
+}
+
+static struct notifier_block mpls_dev_notifier = {
+	.notifier_call = mpls_dev_notify,
+};
+
+static int mpls_net_init(struct net *net)
+{
+	net->mpls.platform_labels = 0;
+	net->mpls.platform_label = NULL;
+
+	return 0;
+}
+
+static void mpls_net_exit(struct net *net)
+{
+	unsigned int index;
+
+	/* An rcu grace period haselapsed since there was a device in
+	 * the network namespace (and thus the last in fqlight packet)
+	 * left this network namespace.  This is because
+	 * unregister_netdevice_many and netdev_run_todo has completed
+	 * for each network device that was in this network namespace.
+	 *
+	 * As such no additional rcu synchronization is necessary when
+	 * freeing the platform_label table.
+	 */
+	rtnl_lock();
+	for (index = 0; index < net->mpls.platform_labels; index++) {
+		struct mpls_route *rt = net->mpls.platform_label[index];
+		rcu_assign_pointer(net->mpls.platform_label[index], NULL);
+		mpls_rt_free(rt);
+	}
+	rtnl_unlock();
+
+	kvfree(net->mpls.platform_label);
+}
+
+static struct pernet_operations mpls_net_ops = {
+	.init = mpls_net_init,
+	.exit = mpls_net_exit,
+};
+
+static int __init mpls_init(void)
+{
+	int err;
+
+	BUILD_BUG_ON(sizeof(struct mpls_shim_hdr) != 4);
+
+	err = register_pernet_subsys(&mpls_net_ops);
+	if (err)
+		goto out;
+
+	err = register_netdevice_notifier(&mpls_dev_notifier);
+	if (err)
+		goto out_unregister_pernet;
+
+	dev_add_pack(&mpls_packet_type);
+
+	err = 0;
+out:
+	return err;
+
+out_unregister_pernet:
+	unregister_pernet_subsys(&mpls_net_ops);
+	goto out;
+}
+module_init(mpls_init);
+
+static void __exit mpls_exit(void)
+{
+	dev_remove_pack(&mpls_packet_type);
+	unregister_netdevice_notifier(&mpls_dev_notifier);
+	unregister_pernet_subsys(&mpls_net_ops);
+}
+module_exit(mpls_exit);
+
+MODULE_DESCRIPTION("MultiProtocol Label Switching");
+MODULE_LICENSE("GPL v2");
+MODULE_ALIAS_NETPROTO(PF_MPLS);
diff --git a/net/mpls/internal.h b/net/mpls/internal.h
new file mode 100644
index 000000000000..c2944cb84d48
--- /dev/null
+++ b/net/mpls/internal.h
@@ -0,0 +1,56 @@
+#ifndef MPLS_INTERNAL_H
+#define MPLS_INTERNAL_H
+
+#define LABEL_IPV4_EXPLICIT_NULL	0 /* RFC3032 */
+#define LABEL_ROUTER_ALERT_LABEL	1 /* RFC3032 */
+#define LABEL_IPV6_EXPLICIT_NULL	2 /* RFC3032 */
+#define LABEL_IMPLICIT_NULL		3 /* RFC3032 */
+#define LABEL_ENTROPY_INDICATOR		7 /* RFC6790 */
+#define LABEL_GAL			13 /* RFC5586 */
+#define LABEL_OAM_ALERT			14 /* RFC3429 */
+#define LABEL_EXTENSION			15 /* RFC7274 */
+
+
+struct mpls_shim_hdr {
+	__be32 label_stack_entry;
+};
+
+struct mpls_entry_decoded {
+	u32 label;
+	u8 ttl;
+	u8 tc;
+	u8 bos;
+};
+
+struct sk_buff;
+
+static inline struct mpls_shim_hdr *mpls_hdr(const struct sk_buff *skb)
+{
+	return (struct mpls_shim_hdr *)skb_network_header(skb);
+}
+
+static inline struct mpls_shim_hdr mpls_entry_encode(u32 label, unsigned ttl, unsigned tc, bool bos)
+{
+	struct mpls_shim_hdr result;
+	result.label_stack_entry =
+		cpu_to_be32((label << MPLS_LS_LABEL_SHIFT) |
+			    (tc << MPLS_LS_TC_SHIFT) |
+			    (bos ? (1 << MPLS_LS_S_SHIFT) : 0) |
+			    (ttl << MPLS_LS_TTL_SHIFT));
+	return result;
+}
+
+static inline struct mpls_entry_decoded mpls_entry_decode(struct mpls_shim_hdr *hdr)
+{
+	struct mpls_entry_decoded result;
+	unsigned entry = be32_to_cpu(hdr->label_stack_entry);
+
+	result.label = (entry & MPLS_LS_LABEL_MASK) >> MPLS_LS_LABEL_SHIFT;
+	result.ttl = (entry & MPLS_LS_TTL_MASK) >> MPLS_LS_TTL_SHIFT;
+	result.tc =  (entry & MPLS_LS_TC_MASK) >> MPLS_LS_TC_SHIFT;
+	result.bos = (entry & MPLS_LS_S_MASK) >> MPLS_LS_S_SHIFT;
+
+	return result;
+}
+
+#endif /* MPLS_INTERNAL_H */
-- 
2.2.1
