From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: locking api self-test hanging
Date: Tue, 4 Mar 2008 07:51:37 -0800
Message-ID: <20080304075137.6bbd285f@extreme>
References: <20080303210540.cea55e13.akpm@linux-foundation.org>
	<20080304084024.GA3980@ff.dom.local>
	<20080304011050.74f30dd3.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:33343 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755747AbYCDPwX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Mar 2008 10:52:23 -0500
In-Reply-To: <20080304011050.74f30dd3.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 4 Mar 2008 01:10:50 -0800
Andrew Morton <akpm@linux-foundation.org> wrote:

> On Tue, 4 Mar 2008 08:40:24 +0000 Jarek Poplawski <jarkao2@gmail.com> wrote:
> 
> > On 04-03-2008 06:05, Andrew Morton wrote:
> > ...
> > >>>> And I've fully bisected this hang twice and both times came up with
> > >>>>
> > >>>> commit 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7
> > >>>> Author: Stephen Hemminger <shemminger@linux-foundation.org>
> > >>>> Date:   Mon Nov 19 19:24:52 2007 -0800
> > >>>>
> > >>>>     [NETPOLL]: Kill NETPOLL_RX_DROP, set but never tested.
> > >>>>
> > >>>> which is stupid because that patch doesn't do anything.
> > 
> > ...or maybe apparently doesn't do anything?
> > 
> > @@ -128,13 +127,11 @@ static int poll_one_napi(struct netpoll_info *npinfo,
> >         if (!test_bit(NAPI_STATE_SCHED, &napi->state))
> >                 return budget;
> >  
> > -       npinfo->rx_flags |= NETPOLL_RX_DROP;
> > 
> > 
> > But in a next patch we can see:
> > 
> > @@ -51,12 +50,12 @@ static inline int netpoll_rx(struct sk_buff *skb)
> >         unsigned long flags;
> >         int ret = 0;
> >  
> > -       if (!npinfo || (!npinfo->rx_np && !npinfo->rx_flags))
> > +       if (!npinfo || !npinfo->rx_np)
> > 
> > So, it seems rx_flags could have been tested here for NETPOLL_RX_DROP
> > yet?
> > 
> 
> Oh damn.  I bisected this three times and the second two times both landed on
> this:
> 
> 
> commit 33f807ba0d9259e7c75c7a2ce8bd2787e5b540c7
> Author: Stephen Hemminger <shemminger@linux-foundation.org>
> Date:   Mon Nov 19 19:24:52 2007 -0800
> 
>     [NETPOLL]: Kill NETPOLL_RX_DROP, set but never tested.
>     
>     Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> diff --git a/net/core/netpoll.c b/net/core/netpoll.c
> index cf6acd3..9e3aea0 100644
> --- a/net/core/netpoll.c
> +++ b/net/core/netpoll.c
> @@ -40,7 +40,6 @@ static atomic_t trapped;
>  
>  #define USEC_PER_POLL	50
>  #define NETPOLL_RX_ENABLED  1
> -#define NETPOLL_RX_DROP     2
>  
>  #define MAX_SKB_SIZE \
>  		(MAX_UDP_CHUNK + sizeof(struct udphdr) + \
> @@ -128,13 +127,11 @@ static int poll_one_napi(struct netpoll_info *npinfo,
>  	if (!test_bit(NAPI_STATE_SCHED, &napi->state))
>  		return budget;
>  
> -	npinfo->rx_flags |= NETPOLL_RX_DROP;
>  	atomic_inc(&trapped);
>  
>  	work = napi->poll(napi, budget);
>  
>  	atomic_dec(&trapped);
> -	npinfo->rx_flags &= ~NETPOLL_RX_DROP;
>  
>  	return budget - work;
>  }
> @@ -475,7 +472,7 @@ int __netpoll_rx(struct sk_buff *skb)
>  	if (skb->dev->type != ARPHRD_ETHER)
>  		goto out;
>  
> -	/* check if netpoll clients need ARP */
> +	/* if receive ARP during middle of NAPI poll, then queue */
>  	if (skb->protocol == htons(ETH_P_ARP) &&
>  	    atomic_read(&trapped)) {
>  		skb_queue_tail(&npi->arp_tx, skb);
> @@ -537,6 +534,9 @@ int __netpoll_rx(struct sk_buff *skb)
>  	return 1;
>  
>  out:
> +	/* If packet received while already in poll then just
> +	 * silently drop.
> +	 */
>  	if (atomic_read(&trapped)) {
>  		kfree_skb(skb);
>  		return 1;
> 
> and I stupidly assumed that it couldn't be this commit because it was a
> no-op.  I didn't think to look for an _impicit_ test of NETPOLL_RX_DROP
> such as the one above.  That's pretty poor style IMO :(
> 
> 
> That bisecting took me several hours and at the time I hoped that it would
> receive a more-than-zero response.  btw.

Mia culpa, individual tests of the netconsole when I did the patch worked.
But obviously didn't stress it enough or trigger that drop code.

Plus, I didn't believe the bisect.
