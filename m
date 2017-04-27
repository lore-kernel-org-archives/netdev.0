From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net] esp: skip GRO for fragmented packets
Date: Thu, 27 Apr 2017 12:43:35 +0200
Message-ID: <20170427104334.GE2649@secunet.com>
References: <37d07f4c9bfaf9733d3cd90653927540e2639d39.1493288951.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, Herbert Xu <herbert@gondor.apana.org.au>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59912 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S965588AbdD0KpO (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 27 Apr 2017 06:45:14 -0400
Content-Disposition: inline
In-Reply-To: <37d07f4c9bfaf9733d3cd90653927540e2639d39.1493288951.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 27, 2017 at 12:31:14PM +0200, Sabrina Dubroca wrote:
> Currently, ESP4 GRO doesn't work for fragmented packets, so let's send
> these through the normal path.
> 
> Fixes: 7785bba299a8 ("esp: Add a software GRO codepath")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
> Steffen, if you prefer to drop this patch and fix this properly,
> that's okay for me. I can't look much deeper into this right now and
> it's broken on current net/master.

I did a fix for this last week, but forgot to submit it.
We can fix this in inet_gro_receive(), as no GRO handler
can really handle fragmented packets.

I'll plan to fix it with this patch:

>From 44a2fc882bb310b66d9cc5c89405d0669a26cd45 Mon Sep 17 00:00:00 2001
From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 20 Apr 2017 09:44:58 +0200
Subject: [PATCH RFC] ipv4: Don't pass IP fragments to upper layer GRO handlers.

Upper layer GRO handlers can not handle IP fragments, so
exit GRO processing in this case. This also fixes ESP GRO
because the packet must be reassembled before we can
decapsulate, otherwise we get authentication failures.

This also aligns IPv4 to IPv6 where packets with fragmentation
headers are not passed to upper layer GRO handlers.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv4/af_inet.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d1a1170..f3dad16 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1343,6 +1343,9 @@ struct sk_buff **inet_gro_receive(struct sk_buff **head, struct sk_buff *skb)
 	if (*(u8 *)iph != 0x45)
 		goto out_unlock;
 
+	if (ip_is_fragment(iph))
+		goto out_unlock;
+
 	if (unlikely(ip_fast_csum((u8 *)iph, 5)))
 		goto out_unlock;
 
-- 
2.7.4
