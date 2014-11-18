From: Jiri Bohac <jbohac@suse.cz>
Subject: Re: ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Tue, 18 Nov 2014 23:10:57 +0100
Message-ID: <20141118221057.GA13473@midget.suse.cz>
References: <20141117013448.GA26743@midget.suse.cz>
 <8698539.evYG7fs8jS@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Bohac <jbohac@suse.cz>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:41469 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753481AbaKRWLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 Nov 2014 17:11:00 -0500
Content-Disposition: inline
In-Reply-To: <8698539.evYG7fs8jS@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 02:37:26PM +0100, Arnd Bergmann wrote:
> Does ipxrtr_route_packet() actually sleep while waiting for the network,
> or is it possible that you only need to change the recvmsg path?

You're right. 
In fact, it can sleep in sock_alloc_send_skb(), but my patch does
not fix this - it releases the lock after that.
So let's ignore that for now, I'll send a V2 modifying only
ipx_recvmsg().

> >  	if (sock_flag(sk, SOCK_ZAPPED))
> > -		goto out;
> > +		goto out_release;
> >  
> > +	release_sock(sk);
> >  	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
> >  				flags & MSG_DONTWAIT, &rc);
> >  	if (!skb) {
> 
> Same thing here: I think your patch could be simplified if you just
> release the socket lock before calling skb_recv_datagram and get
> it back afterwards, 

It would simplify the code a little to just get the lock again.
But do we really want to optimize for source code size at the cost of
taking locks that are not necessarry?

> and it would be much simpler if you could show that the lock is
> not needed at all.

At least the ipxitf_insert_socket() inside __ipx_bind() looks
like it must be protected not to corrupt the intrfc->if_sklist.
I am not familiar with the code, so there may be other things.

Thanks for the review!

-- 
Jiri Bohac <jbohac@suse.cz>
SUSE Labs, SUSE CZ
