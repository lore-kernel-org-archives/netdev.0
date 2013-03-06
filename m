From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] bnx2x: use the default NAPI weight
Date: Wed, 06 Mar 2013 14:59:47 -0500 (EST)
Message-ID: <20130306.145947.1445904594058156164.davem@davemloft.net>
References: <1362540509.15793.158.camel@edumazet-glaptop>
	<20130305.233744.498353801662910535.davem@davemloft.net>
	<1362553398.15793.168.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eilong@broadcom.com, jhs@mojatatu.com,
	herbert@gondor.apana.org.au
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58767 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752977Ab3CFT7t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Mar 2013 14:59:49 -0500
In-Reply-To: <1362553398.15793.168.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 05 Mar 2013 23:03:18 -0800

> On Tue, 2013-03-05 at 23:37 -0500, David Miller wrote:
> 
>> Thanks for the explanation.
>> 
>> Since you haven't completely resolved the issues you were running into
>> I'll target this to net-next for now.
> 
> Thanks David
> 
> An other issue is the spin_trylock() attempted in net_tx_action()
> 
> It seems we can miss a qdisc_run(), and have to wait the following
> NET_TX softirq(s) to send more data. NET_RX being interleaved, we can
> have to wait a long time (not mentioning other softirq handlers like
> RCU ...)
> 
> I might be too tired right now, but cant see the reason of the trylock.
> 
> qdisc lock is already BH safe, so we should do a spinlock
 ...
> @@ -3201,22 +3201,11 @@ static void net_tx_action(struct softirq_action *h)
>  			head = head->next_sched;
>  
>  			root_lock = qdisc_lock(q);
> -			if (spin_trylock(root_lock)) {
> -				smp_mb__before_clear_bit();
> -				clear_bit(__QDISC_STATE_SCHED,
> -					  &q->state);
> -				qdisc_run(q);
> -				spin_unlock(root_lock);

I think this trylock is intentional, but not to deal with BH safeness,
but rather to allow another cpu already processing the qdisc to
continue doing so.

I think this is what Jamal's amazing flash animations back at netconf
in Toronto were all about :-)

Herbert Xu and Jamal have touched upon this issue several times in
the past.
