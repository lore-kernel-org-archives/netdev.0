From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH v2 net-next 10/13] at86rf230: rework reset to trx_off state change
Date: Wed,  2 Jul 2014 17:10:07 +0200
Message-ID: <1404313810-30232-11-git-send-email-alex.aring@gmail.com>
References: <1404313810-30232-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, stilwellt@openlabs.co,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f171.google.com ([74.125.82.171]:64672 "EHLO
	mail-we0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754460AbaGBPK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Jul 2014 11:10:28 -0400
Received: by mail-we0-f171.google.com with SMTP id q58so11515155wes.30
        for <netdev@vger.kernel.org>; Wed, 02 Jul 2014 08:10:27 -0700 (PDT)
In-Reply-To: <1404313810-30232-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 16 +++++++++++++++-
 1 file changed, 15 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 696a604..87685d4 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -42,6 +42,7 @@ struct at86rf230_local;
  * All timings are in us.
  */
 struct at86rf2xx_chip_data {
+	u16 t_reset_to_off;
 	u16 t_off_to_aack;
 	u16 t_off_to_tx_on;
 	u16 t_frame;
@@ -582,6 +583,16 @@ at86rf230_async_state_delay(void *context)
 			break;
 		}
 		break;
+	/* Default value, means RESET state */
+	case STATE_P_ON:
+		switch (ctx->to_state) {
+		case STATE_TRX_OFF:
+			usleep_range(c->t_reset_to_off, c->t_reset_to_off + 10);
+			goto change;
+		default:
+			break;
+		}
+		break;
 	default:
 		break;
 	}
@@ -1236,6 +1247,7 @@ static struct ieee802154_ops at86rf230_ops = {
 };
 
 static struct at86rf2xx_chip_data at86rf233_data = {
+	.t_reset_to_off = 26,
 	.t_off_to_aack = 80,
 	.t_off_to_tx_on = 80,
 	.t_frame = 4096,
@@ -1249,6 +1261,7 @@ static struct at86rf2xx_chip_data at86rf233_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf231_data = {
+	.t_reset_to_off = 37,
 	.t_off_to_aack = 110,
 	.t_off_to_tx_on = 110,
 	.t_frame = 4096,
@@ -1262,6 +1275,7 @@ static struct at86rf2xx_chip_data at86rf231_data = {
 };
 
 static struct at86rf2xx_chip_data at86rf212_data = {
+	.t_reset_to_off = 26,
 	.t_off_to_aack = 200,
 	.t_off_to_tx_on = 200,
 	.t_frame = 4096,
@@ -1280,7 +1294,7 @@ static int at86rf230_hw_init(struct at86rf230_local *lp)
 	unsigned int dvdd;
 	u8 csma_seed[2];
 
-	rc = at86rf230_write_subreg(lp, SR_TRX_CMD, STATE_FORCE_TRX_OFF);
+	rc = at86rf230_sync_state_change(lp, STATE_FORCE_TRX_OFF);
 	if (rc)
 		return rc;
 
-- 
2.0.1
