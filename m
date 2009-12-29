From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: lockdep possible recursive lock in slab parent->list->rlock in
	rc2
Date: Mon, 28 Dec 2009 17:11:37 -0800
Message-ID: <20091229011137.GA8469@linux.vnet.ibm.com>
References: <20091227120622.GA480@basil.fritz.box> <1261917194.5933.2.camel@penberg-laptop>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, a.p.zijlstra@chello.nl,
	cl@linux-foundation.org, Heiko Carstens <heiko.carstens@de.ibm.com>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:51808 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751936AbZL2BLd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2009 20:11:33 -0500
Content-Disposition: inline
In-Reply-To: <1261917194.5933.2.camel@penberg-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 27, 2009 at 02:33:14PM +0200, Pekka Enberg wrote:
> Hi Andi,
> 
> On Sun, 2009-12-27 at 13:06 +0100, Andi Kleen wrote:
> > Get this on a NFS root system while booting
> > This must be a recent change in the last week, 
> > I didn't see it in a post rc1 git* from last week
> > (I haven't done a exact bisect)
> > 
> > It's triggered by the r8169 driver close function, 
> > but looks more like a slab problem?
> > 
> > I haven't checked it in detail if the locks are 
> > really different or just lockdep not knowing 
> > enough classes.
> 
> I broke the lockdep annotations in commit
> ce79ddc8e2376a9a93c7d42daf89bfcbb9187e62 ("SLAB: Fix lockdep annotations
> for CPU hotplug"). Does this fix things for you? Heiko, the following
> patch should fix it for you too.

And no lockdep warnings here, either.  I did get the following
new-to-me preempt_count underflow, but doubt that it is related.

							Thanx, Paul

Badness at kernel/sched.c:5350
NIP: c0000000005b2e58 LR: c0000000005b2e3c CTR: c000000000025f0c
REGS: c000000042893b30 TRAP: 0700   Not tainted  (2.6.33-rc2-autokern1)
MSR: 8000000000029032 <EE,ME,CE,IR,DR>  CR: 22000082  XER: 0000000c
TASK = c00000007d8737e0[0] 'swapper' THREAD: c000000042890000 CPU: 2
GPR00: 0000000000000000 c000000042893db0 c0000000009c07f8 0000000000000001 
GPR04: 0000000000000001 0000000000000006 0000000000000001 000000000000004a 
GPR08: 0000000000000000 c00000000128adb8 c00000000088aa20 c000000000a0da08 
GPR12: 0000000000000002 c0000000009df880 0000000000000000 0000000000c00020 
GPR16: 0000000000000002 0000000000000000 0000000000000000 0000000000000000 
GPR20: 0000000000000000 c0000000009e24b0 0000000000000001 c0000000009df480 
GPR24: 0000000000000000 c0000000009d8628 c0000000009df880 0000000000000002 
GPR28: c0000000009e2068 c0000000009d8628 c00000000093c000 c000000042890000 
NIP [c0000000005b2e58] .sub_preempt_count+0x58/0xc8
LR [c0000000005b2e3c] .sub_preempt_count+0x3c/0xc8
Call Trace:
[c000000042893db0] [c000000042893e30] 0xc000000042893e30 (unreliable)
[c000000042893e30] [c000000000014d38] .cpu_idle+0x1f0/0x20c
[c000000042893ec0] [c0000000005ba678] .start_secondary+0x380/0x3c4
[c000000042893f90] [c000000000008264] .start_secondary_prolog+0x10/0x14
Instruction dump:
78290464 80090014 7f801800 40bc0074 4bd45745 60000000 2fa30000 419e0070 
e93e8a08 80090000 2f800000 409e0060 <0fe00000> 48000058 78000620 2fa00000 
BUG: scheduling while atomic: swapper/0/0x00000000
INFO: lockdep is turned off.
Modules linked in: ehea
Call Trace:
[c000000042897bf0] [c0000000000123b0] .show_stack+0x70/0x184 (unreliable)
[c000000042897ca0] [c00000000005eaa0] .__schedule_bug+0xa4/0xc4
[c000000042897d30] [c0000000005abe4c] .schedule+0xd8/0xa8c
[c000000042897e30] [c000000000014d40] .cpu_idle+0x1f8/0x20c
[c000000042897ec0] [c0000000005ba678] .start_secondary+0x380/0x3c4
[c000000042897f90] [c000000000008264] .start_secondary_prolog+0x10/0x14

> diff --git a/mm/slab.c b/mm/slab.c
> index 7d41f15..7451bda 100644
> --- a/mm/slab.c
> +++ b/mm/slab.c
> @@ -654,7 +654,7 @@ static void init_node_lock_keys(int q)
> 
>  		l3 = s->cs_cachep->nodelists[q];
>  		if (!l3 || OFF_SLAB(s->cs_cachep))
> -			return;
> +			continue;
>  		lockdep_set_class(&l3->list_lock, &on_slab_l3_key);
>  		alc = l3->alien;
>  		/*
> @@ -665,7 +665,7 @@ static void init_node_lock_keys(int q)
>  		 * for alloc_alien_cache,
>  		 */
>  		if (!alc || (unsigned long)alc == BAD_ALIEN_MAGIC)
> -			return;
> +			continue;
>  		for_each_node(r) {
>  			if (alc[r])
>  				lockdep_set_class(&alc[r]->lock,
> 
> 
