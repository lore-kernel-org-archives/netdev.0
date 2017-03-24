From: David Lebrun <david.lebrun@uclouvain.be>
Subject: [PATCH net-next 2/2] ipv6: sr: use dst_cache in seg6_input
Date: Fri, 24 Mar 2017 10:46:27 +0100
Message-ID: <20170324094627.16796-3-david.lebrun@uclouvain.be>
References: <20170324094627.16796-1-david.lebrun@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain
Cc: David Lebrun <david.lebrun@uclouvain.be>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:36231 "EHLO
        smtp4.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751620AbdCXJy0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 24 Mar 2017 05:54:26 -0400
Received: from mailboxes.uclouvain.be (mailboxes.uclouvain.be [130.104.6.131])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-SHA384 (256/256 bits))
        (No client certificate requested)
        by smtp4.sgsi.ucl.ac.be (Postfix) with ESMTPS id 4BAA967DB04
        for <netdev@vger.kernel.org>; Fri, 24 Mar 2017 10:46:05 +0100 (CET)
In-Reply-To: <20170324094627.16796-1-david.lebrun@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We already use dst_cache in seg6_output, when handling locally generated
packets. We extend it in seg6_input, to also handle forwarded packets, and avoid
unnecessary fib lookups.

Performances for SRH encapsulation before the patch:
Result: OK: 5656067(c5655678+d388) usec, 5000000 (1000byte,0frags)
  884006pps 7072Mb/sec (7072048000bps) errors: 0

Performances after the patch:
Result: OK: 4774543(c4774084+d459) usec, 5000000 (1000byte,0frags)
  1047220pps 8377Mb/sec (8377760000bps) errors: 0

Signed-off-by: David Lebrun <david.lebrun@uclouvain.be>
---
 net/ipv6/seg6_iptunnel.c | 27 ++++++++++++++++++++++++++-
 1 file changed, 26 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/seg6_iptunnel.c b/net/ipv6/seg6_iptunnel.c
index dda2c51..30ef1d1 100644
--- a/net/ipv6/seg6_iptunnel.c
+++ b/net/ipv6/seg6_iptunnel.c
@@ -237,6 +237,9 @@ static int seg6_do_srh(struct sk_buff *skb)
 
 static int seg6_input(struct sk_buff *skb)
 {
+	struct dst_entry *orig_dst = skb_dst(skb);
+	struct dst_entry *dst = NULL;
+	struct seg6_lwt *slwt;
 	int err;
 
 	err = seg6_do_srh(skb);
@@ -245,8 +248,30 @@ static int seg6_input(struct sk_buff *skb)
 		return err;
 	}
 
+	slwt = seg6_lwt_lwtunnel(orig_dst->lwtstate);
+
+#ifdef CONFIG_DST_CACHE
+	preempt_disable();
+	dst = dst_cache_get(&slwt->cache);
+	preempt_enable();
+#endif
+
 	skb_dst_drop(skb);
-	ip6_route_input(skb);
+
+	if (!dst) {
+		ip6_route_input(skb);
+#ifdef CONFIG_DST_CACHE
+		dst = skb_dst(skb);
+		if (!dst->error) {
+			preempt_disable();
+			dst_cache_set_ip6(&slwt->cache, dst,
+					  &ipv6_hdr(skb)->saddr);
+			preempt_enable();
+		}
+#endif
+	} else {
+		skb_dst_set(skb, dst);
+	}
 
 	return dst_input(skb);
 }
-- 
2.10.2
