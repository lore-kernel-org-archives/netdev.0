From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net/wireless/nl80211.c: fix endless Netlink callback
	loop.
Date: Tue, 08 Jul 2008 14:06:39 +0200
Message-ID: <1215518799.9610.33.camel@johannes.berg>
References: <1215518539-19587-1-git-send-email-juliusv@google.com>
	 (sfid-20080708_140237_236764_3E4EA51A)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-5L14heZADyWdn7y9wsMC"
Cc: netdev@vger.kernel.org
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:38644 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755161AbYGHMHW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 08:07:22 -0400
In-Reply-To: <1215518539-19587-1-git-send-email-juliusv@google.com> (sfid-20080708_140237_236764_3E4EA51A)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-5L14heZADyWdn7y9wsMC
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Tue, 2008-07-08 at 14:02 +0200, Julius Volz wrote:
> Although I only tested similar code (I don't use any of this wireless
> code), the state maintainance between Netlink dump callback invocations
> seems wrong here and should lead to an endless loop. There are also other
> examples in the same file which might have the same problem. Perhaps some=
one
> can actually test this (or refute my logic).
>=20
> Take the simple example with only one element in the list (which should f=
it
> into the message):

> Also, iterations where the filling of an element fails should not be coun=
ted as
> completed, so idx should not be incremented in this case.

Seems to be the case on both points, however,

> --- a/net/wireless/nl80211.c
> +++ b/net/wireless/nl80211.c
> @@ -194,22 +194,24 @@ static int nl80211_send_wiphy(struct sk_buff *msg, =
u32 pid, u32 seq, int flags,
>  static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callba=
ck *cb)
>  {
>  	int idx =3D 0;
>  	int start =3D cb->args[0];
>  	struct cfg80211_registered_device *dev;
> =20
>  	mutex_lock(&cfg80211_drv_mutex);
>  	list_for_each_entry(dev, &cfg80211_drv_list, list) {
> -		if (++idx < start)
> +		if (++idx <=3D start)
>  			continue;
>  		if (nl80211_send_wiphy(skb, NETLINK_CB(cb->skb).pid,
>  				       cb->nlh->nlmsg_seq, NLM_F_MULTI,
> -				       dev) < 0)
> +				       dev) < 0) {
> +			idx--;
>  			break;
> +		}

I see much of the problem stemming from incrementing 'idx' at the
beginning of the loop, can't we just move it to the end?

johannes

--=-5L14heZADyWdn7y9wsMC
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIc1hHAAoJEKVg1VMiehFYBQ4P/1otVvGmUUC8txc5yVMk0Rfa
u4gXQ1WGuQMZ79vaxhg7fArv1vYFchbAKRIbhz0J2A7GlqjsqQp+KhOpOl6Nv1eu
4Nl41AgdhLlpB8ZfQw4evjdCdF+M7rqn1ogUU2SmGK23mKVjNs84pAce1lsa7qG8
O7mEZQ11RQmRkgSmkv7hQ5MWpHOrIBKADgefeM9oiQ+cLmGitvtsWs5Uk4JEk+yx
VwAiFWZajRJWHFkpIHiP8V2btq1LvGxPLOraCykWEDbwkFRmmoz17Zv9acYE/ypg
tatVWEg2Bq4/dWCrmL8ku9osPcZoGXx2oTgGupSPjwqsOG28W/jbkdNjgaFi5vr+
z0yVHWkziYi1LlzK56jMyQvLhbhZW4QB248aa8y4aipLLtxPgh1TMfY3eOfzILIL
XYh3T7dvHjfi90buZUz820rTprlTFReQOGxhoyeeQgkGpHUn0kWh9Fxa+Ok6wUgj
IC77hGVGwsHSdMaSGruk1q0Q0x4eafcG8oML4dRTROWw3VN5jVryCt8vUSY0Djxz
+tMjZXwbiDo6gD/JWdVLbRoggzX9p4u/QgpDfW3sdA3BOLaFRW0X8mRwZ9Z8cpcA
lfv5qzGGFz7nAMoEToyss1/zigCepPScCK/INSdIhAFQGu9MvbVw0vCJSpek+YWE
9sbRowjUZFxSNubgjhvs
=fS/L
-----END PGP SIGNATURE-----

--=-5L14heZADyWdn7y9wsMC--

