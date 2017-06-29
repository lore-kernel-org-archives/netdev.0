From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [oss-drivers] Re: [PATCH net-next v2 7/9] nfp: add metadata to
 each flow offload
Date: Thu, 29 Jun 2017 01:42:50 -0700
Message-ID: <20170629014250.3000597f@cakuba.netronome.com>
References: <1498681802-2897-1-git-send-email-simon.horman@netronome.com>
        <1498681802-2897-8-git-send-email-simon.horman@netronome.com>
        <20170628193302.555537c1@cakuba.netronome.com>
        <20170629081427.GB29453@vergenet.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
        oss-drivers@netronome.com,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>
To: Simon Horman <simon.horman@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34578 "EHLO
        mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751804AbdF2Imy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 04:42:54 -0400
Received: by mail-pf0-f181.google.com with SMTP id s66so46957249pfs.1
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 01:42:54 -0700 (PDT)
In-Reply-To: <20170629081427.GB29453@vergenet.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 29 Jun 2017 10:14:29 +0200, Simon Horman wrote:
> > > +	/* Checking if buffer is empty. */
> > > +	if (ring->head == ring->tail) {
> > > +		*mask_id = freed_id;
> > > +		return -ENOENT;
> > > +	}
> > > +
> > > +	memcpy(&temp_id, &ring->buf[ring->tail], NFP_FLOWER_MASK_ELEMENT_RS);
> > > +	*mask_id = temp_id;
> > > +	memcpy(&ring->buf[ring->tail], &freed_id, NFP_FLOWER_MASK_ELEMENT_RS);
> > > +	ring->tail = (ring->tail + NFP_FLOWER_MASK_ELEMENT_RS) %
> > > +		     (NFP_FLOWER_MASK_ENTRY_RS * NFP_FLOWER_MASK_ELEMENT_RS);
> > > +
> > > +	getnstimeofday64(&now);
> > > +	delta = timespec64_sub(now, priv->mask_ids.last_used[*mask_id]);
> > > +
> > > +	if (timespec64_to_ns(&delta) < NFP_FL_MASK_REUSE_TIME_NS) {
> > > +		nfp_release_mask_id(app, *mask_id);  
> > 
> > nfp_release_mask_id() will reset the time stamp and put the mask at the
> > end of the queue.  Is that OK?  
> 
> I discussed this with Pieter. He believes that it is ok as it would be too
> early to use the entry and its better put it to the back of the list and
> skip to the next one.

But we shouldn't update the "last use" time if the grace period haven't
elapsed otherwise we can live lock (I know, unlikely).  Could we simply
move the time check right after the:

	*mask_id = temp_id;

line?  I.e. move the check before we actually pick the mask off the
queue?
