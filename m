From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 06/12] ixgbe: Hardware Timestamping + PTP Hardware
 Clock (PHC)
Date: Thu, 10 May 2012 16:11:22 +0200
Message-ID: <20120510141122.GB3392@localhost.localdomain>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46770 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751972Ab2EJOL2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 10:11:28 -0400
Received: by bkcji2 with SMTP id ji2so1332558bkc.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 07:11:27 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1336632413-19135-7-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly, this looks very good. I do have one concern and a nit, though.

On Wed, May 09, 2012 at 11:46:47PM -0700, Jeff Kirsher wrote:
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 1693ec3..9a83c40 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -789,6 +789,13 @@ static bool ixgbe_clean_tx_irq(struct ixgbe_q_vector *q_vector,
>  		total_bytes += tx_buffer->bytecount;
>  		total_packets += tx_buffer->gso_segs;
>  
> +#ifdef CONFIG_IXGBE_PTP
> +		if (unlikely(tx_buffer->tx_flags &
> +			     IXGBE_TX_FLAGS_TSTAMP))
> +			ixgbe_ptp_tx_hwtstamp(q_vector,
> +					      tx_buffer->skb);

This looks strangely wrapped.

> +
> +#endif
>  		/* free the skb */
>  		dev_kfree_skb_any(tx_buffer->skb);
>  

...

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c
> new file mode 100644
> index 0000000..0b6553e
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_ptp.c

...

> +/**
> + * ixgbe_ptp_rx_hwtstamp - utility function which checks for RX time stamp
> + * @q_vector: structure containing interrupt and ring information
> + * @skb: particular skb to send timestamp with
> + *
> + * if the timestamp is valid, we convert it into the timecounter ns
> + * value, then store that result into the shhwtstamps structure which
> + * is passed up the network stack
> + */
> +void ixgbe_ptp_rx_hwtstamp(struct ixgbe_q_vector *q_vector,
> +			   struct sk_buff *skb)
> +{
> +	struct ixgbe_adapter *adapter;
> +	struct ixgbe_hw *hw;
> +	struct skb_shared_hwtstamps *shhwtstamps;
> +	u64 regval = 0, ns;
> +	u32 tsyncrxctl;
> +	unsigned long flags;
> +
> +	/* we cannot process timestamps on a ring without a q_vector */
> +	if (!q_vector || !q_vector->adapter)
> +		return;
> +
> +	adapter = q_vector->adapter;
> +	hw = &adapter->hw;
> +
> +	tsyncrxctl = IXGBE_READ_REG(hw, IXGBE_TSYNCRXCTL);
> +	regval |= (u64)IXGBE_READ_REG(hw, IXGBE_RXSTMPL);
> +	regval |= (u64)IXGBE_READ_REG(hw, IXGBE_RXSTMPH) << 32;
> +
> +	/*
> +	 * If this bit is set, then the RX registers contain the time stamp. No
> +	 * other packet will be time stamped until we read these registers, so
> +	 * read the registers to make them available again. Because only one
> +	 * packet can be time stamped at a time, we know that the register
> +	 * values must belong to this one here and therefore we don't need to
> +	 * compare any of the additional attributes stored for it.

I suspect that this assumption is wrong. What happens if the time
stamping logic locks a value but the packet is lost because the ring
is full?

BTW, the IGB driver also has this defect.

Thanks,
Richard
