From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPCOMP6] Exclude IPCOMP header from props.header_len
Date: Sat, 10 Jul 2004 13:32:09 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040710033209.GA14316@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="C7zPtVaVf+AK4Oqc"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, yoshfuji@linux-ipv6.org,
        netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

Now that the IPv4 encap stuff is out of the way, I'll be sending you
the IPv6 versions.

Here is the one to remove the unnecessary extra space reserved for
IPCOMP.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--C7zPtVaVf+AK4Oqc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv6/ipcomp6.c 1.11 vs edited =====
--- 1.11/net/ipv6/ipcomp6.c	2004-06-18 16:20:58 +10:00
+++ edited/net/ipv6/ipcomp6.c	2004-07-10 13:26:45 +10:00
@@ -123,7 +123,7 @@
 	int err;
 	struct dst_entry *dst = (*pskb)->dst;
 	struct xfrm_state *x = dst->xfrm;
-	struct ipv6hdr *tmp_iph = NULL, *iph, *top_iph;
+	struct ipv6hdr *iph, *top_iph;
 	int hdr_len = 0;
 	struct ipv6_comp_hdr *ipch;
 	struct ipcomp_data *ipcd = x->data;
@@ -193,19 +193,11 @@
 	if ((dlen + sizeof(struct ipv6_comp_hdr)) >= plen) {
 		goto out_ok;
 	}
-	memcpy(start, scratch, dlen);
-	pskb_trim(*pskb, hdr_len+dlen);
+	memcpy(start + sizeof(struct ip_comp_hdr), scratch, dlen);
+	pskb_trim(*pskb, hdr_len + dlen + sizeof(struct ip_comp_hdr));
 
 	/* insert ipcomp header and replace datagram */
-	tmp_iph = kmalloc(hdr_len, GFP_ATOMIC);
-	if (!tmp_iph) {
-		err = -ENOMEM;
-		goto error;
-	}
-	memcpy(tmp_iph, (*pskb)->nh.raw, hdr_len);
-	top_iph = (struct ipv6hdr*)skb_push(*pskb, sizeof(struct ipv6_comp_hdr));
-	memcpy(top_iph, tmp_iph, hdr_len);
-	kfree(tmp_iph);
+	top_iph = (*pskb)->nh.ipv6h;
 
 	if (x->props.mode && (x->props.flags & XFRM_STATE_NOECN))
 		IP6_ECN_clear(top_iph);
@@ -358,7 +350,7 @@
 		goto error;
 
 	memset(ipcd, 0, sizeof(*ipcd));
-	x->props.header_len = sizeof(struct ipv6_comp_hdr);
+	x->props.header_len = 0;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	

--C7zPtVaVf+AK4Oqc--
