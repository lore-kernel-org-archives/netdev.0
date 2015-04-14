From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/5] cxgb4: Add comment for calculate tx flits and sge length code
Date: Wed, 15 Apr 2015 02:02:33 +0530
Message-ID: <1429043554-8744-5-git-send-email-hariprasad@chelsio.com>
References: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:12373 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932590AbbDNPUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Apr 2015 11:20:46 -0400
In-Reply-To: <1429043554-8744-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add comment for tx filt and sge length calucaltion code, also remove
a hardcoded value

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 36 +++++++++++++++++++++++++++++++-
 1 file changed, 35 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 6af4bab..1a31e40 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -730,6 +730,22 @@ static void *alloc_ring(struct device *dev, size_t nelem, size_t elem_size,
  */
 static inline unsigned int sgl_len(unsigned int n)
 {
+	/* A Direct Scatter Gather List uses 32-bit lengths and 64-bit PCI DMA
+	 * addresses.  The DSGL Work Request starts off with a 32-bit DSGL
+	 * ULPTX header, then Length0, then Address0, then, for 1 <= i <= N,
+	 * repeated sequences of { Length[i], Length[i+1], Address[i],
+	 * Address[i+1] } (this ensures that all addresses are on 64-bit
+	 * boundaries).  If N is even, then Length[N+1] should be set to 0 and
+	 * Address[N+1] is omitted.
+	 *
+	 * The following calculation incorporates all of the above.  It's
+	 * somewhat hard to follow but, briefly: the "+2" accounts for the
+	 * first two flits which include the DSGL header, Length0 and
+	 * Address0; the "(3*(n-1))/2" covers the main body of list entries (3
+	 * flits for every pair of the remaining N) +1 if (n-1) is odd; and
+	 * finally the "+((n-1)&1)" adds the one remaining flit needed if
+	 * (n-1) is odd ...
+	 */
 	n--;
 	return (3 * n) / 2 + (n & 1) + 2;
 }
@@ -777,12 +793,30 @@ static inline unsigned int calc_tx_flits(const struct sk_buff *skb)
 	unsigned int flits;
 	int hdrlen = is_eth_imm(skb);
 
+	/* If the skb is small enough, we can pump it out as a work request
+	 * with only immediate data.  In that case we just have to have the
+	 * TX Packet header plus the skb data in the Work Request.
+	 */
+
 	if (hdrlen)
 		return DIV_ROUND_UP(skb->len + hdrlen, sizeof(__be64));
 
+	/* Otherwise, we're going to have to construct a Scatter gather list
+	 * of the skb body and fragments.  We also include the flits necessary
+	 * for the TX Packet Work Request and CPL.  We always have a firmware
+	 * Write Header (incorporated as part of the cpl_tx_pkt_lso and
+	 * cpl_tx_pkt structures), followed by either a TX Packet Write CPL
+	 * message or, if we're doing a Large Send Offload, an LSO CPL message
+	 * with an embedded TX Packet Write CPL message.
+	 */
 	flits = sgl_len(skb_shinfo(skb)->nr_frags + 1) + 4;
 	if (skb_shinfo(skb)->gso_size)
-		flits += 2;
+		flits += (sizeof(struct fw_eth_tx_pkt_wr) +
+			  sizeof(struct cpl_tx_pkt_lso_core) +
+			  sizeof(struct cpl_tx_pkt_core)) / sizeof(__be64);
+	else
+		flits += (sizeof(struct fw_eth_tx_pkt_wr) +
+			  sizeof(struct cpl_tx_pkt_core)) / sizeof(__be64);
 	return flits;
 }
 
-- 
2.3.4
