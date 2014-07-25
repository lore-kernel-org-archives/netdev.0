From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Fri, 25 Jul 2014 01:11:44 -0700 (PDT)
Message-ID: <alpine.DEB.2.10.1407250103580.26489@dinf>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>     <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>     <alpine.DEB.2.02.1406101726390.11647@dtop>     <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>    <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>    <alpine.DEB.2.02.1406281724370.18954@dtop>   <1404110292.15139.42.camel@edumazet-glaptop2.roam.corp.google.com>  
 <alpine.DEB.2.02.1406300112340.31629@dtop>  <1404117049.15139.63.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.02.1407071834230.586@dtop> <1404802064.3515.4.camel@edumazet-glaptop2.roam.corp.google.com>
 <alpine.DEB.2.02.1407161400290.7329@dtop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li263-96.members.linode.com ([173.255.253.96]:35968 "EHLO
	mail.rydia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbaGYILt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jul 2014 04:11:49 -0400
In-Reply-To: <alpine.DEB.2.02.1407161400290.7329@dtop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Tue, 8 Jul 2014, Eric Dumazet wrote:
>
> > On Mon, 2014-07-07 at 18:41 -0700, dormando wrote:
> >
> > > Mostly there, but I think we hit what might be a new bug.. The machines
> > > which crashed every few days previously have been stable for weeks.
> > >
> > > however I had one machine running the new kernel in a larger cluster
> > > elsewhere; we had a network event and the one machine on the new kernel
> > > panic'ed in ipv4_dst_destroy, but what looks like a new path. Sadly I've
> > > had to halt the rollout :( All of the older unfixed kernels survived this
> > > particular network event.
> > >
> > > Unfortunately this is still on 3.10, due to a bad softirq regression in
> > > 3.14 I've not had time to track down. I applied all of your patches for
> > > what wasn't already in 3.10. The only other change I made was to un-revert
> > > 62713c4b6bc10c2d082ee1540e11b01a2b2162ab - which I'd been keeping reverted
> > > as it was making crashes much more frequent.
> >
> > Hmm, always give patch title or a valid sha1 commit, this one is not in
> > David trees, so its hard to tell.
> >
>
> Happened again, about two minutes after causing a large route churn.
> Doing the same action again after it's been rebooted isn't causing it to
> crash... it last went down a week ago. Either we're still not reproducing
> it correctly, or it requires some amount of uptime inbetween crashes.
>
> Trace is slightly different this time, but same function.
>
> Any thoughts on how to instrument? :( kernels without your latest patches
> aren't crashing during these changes. We've fixed the UDP issue but traded
> it for something else.
>
> <4>[774493.032809] general protection fault: 0000 [#1] SMP
> <4>[774493.032830] Modules linked in: xt_TEE xt_dscp xt_DSCP macvlan bridge coretemp crc32_pclmul ghash_clmulni_intel gpio_ich microcode ipmi_watchdog ipmi_devintf sb_edac edac_core lpc_ich mfd_core tpm_tis tpm tpm_bios ipmi_si ipmi_msghandler isci igb libsas i2c_algo_bit ixgbe ptp pps_core mdio
> <4>[774493.032948] CPU: 10 PID: 49 Comm: ksoftirqd/10 Tainted: G        W    3.10.45 #1
> <4>[774493.032964] Hardware name: Supermicro X9DRi-LN4+/X9DR3-LN4+/X9DRi-LN4+/X9DR3-LN4+, BIOS 3.0 07/05/2013
> <4>[774493.032983] task: ffff88be6f3e0000 ti: ffff88be6f3de000 task.ti: ffff88be6f3de000
> <4>[774493.032997] RIP: 0010:[<ffffffff815fa8ef>]  [<ffffffff815fa8ef>] ipv4_dst_destroy+0x4f/0x80

Had our third panic (with very few machines running the kernel). Same
general spot; RCU callback, ipv4_dst_destroy, LIST_POISON1/POISON2 showing
it being a double-free.

The crash is always in the RCU callback, which only happens from
dst_release() when the dst has the DST_NOCACHE flag set.

void dst_release(struct dst_entry *dst)
{
    if (dst) {
        int newrefcnt;

        newrefcnt = atomic_dec_return(&dst->__refcnt);
        WARN_ON(newrefcnt < 0);
        if (unlikely(dst->flags & DST_NOCACHE) && !newrefcnt)
            call_rcu(&dst->rcu_head, dst_destroy_rcu);
    }
}

The WARN_ON() isn't firing so far as I can tell. the pstores we get from
the crashes are a bunch of normal sparse network noise, then immediately
the panic.

That tells me that it's some other part of the code causing the
double-free somehow? I've been working on understanding it but it's slow
going. I dont know if it's possible for a child of a dst to be shared in
more than one place, or if any of the callers of dst_release are wrong
(but if they were, the WARN_ON would fire, I'm pretty sure?)

Reproducing the problem has gone from a curiosity to a frustration:
sometimes when we do network maintenance the new kernel will immediately
die, but then we do the same thing again and it won't. We've done half a
dozen torture tests where we swap hundreds of thousands of routes on the
machine while running vairous mixes of traffic and can't get it to blow on
command.

Did you folks ever run the thing through ksan? I'm trying to come up with
ideas to instrument this better but dst fiddling is done in different ways
all over the kernel, and I've no idea which part is the trigger.

thanks, sorry for the noise :( I'm spinning my wheels on this last bug.
