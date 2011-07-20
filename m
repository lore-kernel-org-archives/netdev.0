From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 6/8] tg3: Fix int selftest for recent devices.
Date: Wed, 20 Jul 2011 13:20:55 -0700
Message-ID: <1311193257-20531-7-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3699 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751400Ab1GTUTb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Jul 2011 16:19:31 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes interrupt selftest failures for recent devices (57765,
5717, 5718. 5719, 5720) by disabling MSI one-shot mode and applying the
status tag workaround to the selftest code.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index e5c1bc9..f2b0839 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -9183,7 +9183,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 	 * Turn off MSI one shot mode.  Otherwise this test has no
 	 * observable way to know whether the interrupt was delivered.
 	 */
-	if (tg3_flag(tp, 57765_PLUS) && tg3_flag(tp, USING_MSI)) {
+	if (tg3_flag(tp, 57765_PLUS)) {
 		val = tr32(MSGINT_MODE) | MSGINT_MODE_ONE_SHOT_DISABLE;
 		tw32(MSGINT_MODE, val);
 	}
@@ -9211,6 +9211,10 @@ static int tg3_test_interrupt(struct tg3 *tp)
 			break;
 		}
 
+		if (tg3_flag(tp, 57765_PLUS) &&
+		    tnapi->hw_status->status_tag != tnapi->last_tag)
+			tw32_mailbox_f(tnapi->int_mbox, tnapi->last_tag << 24);
+
 		msleep(10);
 	}
 
@@ -9225,7 +9229,7 @@ static int tg3_test_interrupt(struct tg3 *tp)
 
 	if (intr_ok) {
 		/* Reenable MSI one shot mode. */
-		if (tg3_flag(tp, 57765_PLUS) && tg3_flag(tp, USING_MSI)) {
+		if (tg3_flag(tp, 57765_PLUS)) {
 			val = tr32(MSGINT_MODE) & ~MSGINT_MODE_ONE_SHOT_DISABLE;
 			tw32(MSGINT_MODE, val);
 		}
-- 
1.7.3.4


