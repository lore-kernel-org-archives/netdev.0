From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/9][TG3]: Improve ASF heartbeat.
Date: Wed, 27 Sep 2006 13:34:25 -0700
Message-ID: <1159389265.3411.19.camel@rh4>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:23314 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1030769AbWI0Uht
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 16:37:49 -0400
To: davem@davemloft.net, linville@tuxdriver.com
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[TG3]: Improve ASF heartbeat.

Change to a different ASF heartbeat message code to improve
reliability.

There were some reports of unintended resets on real time kernels
where the timer may be slow and cause the heartbeat to be late.
Netpoll will also have the same problem because the timer irq will
be unavailable.

Using the new heartbeat code, the ASF firmware will also check the
ring condition before resetting the chip when the heartbeat is
expiring.

Signed-off-by: Michael Chan <mchan@broadcom.com>

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4eef798..6af8ebc 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -6690,13 +6690,29 @@ static void tg3_timer(unsigned long __op
 		tp->timer_counter = tp->timer_multiplier;
 	}
 
-	/* Heartbeat is only sent once every 2 seconds.  */
+	/* Heartbeat is only sent once every 2 seconds.
+	 *
+	 * The heartbeat is to tell the ASF firmware that the host
+	 * driver is still alive.  In the event that the OS crashes,
+	 * ASF needs to reset the hardware to free up the FIFO space
+	 * that may be filled with rx packets destined for the host.
+	 * If the FIFO is full, ASF will no longer function properly.
+	 *
+	 * Unintended resets have been reported on real time kernels
+	 * where the timer doesn't run on time.  Netpoll will also have
+	 * same problem.
+	 *
+	 * The new FWCMD_NICDRV_ALIVE3 command tells the ASF firmware
+	 * to check the ring condition when the heartbeat is expiring
+	 * before doing the reset.  This will prevent most unintended
+	 * resets.
+	 */
 	if (!--tp->asf_counter) {
 		if (tp->tg3_flags & TG3_FLAG_ENABLE_ASF) {
 			u32 val;
 
 			tg3_write_mem(tp, NIC_SRAM_FW_CMD_MBOX,
-				      FWCMD_NICDRV_ALIVE2);
+				      FWCMD_NICDRV_ALIVE3);
 			tg3_write_mem(tp, NIC_SRAM_FW_CMD_LEN_MBOX, 4);
 			/* 5 seconds timeout */
 			tg3_write_mem(tp, NIC_SRAM_FW_CMD_DATA_MBOX, 5);
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index f9c81ba..f7462c2 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1537,6 +1537,7 @@
 #define  FWCMD_NICDRV_FIX_DMAR		 0x00000005
 #define  FWCMD_NICDRV_FIX_DMAW		 0x00000006
 #define  FWCMD_NICDRV_ALIVE2		 0x0000000d
+#define  FWCMD_NICDRV_ALIVE3		 0x0000000e
 #define NIC_SRAM_FW_CMD_LEN_MBOX	0x00000b7c
 #define NIC_SRAM_FW_CMD_DATA_MBOX	0x00000b80
 #define NIC_SRAM_FW_ASF_STATUS_MBOX	0x00000c00


