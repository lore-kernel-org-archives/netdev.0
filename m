From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 1/2] tg3: Fix TSO CAP for 5704 devs w / ASF
 enabled
Date: Mon, 28 Nov 2011 11:41:03 -0800
Message-ID: <1322509264-19636-2-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com,
	"Michael Chan" <mchan@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2633 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753623Ab1K1Tk7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Nov 2011 14:40:59 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On the earliest TSO capable devices, TSO was accomplished through
firmware.  The TSO cannot coexist with ASF management firmware though.
The tg3 driver determines whether or not ASF is enabled by calling
tg3_get_eeprom_hw_cfg(), which checks a particular bit of NIC memory.
Commit dabc5c670d3f86d15ee4f42ab38ec5bd2682487d, entitled "tg3: Move
TSO_CAPABLE assignment", accidentally moved the code that determines
TSO capabilities earlier than the call to tg3_get_eeprom_hw_cfg().  As a
consequence, the driver was attempting to determine TSO capabilities
before it had all the data it needed to make the decision.

This patch fixes the problem by revisiting and reevaluating the decision
after tg3_get_eeprom_hw_cfg() is called.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Signed-off-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/ethernet/broadcom/tg3.c |   14 ++++++++++++--
 1 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/tg3.c b/drivers/net/ethernet/broadcom/tg3.c
index 0acb279..0c695dc 100644
--- a/drivers/net/ethernet/broadcom/tg3.c
+++ b/drivers/net/ethernet/broadcom/tg3.c
@@ -13988,9 +13988,13 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	if (tg3_flag(tp, HW_TSO_1) ||
 	    tg3_flag(tp, HW_TSO_2) ||
 	    tg3_flag(tp, HW_TSO_3) ||
-	    (tp->fw_needed && !tg3_flag(tp, ENABLE_ASF)))
+	    tp->fw_needed) {
+		/* For firmware TSO, assume ASF is disabled.
+		 * We'll disable TSO later if we discover ASF
+		 * is enabled in tg3_get_eeprom_hw_cfg().
+		 */
 		tg3_flag_set(tp, TSO_CAPABLE);
-	else {
+	} else {
 		tg3_flag_clear(tp, TSO_CAPABLE);
 		tg3_flag_clear(tp, TSO_BUG);
 		tp->fw_needed = NULL;
@@ -14266,6 +14270,12 @@ static int __devinit tg3_get_invariants(struct tg3 *tp)
 	 */
 	tg3_get_eeprom_hw_cfg(tp);
 
+	if (tp->fw_needed && tg3_flag(tp, ENABLE_ASF)) {
+		tg3_flag_clear(tp, TSO_CAPABLE);
+		tg3_flag_clear(tp, TSO_BUG);
+		tp->fw_needed = NULL;
+	}
+
 	if (tg3_flag(tp, ENABLE_APE)) {
 		/* Allow reads and writes to the
 		 * APE register and memory space.
-- 
1.7.3.4
