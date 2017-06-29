From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH net-next v2 8/9] nfp: add a stats
 handler for flower offloads
Date: Thu, 29 Jun 2017 10:15:21 +0200
Message-ID: <20170629081519.GD29453@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-9-git-send-email-simon.horman@netronome.com>
 <20170628195518.3397bab1@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:36811 "EHLO
        mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752150AbdF2IPZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 04:15:25 -0400
Received: by mail-wm0-f45.google.com with SMTP id 62so74748436wmw.1
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 01:15:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170628195518.3397bab1@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 07:55:18PM -0700, Jakub Kicinski wrote:
> On Wed, 28 Jun 2017 22:30:01 +0200, Simon Horman wrote:
> > From: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> > 
> > Previously there was no way of updating flow rule stats after they
> > have been offloaded to hardware. This is solved by keeping track of
> > stats received from hardware and providing this to the TC handler
> > on request.
> > 
> > Signed-off-by: Pieter Jansen van Vuuren <pieter.jansenvanvuuren@netronome.com>
> > Signed-off-by: Simon Horman <simon.horman@netronome.com>
> 
> > @@ -334,7 +441,10 @@ int nfp_modify_flow_metadata(struct nfp_app *app,
> >  	/* Update flow payload with mask ids. */
> >  	nfp_flow->unmasked_data[NFP_FL_MASK_ID_LOCATION] = new_mask_id;
> >  
> > -	return 0;
> > +	/* Release the stats ctx id. */
> > +	temp_ctx_id = be32_to_cpu(nfp_flow->meta.host_ctx_id);
> > +
> > +	return nfp_release_stats_entry(app, temp_ctx_id);
> >  }
> >  
> >  int nfp_flower_metadata_init(struct nfp_app *app)
> > @@ -362,6 +472,15 @@ int nfp_flower_metadata_init(struct nfp_app *app)
> >  		return -ENOMEM;
> >  	}
> >  
> > +	/* Init ring buffer and unallocated stats_ids. */
> > +	priv->stats_ids.free_list.buf =
> > +		vmalloc(NFP_FL_STATS_ENTRY_RS * NFP_FL_STATS_ELEM_RS);
> > +	if (!priv->stats_ids.free_list.buf) {
> > +		vfree(priv->mask_ids.mask_id_free_list.buf);
> > +		return -ENOMEM;
> 
> This is hiding a leak, I think.  There were 2 things allocate above.
> Please add a proper unwind path with goto's - it makes catching bugs
> like this much easier.

Sure, will do.
