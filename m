From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/8] cxgb4: LE-Workaround is not atomic in firmware
Date: Tue, 18 Feb 2014 17:56:11 +0530
Message-ID: <1392726375-32001-5-git-send-email-hariprasad@chelsio.com>
References: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, dm@chelsio.com, leedom@chelsio.com,
	nirranjan@chelsio.com, kumaras@chelsio.com, santosh@chelsio.com,
	hariprasad@chelsio.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31324 "EHLO
	stargate.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754609AbaBRNgG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Feb 2014 08:36:06 -0500
In-Reply-To: <1392726375-32001-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kumar Sanghvi <kumaras@chelsio.com>

The LE workaround in firmware is not atomic and fw_ofld_connection_wrs must not interleave.
Therefore, when the workaround is enabled, we need to send all ctrlq WRs on a single ctrl queue.

Based on original work by Santosh Rastapur <santosh@chelsio.com>

Signed-off-by: Kumar Sanghvi <kumaras@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/sge.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/sge.c b/drivers/net/ethernet/chelsio/cxgb4/sge.c
index 47ffa64..23dbe28 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/sge.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/sge.c
@@ -1467,8 +1467,12 @@ static inline int ofld_send(struct adapter *adap, struct sk_buff *skb)
 {
 	unsigned int idx = skb_txq(skb);
 
-	if (unlikely(is_ctrl_pkt(skb)))
+	if (unlikely(is_ctrl_pkt(skb))) {
+		/* Single ctrl queue is a requirement for LE workaround path */
+		if (adap->tids.nsftids)
+			idx = 0;
 		return ctrl_xmit(&adap->sge.ctrlq[idx], skb);
+	}
 	return ofld_xmit(&adap->sge.ofldtxq[idx], skb);
 }
 
-- 
1.8.0
