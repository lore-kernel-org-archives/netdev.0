From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [UDP] Move common code out in udp_encap_rcv
Date: Sat, 26 Jun 2004 16:44:27 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040626064427.GA25395@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="2oS5YaxWCcQjTEyO"
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This patch simply moves the common code out of the switch statement
in udp_encap_rcv().

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email:  Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--2oS5YaxWCcQjTEyO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/udp.c 1.62 vs edited =====
--- 1.62/net/ipv4/udp.c	2004-06-25 22:12:27 +10:00
+++ edited/net/ipv4/udp.c	2004-06-26 16:18:17 +10:00
@@ -976,34 +976,6 @@
 			/* Must be an IKE packet.. pass it through */
 			return 1;
 
-	decaps:
-		/* At this point we are sure that this is an ESPinUDP packet,
-		 * so we need to remove 'len' bytes from the packet (the UDP
-		 * header and optional ESP marker bytes) and then modify the
-		 * protocol to ESP, and then call into the transform receiver.
-		 */
-
-		/* Now we can update and verify the packet length... */
-		iph = skb->nh.iph;
-		iphlen = iph->ihl << 2;
-		iph->tot_len = htons(ntohs(iph->tot_len) - len);
-		if (skb->len < iphlen + len) {
-			/* packet is too small!?! */
-			return 0;
-		}
-
-		/* pull the data buffer up to the ESP header and set the
-		 * transport header to point to ESP.  Keep UDP on the stack
-		 * for later.
-		 */
-		skb->h.raw = skb_pull(skb, len);
-
-		/* modify the protocol (it's ESP!) */
-		iph->protocol = IPPROTO_ESP;
-
-		/* and let the caller know to send this into the ESP processor... */
-		return -1;
-
 	case UDP_ENCAP_ESPINUDP_NON_IKE:
 		/* Check if this is a keepalive packet.  If so, eat it. */
 		if (len == 1 && udpdata[0] == 0xff) {
@@ -1013,11 +985,37 @@
 			
 			/* ESP Packet with Non-IKE marker */
 			len = sizeof(struct udphdr) + 2 * sizeof(u32);
-			goto decaps;
 		} else
 			/* Must be an IKE packet.. pass it through */
 			return 1;
 	}
+
+	/* At this point we are sure that this is an ESPinUDP packet,
+	 * so we need to remove 'len' bytes from the packet (the UDP
+	 * header and optional ESP marker bytes) and then modify the
+	 * protocol to ESP, and then call into the transform receiver.
+	 */
+
+	/* Now we can update and verify the packet length... */
+	iph = skb->nh.iph;
+	iphlen = iph->ihl << 2;
+	iph->tot_len = htons(ntohs(iph->tot_len) - len);
+	if (skb->len < iphlen + len) {
+		/* packet is too small!?! */
+		return 0;
+	}
+
+	/* pull the data buffer up to the ESP header and set the
+	 * transport header to point to ESP.  Keep UDP on the stack
+	 * for later.
+	 */
+	skb->h.raw = skb_pull(skb, len);
+
+	/* modify the protocol (it's ESP!) */
+	iph->protocol = IPPROTO_ESP;
+
+	/* and let the caller know to send this into the ESP processor... */
+	return -1;
 #endif
 }
 

--2oS5YaxWCcQjTEyO--
