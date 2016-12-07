From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net/udp: do not touch skb->peeked unless really needed
Date: Wed, 07 Dec 2016 18:37:47 +0100
Message-ID: <1481132267.1541189.811630457.167E9C56@webmail.messagingengine.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480944138.4694.37.camel@redhat.com>
 <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
 <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481020451.6225.38.camel@redhat.com>
 <1481044098.7129.7.camel@redhat.com>
 <063D6719AE5E284EB5DD2968C1650D6DB0237532@AcuExch.aculab.com>
 <1481131924.4930.40.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Paolo Abeni <pabeni@redhat.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35714 "EHLO
        out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932366AbcLGRhs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 7 Dec 2016 12:37:48 -0500
In-Reply-To: <1481131924.4930.40.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 7, 2016, at 18:32, Eric Dumazet wrote:
> On Wed, 2016-12-07 at 17:09 +0000, David Laight wrote:
> > From: Paolo Abeni
> > > Sent: 06 December 2016 17:08
> > ...
> > > @@ -79,6 +82,9 @@ struct udp_sock {
> > >  	int			(*gro_complete)(struct sock *sk,
> > >  						struct sk_buff *skb,
> > >  						int nhoff);
> > > +
> > > +	/* since we are prone to drops, avoid dirtying any sk cacheline */
> > > +	atomic_t		drops ____cacheline_aligned_in_smp;
> > >  };
> > 
> > Isn't that likely to create a large hole on systems with large cache lines.
> > (Same as any other use of ____cacheline_aligned_in_smp.)
> 
> Yes, I would like to avoid that, unless we come to the conclusion it is
> absolutely needed.
> 
> I feel that we could simply use a pointer, and allocate memory on
> demand, since many sockets do not ever experience a drop.
> 
> The pointer could stay in a read mostly section.
> 
> We even could use per cpu or node counter for some heavy drop cases. 

I had the same idea while discussing that with Paolo, merely using an
*atomic_t = kmalloc(sizeof(atomic_t)) out of band of the socket.

My fear was that those could be aggregated by the slab cache into one
cache line, causing even more heating on cachelines.

Bye,
Hannes
