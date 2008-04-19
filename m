From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: add destructor for skb data (rewritten)
Date: Sat, 19 Apr 2008 02:35:24 -0700 (PDT)
Message-ID: <20080419.023524.75551453.davem@davemloft.net>
References: <200804181421.25828.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maxk@qualcomm.com,
	herbert@gondor.apana.org.au
To: rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35513
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751999AbYDSJf0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Apr 2008 05:35:26 -0400
In-Reply-To: <200804181421.25828.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rusty Russell <rusty@rustcorp.com.au>
Date: Fri, 18 Apr 2008 14:21:25 +1000

> If we want to notify something when an skb is truly finished (such as
> for tun vringfd support), we need a destructor on the data.
> 
> This turns out to be slightly non-trivial as fragments from one skb
> get copied to another skb: if the first skb has a destructor (or its
> parent does) we need to keep a reference to it and destroy it only
> when (all the) children are destroyed.  We add an 'orig' pointer to
> the skb_shared_info to do this.
> 
> But there's currently no way to get from the shinfo to the head (to
> kfree it), so we add a 'len' field.  A better alternative to this
> might be to move the skb_shared_info to before the head of the skb data.
> 
> Note that the destructor is responsible for calling kfree: for the tun
> device, this is critical since the destructor can be called from any
> context and it has to do a copy_to_user, so it queues the skb.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

I'm mostly ambivalent but I will say I'm not happy about all of this
extra state you're adding even though it's "only" to the SKB data
shared-info struct and not sk_buff properly.

Does this handle SKB frags of arbitrary depth?  SKB's can be nested to
arbitrary depths via the frag mechanism.
