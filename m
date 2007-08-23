From: Divy Le Ray <divy@chelsio.com>
Subject: [PATCH 12/11] cxgb3 - remove false positive in xgmac workaround
Date: Wed, 22 Aug 2007 23:37:49 -0700
Message-ID: <20070823063749.30184.51329.stgit@speedy5>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	swise@opengridcomputing.com
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.22.49.110]:15074 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754380AbXHWGhw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2007 02:37:52 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Divy Le Ray <divy@chelsio.com>

Qualify toggling of xgmac tx enable with not getting pause frames, 
we might not make forward progress because the peer is sending 
lots of pause frames.

Signed-off-by: Divy Le Ray <divy@chelsio.com>
---

 drivers/net/cxgb3/common.h |    1 +
 drivers/net/cxgb3/xgmac.c  |    4 +++-
 2 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/common.h b/drivers/net/cxgb3/common.h
index ff867c2..3e5b0db 100644
--- a/drivers/net/cxgb3/common.h
+++ b/drivers/net/cxgb3/common.h
@@ -514,6 +514,7 @@ struct cmac {
 	u64 rx_mcnt;
 	unsigned int toggle_cnt;
 	unsigned int txen;
+	u64 rx_pause;
 	struct mac_stats stats;
 };
 
diff --git a/drivers/net/cxgb3/xgmac.c b/drivers/net/cxgb3/xgmac.c
index 1d1c391..ff9e9dc 100644
--- a/drivers/net/cxgb3/xgmac.c
+++ b/drivers/net/cxgb3/xgmac.c
@@ -452,6 +452,7 @@ int t3_mac_enable(struct cmac *mac, int which)
 						A_XGM_TX_SPI4_SOP_EOP_CNT +
 						oft)));
 		mac->rx_mcnt = s->rx_frames;
+		mac->rx_pause = s->rx_pause;
 		mac->rx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
 						A_XGM_RX_SPI4_SOP_EOP_CNT +
 						oft)));
@@ -504,7 +505,7 @@ int t3b2_mac_watchdog_task(struct cmac *mac)
 	tx_xcnt = 1;		/* By default tx_xcnt is making progress */
 	tx_tcnt = mac->tx_tcnt;	/* If tx_mcnt is progressing ignore tx_tcnt */
 	rx_xcnt = 1;		/* By default rx_xcnt is making progress */
-	if (tx_mcnt == mac->tx_mcnt) {
+	if (tx_mcnt == mac->tx_mcnt && mac->rx_pause == s->rx_pause) {
 		tx_xcnt = (G_TXSPI4SOPCNT(t3_read_reg(adap,
 						A_XGM_TX_SPI4_SOP_EOP_CNT +
 					       	mac->offset)));
@@ -560,6 +561,7 @@ out:
 	mac->tx_mcnt = s->tx_frames;
 	mac->rx_xcnt = rx_xcnt;
 	mac->rx_mcnt = s->rx_frames;
+	mac->rx_pause = s->rx_pause;
 	if (status == 1) {
 		t3_write_reg(adap, A_XGM_TX_CTRL + mac->offset, 0);
 		t3_read_reg(adap, A_XGM_TX_CTRL + mac->offset);  /* flush */
