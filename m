From: "Luis R. Rodriguez" <mcgrof-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [regression] ath5k: Overrides regulatory domain set for cfg80211
Date: Wed, 8 Jul 2009 15:08:24 -0700
Message-ID: <43e72e890907081508n6fa5781an1dcbda078efc5379@mail.gmail.com>
References: <200907082340.07787.elendil@planet.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Frans Pop <elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <200907082340.07787.elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 8, 2009 at 2:40 PM, Frans Pop<elendil-EIBgga6/0yRmR6Xm/wNWPw@public.gmane.org> wrote:
> In /etc/modprobe.d I have a file containing:
> options cfg80211 ieee80211_regdom=3DEU
>
> During boot this results in:
> <snip>
> cfg80211: Using static regulatory domain info
> cfg80211: Regulatory domain: EU
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(start_freq - end_freq @ bandwidth), (max_=
antenna_gain, max_eirp)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(2402000 KHz - 2482000 KHz @ 40000 KHz), (=
600 mBi, 2000 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5170000 KHz - 5190000 KHz @ 40000 KHz), (=
600 mBi, 2300 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5190000 KHz - 5210000 KHz @ 40000 KHz), (=
600 mBi, 2300 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5210000 KHz - 5230000 KHz @ 40000 KHz), (=
600 mBi, 2300 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5230000 KHz - 5330000 KHz @ 40000 KHz), (=
600 mBi, 2000 mBm)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0(5490000 KHz - 5710000 KHz @ 40000 KHz), (=
600 mBi, 3000 mBm)
> cfg80211: Calling CRDA for country: EU
> </snip>
>
> But with 2.6.31-rc2 I then get (the lines marked with "!" are not the=
re
> with .30):
> <snip>
> =C2=A0ath5k 0000:02:00.0: enabling device (0000 -> 0002)
> =C2=A0ath5k 0000:02:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
> =C2=A0ath5k 0000:02:00.0: registered as 'phy0'
> ! ath: EEPROM regdomain: 0x30
> ! ath: EEPROM indicates we should expect a direct regpair map
> ! ath: Country alpha2 being used: AM
> ! ath: Regpair used: 0x30
> =C2=A0phy0: Selected rate control algorithm 'minstrel'
> =C2=A0ath5k phy0: Atheros AR5213A chip found (MAC: 0x59, PHY: 0x43)
> =C2=A0ath5k phy0: RF2112B 2GHz radio found (0x46)
> ! cfg80211: Calling CRDA for country: AM
> </snip>
>
> So it looks

*looks*

> as if ath5k has started to override the regdomain I want.

It looks as if, but you a few things you should be aware of.

=46irst, its not that anything is being ignored, user input is always
welcomed to help compliance you are just using a wrong ISO-3166
alpha2.

EU is not a country and as such is only left on older kernels with
CONFIG_WIRELESS_OLD_REGULATORY  enabled. So "EU" is deprecated for non
CONFIG_WIRELESS_OLD_REGULATORY based kernels now. For further
information please also read
Documentation/feature-removal-schedule.txt. Please use a valid
ISO-3166 alpha2 country code, I also advise to abandon the usage of
the ieee80211_regdom module parameter which we do eventually intend on
deprecating and if you know anyone using that please suggest the same.

Eventually, as you will read from the feature-removal schedule, we
intend on getting the Linux desktop to provide automatic hints of the
user's location through things like GeoClue. Reason for removing the
module parameter is its not the proper way to pass information to the
kernel, we now have a netlink interface for this exact purpose. Until
the desktop catches up we'll keep the ieee80211_regdom module
parameter, but the proper new way to set your regulatory domain as a
user is through iw [1] which does use netlink. Some distributions
(like Fedora) automatically set your country based on the timezone
information. So in the end you should not have to do this at all as a
user.

Another thing you should note is that if a driver has a regulatory
domain hint then the driver regulatory domain is always trusted, users
can *further* help compliance by selecting their country. What this
means since Atheros drivers do have EEPROM reading for the regulatory
domain that will be used first, thus enabling only channels allowed by
the programmed EEPROM. A user input can then only disable channel, but
never enable new ones. For devices with no regulatory at all the user
can have more of a say as no driver regulatory hint is available but
by default, in the absence of a driver regulatory hint, we world roam.

[1] http://wireless.kernel.org/en/users/Documentation/iw

  Luis
--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
