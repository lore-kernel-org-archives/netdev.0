From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next 1/2] ipv6: sr: expand skb head only if necessary
Date: Fri, 24 Mar 2017 10:46:26 +0100
Message-ID: <20170324094627.16796-2-david.lebrun@uclouvain.be>
References: <20170324094627.16796-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:51632 "EHLO
        smtp2.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752206AbdCXJy0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 05:54:26 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp2.sgsi.ucl.ac.be (Postfix) with ESMTPS id 2209A67DC1C
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 10:46:05 +0100 (CET)
In-Reply-To: <20170324094627.16796-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To insert or encapsulate a packet with an SRH, we need a large enough skb
headroom. Currently, we are using pskb_expand_head to inconditionally increase
the size of the headroom by the amount needed by the SRH (and IPv6 header).
If this reallocation is performed by another CPU than the one that initially
allocated the skb, then when the initial CPU kfree the skb, it will enter the
__slab_free slowpath, impacting performances.

This patch replaces pskb_expand_head with skb_cow_head, that will reallocate the
skb head only if the headroom is not large enough.

Performances for SRH encapsulation before the patch:
Result: OK: 7348320(c7347271+d1048) usec, 5000000 (1000byte,0frags)
  680427pps 5443Mb/sec (5443416000bps) errors: 0

Performances after the patch:
Result: OK: 5656067(c5655678+d388) usec, 5000000 (1000byte,0frags)
  884006pps 7072Mb/sec (7072048000bps) errors: 0

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_iptunnel.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index 8558225..dda2c51 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -105,7 +105,7 @@ static int seg6_do_srh_encap(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 	hdrlen = (osrh->hdrlen + 1) << 3;
 	tot_len = hdrlen + sizeof(*hdr);
 
-	err = pskb_expand_head(skb, tot_len, 0, GFP_ATOMIC);
+	err = skb_cow_head(skb, tot_len);
 	if (unlikely(err))
 		return err;
 
@@ -156,7 +156,7 @@ static int seg6_do_srh_inline(struct sk_buff *skb, struct ipv6_sr_hdr *osrh)
 
 	hdrlen = (osrh->hdrlen + 1) << 3;
 
-	err = pskb_expand_head(skb, hdrlen, 0, GFP_ATOMIC);
+	err = skb_cow_head(skb, hdrlen);
 	if (unlikely(err))
 		return err;
 
-- 
2.10.2
