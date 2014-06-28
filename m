From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 05/13] at86rf230: add support for at86rf23x desense
Date: Sat, 28 Jun 2014 20:33:43 +0200
Message-ID: <1403980431-6201-6-git-send-email-alex.aring@gmail.com>
References: <1403980431-6201-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, werner@almesberger.net,
	Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:42601 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932215AbaF1Sek (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Jun 2014 14:34:40 -0400
Received: by mail-wg0-f44.google.com with SMTP id x13so6193943wgg.3
        for <netdev@vger.kernel.org>; Sat, 28 Jun 2014 11:34:39 -0700 (PDT)
In-Reply-To: <1403980431-6201-1-git-send-email-alex.aring@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

To set the CCA_ED_THRES register the calculation for at86rf23x is
different than for at86rf212. This patch adds a new callback for this
calculation in chip data struct.

Signed-off-by: Alexander Aring <alex.aring@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 22 ++++++++++++++++++----
 1 file changed, 18 insertions(+), 4 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 5958e05..5768d56 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -46,6 +46,7 @@ struct at86rf2xx_chip_data {
 	int rssi_base_val;
 
 	int (*set_channel)(struct at86rf230_local *, int, int);
+	int (*get_desense_steps)(struct at86rf230_local *, s32);
 };
 
 struct at86rf230_local {
@@ -819,17 +820,27 @@ at86rf230_set_cca_mode(struct ieee802154_dev *dev, u8 mode)
 }
 
 static int
+at86rf212_get_desens_steps(struct at86rf230_local *lp, s32 level)
+{
+	return (level - lp->data->rssi_base_val) * 100 / 207;
+}
+
+static int
+at86rf23x_get_desens_steps(struct at86rf230_local *lp, s32 level)
+{
+	return (level - lp->data->rssi_base_val) / 2;
+}
+
+static int
 at86rf230_set_cca_ed_level(struct ieee802154_dev *dev, s32 level)
 {
 	struct at86rf230_local *lp = dev->priv;
-	int desens_steps;
 
 	if (level < lp->data->rssi_base_val || level > 30)
 		return -EINVAL;
 
-	desens_steps = (level - lp->data->rssi_base_val) * 100 / 207;
-
-	return at86rf230_write_subreg(lp, SR_CCA_ED_THRES, desens_steps);
+	return at86rf230_write_subreg(lp, SR_CCA_ED_THRES,
+				      lp->data->get_desense_steps(lp, level));
 }
 
 static int
@@ -889,16 +900,19 @@ static struct ieee802154_ops at86rf230_ops = {
 static struct at86rf2xx_chip_data at86rf233_data = {
 	.rssi_base_val = -91,
 	.set_channel = at86rf23x_set_channel,
+	.get_desense_steps = at86rf23x_get_desens_steps
 };
 
 static struct at86rf2xx_chip_data at86rf231_data = {
 	.rssi_base_val = -91,
 	.set_channel = at86rf23x_set_channel,
+	.get_desense_steps = at86rf23x_get_desens_steps
 };
 
 static struct at86rf2xx_chip_data at86rf212_data = {
 	.rssi_base_val = -100,
 	.set_channel = at86rf212_set_channel,
+	.get_desense_steps = at86rf212_get_desens_steps
 };
 
 static void at86rf230_irqwork(struct work_struct *work)
-- 
2.0.1
