From: Willy Tarreau <w@1wt.eu>
Subject: Re: [BUG] null pointer dereference in tcp_gso_segment()
Date: Thu, 23 Jan 2014 00:56:51 +0100
Message-ID: <20140122235651.GA20227@1wt.eu>
References: <87r47z7kqo.fsf@natisbad.org> <1390427824.27806.36.camel@edumazet-glaptop2.roam.corp.google.com> <8761pb7jzq.fsf@natisbad.org> <1390429125.27806.40.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arnaud Ebalard <arno@natisbad.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:55722 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753734AbaAVX5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 18:57:09 -0500
Content-Disposition: inline
In-Reply-To: <1390429125.27806.40.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 02:18:45PM -0800, Eric Dumazet wrote:
> On Wed, 2014-01-22 at 23:02 +0100, Arnaud Ebalard wrote:
> > Hi Eric,
> > 
> > Eric Dumazet <eric.dumazet@gmail.com> writes:
> > 
> > >> Unless there is an assumption I missed somewhere in the function, the
> > >> problem may occur during the first round of the loop, because (unlike
> > >> the 'while' condition does at line 21) skb->next is not checked against
> > >> null at lines 17 above before it is passed to tcp_hdr() at line 18.
> > >> 
> > >> To be honest, I am asking because I am not familiar w/ the code and it
> > >> is somewhat old so I wonder why noone got hit before. AFAICT,
> > >> f4c50d990dcf ([NET]: Add software TSOv4) added TSOv4 support in 2006 via
> > >> introduction of tcp_tso_segmen() (with the same kind of deref but
> > >> possibly different assumptions) which was more recently modified via
> > >> 28850dc7c7 (net: tcp: move GRO/GSO functions to tcp_offload) to become
> > >> tcp_gso_segment().
> > >> 
> > >> David, can you confirm the analysis and possibly comment on the
> > >> conditions needed for the bug to manifest?
> > >
> > > A gso packet contains at least 2 segments.
> > 
> > By whom / where is it enforced?
> 
> For example, tcp_gso_segment() does the following check :
> 
> if (unlikely(skb->len <= mss))
> 	goto out;
> 
> If there was one segment, then skb->len should also be smaller than mss
> 
> Since TCP stack seemed to be the provider of the packet in your stack
> trace, check tcp_set_skb_tso_segs()

Thanks Eric for the explanation. From Arnaud's trace, I suspect that he's
received an ACK which has released some pending data, so it's very likely
indeed that at least two segments were released at once given that the
receiver is likely to ACK every two segments.

Also we can expect that the received ACK was copy-breaked. I don't know
if some sort of skb recycling may happen at this stage and reveal some
bad corner cases (eg: improperly initialized skb during the rx path that
causes everything to break when it's recycled for the tx path), but Arnaud
you can easily disable the rx_copybreak feature by setting the rx_copybreak
module argument to zero. You can change it at run time in /sys/module. At
least it will tell us if it could be related or not.

Regards,
Willy
