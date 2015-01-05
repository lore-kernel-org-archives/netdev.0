From: Arend van Spriel <arend@broadcom.com>
Subject: Re: [PATCH] Revert "ipw2200: select CFG80211_WEXT"
Date: Mon, 5 Jan 2015 19:22:52 +0100
Message-ID: <54AAD67C.7090900@broadcom.com>
References: <1420297188.2397.3.camel@tiscali.nl>	 <CD467A59-F563-439B-BA82-954AB27AD9CC@holtmann.org>	 <CA+55aFzYSiUkntraMrHEhMzkt35Ft2p9E3cT7ejwQOBDwKvcOg@mail.gmail.com>	 <1420324124.9624.60.camel@x220> <54AA641C.7050307@broadcom.com> <1420479510.14308.23.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Stanislav Yakovlev <stas.yakovlev@gmail.com>,
	"Kalle Valo" <kvalo@codeaurora.org>, Jiri Kosina <jkosina@suse.cz>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Paul Bolle <pebolle@tiscali.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1420479510.14308.23.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 01/05/15 18:38, Paul Bolle wrote:
> On Mon, 2015-01-05 at 11:14 +0100, Arend van Spriel wrote:
>> On 01/03/15 23:28, Paul Bolle wrote:
>>> Side note: am I correct in thinking that there's some successor to
>>> CFG80211_WEXT and that the ipw2200 driver could, at least in theory, be
>>> ported to that successor? (ipw2200 hardware appears to be a bit old, so
>>> probably no one would care enough to actually do that.)
>>> net/wireless/kconfig doesn't mention anything like that, so probably I'm
>>> just confused.
>>
>> ipw2200 is a WEXT driver using some wext functionality (and struct
>> wiphy) provided by cfg80211 hence it needs CFG80211_WEXT. I guess that
>> is what makes it confusing.
>
> It doesn't help that I hardly know anything about mac80211, cfg80211 and
> nl80211 (and lib80211 for that matter). To me these are mostly just
> names that end in 80211.

Grapjas ;-)

cfg80211 provides thin-layer API for fullmac drivers (running 802.11 
stack on the device) and mac80211-based drivers (running 802.11 stack in 
kernel).

> Anyhow, concerning, CFG80211_WEXT: it seems the only functionality
> provided by that symbol that ipw2200 uses directly is
> cfg80211_wext_giwname(). Perhaps ipw2200 could have a private version of
> that function, something like ipw2100's ipw2100_wx_get_name(). Should be
> trivial to implement (ie, it could take _me_ a day or two).

Indeed or even an hour or two.

> But perhaps ipw2200 uses CFG80211_WEXT _indirectly_ too. Ie, in
> net/wireless/core.c I stumbled on
>      #ifdef CONFIG_CFG80211_WEXT
>              rdev->wiphy.wext =&cfg80211_wext_handler;
>      #endif

This is the "wext compatibility" being enabled for any cfg80211 or 
mac80211 based driver.

>
> But I net/wireless/wext-core.c I then found
>      #ifdef CONFIG_CFG80211_WEXT
>              if (dev->ieee80211_ptr&&  dev->ieee80211_ptr->wiphy)
>                      handlers = dev->ieee80211_ptr->wiphy->wext;
>      #endif

wext-core is the WEXT framework and here it extracts WEXT handlers from 
a cfg80211/mac80211-based driver that are store in wiphy structure.

>      #ifdef CONFIG_WIRELESS_EXT
>              if (dev->wireless_handlers)
>                      handlers = dev->wireless_handlers;
>      #endif

Here wext-core extracts WEXT handlers from a WEXT driver. struct 
net_device::wireless_handlers is only defined for CONFIG_WIRELESS_EXT.

> (There's much more to discover about WEXT, of course.) Anyhow, IPW2200
> uses both CFG80211_WEXT and WIRELESS_EXT and cfg80211_wext_handler and
> ipw2200's wireless_handlers appear to cover the same set of IOCTLS (one
> exception: SIOCSIWPMKSA). So by now I'm really puzzled how this all fits
> together.

I think ipw2200 is a bit of both worlds indeed adopting the use of 
struct wiphy and wiphy_register() call. That seems to suggest it is a 
cfg80211 driver, but it does not register any cfg80211 driver callbacks 
(see libipw_config_ops in libipw_module.c). So it overrides the WEXT 
ioctls because it needs that to interact with the device.

Regards,
Arend

> Thanks,
>
>
> Paul Bolle
>
