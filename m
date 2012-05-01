From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: add a prefetch in socket backlog
 processing
Date: Tue, 01 May 2012 08:34:51 +0200
Message-ID: <1335854091.11396.21.camel@edumazet-glaptop>
References: <1335838029.11396.12.camel@edumazet-glaptop>
	 <1335842663.26217.10.camel@joe2Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63594 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab2EAGe4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 02:34:56 -0400
Received: by wibhq7 with SMTP id hq7so3531250wib.1
        for <netdev@vger.kernel.org>; Mon, 30 Apr 2012 23:34:55 -0700 (PDT)
In-Reply-To: <1335842663.26217.10.camel@joe2Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-30 at 20:24 -0700, Joe Perches wrote:
> On Tue, 2012-05-01 at 04:07 +0200, Eric Dumazet wrote:
> > From: Eric Dumazet <edumazet@google.com>
> > 
> > TCP or UDP stacks have big enough latencies that prefetching next
> > pointer is worth it.
> > 
> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > ---
> >  net/core/sock.c |    1 +
> >  1 file changed, 1 insertion(+)
> > 
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 836bca6..1a88351 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -1700,6 +1700,7 @@ static void __release_sock(struct sock *sk)
> >  		do {
> >  			struct sk_buff *next = skb->next;
> >  
> > +			prefetch(next);
> >  			WARN_ON_ONCE(skb_dst_is_noref(skb));
> >  			skb->next = NULL;
> >  			sk_backlog_rcv(sk, skb);
> 
> Hi Eric.
> 
> Why should next be "prefetch"ed when
> two lines below it's set to null and
> the only use is as a pointer not as
> an apparently undereferenced pointer?
> 
> 

Thats because you have no idea of what is happening ?

next points to the next skb in list (after this skb)

prefetch(next) instructs CPU to preload its cache with the memory
content of first cache line of next skb (it contains its own ->next
pointer)

After prefetch(next), we clear skb->next before continuing, but we later
will need the memory we preloaded in cpu cache at next iteration.

Basically this patch avoids one memory cache miss per iteration.
