From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-11-13
Date: Thu, 13 Nov 2014 16:28:16 -0500
Message-ID: <20141113212815.GA12075@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="r5Pyd7+fXNt84Ff3"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--r5Pyd7+fXNt84Ff3
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this set of a few more wireless fixes intended for the
3.18 stream...

For the mac80211 bits, Johannes says:

"This has just one fix, for an issue with the CCMP decryption
that can cause a kernel crash. I'm not sure it's remotely
exploitable, but it's an important fix nonetheless."

For the iwlwifi bits, Emmanuel says:

"Two fixes here - we weren't updating mac80211 if a scan
was cut short by RFKILL which confused cfg80211. As a
result, the latter wouldn't allow to run another scan.
Liad fixes a small bug in the firmware dump."

On top of that...

Arend van Spriel corrects a channel width conversion that caused a
WARNING in brcmfmac.

Hauke Mehrtens avoids a NULL pointer dereference in b43.

Larry Finger hits a trio of rtlwifi bugs left over from recent
backporting from the Realtek vendor driver.

Miaoqing Pan fixes a clocking problem in ath9k that could affect
packet timestamps and such.

Stanislaw Gruszka addresses an payload alignment issue that has been
plaguing rt2x00.

Please let me know if there are problems!

John

---

The following changes since commit 0c9a67c8f1d2b71a89f66349362412e9bf6becab:

  Merge tag 'mac80211-for-john-2014-11-04' of git://git.kernel.org/pub/scm/=
linux/kernel/git/jberg/mac80211 (2014-11-04 15:56:33 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-11-11

for you to fetch changes up to 4e6ce4dc7ce71d0886908d55129d5d6482a27ff9:

  ath9k: Fix RTC_DERIVED_CLK usage (2014-11-11 16:24:18 -0500)

----------------------------------------------------------------
Arend van Spriel (1):
      brcmfmac: fix conversion of channel width 20MHZ_NOHT

Emmanuel Grumbach (1):
      iwlwifi: mvm: abort scan upon RFKILL

Hauke Mehrtens (1):
      b43: fix NULL pointer dereference in b43_phy_copy()

John W. Linville (2):
      Merge tag 'mac80211-for-john-2014-11-10' of git://git.kernel.org/.../=
jberg/mac80211
      Merge tag 'iwlwifi-for-john-2014-11-10' of git://git.kernel.org/.../i=
wlwifi/iwlwifi-fixes

Larry Finger (3):
      rtlwifi: Fix setting of tx descriptor for new trx flow
      rtlwifi: Fix errors in descriptor manipulation
      rtlwifi: rtl8192se: Fix connection problems

Liad Kaufman (1):
      iwlwifi: pcie: fix prph dump length

Miaoqing Pan (1):
      ath9k: Fix RTC_DERIVED_CLK usage

Ronald Wahl (1):
      mac80211: Fix regression that triggers a kernel BUG with CCMP

Stanislaw Gruszka (1):
      rt2x00: do not align payload on modern H/W

 drivers/net/wireless/ath/ath9k/ar9003_phy.c        | 13 ++++++
 drivers/net/wireless/ath/ath9k/hw.c                | 13 ------
 drivers/net/wireless/b43/phy_common.c              |  4 +-
 .../net/wireless/brcm80211/brcmfmac/wl_cfg80211.c  |  6 +++
 drivers/net/wireless/iwlwifi/mvm/scan.c            | 20 ++++-----
 drivers/net/wireless/iwlwifi/pcie/trans.c          |  3 +-
 drivers/net/wireless/rt2x00/rt2x00queue.c          | 50 ++++++------------=
----
 drivers/net/wireless/rtlwifi/pci.c                 | 19 +++++---
 drivers/net/wireless/rtlwifi/rtl8192se/hw.c        |  7 ++-
 drivers/net/wireless/rtlwifi/rtl8192se/phy.c       |  2 +
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c        | 16 +++++++
 net/mac80211/aes_ccm.c                             |  3 ++
 12 files changed, 81 insertions(+), 75 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/ar9003_phy.c b/drivers/net/wire=
less/ath/ath9k/ar9003_phy.c
index 697c4ae90af0..1e8ea5e4d4ca 100644
--- a/drivers/net/wireless/ath/ath9k/ar9003_phy.c
+++ b/drivers/net/wireless/ath/ath9k/ar9003_phy.c
@@ -664,6 +664,19 @@ static void ar9003_hw_override_ini(struct ath_hw *ah)
 		ah->enabled_cals |=3D TX_CL_CAL;
 	else
 		ah->enabled_cals &=3D ~TX_CL_CAL;
+
+	if (AR_SREV_9340(ah) || AR_SREV_9531(ah) || AR_SREV_9550(ah)) {
+		if (ah->is_clk_25mhz) {
+			REG_WRITE(ah, AR_RTC_DERIVED_CLK, 0x17c << 1);
+			REG_WRITE(ah, AR_SLP32_MODE, 0x0010f3d7);
+			REG_WRITE(ah, AR_SLP32_INC, 0x0001e7ae);
+		} else {
+			REG_WRITE(ah, AR_RTC_DERIVED_CLK, 0x261 << 1);
+			REG_WRITE(ah, AR_SLP32_MODE, 0x0010f400);
+			REG_WRITE(ah, AR_SLP32_INC, 0x0001e800);
+		}
+		udelay(100);
+	}
 }
=20
 static void ar9003_hw_prog_ini(struct ath_hw *ah,
diff --git a/drivers/net/wireless/ath/ath9k/hw.c b/drivers/net/wireless/ath=
/ath9k/hw.c
index 8be4b1453394..2ad605760e21 100644
--- a/drivers/net/wireless/ath/ath9k/hw.c
+++ b/drivers/net/wireless/ath/ath9k/hw.c
@@ -861,19 +861,6 @@ static void ath9k_hw_init_pll(struct ath_hw *ah,
 	udelay(RTC_PLL_SETTLE_DELAY);
=20
 	REG_WRITE(ah, AR_RTC_SLEEP_CLK, AR_RTC_FORCE_DERIVED_CLK);
-
-	if (AR_SREV_9340(ah) || AR_SREV_9550(ah)) {
-		if (ah->is_clk_25mhz) {
-			REG_WRITE(ah, AR_RTC_DERIVED_CLK, 0x17c << 1);
-			REG_WRITE(ah, AR_SLP32_MODE, 0x0010f3d7);
-			REG_WRITE(ah,  AR_SLP32_INC, 0x0001e7ae);
-		} else {
-			REG_WRITE(ah, AR_RTC_DERIVED_CLK, 0x261 << 1);
-			REG_WRITE(ah, AR_SLP32_MODE, 0x0010f400);
-			REG_WRITE(ah,  AR_SLP32_INC, 0x0001e800);
-		}
-		udelay(100);
-	}
 }
=20
 static void ath9k_hw_init_interrupt_masks(struct ath_hw *ah,
diff --git a/drivers/net/wireless/b43/phy_common.c b/drivers/net/wireless/b=
43/phy_common.c
index 1dfc682a8055..ee27b06074e1 100644
--- a/drivers/net/wireless/b43/phy_common.c
+++ b/drivers/net/wireless/b43/phy_common.c
@@ -300,9 +300,7 @@ void b43_phy_write(struct b43_wldev *dev, u16 reg, u16 =
value)
=20
 void b43_phy_copy(struct b43_wldev *dev, u16 destreg, u16 srcreg)
 {
-	assert_mac_suspended(dev);
-	dev->phy.ops->phy_write(dev, destreg,
-		dev->phy.ops->phy_read(dev, srcreg));
+	b43_phy_write(dev, destreg, b43_phy_read(dev, srcreg));
 }
=20
 void b43_phy_mask(struct b43_wldev *dev, u16 offset, u16 mask)
diff --git a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c b/driver=
s/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
index 28fa25b509db..39b45c038a93 100644
--- a/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
+++ b/drivers/net/wireless/brcm80211/brcmfmac/wl_cfg80211.c
@@ -299,6 +299,7 @@ static u16 chandef_to_chanspec(struct brcmu_d11inf *d11=
inf,
 	primary_offset =3D ch->center_freq1 - ch->chan->center_freq;
 	switch (ch->width) {
 	case NL80211_CHAN_WIDTH_20:
+	case NL80211_CHAN_WIDTH_20_NOHT:
 		ch_inf.bw =3D BRCMU_CHAN_BW_20;
 		WARN_ON(primary_offset !=3D 0);
 		break;
@@ -323,6 +324,10 @@ static u16 chandef_to_chanspec(struct brcmu_d11inf *d1=
1inf,
 				ch_inf.sb =3D BRCMU_CHAN_SB_LU;
 		}
 		break;
+	case NL80211_CHAN_WIDTH_80P80:
+	case NL80211_CHAN_WIDTH_160:
+	case NL80211_CHAN_WIDTH_5:
+	case NL80211_CHAN_WIDTH_10:
 	default:
 		WARN_ON_ONCE(1);
 	}
@@ -333,6 +338,7 @@ static u16 chandef_to_chanspec(struct brcmu_d11inf *d11=
inf,
 	case IEEE80211_BAND_5GHZ:
 		ch_inf.band =3D BRCMU_CHAN_BAND_5G;
 		break;
+	case IEEE80211_BAND_60GHZ:
 	default:
 		WARN_ON_ONCE(1);
 	}
diff --git a/drivers/net/wireless/iwlwifi/mvm/scan.c b/drivers/net/wireless=
/iwlwifi/mvm/scan.c
index b280d5d87127..7554f7053830 100644
--- a/drivers/net/wireless/iwlwifi/mvm/scan.c
+++ b/drivers/net/wireless/iwlwifi/mvm/scan.c
@@ -602,16 +602,6 @@ static int iwl_mvm_cancel_regular_scan(struct iwl_mvm =
*mvm)
 					       SCAN_COMPLETE_NOTIFICATION };
 	int ret;
=20
-	if (mvm->scan_status =3D=3D IWL_MVM_SCAN_NONE)
-		return 0;
-
-	if (iwl_mvm_is_radio_killed(mvm)) {
-		ieee80211_scan_completed(mvm->hw, true);
-		iwl_mvm_unref(mvm, IWL_MVM_REF_SCAN);
-		mvm->scan_status =3D IWL_MVM_SCAN_NONE;
-		return 0;
-	}
-
 	iwl_init_notification_wait(&mvm->notif_wait, &wait_scan_abort,
 				   scan_abort_notif,
 				   ARRAY_SIZE(scan_abort_notif),
@@ -1400,6 +1390,16 @@ int iwl_mvm_unified_sched_scan_lmac(struct iwl_mvm *=
mvm,
=20
 int iwl_mvm_cancel_scan(struct iwl_mvm *mvm)
 {
+	if (mvm->scan_status =3D=3D IWL_MVM_SCAN_NONE)
+		return 0;
+
+	if (iwl_mvm_is_radio_killed(mvm)) {
+		ieee80211_scan_completed(mvm->hw, true);
+		iwl_mvm_unref(mvm, IWL_MVM_REF_SCAN);
+		mvm->scan_status =3D IWL_MVM_SCAN_NONE;
+		return 0;
+	}
+
 	if (mvm->fw->ucode_capa.api[0] & IWL_UCODE_TLV_API_LMAC_SCAN)
 		return iwl_mvm_scan_offload_stop(mvm, true);
 	return iwl_mvm_cancel_regular_scan(mvm);
diff --git a/drivers/net/wireless/iwlwifi/pcie/trans.c b/drivers/net/wirele=
ss/iwlwifi/pcie/trans.c
index 160c3ebc48d0..dd2f3f8baa9d 100644
--- a/drivers/net/wireless/iwlwifi/pcie/trans.c
+++ b/drivers/net/wireless/iwlwifi/pcie/trans.c
@@ -1894,8 +1894,7 @@ static u32 iwl_trans_pcie_dump_prph(struct iwl_trans =
*trans,
 		int reg;
 		__le32 *val;
=20
-		prph_len +=3D sizeof(*data) + sizeof(*prph) +
-			num_bytes_in_chunk;
+		prph_len +=3D sizeof(**data) + sizeof(*prph) + num_bytes_in_chunk;
=20
 		(*data)->type =3D cpu_to_le32(IWL_FW_ERROR_DUMP_PRPH);
 		(*data)->len =3D cpu_to_le32(sizeof(*prph) +
diff --git a/drivers/net/wireless/rt2x00/rt2x00queue.c b/drivers/net/wirele=
ss/rt2x00/rt2x00queue.c
index 8e68f87ab13c..66ff36447b94 100644
--- a/drivers/net/wireless/rt2x00/rt2x00queue.c
+++ b/drivers/net/wireless/rt2x00/rt2x00queue.c
@@ -158,55 +158,29 @@ void rt2x00queue_align_frame(struct sk_buff *skb)
 	skb_trim(skb, frame_length);
 }
=20
-void rt2x00queue_insert_l2pad(struct sk_buff *skb, unsigned int header_len=
gth)
+/*
+ * H/W needs L2 padding between the header and the paylod if header size
+ * is not 4 bytes aligned.
+ */
+void rt2x00queue_insert_l2pad(struct sk_buff *skb, unsigned int hdr_len)
 {
-	unsigned int payload_length =3D skb->len - header_length;
-	unsigned int header_align =3D ALIGN_SIZE(skb, 0);
-	unsigned int payload_align =3D ALIGN_SIZE(skb, header_length);
-	unsigned int l2pad =3D payload_length ? L2PAD_SIZE(header_length) : 0;
+	unsigned int l2pad =3D (skb->len > hdr_len) ? L2PAD_SIZE(hdr_len) : 0;
=20
-	/*
-	 * Adjust the header alignment if the payload needs to be moved more
-	 * than the header.
-	 */
-	if (payload_align > header_align)
-		header_align +=3D 4;
-
-	/* There is nothing to do if no alignment is needed */
-	if (!header_align)
+	if (!l2pad)
 		return;
=20
-	/* Reserve the amount of space needed in front of the frame */
-	skb_push(skb, header_align);
-
-	/*
-	 * Move the header.
-	 */
-	memmove(skb->data, skb->data + header_align, header_length);
-
-	/* Move the payload, if present and if required */
-	if (payload_length && payload_align)
-		memmove(skb->data + header_length + l2pad,
-			skb->data + header_length + l2pad + payload_align,
-			payload_length);
-
-	/* Trim the skb to the correct size */
-	skb_trim(skb, header_length + l2pad + payload_length);
+	skb_push(skb, l2pad);
+	memmove(skb->data, skb->data + l2pad, hdr_len);
 }
=20
-void rt2x00queue_remove_l2pad(struct sk_buff *skb, unsigned int header_len=
gth)
+void rt2x00queue_remove_l2pad(struct sk_buff *skb, unsigned int hdr_len)
 {
-	/*
-	 * L2 padding is only present if the skb contains more than just the
-	 * IEEE 802.11 header.
-	 */
-	unsigned int l2pad =3D (skb->len > header_length) ?
-				L2PAD_SIZE(header_length) : 0;
+	unsigned int l2pad =3D (skb->len > hdr_len) ? L2PAD_SIZE(hdr_len) : 0;
=20
 	if (!l2pad)
 		return;
=20
-	memmove(skb->data + l2pad, skb->data, header_length);
+	memmove(skb->data + l2pad, skb->data, hdr_len);
 	skb_pull(skb, l2pad);
 }
=20
diff --git a/drivers/net/wireless/rtlwifi/pci.c b/drivers/net/wireless/rtlw=
ifi/pci.c
index 25daa8715219..61f5d36eca6a 100644
--- a/drivers/net/wireless/rtlwifi/pci.c
+++ b/drivers/net/wireless/rtlwifi/pci.c
@@ -842,7 +842,8 @@ static void _rtl_pci_rx_interrupt(struct ieee80211_hw *=
hw)
 			break;
 		}
 		/* handle command packet here */
-		if (rtlpriv->cfg->ops->rx_command_packet(hw, stats, skb)) {
+		if (rtlpriv->cfg->ops->rx_command_packet &&
+		    rtlpriv->cfg->ops->rx_command_packet(hw, stats, skb)) {
 				dev_kfree_skb_any(skb);
 				goto end;
 		}
@@ -1127,9 +1128,14 @@ static void _rtl_pci_prepare_bcn_tasklet(struct ieee=
80211_hw *hw)
=20
 	__skb_queue_tail(&ring->queue, pskb);
=20
-	rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, true, HW_DESC_OWN,
-				    &temp_one);
-
+	if (rtlpriv->use_new_trx_flow) {
+		temp_one =3D 4;
+		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pbuffer_desc, true,
+					    HW_DESC_OWN, (u8 *)&temp_one);
+	} else {
+		rtlpriv->cfg->ops->set_desc(hw, (u8 *)pdesc, true, HW_DESC_OWN,
+					    &temp_one);
+	}
 	return;
 }
=20
@@ -1370,9 +1376,9 @@ static void _rtl_pci_free_tx_ring(struct ieee80211_hw=
 *hw,
 	ring->desc =3D NULL;
 	if (rtlpriv->use_new_trx_flow) {
 		pci_free_consistent(rtlpci->pdev,
-				    sizeof(*ring->desc) * ring->entries,
+				    sizeof(*ring->buffer_desc) * ring->entries,
 				    ring->buffer_desc, ring->buffer_desc_dma);
-		ring->desc =3D NULL;
+		ring->buffer_desc =3D NULL;
 	}
 }
=20
@@ -1543,7 +1549,6 @@ int rtl_pci_reset_trx_ring(struct ieee80211_hw *hw)
 							 true,
 							 HW_DESC_TXBUFF_ADDR),
 						 skb->len, PCI_DMA_TODEVICE);
-				ring->idx =3D (ring->idx + 1) % ring->entries;
 				kfree_skb(skb);
 				ring->idx =3D (ring->idx + 1) % ring->entries;
 			}
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c b/drivers/net/wire=
less/rtlwifi/rtl8192se/hw.c
index 00e067044c08..5761d5b49e39 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/hw.c
@@ -1201,6 +1201,9 @@ static int _rtl92se_set_media_status(struct ieee80211=
_hw *hw,
=20
 	}
=20
+	if (type !=3D NL80211_IFTYPE_AP &&
+	    rtlpriv->mac80211.link_state < MAC80211_LINKED)
+		bt_msr =3D rtl_read_byte(rtlpriv, MSR) & ~MSR_LINK_MASK;
 	rtl_write_byte(rtlpriv, (MSR), bt_msr);
=20
 	temp =3D rtl_read_dword(rtlpriv, TCR);
@@ -1262,6 +1265,7 @@ void rtl92se_enable_interrupt(struct ieee80211_hw *hw)
 	rtl_write_dword(rtlpriv, INTA_MASK, rtlpci->irq_mask[0]);
 	/* Support Bit 32-37(Assign as Bit 0-5) interrupt setting now */
 	rtl_write_dword(rtlpriv, INTA_MASK + 4, rtlpci->irq_mask[1] & 0x3F);
+	rtlpci->irq_enabled =3D true;
 }
=20
 void rtl92se_disable_interrupt(struct ieee80211_hw *hw)
@@ -1276,8 +1280,7 @@ void rtl92se_disable_interrupt(struct ieee80211_hw *h=
w)
 	rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
 	rtl_write_dword(rtlpriv, INTA_MASK, 0);
 	rtl_write_dword(rtlpriv, INTA_MASK + 4, 0);
-
-	synchronize_irq(rtlpci->pdev->irq);
+	rtlpci->irq_enabled =3D false;
 }
=20
 static u8 _rtl92s_set_sysclk(struct ieee80211_hw *hw, u8 data)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c b/drivers/net/wir=
eless/rtlwifi/rtl8192se/phy.c
index 77c5b5f35244..4b4612fe2fdb 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/phy.c
@@ -399,6 +399,8 @@ static bool _rtl92s_phy_sw_chnl_step_by_step(struct iee=
e80211_hw *hw,
 		case 2:
 			currentcmd =3D &postcommoncmd[*step];
 			break;
+		default:
+			return true;
 		}
=20
 		if (currentcmd->cmdid =3D=3D CMDID_END) {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192se/sw.c
index aadba29c167a..fb003868bdef 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -236,6 +236,19 @@ static void rtl92s_deinit_sw_vars(struct ieee80211_hw =
*hw)
 	}
 }
=20
+static bool rtl92se_is_tx_desc_closed(struct ieee80211_hw *hw, u8 hw_queue,
+				      u16 index)
+{
+	struct rtl_pci *rtlpci =3D rtl_pcidev(rtl_pcipriv(hw));
+	struct rtl8192_tx_ring *ring =3D &rtlpci->tx_ring[hw_queue];
+	u8 *entry =3D (u8 *)(&ring->desc[ring->idx]);
+	u8 own =3D (u8)rtl92se_get_desc(entry, true, HW_DESC_OWN);
+
+	if (own)
+		return false;
+	return true;
+}
+
 static struct rtl_hal_ops rtl8192se_hal_ops =3D {
 	.init_sw_vars =3D rtl92s_init_sw_vars,
 	.deinit_sw_vars =3D rtl92s_deinit_sw_vars,
@@ -269,6 +282,7 @@ static struct rtl_hal_ops rtl8192se_hal_ops =3D {
 	.led_control =3D rtl92se_led_control,
 	.set_desc =3D rtl92se_set_desc,
 	.get_desc =3D rtl92se_get_desc,
+	.is_tx_desc_closed =3D rtl92se_is_tx_desc_closed,
 	.tx_polling =3D rtl92se_tx_polling,
 	.enable_hw_sec =3D rtl92se_enable_hw_security_config,
 	.set_key =3D rtl92se_set_key,
@@ -306,6 +320,8 @@ static struct rtl_hal_cfg rtl92se_hal_cfg =3D {
 	.maps[MAC_RCR_ACRC32] =3D RCR_ACRC32,
 	.maps[MAC_RCR_ACF] =3D RCR_ACF,
 	.maps[MAC_RCR_AAP] =3D RCR_AAP,
+	.maps[MAC_HIMR] =3D INTA_MASK,
+	.maps[MAC_HIMRE] =3D INTA_MASK + 4,
=20
 	.maps[EFUSE_TEST] =3D REG_EFUSE_TEST,
 	.maps[EFUSE_CTRL] =3D REG_EFUSE_CTRL,
diff --git a/net/mac80211/aes_ccm.c b/net/mac80211/aes_ccm.c
index ec24378caaaf..09d9caaec591 100644
--- a/net/mac80211/aes_ccm.c
+++ b/net/mac80211/aes_ccm.c
@@ -53,6 +53,9 @@ int ieee80211_aes_ccm_decrypt(struct crypto_aead *tfm, u8=
 *b_0, u8 *aad,
 		__aligned(__alignof__(struct aead_request));
 	struct aead_request *aead_req =3D (void *) aead_req_data;
=20
+	if (data_len =3D=3D 0)
+		return -EINVAL;
+
 	memset(aead_req, 0, sizeof(aead_req_data));
=20
 	sg_init_one(&pt, data, data_len);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--r5Pyd7+fXNt84Ff3
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUZSJvAAoJEJctW/TcYTgGAZsP/i9Etf1jP5YkovgrlZcPhNJh
0vxYfBo2o90+j6Qo67Iy94uILXlQtACiox2pNgpRWsp6SJ15Mx3mjyntfXG/F/XH
QX+fl6FlKL6qor4qUtQYuI82m8HrIEfQbYJVB0LIXDsyVCFFWqbFnjniqCB8cDD+
BCjE/7kruJ61DuCDcfJAQl+lhjE+EVGRiBwc0S3615rcZmBw0327iSj1xSK7kJ/B
+yIn/aATczhtHZY6Ynppr8ZNi/KlfQEHpmzfFnLdqKegw1ga2JKS9pTk9Impq7Dm
OALoA+VHLIi4rtT8Ts52dFYLbvyUG2mQl/WbMmTlC4+E71w5xr76wHu7PLucaVvL
uexWMplOxFSzAxo6MjObxXj828vMFuS+3YLrZPgWmp9vdtf8PBUYuAyTcxVwjskx
7QfM8bn7mBm02cPcpVCtckBvlBSOcA1bQT0cXAauaslFuvmEWoBJK28XY3oofnDU
mGtWM60EM1oyEsPdFFoMG5duncJfuoxEDDp5gCjWtcz/qtsrAeDEFGY/unSTi1aQ
5BLT15zWqXvM7Qd/FNL8eXOT3+NdRSJMjYgXoEY0PynEPMHElT5YXyW9FoOzo94M
W9+DVhPUmWzAIPnXWc0olcq2QX0ThTbMo0rm/13ctIxRLJ7qSuuVUfKv3bs6j9sB
9haeos7FsddDLERko/Ds
=2Opk
-----END PGP SIGNATURE-----

--r5Pyd7+fXNt84Ff3--
