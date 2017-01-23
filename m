From: Eric Dumazet <edumazet@google.com>
Subject: [PATCH net-next 1/2] ip6_tunnel: must reload ipv6h in ip6ip6_tnl_xmit()
Date: Mon, 23 Jan 2017 15:58:03 -0800
Message-ID: <20170123235804.29342-2-edumazet@google.com>
References: <20170123235804.29342-1-edumazet@google.com>
Cc: netdev <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        Alexei Starovoitov <ast@kernel.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Dmitry Kozlov <xeb@mail.ru>
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f171.google.com ([209.85.192.171]:35228 "EHLO
        mail-pf0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751869AbdAWX6u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 18:58:50 -0500
Received: by mail-pf0-f171.google.com with SMTP id f144so44908989pfa.2
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 15:58:09 -0800 (PST)
In-Reply-To: <20170123235804.29342-1-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since ip6_tnl_parse_tlv_enc_lim() can call pskb_may_pull(),
we must reload any pointer that was related to skb->head
(or skb->data), or risk use after free.

Fixes: c12b395a4664 ("gre: Support GRE over IPv6")
Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Dmitry Kozlov <xeb@mail.ru>
---
 net/ipv6/ip6_gre.c    | 3 +++
 net/ipv6/ip6_tunnel.c | 2 ++
 2 files changed, 5 insertions(+)

diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index 75b6108234dd05a54af0ae51c7c11eaf1ca2..558631860d91bbcb1321a4b566b6e92ddcaf 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -582,6 +582,9 @@ static inline int ip6gre_xmit_ipv6(struct sk_buff *skb, struct net_device *dev)
 		return -1;
 
 	offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
+	/* ip6_tnl_parse_tlv_enc_lim() might have reallocated skb->head */
+	ipv6h = ipv6_hdr(skb);
+
 	if (offset > 0) {
 		struct ipv6_tlv_tnl_enc_lim *tel;
 		tel = (struct ipv6_tlv_tnl_enc_lim *)&skb_network_header(skb)[offset];
diff --git a/net/ipv6/ip6_tunnel.c b/net/ipv6/ip6_tunnel.c
index 753d6d0860fb14c100ab8b20799782ab8160..02923f956ac8ba5f3270e8d5282fd9637c2d 100644
--- a/net/ipv6/ip6_tunnel.c
+++ b/net/ipv6/ip6_tunnel.c
@@ -1303,6 +1303,8 @@ ip6ip6_tnl_xmit(struct sk_buff *skb, struct net_device *dev)
 		fl6.flowlabel = key->label;
 	} else {
 		offset = ip6_tnl_parse_tlv_enc_lim(skb, skb_network_header(skb));
+		/* ip6_tnl_parse_tlv_enc_lim() might have reallocated skb->head */
+		ipv6h = ipv6_hdr(skb);
 		if (offset > 0) {
 			struct ipv6_tlv_tnl_enc_lim *tel;
 
-- 
2.11.0.483.g087da7b7c-goog
