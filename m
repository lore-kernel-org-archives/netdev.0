From: drago01 <drago01-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] iwlwifi: fix rfkill deps and remove input device usage
Date: Fri, 27 Jun 2008 19:45:07 +0200
Message-ID: <f6ca9fed0806271045p1704b3c2l591dd887f5befdc0@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "Zhu, Yi" <yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	randy.dunlap-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org, "Ivo van Doorn" <ivdoorn-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 27, 2008 at 7:07 PM, John W. Linville
<linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
> On Fri, Jun 27, 2008 at 05:54:06PM +0200, drago01 wrote:
>> On Fri, Jun 27, 2008 at 5:35 PM, John W. Linville
>> <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org> wrote:
>>
>> > Randy Dunlap (1):
>> >      iwlwifi: fix build for CONFIG_INPUT=n
>>
>> this one was NACKED by Ivo (well not exactly this but the 3945
>> version, and Yi posted an updated patch)
>
> I have no record of that.  Could someone send me a correct patch on
> top of this one?

Patch attached for iwl4965/5000 on top of Randy's patch.
Untested due to lack of hardware but it should work fine.

-------------------
This patch fixes the rfkill deps for iwl4965/5000
and removes the input device usage.

Signed-off-by: Adel Gadllah <adel.gadllah-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

diff --git a/drivers/net/wireless/iwlwifi/Kconfig
b/drivers/net/wireless/iwlwifi/Kconfig
index d7ea32f..b628a44 100644
--- a/drivers/net/wireless/iwlwifi/Kconfig
+++ b/drivers/net/wireless/iwlwifi/Kconfig
@@ -8,7 +8,6 @@ config IWLCORE
 	select MAC80211_LEDS if IWLWIFI_LEDS
 	select LEDS_CLASS if IWLWIFI_LEDS
 	select RFKILL if IWLWIFI_RFKILL
-	select RFKILL_INPUT if (IWLWIFI_RFKILL && INPUT)

 config IWLWIFI_LEDS
 	bool
diff --git a/drivers/net/wireless/iwlwifi/iwl-rfkill.c
b/drivers/net/wireless/iwlwifi/iwl-rfkill.c
index ffefbb4..f5211eb 100644
--- a/drivers/net/wireless/iwlwifi/iwl-rfkill.c
+++ b/drivers/net/wireless/iwlwifi/iwl-rfkill.c
@@ -98,36 +98,11 @@ int iwl_rfkill_init(struct iwl_priv *priv)
 	priv->rfkill_mngr.rfkill->dev.class->suspend = NULL;
 	priv->rfkill_mngr.rfkill->dev.class->resume = NULL;

-#if defined(CONFIG_RFKILL_INPUT) || defined(CONFIG_RFKILL_INPUT_MODULE)
-	priv->rfkill_mngr.input_dev = input_allocate_device();
-	if (!priv->rfkill_mngr.input_dev) {
-		IWL_ERROR("Unable to allocate rfkill input device.\n");
-		ret = -ENOMEM;
-		goto freed_rfkill;
-	}
-
-	priv->rfkill_mngr.input_dev->name = priv->cfg->name;
-	priv->rfkill_mngr.input_dev->phys = wiphy_name(priv->hw->wiphy);
-	priv->rfkill_mngr.input_dev->id.bustype = BUS_HOST;
-	priv->rfkill_mngr.input_dev->id.vendor = priv->pci_dev->vendor;
-	priv->rfkill_mngr.input_dev->dev.parent = device;
-	priv->rfkill_mngr.input_dev->evbit[0] = BIT(EV_KEY);
-	set_bit(KEY_WLAN, priv->rfkill_mngr.input_dev->keybit);
-#endif
-
 	ret = rfkill_register(priv->rfkill_mngr.rfkill);
 	if (ret) {
 		IWL_ERROR("Unable to register rfkill: %d\n", ret);
-		goto free_input_dev;
-	}
-
-#if defined(CONFIG_RFKILL_INPUT) || defined(CONFIG_RFKILL_INPUT_MODULE)
-	ret = input_register_device(priv->rfkill_mngr.input_dev);
-	if (ret) {
-		IWL_ERROR("Unable to register rfkill input device: %d\n", ret);
 		goto unregister_rfkill;
 	}
-#endif

 	IWL_DEBUG_RF_KILL("RFKILL initialization complete.\n");
 	return ret;
@@ -136,12 +111,6 @@ unregister_rfkill:
 	rfkill_unregister(priv->rfkill_mngr.rfkill);
 	priv->rfkill_mngr.rfkill = NULL;

-free_input_dev:
-#if defined(CONFIG_RFKILL_INPUT) || defined(CONFIG_RFKILL_INPUT_MODULE)
-	input_free_device(priv->rfkill_mngr.input_dev);
-	priv->rfkill_mngr.input_dev = NULL;
-#endif
-
 freed_rfkill:
 	if (priv->rfkill_mngr.rfkill != NULL)
 		rfkill_free(priv->rfkill_mngr.rfkill);
@@ -156,13 +125,6 @@ EXPORT_SYMBOL(iwl_rfkill_init);
 void iwl_rfkill_unregister(struct iwl_priv *priv)
 {

-#if defined(CONFIG_RFKILL_INPUT) || defined(CONFIG_RFKILL_INPUT_MODULE)
-	if (priv->rfkill_mngr.input_dev)
-		input_unregister_device(priv->rfkill_mngr.input_dev);
-	input_free_device(priv->rfkill_mngr.input_dev);
-	priv->rfkill_mngr.input_dev = NULL;
-#endif
-
 	if (priv->rfkill_mngr.rfkill)
 		rfkill_unregister(priv->rfkill_mngr.rfkill);

@@ -173,7 +135,6 @@ EXPORT_SYMBOL(iwl_rfkill_unregister);
 /* set rf-kill to the right state. */
 void iwl_rfkill_set_hw_state(struct iwl_priv *priv)
 {
