From: Gerrit Renker <acme@ghostprotocols.net>
Subject: [PATCH 10/31] [DCCP]: 48-bit sequence number arithmetic
Date: Tue, 20 Mar 2007 20:06:19 -0300
Message-ID: <20070320230619.GX17811@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.230]:34121 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752082AbXCTXGY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Mar 2007 19:06:24 -0400
Received: by wx-out-0506.google.com with SMTP id h31so64649wxd
        for <netdev@vger.kernel.org>; Tue, 20 Mar 2007 16:06:23 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch
 * organizes the sequence arithmetic functions into one corner of dccp.h
 * performs a small modification of dccp_set_seqno to make it more widely reusable
   (now it is safe to use any number, since it performs modulo-2^48 assignment)
 * adds functions and generic macros for 48-bit sequence arithmetic:
 	--48 bit complement
 	--modulo-48 addition and modulo-48 subtraction
	--dccp_inc_seqno now a special case of add48
Constants renamed following a suggestion by Arnaldo.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Acked-by: Ian McDonald <ian.mcdonald@jandi.co.nz>
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 net/dccp/ackvec.c |    2 +-
 net/dccp/dccp.h   |   47 +++++++++++++++++++++++++++--------------------
 2 files changed, 28 insertions(+), 21 deletions(-)

diff --git a/net/dccp/ackvec.c b/net/dccp/ackvec.c
index a086c63..01030f3 100644
--- a/net/dccp/ackvec.c
+++ b/net/dccp/ackvec.c
@@ -157,7 +157,7 @@ struct dccp_ackvec *dccp_ackvec_alloc(const gfp_t priority)
 
 	if (av != NULL) {
 		av->dccpav_buf_head	= DCCP_MAX_ACKVEC_LEN - 1;
-		av->dccpav_buf_ackno	= DCCP_MAX_SEQNO + 1;
+		av->dccpav_buf_ackno	= UINT48_MAX + 1;
 		av->dccpav_buf_nonce = av->dccpav_buf_nonce = 0;
 		av->dccpav_time.tv_sec	= 0;
 		av->dccpav_time.tv_usec	= 0;
diff --git a/net/dccp/dccp.h b/net/dccp/dccp.h
index a0e7cd1..82c618f 100644
--- a/net/dccp/dccp.h
+++ b/net/dccp/dccp.h
@@ -92,6 +92,32 @@ extern int  sysctl_dccp_feat_send_ack_vector;
 extern int  sysctl_dccp_feat_send_ndp_count;
 extern int  sysctl_dccp_tx_qlen;
 
+/*
+ *	48-bit sequence number arithmetic (signed and unsigned)
+ */
+#define INT48_MIN	  0x800000000000LL		/* 2^47	    */
+#define UINT48_MAX	  0xFFFFFFFFFFFFLL		/* 2^48 - 1 */
+#define COMPLEMENT48(x)	 (0x1000000000000LL - (x))	/* 2^48 - x */
+#define TO_SIGNED48(x)	 (((x) < INT48_MIN)? (x) : -COMPLEMENT48( (x)))
+#define TO_UNSIGNED48(x) (((x) >= 0)?	     (x) :  COMPLEMENT48(-(x)))
+#define ADD48(a, b)	 (((a) + (b)) & UINT48_MAX)
+#define SUB48(a, b)	 ADD48((a), COMPLEMENT48(b))
+
+static inline void dccp_set_seqno(u64 *seqno, u64 value)
+{
+	*seqno = value & UINT48_MAX;
+}
+
+static inline void dccp_inc_seqno(u64 *seqno)
+{
+	*seqno = ADD48(*seqno, 1);
+}
+
+static inline u64 dccp_delta_seqno(u64 seqno1, u64 seqno2)
+{
+	return ((seqno2 << 16) - (seqno1 << 16)) >> 16;
+}
+
 /* is seq1 < seq2 ? */
 static inline int before48(const u64 seq1, const u64 seq2)
 {
@@ -314,26 +340,7 @@ static inline int dccp_packet_without_ack(const struct sk_buff *skb)
 	return type == DCCP_PKT_DATA || type == DCCP_PKT_REQUEST;
 }
 
-#define DCCP_MAX_SEQNO ((((u64)1) << 48) - 1)
-#define DCCP_PKT_WITHOUT_ACK_SEQ (DCCP_MAX_SEQNO << 2)
-
-static inline void dccp_set_seqno(u64 *seqno, u64 value)
-{
-	if (value > DCCP_MAX_SEQNO)
-		value -= DCCP_MAX_SEQNO + 1;
-	*seqno = value;
-}
-
-static inline u64 dccp_delta_seqno(u64 seqno1, u64 seqno2)
-{
-	return ((seqno2 << 16) - (seqno1 << 16)) >> 16;
-}
-
-static inline void dccp_inc_seqno(u64 *seqno)
-{
-	if (++*seqno > DCCP_MAX_SEQNO)
-		*seqno = 0;
-}
+#define DCCP_PKT_WITHOUT_ACK_SEQ (UINT48_MAX << 2)
 
 static inline void dccp_hdr_set_seq(struct dccp_hdr *dh, const u64 gss)
 {
-- 
1.5.0.3

