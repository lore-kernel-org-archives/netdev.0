From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [netfilter bug] BUG: using smp_processor_id() in preemptible
	[00000000] code: ssh/9115, caller is ipt_do_table+0xc8/0x559
Date: Thu, 2 Apr 2009 23:16:06 +0200
Message-ID: <20090402211606.GC4076@elte.hu>
References: <20090402200128.GA21805@elte.hu> <49D51D86.9030906@cosmosbay.com> <20090402203220.GA30375@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	Rusty Russell <rusty@rustcorp.com.au>, coreteam@netfilter.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:46325 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751861AbZDBVQY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 2 Apr 2009 17:16:24 -0400
Content-Disposition: inline
In-Reply-To: <20090402203220.GA30375@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Ingo Molnar <mingo@elte.hu> wrote:

> * Eric Dumazet <dada1@cosmosbay.com> wrote:
> 
> > David put into its tree fix for that a few hours ago
> > 
> > commit fa9a86ddc8ecd2830a5e773facc250f110300ae7
> > 
> > (netfilter: iptables: lock free counters) forgot to disable BH
> > in arpt_do_table(), ipt_do_table() and  ip6t_do_table()
> > 
> > Use rcu_read_lock_bh() instead of rcu_read_lock() cures the problem.
> 
> ok, got your fix (attached below), thanks Eric for the pointer.
> 
> But i think my fix might be slightly better, because it does not 
> manipulate the preempt counter and leaves preemption enabled.
> 
> There's no BH context worries since this code did not seem to have 
> BH protection before either. (it used a plain read_lock(), not 
> read_lock_bh(), AFAICS)
> 
> I dont see any preemption worries either. I must be missing 
> something :)

as per the other mail - what i missed was that the old code _did_ 
use read_lock_bh(), which did not get carried over into the 
rcu_read_lock().

So this fix affects basically all things netfilter, not just 
rcu-preempt - a plain rcu_read_lock() doesnt protect against BH 
context interaction.

	Ingo
