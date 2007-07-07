From: "Michael Chan" <mchan@broadcom.com>
Subject: [2.6.23 7/9][BNX2]: Enhance the heartbeat.
Date: Fri, 06 Jul 2007 20:30:14 -0700
Message-ID: <1183779014.5182.24.camel@dell>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3919 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753748AbXGGCiA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 22:38:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[BNX2]: Enhance the heartbeat.

In addition to the periodic heartbeat, we're adding a heartbeat
request interrupt when the heartbeat is late.  This is needed during
netpoll where the timer is not available.  -rt kernels will also
benefit since the timer is not as accurate.

[ We discussed this patch last time and we decided that the -rt
  kernel problem alone did not justify this patch.  I think the
  netpoll problem makes this patch necessary. ]

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/bnx2.c b/drivers/net/bnx2.c
index 48f5151..3163868 100644
--- a/drivers/net/bnx2.c
+++ b/drivers/net/bnx2.c
@@ -1487,6 +1487,20 @@ bnx2_set_default_link(struct bnx2 *bp)
 }
 
 static void
+bnx2_send_heart_beat(struct bnx2 *bp)
+{
+	u32 msg;
+	u32 addr;
+
+	spin_lock(&bp->indirect_lock);
+	msg = (u32) (++bp->fw_drv_pulse_wr_seq & BNX2_DRV_PULSE_SEQ_MASK);
+	addr = bp->shmem_base + BNX2_DRV_PULSE_MB;
+	REG_WR(bp, BNX2_PCICFG_REG_WINDOW_ADDRESS, addr);
+	REG_WR(bp, BNX2_PCICFG_REG_WINDOW, msg);
+	spin_unlock(&bp->indirect_lock);
+}
+
+static void
 bnx2_remote_phy_event(struct bnx2 *bp)
 {
 	u32 msg;
@@ -1495,6 +1509,11 @@ bnx2_remote_phy_event(struct bnx2 *bp)
 
 	msg = REG_RD_IND(bp, bp->shmem_base + BNX2_LINK_STATUS);
 
+	if (msg & BNX2_LINK_STATUS_HEART_BEAT_EXPIRED)
+		bnx2_send_heart_beat(bp);
+
+	msg &= ~BNX2_LINK_STATUS_HEART_BEAT_EXPIRED;
+
 	if ((msg & BNX2_LINK_STATUS_LINK_UP) == BNX2_LINK_STATUS_LINK_DOWN)
 		bp->link_up = 0;
 	else {
@@ -1572,6 +1591,7 @@ bnx2_set_remote_link(struct bnx2 *bp)
 			break;
 		case BNX2_FW_EVT_CODE_SW_TIMER_EXPIRATION_EVENT:
 		default:
+			bnx2_send_heart_beat(bp);
 			break;
 	}
 	return 0;
@@ -4122,7 +4142,7 @@ bnx2_init_chip(struct bnx2 *bp)
 	rc = bnx2_fw_sync(bp, BNX2_DRV_MSG_DATA_WAIT2 | BNX2_DRV_MSG_CODE_RESET,
 			  0);
 
-	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS, 0x5ffffff);
+	REG_WR(bp, BNX2_MISC_ENABLE_SET_BITS, BNX2_MISC_ENABLE_DEFAULT);
 	REG_RD(bp, BNX2_MISC_ENABLE_SET_BITS);
 
 	udelay(20);
@@ -4930,7 +4950,6 @@ static void
 bnx2_timer(unsigned long data)
 {
 	struct bnx2 *bp = (struct bnx2 *) data;
-	u32 msg;
 
 	if (!netif_running(bp->dev))
 		return;
@@ -4938,8 +4957,7 @@ bnx2_timer(unsigned long data)
 	if (atomic_read(&bp->intr_sem) != 0)
 		goto bnx2_restart_timer;
 
-	msg = (u32) ++bp->fw_drv_pulse_wr_seq;
-	REG_WR_IND(bp, bp->shmem_base + BNX2_DRV_PULSE_MB, msg);
+	bnx2_send_heart_beat(bp);
 
 	bp->stats_blk->stat_FwRxDrop = REG_RD_IND(bp, BNX2_FW_RX_DROP_COUNT);
 
diff --git a/drivers/net/bnx2.h b/drivers/net/bnx2.h
index 14c0a1e..6dca333 100644
--- a/drivers/net/bnx2.h
+++ b/drivers/net/bnx2.h
@@ -6338,6 +6338,8 @@ struct l2_fhdr {
 
 #define RX_COPY_THRESH			92
 
+#define BNX2_MISC_ENABLE_DEFAULT	0x7ffffff
+
 #define DMA_READ_CHANS	5
 #define DMA_WRITE_CHANS	3
 
@@ -6839,6 +6841,7 @@ struct fw_info {
 #define BNX2_LINK_STATUS_SERDES_LINK		 (1<<20)
 #define BNX2_LINK_STATUS_PARTNER_AD_2500FULL	 (1<<21)
 #define BNX2_LINK_STATUS_PARTNER_AD_2500HALF	 (1<<22)
+#define BNX2_LINK_STATUS_HEART_BEAT_EXPIRED	 (1<<31)
 
 #define BNX2_DRV_PULSE_MB			0x00000010
 #define BNX2_DRV_PULSE_SEQ_MASK			 0x00007fff


