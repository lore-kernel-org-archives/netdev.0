From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Mon, 05 Jan 2015 19:57:04 +0100
Message-ID: <1420484224.9459.16.camel@sipsolutions.net>
References: <1420297188.2397.3.camel@tiscali.nl>
	 <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>
	 <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>
	 <1420324124.9624.60.camel@x220> <54AA641C.7050307@broadcom.com>
	 <1420479510.14308.23.camel@x220> (sfid-20150105_183907_807502_81C08416)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Arend van Spriel <arend@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	Kalle Valo <kvalo@codeaurora.org>,
	Jiri Kosina <jkosina@suse.cz>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:55645 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753943AbbAES5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jan 2015 13:57:18 -0500
In-Reply-To: <1420479510.14308.23.camel@x220> (sfid-20150105_183907_807502_81C08416)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-01-05 at 18:38 +0100, Paul Bolle wrote:

> > ipw2200 is a WEXT driver using some wext functionality (and struct 
> > wiphy) provided by cfg80211 hence it needs CFG80211_WEXT. I guess that 
> > is what makes it confusing.
> 
> It doesn't help that I hardly know anything about mac80211, cfg80211 and
> nl80211 (and lib80211 for that matter). To me these are mostly just
> names that end in 80211.

:-)
There isn't really all that much that ipw2x00 is using from cfg80211
though - of note is that it has completely empty ops:

static struct cfg80211_ops libipw_config_ops = { };

IOW - all it does is register with the framework - courtesy of
a3caa99e6c68f. It's practically useless.

> Anyhow, concerning, CFG80211_WEXT: it seems the only functionality
> provided by that symbol that ipw2200 uses directly is
> cfg80211_wext_giwname(). Perhaps ipw2200 could have a private version of
> that function, something like ipw2100's ipw2100_wx_get_name(). Should be
> trivial to implement (ie, it could take _me_ a day or two).

We could just revert that part of the commit above - or even completely.

However, in theory at least doing *that* would now be a userspace
regression - today you can at least discover the presence of ipw2200
devices with nl80211, even if you can't do anything with them that way.

> But perhaps ipw2200 uses CFG80211_WEXT _indirectly_ too. Ie, in
> net/wireless/core.c I stumbled on
>     #ifdef CONFIG_CFG80211_WEXT
>             rdev->wiphy.wext = &cfg80211_wext_handler;
>     #endif

I don't think it does - see the note about the ops above. If it did,
it'd have to implement the ops.

> But I net/wireless/wext-core.c I then found
>     #ifdef CONFIG_CFG80211_WEXT
>             if (dev->ieee80211_ptr && dev->ieee80211_ptr->wiphy)
>                     handlers = dev->ieee80211_ptr->wiphy->wext;
>     #endif
>     #ifdef CONFIG_WIRELESS_EXT
>             if (dev->wireless_handlers)
>                     handlers = dev->wireless_handlers;
>     #endif
> 
> (There's much more to discover about WEXT, of course.) Anyhow, IPW2200
> uses both CFG80211_WEXT and WIRELESS_EXT and cfg80211_wext_handler and
> ipw2200's wireless_handlers appear to cover the same set of IOCTLS (one
> exception: SIOCSIWPMKSA). So by now I'm really puzzled how this all fits
> together.

Well, this was meant as a transition mechanism for drivers. Ultimately,
the way we thought how you'd convert a driver (and how we converted
mac80211) would be to have the wext handlers like for example the scan
ones:

static iw_handler ipw_wx_handlers[] = {
...
        IW_HANDLER(SIOCSIWSCAN, ipw_wx_set_scan),
        IW_HANDLER(SIOCGIWSCAN, ipw_wx_get_scan),
...
};

Then you could make a patch that uses the cfg80211 APIs for scanning in
the driver -- i.e. implement the cfg80211_ops.scan method, report frames
to the cfg80211 scanning and remove all the ieee->network_list stuff
etc. using the related cfg80211 API (e.g. cfg80211_get_bss() and friends
for getting a network, etc.) And then you'd change the handlers to be

static iw_handler ipw_wx_handlers[] = {
...
        IW_HANDLER(SIOCSIWSCAN, cfg80211_wext_siwscan),
        IW_HANDLER(SIOCGIWSCAN, cfg80211_wext_giwscan),
...
};

This part would have to be done in a single patch.

Multiple other groups of ioctls could be converted in similar patches,
until at the end you can completely remove ipw_wx_handlers and rely
entirely on cfg80211's wext compatibility.

So far the theory - in practice nobody cared enough to start working on
any of these drivers, let alone actually has the hardware today.

johannes
