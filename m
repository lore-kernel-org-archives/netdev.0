From: Gerrit Renker <acme@ghostprotocols.net>
Subject: [PATCH 11/31] [DCCP]: Make dccp_delta_seqno return signed numbers
Date: Tue, 20 Mar 2007 20:06:55 -0300
Message-ID: <20070320230655.GZ17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:34121 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbXCTXHL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:07:11 -0400
Received: by wx-out-0506.google.com with SMTP id h31so64649wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:07:11 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Problem:
--------
 Using dccp_delta_seqno(a, b) produces unusable results when -- by accident
 or coincidence -- sequence number b precedes a.  If e.g. a and b are merely
 reordered and have a distance 1, their delta_seqno is 2^48-1, which would
 indicate a loss of 2^48-2 packets.

Fix:
----
 The fix is by using signed 48-bit arithmetic for dccp_delta_seqno, so that
 dccp_delta_seqno(a, b) returns:
  * > 0 if a is `before' b                OR
  *   0 if a == b                         OR
  * < 0 and > -2^47 if b is `before' a    OR
  * -2^47           if neither a `before' b  nor  b `before' a

 This implements http://www.mail-archive.com/dccp@vger.kernel.org/msg01153.html

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/dccp.h |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index 82c618f..e6c95e9 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -113,9 +113,12 @@ static inline void dccp_inc_seqno(u64 *seqno)
 	*seqno = ADD48(*seqno, 1);
 }
 
-static inline u64 dccp_delta_seqno(u64 seqno1, u64 seqno2)
+/* signed mod-2^48 distance: pos. if seqno1 < seqno2, neg. if seqno1 > seqno2 */
+static inline s64 dccp_delta_seqno(const u64 seqno1, const u64 seqno2)
 {
-	return ((seqno2 << 16) - (seqno1 << 16)) >> 16;
+	u64 delta = SUB48(seqno2, seqno1);
+
+	return TO_SIGNED48(delta);
 }
 
 /* is seq1 < seq2 ? */
-- 
1.5.0.3

