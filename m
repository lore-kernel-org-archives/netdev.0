From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: MAX_SKB_FRAGS and GRO
Date: Mon, 8 Feb 2010 23:47:04 +1100
Message-ID: <20100208124704.GA8538@gondor.apana.org.au>
References: <20100208100306.GQ32246@kryten>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	PJ Waskiewicz <peter.p.waskiewicz.jr@intel.com>,
	John Ronciak <john.ronciak@intel.com>, divy@chelsio.com,
	netdev@vger.kernel.org
To: Anton Blanchard <anton@samba.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:49855 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751300Ab0BHMrT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 07:47:19 -0500
Content-Disposition: inline
In-Reply-To: <20100208100306.GQ32246@kryten>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 08, 2010 at 09:03:07PM +1100, Anton Blanchard wrote:
> 
> I was looking through the hardware GRO support in various drivers and I think
> we have a couple of issues with PAGE_SIZE > 4k. For example, if we have a 64kB
> page size then MAX_SKB_FRAGS ends up as 3:
> 
> #define MAX_SKB_FRAGS (65536/PAGE_SIZE + 2)
> 
> This should be fine for hardware and software GSO, but we encounter issues
> with hardware GRO (not sure about software GRO).
> 
> In the ixgbe case we use MAX_SKB_FRAGS to program the max number of GRO
> descriptors, even though we assemble GRO packets using ->frag_list:
> 
> #if (MAX_SKB_FRAGS > 16)
>                 rscctrl |= IXGBE_RSCCTL_MAXDESC_16;
> #elif (MAX_SKB_FRAGS > 8)
>                 rscctrl |= IXGBE_RSCCTL_MAXDESC_8;
> #elif (MAX_SKB_FRAGS > 4)
>                 rscctrl |= IXGBE_RSCCTL_MAXDESC_4;
> #else
>                 rscctrl |= IXGBE_RSCCTL_MAXDESC_1;
> #endif

First of all this isn't GRO, but RSC.  With GRO we impose extra
restrictions on what packets can be merged while RSC is more
permissive.

In fact I think the ixgbe code may be broken as it is since it's
not marking RSC packets in any way to prevent them from being
forwarded through another interface.

As to your problem with RSC on a 64K page system, I'm sure one
of the Intel developers would be able to help you out.
 
> Thinking out aloud, would setting a pessimistic value for MAX_SKB_FRAGS
> be one way to fix this? ie:
> 
> #define MAX_SKB_FRAGS (65536/4096 + 2)

While I can't think of any serious issues with this, as this is
an entirely ixgbe-specific problem, the fix should probably stay
there.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
