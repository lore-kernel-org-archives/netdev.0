From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] net: add a prefetch in socket backlog
 processing
Date: Tue, 01 May 2012 04:52:33 -0700
Message-ID: <1335873153.26217.35.camel@joe2Laptop>
References: <1335838029.11396.12.camel@edumazet-glaptop>
	 <1335842663.26217.10.camel@joe2Laptop>
	 <1335854091.11396.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:37966 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750915Ab2EALwq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 07:52:46 -0400
In-Reply-To: <1335854091.11396.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-05-01 at 08:34 +0200, Eric Dumazet wrote:
> On Mon, 2012-04-30 at 20:24 -0700, Joe Perches wrote:
> > On Tue, 2012-05-01 at 04:07 +0200, Eric Dumazet wrote:
> > > From: Eric Dumazet <edumazet@google.com>
> > > TCP or UDP stacks have big enough latencies that prefetching next
> > > pointer is worth it.
> > > 
> > > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > > ---
> > >  net/core/sock.c |    1 +
> > >  1 file changed, 1 insertion(+)
> > > 
> > > diff --git a/net/core/sock.c b/net/core/sock.c
> > > index 836bca6..1a88351 100644
> > > --- a/net/core/sock.c
> > > +++ b/net/core/sock.c
> > > @@ -1700,6 +1700,7 @@ static void __release_sock(struct sock *sk)
> > >  		do {
> > >  			struct sk_buff *next = skb->next;
> > >  
> > > +			prefetch(next);
> > >  			WARN_ON_ONCE(skb_dst_is_noref(skb));
> > >  			skb->next = NULL;
> > >  			sk_backlog_rcv(sk, skb);
> > 
> > Hi Eric.
> > 
> > Why should next be "prefetch"ed when
> > two lines below it's set to null and
> > the only use is as a pointer not as
> > an apparently undereferenced pointer?
> Thats because you have no idea of what is happening ?

Sometimes true.  Ask my wife though and you
might get a "almost always true" reply.

Here it's true because I just glossed over the
code and didn't notice the loop control variable
was actually next (skb).

> next points to the next skb in list (after this skb)
> 
> prefetch(next) instructs CPU to preload its cache with the memory
> content of first cache line of next skb (it contains its own ->next
> pointer)
> 
> After prefetch(next), we clear skb->next before continuing, but we later
> will need the memory we preloaded in cpu cache at next iteration.
> 
> Basically this patch avoids one memory cache miss per iteration.

That's true for cpus with sufficient cache but prefetch
might be wasteful for cpus without (like some ARMs).

Some of the sk_backlog_rcv functions like tcp_v4_do_rcv
can be relatively large.

It might be useful to have a target cpu compile time
test precede this prefetch.

cheers, Joe
