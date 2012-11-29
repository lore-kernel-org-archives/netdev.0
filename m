From: Jesse Gross <jesse@nicira.com>
Subject: [PATCH net-next 2/7] ipv6: Move ipv6_find_hdr() out of Netfilter code.
Date: Thu, 29 Nov 2012 10:35:44 -0800
Message-ID: <1354214149-33651-3-git-send-email-jesse@nicira.com>
References: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Cc: netdev@vger.kernel.org, dev@openvswitch.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog128.obsmtp.com ([74.125.149.141]:34594 "HELO
	na3sys009aog128.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1752287Ab2K2Sf7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2012 13:35:59 -0500
Received: by mail-pb0-f70.google.com with SMTP id ro2so16813605pbb.1
        for <netdev@vger.kernel.org>; Thu, 29 Nov 2012 10:35:58 -0800 (PST)
In-Reply-To: <1354214149-33651-1-git-send-email-jesse@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Open vSwitch will soon also use ipv6_find_hdr() so this moves it
out of Netfilter-specific code into a more common location.

Signed-off-by: Jesse Gross <jesse@nicira.com>
---
 include/linux/netfilter_ipv6/ip6_tables.h |    9 ---
 include/net/ipv6.h                        |    9 +++
 net/ipv6/exthdrs_core.c                   |  103 +++++++++++++++++++++++++++++
 net/ipv6/netfilter/ip6_tables.c           |  103 -----------------------------
 net/netfilter/xt_HMARK.c                  |    8 +--
 5 files changed, 116 insertions(+), 116 deletions(-)

diff --git a/include/linux/netfilter_ipv6/ip6_tables.h b/include/linux/netfilter_ipv6/ip6_tables.h
index 5f84c62..610208b 100644
--- a/include/linux/netfilter_ipv6/ip6_tables.h
+++ b/include/linux/netfilter_ipv6/ip6_tables.h
@@ -47,15 +47,6 @@ ip6t_ext_hdr(u8 nexthdr)
 	       (nexthdr == IPPROTO_DSTOPTS);
 }
 
-enum {
-	IP6T_FH_F_FRAG	= (1 << 0),
-	IP6T_FH_F_AUTH	= (1 << 1),
-};
-
-/* find specified header and get offset to it */
-extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
-			 int target, unsigned short *fragoff, int *fragflg);
-
 #ifdef CONFIG_COMPAT
 #include <net/compat.h>
 
diff --git a/include/net/ipv6.h b/include/net/ipv6.h
index 979bf6c..b2f0cfb 100644
--- a/include/net/ipv6.h
+++ b/include/net/ipv6.h
@@ -630,6 +630,15 @@ extern int			ipv6_skip_exthdr(const struct sk_buff *, int start,
 
 extern bool			ipv6_ext_hdr(u8 nexthdr);
 
+enum {
+	IP6_FH_F_FRAG	= (1 << 0),
+	IP6_FH_F_AUTH	= (1 << 1),
+};
+
+/* find specified header and get offset to it */
+extern int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
+			 int target, unsigned short *fragoff, int *fragflg);
+
 extern int ipv6_find_tlv(struct sk_buff *skb, int offset, int type);
 
 extern struct in6_addr *fl6_update_dst(struct flowi6 *fl6,
diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
index f73d59a..8ea253a 100644
--- a/net/ipv6/exthdrs_core.c
+++ b/net/ipv6/exthdrs_core.c
@@ -111,3 +111,106 @@ int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp,
 	return start;
 }
 EXPORT_SYMBOL(ipv6_skip_exthdr);
+
+/*
+ * find the offset to specified header or the protocol number of last header
+ * if target < 0. "last header" is transport protocol header, ESP, or
+ * "No next header".
+ *
+ * Note that *offset is used as input/output parameter. an if it is not zero,
+ * then it must be a valid offset to an inner IPv6 header. This can be used
+ * to explore inner IPv6 header, eg. ICMPv6 error messages.
+ *
+ * If target header is found, its offset is set in *offset and return protocol
+ * number. Otherwise, return -1.
+ *
+ * If the first fragment doesn't contain the final protocol header or
+ * NEXTHDR_NONE it is considered invalid.
+ *
+ * Note that non-1st fragment is special case that "the protocol number
+ * of last header" is "next header" field in Fragment header. In this case,
+ * *offset is meaningless and fragment offset is stored in *fragoff if fragoff
+ * isn't NULL.
+ *
+ * if flags is not NULL and it's a fragment, then the frag flag IP6_FH_F_FRAG
+ * will be set. If it's an AH header, the IP6_FH_F_AUTH flag is set and
+ * target < 0, then this function will stop at the AH header.
+ */
+int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
+		  int target, unsigned short *fragoff, int *flags)
+{
+	unsigned int start = skb_network_offset(skb) + sizeof(struct ipv6hdr);
+	u8 nexthdr = ipv6_hdr(skb)->nexthdr;
+	unsigned int len;
+
+	if (fragoff)
+		*fragoff = 0;
+
+	if (*offset) {
+		struct ipv6hdr _ip6, *ip6;
+
+		ip6 = skb_header_pointer(skb, *offset, sizeof(_ip6), &_ip6);
+		if (!ip6 || (ip6->version != 6)) {
+			printk(KERN_ERR "IPv6 header not found\n");
+			return -EBADMSG;
+		}
+		start = *offset + sizeof(struct ipv6hdr);
+		nexthdr = ip6->nexthdr;
+	}
+	len = skb->len - start;
+
+	while (nexthdr != target) {
+		struct ipv6_opt_hdr _hdr, *hp;
+		unsigned int hdrlen;
+
+		if ((!ipv6_ext_hdr(nexthdr)) || nexthdr == NEXTHDR_NONE) {
+			if (target < 0)
+				break;
+			return -ENOENT;
+		}
+
+		hp = skb_header_pointer(skb, start, sizeof(_hdr), &_hdr);
+		if (hp == NULL)
+			return -EBADMSG;
+		if (nexthdr == NEXTHDR_FRAGMENT) {
+			unsigned short _frag_off;
+			__be16 *fp;
+
+			if (flags)	/* Indicate that this is a fragment */
+				*flags |= IP6_FH_F_FRAG;
+			fp = skb_header_pointer(skb,
+						start+offsetof(struct frag_hdr,
+							       frag_off),
+						sizeof(_frag_off),
+						&_frag_off);
+			if (fp == NULL)
+				return -EBADMSG;
+
+			_frag_off = ntohs(*fp) & ~0x7;
+			if (_frag_off) {
+				if (target < 0 &&
+				    ((!ipv6_ext_hdr(hp->nexthdr)) ||
+				     hp->nexthdr == NEXTHDR_NONE)) {
+					if (fragoff)
+						*fragoff = _frag_off;
+					return hp->nexthdr;
+				}
+				return -ENOENT;
+			}
+			hdrlen = 8;
+		} else if (nexthdr == NEXTHDR_AUTH) {
+			if (flags && (*flags & IP6_FH_F_AUTH) && (target < 0))
+				break;
+			hdrlen = (hp->hdrlen + 2) << 2;
+		} else
+			hdrlen = ipv6_optlen(hp);
+
+		nexthdr = hp->nexthdr;
+		len -= hdrlen;
+		start += hdrlen;
+	}
+
+	*offset = start;
+	return nexthdr;
+}
+EXPORT_SYMBOL(ipv6_find_hdr);
diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index d7cb045..1ce4f15 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -2273,112 +2273,9 @@ static void __exit ip6_tables_fini(void)
 	unregister_pernet_subsys(&ip6_tables_net_ops);
 }
 
-/*
- * find the offset to specified header or the protocol number of last header
- * if target < 0. "last header" is transport protocol header, ESP, or
- * "No next header".
- *
- * Note that *offset is used as input/output parameter. an if it is not zero,
- * then it must be a valid offset to an inner IPv6 header. This can be used
- * to explore inner IPv6 header, eg. ICMPv6 error messages.
- *
- * If target header is found, its offset is set in *offset and return protocol
- * number. Otherwise, return -1.
- *
- * If the first fragment doesn't contain the final protocol header or
- * NEXTHDR_NONE it is considered invalid.
- *
- * Note that non-1st fragment is special case that "the protocol number
- * of last header" is "next header" field in Fragment header. In this case,
- * *offset is meaningless and fragment offset is stored in *fragoff if fragoff
- * isn't NULL.
- *
- * if flags is not NULL and it's a fragment, then the frag flag IP6T_FH_F_FRAG
- * will be set. If it's an AH header, the IP6T_FH_F_AUTH flag is set and
- * target < 0, then this function will stop at the AH header.
- */
-int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
-		  int target, unsigned short *fragoff, int *flags)
-{
-	unsigned int start = skb_network_offset(skb) + sizeof(struct ipv6hdr);
-	u8 nexthdr = ipv6_hdr(skb)->nexthdr;
-	unsigned int len;
-
-	if (fragoff)
-		*fragoff = 0;
-
-	if (*offset) {
-		struct ipv6hdr _ip6, *ip6;
-
-		ip6 = skb_header_pointer(skb, *offset, sizeof(_ip6), &_ip6);
-		if (!ip6 || (ip6->version != 6)) {
-			printk(KERN_ERR "IPv6 header not found\n");
-			return -EBADMSG;
-		}
-		start = *offset + sizeof(struct ipv6hdr);
-		nexthdr = ip6->nexthdr;
-	}
-	len = skb->len - start;
-
-	while (nexthdr != target) {
-		struct ipv6_opt_hdr _hdr, *hp;
-		unsigned int hdrlen;
-
-		if ((!ipv6_ext_hdr(nexthdr)) || nexthdr == NEXTHDR_NONE) {
-			if (target < 0)
-				break;
-			return -ENOENT;
-		}
-
-		hp = skb_header_pointer(skb, start, sizeof(_hdr), &_hdr);
-		if (hp == NULL)
-			return -EBADMSG;
-		if (nexthdr == NEXTHDR_FRAGMENT) {
-			unsigned short _frag_off;
-			__be16 *fp;
-
-			if (flags)	/* Indicate that this is a fragment */
-				*flags |= IP6T_FH_F_FRAG;
-			fp = skb_header_pointer(skb,
-						start+offsetof(struct frag_hdr,
-							       frag_off),
-						sizeof(_frag_off),
-						&_frag_off);
-			if (fp == NULL)
-				return -EBADMSG;
-
-			_frag_off = ntohs(*fp) & ~0x7;
-			if (_frag_off) {
-				if (target < 0 &&
-				    ((!ipv6_ext_hdr(hp->nexthdr)) ||
-				     hp->nexthdr == NEXTHDR_NONE)) {
-					if (fragoff)
-						*fragoff = _frag_off;
-					return hp->nexthdr;
-				}
-				return -ENOENT;
-			}
-			hdrlen = 8;
-		} else if (nexthdr == NEXTHDR_AUTH) {
-			if (flags && (*flags & IP6T_FH_F_AUTH) && (target < 0))
-				break;
-			hdrlen = (hp->hdrlen + 2) << 2;
-		} else
-			hdrlen = ipv6_optlen(hp);
-
-		nexthdr = hp->nexthdr;
-		len -= hdrlen;
-		start += hdrlen;
-	}
-
-	*offset = start;
-	return nexthdr;
-}
-
 EXPORT_SYMBOL(ip6t_register_table);
 EXPORT_SYMBOL(ip6t_unregister_table);
 EXPORT_SYMBOL(ip6t_do_table);
-EXPORT_SYMBOL(ipv6_find_hdr);
 
 module_init(ip6_tables_init);
 module_exit(ip6_tables_fini);
diff --git a/net/netfilter/xt_HMARK.c b/net/netfilter/xt_HMARK.c
index 1686ca1..73b73f6 100644
--- a/net/netfilter/xt_HMARK.c
+++ b/net/netfilter/xt_HMARK.c
@@ -167,7 +167,7 @@ hmark_pkt_set_htuple_ipv6(const struct sk_buff *skb, struct hmark_tuple *t,
 			  const struct xt_hmark_info *info)
 {
 	struct ipv6hdr *ip6, _ip6;
-	int flag = IP6T_FH_F_AUTH;
+	int flag = IP6_FH_F_AUTH;
 	unsigned int nhoff = 0;
 	u16 fragoff = 0;
 	int nexthdr;
@@ -177,7 +177,7 @@ hmark_pkt_set_htuple_ipv6(const struct sk_buff *skb, struct hmark_tuple *t,
 	if (nexthdr < 0)
 		return 0;
 	/* No need to check for icmp errors on fragments */
-	if ((flag & IP6T_FH_F_FRAG) || (nexthdr != IPPROTO_ICMPV6))
+	if ((flag & IP6_FH_F_FRAG) || (nexthdr != IPPROTO_ICMPV6))
 		goto noicmp;
 	/* Use inner header in case of ICMP errors */
 	if (get_inner6_hdr(skb, &nhoff)) {
@@ -185,7 +185,7 @@ hmark_pkt_set_htuple_ipv6(const struct sk_buff *skb, struct hmark_tuple *t,
 		if (ip6 == NULL)
 			return -1;
 		/* If AH present, use SPI like in ESP. */
-		flag = IP6T_FH_F_AUTH;
+		flag = IP6_FH_F_AUTH;
 		nexthdr = ipv6_find_hdr(skb, &nhoff, -1, &fragoff, &flag);
 		if (nexthdr < 0)
 			return -1;
@@ -201,7 +201,7 @@ noicmp:
 	if (t->proto == IPPROTO_ICMPV6)
 		return 0;
 
-	if (flag & IP6T_FH_F_FRAG)
+	if (flag & IP6_FH_F_FRAG)
 		return 0;
 
 	hmark_set_tuple_ports(skb, nhoff, t, info);
-- 
1.7.9.5
