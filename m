From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH net-next] net-gre-gro: Fix a bug that breaks the forwarding path
Date: Sun, 13 Jul 2014 07:46:20 -0700
Message-ID: <1405262780-20232-1-git-send-email-hkchu@google.com>
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Jerry Chu <hkchu@google.com>
To: edumazet@google.com, ogerlitz@mellanox.com, linux@stwm.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:57889 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751493AbaGMOqZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jul 2014 10:46:25 -0400
Received: by mail-qc0-f202.google.com with SMTP id x13so527840qcv.5
        for <netdev@vger.kernel.org>; Sun, 13 Jul 2014 07:46:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

Fixed a bug that was introduced by my GRE-GRO patch
(bf5a755f5e9186406bbf50f4087100af5bd68e40 net-gre-gro: Add GRE
support to the GRO stack) that breaks the forwarding path
because various GSO related fields were not set. The bug will
cause on the egress path either the GSO code to fail, or a
GRE-TSO capable (NETIF_F_GSO_GRE) NICs to choke. The following
fix has been tested for both cases.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
 net/core/dev.c           | 2 ++
 net/ipv4/af_inet.c       | 3 +++
 net/ipv4/gre_offload.c   | 3 +++
 net/ipv4/tcp_offload.c   | 2 +-
 net/ipv6/tcpv6_offload.c | 2 +-
 5 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index 6e2a2cd..d603c14 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4089,6 +4089,8 @@ static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 	skb->vlan_tci = 0;
 	skb->dev = napi->dev;
 	skb->skb_iif = 0;
+	skb->encapsulation = 0;
+	skb_shinfo(skb)->gso_type = 0;
 	skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
 
 	napi->skb = skb;
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d5e6836..d156b3c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1429,6 +1429,9 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
 	int proto = iph->protocol;
 	int err = -ENOSYS;
 
+	if (skb->encapsulation)
+		skb_set_inner_network_header(skb, nhoff);
+
 	csum_replace2(&iph->check, iph->tot_len, newlen);
 	iph->tot_len = newlen;
 
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index eb92deb..f0bdd47 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -263,6 +263,9 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 	int err = -ENOENT;
 	__be16 type;
 
+	skb->encapsulation = 1;
+	skb_shinfo(skb)->gso_type = SKB_GSO_GRE;
+
 	type = greh->protocol;
 	if (greh->flags & GRE_KEY)
 		grehlen += GRE_HEADER_SECTION;
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 4e86c59..55046ec 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -309,7 +309,7 @@ static int tcp4_gro_complete(struct sk_buff *skb, int thoff)
 
 	th->check = ~tcp_v4_check(skb->len - thoff, iph->saddr,
 				  iph->daddr, 0);
-	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_TCPV4;
 
 	return tcp_gro_complete(skb);
 }
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index 8517d3c..01b0ff9 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -73,7 +73,7 @@ static int tcp6_gro_complete(struct sk_buff *skb, int thoff)
 
 	th->check = ~tcp_v6_check(skb->len - thoff, &iph->saddr,
 				  &iph->daddr, 0);
-	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV6;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_TCPV6;
 
 	return tcp_gro_complete(skb);
 }
-- 
2.0.0.526.g5318336
