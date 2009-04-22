From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH] netfilter: use per-cpu recursive lock (v11)
Date: Wed, 22 Apr 2009 13:18:17 +0200
Message-ID: <20090422111817.GA21190@elte.hu>
References: <18924.59347.375292.102385@cargo.ozlabs.ibm.com> <20090420215827.GK6822@linux.vnet.ibm.com> <18924.64032.103954.171918@cargo.ozlabs.ibm.com> <20090420160121.268a8226@nehalam> <alpine.LFD.2.00.0904210831560.2199@localhost.localdomain> <20090421111541.228e977a@nehalam> <20090421191007.GA15485@elte.hu> <49EE2293.4090201@cosmosbay.com> <20090422073524.GA31835@elte.hu> <49EEDAF0.2010507@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Mackerras <paulus@samba.org>, paulmck@linux.vnet.ibm.com,
	Evgeniy Polyakov <zbr@ioremap.net>,
	David Miller <davem@davemloft.net>, kaber@trash.net,
	jeff.chua.linux@gmail.com, laijs@cn.fujitsu.com,
	jengelh@medozas.de, r000n@r000n.net, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	benh@kernel.crashing.org, mathieu.desnoyers@polymtl.ca
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <49EEDAF0.2010507@cosmosbay.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Eric Dumazet <dada1@cosmosbay.com> wrote:

> netfilter in 2.6.2[0-9] used :
> 
> CPU 1
> 
> sofirq handles one packet from a NIC
> 
> ipt_do_table() /* to handle INPUT table for example, or FORWARD */
> read_lock_bh(&a_central_and_damn_rwlock)
> ... parse rules
>     -> calling some netfilter sub-function
>        re-entering network IP stack to send some packet (say a RST packet)
>        ...
>        ipt_do_table() /* to handle OUPUT table rules for example */
>        read_lock_bh() ; /* WE RECURSE here, but once in a while (if ever) */
> 
> This is one of the case, but other can happens with virtual 
> networks, tunnels, ... and so on. (Stephen had some cases with KVM 
> if I remember well)
> 
> If this could be done without recursion, I am pretty sure 
> netfilter and network guys would have done it. I found Linus 
> reaction quite shocking IMHO, considering hard work done by all 
> people on this.

Again ... i dont know this code well, but you yourself describe it 
as "a_central_and_damn_rwlock" above.

"Central and damn" locks of any type, anywhere tend to cause such 
trouble.

Often they are mini-BKL's in the making. Here's some historic 
patterns:

 1- First there's a convenient lock around a popular and useful 
    piece of data and code.

 2- As popularity (and reach of code) grows, and some non-trivial 
    interaction ensues, a little bit of self-recursion is added to 
    the mix (this is often easier to do than to fix the root cause 
    of the problem) - making critical sections even easier to grow 
    in size.

 3- Then attempts are made to make it scale all (it's a popular 
    piece of code), it's extended along a per-cpu axis, but 
    complexity of locking explode by taking a ton of locks all at 
    once. The solution: yell at the lock validator for not allowing
    this (or for exploding due to the sheer mathematically 
    large complexity of the locking rules). Frequent requests for
    an exclusion from those pesky validations are made, and various
    hacks are done to work it around. It's all the fault of the lock
    validator, of course.

 4- At this point it's rarely a clean, tidy data lock anymore - it 
    tends to grow into a code lock nobody really knows how it works, 
    except that it better be taken more often than not, badness may
    ensue otherwise. Nobody really knows when to take it, only that 
    it should be taken widely enough, that it should be recursive 
    enough to call even _more_ code from under it. Efforts to reduce 
    critical section length are rebuffed with: "this adds unlocking
    and relocking overhead". And it should then all scale as well.

 5- In the end it's a lock everyone curses but nobody is able to fix 
    anymore. "If it was easy to fix we'd have fixed it long ago 
    already" kind of fatalist thinking becomes widespread.

We saw many examples of this in the past: beyond the BKL (which is a 
bit special as its more of an UP legacy - but which hurt us the 
most), we had the tasklist_lock which was problematic for a long 
time, then there's also the reiser3 locking which was extremely 
monolithic. [ i'm only naming safe examples here, where nobody will 
flame me =B-) ]

Whether this particular case applies is up to you. I see certain 
matches up to phase 3 or so - but i also see certain dissimilarities 
as well. Nor do i claim that it's easy to fix or improve.

	Ingo
