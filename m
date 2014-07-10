From: "John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>
Subject: pull request: wireless 2014-07-10
Date: Thu, 10 Jul 2014 17:22:49 -0400
Message-ID: <20140710212248.GB21203@tuxdriver.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="ZGiS0Q5IWpPtfppv"
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--ZGiS0Q5IWpPtfppv
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Dave,

Please pull this batch of fixes intended for the 3.16 stream!

For the iwlwifi bits, Emmanuel says:

"I have here 2 patches that disable the usage of CTS to self. This
keeps making trouble to the firmware and is not a really reliable
protection anyway. We may re-enable it in the future, but in rarer
cases. Along with this, I have a fix from Ilan that prevents a
firmware assertion."

On top of that...

Amitkumar Karwar provides an mwifiex fix to properly initialize
(i.e. zero) tx_info/rx_info.

Andrea Merello stops rt2800usb from doing DMA operations on the
stack...yikes!

Please let me know if there are problems...

Thanks,

John

---

The following changes since commit 76252723e88681628a3dbb9c09c963e095476f73:

  igb: do a reset on SR-IOV re-init if device is down (2014-07-10 12:45:24 =
-0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless.git for-d=
avem

for you to fetch changes up to d672f939bc81513d28a5bfc570ed2f17d8f5b34a:

  Merge branch 'master' of git://git.kernel.org/pub/scm/linux/kernel/git/li=
nville/wireless into for-davem (2014-07-10 17:14:14 -0400)

----------------------------------------------------------------

Amitkumar Karwar (1):
      mwifiex: initialize Tx/Rx info of a packet correctly

Andrea Merello (1):
      rt2800usb: Don't perform DMA from stack

Emmanuel Grumbach (2):
      iwlwifi: dvm: don't enable CTS to self
      iwlwifi: mvm: disable CTS to Self

Ilan Peer (1):
      iwlwifi: mvm: Fix broadcast filtering

John W. Linville (2):
      Merge branch 'for-john' of git://git.kernel.org/.../iwlwifi/iwlwifi-f=
ixes
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless i=
nto for-davem

 drivers/net/wireless/iwlwifi/dvm/rxon.c     | 12 ------------
 drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c |  5 ++---
 drivers/net/wireless/iwlwifi/mvm/mac80211.c | 12 ++++++------
 drivers/net/wireless/mwifiex/11n_aggr.c     |  1 +
 drivers/net/wireless/mwifiex/cfg80211.c     |  1 +
 drivers/net/wireless/mwifiex/cmdevt.c       |  1 +
 drivers/net/wireless/mwifiex/sta_tx.c       |  1 +
 drivers/net/wireless/mwifiex/tdls.c         |  2 ++
 drivers/net/wireless/mwifiex/txrx.c         |  1 +
 drivers/net/wireless/mwifiex/uap_txrx.c     |  1 +
 drivers/net/wireless/rt2x00/rt2800usb.c     | 28 ++++++++++++++++++++++---=
---
 11 files changed, 38 insertions(+), 27 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/dvm/rxon.c b/drivers/net/wireless=
/iwlwifi/dvm/rxon.c
index ed50de6362ed..6dc5dd3ced44 100644
--- a/drivers/net/wireless/iwlwifi/dvm/rxon.c
+++ b/drivers/net/wireless/iwlwifi/dvm/rxon.c
@@ -1068,13 +1068,6 @@ int iwlagn_commit_rxon(struct iwl_priv *priv, struct=
 iwl_rxon_context *ctx)
 	/* recalculate basic rates */
 	iwl_calc_basic_rates(priv, ctx);
=20
-	/*
-	 * force CTS-to-self frames protection if RTS-CTS is not preferred
-	 * one aggregation protection method
-	 */
-	if (!priv->hw_params.use_rts_for_aggregation)
-		ctx->staging.flags |=3D RXON_FLG_SELF_CTS_EN;
-
 	if ((ctx->vif && ctx->vif->bss_conf.use_short_slot) ||
 	    !(ctx->staging.flags & RXON_FLG_BAND_24G_MSK))
 		ctx->staging.flags |=3D RXON_FLG_SHORT_SLOT_MSK;
@@ -1480,11 +1473,6 @@ void iwlagn_bss_info_changed(struct ieee80211_hw *hw,
 	else
 		ctx->staging.flags &=3D ~RXON_FLG_TGG_PROTECT_MSK;
=20
-	if (bss_conf->use_cts_prot)
-		ctx->staging.flags |=3D RXON_FLG_SELF_CTS_EN;
-	else
-		ctx->staging.flags &=3D ~RXON_FLG_SELF_CTS_EN;
-
 	memcpy(ctx->staging.bssid_addr, bss_conf->bssid, ETH_ALEN);
=20
 	if (vif->type =3D=3D NL80211_IFTYPE_AP ||
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c b/drivers/net/wire=
less/iwlwifi/mvm/mac-ctxt.c
index 8b5302777632..725ba49576bf 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac-ctxt.c
@@ -667,10 +667,9 @@ static void iwl_mvm_mac_ctxt_cmd_common(struct iwl_mvm=
 *mvm,
 	if (vif->bss_conf.qos)
 		cmd->qos_flags |=3D cpu_to_le32(MAC_QOS_FLG_UPDATE_EDCA);
=20
-	if (vif->bss_conf.use_cts_prot) {
+	if (vif->bss_conf.use_cts_prot)
 		cmd->protection_flags |=3D cpu_to_le32(MAC_PROT_FLG_TGG_PROTECT);
-		cmd->protection_flags |=3D cpu_to_le32(MAC_PROT_FLG_SELF_CTS_EN);
-	}
+
 	IWL_DEBUG_RATE(mvm, "use_cts_prot %d, ht_operation_mode %d\n",
 		       vif->bss_conf.use_cts_prot,
 		       vif->bss_conf.ht_operation_mode);
diff --git a/drivers/net/wireless/iwlwifi/mvm/mac80211.c b/drivers/net/wire=
less/iwlwifi/mvm/mac80211.c
index 1cef708cb74d..9bfb90680cdc 100644
--- a/drivers/net/wireless/iwlwifi/mvm/mac80211.c
+++ b/drivers/net/wireless/iwlwifi/mvm/mac80211.c
@@ -1166,8 +1166,12 @@ static void iwl_mvm_bcast_filter_iterator(void *_dat=
a, u8 *mac,
=20
 	bcast_mac =3D &cmd->macs[mvmvif->id];
=20
-	/* enable filtering only for associated stations */
-	if (vif->type !=3D NL80211_IFTYPE_STATION || !vif->bss_conf.assoc)
+	/*
+	 * enable filtering only for associated stations, but not for P2P
+	 * Clients
+	 */
+	if (vif->type !=3D NL80211_IFTYPE_STATION || vif->p2p ||
+	    !vif->bss_conf.assoc)
 		return;
=20
 	bcast_mac->default_discard =3D 1;
@@ -1244,10 +1248,6 @@ static int iwl_mvm_configure_bcast_filter(struct iwl=
_mvm *mvm,
 	if (!(mvm->fw->ucode_capa.flags & IWL_UCODE_TLV_FLAGS_BCAST_FILTERING))
 		return 0;
=20
-	/* bcast filtering isn't supported for P2P client */
-	if (vif->p2p)
-		return 0;
-
 	if (!iwl_mvm_bcast_filter_build_cmd(mvm, &cmd))
 		return 0;
=20
diff --git a/drivers/net/wireless/mwifiex/11n_aggr.c b/drivers/net/wireless=
/mwifiex/11n_aggr.c
index 5b32106182f8..fe0f66f73507 100644
--- a/drivers/net/wireless/mwifiex/11n_aggr.c
+++ b/drivers/net/wireless/mwifiex/11n_aggr.c
@@ -185,6 +185,7 @@ mwifiex_11n_aggregate_pkt(struct mwifiex_private *priv,
 	skb_reserve(skb_aggr, headroom + sizeof(struct txpd));
 	tx_info_aggr =3D  MWIFIEX_SKB_TXCB(skb_aggr);
=20
+	memset(tx_info_aggr, 0, sizeof(*tx_info_aggr));
 	tx_info_aggr->bss_type =3D tx_info_src->bss_type;
 	tx_info_aggr->bss_num =3D tx_info_src->bss_num;
=20
diff --git a/drivers/net/wireless/mwifiex/cfg80211.c b/drivers/net/wireless=
/mwifiex/cfg80211.c
index e95dec91a561..b511613bba2d 100644
--- a/drivers/net/wireless/mwifiex/cfg80211.c
+++ b/drivers/net/wireless/mwifiex/cfg80211.c
@@ -220,6 +220,7 @@ mwifiex_cfg80211_mgmt_tx(struct wiphy *wiphy, struct wi=
reless_dev *wdev,
 	}
=20
 	tx_info =3D MWIFIEX_SKB_TXCB(skb);
+	memset(tx_info, 0, sizeof(*tx_info));
 	tx_info->bss_num =3D priv->bss_num;
 	tx_info->bss_type =3D priv->bss_type;
 	tx_info->pkt_len =3D pkt_len;
diff --git a/drivers/net/wireless/mwifiex/cmdevt.c b/drivers/net/wireless/m=
wifiex/cmdevt.c
index 8dee6c86f4f1..c161141f6c39 100644
--- a/drivers/net/wireless/mwifiex/cmdevt.c
+++ b/drivers/net/wireless/mwifiex/cmdevt.c
@@ -453,6 +453,7 @@ int mwifiex_process_event(struct mwifiex_adapter *adapt=
er)
=20
 	if (skb) {
 		rx_info =3D MWIFIEX_SKB_RXCB(skb);
+		memset(rx_info, 0, sizeof(*rx_info));
 		rx_info->bss_num =3D priv->bss_num;
 		rx_info->bss_type =3D priv->bss_type;
 	}
diff --git a/drivers/net/wireless/mwifiex/sta_tx.c b/drivers/net/wireless/m=
wifiex/sta_tx.c
index 5fce7e78a36e..70eb863c7249 100644
--- a/drivers/net/wireless/mwifiex/sta_tx.c
+++ b/drivers/net/wireless/mwifiex/sta_tx.c
@@ -150,6 +150,7 @@ int mwifiex_send_null_packet(struct mwifiex_private *pr=
iv, u8 flags)
 		return -1;
=20
 	tx_info =3D MWIFIEX_SKB_TXCB(skb);
+	memset(tx_info, 0, sizeof(*tx_info));
 	tx_info->bss_num =3D priv->bss_num;
 	tx_info->bss_type =3D priv->bss_type;
 	tx_info->pkt_len =3D data_len - (sizeof(struct txpd) + INTF_HEADER_LEN);
diff --git a/drivers/net/wireless/mwifiex/tdls.c b/drivers/net/wireless/mwi=
fiex/tdls.c
index e73034fbbde9..0e88364e0c67 100644
--- a/drivers/net/wireless/mwifiex/tdls.c
+++ b/drivers/net/wireless/mwifiex/tdls.c
@@ -605,6 +605,7 @@ int mwifiex_send_tdls_data_frame(struct mwifiex_private=
 *priv, const u8 *peer,
 	}
=20
 	tx_info =3D MWIFIEX_SKB_TXCB(skb);
+	memset(tx_info, 0, sizeof(*tx_info));
 	tx_info->bss_num =3D priv->bss_num;
 	tx_info->bss_type =3D priv->bss_type;
=20
@@ -760,6 +761,7 @@ int mwifiex_send_tdls_action_frame(struct mwifiex_priva=
te *priv, const u8 *peer,
 	skb->priority =3D MWIFIEX_PRIO_VI;
=20
 	tx_info =3D MWIFIEX_SKB_TXCB(skb);
+	memset(tx_info, 0, sizeof(*tx_info));
 	tx_info->bss_num =3D priv->bss_num;
 	tx_info->bss_type =3D priv->bss_type;
 	tx_info->flags |=3D MWIFIEX_BUF_FLAG_TDLS_PKT;
diff --git a/drivers/net/wireless/mwifiex/txrx.c b/drivers/net/wireless/mwi=
fiex/txrx.c
index 37f26afd4314..fd7e5b9b4581 100644
--- a/drivers/net/wireless/mwifiex/txrx.c
+++ b/drivers/net/wireless/mwifiex/txrx.c
@@ -55,6 +55,7 @@ int mwifiex_handle_rx_packet(struct mwifiex_adapter *adap=
ter,
 		return -1;
 	}
=20
+	memset(rx_info, 0, sizeof(*rx_info));
 	rx_info->bss_num =3D priv->bss_num;
 	rx_info->bss_type =3D priv->bss_type;
=20
diff --git a/drivers/net/wireless/mwifiex/uap_txrx.c b/drivers/net/wireless=
/mwifiex/uap_txrx.c
index 9a56bc61cb1d..b0601b91cc4f 100644
--- a/drivers/net/wireless/mwifiex/uap_txrx.c
+++ b/drivers/net/wireless/mwifiex/uap_txrx.c
@@ -175,6 +175,7 @@ static void mwifiex_uap_queue_bridged_pkt(struct mwifie=
x_private *priv,
 	}
=20
 	tx_info =3D MWIFIEX_SKB_TXCB(skb);
+	memset(tx_info, 0, sizeof(*tx_info));
 	tx_info->bss_num =3D priv->bss_num;
 	tx_info->bss_type =3D priv->bss_type;
 	tx_info->flags |=3D MWIFIEX_BUF_FLAG_BRIDGED_PKT;
diff --git a/drivers/net/wireless/rt2x00/rt2800usb.c b/drivers/net/wireless=
/rt2x00/rt2800usb.c
index e11dab2216c6..832006b5aab1 100644
--- a/drivers/net/wireless/rt2x00/rt2800usb.c
+++ b/drivers/net/wireless/rt2x00/rt2800usb.c
@@ -231,9 +231,12 @@ static enum hrtimer_restart rt2800usb_tx_sta_fifo_time=
out(struct hrtimer *timer)
  */
 static int rt2800usb_autorun_detect(struct rt2x00_dev *rt2x00dev)
 {
-	__le32 reg;
+	__le32 *reg;
 	u32 fw_mode;
=20
+	reg =3D kmalloc(sizeof(*reg), GFP_KERNEL);
+	if (reg =3D=3D NULL)
+		return -ENOMEM;
 	/* cannot use rt2x00usb_register_read here as it uses different
 	 * mode (MULTI_READ vs. DEVICE_MODE) and does not pass the
 	 * magic value USB_MODE_AUTORUN (0x11) to the device, thus the
@@ -241,8 +244,9 @@ static int rt2800usb_autorun_detect(struct rt2x00_dev *=
rt2x00dev)
 	 */
 	rt2x00usb_vendor_request(rt2x00dev, USB_DEVICE_MODE,
 				 USB_VENDOR_REQUEST_IN, 0, USB_MODE_AUTORUN,
-				 &reg, sizeof(reg), REGISTER_TIMEOUT_FIRMWARE);
-	fw_mode =3D le32_to_cpu(reg);
+				 reg, sizeof(*reg), REGISTER_TIMEOUT_FIRMWARE);
+	fw_mode =3D le32_to_cpu(*reg);
+	kfree(reg);
=20
 	if ((fw_mode & 0x00000003) =3D=3D 2)
 		return 1;
@@ -261,6 +265,7 @@ static int rt2800usb_write_firmware(struct rt2x00_dev *=
rt2x00dev,
 	int status;
 	u32 offset;
 	u32 length;
+	int retval;
=20
 	/*
 	 * Check which section of the firmware we need.
@@ -278,7 +283,10 @@ static int rt2800usb_write_firmware(struct rt2x00_dev =
*rt2x00dev,
 	/*
 	 * Write firmware to device.
 	 */
-	if (rt2800usb_autorun_detect(rt2x00dev)) {
+	retval =3D rt2800usb_autorun_detect(rt2x00dev);
+	if (retval < 0)
+		return retval;
+	if (retval) {
 		rt2x00_info(rt2x00dev,
 			    "Firmware loading not required - NIC in AutoRun mode\n");
 	} else {
@@ -763,7 +771,12 @@ static void rt2800usb_fill_rxdone(struct queue_entry *=
entry,
  */
 static int rt2800usb_efuse_detect(struct rt2x00_dev *rt2x00dev)
 {
-	if (rt2800usb_autorun_detect(rt2x00dev))
+	int retval;
+
+	retval =3D rt2800usb_autorun_detect(rt2x00dev);
+	if (retval < 0)
+		return retval;
+	if (retval)
 		return 1;
 	return rt2800_efuse_detect(rt2x00dev);
 }
@@ -772,7 +785,10 @@ static int rt2800usb_read_eeprom(struct rt2x00_dev *rt=
2x00dev)
 {
 	int retval;
=20
-	if (rt2800usb_efuse_detect(rt2x00dev))
+	retval =3D rt2800usb_efuse_detect(rt2x00dev);
+	if (retval < 0)
+		return retval;
+	if (retval)
 		retval =3D rt2800_read_eeprom_efuse(rt2x00dev);
 	else
 		retval =3D rt2x00usb_eeprom_read(rt2x00dev, rt2x00dev->eeprom,
--=20
John W. Linville		Someday the world will need a hero, and you
linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org			might be all we have.  Be ready.

--ZGiS0Q5IWpPtfppv
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJTvwQoAAoJEJctW/TcYTgGlCQP+wRWYf13jewmGfNo+k7/kgB0
bhKwFRXhmMEh4+Yl70ptTziNP/B24+6rAepEpcu08qlTQ/vDm5PUUX8QPezmUd7P
iQYXET+wj0jrnvgP0Xa+T4ZVf7lGJxsWFmUlyiBlhUqNon2jWgbm3MW5LdGSvTQ6
74imZTPdBsGgr+dXXAsW2Fhczpw8rStS7Wf5P0aumYxFRkZ1cnNMJ4ipZWClvWIg
Pu5xFcd46Vx+Y2KIfFjxaOS4PhWmgQMwmHdE7Yf6GC1IZRgpKWbr+F6mCV+qBiJ+
E6nks/O0CTcHInrcr7p1PCgHdH+klTFQ740EBLA/V9bHK/Bykqu2dIO2aHjRPW2r
XQHur7fXczWubUQF27ES5weB5wjkj4vi3nDlp+ETzJ/aVqR2BAH/gaVraN2/5iRW
xF42V0WmrYnGSrgPoHjym2NvZgXDE11wSTh8My/PMgo1Hh2KY9bnEdLuq99Xj6aZ
BjND2gyaebcB99XOD3b6tW6t6axH6mTxjfmYkSu165z6k14k0NsWkzv6uSbuuijq
Y88Ivsu74rvqPEUp7X4Uf6/tVqrYL6mCIAYRitiQockJDK9Yf5GMBK6bP4HC8xLv
hiWOpV+6A/gAKuYTkjRbknVIXFgh0Cie0/VwmaXlzRGQRFY436IeiOyWhOU0AB2s
0HCxe5gg/duDgObk5Hz1
=NDhe
-----END PGP SIGNATURE-----

--ZGiS0Q5IWpPtfppv--
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
