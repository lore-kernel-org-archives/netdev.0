From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [patch net-next 0/9] Introduce devlink interface and first
 drivers to use it
Date: Tue, 23 Feb 2016 09:34:19 -0500
Message-ID: <20160223143418.GQ33942@gospo.home.greyhouse.net>
References: <1456165924-14399-1-git-send-email-jiri@resnulli.us>
 <20160223051214.GP33942@gospo.home.greyhouse.net>
 <20160223073203.GA2140@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, idosch@mellanox.com,
	eladr@mellanox.com, yotamg@mellanox.com, ogerlitz@mellanox.com,
	yishaih@mellanox.com, dledford@redhat.com, sean.hefty@intel.com,
	hal.rosenstock@gmail.com, eugenia@mellanox.com,
	roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
	hadarh@mellanox.com, jhs@mojatatu.com, john.fastabend@gmail.com,
	jeffrey.t.kirsher@intel.com, brouer@redhat.com, ivecera@redhat.com,
	rami.rosen@intel.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f175.google.com ([209.85.161.175]:35308 "EHLO
	mail-yw0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752839AbcBWOeX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2016 09:34:23 -0500
Received: by mail-yw0-f175.google.com with SMTP id g127so147785394ywf.2
        for <netdev@vger.kernel.org>; Tue, 23 Feb 2016 06:34:23 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160223073203.GA2140@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 23, 2016 at 08:32:03AM +0100, Jiri Pirko wrote:
> Tue, Feb 23, 2016 at 06:12:15AM CET, gospo@cumulusnetworks.com wrote:
> >On Mon, Feb 22, 2016 at 07:31:55PM +0100, Jiri Pirko wrote:
> >> From: Jiri Pirko <jiri@mellanox.com>
> >> 
> >> There a is need for some userspace API that would allow to expose things
> >> that are not directly related to any device class like net_device of
> >> ib_device, but rather chip-wide/switch-ASIC-wide stuff.
> >> 
> >> Use cases:
> >> 1) get/set of port type (Ethernet/InfiniBand)
> >> 2) setting up port splitters - split port into multiple ones and squash again,
> >>    enables usage of splitter cable
> >> 3) setting up shared buffers - shared among multiple ports within
> >>    one chip (work in progress)
> >> 4) configuration of switch wide properties - resources division etc - This will
> >>    allow to pass configuration that is unacceptable to be passed as
> >>    a module option.
> >
> >I'm generally a fan of use cases #3 and #4 (as we have previously
> >discussed), but I'm not sure I agree that the implementation for #2
> >right now.
> >
> >I'm not sure I would like userspace to have control over whether or not
> >a port should be split or not when the hardware can be queried to
> >determine this.
> 
> I was thinking about this myself for a long time and initially it made
> more sense to me the approach you are suggesting. But after lot of
> thining, I saw a lot of issues, I changed my mind and now I believe that
> splitter should be set by user.

It seems like now we have convinced each other to change our initial
positions.

As you recall I was previously in favor of handling mapping of
switch-ports to physical ports in netlink and performing breakout
configuration that way as well.  Having Mellanox hardware perform in the
way you describe would certainly not prevent a solution to come later
that did automatic detection and reconfiguration, so if the concensus is
that handling breakouts in this way is OK, you are not going to see
significant argument from me.  (I checked back with a few others on what
is done in the closed-source world and some manual intervention is often
needed there as well, so let's stick with what you have).
 
> when you set the splitter port, you have 2 or 4 ports created in
> hardware. They looks exactly the same as unsplitted ports, they are only
> wired up differently. There is a netdev created for every splitter port,
> user would add it to bridge, bond, vlan, set routes, define static fdb
> entry and hw would learn fdbs itself. Now when someone disconnects the
> splitter cable, 2 things may happen:
> 1) yourway. Netdevs disappear, all configs and state info will disappear
>    with it.
> 2) myway. Netdevs stay, only link is down. This is the same behaviour is
>    if someone uplugs cable for unplitted port.
> 
> There are also similar issues before you plug the splitter cable. So it
> makes sense to let user co configure this. He knows what he wants. 1)
> does not look like correct behaviour to me, 2) does.

The bottom line here is that for the switch offload case most chips need
to be reconfigured significantly to function in a way that makes moving
from 1x100GbE > 2x50GbE, so whether one use case is better or worse
doesn't really matter that much.
> 
> 
> 
> <snip>
> 
> >> 	myhost:~$ dl port show
> >> 	devlink0/1: type eth netdev ens4
> >                             ^^^^^^^^^^^
> >> 	devlink0/2: type ib ibdev mlx4_0
> >                            ^^^^^^^^^^^^
> >I think my only other question about this implementation is whether or
> >not one would really want to have the true netdev/ibdev names mapped
> >here.
> >
> >Would be as reasonable to simply specify the type (and there may be more
> >types within ethernet that could be useful in multi-chip configurations)
> >and then let normal infrastructure that exists today figure out how to
> >map the names for the netdevs to the devices?
> 
> What normal infrastructure you have in mind? There is no info about
> devlink port mapping to netdev/ibdev anywhere. Only here. I might be
> missing something but I fail to see what's wrong with it.

I was simply wondering out loud if we _really_ wanted to name netdevs
this way.  I was suggesting that output could be like this:

myhost:~$ dl port show
devlink0/1: type eth
devlink0/2: type ib 

mnd that udev/systemd/biosdevname/etc would take care of naming the
device whataever it wanted.  This appears to be essentially the same
concern Hannes has.
