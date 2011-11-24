From: kaber@trash.net
Subject: [PATCH 10/18] netfilter: add protocol independant NAT core
Date: Thu, 24 Nov 2011 17:57:21 +0100
Message-ID: <1322153850-10533-11-git-send-email-kaber@trash.net>
References: <1322153850-10533-1-git-send-email-kaber@trash.net>
Cc: netdev@vger.kernel.org, kaber@trash.net, ulrich.weber@sophos.com
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1322153850-10533-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>

Convert the IPv4 NAT implementation to a protocol independant core and
address family specific modules.

Signed-off-by: Patrick McHardy <kaber@trash.net>
---
 include/linux/netfilter.h                          |   14 +-
 include/linux/netfilter/nf_nat.h                   |    8 +
 include/linux/netfilter/nfnetlink_conntrack.h      |    6 +-
 include/linux/netfilter_ipv4.h                     |    1 -
 include/net/netfilter/nf_conntrack_expect.h        |    2 +-
 include/net/netfilter/nf_nat.h                     |    2 +-
 include/net/netfilter/nf_nat_core.h                |    5 +-
 include/net/netfilter/nf_nat_l3proto.h             |   47 ++
 include/net/netfilter/nf_nat_l4proto.h             |   71 +++
 include/net/netfilter/nf_nat_protocol.h            |   67 ---
 include/net/netfilter/nf_nat_rule.h                |   15 -
 include/net/netns/conntrack.h                      |    4 +
 include/net/netns/ipv4.h                           |    2 -
 net/ipv4/netfilter.c                               |   37 --
 net/ipv4/netfilter/Kconfig                         |   65 +--
 net/ipv4/netfilter/Makefile                        |   11 +-
 net/ipv4/netfilter/ipt_MASQUERADE.c                |   15 +-
 net/ipv4/netfilter/ipt_NETMAP.c                    |   15 +-
 net/ipv4/netfilter/ipt_REDIRECT.c                  |   15 +-
 .../{nf_nat_standalone.c => iptable_nat.c}         |  264 +++++-----
 net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c     |    6 -
 net/ipv4/netfilter/nf_nat_amanda.c                 |    1 -
 net/ipv4/netfilter/nf_nat_ftp.c                    |    1 -
 net/ipv4/netfilter/nf_nat_h323.c                   |   23 +-
 net/ipv4/netfilter/nf_nat_irc.c                    |    1 -
 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c           |  281 ++++++++++
 net/ipv4/netfilter/nf_nat_pptp.c                   |   15 +-
 net/ipv4/netfilter/nf_nat_proto_gre.c              |   30 +-
 net/ipv4/netfilter/nf_nat_proto_icmp.c             |   24 +-
 net/ipv4/netfilter/nf_nat_rule.c                   |  214 --------
 net/ipv4/netfilter/nf_nat_sip.c                    |   19 +-
 net/ipv4/netfilter/nf_nat_tftp.c                   |    1 -
 net/netfilter/Kconfig                              |   24 +
 net/netfilter/Makefile                             |   11 +
 net/netfilter/core.c                               |    5 +
 net/netfilter/nf_conntrack_core.c                  |    6 +
 net/netfilter/nf_conntrack_netlink.c               |   26 +-
 net/netfilter/nf_conntrack_proto_tcp.c             |    8 +-
 net/netfilter/nf_conntrack_sip.c                   |    6 +-
 net/{ipv4 => }/netfilter/nf_nat_core.c             |  575 ++++++++++----------
 net/{ipv4 => }/netfilter/nf_nat_helper.c           |  100 ++---
 net/{ipv4 => }/netfilter/nf_nat_proto_common.c     |   54 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_dccp.c       |   56 ++-
 net/{ipv4 => }/netfilter/nf_nat_proto_sctp.c       |   53 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_tcp.c        |   40 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_udp.c        |   42 +-
 net/{ipv4 => }/netfilter/nf_nat_proto_udplite.c    |   58 ++-
 net/{ipv4 => }/netfilter/nf_nat_proto_unknown.c    |   16 +-
 net/netfilter/xt_nat.c                             |  183 +++++++
 49 files changed, 1416 insertions(+), 1129 deletions(-)
 create mode 100644 include/net/netfilter/nf_nat_l3proto.h
 create mode 100644 include/net/netfilter/nf_nat_l4proto.h
 delete mode 100644 include/net/netfilter/nf_nat_protocol.h
 delete mode 100644 include/net/netfilter/nf_nat_rule.h
 rename net/ipv4/netfilter/{nf_nat_standalone.c => iptable_nat.c} (52%)
 create mode 100644 net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
 delete mode 100644 net/ipv4/netfilter/nf_nat_rule.c
 rename net/{ipv4 => }/netfilter/nf_nat_core.c (57%)
 rename net/{ipv4 => }/netfilter/nf_nat_helper.c (82%)
 rename net/{ipv4 => }/netfilter/nf_nat_proto_common.c (62%)
 rename net/{ipv4 => }/netfilter/nf_nat_proto_dccp.c (61%)
 rename net/{ipv4 => }/netfilter/nf_nat_proto_sctp.c (61%)
 rename net/{ipv4 => }/netfilter/nf_nat_proto_tcp.c (65%)
 rename net/{ipv4 => }/netfilter/nf_nat_proto_udp.c (60%)
 rename net/{ipv4 => }/netfilter/nf_nat_proto_udplite.c (58%)
 rename net/{ipv4 => }/netfilter/nf_nat_proto_unknown.c (76%)
 create mode 100644 net/netfilter/xt_nat.c

diff --git a/include/linux/netfilter.h b/include/linux/netfilter.h
index 857f502..26ed111 100644
--- a/include/linux/netfilter.h
+++ b/include/linux/netfilter.h
@@ -322,7 +322,7 @@ extern int nf_register_afinfo(const struct nf_afinfo *afinfo);
 extern void nf_unregister_afinfo(const struct nf_afinfo *afinfo);
 
 #include <net/flow.h>
-extern void (*ip_nat_decode_session)(struct sk_buff *, struct flowi *);
+extern void (*nf_nat_decode_session_hook)(struct sk_buff *, struct flowi *);
 
 static inline void
 nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
@@ -330,13 +330,11 @@ nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl, u_int8_t family)
 #ifdef CONFIG_NF_NAT_NEEDED
 	void (*decodefn)(struct sk_buff *, struct flowi *);
 
-	if (family == AF_INET) {
-		rcu_read_lock();
-		decodefn = rcu_dereference(ip_nat_decode_session);
-		if (decodefn)
-			decodefn(skb, fl);
-		rcu_read_unlock();
-	}
+	rcu_read_lock();
+	decodefn = rcu_dereference(nf_nat_decode_session_hook);
+	if (decodefn)
+		decodefn(skb, fl);
+	rcu_read_unlock();
 #endif
 }
 
diff --git a/include/linux/netfilter/nf_nat.h b/include/linux/netfilter/nf_nat.h
index 8df2d13..bf0cc37 100644
--- a/include/linux/netfilter/nf_nat.h
+++ b/include/linux/netfilter/nf_nat.h
@@ -22,4 +22,12 @@ struct nf_nat_ipv4_multi_range_compat {
 	struct nf_nat_ipv4_range	range[1];
 };
 
+struct nf_nat_range {
+	unsigned int			flags;
+	union nf_inet_addr		min_addr;
+	union nf_inet_addr		max_addr;
+	union nf_conntrack_man_proto	min_proto;
+	union nf_conntrack_man_proto	max_proto;
+};
+
 #endif /* _NETFILTER_NF_NAT_H */
diff --git a/include/linux/netfilter/nfnetlink_conntrack.h b/include/linux/netfilter/nfnetlink_conntrack.h
index debf1ae..5f0bed8 100644
--- a/include/linux/netfilter/nfnetlink_conntrack.h
+++ b/include/linux/netfilter/nfnetlink_conntrack.h
@@ -138,8 +138,10 @@ enum ctattr_tstamp {
 
 enum ctattr_nat {
 	CTA_NAT_UNSPEC,
-	CTA_NAT_MINIP,
-	CTA_NAT_MAXIP,
+	CTA_NAT_V4_MINIP,
+#define CTA_NAT_MINIP CTA_NAT_V4_MINIP
+	CTA_NAT_V4_MAXIP,
+#define CTA_NAT_MAXIP CTA_NAT_V4_MAXIP
 	CTA_NAT_PROTO,
 	__CTA_NAT_MAX
 };
diff --git a/include/linux/netfilter_ipv4.h b/include/linux/netfilter_ipv4.h
index fa0946c..55e9452 100644
--- a/include/linux/netfilter_ipv4.h
+++ b/include/linux/netfilter_ipv4.h
@@ -78,7 +78,6 @@ enum nf_ip_hook_priorities {
 
 #ifdef __KERNEL__
 extern int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type);
-extern int ip_xfrm_me_harder(struct sk_buff *skb);
 extern __sum16 nf_ip_checksum(struct sk_buff *skb, unsigned int hook,
 				   unsigned int dataoff, u_int8_t protocol);
 #endif /*__KERNEL__*/
diff --git a/include/net/netfilter/nf_conntrack_expect.h b/include/net/netfilter/nf_conntrack_expect.h
index 0f8a8c5..6f15ce7 100644
--- a/include/net/netfilter/nf_conntrack_expect.h
+++ b/include/net/netfilter/nf_conntrack_expect.h
@@ -43,7 +43,7 @@ struct nf_conntrack_expect {
 	unsigned int class;
 
 #ifdef CONFIG_NF_NAT_NEEDED
-	__be32 saved_ip;
+	union nf_inet_addr saved_addr;
 	/* This is the original per-proto part, used to map the
 	 * expected connection the way the recipient expects. */
 	union nf_conntrack_man_proto saved_proto;
diff --git a/include/net/netfilter/nf_nat.h b/include/net/netfilter/nf_nat.h
index b4de990..1752f13 100644
--- a/include/net/netfilter/nf_nat.h
+++ b/include/net/netfilter/nf_nat.h
@@ -50,7 +50,7 @@ struct nf_conn_nat {
 
 /* Set up the info structure to map into this range. */
 extern unsigned int nf_nat_setup_info(struct nf_conn *ct,
-				      const struct nf_nat_ipv4_range *range,
+				      const struct nf_nat_range *range,
 				      enum nf_nat_manip_type maniptype);
 
 /* Is this tuple already taken? (not by us)*/
diff --git a/include/net/netfilter/nf_nat_core.h b/include/net/netfilter/nf_nat_core.h
index b13d8d1..972e1e4 100644
--- a/include/net/netfilter/nf_nat_core.h
+++ b/include/net/netfilter/nf_nat_core.h
@@ -12,10 +12,7 @@ extern unsigned int nf_nat_packet(struct nf_conn *ct,
 				  unsigned int hooknum,
 				  struct sk_buff *skb);
 
-extern int nf_nat_icmp_reply_translation(struct nf_conn *ct,
-					 enum ip_conntrack_info ctinfo,
-					 unsigned int hooknum,
-					 struct sk_buff *skb);
+extern int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family);
 
 static inline int nf_nat_initialized(struct nf_conn *ct,
 				     enum nf_nat_manip_type manip)
diff --git a/include/net/netfilter/nf_nat_l3proto.h b/include/net/netfilter/nf_nat_l3proto.h
new file mode 100644
index 0000000..3df4a67
--- /dev/null
+++ b/include/net/netfilter/nf_nat_l3proto.h
@@ -0,0 +1,47 @@
+#ifndef _NF_NAT_L3PROTO_H
+#define _NF_NAT_L3PROTO_H
+
+struct nf_nat_l4proto;
+struct nf_nat_l3proto {
+	u8	l3proto;
+
+	int	(*in_range)(const struct nf_conntrack_tuple *t,
+			    const struct nf_nat_range *range);
+
+	u32 	(*secure_port)(const struct nf_conntrack_tuple *t, __be16);
+
+	bool	(*manip_pkt)(struct sk_buff *skb,
+			     unsigned int iphdroff,
+			     const struct nf_nat_l4proto *l4proto,
+			     const struct nf_conntrack_tuple *target,
+			     enum nf_nat_manip_type maniptype);
+
+	void	(*csum_update)(struct sk_buff *skb, unsigned int iphdroff,
+			       __sum16 *check,
+			       const struct nf_conntrack_tuple *t,
+			       enum nf_nat_manip_type maniptype);
+
+	void	(*csum_recalc)(struct sk_buff *skb, u8 proto,
+			       void *data, __sum16 *check,
+			       int datalen, int oldlen);
+
+	void	(*decode_session)(struct sk_buff *skb,
+				  const struct nf_conn *ct,
+				  enum ip_conntrack_dir dir,
+				  unsigned long statusbit,
+				  struct flowi *fl);
+
+	int	(*nlattr_to_range)(struct nlattr *tb[],
+				   struct nf_nat_range *range);
+};
+
+extern int nf_nat_l3proto_register(const struct nf_nat_l3proto *);
+extern void nf_nat_l3proto_unregister(const struct nf_nat_l3proto *);
+extern const struct nf_nat_l3proto *__nf_nat_l3proto_find(u8 l3proto);
+
+extern int nf_nat_icmp_reply_translation(struct sk_buff *skb,
+					 struct nf_conn *ct,
+					 enum ip_conntrack_info ctinfo,
+					 unsigned int hooknum);
+
+#endif /* _NF_NAT_L3PROTO_H */
diff --git a/include/net/netfilter/nf_nat_l4proto.h b/include/net/netfilter/nf_nat_l4proto.h
new file mode 100644
index 0000000..1f0a4f0
--- /dev/null
+++ b/include/net/netfilter/nf_nat_l4proto.h
@@ -0,0 +1,71 @@
+/* Header for use in defining a given protocol. */
+#ifndef _NF_NAT_L4PROTO_H
+#define _NF_NAT_L4PROTO_H
+#include <net/netfilter/nf_nat.h>
+#include <linux/netfilter/nfnetlink_conntrack.h>
+
+struct nf_nat_range;
+struct nf_nat_l3proto;
+
+struct nf_nat_l4proto {
+	/* Protocol number. */
+	u8 l4proto;
+
+	/* Translate a packet to the target according to manip type.
+	 * Return true if succeeded.
+	 */
+	bool (*manip_pkt)(struct sk_buff *skb,
+			  const struct nf_nat_l3proto *l3proto,
+			  unsigned int iphdroff, unsigned int hdroff,
+			  const struct nf_conntrack_tuple *tuple,
+			  enum nf_nat_manip_type maniptype);
+
+	/* Is the manipable part of the tuple between min and max incl? */
+	bool (*in_range)(const struct nf_conntrack_tuple *tuple,
+			 enum nf_nat_manip_type maniptype,
+			 const union nf_conntrack_man_proto *min,
+			 const union nf_conntrack_man_proto *max);
+
+	/* Alter the per-proto part of the tuple (depending on
+	 * maniptype), to give a unique tuple in the given range if
+	 * possible.  Per-protocol part of tuple is initialized to the
+	 * incoming packet.
+	 */
+	void (*unique_tuple)(const struct nf_nat_l3proto *l3proto,
+			     struct nf_conntrack_tuple *tuple,
+			     const struct nf_nat_range *range,
+			     enum nf_nat_manip_type maniptype,
+			     const struct nf_conn *ct);
+
+	int (*nlattr_to_range)(struct nlattr *tb[],
+			       struct nf_nat_range *range);
+};
+
+/* Protocol registration. */
+extern int nf_nat_l4proto_register(u8 l3proto, const struct nf_nat_l4proto *l4proto);
+extern void nf_nat_l4proto_unregister(u8 l3proto, const struct nf_nat_l4proto *l4proto);
+
+extern const struct nf_nat_l4proto *__nf_nat_l4proto_find(u8 l3proto, u8 l4proto);
+
+/* Built-in protocols. */
+extern const struct nf_nat_l4proto nf_nat_l4proto_tcp;
+extern const struct nf_nat_l4proto nf_nat_l4proto_udp;
+extern const struct nf_nat_l4proto nf_nat_l4proto_icmp;
+extern const struct nf_nat_l4proto nf_nat_l4proto_unknown;
+
+extern bool nf_nat_l4proto_in_range(const struct nf_conntrack_tuple *tuple,
+				    enum nf_nat_manip_type maniptype,
+				    const union nf_conntrack_man_proto *min,
+				    const union nf_conntrack_man_proto *max);
+
+extern void nf_nat_l4proto_unique_tuple(const struct nf_nat_l3proto *l3proto,
+					struct nf_conntrack_tuple *tuple,
+					const struct nf_nat_range *range,
+					enum nf_nat_manip_type maniptype,
+					const struct nf_conn *ct,
+					u16 *rover);
+
+extern int nf_nat_l4proto_nlattr_to_range(struct nlattr *tb[],
+					  struct nf_nat_range *range);
+
+#endif /*_NF_NAT_L4PROTO_H*/
diff --git a/include/net/netfilter/nf_nat_protocol.h b/include/net/netfilter/nf_nat_protocol.h
deleted file mode 100644
index 7b0b511..0000000
--- a/include/net/netfilter/nf_nat_protocol.h
+++ /dev/null
@@ -1,67 +0,0 @@
-/* Header for use in defining a given protocol. */
-#ifndef _NF_NAT_PROTOCOL_H
-#define _NF_NAT_PROTOCOL_H
-#include <net/netfilter/nf_nat.h>
-#include <linux/netfilter/nfnetlink_conntrack.h>
-
-struct nf_nat_ipv4_range;
-
-struct nf_nat_protocol {
-	/* Protocol number. */
-	unsigned int protonum;
-
-	/* Translate a packet to the target according to manip type.
-	   Return true if succeeded. */
-	bool (*manip_pkt)(struct sk_buff *skb,
-			  unsigned int iphdroff,
-			  const struct nf_conntrack_tuple *tuple,
-			  enum nf_nat_manip_type maniptype);
-
-	/* Is the manipable part of the tuple between min and max incl? */
-	bool (*in_range)(const struct nf_conntrack_tuple *tuple,
-			 enum nf_nat_manip_type maniptype,
-			 const union nf_conntrack_man_proto *min,
-			 const union nf_conntrack_man_proto *max);
-
-	/* Alter the per-proto part of the tuple (depending on
-	   maniptype), to give a unique tuple in the given range if
-	   possible.  Per-protocol part of tuple is initialized to the
-	   incoming packet. */
-	void (*unique_tuple)(struct nf_conntrack_tuple *tuple,
-			     const struct nf_nat_ipv4_range *range,
-			     enum nf_nat_manip_type maniptype,
-			     const struct nf_conn *ct);
-
-	int (*nlattr_to_range)(struct nlattr *tb[],
-			       struct nf_nat_ipv4_range *range);
-};
-
-/* Protocol registration. */
-extern int nf_nat_protocol_register(const struct nf_nat_protocol *proto);
-extern void nf_nat_protocol_unregister(const struct nf_nat_protocol *proto);
-
-/* Built-in protocols. */
-extern const struct nf_nat_protocol nf_nat_protocol_tcp;
-extern const struct nf_nat_protocol nf_nat_protocol_udp;
-extern const struct nf_nat_protocol nf_nat_protocol_icmp;
-extern const struct nf_nat_protocol nf_nat_unknown_protocol;
-
-extern int init_protocols(void) __init;
-extern void cleanup_protocols(void);
-extern const struct nf_nat_protocol *find_nat_proto(u_int16_t protonum);
-
-extern bool nf_nat_proto_in_range(const struct nf_conntrack_tuple *tuple,
-				  enum nf_nat_manip_type maniptype,
-				  const union nf_conntrack_man_proto *min,
-				  const union nf_conntrack_man_proto *max);
-
-extern void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
-				      const struct nf_nat_ipv4_range *range,
-				      enum nf_nat_manip_type maniptype,
-				      const struct nf_conn *ct,
-				      u_int16_t *rover);
-
-extern int nf_nat_proto_nlattr_to_range(struct nlattr *tb[],
-					struct nf_nat_ipv4_range *range);
-
-#endif /*_NF_NAT_PROTO_H*/
diff --git a/include/net/netfilter/nf_nat_rule.h b/include/net/netfilter/nf_nat_rule.h
deleted file mode 100644
index 2890bdc..0000000
--- a/include/net/netfilter/nf_nat_rule.h
+++ /dev/null
@@ -1,15 +0,0 @@
-#ifndef _NF_NAT_RULE_H
-#define _NF_NAT_RULE_H
-#include <net/netfilter/nf_conntrack.h>
-#include <net/netfilter/nf_nat.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
-
-extern int nf_nat_rule_init(void) __init;
-extern void nf_nat_rule_cleanup(void);
-extern int nf_nat_rule_find(struct sk_buff *skb,
-			    unsigned int hooknum,
-			    const struct net_device *in,
-			    const struct net_device *out,
-			    struct nf_conn *ct);
-
-#endif /* _NF_NAT_RULE_H */
diff --git a/include/net/netns/conntrack.h b/include/net/netns/conntrack.h
index 0249399..f9c60ae 100644
--- a/include/net/netns/conntrack.h
+++ b/include/net/netns/conntrack.h
@@ -24,6 +24,10 @@ struct netns_ct {
 	int			sysctl_tstamp;
 	int			sysctl_checksum;
 	unsigned int		sysctl_log_invalid; /* Log invalid packets */
+#ifdef CONFIG_NF_NAT_NEEDED
+	struct hlist_head	*nat_bysource;
+	unsigned int		nat_htable_size;
+#endif
 #ifdef CONFIG_SYSCTL
 	struct ctl_table_header	*sysctl_header;
 	struct ctl_table_header	*acct_sysctl_header;
diff --git a/include/net/netns/ipv4.h b/include/net/netns/ipv4.h
index d786b4f..15ab452 100644
--- a/include/net/netns/ipv4.h
+++ b/include/net/netns/ipv4.h
@@ -41,8 +41,6 @@ struct netns_ipv4 {
 	struct xt_table		*iptable_security;
 #endif
 	struct xt_table		*nat_table;
-	struct hlist_head	*nat_bysource;
-	unsigned int		nat_htable_size;
 #endif
 
 	int sysctl_icmp_echo_ignore_all;
diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
index 9899619..712894d 100644
--- a/net/ipv4/netfilter.c
+++ b/net/ipv4/netfilter.c
@@ -71,43 +71,6 @@ int ip_route_me_harder(struct sk_buff *skb, unsigned addr_type)
 }
 EXPORT_SYMBOL(ip_route_me_harder);
 
-#ifdef CONFIG_XFRM
-int ip_xfrm_me_harder(struct sk_buff *skb)
-{
-	struct flowi fl;
-	unsigned int hh_len;
-	struct dst_entry *dst;
-
-	if (IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED)
-		return 0;
-	if (xfrm_decode_session(skb, &fl, AF_INET) < 0)
-		return -1;
-
-	dst = skb_dst(skb);
-	if (dst->xfrm)
-		dst = ((struct xfrm_dst *)dst)->route;
-	dst_hold(dst);
-
-	dst = xfrm_lookup(dev_net(dst->dev), dst, &fl, skb->sk, 0);
-	if (IS_ERR(dst))
-		return -1;
-
-	skb_dst_drop(skb);
-	skb_dst_set(skb, dst);
-
-	/* Change in oif may mean change in hh_len. */
-	hh_len = skb_dst(skb)->dev->hard_header_len;
-	if (skb_headroom(skb) < hh_len &&
-	    pskb_expand_head(skb, hh_len - skb_headroom(skb), 0, GFP_ATOMIC))
-		return -1;
-	return 0;
-}
-EXPORT_SYMBOL(ip_xfrm_me_harder);
-#endif
-
-void (*ip_nat_decode_session)(struct sk_buff *, struct flowi *);
-EXPORT_SYMBOL(ip_nat_decode_session);
-
 /*
  * Extra routing may needed on local out, as the QUEUE target never
  * returns control to the table.
diff --git a/net/ipv4/netfilter/Kconfig b/net/ipv4/netfilter/Kconfig
index 1dfc18a..56a1742 100644
--- a/net/ipv4/netfilter/Kconfig
+++ b/net/ipv4/netfilter/Kconfig
@@ -142,25 +142,21 @@ config IP_NF_TARGET_ULOG
 	  To compile it as a module, choose M here.  If unsure, say N.
 
 # NAT + specific targets: nf_conntrack
-config NF_NAT
-	tristate "Full NAT"
+config NF_NAT_IPV4
+	tristate "IPv4 NAT"
 	depends on NF_CONNTRACK_IPV4
 	default m if NETFILTER_ADVANCED=n
+	select NF_NAT
 	help
-	  The Full NAT option allows masquerading, port forwarding and other
+	  The IPv4 NAT option allows masquerading, port forwarding and other
 	  forms of full Network Address Port Translation.  It is controlled by
 	  the `nat' table in iptables: see the man page for iptables(8).
 
 	  To compile it as a module, choose M here.  If unsure, say N.
 
-config NF_NAT_NEEDED
-	bool
-	depends on NF_NAT
-	default y
-
 config IP_NF_TARGET_MASQUERADE
 	tristate "MASQUERADE target support"
-	depends on NF_NAT
+	depends on NF_NAT_IPV4
 	default m if NETFILTER_ADVANCED=n
 	help
 	  Masquerading is a special case of NAT: all outgoing connections are
@@ -173,7 +169,7 @@ config IP_NF_TARGET_MASQUERADE
 
 config IP_NF_TARGET_NETMAP
 	tristate "NETMAP target support"
-	depends on NF_NAT
+	depends on NF_NAT_IPV4
 	depends on NETFILTER_ADVANCED
 	help
 	  NETMAP is an implementation of static 1:1 NAT mapping of network
@@ -184,7 +180,7 @@ config IP_NF_TARGET_NETMAP
 
 config IP_NF_TARGET_REDIRECT
 	tristate "REDIRECT target support"
-	depends on NF_NAT
+	depends on NF_NAT_IPV4
 	depends on NETFILTER_ADVANCED
 	help
 	  REDIRECT is a special case of NAT: all incoming connections are
@@ -196,7 +192,7 @@ config IP_NF_TARGET_REDIRECT
 
 config NF_NAT_SNMP_BASIC
 	tristate "Basic SNMP-ALG support"
-	depends on NF_CONNTRACK_SNMP && NF_NAT
+	depends on NF_CONNTRACK_SNMP && NF_NAT_IPV4
 	depends on NETFILTER_ADVANCED
 	default NF_NAT && NF_CONNTRACK_SNMP
 	---help---
@@ -218,61 +214,46 @@ config NF_NAT_SNMP_BASIC
 #           <expr> '&&' <expr>                   (6)
 #
 # (6) Returns the result of min(/expr/, /expr/).
-config NF_NAT_PROTO_DCCP
-	tristate
-	depends on NF_NAT && NF_CT_PROTO_DCCP
-	default NF_NAT && NF_CT_PROTO_DCCP
 
 config NF_NAT_PROTO_GRE
 	tristate
-	depends on NF_NAT && NF_CT_PROTO_GRE
-
-config NF_NAT_PROTO_UDPLITE
-	tristate
-	depends on NF_NAT && NF_CT_PROTO_UDPLITE
-	default NF_NAT && NF_CT_PROTO_UDPLITE
-
-config NF_NAT_PROTO_SCTP
-	tristate
-	default NF_NAT && NF_CT_PROTO_SCTP
-	depends on NF_NAT && NF_CT_PROTO_SCTP
-	select LIBCRC32C
+	depends on NF_NAT_IPV4 && NF_CT_PROTO_GRE
 
 config NF_NAT_FTP
 	tristate
-	depends on NF_CONNTRACK && NF_NAT
-	default NF_NAT && NF_CONNTRACK_FTP
+	depends on NF_CONNTRACK && NF_NAT_IPV4
+	default NF_NAT_IPV4 && NF_CONNTRACK_FTP
 
 config NF_NAT_IRC
 	tristate
-	depends on NF_CONNTRACK && NF_NAT
-	default NF_NAT && NF_CONNTRACK_IRC
+	depends on NF_CONNTRACK && NF_NAT_IPV4
+	default NF_NAT_IPV4 && NF_CONNTRACK_IRC
 
 config NF_NAT_TFTP
 	tristate
-	depends on NF_CONNTRACK && NF_NAT
-	default NF_NAT && NF_CONNTRACK_TFTP
+	depends on NF_CONNTRACK && NF_NAT_IPV4
+	default NF_NAT_IPV4 && NF_CONNTRACK_TFTP
 
 config NF_NAT_AMANDA
 	tristate
-	depends on NF_CONNTRACK && NF_NAT
-	default NF_NAT && NF_CONNTRACK_AMANDA
+	depends on NF_CONNTRACK && NF_NAT_IPV4
+	default NF_NAT_IPV4 && NF_CONNTRACK_AMANDA
 
 config NF_NAT_PPTP
 	tristate
-	depends on NF_CONNTRACK && NF_NAT
-	default NF_NAT && NF_CONNTRACK_PPTP
+	depends on NF_CONNTRACK && NF_NAT_IPV4
+	default NF_NAT_IPV4 && NF_CONNTRACK_PPTP
 	select NF_NAT_PROTO_GRE
 
 config NF_NAT_H323
 	tristate
-	depends on NF_CONNTRACK && NF_NAT
-	default NF_NAT && NF_CONNTRACK_H323
+	depends on NF_CONNTRACK && NF_NAT_IPV4
+	default NF_NAT_IPV4 && NF_CONNTRACK_H323
 
 config NF_NAT_SIP
 	tristate
-	depends on NF_CONNTRACK && NF_NAT
-	default NF_NAT && NF_CONNTRACK_SIP
+	depends on NF_CONNTRACK && NF_NAT_IPV4
+	default NF_NAT_IPV4 && NF_CONNTRACK_SIP
 
 # mangle + specific targets
 config IP_NF_MANGLE
diff --git a/net/ipv4/netfilter/Makefile b/net/ipv4/netfilter/Makefile
index dca2082..a655e00 100644
--- a/net/ipv4/netfilter/Makefile
+++ b/net/ipv4/netfilter/Makefile
@@ -10,13 +10,11 @@ nf_conntrack_ipv4-objs	+= nf_conntrack_l3proto_ipv4_compat.o
 endif
 endif
 
-nf_nat-y		:= nf_nat_core.o nf_nat_helper.o nf_nat_proto_unknown.o nf_nat_proto_common.o nf_nat_proto_tcp.o nf_nat_proto_udp.o nf_nat_proto_icmp.o
-iptable_nat-y	:= nf_nat_rule.o nf_nat_standalone.o
-
 # connection tracking
 obj-$(CONFIG_NF_CONNTRACK_IPV4) += nf_conntrack_ipv4.o
 
-obj-$(CONFIG_NF_NAT) += nf_nat.o
+nf_nat_ipv4-y		:= nf_nat_l3proto_ipv4.o nf_nat_proto_icmp.o
+obj-$(CONFIG_NF_NAT_IPV4) += nf_nat_ipv4.o
 
 # defrag
 obj-$(CONFIG_NF_DEFRAG_IPV4) += nf_defrag_ipv4.o
@@ -32,10 +30,7 @@ obj-$(CONFIG_NF_NAT_SNMP_BASIC) += nf_nat_snmp_basic.o
 obj-$(CONFIG_NF_NAT_TFTP) += nf_nat_tftp.o
 
 # NAT protocols (nf_nat)
-obj-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
 obj-$(CONFIG_NF_NAT_PROTO_GRE) += nf_nat_proto_gre.o
-obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
-obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 
 # generic IP tables 
 obj-$(CONFIG_IP_NF_IPTABLES) += ip_tables.o
@@ -43,7 +38,7 @@ obj-$(CONFIG_IP_NF_IPTABLES) += ip_tables.o
 # the three instances of ip_tables
 obj-$(CONFIG_IP_NF_FILTER) += iptable_filter.o
 obj-$(CONFIG_IP_NF_MANGLE) += iptable_mangle.o
-obj-$(CONFIG_NF_NAT) += iptable_nat.o
+obj-$(CONFIG_NF_NAT_IPV4) += iptable_nat.o
 obj-$(CONFIG_IP_NF_RAW) += iptable_raw.o
 obj-$(CONFIG_IP_NF_SECURITY) += iptable_security.o
 
diff --git a/net/ipv4/netfilter/ipt_MASQUERADE.c b/net/ipv4/netfilter/ipt_MASQUERADE.c
index 2f210c7..1b96b50 100644
--- a/net/ipv4/netfilter/ipt_MASQUERADE.c
+++ b/net/ipv4/netfilter/ipt_MASQUERADE.c
@@ -19,9 +19,9 @@
 #include <net/ip.h>
 #include <net/checksum.h>
 #include <net/route.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter/x_tables.h>
+#include <net/netfilter/nf_nat.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
@@ -49,7 +49,7 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	struct nf_conn *ct;
 	struct nf_conn_nat *nat;
 	enum ip_conntrack_info ctinfo;
-	struct nf_nat_ipv4_range newrange;
+	struct nf_nat_range newrange;
 	const struct nf_nat_ipv4_multi_range_compat *mr;
 	const struct rtable *rt;
 	__be32 newsrc;
@@ -79,10 +79,13 @@ masquerade_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	nat->masq_index = par->out->ifindex;
 
 	/* Transfer from original range. */
-	newrange = ((struct nf_nat_ipv4_range)
-		{ mr->range[0].flags | NF_NAT_RANGE_MAP_IPS,
-		  newsrc, newsrc,
-		  mr->range[0].min, mr->range[0].max });
+	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
+	memset(&newrange.max_addr, 0, sizeof(newrange.max_addr));
+	newrange.flags       = mr->range[0].flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.ip = newsrc;
+	newrange.max_addr.ip = newsrc;
+	newrange.min_proto   = mr->range[0].min;
+	newrange.max_proto   = mr->range[0].max;
 
 	/* Hand modified range to generic setup. */
 	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_SRC);
diff --git a/net/ipv4/netfilter/ipt_NETMAP.c b/net/ipv4/netfilter/ipt_NETMAP.c
index b5bfbba..85028dc 100644
--- a/net/ipv4/netfilter/ipt_NETMAP.c
+++ b/net/ipv4/netfilter/ipt_NETMAP.c
@@ -16,7 +16,7 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter/x_tables.h>
-#include <net/netfilter/nf_nat_rule.h>
+#include <net/netfilter/nf_nat.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Svenning Soerensen <svenning@post5.tele.dk>");
@@ -44,7 +44,7 @@ netmap_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	enum ip_conntrack_info ctinfo;
 	__be32 new_ip, netmask;
 	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-	struct nf_nat_ipv4_range newrange;
+	struct nf_nat_range newrange;
 
 	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
 		     par->hooknum == NF_INET_POST_ROUTING ||
@@ -61,10 +61,13 @@ netmap_tg(struct sk_buff *skb, const struct xt_action_param *par)
 		new_ip = ip_hdr(skb)->saddr & ~netmask;
 	new_ip |= mr->range[0].min_ip & netmask;
 
-	newrange = ((struct nf_nat_ipv4_range)
-		{ mr->range[0].flags | NF_NAT_RANGE_MAP_IPS,
-		  new_ip, new_ip,
-		  mr->range[0].min, mr->range[0].max });
+	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
+	memset(&newrange.max_addr, 0, sizeof(newrange.max_addr));
+	newrange.flags	     = mr->range[0].flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.ip = new_ip;
+	newrange.max_addr.ip = new_ip;
+	newrange.min_proto   = mr->range[0].min;
+	newrange.max_proto   = mr->range[0].max;
 
 	/* Hand modified range to generic setup. */
 	return nf_nat_setup_info(ct, &newrange, HOOK2MANIP(par->hooknum));
diff --git a/net/ipv4/netfilter/ipt_REDIRECT.c b/net/ipv4/netfilter/ipt_REDIRECT.c
index 7c0103a..11407d7 100644
--- a/net/ipv4/netfilter/ipt_REDIRECT.c
+++ b/net/ipv4/netfilter/ipt_REDIRECT.c
@@ -19,7 +19,7 @@
 #include <net/checksum.h>
 #include <linux/netfilter_ipv4.h>
 #include <linux/netfilter/x_tables.h>
-#include <net/netfilter/nf_nat_rule.h>
+#include <net/netfilter/nf_nat.h>
 
 MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Netfilter Core Team <coreteam@netfilter.org>");
@@ -48,7 +48,7 @@ redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	enum ip_conntrack_info ctinfo;
 	__be32 newdst;
 	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-	struct nf_nat_ipv4_range newrange;
+	struct nf_nat_range newrange;
 
 	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
 		     par->hooknum == NF_INET_LOCAL_OUT);
@@ -76,10 +76,13 @@ redirect_tg(struct sk_buff *skb, const struct xt_action_param *par)
 	}
 
 	/* Transfer from original range. */
-	newrange = ((struct nf_nat_ipv4_range)
-		{ mr->range[0].flags | NF_NAT_RANGE_MAP_IPS,
-		  newdst, newdst,
-		  mr->range[0].min, mr->range[0].max });
+	memset(&newrange.min_addr, 0, sizeof(newrange.min_addr));
+	memset(&newrange.max_addr, 0, sizeof(newrange.max_addr));
+	newrange.flags	     = mr->range[0].flags | NF_NAT_RANGE_MAP_IPS;
+	newrange.min_addr.ip = newdst;
+	newrange.max_addr.ip = newdst;
+	newrange.min_proto   = mr->range[0].min;
+	newrange.max_proto   = mr->range[0].max;
 
 	/* Hand modified range to generic setup. */
 	return nf_nat_setup_info(ct, &newrange, NF_NAT_MANIP_DST);
diff --git a/net/ipv4/netfilter/nf_nat_standalone.c b/net/ipv4/netfilter/iptable_nat.c
similarity index 52%
rename from net/ipv4/netfilter/nf_nat_standalone.c
rename to net/ipv4/netfilter/iptable_nat.c
index 3828a42..9e0ffaf 100644
--- a/net/ipv4/netfilter/nf_nat_standalone.c
+++ b/net/ipv4/netfilter/iptable_nat.c
@@ -1,84 +1,71 @@
 /* (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2011 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-#include <linux/types.h>
-#include <linux/icmp.h>
-#include <linux/gfp.h>
-#include <linux/ip.h>
+
+#include <linux/module.h>
 #include <linux/netfilter.h>
 #include <linux/netfilter_ipv4.h>
-#include <linux/module.h>
-#include <linux/skbuff.h>
-#include <linux/proc_fs.h>
+#include <linux/netfilter_ipv4/ip_tables.h>
+#include <linux/ip.h>
 #include <net/ip.h>
-#include <net/checksum.h>
-#include <linux/spinlock.h>
 
-#include <net/netfilter/nf_conntrack.h>
-#include <net/netfilter/nf_conntrack_core.h>
-#include <net/netfilter/nf_conntrack_extend.h>
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_rule.h>
-#include <net/netfilter/nf_nat_protocol.h>
 #include <net/netfilter/nf_nat_core.h>
-#include <net/netfilter/nf_nat_helper.h>
-#include <linux/netfilter_ipv4/ip_tables.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+
+static const struct xt_table nf_nat_ipv4_table = {
+	.name		= "nat",
+	.valid_hooks	= (1 << NF_INET_PRE_ROUTING) |
+			  (1 << NF_INET_POST_ROUTING) |
+			  (1 << NF_INET_LOCAL_OUT) |
+			  (1 << NF_INET_LOCAL_IN),
+	.me		= THIS_MODULE,
+	.af		= NFPROTO_IPV4,
+};
 
-#ifdef CONFIG_XFRM
-static void nat_decode_session(struct sk_buff *skb, struct flowi *fl)
+static unsigned int alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
 {
-	struct flowi4 *fl4 = &fl->u.ip4;
-	const struct nf_conn *ct;
-	const struct nf_conntrack_tuple *t;
-	enum ip_conntrack_info ctinfo;
-	enum ip_conntrack_dir dir;
-	unsigned long statusbit;
-
-	ct = nf_ct_get(skb, &ctinfo);
-	if (ct == NULL)
-		return;
-	dir = CTINFO2DIR(ctinfo);
-	t = &ct->tuplehash[dir].tuple;
-
-	if (dir == IP_CT_DIR_ORIGINAL)
-		statusbit = IPS_DST_NAT;
-	else
-		statusbit = IPS_SRC_NAT;
-
-	if (ct->status & statusbit) {
-		fl4->daddr = t->dst.u3.ip;
-		if (t->dst.protonum == IPPROTO_TCP ||
-		    t->dst.protonum == IPPROTO_UDP ||
-		    t->dst.protonum == IPPROTO_UDPLITE ||
-		    t->dst.protonum == IPPROTO_DCCP ||
-		    t->dst.protonum == IPPROTO_SCTP)
-			fl4->fl4_dport = t->dst.u.tcp.port;
-	}
+	/* Force range to this IP; let proto decide mapping for
+	 * per-proto parts (hence not IP_NAT_RANGE_PROTO_SPECIFIED).
+	 */
+	struct nf_nat_range range;
+
+	range.flags = 0;
+	pr_debug("Allocating NULL binding for %p (%pI4)\n", ct,
+		 HOOK2MANIP(hooknum) == NF_NAT_MANIP_SRC ?
+		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip :
+		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip);
+
+	return nf_nat_setup_info(ct, &range, HOOK2MANIP(hooknum));
+}
 
-	statusbit ^= IPS_NAT_MASK;
+static unsigned int nf_nat_rule_find(struct sk_buff *skb, unsigned int hooknum,
+				     const struct net_device *in,
+				     const struct net_device *out,
+				     struct nf_conn *ct)
+{
+	struct net *net = nf_ct_net(ct);
+	unsigned int ret;
 
-	if (ct->status & statusbit) {
-		fl4->saddr = t->src.u3.ip;
-		if (t->dst.protonum == IPPROTO_TCP ||
-		    t->dst.protonum == IPPROTO_UDP ||
-		    t->dst.protonum == IPPROTO_UDPLITE ||
-		    t->dst.protonum == IPPROTO_DCCP ||
-		    t->dst.protonum == IPPROTO_SCTP)
-			fl4->fl4_sport = t->src.u.tcp.port;
+	ret = ipt_do_table(skb, hooknum, in, out, net->ipv4.nat_table);
+	if (ret == NF_ACCEPT) {
+		if (!nf_nat_initialized(ct, HOOK2MANIP(hooknum)))
+			ret = alloc_null_binding(ct, hooknum);
 	}
+	return ret;
 }
-#endif
 
 static unsigned int
-nf_nat_fn(unsigned int hooknum,
-	  struct sk_buff *skb,
-	  const struct net_device *in,
-	  const struct net_device *out,
-	  int (*okfn)(struct sk_buff *))
+nf_nat_ipv4_fn(unsigned int hooknum,
+	       struct sk_buff *skb,
+	       const struct net_device *in,
+	       const struct net_device *out,
+	       int (*okfn)(struct sk_buff *))
 {
 	struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -87,14 +74,16 @@ nf_nat_fn(unsigned int hooknum,
 	enum nf_nat_manip_type maniptype = HOOK2MANIP(hooknum);
 
 	/* We never see fragments: conntrack defrags on pre-routing
-	   and local-out, and nf_nat_out protects post-routing. */
+	 * and local-out, and nf_nat_out protects post-routing.
+	 */
 	NF_CT_ASSERT(!ip_is_fragment(ip_hdr(skb)));
 
 	ct = nf_ct_get(skb, &ctinfo);
 	/* Can't track?  It's not due to stress, or conntrack would
-	   have dropped it.  Hence it's the user's responsibilty to
-	   packet filter it out, or implement conntrack/NAT for that
-	   protocol. 8) --RR */
+	 * have dropped it.  Hence it's the user's responsibilty to
+	 * packet filter it out, or implement conntrack/NAT for that
+	 * protocol. 8) --RR
+	 */
 	if (!ct)
 		return NF_ACCEPT;
 
@@ -118,17 +107,17 @@ nf_nat_fn(unsigned int hooknum,
 	case IP_CT_RELATED:
 	case IP_CT_RELATED_REPLY:
 		if (ip_hdr(skb)->protocol == IPPROTO_ICMP) {
-			if (!nf_nat_icmp_reply_translation(ct, ctinfo,
-							   hooknum, skb))
+			if (!nf_nat_icmp_reply_translation(skb, ct, ctinfo,
+							   hooknum))
 				return NF_DROP;
 			else
 				return NF_ACCEPT;
 		}
 		/* Fall thru... (Only ICMPs can be IP_CT_IS_REPLY) */
 	case IP_CT_NEW:
-
 		/* Seen it before?  This can happen for loopback, retrans,
-		   or local packets.. */
+		 * or local packets.
+		 */
 		if (!nf_nat_initialized(ct, maniptype)) {
 			unsigned int ret;
 
@@ -151,16 +140,16 @@ nf_nat_fn(unsigned int hooknum,
 }
 
 static unsigned int
-nf_nat_in(unsigned int hooknum,
-	  struct sk_buff *skb,
-	  const struct net_device *in,
-	  const struct net_device *out,
-	  int (*okfn)(struct sk_buff *))
+nf_nat_ipv4_in(unsigned int hooknum,
+	       struct sk_buff *skb,
+	       const struct net_device *in,
+	       const struct net_device *out,
+	       int (*okfn)(struct sk_buff *))
 {
 	unsigned int ret;
 	__be32 daddr = ip_hdr(skb)->daddr;
 
-	ret = nf_nat_fn(hooknum, skb, in, out, okfn);
+	ret = nf_nat_ipv4_fn(hooknum, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    daddr != ip_hdr(skb)->daddr)
 		skb_dst_drop(skb);
@@ -169,11 +158,11 @@ nf_nat_in(unsigned int hooknum,
 }
 
 static unsigned int
-nf_nat_out(unsigned int hooknum,
-	   struct sk_buff *skb,
-	   const struct net_device *in,
-	   const struct net_device *out,
-	   int (*okfn)(struct sk_buff *))
+nf_nat_ipv4_out(unsigned int hooknum,
+		struct sk_buff *skb,
+		const struct net_device *in,
+		const struct net_device *out,
+		int (*okfn)(struct sk_buff *))
 {
 #ifdef CONFIG_XFRM
 	const struct nf_conn *ct;
@@ -186,29 +175,30 @@ nf_nat_out(unsigned int hooknum,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_fn(hooknum, skb, in, out, okfn);
+	ret = nf_nat_ipv4_fn(hooknum, skb, in, out, okfn);
 #ifdef CONFIG_XFRM
 	if (ret != NF_DROP && ret != NF_STOLEN &&
+	    !(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 
 		if ((ct->tuplehash[dir].tuple.src.u3.ip !=
 		     ct->tuplehash[!dir].tuple.dst.u3.ip) ||
 		    (ct->tuplehash[dir].tuple.src.u.all !=
-		     ct->tuplehash[!dir].tuple.dst.u.all)
-		   )
-			return ip_xfrm_me_harder(skb) == 0 ? ret : NF_DROP;
+		     ct->tuplehash[!dir].tuple.dst.u.all))
+			if (nf_xfrm_me_harder(skb, AF_INET) < 0)
+				ret = NF_DROP;
 	}
 #endif
 	return ret;
 }
 
 static unsigned int
-nf_nat_local_fn(unsigned int hooknum,
-		struct sk_buff *skb,
-		const struct net_device *in,
-		const struct net_device *out,
-		int (*okfn)(struct sk_buff *))
+nf_nat_ipv4_local_fn(unsigned int hooknum,
+		     struct sk_buff *skb,
+		     const struct net_device *in,
+		     const struct net_device *out,
+		     int (*okfn)(struct sk_buff *))
 {
 	const struct nf_conn *ct;
 	enum ip_conntrack_info ctinfo;
@@ -219,7 +209,7 @@ nf_nat_local_fn(unsigned int hooknum,
 	    ip_hdrlen(skb) < sizeof(struct iphdr))
 		return NF_ACCEPT;
 
-	ret = nf_nat_fn(hooknum, skb, in, out, okfn);
+	ret = nf_nat_ipv4_fn(hooknum, skb, in, out, okfn);
 	if (ret != NF_DROP && ret != NF_STOLEN &&
 	    (ct = nf_ct_get(skb, &ctinfo)) != NULL) {
 		enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
@@ -230,21 +220,20 @@ nf_nat_local_fn(unsigned int hooknum,
 				ret = NF_DROP;
 		}
 #ifdef CONFIG_XFRM
-		else if (ct->tuplehash[dir].tuple.dst.u.all !=
+		else if (!(IPCB(skb)->flags & IPSKB_XFRM_TRANSFORMED) &&
+			 ct->tuplehash[dir].tuple.dst.u.all !=
 			 ct->tuplehash[!dir].tuple.src.u.all)
-			if (ip_xfrm_me_harder(skb))
+			if (nf_xfrm_me_harder(skb, AF_INET) < 0)
 				ret = NF_DROP;
 #endif
 	}
 	return ret;
 }
 
-/* We must be after connection tracking and before packet filtering. */
-
-static struct nf_hook_ops nf_nat_ops[] __read_mostly = {
+static struct nf_hook_ops nf_nat_ipv4_ops[] __read_mostly = {
 	/* Before packet filtering, change destination */
 	{
-		.hook		= nf_nat_in,
+		.hook		= nf_nat_ipv4_in,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_PRE_ROUTING,
@@ -252,7 +241,7 @@ static struct nf_hook_ops nf_nat_ops[] __read_mostly = {
 	},
 	/* After packet filtering, change source */
 	{
-		.hook		= nf_nat_out,
+		.hook		= nf_nat_ipv4_out,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_POST_ROUTING,
@@ -260,7 +249,7 @@ static struct nf_hook_ops nf_nat_ops[] __read_mostly = {
 	},
 	/* Before packet filtering, change destination */
 	{
-		.hook		= nf_nat_local_fn,
+		.hook		= nf_nat_ipv4_local_fn,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_OUT,
@@ -268,7 +257,7 @@ static struct nf_hook_ops nf_nat_ops[] __read_mostly = {
 	},
 	/* After packet filtering, change source */
 	{
-		.hook		= nf_nat_fn,
+		.hook		= nf_nat_ipv4_fn,
 		.owner		= THIS_MODULE,
 		.pf		= NFPROTO_IPV4,
 		.hooknum	= NF_INET_LOCAL_IN,
@@ -276,51 +265,56 @@ static struct nf_hook_ops nf_nat_ops[] __read_mostly = {
 	},
 };
 
-static int __init nf_nat_standalone_init(void)
+static int __net_init iptable_nat_net_init(struct net *net)
 {
-	int ret = 0;
+	struct ipt_replace *repl;
+
+	repl = ipt_alloc_initial_table(&nf_nat_ipv4_table);
+	if (repl == NULL)
+		return -ENOMEM;
+	net->ipv4.nat_table = ipt_register_table(net, &nf_nat_ipv4_table, repl);
+	kfree(repl);
+	if (IS_ERR(net->ipv4.nat_table))
+		return PTR_ERR(net->ipv4.nat_table);
+	return 0;
+}
 
-	need_ipv4_conntrack();
+static void __net_exit iptable_nat_net_exit(struct net *net)
+{
+	ipt_unregister_table(net, net->ipv4.nat_table);
+}
 
-#ifdef CONFIG_XFRM
-	BUG_ON(ip_nat_decode_session != NULL);
-	RCU_INIT_POINTER(ip_nat_decode_session, nat_decode_session);
-#endif
-	ret = nf_nat_rule_init();
-	if (ret < 0) {
-		pr_err("nf_nat_init: can't setup rules.\n");
-		goto cleanup_decode_session;
-	}
-	ret = nf_register_hooks(nf_nat_ops, ARRAY_SIZE(nf_nat_ops));
-	if (ret < 0) {
-		pr_err("nf_nat_init: can't register hooks.\n");
-		goto cleanup_rule_init;
-	}
-	return ret;
+static struct pernet_operations iptable_nat_net_ops = {
+	.init	= iptable_nat_net_init,
+	.exit	= iptable_nat_net_exit,
+};
 
- cleanup_rule_init:
-	nf_nat_rule_cleanup();
- cleanup_decode_session:
-#ifdef CONFIG_XFRM
-	RCU_INIT_POINTER(ip_nat_decode_session, NULL);
-	synchronize_net();
-#endif
-	return ret;
+static int __init iptable_nat_init(void)
+{
+	int err;
+
+	err = register_pernet_subsys(&iptable_nat_net_ops);
+	if (err < 0)
+		goto err1;
+
+	err = nf_register_hooks(nf_nat_ipv4_ops, ARRAY_SIZE(nf_nat_ipv4_ops));
+	if (err < 0)
+		goto err2;
+	return 0;
+
+err2:
+	unregister_pernet_subsys(&iptable_nat_net_ops);
+err1:
+	return err;
 }
 
-static void __exit nf_nat_standalone_fini(void)
+static void __exit iptable_nat_exit(void)
 {
-	nf_unregister_hooks(nf_nat_ops, ARRAY_SIZE(nf_nat_ops));
-	nf_nat_rule_cleanup();
-#ifdef CONFIG_XFRM
-	RCU_INIT_POINTER(ip_nat_decode_session, NULL);
-	synchronize_net();
-#endif
-	/* Conntrack caches are unregistered in nf_conntrack_cleanup */
+	nf_unregister_hooks(nf_nat_ipv4_ops, ARRAY_SIZE(nf_nat_ipv4_ops));
+	unregister_pernet_subsys(&iptable_nat_net_ops);
 }
 
-module_init(nf_nat_standalone_init);
-module_exit(nf_nat_standalone_fini);
+module_init(iptable_nat_init);
+module_exit(iptable_nat_exit);
 
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("ip_nat");
diff --git a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
index ef7b190..c3e8257 100644
--- a/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
+++ b/net/ipv4/netfilter/nf_conntrack_l3proto_ipv4.c
@@ -29,12 +29,6 @@
 #include <net/netfilter/ipv4/nf_defrag_ipv4.h>
 #include <net/netfilter/nf_log.h>
 
-int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
-			      struct nf_conn *ct,
-			      enum ip_conntrack_info ctinfo,
-			      unsigned int protoff);
-EXPORT_SYMBOL_GPL(nf_nat_seq_adjust_hook);
-
 static bool ipv4_pkt_to_tuple(const struct sk_buff *skb, unsigned int nhoff,
 			      struct nf_conntrack_tuple *tuple)
 {
diff --git a/net/ipv4/netfilter/nf_nat_amanda.c b/net/ipv4/netfilter/nf_nat_amanda.c
index ef08703..8f5e5c3 100644
--- a/net/ipv4/netfilter/nf_nat_amanda.c
+++ b/net/ipv4/netfilter/nf_nat_amanda.c
@@ -14,7 +14,6 @@
 #include <linux/udp.h>
 
 #include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <linux/netfilter/nf_conntrack_amanda.h>
diff --git a/net/ipv4/netfilter/nf_nat_ftp.c b/net/ipv4/netfilter/nf_nat_ftp.c
index 5589f3a..dd5e387 100644
--- a/net/ipv4/netfilter/nf_nat_ftp.c
+++ b/net/ipv4/netfilter/nf_nat_ftp.c
@@ -15,7 +15,6 @@
 #include <linux/netfilter_ipv4.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <linux/netfilter/nf_conntrack_ftp.h>
diff --git a/net/ipv4/netfilter/nf_nat_h323.c b/net/ipv4/netfilter/nf_nat_h323.c
index 56056cb..a043481 100644
--- a/net/ipv4/netfilter/nf_nat_h323.c
+++ b/net/ipv4/netfilter/nf_nat_h323.c
@@ -15,7 +15,6 @@
 
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <linux/netfilter/nf_conntrack_h323.h>
@@ -400,7 +399,7 @@ static int nat_h245(struct sk_buff *skb, struct nf_conn *ct,
 static void ip_nat_q931_expect(struct nf_conn *new,
 			       struct nf_conntrack_expect *this)
 {
-	struct nf_nat_ipv4_range range;
+	struct nf_nat_range range;
 
 	if (this->tuple.src.u3.ip != 0) {	/* Only accept calls from GK */
 		nf_nat_follow_master(new, this);
@@ -412,14 +411,15 @@ static void ip_nat_q931_expect(struct nf_conn *new,
 
 	/* Change src to where master sends to */
 	range.flags = NF_NAT_RANGE_MAP_IPS;
-	range.min_ip = range.max_ip = new->tuplehash[!this->dir].tuple.src.u3.ip;
+	range.min_addr = range.max_addr =
+	    new->tuplehash[!this->dir].tuple.src.u3;
 	nf_nat_setup_info(new, &range, NF_NAT_MANIP_SRC);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
-	range.min = range.max = this->saved_proto;
-	range.min_ip = range.max_ip =
-	    new->master->tuplehash[!this->dir].tuple.src.u3.ip;
+	range.min_proto = range.max_proto = this->saved_proto;
+	range.min_addr = range.max_addr =
+	    new->master->tuplehash[!this->dir].tuple.src.u3;
 	nf_nat_setup_info(new, &range, NF_NAT_MANIP_DST);
 }
 
@@ -499,20 +499,21 @@ static int nat_q931(struct sk_buff *skb, struct nf_conn *ct,
 static void ip_nat_callforwarding_expect(struct nf_conn *new,
 					 struct nf_conntrack_expect *this)
 {
-	struct nf_nat_ipv4_range range;
+	struct nf_nat_range range;
 
 	/* This must be a fresh one. */
 	BUG_ON(new->status & IPS_NAT_DONE_MASK);
 
 	/* Change src to where master sends to */
 	range.flags = NF_NAT_RANGE_MAP_IPS;
-	range.min_ip = range.max_ip = new->tuplehash[!this->dir].tuple.src.u3.ip;
+	range.min_addr = range.max_addr =
+	    new->tuplehash[!this->dir].tuple.src.u3;
 	nf_nat_setup_info(new, &range, NF_NAT_MANIP_SRC);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
-	range.min = range.max = this->saved_proto;
-	range.min_ip = range.max_ip = this->saved_ip;
+	range.min_proto = range.max_proto = this->saved_proto;
+	range.min_addr = range.max_addr = this->saved_addr;
 	nf_nat_setup_info(new, &range, NF_NAT_MANIP_DST);
 }
 
@@ -528,7 +529,7 @@ static int nat_callforwarding(struct sk_buff *skb, struct nf_conn *ct,
 	u_int16_t nated_port;
 
 	/* Set expectations for NAT */
-	exp->saved_ip = exp->tuple.dst.u3.ip;
+	exp->saved_addr = exp->tuple.dst.u3;
 	exp->tuple.dst.u3.ip = ct->tuplehash[!dir].tuple.dst.u3.ip;
 	exp->saved_proto.tcp.port = exp->tuple.dst.u.tcp.port;
 	exp->expectfn = ip_nat_callforwarding_expect;
diff --git a/net/ipv4/netfilter/nf_nat_irc.c b/net/ipv4/netfilter/nf_nat_irc.c
index 5b0c20a..1ce37f8 100644
--- a/net/ipv4/netfilter/nf_nat_irc.c
+++ b/net/ipv4/netfilter/nf_nat_irc.c
@@ -17,7 +17,6 @@
 
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <linux/netfilter/nf_conntrack_irc.h>
diff --git a/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
new file mode 100644
index 0000000..ede45fb
--- /dev/null
+++ b/net/ipv4/netfilter/nf_nat_l3proto_ipv4.c
@@ -0,0 +1,281 @@
+/*
+ * (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/types.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/ip.h>
+#include <linux/icmp.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter_ipv4.h>
+#include <net/secure_seq.h>
+#include <net/checksum.h>
+#include <net/route.h>
+#include <net/ip.h>
+
+#include <net/netfilter/nf_conntrack_core.h>
+#include <net/netfilter/nf_conntrack.h>
+#include <net/netfilter/nf_nat_core.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
+
+static const struct nf_nat_l3proto nf_nat_l3proto_ipv4;
+
+#ifdef CONFIG_XFRM
+static void nf_nat_ipv4_decode_session(struct sk_buff *skb,
+				       const struct nf_conn *ct,
+				       enum ip_conntrack_dir dir,
+				       unsigned long statusbit,
+				       struct flowi *fl)
+{
+	const struct nf_conntrack_tuple *t = &ct->tuplehash[dir].tuple;
+	struct flowi4 *fl4 = &fl->u.ip4;
+
+	if (ct->status & statusbit) {
+		fl4->daddr = t->dst.u3.ip;
+		if (t->dst.protonum == IPPROTO_TCP ||
+		    t->dst.protonum == IPPROTO_UDP ||
+		    t->dst.protonum == IPPROTO_UDPLITE ||
+		    t->dst.protonum == IPPROTO_DCCP ||
+		    t->dst.protonum == IPPROTO_SCTP)
+			fl4->fl4_dport = t->dst.u.all;
+	}
+
+	statusbit ^= IPS_NAT_MASK;
+
+	if (ct->status & statusbit) {
+		fl4->saddr = t->src.u3.ip;
+		if (t->dst.protonum == IPPROTO_TCP ||
+		    t->dst.protonum == IPPROTO_UDP ||
+		    t->dst.protonum == IPPROTO_UDPLITE ||
+		    t->dst.protonum == IPPROTO_DCCP ||
+		    t->dst.protonum == IPPROTO_SCTP)
+			fl4->fl4_sport = t->src.u.all;
+	}
+}
+#endif /* CONFIG_XFRM */
+
+static int nf_nat_ipv4_in_range(const struct nf_conntrack_tuple *t,
+				const struct nf_nat_range *range)
+{
+	return ntohl(t->src.u3.ip) >= ntohl(range->min_addr.ip) &&
+	       ntohl(t->src.u3.ip) <= ntohl(range->max_addr.ip);
+}
+
+static u32 nf_nat_ipv4_secure_port(const struct nf_conntrack_tuple *t,
+				   __be16 dport)
+{
+	return secure_ipv4_port_ephemeral(t->src.u3.ip, t->dst.u3.ip, dport);
+}
+
+static bool nf_nat_ipv4_manip_pkt(struct sk_buff *skb,
+				  unsigned int iphdroff,
+				  const struct nf_nat_l4proto *l4proto,
+				  const struct nf_conntrack_tuple *target,
+				  enum nf_nat_manip_type maniptype)
+{
+	struct iphdr *iph;
+	unsigned int hdroff;
+
+	if (!skb_make_writable(skb, iphdroff + sizeof(*iph)))
+		return false;
+
+	iph = (void *)skb->data + iphdroff;
+	hdroff = iphdroff + iph->ihl * 4;
+
+	if (!l4proto->manip_pkt(skb, &nf_nat_l3proto_ipv4, iphdroff, hdroff,
+				target, maniptype))
+		return false;
+	iph = (void *)skb->data + iphdroff;
+
+	if (maniptype == NF_NAT_MANIP_SRC) {
+		csum_replace4(&iph->check, iph->saddr, target->src.u3.ip);
+		iph->saddr = target->src.u3.ip;
+	} else {
+		csum_replace4(&iph->check, iph->daddr, target->dst.u3.ip);
+		iph->daddr = target->dst.u3.ip;
+	}
+	return true;
+}
+
+static void nf_nat_ipv4_csum_update(struct sk_buff *skb,
+				    unsigned int iphdroff, __sum16 *check,
+				    const struct nf_conntrack_tuple *t,
+				    enum nf_nat_manip_type maniptype)
+{
+	struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
+	__be32 oldip, newip;
+
+	if (maniptype == NF_NAT_MANIP_SRC) {
+		oldip = iph->saddr;
+		newip = t->src.u3.ip;
+	} else {
+		oldip = iph->daddr;
+		newip = t->dst.u3.ip;
+	}
+	inet_proto_csum_replace4(check, skb, oldip, newip, 1);
+}
+
+static void nf_nat_ipv4_csum_recalc(struct sk_buff *skb,
+				    u8 proto, void *data, __sum16 *check,
+				    int datalen, int oldlen)
+{
+	const struct iphdr *iph = ip_hdr(skb);
+	struct rtable *rt = skb_rtable(skb);
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		if (!(rt->rt_flags & RTCF_LOCAL) &&
+		    (!skb->dev || skb->dev->features & NETIF_F_V4_CSUM)) {
+			skb->ip_summed = CHECKSUM_PARTIAL;
+			skb->csum_start = skb_headroom(skb) +
+					  skb_network_offset(skb) +
+					  ip_hdrlen(skb);
+			skb->csum_offset = (void *)check - data;
+			*check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
+						    datalen, proto, 0);
+		} else {
+			*check = 0;
+			*check = csum_tcpudp_magic(iph->saddr, iph->daddr,
+						   datalen, proto,
+						   csum_partial(data, datalen,
+								0));
+			if (proto == IPPROTO_UDP && !*check)
+				*check = CSUM_MANGLED_0;
+		}
+	} else
+		inet_proto_csum_replace2(check, skb,
+					 htons(oldlen), htons(datalen), 1);
+}
+
+static int nf_nat_ipv4_nlattr_to_range(struct nlattr *tb[],
+				       struct nf_nat_range *range)
+{
+	if (tb[CTA_NAT_V4_MINIP]) {
+		range->min_addr.ip = nla_get_be32(tb[CTA_NAT_V4_MINIP]);
+		range->flags |= NF_NAT_RANGE_MAP_IPS;
+	}
+
+	if (tb[CTA_NAT_V4_MAXIP])
+		range->max_addr.ip = nla_get_be32(tb[CTA_NAT_V4_MAXIP]);
+	else
+		range->max_addr.ip = range->min_addr.ip;
+
+	return 0;
+}
+
+static const struct nf_nat_l3proto nf_nat_l3proto_ipv4 = {
+	.l3proto		= NFPROTO_IPV4,
+	.in_range		= nf_nat_ipv4_in_range,
+	.secure_port		= nf_nat_ipv4_secure_port,
+	.manip_pkt		= nf_nat_ipv4_manip_pkt,
+	.csum_update		= nf_nat_ipv4_csum_update,
+	.csum_recalc		= nf_nat_ipv4_csum_recalc,
+	.nlattr_to_range	= nf_nat_ipv4_nlattr_to_range,
+#ifdef CONFIG_XFRM
+	.decode_session		= nf_nat_ipv4_decode_session,
+#endif
+};
+
+int nf_nat_icmp_reply_translation(struct sk_buff *skb,
+				  struct nf_conn *ct,
+				  enum ip_conntrack_info ctinfo,
+				  unsigned int hooknum)
+{
+	struct {
+		struct icmphdr	icmp;
+		struct iphdr	ip;
+	} *inside;
+	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
+	enum nf_nat_manip_type manip = HOOK2MANIP(hooknum);
+	unsigned int hdrlen = ip_hdrlen(skb);
+	const struct nf_nat_l4proto *l4proto;
+	struct nf_conntrack_tuple target;
+	unsigned long statusbit;
+
+	NF_CT_ASSERT(ctinfo == IP_CT_RELATED || ctinfo == IP_CT_RELATED_REPLY);
+
+	if (!skb_make_writable(skb, hdrlen + sizeof(*inside)))
+		return 0;
+	if (nf_ip_checksum(skb, hooknum, hdrlen, 0))
+		return 0;
+
+	inside = (void *)skb->data + hdrlen;
+	if (inside->icmp.type == ICMP_REDIRECT) {
+		if ((ct->status & IPS_NAT_DONE_MASK) != IPS_NAT_DONE_MASK)
+			return 0;
+		if (ct->status & IPS_NAT_MASK)
+			return 0;
+	}
+
+	if (manip == NF_NAT_MANIP_SRC)
+		statusbit = IPS_SRC_NAT;
+	else
+		statusbit = IPS_DST_NAT;
+
+	/* Invert if this is reply direction */
+	if (dir == IP_CT_DIR_REPLY)
+		statusbit ^= IPS_NAT_MASK;
+
+	if (!(ct->status & statusbit))
+		return 1;
+
+	l4proto = __nf_nat_l4proto_find(NFPROTO_IPV4, inside->ip.protocol);
+	if (!nf_nat_ipv4_manip_pkt(skb, hdrlen + sizeof(inside->icmp),
+				   l4proto, &ct->tuplehash[!dir].tuple, !manip))
+		return 0;
+
+	if (skb->ip_summed != CHECKSUM_PARTIAL) {
+		/* Reloading "inside" here since manip_pkt may reallocate */
+		inside = (void *)skb->data + hdrlen;
+		inside->icmp.checksum = 0;
+		inside->icmp.checksum =
+			csum_fold(skb_checksum(skb, hdrlen,
+					       skb->len - hdrlen, 0));
+	}
+
+	/* Change outer to look like the reply to an incoming packet */
+	nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
+	l4proto = __nf_nat_l4proto_find(NFPROTO_IPV4, 0);
+	if (!nf_nat_ipv4_manip_pkt(skb, 0, l4proto, &target, manip))
+		return 0;
+
+	return 1;
+}
+EXPORT_SYMBOL_GPL(nf_nat_icmp_reply_translation);
+
+static int __init nf_nat_l3proto_ipv4_init(void)
+{
+	int err;
+
+	err = nf_nat_l4proto_register(NFPROTO_IPV4, &nf_nat_l4proto_icmp);
+	if (err < 0)
+		goto err1;
+	err = nf_nat_l3proto_register(&nf_nat_l3proto_ipv4);
+	if (err < 0)
+		goto err2;
+	return err;
+
+err2:
+	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_icmp);
+err1:
+	return err;
+}
+
+static void __exit nf_nat_l3proto_ipv4_exit(void)
+{
+	nf_nat_l3proto_unregister(&nf_nat_l3proto_ipv4);
+	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_icmp);
+}
+
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("nf-nat-" __stringify(AF_INET));
+
+module_init(nf_nat_l3proto_ipv4_init);
+module_exit(nf_nat_l3proto_ipv4_exit);
diff --git a/net/ipv4/netfilter/nf_nat_pptp.c b/net/ipv4/netfilter/nf_nat_pptp.c
index 95762de..c9f59d6 100644
--- a/net/ipv4/netfilter/nf_nat_pptp.c
+++ b/net/ipv4/netfilter/nf_nat_pptp.c
@@ -22,7 +22,6 @@
 
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <net/netfilter/nf_conntrack_zones.h>
@@ -47,7 +46,7 @@ static void pptp_nat_expected(struct nf_conn *ct,
 	struct nf_conntrack_tuple t;
 	const struct nf_ct_pptp_master *ct_pptp_info;
 	const struct nf_nat_pptp *nat_pptp_info;
-	struct nf_nat_ipv4_range range;
+	struct nf_nat_range range;
 
 	ct_pptp_info = &nfct_help(master)->help.ct_pptp_info;
 	nat_pptp_info = &nfct_nat(master)->help.nat_pptp_info;
@@ -89,21 +88,21 @@ static void pptp_nat_expected(struct nf_conn *ct,
 
 	/* Change src to where master sends to */
 	range.flags = NF_NAT_RANGE_MAP_IPS;
-	range.min_ip = range.max_ip
-		= ct->master->tuplehash[!exp->dir].tuple.dst.u3.ip;
+	range.min_addr = range.max_addr
+		= ct->master->tuplehash[!exp->dir].tuple.dst.u3;
 	if (exp->dir == IP_CT_DIR_ORIGINAL) {
 		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
-		range.min = range.max = exp->saved_proto;
+		range.min_proto = range.max_proto = exp->saved_proto;
 	}
 	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_SRC);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = NF_NAT_RANGE_MAP_IPS;
-	range.min_ip = range.max_ip
-		= ct->master->tuplehash[!exp->dir].tuple.src.u3.ip;
+	range.min_addr = range.max_addr
+		= ct->master->tuplehash[!exp->dir].tuple.src.u3;
 	if (exp->dir == IP_CT_DIR_REPLY) {
 		range.flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
-		range.min = range.max = exp->saved_proto;
+		range.min_proto = range.max_proto = exp->saved_proto;
 	}
 	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_DST);
 }
diff --git a/net/ipv4/netfilter/nf_nat_proto_gre.c b/net/ipv4/netfilter/nf_nat_proto_gre.c
index 46ba0b9..ea44f02 100644
--- a/net/ipv4/netfilter/nf_nat_proto_gre.c
+++ b/net/ipv4/netfilter/nf_nat_proto_gre.c
@@ -28,8 +28,7 @@
 #include <linux/ip.h>
 
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_rule.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 #include <linux/netfilter/nf_conntrack_proto_gre.h>
 
 MODULE_LICENSE("GPL");
@@ -38,8 +37,9 @@ MODULE_DESCRIPTION("Netfilter NAT protocol helper module for GRE");
 
 /* generate unique tuple ... */
 static void
-gre_unique_tuple(struct nf_conntrack_tuple *tuple,
-		 const struct nf_nat_ipv4_range *range,
+gre_unique_tuple(const struct nf_nat_l3proto *l3proto,
+		 struct nf_conntrack_tuple *tuple,
+		 const struct nf_nat_range *range,
 		 enum nf_nat_manip_type maniptype,
 		 const struct nf_conn *ct)
 {
@@ -62,8 +62,8 @@ gre_unique_tuple(struct nf_conntrack_tuple *tuple,
 		min = 1;
 		range_size = 0xffff;
 	} else {
-		min = ntohs(range->min.gre.key);
-		range_size = ntohs(range->max.gre.key) - min + 1;
+		min = ntohs(range->min_proto.gre.key);
+		range_size = ntohs(range->max_proto.gre.key) - min + 1;
 	}
 
 	pr_debug("min = %u, range_size = %u\n", min, range_size);
@@ -80,14 +80,14 @@ gre_unique_tuple(struct nf_conntrack_tuple *tuple,
 
 /* manipulate a GRE packet according to maniptype */
 static bool
-gre_manip_pkt(struct sk_buff *skb, unsigned int iphdroff,
+gre_manip_pkt(struct sk_buff *skb,
+	      const struct nf_nat_l3proto *l3proto,
+	      unsigned int iphdroff, unsigned int hdroff,
 	      const struct nf_conntrack_tuple *tuple,
 	      enum nf_nat_manip_type maniptype)
 {
 	const struct gre_hdr *greh;
 	struct gre_hdr_pptp *pgreh;
-	const struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
-	unsigned int hdroff = iphdroff + iph->ihl * 4;
 
 	/* pgreh includes two optional 32bit fields which are not required
 	 * to be there.  That's where the magic '8' comes from */
@@ -117,24 +117,24 @@ gre_manip_pkt(struct sk_buff *skb, unsigned int iphdroff,
 	return true;
 }
 
-static const struct nf_nat_protocol gre = {
-	.protonum		= IPPROTO_GRE,
+static const struct nf_nat_l4proto gre = {
+	.l4proto		= IPPROTO_GRE,
 	.manip_pkt		= gre_manip_pkt,
-	.in_range		= nf_nat_proto_in_range,
+	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= gre_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
+	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
 
 static int __init nf_nat_proto_gre_init(void)
 {
-	return nf_nat_protocol_register(&gre);
+	return nf_nat_l4proto_register(NFPROTO_IPV4, &gre);
 }
 
 static void __exit nf_nat_proto_gre_fini(void)
 {
-	nf_nat_protocol_unregister(&gre);
+	nf_nat_l4proto_unregister(NFPROTO_IPV4, &gre);
 }
 
 module_init(nf_nat_proto_gre_init);
diff --git a/net/ipv4/netfilter/nf_nat_proto_icmp.c b/net/ipv4/netfilter/nf_nat_proto_icmp.c
index b351728..eb30347 100644
--- a/net/ipv4/netfilter/nf_nat_proto_icmp.c
+++ b/net/ipv4/netfilter/nf_nat_proto_icmp.c
@@ -15,8 +15,7 @@
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
-#include <net/netfilter/nf_nat_rule.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 
 static bool
 icmp_in_range(const struct nf_conntrack_tuple *tuple,
@@ -29,8 +28,9 @@ icmp_in_range(const struct nf_conntrack_tuple *tuple,
 }
 
 static void
-icmp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		  const struct nf_nat_ipv4_range *range,
+icmp_unique_tuple(const struct nf_nat_l3proto *l3proto,
+		  struct nf_conntrack_tuple *tuple,
+		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype,
 		  const struct nf_conn *ct)
 {
@@ -38,13 +38,14 @@ icmp_unique_tuple(struct nf_conntrack_tuple *tuple,
 	unsigned int range_size;
 	unsigned int i;
 
-	range_size = ntohs(range->max.icmp.id) - ntohs(range->min.icmp.id) + 1;
+	range_size = ntohs(range->max_proto.icmp.id) -
+		     ntohs(range->min_proto.icmp.id) + 1;
 	/* If no range specified... */
 	if (!(range->flags & NF_NAT_RANGE_PROTO_SPECIFIED))
 		range_size = 0xFFFF;
 
 	for (i = 0; ; ++id) {
-		tuple->src.u.icmp.id = htons(ntohs(range->min.icmp.id) +
+		tuple->src.u.icmp.id = htons(ntohs(range->min_proto.icmp.id) +
 					     (id % range_size));
 		if (++i == range_size || !nf_nat_used_tuple(tuple, ct))
 			return;
@@ -54,13 +55,12 @@ icmp_unique_tuple(struct nf_conntrack_tuple *tuple,
 
 static bool
 icmp_manip_pkt(struct sk_buff *skb,
-	       unsigned int iphdroff,
+	       const struct nf_nat_l3proto *l3proto,
+	       unsigned int iphdroff, unsigned int hdroff,
 	       const struct nf_conntrack_tuple *tuple,
 	       enum nf_nat_manip_type maniptype)
 {
-	const struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
 	struct icmphdr *hdr;
-	unsigned int hdroff = iphdroff + iph->ihl*4;
 
 	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
 		return false;
@@ -72,12 +72,12 @@ icmp_manip_pkt(struct sk_buff *skb,
 	return true;
 }
 
-const struct nf_nat_protocol nf_nat_protocol_icmp = {
-	.protonum		= IPPROTO_ICMP,
+const struct nf_nat_l4proto nf_nat_l4proto_icmp = {
+	.l4proto		= IPPROTO_ICMP,
 	.manip_pkt		= icmp_manip_pkt,
 	.in_range		= icmp_in_range,
 	.unique_tuple		= icmp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
+	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_rule.c b/net/ipv4/netfilter/nf_nat_rule.c
deleted file mode 100644
index d2a9dc3..0000000
--- a/net/ipv4/netfilter/nf_nat_rule.c
+++ /dev/null
@@ -1,214 +0,0 @@
-/* (C) 1999-2001 Paul `Rusty' Russell
- * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
- *
- * This program is free software; you can redistribute it and/or modify
- * it under the terms of the GNU General Public License version 2 as
- * published by the Free Software Foundation.
- */
-
-/* Everything about the rules for NAT. */
-#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
-#include <linux/types.h>
-#include <linux/ip.h>
-#include <linux/netfilter.h>
-#include <linux/netfilter_ipv4.h>
-#include <linux/module.h>
-#include <linux/kmod.h>
-#include <linux/skbuff.h>
-#include <linux/proc_fs.h>
-#include <linux/slab.h>
-#include <net/checksum.h>
-#include <net/route.h>
-#include <linux/bitops.h>
-
-#include <linux/netfilter_ipv4/ip_tables.h>
-#include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_core.h>
-#include <net/netfilter/nf_nat_rule.h>
-
-#define NAT_VALID_HOOKS ((1 << NF_INET_PRE_ROUTING) | \
-			 (1 << NF_INET_POST_ROUTING) | \
-			 (1 << NF_INET_LOCAL_OUT) | \
-			 (1 << NF_INET_LOCAL_IN))
-
-static const struct xt_table nat_table = {
-	.name		= "nat",
-	.valid_hooks	= NAT_VALID_HOOKS,
-	.me		= THIS_MODULE,
-	.af		= NFPROTO_IPV4,
-};
-
-/* Source NAT */
-static unsigned int
-ipt_snat_target(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-
-	NF_CT_ASSERT(par->hooknum == NF_INET_POST_ROUTING ||
-		     par->hooknum == NF_INET_LOCAL_IN);
-
-	ct = nf_ct_get(skb, &ctinfo);
-
-	/* Connection must be valid and new. */
-	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
-			    ctinfo == IP_CT_RELATED_REPLY));
-	NF_CT_ASSERT(par->out != NULL);
-
-	return nf_nat_setup_info(ct, &mr->range[0], NF_NAT_MANIP_SRC);
-}
-
-static unsigned int
-ipt_dnat_target(struct sk_buff *skb, const struct xt_action_param *par)
-{
-	struct nf_conn *ct;
-	enum ip_conntrack_info ctinfo;
-	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-
-	NF_CT_ASSERT(par->hooknum == NF_INET_PRE_ROUTING ||
-		     par->hooknum == NF_INET_LOCAL_OUT);
-
-	ct = nf_ct_get(skb, &ctinfo);
-
-	/* Connection must be valid and new. */
-	NF_CT_ASSERT(ct && (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
-
-	return nf_nat_setup_info(ct, &mr->range[0], NF_NAT_MANIP_DST);
-}
-
-static int ipt_snat_checkentry(const struct xt_tgchk_param *par)
-{
-	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-
-	/* Must be a valid range */
-	if (mr->rangesize != 1) {
-		pr_info("SNAT: multiple ranges no longer supported\n");
-		return -EINVAL;
-	}
-	return 0;
-}
-
-static int ipt_dnat_checkentry(const struct xt_tgchk_param *par)
-{
-	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
-
-	/* Must be a valid range */
-	if (mr->rangesize != 1) {
-		pr_info("DNAT: multiple ranges no longer supported\n");
-		return -EINVAL;
-	}
-	return 0;
-}
-
-static unsigned int
-alloc_null_binding(struct nf_conn *ct, unsigned int hooknum)
-{
-	/* Force range to this IP; let proto decide mapping for
-	   per-proto parts (hence not NF_NAT_RANGE_PROTO_SPECIFIED).
-	*/
-	struct nf_nat_ipv4_range range;
-
-	range.flags = 0;
-	pr_debug("Allocating NULL binding for %p (%pI4)\n", ct,
-		 HOOK2MANIP(hooknum) == NF_NAT_MANIP_SRC ?
-		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.dst.u3.ip :
-		 &ct->tuplehash[IP_CT_DIR_REPLY].tuple.src.u3.ip);
-
-	return nf_nat_setup_info(ct, &range, HOOK2MANIP(hooknum));
-}
-
-int nf_nat_rule_find(struct sk_buff *skb,
-		     unsigned int hooknum,
-		     const struct net_device *in,
-		     const struct net_device *out,
-		     struct nf_conn *ct)
-{
-	struct net *net = nf_ct_net(ct);
-	int ret;
-
-	ret = ipt_do_table(skb, hooknum, in, out, net->ipv4.nat_table);
-
-	if (ret == NF_ACCEPT) {
-		if (!nf_nat_initialized(ct, HOOK2MANIP(hooknum)))
-			/* NUL mapping */
-			ret = alloc_null_binding(ct, hooknum);
-	}
-	return ret;
-}
-
-static struct xt_target ipt_snat_reg __read_mostly = {
-	.name		= "SNAT",
-	.target		= ipt_snat_target,
-	.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
-	.table		= "nat",
-	.hooks		= (1 << NF_INET_POST_ROUTING) | (1 << NF_INET_LOCAL_IN),
-	.checkentry	= ipt_snat_checkentry,
-	.family		= AF_INET,
-};
-
-static struct xt_target ipt_dnat_reg __read_mostly = {
-	.name		= "DNAT",
-	.target		= ipt_dnat_target,
-	.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
-	.table		= "nat",
-	.hooks		= (1 << NF_INET_PRE_ROUTING) | (1 << NF_INET_LOCAL_OUT),
-	.checkentry	= ipt_dnat_checkentry,
-	.family		= AF_INET,
-};
-
-static int __net_init nf_nat_rule_net_init(struct net *net)
-{
-	struct ipt_replace *repl;
-
-	repl = ipt_alloc_initial_table(&nat_table);
-	if (repl == NULL)
-		return -ENOMEM;
-	net->ipv4.nat_table = ipt_register_table(net, &nat_table, repl);
-	kfree(repl);
-	if (IS_ERR(net->ipv4.nat_table))
-		return PTR_ERR(net->ipv4.nat_table);
-	return 0;
-}
-
-static void __net_exit nf_nat_rule_net_exit(struct net *net)
-{
-	ipt_unregister_table(net, net->ipv4.nat_table);
-}
-
-static struct pernet_operations nf_nat_rule_net_ops = {
-	.init = nf_nat_rule_net_init,
-	.exit = nf_nat_rule_net_exit,
-};
-
-int __init nf_nat_rule_init(void)
-{
-	int ret;
-
-	ret = register_pernet_subsys(&nf_nat_rule_net_ops);
-	if (ret != 0)
-		goto out;
-	ret = xt_register_target(&ipt_snat_reg);
-	if (ret != 0)
-		goto unregister_table;
-
-	ret = xt_register_target(&ipt_dnat_reg);
-	if (ret != 0)
-		goto unregister_snat;
-
-	return ret;
-
- unregister_snat:
-	xt_unregister_target(&ipt_snat_reg);
- unregister_table:
-	unregister_pernet_subsys(&nf_nat_rule_net_ops);
- out:
-	return ret;
-}
-
-void nf_nat_rule_cleanup(void)
-{
-	xt_unregister_target(&ipt_dnat_reg);
-	xt_unregister_target(&ipt_snat_reg);
-	unregister_pernet_subsys(&nf_nat_rule_net_ops);
-}
diff --git a/net/ipv4/netfilter/nf_nat_sip.c b/net/ipv4/netfilter/nf_nat_sip.c
index 5aff7ac..7572206 100644
--- a/net/ipv4/netfilter/nf_nat_sip.c
+++ b/net/ipv4/netfilter/nf_nat_sip.c
@@ -19,7 +19,6 @@
 
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <linux/netfilter/nf_conntrack_sip.h>
@@ -254,15 +253,15 @@ static void ip_nat_sip_seq_adjust(struct sk_buff *skb, s16 off)
 static void ip_nat_sip_expected(struct nf_conn *ct,
 				struct nf_conntrack_expect *exp)
 {
-	struct nf_nat_ipv4_range range;
+	struct nf_nat_range range;
 
 	/* This must be a fresh one. */
 	BUG_ON(ct->status & IPS_NAT_DONE_MASK);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
-	range.min = range.max = exp->saved_proto;
-	range.min_ip = range.max_ip = exp->saved_ip;
+	range.min_proto = range.max_proto = exp->saved_proto;
+	range.min_addr = range.max_addr = exp->saved_addr;
 	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_DST);
 
 	/* Change src to where master sends to, but only if the connection
@@ -270,8 +269,8 @@ static void ip_nat_sip_expected(struct nf_conn *ct,
 	if (ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.u3.ip ==
 	    ct->master->tuplehash[exp->dir].tuple.src.u3.ip) {
 		range.flags = NF_NAT_RANGE_MAP_IPS;
-		range.min_ip = range.max_ip
-			= ct->master->tuplehash[!exp->dir].tuple.dst.u3.ip;
+		range.min_addr = range.max_addr
+			= ct->master->tuplehash[!exp->dir].tuple.dst.u3;
 		nf_nat_setup_info(ct, &range, NF_NAT_MANIP_SRC);
 	}
 }
@@ -306,7 +305,7 @@ static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int protoff,
 	else
 		port = ntohs(exp->tuple.dst.u.udp.port);
 
-	exp->saved_ip = exp->tuple.dst.u3.ip;
+	exp->saved_addr = exp->tuple.dst.u3;
 	exp->tuple.dst.u3.ip = newip;
 	exp->saved_proto.udp.port = exp->tuple.dst.u.udp.port;
 	exp->dir = !dir;
@@ -328,7 +327,7 @@ static unsigned int ip_nat_sip_expect(struct sk_buff *skb, unsigned int protoff,
 	if (port == 0)
 		return NF_DROP;
 
-	if (exp->tuple.dst.u3.ip != exp->saved_ip ||
+	if (exp->tuple.dst.u3.ip != exp->saved_addr.ip ||
 	    exp->tuple.dst.u.udp.port != exp->saved_proto.udp.port) {
 		buflen = sprintf(buffer, "%pI4:%u", &newip, port);
 		if (!mangle_packet(skb, protoff, dataoff, dptr, datalen,
@@ -484,13 +483,13 @@ static unsigned int ip_nat_sdp_media(struct sk_buff *skb, unsigned int protoff,
 	else
 		rtp_addr->ip = ct->tuplehash[!dir].tuple.dst.u3.ip;
 
-	rtp_exp->saved_ip = rtp_exp->tuple.dst.u3.ip;
+	rtp_exp->saved_addr = rtp_exp->tuple.dst.u3;
 	rtp_exp->tuple.dst.u3.ip = rtp_addr->ip;
 	rtp_exp->saved_proto.udp.port = rtp_exp->tuple.dst.u.udp.port;
 	rtp_exp->dir = !dir;
 	rtp_exp->expectfn = ip_nat_sip_expected;
 
-	rtcp_exp->saved_ip = rtcp_exp->tuple.dst.u3.ip;
+	rtcp_exp->saved_addr = rtcp_exp->tuple.dst.u3;
 	rtcp_exp->tuple.dst.u3.ip = rtp_addr->ip;
 	rtcp_exp->saved_proto.udp.port = rtcp_exp->tuple.dst.u.udp.port;
 	rtcp_exp->dir = !dir;
diff --git a/net/ipv4/netfilter/nf_nat_tftp.c b/net/ipv4/netfilter/nf_nat_tftp.c
index a2901bf..9600ca4 100644
--- a/net/ipv4/netfilter/nf_nat_tftp.c
+++ b/net/ipv4/netfilter/nf_nat_tftp.c
@@ -9,7 +9,6 @@
 #include <linux/udp.h>
 
 #include <net/netfilter/nf_nat_helper.h>
-#include <net/netfilter/nf_nat_rule.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <linux/netfilter/nf_conntrack_tftp.h>
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 8260b13..bdcb2ca 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -297,6 +297,30 @@ config NF_CT_NETLINK
 	help
 	  This option enables support for a netlink-based userspace interface
 
+config NF_NAT
+	tristate
+
+config NF_NAT_NEEDED
+	bool
+	depends on NF_NAT
+	default y
+
+config NF_NAT_PROTO_DCCP
+	tristate
+	depends on NF_NAT && NF_CT_PROTO_DCCP
+	default NF_NAT && NF_CT_PROTO_DCCP
+
+config NF_NAT_PROTO_UDPLITE
+	tristate
+	depends on NF_NAT && NF_CT_PROTO_UDPLITE
+	default NF_NAT && NF_CT_PROTO_UDPLITE
+
+config NF_NAT_PROTO_SCTP
+	tristate
+	default NF_NAT && NF_CT_PROTO_SCTP
+	depends on NF_NAT && NF_CT_PROTO_SCTP
+	select LIBCRC32C
+
 endif # NF_CONNTRACK
 
 # transparent proxy support
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 1a02853..af649c1 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -37,6 +37,17 @@ obj-$(CONFIG_NF_CONNTRACK_SANE) += nf_conntrack_sane.o
 obj-$(CONFIG_NF_CONNTRACK_SIP) += nf_conntrack_sip.o
 obj-$(CONFIG_NF_CONNTRACK_TFTP) += nf_conntrack_tftp.o
 
+nf_nat-y	:= nf_nat_core.o nf_nat_proto_unknown.o nf_nat_proto_common.o \
+		   nf_nat_proto_udp.o nf_nat_proto_tcp.o nf_nat_helper.o
+
+obj-$(CONFIG_NF_NAT) += nf_nat.o
+obj-$(CONFIG_NF_NAT) += xt_nat.o
+
+# NAT protocols (nf_nat)
+obj-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
+obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
+obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
+
 # transparent proxy support
 obj-$(CONFIG_NETFILTER_TPROXY) += nf_tproxy_core.o
 
diff --git a/net/netfilter/core.c b/net/netfilter/core.c
index afca6c7..d33b48d 100644
--- a/net/netfilter/core.c
+++ b/net/netfilter/core.c
@@ -255,6 +255,11 @@ void nf_conntrack_destroy(struct nf_conntrack *nfct)
 EXPORT_SYMBOL(nf_conntrack_destroy);
 #endif /* CONFIG_NF_CONNTRACK */
 
+#ifdef CONFIG_NF_NAT_NEEDED
+void (*nf_nat_decode_session_hook)(struct sk_buff *, struct flowi *);
+EXPORT_SYMBOL(nf_nat_decode_session_hook);
+#endif
+
 #ifdef CONFIG_PROC_FS
 struct proc_dir_entry *proc_net_netfilter;
 EXPORT_SYMBOL(proc_net_netfilter);
diff --git a/net/netfilter/nf_conntrack_core.c b/net/netfilter/nf_conntrack_core.c
index 1d23cc4..1b85a74 100644
--- a/net/netfilter/nf_conntrack_core.c
+++ b/net/netfilter/nf_conntrack_core.c
@@ -54,6 +54,12 @@ int (*nfnetlink_parse_nat_setup_hook)(struct nf_conn *ct,
 				      const struct nlattr *attr) __read_mostly;
 EXPORT_SYMBOL_GPL(nfnetlink_parse_nat_setup_hook);
 
+int (*nf_nat_seq_adjust_hook)(struct sk_buff *skb,
+			      struct nf_conn *ct,
+			      enum ip_conntrack_info ctinfo,
+			      unsigned int protoff);
+EXPORT_SYMBOL_GPL(nf_nat_seq_adjust_hook);
+
 DEFINE_SPINLOCK(nf_conntrack_lock);
 EXPORT_SYMBOL_GPL(nf_conntrack_lock);
 
diff --git a/net/netfilter/nf_conntrack_netlink.c b/net/netfilter/nf_conntrack_netlink.c
index 2eb1c69..21d9785 100644
--- a/net/netfilter/nf_conntrack_netlink.c
+++ b/net/netfilter/nf_conntrack_netlink.c
@@ -45,7 +45,7 @@
 #include <net/netfilter/nf_conntrack_timestamp.h>
 #ifdef CONFIG_NF_NAT_NEEDED
 #include <net/netfilter/nf_nat_core.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 #endif
 
 #include <linux/netfilter/nfnetlink.h>
@@ -1027,6 +1027,7 @@ ctnetlink_parse_nat_setup(struct nf_conn *ct,
 			  const struct nlattr *attr)
 {
 	typeof(nfnetlink_parse_nat_setup_hook) parse_nat_setup;
+	int err;
 
 	parse_nat_setup = rcu_dereference(nfnetlink_parse_nat_setup_hook);
 	if (!parse_nat_setup) {
@@ -1034,7 +1035,7 @@ ctnetlink_parse_nat_setup(struct nf_conn *ct,
 		rcu_read_unlock();
 		spin_unlock_bh(&nf_conntrack_lock);
 		nfnl_unlock();
-		if (request_module("nf-nat-ipv4") < 0) {
+		if (request_module("nf-nat") < 0) {
 			nfnl_lock();
 			spin_lock_bh(&nf_conntrack_lock);
 			rcu_read_lock();
@@ -1049,7 +1050,26 @@ ctnetlink_parse_nat_setup(struct nf_conn *ct,
 		return -EOPNOTSUPP;
 	}
 
-	return parse_nat_setup(ct, manip, attr);
+	err = parse_nat_setup(ct, manip, attr);
+	if (err == -EAGAIN) {
+#ifdef CONFIG_MODULES
+		rcu_read_unlock();
+		spin_unlock_bh(&nf_conntrack_lock);
+		nfnl_unlock();
+		if (request_module("nf-nat-%u", nf_ct_l3num(ct)) < 0) {
+			nfnl_lock();
+			spin_lock_bh(&nf_conntrack_lock);
+			rcu_read_lock();
+			return -EOPNOTSUPP;
+		}
+		nfnl_lock();
+		spin_lock_bh(&nf_conntrack_lock);
+		rcu_read_lock();
+#else
+		err = -EOPNOTSUPP;
+#endif
+	}
+	return err;
 }
 #endif
 
diff --git a/net/netfilter/nf_conntrack_proto_tcp.c b/net/netfilter/nf_conntrack_proto_tcp.c
index 8235b86..5253d64 100644
--- a/net/netfilter/nf_conntrack_proto_tcp.c
+++ b/net/netfilter/nf_conntrack_proto_tcp.c
@@ -501,10 +501,10 @@ static inline s16 nat_offset(const struct nf_conn *ct,
 
 	return get_offset != NULL ? get_offset(ct, dir, seq) : 0;
 }
-#define NAT_OFFSET(pf, ct, dir, seq) \
-	(pf == NFPROTO_IPV4 ? nat_offset(ct, dir, seq) : 0)
+#define NAT_OFFSET(ct, dir, seq) \
+	(nat_offset(ct, dir, seq))
 #else
-#define NAT_OFFSET(pf, ct, dir, seq)	0
+#define NAT_OFFSET(ct, dir, seq)	0
 #endif
 
 static bool tcp_in_window(const struct nf_conn *ct,
@@ -536,7 +536,7 @@ static bool tcp_in_window(const struct nf_conn *ct,
 		tcp_sack(skb, dataoff, tcph, &sack);
 
 	/* Take into account NAT sequence number mangling */
-	receiver_offset = NAT_OFFSET(pf, ct, !dir, ack - 1);
+	receiver_offset = NAT_OFFSET(ct, !dir, ack - 1);
 	ack -= receiver_offset;
 	sack -= receiver_offset;
 
diff --git a/net/netfilter/nf_conntrack_sip.c b/net/netfilter/nf_conntrack_sip.c
index 295a6d3..4f9c46e 100644
--- a/net/netfilter/nf_conntrack_sip.c
+++ b/net/netfilter/nf_conntrack_sip.c
@@ -893,11 +893,11 @@ static int set_expected_rtp_rtcp(struct sk_buff *skb, unsigned int protoff,
 			break;
 #ifdef CONFIG_NF_NAT_NEEDED
 		if (exp->tuple.src.l3num == AF_INET && !direct_rtp &&
-		    (exp->saved_ip != exp->tuple.dst.u3.ip ||
+		    (exp->saved_addr.ip != exp->tuple.dst.u3.ip ||
 		     exp->saved_proto.udp.port != exp->tuple.dst.u.udp.port) &&
 		    ct->status & IPS_NAT_MASK) {
-			daddr->ip		= exp->saved_ip;
-			tuple.dst.u3.ip		= exp->saved_ip;
+			daddr->ip		= exp->saved_addr.ip;
+			tuple.dst.u3.ip		= exp->saved_addr.ip;
 			tuple.dst.u.udp.port	= exp->saved_proto.udp.port;
 			direct_rtp = 1;
 		} else
diff --git a/net/ipv4/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
similarity index 57%
rename from net/ipv4/netfilter/nf_nat_core.c
rename to net/netfilter/nf_nat_core.c
index acdd002..0cdad5c 100644
--- a/net/ipv4/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -1,7 +1,7 @@
-/* NAT for netfilter; shared with compatibility layer. */
-
-/* (C) 1999-2001 Paul `Rusty' Russell
+/*
+ * (C) 1999-2001 Paul `Rusty' Russell
  * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2011 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -13,38 +13,103 @@
 #include <linux/timer.h>
 #include <linux/skbuff.h>
 #include <linux/gfp.h>
-#include <net/checksum.h>
-#include <net/icmp.h>
-#include <net/ip.h>
-#include <net/tcp.h>  /* For tcp_prot in getorigdst */
-#include <linux/icmp.h>
-#include <linux/udp.h>
+#include <net/xfrm.h>
 #include <linux/jhash.h>
 
-#include <linux/netfilter_ipv4.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_core.h>
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 #include <net/netfilter/nf_nat_core.h>
 #include <net/netfilter/nf_nat_helper.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_l3proto.h>
 #include <net/netfilter/nf_conntrack_zones.h>
+#include <linux/netfilter/nf_nat.h>
 
 static DEFINE_SPINLOCK(nf_nat_lock);
 
-static struct nf_conntrack_l3proto *l3proto __read_mostly;
-
-#define MAX_IP_NAT_PROTO 256
-static const struct nf_nat_protocol __rcu *nf_nat_protos[MAX_IP_NAT_PROTO]
+static const struct nf_nat_l3proto __rcu *nf_nat_l3protos[NFPROTO_NUMPROTO]
+						__read_mostly;
+static const struct nf_nat_l4proto __rcu **nf_nat_l4protos[NFPROTO_NUMPROTO]
 						__read_mostly;
 
-static inline const struct nf_nat_protocol *
-__nf_nat_proto_find(u_int8_t protonum)
+
+inline const struct nf_nat_l3proto *
+__nf_nat_l3proto_find(u8 family)
+{
+	return rcu_dereference(nf_nat_l3protos[family]);
+}
+
+inline const struct nf_nat_l4proto *
+__nf_nat_l4proto_find(u8 family, u8 protonum)
+{
+	return rcu_dereference(nf_nat_l4protos[family][protonum]);
+}
+EXPORT_SYMBOL_GPL(__nf_nat_l4proto_find);
+
+#ifdef CONFIG_XFRM
+static void __nf_nat_decode_session(struct sk_buff *skb, struct flowi *fl)
+{
+	const struct nf_nat_l3proto *l3proto;
+	const struct nf_conn *ct;
+	enum ip_conntrack_info ctinfo;
+	enum ip_conntrack_dir dir;
+	unsigned  long statusbit;
+	u8 family;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	if (ct == NULL)
+		return;
+
+	family = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple.src.l3num;
+	rcu_read_lock();
+	l3proto = __nf_nat_l3proto_find(family);
+	if (l3proto == NULL)
+		goto out;
+
+	dir = CTINFO2DIR(ctinfo);
+	if (dir == IP_CT_DIR_ORIGINAL)
+		statusbit = IPS_DST_NAT;
+	else
+		statusbit = IPS_SRC_NAT;
+
+	l3proto->decode_session(skb, ct, dir, statusbit, fl);
+out:
+	rcu_read_unlock();
+}
+
+int nf_xfrm_me_harder(struct sk_buff *skb, unsigned int family)
 {
-	return rcu_dereference(nf_nat_protos[protonum]);
+	struct flowi fl;
+	unsigned int hh_len;
+	struct dst_entry *dst;
+
+	if (xfrm_decode_session(skb, &fl, family) < 0)
+		return -1;
+
+	dst = skb_dst(skb);
+	if (dst->xfrm)
+		dst = ((struct xfrm_dst *)dst)->route;
+	dst_hold(dst);
+
+	dst = xfrm_lookup(dev_net(dst->dev), dst, &fl, skb->sk, 0);
+	if (IS_ERR(dst))
+		return -1;
+
+	skb_dst_drop(skb);
+	skb_dst_set(skb, dst);
+
+	/* Change in oif may mean change in hh_len. */
+	hh_len = skb_dst(skb)->dev->hard_header_len;
+	if (skb_headroom(skb) < hh_len &&
+	    pskb_expand_head(skb, hh_len - skb_headroom(skb), 0, GFP_ATOMIC))
+		return -1;
+	return 0;
 }
+EXPORT_SYMBOL(nf_xfrm_me_harder);
+#endif /* CONFIG_XFRM */
 
 /* We keep an extra hash for each conntrack, for fast searching. */
 static inline unsigned int
@@ -54,10 +119,9 @@ hash_by_src(const struct net *net, u16 zone,
 	unsigned int hash;
 
 	/* Original src, to ensure we map it consistently if poss. */
-	hash = jhash_3words((__force u32)tuple->src.u3.ip,
-			    (__force u32)tuple->src.u.all ^ zone,
-			    tuple->dst.protonum, nf_conntrack_hash_rnd);
-	return ((u64)hash * net->ipv4.nat_htable_size) >> 32;
+	hash = jhash2((u32 *)&tuple->src, sizeof(tuple->src) / sizeof(u32),
+		      tuple->dst.protonum ^ zone ^ nf_conntrack_hash_rnd);
+	return ((u64)hash * net->ct.nat_htable_size) >> 32;
 }
 
 /* Is this tuple already taken? (not by us) */
@@ -66,10 +130,11 @@ nf_nat_used_tuple(const struct nf_conntrack_tuple *tuple,
 		  const struct nf_conn *ignored_conntrack)
 {
 	/* Conntrack tracking doesn't keep track of outgoing tuples; only
-	   incoming ones.  NAT means they don't have a fixed mapping,
-	   so we invert the tuple and look for the incoming reply.
-
-	   We could keep a separate hash if this proves too slow. */
+	 * incoming ones.  NAT means they don't have a fixed mapping,
+	 * so we invert the tuple and look for the incoming reply.
+	 *
+	 * We could keep a separate hash if this proves too slow.
+	 */
 	struct nf_conntrack_tuple reply;
 
 	nf_ct_invert_tuplepr(&reply, tuple);
@@ -78,31 +143,26 @@ nf_nat_used_tuple(const struct nf_conntrack_tuple *tuple,
 EXPORT_SYMBOL(nf_nat_used_tuple);
 
 /* If we source map this tuple so reply looks like reply_tuple, will
- * that meet the constraints of range. */
-static int
-in_range(const struct nf_conntrack_tuple *tuple,
-	 const struct nf_nat_ipv4_range *range)
+ * that meet the constraints of range.
+ */
+static int in_range(const struct nf_nat_l3proto *l3proto,
+		    const struct nf_nat_l4proto *l4proto,
+		    const struct nf_conntrack_tuple *tuple,
+		    const struct nf_nat_range *range)
 {
-	const struct nf_nat_protocol *proto;
-	int ret = 0;
-
 	/* If we are supposed to map IPs, then we must be in the
-	   range specified, otherwise let this drag us onto a new src IP. */
-	if (range->flags & NF_NAT_RANGE_MAP_IPS) {
-		if (ntohl(tuple->src.u3.ip) < ntohl(range->min_ip) ||
-		    ntohl(tuple->src.u3.ip) > ntohl(range->max_ip))
-			return 0;
-	}
+	 * range specified, otherwise let this drag us onto a new src IP.
+	 */
+	if (range->flags & NF_NAT_RANGE_MAP_IPS &&
+	    !l3proto->in_range(tuple, range))
+		return 0;
 
-	rcu_read_lock();
-	proto = __nf_nat_proto_find(tuple->dst.protonum);
 	if (!(range->flags & NF_NAT_RANGE_PROTO_SPECIFIED) ||
-	    proto->in_range(tuple, NF_NAT_MANIP_SRC,
-			    &range->min, &range->max))
-		ret = 1;
-	rcu_read_unlock();
+	    l4proto->in_range(tuple, NF_NAT_MANIP_SRC,
+			      &range->min_proto, &range->max_proto))
+		return 1;
 
-	return ret;
+	return 0;
 }
 
 static inline int
@@ -113,24 +173,25 @@ same_src(const struct nf_conn *ct,
 
 	t = &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple;
 	return (t->dst.protonum == tuple->dst.protonum &&
-		t->src.u3.ip == tuple->src.u3.ip &&
+		nf_inet_addr_cmp(&t->src.u3, &tuple->src.u3) &&
 		t->src.u.all == tuple->src.u.all);
 }
 
 /* Only called for SRC manip */
 static int
 find_appropriate_src(struct net *net, u16 zone,
+		     const struct nf_nat_l3proto *l3proto,
+		     const struct nf_nat_l4proto *l4proto,
 		     const struct nf_conntrack_tuple *tuple,
 		     struct nf_conntrack_tuple *result,
-		     const struct nf_nat_ipv4_range *range)
+		     const struct nf_nat_range *range)
 {
 	unsigned int h = hash_by_src(net, zone, tuple);
 	const struct nf_conn_nat *nat;
 	const struct nf_conn *ct;
 	const struct hlist_node *n;
 
-	rcu_read_lock();
-	hlist_for_each_entry_rcu(nat, n, &net->ipv4.nat_bysource[h], bysource) {
+	hlist_for_each_entry_rcu(nat, n, &net->ct.nat_bysource[h], bysource) {
 		ct = nat->ct;
 		if (same_src(ct, tuple) && nf_ct_zone(ct) == zone) {
 			/* Copy source part from reply tuple. */
@@ -138,44 +199,43 @@ find_appropriate_src(struct net *net, u16 zone,
 				       &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 			result->dst = tuple->dst;
 
-			if (in_range(result, range)) {
+			if (in_range(l3proto, l4proto, result, range)) {
 				rcu_read_unlock();
 				return 1;
 			}
 		}
 	}
-	rcu_read_unlock();
 	return 0;
 }
 
 /* For [FUTURE] fragmentation handling, we want the least-used
-   src-ip/dst-ip/proto triple.  Fairness doesn't come into it.  Thus
-   if the range specifies 1.2.3.4 ports 10000-10005 and 1.2.3.5 ports
-   1-65535, we don't do pro-rata allocation based on ports; we choose
-   the ip with the lowest src-ip/dst-ip/proto usage.
-*/
+ * src-ip/dst-ip/proto triple.  Fairness doesn't come into it.  Thus
+ * if the range specifies 1.2.3.4 ports 10000-10005 and 1.2.3.5 ports
+ * 1-65535, we don't do pro-rata allocation based on ports; we choose
+ * the ip with the lowest src-ip/dst-ip/proto usage.
+ */
 static void
 find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
-		    const struct nf_nat_ipv4_range *range,
+		    const struct nf_nat_range *range,
 		    const struct nf_conn *ct,
 		    enum nf_nat_manip_type maniptype)
 {
-	__be32 *var_ipp;
+	union nf_inet_addr *var_ipp;
 	/* Host order */
-	u_int32_t minip, maxip, j;
+	u64 minip, maxip, j;
 
 	/* No IP mapping?  Do nothing. */
 	if (!(range->flags & NF_NAT_RANGE_MAP_IPS))
 		return;
 
 	if (maniptype == NF_NAT_MANIP_SRC)
-		var_ipp = &tuple->src.u3.ip;
+		var_ipp = &tuple->src.u3;
 	else
-		var_ipp = &tuple->dst.u3.ip;
+		var_ipp = &tuple->dst.u3;
 
 	/* Fast path: only one choice. */
-	if (range->min_ip == range->max_ip) {
-		*var_ipp = range->min_ip;
+	if (nf_inet_addr_cmp(&range->min_addr, &range->max_addr)) {
+		*var_ipp = range->min_addr;
 		return;
 	}
 
@@ -184,73 +244,86 @@ find_best_ips_proto(u16 zone, struct nf_conntrack_tuple *tuple,
 	 * involved, there usually aren't that many connections
 	 * anyway).  The consistency means that servers see the same
 	 * client coming from the same IP (some Internet Banking sites
-	 * like this), even across reboots. */
-	minip = ntohl(range->min_ip);
-	maxip = ntohl(range->max_ip);
-	j = jhash_2words((__force u32)tuple->src.u3.ip,
-			 range->flags & NF_NAT_RANGE_PERSISTENT ?
-				0 : (__force u32)tuple->dst.u3.ip ^ zone, 0);
+	 * like this), even across reboots.
+	 */
+	minip = (u64)ntohl(range->min_addr.all[1]) << 32 |
+		     ntohl(range->min_addr.all[0]);
+	maxip = (u64)ntohl(range->max_addr.all[1]) << 32 |
+		     ntohl(range->max_addr.all[0]);
+
+	j = jhash2((u32 *)&tuple->src.u3, sizeof(tuple->src.u3),
+		   range->flags & NF_NAT_RANGE_PERSISTENT ?
+			0 : (__force u32)tuple->dst.u3.all[0] ^ zone);
 	j = ((u64)j * (maxip - minip + 1)) >> 32;
-	*var_ipp = htonl(minip + j);
+
+	var_ipp->all[3] = range->min_addr.all[3];
+	var_ipp->all[2] = range->min_addr.all[2];
+	var_ipp->all[1] = range->min_addr.all[1];
+	var_ipp->all[0] = htonl(minip + j);
 }
 
-/* Manipulate the tuple into the range given.  For NF_INET_POST_ROUTING,
- * we change the source to map into the range.  For NF_INET_PRE_ROUTING
+/* Manipulate the tuple into the range given. For NF_INET_POST_ROUTING,
+ * we change the source to map into the range. For NF_INET_PRE_ROUTING
  * and NF_INET_LOCAL_OUT, we change the destination to map into the
- * range.  It might not be possible to get a unique tuple, but we try.
+ * range. It might not be possible to get a unique tuple, but we try.
  * At worst (or if we race), we will end up with a final duplicate in
  * __ip_conntrack_confirm and drop the packet. */
 static void
 get_unique_tuple(struct nf_conntrack_tuple *tuple,
 		 const struct nf_conntrack_tuple *orig_tuple,
-		 const struct nf_nat_ipv4_range *range,
+		 const struct nf_nat_range *range,
 		 struct nf_conn *ct,
 		 enum nf_nat_manip_type maniptype)
 {
+	const struct nf_nat_l3proto *l3proto;
+	const struct nf_nat_l4proto *l4proto;
 	struct net *net = nf_ct_net(ct);
-	const struct nf_nat_protocol *proto;
 	u16 zone = nf_ct_zone(ct);
 
-	/* 1) If this srcip/proto/src-proto-part is currently mapped,
-	   and that same mapping gives a unique tuple within the given
-	   range, use that.
+	rcu_read_lock();
+	l3proto = __nf_nat_l3proto_find(orig_tuple->src.l3num);
+	l4proto = __nf_nat_l4proto_find(orig_tuple->src.l3num,
+					orig_tuple->dst.protonum);
 
-	   This is only required for source (ie. NAT/masq) mappings.
-	   So far, we don't do local source mappings, so multiple
-	   manips not an issue.  */
+	/* 1) If this srcip/proto/src-proto-part is currently mapped,
+	 * and that same mapping gives a unique tuple within the given
+	 * range, use that.
+	 *
+	 * This is only required for source (ie. NAT/masq) mappings.
+	 * So far, we don't do local source mappings, so multiple
+	 * manips not an issue.
+	 */
 	if (maniptype == NF_NAT_MANIP_SRC &&
 	    !(range->flags & NF_NAT_RANGE_PROTO_RANDOM)) {
 		/* try the original tuple first */
-		if (in_range(orig_tuple, range)) {
+		if (in_range(l3proto, l4proto, orig_tuple, range)) {
 			if (!nf_nat_used_tuple(orig_tuple, ct)) {
 				*tuple = *orig_tuple;
-				return;
+				goto out;
 			}
-		} else if (find_appropriate_src(net, zone, orig_tuple, tuple,
-			   range)) {
+		} else if (find_appropriate_src(net, zone, l3proto, l4proto,
+						orig_tuple, tuple, range)) {
 			pr_debug("get_unique_tuple: Found current src map\n");
 			if (!nf_nat_used_tuple(tuple, ct))
-				return;
+				goto out;
 		}
 	}
 
-	/* 2) Select the least-used IP/proto combination in the given
-	   range. */
+	/* 2) Select the least-used IP/proto combination in the given range */
 	*tuple = *orig_tuple;
 	find_best_ips_proto(zone, tuple, range, ct, maniptype);
 
 	/* 3) The per-protocol part of the manip is made to map into
-	   the range to make a unique tuple. */
-
-	rcu_read_lock();
-	proto = __nf_nat_proto_find(orig_tuple->dst.protonum);
+	 * the range to make a unique tuple.
+	 */
 
 	/* Only bother mapping if it's not already in range and unique */
 	if (!(range->flags & NF_NAT_RANGE_PROTO_RANDOM)) {
 		if (range->flags & NF_NAT_RANGE_PROTO_SPECIFIED) {
-			if (proto->in_range(tuple, maniptype, &range->min,
-					    &range->max) &&
-			    (range->min.all == range->max.all ||
+			if (l4proto->in_range(tuple, maniptype,
+					      &range->min_proto,
+					      &range->max_proto) &&
+			    (range->min_proto.all == range->max_proto.all ||
 			     !nf_nat_used_tuple(tuple, ct)))
 				goto out;
 		} else if (!nf_nat_used_tuple(tuple, ct)) {
@@ -259,14 +332,14 @@ get_unique_tuple(struct nf_conntrack_tuple *tuple,
 	}
 
 	/* Last change: get protocol to try to obtain unique tuple. */
-	proto->unique_tuple(tuple, range, maniptype, ct);
+	l4proto->unique_tuple(l3proto, tuple, range, maniptype, ct);
 out:
 	rcu_read_unlock();
 }
 
 unsigned int
 nf_nat_setup_info(struct nf_conn *ct,
-		  const struct nf_nat_ipv4_range *range,
+		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype)
 {
 	struct net *net = nf_ct_net(ct);
@@ -288,10 +361,10 @@ nf_nat_setup_info(struct nf_conn *ct,
 	BUG_ON(nf_nat_initialized(ct, maniptype));
 
 	/* What we've got will look like inverse of reply. Normally
-	   this is what is in the conntrack, except for prior
-	   manipulations (future optimization: if num_manips == 0,
-	   orig_tp =
-	   conntrack->tuplehash[IP_CT_DIR_ORIGINAL].tuple) */
+	 * this is what is in the conntrack, except for prior
+	 * manipulations (future optimization: if num_manips == 0,
+	 * orig_tp = ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple)
+	 */
 	nf_ct_invert_tuplepr(&curr_tuple,
 			     &ct->tuplehash[IP_CT_DIR_REPLY].tuple);
 
@@ -321,7 +394,7 @@ nf_nat_setup_info(struct nf_conn *ct,
 		nat = nfct_nat(ct);
 		nat->ct = ct;
 		hlist_add_head_rcu(&nat->bysource,
-				   &net->ipv4.nat_bysource[srchash]);
+				   &net->ct.nat_bysource[srchash]);
 		spin_unlock_bh(&nf_nat_lock);
 	}
 
@@ -335,47 +408,14 @@ nf_nat_setup_info(struct nf_conn *ct,
 }
 EXPORT_SYMBOL(nf_nat_setup_info);
 
-/* Returns true if succeeded. */
-static bool
-manip_pkt(u_int16_t proto,
-	  struct sk_buff *skb,
-	  unsigned int iphdroff,
-	  const struct nf_conntrack_tuple *target,
-	  enum nf_nat_manip_type maniptype)
-{
-	struct iphdr *iph;
-	const struct nf_nat_protocol *p;
-
-	if (!skb_make_writable(skb, iphdroff + sizeof(*iph)))
-		return false;
-
-	iph = (void *)skb->data + iphdroff;
-
-	/* Manipulate protcol part. */
-
-	/* rcu_read_lock()ed by nf_hook_slow */
-	p = __nf_nat_proto_find(proto);
-	if (!p->manip_pkt(skb, iphdroff, target, maniptype))
-		return false;
-
-	iph = (void *)skb->data + iphdroff;
-
-	if (maniptype == NF_NAT_MANIP_SRC) {
-		csum_replace4(&iph->check, iph->saddr, target->src.u3.ip);
-		iph->saddr = target->src.u3.ip;
-	} else {
-		csum_replace4(&iph->check, iph->daddr, target->dst.u3.ip);
-		iph->daddr = target->dst.u3.ip;
-	}
-	return true;
-}
-
 /* Do packet manipulations according to nf_nat_setup_info. */
 unsigned int nf_nat_packet(struct nf_conn *ct,
 			   enum ip_conntrack_info ctinfo,
 			   unsigned int hooknum,
 			   struct sk_buff *skb)
 {
+	const struct nf_nat_l3proto *l3proto;
+	const struct nf_nat_l4proto *l4proto;
 	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
 	unsigned long statusbit;
 	enum nf_nat_manip_type mtype = HOOK2MANIP(hooknum);
@@ -396,129 +436,94 @@ unsigned int nf_nat_packet(struct nf_conn *ct,
 		/* We are aiming to look like inverse of other direction. */
 		nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
 
-		if (!manip_pkt(target.dst.protonum, skb, 0, &target, mtype))
+		l3proto = __nf_nat_l3proto_find(target.src.l3num);
+		l4proto = __nf_nat_l4proto_find(target.src.l3num,
+						target.dst.protonum);
+		if (!l3proto->manip_pkt(skb, 0, l4proto, &target, mtype))
 			return NF_DROP;
 	}
 	return NF_ACCEPT;
 }
 EXPORT_SYMBOL_GPL(nf_nat_packet);
 
-/* Dir is direction ICMP is coming from (opposite to packet it contains) */
-int nf_nat_icmp_reply_translation(struct nf_conn *ct,
-				  enum ip_conntrack_info ctinfo,
-				  unsigned int hooknum,
-				  struct sk_buff *skb)
-{
-	struct {
-		struct icmphdr icmp;
-		struct iphdr ip;
-	} *inside;
-	struct nf_conntrack_tuple target;
-	int hdrlen = ip_hdrlen(skb);
-	enum ip_conntrack_dir dir = CTINFO2DIR(ctinfo);
-	unsigned long statusbit;
-	enum nf_nat_manip_type manip = HOOK2MANIP(hooknum);
-
-	if (!skb_make_writable(skb, hdrlen + sizeof(*inside)))
-		return 0;
-
-	inside = (void *)skb->data + hdrlen;
-
-	/* We're actually going to mangle it beyond trivial checksum
-	   adjustment, so make sure the current checksum is correct. */
-	if (nf_ip_checksum(skb, hooknum, hdrlen, 0))
-		return 0;
-
-	/* Must be RELATED */
-	NF_CT_ASSERT(skb->nfctinfo == IP_CT_RELATED ||
-		     skb->nfctinfo == IP_CT_RELATED_REPLY);
-
-	/* Redirects on non-null nats must be dropped, else they'll
-	   start talking to each other without our translation, and be
-	   confused... --RR */
-	if (inside->icmp.type == ICMP_REDIRECT) {
-		/* If NAT isn't finished, assume it and drop. */
-		if ((ct->status & IPS_NAT_DONE_MASK) != IPS_NAT_DONE_MASK)
-			return 0;
-
-		if (ct->status & IPS_NAT_MASK)
-			return 0;
-	}
-
-	if (manip == NF_NAT_MANIP_SRC)
-		statusbit = IPS_SRC_NAT;
-	else
-		statusbit = IPS_DST_NAT;
-
-	/* Invert if this is reply dir. */
-	if (dir == IP_CT_DIR_REPLY)
-		statusbit ^= IPS_NAT_MASK;
-
-	if (!(ct->status & statusbit))
-		return 1;
-
-	pr_debug("icmp_reply_translation: translating error %p manip %u "
-		 "dir %s\n", skb, manip,
-		 dir == IP_CT_DIR_ORIGINAL ? "ORIG" : "REPLY");
-
-	/* Change inner back to look like incoming packet.  We do the
-	   opposite manip on this hook to normal, because it might not
-	   pass all hooks (locally-generated ICMP).  Consider incoming
-	   packet: PREROUTING (DST manip), routing produces ICMP, goes
-	   through POSTROUTING (which must correct the DST manip). */
-	if (!manip_pkt(inside->ip.protocol, skb, hdrlen + sizeof(inside->icmp),
-		       &ct->tuplehash[!dir].tuple, !manip))
-		return 0;
-
-	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		/* Reloading "inside" here since manip_pkt inner. */
-		inside = (void *)skb->data + hdrlen;
-		inside->icmp.checksum = 0;
-		inside->icmp.checksum =
-			csum_fold(skb_checksum(skb, hdrlen,
-					       skb->len - hdrlen, 0));
-	}
-
-	/* Change outer to look the reply to an incoming packet
-	 * (proto 0 means don't invert per-proto part). */
-	nf_ct_invert_tuplepr(&target, &ct->tuplehash[!dir].tuple);
-	if (!manip_pkt(0, skb, 0, &target, manip))
-		return 0;
-
-	return 1;
-}
-EXPORT_SYMBOL_GPL(nf_nat_icmp_reply_translation);
-
 /* Protocol registration. */
-int nf_nat_protocol_register(const struct nf_nat_protocol *proto)
+int nf_nat_l4proto_register(u8 l3proto, const struct nf_nat_l4proto *l4proto)
 {
+	const struct nf_nat_l4proto **l4protos;
+	unsigned int i;
 	int ret = 0;
 
 	spin_lock_bh(&nf_nat_lock);
+	if (nf_nat_l4protos[l3proto] == NULL) {
+		l4protos = kmalloc(IPPROTO_MAX * sizeof(struct nf_nat_l4proto *),
+				   GFP_ATOMIC);
+		if (l4protos == NULL) {
+			ret = -ENOMEM;
+			goto out;
+		}
+		for (i = 0; i < IPPROTO_MAX; i++)
+			RCU_INIT_POINTER(l4protos[i], &nf_nat_l4proto_unknown);
+
+		nf_nat_l4protos[l3proto] = l4protos;
+	}
+
 	if (rcu_dereference_protected(
-			nf_nat_protos[proto->protonum],
+			nf_nat_l4protos[l3proto][l4proto->l4proto],
 			lockdep_is_held(&nf_nat_lock)
-			) != &nf_nat_unknown_protocol) {
+			) != &nf_nat_l4proto_unknown) {
 		ret = -EBUSY;
 		goto out;
 	}
-	RCU_INIT_POINTER(nf_nat_protos[proto->protonum], proto);
+	RCU_INIT_POINTER(nf_nat_l4protos[l3proto][l4proto->l4proto], l4proto);
  out:
 	spin_unlock_bh(&nf_nat_lock);
 	return ret;
 }
-EXPORT_SYMBOL(nf_nat_protocol_register);
+EXPORT_SYMBOL_GPL(nf_nat_l4proto_register);
 
 /* No one stores the protocol anywhere; simply delete it. */
-void nf_nat_protocol_unregister(const struct nf_nat_protocol *proto)
+void nf_nat_l4proto_unregister(u8 l3proto, const struct nf_nat_l4proto *l4proto)
 {
 	spin_lock_bh(&nf_nat_lock);
-	RCU_INIT_POINTER(nf_nat_protos[proto->protonum],
-			   &nf_nat_unknown_protocol);
+	RCU_INIT_POINTER(nf_nat_l4protos[l3proto][l4proto->l4proto],
+			 &nf_nat_l4proto_unknown);
 	spin_unlock_bh(&nf_nat_lock);
 	synchronize_rcu();
 }
-EXPORT_SYMBOL(nf_nat_protocol_unregister);
+EXPORT_SYMBOL_GPL(nf_nat_l4proto_unregister);
+
+int nf_nat_l3proto_register(const struct nf_nat_l3proto *l3proto)
+{
+	int err;
+
+	err = nf_ct_l3proto_try_module_get(l3proto->l3proto);
+	if (err < 0)
+		return err;
+
+	spin_lock_bh(&nf_nat_lock);
+	RCU_INIT_POINTER(nf_nat_l4protos[l3proto->l3proto][IPPROTO_TCP],
+			 &nf_nat_l4proto_tcp);
+	RCU_INIT_POINTER(nf_nat_l4protos[l3proto->l3proto][IPPROTO_UDP],
+			 &nf_nat_l4proto_udp);
+	spin_unlock_bh(&nf_nat_lock);
+
+	RCU_INIT_POINTER(nf_nat_l3protos[l3proto->l3proto], l3proto);
+	return 0;
+}
+EXPORT_SYMBOL_GPL(nf_nat_l3proto_register);
+
+static void nf_nat_clean_l3proto(u8 l3proto);
+
+void nf_nat_l3proto_unregister(const struct nf_nat_l3proto *l3proto)
+{
+	RCU_INIT_POINTER(nf_nat_l3protos[l3proto->l3proto], NULL);
+	synchronize_rcu();
+	kfree(nf_nat_l4protos[l3proto->l3proto]);
+	nf_nat_l4protos[l3proto->l3proto] = NULL;
+	nf_nat_clean_l3proto(l3proto->l3proto);
+	nf_ct_l3proto_module_put(l3proto->l3proto);
+}
+EXPORT_SYMBOL_GPL(nf_nat_l3proto_unregister);
 
 /* No one using conntrack by the time this called. */
 static void nf_nat_cleanup_conntrack(struct nf_conn *ct)
@@ -570,34 +575,34 @@ static const struct nla_policy protonat_nla_policy[CTA_PROTONAT_MAX+1] = {
 
 static int nfnetlink_parse_nat_proto(struct nlattr *attr,
 				     const struct nf_conn *ct,
-				     struct nf_nat_ipv4_range *range)
+				     struct nf_nat_range *range)
 {
 	struct nlattr *tb[CTA_PROTONAT_MAX+1];
-	const struct nf_nat_protocol *npt;
+	const struct nf_nat_l4proto *l4proto;
 	int err;
 
 	err = nla_parse_nested(tb, CTA_PROTONAT_MAX, attr, protonat_nla_policy);
 	if (err < 0)
 		return err;
 
-	rcu_read_lock();
-	npt = __nf_nat_proto_find(nf_ct_protonum(ct));
-	if (npt->nlattr_to_range)
-		err = npt->nlattr_to_range(tb, range);
-	rcu_read_unlock();
+	l4proto = __nf_nat_l4proto_find(nf_ct_l3num(ct), nf_ct_protonum(ct));
+	if (l4proto->nlattr_to_range)
+		err = l4proto->nlattr_to_range(tb, range);
+
 	return err;
 }
 
 static const struct nla_policy nat_nla_policy[CTA_NAT_MAX+1] = {
-	[CTA_NAT_MINIP]		= { .type = NLA_U32 },
-	[CTA_NAT_MAXIP]		= { .type = NLA_U32 },
+	[CTA_NAT_V4_MINIP]	= { .type = NLA_U32 },
+	[CTA_NAT_V4_MAXIP]	= { .type = NLA_U32 },
 	[CTA_NAT_PROTO]		= { .type = NLA_NESTED },
 };
 
 static int
 nfnetlink_parse_nat(const struct nlattr *nat,
-		    const struct nf_conn *ct, struct nf_nat_ipv4_range *range)
+		    const struct nf_conn *ct, struct nf_nat_range *range)
 {
+	const struct nf_nat_l3proto *l3proto;
 	struct nlattr *tb[CTA_NAT_MAX+1];
 	int err;
 
@@ -607,25 +612,23 @@ nfnetlink_parse_nat(const struct nlattr *nat,
 	if (err < 0)
 		return err;
 
-	if (tb[CTA_NAT_MINIP])
-		range->min_ip = nla_get_be32(tb[CTA_NAT_MINIP]);
-
-	if (!tb[CTA_NAT_MAXIP])
-		range->max_ip = range->min_ip;
-	else
-		range->max_ip = nla_get_be32(tb[CTA_NAT_MAXIP]);
-
-	if (range->min_ip)
-		range->flags |= NF_NAT_RANGE_MAP_IPS;
+	rcu_read_lock();
+	l3proto = __nf_nat_l3proto_find(nf_ct_l3num(ct));
+	if (l3proto == NULL) {
+		err = -EAGAIN;
+		goto out;
+	}
+	err = l3proto->nlattr_to_range(tb, range);
+	if (err < 0)
+		goto out;
 
 	if (!tb[CTA_NAT_PROTO])
-		return 0;
+		goto out;
 
 	err = nfnetlink_parse_nat_proto(tb[CTA_NAT_PROTO], ct, range);
-	if (err < 0)
-		return err;
-
-	return 0;
+out:
+	rcu_read_unlock();
+	return err;
 }
 
 static int
@@ -633,10 +636,12 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 			  enum nf_nat_manip_type manip,
 			  const struct nlattr *attr)
 {
-	struct nf_nat_ipv4_range range;
+	struct nf_nat_range range;
+	int err;
 
-	if (nfnetlink_parse_nat(attr, ct, &range) < 0)
-		return -EINVAL;
+	err = nfnetlink_parse_nat(attr, ct, &range);
+	if (err < 0)
+		return err;
 	if (nf_nat_initialized(ct, manip))
 		return -EEXIST;
 
@@ -655,9 +660,9 @@ nfnetlink_parse_nat_setup(struct nf_conn *ct,
 static int __net_init nf_nat_net_init(struct net *net)
 {
 	/* Leave them the same for the moment. */
-	net->ipv4.nat_htable_size = net->ct.htable_size;
-	net->ipv4.nat_bysource = nf_ct_alloc_hashtable(&net->ipv4.nat_htable_size, 0);
-	if (!net->ipv4.nat_bysource)
+	net->ct.nat_htable_size = net->ct.htable_size;
+	net->ct.nat_bysource = nf_ct_alloc_hashtable(&net->ct.nat_htable_size, 0);
+	if (!net->ct.nat_bysource)
 		return -ENOMEM;
 	return 0;
 }
@@ -666,19 +671,30 @@ static int __net_init nf_nat_net_init(struct net *net)
 static int clean_nat(struct nf_conn *i, void *data)
 {
 	struct nf_conn_nat *nat = nfct_nat(i);
+	u8 l3proto = (long)data;
 
 	if (!nat)
 		return 0;
+	if (l3proto && nf_ct_l3num(i) != l3proto)
+		return 0;
 	memset(nat, 0, sizeof(*nat));
 	i->status &= ~(IPS_NAT_MASK | IPS_NAT_DONE_MASK | IPS_SEQ_ADJUST);
 	return 0;
 }
 
+static void nf_nat_clean_l3proto(u8 l3proto)
+{
+	struct net *net;
+
+	for_each_net(net)
+		nf_ct_iterate_cleanup(net, clean_nat, (void *)(long)l3proto);
+}
+
 static void __net_exit nf_nat_net_exit(struct net *net)
 {
 	nf_ct_iterate_cleanup(net, &clean_nat, NULL);
 	synchronize_rcu();
-	nf_ct_free_hashtable(net->ipv4.nat_bysource, net->ipv4.nat_htable_size);
+	nf_ct_free_hashtable(net->ct.nat_bysource, net->ct.nat_htable_size);
 }
 
 static struct pernet_operations nf_nat_net_ops = {
@@ -688,11 +704,8 @@ static struct pernet_operations nf_nat_net_ops = {
 
 static int __init nf_nat_init(void)
 {
-	size_t i;
 	int ret;
 
-	need_ipv4_conntrack();
-
 	ret = nf_ct_extend_register(&nat_extend);
 	if (ret < 0) {
 		printk(KERN_ERR "nf_nat_core: Unable to register extension\n");
@@ -703,20 +716,9 @@ static int __init nf_nat_init(void)
 	if (ret < 0)
 		goto cleanup_extend;
 
-	/* Sew in builtin protocols. */
-	spin_lock_bh(&nf_nat_lock);
-	for (i = 0; i < MAX_IP_NAT_PROTO; i++)
-		RCU_INIT_POINTER(nf_nat_protos[i], &nf_nat_unknown_protocol);
-	RCU_INIT_POINTER(nf_nat_protos[IPPROTO_TCP], &nf_nat_protocol_tcp);
-	RCU_INIT_POINTER(nf_nat_protos[IPPROTO_UDP], &nf_nat_protocol_udp);
-	RCU_INIT_POINTER(nf_nat_protos[IPPROTO_ICMP], &nf_nat_protocol_icmp);
-	spin_unlock_bh(&nf_nat_lock);
-
 	/* Initialize fake conntrack so that NAT will skip it */
 	nf_ct_untracked_status_or(IPS_NAT_DONE_MASK);
 
-	l3proto = nf_ct_l3proto_find_get((u_int16_t)AF_INET);
-
 	BUG_ON(nf_nat_seq_adjust_hook != NULL);
 	RCU_INIT_POINTER(nf_nat_seq_adjust_hook, nf_nat_seq_adjust);
 	BUG_ON(nfnetlink_parse_nat_setup_hook != NULL);
@@ -724,6 +726,10 @@ static int __init nf_nat_init(void)
 			   nfnetlink_parse_nat_setup);
 	BUG_ON(nf_ct_nat_offset != NULL);
 	RCU_INIT_POINTER(nf_ct_nat_offset, nf_nat_get_offset);
+#ifdef CONFIG_XFRM
+	BUG_ON(nf_nat_decode_session_hook != NULL);
+	RCU_INIT_POINTER(nf_nat_decode_session_hook, __nf_nat_decode_session);
+#endif
 	return 0;
 
  cleanup_extend:
@@ -733,17 +739,22 @@ static int __init nf_nat_init(void)
 
 static void __exit nf_nat_cleanup(void)
 {
+	unsigned int i;
+
 	unregister_pernet_subsys(&nf_nat_net_ops);
-	nf_ct_l3proto_put(l3proto);
 	nf_ct_extend_unregister(&nat_extend);
 	RCU_INIT_POINTER(nf_nat_seq_adjust_hook, NULL);
 	RCU_INIT_POINTER(nfnetlink_parse_nat_setup_hook, NULL);
 	RCU_INIT_POINTER(nf_ct_nat_offset, NULL);
+#ifdef CONFIG_XFRM
+	RCU_INIT_POINTER(nf_nat_decode_session_hook, NULL);
+#endif
+	for (i = 0; i < NFPROTO_NUMPROTO; i++)
+		kfree(nf_nat_l4protos[i]);
 	synchronize_net();
 }
 
 MODULE_LICENSE("GPL");
-MODULE_ALIAS("nf-nat-ipv4");
 
 module_init(nf_nat_init);
 module_exit(nf_nat_cleanup);
diff --git a/net/ipv4/netfilter/nf_nat_helper.c b/net/netfilter/nf_nat_helper.c
similarity index 82%
rename from net/ipv4/netfilter/nf_nat_helper.c
rename to net/netfilter/nf_nat_helper.c
index 629da48..a2a8eb0 100644
--- a/net/ipv4/netfilter/nf_nat_helper.c
+++ b/net/netfilter/nf_nat_helper.c
@@ -1,4 +1,4 @@
-/* ip_nat_helper.c - generic support functions for NAT helpers
+/* nf_nat_helper.c - generic support functions for NAT helpers
  *
  * (C) 2000-2002 Harald Welte <laforge@netfilter.org>
  * (C) 2003-2006 Netfilter Core Team <coreteam@netfilter.org>
@@ -9,23 +9,19 @@
  */
 #include <linux/module.h>
 #include <linux/gfp.h>
-#include <linux/kmod.h>
 #include <linux/types.h>
-#include <linux/timer.h>
 #include <linux/skbuff.h>
 #include <linux/tcp.h>
 #include <linux/udp.h>
-#include <net/checksum.h>
 #include <net/tcp.h>
-#include <net/route.h>
 
-#include <linux/netfilter_ipv4.h>
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_conntrack_helper.h>
 #include <net/netfilter/nf_conntrack_ecache.h>
 #include <net/netfilter/nf_conntrack_expect.h>
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 #include <net/netfilter/nf_nat_core.h>
 #include <net/netfilter/nf_nat_helper.h>
 
@@ -90,7 +86,6 @@ s16 nf_nat_get_offset(const struct nf_conn *ct,
 
 	return offset;
 }
-EXPORT_SYMBOL_GPL(nf_nat_get_offset);
 
 /* Frobs data inside this packet, which is linear. */
 static void mangle_contents(struct sk_buff *skb,
@@ -125,9 +120,13 @@ static void mangle_contents(struct sk_buff *skb,
 		__skb_trim(skb, skb->len + rep_len - match_len);
 	}
 
-	/* fix IP hdr checksum information */
-	ip_hdr(skb)->tot_len = htons(skb->len);
-	ip_send_check(ip_hdr(skb));
+	if (nf_ct_l3num((struct nf_conn *)skb->nfct) == NFPROTO_IPV4) {
+		/* fix IP hdr checksum information */
+		ip_hdr(skb)->tot_len = htons(skb->len);
+		ip_send_check(ip_hdr(skb));
+	} else
+		ipv6_hdr(skb)->payload_len =
+			htons(skb->len - sizeof(struct ipv6hdr));
 }
 
 /* Unusual, but possible case. */
@@ -153,35 +152,6 @@ void nf_nat_set_seq_adjust(struct nf_conn *ct, enum ip_conntrack_info ctinfo,
 }
 EXPORT_SYMBOL_GPL(nf_nat_set_seq_adjust);
 
-static void nf_nat_csum(struct sk_buff *skb, const struct iphdr *iph, void *data,
-			int datalen, __sum16 *check, int oldlen)
-{
-	struct rtable *rt = skb_rtable(skb);
-
-	if (skb->ip_summed != CHECKSUM_PARTIAL) {
-		if (!(rt->rt_flags & RTCF_LOCAL) &&
-		    (!skb->dev || skb->dev->features & NETIF_F_V4_CSUM)) {
-			skb->ip_summed = CHECKSUM_PARTIAL;
-			skb->csum_start = skb_headroom(skb) +
-					  skb_network_offset(skb) +
-					  iph->ihl * 4;
-			skb->csum_offset = (void *)check - data;
-			*check = ~csum_tcpudp_magic(iph->saddr, iph->daddr,
-						    datalen, iph->protocol, 0);
-		} else {
-			*check = 0;
-			*check = csum_tcpudp_magic(iph->saddr, iph->daddr,
-						   datalen, iph->protocol,
-						   csum_partial(data, datalen,
-								0));
-			if (iph->protocol == IPPROTO_UDP && !*check)
-				*check = CSUM_MANGLED_0;
-		}
-	} else
-		inet_proto_csum_replace2(check, skb,
-					 htons(oldlen), htons(datalen), 1);
-}
-
 /* Generic function for mangling variable-length address changes inside
  * NATed TCP connections (like the PORT XXX,XXX,XXX,XXX,XXX,XXX
  * command in FTP).
@@ -199,7 +169,7 @@ int __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 			       const char *rep_buffer,
 			       unsigned int rep_len, bool adjust)
 {
-	struct iphdr *iph;
+	const struct nf_nat_l3proto *l3proto;
 	struct tcphdr *tcph;
 	int oldlen, datalen;
 
@@ -213,15 +183,17 @@ int __nf_nat_mangle_tcp_packet(struct sk_buff *skb,
 
 	SKB_LINEAR_ASSERT(skb);
 
-	iph = ip_hdr(skb);
-	tcph = (void *)iph + iph->ihl*4;
+	tcph = (void *)skb->data + protoff;
 
-	oldlen = skb->len - iph->ihl*4;
-	mangle_contents(skb, iph->ihl*4 + tcph->doff*4,
+	oldlen = skb->len - protoff;
+	mangle_contents(skb, protoff + tcph->doff*4,
 			match_offset, match_len, rep_buffer, rep_len);
 
-	datalen = skb->len - iph->ihl*4;
-	nf_nat_csum(skb, iph, tcph, datalen, &tcph->check, oldlen);
+	datalen = skb->len - protoff;
+
+	l3proto = __nf_nat_l3proto_find(nf_ct_l3num(ct));
+	l3proto->csum_recalc(skb, IPPROTO_TCP, tcph, &tcph->check,
+			     datalen, oldlen);
 
 	if (adjust && rep_len != match_len)
 		nf_nat_set_seq_adjust(ct, ctinfo, tcph->seq,
@@ -251,7 +223,7 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 			 const char *rep_buffer,
 			 unsigned int rep_len)
 {
-	struct iphdr *iph;
+	const struct nf_nat_l3proto *l3proto;
 	struct udphdr *udph;
 	int datalen, oldlen;
 
@@ -263,22 +235,23 @@ nf_nat_mangle_udp_packet(struct sk_buff *skb,
 	    !enlarge_skb(skb, rep_len - match_len))
 		return 0;
 
-	iph = ip_hdr(skb);
-	udph = (void *)iph + iph->ihl*4;
+	udph = (void *)skb->data + protoff;
 
-	oldlen = skb->len - iph->ihl*4;
-	mangle_contents(skb, iph->ihl*4 + sizeof(*udph),
+	oldlen = skb->len - protoff;
+	mangle_contents(skb, protoff + sizeof(*udph),
 			match_offset, match_len, rep_buffer, rep_len);
 
 	/* update the length of the UDP packet */
-	datalen = skb->len - iph->ihl*4;
+	datalen = skb->len - protoff;
 	udph->len = htons(datalen);
 
 	/* fix udp checksum if udp checksum was previously calculated */
 	if (!udph->check && skb->ip_summed != CHECKSUM_PARTIAL)
 		return 1;
 
-	nf_nat_csum(skb, iph, udph, datalen, &udph->check, oldlen);
+	l3proto = __nf_nat_l3proto_find(nf_ct_l3num(ct));
+	l3proto->csum_recalc(skb, IPPROTO_UDP, udph, &udph->check,
+			     datalen, oldlen);
 
 	return 1;
 }
@@ -330,6 +303,7 @@ sack_adjust(struct sk_buff *skb,
 /* TCP SACK sequence number adjustment */
 static inline unsigned int
 nf_nat_sack_adjust(struct sk_buff *skb,
+		   unsigned int protoff,
 		   struct tcphdr *tcph,
 		   struct nf_conn *ct,
 		   enum ip_conntrack_info ctinfo)
@@ -337,8 +311,8 @@ nf_nat_sack_adjust(struct sk_buff *skb,
 	unsigned int dir, optoff, optend;
 	struct nf_conn_nat *nat = nfct_nat(ct);
 
-	optoff = ip_hdrlen(skb) + sizeof(struct tcphdr);
-	optend = ip_hdrlen(skb) + tcph->doff * 4;
+	optoff = protoff + sizeof(struct tcphdr);
+	optend = protoff + tcph->doff * 4;
 
 	if (!skb_make_writable(skb, optend))
 		return 0;
@@ -419,7 +393,7 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 	tcph->seq = newseq;
 	tcph->ack_seq = newack;
 
-	return nf_nat_sack_adjust(skb, tcph, ct, ctinfo);
+	return nf_nat_sack_adjust(skb, protoff, tcph, ct, ctinfo);
 }
 
 /* Setup NAT on this expected conntrack so it follows master. */
@@ -427,22 +401,22 @@ nf_nat_seq_adjust(struct sk_buff *skb,
 void nf_nat_follow_master(struct nf_conn *ct,
 			  struct nf_conntrack_expect *exp)
 {
-	struct nf_nat_ipv4_range range;
+	struct nf_nat_range range;
 
 	/* This must be a fresh one. */
 	BUG_ON(ct->status & IPS_NAT_DONE_MASK);
 
 	/* Change src to where master sends to */
 	range.flags = NF_NAT_RANGE_MAP_IPS;
-	range.min_ip = range.max_ip
-		= ct->master->tuplehash[!exp->dir].tuple.dst.u3.ip;
+	range.min_addr = range.max_addr
+		= ct->master->tuplehash[!exp->dir].tuple.dst.u3;
 	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_SRC);
 
 	/* For DST manip, map port here to where it's expected. */
 	range.flags = (NF_NAT_RANGE_MAP_IPS | NF_NAT_RANGE_PROTO_SPECIFIED);
-	range.min = range.max = exp->saved_proto;
-	range.min_ip = range.max_ip
-		= ct->master->tuplehash[!exp->dir].tuple.src.u3.ip;
+	range.min_proto = range.max_proto = exp->saved_proto;
+	range.min_addr = range.max_addr
+		= ct->master->tuplehash[!exp->dir].tuple.src.u3;
 	nf_nat_setup_info(ct, &range, NF_NAT_MANIP_DST);
 }
 EXPORT_SYMBOL(nf_nat_follow_master);
diff --git a/net/ipv4/netfilter/nf_nat_proto_common.c b/net/netfilter/nf_nat_proto_common.c
similarity index 62%
rename from net/ipv4/netfilter/nf_nat_proto_common.c
rename to net/netfilter/nf_nat_proto_common.c
index 9993bc9..9baaf73 100644
--- a/net/ipv4/netfilter/nf_nat_proto_common.c
+++ b/net/netfilter/nf_nat_proto_common.c
@@ -9,20 +9,18 @@
 
 #include <linux/types.h>
 #include <linux/random.h>
-#include <linux/ip.h>
-
 #include <linux/netfilter.h>
 #include <linux/export.h>
-#include <net/secure_seq.h>
+
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
-#include <net/netfilter/nf_nat_rule.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 
-bool nf_nat_proto_in_range(const struct nf_conntrack_tuple *tuple,
-			   enum nf_nat_manip_type maniptype,
-			   const union nf_conntrack_man_proto *min,
-			   const union nf_conntrack_man_proto *max)
+bool nf_nat_l4proto_in_range(const struct nf_conntrack_tuple *tuple,
+			     enum nf_nat_manip_type maniptype,
+			     const union nf_conntrack_man_proto *min,
+			     const union nf_conntrack_man_proto *max)
 {
 	__be16 port;
 
@@ -34,13 +32,14 @@ bool nf_nat_proto_in_range(const struct nf_conntrack_tuple *tuple,
 	return ntohs(port) >= ntohs(min->all) &&
 	       ntohs(port) <= ntohs(max->all);
 }
-EXPORT_SYMBOL_GPL(nf_nat_proto_in_range);
+EXPORT_SYMBOL_GPL(nf_nat_l4proto_in_range);
 
-void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
-			       const struct nf_nat_ipv4_range *range,
-			       enum nf_nat_manip_type maniptype,
-			       const struct nf_conn *ct,
-			       u_int16_t *rover)
+void nf_nat_l4proto_unique_tuple(const struct nf_nat_l3proto *l3proto,
+				 struct nf_conntrack_tuple *tuple,
+				 const struct nf_nat_range *range,
+				 enum nf_nat_manip_type maniptype,
+				 const struct nf_conn *ct,
+				 u16 *rover)
 {
 	unsigned int range_size, min, i;
 	__be16 *portptr;
@@ -71,15 +70,14 @@ void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 			range_size = 65535 - 1024 + 1;
 		}
 	} else {
-		min = ntohs(range->min.all);
-		range_size = ntohs(range->max.all) - min + 1;
+		min = ntohs(range->min_proto.all);
+		range_size = ntohs(range->max_proto.all) - min + 1;
 	}
 
 	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM)
-		off = secure_ipv4_port_ephemeral(tuple->src.u3.ip, tuple->dst.u3.ip,
-						 maniptype == NF_NAT_MANIP_SRC
-						 ? tuple->dst.u.all
-						 : tuple->src.u.all);
+		off = l3proto->secure_port(tuple, maniptype == NF_NAT_MANIP_SRC
+						  ? tuple->dst.u.all
+						  : tuple->src.u.all);
 	else
 		off = *rover;
 
@@ -93,22 +91,22 @@ void nf_nat_proto_unique_tuple(struct nf_conntrack_tuple *tuple,
 	}
 	return;
 }
-EXPORT_SYMBOL_GPL(nf_nat_proto_unique_tuple);
+EXPORT_SYMBOL_GPL(nf_nat_l4proto_unique_tuple);
 
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-int nf_nat_proto_nlattr_to_range(struct nlattr *tb[],
-				 struct nf_nat_ipv4_range *range)
+int nf_nat_l4proto_nlattr_to_range(struct nlattr *tb[],
+				   struct nf_nat_range *range)
 {
 	if (tb[CTA_PROTONAT_PORT_MIN]) {
-		range->min.all = nla_get_be16(tb[CTA_PROTONAT_PORT_MIN]);
-		range->max.all = range->min.tcp.port;
+		range->min_proto.all = nla_get_be16(tb[CTA_PROTONAT_PORT_MIN]);
+		range->max_proto.all = range->min_proto.all;
 		range->flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 	if (tb[CTA_PROTONAT_PORT_MAX]) {
-		range->max.all = nla_get_be16(tb[CTA_PROTONAT_PORT_MAX]);
+		range->max_proto.all = nla_get_be16(tb[CTA_PROTONAT_PORT_MAX]);
 		range->flags |= NF_NAT_RANGE_PROTO_SPECIFIED;
 	}
 	return 0;
 }
-EXPORT_SYMBOL_GPL(nf_nat_proto_nlattr_to_range);
+EXPORT_SYMBOL_GPL(nf_nat_l4proto_nlattr_to_range);
 #endif
diff --git a/net/ipv4/netfilter/nf_nat_proto_dccp.c b/net/netfilter/nf_nat_proto_dccp.c
similarity index 61%
rename from net/ipv4/netfilter/nf_nat_proto_dccp.c
rename to net/netfilter/nf_nat_proto_dccp.c
index 3f67138..c8be2cd 100644
--- a/net/ipv4/netfilter/nf_nat_proto_dccp.c
+++ b/net/netfilter/nf_nat_proto_dccp.c
@@ -1,7 +1,7 @@
 /*
  * DCCP NAT protocol helper
  *
- * Copyright (c) 2005, 2006. 2008 Patrick McHardy <kaber@trash.net>
+ * Copyright (c) 2005, 2006, 2008 Patrick McHardy <kaber@trash.net>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -13,35 +13,34 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/skbuff.h>
-#include <linux/ip.h>
 #include <linux/dccp.h>
 
 #include <net/netfilter/nf_conntrack.h>
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 
 static u_int16_t dccp_port_rover;
 
 static void
-dccp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		  const struct nf_nat_ipv4_range *range,
+dccp_unique_tuple(const struct nf_nat_l3proto *l3proto,
+		  struct nf_conntrack_tuple *tuple,
+		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype,
 		  const struct nf_conn *ct)
 {
-	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
-				  &dccp_port_rover);
+	nf_nat_l4proto_unique_tuple(l3proto, tuple, range, maniptype, ct,
+				    &dccp_port_rover);
 }
 
 static bool
 dccp_manip_pkt(struct sk_buff *skb,
-	       unsigned int iphdroff,
+	       const struct nf_nat_l3proto *l3proto,
+	       unsigned int iphdroff, unsigned int hdroff,
 	       const struct nf_conntrack_tuple *tuple,
 	       enum nf_nat_manip_type maniptype)
 {
-	const struct iphdr *iph = (const void *)(skb->data + iphdroff);
 	struct dccp_hdr *hdr;
-	unsigned int hdroff = iphdroff + iph->ihl * 4;
-	__be32 oldip, newip;
 	__be16 *portptr, oldport, newport;
 	int hdrsize = 8; /* DCCP connection tracking guarantees this much */
 
@@ -51,17 +50,12 @@ dccp_manip_pkt(struct sk_buff *skb,
 	if (!skb_make_writable(skb, hdroff + hdrsize))
 		return false;
 
-	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct dccp_hdr *)(skb->data + hdroff);
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
-		oldip = iph->saddr;
-		newip = tuple->src.u3.ip;
 		newport = tuple->src.u.dccp.port;
 		portptr = &hdr->dccph_sport;
 	} else {
-		oldip = iph->daddr;
-		newip = tuple->dst.u3.ip;
 		newport = tuple->dst.u.dccp.port;
 		portptr = &hdr->dccph_dport;
 	}
@@ -72,30 +66,46 @@ dccp_manip_pkt(struct sk_buff *skb,
 	if (hdrsize < sizeof(*hdr))
 		return true;
 
-	inet_proto_csum_replace4(&hdr->dccph_checksum, skb, oldip, newip, 1);
+	l3proto->csum_update(skb, iphdroff, &hdr->dccph_checksum,
+			     tuple, maniptype);
 	inet_proto_csum_replace2(&hdr->dccph_checksum, skb, oldport, newport,
 				 0);
 	return true;
 }
 
-static const struct nf_nat_protocol nf_nat_protocol_dccp = {
-	.protonum		= IPPROTO_DCCP,
+static const struct nf_nat_l4proto nf_nat_l4proto_dccp = {
+	.l4proto		= IPPROTO_DCCP,
 	.manip_pkt		= dccp_manip_pkt,
-	.in_range		= nf_nat_proto_in_range,
+	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= dccp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
+	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
 
 static int __init nf_nat_proto_dccp_init(void)
 {
-	return nf_nat_protocol_register(&nf_nat_protocol_dccp);
+	int err;
+
+	err = nf_nat_l4proto_register(NFPROTO_IPV4, &nf_nat_l4proto_dccp);
+	if (err < 0)
+		goto err1;
+	err = nf_nat_l4proto_register(NFPROTO_IPV6, &nf_nat_l4proto_dccp);
+	if (err < 0)
+		goto err2;
+	return 0;
+
+err2:
+	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_dccp);
+err1:
+	return err;
 }
 
 static void __exit nf_nat_proto_dccp_fini(void)
 {
-	nf_nat_protocol_unregister(&nf_nat_protocol_dccp);
+	nf_nat_l4proto_unregister(NFPROTO_IPV6, &nf_nat_l4proto_dccp);
+	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_dccp);
+
 }
 
 module_init(nf_nat_proto_dccp_init);
diff --git a/net/ipv4/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
similarity index 61%
rename from net/ipv4/netfilter/nf_nat_proto_sctp.c
rename to net/netfilter/nf_nat_proto_sctp.c
index 3cce9b6..e64faa5 100644
--- a/net/ipv4/netfilter/nf_nat_proto_sctp.c
+++ b/net/netfilter/nf_nat_proto_sctp.c
@@ -8,53 +8,46 @@
 
 #include <linux/types.h>
 #include <linux/init.h>
-#include <linux/ip.h>
 #include <linux/sctp.h>
 #include <linux/module.h>
 #include <net/sctp/checksum.h>
 
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 
 static u_int16_t nf_sctp_port_rover;
 
 static void
-sctp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		  const struct nf_nat_ipv4_range *range,
+sctp_unique_tuple(const struct nf_nat_l3proto *l3proto,
+		  struct nf_conntrack_tuple *tuple,
+		  const struct nf_nat_range *range,
 		  enum nf_nat_manip_type maniptype,
 		  const struct nf_conn *ct)
 {
-	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
-				  &nf_sctp_port_rover);
+	nf_nat_l4proto_unique_tuple(l3proto, tuple, range, maniptype, ct,
+				    &nf_sctp_port_rover);
 }
 
 static bool
 sctp_manip_pkt(struct sk_buff *skb,
-	       unsigned int iphdroff,
+	       const struct nf_nat_l3proto *l3proto,
+	       unsigned int iphdroff, unsigned int hdroff,
 	       const struct nf_conntrack_tuple *tuple,
 	       enum nf_nat_manip_type maniptype)
 {
-	const struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
 	struct sk_buff *frag;
 	sctp_sctphdr_t *hdr;
-	unsigned int hdroff = iphdroff + iph->ihl*4;
-	__be32 oldip, newip;
 	__be32 crc32;
 
 	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
 		return false;
 
-	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct sctphdr *)(skb->data + hdroff);
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
-		/* Get rid of src ip and src pt */
-		oldip = iph->saddr;
-		newip = tuple->src.u3.ip;
+		/* Get rid of src port */
 		hdr->source = tuple->src.u.sctp.port;
 	} else {
-		/* Get rid of dst ip and dst pt */
-		oldip = iph->daddr;
-		newip = tuple->dst.u3.ip;
+		/* Get rid of dst port */
 		hdr->dest = tuple->dst.u.sctp.port;
 	}
 
@@ -68,24 +61,38 @@ sctp_manip_pkt(struct sk_buff *skb,
 	return true;
 }
 
-static const struct nf_nat_protocol nf_nat_protocol_sctp = {
-	.protonum		= IPPROTO_SCTP,
+static const struct nf_nat_l4proto nf_nat_l4proto_sctp = {
+	.l4proto		= IPPROTO_SCTP,
 	.manip_pkt		= sctp_manip_pkt,
-	.in_range		= nf_nat_proto_in_range,
+	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= sctp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
+	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
 
 static int __init nf_nat_proto_sctp_init(void)
 {
-	return nf_nat_protocol_register(&nf_nat_protocol_sctp);
+	int err;
+
+	err = nf_nat_l4proto_register(NFPROTO_IPV4, &nf_nat_l4proto_sctp);
+	if (err < 0)
+		goto err1;
+	err = nf_nat_l4proto_register(NFPROTO_IPV6, &nf_nat_l4proto_sctp);
+	if (err < 0)
+		goto err2;
+	return 0;
+
+err2:
+	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_sctp);
+err1:
+	return err;
 }
 
 static void __exit nf_nat_proto_sctp_exit(void)
 {
-	nf_nat_protocol_unregister(&nf_nat_protocol_sctp);
+	nf_nat_l4proto_unregister(NFPROTO_IPV6, &nf_nat_l4proto_sctp);
+	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_sctp);
 }
 
 module_init(nf_nat_proto_sctp_init);
diff --git a/net/ipv4/netfilter/nf_nat_proto_tcp.c b/net/netfilter/nf_nat_proto_tcp.c
similarity index 65%
rename from net/ipv4/netfilter/nf_nat_proto_tcp.c
rename to net/netfilter/nf_nat_proto_tcp.c
index 9fb4b4e..83ec8a6 100644
--- a/net/ipv4/netfilter/nf_nat_proto_tcp.c
+++ b/net/netfilter/nf_nat_proto_tcp.c
@@ -9,37 +9,36 @@
 #include <linux/types.h>
 #include <linux/init.h>
 #include <linux/export.h>
-#include <linux/ip.h>
 #include <linux/tcp.h>
 
 #include <linux/netfilter.h>
 #include <linux/netfilter/nfnetlink_conntrack.h>
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_rule.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 #include <net/netfilter/nf_nat_core.h>
 
-static u_int16_t tcp_port_rover;
+static u16 tcp_port_rover;
 
 static void
-tcp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		 const struct nf_nat_ipv4_range *range,
+tcp_unique_tuple(const struct nf_nat_l3proto *l3proto,
+		 struct nf_conntrack_tuple *tuple,
+		 const struct nf_nat_range *range,
 		 enum nf_nat_manip_type maniptype,
 		 const struct nf_conn *ct)
 {
-	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct, &tcp_port_rover);
+	nf_nat_l4proto_unique_tuple(l3proto, tuple, range, maniptype, ct,
+				    &tcp_port_rover);
 }
 
 static bool
 tcp_manip_pkt(struct sk_buff *skb,
-	      unsigned int iphdroff,
+	      const struct nf_nat_l3proto *l3proto,
+	      unsigned int iphdroff, unsigned int hdroff,
 	      const struct nf_conntrack_tuple *tuple,
 	      enum nf_nat_manip_type maniptype)
 {
-	const struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
 	struct tcphdr *hdr;
-	unsigned int hdroff = iphdroff + iph->ihl*4;
-	__be32 oldip, newip;
 	__be16 *portptr, newport, oldport;
 	int hdrsize = 8; /* TCP connection tracking guarantees this much */
 
@@ -52,19 +51,14 @@ tcp_manip_pkt(struct sk_buff *skb,
 	if (!skb_make_writable(skb, hdroff + hdrsize))
 		return false;
 
-	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct tcphdr *)(skb->data + hdroff);
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
-		/* Get rid of src ip and src pt */
-		oldip = iph->saddr;
-		newip = tuple->src.u3.ip;
+		/* Get rid of src port */
 		newport = tuple->src.u.tcp.port;
 		portptr = &hdr->source;
 	} else {
-		/* Get rid of dst ip and dst pt */
-		oldip = iph->daddr;
-		newip = tuple->dst.u3.ip;
+		/* Get rid of dst port */
 		newport = tuple->dst.u.tcp.port;
 		portptr = &hdr->dest;
 	}
@@ -75,17 +69,17 @@ tcp_manip_pkt(struct sk_buff *skb,
 	if (hdrsize < sizeof(*hdr))
 		return true;
 
-	inet_proto_csum_replace4(&hdr->check, skb, oldip, newip, 1);
+	l3proto->csum_update(skb, iphdroff, &hdr->check, tuple, maniptype);
 	inet_proto_csum_replace2(&hdr->check, skb, oldport, newport, 0);
 	return true;
 }
 
-const struct nf_nat_protocol nf_nat_protocol_tcp = {
-	.protonum		= IPPROTO_TCP,
+const struct nf_nat_l4proto nf_nat_l4proto_tcp = {
+	.l4proto		= IPPROTO_TCP,
 	.manip_pkt		= tcp_manip_pkt,
-	.in_range		= nf_nat_proto_in_range,
+	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= tcp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
+	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_proto_udp.c b/net/netfilter/nf_nat_proto_udp.c
similarity index 60%
rename from net/ipv4/netfilter/nf_nat_proto_udp.c
rename to net/netfilter/nf_nat_proto_udp.c
index 9883336..7df613f 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udp.c
+++ b/net/netfilter/nf_nat_proto_udp.c
@@ -9,59 +9,53 @@
 #include <linux/types.h>
 #include <linux/export.h>
 #include <linux/init.h>
-#include <linux/ip.h>
 #include <linux/udp.h>
 
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_core.h>
-#include <net/netfilter/nf_nat_rule.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 
-static u_int16_t udp_port_rover;
+static u16 udp_port_rover;
 
 static void
-udp_unique_tuple(struct nf_conntrack_tuple *tuple,
-		 const struct nf_nat_ipv4_range *range,
+udp_unique_tuple(const struct nf_nat_l3proto *l3proto,
+		 struct nf_conntrack_tuple *tuple,
+		 const struct nf_nat_range *range,
 		 enum nf_nat_manip_type maniptype,
 		 const struct nf_conn *ct)
 {
-	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct, &udp_port_rover);
+	nf_nat_l4proto_unique_tuple(l3proto, tuple, range, maniptype, ct,
+				    &udp_port_rover);
 }
 
 static bool
 udp_manip_pkt(struct sk_buff *skb,
-	      unsigned int iphdroff,
+	      const struct nf_nat_l3proto *l3proto,
+	      unsigned int iphdroff, unsigned int hdroff,
 	      const struct nf_conntrack_tuple *tuple,
 	      enum nf_nat_manip_type maniptype)
 {
-	const struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
 	struct udphdr *hdr;
-	unsigned int hdroff = iphdroff + iph->ihl*4;
-	__be32 oldip, newip;
 	__be16 *portptr, newport;
 
 	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
 		return false;
-
-	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct udphdr *)(skb->data + hdroff);
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
-		/* Get rid of src ip and src pt */
-		oldip = iph->saddr;
-		newip = tuple->src.u3.ip;
+		/* Get rid of src port */
 		newport = tuple->src.u.udp.port;
 		portptr = &hdr->source;
 	} else {
-		/* Get rid of dst ip and dst pt */
-		oldip = iph->daddr;
-		newip = tuple->dst.u3.ip;
+		/* Get rid of dst port */
 		newport = tuple->dst.u.udp.port;
 		portptr = &hdr->dest;
 	}
 	if (hdr->check || skb->ip_summed == CHECKSUM_PARTIAL) {
-		inet_proto_csum_replace4(&hdr->check, skb, oldip, newip, 1);
+		l3proto->csum_update(skb, iphdroff, &hdr->check,
+				     tuple, maniptype);
 		inet_proto_csum_replace2(&hdr->check, skb, *portptr, newport,
 					 0);
 		if (!hdr->check)
@@ -71,12 +65,12 @@ udp_manip_pkt(struct sk_buff *skb,
 	return true;
 }
 
-const struct nf_nat_protocol nf_nat_protocol_udp = {
-	.protonum		= IPPROTO_UDP,
+const struct nf_nat_l4proto nf_nat_l4proto_udp = {
+	.l4proto		= IPPROTO_UDP,
 	.manip_pkt		= udp_manip_pkt,
-	.in_range		= nf_nat_proto_in_range,
+	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= udp_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
+	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
diff --git a/net/ipv4/netfilter/nf_nat_proto_udplite.c b/net/netfilter/nf_nat_proto_udplite.c
similarity index 58%
rename from net/ipv4/netfilter/nf_nat_proto_udplite.c
rename to net/netfilter/nf_nat_proto_udplite.c
index d24d10a..776a0d1 100644
--- a/net/ipv4/netfilter/nf_nat_proto_udplite.c
+++ b/net/netfilter/nf_nat_proto_udplite.c
@@ -9,59 +9,53 @@
 
 #include <linux/types.h>
 #include <linux/init.h>
-#include <linux/ip.h>
 #include <linux/udp.h>
 
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l3proto.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 
-static u_int16_t udplite_port_rover;
+static u16 udplite_port_rover;
 
 static void
-udplite_unique_tuple(struct nf_conntrack_tuple *tuple,
-		     const struct nf_nat_ipv4_range *range,
+udplite_unique_tuple(const struct nf_nat_l3proto *l3proto,
+		     struct nf_conntrack_tuple *tuple,
+		     const struct nf_nat_range *range,
 		     enum nf_nat_manip_type maniptype,
 		     const struct nf_conn *ct)
 {
-	nf_nat_proto_unique_tuple(tuple, range, maniptype, ct,
-				  &udplite_port_rover);
+	nf_nat_l4proto_unique_tuple(l3proto, tuple, range, maniptype, ct,
+				    &udplite_port_rover);
 }
 
 static bool
 udplite_manip_pkt(struct sk_buff *skb,
-		  unsigned int iphdroff,
+		  const struct nf_nat_l3proto *l3proto,
+		  unsigned int iphdroff, unsigned int hdroff,
 		  const struct nf_conntrack_tuple *tuple,
 		  enum nf_nat_manip_type maniptype)
 {
-	const struct iphdr *iph = (struct iphdr *)(skb->data + iphdroff);
 	struct udphdr *hdr;
-	unsigned int hdroff = iphdroff + iph->ihl*4;
-	__be32 oldip, newip;
 	__be16 *portptr, newport;
 
 	if (!skb_make_writable(skb, hdroff + sizeof(*hdr)))
 		return false;
 
-	iph = (struct iphdr *)(skb->data + iphdroff);
 	hdr = (struct udphdr *)(skb->data + hdroff);
 
 	if (maniptype == NF_NAT_MANIP_SRC) {
-		/* Get rid of src ip and src pt */
-		oldip = iph->saddr;
-		newip = tuple->src.u3.ip;
+		/* Get rid of source port */
 		newport = tuple->src.u.udp.port;
 		portptr = &hdr->source;
 	} else {
-		/* Get rid of dst ip and dst pt */
-		oldip = iph->daddr;
-		newip = tuple->dst.u3.ip;
+		/* Get rid of dst port */
 		newport = tuple->dst.u.udp.port;
 		portptr = &hdr->dest;
 	}
 
-	inet_proto_csum_replace4(&hdr->check, skb, oldip, newip, 1);
+	l3proto->csum_update(skb, iphdroff, &hdr->check, tuple, maniptype);
 	inet_proto_csum_replace2(&hdr->check, skb, *portptr, newport, 0);
 	if (!hdr->check)
 		hdr->check = CSUM_MANGLED_0;
@@ -70,24 +64,38 @@ udplite_manip_pkt(struct sk_buff *skb,
 	return true;
 }
 
-static const struct nf_nat_protocol nf_nat_protocol_udplite = {
-	.protonum		= IPPROTO_UDPLITE,
+static const struct nf_nat_l4proto nf_nat_l4proto_udplite = {
+	.l4proto		= IPPROTO_UDPLITE,
 	.manip_pkt		= udplite_manip_pkt,
-	.in_range		= nf_nat_proto_in_range,
+	.in_range		= nf_nat_l4proto_in_range,
 	.unique_tuple		= udplite_unique_tuple,
 #if defined(CONFIG_NF_CT_NETLINK) || defined(CONFIG_NF_CT_NETLINK_MODULE)
-	.nlattr_to_range	= nf_nat_proto_nlattr_to_range,
+	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
 
 static int __init nf_nat_proto_udplite_init(void)
 {
-	return nf_nat_protocol_register(&nf_nat_protocol_udplite);
+	int err;
+
+	err = nf_nat_l4proto_register(NFPROTO_IPV4, &nf_nat_l4proto_udplite);
+	if (err < 0)
+		goto err1;
+	err = nf_nat_l4proto_register(NFPROTO_IPV6, &nf_nat_l4proto_udplite);
+	if (err < 0)
+		goto err2;
+	return 0;
+
+err2:
+	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_udplite);
+err1:
+	return err;
 }
 
 static void __exit nf_nat_proto_udplite_fini(void)
 {
-	nf_nat_protocol_unregister(&nf_nat_protocol_udplite);
+	nf_nat_l4proto_unregister(NFPROTO_IPV6, &nf_nat_l4proto_udplite);
+	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_udplite);
 }
 
 module_init(nf_nat_proto_udplite_init);
diff --git a/net/ipv4/netfilter/nf_nat_proto_unknown.c b/net/netfilter/nf_nat_proto_unknown.c
similarity index 76%
rename from net/ipv4/netfilter/nf_nat_proto_unknown.c
rename to net/netfilter/nf_nat_proto_unknown.c
index e0afe81..6e494d5 100644
--- a/net/ipv4/netfilter/nf_nat_proto_unknown.c
+++ b/net/netfilter/nf_nat_proto_unknown.c
@@ -15,8 +15,7 @@
 
 #include <linux/netfilter.h>
 #include <net/netfilter/nf_nat.h>
-#include <net/netfilter/nf_nat_rule.h>
-#include <net/netfilter/nf_nat_protocol.h>
+#include <net/netfilter/nf_nat_l4proto.h>
 
 static bool unknown_in_range(const struct nf_conntrack_tuple *tuple,
 			     enum nf_nat_manip_type manip_type,
@@ -26,26 +25,29 @@ static bool unknown_in_range(const struct nf_conntrack_tuple *tuple,
 	return true;
 }
 
-static void unknown_unique_tuple(struct nf_conntrack_tuple *tuple,
-				 const struct nf_nat_ipv4_range *range,
+static void unknown_unique_tuple(const struct nf_nat_l3proto *l3proto,
+				 struct nf_conntrack_tuple *tuple,
+				 const struct nf_nat_range *range,
 				 enum nf_nat_manip_type maniptype,
 				 const struct nf_conn *ct)
 {
 	/* Sorry: we can't help you; if it's not unique, we can't frob
-	   anything. */
+	 * anything.
+	 */
 	return;
 }
 
 static bool
 unknown_manip_pkt(struct sk_buff *skb,
-		  unsigned int iphdroff,
+		  const struct nf_nat_l3proto *l3proto,
+		  unsigned int iphdroff, unsigned int hdroff,
 		  const struct nf_conntrack_tuple *tuple,
 		  enum nf_nat_manip_type maniptype)
 {
 	return true;
 }
 
-const struct nf_nat_protocol nf_nat_unknown_protocol = {
+const struct nf_nat_l4proto nf_nat_l4proto_unknown = {
 	.manip_pkt		= unknown_manip_pkt,
 	.in_range		= unknown_in_range,
 	.unique_tuple		= unknown_unique_tuple,
diff --git a/net/netfilter/xt_nat.c b/net/netfilter/xt_nat.c
new file mode 100644
index 0000000..8b94bb8
--- /dev/null
+++ b/net/netfilter/xt_nat.c
@@ -0,0 +1,183 @@
+/*
+ * (C) 1999-2001 Paul `Rusty' Russell
+ * (C) 2002-2006 Netfilter Core Team <coreteam@netfilter.org>
+ * (C) 2011 Patrick McHardy <kaber@trash.net>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netfilter.h>
+#include <linux/netfilter/x_tables.h>
+#include <net/netfilter/nf_nat_core.h>
+
+static int xt_nat_checkentry_v0(const struct xt_tgchk_param *par)
+{
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
+
+	if (mr->rangesize != 1) {
+		pr_info("%s: multiple ranges no longer supported\n",
+			par->target->name);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static void xt_nat_convert_range(struct nf_nat_range *dst,
+				 const struct nf_nat_ipv4_range *src)
+{
+	memset(&dst->min_addr, 0, sizeof(dst->min_addr));
+	memset(&dst->max_addr, 0, sizeof(dst->max_addr));
+
+	dst->flags	 = src->flags;
+	dst->min_addr.ip = src->min_ip;
+	dst->max_addr.ip = src->max_ip;
+	dst->min_proto	 = src->min;
+	dst->max_proto	 = src->max;
+}
+
+static unsigned int
+xt_snat_target_v0(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
+	struct nf_nat_range range;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	NF_CT_ASSERT(ct != NULL &&
+		     (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
+		      ctinfo == IP_CT_RELATED_REPLY));
+
+	xt_nat_convert_range(&range, &mr->range[0]);
+	return nf_nat_setup_info(ct, &range, NF_NAT_MANIP_SRC);
+}
+
+static unsigned int
+xt_dnat_target_v0(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct nf_nat_ipv4_multi_range_compat *mr = par->targinfo;
+	struct nf_nat_range range;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	NF_CT_ASSERT(ct != NULL &&
+		     (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
+
+	xt_nat_convert_range(&range, &mr->range[0]);
+	return nf_nat_setup_info(ct, &range, NF_NAT_MANIP_DST);
+}
+
+static int xt_nat_checkentry_v1(const struct xt_tgchk_param *par)
+{
+	const struct nf_nat_range *range = par->targinfo;
+
+	if (range->flags & NF_NAT_RANGE_MAP_IPS &&
+	    (range->min_addr.all[2] ^ range->max_addr.all[2] ||
+	     range->min_addr.all[3] ^ range->max_addr.all[3])) {
+		pr_info("%s: address range maximum size is 2^64\n",
+			par->target->name);
+		return -EINVAL;
+	}
+	return 0;
+}
+
+static unsigned int
+xt_snat_target_v1(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct nf_nat_range *range = par->targinfo;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	NF_CT_ASSERT(ct != NULL &&
+		     (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED ||
+		      ctinfo == IP_CT_RELATED_REPLY));
+
+	return nf_nat_setup_info(ct, range, NF_NAT_MANIP_SRC);
+}
+
+static unsigned int
+xt_dnat_target_v1(struct sk_buff *skb, const struct xt_action_param *par)
+{
+	const struct nf_nat_range *range = par->targinfo;
+	enum ip_conntrack_info ctinfo;
+	struct nf_conn *ct;
+
+	ct = nf_ct_get(skb, &ctinfo);
+	NF_CT_ASSERT(ct != NULL &&
+		     (ctinfo == IP_CT_NEW || ctinfo == IP_CT_RELATED));
+
+	return nf_nat_setup_info(ct, range, NF_NAT_MANIP_DST);
+}
+
+static struct xt_target xt_nat_target_reg[] __read_mostly = {
+	{
+		.name		= "SNAT",
+		.revision	= 0,
+		.checkentry	= xt_nat_checkentry_v0,
+		.target		= xt_snat_target_v0,
+		.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
+		.family		= NFPROTO_IPV4,
+		.table		= "nat",
+		.hooks		= (1 << NF_INET_POST_ROUTING) |
+				  (1 << NF_INET_LOCAL_OUT),
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "DNAT",
+		.revision	= 0,
+		.checkentry	= xt_nat_checkentry_v0,
+		.target		= xt_dnat_target_v0,
+		.targetsize	= sizeof(struct nf_nat_ipv4_multi_range_compat),
+		.family		= NFPROTO_IPV4,
+		.table		= "nat",
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "SNAT",
+		.revision	= 1,
+		.checkentry	= xt_nat_checkentry_v1,
+		.target		= xt_snat_target_v1,
+		.targetsize	= sizeof(struct nf_nat_range),
+		.table		= "nat",
+		.hooks		= (1 << NF_INET_POST_ROUTING) |
+				  (1 << NF_INET_LOCAL_OUT),
+		.me		= THIS_MODULE,
+	},
+	{
+		.name		= "DNAT",
+		.revision	= 1,
+		.checkentry	= xt_nat_checkentry_v1,
+		.target		= xt_dnat_target_v1,
+		.targetsize	= sizeof(struct nf_nat_range),
+		.table		= "nat",
+		.hooks		= (1 << NF_INET_PRE_ROUTING) |
+				  (1 << NF_INET_LOCAL_IN),
+		.me		= THIS_MODULE,
+	},
+};
+
+static int __init xt_nat_init(void)
+{
+	return xt_register_targets(xt_nat_target_reg,
+				   ARRAY_SIZE(xt_nat_target_reg));
+}
+
+static void __exit xt_nat_exit(void)
+{
+	xt_unregister_targets(xt_nat_target_reg, ARRAY_SIZE(xt_nat_target_reg));
+}
+
+module_init(xt_nat_init);
+module_exit(xt_nat_exit);
+
+MODULE_LICENSE("GPL");
+MODULE_ALIAS("ipt_SNAT");
+MODULE_ALIAS("ipt_DNAT");
-- 
1.7.1

