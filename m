From: "Keller, Jacob E" <jacob.e.keller@intel.com>
Subject: RE: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
 Clock (PHC)
Date: Thu, 10 May 2012 21:53:18 +0000
Message-ID: <02874ECE860811409154E81DA85FBB580779423F@ORSMSX105.amr.corp.intel.com>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com>
 <20120510141122.GB3392@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Richard Cochran <richardcochran@gmail.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:43193 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761675Ab2EJVxV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 17:53:21 -0400
In-Reply-To: <20120510141122.GB3392@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Thursday, May 10, 2012 7:11 AM
> To: Kirsher, Jeffrey T
> Cc: davem@davemloft.net; Keller, Jacob E; netdev@vger.kernel.org;
> gospo@redhat.com; sassmann@redhat.com
> Subject: Re: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
> Clock (PHC)
> 
> Mostly, this looks very good. I do have one concern and a nit, though.
> 
> On Wed, May 09, 2012 at 11:46:47PM -0700, Jeff Kirsher wrote:
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > index 1693ec3..9a83c40 100644
> > --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> > @@ -789,6 +789,13 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector
> *q_vector,
> >  		total_bytes += tx_buffer->bytecount;
> >  		total_packets += tx_buffer->gso_segs;
> >
> > +#ifdef CONFIG_IXGBE_PTP
> > +		if (unlikely(tx_buffer->tx_flags &
> > +			     IXGBE_TX_FLAGS_TSTAMP))
> > +			ixgbe_ptp_tx_hwtstamp(q_vector,
> > +					      tx_buffer->skb);
> 
> This looks strangely wrapped.
> 
> > +
> > +#endif
> >  		/* free the skb */
> >  		dev_kfree_skb_any(tx_buffer->skb);
> >
> 
> ...
> 
> > diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
> > b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
> > new file mode 100644
> > index 0000000..0b6553e
> > --- /dev/null
> > +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
> 
> ...
> 
> > +/**
> > + * ixgbe_ptp_rx_hwtstamp - utility function which checks for RX time
> > +stamp
> > + * @q_vector: structure containing interrupt and ring information
> > + * @skb: particular skb to send timestamp with
> > + *
> > + * if the timestamp is valid, we convert it into the timecounter ns
> > + * value, then store that result into the shhwtstamps structure which
> > + * is passed up the network stack
> > + */
> > +void ixgbe_ptp_rx_hwtstamp(struct ixgbe_q_vector *q_vector,
> > +			   struct sk_buff *skb)
> > +{
> > +	struct ixgbe_adapter *adapter;
> > +	struct ixgbe_hw *hw;
> > +	struct skb_shared_hwtstamps *shhwtstamps;
> > +	u64 regval = 0, ns;
> > +	u32 tsyncrxctl;
> > +	unsigned long flags;
> > +
> > +	/* we cannot process timestamps on a ring without a q_vector */
> > +	if (!q_vector || !q_vector->adapter)
> > +		return;
> > +
> > +	adapter = q_vector->adapter;
> > +	hw = &adapter->hw;
> > +
> > +	tsyncrxctl = IXGBE_READ_REG(hw, IXGBE_TSYNCRXCTL);
> > +	regval |= (u64)IXGBE_READ_REG(hw, IXGBE_RXSTMPL);
> > +	regval |= (u64)IXGBE_READ_REG(hw, IXGBE_RXSTMPH) << 32;
> > +
> > +	/*
> > +	 * If this bit is set, then the RX registers contain the time stamp. No
> > +	 * other packet will be time stamped until we read these registers, so
> > +	 * read the registers to make them available again. Because only one
> > +	 * packet can be time stamped at a time, we know that the register
> > +	 * values must belong to this one here and therefore we don't need to
> > +	 * compare any of the additional attributes stored for it.
> 
> I suspect that this assumption is wrong. What happens if the time stamping
> logic locks a value but the packet is lost because the ring is full?
> 
> BTW, the IGB driver also has this defect.
>

Note how I read the rx registers first? So it will always clear the value.
That should unlock the value for the next rx stamp packet.
 
> Thanks,
> Richard
