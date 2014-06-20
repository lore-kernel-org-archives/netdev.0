From: Tom Herbert <therbert@google.com>
Subject: [PATCH 4/5] tcp: Call skb_gro_checksum_validate
Date: Fri, 20 Jun 2014 16:37:58 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406201631440.11825@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f74.google.com ([209.85.160.74]:63792 "EHLO
	mail-pb0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752377AbaFTXh7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 19:37:59 -0400
Received: by mail-pb0-f74.google.com with SMTP id rq2so526309pbb.3
        for <netdev@vger.kernel.org>; Fri, 20 Jun 2014 16:37:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tcp[64]_gro_receive call skb_gro_checksum_validate to validate TCP
checksum in the gro context.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv4/tcp_offload.c   | 27 +++------------------------
 net/ipv6/tcpv6_offload.c | 26 +++-----------------------
 2 files changed, 6 insertions(+), 47 deletions(-)

diff --git a/net/ipv4/tcp_offload.c b/net/ipv4/tcp_offload.c
index 4e86c59..2be7fcf 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -270,35 +270,14 @@ static int tcp_v4_gso_send_check(struct sk_buff *skb)
 
 static struct sk_buff **tcp4_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 {
-	/* Use the IP hdr immediately proceeding for this transport */
-	const struct iphdr *iph = skb_gro_network_header(skb);
-	__wsum wsum;
-
 	/* Don't bother verifying checksum if we're going to flush anyway. */
-	if (NAPI_GRO_CB(skb)->flush)
-		goto skip_csum;
-
-	wsum = NAPI_GRO_CB(skb)->csum;
-
-	switch (skb->ip_summed) {
-	case CHECKSUM_NONE:
-		wsum = skb_checksum(skb, skb_gro_offset(skb), skb_gro_len(skb),
-				    0);
-
-		/* fall through */
-
-	case CHECKSUM_COMPLETE:
-		if (!tcp_v4_check(skb_gro_len(skb), iph->saddr, iph->daddr,
-				  wsum)) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			break;
-		}
-
+	if (!NAPI_GRO_CB(skb)->flush &&
+	    skb_gro_checksum_validate(skb, IPPROTO_TCP,
+				      inet_gro_compute_pseudo)) {
 		NAPI_GRO_CB(skb)->flush = 1;
 		return NULL;
 	}
 
-skip_csum:
 	return tcp_gro_receive(head, skb);
 }
 
diff --git a/net/ipv6/tcpv6_offload.c b/net/ipv6/tcpv6_offload.c
index 8517d3c..fea6e74 100644
--- a/net/ipv6/tcpv6_offload.c
+++ b/net/ipv6/tcpv6_offload.c
@@ -35,34 +35,14 @@ static int tcp_v6_gso_send_check(struct sk_buff *skb)
 static struct sk_buff **tcp6_gro_receive(struct sk_buff **head,
 					 struct sk_buff *skb)
 {
-	const struct ipv6hdr *iph = skb_gro_network_header(skb);
-	__wsum wsum;
-
 	/* Don't bother verifying checksum if we're going to flush anyway. */
-	if (NAPI_GRO_CB(skb)->flush)
-		goto skip_csum;
-
-	wsum = NAPI_GRO_CB(skb)->csum;
-
-	switch (skb->ip_summed) {
-	case CHECKSUM_NONE:
-		wsum = skb_checksum(skb, skb_gro_offset(skb), skb_gro_len(skb),
-				    wsum);
-
-		/* fall through */
-
-	case CHECKSUM_COMPLETE:
-		if (!tcp_v6_check(skb_gro_len(skb), &iph->saddr, &iph->daddr,
-				  wsum)) {
-			skb->ip_summed = CHECKSUM_UNNECESSARY;
-			break;
-		}
-
+	if (!NAPI_GRO_CB(skb)->flush &&
+	    skb_gro_checksum_validate(skb, IPPROTO_TCP,
+				      ip6_gro_compute_pseudo)) {
 		NAPI_GRO_CB(skb)->flush = 1;
 		return NULL;
 	}
 
-skip_csum:
 	return tcp_gro_receive(head, skb);
 }
 
-- 
2.0.0.526.g5318336
