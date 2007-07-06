From: "Ed L. Cashin" <ecashin@coraid.com>
Subject: Re: [PATCH 07/12] use a dynamic pool of sk_buffs to keep up with fast targets
Date: Fri, 6 Jul 2007 13:09:07 -0400
Message-ID: <20070706170907.GG13881@coraid.com>
References: <1d8423c28c48a6d26516cdc707dbcdf015a4e347.1182883861.git.ecashin@coraid.com> <bca4cec8ad679e8f8549cb78e012e54bfad1027e.1182883861.git.ecashin@coraid.com> <20070702213636.9ca1d842.akpm@linux-foundation.org> <20070702.214036.42772583.davem@davemloft.net>
Reply-To: support@coraid.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	greg@kroah.com, netdev@vger.kernel.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns1.coraid.com ([65.14.39.133]:26594 "EHLO coraid.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1763853AbXGFRFg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2007 13:05:36 -0400
Content-Disposition: inline
In-Reply-To: <20070702.214036.42772583.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.  I will address the style issues and other things that Andrew
Morton pointed out---Thanks again for the feedback.

As far as the skb pool goes, I'm afraid my comment is misleading.

What this Patch Does 

  Even before this recent series of 12 patches to 2.6.22-rc4, the aoe
  driver was reusing a small set of skbs that were allocated once and
  were only used for outbound AoE commands.
  
  The network layer cannot be allowed to put_page on the data that is
  still associated with a bio we haven't returned to the block layer,
  so the aoe driver (even before the patch under discussion) is still
  the owner of skbs that have been handed to the network layer for
  transmission.  We need to keep track of these skbs so that we can
  free them, but by tracking them, we can also easily re-use them.
  
  The new patch was a response to the behavior of certain network
  drivers.  We cannot reuse an skb that the network driver still has
  in its transmit ring.  Network drivers can defer transmit ring
  cleanup and then use the state in the skb to determine how many data
  segments to clean up in its transmit ring.  The tg3 driver is one
  driver that behaves in this way.
  
  When the network driver defers cleanup of its transmit ring, the aoe
  driver can find itself in a situation where it would like to send an
  AoE command, and the AoE target is ready for more work, but the
  network driver still has all of the pre-allocated skbs.  In that
  case, the new patch just calls alloc_skb, as you'd expect.
  
  We don't want to get carried away, though.  We try not to do
  excessive allocation in the write path, so we cap the number of skbs
  we dynamically allocate.
  
  Probably calling it a "dynamic pool" is misleading.  We were already
  trying to use a small fixed-size set of pre-allocated skbs before
  this patch, and this patch just provides a little headroom (with a
  ceiling, though) to accomodate network drivers that hang onto skbs,
  by allocating when needed.  The d->skbpool_hd list of allocated skbs
  is necessary so that we can free them later.
  
  We didn't notice the need for this headroom until AoE targets got
  fast enough, but the comment summarizing this patch still wasn't
  very good.  So, when I resubmit this patch, I will use a different
  comment:
  
    dynamically allocate a capped number of skbs when necessary


Alternatives

  If the network layer never did a put_page on the pages in the bio's
  we get from the block layer, then it would be possible for us to
  hand skbs to the network layer and forget about them, allowing the
  network layer to free skbs itself (and thereby calling our own
  skb->destructor callback function if we needed that).  In that case
  we could get rid of the pre-allocated skbs and also the
  d->skbpool_hd, instead just calling alloc_skb every time we wanted
  to transmit a packet.  The slab allocator would effectively maintain
  the list of skbs.
  
  Besides a loss of CPU cache locality, the main concern with that
  approach the danger that it would increase the likelihood of
  deadlock when VM is trying to free pages by writing dirty data from
  the page cache through the aoe driver out to persistent storage on
  an AoE device.  Right now we have a situation where we have
  pre-allocation that corresponds to how much we use, which seems
  ideal.
  
  Of course, there's still the separate issue of receiving the packets
  that tell us that a write has successfully completed on the AoE
  target.  When memory is low and VM is using AoE to flush dirty data
  to free up pages, it would be perfect if there were a way for us to
  register a fast callback that could recognize write command
  completion responses.  But I don't think the current problems with
  the receive side of the situation are a justification for
  exacerbating the problem on the transmit side.

-- 
  Support - http://www.coraid.com/support/howto.html
  Ed L Cashin <ecashin@coraid.com>
