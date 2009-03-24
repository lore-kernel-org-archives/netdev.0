From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 35/41: xtables: add cluster match
Date: Tue, 24 Mar 2009 15:03:53 +0100 (MET)
Message-ID: <20090324140349.31401.91299.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit 0269ea4937343536ec7e85649932bc8c9686ea78
Author: Pablo Neira Ayuso <pablo@netfilter.org>
Date:   Mon Mar 16 17:10:36 2009 +0100

    netfilter: xtables: add cluster match
    
    This patch adds the iptables cluster match. This match can be used
    to deploy gateway and back-end load-sharing clusters. The cluster
    can be composed of 32 nodes maximum (although I have only tested
    this with two nodes, so I cannot tell what is the real scalability
    limit of this solution in terms of cluster nodes).
    
    Assuming that all the nodes see all packets (see below for an
    example on how to do that if your switch does not allow this), the
    cluster match decides if this node has to handle a packet given:
    
    	(jhash(source IP) % total_nodes) & node_mask
    
    For related connections, the master conntrack is used. The following
    is an example of its use to deploy a gateway cluster composed of two
    nodes (where this is the node 1):
    
    iptables -I PREROUTING -t mangle -i eth1 -m cluster \
    	--cluster-total-nodes 2 --cluster-local-node 1 \
    	--cluster-proc-name eth1 -j MARK --set-mark 0xffff
    iptables -A PREROUTING -t mangle -i eth1 \
    	-m mark ! --mark 0xffff -j DROP
    iptables -A PREROUTING -t mangle -i eth2 -m cluster \
    	--cluster-total-nodes 2 --cluster-local-node 1 \
    	--cluster-proc-name eth2 -j MARK --set-mark 0xffff
    iptables -A PREROUTING -t mangle -i eth2 \
    	-m mark ! --mark 0xffff -j DROP
    
    And the following commands to make all nodes see the same packets:
    
    ip maddr add 01:00:5e:00:01:01 dev eth1
    ip maddr add 01:00:5e:00:01:02 dev eth2
    arptables -I OUTPUT -o eth1 --h-length 6 \
    	-j mangle --mangle-mac-s 01:00:5e:00:01:01
    arptables -I INPUT -i eth1 --h-length 6 \
    	--destination-mac 01:00:5e:00:01:01 \
    	-j mangle --mangle-mac-d 00:zz:yy:xx:5a:27
    arptables -I OUTPUT -o eth2 --h-length 6 \
    	-j mangle --mangle-mac-s 01:00:5e:00:01:02
    arptables -I INPUT -i eth2 --h-length 6 \
    	--destination-mac 01:00:5e:00:01:02 \
    	-j mangle --mangle-mac-d 00:zz:yy:xx:5a:27
    
    In the case of TCP connections, pickup facility has to be disabled
    to avoid marking TCP ACK packets coming in the reply direction as
    valid.
    
    echo 0 > /proc/sys/net/netfilter/nf_conntrack_tcp_loose
    
    BTW, some final notes:
    
     * This match mangles the skbuff pkt_type in case that it detects
    PACKET_MULTICAST for a non-multicast address. This may be done in
    a PKTTYPE target for this sole purpose.
     * This match supersedes the CLUSTERIP target.
    
    Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index 947b47d..af9d2fb 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -21,6 +21,7 @@ header-y += xt_connbytes.h
 header-y += xt_connlimit.h
 header-y += xt_connmark.h
 header-y += xt_conntrack.h
+header-y += xt_cluster.h
 header-y += xt_dccp.h
 header-y += xt_dscp.h
 header-y += xt_esp.h
diff --git a/include/linux/netfilter/xt_cluster.h b/include/linux/netfilter/xt_cluster.h
new file mode 100644
index 0000000..5e0a0d0
--- /dev/null
+++ b/include/linux/netfilter/xt_cluster.h
@@ -0,0 +1,15 @@
+#ifndef _XT_CLUSTER_MATCH_H
+#define _XT_CLUSTER_MATCH_H
+
+enum xt_cluster_flags {
+	XT_CLUSTER_F_INV	= (1 << 0)
+};
+
+struct xt_cluster_match_info {
+	u_int32_t		total_nodes;
+	u_int32_t		node_mask;
+	u_int32_t		hash_seed;
+	u_int32_t		flags;
+};
+
+#endif /* _XT_CLUSTER_MATCH_H */
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index cdbaaff..2562d05 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -527,6 +527,22 @@ config NETFILTER_XT_TARGET_TCPOPTSTRIP
 	  This option adds a "TCPOPTSTRIP" target, which allows you to strip
 	  TCP options from TCP packets.
 
+config NETFILTER_XT_MATCH_CLUSTER
+	tristate '"cluster" match support'
+	depends on NF_CONNTRACK
+	depends on NETFILTER_ADVANCED
+	---help---
+	  This option allows you to build work-load-sharing clusters of
+	  network servers/stateful firewalls without having a dedicated
+	  load-balancing router/server/switch. Basically, this match returns
+	  true when the packet must be handled by this cluster node. Thus,
+	  all nodes see all packets and this match decides which node handles
+	  what packets. The work-load sharing algorithm is based on source
+	  address hashing.
+
+	  If you say Y or M here, try `iptables -m cluster --help` for
+	  more information.
+
 config NETFILTER_XT_MATCH_COMMENT
 	tristate  '"comment" match support'
 	depends on NETFILTER_ADVANCED
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 7a9b839..6282060 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -59,6 +59,7 @@ obj-$(CONFIG_NETFILTER_XT_TARGET_TCPOPTSTRIP) += xt_TCPOPTSTRIP.o
 obj-$(CONFIG_NETFILTER_XT_TARGET_TRACE) += xt_TRACE.o
 
 # matches
+obj-$(CONFIG_NETFILTER_XT_MATCH_CLUSTER) += xt_cluster.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_COMMENT) += xt_comment.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNBYTES) += xt_connbytes.o
 obj-$(CONFIG_NETFILTER_XT_MATCH_CONNLIMIT) += xt_connlimit.o
diff --git a/net/netfilter/xt_cluster.c b/net/netfilter/xt_cluster.c
new file mode 100644
index 0000000..ad5bd89
--- /dev/null
+++ b/net/netfilter/xt_cluster.c
@@ -0,0 +1,164 @@
+/*
+ * (C) 2008-2009 Pablo Neira Ayuso <pablo@netfilter.org>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/jhash.h>
+#include <linux/ip.h>
+#include <net/ipv6.h>
+
+#include <linux/netfilter/x_tables.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <linux/netfilter/xt_cluster.h>
+
+static inline u_int32_t nf_ct_orig_ipv4_src(const struct nf_conn *ct)
+{
+	return ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip;
+}
+
+static inline const void *nf_ct_orig_ipv6_src(const struct nf_conn *ct)
+{
+	return ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip6;
+}
+
+static inline u_int32_t
+xt_cluster_hash_ipv4(u_int32_t ip, const struct xt_cluster_match_info *info)
+{
+	return jhash_1word(ip, info->hash_seed);
+}
+
+static inline u_int32_t
+xt_cluster_hash_ipv6(const void *ip, const struct xt_cluster_match_info *info)
+{
+	return jhash2(ip, NF_CT_TUPLE_L3SIZE / sizeof(__u32), info->hash_seed);
+}
+
+static inline u_int32_t
+xt_cluster_hash(const struct nf_conn *ct,
+		const struct xt_cluster_match_info *info)
+{
+	u_int32_t hash = 0;
+
+	switch(nf_ct_l3num(ct)) {
+	case AF_INET:
+		hash = xt_cluster_hash_ipv4(nf_ct_orig_ipv4_src(ct), info);
+		break;
+	case AF_INET6:
+		hash = xt_cluster_hash_ipv6(nf_ct_orig_ipv6_src(ct), info);
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+	return (((u64)hash * info->total_nodes) >> 32);
+}
+
+static inline bool
+xt_cluster_is_multicast_addr(const struct sk_buff *skb, u_int8_t family)
+{
+	bool is_multicast = false;
+
+	switch(family) {
+	case NFPROTO_IPV4:
+		is_multicast = ipv4_is_multicast(ip_hdr(skb)->daddr);
+		break;
+	case NFPROTO_IPV6:
+		is_multicast = ipv6_addr_type(&ipv6_hdr(skb)->daddr) &
+						IPV6_ADDR_MULTICAST;
+		break;
+	default:
+		WARN_ON(1);
+		break;
+	}
+	return is_multicast;
+}
+
+static bool
+xt_cluster_mt(const struct sk_buff *skb, const struct xt_match_param *par)
+{
+	struct sk_buff *pskb = (struct sk_buff *)skb;
+	const struct xt_cluster_match_info *info = par->matchinfo;
+	const struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	unsigned long hash;
+
+	/* This match assumes that all nodes see the same packets. This can be
+	 * achieved if the switch that connects the cluster nodes support some
+	 * sort of 'port mirroring'. However, if your switch does not support
+	 * this, your cluster nodes can reply ARP request using a multicast MAC
+	 * address. Thus, your switch will flood the same packets to the
+	 * cluster nodes with the same multicast MAC address. Using a multicast
+	 * link address is a RFC 1812 (section 3.3.2) violation, but this works
+	 * fine in practise.
+	 *
+	 * Unfortunately, if you use the multicast MAC address, the link layer
+	 * sets skbuff's pkt_type to PACKET_MULTICAST, which is not accepted
+	 * by TCP and others for packets coming to this node. For that reason,
+	 * this match mangles skbuff's pkt_type if it detects a packet
+	 * addressed to a unicast address but using PACKET_MULTICAST. Yes, I
+	 * know, matches should not alter packets, but we are doing this here
+	 * because we would need to add a PKTTYPE target for this sole purpose.
+	 */
+	if (!xt_cluster_is_multicast_addr(skb, par->family) &&
+	    skb->pkt_type == PACKET_MULTICAST) {
+	    	pskb->pkt_type = PACKET_HOST;
+	}
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct == NULL)
+		return false;
+
+	if (ct == &nf_conntrack_untracked)
+		return false;
+
+	if (ct->master)
+		hash = xt_cluster_hash(ct->master, info);
+	else
+		hash = xt_cluster_hash(ct, info);
+
+	return !!((1 << hash) & info->node_mask) ^
+	       !!(info->flags & XT_CLUSTER_F_INV);
+}
+
+static bool xt_cluster_mt_checkentry(const struct xt_mtchk_param *par)
+{
+	struct xt_cluster_match_info *info = par->matchinfo;
+
+	if (info->node_mask >= (1 << info->total_nodes)) {
+		printk(KERN_ERR "xt_cluster: this node mask cannot be "
+				"higher than the total number of nodes\n");
+		return false;
+	}
+	return true;
+}
+
+static struct xt_match xt_cluster_match __read_mostly = {
+	.name		= "cluster",
+	.family		= NFPROTO_UNSPEC,
+	.match		= xt_cluster_mt,
+	.checkentry	= xt_cluster_mt_checkentry,
+	.matchsize	= sizeof(struct xt_cluster_match_info),
+	.me		= THIS_MODULE,
+};
+
+static int __init xt_cluster_mt_init(void)
+{
+	return xt_register_match(&xt_cluster_match);
+}
+
+static void __exit xt_cluster_mt_fini(void)
+{
+	xt_unregister_match(&xt_cluster_match);
+}
+
+MODULE_AUTHOR("Pablo Neira Ayuso <pablo@netfilter.org>");
+MODULE_LICENSE("GPL");
+MODULE_DESCRIPTION("Xtables: hash-based cluster match");
+MODULE_ALIAS("ipt_cluster");
+MODULE_ALIAS("ip6t_cluster");
+module_init(xt_cluster_mt_init);
+module_exit(xt_cluster_mt_fini);
