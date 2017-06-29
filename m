From: Simon Horman <simon.horman@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH net-next v2 7/9] nfp: add metadata to
 each flow offload
Date: Thu, 29 Jun 2017 13:22:14 +0200
Message-ID: <20170629112213.GB24136@vergenet.net>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
 <1498681802-2897-8-git-send-email-simon.horman@netronome.com>
 <20170628193302.555537c1@cakuba.netronome.com>
 <20170629081427.GB29453@vergenet.net>
 <20170629014250.3000597f@cakuba.netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f173.google.com ([209.85.220.173]:33433 "EHLO
        mail-qk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752582AbdF2LWW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 07:22:22 -0400
Received: by mail-qk0-f173.google.com with SMTP id r62so73186417qkf.0
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 04:22:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170629014250.3000597f@cakuba.netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 29, 2017 at 01:42:50AM -0700, Jakub Kicinski wrote:
> On Thu, 29 Jun 2017 10:14:29 +0200, Simon Horman wrote:
> > > > +	/* Checking if buffer is empty. */
> > > > +	if (ring->head == ring->tail) {
> > > > +		*mask_id = freed_id;
> > > > +		return -ENOENT;
> > > > +	}
> > > > +
> > > > +	memcpy(&temp_id, &ring->buf[ring->tail], NFP_FLOWER_MASK_ELEMENT_RS);
> > > > +	*mask_id = temp_id;
> > > > +	memcpy(&ring->buf[ring->tail], &freed_id, NFP_FLOWER_MASK_ELEMENT_RS);
> > > > +	ring->tail = (ring->tail + NFP_FLOWER_MASK_ELEMENT_RS) %
> > > > +		     (NFP_FLOWER_MASK_ENTRY_RS * NFP_FLOWER_MASK_ELEMENT_RS);
> > > > +
> > > > +	getnstimeofday64(&now);
> > > > +	delta = timespec64_sub(now, priv->mask_ids.last_used[*mask_id]);
> > > > +
> > > > +	if (timespec64_to_ns(&delta) < NFP_FL_MASK_REUSE_TIME_NS) {
> > > > +		nfp_release_mask_id(app, *mask_id);  
> > > 
> > > nfp_release_mask_id() will reset the time stamp and put the mask at the
> > > end of the queue.  Is that OK?  
> > 
> > I discussed this with Pieter. He believes that it is ok as it would be too
> > early to use the entry and its better put it to the back of the list and
> > skip to the next one.
> 
> But we shouldn't update the "last use" time if the grace period haven't
> elapsed otherwise we can live lock (I know, unlikely).  Could we simply
> move the time check right after the:
> 
> 	*mask_id = temp_id;
> 
> line?  I.e. move the check before we actually pick the mask off the
> queue?

Thanks, we now have a solution along those lines working.
