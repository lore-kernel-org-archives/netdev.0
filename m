From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: TUN problems (regression?)
Date: Thu, 20 Dec 2012 19:39:39 -0800
Message-ID: <1356061179.21834.4515.camel@edumazet-glaptop>
References: <4151394.nMo40zlg68@sifl>
	 <1356046697.21834.3606.camel@edumazet-glaptop>
	 <20121220155001.538bbdb0@nehalam.linuxnetplumber.net>
	 <50D3D85B.1070605@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Paul Moore <pmoore@redhat.com>, netdev@vger.kernel.org
To: Jason Wang <jasowang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:60549 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751429Ab2LUDjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2012 22:39:42 -0500
Received: by mail-pb0-f49.google.com with SMTP id un15so2424876pbc.36
        for <netdev@vger.kernel.org>; Thu, 20 Dec 2012 19:39:42 -0800 (PST)
In-Reply-To: <50D3D85B.1070605@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-12-21 at 11:32 +0800, Jason Wang wrote:
> On 12/21/2012 07:50 AM, Stephen Hemminger wrote:
> > On Thu, 20 Dec 2012 15:38:17 -0800
> > Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >
> >> On Thu, 2012-12-20 at 18:16 -0500, Paul Moore wrote:
> >>> [CC'ing netdev in case this is a known problem I just missed ...]
> >>>
> >>> Hi Jason,
> >>>
> >>> I started doing some more testing with the multiqueue TUN changes and I ran 
> >>> into a problem when running tunctl: running it once w/o arguments works as 
> >>> expected, but running it a second time results in failure and a 
> >>> kmem_cache_sanity_check() failure.  The problem appears to be very repeatable 
> >>> on my test VM and happens independent of the LSM/SELinux fixup patches.
> >>>
> >>> Have you seen this before?
> >>>
> >> Obviously code in tun_flow_init() is wrong...
> >>
> >> static int tun_flow_init(struct tun_struct *tun)
> >> {
> >>         int i;
> >>
> >>         tun->flow_cache = kmem_cache_create("tun_flow_cache",
> >>                                             sizeof(struct tun_flow_entry), 0, 0,
> >>                                             NULL);
> >>         if (!tun->flow_cache)
> >>                 return -ENOMEM;
> >> ...
> >> }
> >>
> >>
> >> I have no idea why we would need a kmem_cache per tun_struct,
> >> and why we even need a kmem_cache.
> > Normally flow malloc/free should be good enough.
> > It might make sense to use private kmem_cache if doing hlist_nulls.
> >
> >
> > Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> Should be at least a global cache, I thought I can get some speed-up by
> using kmem_cache.
> 
> Acked-by: Jason Wang <jasowang@redhat.com>

Was it with SLUB or SLAB ?

Using generic kmalloc-64 is better than a dedicated kmem_cache of 48
bytes per object, as we guarantee each object is on a single cache line.
