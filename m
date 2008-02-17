From: "Benjamin Thery" <ben.thery@gmail.com>
Subject: Re: [BUG] IPv6 recursive locking
Date: Sun, 17 Feb 2008 21:37:40 +0100
Message-ID: <939d53060802171237o6617afb5x1f5c0fbb134ae366@mail.gmail.com>
References: <20080217141229.GB1677@nereid> <47B87D2B.7040400@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Kristof Provost" <Kristof@provost-engineering.be>,
	netdev@vger.kernel.org, davem@davemloft.net
To: "Daniel Lezcano" <dlezcano@fr.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0910.google.com ([209.85.198.189]:25375 "EHLO
	rv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752955AbYBQUhl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 17 Feb 2008 15:37:41 -0500
Received: by rv-out-0910.google.com with SMTP id k20so1055309rvb.1
        for <netdev@vger.kernel.org>; Sun, 17 Feb 2008 12:37:41 -0800 (PST)
In-Reply-To: <47B87D2B.7040400@fr.ibm.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 17, 2008 7:30 PM, Daniel Lezcano <dlezcano@fr.ibm.com> wrote:
> Kristof Provost wrote:
> > -----BEGIN PGP SIGNED MESSAGE-----
> > Hash: SHA1
> >
> > Hi,
> >
> > I'm running the current git (1309d4e68497184d2fd87e892ddf14076c2bda98)
> > without problems. While I was toying with IPv6 on my local network I managed
> > to completely hang my machine whenever it receives or sends a neighbour
> > sollictation. At least, I think that's the cause. It started as soon as I
> > installed radvd on the router. The included trace seems to point in the same
> > direction.
> >
> > The machine is a Dell Latitude D505 (so x86). Network interfaces are e100 and
> > ipw2200 (firmware not loaded). I'm currently using the e100.
> >
> > I'll try to bisect it but here's the trace already. Let me know if
> > there's anything else you'd like to know.
>
> I think this bug was introduced by the commit:
>
> 69cc64d8d92bf852f933e90c888dfff083bd4fc9
> "[NDISC]: Fix race in generic address resolution".

I confirm this commit is the culprit.
I reported the same bug last Thursday, but it seems I made a mistake: I replied
to the original thread which led to this commit to report it. But as the thread
was a bit old it seems my answer hadn't been noticed.
See http://www.spinics.net/lists/netdev/msg55373.html

The lockup happens very quickly when you have IPv6 configured.
I think we should revert this commit for now.

Benjamin

>
>
>
> > [  124.439831] =============================================
> > [  124.443689] [ INFO: possible recursive locking detected ]
> > [  124.443689] 2.6.25-rc2 #33
> > [  124.443689] ---------------------------------------------
> > [  124.443689] swapper/0 is trying to acquire lock:
> > [  124.443689]  (&n->lock){-+-+}, at: [<c0468d39>] neigh_resolve_output+0x139/0x290
> > [  124.443689]
> > [  124.443689] but task is already holding lock:
> > [  124.443689]  (&n->lock){-+-+}, at: [<c0468ea4>] neigh_timer_handler+0x14/0x280
> > [  124.443689]
> > [  124.443689] other info that might help us debug this:
> > [  124.443689] 1 lock held by swapper/0:
> > [  124.443689]  #0:  (&n->lock){-+-+}, at: [<c0468ea4>] neigh_timer_handler+0x14/0x280
> > [  124.443689]
> > [  124.443689] stack backtrace:
> > [  124.443689] Pid: 0, comm: swapper Not tainted 2.6.25-rc2 #33
> > [  124.443689]  [<c014863a>] __lock_acquire+0xd3a/0xf40
> > [  124.443689]  [<c0137ec8>] __kernel_text_address+0x18/0x30
> > [  124.443689]  [<c01488a0>] lock_acquire+0x60/0x80
> > [  124.443689]  [<c0468d39>] neigh_resolve_output+0x139/0x290
> > [  124.443689]  [<c059287e>] _write_lock_bh+0x2e/0x40
> > [  124.443689]  [<c0468d39>] neigh_resolve_output+0x139/0x290
> > [  124.443689]  [<c0468d39>] neigh_resolve_output+0x139/0x290
> > [  124.443689]  [<c0148805>] __lock_acquire+0xf05/0xf40
> > [  124.443689]  [<c04e1650>] ndisc_dst_alloc+0xe0/0x170
> > [  124.443689]  [<c04d39f4>] ip6_output_finish+0xa4/0x110
> > [  124.443689]  [<c0147a1d>] __lock_acquire+0x11d/0xf40
> > [  124.443689]  [<c04d4759>] ip6_output+0x5b9/0xba0
> > [  124.443689]  [<c0456eb6>] sock_alloc_send_skb+0x176/0x1d0
> > [  124.443689]  [<c04e4eab>] __ndisc_send+0x33b/0x540
> > [  124.443690]  [<c04e4d6e>] __ndisc_send+0x1fe/0x540
> > [  124.443690]  [<c04e5b69>] ndisc_send_ns+0x69/0xa0
> > [  124.443690]  [<c04e6c8e>] ndisc_solicit+0xee/0x1b0
> > [  124.443690]  [<c01472b5>] mark_held_locks+0x35/0x80
> > [  124.443690]  [<c0592c65>] _spin_unlock_irqrestore+0x45/0x60
> > [  124.443690]  [<c01473f9>] trace_hardirqs_on+0x79/0x130
> > [  124.443690]  [<c012f99f>] __mod_timer+0x9f/0xb0
> > [  124.443690]  [<c0468fd3>] neigh_timer_handler+0x143/0x280
> > [  124.443690]  [<c012f2ca>] run_timer_softirq+0x14a/0x1c0
> > [  124.443690]  [<c0468e90>] neigh_timer_handler+0x0/0x280
> > [  124.443690]  [<c0468e90>] neigh_timer_handler+0x0/0x280
> > [  124.443690]  [<c012b4c4>] __do_softirq+0x84/0x100
> > [  124.443690]  [<c012b595>] do_softirq+0x55/0x60
> > [  124.443690]  [<c012b9e5>] irq_exit+0x65/0x80
> > [  124.443690]  [<c01073b0>] do_IRQ+0x40/0x70
> > [  124.443690]  [<c010585e>] common_interrupt+0x2e/0x34
> > [  124.443690]  [<c032007b>] acpi_power_on+0x3b/0x104
> > [  124.443690]  [<c0322af6>] acpi_idle_enter_simple+0x194/0x1fe
> > [  124.443690]  [<c0322727>] acpi_idle_enter_bm+0xc1/0x2fc
> > [  124.443690]  [<c03fff43>] cpuidle_idle_call+0x63/0xb0
> > [  124.443690]  [<c03ffee0>] cpuidle_idle_call+0x0/0xb0
> > [  124.443690]  [<c010380d>] cpu_idle+0x5d/0xf0
> > [  124.443690]  =======================
> >
> > Kristof
> >
> --
>
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
