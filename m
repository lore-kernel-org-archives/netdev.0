From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Tue, 28 Apr 2009 08:09:10 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904280748350.22156@localhost.localdomain>
References: <49F22465.80305@gmail.com> <20090425133052.4cb711f5@nehalam> <49F4A6E3.7080102@cosmosbay.com> <20090426185646.GB29238@Krystal> <20090426145746.1184aeba@nehalam> <1240854297.7620.65.camel@twins> <20090427113010.5e3f1700@nehalam> <20090427185423.GC23862@elte.hu>
 <20090427120658.35a858bb@nehalam> <alpine.LFD.2.00.0904271219570.22156@localhost.localdomain> <20090427203616.GB3836@ioremap.net> <alpine.LFD.2.00.0904271340400.22156@localhost.localdomain> <20090427144054.1fb9b7a6@nehalam> <alpine.LFD.2.00.0904271506530.22156@localhost.localdomain>
 <alpine.LFD.2.00.0904271525120.22156@localhost.localdomain> <alpine.LFD.2.00.0904271602390.22156@localhost.localdomain> <49F6A8FD.3010804@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Ingo Molnar <mingo@elte.hu>,
	Peter Zijlstra <peterz@infradead.org>,
	Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33137 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932538AbZD1PVv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 11:21:51 -0400
In-Reply-To: <49F6A8FD.3010804@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 28 Apr 2009, Eric Dumazet wrote:
> 
> Instead of submitting a full patch again, we could first submit a new
>  include file containg all comments and inline functions ?

Well, I actually already suggested to David that he should just merge the 
last patch I saw floating around (with the "recursive" -> "readwrite" fix 
in the comment ;), so that we can at least get the basic issue fixed, and 
then we can tweak it a bit with smaller patches flying around.

And at least right now, the difference between the rwlock and the 
"count+spinlock" should be basically almost unnoticeable, and a very small 
implementation issue. They're entirely interchangeable, after all.

> This include file could be local to netfilter, with a big stick on
> it to forbids its use on other areas (No changes in Documentation/ )
>
> Then, as soon as we can go back to pure RCU solution, we can safely
> delete this controversial-locking-nesting-per-cpu-thing ?

I don't have any strogn preferences, but I'd almost prefer to not abstract 
things out even that much. It's already pretty well hidden inside 
<netfilter/x_tables.h>, I'd hate to add a new file just for this. 

As to just adding more commenting that it must not be used anywhere else, 
I certainly agree with that.

> Instead of local/global name that Paul suggested, that was about
> 'global' locking all locks at the same time. Not any more the good
> name IMHO
> 
> Maybe something like local/remote or owner/foreigner ?

local/remote works for me, and yes, since we only take the remote side one 
CPU at a time, I guess "global" is misleading. But "owner/foreigner" 
sounds pretty odd.

> One comment about this comment you wrote :
> 
> /*
>  * The "writer" side needs to get exclusive access to the lock,
>  * regardless of readers.  This must be called with bottom half
>  * processing (and thus also preemption) disabled. 
>  */
> 
> Its true that BH should be disabled if caller runs
> on the cpu it wants to lock. 
> For other ones (true foreigners), there is
> no requirement about BH (current cpu could be interrupted
> by a softirq and packets could fly)

Yes. Other CPU's just require preemption protection. 

> We could use following construct and not require disabling BH
> more than a short period of time.
> (But preemption disabled for the whole duration)
> 
> preempt_disable(); // could be cpu_migration_disable();
> 
> int curcpu = smp_processor_id();
> /*
>  * Gather stats for current cpu : must disable BH
>  * before trying to lock.
>  */
> local_bh_disable();
> xt_info_wrlock(curcpu);
> // copy stats of this cpu on my private data (not shown here)
> xt_info_wrunlock(curcpu);
> local_bh_enable();
> 
> for_each_possible_cpu(cpu) {
> 	if (cpu == curcpu)
> 		continue;
> 	xt_info_wrlock(cpu);
> 	// fold stats of "cpu" on my private data (not shown here)
> 	xt_info_wrunlock((cpu);
> }
> preempt_enable(); // could be cpu_migration_enable();

Agreed. 

> So your initial comment could be changed to :
> 
> /*
>  * The "writer" side needs to get exclusive access to the lock,
>  * regardless of readers. If caller is about to lock its own lock,
>  * he must have disabled BH before. For other cpus, no special
>  * care but preemption disabled to guarantee no cpu migration.
>  */

Ack.

			Linus
