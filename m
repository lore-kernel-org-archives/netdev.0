From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@linux-ipv6.org>
Subject: [PATCH] IPV6: use macro for M-Flag and clean-up
Date: Sat, 28 Jun 2003 20:30:11 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030628.203011.05536524.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello.

Use macro IP6_MF for the M-Flag.
Clean-up for readability (commented by <aj@dungeon.inka.de>).

Patch against "[PATCH] IPV6: Fixed M-Flag in last fragment" patch.
Thanks.

--yoshfuji

Index: linux-2.5/include/net/ipv6.h
===================================================================
RCS file: /home/cvs/linux-2.5/include/net/ipv6.h,v
retrieving revision 1.20
diff -u -r1.20 ipv6.h
--- linux-2.5/include/net/ipv6.h	24 Jun 2003 21:56:18 -0000	1.20
+++ linux-2.5/include/net/ipv6.h	28 Jun 2003 09:56:10 -0000
@@ -101,6 +101,8 @@
 	__u32		identification;
 };
 
+#define	IP6_MF	0x0001
+
 #ifdef __KERNEL__
 
 #include <net/sock.h>
Index: linux-2.5/net/ipv6/reassembly.c
===================================================================
RCS file: /home/cvs/linux-2.5/net/ipv6/reassembly.c,v
retrieving revision 1.17
diff -u -r1.17 reassembly.c
--- linux-2.5/net/ipv6/reassembly.c	24 Jun 2003 21:56:18 -0000	1.17
+++ linux-2.5/net/ipv6/reassembly.c	28 Jun 2003 09:56:10 -0000
@@ -435,7 +435,7 @@
  				     csum_partial(skb->nh.raw, (u8*)(fhdr+1)-skb->nh.raw, 0));
 
 	/* Is this the final fragment? */
-	if (!(fhdr->frag_off & htons(0x0001))) {
+	if (!(fhdr->frag_off & htons(IP6_MF))) {
 		/* If we already have some bits beyond end
 		 * or have different end, the segment is corrupted.
 		 */
--- linux-2.5/net/ipv6/ip6_output.c.orig	Sat Jun 28 20:10:18 2003
+++ linux-2.5/net/ipv6/ip6_output.c	Sat Jun 28 20:16:02 2003
@@ -984,7 +984,7 @@
 		ipv6_select_ident(skb, fh);
 		fh->nexthdr = nexthdr;
 		fh->reserved = 0;
-		fh->frag_off = htons(0x0001);
+		fh->frag_off = htons(IP6_MF);
 		frag_id = fh->identification;
 
 		first_len = skb_pagelen(skb);
@@ -1004,7 +1004,9 @@
 				offset += skb->len - hlen - sizeof(struct frag_hdr);
 				fh->nexthdr = nexthdr;
 				fh->reserved = 0;
-				fh->frag_off = htons(offset | (frag->next != NULL ? 0x0001 : 0));
+				fh->frag_off = htons(offset);
+				if (frag->next != NULL)
+					fh->frag_off |= htons(IP6_MF);
 				fh->identification = frag_id;
 				frag->nh.ipv6h->payload_len = htons(frag->len - sizeof(struct ipv6hdr));
 				ip6_copy_metadata(frag, skb);
@@ -1111,7 +1113,9 @@
 			BUG();
 		left -= len;
 
-		fh->frag_off = htons( left > 0 ?  (offset | 0x0001) : offset);
+		fh->frag_off = htons(offset);
+		if (left > 0)
+			fh->frag_off |= htons(IP6_MF);
 		frag->nh.ipv6h->payload_len = htons(frag->len - sizeof(struct ipv6hdr));
 
 		ptr += len;

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
