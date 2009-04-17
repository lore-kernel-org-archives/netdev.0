From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] netfilter: use per-cpu spinlock rather than RCU (v3)
Date: Fri, 17 Apr 2009 10:32:46 -0700 (PDT)
Message-ID: <alpine.LFD.2.00.0904171028070.4042@localhost.localdomain>
References: <20090416215033.3e648a7a@nehalam>  <49E810B0.9000906@cosmosbay.com> <20090417054032.GD6885@linux.vnet.ibm.com>  <20090417.010710.59150850.davem@davemloft.net> <1239988979.23397.4841.camel@laptop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	dada1@cosmosbay.com, shemminger@vyatta.com, kaber@trash.net,
	jeff.chua.linux@gmail.com, paulus@samba.org, mingo@elte.hu,
	laijs@cn.fujitsu.com, jengelh@medozas.de, r000n@r000n.net,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, benh@kernel.crashing.org,
	mathieu.desnoyers@polymtl.ca
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:51068 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762280AbZDQRou (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Apr 2009 13:44:50 -0400
In-Reply-To: <1239988979.23397.4841.camel@laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 17 Apr 2009, Peter Zijlstra wrote:
> 
> Since its a full broadcast, we can do that _today_ using on_each_cpu().
> But whatever way we turn this, this will be a very expensive operation.
> Imagine doing that on your 256-way for every iptables rules change.

Well, you _could_ just have a per-CPU bit of "have I used nf rules since 
the last update", and skip those CPU's. Use memory ordering to check the 
bits (set the bit _before_ looking up a NF rule, and check them _after_ 
doing the update, and have a barrier in between if you really think it 
matters).

Remember: the cost was never about a single filter rule update. The cost 
of a single one is almost immaterial, as long as it's not in hundreds of 
milliseconds. It's the cost of people building up things incrementally 
that caused this thing.

So if you have 200 "iptables" commands in a sequence, and especially 
during bootup, a trivial "has the old rule been ever even looked at on 
this CPU" would already fix the issue. Because it would always be zero in 
the only case where it matters.

This is, of course, what we do for the TLB flushing issue. We don't want 
to send IPI's to all CPU's, and in 99.999% of all cases we don't need to, 
because the other CPU's never even loaded the MM.

			Linus
