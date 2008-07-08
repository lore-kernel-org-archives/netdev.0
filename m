From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net/wireless/nl80211.c: fix endless Netlink callback
	loop.
Date: Tue, 08 Jul 2008 14:30:35 +0200
Message-ID: <1215520235.9610.39.camel@johannes.berg>
References: <1215518539-19587-1-git-send-email-juliusv@google.com>
	 <1215518799.9610.33.camel@johannes.berg>
	 <f4845fc0807080523o7e773de2u94c10a8739f4ddf4@mail.gmail.com>
	 (sfid-20080708_142402_544799_C3AAFC88)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-BTeYy4ViqGm9xAHSw1ZE"
Cc: netdev@vger.kernel.org,
	linux-wireless <linux-wireless@vger.kernel.org>
To: Julius Volz <juliusv@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:33772 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbYGHMbU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 08:31:20 -0400
In-Reply-To: <f4845fc0807080523o7e773de2u94c10a8739f4ddf4@mail.gmail.com> (sfid-20080708_142402_544799_C3AAFC88)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BTeYy4ViqGm9xAHSw1ZE
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable


> >>       int idx =3D 0;
> >>       int start =3D cb->args[0];
> >>       struct cfg80211_registered_device *dev;
> >>
> >>       mutex_lock(&cfg80211_drv_mutex);
> >>       list_for_each_entry(dev, &cfg80211_drv_list, list) {
> >> -             if (++idx < start)
> >> +             if (++idx <=3D start)
> >>                       continue;
> >>               if (nl80211_send_wiphy(skb, NETLINK_CB(cb->skb).pid,
> >>                                      cb->nlh->nlmsg_seq, NLM_F_MULTI,
> >> -                                    dev) < 0)
> >> +                                    dev) < 0) {
> >> +                     idx--;
> >>                       break;
> >> +             }
> >
> > I see much of the problem stemming from incrementing 'idx' at the
> > beginning of the loop, can't we just move it to the end?
>=20
> idx still needs to be incremented in the 'continue' case, so that
> alone wouldn't help. I'm not sure if there is a way to make this look
> more intuitive?

Good point. The only ways I can come up with add further to the already
quite deep indentation:

list_for_each_entry(...) {
	if (idx > start)
		if (nl80211_send_wiphy(...) < 0)
			break;
	idx++;
}

or hide the call into an if ():

=EF=BB=BFlist_for_each_entry(...) {
	if (idx > start && nl80211_send_wiphy(...))
		break;
	idx++;
}

Not sure. I guess the code isn't touched often so your patch is fine.

johannes

--=-BTeYy4ViqGm9xAHSw1ZE
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJIc13jAAoJEKVg1VMiehFYIXIP/1e0QoRUKu6kR2afGzgj6k1G
kw2s8DBI9mxa5mR3rExcMbPsJlV6+V/PKZt5IECfx6iT89Srl0grpvd2ctEEQnvT
C5aar1+cl3ZQEGP8Jl8x8xIGNc3cc9h6oKTHFaQ2FUGEZR3s0uOoAR/0PJmXFkA3
qIBn4zdgOCpvcTbpjiuac/jD8oC04RLyeDSgKY+bj5xXEv6WBvV7s8b+1K0bc5OU
ccjm8d4lqp3zt+Iql+6qXiYO2lYZ6xA5RNmDsrM1G8dt5RSSv7SXZsa25Ehgzkw0
eEvF0i4h0okVdWd7FKZnh3LfjWiDB0pgagcM7nGiqj/SjDtVe263kIfgG/R+7lNA
G8QXaNV0YaQv9k+RJJyzhNtK+rlKvXJJwXKbp+oD3YZgt5a0SeLN2PPVAkQZFUts
8jMJljiu7nj2zceQfJzT1IQrPuGRUvwnVQNiNBCcAiXH1ztSjiGNUk9j6lHAFM9x
1TWPZ/tLisG6iOsaHQtPTXp8u/wxmcy9YELbFC9bOQLFCyfdznv68/cJLSN7H1aL
qIghtzKbkiaNjHEP0ZBRDQR73mhsA5KDp1vKXLvE0M7Q0CTM9UOQS2Neggc2KDRk
5D6uP+xJ5KKaLhL5q+LbAVb+sn5fY7WyPKnABsOC5mzghj2aSa1pkNr0lCG8Akw5
5um1GfTZg8xfrf2S7/jN
=C4aF
-----END PGP SIGNATURE-----

--=-BTeYy4ViqGm9xAHSw1ZE--

