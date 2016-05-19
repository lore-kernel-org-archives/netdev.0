From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [RFC net-next] net: sched: do not acquire qdisc spinlock in
 qdisc/class stats dump
Date: Thu, 19 May 2016 09:08:05 -0700
Message-ID: <20160519160803.GA70549@ast-mbp.thefacebook.com>
References: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Kevin Athey <kda@google.com>,
	Xiaotian Pei <xiaotian@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:34974 "EHLO
	mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932277AbcESQIK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 12:08:10 -0400
Received: by mail-pf0-f193.google.com with SMTP id b66so8556621pfb.2
        for <netdev@vger.kernel.org>; Thu, 19 May 2016 09:08:10 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1463661320.18194.178.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 19, 2016 at 05:35:20AM -0700, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> Large tc dumps (tc -s {qdisc|class} sh dev ethX) done by Google BwE host
> agent [1] are problematic at scale :
>     
> For each qdisc/class found in the dump, we currently lock the root qdisc
> spinlock in order to get stats. Sampling stats every 5 seconds from
> thousands of HTB classes is a challenge when the root qdisc spinlock is
> under high pressure.
> 
> These stats are using u64 or u32 fields, so reading integral values
> should not prevent writers from doing concurrent updates if the kernel
> arch is a 64bit one.
> 
> Being able to atomically fetch all counters like packets and bytes sent
> at the expense of interfering in fast path (queue and dequeue packets)
> is simply not worth the pain, as the values are generally stale after 1
> usec.
> 
> These lock acquisitions slow down the fast path by 10 to 20 %
> 
> An audit of existing qdiscs showed that sch_fq_codel is the only qdisc
> that might need the qdisc lock in fq_codel_dump_stats() and
> fq_codel_dump_class_stats()
> 
> gnet_dump_force_lock() call is added there and could be added to other
> qdisc stat handlers if needed.
> 
> [1]
> http://static.googleusercontent.com/media/research.google.com/en//pubs/archive/43838.pdf
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Cc: Kevin Athey <kda@google.com>
> Cc: Xiaotian Pei <xiaotian@google.com>

good optimization.
Acked-by: Alexei Starovoitov <ast@kernel.org>

> +static inline spinlock_t *qdisc_stats_lock(const struct Qdisc *qdisc)
> +{
> +	ASSERT_RTNL();
> +#if defined(CONFIG_64BIT) && !defined(CONFIG_LOCKDEP)
> +	/* With u32/u64 bytes counter, there is no real issue on 64bit arches */
> +	return NULL;
> +#else
> +	return qdisc_lock(qdisc_root_sleeping(qdisc));

initially I thought that above line could have been qdisc_root_sleeping_lock()
but then realized that moving out ASSERT_RTNL makes more sense. Good call.
The only thing not clear to me is why '!defined(CONFIG_LOCKDEP)' ?
Just extra caution? I think should be fine without it.
