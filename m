From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] e1000: enhance frame fragment detection
Date: Tue, 5 Jan 2010 17:04:13 -0500
Message-ID: <20100105220413.GA6825@localhost.localdomain>
References: <20091228201005.GC18422@hmsreliant.think-freely.org>
 <alpine.WNT.2.00.1001051341110.4056@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:36036 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754433Ab0AEWEQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 17:04:16 -0500
Content-Disposition: inline
In-Reply-To: <alpine.WNT.2.00.1001051341110.4056@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 05, 2010 at 01:44:25PM -0800, Brandeburg, Jesse wrote:
> Neil, I couple of comments below, I was just looking at the implementation 
> of this for e1000e.
> 
> On Mon, 28 Dec 2009, Neil Horman wrote:
> 
> > Hey all-
> > 	A security discussion was recently given:
> > http://events.ccc.de/congress/2009/Fahrplan//events/3596.en.html
> > And a patch that I submitted awhile back was brought up.  Apparently some of
> > their testing revealed that they were able to force a buffer fragment in e1000
> > in which the trailing fragment was greater than 4 bytes.  As a result the
> > fragment check I introduced failed to detect the fragement and a partial invalid
> > frame was passed up into the network stack.  I've written this patch to correct
> > it.  I'm in the process of testing it now, but it makes good logical sense to
> > me.  Effectively it maintains a per-adapter state variable which detects a
> > non-EOP frame, and discards it and subsequent non-EOP frames leading up to _and_
> > _including_ the next positive-EOP frame (as it is by definition the last
> > fragment).  This should prevent any and all partial frames from entering the
> > network stack from e1000
> > 
> > Regards
> > Neil
> > 
> > 
> >  e1000.h      |    3 ++-
> >  e1000_main.c |   14 ++++++++++++--
> >  2 files changed, 14 insertions(+), 3 deletions(-)
> > 
> > 
> > diff --git a/drivers/net/e1000/e1000.h b/drivers/net/e1000/e1000.h
> > index 2a567df..3d421ab 100644
> > --- a/drivers/net/e1000/e1000.h
> > +++ b/drivers/net/e1000/e1000.h
> > @@ -331,7 +331,8 @@ struct e1000_adapter {
> >  enum e1000_state_t {
> >  	__E1000_TESTING,
> >  	__E1000_RESETTING,
> > -	__E1000_DOWN
> > +	__E1000_DOWN,
> > +	__E1000_DISCARDING
> >  };
> >  
> >  extern char e1000_driver_name[];
> > diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> > index 7e855f9..0731779 100644
> > --- a/drivers/net/e1000/e1000_main.c
> > +++ b/drivers/net/e1000/e1000_main.c
> > @@ -3850,16 +3850,26 @@ static bool e1000_clean_rx_irq(struct e1000_adapter *adapter,
> >  
> >  		length = le16_to_cpu(rx_desc->length);
> >  		/* !EOP means multiple descriptors were used to store a single
> > -		 * packet, also make sure the frame isn't just CRC only */
> > -		if (unlikely(!(status & E1000_RXD_STAT_EOP) || (length <= 4))) {
> > +		 * packet, if thats the case we need to toss it.  In fact, we
> > +		 * to toss every packet with the EOP bit clear and the next
> > +		 * frame that _does_ have the EOP bit set, as it is by
> > +		 * definition only a frame fragment
> > +		 */
> > +		if (unlikely(!(status & E1000_RXD_STAT_EOP)))
> > +			set_bit(__E1000_DISCARDING, &adapter->flags);
> 
> test_bit and set_bit and clear_bit are atomic operations, isn't that quite 
> a bit of overhead for something that is already being done in a guaranteed 
> single context?
> 
> > +
> > +		if (test_bit(__E1000_DISCARDING, &adapter->flags)) {
> >  			/* All receives must fit into a single buffer */
> >  			E1000_DBG("%s: Receive packet consumed multiple"
> >  				  " buffers\n", netdev->name);
> >  			/* recycle */
> >  			buffer_info->skb = skb;
> > +			if (status & E1000_RXD_STAT_EOP)
> > +				clear_bit(__E1000_DISCARDING, &adapter->flags);
> 
> couldn't these simply be read/modify/write assignments (aka |=)
> 
> That would significantly avoid the extra cycles needed to implement three 
> atomic ops.
> 
They certainly could be non-atomic assignments, but the other flags in the
adapter falgs are atomic and I dont think its safe to mix and match the
accesses, lest we get a waw race somewhere.

If you really think we need to save the save the cycles the best thing to
probably do is define a new flags field separate from adapter->flags that can be
accessed with non-atomics.

Let me know if you would prefer that, and I'll happily re-spin the patch.
Neil

