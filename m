From: Konstantin Sharlaimov <konstantin.sharlaimov@gmail.com>
Subject: [RFC] [PATCH 2.6.21.5] ppp: fix osize too small errors when decoding
 mppe
Date: Wed, 20 Jun 2007 22:37:18 +1100
Message-ID: <4679116E.9050507@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: 7bit
Cc: Sergey Vlasov <vsu@altlinux.ru>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Paul Mackerras <paulus@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.179]:16247 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751750AbXFTLhf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 07:37:35 -0400
Received: by ik-out-1112.google.com with SMTP id b32so134244ika
        for <netdev@vger.kernel.org>; Wed, 20 Jun 2007 04:37:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The mppe_decompress() function required a buffer that is 1 byte too small when
receiving a message of mru size. This fixes buffer allocation to prevent this
from occurring.

Signed-off-by: Konstantin Sharlaimov <konstantin.sharlaimov@gmail.com>
---
As Sergey Vlasov pointed out, ppp_mppe-account-for-osize-too-small-errors-in.patch
may cause buffer overflows on certain data. Here is another patch that should
eliminate the "osize too small" errors. Instead of patching mppe_decompress
itself, I have patched ppp_decompress_frame so it would allocate the required
extra byte when using mppe compression.

I didn't have a chance to check this patch carefully yet, but it seem to be
working as expected. Any comments would be greatly appreciated.

--- linux-2.6.21.3/drivers/net/ppp_generic.c.orig	2007-06-20 09:14:13.000000000
+1100
+++ linux-2.6.21.3/drivers/net/ppp_generic.c	2007-06-20 09:18:06.000000000 +1100
@@ -1711,7 +1711,18 @@ ppp_decompress_frame(struct ppp *ppp, st
 		goto err;

 	if (proto == PPP_COMP) {
-		ns = dev_alloc_skb(ppp->mru + PPP_HDRLEN);
+		int obuff_size;
+
+		switch(ppp->rcomp->compress_proto) {
+		case CI_MPPE:
+			obuff_size = ppp->mru + PPP_HDRLEN + 1;
+			break;
+		default:
+			obuff_size = ppp->mru + PPP_HDRLEN;
+			break;
+		}
+
+		ns = dev_alloc_skb(obuff_size);
 		if (ns == 0) {
 			printk(KERN_ERR "ppp_decompress_frame: no memory\n");
 			goto err;
