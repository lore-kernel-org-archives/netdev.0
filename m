From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless-2.6 2008-03-04
Date: Tue, 4 Mar 2008 16:29:53 -0500
Message-ID: <20080304212953.GB3158@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:3051 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755184AbYCDVc0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Mar 2008 16:32:26 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

Here is today's round of fixes for the 2.6.25 tree.  These are mostly
simple fixes, even one-liners.  The rc80211-pid patch is, of course, an
exception...

conflicts:

net/mac80211/rc80211_pid_algo.c

After pushing to Linus and pulling back into net-2.6.26, simply take
all the _first_ blocks (i.e. between "<<<<" and "====") of conflicting
lines.  This is due to commit "rc80211-pid: fix rate adjustment"
being a backport of a change already in net-2.6.26 with the same title.

Please let me know if there are problems!

Thanks,

John

---

Individual patches are available here:

	http://www.kernel.org/pub/linux/kernel/people/linville/wireless-2.6/

---

The following changes since commit 976dde010e513a9c7c3117a32b7b015f84b37430:
  Linus Torvalds (1):
        Merge branch 'slab-linus' of git://git.kernel.org/.../christoph/vm

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git master

David Woodhouse (1):
      libertas: fix sanity check on sequence number in command response

Johannes Berg (2):
      p54: fix EEPROM structure endianness
      p54: fix eeprom parser length sanity checks

Jussi Kivilinna (1):
      rndis_wlan: fix broken data copy

Michael Buesch (1):
      b43legacy: Fix module init message

Sebastian Siewior (1):
      libertas: compare the current command with response

Stefano Brivio (1):
      rc80211-pid: fix rate adjustment

Yoichi Yuasa (1):
      ssb: Add pcibios_enable_device() return value check

 drivers/net/wireless/b43legacy/main.c   |    2 +-
 drivers/net/wireless/libertas/cmdresp.c |    8 +--
 drivers/net/wireless/p54common.c        |   20 ++++---
 drivers/net/wireless/p54common.h        |    8 +-
 drivers/net/wireless/rndis_wlan.c       |    8 +--
 drivers/ssb/driver_pcicore.c            |    5 +-
 net/mac80211/rc80211_pid_algo.c         |   92 ++++++++++++++----------------
 7 files changed, 70 insertions(+), 73 deletions(-)

diff --git a/drivers/net/wireless/b43legacy/main.c b/drivers/net/wireless/b43legacy/main.c
index c39de42..5f3f34e 100644
--- a/drivers/net/wireless/b43legacy/main.c
+++ b/drivers/net/wireless/b43legacy/main.c
@@ -3829,7 +3829,7 @@ static void b43legacy_print_driverinfo(void)
 #ifdef CONFIG_B43LEGACY_DMA
 	feat_dma = "D";
 #endif
-	printk(KERN_INFO "Broadcom 43xx driver loaded "
+	printk(KERN_INFO "Broadcom 43xx-legacy driver loaded "
 	       "[ Features: %s%s%s%s%s, Firmware-ID: "
 	       B43legacy_SUPPORTED_FIRMWARE_ID " ]\n",
 	       feat_pci, feat_leds, feat_rfkill, feat_pio, feat_dma);
diff --git a/drivers/net/wireless/libertas/cmdresp.c b/drivers/net/wireless/libertas/cmdresp.c
index 159216a..bdc6a1c 100644
--- a/drivers/net/wireless/libertas/cmdresp.c
+++ b/drivers/net/wireless/libertas/cmdresp.c
@@ -562,9 +562,7 @@ int lbs_process_rx_command(struct lbs_private *priv)
 	}
 
 	resp = (void *)priv->upld_buf;
-
-	curcmd = le16_to_cpu(resp->command);
-
+	curcmd = le16_to_cpu(priv->cur_cmd->cmdbuf->command);
 	respcmd = le16_to_cpu(resp->command);
 	result = le16_to_cpu(resp->result);
 
@@ -572,9 +570,9 @@ int lbs_process_rx_command(struct lbs_private *priv)
 		     respcmd, le16_to_cpu(resp->seqnum), priv->upld_len, jiffies);
 	lbs_deb_hex(LBS_DEB_HOST, "CMD_RESP", (void *) resp, priv->upld_len);
 
-	if (resp->seqnum != resp->seqnum) {
+	if (resp->seqnum != priv->cur_cmd->cmdbuf->seqnum) {
 		lbs_pr_info("Received CMD_RESP with invalid sequence %d (expected %d)\n",
-			    le16_to_cpu(resp->seqnum), le16_to_cpu(resp->seqnum));
+			    le16_to_cpu(resp->seqnum), le16_to_cpu(priv->cur_cmd->cmdbuf->seqnum));
 		spin_unlock_irqrestore(&priv->driver_lock, flags);
 		ret = -1;
 		goto done;
diff --git a/drivers/net/wireless/p54common.c b/drivers/net/wireless/p54common.c
index 5cda49a..d191e05 100644
--- a/drivers/net/wireless/p54common.c
+++ b/drivers/net/wireless/p54common.c
@@ -166,18 +166,23 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 	struct p54_common *priv = dev->priv;
 	struct eeprom_pda_wrap *wrap = NULL;
 	struct pda_entry *entry;
-	int i = 0;
 	unsigned int data_len, entry_len;
 	void *tmp;
 	int err;
+	u8 *end = (u8 *)eeprom + len;
 
 	wrap = (struct eeprom_pda_wrap *) eeprom;
-	entry = (void *)wrap->data + wrap->len;
-	i += 2;
-	i += le16_to_cpu(entry->len)*2;
-	while (i < len) {
+	entry = (void *)wrap->data + le16_to_cpu(wrap->len);
+
+	/* verify that at least the entry length/code fits */
+	while ((u8 *)entry <= end - sizeof(*entry)) {
 		entry_len = le16_to_cpu(entry->len);
 		data_len = ((entry_len - 1) << 1);
+
+		/* abort if entry exceeds whole structure */
+		if ((u8 *)entry + sizeof(*entry) + data_len > end)
+			break;
+
 		switch (le16_to_cpu(entry->code)) {
 		case PDR_MAC_ADDRESS:
 			SET_IEEE80211_PERM_ADDR(dev, entry->data);
@@ -249,13 +254,12 @@ int p54_parse_eeprom(struct ieee80211_hw *dev, void *eeprom, int len)
 			priv->version = *(u8 *)(entry->data + 1);
 			break;
 		case PDR_END:
-			i = len;
+			/* make it overrun */
+			entry_len = len;
 			break;
 		}
 
 		entry = (void *)entry + (entry_len + 1)*2;
-		i += 2;
-		i += entry_len*2;
 	}
 
 	if (!priv->iq_autocal || !priv->output_limit || !priv->curve_data) {
diff --git a/drivers/net/wireless/p54common.h b/drivers/net/wireless/p54common.h
index a721334..b67ff34 100644
--- a/drivers/net/wireless/p54common.h
+++ b/drivers/net/wireless/p54common.h
@@ -53,10 +53,10 @@ struct pda_entry {
 } __attribute__ ((packed));
 
 struct eeprom_pda_wrap {
-	u32 magic;
-	u16 pad;
-	u16 len;
-	u32 arm_opcode;
+	__le32 magic;
+	__le16 pad;
+	__le16 len;
+	__le32 arm_opcode;
 	u8 data[0];
 } __attribute__ ((packed));
 
diff --git a/drivers/net/wireless/rndis_wlan.c b/drivers/net/wireless/rndis_wlan.c
index d9460ae..10b776c 100644
--- a/drivers/net/wireless/rndis_wlan.c
+++ b/drivers/net/wireless/rndis_wlan.c
@@ -260,7 +260,7 @@ struct NDIS_802_11_KEY {
 	__le32 KeyLength;
 	u8 Bssid[6];
 	u8 Padding[6];
-	__le64 KeyRSC;
+	u8 KeyRSC[8];
 	u8 KeyMaterial[32];
 } __attribute__((packed));
 
@@ -1508,7 +1508,7 @@ static int rndis_iw_set_encode_ext(struct net_device *dev,
 	struct usbnet *usbdev = dev->priv;
 	struct rndis_wext_private *priv = get_rndis_wext_priv(usbdev);
 	struct NDIS_802_11_KEY ndis_key;
-	int i, keyidx, ret;
+	int keyidx, ret;
 	u8 *addr;
 
 	keyidx = wrqu->encoding.flags & IW_ENCODE_INDEX;
@@ -1543,9 +1543,7 @@ static int rndis_iw_set_encode_ext(struct net_device *dev,
 	ndis_key.KeyIndex = cpu_to_le32(keyidx);
 
 	if (ext->ext_flags & IW_ENCODE_EXT_RX_SEQ_VALID) {
-		for (i = 0; i < 6; i++)
-			ndis_key.KeyRSC |=
-				cpu_to_le64(ext->rx_seq[i] << (i * 8));
+		memcpy(ndis_key.KeyRSC, ext->rx_seq, 6);
 		ndis_key.KeyIndex |= cpu_to_le32(1 << 29);
 	}
 
diff --git a/drivers/ssb/driver_pcicore.c b/drivers/ssb/driver_pcicore.c
index 07ab48d..74b9a8a 100644
--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -111,7 +111,10 @@ static void __init ssb_fixup_pcibridge(struct pci_dev *dev)
 
 	/* Enable PCI bridge bus mastering and memory space */
 	pci_set_master(dev);
-	pcibios_enable_device(dev, ~0);
+	if (pcibios_enable_device(dev, ~0) < 0) {
+		ssb_printk(KERN_ERR "PCI: SSB bridge enable failed\n");
+		return;
+	}
 
 	/* Enable PCI bridge BAR1 prefetch and burst */
 	pci_write_config_dword(dev, SSB_BAR1_CONTROL, 3);
diff --git a/net/mac80211/rc80211_pid_algo.c b/net/mac80211/rc80211_pid_algo.c
index c339571..3b77410 100644
--- a/net/mac80211/rc80211_pid_algo.c
+++ b/net/mac80211/rc80211_pid_algo.c
@@ -2,7 +2,7 @@
  * Copyright 2002-2005, Instant802 Networks, Inc.
  * Copyright 2005, Devicescape Software, Inc.
  * Copyright 2007, Mattias Nissler <mattias.nissler@gmx.de>
- * Copyright 2007, Stefano Brivio <stefano.brivio@polimi.it>
+ * Copyright 2007-2008, Stefano Brivio <stefano.brivio@polimi.it>
  *
  * This program is free software; you can redistribute it and/or modify
  * it under the terms of the GNU General Public License version 2 as
@@ -63,72 +63,66 @@
  * RC_PID_ARITH_SHIFT.
  */
 
-
-/* Shift the adjustment so that we won't switch to a lower rate if it exhibited
- * a worse failed frames behaviour and we'll choose the highest rate whose
- * failed frames behaviour is not worse than the one of the original rate
- * target. While at it, check that the adjustment is within the ranges. Then,
- * provide the new rate index. */
-static int rate_control_pid_shift_adjust(struct rc_pid_rateinfo *r,
-					 int adj, int cur, int l)
-{
-	int i, j, k, tmp;
-
-	j = r[cur].rev_index;
-	i = j + adj;
-
-	if (i < 0)
-		return r[0].index;
-	if (i >= l - 1)
-		return r[l - 1].index;
-
-	tmp = i;
-
-	if (adj < 0) {
-		for (k = j; k >= i; k--)
-			if (r[k].diff <= r[j].diff)
-				tmp = k;
-	} else {
-		for (k = i + 1; k + i < l; k++)
-			if (r[k].diff <= r[i].diff)
-				tmp = k;
-	}
-
-	return r[tmp].index;
-}
-
+/* Adjust the rate while ensuring that we won't switch to a lower rate if it
+ * exhibited a worse failed frames behaviour and we'll choose the highest rate
+ * whose failed frames behaviour is not worse than the one of the original rate
+ * target. While at it, check that the new rate is valid. */
 static void rate_control_pid_adjust_rate(struct ieee80211_local *local,
 					 struct sta_info *sta, int adj,
 					 struct rc_pid_rateinfo *rinfo)
 {
 	struct ieee80211_sub_if_data *sdata;
 	struct ieee80211_hw_mode *mode;
-	int newidx;
-	int maxrate;
-	int back = (adj > 0) ? 1 : -1;
+	int cur_sorted, new_sorted, probe, tmp, n_bitrates;
+	int cur = sta->txrate;
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(sta->dev);
 
 	mode = local->oper_hw_mode;
-	maxrate = sdata->bss ? sdata->bss->max_ratectrl_rateidx : -1;
+	n_bitrates = mode->num_rates;
 
-	newidx = rate_control_pid_shift_adjust(rinfo, adj, sta->txrate,
-					       mode->num_rates);
+	/* Map passed arguments to sorted values. */
+	cur_sorted = rinfo[cur].rev_index;
+	new_sorted = cur_sorted + adj;
 
-	while (newidx != sta->txrate) {
-		if (rate_supported(sta, mode, newidx) &&
-		    (maxrate < 0 || newidx <= maxrate)) {
-			sta->txrate = newidx;
-			break;
-		}
+	/* Check limits. */
+	if (new_sorted < 0)
+		new_sorted = rinfo[0].rev_index;
+	else if (new_sorted >= n_bitrates)
+		new_sorted = rinfo[n_bitrates - 1].rev_index;
 
-		newidx += back;
+	tmp = new_sorted;
+
+	if (adj < 0) {
+		/* Ensure that the rate decrease isn't disadvantageous. */
+		for (probe = cur_sorted; probe >= new_sorted; probe--)
+			if (rinfo[probe].diff <= rinfo[cur_sorted].diff &&
+			    rate_supported(sta, mode, rinfo[probe].index))
+				tmp = probe;
+	} else {
+		/* Look for rate increase with zero (or below) cost. */
+		for (probe = new_sorted + 1; probe < n_bitrates; probe++)
+			if (rinfo[probe].diff <= rinfo[new_sorted].diff &&
+			    rate_supported(sta, mode, rinfo[probe].index))
+				tmp = probe;
 	}
 
+	/* Fit the rate found to the nearest supported rate. */
+	do {
+		if (rate_supported(sta, mode, rinfo[tmp].index)) {
+			sta->txrate = rinfo[tmp].index;
+			break;
+		}
+		if (adj < 0)
+			tmp--;
+		else
+			tmp++;
+	} while (tmp < n_bitrates && tmp >= 0);
+
 #ifdef CONFIG_MAC80211_DEBUGFS
 	rate_control_pid_event_rate_change(
 		&((struct rc_pid_sta_info *)sta->rate_ctrl_priv)->events,
-		newidx, mode->rates[newidx].rate);
+		cur, mode->rates[cur].rate);
 #endif
 }
 
-- 
John W. Linville
linville@tuxdriver.com
