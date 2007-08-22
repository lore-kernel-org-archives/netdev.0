From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 3/11 RESEND] cxgb3 - use immediate data for offload Tx
Date: Tue, 21 Aug 2007 20:49:15 -0700
Message-ID: <20070822034915.9296.97240.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:22925 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755283AbXHVDtS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 23:49:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Send small TX_DATA work requests as immediate data even when
there are fragments. this avoids doing multiple DMAs for 
small fragmented packets. 
The driver already implements this optimization for small
contiguous packets.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/sge.c |   17 +++++++++++------
 1 files changed, 11 insertions(+), 6 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index 9213cda..dca2716 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -1182,8 +1182,8 @@ int t3_eth_xmit(struct sk_buff *skb, struct net_device *dev)
  *
  *	Writes a packet as immediate data into a Tx descriptor.  The packet
  *	contains a work request at its beginning.  We must write the packet
- *	carefully so the SGE doesn't read accidentally before it's written in
- *	its entirety.
+ *	carefully so the SGE doesn't read it accidentally before it's written
+ *	in its entirety.
  */
 static inline void write_imm(struct tx_desc *d, struct sk_buff *skb,
 			     unsigned int len, unsigned int gen)
@@ -1191,7 +1191,11 @@ static inline void write_imm(struct tx_desc *d, struct sk_buff *skb,
 	struct work_request_hdr *from = (struct work_request_hdr *)skb->data;
 	struct work_request_hdr *to = (struct work_request_hdr *)d;
 
-	memcpy(&to[1], &from[1], len - sizeof(*from));
+	if (likely(!skb->data_len))
+		memcpy(&to[1], &from[1], len - sizeof(*from));
+	else
+		skb_copy_bits(skb, sizeof(*from), &to[1], len - sizeof(*from));
+
 	to->wr_hi = from->wr_hi | htonl(F_WR_SOP | F_WR_EOP |
 					V_WR_BCNTLFLT(len & 7));
 	wmb();
@@ -1261,7 +1265,7 @@ static inline void reclaim_completed_tx_imm(struct sge_txq *q)
 
 static inline int immediate(const struct sk_buff *skb)
 {
-	return skb->len <= WR_LEN && !skb->data_len;
+	return skb->len <= WR_LEN;
 }
 
 /**
@@ -1467,12 +1471,13 @@ static void write_ofld_wr(struct adapter *adap, struct sk_buff *skb,
  */
 static inline unsigned int calc_tx_descs_ofld(const struct sk_buff *skb)
 {
-	unsigned int flits, cnt = skb_shinfo(skb)->nr_frags;
+	unsigned int flits, cnt;
 
-	if (skb->len <= WR_LEN && cnt == 0)
+	if (skb->len <= WR_LEN)
 		return 1;	/* packet fits as immediate data */
 
 	flits = skb_transport_offset(skb) / 8;	/* headers */
+	cnt = skb_shinfo(skb)->nr_frags;
 	if (skb->tail != skb->transport_header)
 		cnt++;
 	return flits_to_desc(flits + sgl_len(cnt));
