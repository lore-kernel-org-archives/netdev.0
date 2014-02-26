From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the wireless
 tree
Date: Wed, 26 Feb 2014 14:21:05 +1100
Message-ID: <20140226142105.6e7154303b423b0eef78518d@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA256";
 boundary="Signature=_Wed__26_Feb_2014_14_21_05_+1100_mA.s5K__i=Jyapdm"
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Felix Fietkau <nbd@openwrt.org>,
	Oleksij Rempel <linux@rempel-privat.de>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Signature=_Wed__26_Feb_2014_14_21_05_+1100_mA.s5K__i=Jyapdm
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi all,

Today's linux-next merge of the net-next tree got a conflict in
drivers/net/wireless/ath/ath9k/recv.c between commit b7b146c9c9a0
("ath9k: fix invalid descriptor discarding") from the wireless tree and
commits 1274603646a8 ("ath9k: move ath9k_process_rate to common.c") and
6438696efa81 ("ath9k: move ath9k_rx_accept to common.c") from the
net-next tree.

I fixed it up (see below) and can carry the fix as necessary (no action
is required).

--=20
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc drivers/net/wireless/ath/ath9k/recv.c
index 82e340d3ec60,076dae1e5ab7..000000000000
--- a/drivers/net/wireless/ath/ath9k/recv.c
+++ b/drivers/net/wireless/ath/ath9k/recv.c
@@@ -1055,8 -853,10 +857,8 @@@ static int ath9k_rx_skb_preprocess(stru
  	 * everything but the rate is checked here, the rate check is done
  	 * separately to avoid doing two lookups for a rate for each frame.
  	 */
- 	if (!ath9k_rx_accept(common, hdr, rx_status, rx_stats, decrypt_error))
 -	if (!ath9k_cmn_rx_accept(common, hdr, rx_status, rx_stats, decrypt_error=
, sc->rx.rxfilter)) {
 -		ret =3D -EINVAL;
 -		goto exit;
 -	}
++	if (!ath9k_cmn_rx_accept(common, hdr, rx_status, rx_stats, decrypt_error=
, sc->rx.rxfilter))
 +		return -EINVAL;
 =20
  	if (ath_is_mybeacon(common, hdr)) {
  		RX_STAT_INC(rx_beacons);
@@@ -1066,13 -866,24 +868,21 @@@
  	/*
  	 * This shouldn't happen, but have a safety check anyway.
  	 */
 -	if (WARN_ON(!ah->curchan)) {
 -		ret =3D -EINVAL;
 -		goto exit;
 -	}
 +	if (WARN_ON(!ah->curchan))
 +		return -EINVAL;
 =20
- 	if (ath9k_process_rate(common, hw, rx_stats, rx_status))
+ 	if (ath9k_cmn_process_rate(common, hw, rx_stats, rx_status)) {
+ 		/*
+ 		 * No valid hardware bitrate found -- we should not get here
+ 		 * because hardware has already validated this frame as OK.
+ 		 */
+ 		ath_dbg(common, ANY, "unsupported hw bitrate detected 0x%02x using 1 Mb=
it\n",
+ 			rx_stats->rs_rate);
+ 		RX_STAT_INC(rx_rate_err);
 -		ret =3D-EINVAL;
 -		goto exit;
 +		return -EINVAL;
+ 	}
 =20
- 	ath9k_process_rssi(common, hw, rx_stats, rx_status);
+ 	ath9k_cmn_process_rssi(common, hw, rx_stats, rx_status);
 =20
  	rx_status->band =3D ah->curchan->chan->band;
  	rx_status->freq =3D ah->curchan->chan->center_freq;
@@@ -1085,64 -896,11 +895,13 @@@
  		sc->rx.num_pkts++;
  #endif
 =20
 -exit:
 -	sc->rx.discard_next =3D false;
 -	return ret;
 +	return 0;
 +
 +corrupt:
 +	sc->rx.discard_next =3D rx_stats->rs_more;
 +	return -EINVAL;
  }
 =20
- static void ath9k_rx_skb_postprocess(struct ath_common *common,
- 				     struct sk_buff *skb,
- 				     struct ath_rx_status *rx_stats,
- 				     struct ieee80211_rx_status *rxs,
- 				     bool decrypt_error)
- {
- 	struct ath_hw *ah =3D common->ah;
- 	struct ieee80211_hdr *hdr;
- 	int hdrlen, padpos, padsize;
- 	u8 keyix;
- 	__le16 fc;
-=20
- 	/* see if any padding is done by the hw and remove it */
- 	hdr =3D (struct ieee80211_hdr *) skb->data;
- 	hdrlen =3D ieee80211_get_hdrlen_from_skb(skb);
- 	fc =3D hdr->frame_control;
- 	padpos =3D ieee80211_hdrlen(fc);
-=20
- 	/* The MAC header is padded to have 32-bit boundary if the
- 	 * packet payload is non-zero. The general calculation for
- 	 * padsize would take into account odd header lengths:
- 	 * padsize =3D (4 - padpos % 4) % 4; However, since only
- 	 * even-length headers are used, padding can only be 0 or 2
- 	 * bytes and we can optimize this a bit. In addition, we must
- 	 * not try to remove padding from short control frames that do
- 	 * not have payload. */
- 	padsize =3D padpos & 3;
- 	if (padsize && skb->len>=3Dpadpos+padsize+FCS_LEN) {
- 		memmove(skb->data + padsize, skb->data, padpos);
- 		skb_pull(skb, padsize);
- 	}
-=20
- 	keyix =3D rx_stats->rs_keyix;
-=20
- 	if (!(keyix =3D=3D ATH9K_RXKEYIX_INVALID) && !decrypt_error &&
- 	    ieee80211_has_protected(fc)) {
- 		rxs->flag |=3D RX_FLAG_DECRYPTED;
- 	} else if (ieee80211_has_protected(fc)
- 		   && !decrypt_error && skb->len >=3D hdrlen + 4) {
- 		keyix =3D skb->data[hdrlen + 3] >> 6;
-=20
- 		if (test_bit(keyix, common->keymap))
- 			rxs->flag |=3D RX_FLAG_DECRYPTED;
- 	}
- 	if (ah->sw_mgmt_crypto &&
- 	    (rxs->flag & RX_FLAG_DECRYPTED) &&
- 	    ieee80211_is_mgmt(fc))
- 		/* Use software decrypt for management frames. */
- 		rxs->flag &=3D ~RX_FLAG_DECRYPTED;
- }
-=20
  /*
   * Run the LNA combining algorithm only in these cases:
   *

--Signature=_Wed__26_Feb_2014_14_21_05_+1100_mA.s5K__i=Jyapdm
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBCAAGBQJTDV2mAAoJEMDTa8Ir7ZwVOIEQAIX9Gmks6bSnjhsrlWSfsQpL
aR37r7R52Gp3j0cg0XqdCbV/U/6168XvCn2Drx5fCR2Du515pjef+zTA1c4wXX+w
zirBvcKX2/rPIbsIa7ZK+rbsJb1O1UY9DmPNWU2+DLWkrfI6MsQeo2o2qnNMPbcE
dpX1nqTSO3JxjyRZQcU4SyS0992awtrQGq2x850qHk3UHby/K8TnFP85YNV9F7wg
TF1B6UOEl53CaLyNflqYMVGViTEE+wmC3dTdXPbWr6/4yohZ2j1Mn3jcIE7n/QgG
AQnPEy5WxrG7OcNcjFfkYNwGcYyzM9mrGFSc/JKzPANqNuNIqa37EOgf13cC/yn8
7+27ft9qwYcAiX+UE+exg+NeYQ3tz56cbFVc5dj3+naAeNAT5VdxujVEnPURk52X
uFZc2llRFRscf7EfdcUOxDFszpeCkuG5+z6tE8Uk9E5yC9tdoP4IDtX/xYdXdMT4
8yuwvi9sAV4Rq/4uSGO1j9YLkFgo4i25Sb9Y2CPE2lEIaGZif9ZBgjJjEur3XmRv
Eg5UJkFFPGbHJFswaDsD76PfF/6Md7q2d7F30RyPH9jXsQjBEogJdZlQdYXZKxzR
VjWuL6oEZLcKVe8DPFUS4fQ1pVgtdgG3oSF727V3mj0ft9ygGpwbnrdvgZJfFVtk
c3atFT5G74smitJVuWs7
=Osrq
-----END PGP SIGNATURE-----

--Signature=_Wed__26_Feb_2014_14_21_05_+1100_mA.s5K__i=Jyapdm--
