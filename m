From: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH 3/3] mwifiex: Enable WoWLAN for both sdio and pcie
Date: Mon, 24 Oct 2016 10:56:53 -0700
Message-ID: <1477331813-42151-4-git-send-email-rajatja@google.com>
References: <1477331813-42151-1-git-send-email-rajatja@google.com>
Cc: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        Brian Norris <briannorris-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, rajatxjain-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: Amitkumar Karwar <akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Nishant Sarmukadam <nishants-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>,
        Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
        linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Xinming Hu <huxm-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1477331813-42151-1-git-send-email-rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Commit ce4f6f0c353b ("mwifiex: add platform specific wakeup interrupt
support") added WoWLAN feature only for sdio. This patch moves that
code to the common module so that all the interface drivers can use
it for free. It enables pcie and sdio for its use currently.

Signed-off-by: Rajat Jain <rajatja-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
---
 drivers/net/wireless/marvell/mwifiex/main.c | 41 ++++++++++++++++
 drivers/net/wireless/marvell/mwifiex/main.h | 25 ++++++++++
 drivers/net/wireless/marvell/mwifiex/pcie.c |  2 +
 drivers/net/wireless/marvell/mwifiex/sdio.c | 72 ++---------------------------
 drivers/net/wireless/marvell/mwifiex/sdio.h |  8 ----
 5 files changed, 73 insertions(+), 75 deletions(-)

diff --git a/drivers/net/wireless/marvell/mwifiex/main.c b/drivers/net/wireless/marvell/mwifiex/main.c
index b2f3d96..20c9b77 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.c
+++ b/drivers/net/wireless/marvell/mwifiex/main.c
@@ -1552,14 +1552,55 @@ void mwifiex_do_flr(struct mwifiex_adapter *adapter, bool prepare)
 }
 EXPORT_SYMBOL_GPL(mwifiex_do_flr);
 
+static irqreturn_t mwifiex_irq_wakeup_handler(int irq, void *priv)
+{
+	struct mwifiex_adapter *adapter = priv;
+
+	if (adapter->irq_wakeup >= 0) {
+		dev_dbg(adapter->dev, "%s: wake by wifi", __func__);
+		adapter->wake_by_wifi = true;
+		disable_irq_nosync(irq);
+	}
+
+	/* Notify PM core we are wakeup source */
+	pm_wakeup_event(adapter->dev, 0);
+
+	return IRQ_HANDLED;
+}
+
 static void mwifiex_probe_of(struct mwifiex_adapter *adapter)
 {
+	int ret;
 	struct device *dev = adapter->dev;
 
 	if (!dev->of_node)
 		return;
 
 	adapter->dt_node = dev->of_node;
+	adapter->irq_wakeup = irq_of_parse_and_map(adapter->dt_node, 0);
+	if (!adapter->irq_wakeup) {
+		dev_info(dev, "fail to parse irq_wakeup from device tree\n");
+		return;
+	}
+
+	ret = devm_request_irq(dev, adapter->irq_wakeup,
+			       mwifiex_irq_wakeup_handler, IRQF_TRIGGER_LOW,
+			       "wifi_wake", adapter);
+	if (ret) {
+		dev_err(dev, "Failed to request irq_wakeup %d (%d)\n",
+			adapter->irq_wakeup, ret);
+		goto err_exit;
+	}
+
+	disable_irq(adapter->irq_wakeup);
+	if (device_init_wakeup(dev, true)) {
+		dev_err(dev, "fail to init wakeup for mwifiex\n");
+		goto err_exit;
+	}
+	return;
+
+err_exit:
+	adapter->irq_wakeup = 0;
 }
 
 /*
diff --git a/drivers/net/wireless/marvell/mwifiex/main.h b/drivers/net/wireless/marvell/mwifiex/main.h
index 83e0776..12def94 100644
--- a/drivers/net/wireless/marvell/mwifiex/main.h
+++ b/drivers/net/wireless/marvell/mwifiex/main.h
@@ -1010,6 +1010,10 @@ struct mwifiex_adapter {
 	bool usb_mc_setup;
 	struct cfg80211_wowlan_nd_info *nd_info;
 	struct ieee80211_regdomain *regd;
+
+	/* Wake-on-WLAN (WoWLAN) */
+	int irq_wakeup;
+	bool wake_by_wifi;
 };
 
 void mwifiex_process_tx_queue(struct mwifiex_adapter *adapter);
@@ -1409,6 +1413,27 @@ static inline u8 mwifiex_is_tdls_link_setup(u8 status)
 	return false;
 }
 
+/* Disable platform specific wakeup interrupt */
+static inline void mwifiex_disable_wake(struct mwifiex_adapter *adapter)
+{
+	if (adapter->irq_wakeup >= 0) {
+		disable_irq_wake(adapter->irq_wakeup);
+		if (!adapter->wake_by_wifi)
+			disable_irq(adapter->irq_wakeup);
+	}
+}
+
+/* Enable platform specific wakeup interrupt */
+static inline void mwifiex_enable_wake(struct mwifiex_adapter *adapter)
+{
+	/* Enable platform specific wakeup interrupt */
+	if (adapter->irq_wakeup >= 0) {
+		adapter->wake_by_wifi = false;
+		enable_irq(adapter->irq_wakeup);
+		enable_irq_wake(adapter->irq_wakeup);
+	}
+}
+
 int mwifiex_init_shutdown_fw(struct mwifiex_private *priv,
 			     u32 func_init_shutdown);
 int mwifiex_add_card(void *, struct semaphore *, struct mwifiex_if_ops *, u8,
diff --git a/drivers/net/wireless/marvell/mwifiex/pcie.c b/drivers/net/wireless/marvell/mwifiex/pcie.c
index ea423d5..af93661 100644
--- a/drivers/net/wireless/marvell/mwifiex/pcie.c
+++ b/drivers/net/wireless/marvell/mwifiex/pcie.c
@@ -133,6 +133,7 @@ static int mwifiex_pcie_suspend(struct device *dev)
 
 	adapter = card->adapter;
 
+	mwifiex_enable_wake(adapter);
 	hs_actived = mwifiex_enable_hs(adapter);
 
 	/* Indicate device suspended */
@@ -179,6 +180,7 @@ static int mwifiex_pcie_resume(struct device *dev)
 
 	mwifiex_cancel_hs(mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_STA),
 			  MWIFIEX_ASYNC_CMD);
+	mwifiex_disable_wake(adapter);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.c b/drivers/net/wireless/marvell/mwifiex/sdio.c
index 558743a..ff5bb45 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.c
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.c
@@ -79,67 +79,18 @@ static const struct of_device_id mwifiex_sdio_of_match_table[] = {
 	{ }
 };
 
-static irqreturn_t mwifiex_wake_irq_wifi(int irq, void *priv)
-{
-	struct mwifiex_plt_wake_cfg *cfg = priv;
-
-	if (cfg->irq_wifi >= 0) {
-		pr_info("%s: wake by wifi", __func__);
-		cfg->wake_by_wifi = true;
-		disable_irq_nosync(irq);
-	}
-
-	/* Notify PM core we are wakeup source */
-	pm_wakeup_event(cfg->dev, 0);
-
-	return IRQ_HANDLED;
-}
-
 /* This function parse device tree node using mmc subnode devicetree API.
  * The device node is saved in card->plt_of_node.
  * if the device tree node exist and include interrupts attributes, this
  * function will also request platform specific wakeup interrupt.
  */
-static int mwifiex_sdio_probe_of(struct device *dev, struct sdio_mmc_card *card)
+static int mwifiex_sdio_probe_of(struct device *dev)
 {
-	struct mwifiex_plt_wake_cfg *cfg;
-	int ret;
-
 	if (!of_match_node(mwifiex_sdio_of_match_table, dev->of_node)) {
 		dev_err(dev, "required compatible string missing\n");
 		return -EINVAL;
 	}
 
-	card->plt_of_node = dev->of_node;
-	card->plt_wake_cfg = devm_kzalloc(dev, sizeof(*card->plt_wake_cfg),
-					  GFP_KERNEL);
-	cfg = card->plt_wake_cfg;
-	if (cfg && card->plt_of_node) {
-		cfg->dev = dev;
-		cfg->irq_wifi = irq_of_parse_and_map(card->plt_of_node, 0);
-		if (!cfg->irq_wifi) {
-			dev_dbg(dev,
-				"fail to parse irq_wifi from device tree\n");
-		} else {
-			ret = devm_request_irq(dev, cfg->irq_wifi,
-					       mwifiex_wake_irq_wifi,
-					       IRQF_TRIGGER_LOW,
-					       "wifi_wake", cfg);
-			if (ret) {
-				dev_dbg(dev,
-					"Failed to request irq_wifi %d (%d)\n",
-					cfg->irq_wifi, ret);
-				card->plt_wake_cfg = NULL;
-				return 0;
-			}
-			disable_irq(cfg->irq_wifi);
-		}
-	}
-
-	ret = device_init_wakeup(dev, true);
-	if (ret)
-		dev_err(dev, "fail to init wakeup for mwifiex");
-
 	return 0;
 }
 
@@ -199,11 +150,9 @@ mwifiex_sdio_probe(struct sdio_func *func, const struct sdio_device_id *id)
 
 	/* device tree node parsing and platform specific configuration*/
 	if (func->dev.of_node) {
-		ret = mwifiex_sdio_probe_of(&func->dev, card);
-		if (ret) {
-			dev_err(&func->dev, "SDIO dt node parse failed\n");
+		ret = mwifiex_sdio_probe_of(&func->dev);
+		if (ret)
 			goto err_disable;
-		}
 		valid_of_node = true;
 	}
 
@@ -269,12 +218,7 @@ static int mwifiex_sdio_resume(struct device *dev)
 	mwifiex_cancel_hs(mwifiex_get_priv(adapter, MWIFIEX_BSS_ROLE_STA),
 			  MWIFIEX_SYNC_CMD);
 
-	/* Disable platform specific wakeup interrupt */
-	if (card->plt_wake_cfg && card->plt_wake_cfg->irq_wifi >= 0) {
-		disable_irq_wake(card->plt_wake_cfg->irq_wifi);
-		if (!card->plt_wake_cfg->wake_by_wifi)
-			disable_irq(card->plt_wake_cfg->irq_wifi);
-	}
+	mwifiex_disable_wake(adapter);
 
 	return 0;
 }
@@ -354,13 +298,7 @@ static int mwifiex_sdio_suspend(struct device *dev)
 	}
 
 	adapter = card->adapter;
-
-	/* Enable platform specific wakeup interrupt */
-	if (card->plt_wake_cfg && card->plt_wake_cfg->irq_wifi >= 0) {
-		card->plt_wake_cfg->wake_by_wifi = false;
-		enable_irq(card->plt_wake_cfg->irq_wifi);
-		enable_irq_wake(card->plt_wake_cfg->irq_wifi);
-	}
+	mwifiex_enable_wake(adapter);
 
 	/* Enable the Host Sleep */
 	if (!mwifiex_enable_hs(adapter)) {
diff --git a/drivers/net/wireless/marvell/mwifiex/sdio.h b/drivers/net/wireless/marvell/mwifiex/sdio.h
index 07cdd23..b9fbc5c 100644
--- a/drivers/net/wireless/marvell/mwifiex/sdio.h
+++ b/drivers/net/wireless/marvell/mwifiex/sdio.h
@@ -154,12 +154,6 @@
 	a->mpa_rx.start_port = 0;					\
 } while (0)
 
-struct mwifiex_plt_wake_cfg {
-	struct device *dev;
-	int irq_wifi;
-	bool wake_by_wifi;
-};
