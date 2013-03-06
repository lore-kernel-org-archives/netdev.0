From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 2/2] bnx2x: use the default NAPI weight
Date: Wed, 06 Mar 2013 13:52:57 -0800
Message-ID: <1362606777.15793.198.camel@edumazet-glaptop>
References: <1362540509.15793.158.camel@edumazet-glaptop>
	 <20130305.233744.498353801662910535.davem@davemloft.net>
	 <1362553398.15793.168.camel@edumazet-glaptop>
	 <20130306.145947.1445904594058156164.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, jhs@mojatatu.com,
	herbert@gondor.apana.org.au, Tom Herbert <therbert@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:36015 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752611Ab3CFVxB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 16:53:01 -0500
Received: by mail-pb0-f45.google.com with SMTP id ro8so6600695pbb.18
        for <netdev@vger.kernel.org>; Wed, 06 Mar 2013 13:53:00 -0800 (PST)
In-Reply-To: <20130306.145947.1445904594058156164.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-06 at 14:59 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Tue, 05 Mar 2013 23:03:18 -0800
> 
> > On Tue, 2013-03-05 at 23:37 -0500, David Miller wrote:
> > 
> >> Thanks for the explanation.
> >> 
> >> Since you haven't completely resolved the issues you were running into
> >> I'll target this to net-next for now.
> > 
> > Thanks David
> > 
> > An other issue is the spin_trylock() attempted in net_tx_action()
> > 
> > It seems we can miss a qdisc_run(), and have to wait the following
> > NET_TX softirq(s) to send more data. NET_RX being interleaved, we can
> > have to wait a long time (not mentioning other softirq handlers like
> > RCU ...)
> > 
> > I might be too tired right now, but cant see the reason of the trylock.
> > 
> > qdisc lock is already BH safe, so we should do a spinlock
>  ...
> > @@ -3201,22 +3201,11 @@ static void net_tx_action(struct softirq_action *h)
> >  			head = head->next_sched;
> >  
> >  			root_lock = qdisc_lock(q);
> > -			if (spin_trylock(root_lock)) {
> > -				smp_mb__before_clear_bit();
> > -				clear_bit(__QDISC_STATE_SCHED,
> > -					  &q->state);
> > -				qdisc_run(q);
> > -				spin_unlock(root_lock);
> 
> I think this trylock is intentional, but not to deal with BH safeness,
> but rather to allow another cpu already processing the qdisc to
> continue doing so.
> 
> I think this is what Jamal's amazing flash animations back at netconf
> in Toronto were all about :-)

Yes, but with :

- BQL (incurring more TX completion rounds and possibility to
block/unblock a qdisc)
- ticket spinlocks, and even with the guard of qdisc busylock

-> we can have a starvation problem.

I noticed on perf top sessions once cpu kept scheduling NET_TX softirqs
in (almost) infinite loops.

(if trylock() doesn't succeed, this cpu requeue this qdisc for another
net_tx_action() run)

BTW, I wonder if we should not exchange NET_TX_SOFTIRQ & NET_RX_SOFTIRQ 

Usually the net_rx_action() calls napi poll() and TX completion, and
netdev_tx_completed_queue() unblocks a qdisc (requesting a
netif_schedule_queue() -> scheduling a NT_TX_SOFTIRQ)

Or... maybe netdev_tx_completed_queue() should directly call qdisc_run()
instead of deferring it ?
