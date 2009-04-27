From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] netfilter: use per-CPU r**ursive lock {XV}
Date: Mon, 27 Apr 2009 11:30:10 -0700
Message-ID: <20090427113010.5e3f1700@nehalam>
References: <20090421111541.228e977a@nehalam>
	<20090421193924.GA24404@elte.hu>
	<20090421143927.52d7d89d@nehalam>
	<alpine.LFD.2.00.0904220821240.3101@localhost.localdomain>
	<20090423210938.1501507b@nehalam>
	<49F146FF.5050200@cosmosbay.com>
	<20090424091839.6e13ebec@nehalam>
	<49F22465.80305@gmail.com>
	<20090425133052.4cb711f5@nehalam>
	<49F4A6E3.7080102@cosmosbay.com>
	<20090426185646.GB29238@Krystal>
	<20090426145746.1184aeba@nehalam>
	<1240854297.7620.65.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>,
	Eric Dumazet <dada1@cosmosbay.com>,
	David Miller <davem@davemloft.net>,
	Jarek Poplawski <jarkao2@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Ingo Molnar <mingo@elte.hu>, Paul Mackerras <paulus@samba.org>,
	paulmck@linux.vnet.ibm.com, Evgeniy Polyakov <zbr@ioremap.net>,
	kaber@trash.net, jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:33493 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759241AbZD0SaU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2009 14:30:20 -0400
In-Reply-To: <1240854297.7620.65.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 27 Apr 2009 19:44:57 +0200
Peter Zijlstra <peterz@infradead.org> wrote:

> On Sun, 2009-04-26 at 14:57 -0700, Stephen Hemminger wrote:
> > On Sun, 26 Apr 2009 14:56:46 -0400
> > Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca> wrote:
> > 
> > > * Eric Dumazet (dada1@cosmosbay.com) wrote:
> > > > From: Stephen Hemminger <shemminger@vyatta.com>
> > > > 
> > > > > Epilogue due to master Jarek. Lockdep carest not about the locking
> > > > > doth bestowed. Therefore no keys are needed.
> > > > > 
> > > > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> > > > 
> > > > So far, so good, should be ready for inclusion now, nobody complained :)
> > > > 
> > > > I include the final patch, merge of your last two patches.
> > > > 
> > > > David, could you please review it once again and apply it if it's OK ?
> > > 
> > > > Thanks to all for your help and patience
> > > > 
> > > > [PATCH] netfilter: use per-CPU recursive lock {XV}
> > > 
> > > Hi Eric, 
> > > 
> > > Suitable name would probably be :
> > > 
> > 
> > But Linus is trying to delude himself.
> > 
> > This usage is recursive even if he doesn't like the terminology.
> > The same CPU has to be able to reacquire the read lock without deadlocking.
> > If reader/writer locks were implemented in a pure writer gets priority
> > method, then this code would break!  So yes read locks can be used recursively
> > now in Linux, but if the were implemented differently then this code
> > would break.  For example, the -rt kernel turns all read/write locks into
> > mutexs, so the -rt kernel developers will have to address this.
> 
> A recursive lock has the property:
> 
> lock()
> {
>   if (lock->owner == current) {
>     lock->depth++;
>     return;
>   }
> 
>   /* regular lock stuff */
> }
> 
> unlock()
> {
>   if (!--lock->depth)
>     /* regular unlock */
> }

Only on Linux, and only because you look at locking from
the point of view of the magic variable "current" process
point of view.

> non of the linux kernel locking primitives have this -- with the
> possible exception of the cpu-hotplug lock.
> 
> What rwlock_t has, is reader bias to the point where you can utterly
> starve writers, with the side effect that you can obtain multiple read
> ownerships without causing a deadlock.

But what happens when this side effect disappears?
 
> This is not what is called a recursive lock. A recursive lock would have
> each owner only once, this rwlock_t thing is simply so unfair that it
> can have unlimited owners, including multiple copies of the same one.
> 
> rwsem has fifo fairness, and therefore can deadlock in this scenario,
> suppose thread A does a read, thread B tries a write and blocks, then
> thread A recurses and tries to obtain another read ownership --
> deadlock, as the FIFO fairness will demand the second read ownership
> will wait on the pending writer, which will wait on the outstanding read
> owner.
> 
> Now if rwsem were a fifo-fair recursive lock, the above would not
> deadlock, since it would detect that the task already had (read)
> ownership and simply increment the depth, instead of trying to acquire a
> second ownership.
> 
> This is all common and well understood terminology, not something Linus
> invented just to harras you with.

In Documentation/ ?  online ?  Where is the definition? The only reference
I se is indirectly in DocBook/kernel-locking.tmpl.

> Generally speaking we do not condone recursive locking strategies -- and
> afaik reiserfs (as per the BKL) and the network code (as per abusing
> rwlock_t unfairness) are the only offenders.
> 
> Like Linus stated, recursive locking is generally poor taste and
> indicates you basically gave up on trying to find a proper locking
> scheme. We should very much work towards getting rid of these
> abberations instead of adding new ones.

The people complaining about naming never seem to be the ones providing
workable suggestions or patches.

> Linus is very much right on what he said, and you calling him delusional
> only high-lights your ignorance on the issue.
> 
> [ PS. -rt implements rwlock_t as a proper recursive lock (either a mutex
>   or a full multi-owner reader-writer lock with PI fairness) so if
>   anybody abuses rwlock_t unfairness in a way that is not strict owner
>   recursive we have a problem. ]

Name it "dog's breath locking" for all I care. I am not bothering
with arguments over names; there is real work to do elsewhere.
