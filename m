From: "David S. Miller" <davem@redhat.com>
Subject: Re: dev->destructor
Date: Fri, 02 May 2003 20:46:28 -0700 (PDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030502.204628.35664814.davem@redhat.com>
References: <20030502.134804.78707298.davem@redhat.com>
	<20030503040949.804182C003@lists.samba.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, shemminger@osdl.org, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: rusty@rustcorp.com.au
In-Reply-To: <20030503040949.804182C003@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

   From: Rusty Russell <rusty@rustcorp.com.au>
   Date: Sat, 03 May 2003 14:07:41 +1000

   I imagined schemes where the kernel would be basically stopped during
   module remove, so the half-remove and unremove would appear atomic.
   I shied away from implementing such a monster without deadlock, but it
   might be possible.  Then we would truly have nirvana 8)
   
I think this is an interesting area for exploration.

This isn't a unique requirement BTW Rusty.  IP conntrack rehashing
in the presence of RCU would want something just like this now
wouldn't it?  Consider other applications, such as hot plug memory.
I'm sure tons of other interesting examples could be imagined.

So indeed, the key to nirvana would indeed be here :-)

I think it can work Rusty, in short you create 1 freeze thread
per cpu.  You wake up all the freeze threads on non-local cpus,
and they indicate their presence via some bitmask.

Once the master cpu sees all non-local-cpu bits set in the bitmask,
it begins the unload sequence, after the unload the cpu mask is
cleared and this signals the freeze threads to break from their spin
loops and schedule().

This means the local master cpu executes the unload sequence.  It may
sleep in order to yield to, for example, semaphore holders, it may
also sleep to yield to kswapd and friends for the sake of memory
allocation.  I mean... consider all the situations and please try to
find some hole in this.  We can make all try_to_*() sleep at this
time too... this in particular needs more thought.

To make these freeze threads globally useful, we allow them to
run atomicity commands.  The two defined commands are "local_irq_*()"
and "local_bh_*()", two bitmasks control this and the freeze threads
check the bits in their spin loops.

Do you see?  Maybe... it is nearly Nirvana! :-)))))

Our ability to implement this changes the rest of the conversation,
so let us resolve this first.
