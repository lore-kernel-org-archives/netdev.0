From: Prashant Sreedharan <prashant@broadcom.com>
Subject: [PATCH net]tg3: Change nvram command timeout value to 50ms
Date: Wed, 18 Jun 2014 18:38:42 -0700
Message-ID: <1403141922-21768-1-git-send-email-prashant@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>,
	Prashant Sreedharan <prashant@broadcom.com>,
	Michael Chan <mchan@broadcom.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:16760 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757077AbaFSBmk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2014 21:42:40 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 506724c463fcd63477a5e404728a980b71f80bb7 "tg3: Override clock,
link aware and link idle mode during NVRAM dump" changed the timeout
value for nvram command execution from 100ms to 1ms. But the 1ms
timeout value was only sufficient for nvram read operations but not
write operations for most of the devices supported by tg3 driver.
This patch sets the MAX to 50ms. Also to avoid busy waiting for a long
time, the driver will udelay for 1ms and msleep for the remaining time.

Signed-off-by: Prashant Sreedharan <prashant@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index df2792d..cd92c49 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -3224,7 +3224,7 @@ static int tg3_nvram_read_using_eeprom(struct tg3 *tp,
 	return 0;
 }
 
-#define NVRAM_CMD_TIMEOUT 100
+#define NVRAM_CMD_TIMEOUT 5000
 
 static int tg3_nvram_exec_cmd(struct tg3 *tp, u32 nvram_cmd)
 {
@@ -3232,7 +3232,12 @@ static int tg3_nvram_exec_cmd(struct tg3 *tp, u32 nvram_cmd)
 
 	tw32(NVRAM_CMD, nvram_cmd);
 	for (i = 0; i < NVRAM_CMD_TIMEOUT; i++) {
-		udelay(10);
+		if (i < 100) {
+			udelay(10);
+		} else {
+			msleep(1);
+			i += 99;
+		}
 		if (tr32(NVRAM_CMD) & NVRAM_CMD_DONE) {
 			udelay(10);
 			break;
-- 
1.7.1
