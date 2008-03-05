From: Joy Latten <latten@austin.ibm.com>
Subject: [PATCH]kernel crashes when using aes-xcbc-mac with IPsec
Date: Wed, 5 Mar 2008 08:51:20 -0600
Message-ID: <200803051451.m25EpKv8016389@faith.austin.ibm.com>
Cc: davem@davemloft.net, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org
To: linux-crypto@vger.kernel
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:55695 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752198AbYCEOyV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2008 09:54:21 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m25EsKU8015034
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 09:54:20 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m25EsKas245822
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 09:54:20 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m25EsJPo009613
	for <netdev@vger.kernel.org>; Wed, 5 Mar 2008 09:54:20 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When using aes-xcbc-mac for authentication in IPsec, 
the kernel crashes. It seems this algorithm doesn't 
account for the space IPsec may make in scatterlist for authtag.
Thus when crypto_xcbc_digest_update2() gets called,
nbytes may be less than sg[i].length. 
Since nbytes is an unsigned number, it wraps
at the end of the loop allowing us to go back 
into loop and causing crash in memcpy.

I used update function in digest.c to model this fix.
Please let me know if it looks ok.

regards,
Joy 

Signed-off-by: Joy Latten <latten@austin.ibm.com>

diff -urpN net-2.6.26/crypto/xcbc.c net-2.6.26.patch/crypto/xcbc.c
--- net-2.6.26/crypto/xcbc.c	2008-03-04 16:11:32.000000000 -0600
+++ net-2.6.26.patch/crypto/xcbc.c	2008-03-04 18:28:51.000000000 -0600
@@ -124,6 +124,11 @@ static int crypto_xcbc_digest_update2(st
 		unsigned int offset = sg[i].offset;
 		unsigned int slen = sg[i].length;
 
+		if (unlikely(slen > nbytes))
+			slen = nbytes;
+
+		nbytes -= slen;
+
 		while (slen > 0) {
 			unsigned int len = min(slen, ((unsigned int)(PAGE_SIZE)) - offset);
 			char *p = crypto_kmap(pg, 0) + offset;
@@ -177,7 +182,6 @@ static int crypto_xcbc_digest_update2(st
 			offset = 0;
 			pg++;
 		}
-		nbytes-=sg[i].length;
 		i++;
 	} while (nbytes>0);
 
