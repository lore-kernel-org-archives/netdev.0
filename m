From: Frederic Weisbecker <fweisbec@gmail.com>
Subject: Re: [PATCH] nohz: prevent tilegx network driver interrupts
Date: Sat, 11 Jul 2015 16:30:34 +0200
Message-ID: <20150711143033.GE10257@lerouge>
References: <1436549624-16104-1-git-send-email-cmetcalf@ezchip.com>
 <20150710182406.GC26428@lerouge>
 <55A0175E.2010200@ezchip.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Metcalf <cmetcalf@ezchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f175.google.com ([209.85.212.175]:33880 "EHLO
	mail-wi0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750751AbbGKOah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jul 2015 10:30:37 -0400
Content-Disposition: inline
In-Reply-To: <55A0175E.2010200@ezchip.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 10, 2015 at 03:05:02PM -0400, Chris Metcalf wrote:
> On 07/10/2015 02:24 PM, Frederic Weisbecker wrote:
> >Indeed we are doing more and more references on housekeeping_mask, so
> >we should probably think about an off-case.
> >
> >Now the nohz-full off-case should rather be cpu_possible_mask than
> >cpu_online_mask. housekeeping_mask doesn't take into account onlining
> >at all.
> 
> That suggests that in this case, we might want to default to
> something like "housekeeping_mask & cpu_online_mask",
> since you really don't want to send irqs to offline cores to
> process your packets :-)

In any case it must be up to the drivers to do that. Define
housekeeping_mask as a subset of the online mask complicates a lot
of things. It pushes hotplug complexity to the nohz code for no
reasons. It's up to the drivers and subsystems to handle that really.

> 
> The tilegx chips typically don't do cpu offlining anyway, since
> we've never really found a usecase, so whatever you boot with
> you always have available.  We do have support for a bare-metal
> mode which you can run on some of the cores, so you may start
> with fewer than cpu_possible actually running, but it will always
> be that same set of cores.

And that bare metal mode runs out of Linux?

Note that in nohz_full, The boot CPU can't be offline anyway.

> 
> So this does suggest that my original patch is wrong for that
> same reason.
> 
> >>2. Provide an accessor that returns the cpumask to use for housekeeping
> >>    chores and implement it in the obvious ways for both nohz_full
> >>    and non-nohz_full.
> >>
> >>The latter seems like arguably the most satisfying approach, but
> >>the patch below is, if nothing else, suitable to push for 4.3
> >>without any further API development work.
> >I don't know. 1) looks easier.
> 
> On reflection, the problem with (1) is that if you are in NO_HZ_FULL
> mode but !tick_nohz_full_enabled(), you want to fall back to just
> using cpu_possible_mask anyway.  So I think a simple accessor that
> returns an appropriate cpumask pointer is probably the best bet
> (along the lines of the existing is_housekeeping_cpu() accessor).

Ok!
