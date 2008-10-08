From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: [PATCH 18/32] net: sk_allocation() - concentrate socket
	related allocations
Date: Wed, 08 Oct 2008 08:25:41 +0200
Message-ID: <1223447141.1378.7.camel@lappy.programming.kicks-ass.net>
References: <20081002130504.927878499@chello.nl>
	 <20081002131608.821584767@chello.nl>
	 <20081007.142624.145010147.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org, trond.myklebust@fys.uio.no,
	dlezcano@fr.ibm.com, penberg@cs.helsinki.fi, neilb@suse.de,
	Suresh Jayaraman <sjayaraman@suse.de>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:57809 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751021AbYJHGZq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 02:25:46 -0400
In-Reply-To: <20081007.142624.145010147.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-10-07 at 14:26 -0700, David Miller wrote:
> From: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Date: Thu, 02 Oct 2008 15:05:22 +0200
> 
> > @@ -952,6 +955,7 @@ static void tcp_v6_send_reset(struct soc
> >  #ifdef CONFIG_TCP_MD5SIG
> >  	struct tcp_md5sig_key *key;
> >  #endif
> > +	gfp_t gfp_mask = GFP_ATOMIC;
> >  
> >  	if (th->rst)
> >  		return;
> > @@ -969,13 +973,16 @@ static void tcp_v6_send_reset(struct soc
> >  		tot_len += TCPOLEN_MD5SIG_ALIGNED;
> >  #endif
> >  
> > +	if (sk)
> > +		gfp_mask = sk_allocation(skb->sk, gfp_mask);
> > +
> >  	/*
> >  	 * We need to grab some memory, and put together an RST,
> >  	 * and then put it into the queue to be sent.
> >  	 */
> >  
> >  	buff = alloc_skb(MAX_HEADER + sizeof(struct ipv6hdr) + tot_len,
> > -			 GFP_ATOMIC);
> > +			 sk_allocation(sk, GFP_ATOMIC));
> >  	if (buff == NULL)
> >  		return;
> >  
> 
> I don't think this is doing what you intend it to do.
> 
> First, you're conditionally calling sk_allocation() if
> 'sk' is non-NULL.  But then later you unconditionally
> use sk_allocation() in the alloc_skb() call.
> 
> Furthermore, in the conditionalized case you're using
> "skb->sk" instead of plain "sk" which is what you actually
> checked against NULL.
> 
> I have no fundamental problem with this change, so please
> audit this patch for similar problems, fix them all up,
> and resubmit.
> 
> I'm also tossing the rest of your networking changes since
> they'll have some dependency on this one, please resend those
> at the same time as the fixed up version of this one.

You're right - Suresh Jayaraman hit an oops here, just fixing up that
obviously mis-merged conditional didn't fix it for him. So I'll work on
fixing this for him.

Then I'll make a new patch-series against linux-next and include the
driver parts you left out of 17.

Thanks!

