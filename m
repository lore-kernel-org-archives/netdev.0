From: Rajat Jain <rajatja@google.com>
Subject: [PATCH v3] mwifiex: report wakeup for wowlan
Date: Tue,  4 Oct 2016 13:37:42 -0700
Message-ID: <1475613462-93384-1-git-send-email-rajatja@google.com>
References: <87vax8p9is.fsf@kamboji.qca.qualcomm.com>
Cc: Rajat Jain <rajatja@google.com>,
        Wei-Ning Huang <wnhuang@google.com>,
        Brian Norris <briannorris@google.com>,
        Eric Caruso <ejcaruso@chromium.org>, rajatxjain@gmail.com
To: Amitkumar Karwar <akarwar@marvell.com>,
        Nishant Sarmukadam <nishants@marvell.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34815 "EHLO
        mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753651AbcJDUiJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Oct 2016 16:38:09 -0400
Received: by mail-pa0-f47.google.com with SMTP id rz1so21337158pab.1
        for <netdev@vger.kernel.org>; Tue, 04 Oct 2016 13:38:09 -0700 (PDT)
In-Reply-To: <87vax8p9is.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Register the WLAN device as a wakeup source since it can
wake the system via wake-on-wireless-lan. In an actual wowlan
event, notify the PM core that we are the current wakeup source.
This allows the PM core to update the wakeup attributes in /sys.

This was causing wakeup issues on chromeos as the system was
apparently confused about the wakeup source.

Signed-off-by: Wei-Ning Huang <wnhuang@google.com>
Signed-off-by: Rajat Jain <rajatja@google.com>
Tested-by: Wei-Ning Huang <wnhuang@chromium.org>
Reviewed-by: Eric Caruso <ejcaruso@chromium.org>
Acked-by: Amitkumar Karwar <akarwar@marvell.com>
---
v3: Fix the commit log
v2: Fix the commit log

 drivers/net/wireless/marvell/mwifiex/sdio.c | 8 ++++++++
 drivers/net/wireless/marvell/mwifiex/sdio.h | 1 +
 2 files changed, 9 insertions(+)

diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index d3e1561..a5f63e4 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -89,6 +89,9 @@ static irqreturn_t mwifiex_wake_irq_wifi(int irq, void *priv)
 		disable_irq_nosync(irq);
 	}
 
+	/* Notify PM core we are wakeup source */
+	pm_wakeup_event(cfg->dev, 0);
+
 	return IRQ_HANDLED;
 }
 
@@ -112,6 +115,7 @@ static int mwifiex_sdio_probe_of(struct device *dev, struct sdio_mmc_card *card)
 					  GFP_KERNEL);
 	cfg = card->plt_wake_cfg;
 	if (cfg && card->plt_of_node) {
+		cfg->dev = dev;
 		cfg->irq_wifi = irq_of_parse_and_map(card->plt_of_node, 0);
 		if (!cfg->irq_wifi) {
 			dev_dbg(dev,
@@ -130,6 +134,10 @@ static int mwifiex_sdio_probe_of(struct device *dev, struct sdio_mmc_card *card)
 		}
 	}
 
+	ret = device_init_wakeup(dev, true);
+	if (ret)
+		dev_err(dev, "fail to init wakeup for mwifiex");
+
 	return 0;
 }
 
diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.h b/drivers/net/wireless/marvell/mwifiex/sdio.h
index db837f1..07cdd23 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.h
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.h
@@ -155,6 +155,7 @@
 } while (0)
 
 struct mwifiex_plt_wake_cfg {
+	struct device *dev;
 	int irq_wifi;
 	bool wake_by_wifi;
 };
-- 
2.8.0.rc3.226.g39d4020
