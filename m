From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH next 2/2] sctp: improve how SSN, TSN and ASCONF serial are compared
Date: Tue, 20 Sep 2016 18:19:14 -0300
Message-ID: <d0edc340057c3f9fa84b622c26c2d42a8309245e.1474405559.git.marcelo.leitner@gmail.com>
References: <cover.1474405559.git.marcelo.leitner@gmail.com>
Cc: linux-sctp@vger.kernel.org, Neil Horman <nhorman@tuxdriver.com>,
        Vlad Yasevich <vyasevich@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60600 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753632AbcITVTZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Sep 2016 17:19:25 -0400
In-Reply-To: <cover.1474405559.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Make it similar to time_before() macros:
- easier to understand
- make use of typecheck() to avoid working on unexpected variable types
  (made the issue on previous patch visible)
- for _[lg]te versions, slighly faster, as the compiler used to generate
  a sequence of cmp/je/cmp/js instructions and now it's sub/test/jle
  (for _lte):

Before, for sctp_outq_sack:
	if (primary->cacc.changeover_active) {
    1f01:	80 b9 84 02 00 00 00 	cmpb   $0x0,0x284(%rcx)
    1f08:	74 6e                	je     1f78 <sctp_outq_sack+0xe8>
		u8 clear_cycling = 0;

		if (TSN_lte(primary->cacc.next_tsn_at_change, sack_ctsn)) {
    1f0a:	8b 81 80 02 00 00    	mov    0x280(%rcx),%eax
	return ((s) - (t)) & TSN_SIGN_BIT;
}

static inline int TSN_lte(__u32 s, __u32 t)
{
	return ((s) == (t)) || (((s) - (t)) & TSN_SIGN_BIT);
    1f10:	8b 7d bc             	mov    -0x44(%rbp),%edi
    1f13:	39 c7                	cmp    %eax,%edi
    1f15:	74 25                	je     1f3c <sctp_outq_sack+0xac>
    1f17:	39 f8                	cmp    %edi,%eax
    1f19:	78 21                	js     1f3c <sctp_outq_sack+0xac>
			primary->cacc.changeover_active = 0;

After:
	if (primary->cacc.changeover_active) {
    1ee7:	80 b9 84 02 00 00 00 	cmpb   $0x0,0x284(%rcx)
    1eee:	74 73                	je     1f63 <sctp_outq_sack+0xf3>
		u8 clear_cycling = 0;

		if (TSN_lte(primary->cacc.next_tsn_at_change, sack_ctsn)) {
    1ef0:	8b 81 80 02 00 00    	mov    0x280(%rcx),%eax
    1ef6:	2b 45 b4             	sub    -0x4c(%rbp),%eax
    1ef9:	85 c0                	test   %eax,%eax
    1efb:	7e 26                	jle    1f23 <sctp_outq_sack+0xb3>
			primary->cacc.changeover_active = 0;

*_lt() generated pretty much the same code.
Tested with gcc (GCC) 6.1.1 20160621.

This patch also removes SSN_lte as it is not used and cleanups some
comments.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/sctp/sm.h | 94 ++++++++++-----------------------------------------
 1 file changed, 18 insertions(+), 76 deletions(-)

diff --git a/include/net/sctp/sm.h b/include/net/sctp/sm.h
index bafe2a0ab9085f24e17038516c55c00cfddd02f4..ca6c971dd74aede829d4512ddf71006520c78f47 100644
--- a/include/net/sctp/sm.h
+++ b/include/net/sctp/sm.h
@@ -307,85 +307,27 @@ static inline __u16 sctp_data_size(struct sctp_chunk *chunk)
 }
 
 /* Compare two TSNs */
+#define TSN_lt(a,b)	\
+	(typecheck(__u32, a) && \
+	 typecheck(__u32, b) && \
+	 ((__s32)((a) - (b)) < 0))
 
-/* RFC 1982 - Serial Number Arithmetic
- *
- * 2. Comparison
- *  Then, s1 is said to be equal to s2 if and only if i1 is equal to i2,
- *  in all other cases, s1 is not equal to s2.
- *
- * s1 is said to be less than s2 if, and only if, s1 is not equal to s2,
- * and
- *
- *      (i1 < i2 and i2 - i1 < 2^(SERIAL_BITS - 1)) or
- *      (i1 > i2 and i1 - i2 > 2^(SERIAL_BITS - 1))
- *
- * s1 is said to be greater than s2 if, and only if, s1 is not equal to
- * s2, and
- *
- *      (i1 < i2 and i2 - i1 > 2^(SERIAL_BITS - 1)) or
- *      (i1 > i2 and i1 - i2 < 2^(SERIAL_BITS - 1))
- */
-
-/*
- * RFC 2960
- *  1.6 Serial Number Arithmetic
- *
- * Comparisons and arithmetic on TSNs in this document SHOULD use Serial
- * Number Arithmetic as defined in [RFC1982] where SERIAL_BITS = 32.
- */
-
-enum {
-	TSN_SIGN_BIT = (1<<31)
-};
-
-static inline int TSN_lt(__u32 s, __u32 t)
-{
-	return ((s) - (t)) & TSN_SIGN_BIT;
-}
-
-static inline int TSN_lte(__u32 s, __u32 t)
-{
-	return ((s) == (t)) || (((s) - (t)) & TSN_SIGN_BIT);
-}
+#define TSN_lte(a,b)	\
+	(typecheck(__u32, a) && \
+	 typecheck(__u32, b) && \
+	 ((__s32)((a) - (b)) <= 0))
 
 /* Compare two SSNs */
-
-/*
- * RFC 2960
- *  1.6 Serial Number Arithmetic
- *
- * Comparisons and arithmetic on Stream Sequence Numbers in this document
- * SHOULD use Serial Number Arithmetic as defined in [RFC1982] where
- * SERIAL_BITS = 16.
- */
-enum {
-	SSN_SIGN_BIT = (1<<15)
-};
-
-static inline int SSN_lt(__u16 s, __u16 t)
-{
-	return ((s) - (t)) & SSN_SIGN_BIT;
-}
-
-static inline int SSN_lte(__u16 s, __u16 t)
-{
-	return ((s) == (t)) || (((s) - (t)) & SSN_SIGN_BIT);
-}
-
-/*
- * ADDIP 3.1.1
- * The valid range of Serial Number is from 0 to 4294967295 (2**32 - 1). Serial
- * Numbers wrap back to 0 after reaching 4294967295.
- */
-enum {
-	ADDIP_SERIAL_SIGN_BIT = (1<<31)
-};
-
-static inline int ADDIP_SERIAL_gte(__u32 s, __u32 t)
-{
-	return ((s) == (t)) || (((t) - (s)) & ADDIP_SERIAL_SIGN_BIT);
-}
+#define SSN_lt(a,b)		\
+	(typecheck(__u16, a) && \
+	 typecheck(__u16, b) && \
+	 ((__s16)((a) - (b)) < 0))
+
+/* ADDIP 3.1.1 */
+#define ADDIP_SERIAL_gte(a,b)	\
+	(typecheck(__u32, a) && \
+	 typecheck(__u32, b) && \
+	 ((__s32)((b) - (a)) <= 0))
 
 /* Check VTAG of the packet matches the sender's own tag. */
 static inline int
-- 
2.7.4
