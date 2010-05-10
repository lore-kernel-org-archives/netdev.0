From: kaber@trash.net
Subject: [PATCH 27/84] netfilter: xtables: replace custom duprintf with pr_debug
Date: Mon, 10 May 2010 22:17:58 +0200
Message-ID: <1273522735-24672-28-git-send-email-kaber@trash.net>
References: <1273522735-24672-1-git-send-email-kaber@trash.net>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1273522735-24672-1-git-send-email-kaber@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jan Engelhardt <jengelh@medozas.de>

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 net/ipv4/netfilter/ipt_ah.c  |   18 ++++++------------
 net/ipv6/netfilter/ip6t_mh.c |   11 +++--------
 net/netfilter/x_tables.c     |   12 +++---------
 net/netfilter/xt_esp.c       |   18 ++++++------------
 net/netfilter/xt_multiport.c |   16 +++++-----------
 net/netfilter/xt_sctp.c      |   29 +++++++++++++----------------
 net/netfilter/xt_tcpudp.c    |   16 +++++-----------
 7 files changed, 41 insertions(+), 79 deletions(-)

diff --git a/net/ipv4/netfilter/ipt_ah.c b/net/ipv4/netfilter/ipt_ah.c
index 0104c0b..4f27e17 100644
--- a/net/ipv4/netfilter/ipt_ah.c
+++ b/net/ipv4/netfilter/ipt_ah.c
@@ -5,7 +5,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/in.h>
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -18,21 +18,15 @@ MODULE_LICENSE("GPL");
 MODULE_AUTHOR("Yon Uriarte <yon@astaro.de>");
 MODULE_DESCRIPTION("Xtables: IPv4 IPsec-AH SPI match");
 
-#ifdef DEBUG_CONNTRACK
-#define duprintf(format, args...) printk(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
 /* Returns 1 if the spi is matched by the range, 0 otherwise */
 static inline bool
 spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 {
 	bool r;
-	duprintf("ah spi_match:%c 0x%x <= 0x%x <= 0x%x",invert? '!':' ',
-		min,spi,max);
+	pr_debug("spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
+		 invert ? '!' : ' ', min, spi, max);
 	r=(spi >= min && spi <= max) ^ invert;
-	duprintf(" result %s\n",r? "PASS" : "FAILED");
+	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
 	return r;
 }
 
@@ -51,7 +45,7 @@ static bool ah_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		/* We've been asked to examine this packet, and we
 		 * can't.  Hence, no choice but to drop.
 		 */
-		duprintf("Dropping evil AH tinygram.\n");
+		pr_debug("Dropping evil AH tinygram.\n");
 		*par->hotdrop = true;
 		return 0;
 	}
@@ -67,7 +61,7 @@ static bool ah_mt_check(const struct xt_mtchk_param *par)
 
 	/* Must specify no unknown invflags */
 	if (ahinfo->invflags & ~IPT_AH_INV_MASK) {
-		duprintf("ipt_ah: unknown flags %X\n", ahinfo->invflags);
+		pr_debug("unknown flags %X\n", ahinfo->invflags);
 		return false;
 	}
 	return true;
diff --git a/net/ipv6/netfilter/ip6t_mh.c b/net/ipv6/netfilter/ip6t_mh.c
index aafe4e6..0181eb8 100644
--- a/net/ipv6/netfilter/ip6t_mh.c
+++ b/net/ipv6/netfilter/ip6t_mh.c
@@ -11,6 +11,7 @@
  * Based on net/netfilter/xt_tcpudp.c
  *
  */
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/types.h>
 #include <linux/module.h>
 #include <net/ip.h>
@@ -24,12 +25,6 @@
 MODULE_DESCRIPTION("Xtables: IPv6 Mobility Header match");
 MODULE_LICENSE("GPL");
 
-#ifdef DEBUG_IP_FIREWALL_USER
-#define duprintf(format, args...) printk(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
 /* Returns 1 if the type is matched by the range, 0 otherwise */
 static inline bool
 type_match(u_int8_t min, u_int8_t max, u_int8_t type, bool invert)
@@ -51,13 +46,13 @@ static bool mh_mt6(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (mh == NULL) {
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
-		duprintf("Dropping evil MH tinygram.\n");
+		pr_debug("Dropping evil MH tinygram.\n");
 		*par->hotdrop = true;
 		return false;
 	}
 
 	if (mh->ip6mh_proto != IPPROTO_NONE) {
-		duprintf("Dropping invalid MH Payload Proto: %u\n",
+		pr_debug("Dropping invalid MH Payload Proto: %u\n",
 			 mh->ip6mh_proto);
 		*par->hotdrop = true;
 		return false;
diff --git a/net/netfilter/x_tables.c b/net/netfilter/x_tables.c
index 0a12ced..9a248d4 100644
--- a/net/netfilter/x_tables.c
+++ b/net/netfilter/x_tables.c
@@ -12,7 +12,7 @@
  * published by the Free Software Foundation.
  *
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/kernel.h>
 #include <linux/socket.h>
 #include <linux/net.h>
@@ -54,12 +54,6 @@ struct xt_af {
 
 static struct xt_af *xt;
 
-#ifdef DEBUG_IP_FIREWALL_USER
-#define duprintf(format, args...) printk(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
 static const char *const xt_prefix[NFPROTO_NUMPROTO] = {
 	[NFPROTO_UNSPEC] = "x",
 	[NFPROTO_IPV4]   = "ip",
@@ -720,7 +714,7 @@ xt_replace_table(struct xt_table *table,
 
 	/* Check inside lock: is the old number correct? */
 	if (num_counters != private->number) {
-		duprintf("num_counters != table->private->number (%u/%u)\n",
+		pr_debug("num_counters != table->private->number (%u/%u)\n",
 			 num_counters, private->number);
 		local_bh_enable();
 		*error = -EAGAIN;
@@ -777,7 +771,7 @@ struct xt_table *xt_register_table(struct net *net,
 		goto unlock;
 
 	private = table->private;
-	duprintf("table->private->number = %u\n", private->number);
+	pr_debug("table->private->number = %u\n", private->number);
 
 	/* save number of initial entries */
 	private->initial_entries = private->number;
diff --git a/net/netfilter/xt_esp.c b/net/netfilter/xt_esp.c
index 6094399..f9deecb 100644
--- a/net/netfilter/xt_esp.c
+++ b/net/netfilter/xt_esp.c
@@ -6,7 +6,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <linux/in.h>
@@ -24,21 +24,15 @@ MODULE_DESCRIPTION("Xtables: IPsec-ESP packet match");
 MODULE_ALIAS("ipt_esp");
 MODULE_ALIAS("ip6t_esp");
 
-#if 0
-#define duprintf(format, args...) printk(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
 /* Returns 1 if the spi is matched by the range, 0 otherwise */
 static inline bool
 spi_match(u_int32_t min, u_int32_t max, u_int32_t spi, bool invert)
 {
 	bool r;
-	duprintf("esp spi_match:%c 0x%x <= 0x%x <= 0x%x", invert ? '!' : ' ',
-		 min, spi, max);
+	pr_debug("esp spi_match:%c 0x%x <= 0x%x <= 0x%x\n",
+		 invert ? '!' : ' ', min, spi, max);
 	r = (spi >= min && spi <= max) ^ invert;
-	duprintf(" result %s\n", r ? "PASS" : "FAILED");
+	pr_debug(" result %s\n", r ? "PASS" : "FAILED");
 	return r;
 }
 
@@ -57,7 +51,7 @@ static bool esp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		/* We've been asked to examine this packet, and we
 		 * can't.  Hence, no choice but to drop.
 		 */
-		duprintf("Dropping evil ESP tinygram.\n");
+		pr_debug("Dropping evil ESP tinygram.\n");
 		*par->hotdrop = true;
 		return false;
 	}
@@ -71,7 +65,7 @@ static bool esp_mt_check(const struct xt_mtchk_param *par)
 	const struct xt_esp *espinfo = par->matchinfo;
 
 	if (espinfo->invflags & ~XT_ESP_INV_MASK) {
-		duprintf("xt_esp: unknown flags %X\n", espinfo->invflags);
+		pr_debug("unknown flags %X\n", espinfo->invflags);
 		return false;
 	}
 
diff --git a/net/netfilter/xt_multiport.c b/net/netfilter/xt_multiport.c
index d06bb2d..4fa90c8 100644
--- a/net/netfilter/xt_multiport.c
+++ b/net/netfilter/xt_multiport.c
@@ -8,7 +8,7 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  */
-
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/types.h>
 #include <linux/udp.h>
@@ -26,12 +26,6 @@ MODULE_DESCRIPTION("Xtables: multiple port matching for TCP, UDP, UDP-Lite, SCTP
 MODULE_ALIAS("ipt_multiport");
 MODULE_ALIAS("ip6t_multiport");
 
-#if 0
-#define duprintf(format, args...) printk(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
 /* Returns 1 if the port is matched by the test, 0 otherwise. */
 static inline bool
 ports_match_v0(const u_int16_t *portlist, enum xt_multiport_flags flags,
@@ -63,7 +57,7 @@ ports_match_v1(const struct xt_multiport_v1 *minfo,
 		if (minfo->pflags[i]) {
 			/* range port matching */
 			e = minfo->ports[++i];
-			duprintf("src or dst matches with %d-%d?\n", s, e);
+			pr_debug("src or dst matches with %d-%d?\n", s, e);
 
 			if (minfo->flags == XT_MULTIPORT_SOURCE
 			    && src >= s && src <= e)
@@ -77,7 +71,7 @@ ports_match_v1(const struct xt_multiport_v1 *minfo,
 				return true ^ minfo->invert;
 		} else {
 			/* exact port matching */
-			duprintf("src or dst matches with %d?\n", s);
+			pr_debug("src or dst matches with %d?\n", s);
 
 			if (minfo->flags == XT_MULTIPORT_SOURCE
 			    && src == s)
@@ -109,7 +103,7 @@ multiport_mt_v0(const struct sk_buff *skb, const struct xt_match_param *par)
 		/* We've been asked to examine this packet, and we
 		 * can't.  Hence, no choice but to drop.
 		 */
-		duprintf("xt_multiport: Dropping evil offset=0 tinygram.\n");
+		pr_debug("Dropping evil offset=0 tinygram.\n");
 		*par->hotdrop = true;
 		return false;
 	}
@@ -133,7 +127,7 @@ multiport_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		/* We've been asked to examine this packet, and we
 		 * can't.  Hence, no choice but to drop.
 		 */
-		duprintf("xt_multiport: Dropping evil offset=0 tinygram.\n");
+		pr_debug("Dropping evil offset=0 tinygram.\n");
 		*par->hotdrop = true;
 		return false;
 	}
diff --git a/net/netfilter/xt_sctp.c b/net/netfilter/xt_sctp.c
index a189ada..43c7e1d 100644
--- a/net/netfilter/xt_sctp.c
+++ b/net/netfilter/xt_sctp.c
@@ -1,3 +1,4 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/module.h>
 #include <linux/skbuff.h>
 #include <net/ip.h>
@@ -15,12 +16,6 @@ MODULE_DESCRIPTION("Xtables: SCTP protocol packet match");
 MODULE_ALIAS("ipt_sctp");
 MODULE_ALIAS("ip6t_sctp");
 
-#ifdef DEBUG_SCTP
-#define duprintf(format, args...) printk(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
 #define SCCHECK(cond, option, flag, invflag) (!((flag) & (option)) \
 					      || (!!((invflag) & (option)) ^ (cond)))
 
@@ -52,7 +47,7 @@ match_packet(const struct sk_buff *skb,
 	const struct xt_sctp_flag_info *flag_info = info->flag_info;
 	int flag_count = info->flag_count;
 
-#ifdef DEBUG_SCTP
+#ifdef DEBUG
 	int i = 0;
 #endif
 
@@ -62,17 +57,19 @@ match_packet(const struct sk_buff *skb,
 	do {
 		sch = skb_header_pointer(skb, offset, sizeof(_sch), &_sch);
 		if (sch == NULL || sch->length == 0) {
-			duprintf("Dropping invalid SCTP packet.\n");
+			pr_debug("Dropping invalid SCTP packet.\n");
 			*hotdrop = true;
 			return false;
 		}
-
-		duprintf("Chunk num: %d\toffset: %d\ttype: %d\tlength: %d\tflags: %x\n",
-				++i, offset, sch->type, htons(sch->length), sch->flags);
-
+#ifdef DEBUG
+		pr_debug("Chunk num: %d\toffset: %d\ttype: %d\tlength: %d"
+			 "\tflags: %x\n",
+			 ++i, offset, sch->type, htons(sch->length),
+			 sch->flags);
+#endif
 		offset += (ntohs(sch->length) + 3) & ~3;
 
-		duprintf("skb->len: %d\toffset: %d\n", skb->len, offset);
+		pr_debug("skb->len: %d\toffset: %d\n", skb->len, offset);
 
 		if (SCTP_CHUNKMAP_IS_SET(info->chunkmap, sch->type)) {
 			switch (chunk_match_type) {
@@ -124,17 +121,17 @@ sctp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	sctp_sctphdr_t _sh;
 
 	if (par->fragoff != 0) {
-		duprintf("Dropping non-first fragment.. FIXME\n");
+		pr_debug("Dropping non-first fragment.. FIXME\n");
 		return false;
 	}
 
 	sh = skb_header_pointer(skb, par->thoff, sizeof(_sh), &_sh);
 	if (sh == NULL) {
-		duprintf("Dropping evil TCP offset=0 tinygram.\n");
+		pr_debug("Dropping evil TCP offset=0 tinygram.\n");
 		*par->hotdrop = true;
 		return false;
 	}
-	duprintf("spt: %d\tdpt: %d\n", ntohs(sh->source), ntohs(sh->dest));
+	pr_debug("spt: %d\tdpt: %d\n", ntohs(sh->source), ntohs(sh->dest));
 
 	return  SCCHECK(ntohs(sh->source) >= info->spts[0]
 			&& ntohs(sh->source) <= info->spts[1],
diff --git a/net/netfilter/xt_tcpudp.c b/net/netfilter/xt_tcpudp.c
index 1ebdc49..b53887f 100644
--- a/net/netfilter/xt_tcpudp.c
+++ b/net/netfilter/xt_tcpudp.c
@@ -1,3 +1,4 @@
+#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
 #include <linux/types.h>
 #include <linux/module.h>
 #include <net/ip.h>
@@ -19,13 +20,6 @@ MODULE_ALIAS("ipt_tcp");
 MODULE_ALIAS("ip6t_udp");
 MODULE_ALIAS("ip6t_tcp");
 
-#ifdef DEBUG_IP_FIREWALL_USER
-#define duprintf(format, args...) printk(format , ## args)
-#else
-#define duprintf(format, args...)
-#endif
-
-
 /* Returns 1 if the port is matched by the range, 0 otherwise */
 static inline bool
 port_match(u_int16_t min, u_int16_t max, u_int16_t port, bool invert)
@@ -46,7 +40,7 @@ tcp_find_option(u_int8_t option,
 	u_int8_t _opt[60 - sizeof(struct tcphdr)];
 	unsigned int i;
 
-	duprintf("tcp_match: finding option\n");
+	pr_debug("finding option\n");
 
 	if (!optlen)
 		return invert;
@@ -82,7 +76,7 @@ static bool tcp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 		   flag overwrite to pass the direction checks.
 		*/
 		if (par->fragoff == 1) {
-			duprintf("Dropping evil TCP offset=1 frag.\n");
+			pr_debug("Dropping evil TCP offset=1 frag.\n");
 			*par->hotdrop = true;
 		}
 		/* Must not be a fragment. */
@@ -95,7 +89,7 @@ static bool tcp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (th == NULL) {
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
-		duprintf("Dropping evil TCP offset=0 tinygram.\n");
+		pr_debug("Dropping evil TCP offset=0 tinygram.\n");
 		*par->hotdrop = true;
 		return false;
 	}
@@ -148,7 +142,7 @@ static bool udp_mt(const struct sk_buff *skb, const struct xt_match_param *par)
 	if (uh == NULL) {
 		/* We've been asked to examine this packet, and we
 		   can't.  Hence, no choice but to drop. */
-		duprintf("Dropping evil UDP tinygram.\n");
+		pr_debug("Dropping evil UDP tinygram.\n");
 		*par->hotdrop = true;
 		return false;
 	}
-- 
1.7.0.4

