From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [ESP4] Merge NAT-T code in esp_output
Date: Thu, 1 Jul 2004 22:33:44 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040701123344.GA11639@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="jI8keyz6grp/JLjh"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is another step on the way to distilling the tunnel mode encap
code between AH/ESP/IPCOMP.

This patch removes the needless duplciation of NAT-T code between
transport mode and tunnel mode ESP4.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--jI8keyz6grp/JLjh
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/esp4.c 1.48 vs edited =====
--- 1.48/net/ipv4/esp4.c	2004-07-01 19:11:29 +10:00
+++ edited/net/ipv4/esp4.c	2004-07-01 22:33:16 +10:00
@@ -28,9 +28,6 @@
 	struct crypto_tfm *tfm;
 	struct esp_data *esp;
 	struct sk_buff *trailer;
-	struct udphdr *uh = NULL;
-	u32 *udpdata32;
-	struct xfrm_encap_tmpl *encap = NULL;
 	int blksize;
 	int clen;
 	int alen;
@@ -88,30 +85,10 @@
 	*(u8*)(trailer->tail + clen-(*pskb)->len - 2) = (clen - (*pskb)->len)-2;
 	pskb_put(*pskb, trailer, clen - (*pskb)->len);
 
-	encap = x->encap;
-
 	iph = (*pskb)->nh.iph;
 	if (x->props.mode) {
 		top_iph = (struct iphdr*)skb_push(*pskb, x->props.header_len);
 		esph = (struct ip_esp_hdr*)(top_iph+1);
-		if (encap) {
-			switch (encap->encap_type) {
-			default:
-			case UDP_ENCAP_ESPINUDP:
-				uh = (struct udphdr*) esph;
-				esph = (struct ip_esp_hdr*)(uh+1);
-				top_iph->protocol = IPPROTO_UDP;
-				break;
-			case UDP_ENCAP_ESPINUDP_NON_IKE:
-				uh = (struct udphdr*) esph;
-				udpdata32 = (u32*)(uh+1);
-				udpdata32[0] = udpdata32[1] = 0;
-				esph = (struct ip_esp_hdr*)(udpdata32+2);
-				top_iph->protocol = IPPROTO_UDP;
-				break;
-			}
-		} else
-			top_iph->protocol = IPPROTO_ESP;
 		*(u8*)(trailer->tail - 1) = IPPROTO_IPIP;
 		top_iph->ihl = 5;
 		top_iph->version = 4;
@@ -131,24 +108,6 @@
 		esph = (struct ip_esp_hdr*)skb_push(*pskb, x->props.header_len);
 		top_iph = (struct iphdr*)skb_push(*pskb, iph->ihl*4);
 		memcpy(top_iph, &tmp_iph, iph->ihl*4);
-		if (encap) {
-			switch (encap->encap_type) {
-			default:
-			case UDP_ENCAP_ESPINUDP:
-				uh = (struct udphdr*) esph;
-				esph = (struct ip_esp_hdr*)(uh+1);
-				top_iph->protocol = IPPROTO_UDP;
-				break;
-			case UDP_ENCAP_ESPINUDP_NON_IKE:
-				uh = (struct udphdr*) esph;
-				udpdata32 = (u32*)(uh+1);
-				udpdata32[0] = udpdata32[1] = 0;
-				esph = (struct ip_esp_hdr*)(udpdata32+2);
-				top_iph->protocol = IPPROTO_UDP;
-				break;
-			}
-		} else
-			top_iph->protocol = IPPROTO_ESP;
 		iph = &tmp_iph.iph;
 		top_iph->tot_len = htons((*pskb)->len + alen);
 		top_iph->check = 0;
@@ -157,12 +116,32 @@
 	}
 
 	/* this is non-NULL only with UDP Encapsulation */
-	if (encap && uh) {
+	if (x->encap) {
+		struct xfrm_encap_tmpl *encap = x->encap;
+		struct udphdr *uh;
+		u32 *udpdata32;
+
+		uh = (struct udphdr *)esph;
 		uh->source = encap->encap_sport;
 		uh->dest = encap->encap_dport;
 		uh->len = htons((*pskb)->len + alen - sizeof(struct iphdr));
 		uh->check = 0;
-	}
+
+		switch (encap->encap_type) {
+		default:
+		case UDP_ENCAP_ESPINUDP:
+			esph = (struct ip_esp_hdr *)(uh + 1);
+			break;
+		case UDP_ENCAP_ESPINUDP_NON_IKE:
+			udpdata32 = (u32 *)(uh + 1);
+			udpdata32[0] = udpdata32[1] = 0;
+			esph = (struct ip_esp_hdr *)(udpdata32 + 2);
+			break;
+		}
+
+		top_iph->protocol = IPPROTO_UDP;
+	} else
+		top_iph->protocol = IPPROTO_ESP;
 
 	esph->spi = x->id.spi;
 	esph->seq_no = htonl(++x->replay.oseq);

--jI8keyz6grp/JLjh--
