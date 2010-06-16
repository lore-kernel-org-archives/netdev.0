From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2010-06-16 v2
Date: Wed, 16 Jun 2010 16:13:00 -0400
Message-ID: <20100616201300.GD3138@tuxdriver.com>
References: <20100616182847.GB3138@tuxdriver.com>
 <20100616.115008.226776050.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100616.115008.226776050.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Jun 16, 2010 at 11:50:08AM -0700, David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Wed, 16 Jun 2010 14:28:48 -0400
> 
> > Here is another passel of of fixes intended for 2.6.35.  Included are
> > some build warning fixes, a PCI identifier, a fix for premature
> > IRQs during hostap initialization, a fix for a warning caused by
> > failing to cancel a scan watchdog in iwlwifi, a fix for a null
> > pointer dereference in iwlwifi, and a fix for a race condition in
> > the same driver.  Also included is the MAINTAINERS change for the
> > orphaning of the older Intel wireless drivers.  All but the last few
> > warning fixes have spent some time in linux-next already.
> > 
> > Please let me know if there are problems!
> 
> The patches removing unused function variables just to kill compile
> warnings are not appropriate, _at_ _all_.  They don't fix any real
> bug, and they definitely don't fix entries in the regression list do
> they?
> 
> Kill all of those and resend this pull request.

Fair enough...I dropped the warning fixes for the unused variables.
But I kept the ones related to uninitialized variables, since
those seem potentially more dangerous to ignore.  Hopefully that
is acceptable.

Please let me know if there are problems!

John

---

The following changes since commit fed396a585d8e1870b326f2e8e1888a72957abb8:
  Herbert Xu (1):
        bridge: Fix OOM crash in deliver_clone

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christoph Fritz (1):
      mac80211: fix warn, enum may be used uninitialized

Joerg Albert (1):
      p54pci: add Symbol AP-300 minipci adapters pciid

John W. Linville (1):
      iwlwifi: cancel scan watchdog in iwl_bg_abort_scan

Prarit Bhargava (1):
      libertas_tf: Fix warning in lbtf_rx for stats struct

Reinette Chatre (1):
      iwlwifi: serialize station management actions

Shanyu Zhao (1):
      iwlagn: verify flow id in compressed BA packet

Tim Gardner (1):
      hostap: Protect against initialization interrupt

Zhu Yi (1):
      wireless: orphan ipw2x00 drivers

 MAINTAINERS                                 |   10 ++--------
 drivers/net/wireless/hostap/hostap_cs.c     |   15 +++++++++++++--
 drivers/net/wireless/hostap/hostap_hw.c     |   13 +++++++++++++
 drivers/net/wireless/hostap/hostap_wlan.h   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-agn-tx.c   |    5 +++++
 drivers/net/wireless/iwlwifi/iwl-agn.c      |    8 ++++++--
 drivers/net/wireless/iwlwifi/iwl-scan.c     |    1 +
 drivers/net/wireless/iwlwifi/iwl-sta.c      |    4 ++++
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    9 +++++++--
 drivers/net/wireless/libertas_tf/main.c     |    2 +-
 drivers/net/wireless/p54/p54pci.c           |    2 ++
 net/mac80211/work.c                         |    2 +-
 12 files changed, 56 insertions(+), 17 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 83be538..837a754 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2966,20 +2966,14 @@ F:	drivers/net/ixgb/
 F:	drivers/net/ixgbe/
 
 INTEL PRO/WIRELESS 2100 NETWORK CONNECTION SUPPORT
-M:	Reinette Chatre <reinette.chatre@intel.com>
-M:	Intel Linux Wireless <ilw@linux.intel.com>
 L:	linux-wireless@vger.kernel.org
-W:	http://ipw2100.sourceforge.net
-S:	Odd Fixes
+S:	Orphan
 F:	Documentation/networking/README.ipw2100
 F:	drivers/net/wireless/ipw2x00/ipw2100.*
 
 INTEL PRO/WIRELESS 2915ABG NETWORK CONNECTION SUPPORT
-M:	Reinette Chatre <reinette.chatre@intel.com>
-M:	Intel Linux Wireless <ilw@linux.intel.com>
 L:	linux-wireless@vger.kernel.org
-W:	http://ipw2200.sourceforge.net
-S:	Odd Fixes
+S:	Orphan
 F:	Documentation/networking/README.ipw2200
 F:	drivers/net/wireless/ipw2x00/ipw2200.*
 
diff --git a/drivers/net/wireless/hostap/hostap_cs.c b/drivers/net/wireless/hostap/hostap_cs.c
index db72461..29b31a6 100644
--- a/drivers/net/wireless/hostap/hostap_cs.c
+++ b/drivers/net/wireless/hostap/hostap_cs.c
@@ -594,6 +594,7 @@ static int prism2_config(struct pcmcia_device *link)
 	local_info_t *local;
 	int ret = 1;
 	struct hostap_cs_priv *hw_priv;
+	unsigned long flags;
 
 	PDEBUG(DEBUG_FLOW, "prism2_config()\n");
 
@@ -625,9 +626,15 @@ static int prism2_config(struct pcmcia_device *link)
 	local->hw_priv = hw_priv;
 	hw_priv->link = link;
 
+	/*
+	 * Make sure the IRQ handler cannot proceed until at least
+	 * dev->base_addr is initialized.
+	 */
+	spin_lock_irqsave(&local->irq_init_lock, flags);
+
 	ret = pcmcia_request_irq(link, prism2_interrupt);
 	if (ret)
-		goto failed;
+		goto failed_unlock;
 
 	/*
 	 * This actually configures the PCMCIA socket -- setting up
@@ -636,11 +643,13 @@ static int prism2_config(struct pcmcia_device *link)
 	 */
 	ret = pcmcia_request_configuration(link, &link->conf);
 	if (ret)
-		goto failed;
+		goto failed_unlock;
 
 	dev->irq = link->irq;
 	dev->base_addr = link->io.BasePort1;
 
+	spin_unlock_irqrestore(&local->irq_init_lock, flags);
+
 	/* Finally, report what we've done */
 	printk(KERN_INFO "%s: index 0x%02x: ",
 	       dev_info, link->conf.ConfigIndex);
@@ -667,6 +676,8 @@ static int prism2_config(struct pcmcia_device *link)
 
 	return ret;
 
+ failed_unlock:
+	 spin_unlock_irqrestore(&local->irq_init_lock, flags);
  failed:
 	kfree(hw_priv);
 	prism2_release((u_long)link);
diff --git a/drivers/net/wireless/hostap/hostap_hw.c b/drivers/net/wireless/hostap/hostap_hw.c
index ff9b5c8..2f999fc 100644
--- a/drivers/net/wireless/hostap/hostap_hw.c
+++ b/drivers/net/wireless/hostap/hostap_hw.c
@@ -2621,6 +2621,18 @@ static irqreturn_t prism2_interrupt(int irq, void *dev_id)
 	iface = netdev_priv(dev);
 	local = iface->local;
 
+	/* Detect early interrupt before driver is fully configued */
+	spin_lock(&local->irq_init_lock);
+	if (!dev->base_addr) {
+		if (net_ratelimit()) {
+			printk(KERN_DEBUG "%s: Interrupt, but dev not configured\n",
+			       dev->name);
+		}
+		spin_unlock(&local->irq_init_lock);
+		return IRQ_HANDLED;
+	}
+	spin_unlock(&local->irq_init_lock);
+
 	prism2_io_debug_add(dev, PRISM2_IO_DEBUG_CMD_INTERRUPT, 0, 0);
 
 	if (local->func->card_present && !local->func->card_present(local)) {
@@ -3138,6 +3150,7 @@ prism2_init_local_data(struct prism2_helper_functions *funcs, int card_idx,
 	spin_lock_init(&local->cmdlock);
 	spin_lock_init(&local->baplock);
 	spin_lock_init(&local->lock);
+	spin_lock_init(&local->irq_init_lock);
 	mutex_init(&local->rid_bap_mtx);
 
 	if (card_idx < 0 || card_idx >= MAX_PARM_DEVICES)
diff --git a/drivers/net/wireless/hostap/hostap_wlan.h b/drivers/net/wireless/hostap/hostap_wlan.h
index 3d23891..1ba33be 100644
--- a/drivers/net/wireless/hostap/hostap_wlan.h
+++ b/drivers/net/wireless/hostap/hostap_wlan.h
@@ -654,7 +654,7 @@ struct local_info {
 	rwlock_t iface_lock; /* hostap_interfaces read lock; use write lock
 			      * when removing entries from the list.
 			      * TX and RX paths can use read lock. */
-	spinlock_t cmdlock, baplock, lock;
+	spinlock_t cmdlock, baplock, lock, irq_init_lock;
 	struct mutex rid_bap_mtx;
 	u16 infofid; /* MAC buffer id for info frame */
 	/* txfid, intransmitfid, next_txtid, and next_alloc are protected by
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
index a732f10..7d614c4 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn-tx.c
@@ -1299,6 +1299,11 @@ void iwlagn_rx_reply_compressed_ba(struct iwl_priv *priv,
 	sta_id = ba_resp->sta_id;
 	tid = ba_resp->tid;
 	agg = &priv->stations[sta_id].tid[tid].agg;
+	if (unlikely(agg->txq_id != scd_flow)) {
+		IWL_ERR(priv, "BA scd_flow %d does not match txq_id %d\n",
+			scd_flow, agg->txq_id);
+		return;
+	}
 
 	/* Find index just before block-ack window */
 	index = iwl_queue_dec_wrap(ba_resp_scd_ssn & 0xff, txq->q.n_bd);
diff --git a/drivers/net/wireless/iwlwifi/iwl-agn.c b/drivers/net/wireless/iwlwifi/iwl-agn.c
index 7726e67..24aff65 100644
--- a/drivers/net/wireless/iwlwifi/iwl-agn.c
+++ b/drivers/net/wireless/iwlwifi/iwl-agn.c
@@ -3391,10 +3391,12 @@ static int iwlagn_mac_sta_add(struct ieee80211_hw *hw,
 	int ret;
 	u8 sta_id;
 
-	sta_priv->common.sta_id = IWL_INVALID_STATION;
-
 	IWL_DEBUG_INFO(priv, "received request to add station %pM\n",
 			sta->addr);
+	mutex_lock(&priv->mutex);
+	IWL_DEBUG_INFO(priv, "proceeding to add station %pM\n",
+			sta->addr);
+	sta_priv->common.sta_id = IWL_INVALID_STATION;
 
 	atomic_set(&sta_priv->pending_frames, 0);
 	if (vif->type == NL80211_IFTYPE_AP)
@@ -3406,6 +3408,7 @@ static int iwlagn_mac_sta_add(struct ieee80211_hw *hw,
 		IWL_ERR(priv, "Unable to add station %pM (%d)\n",
 			sta->addr, ret);
 		/* Should we return success if return code is EEXIST ? */
+		mutex_unlock(&priv->mutex);
 		return ret;
 	}
 
@@ -3415,6 +3418,7 @@ static int iwlagn_mac_sta_add(struct ieee80211_hw *hw,
 	IWL_DEBUG_INFO(priv, "Initializing rate scaling for station %pM\n",
 		       sta->addr);
 	iwl_rs_rate_init(priv, sta, sta_id);
+	mutex_unlock(&priv->mutex);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index 5d3f51f..386c5f9 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -491,6 +491,7 @@ void iwl_bg_abort_scan(struct work_struct *work)
 
 	mutex_lock(&priv->mutex);
 
+	cancel_delayed_work_sync(&priv->scan_check);
 	set_bit(STATUS_SCAN_ABORTING, &priv->status);
 	iwl_send_scan_abort(priv);
 
diff --git a/drivers/net/wireless/iwlwifi/iwl-sta.c b/drivers/net/wireless/iwlwifi/iwl-sta.c
index 83a2636..c27c13f 100644
--- a/drivers/net/wireless/iwlwifi/iwl-sta.c
+++ b/drivers/net/wireless/iwlwifi/iwl-sta.c
@@ -1373,10 +1373,14 @@ int iwl_mac_sta_remove(struct ieee80211_hw *hw,
 
 	IWL_DEBUG_INFO(priv, "received request to remove station %pM\n",
 			sta->addr);
+	mutex_lock(&priv->mutex);
+	IWL_DEBUG_INFO(priv, "proceeding to remove station %pM\n",
+			sta->addr);
 	ret = iwl_remove_station(priv, sta_common->sta_id, sta->addr);
 	if (ret)
 		IWL_ERR(priv, "Error removing station %pM\n",
 			sta->addr);
+	mutex_unlock(&priv->mutex);
 	return ret;
 }
 EXPORT_SYMBOL(iwl_mac_sta_remove);
diff --git a/drivers/net/wireless/iwlwifi/iwl3945-base.c b/drivers/net/wireless/iwlwifi/iwl3945-base.c
index 6c353ca..a27872d 100644
--- a/drivers/net/wireless/iwlwifi/iwl3945-base.c
+++ b/drivers/net/wireless/iwlwifi/iwl3945-base.c
@@ -3437,10 +3437,13 @@ static int iwl3945_mac_sta_add(struct ieee80211_hw *hw,
 	bool is_ap = vif->type == NL80211_IFTYPE_STATION;
 	u8 sta_id;
 
-	sta_priv->common.sta_id = IWL_INVALID_STATION;
-
 	IWL_DEBUG_INFO(priv, "received request to add station %pM\n",
 			sta->addr);
+	mutex_lock(&priv->mutex);
+	IWL_DEBUG_INFO(priv, "proceeding to add station %pM\n",
+			sta->addr);
+	sta_priv->common.sta_id = IWL_INVALID_STATION;
+
 
 	ret = iwl_add_station_common(priv, sta->addr, is_ap, &sta->ht_cap,
 				     &sta_id);
@@ -3448,6 +3451,7 @@ static int iwl3945_mac_sta_add(struct ieee80211_hw *hw,
 		IWL_ERR(priv, "Unable to add station %pM (%d)\n",
 			sta->addr, ret);
 		/* Should we return success if return code is EEXIST ? */
+		mutex_unlock(&priv->mutex);
 		return ret;
 	}
 
@@ -3457,6 +3461,7 @@ static int iwl3945_mac_sta_add(struct ieee80211_hw *hw,
 	IWL_DEBUG_INFO(priv, "Initializing rate scaling for station %pM\n",
 		       sta->addr);
 	iwl3945_rs_rate_init(priv, sta, sta_id);
+	mutex_unlock(&priv->mutex);
 
 	return 0;
 }
diff --git a/drivers/net/wireless/libertas_tf/main.c b/drivers/net/wireless/libertas_tf/main.c
index 6a04c21..817fffc 100644
--- a/drivers/net/wireless/libertas_tf/main.c
+++ b/drivers/net/wireless/libertas_tf/main.c
@@ -549,7 +549,7 @@ int lbtf_rx(struct lbtf_private *priv, struct sk_buff *skb)
 
 	prxpd = (struct rxpd *) skb->data;
 
-	stats.flag = 0;
+	memset(&stats, 0, sizeof(stats));
 	if (!(prxpd->status & cpu_to_le16(MRVDRV_RXPD_STATUS_OK)))
 		stats.flag |= RX_FLAG_FAILED_FCS_CRC;
 	stats.freq = priv->cur_freq;
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 07c4528..a5ea89c 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -41,6 +41,8 @@ static DEFINE_PCI_DEVICE_TABLE(p54p_table) = {
 	{ PCI_DEVICE(0x1260, 0x3877) },
 	/* Intersil PRISM Javelin/Xbow Wireless LAN adapter */
 	{ PCI_DEVICE(0x1260, 0x3886) },
+	/* Intersil PRISM Xbow Wireless LAN adapter (Symbol AP-300) */
+	{ PCI_DEVICE(0x1260, 0xffff) },
 	{ },
 };
 
diff --git a/net/mac80211/work.c b/net/mac80211/work.c
index be3d4a6..b025dc7 100644
--- a/net/mac80211/work.c
+++ b/net/mac80211/work.c
@@ -715,7 +715,7 @@ static void ieee80211_work_rx_queued_mgmt(struct ieee80211_local *local,
 	struct ieee80211_rx_status *rx_status;
 	struct ieee80211_mgmt *mgmt;
 	struct ieee80211_work *wk;
-	enum work_action rma;
+	enum work_action rma = WORK_ACT_NONE;
 	u16 fc;
 
 	rx_status = (struct ieee80211_rx_status *) skb->cb;
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
