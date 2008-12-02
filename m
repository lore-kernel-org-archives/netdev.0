From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [RFC PATCH 0/5] IPsec parallelization
Date: Tue, 2 Dec 2008 09:44:19 +0100
Message-ID: <20081202084419.GF13998@secunet.com>
References: <20081201071614.GP476@secunet.com> <20081201084902.GA19904@gondor.apana.org.au> <20081201.022929.253639406.davem@davemloft.net> <20081201111501.GA20650@gondor.apana.org.au> <20081202075804.GD13998@secunet.com> <20081202081948.GA30063@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	klassert@mathematik.tu-chemnitz.de
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([213.68.205.161]:54838 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751817AbYLBInc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Dec 2008 03:43:32 -0500
Content-Disposition: inline
In-Reply-To: <20081202081948.GA30063@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 02, 2008 at 04:19:48PM +0800, Herbert Xu wrote:
> On Tue, Dec 02, 2008 at 08:58:04AM +0100, Steffen Klassert wrote:
> > 
> > The parallelization/serialization interface is generic, so the crypto
> > layer can use it in the same way as xfrm.
> 
> I don't really have an opinion on the padata stuff.  What I'm
> objecting to is the way you're putting the parallelism into
> xfrm.
> 
> > The only network specific information that is used is the knowledge
> > of the xfrm_state that a packet uses. On serialization, this helps
> > to stay as parallel as possible. Packets that uses the same state must
> > go to the same cpu (because of the replay window) packets that use
> > different states can go to different cpus.
> 
> Maybe I'm missing somthing, but all you're doing is paralleising
> based on xfrm_state objects.  You can already do that trivially
> in the crypto layer with no network-specific knowledge at all
> because each xfrm_state allocates its own tfm objects.

No, it's not just parallelizing based on xfrm_states. We are running
in parallel even within the same state. That's why I'm getting a 
bandwith up to 900Mbit/s when sending one tcp stream. Parallelizing
based on state would not help that much if you are sending just one
stream.

What happens is that we are sending the packets round robin to
the different cpus on parallelization. On serialization, the
packets will be brought back to the order as they were before the 
parallelization. And to not just send all the packets back to one cpu,
I'm doing parallelization based on xfrm_state after that.

> 
> What I'm proposing is that you create a single parallel crypto
> algorithm template similar to cryptd (FWIW you could even just
> extend cryptd to do this) that does the parallel processing
> based on tfms.
> 
> This achieves exactly the same thing as your current patch-set
> plus:
> 
> 1) The uesr no longer has to make a system-wide choice of whether
> to enable this, instead the control is per-SA through the usual
> algorithm selection mechanism which means that this no longer
> conflicts with async crypto;
> 
> 2) There is no change to the xfrm code;
> 
> 3) The same mechanism can benefit other crypto users such as
> disk encryption.

The padata stuff is generic, so it can be used even for disk
encryption or for anything else that should run in parallel but
needs a certain order at a given point.
