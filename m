From: "H.K. Jerry Chu" <hkchu@google.com>
Subject: [PATCH] net-gre-gro: Fix a bug that breaks the forwarding path
Date: Thu, 27 Feb 2014 13:26:17 -0800
Message-ID: <1393536377-32243-1-git-send-email-hkchu@google.com>
Cc: netdev@vger.kernel.org, Jerry Chu <hkchu@google.com>
To: edumazet@google.com, ogerlitz@mellanox.com, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f202.google.com ([209.85.214.202]:62945 "EHLO
	mail-ob0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751789AbaB0V0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 16:26:30 -0500
Received: by mail-ob0-f202.google.com with SMTP id wo20so151670obc.1
        for <netdev@vger.kernel.org>; Thu, 27 Feb 2014 13:26:30 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jerry Chu <hkchu@google.com>

I stumbled across a bug that was introduced by my own GRE-GRO
patch (bf5a755f5e9186406bbf50f4087100af5bd68e40
net-gre-gro: Add GRE support to the GRO stack) submitted a while
back that breaks the forwarding path because various GSO related
fields were not set. This will cause on the egress path either
the GSO code to fail, or a GRE-TSO capable (NETIF_F_GSO_GRE)
NICs to choke. The following fix has been tested for both cases.

Signed-off-by: H.K. Jerry Chu <hkchu@google.com>
---
 net/core/dev.c           | 2 ++
 net/ipv4/af_inet.c       | 3 +++
 net/ipv4/gre_offload.c   | 3 +++
 net/ipv4/tcp_offload.c   | 2 +-
 net/ipv6/tcpv6_offload.c | 2 +-
 5 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index b1b0c8d..75517d8 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4045,6 +4045,8 @@ static void napi_reuse_skb(struct napi_struct *napi, struct sk_buff *skb)
 	skb->vlan_tci = 0;
 	skb->dev = napi->dev;
 	skb->skb_iif = 0;
+	skb->encapsulation = 0;
+	skb_shinfo(skb)->gso_type = 0;
 
 	napi->skb = skb;
 }
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index ecd2c3f..68229ca 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1431,6 +1431,9 @@ static int inet_gro_complete(struct sk_buff *skb, int nhoff)
 	int proto = iph->protocol;
 	int err = -ENOSYS;
 
+	if (skb->encapsulation)
+		skb_set_inner_network_header(skb, nhoff);
+
 	csum_replace2(&iph->check, iph->tot_len, newlen);
 	iph->tot_len = newlen;
 
diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index f1d3228..2d24f29 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -255,6 +255,9 @@ static int gre_gro_complete(struct sk_buff *skb, int nhoff)
 	int err = -ENOENT;
 	__be16 type;
 
+	skb->encapsulation = 1;
+	skb_shinfo(skb)->gso_type = SKB_GSO_GRE;
+
 	type = greh->protocol;
 	if (greh->flags & GRE_KEY)
 		grehlen += GRE_HEADER_SECTION;
diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index b92b817..c25953a 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -310,7 +310,7 @@ static int tcp4_gro_complete(struct sk_buff *skb, int thoff)
 
 	th->check = ~tcp_v4_check(skb->len - thoff, iph->saddr,
 				  iph->daddr, 0);
-	skb_shinfo(skb)->gso_type = SKB_GSO_TCPV4;
+	skb_shinfo(skb)->gso_type |= SKB_GSO_TCPV4;
 
 	return tcp_gro_complete(skb);
 }
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index 0d78132..3e8458a 100644
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
1.9.0.279.gdc9e3eb
