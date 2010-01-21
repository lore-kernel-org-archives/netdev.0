From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 00/11] DMA sync errors
Date: Thu, 21 Jan 2010 12:44:23 +0000
Message-ID: <20100121124423.GA8817@ff.dom.local>
References: <20100120204459.820265084@vyatta.com> <20100120.144639.31770545.davem@davemloft.net> <20100120152832.06a905a5@nehalam> <20100120.161805.118613816.davem@davemloft.net> <20100120163410.774f0c4c@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f220.google.com ([209.85.220.220]:54422 "EHLO
	mail-fx0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752164Ab0AUMo2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Jan 2010 07:44:28 -0500
Received: by fxm20 with SMTP id 20so1270555fxm.1
        for <netdev@vger.kernel.org>; Thu, 21 Jan 2010 04:44:27 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20100120163410.774f0c4c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 20, 2010 at 04:34:10PM -0800, Stephen Hemminger wrote:
> On Wed, 20 Jan 2010 16:18:05 -0800 (PST)
> David Miller <davem@davemloft.net> wrote:
> 
> > From: Stephen Hemminger <shemminger@vyatta.com>
> > Date: Wed, 20 Jan 2010 15:28:32 -0800
> > 
> > > This should fix the dma-debug API code (and documentation), to
> > > avoid false positives when sync is done on a partial map.
> > > 
> > > Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >  ...
> > > --- a/lib/dma-debug.c	2010-01-20 15:22:55.919519883 -0800
> > > +++ b/lib/dma-debug.c	2010-01-20 15:26:31.648895638 -0800
> > > @@ -285,11 +285,9 @@ static struct dma_debug_entry *hash_buck
> > >  	}
> > >  
> > >  	/*
> > > -	 * If we have multiple matches but no perfect-fit, just return
> > > -	 * NULL.
> > > +	 * If we have multiple matches but no perfect-fit
> > > +	 * return best value and let caller deal with it.
> > >  	 */
> > > -	ret = (matches == 1) ? ret : NULL;
> > > -
> > >  	return ret;
> > >  }
> > >  
> > 
> > I think you have to enforce a perfect-fit match for the
> > non-SYNC cases.
> > 
> > check_sync() can pass in 'true' for a new bool argument "partial_ok"
> > added to hash_bucket_find() whereas check_unmap() can pass 'false'.
> > 
> > get_nr_mapped_entries() should pass 'false' as well.
> 
> check_unmap has checks for different size, different type,
> call_ents, direction etc.
> 
> The code for get_nr_mapped_entries() is the only question;
> it is used by unmap_sg() and probably needs perfect match only.
> 

Hmm... After looking at it more, mainly dma_sync_single_range()
implementations, I didn't find any reasons for these comments in
DMA-API.txt, but even if I missed something, this patch definitely
shows these lib/dma-debug warnings are buggy if they depend on the
number of mapped entries (while otherwise ref->size < entry->size
isn't reported). Btw, it seems code should try to return minimum
entry->size for such a check.

Thanks Stephen, now I feel 99.9% safe ;-)

Sorry for mistrust, David!
Jarek P.
