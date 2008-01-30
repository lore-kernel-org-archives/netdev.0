From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: ipcomp regression in 2.6.24
Date: Wed, 30 Jan 2008 14:15:33 +1100
Message-ID: <E1JK3QD-0006hM-00@gondolin.me.apana.org.au>
References: <BAY103-DAV76D55A34FB3E0924FF49AB2350@phx.gbl>
Cc: Daniel.Beschorner@facton.com, netdev@vger.kernel.org
To: davem@davemloft.net, pupilla@hotmail.com (Marco Berizzi)
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:55802 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751403AbYA3DPk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jan 2008 22:15:40 -0500
In-Reply-To: <BAY103-DAV76D55A34FB3E0924FF49AB2350@phx.gbl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marco Berizzi <pupilla@hotmail.com> wrote:
>
>> > With 2.6.24 IPSEC/ESP tunnels to older kernels establish fine, data
>> > flows in both directions, but no data comes out of the tunnel.
>> > Needed to disable ipcomp.
> 
> Same problem here: linux 2.6.24 driven by openswan 2.4.11
> on Slackware 11.0

My bad.  This patch should fix it.

[IPCOMP]: Fetch nexthdr before ipch is destroyed

When I moved the nexthdr setting out of IPComp I accidently moved
the reading of ipch->nexthdr after the decompression.  Unfortunately
this means that we'd be reading from a stale ipch pointer which
doesn't work very well.

This patch moves the reading up so that we get the correct nexthdr
value.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
--
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index f4af99a..b79cdbe 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -74,6 +74,7 @@ out:
 
 static int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb)
 {
+	int nexthdr;
 	int err = -ENOMEM;
 	struct ip_comp_hdr *ipch;
 
@@ -84,13 +85,15 @@ static int ipcomp_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	/* Remove ipcomp header and decompress original payload */
 	ipch = (void *)skb->data;
+	nexthdr = ipch->nexthdr;
+
 	skb->transport_header = skb->network_header + sizeof(*ipch);
 	__skb_pull(skb, sizeof(*ipch));
 	err = ipcomp_decompress(x, skb);
 	if (err)
 		goto out;
 
-	err = ipch->nexthdr;
+	err = nexthdr;
 
 out:
 	return err;
diff --git a/net/ipv6/ipcomp6.c b/net/ipv6/ipcomp6.c
index b276d04..710325e 100644
--- a/net/ipv6/ipcomp6.c
+++ b/net/ipv6/ipcomp6.c
@@ -64,6 +64,7 @@ static LIST_HEAD(ipcomp6_tfms_list);
 
 static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
 {
+	int nexthdr;
 	int err = -ENOMEM;
 	struct ip_comp_hdr *ipch;
 	int plen, dlen;
@@ -79,6 +80,8 @@ static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
 
 	/* Remove ipcomp header and decompress original payload */
 	ipch = (void *)skb->data;
+	nexthdr = ipch->nexthdr;
+
 	skb->transport_header = skb->network_header + sizeof(*ipch);
 	__skb_pull(skb, sizeof(*ipch));
 
@@ -108,7 +111,7 @@ static int ipcomp6_input(struct xfrm_state *x, struct sk_buff *skb)
 	skb->truesize += dlen - plen;
 	__skb_put(skb, dlen - plen);
 	skb_copy_to_linear_data(skb, scratch, dlen);
-	err = ipch->nexthdr;
+	err = nexthdr;
 
 out_put_cpu:
 	put_cpu();
