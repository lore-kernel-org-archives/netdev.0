From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: kernel BUG at net/ipv6/exthdrs_core.c:80!
Date: Sat, 23 Apr 2005 00:19:50 +1000
Message-ID: <20050422141950.GA2791@gondor.apana.org.au>
References: <20050422.204610.96031992.yoshfuji@linux-ipv6.org> <E1DOyg4-0000iB-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="TB36FDmn/VVEgNH/"
Cc: matti.aarnio@zmailer.org, linux-net@vger.kernel.org,
	netdev@oss.sgi.com, davem@davemloft.net
Return-path: <linux-net-owner@vger.kernel.org>
To: YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org>
Content-Disposition: inline
In-Reply-To: <E1DOyg4-0000iB-00@gondolin.me.apana.org.au>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Apr 22, 2005 at 11:58:40PM +1000, Herbert Xu wrote:
> 
> Indeed, it's a bug in selinux.  The length should be skb->tail - skb->data,
> and not skb->tail - skb->head.  In fact, we could be vulgar and write it as
> skb->len :)

I was just reading ipv6_skip_exthdr and it occured to me that we can
get rid of len altogether.  The only place where len is used is to
check whether the skb has two bytes for ipv6_opt_hdr.  This check
is done by skb_header_pointer/skb_copy_bits anyway.

Now it might appear that we've made the code slower by deferring
the check to skb_copy_bits.  However, this check should not trigger
in the common case so this is OK.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

This patch supercedes the previous one.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt

--TB36FDmn/VVEgNH/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename=p

===== include/net/ipv6.h 1.44 vs edited =====
--- 1.44/include/net/ipv6.h	2005-03-03 16:12:44 +11:00
+++ edited/include/net/ipv6.h	2005-04-23 00:13:21 +10:00
@@ -416,7 +416,7 @@
 						    u8 *proto);
 
 extern int			ipv6_skip_exthdr(const struct sk_buff *, int start,
-					         u8 *nexthdrp, int len);
+					         u8 *nexthdrp);
 
 extern int 			ipv6_ext_hdr(u8 nexthdr);
 
===== net/ipv6/exthdrs_core.c 1.2 vs edited =====
--- 1.2/net/ipv6/exthdrs_core.c	2004-08-19 10:14:54 +10:00
+++ edited/net/ipv6/exthdrs_core.c	2005-04-23 00:06:11 +10:00
@@ -41,8 +41,8 @@
  * when Linux implements ESP (and maybe AUTH) headers.
  * --AK
  *
- * This function parses (probably truncated) exthdr set "hdr"
- * of length "len". "nexthdrp" initially points to some place,
+ * This function parses (probably truncated) exthdr set "hdr".
+ * "nexthdrp" initially points to some place,
  * where type of the first header can be found.
  *
  * It skips all well-known exthdrs, and returns pointer to the start
@@ -63,7 +63,7 @@
  * --ANK (980726)
  */
 
-int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp, int len)
+int ipv6_skip_exthdr(const struct sk_buff *skb, int start, u8 *nexthdrp)
 {
 	u8 nexthdr = *nexthdrp;
 
@@ -71,13 +71,11 @@
 		struct ipv6_opt_hdr _hdr, *hp;
 		int hdrlen;
 
-		if (len < (int)sizeof(struct ipv6_opt_hdr))
-			return -1;
 		if (nexthdr == NEXTHDR_NONE)
 			return -1;
 		hp = skb_header_pointer(skb, start, sizeof(_hdr), &_hdr);
 		if (hp == NULL)
-			BUG();
+			return -1;
 		if (nexthdr == NEXTHDR_FRAGMENT) {
 			unsigned short _frag_off, *fp;
 			fp = skb_header_pointer(skb,
@@ -97,7 +95,6 @@
 			hdrlen = ipv6_optlen(hp); 
 
 		nexthdr = hp->nexthdr;
-		len -= hdrlen;
 		start += hdrlen;
 	}
 
===== net/ipv6/icmp.c 1.62 vs edited =====
--- 1.62/net/ipv6/icmp.c	2005-03-03 16:12:38 +11:00
+++ edited/net/ipv6/icmp.c	2005-04-23 00:19:13 +10:00
@@ -135,7 +135,7 @@
 	if (len < 0)
 		return 1;
 
-	ptr = ipv6_skip_exthdr(skb, ptr, &nexthdr, len);
+	ptr = ipv6_skip_exthdr(skb, ptr, &nexthdr);
 	if (ptr < 0)
 		return 0;
 	if (nexthdr == IPPROTO_ICMPV6) {
@@ -514,7 +514,7 @@
 	nexthdr = ((struct ipv6hdr *)skb->data)->nexthdr;
 	if (ipv6_ext_hdr(nexthdr)) {
 		/* now skip over extension headers */
-		inner_offset = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr, skb->len - sizeof(struct ipv6hdr));
+		inner_offset = ipv6_skip_exthdr(skb, sizeof(struct ipv6hdr), &nexthdr);
 		if (inner_offset<0)
 			return;
 	} else {
===== security/selinux/hooks.c 1.95 vs edited =====
--- 1.95/security/selinux/hooks.c	2005-04-02 07:30:16 +10:00
+++ edited/security/selinux/hooks.c	2005-04-23 00:13:46 +10:00
@@ -2853,8 +2853,7 @@
 
 	nexthdr = ip6->nexthdr;
 	offset += sizeof(_ipv6h);
-	offset = ipv6_skip_exthdr(skb, offset, &nexthdr,
-				  skb->tail - skb->head - offset);
+	offset = ipv6_skip_exthdr(skb, offset, &nexthdr);
 	if (offset < 0)
 		goto out;
 

--TB36FDmn/VVEgNH/--
