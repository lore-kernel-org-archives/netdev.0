From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-10-27
Date: Mon, 27 Oct 2008 18:00:49 -0400
Message-ID: <20081027220049.GI20389@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:56298 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751338AbYJ0WBm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2008 18:01:42 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Another round of fixes intended for 2.6.28 (got it right this time!)...

"p54: fix misbehavings when firmware can't be found" is a little big,
but it fixes a double free of an IRQ (bug 11782). "ath5k: Reset key
cache on interface up, thus fixing resume" is a little sizable too, but
it moves some code intelligently to fix a regression we introduce on
resume.  The other stuff is cleanups and a kernel-doc fix, as well as an
initialization fix for rfkill.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 8b5f12d04b2e93842f3dda01f029842047bf3f81:
  Florian Westphal (1):
        syncookies: fix inclusion of tcp options in syn-ack

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

Christian Lamparter (2):
      p54: fix misbehavings when firmware can't be found
      p54: fix build warnings

Dmitry Baryshkov (1):
      RFKILL: fix input layer initialisation

Elias Oltmanns (1):
      ath5k: Reset key cache on interface up, thus fixing resume

John W. Linville (1):
      mac80211: correct warnings in minstrel rate control algorithm

Randy Dunlap (1):
      mac80211.h: fix kernel-doc excesses

 drivers/net/wireless/ath5k/base.c       |   33 +++-----
 drivers/net/wireless/p54/p54common.c    |    5 +-
 drivers/net/wireless/p54/p54pci.c       |  132 +++++++++++++++---------------
 include/net/mac80211.h                  |   11 +--
 net/mac80211/rc80211_minstrel_debugfs.c |    6 +-
 net/rfkill/rfkill-input.c               |    5 +
 6 files changed, 93 insertions(+), 99 deletions(-)

diff --git a/drivers/net/wireless/ath5k/base.c b/drivers/net/wireless/ath5k/base.c
index 0f1d6bd..cfd4d05 100644
--- a/drivers/net/wireless/ath5k/base.c
+++ b/drivers/net/wireless/ath5k/base.c
@@ -661,8 +661,7 @@ ath5k_pci_resume(struct pci_dev *pdev)
 {
 	struct ieee80211_hw *hw = pci_get_drvdata(pdev);
 	struct ath5k_softc *sc = hw->priv;
-	struct ath5k_hw *ah = sc->ah;
-	int i, err;
+	int err;
 
 	pci_restore_state(pdev);
 
@@ -688,16 +687,6 @@ ath5k_pci_resume(struct pci_dev *pdev)
 		goto err_irq;
 	ath5k_led_enable(sc);
 
-	/*
-	 * Reset the key cache since some parts do not
-	 * reset the contents on initial power up or resume.
-	 *
-	 * FIXME: This may need to be revisited when mac80211 becomes
-	 *        aware of suspend/resume.
-	 */
-	for (i = 0; i < AR5K_KEYTABLE_SIZE; i++)
-		ath5k_hw_reset_key(ah, i);
-
 	return 0;
 err_irq:
 	free_irq(pdev->irq, sc);
@@ -718,7 +707,6 @@ ath5k_attach(struct pci_dev *pdev, struct ieee80211_hw *hw)
 	struct ath5k_softc *sc = hw->priv;
 	struct ath5k_hw *ah = sc->ah;
 	u8 mac[ETH_ALEN];
-	unsigned int i;
 	int ret;
 
 	ATH5K_DBG(sc, ATH5K_DEBUG_ANY, "devid 0x%x\n", pdev->device);
@@ -737,13 +725,6 @@ ath5k_attach(struct pci_dev *pdev, struct ieee80211_hw *hw)
 		__set_bit(ATH_STAT_MRRETRY, sc->status);
 
 	/*
-	 * Reset the key cache since some parts do not
-	 * reset the contents on initial power up.
-	 */
-	for (i = 0; i < AR5K_KEYTABLE_SIZE; i++)
-		ath5k_hw_reset_key(ah, i);
-
-	/*
 	 * Collect the channel list.  The 802.11 layer
 	 * is resposible for filtering this list based
 	 * on settings like the phy mode and regulatory
@@ -2202,7 +2183,8 @@ ath5k_beacon_config(struct ath5k_softc *sc)
 static int
 ath5k_init(struct ath5k_softc *sc, bool is_resume)
 {
-	int ret;
+	struct ath5k_hw *ah = sc->ah;
+	int ret, i;
 
 	mutex_lock(&sc->lock);
 
@@ -2235,10 +2217,17 @@ ath5k_init(struct ath5k_softc *sc, bool is_resume)
 	if (ret)
 		goto done;
 
+	/*
+	 * Reset the key cache since some parts do not reset the
+	 * contents on initial power up or resume from suspend.
+	 */
+	for (i = 0; i < AR5K_KEYTABLE_SIZE; i++)
+		ath5k_hw_reset_key(ah, i);
+
 	__set_bit(ATH_STAT_STARTED, sc->status);
 
 	/* Set ack to be sent at low bit-rates */
-	ath5k_hw_set_ack_bitrate_high(sc->ah, false);
+	ath5k_hw_set_ack_bitrate_high(ah, false);
 
 	mod_timer(&sc->calib_tim, round_jiffies(jiffies +
 			msecs_to_jiffies(ath5k_calinterval * 1000)));
diff --git a/drivers/net/wireless/p54/p54common.c b/drivers/net/wireless/p54/p54common.c
index 2d022f8..827ca03 100644
--- a/drivers/net/wireless/p54/p54common.c
+++ b/drivers/net/wireless/p54/p54common.c
@@ -319,7 +319,7 @@ static int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 	void *tmp;
 	int err;
 	u8 *end = (u8 *)eeprom + len;
-	u16 synth;
+	u16 synth = 0;
 	DECLARE_MAC_BUF(mac);
 
 	wrap = (struct eeprom_pda_wrap *) eeprom;
@@ -422,7 +422,8 @@ static int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 		entry = (void *)entry + (entry_len + 1)*2;
 	}
 
-	if (!priv->iq_autocal || !priv->output_limit || !priv->curve_data) {
+	if (!synth || !priv->iq_autocal || !priv->output_limit ||
+	    !priv->curve_data) {
 		printk(KERN_ERR "p54: not all required entries found in eeprom!\n");
 		err = -EINVAL;
 		goto err;
diff --git a/drivers/net/wireless/p54/p54pci.c b/drivers/net/wireless/p54/p54pci.c
index 1c2a02a..88b3cad 100644
--- a/drivers/net/wireless/p54/p54pci.c
+++ b/drivers/net/wireless/p54/p54pci.c
@@ -346,68 +346,6 @@ static void p54p_tx(struct ieee80211_hw *dev, struct p54_control_hdr *data,
 		printk(KERN_INFO "%s: tx overflow.\n", wiphy_name(dev->wiphy));
 }
 
-static int p54p_open(struct ieee80211_hw *dev)
-{
-	struct p54p_priv *priv = dev->priv;
-	int err;
-
-	init_completion(&priv->boot_comp);
-	err = request_irq(priv->pdev->irq, &p54p_interrupt,
-			  IRQF_SHARED, "p54pci", dev);
-	if (err) {
-		printk(KERN_ERR "%s: failed to register IRQ handler\n",
-		       wiphy_name(dev->wiphy));
-		return err;
-	}
-
-	memset(priv->ring_control, 0, sizeof(*priv->ring_control));
-	err = p54p_upload_firmware(dev);
-	if (err) {
-		free_irq(priv->pdev->irq, dev);
-		return err;
-	}
-	priv->rx_idx_data = priv->tx_idx_data = 0;
-	priv->rx_idx_mgmt = priv->tx_idx_mgmt = 0;
-
-	p54p_refill_rx_ring(dev, 0, priv->ring_control->rx_data,
-		ARRAY_SIZE(priv->ring_control->rx_data), priv->rx_buf_data);
-
-	p54p_refill_rx_ring(dev, 2, priv->ring_control->rx_mgmt,
-		ARRAY_SIZE(priv->ring_control->rx_mgmt), priv->rx_buf_mgmt);
-
-	P54P_WRITE(ring_control_base, cpu_to_le32(priv->ring_control_dma));
-	P54P_READ(ring_control_base);
-	wmb();
-	udelay(10);
-
-	P54P_WRITE(int_enable, cpu_to_le32(ISL38XX_INT_IDENT_INIT));
-	P54P_READ(int_enable);
-	wmb();
-	udelay(10);
-
-	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_RESET));
-	P54P_READ(dev_int);
-
-	if (!wait_for_completion_interruptible_timeout(&priv->boot_comp, HZ)) {
-		printk(KERN_ERR "%s: Cannot boot firmware!\n",
-		       wiphy_name(dev->wiphy));
-		free_irq(priv->pdev->irq, dev);
-		return -ETIMEDOUT;
-	}
-
-	P54P_WRITE(int_enable, cpu_to_le32(ISL38XX_INT_IDENT_UPDATE));
-	P54P_READ(int_enable);
-	wmb();
-	udelay(10);
-
-	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_UPDATE));
-	P54P_READ(dev_int);
-	wmb();
-	udelay(10);
-
-	return 0;
-}
-
 static void p54p_stop(struct ieee80211_hw *dev)
 {
 	struct p54p_priv *priv = dev->priv;
@@ -474,6 +412,68 @@ static void p54p_stop(struct ieee80211_hw *dev)
 	memset(ring_control, 0, sizeof(*ring_control));
 }
 
+static int p54p_open(struct ieee80211_hw *dev)
+{
+	struct p54p_priv *priv = dev->priv;
+	int err;
+
+	init_completion(&priv->boot_comp);
+	err = request_irq(priv->pdev->irq, &p54p_interrupt,
+			  IRQF_SHARED, "p54pci", dev);
+	if (err) {
+		printk(KERN_ERR "%s: failed to register IRQ handler\n",
+		       wiphy_name(dev->wiphy));
+		return err;
+	}
+
+	memset(priv->ring_control, 0, sizeof(*priv->ring_control));
+	err = p54p_upload_firmware(dev);
+	if (err) {
+		free_irq(priv->pdev->irq, dev);
+		return err;
+	}
+	priv->rx_idx_data = priv->tx_idx_data = 0;
+	priv->rx_idx_mgmt = priv->tx_idx_mgmt = 0;
+
+	p54p_refill_rx_ring(dev, 0, priv->ring_control->rx_data,
+		ARRAY_SIZE(priv->ring_control->rx_data), priv->rx_buf_data);
+
+	p54p_refill_rx_ring(dev, 2, priv->ring_control->rx_mgmt,
+		ARRAY_SIZE(priv->ring_control->rx_mgmt), priv->rx_buf_mgmt);
+
+	P54P_WRITE(ring_control_base, cpu_to_le32(priv->ring_control_dma));
+	P54P_READ(ring_control_base);
+	wmb();
+	udelay(10);
+
+	P54P_WRITE(int_enable, cpu_to_le32(ISL38XX_INT_IDENT_INIT));
+	P54P_READ(int_enable);
+	wmb();
+	udelay(10);
+
+	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_RESET));
+	P54P_READ(dev_int);
+
+	if (!wait_for_completion_interruptible_timeout(&priv->boot_comp, HZ)) {
+		printk(KERN_ERR "%s: Cannot boot firmware!\n",
+		       wiphy_name(dev->wiphy));
+		p54p_stop(dev);
+		return -ETIMEDOUT;
+	}
+
+	P54P_WRITE(int_enable, cpu_to_le32(ISL38XX_INT_IDENT_UPDATE));
+	P54P_READ(int_enable);
+	wmb();
+	udelay(10);
+
+	P54P_WRITE(dev_int, cpu_to_le32(ISL38XX_DEV_INT_UPDATE));
+	P54P_READ(dev_int);
+	wmb();
+	udelay(10);
+
+	return 0;
+}
+
 static int __devinit p54p_probe(struct pci_dev *pdev,
 				const struct pci_device_id *id)
 {
@@ -556,11 +556,13 @@ static int __devinit p54p_probe(struct pci_dev *pdev,
 	spin_lock_init(&priv->lock);
 	tasklet_init(&priv->rx_tasklet, p54p_rx_tasklet, (unsigned long)dev);
 
-	p54p_open(dev);
+	err = p54p_open(dev);
+	if (err)
+		goto err_free_common;
 	err = p54_read_eeprom(dev);
 	p54p_stop(dev);
 	if (err)
-		goto err_free_desc;
+		goto err_free_common;
 
 	err = ieee80211_register_hw(dev);
 	if (err) {
@@ -573,8 +575,6 @@ static int __devinit p54p_probe(struct pci_dev *pdev,
 
  err_free_common:
 	p54_free_common(dev);
-
- err_free_desc:
 	pci_free_consistent(pdev, sizeof(*priv->ring_control),
 			    priv->ring_control, priv->ring_control_dma);
 
diff --git a/include/net/mac80211.h b/include/net/mac80211.h
index d861197..8856e2d 100644
--- a/include/net/mac80211.h
+++ b/include/net/mac80211.h
@@ -1474,7 +1474,6 @@ void ieee80211_tx_status_irqsafe(struct ieee80211_hw *hw,
  * ieee80211_beacon_get - beacon generation function
  * @hw: pointer obtained from ieee80211_alloc_hw().
  * @vif: &struct ieee80211_vif pointer from &struct ieee80211_if_init_conf.
- * @control: will be filled with information needed to send this beacon.
  *
  * If the beacon frames are generated by the host system (i.e., not in
  * hardware/firmware), the low-level driver uses this function to receive
@@ -1575,7 +1574,6 @@ __le16 ieee80211_generic_frame_duration(struct ieee80211_hw *hw,
  * ieee80211_get_buffered_bc - accessing buffered broadcast and multicast frames
  * @hw: pointer as obtained from ieee80211_alloc_hw().
  * @vif: &struct ieee80211_vif pointer from &struct ieee80211_if_init_conf.
- * @control: will be filled with information needed to send returned frame.
  *
  * Function for accessing buffered broadcast and multicast frames. If
  * hardware/firmware does not implement buffering of broadcast/multicast
@@ -1623,9 +1621,8 @@ unsigned int ieee80211_hdrlen(__le16 fc);
  *
  * @keyconf: the parameter passed with the set key
  * @skb: the skb for which the key is needed
- * @rc4key: a buffer to which the key will be written
  * @type: TBD
- * @key: TBD
+ * @key: a buffer to which the key will be written
  */
 void ieee80211_get_tkip_key(struct ieee80211_key_conf *keyconf,
 				struct sk_buff *skb,
@@ -1726,7 +1723,8 @@ void ieee80211_iterate_active_interfaces_atomic(struct ieee80211_hw *hw,
  * @hw: pointer as obtained from ieee80211_alloc_hw().
  * @ra: receiver address of the BA session recipient
  * @tid: the TID to BA on.
- * @return: success if addBA request was sent, failure otherwise
+ *
+ * Return: success if addBA request was sent, failure otherwise
  *
  * Although mac80211/low level driver/user space application can estimate
  * the need to start aggregation on a certain RA/TID, the session level
@@ -1764,7 +1762,8 @@ void ieee80211_start_tx_ba_cb_irqsafe(struct ieee80211_hw *hw, const u8 *ra,
  * @ra: receiver address of the BA session recipient
  * @tid: the TID to stop BA.
  * @initiator: if indicates initiator DELBA frame will be sent.
- * @return: error if no sta with matching da found, success otherwise
+ *
+ * Return: error if no sta with matching da found, success otherwise
  *
  * Although mac80211/low level driver/user space application can estimate
  * the need to stop aggregation on a certain RA/TID, the session level
diff --git a/net/mac80211/rc80211_minstrel_debugfs.c b/net/mac80211/rc80211_minstrel_debugfs.c
index 0b024cd..98f4807 100644
--- a/net/mac80211/rc80211_minstrel_debugfs.c
+++ b/net/mac80211/rc80211_minstrel_debugfs.c
@@ -94,8 +94,8 @@ minstrel_stats_open(struct inode *inode, struct file *file)
 				prob / 10, prob % 10,
 				mr->last_success,
 				mr->last_attempts,
-				mr->succ_hist,
-				mr->att_hist);
+				(unsigned long long)mr->succ_hist,
+				(unsigned long long)mr->att_hist);
 	}
 	p += sprintf(p, "\nTotal packet count::    ideal %d      "
 			"lookaround %d\n\n",
@@ -106,7 +106,7 @@ minstrel_stats_open(struct inode *inode, struct file *file)
 	return 0;
 }
 
-static int
+static ssize_t
 minstrel_stats_read(struct file *file, char __user *buf, size_t len, loff_t *o)
 {
 	struct minstrel_stats_info *ms;
diff --git a/net/rfkill/rfkill-input.c b/net/rfkill/rfkill-input.c
index 21124ec..bfdade7 100644
--- a/net/rfkill/rfkill-input.c
+++ b/net/rfkill/rfkill-input.c
@@ -256,6 +256,11 @@ static struct input_handler rfkill_handler = {
 
 static int __init rfkill_handler_init(void)
 {
+	unsigned long last_run = jiffies - msecs_to_jiffies(500);
+	rfkill_wlan.last = last_run;
+	rfkill_bt.last = last_run;
+	rfkill_uwb.last = last_run;
+	rfkill_wimax.last = last_run;
 	return input_register_handler(&rfkill_handler);
 }
 
-- 
John W. Linville		Linux should be at the core
linville@tuxdriver.com			of your literate lifestyle.
