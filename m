From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH] rcu: increment quiescent state counter in ksoftirqd()
Date: Fri, 27 Feb 2009 08:34:08 -0800
Message-ID: <20090227163408.GB6758@linux.vnet.ibm.com>
References: <20090218051906.174295181@vyatta.com> <20090218052747.321329022@vyatta.com> <20090219114719.560999b5@extreme> <499DEF49.3040602@cosmosbay.com> <49A7F262.8040805@cosmosbay.com> <49A80FE4.6030508@cosmosbay.com>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org,
	linux kernel <linux-kernel@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:39902 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755680AbZB0QeL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Feb 2009 11:34:11 -0500
Content-Disposition: inline
In-Reply-To: <49A80FE4.6030508@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 27, 2009 at 05:08:04PM +0100, Eric Dumazet wrote:
> Eric Dumazet a =E9crit :
> > Eric Dumazet a =E9crit :
> >> Stephen Hemminger a =E9crit :
> >>> The reader/writer lock in ip_tables is acquired in the critical p=
ath of
> >>> processing packets and is one of the reasons just loading iptable=
s can cause
> >>> a 20% performance loss. The rwlock serves two functions:
> >>>
> >>> 1) it prevents changes to table state (xt_replace) while table is=
 in use.
> >>>    This is now handled by doing rcu on the xt_table. When table i=
s
> >>>    replaced, the new table(s) are put in and the old one table(s)=
 are freed
> >>>    after RCU period.
> >>>
> >>> 2) it provides synchronization when accesing the counter values.
> >>>    This is now handled by swapping in new table_info entries for =
each cpu
> >>>    then summing the old values, and putting the result back onto =
one
> >>>    cpu.  On a busy system it may cause sampling to occur at diffe=
rent
> >>>    times on each cpu, but no packet/byte counts are lost in the p=
rocess.
> >>>
> >>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >>
> >> Acked-by: Eric Dumazet <dada1@cosmosbay.com>
> >>
> >> Sucessfully tested on my dual quad core machine too, but iptables =
only (no ipv6 here)
> >>
> >> BTW, my new "tbench 8" result is 2450 MB/s, (it was 2150 MB/s not =
so long ago)
> >>
> >> Thanks Stephen, thats very cool stuff, yet another rwlock out of k=
ernel :)
> >>
> >=20
> > While testing multicast flooding stuff, I found that "iptables -nvL=
" can=20
> > have a *very* slow response time on my dual quad core machine...
> >=20
> >=20
> > # time iptables -nvL
> > Chain INPUT (policy ACCEPT 416M packets, 64G bytes)
> >  pkts bytes target     prot opt in     out     source              =
 destination
> >=20
> > Chain FORWARD (policy ACCEPT 0 packets, 0 bytes)
> >  pkts bytes target     prot opt in     out     source              =
 destination
> >=20
> > Chain OUTPUT (policy ACCEPT 401M packets, 62G bytes)
> >  pkts bytes target     prot opt in     out     source              =
 destination
> >=20
> > real    0m1.810s  <<<< HERE >>>>
> > user    0m0.000s
> > sys     0m0.001s
> >=20
> >=20
> > CONFIG_NO_HZ=3Dy
> > CONFIG_HZ_1000=3Dy
> > CONFIG_HZ=3D1000
> >=20
> > One cpu is 100% handling softirqs, could it be the problem ?
> >=20
> > Cpu0  :  1.0%us, 14.7%sy,  0.0%ni, 83.3%id,  0.0%wa,  0.0%hi,  1.0%=
si,  0.0%st
> > Cpu1  :  3.6%us, 23.2%sy,  0.0%ni, 71.6%id,  0.0%wa,  0.0%hi,  1.7%=
si,  0.0%st
> > Cpu2  :  0.0%us,  0.0%sy,  0.0%ni,  0.0%id,  0.0%wa,  0.0%hi,100.0%=
si,  0.0%st
> > Cpu3  :  2.7%us, 23.9%sy,  0.0%ni, 71.1%id,  0.7%wa,  0.0%hi,  1.7%=
si,  0.0%st
> > Cpu4  :  1.3%us, 14.3%sy,  0.0%ni, 83.3%id,  0.0%wa,  0.0%hi,  1.0%=
si,  0.0%st
> > Cpu5  :  1.0%us, 14.2%sy,  0.0%ni, 83.4%id,  0.0%wa,  0.0%hi,  1.3%=
si,  0.0%st
> > Cpu6  :  0.3%us,  7.0%sy,  0.0%ni, 92.4%id,  0.0%wa,  0.0%hi,  0.3%=
si,  0.0%st
> > Cpu7  :  0.7%us,  8.0%sy,  0.0%ni, 90.0%id,  0.7%wa,  0.0%hi,  0.7%=
si,  0.0%st
>=20
> Hi Paul
>=20
> I found following patch helps if one cpu is looping inside ksoftirqd(=
)
>=20
> synchronize_rcu() now completes in 40 ms instead of 1800 ms.
>=20
> Thank you
>=20
> [PATCH] rcu: increment quiescent state counter in ksoftirqd()
>=20
> If a machine is flooded by network frames, a cpu can loop 100% of its=
 time
> inside ksoftirqd() without calling schedule().
> This can delay RCU grace period to insane values.=20
>=20
> Adding rcu_qsctr_inc() call in ksoftirqd() solves this problem.

Good catch!!!  This regression was a result of the recent change
from "schedule()" to "cond_resched()", which got rid of that quiescent
state in the common case where a reschedule is not needed.

Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>

> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>
> ---
> diff --git a/kernel/softirq.c b/kernel/softirq.c
> index bdbe9de..9041ea7 100644
> --- a/kernel/softirq.c
> +++ b/kernel/softirq.c
> @@ -626,6 +626,7 @@ static int ksoftirqd(void * __bind_cpu)
>  			preempt_enable_no_resched();
>  			cond_resched();
>  			preempt_disable();
> +			rcu_qsctr_inc((long)__bind_cpu);
>  		}
>  		preempt_enable();
>  		set_current_state(TASK_INTERRUPTIBLE);
>=20
