From: Nicolas Bareil <nico@chdir.org>
Subject: [BUG] before() integer overflow
Date: Tue, 05 Aug 2008 19:19:18 +0200
Message-ID: <87y73bqt0p.fsf@chdir.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from main.gmane.org ([80.91.229.2]:60478 "EHLO ciao.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759931AbYHERUG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Aug 2008 13:20:06 -0400
Received: from root by ciao.gmane.org with local (Exim 4.43)
	id 1KQQCY-0002bi-Tl
	for netdev@vger.kernel.org; Tue, 05 Aug 2008 17:20:03 +0000
Received: from moog.chdir.org ([88.191.42.160])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 17:20:02 +0000
Received: from nico by moog.chdir.org with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2008 17:20:02 +0000
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hello!


In include/net/tcp.h, the before() function is defined like this :

 241 /*
 242  * The next routines deal with comparing 32 bit unsigned ints
 243  * and worry about wraparound (automatic with unsigned arithmetic).
 244  */
 245 
 246 static inline int before(__u32 seq1, __u32 seq2)
 247 {
 248         return (__s32)(seq1-seq2) < 0;
 249 }
 250 #define after(seq2, seq1)   before(seq1, seq2)


If seq1 = 0xffffff and seq2 = 0 (so seq1 > seq2), the difference is
equal to 0xffffff, or -1 as a 32 bits signed number.

 => before() will return true instead of false.

It's not really a big deal[1], but I didn't understand why my invalid
packets were accepted when playing with Netfilter code.

If I'm not wrong, a trivial patch could be :

diff --git a/include/net/tcp.h b/include/net/tcp.h
index 8983386..2b01227 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -248,7 +248,7 @@ extern int tcp_memory_pressure;
 
 static inline int before(__u32 seq1, __u32 seq2)
 {
-        return (__s32)(seq1-seq2) < 0;
+        return ((__u64)seq1-seq2) < 0;
 }
 #define after(seq2, seq1)      before(seq1, seq2)

Thanks


Footnotes: 
[1]  The TCP sequence number space is divided by two, now on 31 bits,
     phear! :) 
-- 
Nicolas Bareil                                  http://chdir.org/~nico/
OpenPGP=0xAE4F7057 Fingerprint=34DB22091049FB2F33E6B71580F314DAAE4F7057

