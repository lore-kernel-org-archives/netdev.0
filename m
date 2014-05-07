From: Tom Herbert <therbert@google.com>
Subject: [PATCH 5/7] icmp6: Call skb_checksum_validate
Date: Wed, 7 May 2014 16:52:29 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1405071643290.963@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f74.google.com ([209.85.220.74]:33186 "EHLO
	mail-pa0-f74.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752300AbaEGXwa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 19:52:30 -0400
Received: by mail-pa0-f74.google.com with SMTP id rd3so296929pab.5
        for <netdev@vger.kernel.org>; Wed, 07 May 2014 16:52:29 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use skb_checksum_validate to verify checksum.

Signed-off-by: Tom Herbert <therbert@google.com>
---
 net/ipv6/icmp.c | 21 +++++----------------
 1 file changed, 5 insertions(+), 16 deletions(-)

diff --git a/net/ipv6/icmp.c b/net/ipv6/icmp.c
index 3b0905b..8d39527 100644
--- a/net/ipv6/icmp.c
+++ b/net/ipv6/icmp.c
@@ -692,22 +692,11 @@ static int icmpv6_rcv(struct sk_buff *skb)
 	saddr = &ipv6_hdr(skb)->saddr;
 	daddr = &ipv6_hdr(skb)->daddr;
 
-	/* Perform checksum. */
-	switch (skb->ip_summed) {
-	case CHECKSUM_COMPLETE:
-		if (!csum_ipv6_magic(saddr, daddr, skb->len, IPPROTO_ICMPV6,
-				     skb->csum))
-			break;
-		/* fall through */
-	case CHECKSUM_NONE:
-		skb->csum = ~csum_unfold(csum_ipv6_magic(saddr, daddr, skb->len,
-					     IPPROTO_ICMPV6, 0));
-		if (__skb_checksum_complete(skb)) {
-			LIMIT_NETDEBUG(KERN_DEBUG
-				       "ICMPv6 checksum failed [%pI6c > %pI6c]\n",
-				       saddr, daddr);
-			goto csum_error;
-		}
+	if (skb_checksum_validate(skb, IPPROTO_ICMPV6, ip6_compute_pseudo)) {
+		LIMIT_NETDEBUG(KERN_DEBUG
+			       "ICMPv6 checksum failed [%pI6c > %pI6c]\n",
+			       saddr, daddr);
+		goto csum_error;
 	}
 
 	if (!pskb_pull(skb, sizeof(*hdr)))
-- 
1.9.1.423.g4596e3a
