From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [3/5] [NET]: Add software TSOv4
Date: Fri, 23 Jun 2006 12:33:50 -0700
Message-ID: <1151091230.6498.4.camel@rh4>
References: <20060622081211.GA22505@gondor.apana.org.au>
 <20060622081400.GC22671@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:9488 "EHLO MMS3.broadcom.com")
	by vger.kernel.org with ESMTP id S1751938AbWFWTcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jun 2006 15:32:54 -0400
To: "Herbert Xu" <herbert@gondor.apana.org.au>
In-Reply-To: <20060622081400.GC22671@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-06-22 at 18:14 +1000, Herbert Xu wrote:
> [NET]: Add software TSOv4
> 
> This patch adds the GSO implementation for IPv4 TCP.

Herbert, Looks like there were some problems in the CHECKSUM_HW case.
This patch should fix it.  Please double-check my checksum math.

[NET]: Fix CHECKSUM_HW GSO problems.

Fix the following 2 problems in the GSO code path for CHECKSUM_HW
packets:

1. Adjust ipv4 TCP pseudo header checksum.

2. Initialize skb->tail.

Signed-off-by: Michael Chan <mchan@broadcom.com>


diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index 8e5044b..3f19b3d 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -1954,6 +1954,7 @@ struct sk_buff *skb_segment(struct sk_bu
 		nskb->data_len = len - hsize;
 		nskb->len += nskb->data_len;
 		nskb->truesize += nskb->data_len;
+		nskb->tail += nskb->data_len;
 	} while ((offset += len) < skb->len);
 
 	return segs;
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 0e029c4..3399110 100644
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
@@ -2196,11 +2197,12 @@ struct sk_buff *tcp_tso_segment(struct s
 		th->cwr = 0;
 	} while (skb->next);
 
+	delta = csum_add(oldlen, htonl(skb->tail - skb->h.raw));
 	if (skb->ip_summed == CHECKSUM_NONE) {
-		delta = csum_add(oldlen, htonl(skb->tail - skb->h.raw));
 		th->check = csum_fold(csum_partial(
 			skb->h.raw, thlen, csum_add(skb->csum, delta)));
-	}
+	} else if (skb->ip_summed == CHECKSUM_HW)
+		th->check = ~csum_fold(csum_add(th->check, delta));
 
 out:
 	return segs;


