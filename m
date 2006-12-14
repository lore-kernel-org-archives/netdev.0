From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: [PATCH][RFC] tcp: fix ambiguity in the `before' relation
Date: Thu, 14 Dec 2006 15:07:06 +0000
Message-ID: <200612141507.06888@strip-the-willow>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:53117 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S932801AbWLNPWU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Dec 2006 10:22:20 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While looking at DCCP sequence numbers, I stumbled over a problem with
the following definition of before in tcp.h:

static inline int before(__u32 seq1, __u32 seq2)
{
        return (__s32)(seq1-seq2) < 0;
}

Problem: This definition suffers from an an ambiguity, i.e. always
                   
           before(a, (a + 2^31) % 2^32)) = 1
           before((a + 2^31) % 2^32), a) = 1
 
         In text: when the difference between a and b amounts to 2^31,
         a is always considered `before' b, the function can not decide. 
         The reason is that implicitly 0 is `before' 1 ... 2^31-1 ... 2^31
      
Solution: There is a simple fix, by defining before in such a way that 
          0 is no longer `before' 2^31, i.e. 0 `before' 1 ... 2^31-1
          By not using the middle between 0 and 2^32, before can be made 
          unambiguous. 
          This is achieved by testing whether seq2-seq1 > 0 (using signed
          32-bit arithmetic).

I attach a patch to codify this. Also the `after' relation is basically 
a redefinition of `before', it is now defined as a macro after before.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---
 tcp.h |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)


diff --git a/include/net/tcp.h b/include/net/tcp.h
index c99774f..b7d8317 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -242,14 +242,9 @@ extern int tcp_memory_pressure;
 
 static inline int before(__u32 seq1, __u32 seq2)
 {
-        return (__s32)(seq1-seq2) < 0;
+        return (__s32)(seq2-seq1) > 0;
 }
-
-static inline int after(__u32 seq1, __u32 seq2)
-{
-	return (__s32)(seq2-seq1) < 0;
-}
-
+#define after(seq2, seq1) 	before(seq1, seq2)
 
 /* is s2<=s1<=s3 ? */
 static inline int between(__u32 seq1, __u32 seq2, __u32 seq3)


