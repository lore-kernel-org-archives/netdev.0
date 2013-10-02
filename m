From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [PATCH] ipv6: udp packets following an UFO enqueued packet need
 also be handled by UFO
Date: Wed, 2 Oct 2013 13:20:52 +0200
Message-ID: <20131002112052.GC1528@minipsycho.brq.redhat.com>
References: <20130921042700.GB8070@order.stressinduktion.org>
 <20130930114343.GA6356@minipsycho.brq.redhat.com>
 <20130930172312.GE10771@order.stressinduktion.org>
 <20131001105837.GA1424@minipsycho.brq.redhat.com>
 <20131001120907.GH10771@order.stressinduktion.org>
 <20131001123214.GI10771@order.stressinduktion.org>
 <20131001214721.GJ10771@order.stressinduktion.org>
 <20131001232534.GM10771@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: yoshfuji@linux-ipv6.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@trash.net, herbert@gondor.apana.org.au,
	eric.dumazet@gmail.com, hannes@stressinduktion.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:39938 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753825Ab3JBLU4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Oct 2013 07:20:56 -0400
Received: by mail-we0-f171.google.com with SMTP id p61so741232wes.2
        for <netdev@vger.kernel.org>; Wed, 02 Oct 2013 04:20:55 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20131001232534.GM10771@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Oct 02, 2013 at 01:25:34AM CEST, hannes@stressinduktion.org wrote:
>On Tue, Oct 01, 2013 at 11:47:21PM +0200, Hannes Frederic Sowa wrote:
>> The strange thing is that if I don't do the IPV6_MTU setsockopt I don't
>> get an oops.
>
>This is incorrect, it just depends on the size of the writes and on the
>interface mtu.
>
>> IPv4 seems to work without problems, too.
>
>I also get kernel oopses from IPv4 now, too.

This patch should fix this on ipv4 as well:

Subject: ip_output: do skb ufo init for peeked non ufo skb as well

Now, if user application does:
sendto len<mtu flag MSG_MORE
sendto len>mtu flag 0
The skb is not treated as fragmented one because it is not initialized
that way. So move the initialization to fix this.

Signed-off-by: Jiri Pirko <jiri@resnulli.us>
---
 net/ipv4/ip_output.c | 14 +++++++++-----
 1 file changed, 9 insertions(+), 5 deletions(-)

diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
index a04d872..bd21c5d 100644
--- a/net/ipv4/ip_output.c
+++ b/net/ipv4/ip_output.c
@@ -772,15 +772,19 @@ static inline int ip_ufo_append_data(struct sock *sk,
 		/* initialize protocol header pointer */
 		skb->transport_header = skb->network_header + fragheaderlen;
 
-		skb->ip_summed = CHECKSUM_PARTIAL;
 		skb->csum = 0;
 
-		/* specify the length of each IP datagram fragment */
-		skb_shinfo(skb)->gso_size = maxfraglen - fragheaderlen;
-		skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
+
 		__skb_queue_tail(queue, skb);
-	}
+	} else if (skb_is_gso(skb))
+		goto append;
+
+	skb->ip_summed = CHECKSUM_PARTIAL;
+	/* specify the length of each IP datagram fragment */
+	skb_shinfo(skb)->gso_size = maxfraglen - fragheaderlen;
+	skb_shinfo(skb)->gso_type = SKB_GSO_UDP;
 
+append:
 	return skb_append_datato_frags(sk, skb, getfrag, from,
 				       (length - transhdrlen));
 }
-- 
1.8.3.1
