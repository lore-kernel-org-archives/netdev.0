From: Changli Gao <xiaosuo@gmail.com>
Subject: [PATCH RFC] netfilter: iptables target SYNPROXY
Date: Tue, 25 May 2010 15:06:58 +0800
Message-ID: <1274771218-3204-1-git-send-email-xiaosuo@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Changli Gao <xiaosuo@gmail.com>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:63301 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723Ab0EYHHj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 03:07:39 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

iptables target SYNPROXY.

This patch implements an iptables target SYNPROXY, which works in the raw table
of the PREROUTING chain, before conntracking system. Syncookies is used, so no
new state is introduced into the conntracking system. In fact, until the first
connection is established, conntracking system doesn't see any packets. So when
there is a SYN-flood attack, conntracking system won't be busy on finding and
deleting the un-assured ct.

As the SYN-packet of the second connection request is sent locally, the DNAT
rules which are in the PREROUTING chain should be moved to the OUTPUT chain.

Signed-off-by: Changli Gao <xiaosuo@gmail.com>
----
 include/net/netfilter/nf_conntrack.h        |    8 
 include/net/netfilter/nf_conntrack_core.h   |   15 
 include/net/netfilter/nf_conntrack_extend.h |    2 
 include/net/tcp.h                           |   14 
 net/ipv4/netfilter/Kconfig                  |   12 
 net/ipv4/netfilter/Makefile                 |    1 
 net/ipv4/netfilter/ipt_SYNPROXY.c           |  658 ++++++++++++++++++++++++++++
 net/ipv4/syncookies.c                       |   21 
 net/ipv4/tcp_ipv4.c                         |    5 
 net/netfilter/nf_conntrack_core.c           |   44 +
 10 files changed, 764 insertions(+), 16 deletions(-)
diff --git a/include/net/netfilter/nf_conntrack.h b/include/net/netfilter/nf_conntrack.h
index bde095f..001e6ee 100644
--- a/include/net/netfilter/nf_conntrack.h
+++ b/include/net/netfilter/nf_conntrack.h
@@ -310,5 +310,13 @@ do {							\
 #define MODULE_ALIAS_NFCT_HELPER(helper) \
         MODULE_ALIAS("nfct-helper-" helper)
 
+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
+    defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
+extern int (*syn_proxy_pre_hook)(struct sk_buff *skb, struct nf_conn *ct,
+				 enum ip_conntrack_info ctinfo);
+
+extern int (*syn_proxy_post_hook)(struct sk_buff *skb, struct nf_conn *ct,
+				  enum ip_conntrack_info ctinfo);
+#endif
 #endif /* __KERNEL__ */
 #endif /* _NF_CONNTRACK_H */
diff --git a/include/net/netfilter/nf_conntrack_core.h b/include/net/netfilter/nf_conntrack_core.h
index dffde8e..ae7d4be 100644
--- a/include/net/netfilter/nf_conntrack_core.h
+++ b/include/net/netfilter/nf_conntrack_core.h
@@ -63,8 +63,21 @@ static inline int nf_conntrack_confirm(struct sk_buff *skb)
 	if (ct && ct != &nf_conntrack_untracked) {
 		if (!nf_ct_is_confirmed(ct) && !nf_ct_is_dying(ct))
 			ret = __nf_conntrack_confirm(skb);
-		if (likely(ret == NF_ACCEPT))
+		if (likely(ret == NF_ACCEPT)) {
+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
+    defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
+			int (*syn_proxy)(struct sk_buff *, struct nf_conn *,
+					 enum ip_conntrack_info);
+#endif
+
 			nf_ct_deliver_cached_events(ct);
+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
+    defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
+			syn_proxy = rcu_dereference(syn_proxy_post_hook);
+			if (syn_proxy)
+				ret = syn_proxy(skb, ct, skb->nfctinfo);
+#endif
+		}
 	}
 	return ret;
 }
diff --git a/include/net/netfilter/nf_conntrack_extend.h b/include/net/netfilter/nf_conntrack_extend.h
index 32d15bd..b2ae7e9 100644
--- a/include/net/netfilter/nf_conntrack_extend.h
+++ b/include/net/netfilter/nf_conntrack_extend.h
@@ -11,6 +11,7 @@ enum nf_ct_ext_id {
 	NF_CT_EXT_ACCT,
 	NF_CT_EXT_ECACHE,
 	NF_CT_EXT_ZONE,
+	NF_CT_EXT_SYNPROXY,
 	NF_CT_EXT_NUM,
 };
 
@@ -19,6 +20,7 @@ enum nf_ct_ext_id {
 #define NF_CT_EXT_ACCT_TYPE struct nf_conn_counter
 #define NF_CT_EXT_ECACHE_TYPE struct nf_conntrack_ecache
 #define NF_CT_EXT_ZONE_TYPE struct nf_conntrack_zone
+#define NF_CT_EXT_SYNPROXY_TYPE struct syn_proxy_state
 
 /* Extensions: optional stuff which isn't permanently in struct. */
 struct nf_ct_ext {
diff --git a/include/net/tcp.h b/include/net/tcp.h
index a144914..b1d59c2 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -460,8 +460,18 @@ extern int			tcp_disconnect(struct sock *sk, int flags);
 extern __u32 syncookie_secret[2][16-4+SHA_DIGEST_WORDS];
 extern struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb, 
 				    struct ip_options *opt);
-extern __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, 
-				     __u16 *mss);
+extern __u32 __cookie_v4_init_sequence(__be32 saddr, __be32 daddr,
+				       __be16 sport, __be16 dport, __u32 seq,
+				       __u16 *mssp);
+static inline __u32 cookie_v4_init_sequence(const struct iphdr *iph,
+					    const struct tcphdr *th,
+					    __u16 *mssp)
+{
+	return __cookie_v4_init_sequence(iph->saddr, iph->daddr, th->source,
+					 th->dest, ntohl(th->seq), mssp);
+}
+extern int cookie_v4_check_sequence(const struct iphdr *iph,
+				    const struct tcphdr *th, __u32 cookie);
 
 extern __u32 cookie_init_timestamp(struct request_sock *req);
 extern void cookie_check_timestamp(struct tcp_options_received *tcp_opt);
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 1833bdb..4c0b5df 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -343,6 +343,18 @@ config IP_NF_RAW
 	  If you want to compile it as a module, say M here and read
 	  <file:Documentation/kbuild/modules.txt>.  If unsure, say `N'.
 
+config IP_NF_TARGET_SYNPROXY
+	tristate "SYNPROXY target support (EXPERIMENTAL)"
+	depends on IP_NF_RAW && EXPERIMENTAL
+	depends on NF_CONNTRACK_IPV4
+	depends on SYN_COOKIES
+	help
+	  The SYNPROXY target allows a raw rule to specify that some TCP
+	  connections are relayed to protect the TCP servers from the SYN-flood
+	  DoS attacks.
+
+	  To compile it as a module, choose M here.  If unsure, say N.
+
 # security table for MAC policy
 config IP_NF_SECURITY
 	tristate "Security table"
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index 4811159..ae6a688 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -61,6 +61,7 @@ obj-$(CONFIG_IP_NF_TARGET_NETMAP) += ipt_NETMAP.o
 obj-$(CONFIG_IP_NF_TARGET_REDIRECT) += ipt_REDIRECT.o
 obj-$(CONFIG_IP_NF_TARGET_REJECT) += ipt_REJECT.o
 obj-$(CONFIG_IP_NF_TARGET_ULOG) += ipt_ULOG.o
+obj-$(CONFIG_IP_NF_TARGET_SYNPROXY) += ipt_SYNPROXY.o
 
 # generic ARP tables
 obj-$(CONFIG_IP_NF_ARPTABLES) += arp_tables.o
diff --git a/net/ipv4/netfilter/ipt_SYNPROXY.c b/net/ipv4/netfilter/ipt_SYNPROXY.c
new file mode 100644
index 0000000..2794aac
--- /dev/null
+++ b/net/ipv4/netfilter/ipt_SYNPROXY.c
@@ -0,0 +1,658 @@
+/* (C) 2010- Changli Gao <xiaosuo@gmail.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ *
+ * It bases on ipt_REJECT.c
+ */
+#define pr_fmt(fmt) "SYNPROXY: " fmt
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/slab.h>
+#include <linux/ip.h>
+#include <linux/udp.h>
+#include <linux/icmp.h>
+#include <linux/unaligned/access_ok.h>
+#include <net/icmp.h>
+#include <net/ip.h>
+#include <net/tcp.h>
+#include <net/route.h>
+#include <net/dst.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_conntrack_extend.h>
+#include <linux/netfilter/x_tables.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Changli Gao <xiaosuo@gmail.com>");
+MODULE_DESCRIPTION("Xtables: \"SYNPROXY\" target for IPv4");
+
+enum {
+	TCP_SEND_FLAG_NOTRACE	= 0x1,
+	TCP_SEND_FLAG_SYNCOOKIE	= 0x2,
+	TCP_SEND_FLAG_ACK2SYN	= 0x4,
+};
+
+struct syn_proxy_state {
+	u16	seq_inited;
+	__be16	window;
+	u32	seq_diff;
+};
+
+static int get_mtu(const struct dst_entry *dst)
+{
+	int mtu;
+
+	mtu = dst_mtu(dst);
+	if (mtu)
+		return mtu;
+
+	return dst->dev ? dst->dev->mtu : 0;
+}
+
+static int get_advmss(const struct dst_entry *dst)
+{
+	int advmss;
+
+	advmss = dst_metric(dst, RTAX_ADVMSS);
+	if (advmss)
+		return advmss;
+	advmss = get_mtu(dst);
+	if (advmss)
+		return advmss - (sizeof(struct iphdr) + sizeof(struct tcphdr));
+
+	return TCP_MSS_DEFAULT;
+}
+
+static int syn_proxy_route(struct sk_buff *skb, struct net *net, u16 *pmss)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct rtable *rt;
+	struct flowi fl = {};
+	unsigned int type;
+	int flags = 0;
+	int err;
+	u16 mss;
+
+	type = inet_addr_type(net, iph->saddr);
+	if (type != RTN_LOCAL) {
+		type = inet_addr_type(net, iph->daddr);
+		if (type == RTN_LOCAL)
+			flags |= FLOWI_FLAG_ANYSRC;
+	}
+
+	if (type == RTN_LOCAL) {
+		fl.nl_u.ip4_u.daddr = iph->daddr;
+		fl.nl_u.ip4_u.saddr = iph->saddr;
+		fl.nl_u.ip4_u.tos = RT_TOS(iph->tos);
+		fl.flags = flags;
+		err = ip_route_output_key(net, &rt, &fl);
+		if (err)
+			goto out;
+
+		skb_dst_set(skb, &rt->u.dst);
+	} else {
+		/* non-local src, find valid iif to satisfy
+		 * rp-filter when calling ip_route_input. */
+		fl.nl_u.ip4_u.daddr = iph->saddr;
+		err = ip_route_output_key(net, &rt, &fl);
+		if (err)
+			goto out;
+
+		err = ip_route_input(skb, iph->daddr, iph->saddr,
+				     RT_TOS(iph->tos), rt->u.dst.dev);
+		if (err) {
+			dst_release(&rt->u.dst);
+			goto out;
+		}
+		if (pmss) {
+			mss = get_advmss(&rt->u.dst);
+			if (*pmss > mss)
+				*pmss = mss;
+		}
+		dst_release(&rt->u.dst);
+	}
+
+	err = skb_dst(skb)->error;
+	if (!err && pmss) {
+		mss = get_advmss(skb_dst(skb));
+		if (*pmss > mss)
+			*pmss = mss;
+	}
+
+out:
+	return err;
+}
+
+static int tcp_send(__be32 src, __be32 dst, __be16 sport, __be16 dport,
+		    u32 seq, u32 ack_seq, __be16 window, u16 mss,
+		    __be32 tcp_flags, u8 tos, struct net_device *dev, int flags,
+		    struct sk_buff *oskb)
+{
+	struct sk_buff *skb;
+	struct iphdr *iph;
+	struct tcphdr *th;
+	int err, len;
+
+	len = sizeof(*th);
+	if (mss)
+		len += TCPOLEN_MSS;
+
+	skb = NULL;
+	/* caller must give me a large enough oskb */
+	if (oskb) {
+		unsigned char *odata = oskb->data;
+
+		if (skb_recycle_check(oskb, 0)) {
+			oskb->data = odata;
+			skb_reset_tail_pointer(oskb);
+			skb = oskb;
+			pr_debug("recycle skb\n");
+		}
+	}
+	if (!skb) {
+		skb = alloc_skb(LL_MAX_HEADER + sizeof(*iph) + len, GFP_ATOMIC);
+		if (!skb) {
+			err = -ENOMEM;
+			goto out;
+		}
+		skb_reserve(skb, LL_MAX_HEADER);
+	}
+
+	skb_reset_network_header(skb);
+	if (!(flags & TCP_SEND_FLAG_ACK2SYN) || skb != oskb) {
+		iph = (struct iphdr *)skb_put(skb, sizeof(*iph));
+		iph->version	= 4;
+		iph->ihl	= sizeof(*iph) / 4;
+		iph->tos	= tos;
+		/* tot_len is set in ip_local_out() */
+		iph->id		= 0;
+		iph->frag_off	= htons(IP_DF);
+		iph->protocol	= IPPROTO_TCP;
+		iph->saddr	= src;
+		iph->daddr	= dst;
+		th = (struct tcphdr *)skb_put(skb, len);
+		th->source	= sport;
+		th->dest	= dport;
+	} else {
+		iph = (struct iphdr *)skb->data;
+		iph->id		= 0;
+		iph->frag_off	= htons(IP_DF);
+		skb_put(skb, iph->ihl * 4 + len);
+		th = (struct tcphdr *)(skb->data + iph->ihl * 4);
+	}
+
+	th->seq		= htonl(seq);
+	th->ack_seq	= htonl(ack_seq);
+	tcp_flag_word(th) = tcp_flags;
+	th->doff	= len / 4;
+	th->window	= window;
+	th->urg_ptr	= 0;
+
+	if ((flags & TCP_SEND_FLAG_SYNCOOKIE) && mss)
+		err = syn_proxy_route(skb, dev_net(dev), &mss);
+	else
+		err = syn_proxy_route(skb, dev_net(dev), NULL);
+	if (err)
+		goto err_out;
+
+	if ((flags & TCP_SEND_FLAG_SYNCOOKIE)) {
+		if (mss) {
+			th->seq = htonl(__cookie_v4_init_sequence(dst, src,
+								  dport, sport,
+								  ack_seq - 1,
+								  &mss));
+		} else {
+			mss = TCP_MSS_DEFAULT;
+			th->seq = htonl(__cookie_v4_init_sequence(dst, src,
+								  dport, sport,
+								  ack_seq - 1,
+								  &mss));
+			mss = 0;
+		}
+	}
+
+	if (mss)
+		* (__force __be32 *)(th + 1) = htonl((TCPOPT_MSS << 24) |
+						     (TCPOLEN_MSS << 16) |
+						     mss);
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	th->check = ~tcp_v4_check(len, src, dst, 0);
+	skb->csum_start = (unsigned char *)th - skb->head;
+	skb->csum_offset = offsetof(struct tcphdr, check);
+
+	if (!(flags & TCP_SEND_FLAG_ACK2SYN) || skb != oskb)
+		iph->ttl	= dst_metric(skb_dst(skb), RTAX_HOPLIMIT);
+
+	if (skb->len > get_mtu(skb_dst(skb))) {
+		if (printk_ratelimit())
+			pr_warning("%s has smaller mtu: %d\n",
+				   skb_dst(skb)->dev->name,
+				   get_mtu(skb_dst(skb)));
+		err = -EINVAL;
+		goto err_out;
+	}
+
+	if ((flags & TCP_SEND_FLAG_NOTRACE)) {
+		skb->nfct = &nf_conntrack_untracked.ct_general;
+		skb->nfctinfo = IP_CT_NEW;
+		nf_conntrack_get(skb->nfct);
+	}
+
+	pr_debug("ip_local_out: %pI4n:%hu -> %pI4n:%hu (seq=%u, "
+		 "ack_seq=%u mss=%hu flags=%x)\n", &src, ntohs(th->source),
+		 &dst, ntohs(th->dest), ntohl(th->seq), ack_seq, mss,
+		 ntohl(tcp_flags));
+
+	err = ip_local_out(skb);
+	if (err > 0)
+		err = net_xmit_errno(err);
+
+	pr_debug("ip_local_out: return with %d\n", err);
+out:
+	if (oskb && oskb != skb)
+		kfree_skb(oskb);
+
+	return err;
+
+err_out:
+	kfree_skb(skb);
+	goto out;
+}
+
+static int get_mss(u8 *data, int len)
+{
+	u8 olen;
+
+	while (len >= TCPOLEN_MSS) {
+		switch (data[0]) {
+		case TCPOPT_EOL:
+			return 0;
+		case TCPOPT_NOP:
+			data++;
+			len--;
+			break;
+		case TCPOPT_MSS:
+			if (data[1] != TCPOLEN_MSS)
+				return -EINVAL;
+			return get_unaligned_be16(data + 2);
+		default:
+			olen = data[1];
+			if (olen < 2 || olen > len)
+				return -EINVAL;
+			data += olen;
+			len -= olen;
+			break;
+		}
+	}
+
+	return 0;
+}
+
+static DEFINE_PER_CPU(struct syn_proxy_state, syn_proxy_state);
+
+/* syn_proxy_pre isn't under the protection of nf_conntrack_proto_tcp.c */
+static int syn_proxy_pre(struct sk_buff *skb, struct nf_conn *ct,
+			 enum ip_conntrack_info ctinfo)
+{
+	struct syn_proxy_state *state;
+	struct iphdr *iph;
+	struct tcphdr *th, _th;
+
+	/* only support IPv4 now */
+	iph = ip_hdr(skb);
+	if (iph->version != 4)
+		return NF_ACCEPT;
+
+	th = skb_header_pointer(skb, iph->ihl * 4, sizeof(_th), &_th);
+	BUG_ON(th == NULL);
+
+	if (!ct || !nf_ct_is_confirmed(ct)) {
+		int ret;
+
+		if (!th->syn && th->ack) {
+			u16 mss;
+			struct sk_buff *rec_skb;
+
+			mss = cookie_v4_check_sequence(iph, th,
+						       ntohl(th->ack_seq) - 1);
+			if (!mss)
+				return NF_ACCEPT;
+
+			pr_debug("%pI4n:%hu -> %pI4n:%hu(mss=%hu)\n",
+				 &iph->saddr, ntohs(th->source),
+				 &iph->daddr, ntohs(th->dest), mss);
+
+			if (skb_tailroom(skb) < TCPOLEN_MSS &&
+			    skb->len < iph->ihl * 4 + sizeof(*th) + TCPOLEN_MSS)
+				rec_skb = NULL;
+			else
+				rec_skb = skb;
+
+			local_bh_disable();
+			state = &__get_cpu_var(syn_proxy_state);
+			state->seq_inited = 1;
+			state->window = th->window;
+			state->seq_diff = ntohl(th->ack_seq) - 1;
+			if (rec_skb)
+				tcp_send(iph->saddr, iph->daddr, 0, 0,
+					 ntohl(th->seq) - 1, 0, th->window,
+					 mss, TCP_FLAG_SYN, 0, skb->dev,
+					 TCP_SEND_FLAG_ACK2SYN, rec_skb);
+			else
+				tcp_send(iph->saddr, iph->daddr, th->source,
+					 th->dest, ntohl(th->seq) - 1, 0,
+					 th->window, mss, TCP_FLAG_SYN,
+					 iph->tos, skb->dev, 0, NULL);
+			state->seq_inited = 0;
+			local_bh_enable();
+
+			if (!rec_skb)
+				kfree_skb(skb);
+
+			return NF_STOLEN;
+		}
+
+		if (!ct || !th->syn || th->ack)
+			return NF_ACCEPT;
+
+		ret = NF_ACCEPT;
+		local_bh_disable();
+		state = &__get_cpu_var(syn_proxy_state);
+		if (state->seq_inited) {
+			struct syn_proxy_state *nstate;
+
+			nstate = nf_ct_ext_add(ct, NF_CT_EXT_SYNPROXY,
+					       GFP_ATOMIC);
+			if (nstate != NULL) {
+				nstate->seq_inited = 0;
+				nstate->window = state->window;
+				nstate->seq_diff = state->seq_diff;
+				pr_debug("seq_diff: %u\n", nstate->seq_diff);
+			} else {
+				ret = NF_DROP;
+			}
+		}
+		local_bh_enable();
+
+		return ret;
+	}
+
+	state = nf_ct_ext_find(ct, NF_CT_EXT_SYNPROXY);
+	if (!state)
+		return NF_ACCEPT;
+
+	if (CTINFO2DIR(ctinfo) == IP_CT_DIR_ORIGINAL) {
+		__be32 newack;
+
+		/* don't need to mangle duplicate SYN packets */
+		if (th->syn && !th->ack)
+			return NF_ACCEPT;
+		if (!skb_make_writable(skb, ip_hdrlen(skb) + sizeof(*th)))
+			return NF_DROP;
+		th = (struct tcphdr *)(skb->data + ip_hdrlen(skb));
+		newack = htonl(ntohl(th->ack_seq) - state->seq_diff);
+		inet_proto_csum_replace4(&th->check, skb, th->ack_seq, newack,
+					 0);
+		pr_debug("alter ack seq: %u -> %u\n",
+			 ntohl(th->ack_seq), ntohl(newack));
+		th->ack_seq = newack;
+	} else {
+		/* Simultaneous open ? Oh, no. The connection between
+		 * client and us is established. */
+		if (th->syn && !th->ack)
+			return NF_DROP;
+	}
+
+	return NF_ACCEPT;
+}
+
+static int syn_proxy_mangle_pkt(struct sk_buff *skb, struct iphdr *iph,
+				struct tcphdr *th, u32 seq_diff)
+{
+	__be32 new;
+	int olen;
+
+	if (skb->len < (iph->ihl + th->doff) * 4)
+		return NF_DROP;
+	if (!skb_make_writable(skb, (iph->ihl + th->doff) * 4))
+		return NF_DROP;
+	iph = (struct iphdr *)(skb->data);
+	th = (struct tcphdr *)(skb->data + iph->ihl * 4);
+
+	new = tcp_flag_word(th) & (~TCP_FLAG_SYN);
+	inet_proto_csum_replace4(&th->check, skb, tcp_flag_word(th), new, 0);
+	tcp_flag_word(th) = new;
+
+	new = htonl(ntohl(th->seq) + seq_diff);
+	inet_proto_csum_replace4(&th->check, skb, th->seq, new, 0);
+	pr_debug("alter seq: %u -> %u\n", ntohl(th->seq), ntohl(new));
+	th->seq = new;
+
+	olen = th->doff - sizeof(*th) / 4;
+	if (olen) {
+		__be32 *opt;
+
+		opt = (__force __be32 *)(th + 1);
+#define TCPOPT_EOL_WORD ((TCPOPT_EOL << 24) + (TCPOPT_EOL << 16) + \
+			 (TCPOPT_EOL << 8) + TCPOPT_EOL)
+		inet_proto_csum_replace4(&th->check, skb, *opt, TCPOPT_EOL_WORD,
+					 0);
+		*opt = TCPOPT_EOL_WORD;
+	}
+
+	return NF_ACCEPT;
+}
+
+static int syn_proxy_post(struct sk_buff *skb, struct nf_conn *ct,
+			  enum ip_conntrack_info ctinfo)
+{
+	struct syn_proxy_state *state;
+	struct iphdr *iph;
+	struct tcphdr *th;
+
+	/* untraced packets don't have NF_CT_EXT_SYNPROXY ext, as they don't
+	 * enter syn_proxy_pre() */
+	state = nf_ct_ext_find(ct, NF_CT_EXT_SYNPROXY);
+	if (state == NULL)
+		return NF_ACCEPT;
+
+	iph = ip_hdr(skb);
+	if (!skb_make_writable(skb, iph->ihl * 4 + sizeof(*th)))
+		return NF_DROP;
+	th = (struct tcphdr *)(skb->data + iph->ihl * 4);
+	if (!state->seq_inited) {
+		if (th->syn) {
+			/* It must be from original direction, as the ones
+			 * from the other side are dropped in function
+			 * syn_proxy_pre() */
+			if (!th->ack)
+				return NF_ACCEPT;
+
+			pr_debug("SYN-ACK %pI4n:%hu -> %pI4n:%hu "
+				 "(seq=%u ack_seq=%u)\n",
+				 &iph->saddr, ntohs(th->source), &iph->daddr,
+				 ntohs(th->dest), ntohl(th->seq),
+				 ntohl(th->ack_seq));
+
+			/* SYN-ACK from reply direction with the protection
+			 * of conntrack */
+			spin_lock_bh(&ct->lock);
+			if (!state->seq_inited) {
+				state->seq_inited = 1;
+				pr_debug("update seq_diff %u -> %u\n",
+					 state->seq_diff,
+					 state->seq_diff - ntohl(th->seq));
+				state->seq_diff -= ntohl(th->seq);
+			}
+			spin_unlock_bh(&ct->lock);
+			tcp_send(iph->daddr, iph->saddr, th->dest, th->source,
+				 ntohl(th->ack_seq),
+				 ntohl(th->seq) + 1 + state->seq_diff,
+				 state->window, 0, TCP_FLAG_ACK, iph->tos,
+				 skb->dev, 0, NULL);
+
+			return syn_proxy_mangle_pkt(skb, iph, th,
+						    state->seq_diff + 1);
+		} else {
+			__be32 newseq;
+
+			if (!th->rst)
+				return NF_ACCEPT;
+			newseq = htonl(state->seq_diff + 1);
+			inet_proto_csum_replace4(&th->check, skb, th->seq,
+						 newseq, 0);
+			pr_debug("alter RST seq: %u -> %u\n",
+				 ntohl(th->seq), ntohl(newseq));
+			th->seq = newseq;
+
+			return NF_ACCEPT;
+		}
+	}
+
+	/* ct should be in ESTABLISHED state, but if the ack packets from
+	 * us are lost. */
+	if (th->syn) {
+		if (!th->ack)
+			return NF_ACCEPT;
+
+		tcp_send(iph->daddr, iph->saddr, th->dest, th->source,
+			 ntohl(th->ack_seq),
+			 ntohl(th->seq) + 1 + state->seq_diff,
+			 state->window, 0, TCP_FLAG_ACK, iph->tos,
+			 skb->dev, 0, NULL);
+
+		return syn_proxy_mangle_pkt(skb, iph, th, state->seq_diff + 1);
+	}
+
+	if (CTINFO2DIR(ctinfo) == IP_CT_DIR_REPLY) {
+		__be32 newseq;
+
+		newseq = htonl(ntohl(th->seq) + state->seq_diff);
+		inet_proto_csum_replace4(&th->check, skb, th->seq, newseq, 0);
+		pr_debug("alter seq: %u -> %u\n", ntohl(th->seq),
+			 ntohl(newseq));
+		th->seq = newseq;
+	}
+
+	return NF_ACCEPT;
+}
+
+static int tcp_process(struct sk_buff *skb)
+{
+	const struct iphdr *iph;
+	const struct tcphdr *th;
+	int err;
+	u16 mss;
+
+	iph = ip_hdr(skb);
+	if (iph->frag_off & htons(IP_OFFSET))
+		goto out;
+	if (!pskb_may_pull(skb, iph->ihl * 4 + sizeof(*th)))
+		goto out;
+	th = (const struct tcphdr *)(skb->data + iph->ihl * 4);
+	if (th->fin || th->rst || th->ack || !th->syn)
+		goto out;
+
+	if (nf_ip_checksum(skb, NF_INET_PRE_ROUTING, iph->ihl * 4, IPPROTO_TCP))
+		goto out;
+	mss = 0;
+	if (th->doff > sizeof(*th) / 4) {
+		if (!pskb_may_pull(skb, (iph->ihl + th->doff) * 4))
+			goto out;
+		err = get_mss((u8 *)(th + 1), th->doff * 4 - sizeof(*th));
+		if (err < 0)
+			goto out;
+		if (err != 0)
+			mss = err;
+	} else if (th->doff != sizeof(*th) / 4)
+		goto out;
+
+	tcp_send(iph->daddr, iph->saddr, th->dest, th->source, 0,
+		 ntohl(th->seq) + 1, 0, mss, TCP_FLAG_SYN | TCP_FLAG_ACK,
+		 iph->tos, skb->dev,
+		 TCP_SEND_FLAG_NOTRACE | TCP_SEND_FLAG_SYNCOOKIE, skb);
+
+	return NF_STOLEN;
+
+out:
+	return NF_DROP;
+}
+
+static unsigned int synproxy_tg(struct sk_buff *skb,
+				const struct xt_action_param *par)
+{
+	struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	int ret;
+
+	/* received from lo */
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct)
+		return IPT_CONTINUE;
+
+	local_bh_disable();
+	if (!__get_cpu_var(syn_proxy_state).seq_inited)
+		ret = tcp_process(skb);
+	else
+		ret = IPT_CONTINUE;
+	local_bh_enable();
+
+	return ret;
+}
+
+static struct xt_target synproxy_tg_reg __read_mostly = {
+	.name		= "SYNPROXY",
+	.family		= NFPROTO_IPV4,
+	.target		= synproxy_tg,
+	.table		= "raw",
+	.hooks		= (1 << NF_INET_PRE_ROUTING),
+	.proto		= IPPROTO_TCP,
+	.me		= THIS_MODULE,
+};
+
+static struct nf_ct_ext_type syn_proxy_state_ext __read_mostly = {
+	.len	= sizeof(struct syn_proxy_state),
+	.align	= __alignof__(struct syn_proxy_state),
+	.id	= NF_CT_EXT_SYNPROXY,
+};
+
+static int __init synproxy_tg_init(void)
+{
+	int err, cpu;
+
+	for_each_possible_cpu(cpu)
+		per_cpu(syn_proxy_state, cpu).seq_inited = 0;
+	rcu_assign_pointer(syn_proxy_pre_hook, syn_proxy_pre);
+	rcu_assign_pointer(syn_proxy_post_hook, syn_proxy_post);
+	err = nf_ct_extend_register(&syn_proxy_state_ext);
+	if (err)
+		goto err_out;
+	err = xt_register_target(&synproxy_tg_reg);
+	if (err)
+		goto err_out2;
+
+	return err;
+
+err_out2:
+	nf_ct_extend_unregister(&syn_proxy_state_ext);
+err_out:
+	rcu_assign_pointer(syn_proxy_post_hook, NULL);
+	rcu_assign_pointer(syn_proxy_pre_hook, NULL);
+	rcu_barrier();
+
+	return err;
+}
+
+static void __exit synproxy_tg_exit(void)
+{
+	xt_unregister_target(&synproxy_tg_reg);
+	nf_ct_extend_unregister(&syn_proxy_state_ext);
+	rcu_assign_pointer(syn_proxy_post_hook, NULL);
+	rcu_assign_pointer(syn_proxy_pre_hook, NULL);
+	rcu_barrier();
+}
+
+module_init(synproxy_tg_init);
+module_exit(synproxy_tg_exit);
diff --git a/net/ipv4/syncookies.c b/net/ipv4/syncookies.c
index 5c24db4..d61d374 100644
--- a/net/ipv4/syncookies.c
+++ b/net/ipv4/syncookies.c
@@ -160,26 +160,22 @@ static __u16 const msstab[] = {
  * Generate a syncookie.  mssp points to the mss, which is returned
  * rounded down to the value encoded in the cookie.
  */
-__u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
+__u32 __cookie_v4_init_sequence(__be32 saddr, __be32 daddr, __be16 sport,
+				__be16 dport, __u32 seq, __u16 *mssp)
 {
-	const struct iphdr *iph = ip_hdr(skb);
-	const struct tcphdr *th = tcp_hdr(skb);
 	int mssind;
 	const __u16 mss = *mssp;
 
-	tcp_synq_overflow(sk);
-
 	/* XXX sort msstab[] by probability?  Binary search? */
 	for (mssind = 0; mss > msstab[mssind + 1]; mssind++)
 		;
 	*mssp = msstab[mssind] + 1;
 
-	NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
 
-	return secure_tcp_syn_cookie(iph->saddr, iph->daddr,
-				     th->source, th->dest, ntohl(th->seq),
+	return secure_tcp_syn_cookie(saddr, daddr, sport, dport, seq,
 				     jiffies / (HZ * 60), mssind);
 }
+EXPORT_SYMBOL(__cookie_v4_init_sequence);
 
 /*
  * This (misnamed) value is the age of syncookie which is permitted.
@@ -192,10 +188,9 @@ __u32 cookie_v4_init_sequence(struct sock *sk, struct sk_buff *skb, __u16 *mssp)
  * Check if a ack sequence number is a valid syncookie.
  * Return the decoded mss if it is, or 0 if not.
  */
-static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
+int cookie_v4_check_sequence(const struct iphdr *iph, const struct tcphdr *th,
+			     __u32 cookie)
 {
-	const struct iphdr *iph = ip_hdr(skb);
-	const struct tcphdr *th = tcp_hdr(skb);
 	__u32 seq = ntohl(th->seq) - 1;
 	__u32 mssind = check_tcp_syn_cookie(cookie, iph->saddr, iph->daddr,
 					    th->source, th->dest, seq,
@@ -204,6 +199,7 @@ static inline int cookie_check(struct sk_buff *skb, __u32 cookie)
 
 	return mssind < NUM_MSS ? msstab[mssind] + 1 : 0;
 }
+EXPORT_SYMBOL(cookie_v4_check_sequence);
 
 static inline struct sock *get_cookie_sock(struct sock *sk, struct sk_buff *skb,
 					   struct request_sock *req,
@@ -270,7 +266,8 @@ struct sock *cookie_v4_check(struct sock *sk, struct sk_buff *skb,
 		goto out;
 
 	if (tcp_synq_no_recent_overflow(sk) ||
-	    (mss = cookie_check(skb, cookie)) == 0) {
+	    (mss = cookie_v4_check_sequence(ip_hdr(skb), tcp_hdr(skb),
+					    cookie)) == 0) {
 		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESFAILED);
 		goto out;
 	}
diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 202cf09..9879c3b 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -1330,8 +1330,11 @@ int tcp_v4_conn_request(struct sock *sk, struct sk_buff *skb)
 #ifdef CONFIG_SYN_COOKIES
 		syn_flood_warning(skb);
 		req->cookie_ts = tmp_opt.tstamp_ok;
+		tcp_synq_overflow(sk);
+		NET_INC_STATS_BH(sock_net(sk), LINUX_MIB_SYNCOOKIESSENT);
+		isn = cookie_v4_init_sequence(ip_hdr(skb), tcp_hdr(skb),
+					      &req->mss);
 #endif
-		isn = cookie_v4_init_sequence(sk, skb, &req->mss);
 	} else if (!isn) {
 		struct inet_peer *peer = NULL;
 
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index b83c530..2a2ef7b 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -847,8 +847,24 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 			       l3proto, l4proto, &set_reply, &ctinfo);
 	if (!ct) {
 		/* Not valid part of a connection */
+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
+    defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
+		int (*syn_proxy)(struct sk_buff *, struct nf_conn *,
+				 enum ip_conntrack_info);
+
+		syn_proxy = rcu_dereference(syn_proxy_pre_hook);
+		if (protonum == IPPROTO_TCP && syn_proxy) {
+			ret = syn_proxy(skb, NULL, ctinfo);
+			if (ret == NF_ACCEPT)
+				NF_CT_STAT_INC_ATOMIC(net, invalid);
+		} else {
+#endif
 		NF_CT_STAT_INC_ATOMIC(net, invalid);
 		ret = NF_ACCEPT;
+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
+    defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
+		}
+#endif
 		goto out;
 	}
 
@@ -861,6 +877,20 @@ nf_conntrack_in(struct net *net, u_int8_t pf, unsigned int hooknum,
 
 	NF_CT_ASSERT(skb->nfct);
 
+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
+    defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
+	{
+		int (*syn_proxy)(struct sk_buff *, struct nf_conn *,
+				 enum ip_conntrack_info);
+
+		syn_proxy = rcu_dereference(syn_proxy_pre_hook);
+		if (protonum == IPPROTO_TCP && syn_proxy) {
+			ret = syn_proxy(skb, ct, ctinfo);
+			if (ret != NF_ACCEPT)
+				goto out;
+		}
+	}
+#endif
 	ret = l4proto->packet(ct, skb, dataoff, ctinfo, pf, hooknum);
 	if (ret <= 0) {
 		/* Invalid: inverse of the return code tells
@@ -1448,6 +1478,17 @@ s16 (*nf_ct_nat_offset)(const struct nf_conn *ct,
 			u32 seq);
 EXPORT_SYMBOL_GPL(nf_ct_nat_offset);
 
+#if defined(CONFIG_IP_NF_TARGET_SYNPROXY) || \
+    defined(CONFIG_IP_NF_TARGET_SYNPROXY_MODULE)
+int (*syn_proxy_pre_hook)(struct sk_buff *skb, struct nf_conn *ct,
+			  enum ip_conntrack_info ctinfo);
+EXPORT_SYMBOL(syn_proxy_pre_hook);
+
+int (*syn_proxy_post_hook)(struct sk_buff *skb, struct nf_conn *ct,
+			   enum ip_conntrack_info ctinfo);
+EXPORT_SYMBOL(syn_proxy_post_hook);
+#endif
+
 int nf_conntrack_init(struct net *net)
 {
 	int ret;
@@ -1468,6 +1509,9 @@ int nf_conntrack_init(struct net *net)
 
 		/* Howto get NAT offsets */
 		rcu_assign_pointer(nf_ct_nat_offset, NULL);
+
+		rcu_assign_pointer(syn_proxy_pre_hook, NULL);
+		rcu_assign_pointer(syn_proxy_post_hook, NULL);
 	}
 	return 0;
 
