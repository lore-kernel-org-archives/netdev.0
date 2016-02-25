From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: [PATCH net 1/5] ppp: lock ppp structure before modifying mru in
 ppp_ioctl()
Date: Thu, 25 Feb 2016 20:16:55 +0100
Message-ID: <20160225191655.GA1462@alphalink.fr>
References: <cover.1456167043.git.g.nault@alphalink.fr>
 <be5fc2cf38f44951ea15f366bc52fb4d780009d2.1456167043.git.g.nault@alphalink.fr>
 <20160224.153202.880408949435562278.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, paulus@samba.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:40884 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933590AbcBYTRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Feb 2016 14:17:01 -0500
Content-Disposition: inline
In-Reply-To: <20160224.153202.880408949435562278.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 24, 2016 at 03:32:02PM -0500, David Miller wrote:
> From: Guillaume Nault <g.nault@alphalink.fr>
> Date: Mon, 22 Feb 2016 20:47:13 +0100
> 
> > PPP's Tx and Rx paths read ppp->mru under protection of ppp_xmit_lock()
> > and ppp_recv_lock() respectively.
> > Therefore ppp_ioctl() must hold the xmit and recv locks before
> > concurrently updating ppp->mru.
> > 
> > Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
>  ...
> > diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_generic.c
> > index fc8ad00..4d342ae 100644
> > --- a/drivers/net/ppp/ppp_generic.c
> > +++ b/drivers/net/ppp/ppp_generic.c
> > @@ -654,7 +654,10 @@ static long ppp_ioctl(struct file *file, unsigned int cmd, unsigned long arg)
> >  	case PPPIOCSMRU:
> >  		if (get_user(val, p))
> >  			break;
> > +		ppp_lock(ppp);
> >  		ppp->mru = val;
> > +		ppp_unlock(ppp);
> > +
> 
> I see no bug here at all.
> 
> The store here is atomic, and all of those mentioned code paths only
> read the MRU once and then use that value for the duration of the
> rest of the processing of that PPP frame.
> 
Ok, I didn't think we could assume atomic stores for int on all arch.

> No possible corruptions or misbehavior can occur and I therefore think
> the lack of locking here is completely legitimate.
> 
Then this is also legitimate for most of the other fields considered in
this series. I'll drop the patches.

One exception is the n_channels and flags fields (patch #2). The update
side is done with read-modify-write instructions ('ppp->flags &= ~XXX'
in ppp_ccp_closed(), '++ppp->n_channels' in ppp_connect_channel()). So
locking should be required. I haven't succeeded in triggering any
misbehaviour from userspace though.

> You absolutely must demonstrate a case of corruption or misbehavior
> when you want to add supposedly "missing locking".  Otherwise I'll have
> a hard time accepting your changes.  This is especially for a subsystem
> that as been around as long as PPP.
Understood. Just to be sure, does patch #2 falls under lack of
demonstration? Or should I repost it separately?
