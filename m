From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Followup to netpoll issues
Date: Sat, 8 Jan 2005 00:18:15 +0100
Message-ID: <20050107231815.GC17317@electric-eye.fr.zoreil.com>
References: <1105045914.7687.3.camel@tigger> <20050107002053.GD27896@electric-eye.fr.zoreil.com> <1105128887.3814.20.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matt Mackall <mpm@selenic.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mark Broadbent <markb@wetlettuce.com>
Content-Disposition: inline
In-Reply-To: <1105128887.3814.20.camel@localhost>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Mark Broadbent <markb@wetlettuce.com> :
[...]
> No need, if netpoll_cleanup is called whilst a retry is pending the tx
> list lock is taken.  All the references to the netpoll pointer are
> deleted from the pending list before the lock is released.

I may be a bit dense but:

t0             : tx_retry_wq().queue_delayed_work(tx_wq, &tx_wq_obj, HZ/100);

t0 + 10*HZ/1000: tx_retry_wq() is done (it was not fast for sure)

t0 + 20*HZ/1000: netpoll_cleanup() + module removal

t0 + HZ/100    : tx_retry_wq() <- Where are its code and data ?

[...]
> > However netpoll_send_skb can be called through:
> > netpoll_rx -> arp_reply -> netpoll_send_skb
> > Here I fail to see why netpoll_cleanup could not happen at the same time
> > and issue np->dev = NULL;
> 
> Could this solved by having a per netpoll structure rw_lock to protect
> against changing elements in the structure?
> 
> e.g. 
> struct netpoll {
> 	...
> 	rwlock_t netpoll_lock;
> };
> 
> write_lock_irqsave(&np->netpoll_lock, flags);
> np->dev = NULL;
> write_unlock_irqsave(&np->netpoll_lock, flags);

I am not sure that a fine coarsed lock is necessary since there
will mostly be readers and netpoll_cleanup should be rare.

[...]
> Is it safe to issue spin_lock_irqsave/spin_unlock_restore in this
> context?  Reason: What if it wasn't netconsole calling netpoll_send_udp
> and not with local interrupts disabled?

The irq state is saved and restored.

Did I get the question right ?

[...]
> I've attached a revised version.
> 
> Thanks for you comments (and Matts)

The malloc() in netpoll_send_skb() is heavy-weight and it is not that
uncommon to fail allocation in network context: preallocate when the
np is first set up. It will make netpoll_send_skb() lighter.

Issue schedule_delayed_work() in netpoll_send_skb() only if when the
task is not already scheduled ? It is an information you can get/set
while tx_list_lock is taken.

I'll read the patch (or any updated version) more closely once I have
recovered my sleep quota. It should not be too hard to isolate the
queueing specific stuff from the real fixes.

--
Ueimor
