From: "Dmitry Kravkov" <dmitry@broadcom.com>
Subject: [PATCH net-next] bnx2x: fix crash while ethtool -t
Date: Tue, 6 Dec 2011 14:05:12 +0200
Message-ID: <1323173112-30577-1-git-send-email-dmitry@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2139 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933238Ab1LFMFV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Dec 2011 07:05:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

commit 2df1a70aaf70e8dff11b89b938a5f317556ee640  "bnx2x: Support
for byte queue limits" has introduced an asymmetry in usage of
netdev_tx_completed_queue and netdev_tx_sent_queue. Missing
call to netdev_tx_sent_queue causes the crash during ethtool -t.

The patch adds the missing call.


Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 .../net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c    |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
index c679ed9..0b4b1d3 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c
@@ -1741,6 +1741,7 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 	u16 len;
 	int rc = -ENODEV;
 	u8 *data;
+	struct netdev_queue *txq = netdev_get_tx_queue(bp->dev, txdata->txq_index);
 
 	/* check the loopback mode */
 	switch (loopback_mode) {
@@ -1795,6 +1796,8 @@ static int bnx2x_run_loopback(struct bnx2x *bp, int loopback_mode)
 	tx_start_idx = le16_to_cpu(*txdata->tx_cons_sb);
 	rx_start_idx = le16_to_cpu(*fp_rx->rx_cons_sb);
 
+	netdev_tx_sent_queue(txq, skb->len);
+
 	pkt_prod = txdata->tx_pkt_prod++;
 	tx_buf = &txdata->tx_buf_ring[TX_BD(pkt_prod)];
 	tx_buf->first_bd = txdata->tx_bd_prod;
-- 
1.7.1
