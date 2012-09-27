From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next 1/3] tcp: gro: add checksuming helpers
Date: Thu, 27 Sep 2012 14:14:53 +0200
Message-ID: <1348748093.5093.1171.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:59061 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752418Ab2I0MO5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Sep 2012 08:14:57 -0400
Received: by bkcjk13 with SMTP id jk13so1651458bkc.19
        for <netdev@vger.kernel.org>; Thu, 27 Sep 2012 05:14:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

skb with CHECKSUM_NONE cant currently be handled by GRO, and
we notice this deep in GRO stack in tcp[46]_gro_receive()

But there are cases where GRO can be a benefit, even with a lack
of checksums.

This preliminary work is needed to add GRO support
to tunnels.

Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 net/ipv4/tcp_ipv4.c |   19 ++++++++++++++++---
 net/ipv6/tcp_ipv6.c |   20 +++++++++++++++++---
 2 files changed, 33 insertions(+), 6 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 93406c5..27a235c 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -2804,6 +2804,8 @@ void tcp4_proc_exit(void)
 struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
 	const struct iphdr *iph = skb_gro_network_header(skb);
+	__wsum wsum;
+	__sum16 sum;
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -2812,11 +2814,22 @@ struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			break;
 		}
-
-		/* fall through */
-	case CHECKSUM_NONE:
+flush:
 		NAPI_GRO_CB(skb)->flush = 1;
 		return NULL;
+
+	case CHECKSUM_NONE:
+		wsum = csum_tcpudp_nofold(iph->saddr, iph->daddr,
+					  skb_gro_len(skb), IPPROTO_TCP, 0);
+		sum = csum_fold(skb_checksum(skb,
+					     skb_gro_offset(skb),
+					     skb_gro_len(skb),
+					     wsum));
+		if (sum)
+			goto flush;
+
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		break;
 	}
 
 	return tcp_gro_receive(head, skb);
diff --git a/net/ipv6/tcp_ipv6.c b/net/ipv6/tcp_ipv6.c
index d6212d6..49c8903 100644
--- a/net/ipv6/tcp_ipv6.c
+++ b/net/ipv6/tcp_ipv6.c
@@ -763,6 +763,8 @@ static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
 	const struct ipv6hdr *iph = skb_gro_network_header(skb);
+	__wsum wsum;
+	__sum16 sum;
 
 	switch (skb->ip_summed) {
 	case CHECKSUM_COMPLETE:
@@ -771,11 +773,23 @@ static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 			skb->ip_summed = CHECKSUM_UNNECESSARY;
 			break;
 		}
-
-		/* fall through */
-	case CHECKSUM_NONE:
+flush:
 		NAPI_GRO_CB(skb)->flush = 1;
 		return NULL;
+
+	case CHECKSUM_NONE:
+		wsum = ~csum_unfold(csum_ipv6_magic(&iph->saddr, &iph->daddr,
+						    skb_gro_len(skb),
+						    IPPROTO_TCP, 0));
+		sum = csum_fold(skb_checksum(skb,
+					     skb_gro_offset(skb),
+					     skb_gro_len(skb),
+					     wsum));
+		if (sum)
+			goto flush;
+
+		skb->ip_summed = CHECKSUM_UNNECESSARY;
+		break;
 	}
 
 	return tcp_gro_receive(head, skb);
