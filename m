From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [3/5] [NET]: Add software TSOv4
Date: Fri, 23 Jun 2006 14:26:16 -0700
Message-ID: <1151097976.6498.7.camel@rh4>
References: <20060622081211.GA22505@gondor.apana.org.au>
 <20060622081400.GC22671@gondor.apana.org.au>
 <1151091230.6498.4.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:9483 "EHLO mms2.broadcom.com")
	by vger.kernel.org with ESMTP id S1752080AbWFWVZS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 17:25:18 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <1151091230.6498.4.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2006-06-23 at 12:33 -0700, Michael Chan wrote:
> On Thu, 2006-06-22 at 18:14 +1000, Herbert Xu wrote:
> > [NET]: Add software TSOv4
> > 
> > This patch adds the GSO implementation for IPv4 TCP.
> 
> Herbert, Looks like there were some problems in the CHECKSUM_HW case.
> This patch should fix it.  Please double-check my checksum math.

This patch is more correct.  Please ignore the previous one.

[NET]: Fix CHECKSUM_HW GSO problems.

Fix checksum problems in the GSO code path for CHECKSUM_HW packets.

The ipv4 TCP pseudo header checksum has to be adjusted for GSO
segmented packets.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0e029c4..b9c37f1 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -2186,7 +2186,8 @@ struct sk_buff *tcp_tso_segment(struct s
 		if (skb->ip_summed == CHECKSUM_NONE) {
 			th->check = csum_fold(csum_partial(
 				skb->h.raw, thlen, csum_add(skb->csum, delta)));
-		}
+		} else if (skb->ip_summed == CHECKSUM_HW)
+			th->check = ~csum_fold(csum_add(th->check, delta));
 
 		seq += len;
 		skb = skb->next;
@@ -2200,6 +2201,10 @@ struct sk_buff *tcp_tso_segment(struct s
 		delta = csum_add(oldlen, htonl(skb->tail - skb->h.raw));
 		th->check = csum_fold(csum_partial(
 			skb->h.raw, thlen, csum_add(skb->csum, delta)));
+	} else if (skb->ip_summed == CHECKSUM_HW) {
+		delta = csum_add(oldlen, htonl(skb->len -
+					       (skb->h.raw - skb->data)));
+		th->check = ~csum_fold(csum_add(th->check, delta));
 	}
 
 out:


