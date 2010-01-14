From: Patrick McHardy <kaber@trash.net>
Subject: RFC: netfilter: nf_conntrack: add support for "conntrack zones"
Date: Thu, 14 Jan 2010 15:05:32 +0100
Message-ID: <4B4F24AC.70105@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060008090100030508030002"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	containers@lists.linux-foundation.org
To: Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060008090100030508030002
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

The attached largish patch adds support for "conntrack zones",
which are virtual conntrack tables that can be used to seperate
connections from different zones, allowing to handle multiple
connections with equal identities in conntrack and NAT.

A zone is simply a numerical identifier associated with a network
device that is incorporated into the various hashes and used to
distinguish entries in addition to the connection tuples. Additionally
it is used to seperate conntrack defragmentation queues. An iptables
target for the raw table could be used alternatively to the network
device for assigning conntrack entries to zones.

This is mainly useful when connecting multiple private networks using
the same addresses (which unfortunately happens occasionally) to pass
the packets through a set of veth devices and SNAT each network to a
unique address, after which they can pass through the "main" zone and
be handled like regular non-clashing packets and/or have NAT applied a
second time based f.i. on the outgoing interface.

Something like this, with multiple tunl and veth devices, each pair
using a unique zone:

  <tunl0 / zone 1>
     |
  PREROUTING
     |
  FORWARD
     |
  POSTROUTING: SNAT to unique network
     |
  <veth1 / zone 1>
  <veth0 / zone 0>
     |
  PREROUTING
     |
  FORWARD
     |
  POSTROUTING: SNAT to eth0 address
     |
  <eth0>

As probably everyone has noticed, this is quite similar to what you
can do using network namespaces. The main reason for not using
network namespaces is that its an all-or-nothing approach, you can't
virtualize just connection tracking. Beside the difficulties in
managing different namespaces from f.i. an IKE or PPP daemon running
in the initial namespace, network namespaces have a quite large
overhead, especially when used with a large conntrack table.

I'm not too fond of this partial feature duplication myself, but I
couldn't think of a better way to do this without the downsides of
using namespaces. Having partially shared network namespaces would
be great, but it doesn't seem to fit in the design very well.
I'm open for any better suggestion :)

A couple of notes on the patch:

- its not entirely finished yet (ctnetlink and xt_connlimit are
  missing), I wanted to have a discussion about the general idea first.

- the patch uses ct_extend to avoid increasing the connection tracking
  entry size when this feature is not used. An older version of this
  patch adds the zone identifier to the conntrack tuples. This greatly
  simplifies the changes to the code since the zone doesn't has to
  passed around (something like 40 lines total), but has the downside
  of increasing the tuple size.

- the overhead should be quite small, its mainly the extra argument
  passing and an occasional extra comparison. Code size increase with
  all netfilter options enabled on x86_64 is 152 bytes.

Any comments welcome.

--------------060008090100030508030002
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

commit 7f68e7aa55f9e1f9dfd647b60dace4149f27ae1f
Author: Patrick McHardy <kaber@trash.net>
Date:   Thu Jan 14 13:51:06 2010 +0100

    netfilter: nf_conntrack: add support for "conntrack zones"
    
    Normally, each connection needs a unique identity. Conntrack zones allow
    to specify a numerical zone for each interface, connections in different
    zones can use the same identity.
    
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index a3fccc8..6e6a209 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -953,6 +953,10 @@ struct net_device {
 	/* max exchange id for FCoE LRO by ddp */
 	unsigned int		fcoe_ddp_xid;
 #endif
+
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	u16			nf_ct_zone;
+#endif
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
diff --git a/include/net/ip.h b/include/net/ip.h
index 85108cf..61aface 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -336,8 +336,11 @@ enum ip_defrag_users {
 	IP_DEFRAG_LOCAL_DELIVER,
 	IP_DEFRAG_CALL_RA_CHAIN,
 	IP_DEFRAG_CONNTRACK_IN,
+	__IP_DEFRAG_CONNTRACK_IN_END	= IP_DEFRAG_CONNTRACK_IN + 0xffff,
 	IP_DEFRAG_CONNTRACK_OUT,
+	__IP_DEFRAG_CONNTRACK_OUT_END	= IP_DEFRAG_CONNTRACK_OUT + 0xffff,
 	IP_DEFRAG_CONNTRACK_BRIDGE_IN,
+	__IP_DEFRAG_CONNTRACK_BRIDGE_IN = IP_DEFRAG_CONNTRACK_BRIDGE_IN + 0xffff,
 	IP_DEFRAG_VS_IN,
 	IP_DEFRAG_VS_OUT,
 	IP_DEFRAG_VS_FWD
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index ccab594..b82a68d 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -353,8 +353,11 @@ struct inet_frag_queue;
 enum ip6_defrag_users {
 	IP6_DEFRAG_LOCAL_DELIVER,
 	IP6_DEFRAG_CONNTRACK_IN,
+	__IP6_DEFRAG_CONNTRACK_IN	= IP6_DEFRAG_CONNTRACK_IN + 0xffff,
 	IP6_DEFRAG_CONNTRACK_OUT,
+	__IP6_DEFRAG_CONNTRACK_OUT	= IP6_DEFRAG_CONNTRACK_OUT + 0xffff,
 	IP6_DEFRAG_CONNTRACK_BRIDGE_IN,
+	__IP6_DEFRAG_CONNTRACK_BRIDGE_IN = IP6_DEFRAG_CONNTRACK_BRIDGE_IN + 0xffff,
 };
 
 struct ip6_create_arg {
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index a0904ad..9488ac6 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -198,7 +198,8 @@ extern void *nf_ct_alloc_hashtable(unsigned int *sizep, int *vmalloced, int null
 extern void nf_ct_free_hashtable(void *hash, int vmalloced, unsigned int size);
 
 extern struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple);
+__nf_conntrack_find(struct net *net, u16 zone,
+		    const struct nf_conntrack_tuple *tuple);
 
 extern void nf_conntrack_hash_insert(struct nf_conn *ct);
 extern void nf_ct_delete_from_lists(struct nf_conn *ct);
@@ -267,7 +268,7 @@ extern void
 nf_ct_iterate_cleanup(struct net *net, int (*iter)(struct nf_conn *i, void *data), void *data);
 extern void nf_conntrack_free(struct nf_conn *ct);
 extern struct nf_conn *
-nf_conntrack_alloc(struct net *net,
+nf_conntrack_alloc(struct net *net, u16 zone,
 		   const struct nf_conntrack_tuple *orig,
 		   const struct nf_conntrack_tuple *repl,
 		   gfp_t gfp);
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index 5a449b4..c7a1162 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -20,7 +20,7 @@
 /* This header is used to share core functionality between the
    standalone connection tracking module, and the compatibility layer's use
    of connection tracking. */
-extern unsigned int nf_conntrack_in(struct net *net,
+extern unsigned int nf_conntrack_in(struct net *net, u16 zone,
 				    u_int8_t pf,
 				    unsigned int hooknum,
 				    struct sk_buff *skb);
@@ -49,7 +49,8 @@ nf_ct_invert_tuple(struct nf_conntrack_tuple *inverse,
 
 /* Find a connection corresponding to a tuple. */
 extern struct nf_conntrack_tuple_hash *
-nf_conntrack_find_get(struct net *net, const struct nf_conntrack_tuple *tuple);
+nf_conntrack_find_get(struct net *net, u16 zone,
+		      const struct nf_conntrack_tuple *tuple);
 
 extern int __nf_conntrack_confirm(struct sk_buff *skb);
 
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 9a2b9cb..83c49f3 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -77,13 +77,16 @@ int nf_conntrack_expect_init(struct net *net);
 void nf_conntrack_expect_fini(struct net *net);
 
 struct nf_conntrack_expect *
-__nf_ct_expect_find(struct net *net, const struct nf_conntrack_tuple *tuple);
+__nf_ct_expect_find(struct net *net, u16 zone,
+		    const struct nf_conntrack_tuple *tuple);
 
 struct nf_conntrack_expect *
-nf_ct_expect_find_get(struct net *net, const struct nf_conntrack_tuple *tuple);
+nf_ct_expect_find_get(struct net *net, u16 zone,
+		      const struct nf_conntrack_tuple *tuple);
 
 struct nf_conntrack_expect *
-nf_ct_find_expectation(struct net *net, const struct nf_conntrack_tuple *tuple);
+nf_ct_find_expectation(struct net *net, u16 zone,
+		       const struct nf_conntrack_tuple *tuple);
 
 void nf_ct_unlink_expect(struct nf_conntrack_expect *exp);
 void nf_ct_remove_expectations(struct nf_conn *ct);
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index e192dc1..2d2a1f9 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -8,6 +8,7 @@ enum nf_ct_ext_id {
 	NF_CT_EXT_NAT,
 	NF_CT_EXT_ACCT,
 	NF_CT_EXT_ECACHE,
+	NF_CT_EXT_ZONE,
 	NF_CT_EXT_NUM,
 };
 
@@ -15,6 +16,7 @@ enum nf_ct_ext_id {
 #define NF_CT_EXT_NAT_TYPE struct nf_conn_nat
 #define NF_CT_EXT_ACCT_TYPE struct nf_conn_counter
 #define NF_CT_EXT_ECACHE_TYPE struct nf_conntrack_ecache
+#define NF_CT_EXT_ZONE_TYPE struct nf_conntrack_zone
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
diff --git a/include/net/netfilter/nf_conntrack_l4proto.h b/include/net/netfilter/nf_conntrack_l4proto.h
index ca6dcf3..14b6492 100644
--- a/include/net/netfilter/nf_conntrack_l4proto.h
+++ b/include/net/netfilter/nf_conntrack_l4proto.h
@@ -49,8 +49,8 @@ struct nf_conntrack_l4proto {
 	/* Called when a conntrack entry is destroyed */
 	void (*destroy)(struct nf_conn *ct);
 
-	int (*error)(struct net *net, struct sk_buff *skb, unsigned int dataoff,
-		     enum ip_conntrack_info *ctinfo,
+	int (*error)(struct net *net, u16 zone, struct sk_buff *skb,
+		     unsigned int dataoff, enum ip_conntrack_info *ctinfo,
 		     u_int8_t pf, unsigned int hooknum);
 
 	/* Print out the per-protocol part of the tuple. Return like seq_* */
diff --git a/include/net/netfilter/nf_conntrack_zones.h b/include/net/netfilter/nf_conntrack_zones.h
new file mode 100644
index 0000000..77d430b
--- /dev/null
+++ b/include/net/netfilter/nf_conntrack_zones.h
@@ -0,0 +1,30 @@
+#ifndef _NF_CONNTRACK_ZONES_H
+#define _NF_CONNTRACK_ZONES_H
+
+#include <net/netfilter/nf_conntrack_extend.h>
+
+struct nf_conntrack_zone {
+	u16	id;
+};
+
+static inline u16 nf_ct_zone(const struct nf_conn *ct)
+{
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	struct nf_conntrack_zone *nf_ct_zone;
+	nf_ct_zone = nf_ct_ext_find(ct, NF_CT_EXT_ZONE);
+	if (nf_ct_zone)
+		return nf_ct_zone->id;
+#endif
+	return 0;
+}
+
+static inline u16 nf_ct_dev_zone(const struct net_device *dev)
+{
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	return dev->nf_ct_zone;
+#else
+	return 0;
+#endif
+}
+
+#endif /* _NF_CONNTRACK_ZONES_H */
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index fbc1c74..83d8bf2 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -289,6 +289,23 @@ static ssize_t show_ifalias(struct device *dev,
 	return ret;
 }
 
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+NETDEVICE_SHOW(nf_ct_zone, fmt_dec);
+
+static int change_nf_ct_zone(struct net_device *net, unsigned long zone)
+{
+	net->nf_ct_zone = zone;
+	return 0;
+}
+
+static ssize_t store_nf_ct_zone(struct device *dev,
+				struct device_attribute *attr,
+				const char *buf, size_t len)
+{
+	return netdev_store(dev, attr, buf, len, change_nf_ct_zone);
+}
+#endif
+
 static struct device_attribute net_class_attributes[] = {
 	__ATTR(addr_len, S_IRUGO, show_addr_len, NULL),
 	__ATTR(dev_id, S_IRUGO, show_dev_id, NULL),
@@ -309,6 +326,9 @@ static struct device_attribute net_class_attributes[] = {
 	__ATTR(flags, S_IRUGO | S_IWUSR, show_flags, store_flags),
 	__ATTR(tx_queue_len, S_IRUGO | S_IWUSR, show_tx_queue_len,
 	       store_tx_queue_len),
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	__ATTR(nf_ct_zone, S_IRUGO | S_IWUSR, show_nf_ct_zone, store_nf_ct_zone),
+#endif
 	{}
 };
 
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index d171b12..b3a0634 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -23,6 +23,7 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv4/nf_conntrack_ipv4.h>
 #include <net/netfilter/nf_nat_helper.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
@@ -140,7 +141,7 @@ static unsigned int ipv4_conntrack_in(unsigned int hooknum,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
-	return nf_conntrack_in(dev_net(in), PF_INET, hooknum, skb);
+	return nf_conntrack_in(dev_net(in), nf_ct_dev_zone(in), PF_INET, hooknum, skb);
 }
 
 static unsigned int ipv4_conntrack_local(unsigned int hooknum,
@@ -153,7 +154,7 @@ static unsigned int ipv4_conntrack_local(unsigned int hooknum,
 	if (skb->len < sizeof(struct iphdr) ||
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
-	return nf_conntrack_in(dev_net(out), PF_INET, hooknum, skb);
+	return nf_conntrack_in(dev_net(out), nf_ct_dev_zone(out), PF_INET, hooknum, skb);
 }
 
 /* Connection tracking may drop packets, but never alters them, so
@@ -266,7 +267,7 @@ getorigdst(struct sock *sk, int optval, void __user *user, int *len)
 		return -EINVAL;
 	}
 
-	h = nf_conntrack_find_get(sock_net(sk), &tuple);
+	h = nf_conntrack_find_get(sock_net(sk), 0, &tuple);
 	if (h) {
 		struct sockaddr_in sin;
 		struct nf_conn *ct = nf_ct_tuplehash_to_ctrack(h);
diff --git a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
index 7afd39b..82b4b30 100644
--- a/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_conntrack_proto_icmp.c
@@ -114,7 +114,7 @@ static bool icmp_new(struct nf_conn *ct, const struct sk_buff *skb,
 
 /* Returns conntrack if it dealt with ICMP, and filled in skb fields */
 static int
-icmp_error_message(struct net *net, struct sk_buff *skb,
+icmp_error_message(struct net *net, u16 zone, struct sk_buff *skb,
 		 enum ip_conntrack_info *ctinfo,
 		 unsigned int hooknum)
 {
@@ -146,7 +146,7 @@ icmp_error_message(struct net *net, struct sk_buff *skb,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(net, &innertuple);
+	h = nf_conntrack_find_get(net, zone, &innertuple);
 	if (!h) {
 		pr_debug("icmp_error_message: no match\n");
 		return -NF_ACCEPT;
@@ -163,7 +163,8 @@ icmp_error_message(struct net *net, struct sk_buff *skb,
 
 /* Small and modified version of icmp_rcv */
 static int
-icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
+icmp_error(struct net *net, u16 zone,
+	   struct sk_buff *skb, unsigned int dataoff,
 	   enum ip_conntrack_info *ctinfo, u_int8_t pf, unsigned int hooknum)
 {
 	const struct icmphdr *icmph;
@@ -208,7 +209,7 @@ icmp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	    icmph->type != ICMP_REDIRECT)
 		return NF_ACCEPT;
 
-	return icmp_error_message(net, skb, ctinfo, hooknum);
+	return icmp_error_message(net, zone, skb, ctinfo, hooknum);
 }
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
diff --git a/net/ipv4/netfilter/nf_defrag_ipv4.c b/net/ipv4/netfilter/nf_defrag_ipv4.c
index 331ead3..488e889 100644
--- a/net/ipv4/netfilter/nf_defrag_ipv4.c
+++ b/net/ipv4/netfilter/nf_defrag_ipv4.c
@@ -16,6 +16,7 @@
 
 #include <linux/netfilter_bridge.h>
 #include <linux/netfilter_ipv4.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 
 /* Returns new sk_buff, or NULL */
@@ -35,18 +36,18 @@ static int nf_ct_ipv4_gather_frags(struct sk_buff *skb, u_int32_t user)
 	return err;
 }
 
-static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum,
+static enum ip_defrag_users nf_ct_defrag_user(unsigned int hooknum, u16 zone,
 					      struct sk_buff *skb)
 {
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (skb->nf_bridge &&
 	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
-		return IP_DEFRAG_CONNTRACK_BRIDGE_IN;
+		return IP_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
 #endif
 	if (hooknum == NF_INET_PRE_ROUTING)
-		return IP_DEFRAG_CONNTRACK_IN;
+		return IP_DEFRAG_CONNTRACK_IN + zone;
 	else
-		return IP_DEFRAG_CONNTRACK_OUT;
+		return IP_DEFRAG_CONNTRACK_OUT + zone;
 }
 
 static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
@@ -65,7 +66,9 @@ static unsigned int ipv4_conntrack_defrag(unsigned int hooknum,
 #endif
 	/* Gather fragments. */
 	if (ip_hdr(skb)->frag_off & htons(IP_MF | IP_OFFSET)) {
-		enum ip_defrag_users user = nf_ct_defrag_user(hooknum, skb);
+		u16 zone = nf_ct_dev_zone(hooknum == NF_INET_PRE_ROUTING ? in : out);
+		enum ip_defrag_users user = nf_ct_defrag_user(hooknum, zone, skb);
+
 		if (nf_ct_ipv4_gather_frags(skb, user))
 			return NF_STOLEN;
 	}
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/ipv4/netfilter/nf_nat_core.c
index fe1a644..64b9979 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/ipv4/netfilter/nf_nat_core.c
@@ -30,6 +30,7 @@
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_l4proto.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 
 static DEFINE_SPINLOCK(nf_nat_lock);
 
@@ -72,13 +73,13 @@ EXPORT_SYMBOL_GPL(nf_nat_proto_put);
 
 /* We keep an extra hash for each conntrack, for fast searching. */
 static inline unsigned int
-hash_by_src(const struct nf_conntrack_tuple *tuple)
+hash_by_src(const struct nf_conntrack_tuple *tuple, u16 zone)
 {
 	unsigned int hash;
 
 	/* Original src, to ensure we map it consistently if poss. */
 	hash = jhash_3words((__force u32)tuple->src.u3.ip,
-			    (__force u32)tuple->src.u.all,
+			    (__force u32)tuple->src.u.all ^ zone,
 			    tuple->dst.protonum, 0);
 	return ((u64)hash * nf_nat_htable_size) >> 32;
 }
@@ -142,12 +143,12 @@ same_src(const struct nf_conn *ct,
 
 /* Only called for SRC manip */
 static int
-find_appropriate_src(struct net *net,
+find_appropriate_src(struct net *net, u16 zone,
 		     const struct nf_conntrack_tuple *tuple,
 		     struct nf_conntrack_tuple *result,
 		     const struct nf_nat_range *range)
 {
-	unsigned int h = hash_by_src(tuple);
+	unsigned int h = hash_by_src(tuple, zone);
 	const struct nf_conn_nat *nat;
 	const struct nf_conn *ct;
 	const struct hlist_node *n;
@@ -155,7 +156,7 @@ find_appropriate_src(struct net *net,
 	rcu_read_lock();
 	hlist_for_each_entry_rcu(nat, n, &net->ipv4.nat_bysource[h], bysource) {
 		ct = nat->ct;
-		if (same_src(ct, tuple)) {
+		if (same_src(ct, tuple) && nf_ct_zone(ct) == zone) {
 			/* Copy source part from reply tuple. */
 			nf_ct_invert_tuplepr(result,
 				       &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
@@ -178,7 +179,7 @@ find_appropriate_src(struct net *net,
    the ip with the lowest src-ip/dst-ip/proto usage.
 */
 static void
-find_best_ips_proto(struct nf_conntrack_tuple *tuple,
+find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
 		    const struct nf_nat_range *range,
 		    const struct nf_conn *ct,
 		    enum nf_nat_manip_type maniptype)
@@ -212,7 +213,7 @@ find_best_ips_proto(struct nf_conntrack_tuple *tuple,
 	maxip = ntohl(range->max_ip);
 	j = jhash_2words((__force u32)tuple->src.u3.ip,
 			 range->flags & IP_NAT_RANGE_PERSISTENT ?
-				0 : (__force u32)tuple->dst.u3.ip, 0);
+				0 : (__force u32)tuple->dst.u3.ip ^ zone, 0);
 	j = ((u64)j * (maxip - minip + 1)) >> 32;
 	*var_ipp = htonl(minip + j);
 }
@@ -232,6 +233,7 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 {
 	struct net *net = nf_ct_net(ct);
 	const struct nf_nat_protocol *proto;
+	u16 zone = nf_ct_zone(ct);
 
 	/* 1) If this srcip/proto/src-proto-part is currently mapped,
 	   and that same mapping gives a unique tuple within the given
@@ -242,7 +244,7 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	   manips not an issue.  */
 	if (maniptype == IP_NAT_MANIP_SRC &&
 	    !(range->flags & IP_NAT_RANGE_PROTO_RANDOM)) {
-		if (find_appropriate_src(net, orig_tuple, tuple, range)) {
+		if (find_appropriate_src(net, zone, orig_tuple, tuple, range)) {
 			pr_debug("get_unique_tuple: Found current src map\n");
 			if (!nf_nat_used_tuple(tuple, ct))
 				return;
@@ -252,7 +254,7 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	/* 2) Select the least-used IP/proto combination in the given
 	   range. */
 	*tuple = *orig_tuple;
-	find_best_ips_proto(tuple, range, ct, maniptype);
+	find_best_ips_proto(zone, tuple, range, ct, maniptype);
 
 	/* 3) The per-protocol part of the manip is made to map into
 	   the range to make a unique tuple. */
@@ -330,7 +332,8 @@ nf_nat_setup_info(struct nf_conn *ct,
 	if (have_to_hash) {
 		unsigned int srchash;
 
-		srchash = hash_by_src(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
+		srchash = hash_by_src(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
+				      nf_ct_zone(ct));
 		spin_lock_bh(&nf_nat_lock);
 		/* nf_conntrack_alter_reply might re-allocate exntension aera */
 		nat = nfct_nat(ct);
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index 9eb1710..4c06003 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -25,6 +25,7 @@
 #include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #include <linux/netfilter/nf_conntrack_proto_gre.h>
 #include <linux/netfilter/nf_conntrack_pptp.h>
 
@@ -74,7 +75,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 
 	pr_debug("trying to unexpect other dir: ");
 	nf_ct_dump_tuple_ip(&t);
-	other_exp = nf_ct_expect_find_get(net, &t);
+	other_exp = nf_ct_expect_find_get(net, nf_ct_zone(ct), &t);
 	if (other_exp) {
 		nf_ct_unexpect_related(other_exp);
 		nf_ct_expect_put(other_exp);
diff --git a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
index 0956eba..0db0d7f 100644
--- a/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_l3proto_ipv6.c
@@ -27,6 +27,7 @@
 #include <net/netfilter/nf_conntrack_l4proto.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/ipv6/nf_conntrack_ipv6.h>
 #include <net/netfilter/nf_log.h>
 
@@ -188,18 +189,18 @@ out:
 	return nf_conntrack_confirm(skb);
 }
 
-static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum,
+static enum ip6_defrag_users nf_ct6_defrag_user(unsigned int hooknum, u16 zone,
 						struct sk_buff *skb)
 {
 #ifdef CONFIG_BRIDGE_NETFILTER
 	if (skb->nf_bridge &&
 	    skb->nf_bridge->mask & BRNF_NF_BRIDGE_PREROUTING)
-		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN;
+		return IP6_DEFRAG_CONNTRACK_BRIDGE_IN + zone;
 #endif
 	if (hooknum == NF_INET_PRE_ROUTING)
-		return IP6_DEFRAG_CONNTRACK_IN;
+		return IP6_DEFRAG_CONNTRACK_IN + zone;
 	else
-		return IP6_DEFRAG_CONNTRACK_OUT;
+		return IP6_DEFRAG_CONNTRACK_OUT + zone;
 
 }
 
@@ -210,12 +211,14 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 				int (*okfn)(struct sk_buff *))
 {
 	struct sk_buff *reasm;
+	u16 zone;
 
 	/* Previously seen (loopback)?  */
 	if (skb->nfct)
 		return NF_ACCEPT;
 
-	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, skb));
+	zone = nf_ct_dev_zone(hooknum == NF_INET_PRE_ROUTING ? in : out);
+	reasm = nf_ct_frag6_gather(skb, nf_ct6_defrag_user(hooknum, zone, skb));
 	/* queued */
 	if (reasm == NULL)
 		return NF_STOLEN;
@@ -230,7 +233,7 @@ static unsigned int ipv6_defrag(unsigned int hooknum,
 	return NF_STOLEN;
 }
 
-static unsigned int __ipv6_conntrack_in(struct net *net,
+static unsigned int __ipv6_conntrack_in(struct net *net, u16 zone,
 					unsigned int hooknum,
 					struct sk_buff *skb,
 					int (*okfn)(struct sk_buff *))
@@ -243,7 +246,7 @@ static unsigned int __ipv6_conntrack_in(struct net *net,
 		if (!reasm->nfct) {
 			unsigned int ret;
 
-			ret = nf_conntrack_in(net, PF_INET6, hooknum, reasm);
+			ret = nf_conntrack_in(net, zone, PF_INET6, hooknum, reasm);
 			if (ret != NF_ACCEPT)
 				return ret;
 		}
@@ -253,7 +256,7 @@ static unsigned int __ipv6_conntrack_in(struct net *net,
 		return NF_ACCEPT;
 	}
 
-	return nf_conntrack_in(net, PF_INET6, hooknum, skb);
+	return nf_conntrack_in(net, zone, PF_INET6, hooknum, skb);
 }
 
 static unsigned int ipv6_conntrack_in(unsigned int hooknum,
@@ -262,7 +265,7 @@ static unsigned int ipv6_conntrack_in(unsigned int hooknum,
 				      const struct net_device *out,
 				      int (*okfn)(struct sk_buff *))
 {
-	return __ipv6_conntrack_in(dev_net(in), hooknum, skb, okfn);
+	return __ipv6_conntrack_in(dev_net(in), nf_ct_dev_zone(in), hooknum, skb, okfn);
 }
 
 static unsigned int ipv6_conntrack_local(unsigned int hooknum,
@@ -277,7 +280,7 @@ static unsigned int ipv6_conntrack_local(unsigned int hooknum,
 			printk("ipv6_conntrack_local: packet too short\n");
 		return NF_ACCEPT;
 	}
-	return __ipv6_conntrack_in(dev_net(out), hooknum, skb, okfn);
+	return __ipv6_conntrack_in(dev_net(out), nf_ct_dev_zone(out), hooknum, skb, okfn);
 }
 
 static struct nf_hook_ops ipv6_conntrack_ops[] __read_mostly = {
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index c7b8bd1..c423818 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -128,7 +128,7 @@ static bool icmpv6_new(struct nf_conn *ct, const struct sk_buff *skb,
 }
 
 static int
-icmpv6_error_message(struct net *net,
+icmpv6_error_message(struct net *net, u16 zone,
 		     struct sk_buff *skb,
 		     unsigned int icmp6off,
 		     enum ip_conntrack_info *ctinfo,
@@ -163,7 +163,7 @@ icmpv6_error_message(struct net *net,
 
 	*ctinfo = IP_CT_RELATED;
 
-	h = nf_conntrack_find_get(net, &intuple);
+	h = nf_conntrack_find_get(net, zone, &intuple);
 	if (!h) {
 		pr_debug("icmpv6_error: no match\n");
 		return -NF_ACCEPT;
@@ -179,7 +179,8 @@ icmpv6_error_message(struct net *net,
 }
 
 static int
-icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
+icmpv6_error(struct net *net, u16 zone,
+	     struct sk_buff *skb, unsigned int dataoff,
 	     enum ip_conntrack_info *ctinfo, u_int8_t pf, unsigned int hooknum)
 {
 	const struct icmp6hdr *icmp6h;
@@ -215,7 +216,7 @@ icmpv6_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
 	if (icmp6h->icmp6_type >= 128)
 		return NF_ACCEPT;
 
-	return icmpv6_error_message(net, skb, dataoff, ctinfo, hooknum);
+	return icmpv6_error_message(net, zone, skb, dataoff, ctinfo, hooknum);
 }
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 634d14a..15374ba 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -83,6 +83,15 @@ config NF_CONNTRACK_SECMARK
 
 	  If unsure, say 'N'.
 
+config NF_CONNTRACK_ZONES
+	bool  'Connection tracking zones'
+	help
+	  This option enables support for connection tracking zones.
+	  Normally, each connection needs to have a unique identity.
+	  Connection tracking zones allow to have multiple connections
+	  using the same identity, as long as they are contained in
+	  different zones.
+
 config NF_CONNTRACK_EVENTS
 	bool "Connection tracking events"
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 0e98c32..90909e3 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -41,6 +41,7 @@
 #include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_conntrack_acct.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
 
@@ -69,7 +70,7 @@ static int nf_conntrack_hash_rnd_initted;
 static unsigned int nf_conntrack_hash_rnd;
 
 static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
-				  unsigned int size, unsigned int rnd)
+				  u16 zone, unsigned int size, unsigned int rnd)
 {
 	unsigned int n;
 	u_int32_t h;
@@ -80,15 +81,16 @@ static u_int32_t __hash_conntrack(const struct nf_conntrack_tuple *tuple,
 	 */
 	n = (sizeof(tuple->src) + sizeof(tuple->dst.u3)) / sizeof(u32);
 	h = jhash2((u32 *)tuple, n,
-		   rnd ^ (((__force __u16)tuple->dst.u.all << 16) |
+		   zone ^ rnd ^ (((__force __u16)tuple->dst.u.all << 16) |
 			  tuple->dst.protonum));
 
 	return ((u64)h * size) >> 32;
 }
 
-static inline u_int32_t hash_conntrack(const struct nf_conntrack_tuple *tuple)
+static inline u_int32_t hash_conntrack(const struct nf_conntrack_tuple *tuple,
+				       u16 zone)
 {
-	return __hash_conntrack(tuple, nf_conntrack_htable_size,
+	return __hash_conntrack(tuple, zone, nf_conntrack_htable_size,
 				nf_conntrack_hash_rnd);
 }
 
@@ -292,11 +294,12 @@ static void death_by_timeout(unsigned long ul_conntrack)
  * - Caller must lock nf_conntrack_lock before calling this function
  */
 struct nf_conntrack_tuple_hash *
-__nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
+__nf_conntrack_find(struct net *net, u16 zone,
+		    const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
-	unsigned int hash = hash_conntrack(tuple);
+	unsigned int hash = hash_conntrack(tuple, zone);
 
 	/* Disable BHs the entire time since we normally need to disable them
 	 * at least once for the stats anyway.
@@ -304,7 +307,8 @@ __nf_conntrack_find(struct net *net, const struct nf_conntrack_tuple *tuple)
 	local_bh_disable();
 begin:
 	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
-		if (nf_ct_tuple_equal(tuple, &h->tuple)) {
+		if (nf_ct_tuple_equal(tuple, &h->tuple) &&
+		    nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)) == zone) {
 			NF_CT_STAT_INC(net, found);
 			local_bh_enable();
 			return h;
@@ -326,21 +330,23 @@ EXPORT_SYMBOL_GPL(__nf_conntrack_find);
 
 /* Find a connection corresponding to a tuple. */
 struct nf_conntrack_tuple_hash *
-nf_conntrack_find_get(struct net *net, const struct nf_conntrack_tuple *tuple)
+nf_conntrack_find_get(struct net *net, u16 zone,
+		      const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_tuple_hash *h;
 	struct nf_conn *ct;
 
 	rcu_read_lock();
 begin:
-	h = __nf_conntrack_find(net, tuple);
+	h = __nf_conntrack_find(net, zone, tuple);
 	if (h) {
 		ct = nf_ct_tuplehash_to_ctrack(h);
 		if (unlikely(nf_ct_is_dying(ct) ||
 			     !atomic_inc_not_zero(&ct->ct_general.use)))
 			h = NULL;
 		else {
-			if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple))) {
+			if (unlikely(!nf_ct_tuple_equal(tuple, &h->tuple) ||
+				     nf_ct_zone(ct) != zone)) {
 				nf_ct_put(ct);
 				goto begin;
 			}
@@ -367,9 +373,11 @@ static void __nf_conntrack_hash_insert(struct nf_conn *ct,
 void nf_conntrack_hash_insert(struct nf_conn *ct)
 {
 	unsigned int hash, repl_hash;
+	u16 zone;
 
-	hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-	repl_hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	zone = nf_ct_zone(ct);
+	hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple, zone);
+	repl_hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_REPLY].tuple, zone);
 
 	__nf_conntrack_hash_insert(ct, hash, repl_hash);
 }
@@ -385,6 +393,7 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	struct nf_conn_help *help;
 	struct hlist_nulls_node *n;
 	enum ip_conntrack_info ctinfo;
+	u16 zone;
 	struct net *net;
 
 	ct = nf_ct_get(skb, &ctinfo);
@@ -397,8 +406,9 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	if (CTINFO2DIR(ctinfo) != IP_CT_DIR_ORIGINAL)
 		return NF_ACCEPT;
 
-	hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple);
-	repl_hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_REPLY].tuple);
+	zone = nf_ct_zone(ct);
+	hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple, zone);
+	repl_hash = hash_conntrack(&ct->tuplehash[IP_CT_DIR_REPLY].tuple, zone);
 
 	/* We're not in hash table, and we refuse to set up related
 	   connections for unconfirmed conns.  But packet copies and
@@ -417,11 +427,13 @@ __nf_conntrack_confirm(struct sk_buff *skb)
 	   not in the hash.  If there is, we lost race. */
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
-				      &h->tuple))
+				      &h->tuple) &&
+		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
 			goto out;
 	hlist_nulls_for_each_entry(h, n, &net->ct.hash[repl_hash], hnnode)
 		if (nf_ct_tuple_equal(&ct->tuplehash[IP_CT_DIR_REPLY].tuple,
-				      &h->tuple))
+				      &h->tuple) &&
+		    zone == nf_ct_zone(nf_ct_tuplehash_to_ctrack(h)))
 			goto out;
 
 	/* Remove from unconfirmed list */
@@ -468,15 +480,19 @@ nf_conntrack_tuple_taken(const struct nf_conntrack_tuple *tuple,
 	struct net *net = nf_ct_net(ignored_conntrack);
 	struct nf_conntrack_tuple_hash *h;
 	struct hlist_nulls_node *n;
-	unsigned int hash = hash_conntrack(tuple);
+	struct nf_conn *ct;
+	u16 zone = nf_ct_zone(ignored_conntrack);
+	unsigned int hash = hash_conntrack(tuple, zone);
 
 	/* Disable BHs the entire time since we need to disable them at
 	 * least once for the stats anyway.
 	 */
 	rcu_read_lock_bh();
 	hlist_nulls_for_each_entry_rcu(h, n, &net->ct.hash[hash], hnnode) {
-		if (nf_ct_tuplehash_to_ctrack(h) != ignored_conntrack &&
-		    nf_ct_tuple_equal(tuple, &h->tuple)) {
+		ct = nf_ct_tuplehash_to_ctrack(h);
+		if (ct != ignored_conntrack &&
+		    nf_ct_tuple_equal(tuple, &h->tuple) &&
+		    nf_ct_zone(ct) == zone) {
 			NF_CT_STAT_INC(net, found);
 			rcu_read_unlock_bh();
 			return 1;
@@ -539,7 +555,7 @@ static noinline int early_drop(struct net *net, unsigned int hash)
 	return dropped;
 }
 
-struct nf_conn *nf_conntrack_alloc(struct net *net,
+struct nf_conn *nf_conntrack_alloc(struct net *net, u16 zone,
 				   const struct nf_conntrack_tuple *orig,
 				   const struct nf_conntrack_tuple *repl,
 				   gfp_t gfp)
@@ -557,7 +573,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 
 	if (nf_conntrack_max &&
 	    unlikely(atomic_read(&net->ct.count) > nf_conntrack_max)) {
-		unsigned int hash = hash_conntrack(orig);
+		unsigned int hash = hash_conntrack(orig, zone);
 		if (!early_drop(net, hash)) {
 			atomic_dec(&net->ct.count);
 			if (net_ratelimit())
@@ -578,6 +594,7 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 		atomic_dec(&net->ct.count);
 		return ERR_PTR(-ENOMEM);
 	}
+
 	/*
 	 * Let ct->tuplehash[IP_CT_DIR_ORIGINAL].hnnode.next
 	 * and ct->tuplehash[IP_CT_DIR_REPLY].hnnode.next unchanged.
@@ -594,6 +611,16 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 #ifdef CONFIG_NET_NS
 	ct->ct_net = net;
 #endif
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	if (zone) {
+		struct nf_conntrack_zone *nf_ct_zone;
+
+		nf_ct_zone = nf_ct_ext_add(ct, NF_CT_EXT_ZONE, GFP_ATOMIC);
+		if (!nf_ct_zone)
+			goto out_free;
+		nf_ct_zone->id = zone;
+	}
+#endif
 
 	/*
 	 * changes to lookup keys must be done before setting refcnt to 1
@@ -601,6 +628,12 @@ struct nf_conn *nf_conntrack_alloc(struct net *net,
 	smp_wmb();
 	atomic_set(&ct->ct_general.use, 1);
 	return ct;
+
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+out_free:
+	kmem_cache_free(nf_conntrack_cachep, ct);
+	return ERR_PTR(-ENOMEM);
+#endif
 }
 EXPORT_SYMBOL_GPL(nf_conntrack_alloc);
 
@@ -618,7 +651,7 @@ EXPORT_SYMBOL_GPL(nf_conntrack_free);
 /* Allocate a new conntrack: we return -ENOMEM if classification
    failed due to stress.  Otherwise it really is unclassifiable. */
 static struct nf_conntrack_tuple_hash *
-init_conntrack(struct net *net,
+init_conntrack(struct net *net, u16 zone,
 	       const struct nf_conntrack_tuple *tuple,
 	       struct nf_conntrack_l3proto *l3proto,
 	       struct nf_conntrack_l4proto *l4proto,
@@ -635,7 +668,7 @@ init_conntrack(struct net *net,
 		return NULL;
 	}
 
-	ct = nf_conntrack_alloc(net, tuple, &repl_tuple, GFP_ATOMIC);
+	ct = nf_conntrack_alloc(net, zone, tuple, &repl_tuple, GFP_ATOMIC);
 	if (IS_ERR(ct)) {
 		pr_debug("Can't allocate conntrack.\n");
 		return (struct nf_conntrack_tuple_hash *)ct;
@@ -651,7 +684,7 @@ init_conntrack(struct net *net,
 	nf_ct_ecache_ext_add(ct, GFP_ATOMIC);
 
 	spin_lock_bh(&nf_conntrack_lock);
-	exp = nf_ct_find_expectation(net, tuple);
+	exp = nf_ct_find_expectation(net, zone, tuple);
 	if (exp) {
 		pr_debug("conntrack: expectation arrives ct=%p exp=%p\n",
 			 ct, exp);
@@ -694,7 +727,7 @@ init_conntrack(struct net *net,
 
 /* On success, returns conntrack ptr, sets skb->nfct and ctinfo */
 static inline struct nf_conn *
-resolve_normal_ct(struct net *net,
+resolve_normal_ct(struct net *net, u16 zone,
 		  struct sk_buff *skb,
 		  unsigned int dataoff,
 		  u_int16_t l3num,
@@ -716,9 +749,10 @@ resolve_normal_ct(struct net *net,
 	}
 
 	/* look for tuple match */
-	h = nf_conntrack_find_get(net, &tuple);
+	h = nf_conntrack_find_get(net, zone, &tuple);
 	if (!h) {
-		h = init_conntrack(net, &tuple, l3proto, l4proto, skb, dataoff);
+		h = init_conntrack(net, zone, &tuple, l3proto, l4proto,
+				   skb, dataoff);
 		if (!h)
 			return NULL;
 		if (IS_ERR(h))
@@ -752,7 +786,7 @@ resolve_normal_ct(struct net *net,
 }
 
 unsigned int
-nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
+nf_conntrack_in(struct net *net, u16 zone, u_int8_t pf, unsigned int hooknum,
 		struct sk_buff *skb)
 {
 	struct nf_conn *ct;
@@ -787,7 +821,8 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 	 * inverse of the return code tells to the netfilter
 	 * core what to do with the packet. */
 	if (l4proto->error != NULL) {
-		ret = l4proto->error(net, skb, dataoff, &ctinfo, pf, hooknum);
+		ret = l4proto->error(net, zone, skb, dataoff, &ctinfo,
+				     pf, hooknum);
 		if (ret <= 0) {
 			NF_CT_STAT_INC_ATOMIC(net, error);
 			NF_CT_STAT_INC_ATOMIC(net, invalid);
@@ -795,7 +830,7 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 		}
 	}
 
-	ct = resolve_normal_ct(net, skb, dataoff, pf, protonum,
+	ct = resolve_normal_ct(net, zone, skb, dataoff, pf, protonum,
 			       l3proto, l4proto, &set_reply, &ctinfo);
 	if (!ct) {
 		/* Not valid part of a connection */
@@ -938,6 +973,12 @@ bool __nf_ct_kill_acct(struct nf_conn *ct,
 }
 EXPORT_SYMBOL_GPL(__nf_ct_kill_acct);
 
+static struct nf_ct_ext_type nf_ct_zone_extend __read_mostly = {
+	.len	= sizeof(struct nf_conntrack_zone),
+	.align	= __alignof__(struct nf_conntrack_zone),
+	.id	= NF_CT_EXT_ZONE,
+};
+
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
 
 #include <linux/netfilter/nfnetlink.h>
@@ -1115,6 +1156,7 @@ static void nf_conntrack_cleanup_init_net(void)
 {
 	nf_conntrack_helper_fini();
 	nf_conntrack_proto_fini();
+	nf_ct_extend_unregister(&nf_ct_zone_extend);
 	kmem_cache_destroy(nf_conntrack_cachep);
 }
 
@@ -1193,6 +1235,7 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 	int rnd;
 	struct hlist_nulls_head *hash, *old_hash;
 	struct nf_conntrack_tuple_hash *h;
+	struct nf_conn *ct;
 
 	/* On boot, we can set this without any fancy locking. */
 	if (!nf_conntrack_htable_size)
@@ -1220,8 +1263,10 @@ int nf_conntrack_set_hashsize(const char *val, struct kernel_param *kp)
 		while (!hlist_nulls_empty(&init_net.ct.hash[i])) {
 			h = hlist_nulls_entry(init_net.ct.hash[i].first,
 					struct nf_conntrack_tuple_hash, hnnode);
+			ct = nf_ct_tuplehash_to_ctrack(h);
 			hlist_nulls_del_rcu(&h->hnnode);
-			bucket = __hash_conntrack(&h->tuple, hashsize, rnd);
+			bucket = __hash_conntrack(&h->tuple, nf_ct_zone(ct),
+						  hashsize, rnd);
 			hlist_nulls_add_head_rcu(&h->hnnode, &hash[bucket]);
 		}
 	}
@@ -1288,8 +1333,17 @@ static int nf_conntrack_init_init_net(void)
 	if (ret < 0)
 		goto err_helper;
 
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	ret = nf_ct_extend_register(&nf_ct_zone_extend);
+	if (ret < 0)
+		goto err_extend;
+#endif
 	return 0;
 
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+err_extend:
+	nf_conntrack_helper_fini();
+#endif
 err_helper:
 	nf_conntrack_proto_fini();
 err_proto:
diff --git a/net/netfilter/nf_conntrack_expect.c b/net/netfilter/nf_conntrack_expect.c
index fdf5d2a..5fd0347 100644
--- a/net/netfilter/nf_conntrack_expect.c
+++ b/net/netfilter/nf_conntrack_expect.c
@@ -27,6 +27,7 @@
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_tuple.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 
 unsigned int nf_ct_expect_hsize __read_mostly;
 EXPORT_SYMBOL_GPL(nf_ct_expect_hsize);
@@ -84,7 +85,8 @@ static unsigned int nf_ct_expect_dst_hash(const struct nf_conntrack_tuple *tuple
 }
 
 struct nf_conntrack_expect *
-__nf_ct_expect_find(struct net *net, const struct nf_conntrack_tuple *tuple)
+__nf_ct_expect_find(struct net *net, u16 zone,
+		    const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_expect *i;
 	struct hlist_node *n;
@@ -104,12 +106,13 @@ EXPORT_SYMBOL_GPL(__nf_ct_expect_find);
 
 /* Just find a expectation corresponding to a tuple. */
 struct nf_conntrack_expect *
-nf_ct_expect_find_get(struct net *net, const struct nf_conntrack_tuple *tuple)
+nf_ct_expect_find_get(struct net *net, u16 zone,
+		      const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_expect *i;
 
 	rcu_read_lock();
-	i = __nf_ct_expect_find(net, tuple);
+	i = __nf_ct_expect_find(net, zone, tuple);
 	if (i && !atomic_inc_not_zero(&i->use))
 		i = NULL;
 	rcu_read_unlock();
@@ -121,7 +124,8 @@ EXPORT_SYMBOL_GPL(nf_ct_expect_find_get);
 /* If an expectation for this connection is found, it gets delete from
  * global list then returned. */
 struct nf_conntrack_expect *
-nf_ct_find_expectation(struct net *net, const struct nf_conntrack_tuple *tuple)
+nf_ct_find_expectation(struct net *net, u16 zone,
+		       const struct nf_conntrack_tuple *tuple)
 {
 	struct nf_conntrack_expect *i, *exp = NULL;
 	struct hlist_node *n;
@@ -133,7 +137,8 @@ nf_ct_find_expectation(struct net *net, const struct nf_conntrack_tuple *tuple)
 	h = nf_ct_expect_dst_hash(tuple);
 	hlist_for_each_entry(i, n, &net->ct.expect_hash[h], hnode) {
 		if (!(i->flags & NF_CT_EXPECT_INACTIVE) &&
-		    nf_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask)) {
+		    nf_ct_tuple_mask_cmp(tuple, &i->tuple, &i->mask) &&
+		    nf_ct_zone(i->master) == zone) {
 			exp = i;
 			break;
 		}
@@ -204,7 +209,8 @@ static inline int expect_matches(const struct nf_conntrack_expect *a,
 {
 	return a->master == b->master && a->class == b->class &&
 		nf_ct_tuple_equal(&a->tuple, &b->tuple) &&
-		nf_ct_tuple_mask_equal(&a->mask, &b->mask);
+		nf_ct_tuple_mask_equal(&a->mask, &b->mask) &&
+		nf_ct_zone(a->master) == nf_ct_zone(b->master);
 }
 
 /* Generally a bad idea to call this: could have matched already. */
diff --git a/net/netfilter/nf_conntrack_h323_main.c b/net/netfilter/nf_conntrack_h323_main.c
index 6636949..a1c8dd9 100644
--- a/net/netfilter/nf_conntrack_h323_main.c
+++ b/net/netfilter/nf_conntrack_h323_main.c
@@ -29,6 +29,7 @@
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #include <linux/netfilter/nf_conntrack_h323.h>
 
 /* Parameters */
@@ -1216,7 +1217,7 @@ static struct nf_conntrack_expect *find_expect(struct nf_conn *ct,
 	tuple.dst.u.tcp.port = port;
 	tuple.dst.protonum = IPPROTO_TCP;
 
-	exp = __nf_ct_expect_find(net, &tuple);
+	exp = __nf_ct_expect_find(net, nf_ct_zone(ct), &tuple);
 	if (exp && exp->master == ct)
 		return exp;
 	return NULL;
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 59d8064..2a9c4c3 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -790,7 +790,7 @@ ctnetlink_del_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(&init_net, &tuple);
+	h = nf_conntrack_find_get(&init_net, 0, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -850,7 +850,7 @@ ctnetlink_get_conntrack(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	h = nf_conntrack_find_get(&init_net, &tuple);
+	h = nf_conntrack_find_get(&init_net, 0, &tuple);
 	if (!h)
 		return -ENOENT;
 
@@ -1184,7 +1184,7 @@ ctnetlink_create_conntrack(const struct nlattr * const cda[],
 	int err = -EINVAL;
 	struct nf_conntrack_helper *helper;
 
-	ct = nf_conntrack_alloc(&init_net, otuple, rtuple, GFP_ATOMIC);
+	ct = nf_conntrack_alloc(&init_net, 0, otuple, rtuple, GFP_ATOMIC);
 	if (IS_ERR(ct))
 		return ERR_PTR(-ENOMEM);
 
@@ -1285,7 +1285,7 @@ ctnetlink_create_conntrack(const struct nlattr * const cda[],
 		if (err < 0)
 			goto err2;
 
-		master_h = nf_conntrack_find_get(&init_net, &master);
+		master_h = nf_conntrack_find_get(&init_net, 0, &master);
 		if (master_h == NULL) {
 			err = -ENOENT;
 			goto err2;
@@ -1333,9 +1333,9 @@ ctnetlink_new_conntrack(struct sock *ctnl, struct sk_buff *skb,
 
 	spin_lock_bh(&nf_conntrack_lock);
 	if (cda[CTA_TUPLE_ORIG])
-		h = __nf_conntrack_find(&init_net, &otuple);
+		h = __nf_conntrack_find(&init_net, 0, &otuple);
 	else if (cda[CTA_TUPLE_REPLY])
-		h = __nf_conntrack_find(&init_net, &rtuple);
+		h = __nf_conntrack_find(&init_net, 0, &rtuple);
 
 	if (h == NULL) {
 		err = -ENOENT;
@@ -1660,7 +1660,7 @@ ctnetlink_get_expect(struct sock *ctnl, struct sk_buff *skb,
 	if (err < 0)
 		return err;
 
-	exp = nf_ct_expect_find_get(&init_net, &tuple);
+	exp = nf_ct_expect_find_get(&init_net, 0, &tuple);
 	if (!exp)
 		return -ENOENT;
 
@@ -1716,7 +1716,7 @@ ctnetlink_del_expect(struct sock *ctnl, struct sk_buff *skb,
 			return err;
 
 		/* bump usage count to 2 */
-		exp = nf_ct_expect_find_get(&init_net, &tuple);
+		exp = nf_ct_expect_find_get(&init_net, 0, &tuple);
 		if (!exp)
 			return -ENOENT;
 
@@ -1805,7 +1805,7 @@ ctnetlink_create_expect(const struct nlattr * const cda[], u_int8_t u3,
 		return err;
 
 	/* Look for master conntrack of this expectation */
-	h = nf_conntrack_find_get(&init_net, &master_tuple);
+	h = nf_conntrack_find_get(&init_net, 0, &master_tuple);
 	if (!h)
 		return -ENOENT;
 	ct = nf_ct_tuplehash_to_ctrack(h);
@@ -1861,7 +1861,7 @@ ctnetlink_new_expect(struct sock *ctnl, struct sk_buff *skb,
 		return err;
 
 	spin_lock_bh(&nf_conntrack_lock);
-	exp = __nf_ct_expect_find(&init_net, &tuple);
+	exp = __nf_ct_expect_find(&init_net, 0, &tuple);
 
 	if (!exp) {
 		spin_unlock_bh(&nf_conntrack_lock);
diff --git a/net/netfilter/nf_conntrack_pptp.c b/net/netfilter/nf_conntrack_pptp.c
index 3807ac7..ffe2ae6 100644
--- a/net/netfilter/nf_conntrack_pptp.c
+++ b/net/netfilter/nf_conntrack_pptp.c
@@ -28,6 +28,7 @@
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #include <linux/netfilter/nf_conntrack_proto_gre.h>
 #include <linux/netfilter/nf_conntrack_pptp.h>
 
@@ -123,7 +124,7 @@ static void pptp_expectfn(struct nf_conn *ct,
 		pr_debug("trying to unexpect other dir: ");
 		nf_ct_dump_tuple(&inv_t);
 
-		exp_other = nf_ct_expect_find_get(net, &inv_t);
+		exp_other = nf_ct_expect_find_get(net, nf_ct_zone(ct), &inv_t);
 		if (exp_other) {
 			/* delete other expectation.  */
 			pr_debug("found\n");
@@ -136,7 +137,7 @@ static void pptp_expectfn(struct nf_conn *ct,
 	rcu_read_unlock();
 }
 
-static int destroy_sibling_or_exp(struct net *net,
+static int destroy_sibling_or_exp(struct net *net, u16 zone,
 				  const struct nf_conntrack_tuple *t)
 {
 	const struct nf_conntrack_tuple_hash *h;
@@ -146,7 +147,7 @@ static int destroy_sibling_or_exp(struct net *net,
 	pr_debug("trying to timeout ct or exp for tuple ");
 	nf_ct_dump_tuple(t);
 
-	h = nf_conntrack_find_get(net, t);
+	h = nf_conntrack_find_get(net, zone, t);
 	if (h)  {
 		sibling = nf_ct_tuplehash_to_ctrack(h);
 		pr_debug("setting timeout of conntrack %p to 0\n", sibling);
@@ -157,7 +158,7 @@ static int destroy_sibling_or_exp(struct net *net,
 		nf_ct_put(sibling);
 		return 1;
 	} else {
-		exp = nf_ct_expect_find_get(net, t);
+		exp = nf_ct_expect_find_get(net, zone, t);
 		if (exp) {
 			pr_debug("unexpect_related of expect %p\n", exp);
 			nf_ct_unexpect_related(exp);
@@ -182,7 +183,7 @@ static void pptp_destroy_siblings(struct nf_conn *ct)
 	t.dst.protonum = IPPROTO_GRE;
 	t.src.u.gre.key = help->help.ct_pptp_info.pns_call_id;
 	t.dst.u.gre.key = help->help.ct_pptp_info.pac_call_id;
-	if (!destroy_sibling_or_exp(net, &t))
+	if (!destroy_sibling_or_exp(net, nf_ct_zone(ct), &t))
 		pr_debug("failed to timeout original pns->pac ct/exp\n");
 
 	/* try reply (pac->pns) tuple */
@@ -190,7 +191,7 @@ static void pptp_destroy_siblings(struct nf_conn *ct)
 	t.dst.protonum = IPPROTO_GRE;
 	t.src.u.gre.key = help->help.ct_pptp_info.pac_call_id;
 	t.dst.u.gre.key = help->help.ct_pptp_info.pns_call_id;
-	if (!destroy_sibling_or_exp(net, &t))
+	if (!destroy_sibling_or_exp(net, nf_ct_zone(ct), &t))
 		pr_debug("failed to timeout reply pac->pns ct/exp\n");
 }
 
diff --git a/net/netfilter/nf_conntrack_proto_dccp.c b/net/netfilter/nf_conntrack_proto_dccp.c
index dd37550..d1c1848 100644
--- a/net/netfilter/nf_conntrack_proto_dccp.c
+++ b/net/netfilter/nf_conntrack_proto_dccp.c
@@ -561,7 +561,7 @@ static int dccp_packet(struct nf_conn *ct, const struct sk_buff *skb,
 	return NF_ACCEPT;
 }
 
-static int dccp_error(struct net *net, struct sk_buff *skb,
+static int dccp_error(struct net *net, u16 zone, struct sk_buff *skb,
 		      unsigned int dataoff, enum ip_conntrack_info *ctinfo,
 		      u_int8_t pf, unsigned int hooknum)
 {
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 3c96437..2bfe5bf 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -760,7 +760,7 @@ static const u8 tcp_valid_flags[(TH_FIN|TH_SYN|TH_RST|TH_ACK|TH_URG) + 1] =
 };
 
 /* Protect conntrack agaist broken packets. Code taken from ipt_unclean.c.  */
-static int tcp_error(struct net *net,
+static int tcp_error(struct net *net, u16 zone,
 		     struct sk_buff *skb,
 		     unsigned int dataoff,
 		     enum ip_conntrack_info *ctinfo,
diff --git a/net/netfilter/nf_conntrack_proto_udp.c b/net/netfilter/nf_conntrack_proto_udp.c
index 5c5518b..aee7515 100644
--- a/net/netfilter/nf_conntrack_proto_udp.c
+++ b/net/netfilter/nf_conntrack_proto_udp.c
@@ -91,8 +91,8 @@ static bool udp_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
-static int udp_error(struct net *net, struct sk_buff *skb, unsigned int dataoff,
-		     enum ip_conntrack_info *ctinfo,
+static int udp_error(struct net *net, u16 zone, struct sk_buff *skb,
+		     unsigned int dataoff, enum ip_conntrack_info *ctinfo,
 		     u_int8_t pf,
 		     unsigned int hooknum)
 {
diff --git a/net/netfilter/nf_conntrack_proto_udplite.c b/net/netfilter/nf_conntrack_proto_udplite.c
index 458655b..cc94a67 100644
--- a/net/netfilter/nf_conntrack_proto_udplite.c
+++ b/net/netfilter/nf_conntrack_proto_udplite.c
@@ -89,7 +89,7 @@ static bool udplite_new(struct nf_conn *ct, const struct sk_buff *skb,
 	return true;
 }
 
-static int udplite_error(struct net *net,
+static int udplite_error(struct net *net, u16 zone,
 			 struct sk_buff *skb,
 			 unsigned int dataoff,
 			 enum ip_conntrack_info *ctinfo,
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 4b57216..3b5efc9 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -22,6 +22,7 @@
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <net/netfilter/nf_conntrack_helper.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 #include <linux/netfilter/nf_conntrack_sip.h>
 
 MODULE_LICENSE("GPL");
@@ -777,7 +778,7 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb,
 
 	rcu_read_lock();
 	do {
-		exp = __nf_ct_expect_find(net, &tuple);
+		exp = __nf_ct_expect_find(net, nf_ct_zone(ct), &tuple);
 
 		if (!exp || exp->master == ct ||
 		    nfct_help(exp->master)->helper != nfct_help(ct)->helper ||
diff --git a/net/netfilter/nf_conntrack_standalone.c b/net/netfilter/nf_conntrack_standalone.c
index 028aba6..69da6ef 100644
--- a/net/netfilter/nf_conntrack_standalone.c
+++ b/net/netfilter/nf_conntrack_standalone.c
@@ -26,6 +26,7 @@
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_acct.h>
+#include <net/netfilter/nf_conntrack_zones.h>
 
 MODULE_LICENSE("GPL");
 
@@ -171,6 +172,11 @@ static int ct_seq_show(struct seq_file *s, void *v)
 		goto release;
 #endif
 
+#ifdef CONFIG_NF_CONNTRACK_ZONES
+	if (seq_printf(s, "zone=%u ", nf_ct_zone(ct)));
+		goto release;
+#endif
+
 	if (seq_printf(s, "use=%u\n", atomic_read(&ct->ct_general.use)))
 		goto release;
 
diff --git a/net/netfilter/xt_connlimit.c b/net/netfilter/xt_connlimit.c
index 8103bef..a637ee6 100644
--- a/net/netfilter/xt_connlimit.c
+++ b/net/netfilter/xt_connlimit.c
@@ -113,7 +113,7 @@ static int count_them(struct xt_connlimit_data *data,
 
 	/* check the saved connections */
 	list_for_each_entry_safe(conn, tmp, hash, list) {
-		found    = nf_conntrack_find_get(&init_net, &conn->tuple);
+		found    = nf_conntrack_find_get(&init_net, 0, &conn->tuple);
 		found_ct = NULL;
 
 		if (found != NULL)

--------------060008090100030508030002--
