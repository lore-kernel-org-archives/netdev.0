From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] net: add destructor for skb data (rewritten)
Date: Sun, 20 Apr 2008 02:20:39 +1000
Message-ID: <200804200220.39985.rusty@rustcorp.com.au>
References: <200804181421.25828.rusty@rustcorp.com.au> <20080419.023524.75551453.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxk@qualcomm.com,
	herbert@gondor.apana.org.au
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:60492 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752627AbYDSQUo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 19 Apr 2008 12:20:44 -0400
In-Reply-To: <20080419.023524.75551453.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 19 April 2008 19:35:24 David Miller wrote:
> From: Rusty Russell <rusty@rustcorp.com.au>
> Date: Fri, 18 Apr 2008 14:21:25 +1000
>
> > If we want to notify something when an skb is truly finished (such as
> > for tun vringfd support), we need a destructor on the data.
> >
> > This turns out to be slightly non-trivial as fragments from one skb
> > get copied to another skb: if the first skb has a destructor (or its
> > parent does) we need to keep a reference to it and destroy it only
> > when (all the) children are destroyed.  We add an 'orig' pointer to
> > the skb_shared_info to do this.
> >
> > But there's currently no way to get from the shinfo to the head (to
> > kfree it), so we add a 'len' field.  A better alternative to this
> > might be to move the skb_shared_info to before the head of the skb data.
> >
> > Note that the destructor is responsible for calling kfree: for the tun
> > device, this is critical since the destructor can be called from any
> > context and it has to do a copy_to_user, so it queues the skb.
> >
> > Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
>
> I'm mostly ambivalent but I will say I'm not happy about all of this
> extra state you're adding even though it's "only" to the SKB data
> shared-info struct and not sk_buff properly.

Me neither.  Moving the shared_info to the front of the data would reduce it 
to two fields for me (removing len and destructor arg), but I held off for 
now because this is a lesser change and possible for 2.6.26.

> Does this handle SKB frags of arbitrary depth?  SKB's can be nested to
> arbitrary depths via the frag mechanism.

It doesn't matter in this case.  It's the skb creator who sets the destructor, 
and wants it called when all pages in shinfo->frags[] are done with.  If it 
wanted to also include the frag_list in this lifetime, it would simply 
set ->orig on those skbs's shinfo to point back to the head shinfo, and 
adjust dataref accordingly.

As long as the anyone referencing a frags page from an skb into another sets 
the orig ptr & bumps dataref, this will work.  If someone kept a reference to 
a page and then freed the skb it game from, we're already broken.

You could think of it as a 'struct request' for networking.  Or not.

Cheers,
Rusty.
