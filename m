From: reinette chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: Re: [2.6.31-rc1] iwlagn (4965): regression when hardware rf switch
 is used
Date: Tue, 30 Jun 2009 10:44:18 -0700
Message-ID: <1246383858.17896.527.camel@rc-desk>
References: <200906291128.05639.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200906291128.05639.elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Frans,

On Mon, 2009-06-29 at 02:28 -0700, Frans Pop wrote:

> But with 2.6.31 I get this:
> [disable]
> wlan0: deauthenticating by local choice (reason=3)
> iwlagn 0000:10:00.0: Error sending REPLY_ADD_STA: enqueue_hcmd failed: -5
> mac80211-phy0: failed to remove key (0, 00:14:c1:38:e5:15) from hardware (-5)
> iwlagn 0000:10:00.0: Error sending REPLY_ADD_STA: enqueue_hcmd failed: -5
> mac80211-phy0: failed to remove key (1, ff:ff:ff:ff:ff:ff) from hardware (-5)

Here the driver is trying to remove the keys from the device but with
rfkill enabled it is not able to do so.

> usb 3-1: USB disconnect, address 2
> [enable]
> usb 3-1: new full speed USB device using uhci_hcd and address 3
> usb 3-1: configuration #1 chosen from 1 choice
> 
> A lot uglier with those errors. And after that I have to run ifdown/ifup
> before networking is up again (ifup only does not work as it will complain
> "interface already configured"):

yes, as Johannes mentioned this is a new required step to get networking
back up after rfkill state changes.


> BTW, would it make sense to bring back the first two lines shown with .30
> (or at least the first one):
>    iwlagn 0000:10:00.0: Radio Frequency Kill Switch is On:
>    Kill switch must be turned off for wireless networking to work.
> IMHO it's good to register the reason for the disconnect.

It would be nice to get this from the upper layers, but the device can
do it also as it is getting the interrupt. 

Could you please try the patch below? It will not send command to device
when rfkill is enabled and it will also print messages indicating that
rfkill state changed.


>From 9935d8bab97448f9ab5418602849172dcb0ba00a Mon Sep 17 00:00:00 2001
From: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Date: Tue, 30 Jun 2009 10:14:25 -0700
Subject: [PATCH] iwlagn: do not send key clear commands when rfkill enabled

Do all key clearing except sending sommands to device when rfkill
enabled. When rfkill enabled the interface is brought down and will
be brought back up correctly after rfkill is enabled again.

Same change is not needed for iwl3945 as it ignores return code when
sending key clearing command to device.

Signed-off-by: Reinette Chatre <reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---
 drivers/net/wireless/iwlwifi/iwl-agn.c |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-sta.c |   12 ++++++++++++
 drivers/net/wireless/iwlwifi/iwl-tx.c  |    2 +-
 3 files changed, 15 insertions(+), 3 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index ad50022..32aebd7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -960,7 +960,7 @@ static void iwl_irq_tasklet_legacy(struct iwl_priv *priv)
 				CSR_GP_CNTRL_REG_FLAG_HW_RF_KILL_SW))
 			hw_rf_kill = 1;
 
-		IWL_DEBUG_RF_KILL(priv, "RF_KILL bit toggled to %s.\n",
+		IWL_WARN(priv, "RF_KILL bit toggled to %s.\n",
 				hw_rf_kill ? "disable radio" : "enable radio");
 
 		priv->isr_stats.rfkill++;
@@ -1133,7 +1133,7 @@ static void iwl_irq_tasklet(struct iwl_priv *priv)
 				CSR_GP_CNTRL_REG_FLAG_HW_RF_KILL_SW))
 			hw_rf_kill = 1;
 
-		IWL_DEBUG_RF_KILL(priv, "RF_KILL bit toggled to %s.\n",
+		IWL_WARN(priv, "RF_KILL bit toggled to %s.\n",
 				hw_rf_kill ? "disable radio" : "enable radio");
 
 		priv->isr_stats.rfkill++;
diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wireless/iwlwifi/iwl-sta.c
index 2addf73..ffd5c61 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
@@ -566,6 +566,8 @@ int iwl_remove_default_wep_key(struct iwl_priv *priv,
 	unsigned long flags;
 
 	spin_lock_irqsave(&priv->sta_lock, flags);
+	IWL_DEBUG_WEP(priv, "Removing default WEP key: idx=%d\n",
+		      keyconf->keyidx);
 
 	if (!test_and_clear_bit(keyconf->keyidx, &priv->ucode_key_table))
 		IWL_ERR(priv, "index %d not used in uCode key table.\n",
@@ -573,6 +575,11 @@ int iwl_remove_default_wep_key(struct iwl_priv *priv,
 
 	priv->default_wep_key--;
 	memset(&priv->wep_keys[keyconf->keyidx], 0, sizeof(priv->wep_keys[0]));
+	if (iwl_is_rfkill(priv)) {
+		IWL_DEBUG_WEP(priv, "Not sending REPLY_WEPKEY command due to RFKILL.\n");
+		spin_unlock_irqrestore(&priv->sta_lock, flags);
+		return 0;
+	}
 	ret = iwl_send_static_wepkey_cmd(priv, 1);
 	IWL_DEBUG_WEP(priv, "Remove default WEP key: idx=%d ret=%d\n",
 		      keyconf->keyidx, ret);
@@ -853,6 +860,11 @@ int iwl_remove_dynamic_key(struct iwl_priv *priv,
 	priv->stations[sta_id].sta.sta.modify_mask = STA_MODIFY_KEY_MASK;
 	priv->stations[sta_id].sta.mode = STA_CONTROL_MODIFY_MSK;
 
+	if (iwl_is_rfkill(priv)) {
+		IWL_DEBUG_WEP(priv, "Not sending REPLY_ADD_STA command because RFKILL enabled. \n");
+		spin_unlock_irqrestore(&priv->sta_lock, flags);
+		return 0;
+	}
 	ret =  iwl_send_add_sta(priv, &priv->stations[sta_id].sta, CMD_ASYNC);
 	spin_unlock_irqrestore(&priv->sta_lock, flags);
 	return ret;
diff --git a/drivers/net/wireless/iwlwifi/iwl-tx.c b/drivers/net/wireless/iwlwifi/iwl-tx.c
index 753fca3..acff7a2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-tx.c
@@ -939,7 +939,7 @@ int iwl_enqueue_hcmd(struct iwl_priv *priv, struct iwl_host_cmd *cmd)
 	       !(cmd->meta.flags & CMD_SIZE_HUGE));
 
 	if (iwl_is_rfkill(priv)) {
-		IWL_DEBUG_INFO(priv, "Not sending command - RF KILL");
+		IWL_DEBUG_INFO(priv, "Not sending command - RF KILL\n");
 		return -EIO;
 	}
 
-- 
1.5.6.3



--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
