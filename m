From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] Kernel unaligned access at __skb_flow_dissect
Date: Fri, 29 Jan 2016 11:39:58 -0800
Message-ID: <1454096398.7627.63.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20160129180651.GA17127@oracle.com>
	 <1454092428.7627.52.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1454092810.7627.53.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20160129.110811.1595768260535944996.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sowmini.varadhan@oracle.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:35257 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752348AbcA2TkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jan 2016 14:40:00 -0500
Received: by mail-pf0-f181.google.com with SMTP id 65so46877287pfd.2
        for <netdev@vger.kernel.org>; Fri, 29 Jan 2016 11:39:59 -0800 (PST)
In-Reply-To: <20160129.110811.1595768260535944996.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-01-29 at 11:08 -0800, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 29 Jan 2016 10:40:10 -0800
> 
> > I would try following ixgbe fix (sorry, totally untested, but you get
> > the idea...)
> > 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > index c4003a88bbf6..7ba64ed463a6 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -1525,7 +1525,7 @@ static bool ixgbe_alloc_mapped_page(struct ixgbe_ring *rx_ring,
> >  
> >  	bi->dma = dma;
> >  	bi->page = page;
> > -	bi->page_offset = 0;
> > +	bi->page_offset = NET_IP_ALIGN;
> >  
> >  	return true;
> >  }
> 
> Hmmm, wouldn't this waste 2 bytes on all pages?  Or just the head one with the headers?

On arches where NET_IP_ALIGN = 2, where it makes sense to get a proper
alignement, even for the copy of headers into skb->head, with same
source/destination alignment.

We 'waste' already 66 bytes for typical ethernet+IPv4+TCP headers.

Lets remind we allocate half a page (2048 bytes) for an ethernet frame
anyway. We have plenty of room.
