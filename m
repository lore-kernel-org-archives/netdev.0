From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Tue, 21 Apr 2009 20:02:25 +0200
Message-ID: <20090421180225.GA26237@elte.hu>
References: <20090417012812.GA25534@linux.vnet.ibm.com> <20090418094001.GA2369@ioremap.net> <20090418141455.GA7082@linux.vnet.ibm.com> <20090420103414.1b4c490f@nehalam> <49ECBE0A.7010303@cosmosbay.com> <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Eric Dumazet <dada1@cosmosbay.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757500AbZDUSD2@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> PS: Ingo, why do the *_bh() functions in kernel/spinlock.c do 
> _both_ a "local_bh_disable()" and a "preempt_disable()"? BH 
> disable should disable preemption too, no? Or am I confused? In 
> which case we need that in the above rdlock_bh too.

i think there might be (are?) uses of:

	spin_lock_bh(&some->lock);
	...
	spin_unlock(&some->lock);
	...
	local_bh_enable();

So we have to have two preemption control levels for that, as 
there's no knowledge at the spin_lock_bh() place whether it will be 
followed by a spin_unlock_bh() [in which case it would be safe to do 
SOFTIRQ_OFFSET only] - or by a spin_unlock() + local_bh_enable() 
pair..

[ That locking pattrn even makes a certain amount of sense: keep the 
  lock held for a short amount of time - then weaken locking to bh 
  context exclusion only. ]

What we could do is an optimization to do a compound increase the 
preempt count by SOFTIRQ_OFFSET+1 - instead of a local_bh_disable() 
+ preempt_disable()? Symmetrically we could do a compound decrease 
in the unlock case.

It might even be called: local_bh_preempt_disable() or so?

	Ingo
