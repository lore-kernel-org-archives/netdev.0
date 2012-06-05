From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Wireless networking without CONFIG_PM..
Date: Tue, 05 Jun 2012 08:28:18 +0200
Message-ID: <1338877698.4514.7.camel@jlt3.sipsolutions.net>
References: <CA+55aFw96wx_Vp_z=H9q=0A-Y8iYD-JJEmYzVPr-BEU6ez5bqA@mail.gmail.com>
	 (sfid-20120605_051012_943406_4BDCE2C0)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: Linus Torvalds <linus971@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:36425 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753251Ab2FEG2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jun 2012 02:28:25 -0400
In-Reply-To: <CA+55aFw96wx_Vp_z=H9q=0A-Y8iYD-JJEmYzVPr-BEU6ez5bqA@mail.gmail.com> (sfid-20120605_051012_943406_4BDCE2C0)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Mon, 2012-06-04 at 20:09 -0700, Linus Torvalds wrote:
> I wonder if anybody has really ever tested that? Because I think it's broken..

Yeah, it is indeed.

> In particular, I made the mistake of not enabling CONFIG_PM on a new
> laptop, and it caused some *seriously* nasty-to-debug problems. The
> mac80211 code goes crazy, that upsets the wireless driver, and then
> the wrieless driver in question had a nasty bug where it would
> double-release its firmware, which then caused vmalloc corruption and
> all kinds of really odd recursive panics etc.

That's pure suck :( I see you already sent a separate patch.

> And as far as I can tell, the root cause of the problem is a bad
> choice in net/mac80211/main.c:
> 
>   int ieee80211_register_hw(struct ieee80211_hw *hw)
>   {
>   ...
>         if ((hw->wiphy->wowlan.flags || hw->wiphy->wowlan.n_patterns)
>   #ifdef CONFIG_PM
>             && (!local->ops->suspend || !local->ops->resume)
>   #endif
>             )
>                 return -EINVAL;
> 
> which means that if the wiphy says it supports wake-on-wireless lan,
> and CONFIG_PM isn't enabled, we'll return -EINVAL and will refuse to
> do any wireless at all.
> 
> It's that a bit extreme? Or outright stupid? What is the advantage of
> saying that "if you don't have CONFIG_PM enabled, we'll just refuse to
> register any hardware that talks about it's wake-on-wireless
> patterns"?
>
> Maybe there is some reason for that return -EINVAL, but I don't think
> it makes sense with that particular placement of #ifdef CONFIG_PM.
> Maybe if the #ifdef was around the whole test? Or maybe it should just
> be removed.

It should just be around the whole test.

> Or am I missing some big reason for why it makes sense to do that? Hmm?

No, not really. It was a case of not wanting to compile suspend/resume
methods when they aren't needed, so they aren't even declared in the ops
struct in that case, and then I forgot about that and when somebody
found it they added the ifdef that way here and clearly only tested
non-WoWLAN devices.

> I'll make a separate bug-report email to the intel iwlwifi people
> about their absolutely horribly broken error handling which then made
> it such a disaster, but I thought I'd bring the generic mac80211 issue
> up. I don't think there are a lot of drivers that do the whole wowlan
> thing, and obviously most people use wireless on laptops where you
> want CONFIG_PM anyway, so it probably hasn't triggered very much.

For the next release I think I'll just put the ifdef around the entire
test to avoid this issue. Overall, I'm still debating whether it makes
sense to leave WoWLAN code and data in when the system will never be
able to suspend, I have a feeling that maybe it doesn't and we should
make it a compile error to even try to access wiphy->wowlan when
CONFIG_PM isn't set ...

Interestingly, none of that would actually matter for iwlwifi in
particular since that has yet another issue -- it only declares
suspend/resume ops when CONFIG_PM_SLEEP is set since WoWLAN doesn't work
in other PM cases, so there the #ifdef CONFIG_PM_SLEEP patch that Sedat
pointed to is actually needed pretty much regardless.

johannes
