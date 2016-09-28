From: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v2] mwifiex: report wakeup for wowlan
Date: Tue, 27 Sep 2016 18:45:04 -0700
Message-ID: <1475027104-17423-1-git-send-email-rajatja@google.com>
References: <1474995364-123069-1-git-send-email-rajatja@google.com>
Cc: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Wei-Ning Huang <wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Brian Norris <briannorris-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Eric Caruso <ejcaruso-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, rajatxjain-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1474995364-123069-1-git-send-email-rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Enable notifying wakeup source to the PM core in case of
a wake on wireless LAN event.

Signed-off-by: Wei-Ning Huang <wnhuang-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Signed-off-by: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Tested-by: Wei-Ning Huang <wnhuang-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Reviewed-by: Eric Caruso <ejcaruso-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
---
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
