From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 22/32] rt2x00: Allocate ring structures in single array
Date: Fri, 28 Apr 2006 12:52:01 +0200
Message-ID: <20060428125201.4f20ece2@griffin.suse.cz>
References: <200604280003.14287.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, rt2x00-devel@lfcorreia.dyndns.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:46748 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S964997AbWD1KwD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 06:52:03 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200604280003.14287.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 28 Apr 2006 00:03:13 +0200, Ivo van Doorn wrote:
> Use seperate function to convert a dscape ring ID
> to the address of the actual ring.

Just minor things:

> [...]
> @@ -1386,20 +1412,19 @@ rt2400pci_tx(struct net_device *net_dev,
>  
>  	rt2x00_register_read(rt2x00pci, TXCSR0, &reg);
>  
> -	if (control->queue == IEEE80211_TX_QUEUE_DATA0) {
> -		ring = &rt2x00pci->prio;
> -		rt2x00_set_field32(&reg, TXCSR0_KICK_PRIO, 1);
> -	} else if (control->queue == IEEE80211_TX_QUEUE_DATA1) {
> -		ring = &rt2x00pci->tx;
> -		rt2x00_set_field32(&reg, TXCSR0_KICK_TX, 1);
> -	} else if (control->queue == IEEE80211_TX_QUEUE_AFTER_BEACON) {
> -		ring = &rt2x00pci->atim;
> -		rt2x00_set_field32(&reg, TXCSR0_KICK_ATIM, 1);
> -	} else {
> -		ERROR("Frame received for invalid queue.");
> +	/*
> +	 * Determine which ring to put packet on.
> +	 */
> +	ring = rt2x00pci_get_ring(rt2x00pci, control->queue);
> +	if (unlikely(!ring)) {

Should not happen. Maybe some message that user should report a bug?

> +		ERROR("Attempt to send packet over invalid queue %d.\n",
> +			control->queue);
>  		return NET_RX_DROP;
>  	}
>  
> +	if (rt2x00_ring_full(ring))
> +		return NET_RX_DROP;

NET_XMIT_DROP?

> +
>  	entry = rt2x00_get_data_entry(ring);
>  	txd = entry->desc_addr;
>  
> [...]
> @@ -1780,14 +1813,17 @@ rt2400pci_conf_tx(struct net_device *net
>  	int queue, const struct ieee80211_tx_queue_params *params)
>  {
>  	struct rt2x00_pci	*rt2x00pci = ieee80211_dev_hw_data(net_dev);
> -	struct data_ring	*ring;
> +	struct data_ring	*ring = &rt2x00pci->ring[RING_TX];
>  
> -	if (queue == IEEE80211_TX_QUEUE_DATA0)
> -		ring = &rt2x00pci->prio;
> -	else if (queue == IEEE80211_TX_QUEUE_DATA1)
> -		ring = &rt2x00pci->tx;
> -	else
> -		return -EINVAL;
> +	/*
> +	 * We don't support variating cw_min and cw_max variables
> +	 * per queue. So by default we only configure the TX queue,
> +	 * and ignore all other configurations.
> +	 */
> +	if (queue != IEEE80211_TX_QUEUE_DATA0) {
> +		NOTICE("Ignoring configuration for queue %d.\n", queue);
> +		return 0;

Is there a reason for not returning a proper error code?

> +	}
>  
>  	memcpy(&ring->tx_params, params, sizeof(*params));
>  

Ditto for rt2500pci and rt2500usb.

Thanks,

-- 
Jiri Benc
SUSE Labs
