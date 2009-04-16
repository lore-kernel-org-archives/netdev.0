From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH[] netfilter: use per-cpu reader-writer lock (v0.7)
Date: Fri, 17 Apr 2009 01:04:57 +0200
Message-ID: <20090416230457.GA16226@elte.hu>
References: <alpine.LFD.2.00.0904151705120.4042@localhost.localdomain> <20090415174551.529d241c@nehalam> <49E6BBA9.2030701@cosmosbay.com> <49E7384B.5020707@trash.net> <20090416144748.GB6924@linux.vnet.ibm.com> <49E75876.10509@cosmosbay.com> <20090416175850.GH6924@linux.vnet.ibm.com> <49E77BF6.1080206@cosmosbay.com> <20090416134956.6c1f0087@nehalam> <alpine.LFD.2.00.0904161353370.4042@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Eric Dumazet <dada1@cosmosbay.com>, paulmck@linux.vnet.ibm.com,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, jeff.chua.linux@gmail.com,
	paulus@samba.org, laijs@cn.fujitsu.com, jengelh@medozas.de,
	r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.mail.elte.hu ([157.181.151.9]:53117 "EHLO mx2.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754536AbZDPXFa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 16 Apr 2009 19:05:30 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0904161353370.4042@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Thu, 16 Apr 2009, Stephen Hemminger wrote:
> >
> > This version of x_tables (ip/ip6/arp) locking uses a per-cpu
> > rwlock that can be nested. It is sort of like earlier brwlock 
> > (fast reader, slow writer). The locking is isolated so future improvements
> > can concentrate on measuring/optimizing xt_table_info_lock. I tried
> > other versions based on recursive spin locks and sequence counters and 
> > for me, the risk of inventing own locking primitives not worth it at this time.
> 
> This is stil scary.
> 
> Do we guarantee that read-locks nest in the presense of a waiting 
> writer on another CPU? Now, I know we used to (ie readers always 
> nested happily with readers even if there were pending writers), 
> and then we broke it. I don't know that we ever unbroke it.
> 
> IOW, at least at some point we deadlocked on this (due to trying 
> to be fair, and not lettign in readers while earlier writers were 
> waiting):
> 
> 	CPU#1			CPU#2
> 
> 	read_lock
> 
> 				write_lock
> 				.. spins with write bit set, waiting for
> 				   readers to go away ..
> 
> 	recursive read_lock
> 	.. spins due to the write bit
> 	   being. BOOM: deadlock  ..
> 
> Now, I _think_ we avoid this, but somebody should double-check.

This is a narrow special-case where the spin-rwlock is safe, and the 
rwsem is unsafe.

But it should work for rwlocks - it always worked and the networking 
code always relied on that AFAIK.

Here's the x86 assembly code of the write-side slowpath:

ENTRY(__write_lock_failed)
        CFI_STARTPROC
        LOCK_PREFIX
        addl $RW_LOCK_BIAS,(%rdi)
1:      rep
        nop
        cmpl $RW_LOCK_BIAS,(%rdi)
        jne 1b
        LOCK_PREFIX
        subl $RW_LOCK_BIAS,(%rdi)
        jnz  __write_lock_failed
        ret
        CFI_ENDPROC

the fastpath decreased the value with RW_LOCK_BIAS, and when we 
enter this function we undo that effect by adding RW_LOCK_BIAS. Then 
we spin (without signalling our write-intent) passively until the 
count reaches RW_LOCK_BIAS. Then we try to lock it again and bring 
it to zero (meaning no other readers or writers - we got the lock).

This is pretty much the most unfair strategy possible for writers - 
but this is how rwlocks always behaved - and they do so mostly for 
recursive use within networking.

This is why the tasklist_lock was always so suspect to insane 
starvation symptoms on really large SMP systems, and this is why 
write_lock_irq(&tasklist_lock) was always a dangerous operation to 
do. (it can spin for a _long_ time with irqs off.)

It's not the most optimal of situations. Some patches are in the 
works to fix the irqs-off artifact (on ia64 - no x86 patches yet 
AFAICS) - but that's just papering it over.

	Ingo
