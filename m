From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: [AH4] Harmonisation of output function
Date: Fri, 2 Jul 2004 23:06:52 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040702130652.GA20334@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="opJtzjQTFsWo+cga"
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Hi Dave:

This is another step towards the union of the tunnel mode encapsulation
between transforms.  As there are significant differences between the
tunnel encapsulation of IPv4 and IPv6, I'll be dealing with IPv4 only
for now.

This particular patch rearranges the code in ah_output to isolate the
tunnel mode encapsulation.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--opJtzjQTFsWo+cga
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== net/ipv4/ah4.c 1.33 vs edited =====
--- 1.33/net/ipv4/ah4.c	2004-06-24 11:19:28 +10:00
+++ edited/net/ipv4/ah4.c	2004-07-02 22:53:20 +10:00
@@ -86,29 +86,23 @@
 		top_iph = (struct iphdr*)skb_push(*pskb, x->props.header_len);
 		top_iph->ihl = 5;
 		top_iph->version = 4;
-		top_iph->tos = 0;
-		top_iph->tot_len = htons((*pskb)->len);
-		top_iph->frag_off = 0;
+		top_iph->tos = iph->tos;
+		if (x->props.flags & XFRM_STATE_NOECN)
+			IP_ECN_clear(top_iph);
+		top_iph->frag_off = iph->frag_off & ~htons(IP_MF|IP_OFFSET);
 		if (!(iph->frag_off&htons(IP_DF)))
 			__ip_select_ident(top_iph, dst, 0);
-		top_iph->ttl = 0;
-		top_iph->protocol = IPPROTO_AH;
-		top_iph->check = 0;
+		top_iph->ttl = iph->ttl;
 		top_iph->saddr = x->props.saddr.a4;
 		top_iph->daddr = x->id.daddr.a4;
+		memcpy(&tmp_iph, top_iph, 20);
+		memset(&(IPCB(*pskb)->opt), 0, sizeof(struct ip_options));
 		ah = (struct ip_auth_hdr*)(top_iph+1);
 		ah->nexthdr = IPPROTO_IPIP;
 	} else {
 		memcpy(&tmp_iph, (*pskb)->data, iph->ihl*4);
 		top_iph = (struct iphdr*)skb_push(*pskb, x->props.header_len);
 		memcpy(top_iph, &tmp_iph, iph->ihl*4);
-		iph = &tmp_iph.iph;
-		top_iph->tos = 0;
-		top_iph->tot_len = htons((*pskb)->len);
-		top_iph->frag_off = 0;
-		top_iph->ttl = 0;
-		top_iph->protocol = IPPROTO_AH;
-		top_iph->check = 0;
 		if (top_iph->ihl != 5) {
 			err = ip_clear_mutable_options(top_iph, &top_iph->daddr);
 			if (err)
@@ -117,6 +111,15 @@
 		ah = (struct ip_auth_hdr*)((char*)top_iph+iph->ihl*4);
 		ah->nexthdr = iph->protocol;
 	}
+
+	iph = &tmp_iph.iph;
+	top_iph->tos = 0;
+	top_iph->tot_len = htons((*pskb)->len);
+	top_iph->frag_off = 0;
+	top_iph->ttl = 0;
+	top_iph->protocol = IPPROTO_AH;
+	top_iph->check = 0;
+
 	ahp = x->data;
 	ah->hdrlen  = (XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + 
 				   ahp->icv_trunc_len) >> 2) - 2;
@@ -127,13 +130,8 @@
 	ahp->icv(ahp, *pskb, ah->auth_data);
 	top_iph->tos = iph->tos;
 	top_iph->ttl = iph->ttl;
-	if (x->props.mode) {
-		if (x->props.flags & XFRM_STATE_NOECN)
-			IP_ECN_clear(top_iph);
-		top_iph->frag_off = iph->frag_off&~htons(IP_MF|IP_OFFSET);
-		memset(&(IPCB(*pskb)->opt), 0, sizeof(struct ip_options));
-	} else {
-		top_iph->frag_off = iph->frag_off;
+	top_iph->frag_off = iph->frag_off;
+	if (!x->props.mode) {
 		top_iph->daddr = iph->daddr;
 		if (iph->ihl != 5)
 			memcpy(top_iph+1, iph+1, iph->ihl*4 - sizeof(struct iphdr));

--opJtzjQTFsWo+cga--
