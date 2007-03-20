From: Gerrit Renker <acme@ghostprotocols.net>
Subject: [PATCH 12/31] [DCCP]: Make `before' relation unambiguous
Date: Tue, 20 Mar 2007 20:07:11 -0300
Message-ID: <20070320230711.GA17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:34121 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752126AbXCTXHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:07:16 -0400
Received: by wx-out-0506.google.com with SMTP id h31so64649wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:07:16 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Problem:
--------
 before48(a, b) returns the same as before48(b, a) for all a, b which
 are 2^47 apart (modulo-2^48). The reason is that the difference a-b is used
 and `true' is returned whenever 2^47 <= a-b <= 2^48-1. This has the
 disadvantage that a positive difference a-b = 2^47 can not be distinguished
 from a negative difference b-a = 2^47. As a result, an ambiguity arises in
 2^47 cases.

Fix:
----
 The fix is the same as the one suggested for TCP: define a `before' b
 whenever 1 <= b-a <= 2^47-1 (positive signed 48-bit numbers). As a result,
 the ambiguity disappears. (Note: we could have used dccp_delta_seqno, but
 Arnaldo's concept of using shift and subtraction requires fewer operations).

The patch further defines after48 as a macro, since it is in actual fact just
before48 with the parameters swapped (this mirrors the TCP solution).

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/dccp.h |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index e6c95e9..287a040 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -124,14 +124,11 @@ static inline s64 dccp_delta_seqno(const u64 seqno1, const u64 seqno2)
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
-	return (s64)((seq1 << 16) - (seq2 << 16)) < 0;
+	return (s64)((seq2 << 16) - (seq1 << 16)) > 0;
 }
 
 /* is seq1 > seq2 ? */
-static inline int after48(const u64 seq1, const u64 seq2)
-{
-	return (s64)((seq2 << 16) - (seq1 << 16)) < 0;
-}
+#define after48(seq1, seq2)	before48(seq2, seq1)
 
 /* is seq2 <= seq1 <= seq3 ? */
 static inline int between48(const u64 seq1, const u64 seq2, const u64 seq3)
-- 
1.5.0.3

