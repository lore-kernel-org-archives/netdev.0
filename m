From: latten@austin.ibm.com
Subject: PATCH: IPSec not using padding when Null Encryption
Date: Thu, 27 Feb 2003 15:29:19 -0600
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200302272129.h1RLTJW28434@faith.austin.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com, kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
   netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

When using the Null Encryption algorithm, the ESP packet is
not on a 4-byte boundary. That is, the ciphertext, pad-length and
next-header fields are not right aligned on a 4-byte boundary and
no padding is used to ensure it.

RFC 2406, section 2.4 states irrespective of encryption algorithm
requirements,  padding may be required to ensure that
resulting ciphertext terminates on a 4-byte boundary. Specifically,
the Pad Length and Next Header fields must be right aligned within
a 4-byte word to ensure that the Authentication Data field (if present)
is aligned on a 4-byte boundary.

Ok, anyway, this fix just pretty much makes sure that
when Null Encryption or any algorithm with a blocksize less
than 4 is used, that the ciphertext, any padding, and next-header
and pad-length fields terminate on a 4-byte boundary.
I have tested it. Please let me know if all is well. 

Thanks,
Joy
 
--- esp.c.orig	2003-02-20 16:07:59.000000000 -0600
+++ esp.c	2003-02-27 10:30:25.000000000 -0600
@@ -360,7 +360,7 @@
 	esp = x->data;
 	alen = esp->auth.icv_trunc_len;
 	tfm = esp->conf.tfm;
-	blksize = crypto_tfm_alg_blocksize(tfm);
+	blksize = (crypto_tfm_alg_blocksize(tfm) + 3) & ~3;
 	clen = (clen + 2 + blksize-1)&~(blksize-1);
 	if (esp->conf.padlen)
 		clen = (clen + esp->conf.padlen-1)&~(esp->conf.padlen-1);
