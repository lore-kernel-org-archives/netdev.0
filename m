From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [AH6] Disallow mutable bits after AH header
Date: Wed, 28 Jul 2004 21:46:32 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040728114632.GA7103@gondor.apana.org.au>
References: <20040723135320.GA26000@gondor.apana.org.au> <20040723133737.447a9598.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="82I3+IH0IqGh5yIs"
Cc: kazunori@miyazawa.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040723133737.447a9598.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jul 23, 2004 at 01:37:37PM -0700, David S. Miller wrote:
> On Fri, 23 Jul 2004 23:53:21 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > As we discussed before, mutable headers should not be allowed after
> > the AH header.  In fact, this appears to be the intention of RFC 2402.
> > It is further clarified in section 3.1.1 of
>
> Applied, thanks Herbert.

Unfortunately I broke ah6_input() in that patch.  Thanks to Miyazawa-san
for notifying me of the problem.

In that patch I removed the nh_offset parameter to ipv6_clear_mutable_options.
That broke ah6_input() because it relies on that variable to set the nexthdr.

The following patch fixes this by moving this work out to the caller
xfrm6_rcv() where the information is already available.  It also removes
an unnecessary call to ip6_find_1stfragopt() in xfrm6_rcv() since nhoffp
already points to the nexthdr preceding the current header.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--82I3+IH0IqGh5yIs
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=r

===== net/ipv6/ah6.c 1.36 vs edited =====
--- 1.36/net/ipv6/ah6.c	2004-07-25 20:33:46 +10:00
+++ edited/net/ipv6/ah6.c	2004-07-28 19:36:35 +10:00
@@ -252,9 +252,7 @@
 	unsigned char *tmp_hdr = NULL;
 	u16 hdr_len;
 	u16 ah_hlen;
-	u16 nh_offset = 0;
-	u8 nexthdr = 0;
-	u8 *prevhdr;
+	int nexthdr;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_auth_hdr)))
 		goto out;
@@ -307,8 +305,6 @@
 
 	skb->nh.raw = skb_pull(skb, ah_hlen);
 	memcpy(skb->nh.raw, tmp_hdr, hdr_len);
-	prevhdr = (u8*)(skb->nh.raw + nh_offset);
-	*prevhdr = nexthdr;
 	skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
 	skb_pull(skb, hdr_len);
 	skb->h.raw = skb->data;
===== net/ipv6/esp6.c 1.31 vs edited =====
--- 1.31/net/ipv6/esp6.c	2004-07-25 20:33:46 +10:00
+++ edited/net/ipv6/esp6.c	2004-07-28 19:35:13 +10:00
@@ -197,7 +197,6 @@
 		u8 nexthdr[2];
 		struct scatterlist *sg = &esp->sgbuf[0];
 		u8 padlen;
-		u8 *prevhdr;
 
 		if (unlikely(nfrags > ESP_NUM_FAST_SG)) {
 			sg = kmalloc(sizeof(struct scatterlist)*nfrags, GFP_ATOMIC);
@@ -228,8 +227,7 @@
 		skb->nh.raw += sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
 		memcpy(skb->nh.raw, tmp_hdr, hdr_len);
 		skb->nh.ipv6h->payload_len = htons(skb->len - sizeof(struct ipv6hdr));
-		ip6_find_1stfragopt(skb, &prevhdr);
-		ret = *prevhdr = nexthdr[1];
+		ret = nexthdr[1];
 	}
 
 out:
===== net/ipv6/ipcomp6.c 1.16 vs edited =====
--- 1.16/net/ipv6/ipcomp6.c	2004-07-25 20:33:46 +10:00
+++ edited/net/ipv6/ipcomp6.c	2004-07-28 19:37:00 +10:00
@@ -49,7 +49,6 @@
 {
 	int err = 0;
 	u8 nexthdr = 0;
-	u8 *prevhdr;
 	int hdr_len = skb->h.raw - skb->nh.raw;
 	unsigned char *tmp_hdr = NULL;
 	struct ipv6hdr *iph;
@@ -106,8 +105,6 @@
 	iph = skb->nh.ipv6h;
 	iph->payload_len = htons(skb->len);
 	
-	ip6_find_1stfragopt(skb, &prevhdr);
-	*prevhdr = nexthdr;
 out:
 	if (tmp_hdr)
 		kfree(tmp_hdr);
===== net/ipv6/xfrm6_input.c 1.15 vs edited =====
--- 1.15/net/ipv6/xfrm6_input.c	2004-02-14 18:06:45 +11:00
+++ edited/net/ipv6/xfrm6_input.c	2004-07-28 19:42:26 +10:00
@@ -34,12 +34,11 @@
 	struct xfrm_state *x;
 	int xfrm_nr = 0;
 	int decaps = 0;
-	int nexthdr = 0;
-	u8 *prevhdr = NULL;
+	int nexthdr;
+	unsigned int nhoff;
 
-	ip6_find_1stfragopt(skb, &prevhdr);
-	nexthdr = *prevhdr;
-	*nhoffp = prevhdr - skb->nh.raw;
+	nhoff = *nhoffp;
+	nexthdr = skb->nh.raw[nhoff];
 
 	if ((err = xfrm_parse_spi(skb, nexthdr, &spi, &seq)) != 0)
 		goto drop;
@@ -66,6 +65,8 @@
 		nexthdr = x->type->input(x, &(xfrm_vec[xfrm_nr].decap), skb);
 		if (nexthdr <= 0)
 			goto drop_unlock;
+
+		skb->nh.raw[nhoff] = nexthdr;
 
 		if (x->props.replay_window)
 			xfrm_replay_advance(x, seq);

--82I3+IH0IqGh5yIs--
