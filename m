From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: [PATCH net-next] bnx2x: Fix sparse warnings
Date: Thu, 28 Aug 2014 08:07:32 +0300
Message-ID: <1409202452-372-1-git-send-email-Yuval.Mintz@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016ce01.pphosted.com ([67.231.156.153]:33826 "EHLO
	mx0b-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755437AbaH1FHw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 01:07:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes a sprase warning introduced recently by commit
eeed018cbfa30 ("bnx2x: Add timestamping and PTP hardware clock support"),
as well as another unrelated sparse endian issue.

Signed-off-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
Signed-off-by: Ariel Elior <Ariel.Elior@qlogic.com>
---
Hi Dave,

Please consider applying this to `net-next'.

Thanks,
Yuval Mintz
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |  2 +-
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c  | 14 +++++++-------
 2 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index a54ac45..06d6d3c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -1065,7 +1065,7 @@ reuse_rx:
 		skb_record_rx_queue(skb, fp->rx_queue);
 
 		/* Check if this packet was timestamped */
-		if (unlikely(le16_to_cpu(cqe->fast_path_cqe.type_error_flags) &
+		if (unlikely(cqe->fast_path_cqe.type_error_flags &
 			     (1 << ETH_FAST_PATH_RX_CQE_PTP_PKT_SHIFT)))
 			bnx2x_set_rx_ts(bp, skb);
 
diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
index 38acecd..19d0c11 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_sp.c
@@ -4063,6 +4063,13 @@ static int bnx2x_setup_rss(struct bnx2x *bp,
 	if (test_bit(BNX2X_RSS_GRE_INNER_HDRS, &p->rss_flags))
 		caps |= ETH_RSS_UPDATE_RAMROD_DATA_GRE_INNER_HDRS_CAPABILITY;
 
+	/* RSS keys */
+	if (test_bit(BNX2X_RSS_SET_SRCH, &p->rss_flags)) {
+		memcpy(&data->rss_key[0], &p->rss_key[0],
+		       sizeof(data->rss_key));
+		caps |= ETH_RSS_UPDATE_RAMROD_DATA_UPDATE_RSS_KEY;
+	}
+
 	data->capabilities = cpu_to_le16(caps);
 
 	/* Hashing mask */
@@ -4084,13 +4091,6 @@ static int bnx2x_setup_rss(struct bnx2x *bp,
 	if (netif_msg_ifup(bp))
 		bnx2x_debug_print_ind_table(bp, p);
 
-	/* RSS keys */
-	if (test_bit(BNX2X_RSS_SET_SRCH, &p->rss_flags)) {
-		memcpy(&data->rss_key[0], &p->rss_key[0],
-		       sizeof(data->rss_key));
-		data->capabilities |= ETH_RSS_UPDATE_RAMROD_DATA_UPDATE_RSS_KEY;
-	}
-
 	/* No need for an explicit memory barrier here as long as we
 	 * ensure the ordering of writing to the SPQ element
 	 * and updating of the SPQ producer which involves a memory
-- 
1.8.3.1
