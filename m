From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPSec: Use of "sizeof" for header sizes, part II
Date: Thu, 03 Apr 2003 13:51:04 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030403.135104.748509693.yoshfuji@linux-ipv6.org>
References: <OFFFFBD9B7.552E83C4-ON85256CFC.0051D199-86256CFC.00526741@pok.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: toml@us.ibm.com, davem@redhat.com, kuznet@ms2.inr.ac.ru
In-Reply-To: <OFFFFBD9B7.552E83C4-ON85256CFC.0051D199-86256CFC.00526741@pok.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OFFFFBD9B7.552E83C4-ON85256CFC.0051D199-86256CFC.00526741@pok.ibm.com> (at Wed, 2 Apr 2003 09:00:03 -0600), "Tom Lendacky" <toml@us.ibm.com> says:

> 
> I just noticed the use of the AH_HLEN_NOICV #define which is hardcoded to
> be 12.  The patch should probably take the change to the esp header and
> apply it to the auth header also (as shown in an earlier post) and then
> eliminate the hardcoding of the 12.

Agreed.  Here's the patch against linux-2.5.66 + ChangeSet 1.1004.
Thanks.

Index: include/linux/ip.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/linux/ip.h,v
retrieving revision 1.1.1.4
retrieving revision 1.1.1.4.14.1
diff -u -r1.1.1.4 -r1.1.1.4.14.1
--- include/linux/ip.h	22 Mar 2003 01:52:35 -0000	1.1.1.4
+++ include/linux/ip.h	2 Apr 2003 10:17:41 -0000	1.1.1.4.14.1
@@ -188,13 +188,13 @@
 	__u16 reserved;
 	__u32 spi;
 	__u32 seq_no;		/* Sequence number */
-	__u8  auth_data[4];	/* Variable len but >=4. Mind the 64 bit alignment! */
+	__u8  auth_data[0];	/* Variable len but >=4. Mind the 64 bit alignment! */
 };
 
 struct ip_esp_hdr {
 	__u32 spi;
 	__u32 seq_no;		/* Sequence number */
-	__u8  enc_data[8];	/* Variable len but >=8. Mind the 64 bit alignment! */
+	__u8  enc_data[0];	/* Variable len but >=8. Mind the 64 bit alignment! */
 };
 
 #endif	/* _LINUX_IP_H */
Index: include/linux/ipv6.h
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/include/linux/ipv6.h,v
retrieving revision 1.1.1.4
retrieving revision 1.1.1.4.14.1
diff -u -r1.1.1.4 -r1.1.1.4.14.1
--- include/linux/ipv6.h	22 Mar 2003 01:52:37 -0000	1.1.1.4
+++ include/linux/ipv6.h	2 Apr 2003 10:17:41 -0000	1.1.1.4.14.1
@@ -80,13 +80,13 @@
 	__u16 reserved;
 	__u32 spi;
 	__u32 seq_no;           /* Sequence number */
-	__u8  auth_data[4];     /* Length variable but >=4. Mind the 64 bit alignment! */
+	__u8  auth_data[0];     /* Length variable but >=4. Mind the 64 bit alignment! */
 };
 
 struct ipv6_esp_hdr {
 	__u32 spi;
 	__u32 seq_no;           /* Sequence number */
-	__u8  enc_data[8];      /* Length variable but >=8. Mind the 64 bit alignment! */
+	__u8  enc_data[0];      /* Length variable but >=8. Mind the 64 bit alignment! */
 };
 
 /*
Index: net/ipv4/ah.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv4/ah.c,v
retrieving revision 1.1.1.10
retrieving revision 1.1.1.10.2.1
diff -u -r1.1.1.10 -r1.1.1.10.2.1
--- net/ipv4/ah.c	2 Apr 2003 07:25:57 -0000	1.1.1.10
+++ net/ipv4/ah.c	3 Apr 2003 01:40:12 -0000	1.1.1.10.2.1
@@ -9,8 +9,6 @@
 #include <asm/scatterlist.h>
 
 
-#define AH_HLEN_NOICV	12
-
 /* Clear mutable options and find final destination to substitute
  * into IP header for icv calculation. Options are already checked
  * for validity, so paranoia is not required. */
@@ -116,8 +114,8 @@
 		ah->nexthdr = iph->protocol;
 	}
 	ahp = x->data;
-	ah->hdrlen  = (XFRM_ALIGN8(ahp->icv_trunc_len +
-			AH_HLEN_NOICV) >> 2) - 2;
+	ah->hdrlen  = (XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + 
+				   ahp->icv_trunc_len) >> 2) - 2;
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
@@ -169,8 +167,8 @@
 	ahp = x->data;
 	ah_hlen = (ah->hdrlen + 2) << 2;
 	
-	if (ah_hlen != XFRM_ALIGN8(ahp->icv_full_len + AH_HLEN_NOICV) &&
-	    ah_hlen != XFRM_ALIGN8(ahp->icv_trunc_len + AH_HLEN_NOICV)) 
+	if (ah_hlen != XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + ahp->icv_full_len) &&
+	    ah_hlen != XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + ahp->icv_trunc_len)) 
 		goto out;
 
 	if (!pskb_may_pull(skb, ah_hlen))
@@ -286,7 +284,7 @@
 	if (!ahp->work_icv)
 		goto error;
 	
-	x->props.header_len = XFRM_ALIGN8(ahp->icv_trunc_len + AH_HLEN_NOICV);
+	x->props.header_len = XFRM_ALIGN8(sizeof(struct ip_auth_hdr) + ahp->icv_trunc_len);
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct iphdr);
 	x->data = ahp;
Index: net/ipv4/esp.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv4/esp.c,v
retrieving revision 1.1.1.9
retrieving revision 1.1.1.9.2.1
diff -u -r1.1.1.9 -r1.1.1.9.2.1
--- net/ipv4/esp.c	2 Apr 2003 07:25:57 -0000	1.1.1.9
+++ net/ipv4/esp.c	2 Apr 2003 10:17:41 -0000	1.1.1.9.2.1
@@ -134,7 +134,7 @@
 
 	if (esp->auth.icv_full_len) {
 		esp->auth.icv(esp, skb, (u8*)esph-skb->data,
-		              8+esp->conf.ivlen+clen, trailer->tail);
+		              sizeof(struct ip_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
 		pskb_put(skb, trailer, alen);
 	}
 
@@ -171,7 +171,7 @@
 	struct sk_buff *trailer;
 	int blksize = crypto_tfm_alg_blocksize(esp->conf.tfm);
 	int alen = esp->auth.icv_trunc_len;
-	int elen = skb->len - 8 - esp->conf.ivlen - alen;
+	int elen = skb->len - sizeof(struct ip_esp_hdr) - esp->conf.ivlen - alen;
 	int nfrags;
 
 	if (!pskb_may_pull(skb, sizeof(struct ip_esp_hdr)))
@@ -220,7 +220,7 @@
 			if (!sg)
 				goto out;
 		}
-		skb_to_sgvec(skb, sg, 8+esp->conf.ivlen, elen);
+		skb_to_sgvec(skb, sg, sizeof(struct ip_esp_hdr) + esp->conf.ivlen, elen);
 		crypto_cipher_decrypt(esp->conf.tfm, sg, sg, elen);
 		if (unlikely(sg != sgbuf))
 			kfree(sg);
@@ -237,8 +237,8 @@
 		iph->protocol = nexthdr[1];
 		pskb_trim(skb, skb->len - alen - padlen - 2);
 		memcpy(workbuf, skb->nh.raw, iph->ihl*4);
-		skb->h.raw = skb_pull(skb, 8 + esp->conf.ivlen);
-		skb->nh.raw += 8 + esp->conf.ivlen;
+		skb->h.raw = skb_pull(skb, sizeof(struct ip_esp_hdr) + esp->conf.ivlen);
+		skb->nh.raw += sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
 		memcpy(skb->nh.raw, workbuf, iph->ihl*4);
 		skb->nh.iph->tot_len = htons(skb->len);
 	}
@@ -365,7 +365,7 @@
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
 	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
-	x->props.header_len = 8 + esp->conf.ivlen;
+	x->props.header_len = sizeof(struct ip_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct iphdr);
 	x->data = esp;
Index: net/ipv6/ah6.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/ah6.c,v
retrieving revision 1.1.1.5
retrieving revision 1.1.1.5.2.1
diff -u -r1.1.1.5 -r1.1.1.5.2.1
--- net/ipv6/ah6.c	2 Apr 2003 07:25:59 -0000	1.1.1.5
+++ net/ipv6/ah6.c	3 Apr 2003 01:40:12 -0000	1.1.1.5.2.1
@@ -36,8 +36,6 @@
 #include <net/xfrm.h>
 #include <asm/scatterlist.h>
 
-#define AH_HLEN_NOICV	12
-
 /* XXX no ipv6 ah specific */
 #define NIP6(addr) \
 	ntohs((addr).s6_addr16[0]),\
@@ -110,8 +108,8 @@
 	skb->nh.ipv6h->hop_limit    = 0;
 
 	ahp = x->data;
-	ah->hdrlen  = (XFRM_ALIGN8(ahp->icv_trunc_len +
-		AH_HLEN_NOICV) >> 2) - 2;
+	ah->hdrlen  = (XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + 
+				   ahp->icv_trunc_len) >> 2) - 2;
 
 	ah->reserved = 0;
 	ah->spi = x->id.spi;
@@ -165,8 +163,8 @@
 	ahp = x->data;
         ah_hlen = (ah->hdrlen + 2) << 2;
 
-        if (ah_hlen != XFRM_ALIGN8(ahp->icv_full_len + AH_HLEN_NOICV) &&
-            ah_hlen != XFRM_ALIGN8(ahp->icv_trunc_len + AH_HLEN_NOICV))
+        if (ah_hlen != XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_full_len) &&
+            ah_hlen != XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_trunc_len))
                 goto out;
 
 	if (!pskb_may_pull(skb, ah_hlen))
@@ -285,7 +283,7 @@
 	if (!ahp->work_icv)
 		goto error;
 	
-	x->props.header_len = XFRM_ALIGN8(ahp->icv_trunc_len + AH_HLEN_NOICV);
+	x->props.header_len = XFRM_ALIGN8(sizeof(struct ipv6_auth_hdr) + ahp->icv_trunc_len);
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = ahp;
Index: net/ipv6/esp6.c
===================================================================
RCS file: /cvsroot/usagi/usagi-backport/linux25/net/ipv6/esp6.c,v
retrieving revision 1.1.1.5
retrieving revision 1.1.1.5.2.1
diff -u -r1.1.1.5 -r1.1.1.5.2.1
--- net/ipv6/esp6.c	2 Apr 2003 07:25:59 -0000	1.1.1.5
+++ net/ipv6/esp6.c	2 Apr 2003 10:17:41 -0000	1.1.1.5.2.1
@@ -232,7 +232,7 @@
 
 	if (esp->auth.icv_full_len) {
 		esp->auth.icv(esp, skb, (u8*)esph-skb->data,
-			8+esp->conf.ivlen+clen, trailer->tail);
+			sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen+clen, trailer->tail);
 		pskb_put(skb, trailer, alen);
 	}
 
@@ -262,7 +262,7 @@
 	struct sk_buff *trailer;
 	int blksize = crypto_tfm_alg_blocksize(esp->conf.tfm);
 	int alen = esp->auth.icv_trunc_len;
-	int elen = skb->len - 8 - esp->conf.ivlen - alen;
+	int elen = skb->len - sizeof(struct ipv6_esp_hdr) - esp->conf.ivlen - alen;
 
 	int hdr_len = skb->h.raw - skb->nh.raw;
 	int nfrags;
@@ -319,7 +319,7 @@
 			if (!sg)
 				goto out;
 		}
-		skb_to_sgvec(skb, sg, 8+esp->conf.ivlen, elen);
+		skb_to_sgvec(skb, sg, sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen, elen);
 		crypto_cipher_decrypt(esp->conf.tfm, sg, sg, elen);
 		if (unlikely(sg != sgbuf))
 			kfree(sg);
@@ -338,8 +338,8 @@
 
 		ret_nexthdr = ((struct ipv6hdr*)tmp_hdr)->nexthdr = nexthdr[1];
 		pskb_trim(skb, skb->len - alen - padlen - 2);
-		skb->h.raw = skb_pull(skb, 8 + esp->conf.ivlen);
-		skb->nh.raw += 8 + esp->conf.ivlen;
+		skb->h.raw = skb_pull(skb, sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen);
+		skb->nh.raw += sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
 		memcpy(skb->nh.raw, tmp_hdr, hdr_len);
 	}
 	kfree(tmp_hdr);
@@ -466,7 +466,7 @@
 		get_random_bytes(esp->conf.ivec, esp->conf.ivlen);
 	}
 	crypto_cipher_setkey(esp->conf.tfm, esp->conf.key, esp->conf.key_len);
-	x->props.header_len = 8 + esp->conf.ivlen;
+	x->props.header_len = sizeof(struct ipv6_esp_hdr) + esp->conf.ivlen;
 	if (x->props.mode)
 		x->props.header_len += sizeof(struct ipv6hdr);
 	x->data = esp;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
