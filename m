From: "John W. Linville" <linville@tuxdriver.com>
Subject: wireless-dev updated -- 15 November 2006
Date: Wed, 15 Nov 2006 22:22:07 -0500
Message-ID: <20061116032157.GD3439@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:10510 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1031075AbWKPDbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Nov 2006 22:31:14 -0500
Received: from ra.tuxdriver.com (ra.tuxdriver.com [127.0.0.1])
	by ra.tuxdriver.com (8.13.7/8.13.7) with ESMTP id kAG3UVhh030954
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 15 Nov 2006 22:30:36 -0500
Received: (from uucp@localhost)
	by ra.tuxdriver.com (8.13.7/8.13.6/Submit) with UUCP id kAG3TxkB030903
	for netdev@vger.kernel.org; Wed, 15 Nov 2006 22:29:59 -0500
Received: from linville-t43.mobile (linville-t43.mobile [127.0.0.1])
	by linville-t43.mobile (8.13.8/8.13.8) with ESMTP id kAG3M7W6007922
	for <netdev@vger.kernel.org>; Wed, 15 Nov 2006 22:22:07 -0500
Received: (from linville@localhost)
	by linville-t43.mobile (8.13.8/8.13.8/Submit) id kAG3M7mG007921
	for netdev@vger.kernel.org; Wed, 15 Nov 2006 22:22:07 -0500
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Another round of merges.  Wireless developers, please pull...

---

The following changes since commit aa3e54d82345b2b373603632b04d3cacd59c0c0d:
  John W. Linville:
        Merge branch 'from-linus'

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git

David Kimdon:
      d80211: remove bitfields from ieee80211_tx_control
      d80211: remove bitfields from ieee80211_tx_status
      d80211: remove bitfields from ieee80211_key_conf
      d80211: remove bitfields from ieee80211_hw
      d80211: remove bitfields from ieee80211_conf
      d80211: endian annotations for ieee80211_frame_info, etc.
      d80211: fix usage of capability field for ibss mode

Hong Liu:
      d80211: hardware TKIP support

 drivers/net/wireless/d80211/adm8211/adm8211.c      |   24 +--
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c  |    3 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c |   24 ++-
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c  |    3 
 drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c |   17 +-
 drivers/net/wireless/d80211/p54/prism54common.c    |   28 ++--
 drivers/net/wireless/d80211/rt2x00/rt2400pci.c     |   38 +++--
 drivers/net/wireless/d80211/rt2x00/rt2500pci.c     |   38 +++--
 drivers/net/wireless/d80211/rt2x00/rt2500usb.c     |   38 +++--
 drivers/net/wireless/d80211/rt2x00/rt61pci.c       |   38 +++--
 drivers/net/wireless/d80211/rt2x00/rt73usb.c       |   38 +++--
 include/net/d80211.h                               |  138 +++++++++++--------
 include/net/d80211_common.h                        |   30 ++--
 net/d80211/ieee80211.c                             |  142 ++++++++++++--------
 net/d80211/ieee80211_ioctl.c                       |   36 +++--
 net/d80211/ieee80211_scan.c                        |    4 -
 net/d80211/ieee80211_sta.c                         |    8 +
 net/d80211/ieee80211_sysfs.c                       |    7 +
 net/d80211/sta_info.c                              |    2 
 net/d80211/sta_info.h                              |    2 
 net/d80211/tkip.c                                  |   30 +++-
 net/d80211/tkip.h                                  |    4 +
 net/d80211/wpa.c                                   |   72 +++++++---
 23 files changed, 427 insertions(+), 337 deletions(-)

diff --git a/drivers/net/wireless/d80211/adm8211/adm8211.c b/drivers/net/wireless/d80211/adm8211/adm8211.c
index 0244ab0..7456486 100644
--- a/drivers/net/wireless/d80211/adm8211/adm8211.c
+++ b/drivers/net/wireless/d80211/adm8211/adm8211.c
@@ -428,17 +428,20 @@ static void adm8211_interrupt_tci(struct
 
 		if (status & TDES0_STATUS_ES) {
 			stats->tx_errors++;
-			priv->tx_buffers[entry].tx_status.ack = 0;
+			priv->tx_buffers[entry].tx_status.flags &=
+						~IEEE80211_TX_STATUS_ACK;
 
 			if (status & (TDES0_STATUS_TUF | TDES0_STATUS_TRO))
 				stats->tx_fifo_errors++;
 		} else
-			priv->tx_buffers[entry].tx_status.ack = 1;
+			priv->tx_buffers[entry].tx_status.flags |=
+						IEEE80211_TX_STATUS_ACK;
 
 		pci_unmap_single(priv->pdev, priv->tx_buffers[entry].mapping,
 				 priv->tx_buffers[entry].skb->len, PCI_DMA_TODEVICE);
 
-		if (priv->tx_buffers[entry].tx_status.control.req_tx_status ||
+		if ((priv->tx_buffers[entry].tx_status.control.flags &
+		     IEEE80211_TXCTL_REQ_TX_STATUS) ||
 		    !is_multicast_ether_addr(ieee80211_get_DA(&priv->tx_buffers[entry].hdr))) {
 			struct ieee80211_hdr *hdr;
 			size_t hdrlen = ieee80211_get_hdrlen(le16_to_cpu(priv->tx_buffers[entry].hdr.frame_control));
@@ -1870,7 +1873,7 @@ static int adm8211_tx(struct net_device 
 	if (short_preamble)
 		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_SHORT_PREAMBLE);
 
-	if (control->use_rts_cts)
+	if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
 		txhdr->header_control |= cpu_to_le16(ADM8211_TXHDRCTL_ENABLE_RTS);
 
 	if (fc & IEEE80211_FCTL_PROTECTED)
@@ -2022,17 +2025,10 @@ #endif
 
 	hw->version = 2;
 	hw->name = "adm8211";
-	hw->host_gen_beacon = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;	// however, FCS is kept in promisc mode
-	hw->host_broadcast_ps_buffering = 0;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 0;
-	hw->no_tkip_wmm_hwaccel = 1;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 0;
-	hw->fraglist = 0;
+	hw->flags = IEEE80211_HW_WEP_INCLUDE_IV | IEEE80211_HW_NO_TKIP_WMM_HWACCEL;
+	// however, IEEE80211_HW_RX_INCLUDES_FCS in promisc mode
+
 	hw->channel_change_time = 1000;
 
 	hw->num_modes = 1;
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
index 24fc47d..bae2b0c 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_dma.c
@@ -1127,7 +1127,8 @@ void bcm43xx_dma_handle_txstatus(struct 
 			 * status of the transmission.
 			 * Some fields of txstat are already filled in dma_tx().
 			 */
-			meta->txstat.ack = status->acked;
+			if (status->acked)
+				meta->txstat.flags |= IEEE80211_TX_STATUS_ACK;
 			meta->txstat.retry_count = status->frame_count - 1;
 			ieee80211_tx_status_irqsafe(bcm->net_dev, meta->skb, &(meta->txstat));
 			/* skb is freed by ieee80211_tx_status_irqsafe() */
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
index 6c36ece..bdf41d3 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_main.c
@@ -3562,9 +3562,9 @@ static int bcm43xx_net_config(struct net
 		bcm43xx_radio_selectchannel(bcm, conf->channel_val, 0);
 
 	/* Enable/Disable ShortSlot timing. */
-	if (conf->short_slot_time != bcm->short_slot) {
+	if (!!(conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) != bcm->short_slot) {
 		assert(phy->type == BCM43xx_PHYTYPE_G);
-		if (conf->short_slot_time)
+		if (conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME)
 			bcm43xx_short_slot_timing_enable(bcm);
 		else
 			bcm43xx_short_slot_timing_disable(bcm);
@@ -3577,7 +3577,7 @@ static int bcm43xx_net_config(struct net
 	}
 
 	/* Hide/Show the SSID (AP mode only). */
-	if (conf->ssid_hidden) {
+	if (conf->flags & IEEE80211_CONF_SSID_HIDDEN) {
 		bcm43xx_write32(bcm->wlcore, BCM43xx_MMIO_STATUS_BITFIELD,
 				bcm43xx_read32(bcm->wlcore, BCM43xx_MMIO_STATUS_BITFIELD)
 				| BCM43xx_SBF_NO_SSID_BCAST);
@@ -3667,7 +3667,7 @@ static int bcm43xx_net_set_key(struct ne
 	}
 	if (bcm43xx_current_phy(bcm)->fw == BCM43xx_FW_3) {
 		/* No support for HW-crypto with v3 firmware. */
-		key->force_sw_encrypt = 1;
+		key->flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 		err = 0;
 		goto out_unlock;
 	}
@@ -3678,7 +3678,7 @@ static int bcm43xx_net_set_key(struct ne
 		if (algorithm == BCM43xx_SEC_ALGO_TKIP) {
 			/* FIXME: No TKIP hardware encryption for now. */
 			err = 0;
-			key->force_sw_encrypt = 1;
+			key->flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 			goto out_unlock;
 		}
 
@@ -3702,7 +3702,7 @@ static int bcm43xx_net_set_key(struct ne
 					 bcm43xx_hf_read(bcm) &
 					 ~BCM43xx_HF_USEDEFKEYS);
 		}
-		key->force_sw_encrypt = 0;
+		key->flags &= ~IEEE80211_KEY_FORCE_SW_ENCRYPT;
 		break;
 	case DISABLE_KEY:
 		if (is_broadcast_ether_addr(addr)) {
@@ -3735,7 +3735,8 @@ out:
 	if (!err) {
 		dprintk(KERN_DEBUG PFX "Using %s based encryption for keyidx: %d, "
 			"mac: " MAC_FMT "\n",
-			(key->force_sw_encrypt) ? "software" : "hardware",
+			(key->flags & IEEE80211_KEY_FORCE_SW_ENCRYPT) ?
+			"software" : "hardware",
 			key->keyidx, MAC_ARG(addr));
 	}
 	return err;
@@ -3970,9 +3971,10 @@ #endif
 		goto out;
 	ieee->version = IEEE80211_VERSION;
 	ieee->name = KBUILD_MODNAME;
-	ieee->host_gen_beacon_template = 1;
-	ieee->rx_includes_fcs = 0;
-	ieee->monitor_during_oper = 1;
+	ieee->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
+		      IEEE80211_HW_MONITOR_DURING_OPER |
+		      IEEE80211_HW_DEVICE_HIDES_WEP |
+		      IEEE80211_HW_WEP_INCLUDE_IV;
 	ieee->maxssi = BCM43xx_RX_MAX_SSI;
 	ieee->tx = bcm43xx_net_hard_start_xmit;
 	ieee->open = bcm43xx_net_open;
@@ -3984,12 +3986,10 @@ #endif
 	ieee->config_interface = bcm43xx_config_interface;
 	ieee->set_multicast_list = bcm43xx_set_multicast_list;
 	ieee->set_key = bcm43xx_net_set_key;
-	ieee->device_hides_wep = 1;
 	ieee->get_stats = bcm43xx_net_get_stats;
 	ieee->queues = 1;
 	ieee->get_tx_stats = bcm43xx_net_get_tx_stats;
 	ieee->conf_tx = bcm43xx_net_conf_tx;
-	ieee->wep_include_iv = 1;
 
 	net_dev = ieee80211_alloc_hw(sizeof(*bcm), bcm43xx_netdev_setup);
 	if (!net_dev) {
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
index 58879f3..1c16f2c 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_pio.c
@@ -500,7 +500,8 @@ void bcm43xx_pio_handle_txstatus(struct 
 	queue->tx_devq_packets--;
 	queue->tx_devq_used -= (packet->skb->len + phy->txhdr_size);
 
-	packet->txstat.ack = status->acked;
+	if (status->acked)
+		packet->txstat.flags |= IEEE80211_TX_STATUS_ACK;
 	packet->txstat.retry_count = status->frame_count - 1;
 	ieee80211_tx_status_irqsafe(bcm->net_dev, packet->skb,
 				    &(packet->txstat));
diff --git a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
index 134ba50..b5675eb 100644
--- a/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/d80211/bcm43xx/bcm43xx_xmit.c
@@ -294,7 +294,7 @@ static void generate_txhdr_fw3(struct bc
 	u16 wsec_rate = 0;
 
 	/* No support for HW encryption with v3 firmware. */
-	assert(txctl->do_not_encrypt || txctl->key_idx < 0);
+	assert((txctl->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT) || txctl->key_idx < 0);
 
 	/* Now construct the TX header. */
 	memset(txhdr, 0, sizeof(*txhdr));
@@ -331,14 +331,14 @@ static void generate_txhdr_fw3(struct bc
 		   & BCM43xx_TXHDRCTL_ANTENNADIV_MASK;
 
 	/* Set the FLAGS field */
-	if (!txctl->no_ack)
+	if (!(txctl->flags & IEEE80211_TXCTL_NO_ACK))
 		flags |= BCM43xx_TXHDRFLAG_EXPECTACK;
 	if (!(((fctl & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
 	      ((fctl & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PSPOLL)))
 		flags |= 0x10;
 	if (fallback_ofdm_modulation)
 		flags |= BCM43xx_TXHDRFLAG_FALLBACKOFDM;
-	if (txctl->first_fragment)
+	if (txctl->flags & IEEE80211_TXCTL_FIRST_FRAGMENT)
 		flags |= BCM43xx_TXHDRFLAG_FIRSTFRAGMENT;
 
 	/* Set WSEC/RATE field */
@@ -350,7 +350,7 @@ static void generate_txhdr_fw3(struct bc
 	 *        if we are on 80211g. If we get too many
 	 *        failures (hidden nodes), we should switch back to RTS/CTS.
 	 */
-	if (txctl->use_rts_cts) {
+	if (txctl->flags & IEEE80211_TXCTL_USE_RTS_CTS) {
 		bcm43xx_generate_rts(phy, txhdr, &flags,
 				     txctl->rts_cts_rate,
 				     wireless_header);
@@ -371,7 +371,8 @@ static void generate_txhdr_fw4(struct bc
 	const struct bcm43xx_phyinfo *phy = bcm43xx_current_phy(bcm);
 	const struct bcm43xx_radioinfo *radio = bcm43xx_current_radio(bcm);
 	const struct ieee80211_hdr *wlhdr = (const struct ieee80211_hdr *)fragment_data;
-	int use_encryption = ((!txctl->do_not_encrypt) && (txctl->key_idx >= 0));
+	int use_encryption = ((!(txctl->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT)) &&
+			      (txctl->key_idx >= 0));
 	u16 fctl = le16_to_cpu(wlhdr->frame_control);
 	u8 rate, rate_fb;
 	int rate_ofdm, rate_fb_ofdm;
@@ -461,17 +462,17 @@ static void generate_txhdr_fw4(struct bc
 	}
 
 	/* MAC control */
-	if (!txctl->no_ack)
+	if (!(txctl->flags & IEEE80211_TXCTL_NO_ACK))
 		mac_ctl |= BCM43xx_TX4_MAC_ACK;
 	if (!(((fctl & IEEE80211_FCTL_FTYPE) == IEEE80211_FTYPE_CTL) &&
 	      ((fctl & IEEE80211_FCTL_STYPE) == IEEE80211_STYPE_PSPOLL)))
 		mac_ctl |= BCM43xx_TX4_MAC_HWSEQ;
-	if (txctl->first_fragment)
+	if (txctl->flags & IEEE80211_TXCTL_FIRST_FRAGMENT)
 		mac_ctl |= BCM43xx_TX4_MAC_STMSDU;
 	if (phy->type == BCM43xx_PHYTYPE_A)
 		mac_ctl |= BCM43xx_TX4_MAC_5GHZ;
 
-	if (txctl->use_rts_cts) {
+	if (txctl->flags & IEEE80211_TXCTL_USE_RTS_CTS) {
 		//TODO
 	}
 
diff --git a/drivers/net/wireless/d80211/p54/prism54common.c b/drivers/net/wireless/d80211/p54/prism54common.c
index 7fbcfa8..318e4f6 100644
--- a/drivers/net/wireless/d80211/p54/prism54common.c
+++ b/drivers/net/wireless/d80211/p54/prism54common.c
@@ -250,7 +250,8 @@ static void p54_rx_frame_sent(struct net
 			memcpy(&status.control, range->control,
 			       sizeof(status.control));
 			kfree(range->control);
-			status.ack = (payload->status >> 8) & 1;
+			if ((payload->status >> 8) & 1)
+				status.flags |= IEEE80211_TX_STATUS_ACK;
 			status.ack_signal = le16_to_cpu(payload->ack_rssi);
 			skb_pull(entry, sizeof(*hdr) + sizeof(struct p54_tx_control_allocdata));
 			ieee80211_tx_status_irqsafe(dev, entry, &status);
@@ -396,7 +397,7 @@ static int p54_tx(struct net_device *dev
 
 	hdr->magic1 = __constant_cpu_to_le16(0x0010);
 	hdr->len = skb->len - sizeof(*hdr);
-	hdr->type = control->no_ack ? 0 : 1;
+	hdr->type = (control->flags & IEEE80211_TXCTL_NO_ACK) ? 0 : 1;
 	hdr->retry1 = hdr->retry2 = control->retry_limit;
 	p54_assign_address(dev, skb, hdr, skb->len, control_copy);
 
@@ -405,8 +406,10 @@ static int p54_tx(struct net_device *dev
 	txhdr->wep_key_present = 0;
 	txhdr->wep_key_len = 0;
 	txhdr->frame_type = __constant_cpu_to_le32(0x4);
-	txhdr->magic4 = control->no_ack ? 0 : __constant_cpu_to_le32(0x7f020000);
-	txhdr->magic5 = control->no_ack ? 0 : __constant_cpu_to_le32(0x23);
+	txhdr->magic4 = (control->flags & IEEE80211_TXCTL_NO_ACK) ?
+			 0 : __constant_cpu_to_le32(0x7f020000);
+	txhdr->magic5 = (control->flags & IEEE80211_TXCTL_NO_ACK) ?
+			 0 : __constant_cpu_to_le32(0x23);
 
 	priv->tx(dev, hdr, skb->len, 0);
 	return 0;
@@ -630,17 +633,12 @@ void p54_init_common(struct net_device *
 	priv->modes[0].num_channels = ARRAY_SIZE(p54_channels);
 	priv->modes[0].channels = priv->channels;
 	hw->version = 2;
-	hw->host_gen_beacon = 0;
-	hw->host_gen_beacon_template = 1;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 1;
-	hw->host_broadcast_ps_buffering = 1; /* not sure */
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1; /* TODO: check */
-	hw->no_tkip_wmm_hwaccel = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 0; /* FIXME: check */
-	hw->fraglist = 0;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING | /* not sure */
+		    IEEE80211_HW_RX_INCLUDES_FCS |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK; /* TODO: check */
+		    /* IEEE80211_HW_MONITOR_DURING_OPER FIXME: check */
 	hw->channel_change_time = 1000;	/* TODO: find actual value */
 
 	hw->num_modes = 2;
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
index 356e6e3..d3efc11 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2400pci.c
@@ -742,7 +742,8 @@ static void rt2400pci_config_rate(struct
 
 	rt2x00_register_read(rt2x00dev, TXCSR1, &reg[0]);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_TIMEOUT, value);
@@ -1556,14 +1557,15 @@ static void rt2400pci_write_tx_desc(stru
 		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
-	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
+	rt2x00_set_field32(&txd->word0, TXD_W0_ACK,
+			   !(control->flags & IEEE80211_TXCTL_NO_ACK));
 
 	/*
 	 * Set IFS to IFS_SIFS when the this is not the first fragment,
 	 * or this fragment came after RTS/CTS.
 	 */
 	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
-	    control->use_rts_cts)
+	    (control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
@@ -1748,10 +1750,11 @@ static void rt2400pci_txdone(void *data)
 
 		ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+		entry->tx_status.flags  = 0;
 		/*
-		 * TODO: How can te below field be set correctly?
+		 * TODO: How can bit IEEE80211_TX_STATUS_TX_FILTERED of
+		 * entry->tx_status.flags be set correctly?
 		 */
-		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -1763,11 +1766,10 @@ static void rt2400pci_txdone(void *data)
 		 * was succesfull.
 		 */
 		tx_status = rt2x00_get_field32(txd->word0, TXD_W0_RESULT);
-		entry->tx_status.ack = 0;
 		entry->tx_status.excessive_retries = 0;
 		if (ack && (tx_status == TX_SUCCESS ||
 		    tx_status == TX_SUCCESS_RETRY))
-			entry->tx_status.ack = 1;
+			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 		else if (ack && tx_status == TX_FAIL_RETRY) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 			entry->tx_status.excessive_retries = 1;
@@ -1914,7 +1916,7 @@ static int rt2400pci_tx(struct net_devic
 	 * create and queue that frame first.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (control->use_rts_cts &&
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
 	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt2400pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
@@ -2087,7 +2089,8 @@ static int rt2400pci_config(struct net_d
 		conf->channel_val, conf->channel, conf->freq);
 	rt2400pci_config_txpower(rt2x00dev, conf->power_level);
 	rt2400pci_config_antenna(rt2x00dev, conf->antenna_sel);
-	rt2400pci_config_duration(rt2x00dev, conf->short_slot_time);
+	rt2400pci_config_duration(rt2x00dev,
+				  conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt2400pci_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -2577,18 +2580,13 @@ static int rt2400pci_init_hw(struct rt2x
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
-	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
+ 	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
index 677c5ae..b06728e 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500pci.c
@@ -808,7 +808,8 @@ static void rt2500pci_config_rate(struct
 
 	rt2x00_register_read(rt2x00dev, TXCSR1, &reg[0]);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg[0], TXCSR1_ACK_TIMEOUT, value);
@@ -1681,7 +1682,8 @@ static void rt2500pci_write_tx_desc(stru
 		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
-	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
+	rt2x00_set_field32(&txd->word0, TXD_W0_ACK,
+			   !(control->flags & IEEE80211_TXCTL_NO_ACK));
 
 	ring = rt2x00_get_ring(rt2x00dev, control->queue);
 	if (unlikely(!ring))
@@ -1697,7 +1699,7 @@ static void rt2500pci_write_tx_desc(stru
 	 * or this fragment came after RTS/CTS.
 	 */
 	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
-	    control->use_rts_cts)
+	    (control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
@@ -1897,10 +1899,11 @@ static void rt2500pci_txdone(void *data)
 
 		ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+		entry->tx_status.flags = 0;
 		/*
-		 * TODO: How can te below field be set correctly?
+		 * TODO: How can the IEEE80211_TX_STATUS_TX_FILTERED bit of
+		 * entry->tx_status.flags be set correctly?
 		 */
-		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -1912,11 +1915,10 @@ static void rt2500pci_txdone(void *data)
 		 * was succesfull.
 		 */
 		tx_status = rt2x00_get_field32(txd->word0, TXD_W0_RESULT);
-		entry->tx_status.ack = 0;
 		entry->tx_status.excessive_retries = 0;
 		if (ack && (tx_status == TX_SUCCESS ||
 		    tx_status == TX_SUCCESS_RETRY))
-			entry->tx_status.ack = 1;
+			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 		else if (ack && tx_status == TX_FAIL_RETRY) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 			entry->tx_status.excessive_retries = 1;
@@ -2063,7 +2065,7 @@ static int rt2500pci_tx(struct net_devic
 	 * create and queue that frame first.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (control->use_rts_cts &&
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
 	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt2500pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
@@ -2237,7 +2239,8 @@ static int rt2500pci_config(struct net_d
 		conf->power_level);
 	rt2500pci_config_txpower(rt2x00dev, conf->power_level);
 	rt2500pci_config_antenna(rt2x00dev, conf->antenna_sel);
-	rt2500pci_config_duration(rt2x00dev, conf->short_slot_time);
+	rt2500pci_config_duration(rt2x00dev,
+				  conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt2500pci_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -2731,18 +2734,13 @@ static int rt2500pci_init_hw(struct rt2x
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
-	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
diff --git a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
index 5dfa92e..b191edc 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt2500usb.c
@@ -657,7 +657,8 @@ static void rt2500usb_config_rate(struct
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR1, &reg);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field16_nb(&reg, TXRX_CSR1_ACK_TIMEOUT, value);
@@ -1459,7 +1460,8 @@ static void rt2500usb_write_tx_desc(stru
 	else
 		tx_rate = control->tx_rate;
 
-	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
+	rt2x00_set_field32(&txd->word0, TXD_W0_ACK,
+			   !(control->flags & IEEE80211_TXCTL_NO_ACK));
 
 	ring = rt2x00_get_ring(rt2x00dev, control->queue);
 	if (unlikely(!ring))
@@ -1475,7 +1477,7 @@ static void rt2500usb_write_tx_desc(stru
 	 * or this fragment came after RTS/CTS.
 	 */
 	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
-	    control->use_rts_cts)
+	    (control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
@@ -1685,10 +1687,11 @@ static void rt2500usb_txdone(void *data)
 
 		ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+		entry->tx_status.flags = 0;
 		/*
-		 * TODO: How can te below field be set correctly?
+		 * TODO: How can bit IEEE80211_TX_STATUS_TX_FILTERED of
+		 * entry->tx_status.flags be set correctly?
 		 */
-		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = entry->ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -1698,10 +1701,9 @@ static void rt2500usb_txdone(void *data)
 		 * ACK response when ACK was requested and status
 		 * was succesfull.
 		 */
-		entry->tx_status.ack = 0;
 		entry->tx_status.excessive_retries = 0;
 		if (ack && (urb->status == TX_SUCCESS))
-			entry->tx_status.ack = 1;
+			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 		else if (ack && urb->status == TX_FAIL_OTHER) {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 			entry->tx_status.excessive_retries = 1;
@@ -1800,7 +1802,7 @@ static int rt2500usb_tx(struct net_devic
 	 * create and queue that frame first.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (control->use_rts_cts &&
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
 	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt2500usb_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
@@ -1970,7 +1972,8 @@ static int rt2500usb_config(struct net_d
 		conf->power_level);
 	rt2500usb_config_txpower(rt2x00dev, conf->power_level);
 	rt2500usb_config_antenna(rt2x00dev, conf->antenna_sel);
-	rt2500usb_config_duration(rt2x00dev, conf->short_slot_time);
+	rt2500usb_config_duration(rt2x00dev,
+				  conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt2500usb_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -2419,18 +2422,13 @@ static int rt2500usb_init_hw(struct rt2x
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
-	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
diff --git a/drivers/net/wireless/d80211/rt2x00/rt61pci.c b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
index 526bc27..36542a3 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt61pci.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt61pci.c
@@ -1033,7 +1033,8 @@ static void rt61pci_config_rate(struct r
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, TXRX_CSR0_RX_ACK_TIMEOUT, value);
@@ -2111,7 +2112,8 @@ static void rt61pci_write_tx_desc(struct
 		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
-	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
+	rt2x00_set_field32(&txd->word0, TXD_W0_ACK,
+		       	   !(control->flags & IEEE80211_TXCTL_NO_ACK));
 
 	ring = rt2x00_get_ring(rt2x00dev, control->queue);
 	if (unlikely(!ring))
@@ -2127,7 +2129,7 @@ static void rt61pci_write_tx_desc(struct
 	 * or this fragment came after RTS/CTS.
 	 */
 	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
-	    control->use_rts_cts)
+	    (control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
@@ -2333,10 +2335,11 @@ static void rt61pci_txdone_entry(struct 
 
 	ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+	entry->tx_status.flags = 0;
 	/*
-	 * TODO: How can te below field be set correctly?
+	 * TODO: How can the IEEE80211_TX_STATUS_TX_FILTERED bit of
+	 * entry->tx_status.flags be set correctly?
 	 */
-	entry->tx_status.tx_filtered = 0;
 
 	entry->tx_status.queue_length = entry->ring->stats.limit;
 	entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -2348,11 +2351,10 @@ static void rt61pci_txdone_entry(struct 
 	 * was succesfull.
 	 */
 	tx_status = rt2x00_get_field32(sta_csr4, STA_CSR4_TX_RESULT);
-	entry->tx_status.ack = 0;
 	entry->tx_status.excessive_retries = 0;
 	if (ack && (tx_status == TX_SUCCESS ||
 	    tx_status == TX_SUCCESS_RETRY))
-		entry->tx_status.ack = 1;
+		entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 	else if (ack && tx_status == TX_FAIL_RETRY) {
 		rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 		entry->tx_status.excessive_retries = 1;
@@ -2539,7 +2541,7 @@ static int rt61pci_tx(struct net_device 
 	 * create and queue that frame first.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (control->use_rts_cts &&
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
 	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt61pci_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
@@ -2712,7 +2714,8 @@ static int rt61pci_config(struct net_dev
 		conf->power_level);
 	rt61pci_config_txpower(rt2x00dev, conf->power_level);
 	rt61pci_config_antenna(rt2x00dev, conf->antenna_sel, conf->phymode);
-	rt61pci_config_duration(rt2x00dev, conf->short_slot_time);
+	rt61pci_config_duration(rt2x00dev,
+				conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt61pci_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -3251,18 +3254,13 @@ static int rt61pci_init_hw(struct rt2x00
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
-	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
diff --git a/drivers/net/wireless/d80211/rt2x00/rt73usb.c b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
index 1feac24..0a38cde 100644
--- a/drivers/net/wireless/d80211/rt2x00/rt73usb.c
+++ b/drivers/net/wireless/d80211/rt2x00/rt73usb.c
@@ -771,7 +771,8 @@ static void rt73usb_config_rate(struct r
 
 	rt2x00_register_read(rt2x00dev, TXRX_CSR0, &reg);
 	value = SIFS + PLCP
-		+ (2 * (conf->short_slot_time ? SHORT_SLOT_TIME : SLOT_TIME))
+		+ (2 * ((conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME) ?
+			SHORT_SLOT_TIME : SLOT_TIME))
 		+ preamble
 		+ get_duration(ACK_SIZE, 10);
 	rt2x00_set_field32(&reg, TXRX_CSR0_RX_ACK_TIMEOUT, value);
@@ -1732,7 +1733,8 @@ static void rt73usb_write_tx_desc(struct
 		tx_rate = control->tx_rate;
 
 	rt2x00_set_field32(&txd->word0, TXD_W0_VALID, 1);
-	rt2x00_set_field32(&txd->word0, TXD_W0_ACK, !control->no_ack);
+	rt2x00_set_field32(&txd->word0, TXD_W0_ACK,
+			   !(control->flags & IEEE80211_TXCTL_NO_ACK));
 
 	ring = rt2x00_get_ring(rt2x00dev, control->queue);
 	if (unlikely(!ring))
@@ -1748,7 +1750,7 @@ static void rt73usb_write_tx_desc(struct
 	 * or this fragment came after RTS/CTS.
 	 */
 	if (((le16_to_cpu(ieee80211hdr->seq_ctrl) & IEEE80211_SCTL_FRAG) > 0) ||
-	    control->use_rts_cts)
+	    (control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_SIFS);
 	else
 		rt2x00_set_field32(&txd->word0, TXD_W0_IFS, IFS_BACKOFF);
@@ -1975,10 +1977,11 @@ static void rt73usb_txdone(void *data)
 
 		ack = rt2x00_get_field32(txd->word0, TXD_W0_ACK);
 
+		entry->tx_status.flags = 0;
 		/*
-		 * TODO: How can te below field be set correctly?
+		 * TODO: How can bit IEEE80211_TX_STATUS_TX_FILTERED of
+		 * entry->tx_status.flags be set correctly?
 		 */
-		entry->tx_status.tx_filtered = 0;
 
 		entry->tx_status.queue_length = entry->ring->stats.limit;
 		entry->tx_status.queue_number = entry->tx_status.control.queue;
@@ -1988,10 +1991,9 @@ static void rt73usb_txdone(void *data)
 		 * ACK response when ACK was requested and status
 		 * was succesfull.
 		 */
-		entry->tx_status.ack = 0;
 		entry->tx_status.excessive_retries = 0;
 		if (ack && (urb->status == TX_SUCCESS))
-			entry->tx_status.ack = 1;
+			entry->tx_status.flags |= IEEE80211_TX_STATUS_ACK;
 		else {
 			rt2x00dev->low_level_stats.dot11ACKFailureCount++;
 			entry->tx_status.excessive_retries = 1;
@@ -2089,7 +2091,7 @@ static int rt73usb_tx(struct net_device 
 	 * create and queue that frame first.
 	 */
 	frame_control = le16_to_cpu(ieee80211hdr->frame_control);
-	if (control->use_rts_cts &&
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) &&
 	    (frame_control & IEEE80211_FCTL_STYPE) != IEEE80211_STYPE_RTS) {
 		skb_rts = rt73usb_create_rts(rt2x00dev,
 				ieee80211hdr, control->rts_cts_duration);
@@ -2259,7 +2261,8 @@ static int rt73usb_config(struct net_dev
 		conf->power_level);
 	rt73usb_config_txpower(rt2x00dev, conf->power_level);
 	rt73usb_config_antenna(rt2x00dev, conf->antenna_sel, conf->phymode);
-	rt73usb_config_duration(rt2x00dev, conf->short_slot_time);
+	rt73usb_config_duration(rt2x00dev,
+				conf->flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 	rt73usb_config_phymode(rt2x00dev, conf->phymode);
 
 	/*
@@ -2792,18 +2795,13 @@ static int rt73usb_init_hw(struct rt2x00
 	 */
 	hw->version = IEEE80211_VERSION;
 	hw->name = DRV_NAME;
-	hw->host_gen_beacon = 1;
-	hw->host_gen_beacon_template = 0;
-	hw->device_hides_wep = 0;
-	hw->rx_includes_fcs = 0;
-	hw->host_broadcast_ps_buffering = 1;
-	hw->wep_include_iv = 1;
-	hw->data_nullfunc_ack = 1;
-	hw->no_tkip_wmm_hwaccel = 1;
+	hw->flags = IEEE80211_HW_HOST_GEN_BEACON |
+		    IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING |
+		    IEEE80211_HW_WEP_INCLUDE_IV |
+		    IEEE80211_HW_DATA_NULLFUNC_ACK |
+		    IEEE80211_HW_NO_TKIP_WMM_HWACCEL |
+		    IEEE80211_HW_MONITOR_DURING_OPER;
 	hw->extra_tx_headroom = 0;
-	hw->device_strips_mic = 0;
-	hw->monitor_during_oper = 1;
-	hw->fraglist = 0;
 	hw->maxssi = RT2X00_RX_MAX_SSI;
 
 	/*
diff --git a/include/net/d80211.h b/include/net/d80211.h
index 106bd9c..001091d 100644
--- a/include/net/d80211.h
+++ b/include/net/d80211.h
@@ -141,36 +141,40 @@ struct ieee80211_tx_control {
 	int rts_cts_rate; /* Transmit rate for RTS/CTS frame, given as the hw
 			   * specific value for the rate (from
 			   * struct ieee80211_rate) */
-	/* 1 = only first attempt, 2 = one retry, .. */
-	unsigned int retry_limit:8;
-	/* duration field for RTS/CTS frame */
-	unsigned int rts_cts_duration:16;
-	unsigned int req_tx_status:1; /* request TX status callback for this
-				       * frame */
-	unsigned int do_not_encrypt:1; /* send this frame without encryption;
-			       * e.g., for EAPOL frames */
-	unsigned int use_rts_cts:1; /* Use RTS-CTS before sending frame. */
-	unsigned int use_cts_protect:1; /* Use CTS protection for the frame
-					 * (e.g., for combined 802.11g /
-					 * 802.11b networks) */
-        unsigned int no_ack:1; /* Tell the low level not to wait for an ack */
-	unsigned int rate_ctrl_probe:1;
-	unsigned int clear_dst_mask:1;
-	unsigned int requeue:1;
-	unsigned int first_fragment:1;	/* This is a first fragment of the
-					 * frame */
-        unsigned int power_level:8; /* per-packet transmit power level, in dBm
-				     */
-	unsigned int antenna_sel:4; /* 0 = default/diversity,
-				     * 1 = Ant0, 2 = Ant1 */
-	int key_idx:8; /* -1 = do not encrypt, >= 0 keyidx from hw->set_key()
-			*/
-	int icv_len:8; /* Length of the ICV/MIC field in octets */
-	int iv_len:8; /* Length of the IV field in octets */
-	unsigned int queue:4; /* hardware queue to use for this frame;
-		      * 0 = highest, hw->queues-1 = lowest */
-	unsigned int sw_retry_attempt:4; /* no. of times hw has tried to
-		      * transmit frame (not incl. hw retries) */
+
+#define IEEE80211_TXCTL_REQ_TX_STATUS	(1<<0)/* request TX status callback for
+						* this frame */
+#define IEEE80211_TXCTL_DO_NOT_ENCRYPT	(1<<1) /* send this frame without
+						* encryption; e.g., for EAPOL
+						* frames */
+#define IEEE80211_TXCTL_USE_RTS_CTS	(1<<2) /* use RTS-CTS before sending
+						* frame */
+#define IEEE80211_TXCTL_USE_CTS_PROTECT	(1<<3) /* use CTS protection for the
+						* frame (e.g., for combined
+						* 802.11g / 802.11b networks) */
+#define IEEE80211_TXCTL_NO_ACK		(1<<4) /* tell the low level not to
+						* wait for an ack */
+#define IEEE80211_TXCTL_RATE_CTRL_PROBE	(1<<5)
+#define IEEE80211_TXCTL_CLEAR_DST_MASK	(1<<6)
+#define IEEE80211_TXCTL_REQUEUE		(1<<7)
+#define IEEE80211_TXCTL_FIRST_FRAGMENT	(1<<8) /* this is a first fragment of
+						* the frame */
+#define IEEE80211_TXCTL_TKIP_NEW_PHASE1_KEY (1<<9)
+	u32 flags;			       /* tx control flags defined
+						* above */
+	u16 rts_cts_duration;	/* duration field for RTS/CTS frame */
+	u8 retry_limit;		/* 1 = only first attempt, 2 = one retry, .. */
+	u8 power_level;		/* per-packet transmit power level, in dBm */
+	u8 antenna_sel; 	/* 0 = default/diversity, 1 = Ant0, 2 = Ant1 */
+	s8 key_idx;		/* -1 = do not encrypt, >= 0 keyidx from
+				 * hw->set_key() */
+	u8 icv_len;		/* length of the ICV/MIC field in octets */
+	u8 iv_len;		/* length of the IV field in octets */
+	u8 tkip_key[16];	/* generated phase2/phase1 key for hw TKIP */
+	u8 queue;		/* hardware queue to use for this frame;
+				 * 0 = highest, hw->queues-1 = lowest */
+	u8 sw_retry_attempt;	/* number of times hw has tried to
+				 * transmit frame (not incl. hw retries) */
 
 	int rateidx; /* internal 80211.o rateidx */
 	int alt_retry_rate; /* retry rate for the last retries, given as the
@@ -209,8 +213,10 @@ struct ieee80211_tx_status {
 	/* copied ieee80211_tx_control structure */
 	struct ieee80211_tx_control control;
 
-	unsigned int tx_filtered:1;
-	unsigned int ack:1; /* whether the TX frame was ACKed */
+#define IEEE80211_TX_STATUS_TX_FILTERED	(1<<0)
+#define IEEE80211_TX_STATUS_ACK		(1<<1) /* whether the TX frame was ACKed */
+	u32 flags;		/* tx staus flags defined above */
+
 	int ack_signal; /* measured signal strength of the ACK frame */
 	int excessive_retries;
 	int retry_count;
@@ -238,12 +244,12 @@ struct ieee80211_conf {
 
         int beacon_int;
 
-	/* Bitfields, grouped together */
-
-	unsigned int sw_encrypt:1;
-	unsigned int sw_decrypt:1;
-	unsigned int short_slot_time:1;	/* use IEEE 802.11g Short Slot Time */
-	unsigned int ssid_hidden:1;	/* do not broadcast the ssid */
+#define IEEE80211_CONF_SW_ENCRYPT	(1<<0)
+#define IEEE80211_CONF_SW_DECRYPT	(1<<1)
+#define IEEE80211_CONF_SHORT_SLOT_TIME	(1<<2) /* use IEEE 802.11g Short Slot
+						* Time */
+#define IEEE80211_CONF_SSID_HIDDEN	(1<<3) /* do not broadcast the ssid */
+	u32 flags;			/* configuration flags defined above */
 
         u8 power_level;			/* transmit power limit for current
 					 * regulatory domain; in dBm */
@@ -364,13 +370,19 @@ struct ieee80211_key_conf {
 	ieee80211_key_alg alg;
 	int keylen;
 
-	unsigned int force_sw_encrypt:1;/* to be cleared by low-level driver */
-	int keyidx:8;			/* WEP key index */
-	unsigned int default_tx_key:1;	/* This key is the new default TX key
-			       		 * (used only for broadcast keys). */
-	unsigned int default_wep_only:1;/* static WEP is the only configured security
-					 * policy; this allows some low-level drivers
-					 * to determine when hwaccel can be used */
+#define IEEE80211_KEY_FORCE_SW_ENCRYPT (1<<0) /* to be cleared by low-level
+						 driver */
+#define IEEE80211_KEY_DEFAULT_TX_KEY   (1<<1) /* This key is the new default TX
+						 key (used only for broadcast
+						 keys). */
+#define IEEE80211_KEY_DEFAULT_WEP_ONLY (1<<2) /* static WEP is the only
+						 configured security policy;
+						 this allows some low-level
+						 drivers to determine when
+						 hwaccel can be used */
+	u32 flags; /* key configuration flags defined above */
+
+	s8 keyidx;			/* WEP key index */
         u8 key[0];
 };
 
@@ -429,19 +441,19 @@ struct ieee80211_hw {
 	 * configure the upper layer IEEE 802.11 module to generate beacons.
 	 * The low-level driver can use ieee80211_beacon_get() to fetch the
 	 * next beacon frame. */
-	unsigned int host_gen_beacon:1;
+#define IEEE80211_HW_HOST_GEN_BEACON (1<<0)
 
 	/* The device needs to be supplied with a beacon template only. */
-	unsigned int host_gen_beacon_template:1;
+#define IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE (1<<1)
 
 	/* Some devices handle decryption internally and do not
 	 * indicate whether the frame was encrypted (unencrypted frames
 	 * will be dropped by the hardware, unless specifically allowed
 	 * through) */
-	unsigned int device_hides_wep:1;
+#define IEEE80211_HW_DEVICE_HIDES_WEP (1<<2)
 
 	/* Whether RX frames passed to ieee80211_rx() include FCS in the end */
-	unsigned int rx_includes_fcs:1;
+#define IEEE80211_HW_RX_INCLUDES_FCS (1<<3)
 
 	/* Some wireless LAN chipsets buffer broadcast/multicast frames for
 	 * power saving stations in the hardware/firmware and others rely on
@@ -449,14 +461,15 @@ struct ieee80211_hw {
 	 * configure the IEEE 802.11 upper layer to buffer broadcast/multicast
 	 * frames when there are power saving stations so that low-level driver
 	 * can fetch them with ieee80211_get_buffered_bc(). */
-	unsigned int host_broadcast_ps_buffering:1;
+#define IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING (1<<4)
+
+#define IEEE80211_HW_WEP_INCLUDE_IV (1<<5)
 
-	unsigned int wep_include_iv:1;
-	unsigned int data_nullfunc_ack:1; /* will data nullfunc frames get proper
-					   * TX status callback */
+	/* will data nullfunc frames get proper TX status callback */
+#define IEEE80211_HW_DATA_NULLFUNC_ACK (1<<6)
 
 	/* Force software encryption for TKIP packets if WMM is enabled. */
-	unsigned int no_tkip_wmm_hwaccel:1;
+#define IEEE80211_HW_NO_TKIP_WMM_HWACCEL (1<<7)
 
 	/* Some devices handle Michael MIC internally and do not include MIC in
 	 * the received packets passed up. device_strips_mic must be set
@@ -464,15 +477,26 @@ struct ieee80211_hw {
 	 * be still set in the IEEE 802.11 header with this option unlike with
 	 * the device_hides_wep configuration option.
 	 */
-	unsigned int device_strips_mic:1;
+#define IEEE80211_HW_DEVICE_STRIPS_MIC (1<<8)
 
 	/* Device is capable of performing full monitor mode even during
 	 * normal operation. */
-	unsigned int monitor_during_oper:1;
+#define IEEE80211_HW_MONITOR_DURING_OPER (1<<9)
 
 	/* Set if the low-level driver supports skb fraglist (NETIF_F_FRAGLIST),
 	 * i.e. more than one skb per frame */
-	unsigned int fraglist:1;
+#define IEEE80211_HW_FRAGLIST (1<<10)
+
+	/* calculate Michael MIC for an MSDU when doing hwcrypto */
+#define IEEE80211_HW_TKIP_INCLUDE_MMIC (1<<12)
+	/* Do TKIP phase1 key mixing in stack to support cards only do
+	 * phase2 key mixing when doing hwcrypto */
+#define IEEE80211_HW_TKIP_REQ_PHASE1_KEY (1<<13)
+	/* Do TKIP phase1 and phase2 key mixing in stack and send the generated
+	 * per-packet RC4 key with each TX frame when doing hwcrypto */
+#define IEEE80211_HW_TKIP_REQ_PHASE2_KEY (1<<14)
+
+	u32 flags;			/* hardware flags defined above */
 
 	/* Set to the size of a needed device specific skb headroom for TX skbs. */
 	unsigned int extra_tx_headroom;
diff --git a/include/net/d80211_common.h b/include/net/d80211_common.h
index 69ea939..0b575a2 100644
--- a/include/net/d80211_common.h
+++ b/include/net/d80211_common.h
@@ -20,26 +20,26 @@ #include <linux/types.h>
 #define IEEE80211_FI_VERSION 0x80211001
 
 struct ieee80211_frame_info {
-        u32 version;
-        u32 length;
-        u64 mactime;
-        u64 hosttime;
-        u32 phytype;
-        u32 channel;
-        u32 datarate;
-        u32 antenna;
-        u32 priority;
-        u32 ssi_type;
-        u32 ssi_signal;
-        u32 ssi_noise;
-        u32 preamble;
-        u32 encoding;
+	__be32 version;
+	__be32 length;
+	__be64 mactime;
+	__be64 hosttime;
+	__be32 phytype;
+	__be32 channel;
+	__be32 datarate;
+	__be32 antenna;
+	__be32 priority;
+	__be32 ssi_type;
+	__be32 ssi_signal;
+	__be32 ssi_noise;
+	__be32 preamble;
+	__be32 encoding;
 
 	/* Note: this structure is otherwise identical to capture format used
 	 * in linux-wlan-ng, but this additional field is used to provide meta
 	 * data about the frame to hostapd. This was the easiest method for
 	 * providing this information, but this might change in the future. */
-	u32 msg_type;
+	__be32 msg_type;
 } __attribute__ ((packed));
 
 
diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index eb7e292..cac1c1b 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -64,10 +64,14 @@ ieee80211_key_data2conf(struct ieee80211
 	conf->hw_key_idx = data->hw_key_idx;
 	conf->alg = data->alg;
 	conf->keylen = data->keylen;
-	conf->force_sw_encrypt = data->force_sw_encrypt;
+	conf->flags = 0;
+       if (data->force_sw_encrypt)
+		conf->flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 	conf->keyidx = data->keyidx;
-	conf->default_tx_key = data->default_tx_key;
-	conf->default_wep_only = local->default_wep_only;
+	if (data->default_tx_key)
+		conf->flags |= IEEE80211_KEY_DEFAULT_TX_KEY;
+	if (local->default_wep_only)
+		conf->flags |= IEEE80211_KEY_DEFAULT_WEP_ONLY;
 	memcpy(conf->key, data->key, data->keylen);
 
 	return conf;
@@ -354,7 +358,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 	tx->u.tx.rate = rate_control_get_rate(tx->local, tx->dev, tx->skb,
 					      &extra);
 	if (unlikely(extra.probe != NULL)) {
-		tx->u.tx.control->rate_ctrl_probe = 1;
+		tx->u.tx.control->flags |= IEEE80211_TXCTL_RATE_CTRL_PROBE;
 		tx->u.tx.probe_last_frag = 1;
 		tx->u.tx.control->alt_retry_rate = tx->u.tx.rate->val;
 		tx->u.tx.rate = extra.probe;
@@ -372,7 +376,7 @@ ieee80211_tx_h_rate_ctrl(struct ieee8021
 
 		tx->u.tx.rate = extra.nonerp;
 		tx->u.tx.control->rateidx = extra.nonerp_idx;
-		tx->u.tx.control->rate_ctrl_probe = 0;
+		tx->u.tx.control->flags &= ~IEEE80211_TXCTL_RATE_CTRL_PROBE;
 	} else {
 		tx->u.tx.last_frag_rate = tx->u.tx.rate;
 		tx->u.tx.last_frag_rateidx = extra.rateidx;
@@ -398,7 +402,7 @@ ieee80211_tx_h_select_key(struct ieee802
 	else
 		tx->u.tx.control->key_idx = HW_KEY_IDX_INVALID;
 
-	if (unlikely(tx->u.tx.control->do_not_encrypt))
+	if (unlikely(tx->u.tx.control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT))
 		tx->key = NULL;
 	else if (tx->sta && tx->sta->key)
 		tx->key = tx->sta->key;
@@ -506,12 +510,13 @@ #define IEEE80211_ENCRYPT_TAILROOM 12
 
 static int wep_encrypt_skb(struct ieee80211_txrx_data *tx, struct sk_buff *skb)
 {
-	if (tx->key->force_sw_encrypt || tx->local->conf.sw_encrypt) {
+	if (tx->key->force_sw_encrypt ||
+	    (tx->local->conf.flags & IEEE80211_CONF_SW_ENCRYPT)) {
 		if (ieee80211_wep_encrypt(tx->local, skb, tx->key))
 			return -1;
 	} else {
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
-		if (tx->local->hw->wep_include_iv) {
+		if (tx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) {
 			if (ieee80211_wep_add_iv(tx->local, skb, tx->key) ==
 			    NULL)
 				return -1;
@@ -753,7 +758,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	if (!is_multicast_ether_addr(hdr->addr1)) {
 		if (tx->skb->len + FCS_LEN > tx->local->rts_threshold &&
 		    tx->local->rts_threshold < IEEE80211_MAX_RTS_THRESHOLD) {
-			control->use_rts_cts = 1;
+			control->flags |= IEEE80211_TXCTL_USE_RTS_CTS;
 			control->retry_limit =
 				tx->local->long_retry_limit;
 		} else {
@@ -779,8 +784,8 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 	    (tx->u.tx.rate->flags & IEEE80211_RATE_ERP) &&
 	    tx->u.tx.unicast &&
 	    tx->local->cts_protect_erp_frames &&
-	    !control->use_rts_cts)
-		control->use_cts_protect = 1;
+	    !(control->flags & IEEE80211_TXCTL_USE_RTS_CTS))
+		control->flags |= IEEE80211_TXCTL_USE_CTS_PROTECT;
 
 	/* Setup duration field for the first fragment of the frame. Duration
 	 * for remaining fragments will be updated when they are being sent
@@ -790,7 +795,8 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 				 0);
 	hdr->duration_id = cpu_to_le16(dur);
 
-	if (control->use_rts_cts || control->use_cts_protect) {
+	if ((control->flags & IEEE80211_TXCTL_USE_RTS_CTS) ||
+	    (control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)) {
 		struct ieee80211_rate *rate;
 		int erp = tx->u.tx.rate->flags & IEEE80211_RATE_ERP;
 
@@ -803,7 +809,7 @@ ieee80211_tx_h_misc(struct ieee80211_txr
 		       !(rate->flags & IEEE80211_RATE_BASIC))
 			rate--;
 
-		if (control->use_rts_cts)
+		if (control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
 			dur += ieee80211_frame_duration(tx->local, 10,
 							rate->rate, erp,
 							tx->local->
@@ -946,7 +952,7 @@ ieee80211_tx_h_multicast_ps_buf(struct i
 	/* broadcast/multicast frame */
 	/* If any of the associated stations is in power save mode,
 	 * the frame is buffered to be sent after DTIM beacon frame */
-	if (tx->local->hw->host_broadcast_ps_buffering &&
+	if ((tx->local->hw->flags & IEEE80211_HW_HOST_BROADCAST_PS_BUFFERING) &&
 	    tx->sdata->type != IEEE80211_IF_TYPE_WDS &&
 	    tx->sdata->bss && atomic_read(&tx->sdata->bss->num_sta_ps) &&
 	    !(tx->fc & IEEE80211_FCTL_ORDER)) {
@@ -1059,15 +1065,18 @@ __ieee80211_tx_prepare(struct ieee80211_
         control->power_level = local->conf.power_level;
 	tx->u.tx.control = control;
         tx->u.tx.unicast = !is_multicast_ether_addr(hdr->addr1);
-        control->no_ack = is_multicast_ether_addr(hdr->addr1);
+	if (is_multicast_ether_addr(hdr->addr1))
+		control->flags |= IEEE80211_TXCTL_NO_ACK;
+	else
+		control->flags &= ~IEEE80211_TXCTL_NO_ACK;
 	tx->fragmented = local->fragmentation_threshold <
 		IEEE80211_MAX_FRAG_THRESHOLD && tx->u.tx.unicast &&
 		skb->len + FCS_LEN > local->fragmentation_threshold &&
 		(!local->hw->set_frag_threshold);
 	if (!tx->sta)
-		control->clear_dst_mask = 1;
+		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 	else if (tx->sta->clear_dst_mask) {
-		control->clear_dst_mask = 1;
+		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 		tx->sta->clear_dst_mask = 0;
 	}
 	control->antenna_sel = local->conf.antenna_sel;
@@ -1078,7 +1087,7 @@ __ieee80211_tx_prepare(struct ieee80211_
 		u8 *pos = &skb->data[hdrlen + sizeof(rfc1042_header)];
 		tx->ethertype = (pos[0] << 8) | pos[1];
 	}
-	control->first_fragment = 1;
+	control->flags |= IEEE80211_TXCTL_FIRST_FRAGMENT;
 
 }
 
@@ -1143,10 +1152,10 @@ static int __ieee80211_tx(struct ieee802
 		ieee80211_led_tx(local, 1);
 	}
 	if (tx->u.tx.extra_frag) {
-		control->use_rts_cts = 0;
-		control->use_cts_protect = 0;
-		control->clear_dst_mask = 0;
-		control->first_fragment = 0;
+		control->flags &= ~(IEEE80211_TXCTL_USE_RTS_CTS |
+				    IEEE80211_TXCTL_USE_CTS_PROTECT |
+				    IEEE80211_TXCTL_CLEAR_DST_MASK |
+				    IEEE80211_TXCTL_FIRST_FRAGMENT);
 		for (i = 0; i < tx->u.tx.num_extra_frag; i++) {
 			if (!tx->u.tx.extra_frag[i])
 				continue;
@@ -1155,8 +1164,12 @@ static int __ieee80211_tx(struct ieee802
 			if (i == tx->u.tx.num_extra_frag) {
 				control->tx_rate = tx->u.tx.last_frag_hwrate;
 				control->rateidx = tx->u.tx.last_frag_rateidx;
-				control->rate_ctrl_probe =
-					tx->u.tx.probe_last_frag;
+				if (tx->u.tx.probe_last_frag)
+					control->flags |=
+						IEEE80211_TXCTL_RATE_CTRL_PROBE;
+				else
+					control->flags &=
+						~IEEE80211_TXCTL_RATE_CTRL_PROBE;
 			}
 
 			ieee80211_dump_frame(local->mdev->name,
@@ -1371,11 +1384,14 @@ #endif
 
 	control.ifindex = odev->ifindex;
 	control.type = osdata->type;
-	control.req_tx_status = pkt_data->req_tx_status;
-	control.do_not_encrypt = pkt_data->do_not_encrypt;
+	if (pkt_data->req_tx_status)
+		control.flags |= IEEE80211_TXCTL_REQ_TX_STATUS;
+	if (pkt_data->do_not_encrypt)
+		control.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
 	control.pkt_type =
 		pkt_data->pkt_probe_resp ? PKT_PROBE_RESP : PKT_NORMAL;
-	control.requeue = pkt_data->requeue;
+	if (pkt_data->requeue)
+		control.flags |= IEEE80211_TXCTL_REQUEUE;
 	control.queue = pkt_data->queue;
 
 	ret = ieee80211_tx(odev, skb, &control,
@@ -1765,10 +1781,10 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 			rate->val2 : rate->val;
 		control->antenna_sel = local->conf.antenna_sel;
 		control->power_level = local->conf.power_level;
-		control->no_ack = 1;
+		control->flags |= IEEE80211_TXCTL_NO_ACK;
 		control->retry_limit = 1;
 		control->rts_cts_duration = 0;
-		control->clear_dst_mask = 1;
+		control->flags |= IEEE80211_TXCTL_CLEAR_DST_MASK;
 	}
 
 	ap->num_beacons++;
@@ -1881,7 +1897,7 @@ int ieee80211_if_config_beacon(struct ne
 	struct ieee80211_local *local = dev->ieee80211_ptr;
 	struct sk_buff *skb;
 
-	if (!local->hw->host_gen_beacon_template)
+	if (!(local->hw->flags & IEEE80211_HW_HOST_GEN_BEACON_TEMPLATE))
 		return 0;
 	skb = ieee80211_beacon_get(local->mdev, dev->ifindex, NULL);
 	if (!skb)
@@ -2155,7 +2171,8 @@ static inline void ieee80211_start_soft_
 	struct ieee80211_if_init_conf conf;
 
 	if (local->open_count && local->open_count == local->monitors &&
-	    !local->hw->monitor_during_oper && local->hw->remove_interface) {
+	    !(local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER) &&
+	    local->hw->remove_interface) {
 		conf.if_id = -1;
 		conf.type = IEEE80211_IF_TYPE_MNTR;
 		conf.mac_addr = NULL;
@@ -2170,7 +2187,8 @@ static void ieee80211_start_hard_monitor
 	struct ieee80211_if_init_conf conf;
 
 	if (local->open_count && local->open_count == local->monitors &&
-	    !local->hw->monitor_during_oper && local->hw->add_interface) {
+	    !(local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER) &&
+	    local->hw->add_interface) {
 		conf.if_id = -1;
 		conf.type = IEEE80211_IF_TYPE_MNTR;
 		conf.mac_addr = NULL;
@@ -2201,7 +2219,7 @@ static int ieee80211_open(struct net_dev
 		return -ENOLINK;
 
 	if (sdata->type == IEEE80211_IF_TYPE_MNTR && local->open_count &&
-	    !local->hw->monitor_during_oper) {
+	    !(local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER)) {
 		/* run the interface in a "soft monitor" mode */
 		local->monitors++;
 		local->open_count++;
@@ -2265,7 +2283,8 @@ static int ieee80211_stop(struct net_dev
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 
 	if (sdata->type == IEEE80211_IF_TYPE_MNTR &&
-	    local->open_count > 1 && !local->hw->monitor_during_oper) {
+	    local->open_count > 1 &&
+	    !(local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER)) {
 		/* remove "soft monitor" interface */
 		local->open_count--;
 		local->monitors--;
@@ -2427,7 +2446,7 @@ ieee80211_rx_h_data(struct ieee80211_txr
 		memcpy(skb_push(skb, ETH_ALEN), dst, ETH_ALEN);
 	} else {
 		struct ethhdr *ehdr;
-                unsigned short len;
+		__be16 len;
 		skb_pull(skb, hdrlen);
 		len = htons(skb->len);
 		ehdr = (struct ethhdr *) skb_push(skb, sizeof(struct ethhdr));
@@ -3020,7 +3039,8 @@ ieee80211_rx_h_check(struct ieee80211_tx
 			rx->sta->last_seq_ctrl[rx->u.rx.queue] = hdr->seq_ctrl;
 	}
 
-	if (rx->local->hw->rx_includes_fcs && rx->skb->len > FCS_LEN)
+	if ((rx->local->hw->flags & IEEE80211_HW_RX_INCLUDES_FCS) &&
+	    rx->skb->len > FCS_LEN)
 		skb_trim(rx->skb, rx->skb->len - FCS_LEN);
 
 	if (unlikely(rx->skb->len < 16)) {
@@ -3080,7 +3100,7 @@ ieee80211_rx_h_check(struct ieee80211_tx
 		else
 			rx->key = rx->sdata->default_key;
 
-		if (rx->local->hw->wep_include_iv &&
+		if ((rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
 		    rx->fc & IEEE80211_FCTL_PROTECTED) {
 			int keyidx = ieee80211_wep_get_keyidx(rx->skb);
 
@@ -3191,8 +3211,9 @@ ieee80211_rx_h_wep_weak_iv_detection(str
 		return TXRX_CONTINUE;
 
 	/* Check for weak IVs, if hwaccel did not remove IV from the frame */
-	if (rx->local->hw->wep_include_iv ||
-	    rx->key->force_sw_encrypt || rx->local->conf.sw_decrypt) {
+	if ((rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) ||
+	    rx->key->force_sw_encrypt ||
+	    (rx->local->conf.flags & IEEE80211_CONF_SW_ENCRYPT)) {
 		u8 *iv = ieee80211_wep_is_weak_iv(rx->skb, rx->key);
 		if (iv) {
 			rx->sta->wep_weak_iv_count++;
@@ -3207,7 +3228,7 @@ static ieee80211_txrx_result
 ieee80211_rx_h_wep_decrypt(struct ieee80211_txrx_data *rx)
 {
 	/* If the device handles decryption totally, skip this test */
-	if (rx->local->hw->device_hides_wep)
+	if (rx->local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP)
 		return TXRX_CONTINUE;
 
 	if ((rx->key && rx->key->alg != ALG_WEP) ||
@@ -3224,13 +3245,14 @@ ieee80211_rx_h_wep_decrypt(struct ieee80
 	}
 
 	if (!(rx->u.rx.status->flag & RX_FLAG_DECRYPTED) ||
-	    rx->key->force_sw_encrypt || rx->local->conf.sw_decrypt) {
+	    rx->key->force_sw_encrypt ||
+	    (rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
 		if (ieee80211_wep_decrypt(rx->local, rx->skb, rx->key)) {
 			printk(KERN_DEBUG "%s: RX WEP frame, decrypt "
 			       "failed\n", rx->dev->name);
 			return TXRX_DROP;
 		}
-	} else if (rx->local->hw->wep_include_iv) {
+	} else if (rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) {
 		ieee80211_wep_remove_iv(rx->local, rx->skb, rx->key);
 		/* remove ICV */
 		skb_trim(rx->skb, rx->skb->len - 4);
@@ -3275,7 +3297,7 @@ static ieee80211_txrx_result
 ieee80211_rx_h_drop_unencrypted(struct ieee80211_txrx_data *rx)
 {
 	/*  If the device handles decryption totally, skip this test */
-	if (rx->local->hw->device_hides_wep)
+	if (rx->local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP)
 		return TXRX_CONTINUE;
 
 	/* Drop unencrypted frames if key is set. */
@@ -3344,7 +3366,7 @@ ieee80211_rx_h_passive_scan(struct ieee8
 			local->scan.rx_beacon++;
 			/* Need to trim FCS here because it is normally
 			 * removed only after this passive scan handler. */
-			if (rx->local->hw->rx_includes_fcs &&
+			if ((rx->local->hw->flags & IEEE80211_HW_RX_INCLUDES_FCS) &&
 			    rx->skb->len > FCS_LEN)
 				skb_trim(rx->skb, rx->skb->len - FCS_LEN);
 
@@ -3437,7 +3459,7 @@ static void ieee80211_rx_michael_mic_rep
 		goto ignore;
 	}
 
-	if (rx->local->hw->wep_include_iv &&
+	if ((rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
 	    rx->sdata->type == IEEE80211_IF_TYPE_AP) {
 		int keyidx = ieee80211_wep_get_keyidx(rx->skb);
 		/* AP with Pairwise keys support should never receive Michael
@@ -3720,9 +3742,9 @@ ieee80211_tx_h_load_stats(struct ieee802
 	if (!is_multicast_ether_addr(hdr->addr1))
 		load += hdrtime;
 
-	if (tx->u.tx.control->use_rts_cts)
+	if (tx->u.tx.control->flags & IEEE80211_TXCTL_USE_RTS_CTS)
 		load += 2 * hdrtime;
-	else if (tx->u.tx.control->use_cts_protect)
+	else if (tx->u.tx.control->flags & IEEE80211_TXCTL_USE_CTS_PROTECT)
 		load += hdrtime;
 
 	load += skb->len * tx->u.tx.rate->rate_inv;
@@ -3894,7 +3916,7 @@ void ieee80211_tx_status_irqsafe(struct 
 	memcpy(skb->cb, &saved, sizeof(saved));
 
 	skb->pkt_type = ieee80211_tx_status_msg;
-	skb_queue_tail(status->control.req_tx_status ?
+	skb_queue_tail(status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS ?
 		       &local->skb_queue : &local->skb_queue_unreliable, skb);
 	tmp = skb_queue_len(&local->skb_queue) +
 		skb_queue_len(&local->skb_queue_unreliable);
@@ -3961,10 +3983,10 @@ static void ieee80211_remove_tx_extra(st
 	pkt_data = (struct ieee80211_tx_packet_data *)skb->cb;
 	pkt_data->ifindex = control->ifindex;
 	pkt_data->mgmt_iface = (control->type == IEEE80211_IF_TYPE_MGMT);
-	pkt_data->req_tx_status = control->req_tx_status;
-	pkt_data->do_not_encrypt = control->do_not_encrypt;
+	pkt_data->req_tx_status = !!(control->flags & IEEE80211_TXCTL_REQ_TX_STATUS);
+	pkt_data->do_not_encrypt = !!(control->flags & IEEE80211_TXCTL_DO_NOT_ENCRYPT);
 	pkt_data->pkt_probe_resp = (control->pkt_type == PKT_PROBE_RESP);
-	pkt_data->requeue = control->requeue;
+	pkt_data->requeue = !!(control->flags & IEEE80211_TXCTL_REQUEUE);
 	pkt_data->queue = control->queue;
 
 	hdrlen = ieee80211_get_hdrlen_from_skb(skb);
@@ -4036,13 +4058,13 @@ void ieee80211_tx_status(struct net_devi
 				 * that this TX packet failed because of that.
 				 */
 				status->excessive_retries = 0;
-				status->tx_filtered = 1;
+				status->flags |= IEEE80211_TX_STATUS_TX_FILTERED;
 			}
 			sta_info_put(sta);
 		}
 	}
 
-	if (status->tx_filtered) {
+	if (status->flags & IEEE80211_TX_STATUS_TX_FILTERED) {
 		struct sta_info *sta;
 		sta = sta_info_get(local, hdr->addr1);
 		if (sta) {
@@ -4067,9 +4089,9 @@ void ieee80211_tx_status(struct net_devi
 							  &status->control);
 				skb_queue_tail(&sta->tx_filtered, skb);
 			} else if (!(sta->flags & WLAN_STA_PS) &&
-				   !status->control.requeue) {
+				   !(status->control.flags & IEEE80211_TXCTL_REQUEUE)) {
 				/* Software retry the packet once */
-				status->control.requeue = 1;
+				status->control.flags |= IEEE80211_TXCTL_REQUEUE;
 				ieee80211_remove_tx_extra(local, sta->key,
 							  skb,
 							  &status->control);
@@ -4104,7 +4126,7 @@ void ieee80211_tx_status(struct net_devi
 	frag = le16_to_cpu(hdr->seq_ctrl) & IEEE80211_SCTL_FRAG;
 	type = le16_to_cpu(hdr->frame_control) & IEEE80211_FCTL_FTYPE;
 
-        if (status->ack) {
+        if (status->flags & IEEE80211_TX_STATUS_ACK) {
 		if (frag == 0) {
 			local->dot11TransmittedFrameCount++;
 			if (is_multicast_ether_addr(hdr->addr1))
@@ -4128,13 +4150,13 @@ void ieee80211_tx_status(struct net_devi
 			local->dot11FailedCount++;
         }
 
-        if (!status->control.req_tx_status) {
+        if (!(status->control.flags & IEEE80211_TXCTL_REQ_TX_STATUS)) {
 		dev_kfree_skb(skb);
 		return;
 	}
 
-	msg_type = status->ack ? ieee80211_msg_tx_callback_ack :
-		ieee80211_msg_tx_callback_fail;
+	msg_type = (status->flags & IEEE80211_TX_STATUS_ACK) ?
+	       	ieee80211_msg_tx_callback_ack : ieee80211_msg_tx_callback_fail;
 
 	/* skb was the original skb used for TX. Clone it and give the clone
 	 * to netif_rx(). Free original skb. */
@@ -4484,7 +4506,7 @@ int ieee80211_register_hw(struct net_dev
 	if (result < 0)
 		goto fail_sta_info;
 
-	if (hw->fraglist)
+	if (hw->flags & IEEE80211_HW_FRAGLIST)
 		dev->features |= NETIF_F_FRAGLIST;
 	rtnl_lock();
 	result = dev_alloc_name(dev, dev->name);
diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 9ae4e79..fb2e888 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -126,7 +126,7 @@ static int ieee80211_ioctl_get_hw_featur
 	struct ieee80211_channel_data *chan;
 
 	param->u.hw_features.flags = 0;
-	if (local->hw->data_nullfunc_ack)
+	if (local->hw->flags & IEEE80211_HW_DATA_NULLFUNC_ACK)
 		param->u.hw_features.flags |= HOSTAP_HW_FLAG_NULLFUNC_OK;
 
 	param->u.hw_features.num_modes = local->hw->num_modes;
@@ -218,7 +218,7 @@ static int ieee80211_ioctl_flush(struct 
 struct iapp_layer2_update {
 	u8 da[ETH_ALEN]; /* broadcast */
 	u8 sa[ETH_ALEN]; /* STA addr */
-	u16 len; /* 6 */
+	__be16 len; /* 6 */
 	u8 dsap; /* 0 */
 	u8 ssap; /* 0 */
 	u8 control;
@@ -331,7 +331,7 @@ static int ieee80211_ioctl_add_sta(struc
 		memset(&conf, 0, sizeof(conf));
 		conf.hw_key_idx = HW_KEY_IDX_INVALID;
 		conf.alg = ALG_NULL;
-		conf.force_sw_encrypt = 1;
+		conf.flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 		if (local->hw->set_key(dev, SET_KEY, sta->addr, &conf,
 				       sta->aid)) {
 			sta->key_idx_compression = HW_KEY_IDX_INVALID;
@@ -492,7 +492,8 @@ int ieee80211_set_hw_encryption(struct n
 		key->force_sw_encrypt = 1;
 
 	if (key && local->hw->set_key &&
-	    (!local->conf.sw_encrypt || !local->conf.sw_decrypt) &&
+	    (!(local->conf.flags & IEEE80211_CONF_SW_ENCRYPT) ||
+	     !(local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) &&
 	    (keyconf = ieee80211_key_data2conf(local, key)) != NULL) {
 		if (local->hw->set_key(dev, SET_KEY, addr,
 				       keyconf, sta ? sta->aid : 0)) {
@@ -501,7 +502,7 @@ int ieee80211_set_hw_encryption(struct n
 			key->hw_key_idx = HW_KEY_IDX_INVALID;
 		} else {
 			key->force_sw_encrypt =
-				keyconf->force_sw_encrypt;
+				!!(keyconf->flags & IEEE80211_KEY_FORCE_SW_ENCRYPT);
 			key->hw_key_idx =
 				keyconf->hw_key_idx;
 
@@ -594,14 +595,15 @@ #endif /* CONFIG_D80211_VERBOSE_DEBUG */
 		try_hwaccel = 0;
 	}
 
-	if (local->hw->device_hides_wep) {
+	if (local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP) {
 		/* Software encryption cannot be used with devices that hide
 		 * encryption from the host system, so always try to use
 		 * hardware acceleration with such devices. */
 		try_hwaccel = 1;
 	}
 
-	if (local->hw->no_tkip_wmm_hwaccel && alg == ALG_TKIP) {
+	if ((local->hw->flags & IEEE80211_HW_NO_TKIP_WMM_HWACCEL) &&
+	    alg == ALG_TKIP) {
 		if (sta && (sta->flags & WLAN_STA_WME)) {
 		/* Hardware does not support hwaccel with TKIP when using WMM.
 		 */
@@ -2297,14 +2299,15 @@ static void ieee80211_key_enable_hwaccel
 	u8 addr[ETH_ALEN];
 
 	if (!key || key->alg != ALG_WEP || !key->force_sw_encrypt ||
-	    local->hw->device_hides_wep)
+	    (local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP))
 		return;
 
 	memset(addr, 0xff, ETH_ALEN);
 	keyconf = ieee80211_key_data2conf(local, key);
 	if (keyconf && local->hw->set_key &&
 	    local->hw->set_key(local->mdev, SET_KEY, addr, keyconf, 0) == 0) {
-		key->force_sw_encrypt = keyconf->force_sw_encrypt;
+		key->force_sw_encrypt =
+			!!(keyconf->flags & IEEE80211_KEY_FORCE_SW_ENCRYPT);
 		key->hw_key_idx = keyconf->hw_key_idx;
 	}
 	kfree(keyconf);
@@ -2318,7 +2321,7 @@ static void ieee80211_key_disable_hwacce
 	u8 addr[ETH_ALEN];
 
 	if (!key || key->alg != ALG_WEP || key->force_sw_encrypt ||
-	    local->hw->device_hides_wep)
+	    (local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP))
 		return;
 
 	memset(addr, 0xff, ETH_ALEN);
@@ -2430,7 +2433,10 @@ static int ieee80211_ioctl_prism2_param(
                 local->stat_time = value;
                 break;
 	case PRISM2_PARAM_SHORT_SLOT_TIME:
-		local->conf.short_slot_time = value;
+		if (value)
+			local->conf.flags |= IEEE80211_CONF_SHORT_SLOT_TIME;
+		else
+			local->conf.flags &= ~IEEE80211_CONF_SHORT_SLOT_TIME;
 		if (ieee80211_hw_config(dev))
 			ret = -EINVAL;
 		break;
@@ -2477,8 +2483,10 @@ static int ieee80211_ioctl_prism2_param(
 	case PRISM2_PARAM_BROADCAST_SSID:
 		if ((value < 0) || (value > 1))
 			ret = -EINVAL;
+		else if (value)
+			local->conf.flags |= IEEE80211_CONF_SSID_HIDDEN;
 		else
-			local->conf.ssid_hidden = value;
+			local->conf.flags &= ~IEEE80211_CONF_SSID_HIDDEN;
 		break;
 
 	case PRISM2_PARAM_STA_ANTENNA_SEL:
@@ -2656,7 +2664,7 @@ static int ieee80211_ioctl_get_prism2_pa
                 *param = local->stat_time;
                 break;
 	case PRISM2_PARAM_SHORT_SLOT_TIME:
-		*param = local->conf.short_slot_time;
+		*param = !!(local->conf.flags & IEEE80211_CONF_SHORT_SLOT_TIME);
 		break;
 
 	case PRISM2_PARAM_NEXT_MODE:
@@ -2676,7 +2684,7 @@ static int ieee80211_ioctl_get_prism2_pa
 		break;
 
 	case PRISM2_PARAM_BROADCAST_SSID:
-		*param = local->conf.ssid_hidden;
+		*param = !!(local->conf.flags & IEEE80211_CONF_SSID_HIDDEN);
 		break;
 
 	case PRISM2_PARAM_STA_ANTENNA_SEL:
diff --git a/net/d80211/ieee80211_scan.c b/net/d80211/ieee80211_scan.c
index add0bf3..7089f9a 100644
--- a/net/d80211/ieee80211_scan.c
+++ b/net/d80211/ieee80211_scan.c
@@ -329,12 +329,12 @@ void ieee80211_init_scan(struct net_devi
 
 	memset(&local->scan.tx_control, 0, sizeof(local->scan.tx_control));
 	local->scan.tx_control.key_idx = HW_KEY_IDX_INVALID;
-	local->scan.tx_control.do_not_encrypt = 1;
+	local->scan.tx_control.flags |= IEEE80211_TXCTL_DO_NOT_ENCRYPT;
 	memset(&extra, 0, sizeof(extra));
 	extra.endidx = local->num_curr_rates;
 	local->scan.tx_control.tx_rate =
 		rate_control_get_rate(local, dev, local->scan.skb, &extra)->val;
-	local->scan.tx_control.no_ack = 1;
+	local->scan.tx_control.flags |= IEEE80211_TXCTL_NO_ACK;
 }
 
 
diff --git a/net/d80211/ieee80211_sta.c b/net/d80211/ieee80211_sta.c
index bf74b6b..4b73545 100644
--- a/net/d80211/ieee80211_sta.c
+++ b/net/d80211/ieee80211_sta.c
@@ -1984,7 +1984,7 @@ static int ieee80211_sta_join_ibss(struc
 
 	sdata = IEEE80211_DEV_TO_SUB_IF(dev);
 	sdata->drop_unencrypted = bss->capability &
-		cpu_to_le16(WLAN_CAPABILITY_PRIVACY) ? 1 : 0;
+		WLAN_CAPABILITY_PRIVACY ? 1 : 0;
 
 	memset(&rq, 0, sizeof(rq));
 	rq.m = bss->freq * 100000;
@@ -2064,7 +2064,7 @@ static int ieee80211_sta_join_ibss(struc
 			rate->val2 : rate->val;
 		control.antenna_sel = local->conf.antenna_sel;
 		control.power_level = local->conf.power_level;
-		control.no_ack = 1;
+		control.flags |= IEEE80211_TXCTL_NO_ACK;
 		control.retry_limit = 1;
 		control.rts_cts_duration = 0;
 
@@ -2153,9 +2153,9 @@ #endif
 	bss->channel = local->conf.channel;
 	bss->freq = local->conf.freq;
 	bss->last_update = jiffies;
-	bss->capability = cpu_to_le16(WLAN_CAPABILITY_IBSS);
+	bss->capability = WLAN_CAPABILITY_IBSS;
 	if (sdata->default_key) {
-		bss->capability |= cpu_to_le16(WLAN_CAPABILITY_PRIVACY);
+		bss->capability |= WLAN_CAPABILITY_PRIVACY;
 	} else
 		sdata->drop_unencrypted = 0;
 	bss->supp_rates_len = local->num_curr_rates;
diff --git a/net/d80211/ieee80211_sysfs.c b/net/d80211/ieee80211_sysfs.c
index 545dc6e..dbdd28e 100644
--- a/net/d80211/ieee80211_sysfs.c
+++ b/net/d80211/ieee80211_sysfs.c
@@ -530,9 +530,10 @@ static ssize_t ieee80211_if_fmt_mode(con
 {
 	struct ieee80211_local *local = sdata->local;
 
-	return sprintf(buf, "%s\n", (local->hw->monitor_during_oper ||
-				     local->open_count == local->monitors) ?
-				    "hard" : "soft");
+	return sprintf(buf, "%s\n",
+		       ((local->hw->flags & IEEE80211_HW_MONITOR_DURING_OPER) ||
+			local->open_count == local->monitors) ?
+		       "hard" : "soft");
 }
 __IEEE80211_IF_SHOW(mode);
 
diff --git a/net/d80211/sta_info.c b/net/d80211/sta_info.c
index 17f4b92..6e73fab 100644
--- a/net/d80211/sta_info.c
+++ b/net/d80211/sta_info.c
@@ -255,7 +255,7 @@ void sta_info_free(struct sta_info *sta,
 		memset(&conf, 0, sizeof(conf));
 		conf.hw_key_idx = sta->key_idx_compression;
 		conf.alg = ALG_NULL;
-		conf.force_sw_encrypt = 1;
+		conf.flags |= IEEE80211_KEY_FORCE_SW_ENCRYPT;
 		local->hw->set_key(local->mdev, DISABLE_KEY, sta->addr, &conf,
 				   sta->aid);
 		sta->key_idx_compression = HW_KEY_IDX_INVALID;
diff --git a/net/d80211/sta_info.h b/net/d80211/sta_info.h
index acac699..ad000a2 100644
--- a/net/d80211/sta_info.h
+++ b/net/d80211/sta_info.h
@@ -74,7 +74,7 @@ struct sta_info {
 	void *rate_ctrl_priv;
 
 	/* last received seq/frag number from this STA (per RX queue) */
-	u16 last_seq_ctrl[NUM_RX_DATA_QUEUES];
+	__le16 last_seq_ctrl[NUM_RX_DATA_QUEUES];
 	unsigned long num_duplicates; /* number of duplicate frames received
 				       * from this STA */
 	unsigned long tx_fragments; /* number of transmitted MPDUs */
diff --git a/net/d80211/tkip.c b/net/d80211/tkip.c
index 1e2621a..11966e0 100644
--- a/net/d80211/tkip.c
+++ b/net/d80211/tkip.c
@@ -191,17 +191,16 @@ u8 * ieee80211_tkip_add_iv(u8 *pos, stru
 }
 
 
-/* Encrypt packet payload with TKIP using @key. @pos is a pointer to the
- * beginning of the buffer containing payload. This payload must include
- * headroom of eight octets for IV and Ext. IV and taildroom of four octets
- * for ICV. @payload_len is the length of payload (_not_ including extra
- * headroom and tailroom). @ta is the transmitter addresses. */
-void ieee80211_tkip_encrypt_data(struct crypto_blkcipher *tfm,
-				 struct ieee80211_key *key,
-				 u8 *pos, size_t payload_len, u8 *ta)
+void ieee80211_tkip_gen_phase1key(struct ieee80211_key *key, u8 *ta,
+				  u16 *phase1key)
 {
-	u8 rc4key[16];
+	tkip_mixing_phase1(ta, &key->key[ALG_TKIP_TEMP_ENCR_KEY],
+			   key->u.tkip.iv32, phase1key);
+}
 
+void ieee80211_tkip_gen_rc4key(struct ieee80211_key *key, u8 *ta,
+			       u8 *rc4key)
+{
 	/* Calculate per-packet key */
 	if (key->u.tkip.iv16 == 0 || !key->u.tkip.tx_initialized) {
 		/* IV16 wrapped around - perform TKIP phase 1 */
@@ -212,7 +211,20 @@ void ieee80211_tkip_encrypt_data(struct 
 
 	tkip_mixing_phase2(key->u.tkip.p1k, &key->key[ALG_TKIP_TEMP_ENCR_KEY],
 			   key->u.tkip.iv16, rc4key);
+}
+
+/* Encrypt packet payload with TKIP using @key. @pos is a pointer to the
+ * beginning of the buffer containing payload. This payload must include
+ * headroom of eight octets for IV and Ext. IV and taildroom of four octets
+ * for ICV. @payload_len is the length of payload (_not_ including extra
+ * headroom and tailroom). @ta is the transmitter addresses. */
+void ieee80211_tkip_encrypt_data(struct crypto_blkcipher *tfm,
+				 struct ieee80211_key *key,
+				 u8 *pos, size_t payload_len, u8 *ta)
+{
+	u8 rc4key[16];
 
+	ieee80211_tkip_gen_rc4key(key, ta, rc4key);
 	pos = ieee80211_tkip_add_iv(pos, key, rc4key[0], rc4key[1], rc4key[2]);
 	ieee80211_wep_encrypt_data(tfm, rc4key, 16, pos, payload_len);
 }
diff --git a/net/d80211/tkip.h b/net/d80211/tkip.h
index c715077..a0d181a 100644
--- a/net/d80211/tkip.h
+++ b/net/d80211/tkip.h
@@ -15,6 +15,10 @@ #include "ieee80211_key.h"
 
 u8 * ieee80211_tkip_add_iv(u8 *pos, struct ieee80211_key *key,
 			   u8 iv0, u8 iv1, u8 iv2);
+void ieee80211_tkip_gen_phase1key(struct ieee80211_key *key, u8 *ta,
+				  u16 *phase1key);
+void ieee80211_tkip_gen_rc4key(struct ieee80211_key *key, u8 *ta,
+			       u8 *rc4key);
 void ieee80211_tkip_encrypt_data(struct crypto_blkcipher *tfm,
 				 struct ieee80211_key *key,
 				 u8 *pos, size_t payload_len, u8 *ta);
diff --git a/net/d80211/wpa.c b/net/d80211/wpa.c
index 04aef41..1b4fe9a 100644
--- a/net/d80211/wpa.c
+++ b/net/d80211/wpa.c
@@ -103,8 +103,11 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	}
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
-	    !tx->fragmented && !wpa_test) {
+	if (!tx->key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
+	    !tx->fragmented &&
+	    !(tx->local->hw->flags & IEEE80211_HW_TKIP_INCLUDE_MMIC) &&
+	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for Michael MIC
 		 */
 		return TXRX_CONTINUE;
@@ -168,8 +171,8 @@ ieee80211_rx_h_michael_mic_verify(struct
 	fc = rx->fc;
 
 	/* If device handles decryption totally, skip this check */
-	if (rx->local->hw->device_hides_wep ||
-	    rx->local->hw->device_strips_mic)
+	if ((rx->local->hw->flags & IEEE80211_HW_DEVICE_HIDES_WEP) ||
+	    (rx->local->hw->flags & IEEE80211_HW_DEVICE_STRIPS_MIC))
 		return TXRX_CONTINUE;
 
 	if (!rx->key || rx->key->alg != ALG_TKIP ||
@@ -183,8 +186,9 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !rx->key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
-		if (rx->local->hw->wep_include_iv) {
+	    !rx->key->force_sw_encrypt &&
+	    !(rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
+		if (rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) {
 			if (skb->len < MICHAEL_MIC_LEN)
 				return TXRX_DROP;
 		}
@@ -290,7 +294,8 @@ static int tkip_encrypt_skb(struct ieee8
 	hdrlen = ieee80211_get_hdrlen(fc);
 	len = skb->len - hdrlen;
 
-	tailneed = (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt)
+	tailneed = (!tx->key->force_sw_encrypt &&
+		    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT))
 		? 0 : TKIP_ICV_LEN;
 	if ((skb_headroom(skb) < TKIP_IV_LEN ||
 	     skb_tailroom(skb) < tailneed)) {
@@ -323,19 +328,38 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 skip_iv_inc:
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt
+	if (!tx->key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)
 #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	    && !tx->wpa_test
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 		) {
-		/* hwaccel - with preallocated room for IV */
+		u32 flags = tx->local->hw->flags;
+		hdr = (struct ieee80211_hdr *)skb->data;
 
+		/* hwaccel - with preallocated room for IV */
 		ieee80211_tkip_add_iv(pos, key,
 				      (u8) (key->u.tkip.iv16 >> 8),
 				      (u8) (((key->u.tkip.iv16 >> 8) | 0x20) &
 					    0x7f),
 				      (u8) key->u.tkip.iv16);
 
+		if (flags & IEEE80211_HW_TKIP_REQ_PHASE2_KEY)
+			ieee80211_tkip_gen_rc4key(key, hdr->addr2,
+						  tx->u.tx.control->tkip_key);
+		else if (flags & IEEE80211_HW_TKIP_REQ_PHASE1_KEY) {
+			if (key->u.tkip.iv16 == 0 ||
+			    !key->u.tkip.tx_initialized) {
+				ieee80211_tkip_gen_phase1key(key, hdr->addr2,
+					    (u16 *)tx->u.tx.control->tkip_key);
+				key->u.tkip.tx_initialized = 1;
+				tx->u.tx.control->flags |=
+					    IEEE80211_TXCTL_TKIP_NEW_PHASE1_KEY;
+			} else
+				tx->u.tx.control->flags &=
+					    ~IEEE80211_TXCTL_TKIP_NEW_PHASE1_KEY;
+		}
+
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
 		return 0;
 	}
@@ -399,8 +423,10 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 	}
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
-	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
-	    !tx->local->hw->wep_include_iv && !wpa_test) {
+	if (!tx->key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
+	    !(tx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV) &&
+	    !wpa_test) {
 		/* hwaccel - with no need for preallocated room for IV/ICV */
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
 		return TXRX_CONTINUE;
@@ -477,8 +503,9 @@ #ifdef CONFIG_HOSTAPD_WPA_TESTING
 #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !rx->key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
-		if (!rx->local->hw->wep_include_iv) {
+	    !rx->key->force_sw_encrypt &&
+	    !(rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
+		if (!(rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
 			/* Hardware takes care of all processing, including
 			 * replay protection, so no need to continue here. */
 			return TXRX_CONTINUE;
@@ -621,7 +648,8 @@ static int ccmp_encrypt_skb(struct ieee8
 	hdrlen = ieee80211_get_hdrlen(fc);
 	len = skb->len - hdrlen;
 
-	tailneed = (!key->force_sw_encrypt && !tx->local->conf.sw_decrypt)
+	tailneed = (!key->force_sw_encrypt &&
+		    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT))
 		? 0 : CCMP_MIC_LEN;
 
 	if ((skb_headroom(skb) < CCMP_HDR_LEN ||
@@ -662,7 +690,8 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 
 	ccmp_pn2hdr(pos, pn, key->keyidx);
 
-	if (!key->force_sw_encrypt && !tx->local->conf.sw_decrypt) {
+	if (!key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
 		/* hwaccel - with preallocated room for CCMP header */
 		tx->u.tx.control->key_idx = key->hw_key_idx;
 		return 0;
@@ -716,8 +745,9 @@ #endif /* CONFIG_HOSTAPD_WPA_TESTING */
 	tx->u.tx.control->iv_len = CCMP_HDR_LEN;
 	ieee80211_tx_set_iswep(tx);
 
-	if (!tx->key->force_sw_encrypt && !tx->local->conf.sw_decrypt &&
-	    !tx->local->hw->wep_include_iv) {
+	if (!tx->key->force_sw_encrypt &&
+	    !(tx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
+	    !(tx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV)) {
 		/* hwaccel - with no need for preallocated room for CCMP "
 		 * header or MIC fields */
 		tx->u.tx.control->key_idx = tx->key->hw_key_idx;
@@ -768,8 +798,9 @@ ieee80211_rx_h_ccmp_decrypt(struct ieee8
 		return TXRX_DROP;
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !key->force_sw_encrypt && !rx->local->conf.sw_decrypt &&
-	    !rx->local->hw->wep_include_iv)
+	    !key->force_sw_encrypt &&
+	    !(rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT) &&
+	    !(rx->local->hw->flags & IEEE80211_HW_WEP_INCLUDE_IV))
 		return TXRX_CONTINUE;
 
 	(void) ccmp_hdr2pn(pn, skb->data + hdrlen);
@@ -789,7 +820,8 @@ #endif /* CONFIG_D80211_DEBUG */
 	}
 
 	if ((rx->u.rx.status->flag & RX_FLAG_DECRYPTED) &&
-	    !key->force_sw_encrypt && !rx->local->conf.sw_decrypt) {
+	    !key->force_sw_encrypt &&
+	    !(rx->local->conf.flags & IEEE80211_CONF_SW_DECRYPT)) {
 		/* hwaccel has already decrypted frame and verified MIC */
 	} else {
 		u8 *scratch, *b_0, *aad;
-- 
John W. Linville
linville@tuxdriver.com
