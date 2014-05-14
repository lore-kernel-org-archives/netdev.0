From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] tcp: set retransmit_high on loop exit
Date: Wed, 14 May 2014 11:27:18 -0700
Message-ID: <1400092038.7973.111.camel@edumazet-glaptop2.roam.corp.google.com>
References: <b1093d318477c57478b0b64475d9066710d7c75b.1399812676.git.panweiping3@gmail.com>
	 <20140514.140828.379626997254455792.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: panweiping3@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:37409 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbaENS1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 14:27:19 -0400
Received: by mail-pb0-f53.google.com with SMTP id md12so1987809pbc.26
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 11:27:18 -0700 (PDT)
In-Reply-To: <20140514.140828.379626997254455792.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-05-14 at 14:08 -0400, David Miller wrote:
> From: Weiping Pan <panweiping3@gmail.com>
> Date: Sun, 11 May 2014 20:57:30 +0800
> 
> > To save some CPU cycles slightly.
> > 
> > Signed-off-by: Weiping Pan <panweiping3@gmail.com>
> 
> Can a TCP expert please review this?
> 
> > ---
> >  net/ipv4/tcp_input.c | 8 ++++++--
> >  1 file changed, 6 insertions(+), 2 deletions(-)
> > 
> > diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
> > index d6b46eb..e431037 100644
> > --- a/net/ipv4/tcp_input.c
> > +++ b/net/ipv4/tcp_input.c
> > @@ -1941,8 +1941,13 @@ void tcp_enter_loss(struct sock *sk, int how)
> >  	tcp_clear_all_retrans_hints(tp);
> >  
> >  	tcp_for_write_queue(skb, sk) {
> > -		if (skb == tcp_send_head(sk))
> > +		if (skb == tcp_send_head(sk)) {
> > +			if (skb != tcp_write_queue_head(sk)) {
> > +				skb = tcp_write_queue_prev(sk, skb);
> > +				tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
> > +			}
> >  			break;
> > +		}
> >  
> >  		if (TCP_SKB_CB(skb)->sacked & TCPCB_SACKED_RETRANS)
> >  			tp->undo_marker = 0;
> > @@ -1952,7 +1957,6 @@ void tcp_enter_loss(struct sock *sk, int how)
> >  			TCP_SKB_CB(skb)->sacked &= ~TCPCB_SACKED_ACKED;
> >  			TCP_SKB_CB(skb)->sacked |= TCPCB_LOST;
> >  			tp->lost_out += tcp_skb_pcount(skb);
> > -			tp->retransmit_high = TCP_SKB_CB(skb)->end_seq;
> >  		}
> >  	}
> >  	tcp_verify_left_out(tp);
> > -- 

Frankly I do not see the point here.

This adds code and conditional jumps, while original code is 2
instructions with no cache line misses, and is cleaner IMHO.
