From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [IPSEC] Remove run-time encap_type checks in esp4
Date: Sat, 26 Jun 2004 11:57:15 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040626015715.GA16496@gondor.apana.org.au>
References: <20040625121147.GA11231@gondor.apana.org.au> <20040625123527.GA11685@gondor.apana.org.au> <20040625103928.3b1b3275.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="YiEDa0DAkWCtVeE4"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040625103928.3b1b3275.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jun 25, 2004 at 10:39:28AM -0700, David S. Miller wrote:
> On Fri, 25 Jun 2004 22:35:27 +1000
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
> > Here is the patch to check encap_type at the earliest possible
> > opportunity in xfrm_user/af_key.
> 
> Applied.

Thanks.

This allows us to remove all the per-packet checks on x->encap->encap_type.
I've left the check in esp_input just in case someone adds a non-ESP encap
type in future.

However, printing a warning and then continuing is definitely wrong.
So expect a follow-up patch to drop the packet when encap_type is
unknown in esp_input.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--YiEDa0DAkWCtVeE4
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/esp4.c 1.44 vs edited =====
--- 1.44/net/ipv4/esp4.c	2004-06-25 18:38:22 +10:00
+++ edited/net/ipv4/esp4.c	2004-06-26 11:47:15 +10:00
@@ -94,8 +94,9 @@
 	if (x->props.mode) {
 		top_iph = (struct iphdr*)skb_push(*pskb, x->props.header_len);
 		esph = (struct ip_esp_hdr*)(top_iph+1);
-		if (encap && encap->encap_type) {
+		if (encap) {
 			switch (encap->encap_type) {
+			default:
 			case UDP_ENCAP_ESPINUDP:
 				uh = (struct udphdr*) esph;
 				esph = (struct ip_esp_hdr*)(uh+1);
@@ -108,12 +109,6 @@
 				esph = (struct ip_esp_hdr*)(udpdata32+2);
 				top_iph->protocol = IPPROTO_UDP;
 				break;
-			default:
-				printk(KERN_INFO
-				       "esp_output(): Unhandled encap: %u\n",
-				       encap->encap_type);
-				top_iph->protocol = IPPROTO_ESP;
-				break;
 			}
 		} else
 			top_iph->protocol = IPPROTO_ESP;
@@ -136,8 +131,9 @@
 		esph = (struct ip_esp_hdr*)skb_push(*pskb, x->props.header_len);
 		top_iph = (struct iphdr*)skb_push(*pskb, iph->ihl*4);
 		memcpy(top_iph, &tmp_iph, iph->ihl*4);
-		if (encap && encap->encap_type) {
+		if (encap) {
 			switch (encap->encap_type) {
+			default:
 			case UDP_ENCAP_ESPINUDP:
 				uh = (struct udphdr*) esph;
 				esph = (struct ip_esp_hdr*)(uh+1);
@@ -150,12 +146,6 @@
 				esph = (struct ip_esp_hdr*)(udpdata32+2);
 				top_iph->protocol = IPPROTO_UDP;
 				break;
-			default:
-				printk(KERN_INFO
-				       "esp_output(): Unhandled encap: %u\n",
-				       encap->encap_type);
-				top_iph->protocol = IPPROTO_ESP;
-				break;
 			}
 		} else
 			top_iph->protocol = IPPROTO_ESP;
@@ -365,11 +355,8 @@
 		if (encap->encap_type != decap->decap_type)
 			return -EINVAL;
 
-		/* Next, if we don't have an encap type, then ignore it */
-		if (!encap->encap_type)
-			return 0;
-
 		switch (encap->encap_type) {
+		default:
 		case UDP_ENCAP_ESPINUDP:
 		case UDP_ENCAP_ESPINUDP_NON_IKE:
 			/*
@@ -406,11 +393,6 @@
 				skb->ip_summed = CHECKSUM_UNNECESSARY;
 
 			break;
-		default:
-			printk(KERN_INFO
-			       "esp4_post_input(): Unhandled encap type: %u\n",
-			       encap->encap_type);
-			break;
 		}
 	}
 	return 0;
@@ -547,20 +529,14 @@
 	if (x->encap) {
 		struct xfrm_encap_tmpl *encap = x->encap;
 
-		if (encap->encap_type) {
-			switch (encap->encap_type) {
-			case UDP_ENCAP_ESPINUDP:
-				x->props.header_len += sizeof(struct udphdr);
-				break;
-			case UDP_ENCAP_ESPINUDP_NON_IKE:
-				x->props.header_len += sizeof(struct udphdr) + 2 * sizeof(u32);
-				break;
-			default:
-				printk (KERN_INFO
-				"esp_init_state(): Unhandled encap type: %u\n",
-					encap->encap_type);
-				break;
-			}
+		switch (encap->encap_type) {
+		default:
+		case UDP_ENCAP_ESPINUDP:
+			x->props.header_len += sizeof(struct udphdr);
+			break;
+		case UDP_ENCAP_ESPINUDP_NON_IKE:
+			x->props.header_len += sizeof(struct udphdr) + 2 * sizeof(u32);
+			break;
 		}
 	}
 	x->data = esp;

--YiEDa0DAkWCtVeE4--
