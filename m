From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [UDP] Check encap_type at config time
Date: Fri, 25 Jun 2004 22:11:47 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040625121147.GA11231@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="PNTmBPCT7hxwcZjr"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

My foray into the TTL stuff is turning into an all-out assault on NAT-T :)

The following patch moves the udp->encap_type check from the per-packet
hot-path into udp_setsockopt().

As a consequence, this allows user space to detect whether the kernel
actually supports the encap type that they're requesting.  Pity no one
did this before the NON-IKE patch was applied.  As it is there is no
easy way to detect whether NON-IKE support is present.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

PS I will be doing a similar patch for the encap_type in xfrm.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--PNTmBPCT7hxwcZjr
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/udp.c 1.61 vs edited =====
--- 1.61/net/ipv4/udp.c	2004-06-05 06:59:36 +10:00
+++ edited/net/ipv4/udp.c	2004-06-25 21:56:34 +10:00
@@ -964,6 +964,7 @@
 	len = skb->tail - udpdata;
 
 	switch (encap_type) {
+	default:
 	case UDP_ENCAP_ESPINUDP:
 		/* Check if this is a keepalive packet.  If so, eat it. */
 		if (len == 1 && udpdata[0] == 0xff) {
@@ -1016,12 +1017,6 @@
 		} else
 			/* Must be an IKE packet.. pass it through */
 			return 1;
-
-	default:
-		if (net_ratelimit())
-			printk(KERN_INFO "udp_encap_rcv(): Unhandled UDP encap type: %u\n",
-			       encap_type);
-		return 1;
 	}
 #endif
 }
@@ -1297,7 +1292,16 @@
 		break;
 		
 	case UDP_ENCAP:
-		up->encap_type = val;
+		switch (val) {
+		case 0:
+		case UDP_ENCAP_ESPINUDP:
+		case UDP_ENCAP_ESPINUDP_NON_IKE:
+			up->encap_type = val;
+			break;
+		default:
+			err = -ENOPROTOOPT;
+			break;
+		}
 		break;
 
 	default:
===== net/ipv6/udp.c 1.67 vs edited =====
--- 1.67/net/ipv6/udp.c	2004-06-21 09:37:54 +10:00
+++ edited/net/ipv6/udp.c	2004-06-25 20:13:50 +10:00
@@ -1044,7 +1044,14 @@
 		break;
 		
 	case UDP_ENCAP:
-		up->encap_type = val;
+		switch (val) {
+		case 0:
+			up->encap_type = val;
+			break;
+		default:
+			err = -ENOPROTOOPT;
+			break;
+		}
 		break;
 
 	default:

--PNTmBPCT7hxwcZjr--
