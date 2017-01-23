From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 2/2] ipv6: fix ip6_tnl_parse_tlv_enc_lim()
Date: Mon, 23 Jan 2017 15:58:04 -0800
Message-ID: <20170123235804.29342-3-edumazet@google.com>
References: <20170123235804.29342-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f49.google.com ([74.125.83.49]:33703 "EHLO
        mail-pg0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751872AbdAWX6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 18:58:50 -0500
Received: by mail-pg0-f49.google.com with SMTP id 204so49105515pge.0
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 15:58:11 -0800 (PST)
In-Reply-To: <20170123235804.29342-1-edumazet@google.com>
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
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Cc: Willem de Bruijn <willemb@google.com>
---
 net/ipv6/ip6_tunnel.c | 32 +++++++++++++++++++++-----------
 1 file changed, 21 insertions(+), 11 deletions(-)

diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 02923f956ac8ba5f3270e8d5282fd9637c2d..f9c43c9043f7e386108bca2f2aeb866cfb76 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -400,18 +400,18 @@ ip6_tnl_dev_uninit(struct net_device *dev)
 
 __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw)
 {
-	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *) raw;
-	__u8 nexthdr = ipv6h->nexthdr;
-	__u16 off = sizeof(*ipv6h);
+	const struct ipv6hdr *ipv6h = (const struct ipv6hdr *)raw;
+	unsigned int nhoff = (raw - skb->data) + sizeof(*ipv6h);
+	u8 next, nexthdr = ipv6h->nexthdr;
 
 	while (ipv6_ext_hdr(nexthdr) && nexthdr != NEXTHDR_NONE) {
-		__u16 optlen = 0;
 		struct ipv6_opt_hdr *hdr;
-		if (raw + off + sizeof(*hdr) > skb->data &&
-		    !pskb_may_pull(skb, raw - skb->data + off + sizeof (*hdr)))
+		u16 optlen;
+
+		if (!pskb_may_pull(skb, nhoff + sizeof(*hdr)))
 			break;
 
-		hdr = (struct ipv6_opt_hdr *) (raw + off);
+		hdr = (struct ipv6_opt_hdr *)(skb->data + nhoff);
 		if (nexthdr == NEXTHDR_FRAGMENT) {
 			struct frag_hdr *frag_hdr = (struct frag_hdr *) hdr;
 			if (frag_hdr->frag_off)
@@ -422,13 +422,23 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw)
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
+			if (!pskb_may_pull(skb, nhoff + optlen))
+				break;
+
+			raw = skb->data + nhoff;
 			while (1) {
 				struct ipv6_tlv_tnl_enc_lim *tel;
 
 				/* No more room for encapsulation limit */
-				if (i + sizeof (*tel) > off + optlen)
+				if (i + sizeof(*tel) > optlen)
 					break;
 
 				tel = (struct ipv6_tlv_tnl_enc_lim *) &raw[i];
@@ -443,8 +453,8 @@ __u16 ip6_tnl_parse_tlv_enc_lim(struct sk_buff *skb, __u8 *raw)
 					i++;
 			}
 		}
-		nexthdr = hdr->nexthdr;
-		off += optlen;
+		nexthdr = next;
+		nhoff += optlen;
 	}
 	return 0;
 }
-- 
2.11.0.483.g087da7b7c-goog
