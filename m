From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH] jhash: Update jhash_[321]words functions to use
 correct initval
Date: Tue, 31 Mar 2015 14:19:10 -0700
Message-ID: <20150331211826.1133.19645.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51571 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753627AbbCaVTL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Mar 2015 17:19:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Looking over the implementation for jhash2 and comparing it to jhash_3words
I realized that the two hashes were in fact very different.  Doing a bit of
digging led me to "The new jhash implementation" in which lookup2 was
supposed to have been replaced with lookup3.

In reviewing the patch I noticed that jhash2 had originally initialized a
and b to JHASH_GOLDENRATIO and c to initval, but after the patch a, b, and
c were initialized to initval + (length << 2) + JHASH_INITVAL.  However the
changes in jhash_3words simply replaced the initialization of a and b with
JHASH_INITVAL.

This change corrects what I believe was an oversight so that a, b, and c in
jhash_3words all have the same value added consisting of initval + (length
<< 2) + JHASH_INITVAL so that jhash2 and jhash_3words will now produce the
same hash result given the same inputs.

Fixes: 60d509c823cca ("The new jhash implementation")
Signed-off-by: Alexander Duyck <alexander.h.duyck@redhat.com>
---
 include/linux/jhash.h |   17 +++++++++++------
 1 file changed, 11 insertions(+), 6 deletions(-)

diff --git a/include/linux/jhash.h b/include/linux/jhash.h
index 47cb09edec1a..348c6f47e4cc 100644
--- a/include/linux/jhash.h
+++ b/include/linux/jhash.h
@@ -145,11 +145,11 @@ static inline u32 jhash2(const u32 *k, u32 length, u32 initval)
 }
 
 
-/* jhash_3words - hash exactly 3, 2 or 1 word(s) */
-static inline u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
+/* __jhash_nwords - hash exactly 3, 2 or 1 word(s) */
+static inline u32 __jhash_nwords(u32 a, u32 b, u32 c, u32 initval)
 {
-	a += JHASH_INITVAL;
-	b += JHASH_INITVAL;
+	a += initval;
+	b += initval;
 	c += initval;
 
 	__jhash_final(a, b, c);
@@ -157,14 +157,19 @@ static inline u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
 	return c;
 }
 
+static inline u32 jhash_3words(u32 a, u32 b, u32 c, u32 initval)
+{
+	return __jhash_nwords(a, b, c, initval + JHASH_INITVAL + (3 << 2));
+}
+
 static inline u32 jhash_2words(u32 a, u32 b, u32 initval)
 {
-	return jhash_3words(a, b, 0, initval);
+	return __jhash_nwords(a, b, 0, initval + JHASH_INITVAL + (2 << 2));
 }
 
 static inline u32 jhash_1word(u32 a, u32 initval)
 {
-	return jhash_3words(a, 0, 0, initval);
+	return __jhash_nwords(a, 0, 0, initval + JHASH_INITVAL + (1 << 2));
 }
 
 #endif /* _LINUX_JHASH_H */
