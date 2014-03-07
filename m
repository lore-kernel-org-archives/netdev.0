From: Werner Almesberger <werner@almesberger.net>
Subject: Re: [Linux-zigbee-devel] Simplifying the 802.15.4 stack
Date: Fri, 7 Mar 2014 16:38:20 -0300
Message-ID: <20140307193820.GA25736@ws>
References: <20140307133924.21165955@zoidberg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-zigbee-devel@lists.sourceforge.net,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Phoebe Buckheister <phoebe.buckheister@itwm.fraunhofer.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host.almesberger.net ([204.10.140.10]:45776 "EHLO
	host.almesberger.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751011AbaCGTug (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Mar 2014 14:50:36 -0500
Content-Disposition: inline
In-Reply-To: <20140307133924.21165955@zoidberg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phoebe Buckheister wrote:
> the 802.15.4/6LoWPAN stack on Linux is pretty usable as it is now, much
> due to the recent 6lowpan fixes by Alex.

Indeed, thanks to the work both of you did !

Regarding the proposed massive changes, I think everyone who had
a closer look at the stack knows that (too) much of it is still a
smoldering mess, and that most of the remaining problems are
caused by design issues that also touch APIs.

> 1) header handling in the stack
> 2) endianness in the stack

I don't care much about these, but jumping between byte orders is
certainly confusing. As long as an API user can tell easily and
unambiguously what was or will be in the air, I won't complain.

> 3) the mac802154_priv slave list

Yes, weird and of dubious use. Ironically, support for the only
piece of code that could have a chance to actually use this
without devastation - the coordinator - was dropped when 802.15.4
support originally went mainline.

And even if someone was to resurrect the coordinator and made it
multi-PAN, there are probably easier ways to accomplish all that.
So I don't see a problem with this sort of change, as long as
there is some way to set up the matching rules of 802.15.4-2011
section 5.1.6.2 (page 42), specifically the broadcast PAN ID
match.

This API has of course a non-negligible installed base since the
administrative tools touch it and everyone who uses 802.15.4 in
any way, including through 6LoWPAN, has to use the administrative
tools.

But then that very same installed base barely noticed that a few
months ago not even a ping really worked, so I wouldn't be overly
concerned about continuity.

In practical terms, it will be impossible to perfectly synchronize
kernel API changes and user space tools or documentation. Thus,
the sooner the change is made, the better.

Furthermore, if you could think of a way to preserve the old API
for a while, possibly reduced to just supporting the only
real-life case of having exactly one slave, that would ease the
transition.

This leads us to the heart of evil, ...

> 4) our *drivers* are expected to *sleep*

Linux has a perfectly good network device API that avoids such
perversions and also has a sane concept of flow control. Making
802.15.4 use that API will of course break every existing
802.15.4 driver, but there are few enough of them in mainline and
probably not a lot in active use out of mainline.

Specifically, we have in mainline:

- at86rf230.c which you are using yourself, so I'd assume you'd
  adapt is when such a change is made,
- mrf24j40.c by Alan Ott. Not sure what he thinks of the idea,
- fake*.c which should be fairly straightforward to adapt,

Outside mainline I know of atben which reuses at86rf230, so there
is nothing to do there, and atusb, which I'll be happy to adapt
(and should finally beat into shape for mainline anyway.)

Maybe one could also come up with a smooth transition strategy for
the driver API change, but I'd be careful not to waste time going
through the motions if nobody really needs that.


So to gauge the impact of the changes you're proposing, we'd need
to know:

1) whether there are any major users of AF_IEEE802154 (if you're
   planning to change that API),

2) whether anyone depends on the 802.15.4 administrative interface
   beyond having compiled a variant of
   http://sourceforge.net/apps/trac/linux-zigbee/wiki/GettingStarted-0.2

3) and whether there are any other 802.15.4 device drivers in active
   use with recent kernels besides the ones I mentioned above.

I don't think the sleepy driver API change needs to happen at the
same time as the rest so it may make sense to do all this in at
least two phases.

This brings us to the next question: when do you plan to do all
this ? :)

- Werner
