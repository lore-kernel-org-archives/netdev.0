From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-07-02
Date: Wed, 2 Jul 2008 16:18:51 -0400
Message-ID: <20080702201851.GA10272@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

A few stragglers for 2.6.26...

Let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 2fe195cfe3e53c144d247b2768e37732e8eae4d8:
  Patrick McHardy (1):
        net: fib_rules: fix error code for unsupported families

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Rick Farrington (1):
      iwlwifi: fix incorrect 5GHz rates reported in monitor mode

Zhu Yi (1):
      iwlwifi: drop skb silently for Tx request in monitor mode

andrey-W/OLz77bvjtBDgjK7y7TUQ@public.gmane.org (1):
      libertas: support USB persistence on suspend/resume (resend)

 drivers/net/wireless/iwlwifi/iwl-3945.c     |    6 +++++-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    6 +++++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    3 ++-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    3 ++-
 drivers/net/wireless/libertas/if_usb.c      |    1 +
 5 files changed, 15 insertions(+), 4 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-3945.c b/drivers/net/wireless/iwlwifi/iwl-3945.c
index 62a3d8f..f5387a7 100644
--- a/drivers/net/wireless/iwlwifi/iwl-3945.c
+++ b/drivers/net/wireless/iwlwifi/iwl-3945.c
@@ -588,8 +588,12 @@ static void iwl3945_add_radiotap(struct iwl3945_priv *priv,
 
 	if (rate == -1)
 		iwl3945_rt->rt_rate = 0;
-	else
+	else {
+		if (stats->band == IEEE80211_BAND_5GHZ)
+			rate += IWL_FIRST_OFDM_RATE;
+
 		iwl3945_rt->rt_rate = iwl3945_rates[rate].ieee;
+	}
 
 	/* antenna number */
 	antenna = phy_flags_hw & RX_RES_PHY_FLAGS_ANTENNA_MSK;
diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index bf19eb8..de330ae 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -3528,8 +3528,12 @@ static void iwl4965_add_radiotap(struct iwl_priv *priv,
 
 	if (rate == -1)
 		iwl4965_rt->rt_rate = 0;
-	else
+	else {
+		if (stats->band == IEEE80211_BAND_5GHZ)
+			rate += IWL_FIRST_OFDM_RATE;
+
 		iwl4965_rt->rt_rate = iwl4965_rates[rate].ieee;
+	}
 
 	/*
 	 * "antenna number"
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index b1b3c52..6027e11 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -6687,7 +6687,8 @@ static int iwl3945_mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb,
 
 	if (priv->iw_mode == IEEE80211_IF_TYPE_MNTR) {
 		IWL_DEBUG_MAC80211("leave - monitor\n");
-		return -1;
+		dev_kfree_skb_any(skb);
+		return 0;
 	}
 
 	IWL_DEBUG_TX("dev->xmit(%d bytes) at rate 0x%02x\n", skb->len,
diff --git a/drivers/net/wireless/iwlwifi/iwl4965-base.c b/drivers/net/wireless/iwlwifi/iwl4965-base.c
index 5ed16ce..0bd55bb 100644
--- a/drivers/net/wireless/iwlwifi/iwl4965-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl4965-base.c
@@ -6237,7 +6237,8 @@ static int iwl4965_mac_tx(struct ieee80211_hw *hw, struct sk_buff *skb,
 
 	if (priv->iw_mode == IEEE80211_IF_TYPE_MNTR) {
 		IWL_DEBUG_MAC80211("leave - monitor\n");
-		return -1;
+		dev_kfree_skb_any(skb);
+		return 0;
 	}
 
 	IWL_DEBUG_TX("dev->xmit(%d bytes) at rate 0x%02x\n", skb->len,
diff --git a/drivers/net/wireless/libertas/if_usb.c b/drivers/net/wireless/libertas/if_usb.c
index 8032df7..36288b2 100644
--- a/drivers/net/wireless/libertas/if_usb.c
+++ b/drivers/net/wireless/libertas/if_usb.c
@@ -925,6 +925,7 @@ static struct usb_driver if_usb_driver = {
 	.id_table = if_usb_table,
 	.suspend = if_usb_suspend,
 	.resume = if_usb_resume,
+	.reset_resume = if_usb_resume,
 };
 
 static int __init if_usb_init_module(void)
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
