From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH v2 net 2/2] ipv6: fix ip6_tnl_parse_tlv_enc_lim()
Date: Mon, 23 Jan 2017 16:43:06 -0800
Message-ID: <20170124004306.19236-3-edumazet@google.com>
References: <20170124004306.19236-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33767 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751786AbdAXAnY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 19:43:24 -0500
Received: by mail-pf0-f172.google.com with SMTP id y143so45192901pfb.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 16:43:18 -0800 (PST)
In-Reply-To: <20170124004306.19236-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This function suffers from multiple issues.

First one is that pskb_may_pull() may reallocate skb->head,
so the 'raw' pointer needs either to be reloaded or not used at all.

Second issue is that NEXTHDR_DEST handling does not validate
that the options are present in skb->data, so we might read
garbage or access non existent memory.

With help from Willem de Bruijn.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Reported-by: Dmitry Vyukov  <dvyukov@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/ipv6/ip6_tunnel.c | 34 ++++++++++++++++++++++------------
 1 file changed, 22 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 02923f956ac8ba5f3270e8d5282fd9637c2d..ff8ee06491c335d209e86bb15f2526ab1915 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -400,18 +400,19 @@ ip6_tnl_dev_uninit(struct net_device *dev)
 
 __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw)
 {
-	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *) raw;
-	__u8 nexthdr = ipv6h->nexthdr;
-	__u16 off = sizeof(*ipv6h);
+	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *)raw;
+	unsigned int nhoff = raw - skb->data;
+	unsigned int off = nhoff + sizeof(*ipv6h);
+	u8 next, nexthdr = ipv6h->nexthdr;
 
 	while (ipv6_ext_hdr(nexthdr) && nexthdr != NEXTHDR_NONE) {
-		__u16 optlen = 0;
 		struct ipv6_opt_hdr *hdr;
-		if (raw + off + sizeof(*hdr) > skb->data &&
-		    !pskb_may_pull(skb, raw - skb->data + off + sizeof (*hdr)))
+		u16 optlen;
+
+		if (!pskb_may_pull(skb, off + sizeof(*hdr)))
 			break;
 
-		hdr = (struct ipv6_opt_hdr *) (raw + off);
+		hdr = (struct ipv6_opt_hdr *)(skb->data + off);
 		if (nexthdr == NEXTHDR_FRAGMENT) {
 			struct frag_hdr *frag_hdr = (struct frag_hdr *) hdr;
 			if (frag_hdr->frag_off)
@@ -422,20 +423,29 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw)
 		} else {
 			optlen = ipv6_optlen(hdr);
 		}
+		/* cache hdr->nexthdr, since pskb_may_pull() might
+		 * invalidate hdr
+		 */
+		next = hdr->nexthdr;
 		if (nexthdr == NEXTHDR_DEST) {
-			__u16 i = off + 2;
+			u16 i = 2;
+
+			/* Remember : hdr is no longer valid at this point. */
+			if (!pskb_may_pull(skb, off + optlen))
+				break;
+
 			while (1) {
 				struct ipv6_tlv_tnl_enc_lim *tel;
 
 				/* No more room for encapsulation limit */
-				if (i + sizeof (*tel) > off + optlen)
+				if (i + sizeof(*tel) > optlen)
 					break;
 
-				tel = (struct ipv6_tlv_tnl_enc_lim *) &raw[i];
+				tel = (struct ipv6_tlv_tnl_enc_lim *) skb->data + off + i;
 				/* return index of option if found and valid */
 				if (tel->type == IPV6_TLV_TNL_ENCAP_LIMIT &&
 				    tel->length == 1)
-					return i;
+					return i + off - nhoff;
 				/* else jump to next option */
 				if (tel->type)
 					i += tel->length + 2;
@@ -443,7 +453,7 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw)
 					i++;
 			}
 		}
-		nexthdr = hdr->nexthdr;
+		nexthdr = next;
 		off += optlen;
 	}
 	return 0;
-- 
2.11.0.483.g087da7b7c-goog
