From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 27/44] [IPV6] IPSEC: Support sending with Mobile IPv6 extension headers.
Date: Thu, 24 Aug 2006 00:02:28 +0900
Message-ID: <11563453671174-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org> <1156345365312-git-send-email-yoshfuji@linux-ipv6.org> <11563453652646-git-send-email-yoshfuji@linux-ipv6.org> <1156345365315-git-send-email-yoshfuji@linux-ipv6.org> <11563453651452-git-send-email-yoshfuji@linux-ipv6.org> <1156345366288-git-send-email-yoshfuji@linux-ipv6.org> <1156345366857-git-send-email-yoshfuji@linux-ipv6.org> <11563453663761-git-send-email-yoshfuji@linux-ipv6.org> <11563453662321-git-send-email-yoshfuji@linux-ipv6.org>
  <11563453661892-git-send-email-yoshfuji@linux-ipv6.org> <11563453661207-git-send-email-yoshfuji@linux-ipv6.org> <11563453663743-git-send-email-yoshfuji@linux-ipv6.org> <1156345366676-git-send-email-yoshfuji@linux-ipv6.org> <11563453662840-git-send-email-yoshfuji@linux-ipv6.org> <11563453662913-git-send-email-yoshfuji@linux-ipv6.org> <11563453663400-git-send-email-yoshfuji@linux-ipv6.org> <1156345366549-git-send-email-yoshfuji@linux-ipv6.org> <11563453662956-git-send-email-yoshfuji@linux-ipv6.org> <11563453661764-git-send-email-yoshfuji@linux-ipv6.org> <11563453663275-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:7305 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964915AbWHWPCv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:51 -0400
To: davem@davemloft.net
In-Reply-To: <11563453663275-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Mobile IPv6 defines home address option as an option of destination
options header. It is placed before fragment header then
ip6_find_1stfragopt() is fixed to know about it.
Home address option also carries final source address of the flow, then
outbound AH calculation should take care of it like routing header case.
Based on MIPL2 kernel patch.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ah6.c        |  109 +++++++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_output.c |   18 ++++++--
 2 files changed, 122 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/ah6.c b/net/ipv6/ah6.c
index ab90b2d..96f36fd 100644
--- a/net/ipv6/ah6.c
+++ b/net/ipv6/ah6.c
@@ -74,6 +74,68 @@ bad:
 	return 0;
 }
 
+#ifdef CONFIG_IPV6_MIP6
+/**
+ *	ipv6_rearrange_destopt - rearrange IPv6 destination options header
+ *	@iph: IPv6 header
+ *	@destopt: destionation options header
+ */
+static void ipv6_rearrange_destopt(struct ipv6hdr *iph, struct ipv6_opt_hdr *destopt)
+{
+	u8 *opt = (u8 *)destopt;
+	int len = ipv6_optlen(destopt);
+	int off = 0;
+	int optlen = 0;
+
+	off += 2;
+	len -= 2;
+
+	while (len > 0) {
+
+		switch (opt[off]) {
+
+		case IPV6_TLV_PAD0:
+			optlen = 1;
+			break;
+		default:
+			if (len < 2)
+				goto bad;
+			optlen = opt[off+1]+2;
+			if (len < optlen)
+				goto bad;
+
+			/* Rearrange the source address in @iph and the
+			 * addresses in home address option for final source.
+			 * See 11.3.2 of RFC 3775 for details.
+			 */
+			if (opt[off] == IPV6_TLV_HAO) {
+				struct in6_addr final_addr;
+				struct ipv6_destopt_hao *hao;
+
+				hao = (struct ipv6_destopt_hao *)&opt[off];
+				if (hao->length != sizeof(hao->addr)) {
+					if (net_ratelimit())
+						printk(KERN_WARNING "destopt hao: invalid header length: %u\n", hao->length);
+					goto bad;
+				}
+				ipv6_addr_copy(&final_addr, &hao->addr);
+				ipv6_addr_copy(&hao->addr, &iph->saddr);
+				ipv6_addr_copy(&iph->saddr, &final_addr);
+			}
+			break;
+		}
+
+		off += optlen;
+		len -= optlen;
+	}
+	if (len == 0)
+		return;
+
+bad:
+	return;
+}
+#endif
+
 /**
  *	ipv6_rearrange_rthdr - rearrange IPv6 routing header
  *	@iph: IPv6 header
@@ -113,7 +175,11 @@ static void ipv6_rearrange_rthdr(struct 
 	ipv6_addr_copy(&iph->daddr, &final_addr);
 }
 
+#ifdef CONFIG_IPV6_MIP6
+static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
+#else
 static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len)
+#endif
 {
 	union {
 		struct ipv6hdr *iph;
@@ -128,6 +194,28 @@ static int ipv6_clear_mutable_options(st
 
 	while (exthdr.raw < end) {
 		switch (nexthdr) {
+#ifdef CONFIG_IPV6_MIP6
+		case NEXTHDR_HOP:
+			if (!zero_out_mutable_opts(exthdr.opth)) {
+				LIMIT_NETDEBUG(
+					KERN_WARNING "overrun %sopts\n",
+					nexthdr == NEXTHDR_HOP ?
+						"hop" : "dest");
+				return -EINVAL;
+			}
+			break;
+		case NEXTHDR_DEST:
+			if (dir == XFRM_POLICY_OUT)
+				ipv6_rearrange_destopt(iph, exthdr.opth);
+			if (!zero_out_mutable_opts(exthdr.opth)) {
+				LIMIT_NETDEBUG(
+					KERN_WARNING "overrun %sopts\n",
+					nexthdr == NEXTHDR_HOP ?
+						"hop" : "dest");
+				return -EINVAL;
+			}
+			break;
+#else
 		case NEXTHDR_HOP:
 		case NEXTHDR_DEST:
 			if (!zero_out_mutable_opts(exthdr.opth)) {
@@ -138,6 +226,7 @@ static int ipv6_clear_mutable_options(st
 				return -EINVAL;
 			}
 			break;
+#endif
 
 		case NEXTHDR_ROUTING:
 			ipv6_rearrange_rthdr(iph, exthdr.rth);
@@ -164,6 +253,9 @@ static int ah6_output(struct xfrm_state 
 	u8 nexthdr;
 	char tmp_base[8];
 	struct {
+#ifdef CONFIG_IPV6_MIP6
+		struct in6_addr saddr;
+#endif
 		struct in6_addr daddr;
 		char hdrs[0];
 	} *tmp_ext;
@@ -188,10 +280,18 @@ static int ah6_output(struct xfrm_state 
 			err = -ENOMEM;
 			goto error;
 		}
+#ifdef CONFIG_IPV6_MIP6
+		memcpy(tmp_ext, &top_iph->saddr, extlen);
+		err = ipv6_clear_mutable_options(top_iph,
+						 extlen - sizeof(*tmp_ext) +
+						 sizeof(*top_iph),
+						 XFRM_POLICY_OUT);
+#else
 		memcpy(tmp_ext, &top_iph->daddr, extlen);
 		err = ipv6_clear_mutable_options(top_iph,
 						 extlen - sizeof(*tmp_ext) +
 						 sizeof(*top_iph));
+#endif
 		if (err)
 			goto error_free_iph;
 	}
@@ -219,7 +319,11 @@ static int ah6_output(struct xfrm_state 
 
 	memcpy(top_iph, tmp_base, sizeof(tmp_base));
 	if (tmp_ext) {
+#ifdef CONFIG_IPV6_MIP6
+		memcpy(&top_iph->saddr, tmp_ext, extlen);
+#else
 		memcpy(&top_iph->daddr, tmp_ext, extlen);
+#endif
 error_free_iph:
 		kfree(tmp_ext);
 	}
@@ -278,8 +382,13 @@ static int ah6_input(struct xfrm_state *
 	if (!tmp_hdr)
 		goto out;
 	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
+#ifdef CONFIG_IPV6_MIP6
+	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len, XFRM_POLICY_IN))
+		goto out;
+#else
 	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len))
 		goto free_out;
+#endif
 	skb->nh.ipv6h->priority    = 0;
 	skb->nh.ipv6h->flow_lbl[0] = 0;
 	skb->nh.ipv6h->flow_lbl[1] = 0;
diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index ebb23db..7436947 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -475,17 +475,25 @@ int ip6_find_1stfragopt(struct sk_buff *
 		switch (**nexthdr) {
 
 		case NEXTHDR_HOP:
+			break;
 		case NEXTHDR_ROUTING:
+			found_rhdr = 1;
+			break;
 		case NEXTHDR_DEST:
-			if (**nexthdr == NEXTHDR_ROUTING) found_rhdr = 1;
-			if (**nexthdr == NEXTHDR_DEST && found_rhdr) return offset;
-			offset += ipv6_optlen(exthdr);
-			*nexthdr = &exthdr->nexthdr;
-			exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
+#ifdef CONFIG_IPV6_MIP6
+			if (ipv6_find_tlv(skb, offset, IPV6_TLV_HAO) >= 0)
+				break;
+#endif
+			if (found_rhdr)
+				return offset;
 			break;
 		default :
 			return offset;
 		}
+
+		offset += ipv6_optlen(exthdr);
+		*nexthdr = &exthdr->nexthdr;
+		exthdr = (struct ipv6_opt_hdr*)(skb->nh.raw + offset);
 	}
 
 	return offset;
-- 
1.4.0

