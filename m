From: Kalle Valo <kalle.valo@iki.fi>
Subject: Re: [PATCH 0/2] cfg80211: firmware and hardware version
Date: Thu, 01 Oct 2009 19:20:09 +0300
Message-ID: <873a63qe6e.fsf@purkki.valot.fi>
References: <20090924180048.14503.9579.stgit@tikku>
	<43e72e890909241320j592e347die8a14f8bdd962ffb@mail.gmail.com>
	<20090925044258.GA2722@tuxdriver.com>
	<da94abde0909250947k5084db85vccafe0d3e74e2ecf@mail.gmail.com>
	<43e72e890909250953r1714c79bsa679b96ca6f5797@mail.gmail.com>
	<20091001011340.GA3123@tuxdriver.com> <87fxa3qjt2.fsf@purkki.valot.fi>
	<20091001151820.GA2895@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Luis R. Rodriguez" <mcgrof@gmail.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.25]:58482 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753597AbZJAQUJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 12:20:09 -0400
In-Reply-To: <20091001151820.GA2895@tuxdriver.com> (John W. Linville's message of "Thu\, 1 Oct 2009 11\:18\:20 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

"John W. Linville" <linville@tuxdriver.com> writes:

> On Thu, Oct 01, 2009 at 05:18:33PM +0300, Kalle Valo wrote:
>> 
>> I'm not worried about the implementation complexity, and as your
>> patches show it was easy. My concern is the overall design for
>> wireless devices. Instead of using nl80211 for everything, with some
>> features we would use nl80211/iw and with some ethtool. That's just
>> confusing and I don't like that. I would prefer that nl80211 provides
>> everything, it makes things so much easier.
>
> Well, if the hw/fw version numbers were the only thing then I'd
> probably say it's not a big deal.  But having ethtool support is nice
> in that it makes a familiar tool work for us.  Among other things,
> this probably helps with some distro scripts that don't work quite
> right without it.  Plus, there is lots of debugging stuff that could
> be turned-on without having to write new tools.

Agreed, maybe expect the distro scripts part. To me that just sounds
as a bug in the scripts.

> I suppose I understand the 'one API' idea, but why duplicate
> functionality?

Just because the common functionality in this case isn't high enough.
I'm worried that we will use 10% of the functionality in nl80211 and
the rest 90% will be something we can't use and have to reimplement in
nl80211.

> Anyway, adding a couple of ioctl calls isn't a big deal.

Sure, but we need to support this forever. If, say after two years, we
decide that ethtool is not the way to go, it's very difficult to
remove it. The less interfaces we have, the easier it is to maintain
them.

> And don't forget, we are still network drivers too...

I hope ethtool isn't a strict requirement for a network driver, at
least I haven't heard about that.

>> One example is the hw version, ethtool only provides u32 to userspace
>> and moves the burden of translating hw id to the user. For us a string
>> is much better choise because when debuggin we need to often (or
>> always?) know the chip version.
>
> Look at the way most drivers set the version (using each byte as a
> field).

Yes, that's how it is also with wl1251. A number like '0x7030101' is
just not that user friendly.

> If you want prettier output, adding a parser to the userland ethtool
> is fairly trivial. It looks something like the patch below...

Oh wow, that's cool and a truly useful feature. One complaint less
from me :)

>>         ethtool -c|--show-coalesce DEVNAME      Show coalesce options
>>         ethtool -C|--coalesce DEVNAME   Set coalesce options
>>                 [adaptive-rx on|off]
>>                 [adaptive-tx on|off]
>>                 [rx-usecs N]
>>                 [rx-frames N]
>>                 [rx-usecs-irq N]
>>                 [rx-frames-irq N]
>>                 [tx-usecs N]
>>                 [tx-frames N]
>>                 [tx-usecs-irq N]
>>                 [tx-frames-irq N]
>>                 [stats-block-usecs N]
>>                 [pkt-rate-low N]
>>                 [rx-usecs-low N]
>>                 [rx-frames-low N]
>>                 [tx-usecs-low N]
>>                 [tx-frames-low N]
>>                 [pkt-rate-high N]
>>                 [rx-usecs-high N]
>>                 [rx-frames-high N]
>>                 [tx-usecs-high N]
>>                 [tx-frames-high N]
>>                 [sample-interval N]
>
> These _could_ be useful if wireless becomes more
> performance-oriented...

Maybe, or maybe not. We will only find out within the next few years.

And what will we do if the parameters are actually a bit different? Is
it ok to extend ethtool for supporting wireless or do we later on have
to add separate support to nl80211? The latter would suck big time.

>>         ethtool -g|--show-ring DEVNAME  Query RX/TX ring parameters
>>         ethtool -G|--set-ring DEVNAME   Set RX/TX ring parameters
>>                 [ rx N ]
>>                 [ rx-mini N ]
>>                 [ rx-jumbo N ]
>>                 [ tx N ]
>
> Wireless devices have ring buffers, no?

Yes, there is hardware which have them but again the question is this
relevant for wireless devices. In ethernet the hardware is the
bottleneck but in 802.11 the wireless medium is the bottleneck, so the
parameters we need to configure are usually different.

>>         ethtool -r|--negotiate DEVNAME  Restart N-WAY negotation
>
> Ethernet-specific...might could be overloaded for wireless to trigger
> reassoc...?

Please no, I don't want to see any reassociation or anything else
802.11 state related in ethtool, nl80211 was created for this. This is
something I would object loudly :)

> Anyway, it doesn't really matter if we don't use the whole API -- many
> older ethernet devices don't support all these features.  The point
> is that the API exists and has some overlap with our needs.  It is a
> driver-oriented API, with nitty-gritty stuff that need not clutter a
> configuraiton API like cfg80211.  There is even the potential of us
> adding our own extensions (e.g. WoW) that are also device-oriented.
>
> Anyway, between the link detection and making distro scripts work
> plus enabling a familiar tool for basic driver info I think this is
> a win.  So much the better if some drivers move to ethtool for register
> dumping, setting message verbosity, querying/changing eeprom values,
> etc, etc...

Sounds good enough. As I said in my earlier email, I'm not going argue
about this for too long. You know this better than I do. So let's go
forward with ethtool. 

Thanks for listening to my concerns.

-- 
Kalle Valo
