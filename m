From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH v2 2/2] ixgbe: enable l2 forwarding acceleration for macvlans
Date: Mon, 04 Nov 2013 22:24:46 -0800
Message-ID: <52788F2E.1070805@intel.com>
References: <20131104185717.11802.69282.stgit@jf-dev1-dcblab> <20131104190154.11802.75724.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: nhorman@tuxdriver.com, alexander.h.duyck@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:40220 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750704Ab3KEGYu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Nov 2013 01:24:50 -0500
In-Reply-To: <20131104190154.11802.75724.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/4/2013 11:01 AM, John Fastabend wrote:
> Now that l2 acceleration ops are in place from the prior patch,
> enable ixgbe to take advantage of these operations.  Allow it to
> allocate queues for a macvlan so that when we transmit a frame,
> we can do the switching in hardware inside the ixgbe card, rather
> than in software.
>
> For now this patch limits the hardware to 8 offloaded macvlan ports.
> A follow on patch will remove this limitation but to simplify
> review/validation of the new macvlan offload ops we leave it at 8
> for now.
>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>
> CC: Andy Gospodarek <andy@greyhouse.net>
> CC: "David S. Miller" <davem@davemloft.net>
> ---

[...]

>
>   #define IXGBE_MAX_RSS_INDICES  16
> -#define IXGBE_MAX_VMDQ_INDICES 64
> +#define IXGBE_MAX_VMDQ_INDICES	8

This define is also used for max VFs in SR-IOV mode so we can't just
redefine it like this without also limiting SR-IOV.

[...]

> +static void ixgbe_fwd_del(struct net_device *pdev, void *priv)
> +{
> +	struct ixgbe_fwd_adapter *fwd_adapter = priv;
> +	struct ixgbe_adapter *adapter = fwd_adapter->real_adapter;
> +
> +	clear_bit(fwd_adapter->pool, &adapter->fwd_bitmask);
> +	adapter->num_rx_pools--;
> +
> +	ixgbe_fwd_ring_down(fwd_adapter->netdev, fwd_adapter);
> +
> +	netdev_dbg(pdev, "pool %i:%i queues %i:%i VSI bitmask %lx\n",
> +		   fwd_adapter->pool, adapter->num_rx_pools,
> +		   fwd_adapter->rx_base_queue,
> +		   fwd_adapter->rx_base_queue + adapter->num_rx_queues_per_pool,
> +		   adapter->fwd_bitmask);

Missing a kfree(fwd_adapter) here, and a ixgbe_setup_tc() call to
release the queues.

I'm testing a fix now and will send a v3.

Thanks,
John
