From: Jiri Pirko <jiri@resnulli.us>
Subject: [patch net v2 3/3] ip_output: do skb ufo init for peeked non ufo skb as well
Date: Sat, 19 Oct 2013 12:29:17 +0200
Message-ID: <1382178557-14737-4-git-send-email-jiri@resnulli.us>
References: <1382178557-14737-1-git-send-email-jiri@resnulli.us>
Cc: davem@davemloft.net, eric.dumazet@gmail.com,
	hannes@stressinduktion.org, jdmason@kudzu.us,
	yoshfuji@linux-ipv6.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	kaber@trash.net, herbert@gondor.apana.org.au
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f176.google.com ([209.85.215.176]:42643 "EHLO
	mail-ea0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751209Ab3JSK3Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Oct 2013 06:29:25 -0400
Received: by mail-ea0-f176.google.com with SMTP id q16so2543691ead.35
        for <netdev@vger.kernel.org>; Sat, 19 Oct 2013 03:29:24 -0700 (PDT)
In-Reply-To: <1382178557-14737-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now, if user application does:
sendto len<mtu flag MSG_MORE
sendto len>mtu flag 0
The skb is not treated as fragmented one because it is not initialized
that way. So move the initialization to fix this.

introduced by:
commit e89e9cf539a28df7d0eb1d0a545368e9920b34ac "[IPv4/IPv6]: UFO Scatter-gather approach"

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/ip_output.c | 13 +++++++++----
 1 file changed, 9 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a04d872..3982eab 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -772,15 +772,20 @@ static inline int ip_ufo_append_data(struct sock *sk,
 		/* initialize protocol header pointer */
 		skb->transport_header = skb->network_header + fragheaderlen;
 
-		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 
-		/* specify the length of each IP datagram fragment */
-		skb_shinfo(skb)->gso_size = maxfraglen - fragheaderlen;
-		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+
 		__skb_queue_tail(queue, skb);
+	} else if (skb_is_gso(skb)) {
+		goto append;
 	}
 
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	/* specify the length of each IP datagram fragment */
+	skb_shinfo(skb)->gso_size = maxfraglen - fragheaderlen;
+	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+
+append:
 	return skb_append_datato_frags(sk, skb, getfrag, from,
 				       (length - transhdrlen));
 }
-- 
1.8.3.1
