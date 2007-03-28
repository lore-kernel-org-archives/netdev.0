From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: RFC: Established connections hash function
Date: Wed, 28 Mar 2007 15:50:47 +0200
Message-ID: <20070328155047.4112fb47.dada1@cosmosbay.com>
References: <10189ABA61CF4D5AB3881F96C9CACE87@XEON>
	<p73lkhi6aj7.fsf@bingen.suse.de>
	<EED7DAB373CC4CB9B576EE1B1FBC9E32@XEON>
	<200703281129.43783.ak@suse.de>
	<20070328104505.GA18748@2ka.mipt.ru>
	<p73y7lh316u.fsf@bingen.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Evgeniy Polyakov <johnpol@2ka.mipt.ru>, nikb@webmaster.com,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:32969 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751844AbXC1Nus (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 09:50:48 -0400
In-Reply-To: <p73y7lh316u.fsf@bingen.suse.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 28 Mar 2007 16:14:17 +0200
Andi Kleen <andi@firstfloor.org> wrote:
> TCP tends to be initialized early before there is anything
> good in the entropy pool.
> 
> static void init_std_data(struct entropy_store *r)
> {
>         struct timeval tv;
>         unsigned long flags;
> 
>         spin_lock_irqsave(&r->lock, flags);
>         r->entropy_count = 0;
>         spin_unlock_irqrestore(&r->lock, flags);
> 
>         do_gettimeofday(&tv);
>         add_entropy_words(r, (__u32 *)&tv, sizeof(tv)/4);
>         add_entropy_words(r, (__u32 *)utsname(),
>                           sizeof(*(utsname()))/4);
> }
> 
> utsname is useless here because it runs before user space has 
> a chance to set it. The only truly variable thing is the 
> boot time, which can be guessed with the ns part being brute forced.
> 
> To make it secure you would need to do regular rehash like
> the routing cache which would pick up true randomness on the first
> rehash.

Good point, but :

1) We can now use "struct timespec" to get more bits in init_std_data()

2) tcp ehash salt is initialized at first socket creation, not boot time. Maybe we have more available entropy at this point.

3) We dont want to be 'totally secure'. We only want to raise the level, and eventually see if we have to spend more time on this next year(s). AFAIK we had two different reports from people being hit by the flaw of previous hash. Not really a critical issue.

4) We could add a hard limit on the length of one chain. Even if the bad guys discover a flaw, it wont hurt too much.
