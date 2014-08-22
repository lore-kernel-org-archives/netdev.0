From: Tom Herbert <therbert@google.com>
Subject: [PATCH v2 net-next 4/6] tcp: Call skb_gro_checksum_validate
Date: Fri, 22 Aug 2014 13:34:30 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1408221316260.1774@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f73.google.com ([209.85.220.73]:51602 "EHLO
	mail-pa0-f73.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752005AbaHVUeb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 16:34:31 -0400
Received: by mail-pa0-f73.google.com with SMTP id kx10so3032502pab.2
        for <netdev@vger.kernel.org>; Fri, 22 Aug 2014 13:34:31 -0700 (PDT)
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
index bc1b83c..7291253 100644
--- a/net/ipv4/tcp_offload.c
+++ b/net/ipv4/tcp_offload.c
@@ -288,35 +288,14 @@ static int tcp_v4_gso_send_check(struct sk_buff *skb)
 
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
index 01b0ff9..dbb3d92 100644
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
2.1.0.rc2.206.gedb03e5
