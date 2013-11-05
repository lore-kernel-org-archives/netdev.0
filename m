From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2 2/2] ixgbe: enable l2 forwarding acceleration for
 macvlans
Date: Tue, 5 Nov 2013 09:26:31 -0500
Message-ID: <20131105142631.GB14954@hmsreliant.think-freely.org>
References: <20131104185717.11802.69282.stgit@jf-dev1-dcblab>
 <20131104190154.11802.75724.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alexander.h.duyck@intel.com, netdev@vger.kernel.org,
	andy@greyhouse.net, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:57673 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754596Ab3KEO0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Nov 2013 09:26:49 -0500
Content-Disposition: inline
In-Reply-To: <20131104190154.11802.75724.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 04, 2013 at 11:01:55AM -0800, John Fastabend wrote:
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

A few Nits, since you're going to send a V3 anyway.  Comments inline.

> ---
><snip> 
> +static void ixgbe_configure_vsi(struct ixgbe_adapter *adapter)
> +{
> +	struct net_device *upper;
> +	struct list_head *iter;
> +	int err;
> +
> +	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
> +		if (netif_is_macvlan(upper)) {
> +			struct macvlan_dev *vlan = netdev_priv(upper);
> +			struct ixgbe_fwd_adapter *vadapter = vlan->fwd_priv;
> +
> +			if (vlan->fwd_priv) {
> +				err = ixgbe_fwd_ring_up(upper, vadapter);
> +				if (err)
> +					continue;
> +				ixgbe_macvlan_set_rx_mode(upper,
> +							  vadapter->pool,
> +							  adapter);
Nit: You're using macvlan here, and vsi above.  Might be nice to give everything
a consistent suffix/prefix for clarity.  Perhaps dfwd since thats what the new
ndo_ops uses?

><snip>
  
>  static inline bool ixgbe_is_sfp(struct ixgbe_hw *hw)
> @@ -4317,6 +4521,8 @@ static void ixgbe_setup_gpie(struct ixgbe_adapter *adapter)
>  static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
>  {
>  	struct ixgbe_hw *hw = &adapter->hw;
> +	struct net_device *upper;
> +	struct list_head *iter;
>  	int err;
>  	u32 ctrl_ext;
>  
> @@ -4360,6 +4566,16 @@ static void ixgbe_up_complete(struct ixgbe_adapter *adapter)
>  	/* enable transmits */
>  	netif_tx_start_all_queues(adapter->netdev);
>  
> +	/* enable any upper devices */
> +	netdev_for_each_all_upper_dev_rcu(adapter->netdev, upper, iter) {
> +		if (netif_is_macvlan(upper)) {
> +			struct macvlan_dev *vlan = netdev_priv(upper);
> +
> +			if (vlan->fwd_priv)
> +				netif_tx_start_all_queues(upper);
> +		}
> +	}
> +
I don't think it matters much, but do we want to start the upper devs queues
here unilaterally?  Nominally a network interface starts its queues on dev_open.
Would it be better to only start those devices if (vlan->fwd_priv &&
(upper->flags & IFF_UP)?  We would then have to listen for NETDEV_UP events as
well to handle accelerated macvlans comming up after ixgbe does, which is more
work, but I wanted to mention this in case theres some disadvantage to starting
the queue early.


Other than that I think it looks good though.  Nice work!

Regards
Neil
