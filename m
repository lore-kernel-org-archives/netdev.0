From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: [AH6] Rearrange routing headers
Date: Sat, 24 Jul 2004 14:22:03 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040724.142203.15175626.yoshfuji@linux-ipv6.org>
References: <20040724083709.GA9416@gondor.apana.org.au>
	<200407250222.22934.kazunori@miyazawa.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-2022-jp
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: kazunori@miyazawa.org, davem@redhat.com, herbert@gondor.apana.org.au
In-Reply-To: <200407250222.22934.kazunori@miyazawa.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <200407250222.22934.kazunori@miyazawa.org> (at Sun, 25 Jul 2004 02:22:22 +0900), Kazunori Miyazawa <kazunori@miyazawa.org> says:

> 2004/07/24(土) 17:37、Herbert Xu  wrote:
> > Hi:
> >
> > This patch rearranges the IPv6 routing header so that the destination
> > addresses appear in the order as they would on the destination.  This
> > is specified in Appendix A2 of RFC 2402.
> >
> > Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> >
> > Cheers,
> 
> I saw roughly the packet.
> It needs to check direction of the process.
> We don't need to do that in INBOUND.

Here's the patch (on top of the Xu's patch).

Signed-off-by: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>

--- linux26/net/ipv6/ah6.c	2004-07-24 13:53:08.000000000 -0400
+++ linux26/net/ipv6/ah6.c	2004-07-24 14:01:12.000000000 -0400
@@ -93,7 +93,6 @@
 	segments_left = rthdr->segments_left;
 	if (segments_left == 0)
 		return;
-	rthdr->segments_left = 0; 
 
 	/* The value of rthdr->hdrlen has been verified either by the system
 	 * call if it is locally generated, or by ipv6_rthdr_rcv() for incoming
@@ -114,7 +113,7 @@
 	ipv6_addr_copy(&iph->daddr, &final_addr);
 }
 
-static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len)
+static int ipv6_clear_mutable_options(struct ipv6hdr *iph, int len, int dir)
 {
 	union {
 		struct ipv6hdr *iph;
@@ -141,7 +140,9 @@
 			break;
 
 		case NEXTHDR_ROUTING:
-			ipv6_rearrange_rthdr(iph, exthdr.rth);
+			if (dir == XFRM_POLICY_OUT)
+				ipv6_rearrange_rthdr(iph, exthdr.rth);
+			exthdr.rth->segments_left = 0;
 			break;
 
 		default :
@@ -208,7 +209,8 @@
 		(*pskb)->nh.ipv6h = (struct ipv6hdr*)skb_push(*pskb, x->props.header_len);
 		iph->payload_len = htons((*pskb)->len - sizeof(struct ipv6hdr));
 		memcpy((*pskb)->nh.ipv6h, iph, hdr_len);
-		err = ipv6_clear_mutable_options((*pskb)->nh.ipv6h, hdr_len);
+		err = ipv6_clear_mutable_options((*pskb)->nh.ipv6h, hdr_len,
+						 XFRM_POLICY_OUT);
 		if (err)
 			goto error_free_iph;
 
@@ -316,7 +318,7 @@
 	if (!tmp_hdr)
 		goto out;
 	memcpy(tmp_hdr, skb->nh.raw, hdr_len);
-	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len))
+	if (ipv6_clear_mutable_options(skb->nh.ipv6h, hdr_len, XFRM_POLICY_IN))
 		goto out;
 	skb->nh.ipv6h->priority    = 0;
 	skb->nh.ipv6h->flow_lbl[0] = 0;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
