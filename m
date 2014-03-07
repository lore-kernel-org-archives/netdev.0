From: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>
Subject: Re: [Linux-zigbee-devel] Simplifying the 802.15.4 stack
Date: Fri, 7 Mar 2014 22:49:28 +0100
Message-ID: <8b7437e4d68b3f96e010ad47f6aa530d.squirrel@webmail.itwm.fhg.de>
References: <20140307133924.21165955@zoidberg> <20140307193820.GA25736@ws>
Reply-To: phoebe.buckheister@itwm.fraunhofer.de
Mime-Version: 1.0
Content-Type: text/plain;charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "Phoebe Buckheister" <phoebe.buckheister@itwm.fraunhofer.de>,
	linux-zigbee-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>
To: "Werner Almesberger" <werner@almesberger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw1.uni-kl.de ([131.246.120.220]:37219 "EHLO
	mailgw1.uni-kl.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751365AbaCGVuT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 16:50:19 -0500
Received: from itwm2.itwm.fhg.de (itwm2.itwm.fhg.de [131.246.191.3])
	by mailgw1.uni-kl.de (8.14.3/8.14.3/Debian-9.4) with ESMTP id s27LoGCs005754
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 7 Mar 2014 22:50:16 +0100
In-Reply-To: <20140307193820.GA25736@ws>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, March 7, 2014 8:38 pm, Werner Almesberger wrote:
>> 1) header handling in the stack
>> 2) endianness in the stack
>
> I don't care much about these, but jumping between byte orders is
> certainly confusing. As long as an API user can tell easily and
> unambiguously what was or will be in the air, I won't complain.

I'm not so sure that API users can tell, especially since even within the
sockaddr struct we have differing byte orders for different fields. At
least *that* should be consistent, even if only in itself and not with
what the stack uses internally.

>> 3) the mac802154_priv slave list
>
> Yes, weird and of dubious use. Ironically, support for the only
> piece of code that could have a chance to actually use this
> without devastation - the coordinator - was dropped when 802.15.4
> support originally went mainline.
>
> And even if someone was to resurrect the coordinator and made it
> multi-PAN, there are probably easier ways to accomplish all that.

Precisely. The coordinator is also *much* better of setting parameters via
netlink that would have otherwise been set implicitly. Changing specific
WPANs via a packet imposes all the possible delays and reorderings a qdisc
can cause, and that's most certainly not what a coordinator wants, and
it's also completely impossible to change some parameters like that (see
below).

> So I don't see a problem with this sort of change, as long as
> there is some way to set up the matching rules of 802.15.4-2011
> section 5.1.6.2 (page 42), specifically the broadcast PAN ID
> match.

That would still be possible, of course. Hardware will hand either all
packets up the stack, which can then easily be filtered, or hardware
supports its own address filtering and hands over only matching packets.
Currently, we do a mixture of both, and if someone uses the slaves feature
to set up multiple interface with different PAN IDs, we do hardware
address filtering wrong. Implicit specific WPAN switching changes only
channel and page, and nothing else, making the slaves even more harmful.

> This API has of course a non-negligible installed base since the
> administrative tools touch it and everyone who uses 802.15.4 in
> any way, including through 6LoWPAN, has to use the administrative
> tools.
>
> But then that very same installed base barely noticed that a few
> months ago not even a ping really worked, so I wouldn't be overly
> concerned about continuity.

6lowpan was broken for basically everything until Alex fixed it. Perhaps
the raw/dgram sockets worked fine all the time (I haven't used them much
yet). But then you can hand a MTU-sized packet to a dgram socket, which
might - depending on the driver - either silently truncate the frame,
report success and not transmit it at all, or do even wilder things ...

> In practical terms, it will be impossible to perfectly synchronize
> kernel API changes and user space tools or documentation. Thus,
> the sooner the change is made, the better.

To my understanding, the current API to the stack isn't even exposed to
userspace. It lives entirely in include/net, and all users I know of
(which is exactly lowpan-tools and my local wpan manager daemon) copy
headers from the kernel to have at least *some* definitions to use. As
such, I would consider those users at the mercy of whoever or whatever
might change those headers.

> Furthermore, if you could think of a way to preserve the old API
> for a while, possibly reduced to just supporting the only
> real-life case of having exactly one slave, that would ease the
> transition.

We could easily keep LIST_PHY for a while, let ADD_IFACE work *exactly*
once and DEL_IFACE not at all. That's not exactly preserving the API, but
it is the closest thing to preserving the API I can currently think of.
Removing the slaves is such an intrusive change that all API compatibility
will break at first or second poke, just like 6lowpan has for years -
ADD_IFACE for example would effectively be only a rename, and for
compatibility with LIST_PHY, we'd have to keep the old name around. I'd
rather not do that if the interface handling is fundamentally incompatible
with the old way anyway.

>> 4) our *drivers* are expected to *sleep*
>
> Linux has a perfectly good network device API that avoids such
> perversions and also has a sane concept of flow control. Making
> 802.15.4 use that API will of course break every existing
> 802.15.4 driver, but there are few enough of them in mainline and
> probably not a lot in active use out of mainline.

That's the funny thing. mac802154 disables/enables all netdev queues on a
phy before/after every TX action.

> Specifically, we have in mainline:
>
> - at86rf230.c which you are using yourself, so I'd assume you'd
>   adapt is when such a change is made,

Yes, though the driver change is not actually one of priorities at the
moment since it does "just work". It is freakishly ugly, but it works for
everything I've yet thrown at it.

> Maybe one could also come up with a smooth transition strategy for
> the driver API change, but I'd be careful not to waste time going
> through the motions if nobody really needs that.

That's will most likely force us to keep the workqueues, or queue the
RX/TX actions to the system queues and suffer from even more latencies
(possibly). I suppose it's possible to add a start_xmit to struct
ieee802154_ops and entirely rip out the mac802154 workqueues, running
driver that have only xmit

> So to gauge the impact of the changes you're proposing, we'd need
> to know:
>
> 1) whether there are any major users of AF_IEEE802154 (if you're
>    planning to change that API),

I want to change that, yes, but it's not hugely important for
AF_IEEE802154. The address format can stay as weird as it is now without
actively harming anybody.

> 2) whether anyone depends on the 802.15.4 administrative interface
>    beyond having compiled a variant of
>    http://sourceforge.net/apps/trac/linux-zigbee/wiki/GettingStarted-0.2

I would almost assume that not, and if so, be inclined to not care a lot
about those users since they too will have taken kernel definitions that
weren't actually exposed to userspace at any point. Also, since that guide
mentions mainly 6lowpan for anything other than the primitive chat thingy,
I'm inclined to believe that virtually nobody has ever gotten even that
far.

> 3) and whether there are any other 802.15.4 device drivers in active
>    use with recent kernels besides the ones I mentioned above.

I'm tempted to say "someone else's problem", but that won't help anyone in
the long run. Let's hope that anybody using such drivers reads this thread
and will reply ...

> I don't think the sleepy driver API change needs to happen at the
> same time as the rest so it may make sense to do all this in at
> least two phases.

Yes. What's really pressing is the slave list disaster and the netlink
APIs that concern themselves with it.

> This brings us to the next question: when do you plan to do all
> this ? :)

During some office hours and whatever time outside of office hours I want
to  dedicate to that task ;) My current priorities actually lie on
implementing link-layer security and what netlink APIs that requires,
which is at least partially done by now - so I might actually have time to
this not solely in my free time in the nearer future.
