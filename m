From: Andreas Gruenbacher <agruen@suse.de>
Subject: Re: [NAT-T] NON-IKE encapsulation
Date: Sat, 26 Jun 2004 01:30:29 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1088206229.25933.57.camel@winden.suse.de>
References: <20040624123603.GA1241@gondor.apana.org.au>
	 <20040625101231.6f6b2f12.davem@redhat.com>
	 <20040625215747.GA14930@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-U0g4M2Kzyf8oqhVmy+zn"
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20040625215747.GA14930@gondor.apana.org.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--=-U0g4M2Kzyf8oqhVmy+zn
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

Hello,

On Fri, 2004-06-25 at 23:57, Herbert Xu wrote:
> On Fri, Jun 25, 2004 at 10:12:31AM -0700, David S. Miller wrote:
> > 
> > I now think it's trying to account for the udpdata32[] header area.
> > But that's not 2 bytes, it's (2 * sizeof(u32)) or 8 bytes.
> 
> That's what I thought too, but that is already accounted by
> x->props.header_len in init_state.
> 
> In any case, just increasing alen like that is wrong.  It needs to
> do at least three other things:
> 
> 1. Allocate memory for it in skb_cow_data.
> 2. Fill in those bytes with data so we don't leak information.
> 3. Teach get_max_size about it.
> 
> Andreas, can you please clarify for us as to what those two bytes
> are for?

Your analyses are entirely correct. The two instances of ``alen += 2''
are indeed complete nonsense. The extra 8 bytes required are already
accounted for in header_len; nothing other than the two zero-filled
words is required for this encapsulation mode.

Attached is a new version of the original patch, and a relative diff for
reference. Thanks for reviewing and for reporting. (And sorry for the
confusion; I'm a bit stressed out at the moment.)


Cheers,
-- 
Andreas Gruenbacher <agruen@suse.de>
SUSE Labs, SUSE LINUX AG


--=-U0g4M2Kzyf8oqhVmy+zn
Content-Disposition: attachment; filename=ipsec-nat-t-old
Content-Type: text/plain; name=ipsec-nat-t-old; charset=utf-8
Content-Transfer-Encoding: 7bit

This adds support for the old NAT Traversal packet format described
in draft-ietf-ipsec-udp-encaps-00/01. More recent Internet Drafts
define an improved format, but some ipsec implementations still
don't support that.

  Andreas Gruenbacher <agruen@suse.de>, SUSE Labs, 2004.


Index: linux-2.6.5/net/ipv4/udp.c
===================================================================
--- linux-2.6.5.orig/net/ipv4/udp.c
+++ linux-2.6.5/net/ipv4/udp.c
@@ -975,6 +975,7 @@ static int udp_encap_rcv(struct sock * s
 			/* Must be an IKE packet.. pass it through */
 			return 1;
 
+	decaps:
 		/* At this point we are sure that this is an ESPinUDP packet,
 		 * so we need to remove 'len' bytes from the packet (the UDP
 		 * header and optional ESP marker bytes) and then modify the
@@ -1002,6 +1003,20 @@ static int udp_encap_rcv(struct sock * s
 		/* and let the caller know to send this into the ESP processor... */
 		return -1;
 
+	case UDP_ENCAP_ESPINUDP_NON_IKE:
+		/* Check if this is a keepalive packet.  If so, eat it. */
+		if (len == 1 && udpdata[0] == 0xff) {
+			return 0;
+		} else if (len > 2 * sizeof(u32) + sizeof(struct ip_esp_hdr) &&
+			   udpdata32[0] == 0 && udpdata32[1] == 0) {
+			
+			/* ESP Packet with Non-IKE marker */
+			len = sizeof(struct udphdr) + 2 * sizeof(u32);
+			goto decaps;
+		} else
+			/* Must be an IKE packet.. pass it through */
+			return 1;
+
 	default:
 		if (net_ratelimit())
 			printk(KERN_INFO "udp_encap_rcv(): Unhandled UDP encap type: %u\n",
Index: linux-2.6.5/net/ipv4/esp4.c
===================================================================
--- linux-2.6.5.orig/net/ipv4/esp4.c
+++ linux-2.6.5/net/ipv4/esp4.c
@@ -31,6 +31,7 @@ int esp_output(struct sk_buff *skb)
 	struct esp_data *esp;
 	struct sk_buff *trailer;
 	struct udphdr *uh = NULL;
+	u32 *udpdata32;
 	struct xfrm_encap_tmpl *encap = NULL;
 	int blksize;
 	int clen;
@@ -97,6 +98,13 @@ int esp_output(struct sk_buff *skb)
 				esph = (struct ip_esp_hdr*)(uh+1);
 				top_iph->protocol = IPPROTO_UDP;
 				break;
+			case UDP_ENCAP_ESPINUDP_NON_IKE:
+				uh = (struct udphdr*) esph;
+				udpdata32 = (u32*)(uh+1);
+				udpdata32[0] = udpdata32[1] = 0;
+				esph = (struct ip_esp_hdr*)(udpdata32+2);
+				top_iph->protocol = IPPROTO_UDP;
+				break;
 			default:
 				printk(KERN_INFO
 				       "esp_output(): Unhandled encap: %u\n",
@@ -132,6 +140,13 @@ int esp_output(struct sk_buff *skb)
 				esph = (struct ip_esp_hdr*)(uh+1);
 				top_iph->protocol = IPPROTO_UDP;
 				break;
+			case UDP_ENCAP_ESPINUDP_NON_IKE:
+				uh = (struct udphdr*) esph;
+				udpdata32 = (u32*)(uh+1);
+				udpdata32[0] = udpdata32[1] = 0;
+				esph = (struct ip_esp_hdr*)(udpdata32+2);
+				top_iph->protocol = IPPROTO_UDP;
+				break;
 			default:
 				printk(KERN_INFO
 				       "esp_output(): Unhandled encap: %u\n",
@@ -294,6 +309,7 @@ int esp_input(struct xfrm_state *x, stru
 
 			switch (decap->decap_type) {
 			case UDP_ENCAP_ESPINUDP:
+			case UDP_ENCAP_ESPINUDP_NON_IKE:
 
 				if ((void*)uh == (void*)esph) {
 					printk(KERN_DEBUG
@@ -354,6 +370,7 @@ int esp_post_input(struct xfrm_state *x,
 
 		switch (encap->encap_type) {
 		case UDP_ENCAP_ESPINUDP:
+		case UDP_ENCAP_ESPINUDP_NON_IKE:
 			/*
 			 * 1) if the NAT-T peer's IP or port changed then
 			 *    advertize the change to the keying daemon.
@@ -534,6 +551,9 @@ int esp_init_state(struct xfrm_state *x,
 			case UDP_ENCAP_ESPINUDP:
 				x->props.header_len += sizeof(struct udphdr);
 				break;
+			case UDP_ENCAP_ESPINUDP_NON_IKE:
+				x->props.header_len += sizeof(struct udphdr) + 2 * sizeof(u32);
+				break;
 			default:
 				printk (KERN_INFO
 				"esp_init_state(): Unhandled encap type: %u\n",
Index: linux-2.6.5/include/linux/udp.h
===================================================================
--- linux-2.6.5.orig/include/linux/udp.h
+++ linux-2.6.5/include/linux/udp.h
@@ -31,6 +31,7 @@ struct udphdr {
 #define UDP_ENCAP	100	/* Set the socket to accept encapsulated packets */
 
 /* UDP encapsulation types */
+#define UDP_ENCAP_ESPINUDP_NON_IKE	1 /* draft-ietf-ipsec-nat-t-ike-00/01 */
 #define UDP_ENCAP_ESPINUDP	2 /* draft-ietf-ipsec-udp-encaps-06 */
 
 #ifdef __KERNEL__

--=-U0g4M2Kzyf8oqhVmy+zn
Content-Disposition: attachment; filename=delta.diff
Content-Type: text/x-patch; name=delta.diff; charset=utf-8
Content-Transfer-Encoding: 7bit

Index: linux-2.6.5/net/ipv4/esp4.c
===================================================================
--- linux-2.6.5.orig/net/ipv4/esp4.c
+++ linux-2.6.5/net/ipv4/esp4.c
@@ -103,7 +103,6 @@ int esp_output(struct sk_buff *skb)
 				udpdata32 = (u32*)(uh+1);
 				udpdata32[0] = udpdata32[1] = 0;
 				esph = (struct ip_esp_hdr*)(udpdata32+2);
-				alen += 2;
 				top_iph->protocol = IPPROTO_UDP;
 				break;
 			default:
@@ -146,7 +145,6 @@ int esp_output(struct sk_buff *skb)
 				udpdata32 = (u32*)(uh+1);
 				udpdata32[0] = udpdata32[1] = 0;
 				esph = (struct ip_esp_hdr*)(udpdata32+2);
-				alen += 2;
 				top_iph->protocol = IPPROTO_UDP;
 				break;
 			default:

--=-U0g4M2Kzyf8oqhVmy+zn--
