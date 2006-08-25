From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [GIT PATCH] IPv6 Updates for net-2.6.19
Date: Fri, 25 Aug 2006 17:21:30 +0900 (JST)
Message-ID: <20060825.172130.112746083.yoshfuji@linux-ipv6.org>
References: <20060825.030034.68559899.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yoshfuji@linux-ipv6.org,
	usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:30218 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S932170AbWHYITm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Aug 2006 04:19:42 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060825.030034.68559899.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060825.030034.68559899.yoshfuji@linux-ipv6.org> (at Fri, 25 Aug 2006 03:00:34 +0900 (JST)), YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org> says:

> Please pull
>   git://git.skbuff.net/gitroot/yoshfuji/net-2.6.19-20060825-inet6

> +int in6_pton(const char *src, int srclen,
:
> +	printf("srclen=%d\n", srclen);

(FYI, Dave has pointed out and fixed up this this but anyway,)
My fault... Here's the updated version.  It is available at the same URL.

I'll be more careful in the future.

HEADLINES
---------

    [IPV6] MIP6: Several obvious clean-ups.
    [IPV6] ROUTE: Routing by Traffic Class.
    [IPV6] ROUTE: Routing by FWMARK.
    [NET]: Add common helper functions to convert IPv6/IPv4 address string to network address structure.
    [NETFILTER] NF_CONNTRACK_FTP: Use in6_pton() to convert address string.

DIFFSTAT
--------

 include/linux/fib_rules.h        |    2 
 include/linux/inet.h             |    2 
 include/net/flow.h               |    2 
 net/core/utils.c                 |  213 ++++++++++++++++++++++++++++++++++++++
 net/ipv6/Kconfig                 |    7 +
 net/ipv6/ah6.c                   |   45 +-------
 net/ipv6/exthdrs.c               |    1 
 net/ipv6/fib6_rules.c            |   26 +++++
 net/ipv6/mip6.c                  |    6 +
 net/ipv6/route.c                 |    1 
 net/netfilter/nf_conntrack_ftp.c |   96 +----------------
 11 files changed, 266 insertions(+), 135 deletions(-)

CHANGESETS
----------

commit 6dabb77fd82cd927727d5fb8136eff2e123910f5
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Thu Aug 24 23:18:12 2006 +0900

    [IPV6] MIP6: Several obvious clean-ups.
    
    - Remove redundant code.  Pointed out by Brian Haley <brian.haley@hp.com>.
    - Unify code paths with/without CONFIG_IPV6_MIP.
    - Use NIP6_FMT for IPv6 address textual presentation.
    - Fold long line.  Pointed out by David Miller <davem@davemloft.net>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index 164546b..9b007eb 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -128,9 +128,7 @@ static void ipv6_rearrange_destopt(struc
 		off += optlen;
 		len -= optlen;
 	}
-	if (len == 0)
-		return;
-
+	/* Note: ok if len == 0 */
 bad:
 	return;
 }
@@ -175,11 +173,7 @@ static void ipv6_rearrange_rthdr(struct 
 	ipv6_addr_copy(&iph->daddr, &final_addr);
 }
 
-#ifdef CONFIG_IPV6_MIP6
 static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
-#else
-static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len)
-#endif
 {
 	union {
 		struct ipv6hdr *iph;
@@ -194,30 +188,12 @@ #endif
 
 	while (exthdr.raw < end) {
 		switch (nexthdr) {
-#ifdef CONFIG_IPV6_MIP6
-		case NEXTHDR_HOP:
-			if (!zero_out_mutable_opts(exthdr.opth)) {
-				LIMIT_NETDEBUG(
-					KERN_WARNING "overrun %sopts\n",
-					nexthdr == NEXTHDR_HOP ?
-						"hop" : "dest");
-				return -EINVAL;
-			}
-			break;
 		case NEXTHDR_DEST:
+#ifdef CONFIG_IPV6_MIP6
 			if (dir == XFRM_POLICY_OUT)
 				ipv6_rearrange_destopt(iph, exthdr.opth);
-			if (!zero_out_mutable_opts(exthdr.opth)) {
-				LIMIT_NETDEBUG(
-					KERN_WARNING "overrun %sopts\n",
-					nexthdr == NEXTHDR_HOP ?
-						"hop" : "dest");
-				return -EINVAL;
-			}
-			break;
-#else
+#endif
 		case NEXTHDR_HOP:
-		case NEXTHDR_DEST:
 			if (!zero_out_mutable_opts(exthdr.opth)) {
 				LIMIT_NETDEBUG(
 					KERN_WARNING "overrun %sopts\n",
@@ -226,7 +202,6 @@ #else
 				return -EINVAL;
 			}
 			break;
-#endif
 
 		case NEXTHDR_ROUTING:
 			ipv6_rearrange_rthdr(iph, exthdr.rth);
@@ -282,16 +257,13 @@ #endif
 		}
 #ifdef CONFIG_IPV6_MIP6
 		memcpy(tmp_ext, &top_iph->saddr, extlen);
-		err = ipv6_clear_mutable_options(top_iph,
-						 extlen - sizeof(*tmp_ext) +
-						 sizeof(*top_iph),
-						 XFRM_POLICY_OUT);
 #else
 		memcpy(tmp_ext, &top_iph->daddr, extlen);
+#endif
 		err = ipv6_clear_mutable_options(top_iph,
 						 extlen - sizeof(*tmp_ext) +
-						 sizeof(*top_iph));
-#endif
+						 sizeof(*top_iph),
+						 XFRM_POLICY_OUT);
 		if (err)
 			goto error_free_iph;
 	}
@@ -382,13 +354,8 @@ static int ah6_input(struct xfrm_state *
 	if (!tmp_hdr)
 		goto out;
 	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
-#ifdef CONFIG_IPV6_MIP6
 	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len, XFRM_POLICY_IN))
 		goto free_out;
-#else
-	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len))
-		goto free_out;
-#endif
 	skb->nh.ipv6h->priority    = 0;
 	skb->nh.ipv6h->flow_lbl[0] = 0;
 	skb->nh.ipv6h->flow_lbl[1] = 0;
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index 077f626..f4c7629 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -87,7 +87,6 @@ int ipv6_find_tlv(struct sk_buff *skb, i
 		len -= optlen;
 	}
 	/* not_found */
-	return -1;
  bad:
 	return -1;
 }
diff --git a/net/ipv6/mip6.c b/net/ipv6/mip6.c
index 7085403..99d116c 100644
--- a/net/ipv6/mip6.c
+++ b/net/ipv6/mip6.c
@@ -121,7 +121,8 @@ int mip6_mh_filter(struct sock *sk, stru
 				    &skb->nh.ipv6h->daddr,
 				    mhlen, IPPROTO_MH,
 				    skb_checksum(skb, 0, mhlen, 0))) {
-			LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH checksum failed [%04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x > %04x:%04x:%04x:%04x:%04x:%04x:%04x:%04x]\n",
+			LIMIT_NETDEBUG(KERN_DEBUG "mip6: MH checksum failed "
+				       "[" NIP6_FMT " > " NIP6_FMT "]\n",
 				       NIP6(skb->nh.ipv6h->saddr),
 				       NIP6(skb->nh.ipv6h->daddr));
 			return -1;
@@ -234,7 +235,8 @@ static int mip6_destopt_reject(struct xf
 	struct timeval stamp;
 	int err = 0;
 
-	if (unlikely(fl->proto == IPPROTO_MH && fl->fl_mh_type <= IP6_MH_TYPE_MAX))
+	if (unlikely(fl->proto == IPPROTO_MH &&
+		     fl->fl_mh_type <= IP6_MH_TYPE_MAX))
 		goto out;
 
 	if (likely(opt->dsthao)) {

---
commit 95dcd7a0c5e55a36d78c4a6bf0a44fc9a6060fdf
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Aug 21 19:18:57 2006 +0900

    [IPV6] ROUTE: Routing by Traffic Class.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 7b4908c..91f6233 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -121,6 +121,9 @@ static int fib6_rule_match(struct fib_ru
 	    !ipv6_prefix_equal(&fl->fl6_src, &r->src.addr, r->src.plen))
 		return 0;
 
+	if (r->tclass && r->tclass != ((ntohl(fl->fl6_flowlabel) >> 20) & 0xff))
+		return 0;
+
 	return 1;
 }
 

---
commit 10204d532f5f8bb379009ba0bee2113bafda72be
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Aug 21 19:22:01 2006 +0900

    [IPV6] ROUTE: Routing by FWMARK.
    
    Based on patch by Jean Lorchat <lorchat@sfc.wide.ad.jp>.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/fib_rules.h b/include/linux/fib_rules.h
index 19a82b6..2987549 100644
--- a/include/linux/fib_rules.h
+++ b/include/linux/fib_rules.h
@@ -34,7 +34,7 @@ enum
 	FRA_UNUSED3,
 	FRA_UNUSED4,
 	FRA_UNUSED5,
-	FRA_FWMARK,	/* netfilter mark (IPv4) */
+	FRA_FWMARK,	/* netfilter mark (IPv4/IPv6) */
 	FRA_FLOW,	/* flow/class id */
 	FRA_UNUSED6,
 	FRA_UNUSED7,
diff --git a/include/net/flow.h b/include/net/flow.h
index e052291..3ca210e 100644
--- a/include/net/flow.h
+++ b/include/net/flow.h
@@ -26,6 +26,7 @@ struct flowi {
 		struct {
 			struct in6_addr		daddr;
 			struct in6_addr		saddr;
+			__u32			fwmark;
 			__u32			flowlabel;
 		} ip6_u;
 
@@ -42,6 +43,7 @@ #define fld_fwmark	nl_u.dn_u.fwmark
 #define fld_scope	nl_u.dn_u.scope
 #define fl6_dst		nl_u.ip6_u.daddr
 #define fl6_src		nl_u.ip6_u.saddr
+#define fl6_fwmark	nl_u.ip6_u.fwmark
 #define fl6_flowlabel	nl_u.ip6_u.flowlabel
 #define fl4_dst		nl_u.ip4_u.daddr
 #define fl4_src		nl_u.ip4_u.saddr
diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index e523d39..54397ee 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -172,3 +172,10 @@ config IPV6_MULTIPLE_TABLES
 	---help---
 	  Support multiple routing tables.
 
+config IPV6_ROUTE_FWMARK
+	bool "IPv6: use netfilter MARK value as routing key"
+	depends on IPV6_MULTIPLE_TABLES && NETFILTER
+	---help---
+	  If you say Y here, you will be able to specify different routes for
+	  packets with different mark values (see iptables(8), MARK target).
+
diff --git a/net/ipv6/fib6_rules.c b/net/ipv6/fib6_rules.c
index 91f6233..aebd9e2 100644
--- a/net/ipv6/fib6_rules.c
+++ b/net/ipv6/fib6_rules.c
@@ -26,6 +26,9 @@ struct fib6_rule
 	struct fib_rule		common;
 	struct rt6key		src;
 	struct rt6key		dst;
+#ifdef CONFIG_IPV6_ROUTE_FWMARK
+	u8			fwmark;
+#endif
 	u8			tclass;
 };
 
@@ -124,6 +127,11 @@ static int fib6_rule_match(struct fib_ru
 	if (r->tclass && r->tclass != ((ntohl(fl->fl6_flowlabel) >> 20) & 0xff))
 		return 0;
 
+#ifdef CONFIG_IPV6_ROUTE_FWMARK
+	if (r->fwmark && (r->fwmark != fl->fl6_fwmark))
+		return 0;
+#endif
+
 	return 1;
 }
 
@@ -164,6 +172,11 @@ static int fib6_rule_configure(struct fi
 		nla_memcpy(&rule6->dst.addr, tb[FRA_DST],
 			   sizeof(struct in6_addr));
 
+#ifdef CONFIG_IPV6_ROUTE_FWMARK
+	if (tb[FRA_FWMARK])
+		rule6->fwmark = nla_get_u32(tb[FRA_FWMARK]);
+#endif
+
 	rule6->src.plen = frh->src_len;
 	rule6->dst.plen = frh->dst_len;
 	rule6->tclass = frh->tos;
@@ -195,6 +208,11 @@ static int fib6_rule_compare(struct fib_
 	    nla_memcmp(tb[FRA_DST], &rule6->dst.addr, sizeof(struct in6_addr)))
 		return 0;
 
+#ifdef CONFIG_IPV6_ROUTE_FWMARK
+	if (tb[FRA_FWMARK] && (rule6->fwmark != nla_get_u32(tb[FRA_FWMARK])))
+		return 0;
+#endif
+
 	return 1;
 }
 
@@ -216,6 +234,11 @@ static int fib6_rule_fill(struct fib_rul
 		NLA_PUT(skb, FRA_SRC, sizeof(struct in6_addr),
 			&rule6->src.addr);
 
+#ifdef CONFIG_IPV6_ROUTE_FWMARK
+	if (rule6->fwmark)
+		NLA_PUT_U32(skb, FRA_FWMARK, rule6->fwmark);
+#endif
+
 	return 0;
 
 nla_put_failure:
diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index c9f74c1..9b50e0c 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -703,6 +703,7 @@ void ip6_route_input(struct sk_buff *skb
 			.ip6_u = {
 				.daddr = iph->daddr,
 				.saddr = iph->saddr,
+				.fwmark = skb->nfmark,
 				.flowlabel = (* (u32 *) iph)&IPV6_FLOWINFO_MASK,
 			},
 		},

---
commit 47d9922c9c8cf4baa8f3b1727e7dff133cd2755a
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Fri Aug 25 16:39:26 2006 +0900

    [NET]: Add common helper functions to convert IPv6/IPv4 address string to network address structure.
    
    These helpers can be used in netfilter, cifs etc.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/include/linux/inet.h b/include/linux/inet.h
index 6c5587a..b7c6da7 100644
--- a/include/linux/inet.h
+++ b/include/linux/inet.h
@@ -46,5 +46,7 @@ #ifdef __KERNEL__
 #include <linux/types.h>
 
 extern __be32 in_aton(const char *str);
+extern int in4_pton(const char *src, int srclen, u8 *dst, char delim, const char **end);
+extern int in6_pton(const char *src, int srclen, u8 *dst, char delim, const char **end);
 #endif
 #endif	/* _LINUX_INET_H */
diff --git a/net/core/utils.c b/net/core/utils.c
index 4f96f38..926c949 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -4,6 +4,7 @@
  *	Authors:
  *	net_random Alan Cox
  *	net_ratelimit Andy Kleen
+ *	in{4,6}_pton YOSHIFUJI Hideaki, Copyright (C)2006 USAGI/WIDE Project
  *
  *	Created by Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
  *
@@ -190,3 +191,215 @@ __be32 in_aton(const char *str)
 }
 
 EXPORT_SYMBOL(in_aton);
+
+#define IN6PTON_XDIGIT		0x00010000
+#define IN6PTON_DIGIT		0x00020000
+#define IN6PTON_COLON_MASK	0x00700000
+#define IN6PTON_COLON_1		0x00100000	/* single : requested */
+#define IN6PTON_COLON_2		0x00200000	/* second : requested */
+#define IN6PTON_COLON_1_2	0x00400000	/* :: requested */
+#define IN6PTON_DOT		0x00800000	/* . */
+#define IN6PTON_DELIM		0x10000000
+#define IN6PTON_NULL		0x20000000	/* first/tail */
+#define IN6PTON_UNKNOWN		0x40000000
+
+static inline int digit2bin(char c, char delim)
+{
+	if (c == delim || c == '\0')
+		return IN6PTON_DELIM;
+	if (c == '.')
+		return IN6PTON_DOT;
+	if (c >= '0' && c <= '9')
+		return (IN6PTON_DIGIT | (c - '0'));
+	return IN6PTON_UNKNOWN;
+}
+
+static inline int xdigit2bin(char c, char delim)
+{
+	if (c == delim || c == '\0')
+		return IN6PTON_DELIM;
+	if (c == ':')
+		return IN6PTON_COLON_MASK;
+	if (c == '.')
+		return IN6PTON_DOT;
+	if (c >= '0' && c <= '9')
+		return (IN6PTON_XDIGIT | IN6PTON_DIGIT| (c - '0'));
+	if (c >= 'a' && c <= 'f')
+		return (IN6PTON_XDIGIT | (c - 'a' + 10));
+	if (c >= 'A' && c <= 'F')
+		return (IN6PTON_XDIGIT | (c - 'A' + 10));
+	return IN6PTON_UNKNOWN;
+}
+
+int in4_pton(const char *src, int srclen,
+	     u8 *dst,
+	     char delim, const char **end)
+{
+	const char *s;
+	u8 *d;
+	u8 dbuf[4];
+	int ret = 0;
+	int i;
+	int w = 0;
+
+	if (srclen < 0)
+		srclen = strlen(src);
+	s = src;
+	d = dbuf;
+	i = 0;
+	while(1) {
+		int c;
+		c = xdigit2bin(srclen > 0 ? *s : '\0', delim);
+		if (!(c & (IN6PTON_DIGIT | IN6PTON_DOT | IN6PTON_DELIM))) {
+			goto out;
+		}
+		if (c & (IN6PTON_DOT | IN6PTON_DELIM)) {
+			if (w == 0)
+				goto out;
+			*d++ = w & 0xff;
+			w = 0;
+			i++;
+			if (c & IN6PTON_DELIM) {
+				if (i != 4)
+					goto out;
+				break;
+			}
+			goto cont;
+		}
+		w = (w * 10) + c;
+		if ((w & 0xffff) > 255) {
+			goto out;
+		}
+cont:
+		if (i >= 4)
+			goto out;
+		s++;
+		srclen--;
+	}
+	ret = 1;
+	memcpy(dst, dbuf, sizeof(dbuf));
+out:
+	if (end)
+		*end = s;
+	return ret;
+}
+
+EXPORT_SYMBOL(in4_pton);
+
+int in6_pton(const char *src, int srclen,
+	     u8 *dst,
+	     char delim, const char **end)
+{
+	const char *s, *tok = NULL;
+	u8 *d, *dc = NULL;
+	u8 dbuf[16];
+	int ret = 0;
+	int i;
+	int state = IN6PTON_COLON_1_2 | IN6PTON_XDIGIT | IN6PTON_NULL;
+	int w = 0;
+
+	memset(dbuf, 0, sizeof(dbuf));
+
+	s = src;
+	d = dbuf;
+	if (srclen < 0)
+		srclen = strlen(src);
+
+	while (1) {
+		int c;
+
+		c = xdigit2bin(srclen > 0 ? *s : '\0', delim);
+		if (!(c & state))
+			goto out;
+		if (c & (IN6PTON_DELIM | IN6PTON_COLON_MASK)) {
+			/* process one 16-bit word */
+			if (!(state & IN6PTON_NULL)) {
+				*d++ = (w >> 8) & 0xff;
+				*d++ = w & 0xff;
+			}
+			w = 0;
+			if (c & IN6PTON_DELIM) {
+				/* We've processed last word */
+				break;
+			}
+			/*
+			 * COLON_1 => XDIGIT
+			 * COLON_2 => XDIGIT|DELIM
+			 * COLON_1_2 => COLON_2
+			 */
+			switch (state & IN6PTON_COLON_MASK) {
+			case IN6PTON_COLON_2:
+				dc = d;
+				state = IN6PTON_XDIGIT | IN6PTON_DELIM;
+				if (dc - dbuf >= sizeof(dbuf))
+					state |= IN6PTON_NULL;
+				break;
+			case IN6PTON_COLON_1|IN6PTON_COLON_1_2:
+				state = IN6PTON_XDIGIT | IN6PTON_COLON_2;
+				break;
+			case IN6PTON_COLON_1:
+				state = IN6PTON_XDIGIT;
+				break;
+			case IN6PTON_COLON_1_2:
+				state = IN6PTON_COLON_2;
+				break;
+			default:
+				state = 0;
+			}
+			tok = s + 1;
+			goto cont;
+		}
+
+		if (c & IN6PTON_DOT) {
+			ret = in4_pton(tok ? tok : s, srclen + (int)(s - tok), d, delim, &s);
+			if (ret > 0) {
+				d += 4;
+				break;
+			}
+			goto out;
+		}
+
+		w = (w << 4) | (0xff & c);
+		state = IN6PTON_COLON_1 | IN6PTON_DELIM;
+		if (!(w & 0xf000)) {
+			state |= IN6PTON_XDIGIT;
+		}
+		if (!dc && d + 2 < dbuf + sizeof(dbuf)) {
+			state |= IN6PTON_COLON_1_2;
+			state &= ~IN6PTON_DELIM;
+		}
+		if (d + 2 >= dbuf + sizeof(dbuf)) {
+			state &= ~(IN6PTON_COLON_1|IN6PTON_COLON_1_2);
+		}
+cont:
+		if ((dc && d + 4 < dbuf + sizeof(dbuf)) ||
+		    d + 4 == dbuf + sizeof(dbuf)) {
+			state |= IN6PTON_DOT;
+		}
+		if (d >= dbuf + sizeof(dbuf)) {
+			state &= ~(IN6PTON_XDIGIT|IN6PTON_COLON_MASK);
+		}
+		s++;
+		srclen--;
+	}
+
+	i = 15; d--;
+
+	if (dc) {
+		while(d >= dc)
+			dst[i--] = *d--;
+		while(i >= dc - dbuf)
+			dst[i--] = 0;
+		while(i >= 0)
+			dst[i--] = *d--;
+	} else
+		memcpy(dst, dbuf, sizeof(dbuf));
+
+	ret = 1;
+out:
+	if (end)
+		*end = s;
+	return ret;
+}
+
+EXPORT_SYMBOL(in6_pton);

---
commit 83f70895f157e743614b3c8c148aa8751949c689
Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date:   Mon Jun 19 03:20:32 2006 +0900

    [NETFILTER] NF_CONNTRACK_FTP: Use in6_pton() to convert address string.
    
    Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

diff --git a/net/netfilter/nf_conntrack_ftp.c b/net/netfilter/nf_conntrack_ftp.c
index 960972d..9dccb40 100644
--- a/net/netfilter/nf_conntrack_ftp.c
+++ b/net/netfilter/nf_conntrack_ftp.c
@@ -111,101 +111,13 @@ static struct ftp_search {
 	},
 };
 
-/* This code is based on inet_pton() in glibc-2.2.4 */
 static int
 get_ipv6_addr(const char *src, size_t dlen, struct in6_addr *dst, u_int8_t term)
 {
-	static const char xdigits[] = "0123456789abcdef";
-	u_int8_t tmp[16], *tp, *endp, *colonp;
-	int ch, saw_xdigit;
-	u_int32_t val;
-	size_t clen = 0;
-
-	tp = memset(tmp, '\0', sizeof(tmp));
-	endp = tp + sizeof(tmp);
-	colonp = NULL;
-
-	/* Leading :: requires some special handling. */
-	if (*src == ':'){
-		if (*++src != ':') {
-			DEBUGP("invalid \":\" at the head of addr\n");
-			return 0;
-		}
-		clen++;
-	}
-
-	saw_xdigit = 0;
-	val = 0;
-	while ((clen < dlen) && (*src != term)) {
-		const char *pch;
-
-		ch = tolower(*src++);
-		clen++;
-
-                pch = strchr(xdigits, ch);
-                if (pch != NULL) {
-                        val <<= 4;
-                        val |= (pch - xdigits);
-                        if (val > 0xffff)
-                                return 0;
-
-			saw_xdigit = 1;
-                        continue;
-                }
-		if (ch != ':') {
-			DEBUGP("get_ipv6_addr: invalid char. \'%c\'\n", ch);
-			return 0;
-		}
-
-		if (!saw_xdigit) {
-			if (colonp) {
-				DEBUGP("invalid location of \"::\".\n");
-				return 0;
-			}
-			colonp = tp;
-			continue;
-		} else if (*src == term) {
-			DEBUGP("trancated IPv6 addr\n");
-			return 0;
-		}
-
-		if (tp + 2 > endp)
-			return 0;
-		*tp++ = (u_int8_t) (val >> 8) & 0xff;
-		*tp++ = (u_int8_t) val & 0xff;
-
-		saw_xdigit = 0;
-		val = 0;
-		continue;
-        }
-        if (saw_xdigit) {
-                if (tp + 2 > endp)
-                        return 0;
-                *tp++ = (u_int8_t) (val >> 8) & 0xff;
-                *tp++ = (u_int8_t) val & 0xff;
-        }
-        if (colonp != NULL) {
-                /*
-                 * Since some memmove()'s erroneously fail to handle
-                 * overlapping regions, we'll do the shift by hand.
-                 */
-                const int n = tp - colonp;
-                int i;
-
-                if (tp == endp)
-                        return 0;
-
-                for (i = 1; i <= n; i++) {
-                        endp[- i] = colonp[n - i];
-                        colonp[n - i] = 0;
-                }
-                tp = endp;
-        }
-        if (tp != endp || (*src != term))
-                return 0;
-
-        memcpy(dst->s6_addr, tmp, sizeof(dst->s6_addr));
-        return clen;
+	int ret = in6_pton(src, min_t(size_t, dlen, 0xffff), dst, term, &end);
+	if (ret > 0)
+		return (int)(end - src);
+	return 0;
 }
 
 static int try_number(const char *data, size_t dlen, u_int32_t array[],

---

-- 
YOSHIFUJI Hideaki @ USAGI Project  <yoshfuji@linux-ipv6.org>
GPG-FP  : 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
