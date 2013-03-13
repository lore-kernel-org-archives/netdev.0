From: Pravin B Shelar <pshelar@nicira.com>
Subject: [PATCH net-next 2/6] GRE: Refactor GRE tunneling code.
Date: Wed, 13 Mar 2013 15:48:31 -0700
Message-ID: <1363214911-3289-1-git-send-email-pshelar@nicira.com>
Cc: netdev@vger.kernel.org, jesse@nicira.com,
	Pravin B Shelar <pshelar@nicira.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog113.obsmtp.com ([74.125.149.209]:52112 "HELO
	na3sys009aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S934310Ab3CMWtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Mar 2013 18:49:12 -0400
Received: by mail-pb0-f72.google.com with SMTP id wz12so2781288pbc.11
        for <netdev@vger.kernel.org>; Wed, 13 Mar 2013 15:49:12 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Following patch refactors GRE code into ip tunneling code and GRE
specific code. Common tunneling code is moved to ip_tunnel module.
ip_tunnel module is written as generic library which can be used
by different tunneling implementations.

ip_tunnel module contains following components:
 - packet xmit and rcv generic code. xmit flow looks like
   (gre_xmit/ipip_xmit)->ip_tunnel_xmit->ip_local_out.
 - hash table of all devices.
 - lookup for tunnel devices.
 - control plane operations like device create, destroy, ioctl, netlink
   operations code.
 - registration for tunneling modules, like gre, ipip etc.
 - define single pcpu_tstats dev->tstats.

ipip.h header is renamed to ip_tunnel.h

Signed-off-by: Pravin B Shelar <pshelar@nicira.com>
---
 drivers/net/vxlan.c      |    2 +-
 include/net/gre.h        |   51 ++
 include/net/ip_tunnels.h |  169 ++++++
 include/net/ipip.h       |   88 ---
 net/ipv4/Kconfig         |    5 +
 net/ipv4/Makefile        |    1 +
 net/ipv4/af_inet.c       |    1 -
 net/ipv4/gre.c           |    5 -
 net/ipv4/ip_gre.c        | 1490 ++++++++++------------------------------------
 net/ipv4/ip_tunnel.c     | 1036 ++++++++++++++++++++++++++++++++
 net/ipv4/ip_vti.c        |    2 +-
 net/ipv4/ipip.c          |    2 +-
 net/ipv4/ipmr.c          |    2 +-
 net/ipv6/af_inet6.c      |    1 -
 net/ipv6/ip6_gre.c       |    1 +
 net/ipv6/ip6_tunnel.c    |    1 +
 net/ipv6/sit.c           |    2 +-
 17 files changed, 1569 insertions(+), 1290 deletions(-)
 create mode 100644 include/net/ip_tunnels.h
 delete mode 100644 include/net/ipip.h
 create mode 100644 net/ipv4/ip_tunnel.c

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index db0df07..338d44e 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -33,7 +33,7 @@
 #include <net/arp.h>
 #include <net/ndisc.h>
 #include <net/ip.h>
-#include <net/ipip.h>
+#include <net/ip_tunnels.h>
 #include <net/icmp.h>
 #include <net/udp.h>
 #include <net/rtnetlink.h>
diff --git a/include/net/gre.h b/include/net/gre.h
index 8266547..9f03a39 100644
--- a/include/net/gre.h
+++ b/include/net/gre.h
@@ -2,6 +2,7 @@
 #define __LINUX_GRE_H
 
 #include <linux/skbuff.h>
+#include <net/ip_tunnels.h>
 
 #define GREPROTO_CISCO		0
 #define GREPROTO_PPTP		1
@@ -12,7 +13,57 @@ struct gre_protocol {
 	void (*err_handler)(struct sk_buff *skb, u32 info);
 };
 
+struct gre_base_hdr {
+	__be16 flags;
+	__be16 protocol;
+};
+#define GRE_HEADER_SECTION 4
+
 int gre_add_protocol(const struct gre_protocol *proto, u8 version);
 int gre_del_protocol(const struct gre_protocol *proto, u8 version);
 
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
+
 #endif
diff --git a/include/net/ip_tunnels.h b/include/net/ip_tunnels.h
new file mode 100644
index 0000000..324d08f
--- /dev/null
+++ b/include/net/ip_tunnels.h
@@ -0,0 +1,169 @@
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
+	int		err_count;	/* Number of arrived ICMP errors */
+	unsigned long	err_time;	/* Time when the last ICMP error
+					 * arrived */
+
+	/* These four fields used only by GRE */
+	__u32		i_seqno;	/* The last seen seqno	*/
+	__u32		o_seqno;	/* The last output seqno */
+	int		hlen;		/* Precalculated header length */
+	int		mlink;
+
+	struct ip_tunnel_parm parms;
+
+	/* for SIT */
+#ifdef CONFIG_IPV6_SIT_6RD
+	struct ip_tunnel_6rd_parm ip6rd;
+#endif
+	struct ip_tunnel_prl_entry __rcu *prl;	/* potential router list */
+	unsigned int		prl_count;	/* # of entries in PRL */
+	int			ip_tnl_net_id;
+	struct gro_cells	gro_cells;
+};
+
+#define TUNNEL_CSUM	__cpu_to_be16(0x01)
+#define TUNNEL_ROUTING	__cpu_to_be16(0x02)
+#define TUNNEL_KEY	__cpu_to_be16(0x04)
+#define TUNNEL_SEQ	__cpu_to_be16(0x08)
+#define TUNNEL_STRICT	__cpu_to_be16(0x10)
+#define TUNNEL_REC	__cpu_to_be16(0x20)
+#define TUNNEL_VERSION	__cpu_to_be16(0x40)
+#define TUNNEL_NO_KEY	__cpu_to_be16(0x80)
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
+#define PACKET_RCVD	0
+#define PACKET_REJECT	1
+
+#define IP_TNL_HASH_BITS   10
+#define IP_TNL_HASH_SIZE   (1 << IP_TNL_HASH_BITS)
+
+struct ip_tunnel_net {
+	struct hlist_head *tunnels;
+	struct net_device *fb_tunnel_dev;
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
+int ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
+			  const struct iphdr  *tnl_params);
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
+int ip_tunnel_changelink(struct net_device *dev, struct nlattr *tb[],
+			 struct ip_tunnel_parm *p);
+int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
+		      struct ip_tunnel_parm *p);
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
+static inline void tunnel_ip_select_ident(struct sk_buff *skb,
+					  const struct iphdr  *old_iph,
+					  struct dst_entry *dst)
+{
+	struct iphdr *iph = ip_hdr(skb);
+
+	if (iph->frag_off & htons(IP_DF))
+		iph->id	= 0;
+	else {
+		/* Use inner packet iph-id if possible. */
+		if (skb->protocol == htons(ETH_P_IP) && old_iph->id)
+			iph->id	= old_iph->id;
+		else
+			__ip_select_ident(iph, dst,
+					  (skb_shinfo(skb)->gso_segs ?: 1) - 1);
+	}
+}
+
+static inline void iptunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	int err;
+	int pkt_len = skb->len - skb_transport_offset(skb);
+	struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
+
+	nf_reset(skb);
+
+	err = ip_local_out(skb);
+	if (likely(net_xmit_eval(err) == 0)) {
+		u64_stats_update_begin(&tstats->syncp);
+		tstats->tx_bytes += pkt_len;
+		tstats->tx_packets++;
+		u64_stats_update_end(&tstats->syncp);
+	} else {
+		dev->stats.tx_errors++;
+		dev->stats.tx_aborted_errors++;
+	}
+}
+#endif /* __NET_IP_TUNNEL_H */
diff --git a/include/net/ipip.h b/include/net/ipip.h
deleted file mode 100644
index 0c046e3..0000000
--- a/include/net/ipip.h
+++ /dev/null
@@ -1,88 +0,0 @@
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
-	int pkt_len = skb->len - skb_transport_offset(skb);
-	struct pcpu_tstats *tstats = this_cpu_ptr(dev->tstats);
-
-	nf_reset(skb);
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
-static inline void tunnel_ip_select_ident(struct sk_buff *skb,
-					  const struct iphdr  *old_iph,
-					  struct dst_entry *dst)
-{
-	struct iphdr *iph = ip_hdr(skb);
-
-	if (iph->frag_off & htons(IP_DF))
-		iph->id	= 0;
-	else {
-		/* Use inner packet iph-id if possible. */
-		if (skb->protocol == htons(ETH_P_IP) && old_iph->id)
-			iph->id	= old_iph->id;
-		else
-			__ip_select_ident(iph, dst,
-					  (skb_shinfo(skb)->gso_segs ?: 1) - 1);
-	}
-}
-#endif
diff --git a/net/ipv4/Kconfig b/net/ipv4/Kconfig
index 7944df7..2073226 100644
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
index 9e5882c..a1fca33 100644
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
index fbaf33d..9d51d46 100644
--- a/net/ipv4/gre.c
+++ b/net/ipv4/gre.c
@@ -26,11 +26,6 @@
 
 
 static const struct gre_protocol __rcu *gre_proto[GREPROTO_MAX] __read_mostly;
-struct gre_base_hdr {
-	__be16 flags;
-	__be16 protocol;
-};
-#define GRE_HEADER_SECTION 4
 
 int gre_add_protocol(const struct gre_protocol *proto, u8 version)
 {
diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
index 99cf2b4..e40d7ba 100644
--- a/net/ipv4/ip_gre.c
+++ b/net/ipv4/ip_gre.c
@@ -37,7 +37,7 @@
 #include <net/ip.h>
 #include <net/icmp.h>
 #include <net/protocol.h>
-#include <net/ipip.h>
+#include <net/ip_tunnels.h>
 #include <net/arp.h>
 #include <net/checksum.h>
 #include <net/dsfield.h>
@@ -108,15 +108,6 @@
    fatal route to network, even if it were you who configured
    fatal static route: you are innocent. :-)
 
-
-
-   3. Really, ipv4/ipip.c, ipv4/ip_gre.c and ipv6/sit.c contain
-   practically identical code. It would be good to glue them
-   together, but it is not very evident, how to make them modular.
-   sit is integral part of IPv6, ipip and gre are naturally modular.
-   We could extract common parts (hash table, ioctl etc)
-   to a separate module (ip_tunnel.c).
-
    Alexey Kuznetsov.
  */
 
@@ -126,400 +117,129 @@ MODULE_PARM_DESC(log_ecn_error, "Log packets received with corrupted ECN");
 
 static struct rtnl_link_ops ipgre_link_ops __read_mostly;
 static int ipgre_tunnel_init(struct net_device *dev);
-static void ipgre_tunnel_setup(struct net_device *dev);
-static int ipgre_tunnel_bind_dev(struct net_device *dev);
-
-/* Fallback tunnel: no source, no destination, no key, no options */
-
-#define HASH_SIZE  16
 
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
+static int ipgre_tap_net_id __read_mostly;
 
-   All keysless packets, if not matched configured keyless tunnels
-   will match fallback tunnel.
- */
+static __sum16 check_checksum(struct sk_buff *skb)
+{
+	__sum16 csum = 0;
 
-#define HASH(addr) (((__force u32)addr^((__force u32)addr>>4))&0xF)
+	switch (skb->ip_summed) {
+	case CHECKSUM_COMPLETE:
+		csum = csum_fold(skb->csum);
 
-#define tunnels_r_l	tunnels[3]
-#define tunnels_r	tunnels[2]
-#define tunnels_l	tunnels[1]
-#define tunnels_wc	tunnels[0]
+		if (!csum)
+			break;
+		/* Fall through. */
 
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
+	case CHECKSUM_NONE:
+		skb->csum = 0;
+		csum = __skb_checksum_complete(skb);
+		skb->ip_summed = CHECKSUM_COMPLETE;
+		break;
 	}
 
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
+	return csum;
 }
 
-/* Does key in tunnel parameters match packet */
-static bool ipgre_key_match(const struct ip_tunnel_parm *p,
-			    __be16 flags, __be32 key)
+static int ip_gre_calc_hlen(__be16 o_flags)
 {
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
+	int addend = 4;
 
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
+	if (o_flags&TUNNEL_CSUM)
+		addend += 4;
+	if (o_flags&TUNNEL_KEY)
+		addend += 4;
+	if (o_flags&TUNNEL_SEQ)
+		addend += 4;
+	return addend;
 }
 
-static struct ip_tunnel __rcu **__ipgre_bucket(struct ipgre_net *ign,
-		struct ip_tunnel_parm *parms)
+static int parse_gre_header(struct sk_buff *skb, struct tnl_ptk_info *tpi,
+			    bool *csum_err, int *hdr_len)
 {
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
+	struct gre_base_hdr *greh = (struct gre_base_hdr *)skb->data;
+	__be32 *options = (__be32 *)(greh + 1);
 
-	return &ign->tunnels[prio][h];
-}
+	if (unlikely(greh->flags & (GRE_VERSION | GRE_ROUTING)))
+		return -EINVAL;
 
-static inline struct ip_tunnel __rcu **ipgre_bucket(struct ipgre_net *ign,
-		struct ip_tunnel *t)
-{
-	return __ipgre_bucket(ign, &t->parms);
-}
+	tpi->flags = gre_flags_to_tnl_flags(greh->flags);
+	*hdr_len = ip_gre_calc_hlen(tpi->flags);
 
-static void ipgre_tunnel_link(struct ipgre_net *ign, struct ip_tunnel *t)
-{
-	struct ip_tunnel __rcu **tp = ipgre_bucket(ign, t);
+	if (!pskb_may_pull(skb, *hdr_len))
+		return -EINVAL;
 
-	rcu_assign_pointer(t->next, rtnl_dereference(*tp));
-	rcu_assign_pointer(*tp, t);
-}
+	tpi->proto = greh->protocol;
 
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
+	if (greh->flags & GRE_CSUM) {
+		if (check_checksum(skb)) {
+			*csum_err = true;
+			return -EINVAL;
 		}
+		options++;
 	}
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
+	if (greh->flags & GRE_KEY) {
+		tpi->key = *options;
+		options++;
+	} else
+		tpi->key = 0;
 
-failed_free:
-	free_netdev(dev);
-	return NULL;
-}
+	if (unlikely(greh->flags & GRE_SEQ)) {
+		tpi->seq = *options;
+		options++;
+	} else
+		tpi->seq = 0;
 
-static void ipgre_tunnel_uninit(struct net_device *dev)
-{
-	struct net *net = dev_net(dev);
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
+	/* WCCP version 1 and 2 protocol decoding.
+	 * - Change protocol to IP
+	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
+	 */
+	if (greh->flags == 0 && tpi->proto == htons(ETH_P_WCCP)) {
+		tpi->proto = htons(ETH_P_IP);
+		if ((*(u8 *)options & 0xF0) != 0x40) {
+			*hdr_len += 4;
+			if (!pskb_may_pull(skb, *hdr_len))
+				return -EINVAL;
+		}
+	}
 
-	ipgre_tunnel_unlink(ign, netdev_priv(dev));
-	dev_put(dev);
+	return 0;
 }
 
-
 static void ipgre_err(struct sk_buff *skb, u32 info)
 {
 
-/* All the routers (except for Linux) return only
-   8 bytes of packet payload. It means, that precise relaying of
-   ICMP in the real Internet is absolutely infeasible.
-
-   Moreover, Cisco "wise men" put GRE key to the third word
-   in GRE header. It makes impossible maintaining even soft state for keyed
-   GRE tunnels with enabled checksum. Tell them "thank you".
+	/* All the routers (except for Linux) return only
+	   8 bytes of packet payload. It means, that precise relaying of
+	   ICMP in the real Internet is absolutely infeasible.
 
-   Well, I wonder, rfc1812 was written by Cisco employee,
-   what the hell these idiots break standards established
-   by themselves???
- */
+	   Moreover, Cisco "wise men" put GRE key to the third word
+	   in GRE header. It makes impossible maintaining even soft
+	   state for keyed GRE tunnels with enabled checksum. Tell
+	   them "thank you".
 
+	   Well, I wonder, rfc1812 was written by Cisco employee,
+	   what the hell these idiots break standards established
+	   by themselves???
+	   */
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
+	struct tnl_ptk_info tpi;
+	int hdr_len;
+	bool csum_err = false;
 
-	flags = p[0];
-	if (flags&(GRE_CSUM|GRE_KEY|GRE_SEQ|GRE_ROUTING|GRE_VERSION)) {
-		if (flags&(GRE_VERSION|GRE_ROUTING))
+	if (parse_gre_header(skb, &tpi, &csum_err, &hdr_len)) {
+		if (!csum_err)          /* ignore csum errors. */
 			return;
-		if (flags&GRE_KEY) {
-			grehlen += 4;
-			if (flags&GRE_CSUM)
-				grehlen += 4;
-		}
 	}
 
-	/* If only 8 bytes returned, keyed message will be dropped here */
-	if (skb_headlen(skb) < grehlen)
-		return;
-
-	if (flags & GRE_KEY)
-		key = *(((__be32 *)p) + (grehlen / 4) - 1);
-
 	switch (type) {
 	default:
 	case ICMP_PARAMETERPROB:
@@ -548,8 +268,13 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 		break;
 	}
 
-	t = ipgre_tunnel_lookup(skb->dev, iph->daddr, iph->saddr,
-				flags, key, p[1]);
+	if (tpi.proto == htons(ETH_P_TEB))
+		itn = net_generic(net, ipgre_tap_net_id);
+	else
+		itn = net_generic(net, ipgre_net_id);
+
+	t = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi.flags,
+			     iph->daddr, iph->saddr, tpi.key);
 
 	if (t == NULL)
 		return;
@@ -578,158 +303,33 @@ static void ipgre_err(struct sk_buff *skb, u32 info)
 	t->err_time = jiffies;
 }
 
-static inline u8
-ipgre_ecn_encapsulate(u8 tos, const struct iphdr *old_iph, struct sk_buff *skb)
-{
-	u8 inner = 0;
-	if (skb->protocol == htons(ETH_P_IP))
-		inner = old_iph->tos;
-	else if (skb->protocol == htons(ETH_P_IPV6))
-		inner = ipv6_get_dsfield((const struct ipv6hdr *)old_iph);
-	return INET_ECN_encapsulate(tos, inner);
-}
-
 static int ipgre_rcv(struct sk_buff *skb)
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
+	struct tnl_ptk_info tpi;
+	int hdr_len;
+	bool csum_err = false;
 
-	if (!pskb_may_pull(skb, 16))
+	if (parse_gre_header(skb, &tpi, &csum_err, &hdr_len) < 0)
 		goto drop;
 
-	iph = ip_hdr(skb);
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
+	if (tpi.proto == htons(ETH_P_TEB))
+		itn = net_generic(net, ipgre_tap_net_id);
+	else
+		itn = net_generic(net, ipgre_net_id);
 
-	gre_proto = *(__be16 *)(h + 2);
+	iph = ip_hdr(skb);
+	tunnel = ip_tunnel_lookup(itn, skb->dev->ifindex, tpi.flags,
+				  iph->saddr, iph->daddr, tpi.key);
 
-	tunnel = ipgre_tunnel_lookup(skb->dev,
-				     iph->saddr, iph->daddr, flags, key,
-				     gre_proto);
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
+		ip_tunnel_rcv(tunnel, skb, &tpi, log_ecn_error);
 		return 0;
 	}
 	icmp_send(skb, ICMP_DEST_UNREACH, ICMP_PORT_UNREACH, 0);
-
 drop:
 	kfree_skb(skb);
 	return 0;
@@ -746,7 +346,7 @@ static struct sk_buff *handle_offloads(struct ip_tunnel *tunnel, struct sk_buff
 		skb_shinfo(skb)->gso_type |= SKB_GSO_GRE;
 		return skb;
 	} else if (skb->ip_summed == CHECKSUM_PARTIAL &&
-		   tunnel->parms.o_flags&GRE_CSUM) {
+		   tunnel->parms.o_flags&TUNNEL_CSUM) {
 		err = skb_checksum_help(skb);
 		if (unlikely(err))
 			goto error;
@@ -760,483 +360,145 @@ error:
 	return ERR_PTR(err);
 }
 
-static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb, struct net_device *dev)
+static struct sk_buff *gre_build_header(struct sk_buff *skb,
+					const struct tnl_ptk_info *tpi,
+					int hdr_len)
 {
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-	const struct iphdr  *old_iph;
-	const struct iphdr  *tiph;
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
-	int    err;
-
-	skb = handle_offloads(tunnel, skb);
-	if (IS_ERR(skb)) {
-		dev->stats.tx_dropped++;
-		return NETDEV_TX_OK;
-	}
+	struct gre_base_hdr *greh;
 
-	if (!skb->encapsulation) {
-		skb_reset_inner_headers(skb);
-		skb->encapsulation = 1;
-	}
+	skb_push(skb, hdr_len);
 
-	old_iph = ip_hdr(skb);
+	greh = (struct gre_base_hdr *)skb->data;
+	greh->flags = tnl_flags_to_gre_flags(tpi->flags);
+	greh->protocol = tpi->proto;
 
-	if (dev->type == ARPHRD_ETHER)
-		IPCB(skb)->flags = 0;
+	if (tpi->flags&(TUNNEL_KEY|TUNNEL_CSUM|TUNNEL_SEQ)) {
+		__be32 *ptr = (__be32 *)(((u8 *)greh) + hdr_len - 4);
 
-	if (dev->header_ops && dev->type == ARPHRD_IPGRE) {
-		gre_hlen = 0;
-		if (skb->protocol == htons(ETH_P_IP))
-			tiph = (const struct iphdr *)skb->data;
-		else
-			tiph = &tunnel->parms.iph;
-	} else {
-		gre_hlen = tunnel->hlen;
-		tiph = &tunnel->parms.iph;
-	}
-
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
-	if (tos & 0x1) {
-		tos &= ~0x1;
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
-		if (!skb_is_gso(skb) &&
-		    (old_iph->frag_off&htons(IP_DF)) &&
-		    mtu < ntohs(old_iph->tot_len)) {
-			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
-			ip_rt_put(rt);
-			goto tx_error;
+		if (tpi->flags&TUNNEL_SEQ) {
+			*ptr = tpi->seq;
+			ptr--;
 		}
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
+		if (tpi->flags&TUNNEL_KEY) {
+			*ptr = tpi->key;
+			ptr--;
 		}
-
-		if (!skb_is_gso(skb) &&
-		    mtu >= IPV6_MIN_MTU &&
-		    mtu < skb->len - tunnel->hlen + gre_hlen) {
-			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
-			ip_rt_put(rt);
-			goto tx_error;
+		if (tpi->flags&TUNNEL_CSUM &&
+		    !(skb_shinfo(skb)->gso_type & SKB_GSO_GRE)) {
+			*(__sum16 *)ptr = 0;
+			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, 0,
+								 skb->len, 0));
 		}
 	}
-#endif
 
-	if (tunnel->err_count > 0) {
-		if (time_before(jiffies,
-				tunnel->err_time + IPTUNNEL_ERR_TIMEO)) {
-			tunnel->err_count--;
+	return skb;
+}
 
-			dst_link_failure(skb);
-		} else
-			tunnel->err_count = 0;
-	}
+static netdev_tx_t __gre_xmit(struct sk_buff *skb, struct net_device *dev,
+			      const struct iphdr *tnl_params,
+			       __be16 proto)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct tnl_ptk_info tpi;
 
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
+	if (!skb->encapsulation) {
+		skb_reset_inner_headers(skb);
+		skb->encapsulation = 1;
 	}
 
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
+	tpi.flags = tunnel->parms.o_flags;
+	tpi.proto = proto;
+	tpi.key = tunnel->parms.o_key;
+	if (tunnel->parms.o_flags & TUNNEL_SEQ)
+		tunnel->o_seqno++;
+	tpi.seq = htonl(tunnel->o_seqno);
 
-	tunnel_ip_select_ident(skb, old_iph, &rt->dst);
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
+	/* Need space for new headers (invalidates iph ptr) */
+	if (skb_cow_head(skb, dev->needed_headroom))
+		goto drop;
 
-	((__be16 *)(iph + 1))[0] = tunnel->parms.o_flags;
-	((__be16 *)(iph + 1))[1] = (dev->type == ARPHRD_ETHER) ?
-				   htons(ETH_P_TEB) : skb->protocol;
+	/* Push GRE header. */
+	skb = gre_build_header(skb, &tpi, tunnel->hlen);
+	if (!skb)
+		goto out;
 
-	if (tunnel->parms.o_flags&(GRE_KEY|GRE_CSUM|GRE_SEQ)) {
-		__be32 *ptr = (__be32 *)(((u8 *)iph) + tunnel->hlen - 4);
+	ip_tunnel_xmit(skb, dev, tnl_params);
 
-		if (tunnel->parms.o_flags&GRE_SEQ) {
-			++tunnel->o_seqno;
-			*ptr = htonl(tunnel->o_seqno);
-			ptr--;
-		}
-		if (tunnel->parms.o_flags&GRE_KEY) {
-			*ptr = tunnel->parms.o_key;
-			ptr--;
-		}
-		/* Skip GRE checksum if skb is getting offloaded. */
-		if (!(skb_shinfo(skb)->gso_type & SKB_GSO_GRE) &&
-		    (tunnel->parms.o_flags&GRE_CSUM)) {
-			int offset = skb_transport_offset(skb);
-
-			if (skb_has_shared_frag(skb)) {
-				err = __skb_linearize(skb);
-				if (err)
-					goto tx_error;
-			}
-
-			*ptr = 0;
-			*(__sum16 *)ptr = csum_fold(skb_checksum(skb, offset,
-								 skb->len - offset,
-								 0));
-		}
-	}
-
-	iptunnel_xmit(skb, dev);
 	return NETDEV_TX_OK;
-
-#if IS_ENABLED(CONFIG_IPV6)
-tx_error_icmp:
-	dst_link_failure(skb);
-#endif
-tx_error:
-	dev->stats.tx_errors++;
+drop:
 	dev_kfree_skb(skb);
+out:
+	dev->stats.tx_dropped++;
 	return NETDEV_TX_OK;
 }
 
-static int ipgre_tunnel_bind_dev(struct net_device *dev)
+static netdev_tx_t ipgre_tap_xmit(struct sk_buff *skb, struct net_device *dev)
 {
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
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	const struct iphdr *tnl_params = &tunnel->parms.iph;
 
-		if (dev->type != ARPHRD_ETHER)
-			dev->flags |= IFF_POINTOPOINT;
+	skb = handle_offloads(tunnel, skb);
+	if (IS_ERR(skb)) {
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
 	}
 
-	if (!tdev && tunnel->parms.link)
-		tdev = __dev_get_by_index(dev_net(dev), tunnel->parms.link);
+	return __gre_xmit(skb, dev, tnl_params, htons(ETH_P_TEB));
+}
 
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
+static netdev_tx_t ipgre_tunnel_xmit(struct sk_buff *skb,
+				     struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	const struct iphdr *tnl_params;
 
-	if (mtu < 68)
-		mtu = 68;
+	skb = handle_offloads(tunnel, skb);
+	if (IS_ERR(skb)) {
+		dev->stats.tx_dropped++;
+		return NETDEV_TX_OK;
+	}
+	if (dev->header_ops) {
+		if (skb->protocol == htons(ETH_P_IP))
+			tnl_params = (const struct iphdr *)skb->data;
+		else
+			tnl_params = &tunnel->parms.iph;
 
-	tunnel->hlen = addend;
-	/* TCP offload with GRE SEQ is not supported. */
-	if (!(tunnel->parms.o_flags & GRE_SEQ)) {
-		dev->features		|= NETIF_F_GSO_SOFTWARE;
-		dev->hw_features	|= NETIF_F_GSO_SOFTWARE;
+		/* Pull skb since ip_tunnel_xmit() needs skb->data pointing
+		 * to gre header.
+		 */
+		skb_pull(skb, tunnel->hlen + sizeof(struct iphdr));
+	} else {
+		tnl_params = &tunnel->parms.iph;
 	}
 
-	return mtu;
+	return __gre_xmit(skb, dev, tnl_params, skb->protocol);
 }
 
-static int
-ipgre_tunnel_ioctl (struct net_device *dev, struct ifreq *ifr, int cmd)
+static int ipgre_tunnel_ioctl(struct net_device *dev,
+			      struct ifreq *ifr, int cmd)
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
-
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
-
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
+	if (copy_from_user(&p, ifr->ifr_ifru.ifru_data, sizeof(p)))
+		return -EFAULT;
+	if (p.iph.version != 4 || p.iph.protocol != IPPROTO_GRE ||
+	    p.iph.ihl != 5 || (p.iph.frag_off&htons(~IP_DF)) ||
+	    ((p.i_flags|p.o_flags)&(GRE_VERSION|GRE_ROUTING))) {
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
 
-static int ipgre_tunnel_change_mtu(struct net_device *dev, int new_mtu)
-{
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-	if (new_mtu < 68 ||
-	    new_mtu > 0xFFF8 - dev->hard_header_len - tunnel->hlen)
-		return -EINVAL;
-	dev->mtu = new_mtu;
+	p.i_flags = tnl_flags_to_gre_flags(p.i_flags);
+	p.o_flags = tnl_flags_to_gre_flags(p.o_flags);
+
+	if (copy_to_user(ifr->ifr_ifru.ifru_data, &p, sizeof(p)))
+		return -EFAULT;
 	return 0;
 }
 
@@ -1274,17 +536,17 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 			const void *daddr, const void *saddr, unsigned int len)
 {
 	struct ip_tunnel *t = netdev_priv(dev);
-	struct iphdr *iph = (struct iphdr *)skb_push(skb, t->hlen);
-	__be16 *p = (__be16 *)(iph+1);
+	struct iphdr *iph;
+	struct gre_base_hdr *greh;
 
-	memcpy(iph, &t->parms.iph, sizeof(struct iphdr));
-	p[0]		= t->parms.o_flags;
-	p[1]		= htons(type);
+	iph = (struct iphdr *)skb_push(skb, t->hlen + sizeof(*iph));
+	greh = (struct gre_base_hdr *)(iph+1);
+	greh->flags = tnl_flags_to_gre_flags(t->parms.o_flags);
+	greh->protocol = htons(type);
 
-	/*
-	 *	Set the source hardware address.
-	 */
+	memcpy(iph, &t->parms.iph, sizeof(struct iphdr));
 
+	/* Set the source hardware address. */
 	if (saddr)
 		memcpy(&iph->saddr, saddr, 4);
 	if (daddr)
@@ -1292,7 +554,7 @@ static int ipgre_header(struct sk_buff *skb, struct net_device *dev,
 	if (iph->daddr)
 		return t->hlen;
 
-	return -t->hlen;
+	return -(t->hlen + sizeof(*iph));
 }
 
 static int ipgre_header_parse(const struct sk_buff *skb, unsigned char *haddr)
@@ -1351,26 +613,17 @@ static int ipgre_close(struct net_device *dev)
 
 static const struct net_device_ops ipgre_netdev_ops = {
 	.ndo_init		= ipgre_tunnel_init,
-	.ndo_uninit		= ipgre_tunnel_uninit,
+	.ndo_uninit		= ip_tunnel_uninit,
 #ifdef CONFIG_NET_IPGRE_BROADCAST
 	.ndo_open		= ipgre_open,
 	.ndo_stop		= ipgre_close,
 #endif
 	.ndo_start_xmit		= ipgre_tunnel_xmit,
 	.ndo_do_ioctl		= ipgre_tunnel_ioctl,
-	.ndo_change_mtu		= ipgre_tunnel_change_mtu,
-	.ndo_get_stats64	= ipgre_get_stats64,
+	.ndo_change_mtu		= ip_tunnel_change_mtu,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
 };
 
-static void ipgre_dev_free(struct net_device *dev)
-{
-	struct ip_tunnel *tunnel = netdev_priv(dev);
-
-	gro_cells_destroy(&tunnel->gro_cells);
-	free_percpu(dev->tstats);
-	free_netdev(dev);
-}
-
 #define GRE_FEATURES (NETIF_F_SG |		\
 		      NETIF_F_FRAGLIST |	\
 		      NETIF_F_HIGHDMA |		\
@@ -1379,35 +632,49 @@ static void ipgre_dev_free(struct net_device *dev)
 static void ipgre_tunnel_setup(struct net_device *dev)
 {
 	dev->netdev_ops		= &ipgre_netdev_ops;
-	dev->destructor 	= ipgre_dev_free;
+	ip_tunnel_setup(dev, ipgre_net_id);
+}
 
-	dev->type		= ARPHRD_IPGRE;
-	dev->needed_headroom 	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
+static void __gre_tunnel_init(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel;
+
+	tunnel = netdev_priv(dev);
+	tunnel->hlen = ip_gre_calc_hlen(tunnel->parms.o_flags);
+	tunnel->parms.iph.protocol = IPPROTO_GRE;
+
+	dev->needed_headroom	= LL_MAX_HEADER + sizeof(struct iphdr) + 4;
 	dev->mtu		= ETH_DATA_LEN - sizeof(struct iphdr) - 4;
-	dev->flags		= IFF_NOARP;
 	dev->iflink		= 0;
-	dev->addr_len		= 4;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
-	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
 
-	dev->features		|= GRE_FEATURES;
+	dev->features		|= NETIF_F_NETNS_LOCAL | GRE_FEATURES;
 	dev->hw_features	|= GRE_FEATURES;
+
+	if (!(tunnel->parms.o_flags & TUNNEL_SEQ)) {
+		/* TCP offload with GRE SEQ is not supported. */
+		dev->features    |= NETIF_F_GSO_SOFTWARE;
+		dev->hw_features |= NETIF_F_GSO_SOFTWARE;
+		/* Can use a lockless transmit, unless we generate
+		 * output sequences
+		 */
+		dev->features |= NETIF_F_LLTX;
+	}
 }
 
 static int ipgre_tunnel_init(struct net_device *dev)
 {
-	struct ip_tunnel *tunnel;
-	struct iphdr *iph;
-	int err;
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct iphdr *iph = &tunnel->parms.iph;
 
-	tunnel = netdev_priv(dev);
-	iph = &tunnel->parms.iph;
+	__gre_tunnel_init(dev);
 
-	tunnel->dev = dev;
-	strcpy(tunnel->parms.name, dev->name);
+	memcpy(dev->dev_addr, &iph->saddr, 4);
+	memcpy(dev->broadcast, &iph->daddr, 4);
 
-	memcpy(dev->dev_addr, &tunnel->parms.iph.saddr, 4);
-	memcpy(dev->broadcast, &tunnel->parms.iph.daddr, 4);
+	dev->type		= ARPHRD_IPGRE;
+	dev->flags		= IFF_NOARP;
+	dev->priv_flags		&= ~IFF_XMIT_DST_RELEASE;
+	dev->addr_len		= 4;
 
 	if (iph->daddr) {
 #ifdef CONFIG_NET_IPGRE_BROADCAST
@@ -1421,106 +688,30 @@ static int ipgre_tunnel_init(struct net_device *dev)
 	} else
 		dev->header_ops = &ipgre_header_ops;
 
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
+	return ip_tunnel_init(dev);
 }
 
-
 static const struct gre_protocol ipgre_protocol = {
 	.handler     = ipgre_rcv,
 	.err_handler = ipgre_err,
 };
 
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
 static int __net_init ipgre_init_net(struct net *net)
 {
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
+	return ip_tunnel_init_net(net, ipgre_net_id, &ipgre_link_ops, NULL);
 }
 
 static void __net_exit ipgre_exit_net(struct net *net)
 {
-	struct ipgre_net *ign;
-	LIST_HEAD(list);
-
-	ign = net_generic(net, ipgre_net_id);
-	rtnl_lock();
-	ipgre_destroy_tunnels(ign, &list);
-	unregister_netdevice_many(&list);
-	rtnl_unlock();
+	struct ip_tunnel_net *itn = net_generic(net, ipgre_net_id);
+	ip_tunnel_delete_net(itn);
 }
 
 static struct pernet_operations ipgre_net_ops = {
 	.init = ipgre_init_net,
 	.exit = ipgre_exit_net,
 	.id   = &ipgre_net_id,
-	.size = sizeof(struct ipgre_net),
+	.size = sizeof(struct ip_tunnel_net),
 };
 
 static int ipgre_tunnel_validate(struct nlattr *tb[], struct nlattr *data[])
@@ -1565,8 +756,8 @@ out:
 	return ipgre_tunnel_validate(tb, data);
 }
 
-static void ipgre_netlink_parms(struct nlattr *data[],
-				struct ip_tunnel_parm *parms)
+static void ipgre_netlink_parms(struct nlattr *data[], struct nlattr *tb[],
+			       struct ip_tunnel_parm *parms)
 {
 	memset(parms, 0, sizeof(*parms));
 
@@ -1579,10 +770,10 @@ static void ipgre_netlink_parms(struct nlattr *data[],
 		parms->link = nla_get_u32(data[IFLA_GRE_LINK]);
 
 	if (data[IFLA_GRE_IFLAGS])
-		parms->i_flags = nla_get_be16(data[IFLA_GRE_IFLAGS]);
+		parms->i_flags = gre_flags_to_tnl_flags(nla_get_be16(data[IFLA_GRE_IFLAGS]));
 
 	if (data[IFLA_GRE_OFLAGS])
-		parms->o_flags = nla_get_be16(data[IFLA_GRE_OFLAGS]);
+		parms->o_flags = gre_flags_to_tnl_flags(nla_get_be16(data[IFLA_GRE_OFLAGS]));
 
 	if (data[IFLA_GRE_IKEY])
 		parms->i_key = nla_get_be32(data[IFLA_GRE_IKEY]);
@@ -1608,146 +799,44 @@ static void ipgre_netlink_parms(struct nlattr *data[],
 
 static int ipgre_tap_init(struct net_device *dev)
 {
-	struct ip_tunnel *tunnel;
-
-	tunnel = netdev_priv(dev);
-
-	tunnel->dev = dev;
-	strcpy(tunnel->parms.name, dev->name);
-
-	ipgre_tunnel_bind_dev(dev);
+	__gre_tunnel_init(dev);
 
-	dev->tstats = alloc_percpu(struct pcpu_tstats);
-	if (!dev->tstats)
-		return -ENOMEM;
-
-	return 0;
+	return ip_tunnel_init(dev);
 }
 
 static const struct net_device_ops ipgre_tap_netdev_ops = {
 	.ndo_init		= ipgre_tap_init,
-	.ndo_uninit		= ipgre_tunnel_uninit,
-	.ndo_start_xmit		= ipgre_tunnel_xmit,
+	.ndo_uninit		= ip_tunnel_uninit,
+	.ndo_start_xmit		= ipgre_tap_xmit,
 	.ndo_set_mac_address 	= eth_mac_addr,
 	.ndo_validate_addr	= eth_validate_addr,
-	.ndo_change_mtu		= ipgre_tunnel_change_mtu,
-	.ndo_get_stats64	= ipgre_get_stats64,
+	.ndo_change_mtu		= ip_tunnel_change_mtu,
+	.ndo_get_stats64	= ip_tunnel_get_stats64,
 };
 
 static void ipgre_tap_setup(struct net_device *dev)
 {
-
 	ether_setup(dev);
-
 	dev->netdev_ops		= &ipgre_tap_netdev_ops;
-	dev->destructor 	= ipgre_dev_free;
-
-	dev->iflink		= 0;
-	dev->features		|= NETIF_F_NETNS_LOCAL;
-
-	dev->features		|= GRE_FEATURES;
-	dev->hw_features	|= GRE_FEATURES;
+	ip_tunnel_setup(dev, ipgre_tap_net_id);
 }
 
-static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nlattr *tb[],
-			 struct nlattr *data[])
+static int ipgre_newlink(struct net *src_net, struct net_device *dev,
+			 struct nlattr *tb[], struct nlattr *data[])
 {
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
+	struct ip_tunnel_parm p;
 
-out:
-	return err;
+	ipgre_netlink_parms(data, tb, &p);
+	return ip_tunnel_newlink(dev, tb, &p);
 }
 
 static int ipgre_changelink(struct net_device *dev, struct nlattr *tb[],
 			    struct nlattr *data[])
 {
-	struct ip_tunnel *t, *nt;
-	struct net *net = dev_net(dev);
-	struct ipgre_net *ign = net_generic(net, ipgre_net_id);
 	struct ip_tunnel_parm p;
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
+	ipgre_netlink_parms(data, tb, &p);
+	return ip_tunnel_changelink(dev, tb, &p);
 }
 
 static size_t ipgre_get_size(const struct net_device *dev)
@@ -1782,8 +871,8 @@ static int ipgre_fill_info(struct sk_buff *skb, const struct net_device *dev)
 	struct ip_tunnel_parm *p = &t->parms;
 
 	if (nla_put_u32(skb, IFLA_GRE_LINK, p->link) ||
-	    nla_put_be16(skb, IFLA_GRE_IFLAGS, p->i_flags) ||
-	    nla_put_be16(skb, IFLA_GRE_OFLAGS, p->o_flags) ||
+	    nla_put_be16(skb, IFLA_GRE_IFLAGS, tnl_flags_to_gre_flags(p->i_flags)) ||
+	    nla_put_be16(skb, IFLA_GRE_OFLAGS, tnl_flags_to_gre_flags(p->o_flags)) ||
 	    nla_put_be32(skb, IFLA_GRE_IKEY, p->i_key) ||
 	    nla_put_be32(skb, IFLA_GRE_OKEY, p->o_key) ||
 	    nla_put_be32(skb, IFLA_GRE_LOCAL, p->iph.saddr) ||
@@ -1821,6 +910,7 @@ static struct rtnl_link_ops ipgre_link_ops __read_mostly = {
 	.validate	= ipgre_tunnel_validate,
 	.newlink	= ipgre_newlink,
 	.changelink	= ipgre_changelink,
+	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
 };
@@ -1834,13 +924,28 @@ static struct rtnl_link_ops ipgre_tap_ops __read_mostly = {
 	.validate	= ipgre_tap_validate,
 	.newlink	= ipgre_newlink,
 	.changelink	= ipgre_changelink,
+	.dellink	= ip_tunnel_dellink,
 	.get_size	= ipgre_get_size,
 	.fill_info	= ipgre_fill_info,
 };
 
-/*
- *	And now the modules code and kernel interface.
- */
+static int __net_init ipgre_tap_init_net(struct net *net)
+{
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
 
 static int __init ipgre_init(void)
 {
@@ -1852,6 +957,10 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		return err;
 
+	err = register_pernet_device(&ipgre_tap_net_ops);
+	if (err < 0)
+		goto pnet_tap_faied;
+
 	rtnl_lock();
 	err = gre_add_protocol(&ipgre_protocol, GREPROTO_CISCO);
 	rtnl_unlock();
@@ -1868,18 +977,17 @@ static int __init ipgre_init(void)
 	if (err < 0)
 		goto tap_ops_failed;
 
-out:
-	return err;
+	return 0;
 
 tap_ops_failed:
 	rtnl_link_unregister(&ipgre_link_ops);
 rtnl_link_failed:
-	rtnl_lock();
 	gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO);
-	rtnl_unlock();
 add_proto_failed:
+	unregister_pernet_device(&ipgre_tap_net_ops);
+pnet_tap_faied:
 	unregister_pernet_device(&ipgre_net_ops);
-	goto out;
+	return err;
 }
 
 static void __exit ipgre_fini(void)
@@ -1890,6 +998,7 @@ static void __exit ipgre_fini(void)
 	if (gre_del_protocol(&ipgre_protocol, GREPROTO_CISCO) < 0)
 		pr_info("%s: can't remove protocol\n", __func__);
 	rtnl_unlock();
+	unregister_pernet_device(&ipgre_tap_net_ops);
 	unregister_pernet_device(&ipgre_net_ops);
 }
 
@@ -1899,3 +1008,4 @@ MODULE_LICENSE("GPL");
 MODULE_ALIAS_RTNL_LINK("gre");
 MODULE_ALIAS_RTNL_LINK("gretap");
 MODULE_ALIAS_NETDEV("gre0");
+MODULE_ALIAS_NETDEV("gretap0");
diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
new file mode 100644
index 0000000..88b4432
--- /dev/null
+++ b/net/ipv4/ip_tunnel.c
@@ -0,0 +1,1036 @@
+/*
+ * Copyright (c) 2013 Nicira, Inc.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of version 2 of the GNU General Public
+ * License as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
+ * General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA
+ * 02110-1301, USA
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
+#include <linux/rculist.h>
+
+#include <net/sock.h>
+#include <net/ip.h>
+#include <net/icmp.h>
+#include <net/protocol.h>
+#include <net/ip_tunnels.h>
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
+/* Often modified stats are per cpu, other are shared (netdev->stats) */
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
+   Given src, dst and key, find appropriate for input tunnel.
+*/
+struct ip_tunnel *ip_tunnel_lookup(struct ip_tunnel_net *itn,
+				    int link, __be16 flags,
+				    __be32 remote, __be32 local,
+				    __be32 key)
+{
+	unsigned int hash;
+	struct ip_tunnel *t, *cand = NULL;
+	struct hlist_head *head;
+
+	hash = ip_tunnel_hash(itn, key, remote);
+	head = &itn->tunnels[hash];
+
+	hlist_for_each_entry_rcu(t, head, hash_node) {
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
+	hlist_for_each_entry_rcu(t, head, hash_node) {
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
+	hlist_for_each_entry_rcu(t, head, hash_node) {
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
+	if (flags & TUNNEL_NO_KEY)
+		goto skip_key_lookup;
+
+	hlist_for_each_entry_rcu(t, head, hash_node) {
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
+skip_key_lookup:
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
+	struct hlist_head *head = ip_bucket(itn, parms);
+
+	hlist_for_each_entry_rcu(t, head, hash_node) {
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
+		if (dev->type != ARPHRD_ETHER)
+			dev->flags |= IFF_POINTOPOINT;
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
+	struct pcpu_tstats *tstats;
+	const struct iphdr *iph = ip_hdr(skb);
+	int err;
+
+	secpath_reset(skb);
+
+	skb->protocol = tpi->proto;
+
+	skb->mac_header = skb->network_header;
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
+	if ((!(tpi->flags&TUNNEL_CSUM) &&  (tunnel->parms.i_flags&TUNNEL_CSUM)) ||
+	     ((tpi->flags&TUNNEL_CSUM) && !(tunnel->parms.i_flags&TUNNEL_CSUM))) {
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
+	skb->pkt_type = PACKET_HOST;
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
+int ip_tunnel_xmit(struct sk_buff *skb, struct net_device *dev,
+			  const struct iphdr  *tnl_params)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	const struct iphdr *inner_iph;
+	struct iphdr *iph;
+	struct flowi4 fl4;
+	u8     tos, ttl;
+	__be16 df;
+	struct rtable *rt;		/* Route to the other host */
+	struct net_device *tdev;	/* Device to other host */
+	unsigned int max_headroom;	/* The extra header space needed */
+	__be32 dst;
+	int mtu;
+
+	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
+
+	dst = tnl_params->daddr;
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
+			dst = rt_nexthop(rt, inner_iph->daddr);
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
+	tos = tnl_params->tos;
+	if (tos & 0x1) {
+		tos &= ~0x1;
+		if (skb->protocol == htons(ETH_P_IP))
+			tos = inner_iph->tos;
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			tos = ipv6_get_dsfield((const struct ipv6hdr *)inner_iph);
+	}
+
+	rt = ip_route_output_tunnel(dev_net(dev), &fl4,
+				    tunnel->parms.iph.protocol,
+				    dst, tnl_params->saddr,
+				    tunnel->parms.o_key,
+				    RT_TOS(tos),
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
+	df = tnl_params->frag_off;
+
+	if (df)
+		mtu = dst_mtu(&rt->dst) - dev->hard_header_len
+					- sizeof(struct iphdr);
+	else
+		mtu = skb_dst(skb) ? dst_mtu(skb_dst(skb)) : dev->mtu;
+
+	if (skb_dst(skb))
+		skb_dst(skb)->ops->update_pmtu(skb_dst(skb), NULL, skb, mtu);
+
+	if (skb->protocol == htons(ETH_P_IP)) {
+		df |= (inner_iph->frag_off&htons(IP_DF));
+
+		if (!skb_is_gso(skb) &&
+		    (inner_iph->frag_off&htons(IP_DF)) &&
+		     mtu < ntohs(inner_iph->tot_len)) {
+			icmp_send(skb, ICMP_DEST_UNREACH, ICMP_FRAG_NEEDED, htonl(mtu));
+			ip_rt_put(rt);
+			goto tx_error;
+		}
+	}
+#if IS_ENABLED(CONFIG_IPV6)
+	else if (skb->protocol == htons(ETH_P_IPV6)) {
+		struct rt6_info *rt6 = (struct rt6_info *)skb_dst(skb);
+
+		if (rt6 && mtu < dst_mtu(skb_dst(skb)) &&
+		    mtu >= IPV6_MIN_MTU) {
+			if ((tunnel->parms.iph.daddr &&
+			    !ipv4_is_multicast(tunnel->parms.iph.daddr)) ||
+			    rt6->rt6i_dst.plen == 128) {
+				rt6->rt6i_flags |= RTF_MODIFIED;
+				dst_metric_set(skb_dst(skb), RTAX_MTU, mtu);
+			}
+		}
+
+		if (!skb_is_gso(skb) && mtu >= IPV6_MIN_MTU &&
+		    mtu < skb->len) {
+			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, mtu);
+			ip_rt_put(rt);
+			goto tx_error;
+		}
+	}
+#endif
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
+	ttl = tnl_params->ttl;
+	if (ttl == 0) {
+		if (skb->protocol == htons(ETH_P_IP))
+			ttl = inner_iph->ttl;
+#if IS_ENABLED(CONFIG_IPV6)
+		else if (skb->protocol == htons(ETH_P_IPV6))
+			ttl = ((const struct ipv6hdr *)inner_iph)->hop_limit;
+#endif
+		else
+			ttl = ip4_dst_hoplimit(&rt->dst);
+	}
+
+	max_headroom = LL_RESERVED_SPACE(tdev) + sizeof(struct iphdr)
+					       + rt->dst.header_len;
+	if (max_headroom > dev->needed_headroom) {
+		dev->needed_headroom = max_headroom;
+		if (skb_cow_head(skb, dev->needed_headroom)) {
+			dev->stats.tx_dropped++;
+			dev_kfree_skb(skb);
+			return NETDEV_TX_OK;
+		}
+	}
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, &rt->dst);
+	memset(IPCB(skb), 0, sizeof(*IPCB(skb)));
+
+	/* Push down and install the IP header. */
+	skb_push(skb, sizeof(struct iphdr));
+	skb_reset_network_header(skb);
+
+	iph = ip_hdr(skb);
+	inner_iph = (const struct iphdr *)skb_inner_network_header(skb);
+
+	iph->version	=	4;
+	iph->ihl	=	sizeof(struct iphdr) >> 2;
+	iph->frag_off	=	df;
+	iph->protocol	=	tnl_params->protocol;
+	iph->tos	=	ip_tunnel_ecn_encap(tos, inner_iph, skb);
+	iph->daddr	=	fl4.daddr;
+	iph->saddr	=	fl4.saddr;
+	iph->ttl	=	ttl;
+	tunnel_ip_select_ident(skb, inner_iph, &rt->dst);
+
+	iptunnel_xmit(skb, dev);
+	return 0;
+
+#if IS_ENABLED(CONFIG_IPV6)
+tx_error_icmp:
+	dst_link_failure(skb);
+#endif
+tx_error:
+	dev->stats.tx_errors++;
+	dev_kfree_skb(skb);
+	return 0;
+}
+EXPORT_SYMBOL(ip_tunnel_xmit);
+
+static void ip_tunnel_update(struct ip_tunnel_net *itn,
+			       struct ip_tunnel *t,
+			       struct net_device *dev,
+			       struct ip_tunnel_parm *p,
+			       bool set_mtu)
+{
+	ip_tunnel_del(itn, t);
+	t->parms.iph.saddr = p->iph.saddr;
+	t->parms.iph.daddr = p->iph.daddr;
+	t->parms.i_key = p->i_key;
+	t->parms.o_key = p->o_key;
+	if (dev->type != ARPHRD_ETHER) {
+		memcpy(dev->dev_addr, &p->iph.saddr, 4);
+		memcpy(dev->broadcast, &p->iph.daddr, 4);
+	}
+	ip_tunnel_add(itn, t);
+
+	t->parms.iph.ttl = p->iph.ttl;
+	t->parms.iph.tos = p->iph.tos;
+	t->parms.iph.frag_off = p->iph.frag_off;
+
+	if (t->parms.link != p->link) {
+		int mtu;
+
+		t->parms.link = p->link;
+		mtu = ip_tunnel_bind_dev(dev);
+		if (set_mtu)
+			dev->mtu = mtu;
+	}
+	netdev_state_change(dev);
+}
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
+			}
+		}
+
+		if (t) {
+			err = 0;
+			ip_tunnel_update(itn, t, dev, p, true);
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
+		struct hlist_node *n;
+		struct hlist_head *thead = &itn->tunnels[h];
+
+		hlist_for_each_entry_safe(t, n, thead, hash_node)
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
+int ip_tunnel_newlink(struct net_device *dev, struct nlattr *tb[],
+		      struct ip_tunnel_parm *p)
+{
+	struct ip_tunnel *nt;
+	struct net *net = dev_net(dev);
+	struct ip_tunnel_net *itn;
+	int mtu;
+	int err;
+
+	nt = netdev_priv(dev);
+	itn = net_generic(net, nt->ip_tnl_net_id);
+
+	if (ip_tunnel_find(itn, p, dev->type))
+		return -EEXIST;
+
+	nt->parms = *p;
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
+			 struct ip_tunnel_parm *p)
+{
+	struct ip_tunnel *t, *nt;
+	struct net *net = dev_net(dev);
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct ip_tunnel_net *itn = net_generic(net, tunnel->ip_tnl_net_id);
+
+	if (dev == itn->fb_tunnel_dev)
+		return -EINVAL;
+
+	nt = netdev_priv(dev);
+
+	t = ip_tunnel_find(itn, p, dev->type);
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
+			if (ipv4_is_multicast(p->iph.daddr))
+				nflags = IFF_BROADCAST;
+			else if (p->iph.daddr)
+				nflags = IFF_POINTOPOINT;
+
+			if ((dev->flags ^ nflags) &
+			    (IFF_POINTOPOINT | IFF_BROADCAST))
+				return -EINVAL;
+		}
+	}
+
+	ip_tunnel_update(itn, t, dev, p, !tb[IFLA_MTU]);
+	return 0;
+}
+EXPORT_SYMBOL(ip_tunnel_changelink);
+
+int ip_tunnel_init(struct net_device *dev)
+{
+	struct ip_tunnel *tunnel = netdev_priv(dev);
+	struct iphdr *iph = &tunnel->parms.iph;
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
+	iph->version		= 4;
+	iph->ihl		= 5;
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
index c3a4233..6a628fb 100644
--- a/net/ipv4/ip_vti.c
+++ b/net/ipv4/ip_vti.c
@@ -38,7 +38,7 @@
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/icmp.h>
-#include <net/ipip.h>
+#include <net/ip_tunnels.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
diff --git a/net/ipv4/ipip.c b/net/ipv4/ipip.c
index 34e006f..a557d6a 100644
--- a/net/ipv4/ipip.c
+++ b/net/ipv4/ipip.c
@@ -111,7 +111,7 @@
 #include <net/sock.h>
 #include <net/ip.h>
 #include <net/icmp.h>
-#include <net/ipip.h>
+#include <net/ip_tunnels.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
 #include <net/net_namespace.h>
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 5f95b3a..fd61fe1 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -61,7 +61,7 @@
 #include <linux/netfilter_ipv4.h>
 #include <linux/compat.h>
 #include <linux/export.h>
-#include <net/ipip.h>
+#include <net/ip_tunnels.h>
 #include <net/checksum.h>
 #include <net/netlink.h>
 #include <net/fib_rules.h>
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index f56277f..ab5c7ad 100644
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
index 6a6ba73..af4a5e2 100644
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
index bef3fed..1e55866 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -47,6 +47,7 @@
 
 #include <net/icmp.h>
 #include <net/ip.h>
+#include <net/ip_tunnels.h>
 #include <net/ipv6.h>
 #include <net/ip6_route.h>
 #include <net/addrconf.h>
diff --git a/net/ipv6/sit.c b/net/ipv6/sit.c
index 898e671..ee4fc57 100644
--- a/net/ipv6/sit.c
+++ b/net/ipv6/sit.c
@@ -49,7 +49,7 @@
 #include <net/ip.h>
 #include <net/udp.h>
 #include <net/icmp.h>
-#include <net/ipip.h>
+#include <net/ip_tunnels.h>
 #include <net/inet_ecn.h>
 #include <net/xfrm.h>
 #include <net/dsfield.h>
-- 
1.7.1
