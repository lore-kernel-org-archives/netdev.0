From: Tom Herbert <therbert@google.com>
Subject: Re: Setting RPS affinities from network driver
Date: Fri, 20 Feb 2015 14:30:24 -0800
Message-ID: <CA+mtBx9inCEq7PS3h02tSThsMLBVv5OUrusDkMg7d-OOvmqdiQ@mail.gmail.com>
References: <CA+sq2CeC89YfaTM18JR9dFOoNAbohGk=gFXSkM_4q2oySB12GA@mail.gmail.com>
	<CA+mtBx9qHdEeXmEGbbWSr_OL3aAQJ37eTbC0mUY_XrTNoZ6iXw@mail.gmail.com>
	<CA+sq2CdYSg4NTnyLOMGyF1bmfr0+h+9UJyjJGO2hKEcq4rED8A@mail.gmail.com>
	<CAPFHKzc1+HTOm4PGAnRJ_svjAdZDrK5fMWpYL9Q0RQcPsXCd+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Sunil Kovvuri <sunil.kovvuri@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Jonathon Reinhart <jonathon.reinhart@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:35130 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754617AbbBTWaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2015 17:30:25 -0500
Received: by iecrl12 with SMTP id rl12so11426649iec.2
        for <netdev@vger.kernel.org>; Fri, 20 Feb 2015 14:30:24 -0800 (PST)
In-Reply-To: <CAPFHKzc1+HTOm4PGAnRJ_svjAdZDrK5fMWpYL9Q0RQcPsXCd+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 19, 2015 at 6:07 PM, Jonathon Reinhart
<jonathon.reinhart@gmail.com> wrote:
>
> I don't know if this is a good idea. It seems like allowing the driver to
> set this default configuration opens the door to a whole slew of driver-
> specific config customizations.
>
> As as user, I wouldn't expect one driver to have a different default
> value of rps_cpus than another driver. Furthermore, I could imagine a
> case where a user expects rps_cpus to default to zero for all of his
> NICs, and has other CPU affinity settings applied (think realtime).
>
> In my opinion, this should be left to userspace. It's not that hard to
> add it to your init scripts.
>
>
In the old days I might have agreed with that-- kernel implements
mechanism and policy is handled in user space. However, in this brave
new world of hardware offloads for more and more kernel networking,
I'm not so sure about this any more. It's starting to look like we may
want kernel to do more dynamic resource management under some
described policies.

In davem's keynote at netdev he mentioned that hardware offload should
be transparent to things like ip route, so one implication is that at
some point the kernel may need to decide which routes are the best to
offload per a policy. Also at netdev, Jesse Brandeburg mentioned that
Windows had a capabilities of spinning up RSS queues to handle
increased load, and lamented that we couldn't do this easily in Linux.
Willem deBruijn made RPS resilient under DOS with RPS flow limit as a
step in that direction. We have spent countless hours tuning RPS and
interrupt settings per platform, per NIC, and per some major
applications-- but the resultant init scripts that result are very
convoluted and static. It is an interesting idea if we could just tell
kernel to take it's best guess and be adaptive. I suppose something
like irqbalance is the alternative to do this sort of stuff in user
space, but I don't know if that is well deployed or sufficiently
reactive under DOS attack.

Tom

> On Wed, Feb 18, 2015 at 10:47 AM, Sunil Kovvuri <sunil.kovvuri@gmail.com> wrote:
> > Thanks Tom,
> >
> > Will try to implement something like a library function which can be used
> > by any driver.
> >
> > Regards,
> > Sunil.
> >
> > On Wed, Feb 18, 2015 at 9:14 PM, Tom Herbert <therbert@google.com> wrote:
> >> On Tue, Feb 17, 2015 at 10:16 PM, Sunil Kovvuri <sunil.kovvuri@gmail.com> wrote:
> >>> Hi,
> >>>
> >>> I am writing a network driver for a multicore SOC with a on-board
> >>> network interface and would like to set RPS affinities from driver by
> >>> default. So that the network performance is good with whatever driver
> >>> supplied. Ofcourse these can be further adjusted from userspace
> >>> anyways.
> >>>
> >>> Is there a way to set RPS settings from driver itself ?
> >>> The only issue i am seeing is while setting 'rps_needed' key.
> >>>
> >> There is nothing to prevent this, but it would be really cool to make
> >> this into a library function that drivers can call to initialize RPS
> >> in some sane way (you might want to look at cpu_rmap).
> >>
> >>> static_key_slow_inc(&rps_needed);
> >>>
> >>> Currently this is not exported, so having issues while compiling
> >>> driver as module.
> >>>
> >>> If i export this symbol, will it be acceptable ?
> >>>
> >> Seems okay to me.
> >>
> >> Thanks,
> >> Tom
> >>
> >>>
> >>> Thanks,
> >>> Sunil.
> >>> --
> >>> To unsubscribe from this list: send the line "unsubscribe netdev" in
> >>> the body of a message to majordomo@vger.kernel.org
> >>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> > --
> > To unsubscribe from this list: send the line "unsubscribe netdev" in
> > the body of a message to majordomo@vger.kernel.org
> > More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
>
>
> --
> Computers are incredibly fast, accurate and stupid. Human beings are
> incredibly slow, inaccurate and brilliant. Together they are powerful
> beyond imagination.
>                                     A. Einstein
