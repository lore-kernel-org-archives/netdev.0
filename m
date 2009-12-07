From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: [PATCH 1/3] e1000: increase skb size to prevent dma over skb
 boundary
Date: Mon, 07 Dec 2009 16:24:02 +0100
Message-ID: <4B1D1E12.8010200@lastsummer.de>
References: <20091207144623.GA8073@hmsreliant.think-freely.org> <20091207144736.GB8073@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	davem@davemloft.net, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, bruce.w.allan@intel.com,
	peter.p.waskiewicz.jr@intel.com, john.ronciak@intel.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:44460 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932685AbZLGPYI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Dec 2009 10:24:08 -0500
In-Reply-To: <20091207144736.GB8073@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Neil,

Neil Horman wrote:
> Update e1000 driver to not allow dma beyond the end of the allocated skb
>     
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>
>
> e1000_main.c |   34 +++++++++++++++++++++++++++++++++-
> 1 file changed, 33 insertions(+), 1 deletion(-)
>
>
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 7e855f9..7600deb 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -1667,6 +1667,19 @@ int e1000_setup_all_rx_resources(struct e1000_adapter *adapter)
>  	return err;
>  }
>  
> +static inline u32 normalize_rx_len(u32 len)
> +{
> +        u32 match, last_match;
> +
>   
Skip newline and get rid of last_match. Also, there is a whitespace error...
> +
> +        for (match = 0x100; match <= 0x4000; match *= 2) {
> +                if (len <= match)
> +                        return match;
> +        }
> +
>   
> +        return 0;
> +}
>   
You should return (match >> 1), which is the largest size possible. (Which
is exactly what you need here).
> +
>  /**
>   * e1000_setup_rctl - configure the receive control registers
>   * @adapter: Board private structure
> @@ -1675,6 +1688,7 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
>  {
>  	struct e1000_hw *hw = &adapter->hw;
>  	u32 rctl;
> +	u32 normed_rx_len;
>  
>  	rctl = er32(RCTL);
>  
> @@ -1697,7 +1711,25 @@ static void e1000_setup_rctl(struct e1000_adapter *adapter)
>  	/* Setup buffer sizes */
>  	rctl &= ~E1000_RCTL_SZ_4096;
>  	rctl |= E1000_RCTL_BSEX;
> -	switch (adapter->rx_buffer_len) {
> +
> +	/*
> +	 * We need to normalize the rx_buffer_len here
> +	 * since the hardware only knows about 7 discrete
> +	 * frame lengths here.  To accomodate that we need
> +	 * to set the rx length in the hardware to the next highest
> +	 * size over the rx_buffer_len, then increase rx_buffer_len
> +	 * to match it, so that we can get a full mtu sized frame 
> +	 */
> +	normed_rx_len = normalize_rx_len(adapter->rx_buffer_len);
> +	
> +	if (!normed_rx_len) {
> +		printk(KERN_ERR "No valid rx len found, assume 2048\n");
> +		normed_rx_len = 0x800;
> +	}
> +
> +	adapter->rx_buffer_len = normed_rx_len;
>   
If you modify rx_buffer_len anyway, then get rid of normed_rx_len and
do a quick

    adapter->rx_buffer_len = normalize_rx_len(adapter->rx_buffer_len);

instead. With the modification above, it never fails, so no need to check
for !normed_rx_len.

But I don't really know the context of this change. Is it okay to shorten
rx_buffer_len here? Why was it not set appropriately as the driver
expects?

Oh, BTW, the default case in the switch statement is stupid and should
be removed.

> +
> +	switch (normed_rx_len) {
>  		case E1000_RXBUFFER_256:
>  			rctl |= E1000_RCTL_SZ_256;
>  			rctl &= ~E1000_RCTL_BSEX;
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>   

Franco
