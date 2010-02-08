From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: Re: MAX_SKB_FRAGS and GRO
Date: Mon, 8 Feb 2010 09:41:58 -0800 (Pacific Standard Time)
Message-ID: <alpine.WNT.2.00.1002080936180.6892@jbrandeb-desk1.amr.corp.intel.com>
References: <20100208100306.GQ32246@kryten> <20100208124704.GA8538@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Anton Blanchard <anton@samba.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Duyck, Alexander H" <alexander.h.duyck@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"divy@chelsio.com" <divy@chelsio.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:34719 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752292Ab0BHRl7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Feb 2010 12:41:59 -0500
In-Reply-To: <20100208124704.GA8538@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Feb 2010, Herbert Xu wrote:
> On Mon, Feb 08, 2010 at 09:03:07PM +1100, Anton Blanchard wrote:
> > 
> > I was looking through the hardware GRO support in various drivers and I think
> > we have a couple of issues with PAGE_SIZE > 4k. For example, if we have a 64kB
> > page size then MAX_SKB_FRAGS ends up as 3:
> > 
> > #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
> > 
> > This should be fine for hardware and software GSO, but we encounter issues
> > with hardware GRO (not sure about software GRO).
> > 
> > In the ixgbe case we use MAX_SKB_FRAGS to program the max number of GRO
> > descriptors, even though we assemble GRO packets using ->frag_list:
> > 
> > #if (MAX_SKB_FRAGS > 16)
> >                 rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
> > #elif (MAX_SKB_FRAGS > 8)
> >                 rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
> > #elif (MAX_SKB_FRAGS > 4)
> >                 rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
> > #else
> >                 rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
> > #endif
> 
> First of all this isn't GRO, but RSC.  With GRO we impose extra
> restrictions on what packets can be merged while RSC is more
> permissive.

Herbert is right.  Just for clarity lets not call it "hardware GRO" but 
instead just call it RSC or hardware RSC (receive side coalescing)
 
> In fact I think the ixgbe code may be broken as it is since it's
> not marking RSC packets in any way to prevent them from being
> forwarded through another interface.

Herbert, what are we missing? Is there some interface for us to do what 
you describe?  do we need to set DODGY?
 
> As to your problem with RSC on a 64K page system, I'm sure one
> of the Intel developers would be able to help you out.

I'm here, Anton, what can I do or test specifically for you?
  
> > Thinking out aloud, would setting a pessimistic value for MAX_SKB_FRAGS
> > be one way to fix this? ie:
> > 
> > #define MAX_SKB_FRAGS (65536/4096 + 2)
> 
> While I can't think of any serious issues with this, as this is
> an entirely ixgbe-specific problem, the fix should probably stay
> there.

I've always seen MAX_SKB_FRAGS as being the primary way of making sure 
that an SKB never has more than 64kB of data in it.  If we can stuff > 
64kB of data in an skb then some of the above problem with 64kB pages goes 
away.
