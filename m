From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: relax expensive skb_unclone() in
 iptunnel_handle_offloads()
Date: Sat, 30 Apr 2016 10:19:29 -0700
Message-ID: <1462036769.5535.180.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:32973 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750973AbcD3RTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 30 Apr 2016 13:19:32 -0400
Received: by mail-qg0-f51.google.com with SMTP id f92so54680049qgf.0
        for <netdev@vger.kernel.org>; Sat, 30 Apr 2016 10:19:31 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Locally generated TCP GSO packets having to go through a GRE/SIT/IPIP
tunnel have to go through an expensive skb_unclone()

Reallocating skb->head is a lot of work.

Test should really check if a 'real clone' of the packet was done.

TCP does not care if the original gso_type is changed while the packet
travels in the stack.

This adds skb_header_unclone() which is a variant of skb_clone()
using skb_header_cloned() check instead of skb_cloned().

This variant can probably be used from other points.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/skbuff.h    |   10 ++++++++++
 net/ipv4/ip_tunnel_core.c |    2 +-
 2 files changed, 11 insertions(+), 1 deletion(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index c84a5a1078c5528bf6fc84573f63f3c6f470ce8f..c413c588a24f854be9e4df78d8a6872b6b1ff9f3 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -1325,6 +1325,16 @@ static inline int skb_header_cloned(const struct sk_buff *skb)
 	return dataref != 1;
 }
 
+static inline int skb_header_unclone(struct sk_buff *skb, gfp_t pri)
+{
+	might_sleep_if(gfpflags_allow_blocking(pri));
+
+	if (skb_header_cloned(skb))
+		return pskb_expand_head(skb, 0, 0, pri);
+
+	return 0;
+}
+
 /**
  *	skb_header_release - release reference to header
  *	@skb: buffer to operate on
diff --git a/net/ipv4/ip_tunnel_core.c b/net/ipv4/ip_tunnel_core.c
index 786fa7ca28e0db00865cdf9fab472836866b7d6d..9118b0e640ba3a96850cf28aa8caab4e615254d9 100644
--- a/net/ipv4/ip_tunnel_core.c
+++ b/net/ipv4/ip_tunnel_core.c
@@ -157,7 +157,7 @@ int iptunnel_handle_offloads(struct sk_buff *skb,
 	}
 
 	if (skb_is_gso(skb)) {
-		err = skb_unclone(skb, GFP_ATOMIC);
+		err = skb_header_unclone(skb, GFP_ATOMIC);
 		if (unlikely(err))
 			return err;
 		skb_shinfo(skb)->gso_type |= gso_type_mask;
