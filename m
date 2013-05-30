From: Shawn Bohrer <shawn.bohrer@gmail.com>
Subject: Re: 3.10.0-rc2 mlx4 not receiving packets for some multicast groups
Date: Thu, 30 May 2013 15:31:13 -0500
Message-ID: <20130530203113.GA4891@sbohrermbp13-local.rgmadvisors.com>
References: <20130524154931.GA9245@sbohrermbp13-local.rgmadvisors.com>
 <20130524163446.GC9245@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZJwe6xAj7xRK5_BnWN2wNT+oVS329+iYtE4hYTqPMLwJQ@mail.gmail.com>
 <20130525151347.GB25744@lintop.rgmadvisors.com>
 <20130528201508.GA6409@sbohrermbp13-local.rgmadvisors.com>
 <CAJZOPZLZmLi3V-3D_16FZHQLsCsHKZY7ZhvaEH1k=Pw_i+ciwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Hadar Hen Zion <hadarh@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Vlad Yasevich <vyasevic@redhat.com>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vb0-f47.google.com ([209.85.212.47]:49399 "EHLO
	mail-vb0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750811Ab3E3UbY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 16:31:24 -0400
Received: by mail-vb0-f47.google.com with SMTP id x13so502037vbb.6
        for <netdev@vger.kernel.org>; Thu, 30 May 2013 13:31:23 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJZOPZLZmLi3V-3D_16FZHQLsCsHKZY7ZhvaEH1k=Pw_i+ciwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 29, 2013 at 04:55:32PM +0300, Or Gerlitz wrote:
> On Tue, May 28, 2013 at 11:15 PM, Shawn Bohrer <shawn.bohrer@gmail.com> wrote:
> > Naturally I was wrong and we set more than the above non-default
> > values.  We additionally set high_rate_steer=1 on mlx4_core. As
> > you may know this parameter isn't currently available in the upstream
> > driver, so I've been carrying the following patch in my 3.4 and 3.10 trees:
> 
> [...]
> 
> > I've confirmed that with the above high_rate_steer patch and
> > high_rate_steer=1 I receive data on 3.10.0-rc3 and with
> > high_rate_steer=0 I only receive data on a small number of multicast
> > addresses.  With 3.4 and the same patch I receive data in both cases.
> 
> [...]
> 
> Shawn, so end-in mind you want the NIC steering mode to be DMFS
> (Device Managed Flow Steering) e.g for the processes bypassing the
> kernel, correct? since the NIC steering mode is global, you will not
> be able to use that non-upstream patch moving forward.

Yes, end goal is to use DMFS.  However, we have some ConnectX-2 cards
which I guess do not support DMFS and naturally I'd like plain old UDP
multicast to continue to work at the same level as 3.4.  So I may
still want that high_rate_steer option upstreamed, but we'll see once
I get 3.10 into better shape.

> So we need to
> debug/bisect why without the patch (what you call high_rate_steer=0)
> you don't get data on all groups. Can you bisect that on a single
> node, e.g set the rest of the environment with 3.4 that works, and on
> a given node see what is the commit that breaks that?

Done. It appears that the patch that breaks receiving packets on many
different multicast groups/sockets is:

commit 4cd729b04285b7330edaf5a7080aa795d6d15ff3
Author: Vlad Yasevich <vyasevic@redhat.com>
Date:   Mon Apr 15 09:54:25 2013 +0000

    net: add dev_uc_sync_multiple() and dev_mc_sync_multiple() api
    
    The current implementation of dev_uc_sync/unsync() assumes that there is
    a strict 1-to-1 relationship between the source and destination of the sync.
    In other words, once an address has been synced to a destination device, it
    will not be synced to any other device through the sync API.
    However, there are some virtual devices that aggreate a number of lower
    devices and need to sync addresses to all of them.  The current
    API falls short there.
    
    This patch introduces a new dev_uc_sync_multiple() api that can be called
    in the above circumstances and allows sync to work for every invocation.
    
    CC: Jiri Pirko <jiri@resnulli.us>
    Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

I've confirmed that reverting this patch on top of 3.10-rc3 allows me
to receive packets on all of my multicast groups without the Mellanox
high_rate_steer option set.

--
Shawn
