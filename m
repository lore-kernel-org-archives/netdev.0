From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates
 [mac80211]
Date: Thu, 28 Jan 2016 21:40:25 +0100
Message-ID: <1454013625.2332.9.camel@sipsolutions.net>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	 <1453983185.2217.12.camel@sipsolutions.net>
	 <CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
	 (sfid-20160128_200137_617680_79F89D8E)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:56994 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161254AbcA1Ukb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Jan 2016 15:40:31 -0500
In-Reply-To: <CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com> (sfid-20160128_200137_617680_79F89D8E)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-01-28 at 11:01 -0800, Linus Torvalds wrote:
>=C2=A0
> I used to have the basic original UniFi UAP. I've replaced them with
> the newer "AC Lite" version:
>=20
> =C2=A0=C2=A0=C2=A0=C2=A0https://www.ubnt.com/unifi/unifi-ap-ac-lite/
>=20
> so it's a fairly big jump from a 2.4GHz-only network to a dual-band
> one.
>=20
> The old 2.4GHz-only AP's showed the problem with minstrel-ht
> incorrectly starting off at the highest rate (on a totally different
> machine). So the Unifi AP's have shown problems in the kernel
> wireless before, but so far it's always been the fault of the kernel
> wireless, not the AP.

Yeah; I wasn't trying to blame it on this change, I was just trying to
understand the change in the environment. Seems likely that it's simply
the switch to 5 GHz, which is strange, I'd have thought that even that
rtlwifi driver would've been tested with that :)

> > Could you print out the entire table there when the warning
> > happens?
>=20
> This is the best I can come up with: printing out the index, and the
> rate and bitrate tables:
>=20
> =C2=A0 rates[i].idx (9) >=3D sband->n_bitrates (8)
> =C2=A0 Rates:
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00: idx 9 count 1 flags a0
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01: idx 8 count 1 flags a0
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02: idx 7 count 2 flags a0
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A03: idx 6 count 3 flags a0

Yeah, perfect. See, this is already evidently not making any sense:

flags a0 is
IEEE80211_TX_RC_40_MHZ_WIDTH |=C2=A0IEEE80211_TX_RC_SHORT_GI

both of those options *require*=C2=A0IEEE80211_TX_RC_MCS or
IEEE80211_TX_RC_VHT_MCS as well, so the flags really should be a8 or
1a0.

> =C2=A0 Bitrates:
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A00: flags 00000002 bitrate 60 (hw:=
 0004 0000)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A01: flags 00000000 bitrate 90 (hw:=
 0005 0000)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A02: flags 00000002 bitrate 120 (hw=
: 0006 0000)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A03: flags 00000000 bitrate 180 (hw=
: 0007 0000)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A04: flags 00000002 bitrate 240 (hw=
: 0008 0000)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A05: flags 00000000 bitrate 360 (hw=
: 0009 0000)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A06: flags 00000000 bitrate 480 (hw=
: 000a 0000)
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A07: flags 00000000 bitrate 540 (hw=
: 000b 0000)
>=20
> So it's the very first rate that has index 9, but the bitrate table
> only goes from 0-7.
>=20
> So I suspect that once the first index has been marked invalid, it
> now will never even look at the later indices, so it has no transmit
> rates at all.=C2=A0=C2=A0Or something.

Indeed.

> That bitrate table does seem to match:
>=20
> =C2=A0=C2=A0=C2=A0static struct ieee80211_rate rtl_ratetable_5g[] =3D=
 {
>=20
> in drivers/net/wireless/realtek/rtlwifi/base.c
>=20

Yeah, it would, but it's irrelevant since the rate table isn't actually
used with MCS rates.

I'm not familiar with this code at all, but looking at it suggests that
perhaps the switch to 5 GHz wasn't at fault, but instead the switch to
VHT (802.11ac) - that's more plausible too, not testing with VHT seems
like something that could have happened for this driver.

And as I figured, the code in _rtl_rc_rate_set_series() is obviously
not handling VHT correctly: it has

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (sgi_20 || s=
gi_40 || sgi_80)
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
rate->flags |=3D IEEE80211_TX_RC_SHORT_GI;
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0if (sta && sta->ht_cap.ht_supported &&
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0((wireless_mode =3D=3D =
WIRELESS_MODE_N_5G) ||
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(wireless_mode =3D=
=3D WIRELESS_MODE_N_24G)))
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
rate->flags |=3D IEEE80211_TX_RC_MCS;

but can never set IEEE80211_TX_RC_VHT_MCS. Seems like there should be
something like

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (sta && sta-=
>ht_cap.vht_supported &&
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0(wireless_mode =3D=3D W=
IRELESS_MODE_AC_5G ||
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0wireless_mode =3D=3D WIRELESS_MODE_AC_24G ||
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0wireless_mode =3D=3D WIRELESS_MODE_AC_ONLY))
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=
rate->flags |=3D IEEE80211_TX_RC_VHT_MCS;

just after/before the above block.

But I'm not familiar with this code at all, so that may not really be
the right fix or even work.

johannes
