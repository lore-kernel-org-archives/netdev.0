From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Tue, 27 Aug 2013 14:10:56 +1000
Message-ID: <20130827141056.d4e343a874a7b21eecc0ee5c@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Tue__27_Aug_2013_14_10_56_+1000_+U60qZKggG99iGre"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Simon Wunderlich <simon.wunderlich@s2003.tu-chemnitz.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Tue__27_Aug_2013_14_10_56_+1000_+U60qZKggG99iGre
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
net/mac80211/ibss.c between commit 75a423f493ff ("mac80211: ibss: fix
ignored channel parameter") from the wireless tree and commit
7ca15a0ae865 ("mac80211: allow scanning for 5/10 MHz channels in IBSS")
from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc net/mac80211/ibss.c
index 2d45643,e08387c..0000000
--- a/net/mac80211/ibss.c
+++ b/net/mac80211/ibss.c
@@@ -48,12 -49,13 +49,14 @@@ static void __ieee80211_sta_join_ibss(s
  	u8 *pos;
  	struct ieee80211_supported_band *sband;
  	struct cfg80211_bss *bss;
- 	u32 bss_change;
- 	u8 supp_rates[IEEE80211_MAX_SUPP_RATES];
+ 	u32 bss_change, rate_flags, rates =3D 0, rates_added =3D 0;
  	struct cfg80211_chan_def chandef;
 +	struct ieee80211_channel *chan;
+ 	enum nl80211_bss_scan_width scan_width;
+ 	bool have_higher_than_11mbit =3D false;
  	struct beacon_data *presp;
  	int frame_len;
+ 	int shift;
 =20
  	sdata_assert_lock(sdata);
 =20
@@@ -82,10 -84,16 +85,18 @@@
 =20
  	sdata->drop_unencrypted =3D capability & WLAN_CAPABILITY_PRIVACY ? 1 : 0;
 =20
 -	chandef =3D ifibss->chandef;
 +	/* make a copy of the chandef, it could be modified below. */
 +	chandef =3D *req_chandef;
 +	chan =3D chandef.chan;
  	if (!cfg80211_reg_can_beacon(local->hw.wiphy, &chandef)) {
+ 		if (chandef.width =3D=3D NL80211_CHAN_WIDTH_5 ||
+ 		    chandef.width =3D=3D NL80211_CHAN_WIDTH_10 ||
+ 		    chandef.width =3D=3D NL80211_CHAN_WIDTH_20_NOHT ||
+ 		    chandef.width =3D=3D NL80211_CHAN_WIDTH_20) {
+ 			sdata_info(sdata,
+ 				   "Failed to join IBSS, beacons forbidden\n");
+ 			return;
+ 		}
  		chandef.width =3D NL80211_CHAN_WIDTH_20;
  		chandef.center_freq1 =3D chan->center_freq;
  	}
@@@ -267,35 -310,18 +314,39 @@@ static void ieee80211_sta_join_ibss(str
  	int i, j;
  	u16 beacon_int =3D cbss->beacon_interval;
  	const struct cfg80211_bss_ies *ies;
 +	enum nl80211_channel_type chan_type;
  	u64 tsf;
+ 	u32 rate_flags;
+ 	int shift;
 =20
  	sdata_assert_lock(sdata);
 =20
  	if (beacon_int < 10)
  		beacon_int =3D 10;
 =20
 +	switch (sdata->u.ibss.chandef.width) {
 +	case NL80211_CHAN_WIDTH_20_NOHT:
 +	case NL80211_CHAN_WIDTH_20:
 +	case NL80211_CHAN_WIDTH_40:
 +		chan_type =3D cfg80211_get_chandef_type(&sdata->u.ibss.chandef);
 +		cfg80211_chandef_create(&chandef, cbss->channel, chan_type);
 +		break;
 +	case NL80211_CHAN_WIDTH_5:
 +	case NL80211_CHAN_WIDTH_10:
 +		cfg80211_chandef_create(&chandef, cbss->channel,
 +					NL80211_CHAN_WIDTH_20_NOHT);
 +		chandef.width =3D sdata->u.ibss.chandef.width;
 +		break;
 +	default:
 +		/* fall back to 20 MHz for unsupported modes */
 +		cfg80211_chandef_create(&chandef, cbss->channel,
 +					NL80211_CHAN_WIDTH_20_NOHT);
 +		break;
 +	}
 +
  	sband =3D sdata->local->hw.wiphy->bands[cbss->channel->band];
+ 	rate_flags =3D ieee80211_chandef_rate_flags(&sdata->u.ibss.chandef);
+ 	shift =3D ieee80211_vif_get_shift(&sdata->vif);
 =20
  	basic_rates =3D 0;
 =20

--Signature=_Tue__27_Aug_2013_14_10_56_+1000_+U60qZKggG99iGre
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.20 (GNU/Linux)

iQIcBAEBCAAGBQJSHCbUAAoJEECxmPOUX5FEoqcP/RDyGSx6d+bNpw7NP/Nm1U8+
7j6HQCu9/006H/cqiz0ie2l/Z07blIwRq32oIpqxWhDReJ7GHtFMkP3pDwCH+Jsm
DMgpshKJmGJN8yLmY3eciq5IQ54W+Uux81X+IUhrWftqX2dRC4t64jz8agP82upf
mIarAah2HZIDnKxIPILiyzF50QpjcR4rYBxrF287AYBQDkOPzl+i0WL7jYvjMF0p
KiMFFec0KL4hLJA5zR/C4MRAsNasKnI4ZGi/U5y19WiR7BG1pmJWdAIiP2G9mC5L
iVwK+/SA3e3mKoENtZaSPPdjGmsdDpnUO/SmPvdE6bayXe/e9qOAiPsal/q1z2kb
wguUyWUZoadACBVrBQ9MDHgvb0gEWoMJHPdNLZA5Ih6G+6SPITnSfofLtgvnIGQr
JlspWDePHJGAV28BvimLf5NC0PX2KtpiA82BDxIteQlXMacYvJVMdWR8q/OMBe1e
YfwFg9xF8OoIJJS/+Zd1NnSwJsPan4bMI1/I9pokvAILofNW/2FzZukdt4XAhdfn
z5Nq5c7/LClZu8F2qD76MMDXE57AXcM+fKVgPqXFDX+xHkU7yIIzmj81P8b8URl0
SHWD6TxakIfMohqOnt23ZXQIFubSR0k8R9dOqbYTRtbS29bK9QDDURjOFf2hcnUU
EsOLYKhUlo1kt4rFICwB
=sPtG
-----END PGP SIGNATURE-----

--Signature=_Tue__27_Aug_2013_14_10_56_+1000_+U60qZKggG99iGre--
