From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6
Date: Mon, 26 Jun 2006 17:25:52 -0400
Message-ID: <20060626212547.GE30706@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:64519 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S933072AbWFZV0g (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 17:26:36 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit fcc18e83e1f6fd9fa6b333735bf0fcd530655511:
  Malcolm Parsons:
        uclinux: use PER_LINUX_32BIT in binfmt_flat

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Daniel Drake:
      bcm43xx: use softmac-suggested TX rate
      bcm43xx: enable shared key authentication

Eric Sesterhenn:
      skb used after passing to netif_rx in net/ieee80211/ieee80211_rx.c

Faidon Liambotis:
      Add two PLX device IDs

Hong Liu:
      ieee80211: fix not allocating IV+ICV space when usingencryption in ieee80211_tx_frame

Horms:
      CONFIG_WIRELESS_EXT is neccessary after all

John W. Linville:
      softmac: fix build-break from 881ee6999d66c8fc903b429b73bbe6045b38c549

Joseph Jezak:
      SoftMAC: Prevent multiple authentication attempts on the same network
      SoftMAC: Add network to ieee80211softmac_call_events when associate times out

Larry Finger:
      Convert bcm43xx-softmac to use the ieee80211_is_valid_channel routine
      2.6.17 missing a call to ieee80211softmac_capabilities from ieee80211softmac_assoc_req

Michael Buesch:
      bcm43xx: suspend MAC while executing long pwork
      bcm43xx: workaround init_board vs. IRQ race

 drivers/net/wireless/bcm43xx/bcm43xx.h         |    2 +
 drivers/net/wireless/bcm43xx/bcm43xx_main.c    |   82 +++++++++++++++---------
 drivers/net/wireless/bcm43xx/bcm43xx_main.h    |   24 -------
 drivers/net/wireless/bcm43xx/bcm43xx_radio.c   |    7 +-
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c      |    2 -
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c    |    5 +
 drivers/net/wireless/hostap/hostap_plx.c       |    2 +
 include/net/ieee80211softmac.h                 |    1 
 net/ieee80211/ieee80211_rx.c                   |    4 +
 net/ieee80211/ieee80211_tx.c                   |   15 +++-
 net/ieee80211/softmac/ieee80211softmac_assoc.c |   31 +++++++--
 net/ieee80211/softmac/ieee80211softmac_auth.c  |    4 +
 net/ieee80211/softmac/ieee80211softmac_io.c    |    3 +
 net/ieee80211/softmac/ieee80211softmac_wx.c    |   36 ++++++++++-
 14 files changed, 139 insertions(+), 79 deletions(-)

diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index d8f917c..d5e10e2 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -722,6 +722,8 @@ #endif
 	u32 irq_savedstate;
 	/* Link Quality calculation context. */
 	struct bcm43xx_noise_calculation noisecalc;
+	/* if > 0 MAC is suspended. if == 0 MAC is enabled. */
+	int mac_suspended;
 
 	/* Threshold values. */
 	//TODO: The RTS thr has to be _used_. Currently, it is only set via WX.
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index 085d785..af97755 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -1885,6 +1885,15 @@ static irqreturn_t bcm43xx_interrupt_han
 
 	spin_lock(&bcm->irq_lock);
 
+	/* Only accept IRQs, if we are initialized properly.
+	 * This avoids an RX race while initializing.
+	 * We should probably not enable IRQs before we are initialized
+	 * completely, but some careful work is needed to fix this. I think it
+	 * is best to stay with this cheap workaround for now... .
+	 */
+	if (unlikely(bcm43xx_status(bcm) != BCM43xx_STAT_INITIALIZED))
+		goto out;
+
 	reason = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
 	if (reason == 0xffffffff) {
 		/* irq not for us (shared irq) */
@@ -1906,19 +1915,11 @@ static irqreturn_t bcm43xx_interrupt_han
 
 	bcm43xx_interrupt_ack(bcm, reason);
 
-	/* Only accept IRQs, if we are initialized properly.
-	 * This avoids an RX race while initializing.
-	 * We should probably not enable IRQs before we are initialized
-	 * completely, but some careful work is needed to fix this. I think it
-	 * is best to stay with this cheap workaround for now... .
-	 */
-	if (likely(bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED)) {
-		/* disable all IRQs. They are enabled again in the bottom half. */
-		bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
-		/* save the reason code and call our bottom half. */
-		bcm->irq_reason = reason;
-		tasklet_schedule(&bcm->isr_tasklet);
-	}
+	/* disable all IRQs. They are enabled again in the bottom half. */
+	bcm->irq_savedstate = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
+	/* save the reason code and call our bottom half. */
+	bcm->irq_reason = reason;
+	tasklet_schedule(&bcm->isr_tasklet);
 
 out:
 	mmiowb();
@@ -2297,13 +2298,17 @@ static int bcm43xx_gpio_cleanup(struct b
 /* http://bcm-specs.sipsolutions.net/EnableMac */
 void bcm43xx_mac_enable(struct bcm43xx_private *bcm)
 {
-	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
-	                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
-			| BCM43xx_SBF_MAC_ENABLED);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, BCM43xx_IRQ_READY);
-	bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
-	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
-	bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
+	bcm->mac_suspended--;
+	assert(bcm->mac_suspended >= 0);
+	if (bcm->mac_suspended == 0) {
+		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
+		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
+				| BCM43xx_SBF_MAC_ENABLED);
+		bcm43xx_write32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON, BCM43xx_IRQ_READY);
+		bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD); /* dummy read */
+		bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
+		bcm43xx_power_saving_ctl_bits(bcm, -1, -1);
+	}
 }
 
 /* http://bcm-specs.sipsolutions.net/SuspendMAC */
@@ -2312,18 +2317,23 @@ void bcm43xx_mac_suspend(struct bcm43xx_
 	int i;
 	u32 tmp;
 
-	bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
-	bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
-	                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
-			& ~BCM43xx_SBF_MAC_ENABLED);
-	bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
-	for (i = 100000; i; i--) {
-		tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
-		if (tmp & BCM43xx_IRQ_READY)
-			return;
-		udelay(10);
+	assert(bcm->mac_suspended >= 0);
+	if (bcm->mac_suspended == 0) {
+		bcm43xx_power_saving_ctl_bits(bcm, -1, 1);
+		bcm43xx_write32(bcm, BCM43xx_MMIO_STATUS_BITFIELD,
+		                bcm43xx_read32(bcm, BCM43xx_MMIO_STATUS_BITFIELD)
+				& ~BCM43xx_SBF_MAC_ENABLED);
+		bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON); /* dummy read */
+		for (i = 100000; i; i--) {
+			tmp = bcm43xx_read32(bcm, BCM43xx_MMIO_GEN_IRQ_REASON);
+			if (tmp & BCM43xx_IRQ_READY)
+				goto out;
+			udelay(10);
+		}
+		printkl(KERN_ERR PFX "MAC suspend failed\n");
 	}
-	printkl(KERN_ERR PFX "MAC suspend failed\n");
+out:
+	bcm->mac_suspended++;
 }
 
 void bcm43xx_set_iwmode(struct bcm43xx_private *bcm,
@@ -3181,8 +3191,10 @@ static void bcm43xx_periodic_work_handle
 		/* Periodic work will take a long time, so we want it to
 		 * be preemtible.
 		 */
-		bcm43xx_lock_irqonly(bcm, flags);
 		netif_stop_queue(bcm->net_dev);
+		synchronize_net();
+		bcm43xx_lock_irqonly(bcm, flags);
+		bcm43xx_mac_suspend(bcm);
 		if (bcm43xx_using_pio(bcm))
 			bcm43xx_pio_freeze_txqueues(bcm);
 		savedirqs = bcm43xx_interrupt_disable(bcm, BCM43xx_IRQ_ALL);
@@ -3205,6 +3217,7 @@ static void bcm43xx_periodic_work_handle
 			bcm43xx_interrupt_enable(bcm, savedirqs);
 			if (bcm43xx_using_pio(bcm))
 				bcm43xx_pio_thaw_txqueues(bcm);
+			bcm43xx_mac_enable(bcm);
 		}
 		netif_wake_queue(bcm->net_dev);
 		mmiowb();
@@ -3661,6 +3674,10 @@ static void bcm43xx_ieee80211_set_securi
 		secinfo->encrypt = sec->encrypt;
 		dprintk(", .encrypt = %d", sec->encrypt);
 	}
+	if (sec->flags & SEC_AUTH_MODE) {
+		secinfo->auth_mode = sec->auth_mode;
+		dprintk(", .auth_mode = %d\n", sec->auth_mode);
+	}
 	dprintk("\n");
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED &&
 	    !bcm->ieee->host_encrypt) {
@@ -3776,6 +3793,7 @@ static int bcm43xx_init_private(struct b
 	bcm->softmac->set_channel = bcm43xx_ieee80211_set_chan;
 
 	bcm->irq_savedstate = BCM43xx_IRQ_INITIAL;
+	bcm->mac_suspended = 1;
 	bcm->pci_dev = pci_dev;
 	bcm->net_dev = net_dev;
 	bcm->bad_frames_preempt = modparam_bad_frames_preempt;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.h b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
index 30a202b..1164936 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.h
@@ -112,30 +112,6 @@ int bcm43xx_channel_to_freq(struct bcm43
 	return bcm43xx_channel_to_freq_bg(channel);
 }
 
-/* Lightweight function to check if a channel number is valid.
- * Note that this does _NOT_ check for geographical restrictions!
- */
-static inline
-int bcm43xx_is_valid_channel_a(u8 channel)
-{
-	return (channel >= IEEE80211_52GHZ_MIN_CHANNEL
-	       && channel <= IEEE80211_52GHZ_MAX_CHANNEL);
-}
-static inline
-int bcm43xx_is_valid_channel_bg(u8 channel)
-{
-	return (channel >= IEEE80211_24GHZ_MIN_CHANNEL
-	       && channel <= IEEE80211_24GHZ_MAX_CHANNEL);
-}
-static inline
-int bcm43xx_is_valid_channel(struct bcm43xx_private *bcm,
-			     u8 channel)
-{
-	if (bcm43xx_current_phy(bcm)->type == BCM43xx_PHYTYPE_A)
-		return bcm43xx_is_valid_channel_a(channel);
-	return bcm43xx_is_valid_channel_bg(channel);
-}
-
 void bcm43xx_tsf_read(struct bcm43xx_private *bcm, u64 *tsf);
 void bcm43xx_tsf_write(struct bcm43xx_private *bcm, u64 tsf);
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
index af5c0bf..bb9c484 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_radio.c
@@ -1594,11 +1594,11 @@ int bcm43xx_radio_selectchannel(struct b
 	u16 r8, tmp;
 	u16 freq;
 
+	if (!ieee80211_is_valid_channel(bcm->ieee, channel))
+		return -EINVAL;
 	if ((radio->manufact == 0x17F) &&
 	    (radio->version == 0x2060) &&
 	    (radio->revision == 1)) {
-		if (channel > 200)
-			return -EINVAL;
 		freq = channel2freq_a(channel);
 
 		r8 = bcm43xx_radio_read16(bcm, 0x0008);
@@ -1651,9 +1651,6 @@ int bcm43xx_radio_selectchannel(struct b
 		TODO();	//TODO:	TSSI2dbm workaround
 		bcm43xx_phy_xmitpower(bcm);//FIXME correct?
 	} else {
-		if ((channel < 1) || (channel > 14))
-			return -EINVAL;
-
 		if (synthetic_pu_workaround)
 			bcm43xx_synth_pu_workaround(bcm, channel);
 
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index c35cb3a..5c36e29 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -119,7 +119,7 @@ static int bcm43xx_wx_set_channelfreq(st
 		channel = bcm43xx_freq_to_channel(bcm, data->freq.m);
 		freq = data->freq.m;
 	}
-	if (!bcm43xx_is_valid_channel(bcm, channel))
+	if (!ieee80211_is_valid_channel(bcm->ieee, channel))
 		goto out_unlock;
 	if (bcm43xx_status(bcm) == BCM43xx_STAT_INITIALIZED) {
 		//ieee80211softmac_disassoc(softmac, $REASON);
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
index d8ece28..6dbd855 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -296,11 +296,14 @@ void bcm43xx_generate_txhdr(struct bcm43
 	u16 control = 0;
 	u16 wsec_rate = 0;
 	u16 encrypt_frame;
+	const u16 ftype = WLAN_FC_GET_TYPE(le16_to_cpu(wireless_header->frame_ctl));
+	const int is_mgt = (ftype == IEEE80211_FTYPE_MGMT);
 
 	/* Now construct the TX header. */
 	memset(txhdr, 0, sizeof(*txhdr));
 
-	bitrate = bcm->softmac->txrates.default_rate;
+	bitrate = ieee80211softmac_suggest_txrate(bcm->softmac,
+		is_multicast_ether_addr(wireless_header->addr1), is_mgt);
 	ofdm_modulation = !(ieee80211_is_cck_rate(bitrate));
 	fallback_bitrate = bcm43xx_calc_fallback_rate(bitrate);
 	fallback_ofdm_modulation = !(ieee80211_is_cck_rate(fallback_bitrate));
diff --git a/drivers/net/wireless/hostap/hostap_plx.c b/drivers/net/wireless/hostap/hostap_plx.c
index edaaa94..39c545e 100644
--- a/drivers/net/wireless/hostap/hostap_plx.c
+++ b/drivers/net/wireless/hostap/hostap_plx.c
@@ -67,10 +67,12 @@ static struct pci_device_id prism2_plx_i
 	PLXDEV(0x10b7, 0x7770, "3Com AirConnect PCI 777A"),
 	PLXDEV(0x111a, 0x1023, "Siemens SpeedStream SS1023"),
 	PLXDEV(0x126c, 0x8030, "Nortel emobility"),
+	PLXDEV(0x1562, 0x0001, "Symbol LA-4123"),
 	PLXDEV(0x1385, 0x4100, "Netgear MA301"),
 	PLXDEV(0x15e8, 0x0130, "National Datacomm NCP130 (PLX9052)"),
 	PLXDEV(0x15e8, 0x0131, "National Datacomm NCP130 (TMD7160)"),
 	PLXDEV(0x1638, 0x1100, "Eumitcom WL11000"),
+	PLXDEV(0x16ab, 0x1100, "Global Sun Tech GL24110P"),
 	PLXDEV(0x16ab, 0x1101, "Global Sun Tech GL24110P (?)"),
 	PLXDEV(0x16ab, 0x1102, "Linksys WPC11 with WDT11"),
 	PLXDEV(0x16ab, 0x1103, "Longshine 8031"),
diff --git a/include/net/ieee80211softmac.h b/include/net/ieee80211softmac.h
index 7a483ab..00ad810 100644
--- a/include/net/ieee80211softmac.h
+++ b/include/net/ieee80211softmac.h
@@ -104,6 +104,7 @@ struct ieee80211softmac_assoc_info {
 	 */
 	u8 static_essid:1,
 	   associating:1,
+	   assoc_wait:1,
 	   bssvalid:1,
 	   bssfixed:1;
 
diff --git a/net/ieee80211/ieee80211_rx.c b/net/ieee80211/ieee80211_rx.c
index 2bf567f..b2fabbb 100644
--- a/net/ieee80211/ieee80211_rx.c
+++ b/net/ieee80211/ieee80211_rx.c
@@ -369,6 +369,7 @@ #endif
 
 	/* Put this code here so that we avoid duplicating it in all
 	 * Rx paths. - Jean II */
+#ifdef CONFIG_WIRELESS_EXT
 #ifdef IW_WIRELESS_SPY		/* defined in iw_handler.h */
 	/* If spy monitoring on */
 	if (ieee->spy_data.spy_number > 0) {
@@ -397,15 +398,16 @@ #ifdef IW_WIRELESS_SPY		/* defined in iw
 		wireless_spy_update(ieee->dev, hdr->addr2, &wstats);
 	}
 #endif				/* IW_WIRELESS_SPY */
+#endif				/* CONFIG_WIRELESS_EXT */
 
 #ifdef NOT_YET
 	hostap_update_rx_stats(local->ap, hdr, rx_stats);
 #endif
 
 	if (ieee->iw_mode == IW_MODE_MONITOR) {
-		ieee80211_monitor_rx(ieee, skb, rx_stats);
 		stats->rx_packets++;
 		stats->rx_bytes += skb->len;
+		ieee80211_monitor_rx(ieee, skb, rx_stats);
 		return 1;
 	}
 
diff --git a/net/ieee80211/ieee80211_tx.c b/net/ieee80211/ieee80211_tx.c
index 6a5de1b..e63bf77 100644
--- a/net/ieee80211/ieee80211_tx.c
+++ b/net/ieee80211/ieee80211_tx.c
@@ -563,10 +563,13 @@ int ieee80211_tx_frame(struct ieee80211_
 	struct net_device_stats *stats = &ieee->stats;
 	struct sk_buff *skb_frag;
 	int priority = -1;
+	int fraglen = total_len;
+	int headroom = ieee->tx_headroom;
+	struct ieee80211_crypt_data *crypt = ieee->crypt[ieee->tx_keyidx];
 
 	spin_lock_irqsave(&ieee->lock, flags);
 
-	if (encrypt_mpdu && !ieee->sec.encrypt)
+	if (encrypt_mpdu && (!ieee->sec.encrypt || !crypt))
 		encrypt_mpdu = 0;
 
 	/* If there is no driver handler to take the TXB, dont' bother
@@ -582,20 +585,24 @@ int ieee80211_tx_frame(struct ieee80211_
 		goto success;
 	}
 
-	if (encrypt_mpdu)
+	if (encrypt_mpdu) {
 		frame->frame_ctl |= cpu_to_le16(IEEE80211_FCTL_PROTECTED);
+		fraglen += crypt->ops->extra_mpdu_prefix_len +
+			   crypt->ops->extra_mpdu_postfix_len;
+		headroom += crypt->ops->extra_mpdu_prefix_len;
+	}
 
 	/* When we allocate the TXB we allocate enough space for the reserve
 	 * and full fragment bytes (bytes_per_frag doesn't include prefix,
 	 * postfix, header, FCS, etc.) */
-	txb = ieee80211_alloc_txb(1, total_len, ieee->tx_headroom, GFP_ATOMIC);
+	txb = ieee80211_alloc_txb(1, fraglen, headroom, GFP_ATOMIC);
 	if (unlikely(!txb)) {
 		printk(KERN_WARNING "%s: Could not allocate TXB\n",
 		       ieee->dev->name);
 		goto failed;
 	}
 	txb->encrypted = 0;
-	txb->payload_size = total_len;
+	txb->payload_size = fraglen;
 
 	skb_frag = txb->fragments[0];
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_assoc.c b/net/ieee80211/softmac/ieee80211softmac_assoc.c
index 5e9a906..44215ce 100644
--- a/net/ieee80211/softmac/ieee80211softmac_assoc.c
+++ b/net/ieee80211/softmac/ieee80211softmac_assoc.c
@@ -47,9 +47,7 @@ ieee80211softmac_assoc(struct ieee80211s
 	
 	dprintk(KERN_INFO PFX "sent association request!\n");
 
-	/* Change the state to associating */
 	spin_lock_irqsave(&mac->lock, flags);
-	mac->associnfo.associating = 1;
 	mac->associated = 0; /* just to make sure */
 
 	/* Set a timer for timeout */
@@ -63,6 +61,7 @@ void
 ieee80211softmac_assoc_timeout(void *d)
 {
 	struct ieee80211softmac_device *mac = (struct ieee80211softmac_device *)d;
+	struct ieee80211softmac_network *n;
 	unsigned long flags;
 
 	spin_lock_irqsave(&mac->lock, flags);
@@ -75,11 +74,12 @@ ieee80211softmac_assoc_timeout(void *d)
 	mac->associnfo.associating = 0;
 	mac->associnfo.bssvalid = 0;
 	mac->associated = 0;
+
+	n = ieee80211softmac_get_network_by_bssid_locked(mac, mac->associnfo.bssid);
 	spin_unlock_irqrestore(&mac->lock, flags);
 
 	dprintk(KERN_INFO PFX "assoc request timed out!\n");
-	/* FIXME: we need to know the network here. that requires a bit of restructuring */
-	ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_TIMEOUT, NULL);
+	ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_TIMEOUT, n);
 }
 
 void
@@ -203,6 +203,10 @@ ieee80211softmac_assoc_work(void *d)
 	if (mac->associated)
 		ieee80211softmac_send_disassoc_req(mac, WLAN_REASON_DISASSOC_STA_HAS_LEFT);
 
+	spin_lock_irqsave(&mac->lock, flags);
+	mac->associnfo.associating = 1;
+	spin_unlock_irqrestore(&mac->lock, flags);
+
 	/* try to find the requested network in our list, if we found one already */
 	if (bssvalid || mac->associnfo.bssfixed)
 		found = ieee80211softmac_get_network_by_bssid(mac, mac->associnfo.bssid);	
@@ -295,19 +299,32 @@ ieee80211softmac_assoc_work(void *d)
 	memcpy(mac->associnfo.associate_essid.data, found->essid.data, IW_ESSID_MAX_SIZE + 1);
 	
 	/* we found a network! authenticate (if necessary) and associate to it. */
-	if (!found->authenticated) {
+	if (found->authenticating) {
+		dprintk(KERN_INFO PFX "Already requested authentication, waiting...\n");
+		if(!mac->associnfo.assoc_wait) {
+			mac->associnfo.assoc_wait = 1;
+			ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify_auth, NULL, GFP_KERNEL);
+		}
+		return;
+	}
+	if (!found->authenticated && !found->authenticating) {
 		/* This relies on the fact that _auth_req only queues the work,
 		 * otherwise adding the notification would be racy. */
 		if (!ieee80211softmac_auth_req(mac, found)) {
-			dprintk(KERN_INFO PFX "cannot associate without being authenticated, requested authentication\n");
-			ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify_auth, NULL, GFP_KERNEL);
+			if(!mac->associnfo.assoc_wait) {
+				dprintk(KERN_INFO PFX "Cannot associate without being authenticated, requested authentication\n");
+				mac->associnfo.assoc_wait = 1;
+				ieee80211softmac_notify_internal(mac, IEEE80211SOFTMAC_EVENT_ANY, found, ieee80211softmac_assoc_notify_auth, NULL, GFP_KERNEL);
+			}
 		} else {
 			printkl(KERN_WARNING PFX "Not authenticated, but requesting authentication failed. Giving up to associate\n");
+			mac->associnfo.assoc_wait = 0;
 			ieee80211softmac_call_events(mac, IEEE80211SOFTMAC_EVENT_ASSOCIATE_FAILED, found);
 		}
 		return;
 	}
 	/* finally! now we can start associating */
+	mac->associnfo.assoc_wait = 0;
 	ieee80211softmac_assoc(mac, found);
 }
 
diff --git a/net/ieee80211/softmac/ieee80211softmac_auth.c b/net/ieee80211/softmac/ieee80211softmac_auth.c
index 90b8484..ebc33ca 100644
--- a/net/ieee80211/softmac/ieee80211softmac_auth.c
+++ b/net/ieee80211/softmac/ieee80211softmac_auth.c
@@ -36,8 +36,9 @@ ieee80211softmac_auth_req(struct ieee802
 	struct ieee80211softmac_auth_queue_item *auth;
 	unsigned long flags;
 	
-	if (net->authenticating)
+	if (net->authenticating || net->authenticated)
 		return 0;
+	net->authenticating = 1;
 
 	/* Add the network if it's not already added */
 	ieee80211softmac_add_network(mac, net);
@@ -92,7 +93,6 @@ ieee80211softmac_auth_queue(void *data)
 			return;
 		}
 		net->authenticated = 0;
-		net->authenticating = 1;
 		/* add a timeout call so we eventually give up waiting for an auth reply */
 		schedule_delayed_work(&auth->work, IEEE80211SOFTMAC_AUTH_TIMEOUT);
 		auth->retry--;
diff --git a/net/ieee80211/softmac/ieee80211softmac_io.c b/net/ieee80211/softmac/ieee80211softmac_io.c
index 0954161..8cc8b20 100644
--- a/net/ieee80211/softmac/ieee80211softmac_io.c
+++ b/net/ieee80211/softmac/ieee80211softmac_io.c
@@ -229,6 +229,9 @@ ieee80211softmac_assoc_req(struct ieee80
 		return 0;
 	ieee80211softmac_hdr_3addr(mac, &((*pkt)->header), IEEE80211_STYPE_ASSOC_REQ, net->bssid, net->bssid);
 
+	/* Fill in the capabilities */
+	(*pkt)->capability = ieee80211softmac_capabilities(mac, net);
+
 	/* Fill in Listen Interval (?) */
 	(*pkt)->listen_interval = cpu_to_le16(10);
 	
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 0e65ff4..75320b6 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -70,12 +70,44 @@ ieee80211softmac_wx_set_essid(struct net
 			      char *extra)
 {
 	struct ieee80211softmac_device *sm = ieee80211_priv(net_dev);
+	struct ieee80211softmac_network *n;
+	struct ieee80211softmac_auth_queue_item *authptr;
 	int length = 0;
 	unsigned long flags;
-	
+
+	/* Check if we're already associating to this or another network
+	 * If it's another network, cancel and start over with our new network
+	 * If it's our network, ignore the change, we're already doing it!
+	 */
+	if((sm->associnfo.associating || sm->associated) &&
+	   (data->essid.flags && data->essid.length && extra)) {
+		/* Get the associating network */
+		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
+		if(n && n->essid.len == (data->essid.length - 1) &&
+		   !memcmp(n->essid.data, extra, n->essid.len)) {
+			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
+				MAC_ARG(sm->associnfo.bssid));
+			return 0;
+		} else {
+			dprintk(KERN_INFO PFX "Canceling existing associate request!\n");
+			spin_lock_irqsave(&sm->lock,flags);
+			/* Cancel assoc work */
+			cancel_delayed_work(&sm->associnfo.work);
+			/* We don't have to do this, but it's a little cleaner */
+			list_for_each_entry(authptr, &sm->auth_queue, list)
+				cancel_delayed_work(&authptr->work);
+			sm->associnfo.bssvalid = 0;
+			sm->associnfo.bssfixed = 0;
+			spin_unlock_irqrestore(&sm->lock,flags);
+			flush_scheduled_work();
+		}
+	}
+
+
 	spin_lock_irqsave(&sm->lock, flags);
-	
+
 	sm->associnfo.static_essid = 0;
+	sm->associnfo.assoc_wait = 0;
 
 	if (data->essid.flags && data->essid.length && extra /*required?*/) {
 		length = min(data->essid.length - 1, IW_ESSID_MAX_SIZE);
-- 
John W. Linville
linville@tuxdriver.com
