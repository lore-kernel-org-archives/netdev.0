From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next 1/3] Add LAN743X driver
Date: Fri, 11 Aug 2017 15:57:34 -0700
Message-ID: <20170811155734.26a4c679@xeon-e3>
References: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
        <UNGLinuxDriver@microchip.com>
To: <Bryan.Whitehead@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:36275 "EHLO
        mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753659AbdHKW5m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 18:57:42 -0400
Received: by mail-pf0-f174.google.com with SMTP id c28so20925852pfe.3
        for <netdev@vger.kernel.org>; Fri, 11 Aug 2017 15:57:42 -0700 (PDT)
In-Reply-To: <90A7E81AE28BAE4CBDDB3B35F187D264406F603F@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Aug 2017 19:47:57 +0000
<Bryan.Whitehead@microchip.com> wrote:

> +
> +static int lan743x_rx_napi_poll(struct napi_struct *napi, int weight)
> +{
> +	int count;
> +	bool finished = false;
> +	struct lan743x_rx *rx = container_of(napi,
> +		struct lan743x_rx, napi);
> +	struct lan743x_adapter *adapter = rx->adapter;
> +
> +	if (weight < 0)
> +		finished = true;
> +
> +	count = 0;
> +	while (count < weight) {
> +		int rx_process_result = -1;
> +
> +		/* clear int status bit before reading packet */
> +		lan743x_csr_write(adapter, DMAC_INT_STS,
> +				  DMAC_INT_BIT_RXFRM_(rx->channel_number));
> +		lan743x_csr_read(adapter, DMAC_INT_STS);
> +
> +		rx_process_result = lan743x_rx_process_packet(rx);
> +		if (rx_process_result == RX_PROCESS_RESULT_PACKET_RECEIVED) {
> +			count++;
> +		} else if (rx_process_result ==
> +			RX_PROCESS_RESULT_NOTHING_TO_DO) {
> +			finished = true;
> +			break;
> +		} else if (rx_process_result ==
> +			RX_PROCESS_RESULT_PACKET_DROPPED) {
> +			continue;
> +		} else {
> +			NETIF_ERROR(adapter, drv, adapter->netdev,
> +				    "Unknown rx_process_result == %d",
> +				    rx_process_result);
> +		}
> +	}
> +
> +	adapter->netdev->stats.rx_packets += count;
> +
> +	if (!finished) {
> +		NETIF_ASSERT(adapter, drv, adapter->netdev, count == weight);
> +		return count;
> +	}
> +
> +	napi_complete_done(napi, count);
> +
> +	lan743x_csr_write(adapter, INT_EN_SET,
> +			  INT_BIT_DMA_RX_(rx->channel_number));
> +	lan743x_csr_read(adapter, INT_STS);
> +
> +	return 0;

NAPI poll routine is supposed to return count of packets processed.
If you write the code in a logical manner, you won't need the finished flag either.
Also with net_poll you should be checking return value from napi_complete_done.
