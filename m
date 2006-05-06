From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [RFC 3/3] [IPSEC]: Abstract out transport mode input code
Date: Sat, 6 May 2006 21:24:44 +1000
Message-ID: <20060506112444.GC27904@gondor.apana.org.au>
References: <1145343829.44448f556684c@webmail.hiit.fi> <20060418080340.GA2206@gondor.apana.org.au> <Pine.SOL.4.64.0604181512460.26361@kekkonen.cs.hut.fi> <20060419110209.GA15584@gondor.apana.org.au> <Pine.SOL.4.64.0604191529100.11141@kekkonen.cs.hut.fi> <20060506112026.GA27671@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="yVhtmJPUSI46BTXb"
Cc: Diego Beltrami <Diego.Beltrami@hiit.fi>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:28430 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1750790AbWEFLYu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 6 May 2006 07:24:50 -0400
To: Miika Komu <miika@iki.fi>
Content-Disposition: inline
In-Reply-To: <20060506112026.GA27671@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--yVhtmJPUSI46BTXb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi:

This patch is totally untested but shows how we can use xfrm_mode to
remove unnecessary code sharing between modes that in fact end up
slowing things down.  In particular, notice how we've eliminated a
double IP header copying for tunnel mode which is in fact the common
case.

I need to finish it for IPv6 and actually test this one :)

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--yVhtmJPUSI46BTXb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="p3.patch"

diff --git a/net/ipv4/ah4.c b/net/ipv4/ah4.c
index e2e4771..30524b9 100644
--- a/net/ipv4/ah4.c
+++ b/net/ipv4/ah4.c
@@ -172,11 +172,8 @@
 		}
 	}
 	((struct iphdr*)work_buf)->protocol = ah->nexthdr;
-	skb->nh.raw = skb_pull(skb, ah_hlen);
-	memcpy(skb->nh.raw, work_buf, iph->ihl*4);
-	skb->nh.iph->tot_len = htons(skb->len);
-	skb_pull(skb, skb->nh.iph->ihl*4);
-	skb->h.raw = skb->data;
+	skb->h.raw = memcpy(skb->nh.raw, work_buf, iph->ihl * 4) + ah_hlen;
+	__skb_pull(skb, ah_hlen + iph->ihl * 4);
 
 	return 0;
 
diff --git a/net/ipv4/esp4.c b/net/ipv4/esp4.c
index 9d1881c..451803e 100644
--- a/net/ipv4/esp4.c
+++ b/net/ipv4/esp4.c
@@ -143,10 +143,8 @@
 	int alen = esp->auth.icv_trunc_len;
 	int elen = skb->len - sizeof(struct ip_esp_hdr) - esp->conf.ivlen - alen;
 	int nfrags;
-	int encap_len = 0;
 	u8 nexthdr[2];
 	struct scatterlist *sg;
-	u8 workbuf[60];
 	int padlen;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr)))
@@ -209,7 +207,6 @@
 		struct udphdr *uh;
 
 		uh = (struct udphdr *)(iph + 1);
-		encap_len = (void*)esph - (void*)uh;
 
 		/*
 		 * 1) if the NAT-T peer's IP or port changed then
@@ -246,11 +243,9 @@
 
 	iph->protocol = nexthdr[1];
 	pskb_trim(skb, skb->len - alen - padlen - 2);
-	memcpy(workbuf, skb->nh.raw, iph->ihl*4);
-	skb->h.raw = skb_pull(skb, sizeof(struct ip_esp_hdr) + esp->conf.ivlen);
-	skb->nh.raw += encap_len + sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
-	memcpy(skb->nh.raw, workbuf, iph->ihl*4);
-	skb->nh.iph->tot_len = htons(skb->len);
+	skb->h.raw = __skb_pull(skb,
+				sizeof(struct ip_esp_hdr) + esp->conf.ivlen) -
+		     iph->ihl * 4;
 
 	return 0;
 
diff --git a/net/ipv4/ipcomp.c b/net/ipv4/ipcomp.c
index cd810f4..704937b 100644
--- a/net/ipv4/ipcomp.c
+++ b/net/ipv4/ipcomp.c
@@ -45,7 +45,6 @@
 static int ipcomp_decompress(struct xfrm_state *x, struct sk_buff *skb)
 {
 	int err, plen, dlen;
-	struct iphdr *iph;
 	struct ipcomp_data *ipcd = x->data;
 	u8 *start, *scratch;
 	struct crypto_tfm *tfm;
@@ -74,8 +73,6 @@
 		
 	skb_put(skb, dlen - plen);
 	memcpy(skb->data, scratch, dlen);
-	iph = skb->nh.iph;
-	iph->tot_len = htons(dlen + iph->ihl * 4);
 out:	
 	put_cpu();
 	return err;
@@ -108,9 +105,8 @@
 	skb->nh.raw += sizeof(struct ip_comp_hdr);
 	memcpy(skb->nh.raw, &tmp_iph, tmp_iph.iph.ihl * 4);
 	iph = skb->nh.iph;
-	iph->tot_len = htons(ntohs(iph->tot_len) - sizeof(struct ip_comp_hdr));
 	iph->protocol = nexthdr;
-	skb->h.raw = skb->data;
+	skb->h.raw = skb->nh.raw;
 	err = ipcomp_decompress(x, skb);
 
 out:	
diff --git a/net/ipv4/xfrm4_mode_transport.c b/net/ipv4/xfrm4_mode_transport.c
index e46d9a4..c2e507e 100644
--- a/net/ipv4/xfrm4_mode_transport.c
+++ b/net/ipv4/xfrm4_mode_transport.c
@@ -40,6 +40,11 @@
 
 static int xfrm4_transport_input(struct xfrm_state *x, struct sk_buff *skb)
 {
+	if (skb->h.raw != skb->nh.raw)
+		skb->nh.raw = memmove(skb->h.raw, skb->nh.raw,
+				      skb->nh.iph->ihl * 4);
+	skb->nh.iph->tot_len = htons(skb->len);
+	skb->h.raw = skb->data;
 	return 0;
 }
 
diff --git a/net/ipv4/xfrm4_mode_tunnel.c b/net/ipv4/xfrm4_mode_tunnel.c
index f8d880b..a304d1d 100644
--- a/net/ipv4/xfrm4_mode_tunnel.c
+++ b/net/ipv4/xfrm4_mode_tunnel.c
@@ -73,9 +73,11 @@
 
 static int xfrm4_tunnel_input(struct xfrm_state *x, struct sk_buff *skb)
 {
-	struct iphdr *iph = skb->nh.iph;
+	struct iphdr *iph;
 	int err = -EINVAL;
 
+	skb->nh.raw = skb->data;
+	iph = skb->nh.iph;
 	if (iph->protocol != IPPROTO_IPIP)
 		goto out;
 	if (!pskb_may_pull(skb, sizeof(struct iphdr)))
diff --git a/net/ipv4/xfrm4_tunnel.c b/net/ipv4/xfrm4_tunnel.c

--yVhtmJPUSI46BTXb--
