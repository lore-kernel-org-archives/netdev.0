From: Linus Torvalds <linus971@gmail.com>
Subject: Wireless networking without CONFIG_PM..
Date: Mon, 4 Jun 2012 20:09:51 -0700
Message-ID: <CA+55aFw96wx_Vp_z=H9q=0A-Y8iYD-JJEmYzVPr-BEU6ez5bqA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>,
	Johannes Berg <johannes@sipsolutions.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:58775 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757857Ab2FEDKN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 23:10:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wonder if anybody has really ever tested that? Because I think it's broken..

In particular, I made the mistake of not enabling CONFIG_PM on a new
laptop, and it caused some *seriously* nasty-to-debug problems. The
mac80211 code goes crazy, that upsets the wireless driver, and then
the wrieless driver in question had a nasty bug where it would
double-release its firmware, which then caused vmalloc corruption and
all kinds of really odd recursive panics etc.

And as far as I can tell, the root cause of the problem is a bad
choice in net/mac80211/main.c:

  int ieee80211_register_hw(struct ieee80211_hw *hw)
  {
  ...
        if ((hw->wiphy->wowlan.flags || hw->wiphy->wowlan.n_patterns)
  #ifdef CONFIG_PM
            && (!local->ops->suspend || !local->ops->resume)
  #endif
            )
                return -EINVAL;

which means that if the wiphy says it supports wake-on-wireless lan,
and CONFIG_PM isn't enabled, we'll return -EINVAL and will refuse to
do any wireless at all.

It's that a bit extreme? Or outright stupid? What is the advantage of
saying that "if you don't have CONFIG_PM enabled, we'll just refuse to
register any hardware that talks about it's wake-on-wireless
patterns"?

Maybe there is some reason for that return -EINVAL, but I don't think
it makes sense with that particular placement of #ifdef CONFIG_PM.
Maybe if the #ifdef was around the whole test? Or maybe it should just
be removed.

Or am I missing some big reason for why it makes sense to do that? Hmm?

I'll make a separate bug-report email to the intel iwlwifi people
about their absolutely horribly broken error handling which then made
it such a disaster, but I thought I'd bring the generic mac80211 issue
up. I don't think there are a lot of drivers that do the whole wowlan
thing, and obviously most people use wireless on laptops where you
want CONFIG_PM anyway, so it probably hasn't triggered very much.

                  Linus
