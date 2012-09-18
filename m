From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Tue, 18 Sep 2012 16:40:39 +0200
Message-ID: <1347979239.26523.267.camel@edumazet-glaptop>
References: <5057455A.7050108@googlemail.com>
	 <50588371.40103@googlemail.com>  <505885DC.1060006@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chris Clayton <chris2553@googlemail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:38828 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751847Ab2IROkr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2012 10:40:47 -0400
Received: by eekc1 with SMTP id c1so3988606eek.19
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2012 07:40:43 -0700 (PDT)
In-Reply-To: <505885DC.1060006@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-09-18 at 15:31 +0100, Chris Clayton wrote:
> >> ...
> >> r8169                  47159  0
> >>
> >>  From the host I can successfully ping the guest, tap0 and the router as
> >> you would expect, but from the guest, although I can ping the host and
> >> tap0, I cannot ping the router. In practice, this means I have no
> >> internet access from the guest. As I say, this configuration works
> >> perfectly under 3.5.x and 3.4.x kernels.
> >>
> >> I'll do a coarse-grained "bisect" of Linus' 3.6 release candidates and
> >> report back, but does anyone have any prime-suspect patches that may be
> >> at the cause of this problem?
> >>
> >
> > -rc1 turned out to have the problem so I've bisected between 3.5 and
> > 3.6-rc1. I arrived at:
> >
> > $ git bisect bad
> > d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5 is the first bad commit
> > commit d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5
> > Author: David S. Miller <davem@davemloft.net>
> > Date:   Tue Jul 17 12:58:50 2012 -0700
> >
> >      ipv4: Cache input routes in fib_info nexthops.
> >
> >      Caching input routes is slightly simpler than output routes, since we
> >      don't need to be concerned with nexthop exceptions.  (locally
> >      destined, and routed packets, never trigger PMTU events or redirects
> >      that will be processed by us).
> >
> >      However, we have to elide caching for the DIRECTSRC and non-zero itag
> >      cases.
> >
> >      Signed-off-by: David S. Miller <davem@davemloft.net>
> >
> > :040000 040000 6bbc75c1cbe62bf84ea412d3b98adf2b614779cd
> > 3ad7256b4a71e63ca4530977c0550121ea803d35 M      include
> > :040000 040000 18c2a950a53c4eec9bfa12185d1e382dfed74af8
> > a2ab6157d6cd54930da395758c6ded3a225d1f04 M      net
> >
> > The bisect log:
> > git bisect start
> > # bad: [0d7614f09c1ebdbaa1599a5aba7593f147bf96ee] Linux 3.6-rc1
> > git bisect bad 0d7614f09c1ebdbaa1599a5aba7593f147bf96ee
> > # good: [28a33cbc24e4256c143dce96c7d93bf423229f92] Linux 3.5
> > git bisect good 28a33cbc24e4256c143dce96c7d93bf423229f92
> > # bad: [614a6d4341b3760ca98a1c2c09141b71db5d1e90] Merge branch 'for-3.6'
> > of git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup
> > git bisect bad 614a6d4341b3760ca98a1c2c09141b71db5d1e90
> > # bad: [320f5ea0cedc08ef65d67e056bcb9d181386ef2c] genetlink: define
> > lockdep_genl_is_held() when CONFIG_LOCKDEP
> > git bisect bad 320f5ea0cedc08ef65d67e056bcb9d181386ef2c
> > # good: [0cd06647b7c24f6633e32a505930a9aa70138c22] Merge branch 'master'
> > of git://git.kernel.org/pub/scm/linux/kernel/git/bluetooth/bluetooth-next
> > git bisect good 0cd06647b7c24f6633e32a505930a9aa70138c22
> > # good: [dbfa600148a25903976910863c75dae185f8d187] cxgb3: set maximal
> > number of default RSS queues
> > git bisect good dbfa600148a25903976910863c75dae185f8d187
> > # good: [efdfad3205403e1d1c5c0bdcbdb647ddd89bfaa3] bnx2: Try to recover
> > from PCI block reset
> > git bisect good efdfad3205403e1d1c5c0bdcbdb647ddd89bfaa3
> > # good: [1bf91cdc1bba94ea062a9147d924815c13f029f2] ixgbe: Drop
> > references to deprecated pci_ DMA api and instead use dma_ API
> > git bisect good 1bf91cdc1bba94ea062a9147d924815c13f029f2
> > # good: [b6dfd939fdc249fcf8cd7b8006f76239b33eb581] ixgbe: add support
> > for new 82599 device
> > git bisect good b6dfd939fdc249fcf8cd7b8006f76239b33eb581
> > # good: [3ba97381343b271296487bf073eb670d5465a8b8] net: ethernet:
> > davinci_emac: add pm_runtime support
> > git bisect good 3ba97381343b271296487bf073eb670d5465a8b8
> > # bad: [5e9965c15ba88319500284e590733f4a4629a288] Merge branch
> > 'kill_rtcache'
> > git bisect bad 5e9965c15ba88319500284e590733f4a4629a288
> > # good: [f5b0a8743601a4477419171f5046bd07d1c080a0] net: Document
> > dst->obsolete better.
> > git bisect good f5b0a8743601a4477419171f5046bd07d1c080a0
> > # bad: [ba3f7f04ef2b19aace38f855aedd17fe43035d50] ipv4: Kill
> > FLOWI_FLAG_RT_NOCACHE and associated code.
> > git bisect bad ba3f7f04ef2b19aace38f855aedd17fe43035d50
> > # good: [f2bb4bedf35d5167a073dcdddf16543f351ef3ae] ipv4: Cache output
> > routes in fib_info nexthops.
> > git bisect good f2bb4bedf35d5167a073dcdddf16543f351ef3ae
> > # bad: [d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5] ipv4: Cache input
> > routes in fib_info nexthops.
> > git bisect bad d2d68ba9fe8b38eb03124b3176a013bb8aa2b5e5
> >
> > Checking out the parent commit
> > (f2bb4bedf35d5167a073dcdddf16543f351ef3ae) and building and installing
> > the kernel gives a working configuration, so I'm pretty confident in the
> > outcome of the bisect. Reversing the patch gives errors, so I've not
> > tested master with the patch reversed.
> >
> > Let me know if I can help in any way to identify a fix.
> >
> Sorry, I forgot to say that I also have tried running TinyCore Linux as 
> a KVM guest on a 3.6.0-rc6 kernel, and I can ping the router fine, so 
> the problem seems to be something specifically related to ruuning 
> Windows XP as the guest. I don't have any other guests installed so 
> that's as much as I can say, although I could maybe install a Win7 guest 
> tomorrow if that would help.

It would help to have some traffic sample, maybe.

Especially if the problem is not easily reproductible for us.

(I dont have Windows XP nor Win7)

Also the bisect might point to a commit with an already fixed bug :

commit 4331debc51ee1ce319f4a389484e0e8e05de2aca
Author: Eric Dumazet <edumazet@google.com>
Date:   Wed Jul 25 05:11:23 2012 +0000

    ipv4: rt_cache_valid must check expired routes
    
    commit d2d68ba9fe8 (ipv4: Cache input routes in fib_info nexthops.)
    introduced rt_cache_valid() helper. It unfortunately doesn't check if
    route is expired before caching it.
    
    I noticed sk_setup_caps() was constantly called on a tcp workload.
    
    Signed-off-by: Eric Dumazet <edumazet@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>
