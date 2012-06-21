From: "Michael Chan" <mchan@broadcom.com>
Subject: [PATCH 2/3 net-next] tg3: Add APE scratchpad read and write
 functions.
Date: Wed, 20 Jun 2012 17:06:31 -0700
Message-ID: <1340237192-30052-2-git-send-email-mchan@broadcom.com>
References: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsujir@broadcom.com, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:4729 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758619Ab2FTXzl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jun 2012 19:55:41 -0400
In-Reply-To: <1340237192-30052-1-git-send-email-mchan@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matt Carlson <mcarlson@broadcom.com>

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |  137 +++++++++++++++++++++++++++++++++++
 drivers/net/ethernet/broadcom/tg3.h |   10 ++-
 2 files changed, 145 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 7c515db..e93760c 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -751,6 +751,143 @@ static int tg3_ape_event_lock(struct tg3 *tp, u32 timeout_us)
 	return timeout_us ? 0 : -EBUSY;
 }
 
+static int tg3_ape_wait_for_event(struct tg3 *tp, u32 timeout_us)
+{
+	u32 i, apedata;
+
+	for (i = 0; i < timeout_us / 10; i++) {
+		apedata = tg3_ape_read32(tp, TG3_APE_EVENT_STATUS);
+
+		if (!(apedata & APE_EVENT_STATUS_EVENT_PENDING))
+			break;
+
+		udelay(10);
+	}
+
+	return i == timeout_us / 10;
+}
+
+int tg3_ape_scratchpad_read(struct tg3 *tp, u32 *data, u32 base_off, u32 len)
+{
+	int err;
+	u32 i, bufoff, msgoff, maxlen, apedata;
+
+	if (!tg3_flag(tp, APE_HAS_NCSI))
+		return 0;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
+	if (apedata != APE_SEG_SIG_MAGIC)
+		return -ENODEV;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_FW_STATUS);
+	if (!(apedata & APE_FW_STATUS_READY))
+		return -EAGAIN;
+
+	bufoff = tg3_ape_read32(tp, TG3_APE_SEG_MSG_BUF_OFF) +
+		 TG3_APE_SHMEM_BASE;
+	msgoff = bufoff + 2 * sizeof(u32);
+	maxlen = tg3_ape_read32(tp, TG3_APE_SEG_MSG_BUF_LEN);
+
+	while (len) {
+		u32 length;
+
+		/* Cap xfer sizes to scratchpad limits. */
+		length = (len > maxlen) ? maxlen : len;
+		len -= length;
+
+		apedata = tg3_ape_read32(tp, TG3_APE_FW_STATUS);
+		if (!(apedata & APE_FW_STATUS_READY))
+			return -EAGAIN;
+
+		/* Wait for up to 1 msec for APE to service previous event. */
+		err = tg3_ape_event_lock(tp, 1000);
+		if (err)
+			return err;
+
+		apedata = APE_EVENT_STATUS_DRIVER_EVNT |
+			  APE_EVENT_STATUS_SCRTCHPD_READ |
+			  APE_EVENT_STATUS_EVENT_PENDING;
+		tg3_ape_write32(tp, TG3_APE_EVENT_STATUS, apedata);
+
+		tg3_ape_write32(tp, bufoff, base_off);
+		tg3_ape_write32(tp, bufoff + sizeof(u32), length);
+
+		tg3_ape_unlock(tp, TG3_APE_LOCK_MEM);
+		tg3_ape_write32(tp, TG3_APE_EVENT, APE_EVENT_1);
+
+		base_off += length;
+
+		if (tg3_ape_wait_for_event(tp, 30000))
+			return -EAGAIN;
+
+		for (i = 0; length; i += 4, length -= 4) {
+			u32 val = tg3_ape_read32(tp, msgoff + i);
+			memcpy(data, &val, sizeof(u32));
+			data++;
+		}
+	}
+
+	return 0;
+}
+
+int tg3_ape_scratchpad_write(struct tg3 *tp, u32 dstoff, u32 *data, u32 len)
+{
+	u32 i, bufoff, msgoff, maxlen, apedata;
+
+	if (!tg3_flag(tp, APE_HAS_NCSI))
+		return 0;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_SEG_SIG);
+	if (apedata != APE_SEG_SIG_MAGIC)
+		return -ENODEV;
+
+	apedata = tg3_ape_read32(tp, TG3_APE_FW_STATUS);
+	if (!(apedata & APE_FW_STATUS_READY))
+		return -EAGAIN;
+
+	bufoff = tg3_ape_read32(tp, TG3_APE_SEG_MSG_BUF_OFF) +
+		 TG3_APE_SHMEM_BASE;
+	msgoff = bufoff + 2 * sizeof(u32);
+	maxlen = tg3_ape_read32(tp, TG3_APE_SEG_MSG_BUF_LEN);
+
+	while (len) {
+		int err;
+		u32 length;
+
+		/* Cap xfer sizes to scratchpad limits. */
+		length = (len > maxlen) ? maxlen : len;
+		len -= length;
+
+		/* Wait for up to 1 millisecond for
+		 * APE to service previous event.
+		 */
+		err = tg3_ape_event_lock(tp, 1000);
+		if (err)
+			return err;
+
+		tg3_ape_write32(tp, bufoff, dstoff);
+		tg3_ape_write32(tp, bufoff + sizeof(u32), length);
+		apedata = msgoff;
+
+		dstoff += length;
+
+		for (i = 0; length; i += 4, length -= sizeof(u32)) {
+			tg3_ape_write32(tp, apedata, *data++);
+			apedata += sizeof(u32);
+		}
+
+		apedata = APE_EVENT_STATUS_DRIVER_EVNT |
+			  APE_EVENT_STATUS_SCRTCHPD_WRITE |
+			  APE_EVENT_STATUS_EVENT_PENDING;
+		tg3_ape_write32(tp, TG3_APE_EVENT_STATUS, apedata);
+
+		tg3_ape_unlock(tp, TG3_APE_LOCK_MEM);
+		tg3_ape_write32(tp, TG3_APE_EVENT, APE_EVENT_1);
+	}
+
+	return 0;
+}
+
 static int tg3_ape_send_event(struct tg3 *tp, u32 event)
 {
 	int err;
diff --git a/drivers/net/ethernet/broadcom/tg3.h b/drivers/net/ethernet/broadcom/tg3.h
index 93865f8..d167a1c 100644
--- a/drivers/net/ethernet/broadcom/tg3.h
+++ b/drivers/net/ethernet/broadcom/tg3.h
@@ -2311,10 +2311,12 @@
 #define  APE_LOCK_REQ_DRIVER		 0x00001000
 #define TG3_APE_LOCK_GRANT		0x004c
 #define  APE_LOCK_GRANT_DRIVER		 0x00001000
-#define TG3_APE_SEG_SIG			0x4000
-#define  APE_SEG_SIG_MAGIC		 0x41504521
+#define TG3_APE_STICKY_TMR		0x00b0
 
 /* APE shared memory.  Accessible through BAR1 */
+#define TG3_APE_SHMEM_BASE		0x4000
+#define TG3_APE_SEG_SIG			0x4000
+#define  APE_SEG_SIG_MAGIC		 0x41504521
 #define TG3_APE_FW_STATUS		0x400c
 #define  APE_FW_STATUS_READY		 0x00000100
 #define TG3_APE_FW_FEATURES		0x4010
@@ -2327,6 +2329,8 @@
 #define  APE_FW_VERSION_REVMSK		 0x0000ff00
 #define  APE_FW_VERSION_REVSFT		 8
 #define  APE_FW_VERSION_BLDMSK		 0x000000ff
+#define TG3_APE_SEG_MSG_BUF_OFF		0x401c
+#define TG3_APE_SEG_MSG_BUF_LEN		0x4020
 #define TG3_APE_HOST_SEG_SIG		0x4200
 #define  APE_HOST_SEG_SIG_MAGIC		 0x484f5354
 #define TG3_APE_HOST_SEG_LEN		0x4204
@@ -2353,6 +2357,8 @@
 
 #define  APE_EVENT_STATUS_DRIVER_EVNT	 0x00000010
 #define  APE_EVENT_STATUS_STATE_CHNGE	 0x00000500
+#define  APE_EVENT_STATUS_SCRTCHPD_READ	 0x00001600
+#define  APE_EVENT_STATUS_SCRTCHPD_WRITE 0x00001700
 #define  APE_EVENT_STATUS_STATE_START	 0x00010000
 #define  APE_EVENT_STATUS_STATE_UNLOAD	 0x00020000
 #define  APE_EVENT_STATUS_STATE_WOL	 0x00030000
-- 
1.7.1
