From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: net_ns cleanup / RCU overhead
Date: Fri, 29 Aug 2014 16:57:09 -0500
Message-ID: <87ppfjj6x6.fsf@x220.int.ebiederm.org>
References: <20140820055855.GB5579@hostway.ca>
	<20140828192431.GF5001@linux.vnet.ibm.com>
	<20140828194422.GB8867@hostway.ca>
	<87oav4l5g9.fsf@x220.int.ebiederm.org>
	<20140828204658.GL5001@linux.vnet.ibm.com>
	<20140829004029.GA18300@hostway.ca>
	<alpine.LFD.2.11.1408290635530.1520@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Simon Kirby <sim@hostway.ca>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Florian Westphal <fw@strlen.de>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:41947 "EHLO
	out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751249AbaH2V5Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Aug 2014 17:57:16 -0400
In-Reply-To: <alpine.LFD.2.11.1408290635530.1520@ja.home.ssi.bg> (Julian
	Anastasov's message of "Fri, 29 Aug 2014 06:57:55 +0300 (EEST)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Julian Anastasov <ja@ssi.bg> writes:

> 	Hello,
>
> On Thu, 28 Aug 2014, Simon Kirby wrote:
>
>> I noticed that [kworker/u16:0]'s stack is often:
>> 
>> [<ffffffff810942a6>] wait_rcu_gp+0x46/0x50
>> [<ffffffff8109607e>] synchronize_sched+0x2e/0x50
>> [<ffffffffa00385ac>] nf_nat_net_exit+0x2c/0x50 [nf_nat]
>
> 	I guess the problem is in nf_nat_net_exit,
> may be other nf exit handlers too. pernet-exit handlers
> should avoid synchronize_rcu and rcu_barrier.
> A RCU callback and rcu_barrier in module-exit is the way
> to go. cleanup_net includes rcu_barrier, so pernet-exit
> does not need such calls.

In principle I agree, however in this particular case it looks a bit
tricky because a separate hash table to track nat state per network
namespace.

At the same time all of the packets should be drained before
we get to nf_nat_net_exit so it doesn't look the synchronize_rcu
in nf_nat_exit is actually protecting anything.

Further calling a rcu delay function in net_exit methods largely
destroys the batched cleanup of network namespaces, so it is very
unpleasant.

Could someone who knows nf_nat_core.c better than I do look and
see if we can just remove the synchronize_rcu in nf_nat_exit?

>> [<ffffffff81720339>] ops_exit_list.isra.4+0x39/0x60
>> [<ffffffff817209e0>] cleanup_net+0xf0/0x1a0
>> [<ffffffff81062997>] process_one_work+0x157/0x440
>> [<ffffffff81063303>] worker_thread+0x63/0x520
>> [<ffffffff81068b96>] kthread+0xd6/0xf0
>> [<ffffffff818d412c>] ret_from_fork+0x7c/0xb0
>> [<ffffffffffffffff>] 0xffffffffffffffff

Eric
