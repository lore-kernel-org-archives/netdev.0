From: Neal Cardwell <ncardwell@google.com>
Subject: [PATCH net-next] gre_offload: simplify GRE header length calculation in gre_gso_segment()
Date: Thu,  9 Jan 2014 20:47:17 -0500
Message-ID: <1389318437-17744-1-git-send-email-ncardwell@google.com>
Cc: netdev@vger.kernel.org, Neal Cardwell <ncardwell@google.com>,
	Eric Dumazet <edumazet@google.com>,
	"H.K. Jerry Chu" <hkchu@google.com>,
	Pravin B Shelar <pshelar@nicira.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f202.google.com ([209.85.216.202]:48386 "EHLO
	mail-qc0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751745AbaAJBrY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jan 2014 20:47:24 -0500
Received: by mail-qc0-f202.google.com with SMTP id i17so383315qcy.5
        for <netdev@vger.kernel.org>; Thu, 09 Jan 2014 17:47:23 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Simplify the GRE header length calculation in gre_gso_segment().
Switch to an approach that is simpler, faster, and more general. The
new approach will continue to be correct even if we add support for
the optional variable-length routing info that may be present in a GRE
header.

Signed-off-by: Neal Cardwell <ncardwell@google.com>
Cc: Eric Dumazet <edumazet@google.com>
Cc: H.K. Jerry Chu <hkchu@google.com>
Cc: Pravin B Shelar <pshelar@nicira.com>
---
 net/ipv4/gre_offload.c | 16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

diff --git a/net/ipv4/gre_offload.c b/net/ipv4/gre_offload.c
index 746a7b1..f6604b6 100644
--- a/net/ipv4/gre_offload.c
+++ b/net/ipv4/gre_offload.c
@@ -26,7 +26,7 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 {
 	struct sk_buff *segs = ERR_PTR(-EINVAL);
 	netdev_features_t enc_features;
-	int ghl = GRE_HEADER_SECTION;
+	int ghl;
 	struct gre_base_hdr *greh;
 	u16 mac_offset = skb->mac_header;
 	int mac_len = skb->mac_len;
@@ -49,15 +49,11 @@ static struct sk_buff *gre_gso_segment(struct sk_buff *skb,
 
 	greh = (struct gre_base_hdr *)skb_transport_header(skb);
 
-	if (greh->flags & GRE_KEY)
-		ghl += GRE_HEADER_SECTION;
-	if (greh->flags & GRE_SEQ)
-		ghl += GRE_HEADER_SECTION;
-	if (greh->flags & GRE_CSUM) {
-		ghl += GRE_HEADER_SECTION;
-		csum = true;
-	} else
-		csum = false;
+	ghl = skb_inner_network_header(skb) - skb_transport_header(skb);
+	if (unlikely(ghl < sizeof(*greh)))
+		goto out;
+
+	csum = !!(greh->flags & GRE_CSUM);
 
 	if (unlikely(!pskb_may_pull(skb, ghl)))
 		goto out;
-- 
1.8.5.1
