From: "John W. Linville" <linville@tuxdriver.com>
Subject: pull request: wireless 2014-10-31
Date: Fri, 31 Oct 2014 15:58:17 -0400
Message-ID: <20141031195817.GC3768@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="6c2NcOVqGQ03X4Wi"
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--6c2NcOVqGQ03X4Wi
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this small batch of spooky fixes intended for the 3.18
stream...boo!

Cyril Brulebois adds an rt2x00 device ID.

Dan Carpenter provides a one-line masking fix for an ath9k debugfs
entry.

Larry Finger gives us a package of small rtlwifi fixes which add some
bits that were left out of some feature updates that were included
in the merge window.  Hopefully this isn't a sign that the rtlwifi
base is getting too big...

Marc Yang brings a fix for a temporary mwifiex stall when doing 11n
RX reordering.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 99c814066e75d09e6a38574c6c395f022a04b730:

  Merge tag 'mac80211-for-john-2014-10-23' of git://git.kernel.org/pub/scm/=
linux/kernel/git/jberg/mac80211 (2014-10-27 13:38:15 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git tags/=
master-2014-10-30

for you to fetch changes up to 75a916e1944fea8347d2245c62567187e4eff9dd:

  rtlwifi: rtl8192se: Fix firmware loading (2014-10-30 15:00:23 -0400)

----------------------------------------------------------------
Cyril Brulebois (1):
      wireless: rt2x00: add new rt2800usb device

Dan Carpenter (1):
      ath9k: fix some debugfs output

Larry Finger (5):
      rtlwifi: rtl8192ce: rtl8192de: rtl8192se: Fix handling for missing ge=
t_btc_status
      rtlwifi: rtl8192se: Fix duplicate calls to ieee80211_register_hw()
      rtlwifi: rtl8192se: Add missing section to read descriptor setting
      rtlwifi: rtl8192ce: Add missing section to read descriptor setting
      rtlwifi: rtl8192se: Fix firmware loading

Marc Yang (1):
      mwifiex: restart rxreorder timer correctly

 drivers/net/wireless/ath/ath9k/debug.c       |  2 +-
 drivers/net/wireless/mwifiex/11n_rxreorder.c | 52 +++++++++++++++++++++---=
----
 drivers/net/wireless/mwifiex/11n_rxreorder.h |  2 ++
 drivers/net/wireless/mwifiex/main.h          |  1 +
 drivers/net/wireless/rt2x00/rt2800usb.c      |  1 +
 drivers/net/wireless/rtlwifi/core.c          |  6 ++++
 drivers/net/wireless/rtlwifi/core.h          |  1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/def.h |  2 ++
 drivers/net/wireless/rtlwifi/rtl8192ce/sw.c  |  1 +
 drivers/net/wireless/rtlwifi/rtl8192ce/trx.c |  3 ++
 drivers/net/wireless/rtlwifi/rtl8192de/sw.c  |  1 +
 drivers/net/wireless/rtlwifi/rtl8192se/def.h |  2 ++
 drivers/net/wireless/rtlwifi/rtl8192se/sw.c  | 22 ++----------
 drivers/net/wireless/rtlwifi/rtl8192se/trx.c |  3 ++
 14 files changed, 67 insertions(+), 32 deletions(-)

diff --git a/drivers/net/wireless/ath/ath9k/debug.c b/drivers/net/wireless/=
ath/ath9k/debug.c
index 46f20a309b5f..5c45e787814e 100644
--- a/drivers/net/wireless/ath/ath9k/debug.c
+++ b/drivers/net/wireless/ath/ath9k/debug.c
@@ -455,7 +455,7 @@ static ssize_t read_file_dma(struct file *file, char __=
user *user_buf,
 			 "%2d          %2x      %1x     %2x           %2x\n",
 			 i, (*qcuBase & (0x7 << qcuOffset)) >> qcuOffset,
 			 (*qcuBase & (0x8 << qcuOffset)) >> (qcuOffset + 3),
-			 val[2] & (0x7 << (i * 3)) >> (i * 3),
+			 (val[2] & (0x7 << (i * 3))) >> (i * 3),
 			 (*dcuBase & (0x1f << dcuOffset)) >> dcuOffset);
 	}
=20
diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.c b/drivers/net/wir=
eless/mwifiex/11n_rxreorder.c
index 40057079ffb9..5ef5a0eeba50 100644
--- a/drivers/net/wireless/mwifiex/11n_rxreorder.c
+++ b/drivers/net/wireless/mwifiex/11n_rxreorder.c
@@ -196,6 +196,7 @@ mwifiex_del_rx_reorder_entry(struct mwifiex_private *pr=
iv,
 	mwifiex_11n_dispatch_pkt_until_start_win(priv, tbl, start_win);
=20
 	del_timer_sync(&tbl->timer_context.timer);
+	tbl->timer_context.timer_is_set =3D false;
=20
 	spin_lock_irqsave(&priv->rx_reorder_tbl_lock, flags);
 	list_del(&tbl->list);
@@ -297,6 +298,7 @@ mwifiex_flush_data(unsigned long context)
 		(struct reorder_tmr_cnxt *) context;
 	int start_win, seq_num;
=20
+	ctx->timer_is_set =3D false;
 	seq_num =3D mwifiex_11n_find_last_seq_num(ctx);
=20
 	if (seq_num < 0)
@@ -385,6 +387,7 @@ mwifiex_11n_create_rx_reorder_tbl(struct mwifiex_privat=
e *priv, u8 *ta,
=20
 	new_node->timer_context.ptr =3D new_node;
 	new_node->timer_context.priv =3D priv;
+	new_node->timer_context.timer_is_set =3D false;
=20
 	init_timer(&new_node->timer_context.timer);
 	new_node->timer_context.timer.function =3D mwifiex_flush_data;
@@ -399,6 +402,22 @@ mwifiex_11n_create_rx_reorder_tbl(struct mwifiex_priva=
te *priv, u8 *ta,
 	spin_unlock_irqrestore(&priv->rx_reorder_tbl_lock, flags);
 }
=20
+static void
+mwifiex_11n_rxreorder_timer_restart(struct mwifiex_rx_reorder_tbl *tbl)
+{
+	u32 min_flush_time;
+
+	if (tbl->win_size >=3D MWIFIEX_BA_WIN_SIZE_32)
+		min_flush_time =3D MIN_FLUSH_TIMER_15_MS;
+	else
+		min_flush_time =3D MIN_FLUSH_TIMER_MS;
+
+	mod_timer(&tbl->timer_context.timer,
+		  jiffies + msecs_to_jiffies(min_flush_time * tbl->win_size));
+
+	tbl->timer_context.timer_is_set =3D true;
+}
+
 /*
  * This function prepares command for adding a BA request.
  *
@@ -523,31 +542,31 @@ int mwifiex_11n_rx_reorder_pkt(struct mwifiex_private=
 *priv,
 				u8 *ta, u8 pkt_type, void *payload)
 {
 	struct mwifiex_rx_reorder_tbl *tbl;
-	int start_win, end_win, win_size;
+	int prev_start_win, start_win, end_win, win_size;
 	u16 pkt_index;
 	bool init_window_shift =3D false;
+	int ret =3D 0;
=20
 	tbl =3D mwifiex_11n_get_rx_reorder_tbl(priv, tid, ta);
 	if (!tbl) {
 		if (pkt_type !=3D PKT_TYPE_BAR)
 			mwifiex_11n_dispatch_pkt(priv, payload);
-		return 0;
+		return ret;
 	}
=20
 	if ((pkt_type =3D=3D PKT_TYPE_AMSDU) && !tbl->amsdu) {
 		mwifiex_11n_dispatch_pkt(priv, payload);
-		return 0;
+		return ret;
 	}
=20
 	start_win =3D tbl->start_win;
+	prev_start_win =3D start_win;
 	win_size =3D tbl->win_size;
 	end_win =3D ((start_win + win_size) - 1) & (MAX_TID_VALUE - 1);
 	if (tbl->flags & RXREOR_INIT_WINDOW_SHIFT) {
 		init_window_shift =3D true;
 		tbl->flags &=3D ~RXREOR_INIT_WINDOW_SHIFT;
 	}
-	mod_timer(&tbl->timer_context.timer,
-		  jiffies + msecs_to_jiffies(MIN_FLUSH_TIMER_MS * win_size));
=20
 	if (tbl->flags & RXREOR_FORCE_NO_DROP) {
 		dev_dbg(priv->adapter->dev,
@@ -568,11 +587,14 @@ int mwifiex_11n_rx_reorder_pkt(struct mwifiex_private=
 *priv,
 		if ((start_win + TWOPOW11) > (MAX_TID_VALUE - 1)) {
 			if (seq_num >=3D ((start_win + TWOPOW11) &
 					(MAX_TID_VALUE - 1)) &&
-			    seq_num < start_win)
-				return -1;
+			    seq_num < start_win) {
+				ret =3D -1;
+				goto done;
+			}
 		} else if ((seq_num < start_win) ||
-			   (seq_num > (start_win + TWOPOW11))) {
-			return -1;
+			   (seq_num >=3D (start_win + TWOPOW11))) {
+			ret =3D -1;
+			goto done;
 		}
 	}
=20
@@ -601,8 +623,10 @@ int mwifiex_11n_rx_reorder_pkt(struct mwifiex_private =
*priv,
 		else
 			pkt_index =3D (seq_num+MAX_TID_VALUE) - start_win;
=20
-		if (tbl->rx_reorder_ptr[pkt_index])
-			return -1;
+		if (tbl->rx_reorder_ptr[pkt_index]) {
+			ret =3D -1;
+			goto done;
+		}
=20
 		tbl->rx_reorder_ptr[pkt_index] =3D payload;
 	}
@@ -613,7 +637,11 @@ int mwifiex_11n_rx_reorder_pkt(struct mwifiex_private =
*priv,
 	 */
 	mwifiex_11n_scan_and_dispatch(priv, tbl);
=20
-	return 0;
+done:
+	if (!tbl->timer_context.timer_is_set ||
+	    prev_start_win !=3D tbl->start_win)
+		mwifiex_11n_rxreorder_timer_restart(tbl);
+	return ret;
 }
=20
 /*
diff --git a/drivers/net/wireless/mwifiex/11n_rxreorder.h b/drivers/net/wir=
eless/mwifiex/11n_rxreorder.h
index 3a87bb0e3a62..63ecea89b4ab 100644
--- a/drivers/net/wireless/mwifiex/11n_rxreorder.h
+++ b/drivers/net/wireless/mwifiex/11n_rxreorder.h
@@ -21,6 +21,8 @@
 #define _MWIFIEX_11N_RXREORDER_H_
=20
 #define MIN_FLUSH_TIMER_MS		50
+#define MIN_FLUSH_TIMER_15_MS		15
+#define MWIFIEX_BA_WIN_SIZE_32		32
=20
 #define PKT_TYPE_BAR 0xE7
 #define MAX_TID_VALUE			(2 << 11)
diff --git a/drivers/net/wireless/mwifiex/main.h b/drivers/net/wireless/mwi=
fiex/main.h
index e2635747d966..f55658d15c60 100644
--- a/drivers/net/wireless/mwifiex/main.h
+++ b/drivers/net/wireless/mwifiex/main.h
@@ -592,6 +592,7 @@ struct reorder_tmr_cnxt {
 	struct timer_list timer;
 	struct mwifiex_rx_reorder_tbl *ptr;
 	struct mwifiex_private *priv;
+	u8 timer_is_set;
 };
=20
 struct mwifiex_rx_reorder_tbl {
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless=
/rt2x00/rt2800usb.c
index 573897b8e878..8444313eabe2 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -1111,6 +1111,7 @@ static struct usb_device_id rt2800usb_device_table[] =
=3D {
 	/* Ovislink */
 	{ USB_DEVICE(0x1b75, 0x3071) },
 	{ USB_DEVICE(0x1b75, 0x3072) },
+	{ USB_DEVICE(0x1b75, 0xa200) },
 	/* Para */
 	{ USB_DEVICE(0x20b8, 0x8888) },
 	/* Pegatron */
diff --git a/drivers/net/wireless/rtlwifi/core.c b/drivers/net/wireless/rtl=
wifi/core.c
index f6179bc06086..07dae0d44abc 100644
--- a/drivers/net/wireless/rtlwifi/core.c
+++ b/drivers/net/wireless/rtlwifi/core.c
@@ -1828,3 +1828,9 @@ const struct ieee80211_ops rtl_ops =3D {
 	.flush =3D rtl_op_flush,
 };
 EXPORT_SYMBOL_GPL(rtl_ops);
+
+bool rtl_btc_status_false(void)
+{
+	return false;
+}
+EXPORT_SYMBOL_GPL(rtl_btc_status_false);
diff --git a/drivers/net/wireless/rtlwifi/core.h b/drivers/net/wireless/rtl=
wifi/core.h
index 59cd3b9dca25..624e1dc16d31 100644
--- a/drivers/net/wireless/rtlwifi/core.h
+++ b/drivers/net/wireless/rtlwifi/core.h
@@ -42,5 +42,6 @@ void rtl_rfreg_delay(struct ieee80211_hw *hw, enum radio_=
path rfpath, u32 addr,
 		     u32 mask, u32 data);
 void rtl_bb_delay(struct ieee80211_hw *hw, u32 addr, u32 data);
 bool rtl_cmd_send_packet(struct ieee80211_hw *hw, struct sk_buff *skb);
+bool rtl_btc_status_false(void);
=20
 #endif
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h b/drivers/net/wir=
eless/rtlwifi/rtl8192ce/def.h
index 831df101d7b7..9b660df6fd71 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/def.h
@@ -114,6 +114,8 @@
 	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 16, 4)
 #define	GET_C2H_CMD_FEEDBACK_CCX_SEQ(__pcmdfbhdr)	\
 	LE_BITS_TO_4BYTE(((__pcmdfbhdr) + 4), 20, 12)
+#define GET_RX_STATUS_DESC_BUFF_ADDR(__pdesc)			\
+	SHIFT_AND_MASK_LE(__pdesc + 24, 0, 32)
=20
 #define CHIP_VER_B			BIT(4)
 #define CHIP_BONDING_IDENTIFIER(_value) (((_value) >> 22) & 0x3)
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192ce/sw.c
index d86b5b566444..46ea07605eb4 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/sw.c
@@ -244,6 +244,7 @@ static struct rtl_hal_ops rtl8192ce_hal_ops =3D {
 	.phy_lc_calibrate =3D _rtl92ce_phy_lc_calibrate,
 	.phy_set_bw_mode_callback =3D rtl92ce_phy_set_bw_mode_callback,
 	.dm_dynamic_txpower =3D rtl92ce_dm_dynamic_txpower,
+	.get_btc_status =3D rtl_btc_status_false,
 };
=20
 static struct rtl_mod_params rtl92ce_mod_params =3D {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192ce/trx.c
index 2fb9c7acb76a..dc3d20b17a26 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192ce/trx.c
@@ -728,6 +728,9 @@ u32 rtl92ce_get_desc(u8 *p_desc, bool istx, u8 desc_nam=
e)
 		case HW_DESC_RXPKT_LEN:
 			ret =3D GET_RX_DESC_PKT_LEN(pdesc);
 			break;
+		case HW_DESC_RXBUFF_ADDR:
+			ret =3D GET_RX_STATUS_DESC_BUFF_ADDR(pdesc);
+			break;
 		default:
 			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
 				  desc_name);
diff --git a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192de/sw.c
index edab5a5351b5..a0aba088259a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192de/sw.c
@@ -251,6 +251,7 @@ static struct rtl_hal_ops rtl8192de_hal_ops =3D {
 	.get_rfreg =3D rtl92d_phy_query_rf_reg,
 	.set_rfreg =3D rtl92d_phy_set_rf_reg,
 	.linked_set_reg =3D rtl92d_linked_set_reg,
+	.get_btc_status =3D rtl_btc_status_false,
 };
=20
 static struct rtl_mod_params rtl92de_mod_params =3D {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/def.h b/drivers/net/wir=
eless/rtlwifi/rtl8192se/def.h
index 83c98674bfd3..6e7a70b43949 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/def.h
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/def.h
@@ -446,6 +446,8 @@
 /* DWORD 6 */
 #define SET_RX_STATUS__DESC_BUFF_ADDR(__pdesc, __val)	\
 	SET_BITS_OFFSET_LE(__pdesc + 24, 0, 32, __val)
+#define GET_RX_STATUS_DESC_BUFF_ADDR(__pdesc)			\
+	SHIFT_AND_MASK_LE(__pdesc + 24, 0, 32)
=20
 #define SE_RX_HAL_IS_CCK_RATE(_pdesc)\
 	(GET_RX_STATUS_DESC_RX_MCS(_pdesc) =3D=3D DESC92_RATE1M ||	\
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c b/drivers/net/wire=
less/rtlwifi/rtl8192se/sw.c
index 1bff2a0f7600..aadba29c167a 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/sw.c
@@ -87,11 +87,8 @@ static void rtl92s_init_aspm_vars(struct ieee80211_hw *h=
w)
 static void rtl92se_fw_cb(const struct firmware *firmware, void *context)
 {
 	struct ieee80211_hw *hw =3D context;
-	struct rtl_pci_priv *pcipriv =3D rtl_pcipriv(hw);
 	struct rtl_priv *rtlpriv =3D rtl_priv(hw);
-	struct rtl_pci *rtlpci =3D rtl_pcidev(pcipriv);
 	struct rt_firmware *pfirmware =3D NULL;
-	int err;
=20
 	RT_TRACE(rtlpriv, COMP_ERR, DBG_LOUD,
 			 "Firmware callback routine entered!\n");
@@ -112,20 +109,6 @@ static void rtl92se_fw_cb(const struct firmware *firmw=
are, void *context)
 	memcpy(pfirmware->sz_fw_tmpbuffer, firmware->data, firmware->size);
 	pfirmware->sz_fw_tmpbufferlen =3D firmware->size;
 	release_firmware(firmware);
-
-	err =3D ieee80211_register_hw(hw);
-	if (err) {
-		RT_TRACE(rtlpriv, COMP_ERR, DBG_EMERG,
-			 "Can't register mac80211 hw\n");
-		return;
-	} else {
-		rtlpriv->mac80211.mac80211_registered =3D 1;
-	}
-	rtlpci->irq_alloc =3D 1;
-	set_bit(RTL_STATUS_INTERFACE_START, &rtlpriv->status);
-
-	/*init rfkill */
-	rtl_init_rfkill(hw);
 }
=20
 static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
@@ -226,8 +209,8 @@ static int rtl92s_init_sw_vars(struct ieee80211_hw *hw)
 	if (!rtlpriv->rtlhal.pfirmware)
 		return 1;
=20
-	rtlpriv->max_fw_size =3D RTL8190_MAX_RAW_FIRMWARE_CODE_SIZE;
-
+	rtlpriv->max_fw_size =3D RTL8190_MAX_FIRMWARE_CODE_SIZE*2 +
+			       sizeof(struct fw_hdr);
 	pr_info("Driver for Realtek RTL8192SE/RTL8191SE\n"
 		"Loading firmware %s\n", rtlpriv->cfg->fw_name);
 	/* request fw */
@@ -294,6 +277,7 @@ static struct rtl_hal_ops rtl8192se_hal_ops =3D {
 	.set_bbreg =3D rtl92s_phy_set_bb_reg,
 	.get_rfreg =3D rtl92s_phy_query_rf_reg,
 	.set_rfreg =3D rtl92s_phy_set_rf_reg,
+	.get_btc_status =3D rtl_btc_status_false,
 };
=20
 static struct rtl_mod_params rtl92se_mod_params =3D {
diff --git a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c b/drivers/net/wir=
eless/rtlwifi/rtl8192se/trx.c
index b358ebce8942..672fd3b02835 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192se/trx.c
@@ -640,6 +640,9 @@ u32 rtl92se_get_desc(u8 *desc, bool istx, u8 desc_name)
 		case HW_DESC_RXPKT_LEN:
 			ret =3D GET_RX_STATUS_DESC_PKT_LEN(desc);
 			break;
+		case HW_DESC_RXBUFF_ADDR:
+			ret =3D GET_RX_STATUS_DESC_BUFF_ADDR(desc);
+			break;
 		default:
 			RT_ASSERT(false, "ERR rxdesc :%d not process\n",
 				  desc_name);
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.

--6c2NcOVqGQ03X4Wi
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJUU+nYAAoJEJctW/TcYTgGl+8P/jNP+7lld84jnK9nMy5U1WOI
TbvOr1/QnE2cbKoeSqxl9GVvPd3F9+zwoqZdaSLnwyxp9BnTeGnFHyaYNj1TEeEp
UaAEMbMWXAU+uyDwePQxSB2q8Cosws2B7EcrBVokCgQQCS09W1K7NdQhRakbYsGv
u0vUJqHQ5wK8k7hf030LgMg568xCV0xHKuJ3U5bWCLR/eGzImW2VNjKtMj9hXLH4
16aRHQ1RK0yD1nNhmBEcCRiRJxhJq3Y/16acYEEYKjbEkhyhi5gFICvwvZMEjuRU
69PZbro4/SYnau4H25I0LLZQHvj5TeunSqun2VZm71KOrtouDfW1W5iGSRqFCMgC
6MXHKE8zYjS5Chrw0hVIfsXKS42GJRVzEo333SNSb+Tmo4+YVJijIEeUooKdsjHn
7P2La7Ka3jGvkz7oTYkpN1akG2F1T4fcdmPUcKVQL9ft8GbBxqW6fRtx4YZb6eWk
+HR4Pplw+VSw7/VMbwW0hKUo5DsqqEAPgq0R4YMDYjq8tQag04DYu+rj+RaLg+Xz
VDgvwwq/l5vEsh0hfWuArp4hbRfVpdI9Jka0Kk5sQR3Lxm5NTp8thDR9s8Wg9zZa
1mFhOAf0dX+ui7opVy8DPSL4leM4IQdOsz4BLcem+NWg6O58XxgsWLoD6DD5zACh
qqqECONsOaBReHAUoJ4w
=u8CC
-----END PGP SIGNATURE-----

--6c2NcOVqGQ03X4Wi--
