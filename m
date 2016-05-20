From: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH V2 4.8 2/2] brcmfmac: support get_channel cfg80211 callback
Date: Fri, 20 May 2016 13:38:58 +0200
Message-ID: <1463744355-5528-2-git-send-email-zajec5@gmail.com>
References: <1463655770-22467-1-git-send-email-zajec5@gmail.com>
 <1463744355-5528-1-git-send-email-zajec5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Rafa=C5=82=20Mi=C5=82ecki?= <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Brett Rudley <brudley-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Arend van Spriel <arend-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	"Franky (Zhenhui) Lin" <frankyl-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Hante Meuleman <meuleman-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	Pieter-Paul Giesberts <pieterpg-dY08KVG/lbpWk0Htik3J/w@public.gmane.org>,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	brcm80211-dev-list-dY08KVG/lbpWk0Htik3J/w@public.gmane.org (open list:BROADCOM BRCM80211
	IEEE802.11n WIRELESS DRIVER),
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list:NETWORKING DRIVERS),
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org (open list)
To: Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1463744355-5528-1-git-send-email-zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is important for brcmfmac as some of released firmwares (e.g.
brcmfmac4366b-pcie.bin) may pick different channel than requested. This
has been tested with BCM4366B1 in D-Link DIR-885L.

Signed-off-by: Rafa=C5=82 Mi=C5=82ecki <zajec5-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
V2: Check if ndev isn't NULL, update description.
---
 .../broadcom/brcm80211/brcmfmac/cfg80211.c         | 63 ++++++++++++++=
++++++++
 1 file changed, 63 insertions(+)

diff --git a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.=
c b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
index 597495d..299a404 100644
--- a/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
+++ b/drivers/net/wireless/broadcom/brcm80211/brcmfmac/cfg80211.c
@@ -4892,6 +4892,68 @@ exit:
 	return err;
 }
=20
+static int brcmf_cfg80211_get_channel(struct wiphy *wiphy,
+				      struct wireless_dev *wdev,
+				      struct cfg80211_chan_def *chandef)
+{
+	struct brcmf_cfg80211_info *cfg =3D wiphy_to_cfg(wiphy);
+	struct net_device *ndev =3D wdev->netdev;
+	struct brcmf_if *ifp;
+	struct brcmu_chan ch;
+	enum nl80211_band band =3D 0;
+	enum nl80211_chan_width width =3D 0;
+	u32 chanspec;
+	int freq, err;
+
+	if (!ndev)
+		return -ENODEV;
+	ifp =3D netdev_priv(ndev);
+
+	err =3D brcmf_fil_iovar_int_get(ifp, "chanspec", &chanspec);
+	if (err) {
+		brcmf_err("chanspec failed (%d)\n", err);
+		return err;
+	}
+
+	ch.chspec =3D chanspec;
+	cfg->d11inf.decchspec(&ch);
+
+	switch (ch.band) {
+	case BRCMU_CHAN_BAND_2G:
+		band =3D NL80211_BAND_2GHZ;
+		break;
+	case BRCMU_CHAN_BAND_5G:
+		band =3D NL80211_BAND_5GHZ;
+		break;
+	}
+
+	switch (ch.bw) {
+	case BRCMU_CHAN_BW_80:
+		width =3D NL80211_CHAN_WIDTH_80;
+		break;
+	case BRCMU_CHAN_BW_40:
+		width =3D NL80211_CHAN_WIDTH_40;
+		break;
+	case BRCMU_CHAN_BW_20:
+		width =3D NL80211_CHAN_WIDTH_20;
+		break;
+	case BRCMU_CHAN_BW_80P80:
+		width =3D NL80211_CHAN_WIDTH_80P80;
+		break;
+	case BRCMU_CHAN_BW_160:
+		width =3D NL80211_CHAN_WIDTH_160;
+		break;
+	}
+
+	freq =3D ieee80211_channel_to_frequency(ch.control_ch_num, band);
+	chandef->chan =3D ieee80211_get_channel(wiphy, freq);
+	chandef->width =3D width;
+	chandef->center_freq1 =3D ieee80211_channel_to_frequency(ch.chnum, ba=
nd);
+	chandef->center_freq2 =3D 0;
+
+	return 0;
+}
+
 static int brcmf_cfg80211_crit_proto_start(struct wiphy *wiphy,
 					   struct wireless_dev *wdev,
 					   enum nl80211_crit_proto_id proto,
@@ -5054,6 +5116,7 @@ static struct cfg80211_ops brcmf_cfg80211_ops =3D=
 {
 	.mgmt_tx =3D brcmf_cfg80211_mgmt_tx,
 	.remain_on_channel =3D brcmf_p2p_remain_on_channel,
 	.cancel_remain_on_channel =3D brcmf_cfg80211_cancel_remain_on_channel=
,
+	.get_channel =3D brcmf_cfg80211_get_channel,
 	.start_p2p_device =3D brcmf_p2p_start_device,
 	.stop_p2p_device =3D brcmf_p2p_stop_device,
 	.crit_proto_start =3D brcmf_cfg80211_crit_proto_start,
--=20
1.8.4.5

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
