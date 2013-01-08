From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH 3/5] GRE: Refactor code GRE code.
Date: Mon,  7 Jan 2013 18:31:48 -0800
Message-ID: <1357612308-1781-1-git-send-email-pshelar@nicira.com>
Cc: jesse@nicira.com, Pravin Shelar <pshelar@nicira.com>
To: dev@openvswitch.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog126.obsmtp.com ([74.125.149.155]:34408 "HELO
	na3sys009aog126.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754066Ab3AHCbb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 21:31:31 -0500
Received: by mail-gg0-f197.google.com with SMTP id i1so30865970ggn.4
        for <netdev@vger.kernel.org>; Mon, 07 Jan 2013 18:31:28 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>

Following patch refactors GRE code into ip tunneling code and GRE
specific code. This patch also introduces new tunneling protocol
handler so that multiple modules are register protocol handler for
same protocol simultaneously.

Goal of this work is to reuse ip-tunneling part in other tunneling
implementations. E.g. code related to device management, packet rx/tx.

Suggested-by: Jesse Gross <jesse@nicira.com>
Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 include/linux/if_tunnel.h |    8 -
 include/net/gre.h         |   59 ++-
 include/net/ip_tunnel.h   |  163 +++++
 include/net/ipip.h        |   74 ---
 net/ipv4/Kconfig          |    5 +
 net/ipv4/Makefile         |    1 +
 net/ipv4/af_inet.c        |    1 -
 net/ipv4/gre.c            |  383 +++++++++++-
 net/ipv4/ip_gre.c         | 1565 ++++++++-------------------------------------
 net/ipv4/ip_tunnel.c      | 1063 ++++++++++++++++++++++++++++++
 net/ipv4/ip_vti.c         |    2 +-
 net/ipv4/ipip.c           |    2 +-
 net/ipv4/ipmr.c           |    2 +-
 net/ipv6/af_inet6.c       |    1 -
 net/ipv6/ip6_gre.c        |    1 +
 net/ipv6/ip6_tunnel.c     |    1 +
 net/ipv6/sit.c            |    2 +-
 17 files changed, 1943 insertions(+), 1390 deletions(-)
 create mode 100644 include/net/ip_tunnel.h
 delete mode 100644 include/net/ipip.h
 create mode 100644 net/ipv4/ip_tunnel.c

diff --git a/include/linux/if_tunnel.h b/include/linux/if_tunnel.h
index f4e56ec..b92ac8f 100644
--- a/include/linux/if_tunnel.h
+++ b/include/linux/if_tunnel.h
@@ -13,13 +13,5 @@
 #define for_each_ip_tunnel_rcu(pos, start) \
 	for (pos = rcu_dereference(start); pos; pos = rcu_dereference(pos->next))
 
-/* often modified stats are per cpu, other are shared (netdev->stats) */
-struct pcpu_tstats {
-	u64	rx_packets;
-	u64	rx_bytes;
-	u64	tx_packets;
-	u64	tx_bytes;
-	struct u64_stats_sync	syncp;
-};
 
 #endif /* _IF_TUNNEL_H_ */
diff --git a/include/net/gre.h b/include/net/gre.h
index f7d5bfb..b427aff 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -2,6 +2,7 @@
 #define __LINUX_GRE_H
 
 #include <linux/skbuff.h>
+#include <net/ip_tunnel.h>
 
 #define GREPROTO_CISCO		0
 #define GREPROTO_PPTP		1
@@ -15,10 +16,60 @@ struct gre_protocol {
 int gre_add_protocol(const struct gre_protocol *proto, u8 version);
 int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
-struct gre_base_hdr {
-	__be16 flags;
-	__be16 protocol;
+struct gre_ip_protocol {
+	int (*handler)(struct sk_buff *skb, const struct tnl_ptk_info *tpi);
+	int (*err_handler)(struct sk_buff *skb, u32 info,
+			const struct tnl_ptk_info *tpi);
+	u8 priority;
 };
-#define GRE_HEADER_SECTION 4
 
+int gre_ip_register(struct gre_ip_protocol *proto);
+void gre_ip_unregister(struct gre_ip_protocol *proto);
+int gre_tunnel_xmit(struct sk_buff *skb,
+		  const struct iphdr *tiph,
+		  const struct tnl_ptk_info *tpi, int hdr_len);
+
+static inline __be16 gre_flags_to_tnl_flags(__be16 flags)
+{
+	__be16 tflags = 0;
+
+	if (flags & GRE_CSUM)
+		tflags |= TUNNEL_CSUM;
+	if (flags & GRE_ROUTING)
+		tflags |= TUNNEL_ROUTING;
+	if (flags & GRE_KEY)
+		tflags |= TUNNEL_KEY;
+	if (flags & GRE_SEQ)
+		tflags |= TUNNEL_SEQ;
+	if (flags & GRE_STRICT)
+		tflags |= TUNNEL_STRICT;
+	if (flags & GRE_REC)
+		tflags |= TUNNEL_REC;
+	if (flags & GRE_VERSION)
+		tflags |= TUNNEL_VERSION;
+
+	return tflags;
+}
+
+static inline __be16 tnl_flags_to_gre_flags(__be16 tflags)
+{
+	__be16 flags = 0;
+
+	if (tflags & TUNNEL_CSUM)
+		flags |= GRE_CSUM;
+	if (tflags & TUNNEL_ROUTING)
+		flags |= GRE_ROUTING;
+	if (tflags & TUNNEL_KEY)
+		flags |= GRE_KEY;
+	if (tflags & TUNNEL_SEQ)
+		flags |= GRE_SEQ;
+	if (tflags & TUNNEL_STRICT)
+		flags |= GRE_STRICT;
+	if (tflags & TUNNEL_REC)
+		flags |= GRE_REC;
+	if (tflags & TUNNEL_VERSION)
+		flags |= GRE_VERSION;
+
+	return flags;
+}
 #endif
diff --git a/include/net/ip_tunnel.h b/include/net/ip_tunnel.h
new file mode 100644
index 0000000..7328871
--- /dev/null
+++ b/include/net/ip_tunnel.h
@@ -0,0 +1,163 @@
+#ifndef __NET_IP_TUNNEL_H
+#define __NET_IP_TUNNEL_H 1
+
+#include <linux/if_tunnel.h>
+#include <net/dsfield.h>
+#include <net/gro_cells.h>
+#include <net/inet_ecn.h>
+#include <net/ip.h>
+
+/* Keep error state on tunnel for 30 sec */
+#define IPTUNNEL_ERR_TIMEO	(30*HZ)
+
+/* 6rd prefix/relay information */
+struct ip_tunnel_6rd_parm {
+	struct in6_addr		prefix;
+	__be32			relay_prefix;
+	u16			prefixlen;
+	u16			relay_prefixlen;
+};
+
+struct ip_tunnel {
+	struct ip_tunnel __rcu	*next;
+	struct hlist_node hash_node;
+	struct net_device	*dev;
+
+	int			err_count;	/* Number of arrived ICMP errors */
+	unsigned long		err_time;	/* Time when the last ICMP error arrived */
+
+	/* These four fields used only by GRE */
+	__u32			i_seqno;	/* The last seen seqno	*/
+	__u32			o_seqno;	/* The last output seqno */
+	int			hlen;		/* Precalculated header length */
+	int			mlink;
+
+	struct ip_tunnel_parm	parms;
+
+	/* for SIT */
+#ifdef CONFIG_IPV6_SIT_6RD
+	struct ip_tunnel_6rd_parm	ip6rd;
+#endif
+	struct ip_tunnel_prl_entry __rcu *prl;		/* potential router list */
+	unsigned int			prl_count;	/* # of entries in PRL */
+	int ip_tnl_net_id;
+	struct gro_cells		gro_cells;
+};
+
+#define TUNNEL_CSUM	__cpu_to_be16(0x01)
+#define TUNNEL_ROUTING	__cpu_to_be16(0x02)
+#define TUNNEL_KEY	__cpu_to_be16(0x04)
+#define TUNNEL_SEQ	__cpu_to_be16(0x08)
+#define TUNNEL_STRICT	__cpu_to_be16(0x10)
+#define TUNNEL_REC	__cpu_to_be16(0x20)
+#define TUNNEL_VERSION	__cpu_to_be16(0x40)
+
+struct tnl_ptk_info {
+	__be16 flags;
+	__be16 proto;
+	__be32 key;
+	__be32 seq;
+};
+
+struct ip_tunnel_prl_entry {
+	struct ip_tunnel_prl_entry __rcu *next;
+	__be32				addr;
+	u16				flags;
+	struct rcu_head			rcu_head;
+};
+
+struct pcpu_tstats {
+	u64	rx_packets;
+	u64	rx_bytes;
+	u64	tx_packets;
+	u64	tx_bytes;
+	struct u64_stats_sync	syncp;
+};
+
+void ip_tunnel_xmit_stats(struct sk_buff *skb, struct net_device *dev, int err);
+static inline void iptunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int err;
+	struct iphdr *iph = ip_hdr(skb);
+
+	nf_reset(skb);
+	skb->ip_summed = CHECKSUM_NONE;
+	ip_select_ident(iph, skb_dst(skb), NULL);
+
+	err = ip_local_out(skb);
+	ip_tunnel_xmit_stats(skb, dev, err);
+}
+
+struct ip_tunnel_ops {
+	int (*parse_netlink_parms)(struct ip_tunnel *vxlan,
+				   struct nlattr *data[],
+				   struct nlattr *tb[],
+				   struct ip_tunnel_parm *parms);
+};
+
+#define PACKET_RCVD	0
+#define PACKET_REJECT	1
+
+#define IP_TNL_HASH_BITS   10
+#define IP_TNL_HASH_SIZE   (1 << IP_TNL_HASH_BITS)
+
+struct ip_tunnel_net {
+	struct hlist_head *tunnels;
+	struct net_device *fb_tunnel_dev;
+	const struct ip_tunnel_ops *ops;
+};
+
+int ip_tunnel_init(struct net_device *dev);
+void ip_tunnel_uninit(struct net_device *dev);
+void  ip_tunnel_dellink(struct net_device *dev, struct list_head *head);
+int __net_init ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
+				 struct rtnl_link_ops *ops, char *devname);
+
+void __net_exit ip_tunnel_delete_net(struct ip_tunnel_net *itn);
+
+int  ip_tunnel_build_iphdr(struct sk_buff *skb, struct net_device *dev,
+			   const struct iphdr *tiph, int hlen,
+			   struct iphdr  *niph);
+int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd);
+int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu);
+
+struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
+						struct rtnl_link_stats64 *tot);
+struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
+				   int link, __be16 flags,
+				 __be32 remote, __be32 local,
+				   __be32 key);
+
+int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
+		  const struct tnl_ptk_info *tpi, bool log_ecn_error);
+int ip_tunnel_newlink(struct net *src_net, struct net_device *dev,
+		      struct nlattr *tb[],
+		      struct nlattr *data[]);
+int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
+			 struct nlattr *data[]);
+
+void ip_tunnel_setup(struct net_device *dev, int net_id);
+
+/* Extract dsfield from inner protocol */
+static inline u8 ip_tunnel_get_dsfield(const struct iphdr *iph,
+				   const struct sk_buff *skb)
+{
+	if (skb->protocol == htons(ETH_P_IP))
+		return iph->tos;
+	else if (skb->protocol == htons(ETH_P_IPV6))
+		return ipv6_get_dsfield((const struct ipv6hdr *)iph);
+	else
+		return 0;
+}
+
+/* Propogate ECN bits out */
+static inline u8 ip_tunnel_ecn_encap(u8 tos,
+				 const struct iphdr *iph,
+				 const struct sk_buff *skb)
+{
+	u8 inner = ip_tunnel_get_dsfield(iph, skb);
+
+	return INET_ECN_encapsulate(tos, inner);
+}
+
+#endif /* __NET_IP_TUNNEL_H */
diff --git a/include/net/ipip.h b/include/net/ipip.h
deleted file mode 100644
index 21947cf..0000000
--- a/include/net/ipip.h
+++ /dev/null
@@ -1,74 +0,0 @@
-#ifndef __NET_IPIP_H
-#define __NET_IPIP_H 1
-
-#include <linux/if_tunnel.h>
-#include <net/gro_cells.h>
-#include <net/ip.h>
-
-/* Keep error state on tunnel for 30 sec */
-#define IPTUNNEL_ERR_TIMEO	(30*HZ)
-
-/* 6rd prefix/relay information */
-struct ip_tunnel_6rd_parm {
-	struct in6_addr		prefix;
-	__be32			relay_prefix;
-	u16			prefixlen;
-	u16			relay_prefixlen;
-};
-
-struct ip_tunnel {
-	struct ip_tunnel __rcu	*next;
-	struct net_device	*dev;
-
-	int			err_count;	/* Number of arrived ICMP errors */
-	unsigned long		err_time;	/* Time when the last ICMP error arrived */
-
-	/* These four fields used only by GRE */
-	__u32			i_seqno;	/* The last seen seqno	*/
-	__u32			o_seqno;	/* The last output seqno */
-	int			hlen;		/* Precalculated GRE header length */
-	int			mlink;
-
-	struct ip_tunnel_parm	parms;
-
-	/* for SIT */
-#ifdef CONFIG_IPV6_SIT_6RD
-	struct ip_tunnel_6rd_parm	ip6rd;
-#endif
-	struct ip_tunnel_prl_entry __rcu *prl;		/* potential router list */
-	unsigned int			prl_count;	/* # of entries in PRL */
-
-	struct gro_cells		gro_cells;
-};
-
-struct ip_tunnel_prl_entry {
-	struct ip_tunnel_prl_entry __rcu *next;
-	__be32				addr;
-	u16				flags;
-	struct rcu_head			rcu_head;
-};
-
-static inline void iptunnel_xmit(struct sk_buff *skb, struct net_device *dev)
-{
-	int err;
-	struct iphdr *iph = ip_hdr(skb);
-	int pkt_len = skb->len - skb_transport_offset(skb);
-	struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
-
-	nf_reset(skb);
-	skb->ip_summed = CHECKSUM_NONE;
-	ip_select_ident(iph, skb_dst(skb), NULL);
-
-	err = ip_local_out(skb);
-	if (likely(net_xmit_eval(err) == 0)) {
-		u64_stats_update_begin(&tstats->syncp);
-		tstats->tx_bytes += pkt_len;
-		tstats->tx_packets++;
-		u64_stats_update_end(&tstats->syncp);
-	} else {
-		dev->stats.tx_errors++;
-		dev->stats.tx_aborted_errors++;
-	}
-}
-
-#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 5a19aeb..4c8b845 100644
--- a/net/ipv4/Kconfig
+++ b/net/ipv4/Kconfig
@@ -186,9 +186,14 @@ config NET_IPGRE_DEMUX
 	 This is helper module to demultiplex GRE packets on GRE version field criteria.
 	 Required by ip_gre and pptp modules.
 
+config NET_IP_TUNNEL
+	tristate
+	default n
+
 config NET_IPGRE
 	tristate "IP: GRE tunnels over IP"
 	depends on (IPV6 || IPV6=n) && NET_IPGRE_DEMUX
+	select NET_IP_TUNNEL
 	help
 	  Tunneling means encapsulating data of one protocol type within
 	  another protocol and sending it over a channel that understands the
diff --git a/net/ipv4/Makefile b/net/ipv4/Makefile
index 15ca63e..089cb9f 100644
--- a/net/ipv4/Makefile
+++ b/net/ipv4/Makefile
@@ -13,6 +13,7 @@ obj-y     := route.o inetpeer.o protocol.o \
 	     fib_frontend.o fib_semantics.o fib_trie.o \
 	     inet_fragment.o ping.o
 
+obj-$(CONFIG_NET_IP_TUNNEL) += ip_tunnel.o
 obj-$(CONFIG_SYSCTL) += sysctl_net_ipv4.o
 obj-$(CONFIG_PROC_FS) += proc.o
 obj-$(CONFIG_IP_MULTIPLE_TABLES) += fib_rules.o
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9a3d5d2..61660a0 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -111,7 +111,6 @@
 #include <net/sock.h>
 #include <net/raw.h>
 #include <net/icmp.h>
-#include <net/ipip.h>
 #include <net/inet_common.h>
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
diff --git a/net/ipv4/gre.c b/net/ipv4/gre.c
index c0757c9..7bc7f30 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -16,17 +16,32 @@
 #include <linux/kernel.h>
 #include <linux/kmod.h>
 #include <linux/skbuff.h>
+#include <linux/if.h>
+#include <linux/icmp.h>
 #include <linux/in.h>
 #include <linux/ip.h>
 #include <linux/netdevice.h>
 #include <linux/if_tunnel.h>
+#include <linux/if_vlan.h>
 #include <linux/spinlock.h>
 #include <net/protocol.h>
 #include <net/gre.h>
+#include <net/icmp.h>
+#include <net/route.h>
+#include <net/xfrm.h>
 
+struct gre_base_hdr {
+	__be16 flags;
+	__be16 protocol;
+};
+#define GRE_HEADER_SECTION	4
+#define GRE_MAX_HEADERLEN	(GRE_HEADER_SECTION * 4)
 
 static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read_mostly;
 
+#define GRE_IP_PROTO_MAX	2
+static struct gre_ip_protocol *gre_ip_proto_list[GRE_IP_PROTO_MAX];
+
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
 {
 	ASSERT_RTNL();
@@ -105,6 +120,319 @@ static void gre_err(struct sk_buff *skb, u32 info)
 	rcu_read_unlock();
 }
 
+static int gre_header_len(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
+{
+	int hdr_len = GRE_HEADER_SECTION;
+
+	if (tpi->flags & TUNNEL_CSUM)
+		hdr_len += GRE_HEADER_SECTION;
+
+	if (tpi->flags & TUNNEL_KEY)
+		hdr_len += GRE_HEADER_SECTION;
+
+	if (unlikely(tpi->flags & TUNNEL_SEQ))
+		hdr_len += GRE_HEADER_SECTION;
+
+	/* WCCP version 1 and 2 protocol decoding.
+	 * - Change protocol to IP
+	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
+	 */
+	if (tpi->flags == 0 && tpi->proto == htons(ETH_P_WCCP)) {
+		struct gre_base_hdr *greh = (struct gre_base_hdr *)skb->data;
+		__be32 *options = (__be32 *)(greh + 1 + hdr_len);
+
+		if ((*(u8 *)options & 0xF0) != 0x40)
+			hdr_len += 4;
+	}
+
+	return hdr_len;
+}
+
+static struct sk_buff *gre_build_header(struct sk_buff *skb,
+				 const struct tnl_ptk_info *tpi)
+{
+	struct gre_base_hdr *greh = (struct gre_base_hdr *)skb->data;
+
+	greh->flags = tnl_flags_to_gre_flags(tpi->flags);
+	greh->protocol = tpi->proto;
+	if (tpi->flags&(TUNNEL_KEY|TUNNEL_CSUM|TUNNEL_SEQ)) {
+		__be32 *ptr = (__be32 *)(((u8 *)greh) + gre_header_len(skb, tpi) - 4);
+
+		if (tpi->flags&TUNNEL_SEQ) {
+			*ptr = tpi->seq;
+			ptr--;
+		}
+		if (tpi->flags&TUNNEL_KEY) {
+			*ptr = tpi->key;
+			ptr--;
+		}
+		if (tpi->flags&TUNNEL_CSUM) {
+			*(__sum16 *)ptr = 0;
+			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0, skb->len, 0));
+		}
+	}
+
+	return skb;
+}
+
+static struct sk_buff *handle_offloads(struct sk_buff *skb)
+{
+	int err;
+
+	if (skb_is_gso(skb)) {
+		err = skb_unclone(skb, GFP_ATOMIC);
+		if (unlikely(err))
+			goto error;
+		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
+		return skb;
+	} else if (skb->ip_summed == CHECKSUM_PARTIAL) {
+		/* Pages aren't locked and could change at any time.
+		 * If this happens after we compute the checksum, the
+		 * checksum will be wrong.  We linearize now to avoid
+		 * this problem.
+		 */
+		err = __skb_linearize(skb);
+		if (unlikely(err))
+			goto error;
+
+		err = skb_checksum_help(skb);
+		if (unlikely(err))
+			goto error;
+	}
+
+	skb->ip_summed = CHECKSUM_NONE;
+
+	return skb;
+
+error:
+	kfree_skb(skb);
+	return ERR_PTR(err);
+}
+
+int gre_tunnel_xmit(struct sk_buff *skb,
+		  const struct iphdr *tiph,
+		  const struct tnl_ptk_info *tpi, int hdr_len)
+{
+	struct dst_entry *dst = skb_dst(skb);
+	struct iphdr *iph;
+	int err = NET_XMIT_DROP;
+
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
+	}
+
+	skb = handle_offloads(skb);
+	if (IS_ERR(skb))
+		goto error;
+
+	if (vlan_tx_tag_present(skb)) {
+		skb = __vlan_put_tag(skb, vlan_tx_tag_get(skb));
+		if (unlikely(!skb))
+			goto error;
+		skb->vlan_tci = 0;
+	}
+
+	/* Push GRE header. */
+	skb_push(skb, hdr_len);
+	skb = gre_build_header(skb, tpi);
+	if (!skb)
+		goto error;
+
+	/* Push IP header. */
+	skb_push(skb, sizeof(struct iphdr));
+	skb_reset_network_header(skb);
+	skb_set_transport_header(skb, sizeof(struct iphdr));
+
+	iph = ip_hdr(skb);
+	*iph = *tiph;
+	skb->local_df = 1;
+	__ip_select_ident(ip_hdr(skb), dst, 0);
+
+	/* Reset SKB */
+	nf_reset(skb);
+	secpath_reset(skb);
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
+
+	err = ip_local_out(skb);
+	return err;
+
+error:
+	dst_release(dst);
+	return err;
+}
+EXPORT_SYMBOL(gre_tunnel_xmit);
+
+static __sum16 check_checksum(struct sk_buff *skb)
+{
+	struct iphdr *iph = ip_hdr(skb);
+	struct gre_base_hdr *greh = (struct gre_base_hdr *)(iph + 1);
+	__sum16 csum = 0;
+
+	if (greh->flags & GRE_CSUM) {
+		switch (skb->ip_summed) {
+		case CHECKSUM_COMPLETE:
+			csum = csum_fold(skb->csum);
+
+			if (!csum)
+				break;
+			/* Fall through. */
+
+		case CHECKSUM_NONE:
+			skb->csum = 0;
+			csum = __skb_checksum_complete(skb);
+			skb->ip_summed = CHECKSUM_COMPLETE;
+			break;
+		}
+	}
+
+	return csum;
+}
+
+static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
+			    bool *csum_err, int *hdr_len)
+{
+	struct gre_base_hdr *greh = (struct gre_base_hdr *)skb->data;
+	__be32 *options = (__be32 *)(greh + 1);
+
+	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
+		return -EINVAL;
+
+	tpi->flags = gre_flags_to_tnl_flags(greh->flags);
+	tpi->proto = greh->protocol;
+
+	*hdr_len = GRE_HEADER_SECTION;
+	if (greh->flags & GRE_CSUM) {
+		*hdr_len += GRE_HEADER_SECTION;
+		options++;
+	}
+
+	if (greh->flags & GRE_KEY) {
+		if ((void *)(options + 1) > (void *)skb_tail_pointer(skb))
+			return -1;
+		*hdr_len += GRE_HEADER_SECTION;
+		tpi->key = *options;
+		options++;
+	} else
+		tpi->key = 0;
+
+	if (check_checksum(skb)) {
+		*csum_err = true;
+		return -EINVAL;
+	}
+
+	if (unlikely(greh->flags & GRE_SEQ)) {
+		if ((void *) (options + 1) > (void *)skb_tail_pointer(skb))
+			return -1;
+
+		tpi->seq = *options;
+		*hdr_len += GRE_HEADER_SECTION;
+		options++;
+	} else
+		tpi->seq = 0;
+
+	/* WCCP version 1 and 2 protocol decoding.
+	 * - Change protocol to IP
+	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
+	 */
+	if (greh->flags == 0 && tpi->proto == htons(ETH_P_WCCP)) {
+		tpi->proto = htons(ETH_P_IP);
+		if ((*(u8 *)options & 0xF0) != 0x40)
+			*hdr_len += 4;
+	}
+
+	return 0;
+}
+
+static int gre_ip_rcv(struct sk_buff *skb)
+{
+	struct tnl_ptk_info tpi;
+	int i;
+	int hdr_len;
+	bool csum_err = false;
+
+	if (!pskb_may_pull(skb, GRE_MAX_HEADERLEN))
+		goto drop;
+
+	if (parse_gre_header(skb, &tpi, &csum_err, &hdr_len) < 0)
+		goto drop;
+
+	for (i = 0; i < GRE_IP_PROTO_MAX; i++) {
+		struct gre_ip_protocol *proto;
+		int ret;
+
+		proto = gre_ip_proto_list[i];
+		if (!proto)
+			continue;
+		ret = proto->handler(skb, &tpi);
+		if (ret == PACKET_RCVD)
+			return 0;
+
+	}
+
+	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
+
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+
+static void gre_ip_err(struct sk_buff *skb, u32 info)
+{
+
+	/* All the routers (except for Linux) return only
+	 * 8 bytes of packet payload. It means, that precise relaying of
+	 * ICMP in the real Internet is absolutely infeasible.
+	 *
+	 * Moreover, Cisco "wise men" put GRE key to the third word
+	 * in GRE header. It makes impossible maintaining even soft
+	 * state for keyed
+	 * GRE tunnels with enabled checksum. Tell them "thank you".
+	 *
+	 * Well, I wonder, rfc1812 was written by Cisco employee,
+	 * what the hell these idiots break standards established
+	 * by themselves???
+	 */
+
+	const int type = icmp_hdr(skb)->type;
+	const int code = icmp_hdr(skb)->code;
+	struct tnl_ptk_info tpi;
+	bool csum_err = false;
+	int hdr_len;
+	int i;
+
+	if (!pskb_may_pull(skb, sizeof(struct gre_base_hdr)))
+		return;
+
+	if (parse_gre_header(skb, &tpi, &csum_err, &hdr_len)) {
+		if (!csum_err)		/* ignore csum errors. */
+			return;
+	}
+
+	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
+		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
+				 skb->dev->ifindex, 0, IPPROTO_GRE, 0);
+		return;
+	}
+	if (type == ICMP_REDIRECT) {
+		ipv4_redirect(skb, dev_net(skb->dev), skb->dev->ifindex, 0,
+			      IPPROTO_GRE, 0);
+		return;
+	}
+
+	for (i = 0; i < GRE_IP_PROTO_MAX; i++) {
+		struct gre_ip_protocol *proto;
+
+		proto = gre_ip_proto_list[i];
+		if (!proto)
+			continue;
+
+		if (proto->err_handler(skb, info, &tpi) == PACKET_RCVD)
+			return;
+
+	}
+}
+
 static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 				       netdev_features_t features)
 {
@@ -197,6 +525,11 @@ static const struct net_protocol net_gre_protocol = {
 	.netns_ok    = 1,
 };
 
+static const struct gre_protocol ipgre_protocol = {
+	.handler     = gre_ip_rcv,
+	.err_handler = gre_ip_err,
+};
+
 static const struct net_offload gre_offload = {
 	.callbacks = {
 		.gso_send_check =	gre_gso_send_check,
@@ -204,27 +537,69 @@ static const struct net_offload gre_offload = {
 	},
 };
 
+int gre_ip_register(struct gre_ip_protocol *newp)
+{
+	ASSERT_RTNL();
+
+	if (gre_ip_proto_list[newp->priority])
+		return -EEXIST;
+
+	gre_ip_proto_list[newp->priority] = newp;
+	return 0;
+}
+EXPORT_SYMBOL(gre_ip_register);
+
+void gre_ip_unregister(struct gre_ip_protocol *proto)
+{
+	ASSERT_RTNL();
+
+	BUG_ON(!gre_ip_proto_list[proto->priority]);
+	gre_ip_proto_list[proto->priority] = NULL;
+	synchronize_rcu();
+}
+EXPORT_SYMBOL(gre_ip_unregister);
+
 static int __init gre_init(void)
 {
 	pr_info("GRE over IPv4 demultiplexor driver\n");
 
 	if (inet_add_protocol(&net_gre_protocol, IPPROTO_GRE) < 0) {
 		pr_err("can't add protocol\n");
-		return -EAGAIN;
+		goto err;
+	}
+	rtnl_lock();
+	if (gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0) {
+		pr_info("%s: can't add ipgre handler\n", __func__);
+		rtnl_unlock();
+		goto err_gre;
 	}
+	rtnl_unlock();
 
 	if (inet_add_offload(&gre_offload, IPPROTO_GRE)) {
 		pr_err("can't add protocol offload\n");
-		inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
-		return -EAGAIN;
+		goto err_gso;
 	}
-
 	return 0;
+
+err_gso:
+	rtnl_lock();
+	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
+	rtnl_unlock();
+
+err_gre:
+	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
+err:
+	return -EAGAIN;
 }
 
 static void __exit gre_exit(void)
 {
 	inet_del_offload(&gre_offload, IPPROTO_GRE);
+	rtnl_lock();
+	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
+		pr_info("%s: can't remove protocol\n", __func__);
+	rtnl_unlock();
+
 	inet_del_protocol(&net_gre_protocol, IPPROTO_GRE);
 }
 
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 05f389f..3677955 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -37,7 +37,7 @@
 #include <net/ip.h>
 #include <net/icmp.h>
 #include <net/protocol.h>
-#include <net/ipip.h>
+#include <net/ip_tunnel.h>
 #include <net/arp.h>
 #include <net/checksum.h>
 #include <net/dsfield.h>
@@ -124,360 +124,11 @@ static bool log_ecn_error = true;
 module_param(log_ecn_error, bool, 0644);
 MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
-static struct rtnl_link_ops ipgre_link_ops __read_mostly;
-static int ipgre_tunnel_init(struct net_device *dev);
-static void ipgre_tunnel_setup(struct net_device *dev);
-static int ipgre_tunnel_bind_dev(struct net_device *dev);
-
-/* Fallback tunnel: no source, no destination, no key, no options */
-
-#define HASH_SIZE  16
-
 static int ipgre_net_id __read_mostly;
-struct ipgre_net {
-	struct ip_tunnel __rcu *tunnels[4][HASH_SIZE];
-
-	struct net_device *fb_tunnel_dev;
-};
-
-/* Tunnel hash table */
-
-/*
-   4 hash tables:
-
-   3: (remote,local)
-   2: (remote,*)
-   1: (*,local)
-   0: (*,*)
-
-   We require exact key match i.e. if a key is present in packet
-   it will match only tunnel with the same key; if it is not present,
-   it will match only keyless tunnel.
-
-   All keysless packets, if not matched configured keyless tunnels
-   will match fallback tunnel.
- */
-
-#define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
-
-#define tunnels_r_l	tunnels[3]
-#define tunnels_r	tunnels[2]
-#define tunnels_l	tunnels[1]
-#define tunnels_wc	tunnels[0]
-
-static struct rtnl_link_stats64 *ipgre_get_stats64(struct net_device *dev,
-						   struct rtnl_link_stats64 *tot)
-{
-	int i;
-
-	for_each_possible_cpu(i) {
-		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
-		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
-		unsigned int start;
-
-		do {
-			start = u64_stats_fetch_begin_bh(&tstats->syncp);
-			rx_packets = tstats->rx_packets;
-			tx_packets = tstats->tx_packets;
-			rx_bytes = tstats->rx_bytes;
-			tx_bytes = tstats->tx_bytes;
-		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
-
-		tot->rx_packets += rx_packets;
-		tot->tx_packets += tx_packets;
-		tot->rx_bytes   += rx_bytes;
-		tot->tx_bytes   += tx_bytes;
-	}
-
-	tot->multicast = dev->stats.multicast;
-	tot->rx_crc_errors = dev->stats.rx_crc_errors;
-	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
-	tot->rx_length_errors = dev->stats.rx_length_errors;
-	tot->rx_frame_errors = dev->stats.rx_frame_errors;
-	tot->rx_errors = dev->stats.rx_errors;
-
-	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
-	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
-	tot->tx_dropped = dev->stats.tx_dropped;
-	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
-	tot->tx_errors = dev->stats.tx_errors;
-
-	return tot;
-}
-
-/* Does key in tunnel parameters match packet */
-static bool ipgre_key_match(const struct ip_tunnel_parm *p,
-			    __be16 flags, __be32 key)
-{
-	if (p->i_flags & GRE_KEY) {
-		if (flags & GRE_KEY)
-			return key == p->i_key;
-		else
-			return false;	/* key expected, none present */
-	} else
-		return !(flags & GRE_KEY);
-}
-
-/* Given src, dst and key, find appropriate for input tunnel. */
-
-static struct ip_tunnel *ipgre_tunnel_lookup(struct net_device *dev,
-					     __be32 remote, __be32 local,
-					     __be16 flags, __be32 key,
-					     __be16 gre_proto)
-{
-	struct net *net = dev_net(dev);
-	int link = dev->ifindex;
-	unsigned int h0 = HASH(remote);
-	unsigned int h1 = HASH(key);
-	struct ip_tunnel *t, *cand = NULL;
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
-	int dev_type = (gre_proto == htons(ETH_P_TEB)) ?
-		       ARPHRD_ETHER : ARPHRD_IPGRE;
-	int score, cand_score = 4;
-
-	for_each_ip_tunnel_rcu(t, ign->tunnels_r_l[h0 ^ h1]) {
-		if (local != t->parms.iph.saddr ||
-		    remote != t->parms.iph.daddr ||
-		    !(t->dev->flags & IFF_UP))
-			continue;
-
-		if (!ipgre_key_match(&t->parms, flags, key))
-			continue;
-
-		if (t->dev->type != ARPHRD_IPGRE &&
-		    t->dev->type != dev_type)
-			continue;
-
-		score = 0;
-		if (t->parms.link != link)
-			score |= 1;
-		if (t->dev->type != dev_type)
-			score |= 2;
-		if (score == 0)
-			return t;
-
-		if (score < cand_score) {
-			cand = t;
-			cand_score = score;
-		}
-	}
-
-	for_each_ip_tunnel_rcu(t, ign->tunnels_r[h0 ^ h1]) {
-		if (remote != t->parms.iph.daddr ||
-		    !(t->dev->flags & IFF_UP))
-			continue;
-
-		if (!ipgre_key_match(&t->parms, flags, key))
-			continue;
-
-		if (t->dev->type != ARPHRD_IPGRE &&
-		    t->dev->type != dev_type)
-			continue;
-
-		score = 0;
-		if (t->parms.link != link)
-			score |= 1;
-		if (t->dev->type != dev_type)
-			score |= 2;
-		if (score == 0)
-			return t;
-
-		if (score < cand_score) {
-			cand = t;
-			cand_score = score;
-		}
-	}
-
-	for_each_ip_tunnel_rcu(t, ign->tunnels_l[h1]) {
-		if ((local != t->parms.iph.saddr &&
-		     (local != t->parms.iph.daddr ||
-		      !ipv4_is_multicast(local))) ||
-		    !(t->dev->flags & IFF_UP))
-			continue;
-
-		if (!ipgre_key_match(&t->parms, flags, key))
-			continue;
-
-		if (t->dev->type != ARPHRD_IPGRE &&
-		    t->dev->type != dev_type)
-			continue;
-
-		score = 0;
-		if (t->parms.link != link)
-			score |= 1;
-		if (t->dev->type != dev_type)
-			score |= 2;
-		if (score == 0)
-			return t;
-
-		if (score < cand_score) {
-			cand = t;
-			cand_score = score;
-		}
-	}
-
-	for_each_ip_tunnel_rcu(t, ign->tunnels_wc[h1]) {
-		if (t->parms.i_key != key ||
-		    !(t->dev->flags & IFF_UP))
-			continue;
-
-		if (t->dev->type != ARPHRD_IPGRE &&
-		    t->dev->type != dev_type)
-			continue;
-
-		score = 0;
-		if (t->parms.link != link)
-			score |= 1;
-		if (t->dev->type != dev_type)
-			score |= 2;
-		if (score == 0)
-			return t;
-
-		if (score < cand_score) {
-			cand = t;
-			cand_score = score;
-		}
-	}
-
-	if (cand != NULL)
-		return cand;
-
-	dev = ign->fb_tunnel_dev;
-	if (dev->flags & IFF_UP)
-		return netdev_priv(dev);
-
-	return NULL;
-}
-
-static struct ip_tunnel __rcu **__ipgre_bucket(struct ipgre_net *ign,
-		struct ip_tunnel_parm *parms)
-{
-	__be32 remote = parms->iph.daddr;
-	__be32 local = parms->iph.saddr;
-	__be32 key = parms->i_key;
-	unsigned int h = HASH(key);
-	int prio = 0;
-
-	if (local)
-		prio |= 1;
-	if (remote && !ipv4_is_multicast(remote)) {
-		prio |= 2;
-		h ^= HASH(remote);
-	}
-
-	return &ign->tunnels[prio][h];
-}
-
-static inline struct ip_tunnel __rcu **ipgre_bucket(struct ipgre_net *ign,
-		struct ip_tunnel *t)
-{
-	return __ipgre_bucket(ign, &t->parms);
-}
-
-static void ipgre_tunnel_link(struct ipgre_net *ign, struct ip_tunnel *t)
-{
-	struct ip_tunnel __rcu **tp = ipgre_bucket(ign, t);
-
-	rcu_assign_pointer(t->next, rtnl_dereference(*tp));
-	rcu_assign_pointer(*tp, t);
-}
-
-static void ipgre_tunnel_unlink(struct ipgre_net *ign, struct ip_tunnel *t)
-{
-	struct ip_tunnel __rcu **tp;
-	struct ip_tunnel *iter;
-
-	for (tp = ipgre_bucket(ign, t);
-	     (iter = rtnl_dereference(*tp)) != NULL;
-	     tp = &iter->next) {
-		if (t == iter) {
-			rcu_assign_pointer(*tp, t->next);
-			break;
-		}
-	}
-}
-
-static struct ip_tunnel *ipgre_tunnel_find(struct net *net,
-					   struct ip_tunnel_parm *parms,
-					   int type)
-{
-	__be32 remote = parms->iph.daddr;
-	__be32 local = parms->iph.saddr;
-	__be32 key = parms->i_key;
-	int link = parms->link;
-	struct ip_tunnel *t;
-	struct ip_tunnel __rcu **tp;
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
-
-	for (tp = __ipgre_bucket(ign, parms);
-	     (t = rtnl_dereference(*tp)) != NULL;
-	     tp = &t->next)
-		if (local == t->parms.iph.saddr &&
-		    remote == t->parms.iph.daddr &&
-		    key == t->parms.i_key &&
-		    link == t->parms.link &&
-		    type == t->dev->type)
-			break;
-
-	return t;
-}
-
-static struct ip_tunnel *ipgre_tunnel_locate(struct net *net,
-		struct ip_tunnel_parm *parms, int create)
-{
-	struct ip_tunnel *t, *nt;
-	struct net_device *dev;
-	char name[IFNAMSIZ];
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
-
-	t = ipgre_tunnel_find(net, parms, ARPHRD_IPGRE);
-	if (t || !create)
-		return t;
-
-	if (parms->name[0])
-		strlcpy(name, parms->name, IFNAMSIZ);
-	else
-		strcpy(name, "gre%d");
-
-	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
-	if (!dev)
-		return NULL;
-
-	dev_net_set(dev, net);
-
-	nt = netdev_priv(dev);
-	nt->parms = *parms;
-	dev->rtnl_link_ops = &ipgre_link_ops;
-
-	dev->mtu = ipgre_tunnel_bind_dev(dev);
-
-	if (register_netdevice(dev) < 0)
-		goto failed_free;
-
-	/* Can use a lockless transmit, unless we generate output sequences */
-	if (!(nt->parms.o_flags & GRE_SEQ))
-		dev->features |= NETIF_F_LLTX;
-
-	dev_hold(dev);
-	ipgre_tunnel_link(ign, nt);
-	return nt;
-
-failed_free:
-	free_netdev(dev);
-	return NULL;
-}
+static int ipgre_tap_net_id __read_mostly;
 
-static void ipgre_tunnel_uninit(struct net_device *dev)
-{
-	struct net *net = dev_net(dev);
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
-
-	ipgre_tunnel_unlink(ign, netdev_priv(dev));
-	dev_put(dev);
-}
-
-
-static void ipgre_err(struct sk_buff *skb, u32 info)
+static int ipgre_err(struct sk_buff *skb, u32 info,
+		     const struct tnl_ptk_info *tpi)
 {
 
 /* All the routers (except for Linux) return only
@@ -492,45 +143,35 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
    what the hell these idiots break standards established
    by themselves???
  */
-
+	struct net *net = dev_net(skb->dev);
+	struct ip_tunnel_net *itn;
 	const struct iphdr *iph = (const struct iphdr *)skb->data;
-	__be16	     *p = (__be16 *)(skb->data+(iph->ihl<<2));
-	int grehlen = (iph->ihl<<2) + 4;
 	const int type = icmp_hdr(skb)->type;
 	const int code = icmp_hdr(skb)->code;
 	struct ip_tunnel *t;
-	__be16 flags;
-	__be32 key = 0;
-
-	flags = p[0];
-	if (flags&(GRE_CSUM|GRE_KEY|GRE_SEQ|GRE_ROUTING|GRE_VERSION)) {
-		if (flags&(GRE_VERSION|GRE_ROUTING))
-			return;
-		if (flags&GRE_KEY) {
-			grehlen += 4;
-			if (flags&GRE_CSUM)
-				grehlen += 4;
-		}
-	}
 
-	/* If only 8 bytes returned, keyed message will be dropped here */
-	if (skb_headlen(skb) < grehlen)
-		return;
+	if (tpi->proto == htons(ETH_P_TEB))
+		itn = net_generic(net, ipgre_tap_net_id);
+	else
+		itn = net_generic(net, ipgre_net_id);
+
+	t = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
+			iph->daddr, iph->saddr, tpi->key);
 
-	if (flags & GRE_KEY)
-		key = *(((__be32 *)p) + (grehlen / 4) - 1);
+	if (t == NULL)
+		return PACKET_REJECT;
 
 	switch (type) {
 	default:
 	case ICMP_PARAMETERPROB:
-		return;
+		return PACKET_RCVD;
 
 	case ICMP_DEST_UNREACH:
 		switch (code) {
 		case ICMP_SR_FAILED:
 		case ICMP_PORT_UNREACH:
 			/* Impossible event. */
-			return;
+			return PACKET_RCVD;
 		default:
 			/* All others are translated to HOST_UNREACH.
 			   rfc2003 contains "deep thoughts" about NET_UNREACH,
@@ -541,645 +182,116 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 		break;
 	case ICMP_TIME_EXCEEDED:
 		if (code != ICMP_EXC_TTL)
-			return;
-		break;
-
-	case ICMP_REDIRECT:
+			return PACKET_RCVD;
 		break;
 	}
 
-	t = ipgre_tunnel_lookup(skb->dev, iph->daddr, iph->saddr,
-				flags, key, p[1]);
-
-	if (t == NULL)
-		return;
-
-	if (type == ICMP_DEST_UNREACH && code == ICMP_FRAG_NEEDED) {
-		ipv4_update_pmtu(skb, dev_net(skb->dev), info,
-				 t->parms.link, 0, IPPROTO_GRE, 0);
-		return;
-	}
-	if (type == ICMP_REDIRECT) {
-		ipv4_redirect(skb, dev_net(skb->dev), t->parms.link, 0,
-			      IPPROTO_GRE, 0);
-		return;
-	}
 	if (t->parms.iph.daddr == 0 ||
 	    ipv4_is_multicast(t->parms.iph.daddr))
-		return;
+		return PACKET_RCVD;
 
 	if (t->parms.iph.ttl == 0 && type == ICMP_TIME_EXCEEDED)
-		return;
+		return PACKET_RCVD;
 
 	if (time_before(jiffies, t->err_time + IPTUNNEL_ERR_TIMEO))
 		t->err_count++;
 	else
 		t->err_count = 1;
 	t->err_time = jiffies;
-}
 
-static inline u8
-ipgre_ecn_encapsulate(u8 tos, const struct iphdr *old_iph, struct sk_buff *skb)
-{
-	u8 inner = 0;
-	if (skb->protocol == htons(ETH_P_IP))
-		inner = old_iph->tos;
-	else if (skb->protocol == htons(ETH_P_IPV6))
-		inner = ipv6_get_dsfield((const struct ipv6hdr *)old_iph);
-	return INET_ECN_encapsulate(tos, inner);
+	return PACKET_RCVD;
 }
 
-static int ipgre_rcv(struct sk_buff *skb)
+static int ipgre_rcv(struct sk_buff *skb, const struct tnl_ptk_info *tpi)
 {
+	struct net *net = dev_net(skb->dev);
+	struct ip_tunnel_net *itn;
 	const struct iphdr *iph;
-	u8     *h;
-	__be16    flags;
-	__sum16   csum = 0;
-	__be32 key = 0;
-	u32    seqno = 0;
 	struct ip_tunnel *tunnel;
-	int    offset = 4;
-	__be16 gre_proto;
-	int    err;
-
-	if (!pskb_may_pull(skb, 16))
-		goto drop;
 
 	iph = ip_hdr(skb);
-	h = skb->data;
-	flags = *(__be16 *)h;
-
-	if (flags&(GRE_CSUM|GRE_KEY|GRE_ROUTING|GRE_SEQ|GRE_VERSION)) {
-		/* - Version must be 0.
-		   - We do not support routing headers.
-		 */
-		if (flags&(GRE_VERSION|GRE_ROUTING))
-			goto drop;
-
-		if (flags&GRE_CSUM) {
-			switch (skb->ip_summed) {
-			case CHECKSUM_COMPLETE:
-				csum = csum_fold(skb->csum);
-				if (!csum)
-					break;
-				/* fall through */
-			case CHECKSUM_NONE:
-				skb->csum = 0;
-				csum = __skb_checksum_complete(skb);
-				skb->ip_summed = CHECKSUM_COMPLETE;
-			}
-			offset += 4;
-		}
-		if (flags&GRE_KEY) {
-			key = *(__be32 *)(h + offset);
-			offset += 4;
-		}
-		if (flags&GRE_SEQ) {
-			seqno = ntohl(*(__be32 *)(h + offset));
-			offset += 4;
-		}
-	}
-
-	gre_proto = *(__be16 *)(h + 2);
+	if (tpi->proto == htons(ETH_P_TEB))
+		itn = net_generic(net, ipgre_tap_net_id);
+	else
+		itn = net_generic(net, ipgre_net_id);
 
-	tunnel = ipgre_tunnel_lookup(skb->dev,
-				     iph->saddr, iph->daddr, flags, key,
-				     gre_proto);
+	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi->flags,
+			iph->saddr, iph->daddr, tpi->key);
 	if (tunnel) {
-		struct pcpu_tstats *tstats;
-
-		secpath_reset(skb);
-
-		skb->protocol = gre_proto;
-		/* WCCP version 1 and 2 protocol decoding.
-		 * - Change protocol to IP
-		 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
-		 */
-		if (flags == 0 && gre_proto == htons(ETH_P_WCCP)) {
-			skb->protocol = htons(ETH_P_IP);
-			if ((*(h + offset) & 0xF0) != 0x40)
-				offset += 4;
-		}
-
-		skb->mac_header = skb->network_header;
-		__pskb_pull(skb, offset);
-		skb_postpull_rcsum(skb, skb_transport_header(skb), offset);
-		skb->pkt_type = PACKET_HOST;
-#ifdef CONFIG_NET_IPGRE_BROADCAST
-		if (ipv4_is_multicast(iph->daddr)) {
-			/* Looped back packet, drop it! */
-			if (rt_is_output_route(skb_rtable(skb)))
-				goto drop;
-			tunnel->dev->stats.multicast++;
-			skb->pkt_type = PACKET_BROADCAST;
-		}
-#endif
-
-		if (((flags&GRE_CSUM) && csum) ||
-		    (!(flags&GRE_CSUM) && tunnel->parms.i_flags&GRE_CSUM)) {
-			tunnel->dev->stats.rx_crc_errors++;
-			tunnel->dev->stats.rx_errors++;
-			goto drop;
-		}
-		if (tunnel->parms.i_flags&GRE_SEQ) {
-			if (!(flags&GRE_SEQ) ||
-			    (tunnel->i_seqno && (s32)(seqno - tunnel->i_seqno) < 0)) {
-				tunnel->dev->stats.rx_fifo_errors++;
-				tunnel->dev->stats.rx_errors++;
-				goto drop;
-			}
-			tunnel->i_seqno = seqno + 1;
-		}
-
-		/* Warning: All skb pointers will be invalidated! */
-		if (tunnel->dev->type == ARPHRD_ETHER) {
-			if (!pskb_may_pull(skb, ETH_HLEN)) {
-				tunnel->dev->stats.rx_length_errors++;
-				tunnel->dev->stats.rx_errors++;
-				goto drop;
-			}
-
-			iph = ip_hdr(skb);
-			skb->protocol = eth_type_trans(skb, tunnel->dev);
-			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
-		}
-
-		__skb_tunnel_rx(skb, tunnel->dev);
-
-		skb_reset_network_header(skb);
-		err = IP_ECN_decapsulate(iph, skb);
-		if (unlikely(err)) {
-			if (log_ecn_error)
-				net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
-						     &iph->saddr, iph->tos);
-			if (err > 1) {
-				++tunnel->dev->stats.rx_frame_errors;
-				++tunnel->dev->stats.rx_errors;
-				goto drop;
-			}
-		}
-
-		tstats = this_cpu_ptr(tunnel->dev->tstats);
-		u64_stats_update_begin(&tstats->syncp);
-		tstats->rx_packets++;
-		tstats->rx_bytes += skb->len;
-		u64_stats_update_end(&tstats->syncp);
-
-		gro_cells_receive(&tunnel->gro_cells, skb);
-		return 0;
+		ip_tunnel_rcv(tunnel, skb, tpi, log_ecn_error);
+		return PACKET_RCVD;
 	}
-	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
 
-drop:
-	kfree_skb(skb);
-	return 0;
+	return PACKET_REJECT;
 }
 
 static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
 {
+	__be16 proto = skb->dev->type == ARPHRD_ETHER ?
+		htons(ETH_P_TEB) : skb->protocol;
+	struct tnl_ptk_info tpi;
 	struct ip_tunnel *tunnel = netdev_priv(dev);
-	const struct iphdr  *old_iph = ip_hdr(skb);
 	const struct iphdr  *tiph;
-	struct flowi4 fl4;
-	u8     tos;
-	__be16 df;
-	struct rtable *rt;     			/* Route to the other host */
-	struct net_device *tdev;		/* Device to other host */
-	struct iphdr  *iph;			/* Our new IP header */
-	unsigned int max_headroom;		/* The extra header space needed */
-	int    gre_hlen;
-	__be32 dst;
-	int    mtu;
-	u8     ttl;
-
-	if (skb->ip_summed == CHECKSUM_PARTIAL &&
-	    skb_checksum_help(skb))
-		goto tx_error;
-
-	if (dev->type == ARPHRD_ETHER)
-		IPCB(skb)->flags = 0;
+	struct iphdr iph;
+	int    hlen;
+	int err;
 
 	if (dev->header_ops && dev->type == ARPHRD_IPGRE) {
-		gre_hlen = 0;
+		hlen = 0;
 		if (skb->protocol == htons(ETH_P_IP))
 			tiph = (const struct iphdr *)skb->data;
 		else
 			tiph = &tunnel->parms.iph;
 	} else {
-		gre_hlen = tunnel->hlen;
+		hlen = tunnel->hlen + sizeof(struct iphdr);
 		tiph = &tunnel->parms.iph;
 	}
 
-	if ((dst = tiph->daddr) == 0) {
-		/* NBMA tunnel */
-
-		if (skb_dst(skb) == NULL) {
-			dev->stats.tx_fifo_errors++;
-			goto tx_error;
-		}
-
-		if (skb->protocol == htons(ETH_P_IP)) {
-			rt = skb_rtable(skb);
-			dst = rt_nexthop(rt, old_iph->daddr);
-		}
-#if IS_ENABLED(CONFIG_IPV6)
-		else if (skb->protocol == htons(ETH_P_IPV6)) {
-			const struct in6_addr *addr6;
-			struct neighbour *neigh;
-			bool do_tx_error_icmp;
-			int addr_type;
-
-			neigh = dst_neigh_lookup(skb_dst(skb), &ipv6_hdr(skb)->daddr);
-			if (neigh == NULL)
-				goto tx_error;
-
-			addr6 = (const struct in6_addr *)&neigh->primary_key;
-			addr_type = ipv6_addr_type(addr6);
-
-			if (addr_type == IPV6_ADDR_ANY) {
-				addr6 = &ipv6_hdr(skb)->daddr;
-				addr_type = ipv6_addr_type(addr6);
-			}
-
-			if ((addr_type & IPV6_ADDR_COMPATv4) == 0)
-				do_tx_error_icmp = true;
-			else {
-				do_tx_error_icmp = false;
-				dst = addr6->s6_addr32[3];
-			}
-			neigh_release(neigh);
-			if (do_tx_error_icmp)
-				goto tx_error_icmp;
-		}
-#endif
-		else
-			goto tx_error;
-	}
-
-	ttl = tiph->ttl;
-	tos = tiph->tos;
-	if (tos == 1) {
-		tos = 0;
-		if (skb->protocol == htons(ETH_P_IP))
-			tos = old_iph->tos;
-		else if (skb->protocol == htons(ETH_P_IPV6))
-			tos = ipv6_get_dsfield((const struct ipv6hdr *)old_iph);
-	}
-
-	rt = ip_route_output_gre(dev_net(dev), &fl4, dst, tiph->saddr,
-				 tunnel->parms.o_key, RT_TOS(tos),
-				 tunnel->parms.link);
-	if (IS_ERR(rt)) {
-		dev->stats.tx_carrier_errors++;
-		goto tx_error;
-	}
-	tdev = rt->dst.dev;
-
-	if (tdev == dev) {
-		ip_rt_put(rt);
-		dev->stats.collisions++;
-		goto tx_error;
-	}
-
-	df = tiph->frag_off;
-	if (df)
-		mtu = dst_mtu(&rt->dst) - dev->hard_header_len - tunnel->hlen;
-	else
-		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
-
-	if (skb_dst(skb))
-		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
-
-	if (skb->protocol == htons(ETH_P_IP)) {
-		df |= (old_iph->frag_off&htons(IP_DF));
-
-		if ((old_iph->frag_off&htons(IP_DF)) &&
-		    mtu < ntohs(old_iph->tot_len)) {
-			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-			ip_rt_put(rt);
-			goto tx_error;
-		}
-	}
-#if IS_ENABLED(CONFIG_IPV6)
-	else if (skb->protocol == htons(ETH_P_IPV6)) {
-		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
-
-		if (rt6 && mtu < dst_mtu(skb_dst(skb)) && mtu >= IPV6_MIN_MTU) {
-			if ((tunnel->parms.iph.daddr &&
-			     !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
-			    rt6->rt6i_dst.plen == 128) {
-				rt6->rt6i_flags |= RTF_MODIFIED;
-				dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
-			}
-		}
-
-		if (mtu >= IPV6_MIN_MTU && mtu < skb->len - tunnel->hlen + gre_hlen) {
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-			ip_rt_put(rt);
-			goto tx_error;
-		}
-	}
-#endif
-
-	if (tunnel->err_count > 0) {
-		if (time_before(jiffies,
-				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
-			tunnel->err_count--;
-
-			dst_link_failure(skb);
-		} else
-			tunnel->err_count = 0;
-	}
-
-	max_headroom = LL_RESERVED_SPACE(tdev) + gre_hlen + rt->dst.header_len;
-
-	if (skb_headroom(skb) < max_headroom || skb_shared(skb)||
-	    (skb_cloned(skb) && !skb_clone_writable(skb, 0))) {
-		struct sk_buff *new_skb = skb_realloc_headroom(skb, max_headroom);
-		if (max_headroom > dev->needed_headroom)
-			dev->needed_headroom = max_headroom;
-		if (!new_skb) {
-			ip_rt_put(rt);
-			dev->stats.tx_dropped++;
-			dev_kfree_skb(skb);
-			return NETDEV_TX_OK;
-		}
-		if (skb->sk)
-			skb_set_owner_w(new_skb, skb->sk);
-		dev_kfree_skb(skb);
-		skb = new_skb;
-		old_iph = ip_hdr(skb);
-		/* Warning : tiph value might point to freed memory */
-	}
-
-	skb_push(skb, gre_hlen);
-	skb_reset_network_header(skb);
-	skb_set_transport_header(skb, sizeof(*iph));
-	memset(&(IPCB(skb)->opt), 0, sizeof(IPCB(skb)->opt));
-	IPCB(skb)->flags &= ~(IPSKB_XFRM_TUNNEL_SIZE | IPSKB_XFRM_TRANSFORMED |
-			      IPSKB_REROUTED);
-	skb_dst_drop(skb);
-	skb_dst_set(skb, &rt->dst);
-
-	/*
-	 *	Push down and install the IPIP header.
-	 */
-
-	iph 			=	ip_hdr(skb);
-	iph->version		=	4;
-	iph->ihl		=	sizeof(struct iphdr) >> 2;
-	iph->frag_off		=	df;
-	iph->protocol		=	IPPROTO_GRE;
-	iph->tos		=	ipgre_ecn_encapsulate(tos, old_iph, skb);
-	iph->daddr		=	fl4.daddr;
-	iph->saddr		=	fl4.saddr;
-	iph->ttl		=	ttl;
-
-	if (ttl == 0) {
-		if (skb->protocol == htons(ETH_P_IP))
-			iph->ttl = old_iph->ttl;
-#if IS_ENABLED(CONFIG_IPV6)
-		else if (skb->protocol == htons(ETH_P_IPV6))
-			iph->ttl = ((const struct ipv6hdr *)old_iph)->hop_limit;
-#endif
-		else
-			iph->ttl = ip4_dst_hoplimit(&rt->dst);
-	}
-
-	((__be16 *)(iph + 1))[0] = tunnel->parms.o_flags;
-	((__be16 *)(iph + 1))[1] = (dev->type == ARPHRD_ETHER) ?
-				   htons(ETH_P_TEB) : skb->protocol;
-
-	if (tunnel->parms.o_flags&(GRE_KEY|GRE_CSUM|GRE_SEQ)) {
-		__be32 *ptr = (__be32 *)(((u8 *)iph) + tunnel->hlen - 4);
+	err = ip_tunnel_build_iphdr(skb, dev, tiph, hlen, &iph);
+	if (err)
+		return NETDEV_TX_OK;
 
-		if (tunnel->parms.o_flags&GRE_SEQ) {
-			++tunnel->o_seqno;
-			*ptr = htonl(tunnel->o_seqno);
-			ptr--;
-		}
-		if (tunnel->parms.o_flags&GRE_KEY) {
-			*ptr = tunnel->parms.o_key;
-			ptr--;
-		}
-		if (tunnel->parms.o_flags&GRE_CSUM) {
-			*ptr = 0;
-			*(__sum16 *)ptr = ip_compute_csum((void *)(iph+1), skb->len - sizeof(struct iphdr));
-		}
-	}
+	if (tunnel->parms.o_flags&TUNNEL_SEQ)
+		tunnel->o_seqno++;
 
-	iptunnel_xmit(skb, dev);
-	return NETDEV_TX_OK;
+	tpi.flags = tunnel->parms.o_flags;
+	tpi.proto = proto;
+	tpi.key = tunnel->parms.o_key;
+	tpi.seq = htonl(tunnel->o_seqno);
 
-#if IS_ENABLED(CONFIG_IPV6)
-tx_error_icmp:
-	dst_link_failure(skb);
-#endif
-tx_error:
-	dev->stats.tx_errors++;
-	dev_kfree_skb(skb);
+	err = gre_tunnel_xmit(skb, &iph, &tpi, tunnel->hlen);
+	ip_tunnel_xmit_stats(skb, dev, err);
 	return NETDEV_TX_OK;
 }
 
-static int ipgre_tunnel_bind_dev(struct net_device *dev)
-{
-	struct net_device *tdev = NULL;
-	struct ip_tunnel *tunnel;
-	const struct iphdr *iph;
-	int hlen = LL_MAX_HEADER;
-	int mtu = ETH_DATA_LEN;
-	int addend = sizeof(struct iphdr) + 4;
-
-	tunnel = netdev_priv(dev);
-	iph = &tunnel->parms.iph;
-
-	/* Guess output device to choose reasonable mtu and needed_headroom */
-
-	if (iph->daddr) {
-		struct flowi4 fl4;
-		struct rtable *rt;
-
-		rt = ip_route_output_gre(dev_net(dev), &fl4,
-					 iph->daddr, iph->saddr,
-					 tunnel->parms.o_key,
-					 RT_TOS(iph->tos),
-					 tunnel->parms.link);
-		if (!IS_ERR(rt)) {
-			tdev = rt->dst.dev;
-			ip_rt_put(rt);
-		}
-
-		if (dev->type != ARPHRD_ETHER)
-			dev->flags |= IFF_POINTOPOINT;
-	}
-
-	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(dev_net(dev), tunnel->parms.link);
-
-	if (tdev) {
-		hlen = tdev->hard_header_len + tdev->needed_headroom;
-		mtu = tdev->mtu;
-	}
-	dev->iflink = tunnel->parms.link;
-
-	/* Precalculate GRE options length */
-	if (tunnel->parms.o_flags&(GRE_CSUM|GRE_KEY|GRE_SEQ)) {
-		if (tunnel->parms.o_flags&GRE_CSUM)
-			addend += 4;
-		if (tunnel->parms.o_flags&GRE_KEY)
-			addend += 4;
-		if (tunnel->parms.o_flags&GRE_SEQ)
-			addend += 4;
-	}
-	dev->needed_headroom = addend + hlen;
-	mtu -= dev->hard_header_len + addend;
-
-	if (mtu < 68)
-		mtu = 68;
-
-	tunnel->hlen = addend;
-
-	return mtu;
-}
-
 static int
-ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
+ipgre_tunnel_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd)
 {
 	int err = 0;
 	struct ip_tunnel_parm p;
-	struct ip_tunnel *t;
-	struct net *net = dev_net(dev);
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
-
-	switch (cmd) {
-	case SIOCGETTUNNEL:
-		t = NULL;
-		if (dev == ign->fb_tunnel_dev) {
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p))) {
-				err = -EFAULT;
-				break;
-			}
-			t = ipgre_tunnel_locate(net, &p, 0);
-		}
-		if (t == NULL)
-			t = netdev_priv(dev);
-		memcpy(&p, &t->parms, sizeof(p));
-		if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
-			err = -EFAULT;
-		break;
-
-	case SIOCADDTUNNEL:
-	case SIOCCHGTUNNEL:
-		err = -EPERM;
-		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
-			goto done;
-
-		err = -EFAULT;
-		if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
-			goto done;
-
-		err = -EINVAL;
-		if (p.iph.version != 4 || p.iph.protocol != IPPROTO_GRE ||
-		    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)) ||
-		    ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING)))
-			goto done;
-		if (p.iph.ttl)
-			p.iph.frag_off |= htons(IP_DF);
-
-		if (!(p.i_flags&GRE_KEY))
-			p.i_key = 0;
-		if (!(p.o_flags&GRE_KEY))
-			p.o_key = 0;
-
-		t = ipgre_tunnel_locate(net, &p, cmd == SIOCADDTUNNEL);
-
-		if (dev != ign->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
-			if (t != NULL) {
-				if (t->dev != dev) {
-					err = -EEXIST;
-					break;
-				}
-			} else {
-				unsigned int nflags = 0;
-
-				t = netdev_priv(dev);
-
-				if (ipv4_is_multicast(p.iph.daddr))
-					nflags = IFF_BROADCAST;
-				else if (p.iph.daddr)
-					nflags = IFF_POINTOPOINT;
-
-				if ((dev->flags^nflags)&(IFF_POINTOPOINT|IFF_BROADCAST)) {
-					err = -EINVAL;
-					break;
-				}
-				ipgre_tunnel_unlink(ign, t);
-				synchronize_net();
-				t->parms.iph.saddr = p.iph.saddr;
-				t->parms.iph.daddr = p.iph.daddr;
-				t->parms.i_key = p.i_key;
-				t->parms.o_key = p.o_key;
-				memcpy(dev->dev_addr, &p.iph.saddr, 4);
-				memcpy(dev->broadcast, &p.iph.daddr, 4);
-				ipgre_tunnel_link(ign, t);
-				netdev_state_change(dev);
-			}
-		}
 
-		if (t) {
-			err = 0;
-			if (cmd == SIOCCHGTUNNEL) {
-				t->parms.iph.ttl = p.iph.ttl;
-				t->parms.iph.tos = p.iph.tos;
-				t->parms.iph.frag_off = p.iph.frag_off;
-				if (t->parms.link != p.link) {
-					t->parms.link = p.link;
-					dev->mtu = ipgre_tunnel_bind_dev(dev);
-					netdev_state_change(dev);
-				}
-			}
-			if (copy_to_user(ifr->ifr_ifru.ifru_data, &t->parms, sizeof(p)))
-				err = -EFAULT;
-		} else
-			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
-		break;
+	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
+		return -EFAULT;
 
-	case SIOCDELTUNNEL:
-		err = -EPERM;
-		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
-			goto done;
-
-		if (dev == ign->fb_tunnel_dev) {
-			err = -EFAULT;
-			if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
-				goto done;
-			err = -ENOENT;
-			if ((t = ipgre_tunnel_locate(net, &p, 0)) == NULL)
-				goto done;
-			err = -EPERM;
-			if (t == netdev_priv(ign->fb_tunnel_dev))
-				goto done;
-			dev = t->dev;
-		}
-		unregister_netdevice(dev);
-		err = 0;
-		break;
 
-	default:
-		err = -EINVAL;
+	if (p.iph.version != 4 || p.iph.protocol != IPPROTO_GRE ||
+			p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)) ||
+			((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING))) {
+		return -EINVAL;
 	}
+	p.i_flags = gre_flags_to_tnl_flags(p.i_flags);
+	p.o_flags = gre_flags_to_tnl_flags(p.o_flags);
 
-done:
-	return err;
-}
+	err = ip_tunnel_ioctl(dev, &p, cmd);
+	if (err)
+		return err;
+
+	p.i_flags = tnl_flags_to_gre_flags(p.i_flags);
+	p.o_flags = tnl_flags_to_gre_flags(p.o_flags);
+
+	if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
+		return -EFAULT;
 
-static int ipgre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
-{
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-	if (new_mtu < 68 ||
-	    new_mtu > 0xFFF8 - dev->hard_header_len - tunnel->hlen)
-		return -EINVAL;
-	dev->mtu = new_mtu;
 	return 0;
 }
 
@@ -1221,7 +333,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 	__be16 *p = (__be16 *)(iph+1);
 
 	memcpy(iph, &t->parms.iph, sizeof(struct iphdr));
-	p[0]		= t->parms.o_flags;
+	p[0]		= tnl_flags_to_gre_flags(t->parms.o_flags);
 	p[1]		= htons(type);
 
 	/*
@@ -1289,182 +401,7 @@ static int ipgre_close(struct net_device *dev)
 	}
 	return 0;
 }
-
-#endif
-
-static const struct net_device_ops ipgre_netdev_ops = {
-	.ndo_init		= ipgre_tunnel_init,
-	.ndo_uninit		= ipgre_tunnel_uninit,
-#ifdef CONFIG_NET_IPGRE_BROADCAST
-	.ndo_open		= ipgre_open,
-	.ndo_stop		= ipgre_close,
-#endif
-	.ndo_start_xmit		= ipgre_tunnel_xmit,
-	.ndo_do_ioctl		= ipgre_tunnel_ioctl,
-	.ndo_change_mtu		= ipgre_tunnel_change_mtu,
-	.ndo_get_stats64	= ipgre_get_stats64,
-};
-
-static void ipgre_dev_free(struct net_device *dev)
-{
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-
-	gro_cells_destroy(&tunnel->gro_cells);
-	free_percpu(dev->tstats);
-	free_netdev(dev);
-}
-
-#define GRE_FEATURES (NETIF_F_SG |		\
-		      NETIF_F_FRAGLIST |	\
-		      NETIF_F_HIGHDMA |		\
-		      NETIF_F_HW_CSUM)
-
-static void ipgre_tunnel_setup(struct net_device *dev)
-{
-	dev->netdev_ops		= &ipgre_netdev_ops;
-	dev->destructor 	= ipgre_dev_free;
-
-	dev->type		= ARPHRD_IPGRE;
-	dev->needed_headroom 	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
-	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 4;
-	dev->flags		= IFF_NOARP;
-	dev->iflink		= 0;
-	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
-	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
-
-	dev->features		|= GRE_FEATURES;
-	dev->hw_features	|= GRE_FEATURES;
-}
-
-static int ipgre_tunnel_init(struct net_device *dev)
-{
-	struct ip_tunnel *tunnel;
-	struct iphdr *iph;
-	int err;
-
-	tunnel = netdev_priv(dev);
-	iph = &tunnel->parms.iph;
-
-	tunnel->dev = dev;
-	strcpy(tunnel->parms.name, dev->name);
-
-	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
-	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
-
-	if (iph->daddr) {
-#ifdef CONFIG_NET_IPGRE_BROADCAST
-		if (ipv4_is_multicast(iph->daddr)) {
-			if (!iph->saddr)
-				return -EINVAL;
-			dev->flags = IFF_BROADCAST;
-			dev->header_ops = &ipgre_header_ops;
-		}
 #endif
-	} else
-		dev->header_ops = &ipgre_header_ops;
-
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
-	if (!dev->tstats)
-		return -ENOMEM;
-
-	err = gro_cells_init(&tunnel->gro_cells, dev);
-	if (err) {
-		free_percpu(dev->tstats);
-		return err;
-	}
-
-	return 0;
-}
-
-static void ipgre_fb_tunnel_init(struct net_device *dev)
-{
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-	struct iphdr *iph = &tunnel->parms.iph;
-
-	tunnel->dev = dev;
-	strcpy(tunnel->parms.name, dev->name);
-
-	iph->version		= 4;
-	iph->protocol		= IPPROTO_GRE;
-	iph->ihl		= 5;
-	tunnel->hlen		= sizeof(struct iphdr) + 4;
-
-	dev_hold(dev);
-}
-
-
-static const struct gre_protocol ipgre_protocol = {
-	.handler     = ipgre_rcv,
-	.err_handler = ipgre_err,
-};
-
-static void ipgre_destroy_tunnels(struct ipgre_net *ign, struct list_head *head)
-{
-	int prio;
-
-	for (prio = 0; prio < 4; prio++) {
-		int h;
-		for (h = 0; h < HASH_SIZE; h++) {
-			struct ip_tunnel *t;
-
-			t = rtnl_dereference(ign->tunnels[prio][h]);
-
-			while (t != NULL) {
-				unregister_netdevice_queue(t->dev, head);
-				t = rtnl_dereference(t->next);
-			}
-		}
-	}
-}
-
-static int __net_init ipgre_init_net(struct net *net)
-{
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
-	int err;
-
-	ign->fb_tunnel_dev = alloc_netdev(sizeof(struct ip_tunnel), "gre0",
-					   ipgre_tunnel_setup);
-	if (!ign->fb_tunnel_dev) {
-		err = -ENOMEM;
-		goto err_alloc_dev;
-	}
-	dev_net_set(ign->fb_tunnel_dev, net);
-
-	ipgre_fb_tunnel_init(ign->fb_tunnel_dev);
-	ign->fb_tunnel_dev->rtnl_link_ops = &ipgre_link_ops;
-
-	if ((err = register_netdev(ign->fb_tunnel_dev)))
-		goto err_reg_dev;
-
-	rcu_assign_pointer(ign->tunnels_wc[0],
-			   netdev_priv(ign->fb_tunnel_dev));
-	return 0;
-
-err_reg_dev:
-	ipgre_dev_free(ign->fb_tunnel_dev);
-err_alloc_dev:
-	return err;
-}
-
-static void __net_exit ipgre_exit_net(struct net *net)
-{
-	struct ipgre_net *ign;
-	LIST_HEAD(list);
-
-	ign = net_generic(net, ipgre_net_id);
-	rtnl_lock();
-	ipgre_destroy_tunnels(ign, &list);
-	unregister_netdevice_many(&list);
-	rtnl_unlock();
-}
-
-static struct pernet_operations ipgre_net_ops = {
-	.init = ipgre_init_net,
-	.exit = ipgre_exit_net,
-	.id   = &ipgre_net_id,
-	.size = sizeof(struct ipgre_net),
-};
 
 static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
 {
@@ -1508,24 +445,24 @@ out:
 	return ipgre_tunnel_validate(tb, data);
 }
 
-static void ipgre_netlink_parms(struct nlattr *data[],
-				struct ip_tunnel_parm *parms)
+static int ipgre_netlink_parms(struct ip_tunnel *itn, struct nlattr *data[],
+			struct nlattr *tb[], struct ip_tunnel_parm *parms)
 {
 	memset(parms, 0, sizeof(*parms));
 
 	parms->iph.protocol = IPPROTO_GRE;
 
 	if (!data)
-		return;
+		return 0;
 
 	if (data[IFLA_GRE_LINK])
 		parms->link = nla_get_u32(data[IFLA_GRE_LINK]);
 
 	if (data[IFLA_GRE_IFLAGS])
-		parms->i_flags = nla_get_be16(data[IFLA_GRE_IFLAGS]);
+		parms->i_flags = gre_flags_to_tnl_flags(nla_get_be16(data[IFLA_GRE_IFLAGS]));
 
 	if (data[IFLA_GRE_OFLAGS])
-		parms->o_flags = nla_get_be16(data[IFLA_GRE_OFLAGS]);
+		parms->o_flags = gre_flags_to_tnl_flags(nla_get_be16(data[IFLA_GRE_OFLAGS]));
 
 	if (data[IFLA_GRE_IKEY])
 		parms->i_key = nla_get_be32(data[IFLA_GRE_IKEY]);
@@ -1547,148 +484,10 @@ static void ipgre_netlink_parms(struct nlattr *data[],
 
 	if (!data[IFLA_GRE_PMTUDISC] || nla_get_u8(data[IFLA_GRE_PMTUDISC]))
 		parms->iph.frag_off = htons(IP_DF);
-}
-
-static int ipgre_tap_init(struct net_device *dev)
-{
-	struct ip_tunnel *tunnel;
-
-	tunnel = netdev_priv(dev);
-
-	tunnel->dev = dev;
-	strcpy(tunnel->parms.name, dev->name);
-
-	ipgre_tunnel_bind_dev(dev);
-
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
-	if (!dev->tstats)
-		return -ENOMEM;
 
 	return 0;
 }
 
-static const struct net_device_ops ipgre_tap_netdev_ops = {
-	.ndo_init		= ipgre_tap_init,
-	.ndo_uninit		= ipgre_tunnel_uninit,
-	.ndo_start_xmit		= ipgre_tunnel_xmit,
-	.ndo_set_mac_address 	= eth_mac_addr,
-	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= ipgre_tunnel_change_mtu,
-	.ndo_get_stats64	= ipgre_get_stats64,
-};
-
-static void ipgre_tap_setup(struct net_device *dev)
-{
-
-	ether_setup(dev);
-
-	dev->netdev_ops		= &ipgre_tap_netdev_ops;
-	dev->destructor 	= ipgre_dev_free;
-
-	dev->iflink		= 0;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
-}
-
-static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nlattr *tb[],
-			 struct nlattr *data[])
-{
-	struct ip_tunnel *nt;
-	struct net *net = dev_net(dev);
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
-	int mtu;
-	int err;
-
-	nt = netdev_priv(dev);
-	ipgre_netlink_parms(data, &nt->parms);
-
-	if (ipgre_tunnel_find(net, &nt->parms, dev->type))
-		return -EEXIST;
-
-	if (dev->type == ARPHRD_ETHER && !tb[IFLA_ADDRESS])
-		eth_hw_addr_random(dev);
-
-	mtu = ipgre_tunnel_bind_dev(dev);
-	if (!tb[IFLA_MTU])
-		dev->mtu = mtu;
-
-	/* Can use a lockless transmit, unless we generate output sequences */
-	if (!(nt->parms.o_flags & GRE_SEQ))
-		dev->features |= NETIF_F_LLTX;
-
-	err = register_netdevice(dev);
-	if (err)
-		goto out;
-
-	dev_hold(dev);
-	ipgre_tunnel_link(ign, nt);
-
-out:
-	return err;
-}
-
-static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
-			    struct nlattr *data[])
-{
-	struct ip_tunnel *t, *nt;
-	struct net *net = dev_net(dev);
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
-	struct ip_tunnel_parm p;
-	int mtu;
-
-	if (dev == ign->fb_tunnel_dev)
-		return -EINVAL;
-
-	nt = netdev_priv(dev);
-	ipgre_netlink_parms(data, &p);
-
-	t = ipgre_tunnel_locate(net, &p, 0);
-
-	if (t) {
-		if (t->dev != dev)
-			return -EEXIST;
-	} else {
-		t = nt;
-
-		if (dev->type != ARPHRD_ETHER) {
-			unsigned int nflags = 0;
-
-			if (ipv4_is_multicast(p.iph.daddr))
-				nflags = IFF_BROADCAST;
-			else if (p.iph.daddr)
-				nflags = IFF_POINTOPOINT;
-
-			if ((dev->flags ^ nflags) &
-			    (IFF_POINTOPOINT | IFF_BROADCAST))
-				return -EINVAL;
-		}
-
-		ipgre_tunnel_unlink(ign, t);
-		t->parms.iph.saddr = p.iph.saddr;
-		t->parms.iph.daddr = p.iph.daddr;
-		t->parms.i_key = p.i_key;
-		if (dev->type != ARPHRD_ETHER) {
-			memcpy(dev->dev_addr, &p.iph.saddr, 4);
-			memcpy(dev->broadcast, &p.iph.daddr, 4);
-		}
-		ipgre_tunnel_link(ign, t);
-		netdev_state_change(dev);
-	}
-
-	t->parms.o_key = p.o_key;
-	t->parms.iph.ttl = p.iph.ttl;
-	t->parms.iph.tos = p.iph.tos;
-	t->parms.iph.frag_off = p.iph.frag_off;
-
-	if (t->parms.link != p.link) {
-		t->parms.link = p.link;
-		mtu = ipgre_tunnel_bind_dev(dev);
-		if (!tb[IFLA_MTU])
-			dev->mtu = mtu;
-		netdev_state_change(dev);
-	}
-
-	return 0;
-}
 
 static size_t ipgre_get_size(const struct net_device *dev)
 {
@@ -1722,8 +521,8 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct ip_tunnel_parm *p = &t->parms;
 
 	if (nla_put_u32(skb, IFLA_GRE_LINK, p->link) ||
-	    nla_put_be16(skb, IFLA_GRE_IFLAGS, p->i_flags) ||
-	    nla_put_be16(skb, IFLA_GRE_OFLAGS, p->o_flags) ||
+	    nla_put_be16(skb, IFLA_GRE_IFLAGS, tnl_flags_to_gre_flags(p->i_flags)) ||
+	    nla_put_be16(skb, IFLA_GRE_OFLAGS, tnl_flags_to_gre_flags(p->o_flags)) ||
 	    nla_put_be32(skb, IFLA_GRE_IKEY, p->i_key) ||
 	    nla_put_be32(skb, IFLA_GRE_OKEY, p->o_key) ||
 	    nla_put_be32(skb, IFLA_GRE_LOCAL, p->iph.saddr) ||
@@ -1752,6 +551,101 @@ static const struct nla_policy ipgre_policy[IFLA_GRE_MAX + 1] = {
 	[IFLA_GRE_PMTUDISC]	= { .type = NLA_U8 },
 };
 
+static int ip_gre_calc_hlen(struct ip_tunnel *tunnel)
+{
+	int addend = 4;
+
+	/* Precalculate GRE options length */
+	if (tunnel->parms.o_flags&TUNNEL_CSUM)
+		addend += 4;
+	if (tunnel->parms.o_flags&TUNNEL_KEY)
+		addend += 4;
+	if (tunnel->parms.o_flags&TUNNEL_SEQ)
+		addend += 4;
+	return addend;
+}
+
+#define GRE_FEATURES (NETIF_F_SG |		\
+		      NETIF_F_FRAGLIST |	\
+		      NETIF_F_HIGHDMA |		\
+		      NETIF_F_HW_CSUM)
+
+static void __gre_tunnel_init(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel;
+
+	tunnel = netdev_priv(dev);
+	tunnel->hlen = ip_gre_calc_hlen(tunnel);
+	tunnel->parms.iph.protocol = IPPROTO_GRE;
+
+	dev->needed_headroom	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
+	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 4;
+	dev->iflink		= 0;
+
+	dev->features		|= NETIF_F_NETNS_LOCAL | GRE_FEATURES;
+	dev->hw_features	|= GRE_FEATURES;
+}
+
+static int ipgre_tunnel_init(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct iphdr *iph;
+
+	__gre_tunnel_init(dev);
+
+	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
+	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
+
+	dev->type		= ARPHRD_IPGRE;
+	dev->flags		= IFF_NOARP;
+	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
+	dev->addr_len		= 4;
+
+	iph = &tunnel->parms.iph;
+	if (iph->daddr) {
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+		if (ipv4_is_multicast(iph->daddr)) {
+			if (!iph->saddr)
+				return -EINVAL;
+			dev->flags = IFF_BROADCAST;
+			dev->header_ops = &ipgre_header_ops;
+		}
+#endif
+	} else
+		dev->header_ops = &ipgre_header_ops;
+
+
+	return ip_tunnel_init(dev);
+}
+
+static int ipgre_tap_init(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	__gre_tunnel_init(dev);
+
+	if (!(tunnel->parms.o_flags & TUNNEL_SEQ)) {
+		dev->features    |= NETIF_F_GSO_SOFTWARE;
+		dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+	}
+
+	return ip_tunnel_init(dev);
+}
+
+static const struct net_device_ops ipgre_tap_netdev_ops;
+static inline void ipgre_tap_tunnel_setup(struct net_device *dev)
+{
+	ether_setup(dev);
+	dev->netdev_ops = &ipgre_tap_netdev_ops;
+	ip_tunnel_setup(dev, ipgre_tap_net_id);
+}
+
+static const struct net_device_ops ipgre_netdev_ops;
+static inline void ipgre_tunnel_setup(struct net_device *dev)
+{
+	dev->netdev_ops = &ipgre_netdev_ops;
+	ip_tunnel_setup(dev, ipgre_net_id);
+}
+
 static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
 	.kind		= "gre",
 	.maxtype	= IFLA_GRE_MAX,
@@ -1759,8 +653,9 @@ static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
 	.priv_size	= sizeof(struct ip_tunnel),
 	.setup		= ipgre_tunnel_setup,
 	.validate	= ipgre_tunnel_validate,
-	.newlink	= ipgre_newlink,
-	.changelink	= ipgre_changelink,
+	.newlink	= ip_tunnel_newlink,
+	.changelink	= ip_tunnel_changelink,
+	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
 };
@@ -1770,17 +665,93 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.maxtype	= IFLA_GRE_MAX,
 	.policy		= ipgre_policy,
 	.priv_size	= sizeof(struct ip_tunnel),
-	.setup		= ipgre_tap_setup,
+	.setup		= ipgre_tap_tunnel_setup,
 	.validate	= ipgre_tap_validate,
-	.newlink	= ipgre_newlink,
-	.changelink	= ipgre_changelink,
+	.newlink	= ip_tunnel_newlink,
+	.changelink	= ip_tunnel_changelink,
+	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
 };
 
-/*
- *	And now the modules code and kernel interface.
- */
+static const struct net_device_ops ipgre_netdev_ops = {
+	.ndo_init		= ipgre_tunnel_init,
+	.ndo_uninit		= ip_tunnel_uninit,
+	.ndo_start_xmit		= ipgre_tunnel_xmit,
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+	.ndo_open		= ipgre_open,
+	.ndo_stop		= ipgre_close,
+#endif
+	.ndo_do_ioctl		= ipgre_tunnel_ioctl,
+	.ndo_change_mtu		= ip_tunnel_change_mtu,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
+};
+
+static const struct net_device_ops ipgre_tap_netdev_ops = {
+	.ndo_init		= ipgre_tap_init,
+	.ndo_uninit		= ip_tunnel_uninit,
+	.ndo_start_xmit		= ipgre_tunnel_xmit,
+	.ndo_set_mac_address	= eth_mac_addr,
+	.ndo_validate_addr	= eth_validate_addr,
+	.ndo_change_mtu		= ip_tunnel_change_mtu,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
+};
+
+static const struct ip_tunnel_ops ipgre_tunnel_ops = {
+	.parse_netlink_parms = ipgre_netlink_parms,
+};
+
+static int __net_init ipgre_init_net(struct net *net)
+{
+	struct ip_tunnel_net *itn = net_generic(net, ipgre_net_id);
+
+	itn->ops = &ipgre_tunnel_ops;
+	return ip_tunnel_init_net(net, ipgre_net_id, &ipgre_link_ops, NULL);
+}
+
+static void __net_exit ipgre_exit_net(struct net *net)
+{
+	struct ip_tunnel_net *itn = net_generic(net, ipgre_net_id);
+	ip_tunnel_delete_net(itn);
+}
+
+static struct pernet_operations ipgre_net_ops = {
+	.init = ipgre_init_net,
+	.exit = ipgre_exit_net,
+	.id   = &ipgre_net_id,
+	.size = sizeof(struct ip_tunnel_net),
+};
+
+static const struct ip_tunnel_ops ipgre_tap_tunnel_ops = {
+	.parse_netlink_parms = ipgre_netlink_parms,
+};
+
+static int __net_init ipgre_tap_init_net(struct net *net)
+{
+	struct ip_tunnel_net *itn = net_generic(net, ipgre_tap_net_id);
+
+	itn->ops = &ipgre_tap_tunnel_ops;
+	return ip_tunnel_init_net(net, ipgre_tap_net_id, &ipgre_tap_ops, NULL);
+}
+
+static void __net_exit ipgre_tap_exit_net(struct net *net)
+{
+	struct ip_tunnel_net *itn = net_generic(net, ipgre_tap_net_id);
+	ip_tunnel_delete_net(itn);
+}
+
+static struct pernet_operations ipgre_tap_net_ops = {
+	.init = ipgre_tap_init_net,
+	.exit = ipgre_tap_exit_net,
+	.id   = &ipgre_tap_net_id,
+	.size = sizeof(struct ip_tunnel_net),
+};
+
+static struct gre_ip_protocol ipgre_protocol = {
+	.handler	= ipgre_rcv,
+	.err_handler	= ipgre_err,
+	.priority	= 0,
+};
 
 static int __init ipgre_init(void)
 {
@@ -1792,8 +763,12 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		return err;
 
+	err = register_pernet_device(&ipgre_tap_net_ops);
+	if (err < 0)
+		goto pnet_tap_faied;
+
 	rtnl_lock();
-	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
+	err = gre_ip_register(&ipgre_protocol);
 	rtnl_unlock();
 	if (err < 0) {
 		pr_info("%s: can't add protocol\n", __func__);
@@ -1808,16 +783,17 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto tap_ops_failed;
 
-out:
-	return err;
+	return 0;
 
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
-	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
+	gre_ip_unregister(&ipgre_protocol);
 add_proto_failed:
+	unregister_pernet_device(&ipgre_tap_net_ops);
+pnet_tap_faied:
 	unregister_pernet_device(&ipgre_net_ops);
-	goto out;
+	return err;
 }
 
 static void __exit ipgre_fini(void)
@@ -1825,9 +801,9 @@ static void __exit ipgre_fini(void)
 	rtnl_link_unregister(&ipgre_tap_ops);
 	rtnl_link_unregister(&ipgre_link_ops);
 	rtnl_lock();
-	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
-		pr_info("%s: can't remove protocol\n", __func__);
+	gre_ip_unregister(&ipgre_protocol);
 	rtnl_unlock();
+	unregister_pernet_device(&ipgre_tap_net_ops);
 	unregister_pernet_device(&ipgre_net_ops);
 }
 
@@ -1837,3 +813,4 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK("gre");
 MODULE_ALIAS_RTNL_LINK("gretap");
 MODULE_ALIAS_NETDEV("gre0");
+MODULE_ALIAS_NETDEV("gretap0");
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
new file mode 100644
index 0000000..5e0e46e
--- /dev/null
+++ b/net/ipv4/ip_tunnel.c
@@ -0,0 +1,1063 @@
+/*
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ *
+ */
+
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
+
+#include <linux/capability.h>
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/uaccess.h>
+#include <linux/skbuff.h>
+#include <linux/netdevice.h>
+#include <linux/in.h>
+#include <linux/tcp.h>
+#include <linux/udp.h>
+#include <linux/if_arp.h>
+#include <linux/mroute.h>
+#include <linux/init.h>
+#include <linux/in6.h>
+#include <linux/inetdevice.h>
+#include <linux/igmp.h>
+#include <linux/netfilter_ipv4.h>
+#include <linux/etherdevice.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+
+#include <net/sock.h>
+#include <net/ip.h>
+#include <net/icmp.h>
+#include <net/protocol.h>
+#include <net/ip_tunnel.h>
+#include <net/arp.h>
+#include <net/checksum.h>
+#include <net/dsfield.h>
+#include <net/inet_ecn.h>
+#include <net/xfrm.h>
+#include <net/net_namespace.h>
+#include <net/netns/generic.h>
+#include <net/rtnetlink.h>
+
+#if IS_ENABLED(CONFIG_IPV6)
+#include <net/ipv6.h>
+#include <net/ip6_fib.h>
+#include <net/ip6_route.h>
+#endif
+
+static unsigned int ip_tunnel_hash(struct ip_tunnel_net *itn,
+				   __be32 key, __be32 remote)
+{
+	return hash_32((__force u32)key ^ (__force u32)remote,
+			 IP_TNL_HASH_BITS);
+}
+
+/* often modified stats are per cpu, other are shared (netdev->stats) */
+struct rtnl_link_stats64 *ip_tunnel_get_stats64(struct net_device *dev,
+					   struct rtnl_link_stats64 *tot)
+{
+	int i;
+
+	for_each_possible_cpu(i) {
+		const struct pcpu_tstats *tstats = per_cpu_ptr(dev->tstats, i);
+		u64 rx_packets, rx_bytes, tx_packets, tx_bytes;
+		unsigned int start;
+
+		do {
+			start = u64_stats_fetch_begin_bh(&tstats->syncp);
+			rx_packets = tstats->rx_packets;
+			tx_packets = tstats->tx_packets;
+			rx_bytes = tstats->rx_bytes;
+			tx_bytes = tstats->tx_bytes;
+		} while (u64_stats_fetch_retry_bh(&tstats->syncp, start));
+
+		tot->rx_packets += rx_packets;
+		tot->tx_packets += tx_packets;
+		tot->rx_bytes   += rx_bytes;
+		tot->tx_bytes   += tx_bytes;
+	}
+
+	tot->multicast = dev->stats.multicast;
+
+	tot->rx_crc_errors = dev->stats.rx_crc_errors;
+	tot->rx_fifo_errors = dev->stats.rx_fifo_errors;
+	tot->rx_length_errors = dev->stats.rx_length_errors;
+	tot->rx_frame_errors = dev->stats.rx_frame_errors;
+	tot->rx_errors = dev->stats.rx_errors;
+
+	tot->tx_fifo_errors = dev->stats.tx_fifo_errors;
+	tot->tx_carrier_errors = dev->stats.tx_carrier_errors;
+	tot->tx_dropped = dev->stats.tx_dropped;
+	tot->tx_aborted_errors = dev->stats.tx_aborted_errors;
+	tot->tx_errors = dev->stats.tx_errors;
+
+	tot->collisions  = dev->stats.collisions;
+
+	return tot;
+}
+EXPORT_SYMBOL(ip_tunnel_get_stats64);
+
+static bool ip_tunnel_key_match(const struct ip_tunnel_parm *p,
+				__be16 flags, __be32 key)
+{
+	if (p->i_flags & TUNNEL_KEY) {
+		if (flags & TUNNEL_KEY)
+			return key == p->i_key;
+		else
+			/* key expected, none present */
+			return false;
+	} else
+		return !(flags & TUNNEL_KEY);
+}
+
+/* Fallback tunnel: no source, no destination, no key, no options
+
+   Tunnel hash table:
+   We require exact key match i.e. if a key is present in packet
+   it will match only tunnel with the same key; if it is not present,
+   it will match only keyless tunnel.
+
+   All keysless packets, if not matched configured keyless tunnels
+   will match fallback tunnel.
+   Given src, dst and key, find appropriate for input tunnel. */
+
+struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
+				    int link, __be16 flags,
+				    __be32 remote, __be32 local,
+				    __be32 key)
+{
+	unsigned int hash;
+	struct ip_tunnel *t, *cand = NULL;
+	struct hlist_node *node;
+	struct hlist_head *head;
+
+	hash = ip_tunnel_hash(itn, key, remote);
+	head = &itn->tunnels[hash];
+
+	hlist_for_each_entry_rcu(t, node, head, hash_node) {
+		if (local != t->parms.iph.saddr ||
+		    remote != t->parms.iph.daddr ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (!ip_tunnel_key_match(&t->parms, flags, key))
+			continue;
+
+		if (t->parms.link == link)
+			return t;
+		else
+			cand = t;
+	}
+
+	hlist_for_each_entry_rcu(t, node, head, hash_node) {
+		if (remote != t->parms.iph.daddr ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (!ip_tunnel_key_match(&t->parms, flags, key))
+			continue;
+
+		if (t->parms.link == link)
+			return t;
+		else if (!cand)
+			cand = t;
+	}
+
+	hash = ip_tunnel_hash(itn, key, 0);
+	head = &itn->tunnels[hash];
+
+	hlist_for_each_entry_rcu(t, node, head, hash_node) {
+		if ((local != t->parms.iph.saddr &&
+		     (local != t->parms.iph.daddr ||
+		      !ipv4_is_multicast(local))) ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (!ip_tunnel_key_match(&t->parms, flags, key))
+			continue;
+
+		if (t->parms.link == link)
+			return t;
+		else if (!cand)
+			cand = t;
+	}
+
+	hlist_for_each_entry_rcu(t, node, head, hash_node) {
+		if (t->parms.i_key != key ||
+		    !(t->dev->flags & IFF_UP))
+			continue;
+
+		if (t->parms.link == link)
+			return t;
+		else if (!cand)
+			cand = t;
+	}
+
+	if (cand)
+		return cand;
+
+	if (itn->fb_tunnel_dev && itn->fb_tunnel_dev->flags & IFF_UP)
+		return netdev_priv(itn->fb_tunnel_dev);
+
+
+	return NULL;
+}
+EXPORT_SYMBOL(ip_tunnel_lookup);
+
+static struct hlist_head *ip_bucket(struct ip_tunnel_net *itn,
+					  struct ip_tunnel_parm *parms)
+{
+	unsigned int h;
+	__be32 remote;
+
+	if (parms->iph.daddr && !ipv4_is_multicast(parms->iph.daddr))
+		remote = parms->iph.daddr;
+	else
+		remote = 0;
+
+	h = ip_tunnel_hash(itn, parms->i_key, remote);
+	return &itn->tunnels[h];
+}
+
+static void ip_tunnel_add(struct ip_tunnel_net *itn, struct ip_tunnel *t)
+{
+	struct hlist_head *head = ip_bucket(itn, &t->parms);
+
+	hlist_add_head_rcu(&t->hash_node, head);
+}
+
+static void ip_tunnel_del(struct ip_tunnel_net *itn, struct ip_tunnel *t)
+{
+	hlist_del_init_rcu(&t->hash_node);
+}
+
+static struct ip_tunnel *ip_tunnel_find(struct ip_tunnel_net *itn,
+				 struct ip_tunnel_parm *parms,
+				 int type)
+{
+	__be32 remote = parms->iph.daddr;
+	__be32 local = parms->iph.saddr;
+	__be32 key = parms->i_key;
+	int link = parms->link;
+	struct ip_tunnel *t = NULL;
+	struct hlist_node *node;
+	struct hlist_head *head = ip_bucket(itn, parms);
+
+	hlist_for_each_entry_rcu(t, node, head, hash_node) {
+		if (local == t->parms.iph.saddr &&
+		    remote == t->parms.iph.daddr &&
+		    key == t->parms.i_key &&
+		    link == t->parms.link &&
+		    type == t->dev->type)
+			break;
+	}
+	return t;
+}
+
+static struct net_device *__ip_tunnel_create(struct net *net,
+					  const struct rtnl_link_ops *ops,
+					  struct ip_tunnel_parm *parms)
+{
+	int err;
+	struct ip_tunnel *tunnel;
+	struct net_device *dev;
+	char name[IFNAMSIZ];
+
+	if (parms->name[0])
+		strlcpy(name, parms->name, IFNAMSIZ);
+	else {
+		if (strlen(ops->kind) + 3 >= IFNAMSIZ) {
+			err = -E2BIG;
+			goto failed;
+		}
+		strlcpy(name, ops->kind, IFNAMSIZ);
+		strncat(name, "%d", 2);
+	}
+
+	ASSERT_RTNL();
+	dev = alloc_netdev(ops->priv_size, name, ops->setup);
+	if (!dev) {
+		err = -ENOMEM;
+		goto failed;
+	}
+	dev_net_set(dev, net);
+
+	dev->rtnl_link_ops = ops;
+
+	tunnel = netdev_priv(dev);
+	tunnel->parms = *parms;
+
+	err = register_netdevice(dev);
+	if (err)
+		goto failed_free;
+
+	return dev;
+
+failed_free:
+	free_netdev(dev);
+failed:
+	return ERR_PTR(err);
+}
+
+static inline struct rtable *ip_route_output_tunnel(struct net *net,
+						  struct flowi4 *fl4,
+						  int proto,
+						  __be32 daddr, __be32 saddr,
+						  __be32 key, __u8 tos, int oif)
+{
+	memset(fl4, 0, sizeof(*fl4));
+	fl4->flowi4_oif = oif;
+	fl4->daddr = daddr;
+	fl4->saddr = saddr;
+	fl4->flowi4_tos = tos;
+	fl4->flowi4_proto = proto;
+	fl4->fl4_gre_key = key;
+	return ip_route_output_key(net, fl4);
+}
+
+static int ip_tunnel_bind_dev(struct net_device *dev)
+{
+	struct net_device *tdev = NULL;
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	const struct iphdr *iph;
+	int hlen = LL_MAX_HEADER;
+	int mtu = ETH_DATA_LEN;
+	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
+
+	iph = &tunnel->parms.iph;
+
+	/* Guess output device to choose reasonable mtu and needed_headroom */
+	if (iph->daddr) {
+		struct flowi4 fl4;
+		struct rtable *rt;
+
+		rt = ip_route_output_tunnel(dev_net(dev), &fl4,
+					 tunnel->parms.iph.protocol,
+					 iph->daddr, iph->saddr,
+					 tunnel->parms.o_key,
+					 RT_TOS(iph->tos),
+					 tunnel->parms.link);
+		if (!IS_ERR(rt)) {
+			tdev = rt->dst.dev;
+			ip_rt_put(rt);
+		}
+
+	}
+
+	if (!tdev && tunnel->parms.link)
+		tdev = __dev_get_by_index(dev_net(dev), tunnel->parms.link);
+
+	if (tdev) {
+		hlen = tdev->hard_header_len + tdev->needed_headroom;
+		mtu = tdev->mtu;
+	}
+	dev->iflink = tunnel->parms.link;
+
+	dev->needed_headroom = t_hlen + hlen;
+	mtu -= (dev->hard_header_len + t_hlen);
+
+	if (mtu < 68)
+		mtu = 68;
+
+	return mtu;
+}
+
+static struct ip_tunnel *ip_tunnel_create(struct net *net,
+					  struct ip_tunnel_net *itn,
+					  struct ip_tunnel_parm *parms)
+{
+	struct ip_tunnel *nt, *fbt;
+	struct net_device *dev;
+
+	BUG_ON(!itn->fb_tunnel_dev);
+	fbt = netdev_priv(itn->fb_tunnel_dev);
+	dev = __ip_tunnel_create(net, itn->fb_tunnel_dev->rtnl_link_ops, parms);
+	if (IS_ERR(dev))
+		return NULL;
+
+	dev->mtu = ip_tunnel_bind_dev(dev);
+
+	nt = netdev_priv(dev);
+	ip_tunnel_add(itn, nt);
+	return nt;
+}
+
+int ip_tunnel_rcv(struct ip_tunnel *tunnel, struct sk_buff *skb,
+		  const struct tnl_ptk_info *tpi, bool log_ecn_error)
+{
+	int err;
+
+	struct pcpu_tstats *tstats;
+	const struct iphdr *iph = ip_hdr(skb);
+
+	secpath_reset(skb);
+
+	skb->protocol = tpi->proto;
+
+	skb->mac_header = skb->network_header;
+	skb->pkt_type = PACKET_HOST;
+
+	__pskb_pull(skb, tunnel->hlen);
+	skb_postpull_rcsum(skb, skb_transport_header(skb), tunnel->hlen);
+#ifdef CONFIG_NET_IPGRE_BROADCAST
+	if (ipv4_is_multicast(iph->daddr)) {
+		/* Looped back packet, drop it! */
+		if (rt_is_output_route(skb_rtable(skb)))
+			goto drop;
+		tunnel->dev->stats.multicast++;
+		skb->pkt_type = PACKET_BROADCAST;
+	}
+#endif
+
+	if ((!(tpi->flags&TUNNEL_CSUM) && tunnel->parms.i_flags&TUNNEL_CSUM)) {
+		tunnel->dev->stats.rx_crc_errors++;
+		tunnel->dev->stats.rx_errors++;
+		goto drop;
+	}
+
+	if (tunnel->parms.i_flags&TUNNEL_SEQ) {
+		if (!(tpi->flags&TUNNEL_SEQ) ||
+		    (tunnel->i_seqno && (s32)(ntohl(tpi->seq) - tunnel->i_seqno) < 0)) {
+			tunnel->dev->stats.rx_fifo_errors++;
+			tunnel->dev->stats.rx_errors++;
+			goto drop;
+		}
+		tunnel->i_seqno = ntohl(tpi->seq) + 1;
+	}
+
+	/* Warning: All skb pointers will be invalidated! */
+	if (tunnel->dev->type == ARPHRD_ETHER) {
+		if (!pskb_may_pull(skb, ETH_HLEN)) {
+			tunnel->dev->stats.rx_length_errors++;
+			tunnel->dev->stats.rx_errors++;
+			goto drop;
+		}
+
+		iph = ip_hdr(skb);
+		skb->protocol = eth_type_trans(skb, tunnel->dev);
+		skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
+	}
+
+	__skb_tunnel_rx(skb, tunnel->dev);
+
+	skb_reset_network_header(skb);
+	err = IP_ECN_decapsulate(iph, skb);
+	if (unlikely(err)) {
+		if (log_ecn_error)
+			net_info_ratelimited("non-ECT from %pI4 with TOS=%#x\n",
+					&iph->saddr, iph->tos);
+		if (err > 1) {
+			++tunnel->dev->stats.rx_frame_errors;
+			++tunnel->dev->stats.rx_errors;
+			goto drop;
+		}
+	}
+
+	tstats = this_cpu_ptr(tunnel->dev->tstats);
+	u64_stats_update_begin(&tstats->syncp);
+	tstats->rx_packets++;
+	tstats->rx_bytes += skb->len;
+	u64_stats_update_end(&tstats->syncp);
+
+	gro_cells_receive(&tunnel->gro_cells, skb);
+
+	return 0;
+
+drop:
+	kfree_skb(skb);
+	return 0;
+}
+EXPORT_SYMBOL(ip_tunnel_rcv);
+
+static void build_ip_header(struct iphdr  *iph, struct flowi4 *fl4, int proto,
+			    __be16 df, u8 tos, u8 ttl)
+{
+	iph->version		=	4;
+	iph->ihl		=	sizeof(struct iphdr) >> 2;
+	iph->frag_off		=	df;
+	iph->protocol		=	proto;
+	iph->tos		=	tos;
+	iph->daddr		=	fl4->daddr;
+	iph->saddr		=	fl4->saddr;
+	iph->ttl		=	ttl;
+}
+
+int ip_tunnel_build_iphdr(struct sk_buff *skb, struct net_device *dev,
+			   const struct iphdr *tiph, int hlen,
+			   struct iphdr  *niph)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	const struct iphdr  *old_iph = ip_hdr(skb);
+	struct flowi4 fl4;
+	u8     tos, ttl;
+	__be16 df;
+	struct rtable *rt;		/* Route to the other host */
+	struct net_device *tdev;	/* Device to other host */
+	unsigned int max_headroom;	/* The extra header space needed */
+	__be32 dst;
+	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
+
+	if (dev->type == ARPHRD_ETHER)
+		IPCB(skb)->flags = 0;
+
+	dst = tiph->daddr;
+	if (dst == 0) {
+		/* NBMA tunnel */
+
+		if (skb_dst(skb) == NULL) {
+			dev->stats.tx_fifo_errors++;
+			goto tx_error;
+		}
+
+		if (skb->protocol == htons(ETH_P_IP)) {
+			rt = skb_rtable(skb);
+			dst = rt_nexthop(rt, old_iph->daddr);
+		}
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (skb->protocol == htons(ETH_P_IPV6)) {
+			const struct in6_addr *addr6;
+			struct neighbour *neigh;
+			bool do_tx_error_icmp;
+			int addr_type;
+
+			neigh = dst_neigh_lookup(skb_dst(skb),
+						 &ipv6_hdr(skb)->daddr);
+			if (neigh == NULL)
+				goto tx_error;
+
+			addr6 = (const struct in6_addr *)&neigh->primary_key;
+			addr_type = ipv6_addr_type(addr6);
+
+			if (addr_type == IPV6_ADDR_ANY) {
+				addr6 = &ipv6_hdr(skb)->daddr;
+				addr_type = ipv6_addr_type(addr6);
+			}
+
+			if ((addr_type & IPV6_ADDR_COMPATv4) == 0)
+				do_tx_error_icmp = true;
+			else {
+				do_tx_error_icmp = false;
+				dst = addr6->s6_addr32[3];
+			}
+			neigh_release(neigh);
+			if (do_tx_error_icmp)
+				goto tx_error_icmp;
+		}
+#endif
+		else
+			goto tx_error;
+	}
+
+	tos = tiph->tos;
+	if (tos == 1) {
+		tos = 0;
+		if (skb->protocol == htons(ETH_P_IP))
+			tos = old_iph->tos;
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			tos = ipv6_get_dsfield((const struct ipv6hdr *)old_iph);
+	}
+
+	rt = ip_route_output_tunnel(dev_net(dev), &fl4,
+				    tunnel->parms.iph.protocol,
+				    dst, tiph->saddr,
+				    tunnel->parms.o_key, RT_TOS(tos),
+				    tunnel->parms.link);
+	if (IS_ERR(rt)) {
+		dev->stats.tx_carrier_errors++;
+		goto tx_error;
+	}
+	tdev = rt->dst.dev;
+
+	if (tdev == dev) {
+		ip_rt_put(rt);
+		dev->stats.collisions++;
+		goto tx_error;
+	}
+
+	df = tiph->frag_off;
+	if (dev->type != ARPHRD_ETHER) {
+		int mtu;
+
+		if (df)
+			mtu = dst_mtu(&rt->dst) - dev->hard_header_len - t_hlen;
+		else
+			mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
+
+		if (skb_dst(skb))
+			skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
+
+		if (skb->protocol == htons(ETH_P_IP)) {
+			df |= (old_iph->frag_off&htons(IP_DF));
+
+			if ((old_iph->frag_off&htons(IP_DF)) &&
+					mtu < ntohs(old_iph->tot_len)) {
+				icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
+				ip_rt_put(rt);
+				goto tx_error;
+			}
+		}
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (skb->protocol == htons(ETH_P_IPV6)) {
+			struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
+
+			if (rt6 && mtu < dst_mtu(skb_dst(skb)) &&
+				   mtu >= IPV6_MIN_MTU) {
+				if ((tunnel->parms.iph.daddr &&
+				!ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
+				rt6->rt6i_dst.plen == 128) {
+					rt6->rt6i_flags |= RTF_MODIFIED;
+					dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
+				}
+			}
+
+			if (mtu >= IPV6_MIN_MTU &&
+			    mtu < skb->len - t_hlen + hlen) {
+				icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+				ip_rt_put(rt);
+				goto tx_error;
+			}
+		}
+#endif
+	}
+
+	if (tunnel->err_count > 0) {
+		if (time_before(jiffies,
+				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
+			tunnel->err_count--;
+
+			dst_link_failure(skb);
+		} else
+			tunnel->err_count = 0;
+	}
+
+	tos = ip_tunnel_ecn_encap(tos, old_iph, skb);
+
+	ttl = tiph->ttl;
+	if (ttl == 0) {
+		if (skb->protocol == htons(ETH_P_IP))
+			ttl = old_iph->ttl;
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			ttl = ((const struct ipv6hdr *)old_iph)->hop_limit;
+#endif
+		else
+			ttl = ip4_dst_hoplimit(&rt->dst);
+	}
+
+	max_headroom = LL_RESERVED_SPACE(tdev) + hlen + rt->dst.header_len;
+	if (max_headroom > dev->needed_headroom) {
+		dev->needed_headroom = max_headroom;
+		if (skb_cow_head(skb, dev->needed_headroom)) {
+			dev->stats.tx_dropped++;
+			dev_kfree_skb(skb);
+			return NETDEV_TX_OK;
+		}
+	}
+
+	/* Push down and install the IP header. */
+	build_ip_header(niph, &fl4, tunnel->parms.iph.protocol, df, tos, ttl);
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
+	return 0;
+
+#if IS_ENABLED(CONFIG_IPV6)
+tx_error_icmp:
+	dst_link_failure(skb);
+#endif
+tx_error:
+	dev->stats.tx_errors++;
+	dev_kfree_skb(skb);
+	return -1;
+}
+EXPORT_SYMBOL(ip_tunnel_build_iphdr);
+
+void ip_tunnel_xmit_stats(struct sk_buff *skb, struct net_device *dev, int err)
+{
+	if (likely(net_xmit_eval(err) == 0)) {
+		struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
+		int pkt_len = skb->len - skb_transport_offset(skb);
+
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes += pkt_len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
+	}
+}
+EXPORT_SYMBOL(ip_tunnel_xmit_stats);
+
+int ip_tunnel_ioctl(struct net_device *dev, struct ip_tunnel_parm *p, int cmd)
+{
+	int err = 0;
+	struct ip_tunnel *t;
+	struct net *net = dev_net(dev);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_net *itn = net_generic(net, tunnel->ip_tnl_net_id);
+
+	BUG_ON(!itn->fb_tunnel_dev);
+	switch (cmd) {
+	case SIOCGETTUNNEL:
+		t = NULL;
+		if (dev == itn->fb_tunnel_dev)
+			t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
+		if (t == NULL)
+			t = netdev_priv(dev);
+		memcpy(p, &t->parms, sizeof(*p));
+		break;
+
+	case SIOCADDTUNNEL:
+	case SIOCCHGTUNNEL:
+		err = -EPERM;
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+			goto done;
+		if (p->iph.ttl)
+			p->iph.frag_off |= htons(IP_DF);
+		if (!(p->i_flags&TUNNEL_KEY))
+			p->i_key = 0;
+		if (!(p->o_flags&TUNNEL_KEY))
+			p->o_key = 0;
+
+		t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
+
+		if (!t && (cmd == SIOCADDTUNNEL))
+			t = ip_tunnel_create(net, itn, p);
+
+		if (dev != itn->fb_tunnel_dev && cmd == SIOCCHGTUNNEL) {
+			if (t != NULL) {
+				if (t->dev != dev) {
+					err = -EEXIST;
+					break;
+				}
+			} else {
+				unsigned int nflags = 0;
+
+				if (ipv4_is_multicast(p->iph.daddr))
+					nflags = IFF_BROADCAST;
+				else if (p->iph.daddr)
+					nflags = IFF_POINTOPOINT;
+
+				if ((dev->flags^nflags)&(IFF_POINTOPOINT|IFF_BROADCAST)) {
+					err = -EINVAL;
+					break;
+				}
+
+				t = netdev_priv(dev);
+				ip_tunnel_del(itn, t);
+				synchronize_net();
+
+				t->parms.iph.saddr = p->iph.saddr;
+				t->parms.iph.daddr = p->iph.daddr;
+				t->parms.i_key = p->i_key;
+				t->parms.o_key = p->o_key;
+				memcpy(dev->dev_addr, &p->iph.saddr, 4);
+				memcpy(dev->broadcast, &p->iph.daddr, 4);
+				ip_tunnel_add(itn, t);
+				netdev_state_change(dev);
+			}
+		}
+
+		if (t) {
+			err = 0;
+			if (cmd == SIOCCHGTUNNEL) {
+				t->parms.iph.ttl = p->iph.ttl;
+				t->parms.iph.tos = p->iph.tos;
+				t->parms.iph.frag_off = p->iph.frag_off;
+				if (t->parms.link != p->link) {
+					t->parms.link = p->link;
+					dev->mtu = ip_tunnel_bind_dev(dev);
+					netdev_state_change(dev);
+				}
+			}
+		} else
+			err = (cmd == SIOCADDTUNNEL ? -ENOBUFS : -ENOENT);
+		break;
+
+	case SIOCDELTUNNEL:
+		err = -EPERM;
+		if (!ns_capable(net->user_ns, CAP_NET_ADMIN))
+			goto done;
+
+		if (dev == itn->fb_tunnel_dev) {
+			err = -ENOENT;
+			t = ip_tunnel_find(itn, p, itn->fb_tunnel_dev->type);
+			if (t == NULL)
+				goto done;
+			err = -EPERM;
+			if (t == netdev_priv(itn->fb_tunnel_dev))
+				goto done;
+			dev = t->dev;
+		}
+		unregister_netdevice(dev);
+		err = 0;
+		break;
+
+	default:
+		err = -EINVAL;
+	}
+
+done:
+	return err;
+}
+EXPORT_SYMBOL(ip_tunnel_ioctl);
+
+int ip_tunnel_change_mtu(struct net_device *dev, int new_mtu)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	int t_hlen = tunnel->hlen + sizeof(struct iphdr);
+
+	if (new_mtu < 68 ||
+	    new_mtu > 0xFFF8 - dev->hard_header_len - t_hlen)
+		return -EINVAL;
+	dev->mtu = new_mtu;
+	return 0;
+}
+EXPORT_SYMBOL(ip_tunnel_change_mtu);
+
+static void ip_tunnel_dev_free(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+
+	gro_cells_destroy(&tunnel->gro_cells);
+	free_percpu(dev->tstats);
+	free_netdev(dev);
+}
+
+void ip_tunnel_dellink(struct net_device *dev, struct list_head *head)
+{
+	struct net *net = dev_net(dev);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_net *itn;
+
+	itn = net_generic(net, tunnel->ip_tnl_net_id);
+
+	if (itn->fb_tunnel_dev != dev) {
+		ip_tunnel_del(itn, netdev_priv(dev));
+		unregister_netdevice_queue(dev, head);
+	}
+}
+EXPORT_SYMBOL(ip_tunnel_dellink);
+
+int __net_init ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
+				  struct rtnl_link_ops *ops, char *devname)
+{
+	struct ip_tunnel_net *itn = net_generic(net, ip_tnl_net_id);
+	struct ip_tunnel_parm parms;
+
+	itn->tunnels = kzalloc(IP_TNL_HASH_SIZE * sizeof(struct hlist_head), GFP_KERNEL);
+	if (!itn->tunnels)
+		return -ENOMEM;
+
+	if (!ops) {
+		itn->fb_tunnel_dev = NULL;
+		return 0;
+	}
+	memset(&parms, 0, sizeof(parms));
+	if (devname)
+		strlcpy(parms.name, devname, IFNAMSIZ);
+
+	rtnl_lock();
+	itn->fb_tunnel_dev = __ip_tunnel_create(net, ops, &parms);
+	rtnl_unlock();
+	if (IS_ERR(itn->fb_tunnel_dev)) {
+		kfree(itn->tunnels);
+		return PTR_ERR(itn->fb_tunnel_dev);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(ip_tunnel_init_net);
+
+static void ip_tunnel_destroy(struct ip_tunnel_net *itn, struct list_head *head)
+{
+	int h;
+
+	for (h = 0; h < IP_TNL_HASH_SIZE; h++) {
+		struct ip_tunnel *t;
+		struct hlist_node *node, *n;
+		struct hlist_head *thead = &itn->tunnels[h];
+
+		hlist_for_each_entry_safe(t, node, n, thead, hash_node)
+			unregister_netdevice_queue(t->dev, head);
+	}
+	if (itn->fb_tunnel_dev)
+		unregister_netdevice_queue(itn->fb_tunnel_dev, head);
+}
+
+void __net_exit ip_tunnel_delete_net(struct ip_tunnel_net *itn)
+{
+	LIST_HEAD(list);
+
+	rtnl_lock();
+	ip_tunnel_destroy(itn, &list);
+	unregister_netdevice_many(&list);
+	rtnl_unlock();
+	kfree(itn->tunnels);
+}
+EXPORT_SYMBOL(ip_tunnel_delete_net);
+
+int ip_tunnel_newlink(struct net *src_net, struct net_device *dev,
+			struct nlattr *tb[],
+			struct nlattr *data[])
+{
+	struct ip_tunnel *nt;
+	struct net *net = dev_net(dev);
+	struct ip_tunnel_net *itn;
+	int mtu;
+	int err;
+
+	nt = netdev_priv(dev);
+	itn = net_generic(net, nt->ip_tnl_net_id);
+	err = itn->ops->parse_netlink_parms(nt, data, tb, &nt->parms);
+	if (err)
+		return err;
+
+	if (ip_tunnel_find(itn, &nt->parms, dev->type))
+		return -EEXIST;
+
+	err = register_netdevice(dev);
+	if (err)
+		goto out;
+
+	if (dev->type == ARPHRD_ETHER && !tb[IFLA_ADDRESS])
+		eth_hw_addr_random(dev);
+
+	mtu = ip_tunnel_bind_dev(dev);
+	if (!tb[IFLA_MTU])
+		dev->mtu = mtu;
+
+	ip_tunnel_add(itn, nt);
+
+out:
+	return err;
+}
+EXPORT_SYMBOL(ip_tunnel_newlink);
+
+int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
+			    struct nlattr *data[])
+{
+	struct ip_tunnel *t, *nt;
+	struct net *net = dev_net(dev);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_net *itn = net_generic(net, tunnel->ip_tnl_net_id);
+
+	struct ip_tunnel_parm p;
+	int mtu;
+
+	if (dev == itn->fb_tunnel_dev)
+		return -EINVAL;
+
+	nt = netdev_priv(dev);
+	itn->ops->parse_netlink_parms(nt, data, tb, &p);
+
+	t = ip_tunnel_find(itn, &p, dev->type);
+
+	if (t) {
+		if (t->dev != dev)
+			return -EEXIST;
+	} else {
+		t = nt;
+
+		if (dev->type != ARPHRD_ETHER) {
+			unsigned int nflags = 0;
+
+			if (ipv4_is_multicast(p.iph.daddr))
+				nflags = IFF_BROADCAST;
+			else if (p.iph.daddr)
+				nflags = IFF_POINTOPOINT;
+
+			if ((dev->flags ^ nflags) &
+			    (IFF_POINTOPOINT | IFF_BROADCAST))
+				return -EINVAL;
+		}
+
+		ip_tunnel_del(itn, t);
+		t->parms.iph.saddr = p.iph.saddr;
+		t->parms.iph.daddr = p.iph.daddr;
+		t->parms.i_key = p.i_key;
+		if (dev->type != ARPHRD_ETHER) {
+			memcpy(dev->dev_addr, &p.iph.saddr, 4);
+			memcpy(dev->broadcast, &p.iph.daddr, 4);
+		}
+		ip_tunnel_add(itn, t);
+		netdev_state_change(dev);
+	}
+
+	t->parms.o_key = p.o_key;
+	t->parms.iph.ttl = p.iph.ttl;
+	t->parms.iph.tos = p.iph.tos;
+	t->parms.iph.frag_off = p.iph.frag_off;
+
+	if (t->parms.link != p.link) {
+		t->parms.link = p.link;
+		mtu = ip_tunnel_bind_dev(dev);
+		if (!tb[IFLA_MTU])
+			dev->mtu = mtu;
+		netdev_state_change(dev);
+	}
+
+	return 0;
+}
+EXPORT_SYMBOL(ip_tunnel_changelink);
+
+int ip_tunnel_init(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct iphdr *iph;
+	int err;
+
+	dev->destructor	= ip_tunnel_dev_free;
+	dev->tstats = alloc_percpu(struct pcpu_tstats);
+	if (!dev->tstats)
+		return -ENOMEM;
+
+	err = gro_cells_init(&tunnel->gro_cells, dev);
+	if (err) {
+		free_percpu(dev->tstats);
+		return err;
+	}
+
+	tunnel->dev = dev;
+	strcpy(tunnel->parms.name, dev->name);
+
+	iph = &tunnel->parms.iph;
+	iph->version		= 4;
+	iph->ihl		= 5;
+
+	/* Can use a lockless transmit, unless we generate output sequences */
+	if (!(tunnel->parms.o_flags & TUNNEL_SEQ))
+		dev->features |= NETIF_F_LLTX;
+
+	return 0;
+}
+EXPORT_SYMBOL(ip_tunnel_init);
+
+void ip_tunnel_uninit(struct net_device *dev)
+{
+	struct net *net = dev_net(dev);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_net *itn;
+
+	itn = net_generic(net, tunnel->ip_tnl_net_id);
+	/* fb_tunnel_dev will be unregisted in net-exit call. */
+	if (itn->fb_tunnel_dev != dev)
+		ip_tunnel_del(itn, netdev_priv(dev));
+}
+EXPORT_SYMBOL(ip_tunnel_uninit);
+
+void ip_tunnel_setup(struct net_device *dev, int net_id)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	tunnel->ip_tnl_net_id = net_id;
+}
+EXPORT_SYMBOL(ip_tunnel_setup);
+
+MODULE_LICENSE("GPL");
diff --git a/net/ipv4/ip_vti.c b/net/ipv4/ip_vti.c
index c3a4233..aab982e 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -38,7 +38,7 @@
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/icmp.h>
-#include <net/ipip.h>
+#include <net/ip_tunnel.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 191fc24..afff01a 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -111,7 +111,7 @@
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/icmp.h>
-#include <net/ipip.h>
+#include <net/ip_tunnel.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index a9454cb..0e0f80b 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -61,7 +61,7 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/compat.h>
 #include <linux/export.h>
-#include <net/ipip.h>
+#include <net/ip_tunnel.h>
 #include <net/checksum.h>
 #include <net/netlink.h>
 #include <net/fib_rules.h>
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index b043c60..9f0e09c 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -49,7 +49,6 @@
 #include <net/udp.h>
 #include <net/udplite.h>
 #include <net/tcp.h>
-#include <net/ipip.h>
 #include <net/protocol.h>
 #include <net/inet_common.h>
 #include <net/route.h>
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index c727e47..c9ddb98 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -38,6 +38,7 @@
 
 #include <net/sock.h>
 #include <net/ip.h>
+#include <net/ip_tunnel.h>
 #include <net/icmp.h>
 #include <net/protocol.h>
 #include <net/addrconf.h>
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index a14f28b..303679f 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -47,6 +47,7 @@
 
 #include <net/icmp.h>
 #include <net/ip.h>
+#include <net/ip_tunnel.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index cfba99b..0f7c7d6 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -49,7 +49,7 @@
 #include <net/ip.h>
 #include <net/udp.h>
 #include <net/icmp.h>
-#include <net/ipip.h>
+#include <net/ip_tunnel.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
 #include <net/dsfield.h>
-- 
1.7.1
