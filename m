From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: add tcp_add_backlog()
Date: Thu, 22 Sep 2016 16:21:30 -0700
Message-ID: <1474586490.28155.10.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1472308674.14381.226.camel@edumazet-glaptop3.roam.corp.google.com>
         <20160922223411.GA17222@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Neal Cardwell <ncardwell@google.com>,
        Yuchung Cheng <ycheng@google.com>
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:35777 "EHLO
        mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756473AbcIVXVc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 19:21:32 -0400
Received: by mail-pa0-f65.google.com with SMTP id hi10so4199326pac.2
        for <netdev@vger.kernel.org>; Thu, 22 Sep 2016 16:21:31 -0700 (PDT)
In-Reply-To: <20160922223411.GA17222@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-09-22 at 19:34 -0300, Marcelo Ricardo Leitner wrote:
> On Sat, Aug 27, 2016 at 07:37:54AM -0700, Eric Dumazet wrote:
> > +bool tcp_add_backlog(struct sock *sk, struct sk_buff *skb)
> > +{
> > +	u32 limit = sk->sk_rcvbuf + sk->sk_sndbuf;
>                                  ^^^
> ...
> > +	if (!skb->data_len)
> > +		skb->truesize = SKB_TRUESIZE(skb_end_offset(skb));
> > +
> > +	if (unlikely(sk_add_backlog(sk, skb, limit))) {
> ...
> > -	} else if (unlikely(sk_add_backlog(sk, skb,
> > -					   sk->sk_rcvbuf + sk->sk_sndbuf))) {
> 	                                                 ^---- [1]
> > -		bh_unlock_sock(sk);
> > -		__NET_INC_STATS(net, LINUX_MIB_TCPBACKLOGDROP);
> > +	} else if (tcp_add_backlog(sk, skb)) {
> 
> Hi Eric, after this patch, do you think we still need to add sk_sndbuf
> as a stretching factor to the backlog here?
> 
> It was added by [1] and it was justified that the (s)ack packets were
> just too big for the rx buf size. Maybe this new patch alone is enough
> already, as such packets will have a very small truesize then.
> 
>   Marcelo
> 
> [1] da882c1f2eca ("tcp: sk_add_backlog() is too agressive for TCP")
> 

Hi Marcelo

Yes, it is still needed, some drivers provide linear skbs, so the
skb->truesize of ack packets will likely be the same (skb->head points
to a full size frame allocated by the driver)
