From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 11/13] igb: Update PTP function names/variables and
 locations.
Date: Thu, 23 Aug 2012 18:00:37 +0000
Message-ID: <02874ECE860811409154E81DA85FBB5807857EEA@ORSMSX105.amr.corp.intel.com>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-12-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120823111622.GC2238@netboy.at.omicron.at>
 <06DFBC1E25D8024DB214DC7F41A3CD34488DD079@ORSMSX101.amr.corp.intel.com>
 <20120823175335.GB2192@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Vick, Matthew" <matthew.vick@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:34663 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756241Ab2HWSAk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 14:00:40 -0400
In-Reply-To: <20120823175335.GB2192@netboy.at.omicron.at>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Richard Cochran
> Sent: Thursday, August 23, 2012 10:54 AM
> To: Vick, Matthew
> Cc: Kirsher, Jeffrey T; davem@davemloft.net; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 11/13] igb: Update PTP function names/variables and
> locations.
> 
> On Thu, Aug 23, 2012 at 04:22:02PM +0000, Vick, Matthew wrote:
> 
> > > >  #ifdef CONFIG_IGB_PTP
> > > > -static int igb_ethtool_get_ts_info(struct net_device *dev,
> > > > +static int igb_get_ts_info(struct net_device *dev,
> > >
> > > I like the old name better.
> >
> > The old name is out of the coding style of igb. Every other function is
> igb_get_* or igb_set_*, with the exception of igb_ethtool_begin and
> igb_ethtool_complete. Are you suggesting we add _ethtool to every ethtool
> function in igb?
> 
> No, just leave the names alone, and keep the functions where they are. It
> is just churn.
> 
> One of the most useful ways to understand code (at least for me) is to use
> git blame. It tells you when code was added, what the reason was, and how
> the change looks in context. By moving and renaming willy nilly, you are
> obscuring this valuable information.
> 
> > > > -#ifdef CONFIG_IGB_PTP
> > > > -/**
> > > > - * igb_tx_hwtstamp - utility function which checks for TX time
> > > > stamp
> > > > - * @q_vector: pointer to q_vector containing needed info
> > > > - * @buffer: pointer to igb_tx_buffer structure
> > > > - *
> > > > - * If we were asked to do hardware stamping and such a time stamp
> > > > is
> > > > - * available, then it must have been for this skb here because we
> > > > only
> > > > - * allow only one such packet into the queue.
> > > > - */
> > > > -static void igb_tx_hwtstamp(struct igb_q_vector *q_vector,
> > > > -			    struct igb_tx_buffer *buffer_info)
> > > > -{
> > > > -	struct igb_adapter *adapter = q_vector->adapter;
> > > > -	struct e1000_hw *hw = &adapter->hw;
> > > > -	struct skb_shared_hwtstamps shhwtstamps;
> > > > -	u64 regval;
> > > > -
> > > > -	/* if skb does not support hw timestamp or TX stamp not valid
> > > exit */
> > > > -	if (likely(!(buffer_info->tx_flags & IGB_TX_FLAGS_TSTAMP)) ||
> > > > -	    !(rd32(E1000_TSYNCTXCTL) & E1000_TSYNCTXCTL_VALID))
> > > > -		return;
> > > > -
> > > > -	regval = rd32(E1000_TXSTMPL);
> > > > -	regval |= (u64)rd32(E1000_TXSTMPH) << 32;
> > > > -
> > > > -	igb_systim_to_hwtstamp(adapter, &shhwtstamps, regval);
> > > > -	skb_tstamp_tx(buffer_info->skb, &shhwtstamps);
> > > > -}
> > > > -#endif /* CONFIG_IGB_PTP */
> > > > -
> > >
> > > Here you have taken a static local function and made it into a
> > > global function. This can have performance impacts.
> >
> > Which, this function calls igb_systim_to_hwtstamp anyway, which is
> > global.
> 
> So how does calling two global functions in series improve performance?
> 
> > Also, in a follow-on patch I have coming, igb_ptp_tx_hwtstamp won't
> > even be called in clean_tx_irq, FWIW.
> 
> If this is part of some larger plan, then it would help to see that plan.
> 
> > > >  /**
> > > >   * igb_clean_tx_irq - Reclaim resources after transmit completes
> > > >   * @q_vector: pointer to q_vector containing needed info @@
> > > > -5827,7
> > > > +5796,7 @@ static bool igb_clean_tx_irq(struct igb_q_vector
> > > *q_vector)
> > > >
> > > >  #ifdef CONFIG_IGB_PTP
> > > >  		/* retrieve hardware timestamp */
> > > > -		igb_tx_hwtstamp(q_vector, tx_buffer);
> > > > +		igb_ptp_tx_hwtstamp(q_vector, tx_buffer);
> > >
> > > This name stinks, too. You know that you can have time stamping all
> > > by itself, right? It is logically separate from the ptp clock stuff.
> > >
> > > This patch doesn't really improve the driver at all, IMHO.
> > >
> > > Thanks,
> > > Richard
> >
> > Yes, I'm aware. But, as it stands today, we don't use it for anything
> else. If the function is feature specific, then we should be calling it
> out as such.
> 
> Right now the time stamping is being equated with the clock functions, but
> it really should be decoupled. The 82580 can time stamp every received
> packet, which can be interesting for performance monitoring, even without
> PTP (and adding *that* would be a useful change).
> 
The timestamp all does not really work with the ptp clock features gone, because you don't have the clock. You can't equate the time values of the packets when the clock isn't synched to something meaningful. Yes that does not require PTP adjustment functions, but it does require the SYSTIME setup and some method to get the clock correct, which currently is only done in the PTP init sequence. Timestamp all packets also can cause a performance hit when used with certain workloads.

> > I'm sorry you feel like this patch doesn't improve the driver. The goal
> is code cleanup and consistency, both of which I consider to be driver
> improvements and is why I made the patches.
> 
> But the code wasn't dirty in the first place. It doesn't need this
> "cleaning." This series undoes the inline-able functions for no good
> reason. As far as ixgbe goes, this driver came first, so you might as well
> be making *that* driver consistent with this one.

ixgbe hardware is (currently) even more closely synched with PTP for the register bits so it does make some sense for ixgbe to remain the way it is. Right now the igb features are partially synched (even before this change) in odd ways. The time values returned when PHC information is disabled are basically only useful for comparing between themselves, not with any meaningful clock on the device.

> 
> Thanks,
> Richard
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in the
> body of a message to majordomo@vger.kernel.org More majordomo info at
> http://vger.kernel.org/majordomo-info.html
