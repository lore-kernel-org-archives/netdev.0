From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net] gro: Disable frag0 optimization on IPv6 ext headers
Date: Tue, 10 Jan 2017 12:24:15 -0800
Message-ID: <1484079855.21472.36.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Slava Shwartsman <slavash@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Eric Dumazet <edumazet@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:34947 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161874AbdAJUYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 15:24:17 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so11430463pfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 12:24:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>

The GRO fast path caches the frag0 address.  This address becomes
invalid if frag0 is modified by pskb_may_pull or its variants.
So whenever that happens we must disable the frag0 optimization.

This is usually done through the combination of gro_header_hard
and gro_header_slow, however, the IPv6 extension header path did
the pulling directly and would continue to use the GRO fast path
incorrectly.

This patch fixes it by disabling the fast path when we enter the
IPv6 extension header path.

Fixes: 78a478d0efd9 ("gro: Inline skb_gro_header and cache frag0 virtual address")
Reported-by: Slava Shwartsman <slavash@mellanox.com>
Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/linux/netdevice.h |    9 +++++++--
 net/ipv6/ip6_offload.c    |    1 +
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 994f7423a74bd622884c3b646f4123d28697b8ad..9bde9558b59672a866bd763039d326bde2af0f81 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2477,14 +2477,19 @@ static inline int skb_gro_header_hard(struct sk_buff *skb, unsigned int hlen)
 	return NAPI_GRO_CB(skb)->frag0_len < hlen;
 }
 
+static inline void skb_gro_frag0_invalidate(struct sk_buff *skb)
+{
+	NAPI_GRO_CB(skb)->frag0 = NULL;
+	NAPI_GRO_CB(skb)->frag0_len = 0;
+}
+
 static inline void *skb_gro_header_slow(struct sk_buff *skb, unsigned int hlen,
 					unsigned int offset)
 {
 	if (!pskb_may_pull(skb, hlen))
 		return NULL;
 
-	NAPI_GRO_CB(skb)->frag0 = NULL;
-	NAPI_GRO_CB(skb)->frag0_len = 0;
+	skb_gro_frag0_invalidate(skb);
 	return skb->data + offset;
 }
 
diff --git a/net/ipv6/ip6_offload.c b/net/ipv6/ip6_offload.c
index 89c59e656f44939863ceada610d3442d2de666ba..fc7b4017ba241f9dd39d49bd6258ecd4a16e3a3a 100644
--- a/net/ipv6/ip6_offload.c
+++ b/net/ipv6/ip6_offload.c
@@ -191,6 +191,7 @@ static struct sk_buff **ipv6_gro_receive(struct sk_buff **head,
 	ops = rcu_dereference(inet6_offloads[proto]);
 	if (!ops || !ops->callbacks.gro_receive) {
 		__pskb_pull(skb, skb_gro_offset(skb));
+		skb_gro_frag0_invalidate(skb);
 		proto = ipv6_gso_pull_exthdrs(skb, proto);
 		skb_gro_pull(skb, -skb_transport_offset(skb));
 		skb_reset_transport_header(skb);
