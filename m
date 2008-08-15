From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH 1/7] tg3: Add APE register access locking
Date: Fri, 15 Aug 2008 13:57:05 -0700
Message-ID: <1218834763.6472@xw6200>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Michael Chan" <mchan@broadcom.com>,
	andy@greyhouse.net
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4231 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751751AbYHOU1e (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Aug 2008 16:27:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If the driver resets the chip while the APE is performing a register
access, that register access will never complete and the APE will hang
indefinitely.  To prevent this race condition, the driver must acquire
an APE mutex before resetting the chip.  The APE will not attempt a
register access until it acquires this lock.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>

---
 drivers/net/tg3.c |    6 ++++++
 drivers/net/tg3.h |    1 +
 2 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index d2439b8..e3fd74b 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -536,6 +536,7 @@ static int tg3_ape_lock(struct tg3 *tp, int locknum)
 		return 0;
 
 	switch (locknum) {
+		case TG3_APE_LOCK_GRC:
 		case TG3_APE_LOCK_MEM:
 			break;
 		default:
@@ -573,6 +574,7 @@ static void tg3_ape_unlock(struct tg3 *tp, int locknum)
 		return;
 
 	switch (locknum) {
+		case TG3_APE_LOCK_GRC:
 		case TG3_APE_LOCK_MEM:
 			break;
 		default:
@@ -5760,6 +5762,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	tg3_mdio_stop(tp);
 
+	tg3_ape_lock(tp, TG3_APE_LOCK_GRC);
+
 	/* No matching tg3_nvram_unlock() after this because
 	 * chip reset below will undo the nvram lock.
 	 */
@@ -5914,6 +5918,8 @@ static int tg3_chip_reset(struct tg3 *tp)
 
 	tg3_mdio_start(tp);
 
+	tg3_ape_unlock(tp, TG3_APE_LOCK_GRC);
+
 	err = tg3_poll_fw(tp);
 	if (err)
 		return err;
diff --git a/drivers/net/tg3.h b/drivers/net/tg3.h
index df07842..dd1af50 100644
--- a/drivers/net/tg3.h
+++ b/drivers/net/tg3.h
@@ -1889,6 +1889,7 @@
 #define  APE_EVENT_STATUS_EVENT_PENDING	 0x80000000
 
 /* APE convenience enumerations. */
+#define TG3_APE_LOCK_GRC                1
 #define TG3_APE_LOCK_MEM                4
 
 #define TG3_EEPROM_SB_F1R2_MBA_OFF	0x10
-- 
1.5.6.4



