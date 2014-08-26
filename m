From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 2/2] ixgbe: support skb->xmit_more in
 netdev_ops->ndo_start_xmit()
Date: Tue, 26 Aug 2014 17:40:57 +0200
Message-ID: <1409067657.22108.7.camel@localhost>
References: <20140825.163505.1969688661687017343.davem@davemloft.net>
	 <53FCA0FA.20600@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	therbert@google.com, jhs@mojatatu.com, edumazet@google.com,
	jeffrey.t.kirsher@intel.com, rusty@rustcorp.com.au,
	dborkman@redhat.com, brouer@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out2-smtp.messagingengine.com ([66.111.4.26]:35491 "EHLO
	out2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750942AbaHZPlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 11:41:00 -0400
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by gateway2.nyi.internal (Postfix) with ESMTP id 077D22074E
	for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 11:41:00 -0400 (EDT)
In-Reply-To: <53FCA0FA.20600@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Di, 2014-08-26 at 08:00 -0700, Alexander Duyck wrote:
> On 08/25/2014 04:35 PM, David Miller wrote:
> > 
> > From: Daniel Borkmann <dborkman@redhat.com>
> > 
> > This implements the deferred tail pointer flush API for the ixgbe
> > driver. Similar version also proposed longer time ago by Alexander Duyck.
> > 
> > Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > ---
> >  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c | 7 ++++---
> >  1 file changed, 4 insertions(+), 3 deletions(-)
> > 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > index 87bd53f..ba9ceaa 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -6958,9 +6958,10 @@ static void ixgbe_tx_map(struct ixgbe_ring *tx_ring,
> >  
> >  	tx_ring->next_to_use = i;
> >  
> > -	/* notify HW of packet */
> > -	ixgbe_write_tail(tx_ring, i);
> > -
> > +	if (!skb->xmit_more) {
> > +		/* notify HW of packet */
> > +		ixgbe_write_tail(tx_ring, i);
> > +	}
> >  	return;
> >  dma_error:
> >  	dev_err(tx_ring->dev, "TX DMA map failed\n");
> > 
> 
> It might help to add some handling for the case where xmit_more is set,
> but the ring has become full.  This current implementation introduces
> the risk of triggering a Tx hang.

IMHO this should be done before the patch lands in the driver.

> My advice would be to pull the ixgbe_maybe_stop_tx code at the end of
> xmit_frame into the if check here, and perhaps look into adding an
> additional check to see if BQL has stopped the ring as well.

I would like to have the BQL check not in the driver but in the generic
code steering xmit_more.

Otherwise I'll like the API.

David, because of debugging and driver bugs, can we have an interface
flag for that, so we can e.g. switch xmit_more to 0 permanently? It
would also be nice to have for documentation purposes, so ethtool e.g.
can discover feature-set of a driver.

Thanks,
Hannes
