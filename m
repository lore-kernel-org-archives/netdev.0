From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2013-02-01
Date: Fri, 1 Feb 2013 14:17:45 -0500
Message-ID: <20130201191745.GA29418@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="gKMricLos+KVdGMg"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--gKMricLos+KVdGMg
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

I'm sorry you got hit by the flu!  Hopefully you are fully recovered
by now? :-)

This is a small batch of fixes intended for the 3.8 stream...

There are two pulls from Johannes.  Regarding mac80211, Johannes says:

"One fix from Dan for a possible memory overrun."

Regarding iwlwifi,  Johannes says:

"I have one fix from Emmanuel reverting a previous fix that caused
more trouble than it's worth."

Along with those:

Arend van Spriel fixes a fatal error in brcsmac related to tx status proces=
sing.

Bing Zhao corrects a problem where mwifiex would fail to complete a scan
in the event of an IE processing error.

Larry Finger fixes a thinko in rtlwifi in which the wrong skb variable
was being used in some cases.

Rafa=C5=82 Mi=C5=82ecki fixes a thinko in an ID check in the bcma flash cod=
e.

Please let me know if there are problems!

Thanks,

John

---

The following changes since commit 66555e92fb7a619188c02cceae4bbc414f15f96d:

  tcp: detect SYN/data drop when F-RTO is disabled (2013-01-31 14:20:07 -05=
00)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to ed6882ac40552034ae6bde3e540b84c832dc8491:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2013-02-01 13:43:25 -0500)

----------------------------------------------------------------

Arend van Spriel (1):
      brcmsmac: fix tx status processing

Bing Zhao (1):
      mwifiex: fix incomplete scan in case of IE parsing error

Dan Carpenter (1):
      cfg80211: off by one in ieee80211_bss()

Emmanuel Grumbach (1):
      Revert "iwlwifi: fix the reclaimed packet tracking upon flush queue"

John W. Linville (3):
      Merge branch 'for-john' of git://git.kernel.org/.../jberg/mac80211
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

Larry Finger (1):
      rtlwifi: Fix the usage of the wrong variable in usb.c

Rafa=C5=82 Mi=C5=82ecki (1):
      bcma: fix NAND flash validation

 drivers/bcma/driver_chipcommon_nflash.c        |  2 +-
 drivers/net/wireless/brcm80211/brcmsmac/main.c | 25 +++++++++-------------=
---
 drivers/net/wireless/iwlwifi/dvm/tx.c          | 24 +++++++---------------=
--
 drivers/net/wireless/mwifiex/scan.c            |  9 +++++----
 drivers/net/wireless/rtlwifi/usb.c             |  4 ++--
 net/wireless/scan.c                            |  2 +-
 6 files changed, 25 insertions(+), 41 deletions(-)

diff --git a/drivers/bcma/driver_chipcommon_nflash.c b/drivers/bcma/driver_=
chipcommon_nflash.c
index dbda91e..1f0b83e 100644
--- a/drivers/bcma/driver_chipcommon_nflash.c
+++ b/drivers/bcma/driver_chipcommon_nflash.c
@@ -21,7 +21,7 @@ int bcma_nflash_init(struct bcma_drv_cc *cc)
 	struct bcma_bus *bus =3D cc->core->bus;
=20
 	if (bus->chipinfo.id !=3D BCMA_CHIP_ID_BCM4706 &&
-	    cc->core->id.rev !=3D 0x38) {
+	    cc->core->id.rev !=3D 38) {
 		bcma_err(bus, "NAND flash on unsupported board!\n");
 		return -ENOTSUPP;
 	}
diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/w=
ireless/brcm80211/brcmsmac/main.c
index 17594de..9f3d7e9 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -1027,7 +1027,6 @@ brcms_c_dotxstatus(struct brcms_c_info *wlc, struct t=
x_status *txs)
 static bool
 brcms_b_txstatus(struct brcms_hardware *wlc_hw, bool bound, bool *fatal)
 {
-	bool morepending =3D false;
 	struct bcma_device *core;
 	struct tx_status txstatus, *txs;
 	u32 s1, s2;
@@ -1041,23 +1040,20 @@ brcms_b_txstatus(struct brcms_hardware *wlc_hw, boo=
l bound, bool *fatal)
 	txs =3D &txstatus;
 	core =3D wlc_hw->d11core;
 	*fatal =3D false;
-	s1 =3D bcma_read32(core, D11REGOFFS(frmtxstatus));
-	while (!(*fatal)
-	       && (s1 & TXS_V)) {
-		/* !give others some time to run! */
-		if (n >=3D max_tx_num) {
-			morepending =3D true;
-			break;
-		}
=20
+	while (n < max_tx_num) {
+		s1 =3D bcma_read32(core, D11REGOFFS(frmtxstatus));
 		if (s1 =3D=3D 0xffffffff) {
 			brcms_err(core, "wl%d: %s: dead chip\n", wlc_hw->unit,
 				  __func__);
 			*fatal =3D true;
 			return false;
 		}
-		s2 =3D bcma_read32(core, D11REGOFFS(frmtxstatus2));
+		/* only process when valid */
+		if (!(s1 & TXS_V))
+			break;
=20
+		s2 =3D bcma_read32(core, D11REGOFFS(frmtxstatus2));
 		txs->status =3D s1 & TXS_STATUS_MASK;
 		txs->frameid =3D (s1 & TXS_FID_MASK) >> TXS_FID_SHIFT;
 		txs->sequence =3D s2 & TXS_SEQ_MASK;
@@ -1065,15 +1061,12 @@ brcms_b_txstatus(struct brcms_hardware *wlc_hw, boo=
l bound, bool *fatal)
 		txs->lasttxtime =3D 0;
=20
 		*fatal =3D brcms_c_dotxstatus(wlc_hw->wlc, txs);
-
-		s1 =3D bcma_read32(core, D11REGOFFS(frmtxstatus));
+		if (*fatal =3D=3D true)
+			return false;
 		n++;
 	}
=20
-	if (*fatal)
-		return false;
-
-	return morepending;
+	return n >=3D max_tx_num;
 }
=20
 static void brcms_c_tbtt(struct brcms_c_info *wlc)
diff --git a/drivers/net/wireless/iwlwifi/dvm/tx.c b/drivers/net/wireless/i=
wlwifi/dvm/tx.c
index 31534f7..2797964 100644
--- a/drivers/net/wireless/iwlwifi/dvm/tx.c
+++ b/drivers/net/wireless/iwlwifi/dvm/tx.c
@@ -1153,6 +1153,13 @@ int iwlagn_rx_reply_tx(struct iwl_priv *priv, struct=
 iwl_rx_cmd_buffer *rxb,
 			next_reclaimed =3D ssn;
 		}
=20
+		if (tid !=3D IWL_TID_NON_QOS) {
+			priv->tid_data[sta_id][tid].next_reclaimed =3D
+				next_reclaimed;
+			IWL_DEBUG_TX_REPLY(priv, "Next reclaimed packet:%d\n",
+						  next_reclaimed);
+		}
+
 		iwl_trans_reclaim(priv->trans, txq_id, ssn, &skbs);
=20
 		iwlagn_check_ratid_empty(priv, sta_id, tid);
@@ -1203,28 +1210,11 @@ int iwlagn_rx_reply_tx(struct iwl_priv *priv, struc=
t iwl_rx_cmd_buffer *rxb,
 			if (!is_agg)
 				iwlagn_non_agg_tx_status(priv, ctx, hdr->addr1);
=20
-			/*
-			 * W/A for FW bug - the seq_ctl isn't updated when the
-			 * queues are flushed. Fetch it from the packet itself
-			 */
-			if (!is_agg && status =3D=3D TX_STATUS_FAIL_FIFO_FLUSHED) {
-				next_reclaimed =3D le16_to_cpu(hdr->seq_ctrl);
-				next_reclaimed =3D
-					SEQ_TO_SN(next_reclaimed + 0x10);
-			}
-
 			is_offchannel_skb =3D
 				(info->flags & IEEE80211_TX_CTL_TX_OFFCHAN);
 			freed++;
 		}
=20
-		if (tid !=3D IWL_TID_NON_QOS) {
-			priv->tid_data[sta_id][tid].next_reclaimed =3D
-				next_reclaimed;
-			IWL_DEBUG_TX_REPLY(priv, "Next reclaimed packet:%d\n",
-					   next_reclaimed);
-		}
-
 		WARN_ON(!is_agg && freed !=3D 1);
=20
 		/*
diff --git a/drivers/net/wireless/mwifiex/scan.c b/drivers/net/wireless/mwi=
fiex/scan.c
index 9189a32..973a9d9 100644
--- a/drivers/net/wireless/mwifiex/scan.c
+++ b/drivers/net/wireless/mwifiex/scan.c
@@ -1563,7 +1563,7 @@ int mwifiex_ret_802_11_scan(struct mwifiex_private *p=
riv,
 		dev_err(adapter->dev, "SCAN_RESP: too many AP returned (%d)\n",
 			scan_rsp->number_of_sets);
 		ret =3D -1;
-		goto done;
+		goto check_next_scan;
 	}
=20
 	bytes_left =3D le16_to_cpu(scan_rsp->bss_descript_size);
@@ -1634,7 +1634,8 @@ int mwifiex_ret_802_11_scan(struct mwifiex_private *p=
riv,
 		if (!beacon_size || beacon_size > bytes_left) {
 			bss_info +=3D bytes_left;
 			bytes_left =3D 0;
-			return -1;
+			ret =3D -1;
+			goto check_next_scan;
 		}
=20
 		/* Initialize the current working beacon pointer for this BSS
@@ -1690,7 +1691,7 @@ int mwifiex_ret_802_11_scan(struct mwifiex_private *p=
riv,
 				dev_err(priv->adapter->dev,
 					"%s: bytes left < IE length\n",
 					__func__);
-				goto done;
+				goto check_next_scan;
 			}
 			if (element_id =3D=3D WLAN_EID_DS_PARAMS) {
 				channel =3D *(current_ptr + sizeof(struct ieee_types_header));
@@ -1753,6 +1754,7 @@ int mwifiex_ret_802_11_scan(struct mwifiex_private *p=
riv,
 		}
 	}
=20
+check_next_scan:
 	spin_lock_irqsave(&adapter->scan_pending_q_lock, flags);
 	if (list_empty(&adapter->scan_pending_q)) {
 		spin_unlock_irqrestore(&adapter->scan_pending_q_lock, flags);
@@ -1813,7 +1815,6 @@ int mwifiex_ret_802_11_scan(struct mwifiex_private *p=
riv,
 		}
 	}
=20
-done:
 	return ret;
 }
=20
diff --git a/drivers/net/wireless/rtlwifi/usb.c b/drivers/net/wireless/rtlw=
ifi/usb.c
index f2ecdeb..1535efd 100644
--- a/drivers/net/wireless/rtlwifi/usb.c
+++ b/drivers/net/wireless/rtlwifi/usb.c
@@ -542,8 +542,8 @@ static void _rtl_rx_pre_process(struct ieee80211_hw *hw=
, struct sk_buff *skb)
 	WARN_ON(skb_queue_empty(&rx_queue));
 	while (!skb_queue_empty(&rx_queue)) {
 		_skb =3D skb_dequeue(&rx_queue);
-		_rtl_usb_rx_process_agg(hw, skb);
-		ieee80211_rx_irqsafe(hw, skb);
+		_rtl_usb_rx_process_agg(hw, _skb);
+		ieee80211_rx_irqsafe(hw, _skb);
 	}
 }
=20
diff --git a/net/wireless/scan.c b/net/wireless/scan.c
index 01592d7..45f1618 100644
--- a/net/wireless/scan.c
+++ b/net/wireless/scan.c
@@ -1358,7 +1358,7 @@ ieee80211_bss(struct wiphy *wiphy, struct iw_request_=
info *info,
 						  &iwe, IW_EV_UINT_LEN);
 	}
=20
-	buf =3D kmalloc(30, GFP_ATOMIC);
+	buf =3D kmalloc(31, GFP_ATOMIC);
 	if (buf) {
 		memset(&iwe, 0, sizeof(iwe));
 		iwe.cmd =3D IWEVCUSTOM;
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--gKMricLos+KVdGMg
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)

iQIcBAEBAgAGBQJRDBTYAAoJEJctW/TcYTgGkFAP/25QUCutzp4EdwDiw7exAou7
4KyRKQ29DrY+Az6c5Yj3dj1v8M/vFooX6yK7X74kjwTSZzoZs6E8UxAsZSQUOr39
uceVgu9ZwhHe1mikzjIICcHBuQsc8jq3/8BtxdIV00Gntq0RVoKppH/VJJ1W5tru
WbVyl5B4BHBqi065i3Wmq84ZwjCfTqiHkDa1riQQg9l+WO6PYAbS/Jagnmvwk/fW
a54HzrnguM5YuIKtNMAw5bCZpWDyPKi3u2ymFAClmMLbF6TY5fYbE14GD/E0iEwy
tRYg53pWpO3377pDdXoXyqHHXTXSFs4+qfl/GQtuVfbQ9Ov2Ljwxj31Kt6aCWOmC
wq2/MBe7lwxzIgwGVDlPy6fBEy6q2QAsKUs7muQ2SpfPHAhO98fe3iYcEe5lanon
lumdtl6grQR7vUZjZCqX+eebX3gDXTO0q5lPI2OZxt4Y5Qc0lF8+FiGcFbyw3PVN
ZwSE/0F8dG1oJXKnLQlWbYgGLQS04Jizq2QMorgrcG/FFn6MCd6rKpajMV7aprrD
Y9RmzZeqXngnuQ4S1Ps1OszGdDzKHIR6ZWFoyv07zTJFdOCww0eLbwb1GAlKPw80
v5Fy4+zBw0uOD8quJFf5n+Vnc1V8AWN/Z82KpFeSEKj2sJZpnAp8Dhpr5wOMU3u+
g32Og2qrPonjQq76U/tq
=QLo7
-----END PGP SIGNATURE-----

--gKMricLos+KVdGMg--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
