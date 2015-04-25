From: Ian Morris <ipm@chirality.org.uk>
Subject: [PATCH net-next 6/6] ipv6: netfilter: simply if-else statements
Date: Sat, 25 Apr 2015 10:27:00 +0100
Message-ID: <1429954020-11763-7-git-send-email-ipm@chirality.org.uk>
References: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Cc: Ian Morris <ipm@chirality.org.uk>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from inet-gw.chirality.org.uk ([88.97.209.22]:36722 "EHLO
	yew.chirality.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758804AbbDYJ1K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Apr 2015 05:27:10 -0400
In-Reply-To: <1429954020-11763-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Remove "else" branch of "if" statements where a return is always done
when the condition is true.

No changes detected by objdiff.

Signed-off-by: Ian Morris <ipm@chirality.org.uk>
---
 net/ipv6/netfilter/ip6_tables.c                |   7 +-
 net/ipv6/netfilter/ip6t_hbh.c                  | 105 ++++++++++++-------------
 net/ipv6/netfilter/ip6t_rt.c                   | 100 +++++++++++------------
 net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c |   5 +-
 4 files changed, 105 insertions(+), 112 deletions(-)

diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
index ed3612d..ad02f10 100644
--- a/net/ipv6/netfilter/ip6_tables.c
+++ b/net/ipv6/netfilter/ip6_tables.c
@@ -268,8 +268,8 @@ get_chainname_rulenum(const struct ip6t_entry *s, const struct ip6t_entry *e,
 				: comments[NF_IP6_TRACE_COMMENT_RETURN];
 		}
 		return 1;
-	} else
-		(*rulenum)++;
+	}
+	(*rulenum)++;
 
 	return 0;
 }
@@ -446,7 +446,8 @@ ip6t_do_table(struct sk_buff *skb,
 #else
 	if (acpar.hotdrop)
 		return NF_DROP;
-	else return verdict;
+
+	return verdict;
 #endif
 }
 
diff --git a/net/ipv6/netfilter/ip6t_hbh.c b/net/ipv6/netfilter/ip6t_hbh.c
index a99313f..98304ba 100644
--- a/net/ipv6/netfilter/ip6t_hbh.c
+++ b/net/ipv6/netfilter/ip6t_hbh.c
@@ -95,70 +95,67 @@ hbh_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 
 	ptr += 2;
 	hdrlen -= 2;
-	if (!(optinfo->flags & IP6T_OPTS_OPTS)) {
+	if (!(optinfo->flags & IP6T_OPTS_OPTS))
 		return ret;
-	} else {
-		pr_debug("Strict ");
-		pr_debug("#%d ", optinfo->optsnr);
-		for (temp = 0; temp < optinfo->optsnr; temp++) {
-			/* type field exists ? */
-			if (hdrlen < 1)
+
+	pr_debug("Strict ");
+	pr_debug("#%d ", optinfo->optsnr);
+	for (temp = 0; temp < optinfo->optsnr; temp++) {
+		/* type field exists ? */
+		if (hdrlen < 1)
+			break;
+		tp = skb_header_pointer(skb, ptr, sizeof(_opttype),
+					&_opttype);
+		if (!tp)
+			break;
+
+		/* Type check */
+		if (*tp != (optinfo->opts[temp] & 0xFF00) >> 8) {
+			pr_debug("Tbad %02X %02X\n", *tp,
+				 (optinfo->opts[temp] & 0xFF00) >> 8);
+			return false;
+		}
+		pr_debug("Tok ");
+
+		/* Length check */
+		if (*tp) {
+			u16 spec_len;
+
+			/* length field exists ? */
+			if (hdrlen < 2)
 				break;
-			tp = skb_header_pointer(skb, ptr, sizeof(_opttype),
-						&_opttype);
-			if (!tp)
+			lp = skb_header_pointer(skb, ptr + 1,
+						sizeof(_optlen),
+						&_optlen);
+			if (!lp)
 				break;
+			spec_len = optinfo->opts[temp] & 0x00FF;
 
-			/* Type check */
-			if (*tp != (optinfo->opts[temp] & 0xFF00) >> 8) {
-				pr_debug("Tbad %02X %02X\n", *tp,
-					 (optinfo->opts[temp] & 0xFF00) >> 8);
+			if (spec_len != 0x00FF && spec_len != *lp) {
+				pr_debug("Lbad %02X %04X\n", *lp,
+					 spec_len);
 				return false;
-			} else {
-				pr_debug("Tok ");
-			}
-			/* Length check */
-			if (*tp) {
-				u16 spec_len;
-
-				/* length field exists ? */
-				if (hdrlen < 2)
-					break;
-				lp = skb_header_pointer(skb, ptr + 1,
-							sizeof(_optlen),
-							&_optlen);
-				if (!lp)
-					break;
-				spec_len = optinfo->opts[temp] & 0x00FF;
-
-				if (spec_len != 0x00FF && spec_len != *lp) {
-					pr_debug("Lbad %02X %04X\n", *lp,
-						 spec_len);
-					return false;
-				}
-				pr_debug("Lok ");
-				optlen = *lp + 2;
-			} else {
-				pr_debug("Pad1\n");
-				optlen = 1;
 			}
+			pr_debug("Lok ");
+			optlen = *lp + 2;
+		} else {
+			pr_debug("Pad1\n");
+			optlen = 1;
+		}
 
-			/* Step to the next */
-			pr_debug("len%04X\n", optlen);
+		/* Step to the next */
+		pr_debug("len%04X\n", optlen);
 
-			if ((ptr > skb->len - optlen || hdrlen < optlen) &&
-			    temp < optinfo->optsnr - 1) {
-				pr_debug("new pointer is too large!\n");
-				break;
-			}
-			ptr += optlen;
-			hdrlen -= optlen;
+		if ((ptr > skb->len - optlen || hdrlen < optlen) &&
+		    temp < optinfo->optsnr - 1) {
+			pr_debug("new pointer is too large!\n");
+			break;
 		}
-		if (temp == optinfo->optsnr)
-			return ret;
-		else
-			return false;
+		ptr += optlen;
+		hdrlen -= optlen;
 	}
+	if (temp == optinfo->optsnr)
+		return ret;
 
 	return false;
 }
diff --git a/net/ipv6/netfilter/ip6t_rt.c b/net/ipv6/netfilter/ip6t_rt.c
index bdab49e..f2668e2 100644
--- a/net/ipv6/netfilter/ip6t_rt.c
+++ b/net/ipv6/netfilter/ip6t_rt.c
@@ -119,66 +119,62 @@ static bool rt_mt6(const struct sk_buff *skb, struct xt_action_param *par)
 	if (!(rtinfo->flags & IP6T_RT_FST)) {
 		return ret;
 	} else if (rtinfo->flags & IP6T_RT_FST_NSTRICT) {
+		unsigned int i = 0;
+
 		pr_debug("Not strict ");
 		if (rtinfo->addrnr > (unsigned int)((hdrlen - 8) / 16)) {
 			pr_debug("There isn't enough space\n");
 			return false;
-		} else {
-			unsigned int i = 0;
-
-			pr_debug("#%d ", rtinfo->addrnr);
-			for (temp = 0;
-			     temp < (unsigned int)((hdrlen - 8) / 16);
-			     temp++) {
-				ap = skb_header_pointer(skb,
-							ptr
-							+ sizeof(struct rt0_hdr)
-							+ temp * sizeof(_addr),
-							sizeof(_addr),
-							&_addr);
-
-				BUG_ON(!ap);
-
-				if (ipv6_addr_equal(ap, &rtinfo->addrs[i])) {
-					pr_debug("i=%d temp=%d;\n", i, temp);
-					i++;
-				}
-				if (i == rtinfo->addrnr)
-					break;
-			}
-			pr_debug("i=%d #%d\n", i, rtinfo->addrnr);
-			if (i == rtinfo->addrnr)
-				return ret;
-			else
-				return false;
 		}
-	} else {
-		pr_debug("Strict ");
-		if (rtinfo->addrnr > (unsigned int)((hdrlen - 8) / 16)) {
-			pr_debug("There isn't enough space\n");
-			return false;
-		} else {
-			pr_debug("#%d ", rtinfo->addrnr);
-			for (temp = 0; temp < rtinfo->addrnr; temp++) {
-				ap = skb_header_pointer(skb,
-							ptr
-							+ sizeof(struct rt0_hdr)
-							+ temp * sizeof(_addr),
-							sizeof(_addr),
-							&_addr);
-				BUG_ON(!ap);
-
-				if (!ipv6_addr_equal(ap, &rtinfo->addrs[temp]))
-					break;
+
+		pr_debug("#%d ", rtinfo->addrnr);
+		for (temp = 0;
+		     temp < (unsigned int)((hdrlen - 8) / 16);
+		     temp++) {
+			ap = skb_header_pointer(skb,
+						ptr
+						+ sizeof(struct rt0_hdr)
+						+ temp * sizeof(_addr),
+						sizeof(_addr),
+						&_addr);
+
+			BUG_ON(!ap);
+
+			if (ipv6_addr_equal(ap, &rtinfo->addrs[i])) {
+				pr_debug("i=%d temp=%d;\n", i, temp);
+				i++;
 			}
-			pr_debug("temp=%d #%d\n", temp, rtinfo->addrnr);
-			if (temp == rtinfo->addrnr &&
-			    temp == (unsigned int)((hdrlen - 8) / 16))
-				return ret;
-			else
-				return false;
+			if (i == rtinfo->addrnr)
+				break;
 		}
+		pr_debug("i=%d #%d\n", i, rtinfo->addrnr);
+		if (i == rtinfo->addrnr)
+			return ret;
+
+		return false;
+	}
+	pr_debug("Strict ");
+	if (rtinfo->addrnr > (unsigned int)((hdrlen - 8) / 16)) {
+		pr_debug("There isn't enough space\n");
+		return false;
 	}
+	pr_debug("#%d ", rtinfo->addrnr);
+	for (temp = 0; temp < rtinfo->addrnr; temp++) {
+		ap = skb_header_pointer(skb,
+					ptr
+					+ sizeof(struct rt0_hdr)
+					+ temp * sizeof(_addr),
+					sizeof(_addr),
+					&_addr);
+		BUG_ON(!ap);
+
+		if (!ipv6_addr_equal(ap, &rtinfo->addrs[temp]))
+			break;
+	}
+	pr_debug("temp=%d #%d\n", temp, rtinfo->addrnr);
+	if (temp == rtinfo->addrnr &&
+	    temp == (unsigned int)((hdrlen - 8) / 16))
+		return ret;
 
 	return false;
 }
diff --git a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
index b6cd77b..10030ad 100644
--- a/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
+++ b/net/ipv6/netfilter/nf_conntrack_proto_icmpv6.c
@@ -181,10 +181,9 @@ icmpv6_error_message(struct net *net, struct nf_conn *tmpl,
 	if (!h) {
 		pr_debug("icmpv6_error: no match\n");
 		return -NF_ACCEPT;
-	} else {
-		if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
-			*ctinfo += IP_CT_IS_REPLY;
 	}
+	if (NF_CT_DIRECTION(h) == IP_CT_DIR_REPLY)
+		*ctinfo += IP_CT_IS_REPLY;
 
 	/* Update skb to refer to this connection */
 	skb->nfct = &nf_ct_tuplehash_to_ctrack(h)->ct_general;
-- 
1.9.1
