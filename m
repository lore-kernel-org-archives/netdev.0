From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [RFC] net: ipv4 -- Introduce ifa limit per net
Date: Wed, 9 Mar 2016 22:55:28 +0300
Message-ID: <20160309195528.GN2207@uranus.lan>
References: <20160309163919.GJ2207@uranus.lan>
 <20160309165850.GA49579@ast-mbp.thefacebook.com>
 <20160309170921.GL2207@uranus.lan>
 <20160309.122400.951958972682394628.davem@davemloft.net>
 <20160309175307.GM2207@uranus.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, solar@openwall.com, vvs@virtuozzo.com,
	avagin@virtuozzo.com, xemul@virtuozzo.com, vdavydov@virtuozzo.com,
	khorenko@virtuozzo.com
To: David Miller <davem@davemloft.net>, alexei.starovoitov@gmail.com,
	eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f180.google.com ([209.85.217.180]:36221 "EHLO
	mail-lb0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcCITzh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 14:55:37 -0500
Received: by mail-lb0-f180.google.com with SMTP id x1so81325229lbj.3
        for <netdev@vger.kernel.org>; Wed, 09 Mar 2016 11:55:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20160309175307.GM2207@uranus.lan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 09, 2016 at 08:53:07PM +0300, Cyrill Gorcunov wrote:
> On Wed, Mar 09, 2016 at 12:24:00PM -0500, David Miller wrote:
> ...
> > We asked you for numbers without a lot of features enabled, it'll
> > help us diagnose which subsystem still causes a lot of overhead
> > much more clearly.
> > 
> > So please do so.
> 
> Sure. Gimme some time and I'll back with numbers.

OK, here are the results (with preempt-debug/trace disabled,
on the kernel with David's two patches).
---

 No conntrack
 ------------
 [root@s125 ~]# ./exploit.sh 
 START 4	addresses STOP 1457549979 1457549980	-> 1
 START 2704	addresses STOP 1457549983 1457549984	-> 1
 START 10404	addresses STOP 1457549996 1457549997	-> 1
 START 23104	addresses STOP 1457550029 1457550030	-> 1
 START 40804	addresses STOP 1457550103 1457550104	-> 1
 START 63504	addresses STOP 1457550267 1457550268	-> 1

all works quite fast, takes 1 second.

 With conntrack
 --------------

 1) In a middle of "release -> create new addresses" transition

  27.53%  [kernel]                    [k] __local_bh_enable_ip
  26.29%  [kernel]                    [k] _raw_spin_lock
   6.00%  [kernel]                    [k] nf_ct_iterate_cleanup
   3.95%  [kernel]                    [k] nf_conntrack_lock
   2.94%  [kernel]                    [k] _raw_spin_unlock
   1.91%  [kernel]                    [k] _cond_resched
   1.78%  [kernel]                    [k] check_lifetime
   1.25%  [kernel]                    [k] __inet_insert_ifa
   1.19%  [kernel]                    [k] inet_rtm_newaddr

 2) Last one with 63K of addresses releasing

  36.36%  [kernel]                 [k] __local_bh_enable_ip
  34.75%  [kernel]                 [k] _raw_spin_lock
   7.93%  [kernel]                 [k] nf_ct_iterate_cleanup
   5.11%  [kernel]                 [k] nf_conntrack_lock
   3.71%  [kernel]                 [k] _raw_spin_unlock
   2.51%  [kernel]                 [k] _cond_resched
   0.89%  [kernel]                 [k] task_tick_fair
   0.77%  [kernel]                 [k] native_write_msr_safe
   0.58%  [kernel]                 [k] hrtimer_active
   0.52%  [kernel]                 [k] rcu_check_callbacks

[root@s125 ~]# ./exploit.sh 
START 4		addresses STOP 1457552395 1457552397	-> 2
START 2704	addresses STOP 1457552399 1457552403	-> 4
START 10404	addresses STOP 1457552415 1457552429	-> 14
START 23104	addresses STOP 1457552461 1457552492	-> 31
START 40804	addresses STOP 1457552566 1457552620	-> 54
START 63504	addresses STOP 1457552785 1457552870	-> 85

at the final stage it took 85 seconds to become alive. All
eaten inside nf_ct_iterate_cleanup (actually inside
get_next_corpse). IIRC there were some feature of perf
which could annotate the instructions, no? Have to refresh
memory on how to use perf record and such...
