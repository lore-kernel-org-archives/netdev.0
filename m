From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [net-next 03/11] ixgbe: add support for XDP_TX action
Date: Sat, 22 Apr 2017 19:24:11 -0700
Message-ID: <20170422192411.1d85793a@cakuba.lan>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
        <20170421015029.18994-4-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, John Fastabend <john.fastabend@gmail.com>,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, John Fastabend <john.r.fastabend@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:56132 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1427441AbdDWCYa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 22 Apr 2017 22:24:30 -0400
In-Reply-To: <20170421015029.18994-4-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 20 Apr 2017 18:50:21 -0700, Jeff Kirsher wrote:
> +static int ixgbe_xdp_queues(struct ixgbe_adapter *adapter)
> +{
> +	if (nr_cpu_ids > MAX_XDP_QUEUES)
> +		return 0;
> +
> +	return adapter->xdp_prog ? nr_cpu_ids : 0;
> +}

Nit: AFAICT ixgbe_xdp_setup() will guarantee xdp_prog is not set if
there are too many CPU ids.

> @@ -6120,10 +6193,21 @@ static int ixgbe_setup_all_tx_resources(struct ixgbe_adapter *adapter)
>  		e_err(probe, "Allocation for Tx Queue %u failed\n", i);
>  		goto err_setup_tx;
>  	}
> +	for (j = 0; j < adapter->num_xdp_queues; j++) {
> +		err = ixgbe_setup_tx_resources(adapter->xdp_ring[j]);
> +		if (!err)
> +			continue;
> +
> +		e_err(probe, "Allocation for Tx Queue %u failed\n", j);
> +		goto err_setup_tx;
> +	}
> +
>  

Nit: extra line here

> @@ -9557,7 +9739,21 @@ static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
>  			return -EINVAL;
>  	}
>  
> +	if (nr_cpu_ids > MAX_XDP_QUEUES)
> +		return -ENOMEM;
> +
>  	old_prog = xchg(&adapter->xdp_prog, prog);
> +
> +	/* If transitioning XDP modes reconfigure rings */
> +	if (!!prog != !!old_prog) {
> +		int err = ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
> +
> +		if (err) {
> +			rcu_assign_pointer(adapter->xdp_prog, old_prog);
> +			return -EINVAL;
> +		}
> +	}
> +
>  	for (i = 0; i < adapter->num_rx_queues; i++)
>  		xchg(&adapter->rx_ring[i]->xdp_prog, adapter->xdp_prog);
>  

In case of disabling XDP I assume ixgbe_setup_tc() will free the rings
before the xdp_prog on the rings is swapped to NULL.  Is there anything
preventing TX in that time window?  I think usual ordering would be to
install the prog after reconfig but uninstall before.
