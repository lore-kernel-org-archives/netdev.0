From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPCOMP] Exclude IPCOMP header from props.header_len
Date: Tue, 6 Jul 2004 22:31:27 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040706123127.GA18271@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="J/dobhs11T7y2rNN"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is another patch on the way towards a unified XFRM tunnel
encapsulation function.

This patch changes the value of props.header_len for IPCOMP to
exclude the IPCOMP header.  The reason is that the IPCOMP header
is added only if the packet is compressible.  That is, if the
size of the compressed payload plus the size of the IPCOMP header
is less than that of the original payload.

This means that the IPCOMP encapsulation does not impose any
overhead at all as far as the MTU is concerned.  The current
code incorrectly reduces the MTU by the size of the IPCOMP
header.

As a side-effect, this means that we don't have to move the
IP header around when IPCOMP is used.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--J/dobhs11T7y2rNN
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/ipcomp.c 1.24 vs edited =====
--- 1.24/net/ipv4/ipcomp.c	2004-06-25 18:38:22 +10:00
+++ edited/net/ipv4/ipcomp.c	2004-07-06 22:15:58 +10:00
@@ -114,8 +114,8 @@
 		goto out;
 	}
 	
-	memcpy(start, scratch, dlen);
-	pskb_trim(skb, ihlen + dlen);
+	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
+	pskb_trim(skb, ihlen + dlen + sizeof(struct ip_comp_hdr));
 	
 out:	
 	return err;
@@ -148,13 +148,9 @@
 	int err;
 	struct dst_entry *dst = (*pskb)->dst;
 	struct xfrm_state *x = dst->xfrm;
-	struct iphdr *iph, *top_iph;
+	struct iphdr *iph;
 	struct ip_comp_hdr *ipch;
 	struct ipcomp_data *ipcd = x->data;
-	union {
-		struct iphdr	iph;
-		char 		buf[60];
-	} tmp_iph;
 	int hdr_len = 0;
 
 	if ((*pskb)->ip_summed == CHECKSUM_HW) {
@@ -211,19 +207,15 @@
 
 	/* Install ipcomp header, convert into ipcomp datagram. */
 	iph = (*pskb)->nh.iph;
-	memcpy(&tmp_iph, iph, iph->ihl * 4);
-	top_iph = (struct iphdr *)skb_push(*pskb, sizeof(struct ip_comp_hdr));
-	memcpy(top_iph, &tmp_iph, iph->ihl * 4);
-	iph = top_iph;
 	if (x->props.mode && (x->props.flags & XFRM_STATE_NOECN))
 		IP_ECN_clear(iph);
 	iph->tot_len = htons((*pskb)->len);
-	iph->protocol = IPPROTO_COMP;
 	iph->check = 0;
 	ipch = (struct ip_comp_hdr *)((char *)iph + iph->ihl * 4);
-	ipch->nexthdr = x->props.mode ? IPPROTO_IPIP : tmp_iph.iph.protocol;
+	ipch->nexthdr = x->props.mode ? IPPROTO_IPIP : iph->protocol;
 	ipch->flags = 0;
 	ipch->cpi = htons((u16 )ntohl(x->id.spi));
+	iph->protocol = IPPROTO_COMP;
 	ip_send_check(iph);
 	(*pskb)->nh.raw = (*pskb)->data;
 
@@ -365,7 +357,7 @@
 		goto error;
 
 	memset(ipcd, 0, sizeof(*ipcd));
-	x->props.header_len = sizeof(struct ip_comp_hdr);
+	x->props.header_len = 0;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct iphdr);
 

--J/dobhs11T7y2rNN--
