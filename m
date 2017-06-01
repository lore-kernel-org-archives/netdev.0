From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next 2/3] udp: avoid a cache miss on dequeue
Date: Thu, 01 Jun 2017 12:39:52 +0200
Message-ID: <1496313592.4872.14.camel@redhat.com>
References: <cover.1496070490.git.pabeni@redhat.com>
         <b07f7111480bb0ca2d98fe9fef49a593ab1c4787.1496070490.git.pabeni@redhat.com>
         <1496250043.27480.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:50254 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751346AbdFAKjz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 1 Jun 2017 06:39:55 -0400
In-Reply-To: <1496250043.27480.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2017-05-31 at 10:00 -0700, Eric Dumazet wrote:
> On Mon, 2017-05-29 at 17:27 +0200, Paolo Abeni wrote:
> > Since UDP no more uses sk->destructor, we can clear completely
> > the skb head state before enqueuing.
> 
> ...
> 
> > @@ -1739,6 +1740,9 @@ static int __udp_queue_rcv_skb(struct sock *sk, struct sk_buff *skb)
> >  		sk_mark_napi_id_once(sk, skb);
> >  	}
> >  
> > +	/* drop all pending head states; dst, nf and sk are dropped by caller */
> > +	secpath_reset(skb);
> > +
> 
> I wonder if using skb_release_head_state() would be more appropriate ?
> 
> Surely more descriptive and probably not more expensive since all
> cache lines should be already hot at this point.

Thank you for reviewing this.

I would prefer not adding more code to the core, but I think we would
need something new, like:

skb_reset_head_state()
{
	skb_dst_drop(skb);
        secpath_reset(skb);
        nf_reset(skb);
	skb_orphan(skb);
}

because elsewhere the skb could be in inconsistent state: skb->sp !=
NULL but with its refcount is already decremented. WDYT?

Paolo
