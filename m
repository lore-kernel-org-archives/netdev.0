From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless-2.6 2008-03-27
Date: Thu, 27 Mar 2008 15:32:12 -0400
Message-ID: <20080327193212.GA10820@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dave,

A few more for 2.6.25...please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 732c8bd590625e8bc0b88313b82930e336b2bec4:
  Herbert Xu (1):
        [IPSEC]: Fix BEET output

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Holger Schurig (1):
      libertas: fix spinlock recursion bug

Ivo van Doorn (1):
      rt2x00: Ignore set_state(STATE_SLEEP) failure

Julia Lawall (1):
      drivers/net/wireless/iwlwifi/iwl-4965.c: correct use of ! and &

 drivers/net/wireless/iwlwifi/iwl-4965.c |    2 +-
 drivers/net/wireless/libertas/if_cs.c   |    2 --
 drivers/net/wireless/rt2x00/rt2x00dev.c |   13 +++++++++++--
 3 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-4965.c b/drivers/net/wireless/iwlwifi/iwl-4965.c
index d727de8..6576757 100644
--- a/drivers/net/wireless/iwlwifi/iwl-4965.c
+++ b/drivers/net/wireless/iwlwifi/iwl-4965.c
@@ -4589,7 +4589,7 @@ static u8 iwl4965_is_fat_tx_allowed(struct iwl4965_priv *priv,
 
 	if (sta_ht_inf) {
 		if ((!sta_ht_inf->ht_supported) ||
-		   (!sta_ht_inf->cap & IEEE80211_HT_CAP_SUP_WIDTH))
+		   (!(sta_ht_inf->cap & IEEE80211_HT_CAP_SUP_WIDTH)))
 			return 0;
 	}
 
diff --git a/drivers/net/wireless/libertas/if_cs.c b/drivers/net/wireless/libertas/if_cs.c
index 5a9cadb..038c66a 100644
--- a/drivers/net/wireless/libertas/if_cs.c
+++ b/drivers/net/wireless/libertas/if_cs.c
@@ -677,9 +677,7 @@ sbi_get_int_status_exit:
 
 	/* Card has a command result for us */
 	if (*ireg & IF_CS_C_S_CMD_UPLD_RDY) {
-		spin_lock(&priv->driver_lock);
 		ret = if_cs_receive_cmdres(priv, priv->upld_buf, &priv->upld_len);
-		spin_unlock(&priv->driver_lock);
 		if (ret < 0)
 			lbs_pr_err("could not receive cmd from card\n");
 	}
diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index bd305f7..e873a39 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -1393,11 +1393,20 @@ int rt2x00lib_suspend(struct rt2x00_dev *rt2x00dev, pm_message_t state)
 
 exit:
 	/*
-	 * Set device mode to sleep for power management.
+	 * Set device mode to sleep for power management,
+	 * on some hardware this call seems to consistently fail.
+	 * From the specifications it is hard to tell why it fails,
+	 * and if this is a "bad thing".
+	 * Overall it is safe to just ignore the failure and
+	 * continue suspending. The only downside is that the
+	 * device will not be in optimal power save mode, but with
+	 * the radio and the other components already disabled the
+	 * device is as good as disabled.
 	 */
 	retval = rt2x00dev->ops->lib->set_device_state(rt2x00dev, STATE_SLEEP);
 	if (retval)
-		return retval;
+		WARNING(rt2x00dev, "Device failed to enter sleep state, "
+			"continue suspending.\n");
 
 	return 0;
 }
-- 
John W. Linville
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
