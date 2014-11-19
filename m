From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: ipx: fix locking regression in ipx_sendmsg and ipx_recvmsg
Date: Wed, 19 Nov 2014 09:32:54 +0100
Message-ID: <1609909.1jJeqOzgZ8@wuerfel>
References: <20141117013448.GA26743@midget.suse.cz> <8698539.evYG7fs8jS@wuerfel> <20141118221057.GA13473@midget.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.10]:59833 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750712AbaKSIdJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 03:33:09 -0500
In-Reply-To: <20141118221057.GA13473@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 18 November 2014 23:10:57 Jiri Bohac wrote:
> On Tue, Nov 18, 2014 at 02:37:26PM +0100, Arnd Bergmann wrote:
> > Does ipxrtr_route_packet() actually sleep while waiting for the network,
> > or is it possible that you only need to change the recvmsg path?
> 
> You're right. 
> In fact, it can sleep in sock_alloc_send_skb(), but my patch does
> not fix this - it releases the lock after that.
> So let's ignore that for now, I'll send a V2 modifying only
> ipx_recvmsg().

Ok.

> > >  	if (sock_flag(sk, SOCK_ZAPPED))
> > > -		goto out;
> > > +		goto out_release;
> > >  
> > > +	release_sock(sk);
> > >  	skb = skb_recv_datagram(sk, flags & ~MSG_DONTWAIT,
> > >  				flags & MSG_DONTWAIT, &rc);
> > >  	if (!skb) {
> > 
> > Same thing here: I think your patch could be simplified if you just
> > release the socket lock before calling skb_recv_datagram and get
> > it back afterwards, 
> 
> It would simplify the code a little to just get the lock again.
> But do we really want to optimize for source code size at the cost of
> taking locks that are not necessarry?

I'm more interested in the code structure, in particular this bit

@@ -1807,8 +1812,10 @@ static int ipx_recvmsg(struct kiocb *iocb, struct socket *sock,
 
        rc = skb_copy_datagram_iovec(skb, sizeof(struct ipxhdr), msg->msg_iov,
                                     copied);
-       if (rc)
-               goto out_free;
+       if (rc) {
+               skb_free_datagram(sk, skb);
+               goto out;
+       }


after your change mixes coding styles: in some failure cases you just goto
a cleanup part, in other cases you do the cleanup before the goto.

If I'm reading the patch correctly, this change has introduced a leak
because you no longer call skb_free_datagram() in the success case.
Changing the locking only around the skb_recv_datagram() call would
have avoided this problem or at least (if I'm reading it wrong and
the patch is indeed correct) have made it easier to review what the
new code flow and what the change is.

> > and it would be much simpler if you could show that the lock is
> > not needed at all.
> 
> At least the ipxitf_insert_socket() inside __ipx_bind() looks
> like it must be protected not to corrupt the intrfc->if_sklist.
> I am not familiar with the code, so there may be other things.

Ok. Better to do just a less invasive change then. Clearly this code
is not getting much testing, so leaving the locking in place (aside
from fixing the bug) seems the better choice.

	Arnd
