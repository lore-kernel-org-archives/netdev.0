From: Sedat Dilek <sedat.dilek@googlemail.com>
Subject: Re: Wireless networking without CONFIG_PM..
Date: Tue, 5 Jun 2012 07:50:54 +0200
Message-ID: <CA+icZUVu-PNAgna2aoEV78GPK6Fa9PJSDQu1e3-OzvU6v9-UzQ@mail.gmail.com>
References: <CA+55aFw96wx_Vp_z=H9q=0A-Y8iYD-JJEmYzVPr-BEU6ez5bqA@mail.gmail.com>
Reply-To: sedat.dilek@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <linus971@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:63555 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365Ab2FEFuz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 01:50:55 -0400
In-Reply-To: <CA+55aFw96wx_Vp_z=H9q=0A-Y8iYD-JJEmYzVPr-BEU6ez5bqA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 5, 2012 at 5:09 AM, Linus Torvalds <linus971@gmail.com> wro=
te:
> I wonder if anybody has really ever tested that? Because I think it's=
 broken..
>
> In particular, I made the mistake of not enabling CONFIG_PM on a new
> laptop, and it caused some *seriously* nasty-to-debug problems. The
> mac80211 code goes crazy, that upsets the wireless driver, and then
> the wrieless driver in question had a nasty bug where it would
> double-release its firmware, which then caused vmalloc corruption and
> all kinds of really odd recursive panics etc.
>
> And as far as I can tell, the root cause of the problem is a bad
> choice in net/mac80211/main.c:
>
> =C2=A0int ieee80211_register_hw(struct ieee80211_hw *hw)
> =C2=A0{
> =C2=A0...
> =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((hw->wiphy->wowlan.flags || hw->wiphy-=
>wowlan.n_patterns)
> =C2=A0#ifdef CONFIG_PM
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0&& (!local->ops->suspend || =
!local->ops->resume)
> =C2=A0#endif
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0)
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0return -EINVAL=
;
>
> which means that if the wiphy says it supports wake-on-wireless lan,
> and CONFIG_PM isn't enabled, we'll return -EINVAL and will refuse to
> do any wireless at all.
>
> It's that a bit extreme? Or outright stupid? What is the advantage of
> saying that "if you don't have CONFIG_PM enabled, we'll just refuse t=
o
> register any hardware that talks about it's wake-on-wireless
> patterns"?
>
> Maybe there is some reason for that return -EINVAL, but I don't think
> it makes sense with that particular placement of #ifdef CONFIG_PM.
> Maybe if the #ifdef was around the whole test? Or maybe it should jus=
t
> be removed.
>
> Or am I missing some big reason for why it makes sense to do that? Hm=
m?
>
> I'll make a separate bug-report email to the intel iwlwifi people
> about their absolutely horribly broken error handling which then made
> it such a disaster, but I thought I'd bring the generic mac80211 issu=
e
> up. I don't think there are a lot of drivers that do the whole wowlan
> thing, and obviously most people use wireless on laptops where you
> want CONFIG_PM anyway, so it probably hasn't triggered very much.
>
> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0Linus

Sounds like you have hit...

"[PATCH 3.5 v2] iwlwifi: disable WoWLAN if !CONFIG_PM_SLEEP"
http://www.spinics.net/lists/linux-wireless/msg91308.html

- Sedat -
