From: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Subject: mac80211 truesize bugs
Date: Thu, 01 May 2008 04:02:48 +0200
Message-ID: <1209607368.7173.20.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-Dpc07RSskzhXXMFJW4Ta"
Cc: linux-wireless <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-Dpc07RSskzhXXMFJW4Ta
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Hi,

Whenever you run a monitor interface in mac80211, you can see lots of
truesize bugs:

SKB BUG: Invalid truesize (464) len=3D307, sizeof(sk_buff)=3D176

It appears to be caused by mac80211's re-injection of the transmitted
frame. For those not familiar, here's what happens:

When a frame comes in on say wlan0's hard_start_xmit(), it is prepared
for transmission by the code there (802.11 headers added etc.) and then
scheduled to the master interface. Once it arrives on the master
(wmaster0) interface's hard_start_xmit(), it is modified again and
finally handed to the driver.

When the driver has transmitted the frame (successfully or not) it
reports the status of the transmission to mac80211 including the skb the
driver was given. At that point, things go different depending on
circumstances.

If no monitor interfaces are present, mac80211 simply orphans the skb
and destroys it. If there are monitor interfaces, it pushes some data
into the skb (the radiotap transmit status) and hands clones of the skb
to netif_rx() for each monitor interface, or the skb itself for the last
interface in the list.

All this is in net/mac80211/main.c:ieee80211_tx_status.

Now, the thing is that the skb truesize bug ONLY occurs when the last
part here is done when a radiotap monitor interface is present, if you
add

	dev_kfree_skb(skb);
	return;

in that function somewhere before the skb_orphan() call it never
happens. Hence, I'm confused. Since I only have a single monitor
interface when this happens, it can't be due to af_packet either,
afaict.

Can anyone help me diagnose this?

johannes

--=-Dpc07RSskzhXXMFJW4Ta
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIVAwUASBkkxqVg1VMiehFYAQIGaxAAt9J6H/MUKjLU+yt9gg7/s9BKvsBm5X26
H2x8LbxOW5Sj0isvtslWIav3Z5+mnXsXOpN7jgEGm3s+W+pc0++sLWcCaj4Nsett
NxwVMKIVNXmEFFuvGUpFv5BhXwlC1BAlt7Pw7z/w497uqrY8gaHnqvWTigGl6oE0
RomflSf7S8VsLhZlcO5fM2HbXapb0FYq8/JFnfTaxbQHSn3KAQpec7a3J43LWMHj
m2SpmObgaIRfM1stbEKPYqLC7jD/+5ijAu88CFAd8wkcGIcFHZqEvImazxomO7SD
6UxXjg8xxTVIYtLoVENWg/dwYnZv7uo18NvODarYCkOsl96yVMAzGXQ5cNGqL8fL
VVNHmA6WuFCVfcPlV234feNgVc/BnmFOzg9COzlpEGzADukFBftV/iW1MfqAZzui
8nmQRQMf31JteTql1NL5feUsDQs85HUsJPenL9HlL8c+IrcubyKAbERbpS5whvME
LVknwt6VeCxI9L7W/FndAP6zZNnR2sJiaUT5FxGhZ0GXmKgrHsDJoEe/J+7rBkEH
NTqDh8tFYfyqH5Bk5fkCjqu0vs8zNXkiV8F4jBbq34DWKskqjiCMyy6eLY40BKfZ
YUjgYpVSoyphjBXuMseKBKBAHvYTSMyRBhnOTHZbB5Jrtdnxb8PbJ/088+cpFgyr
beX/00QJ9jU=
=a4Qa
-----END PGP SIGNATURE-----

--=-Dpc07RSskzhXXMFJW4Ta--

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
