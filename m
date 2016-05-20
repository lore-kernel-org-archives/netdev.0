From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>
Subject: [PATCH V2 4.8 1/2] brcmutil: add field storing control channel to the struct brcmu_chan
Date: Fri, 20 May 2016 13:38:57 +0200
Message-ID: <1463744355-5528-1-git-send-email-zajec5@gmail.com>
References: <1463655770-22467-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5@gmail.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	linux-wireless@vger.kernel.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list@broadcom.com (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev@vger.kernel.org (open list:NETWORKING DRIVERS),
	linux-kernel@vger.kernel.org (open list)
To: Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1463655770-22467-1-git-send-email-zajec5@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Our d11 code supports encoding/decoding channel info into/from chanspec
format used by firmware. Current implementation is quite misleading
because of the way "chnum" field is used.
When encoding channel info, "chnum" has to be filled by a caller with
*center* channel number. However when decoding chanspec the same field
is filled with a *control* channel number.

1) This can be confusing. It's expected for information to be the same
   after encoding and decoding.
2) It doesn't allow accessing all info when decoding. Some functions ma=
y
   need to know both channel numbers, e.g. cfg80211 callback getting
   current channel.
Solve this by adding a separated field for control channel.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5@gmail.com>
Reviewed-by: Arend van Spriel <arend.vanspriel@broadcom.com>
---
V2: Update commit description message.
---
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 17 +++++++++-----=
---
 .../net/wireless/broadcom/brcm80211/brcmfmac/p2p.c | 10 +++++-----
 .../net/wireless/broadcom/brcm80211/brcmutil/d11.c | 18 ++++++++++----=
----
 .../broadcom/brcm80211/include/brcmu_d11.h         | 22 ++++++++++++++=
++++++++
 4 files changed, 46 insertions(+), 21 deletions(-)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index d0631b6..597495d 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -2734,7 +2734,7 @@ static s32 brcmf_inform_single_bss(struct brcmf_c=
fg80211_info *cfg,
 	if (!bi->ctl_ch) {
 		ch.chspec =3D le16_to_cpu(bi->chanspec);
 		cfg->d11inf.decchspec(&ch);
-		bi->ctl_ch =3D ch.chnum;
+		bi->ctl_ch =3D ch.control_ch_num;
 	}
 	channel =3D bi->ctl_ch;
=20
@@ -2852,7 +2852,7 @@ static s32 brcmf_inform_ibss(struct brcmf_cfg8021=
1_info *cfg,
 	else
 		band =3D wiphy->bands[NL80211_BAND_5GHZ];
=20
-	freq =3D ieee80211_channel_to_frequency(ch.chnum, band->band);
+	freq =3D ieee80211_channel_to_frequency(ch.control_ch_num, band->band=
);
 	cfg->channel =3D freq;
 	notify_channel =3D ieee80211_get_channel(wiphy, freq);
=20
@@ -2862,7 +2862,7 @@ static s32 brcmf_inform_ibss(struct brcmf_cfg8021=
1_info *cfg,
 	notify_ielen =3D le32_to_cpu(bi->ie_length);
 	notify_signal =3D (s16)le16_to_cpu(bi->RSSI) * 100;
=20
-	brcmf_dbg(CONN, "channel: %d(%d)\n", ch.chnum, freq);
+	brcmf_dbg(CONN, "channel: %d(%d)\n", ch.control_ch_num, freq);
 	brcmf_dbg(CONN, "capability: %X\n", notify_capability);
 	brcmf_dbg(CONN, "beacon interval: %d\n", notify_interval);
 	brcmf_dbg(CONN, "signal: %d\n", notify_signal);
@@ -5280,7 +5280,7 @@ brcmf_bss_roaming_done(struct brcmf_cfg80211_info=
 *cfg,
 	else
 		band =3D wiphy->bands[NL80211_BAND_5GHZ];
=20
-	freq =3D ieee80211_channel_to_frequency(ch.chnum, band->band);
+	freq =3D ieee80211_channel_to_frequency(ch.control_ch_num, band->band=
);
 	notify_channel =3D ieee80211_get_channel(wiphy, freq);
=20
 done:
@@ -5802,14 +5802,15 @@ static int brcmf_construct_chaninfo(struct brcm=
f_cfg80211_info *cfg,
 		channel =3D band->channels;
 		index =3D band->n_channels;
 		for (j =3D 0; j < band->n_channels; j++) {
-			if (channel[j].hw_value =3D=3D ch.chnum) {
+			if (channel[j].hw_value =3D=3D ch.control_ch_num) {
 				index =3D j;
 				break;
 			}
 		}
 		channel[index].center_freq =3D
-			ieee80211_channel_to_frequency(ch.chnum, band->band);
-		channel[index].hw_value =3D ch.chnum;
+			ieee80211_channel_to_frequency(ch.control_ch_num,
+						       band->band);
+		channel[index].hw_value =3D ch.control_ch_num;
=20
 		/* assuming the chanspecs order is HT20,
 		 * HT40 upper, HT40 lower, and VHT80.
@@ -5911,7 +5912,7 @@ static int brcmf_enable_bw40_2g(struct brcmf_cfg8=
0211_info *cfg)
 			if (WARN_ON(ch.bw !=3D BRCMU_CHAN_BW_40))
 				continue;
 			for (j =3D 0; j < band->n_channels; j++) {
-				if (band->channels[j].hw_value =3D=3D ch.chnum)
+				if (band->channels[j].hw_value =3D=3D ch.control_ch_num)
 					break;
 			}
 			if (WARN_ON(j =3D=3D band->n_channels))
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c b/d=
rivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
index a70cda6..1652a48 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/p2p.c
@@ -1246,7 +1246,7 @@ bool brcmf_p2p_scan_finding_common_channel(struct=
 brcmf_cfg80211_info *cfg,
 		if (!bi->ctl_ch) {
 			ch.chspec =3D le16_to_cpu(bi->chanspec);
 			cfg->d11inf.decchspec(&ch);
-			bi->ctl_ch =3D ch.chnum;
+			bi->ctl_ch =3D ch.control_ch_num;
 		}
 		afx_hdl->peer_chan =3D bi->ctl_ch;
 		brcmf_dbg(TRACE, "ACTION FRAME SCAN : Peer %pM found, channel : %d\n=
",
@@ -1385,7 +1385,7 @@ int brcmf_p2p_notify_action_frame_rx(struct brcmf=
_if *ifp,
 			if (test_bit(BRCMF_P2P_STATUS_FINDING_COMMON_CHANNEL,
 				     &p2p->status) &&
 			    (ether_addr_equal(afx_hdl->tx_dst_addr, e->addr))) {
-				afx_hdl->peer_chan =3D ch.chnum;
+				afx_hdl->peer_chan =3D ch.control_ch_num;
 				brcmf_dbg(INFO, "GON request: Peer found, channel=3D%d\n",
 					  afx_hdl->peer_chan);
 				complete(&afx_hdl->act_frm_scan);
@@ -1428,7 +1428,7 @@ int brcmf_p2p_notify_action_frame_rx(struct brcmf=
_if *ifp,
 	memcpy(&mgmt_frame->u, frame, mgmt_frame_len);
 	mgmt_frame_len +=3D offsetof(struct ieee80211_mgmt, u);
=20
-	freq =3D ieee80211_channel_to_frequency(ch.chnum,
+	freq =3D ieee80211_channel_to_frequency(ch.control_ch_num,
 					      ch.band =3D=3D BRCMU_CHAN_BAND_2G ?
 					      NL80211_BAND_2GHZ :
 					      NL80211_BAND_5GHZ);
@@ -1873,7 +1873,7 @@ s32 brcmf_p2p_notify_rx_mgmt_p2p_probereq(struct =
brcmf_if *ifp,
=20
 	if (test_bit(BRCMF_P2P_STATUS_FINDING_COMMON_CHANNEL, &p2p->status) &=
&
 	    (ether_addr_equal(afx_hdl->tx_dst_addr, e->addr))) {
-		afx_hdl->peer_chan =3D ch.chnum;
+		afx_hdl->peer_chan =3D ch.control_ch_num;
 		brcmf_dbg(INFO, "PROBE REQUEST: Peer found, channel=3D%d\n",
 			  afx_hdl->peer_chan);
 		complete(&afx_hdl->act_frm_scan);
@@ -1898,7 +1898,7 @@ s32 brcmf_p2p_notify_rx_mgmt_p2p_probereq(struct =
brcmf_if *ifp,
=20
 	mgmt_frame =3D (u8 *)(rxframe + 1);
 	mgmt_frame_len =3D e->datalen - sizeof(*rxframe);
-	freq =3D ieee80211_channel_to_frequency(ch.chnum,
+	freq =3D ieee80211_channel_to_frequency(ch.control_ch_num,
 					      ch.band =3D=3D BRCMU_CHAN_BAND_2G ?
 					      NL80211_BAND_2GHZ :
 					      NL80211_BAND_5GHZ);
diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmutil/d11.c b/d=
rivers/net/wireless/broadcom/brcm80211/brcmutil/d11.c
index 2b2522b..d8b79cb 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmutil/d11.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmutil/d11.c
@@ -107,6 +107,7 @@ static void brcmu_d11n_decchspec(struct brcmu_chan =
*ch)
 	u16 val;
=20
 	ch->chnum =3D (u8)(ch->chspec & BRCMU_CHSPEC_CH_MASK);
+	ch->control_ch_num =3D ch->chnum;
=20
 	switch (ch->chspec & BRCMU_CHSPEC_D11N_BW_MASK) {
 	case BRCMU_CHSPEC_D11N_BW_20:
@@ -118,10 +119,10 @@ static void brcmu_d11n_decchspec(struct brcmu_cha=
n *ch)
 		val =3D ch->chspec & BRCMU_CHSPEC_D11N_SB_MASK;
 		if (val =3D=3D BRCMU_CHSPEC_D11N_SB_L) {
 			ch->sb =3D BRCMU_CHAN_SB_L;
-			ch->chnum -=3D CH_10MHZ_APART;
+			ch->control_ch_num -=3D CH_10MHZ_APART;
 		} else {
 			ch->sb =3D BRCMU_CHAN_SB_U;
-			ch->chnum +=3D CH_10MHZ_APART;
+			ch->control_ch_num +=3D CH_10MHZ_APART;
 		}
 		break;
 	default:
@@ -147,6 +148,7 @@ static void brcmu_d11ac_decchspec(struct brcmu_chan=
 *ch)
 	u16 val;
=20
 	ch->chnum =3D (u8)(ch->chspec & BRCMU_CHSPEC_CH_MASK);
+	ch->control_ch_num =3D ch->chnum;
=20
 	switch (ch->chspec & BRCMU_CHSPEC_D11AC_BW_MASK) {
 	case BRCMU_CHSPEC_D11AC_BW_20:
@@ -158,10 +160,10 @@ static void brcmu_d11ac_decchspec(struct brcmu_ch=
an *ch)
 		val =3D ch->chspec & BRCMU_CHSPEC_D11AC_SB_MASK;
 		if (val =3D=3D BRCMU_CHSPEC_D11AC_SB_L) {
 			ch->sb =3D BRCMU_CHAN_SB_L;
-			ch->chnum -=3D CH_10MHZ_APART;
+			ch->control_ch_num -=3D CH_10MHZ_APART;
 		} else if (val =3D=3D BRCMU_CHSPEC_D11AC_SB_U) {
 			ch->sb =3D BRCMU_CHAN_SB_U;
-			ch->chnum +=3D CH_10MHZ_APART;
+			ch->control_ch_num +=3D CH_10MHZ_APART;
 		} else {
 			WARN_ON_ONCE(1);
 		}
@@ -172,16 +174,16 @@ static void brcmu_d11ac_decchspec(struct brcmu_ch=
an *ch)
 					 BRCMU_CHSPEC_D11AC_SB_SHIFT);
 		switch (ch->sb) {
 		case BRCMU_CHAN_SB_LL:
-			ch->chnum -=3D CH_30MHZ_APART;
+			ch->control_ch_num -=3D CH_30MHZ_APART;
 			break;
 		case BRCMU_CHAN_SB_LU:
-			ch->chnum -=3D CH_10MHZ_APART;
+			ch->control_ch_num -=3D CH_10MHZ_APART;
 			break;
 		case BRCMU_CHAN_SB_UL:
-			ch->chnum +=3D CH_10MHZ_APART;
+			ch->control_ch_num +=3D CH_10MHZ_APART;
 			break;
 		case BRCMU_CHAN_SB_UU:
-			ch->chnum +=3D CH_30MHZ_APART;
+			ch->control_ch_num +=3D CH_30MHZ_APART;
 			break;
 		default:
 			WARN_ON_ONCE(1);
diff --git a/drivers/net/wireless/broadcom/brcm80211/include/brcmu_d11.=
h b/drivers/net/wireless/broadcom/brcm80211/include/brcmu_d11.h
index f9745ea..8b8b2ec 100644
--- a/drivers/net/wireless/broadcom/brcm80211/include/brcmu_d11.h
+++ b/drivers/net/wireless/broadcom/brcm80211/include/brcmu_d11.h
@@ -125,14 +125,36 @@ enum brcmu_chan_sb {
 	BRCMU_CHAN_SB_UU =3D BRCMU_CHAN_SB_LUU,
 };
=20
+/**
+ * struct brcmu_chan - stores channel formats
+ *
+ * This structure can be used with functions translating chanspec into=
 generic
+ * channel info and the other way.
+ *
+ * @chspec: firmware specific format
+ * @chnum: center channel number
+ * @control_ch_num: control channel number
+ * @band: frequency band
+ * @bw: channel width
+ * @sb: control sideband (location of control channel against the cent=
er one)
+ */
 struct brcmu_chan {
 	u16 chspec;
 	u8 chnum;
+	u8 control_ch_num;
 	u8 band;
 	enum brcmu_chan_bw bw;
 	enum brcmu_chan_sb sb;
 };
=20
+/**
+ * struct brcmu_d11inf - provides functions translating channel format
+ *
+ * @io_type: determines version of channel format used by firmware
+ * @encchspec: encodes channel info into a chanspec, requires center c=
hannel
+ *	number, ignores control one
+ * @decchspec: decodes chanspec into generic info
+ */
 struct brcmu_d11inf {
 	u8 io_type;
=20
--=20
1.8.4.5
