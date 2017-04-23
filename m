From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [net-next 03/11] ixgbe: add support for XDP_TX action
Date: Sat, 22 Apr 2017 20:52:25 -0700
Message-ID: <20170422205226.1389d2dc@cakuba.lan>
References: <20170421015029.18994-1-jeffrey.t.kirsher@intel.com>
        <20170421015029.18994-4-jeffrey.t.kirsher@intel.com>
        <20170422192411.1d85793a@cakuba.lan>
        <58FC2226.3070207@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
        netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com, John Fastabend <john.r.fastabend@intel.com>
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx4.wp.pl ([212.77.101.11]:6208 "EHLO mx4.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1427506AbdDWDwt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sat, 22 Apr 2017 23:52:49 -0400
In-Reply-To: <58FC2226.3070207@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 22 Apr 2017 20:40:22 -0700, John Fastabend wrote:
> >> @@ -9557,7 +9739,21 @@ static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
> >>  			return -EINVAL;
> >>  	}
> >>  
> >> +	if (nr_cpu_ids > MAX_XDP_QUEUES)
> >> +		return -ENOMEM;
> >> +
> >>  	old_prog = xchg(&adapter->xdp_prog, prog);
> >> +
> >> +	/* If transitioning XDP modes reconfigure rings */
> >> +	if (!!prog != !!old_prog) {
> >> +		int err = ixgbe_setup_tc(dev, netdev_get_num_tc(dev));
> >> +
> >> +		if (err) {
> >> +			rcu_assign_pointer(adapter->xdp_prog, old_prog);
> >> +			return -EINVAL;
> >> +		}
> >> +	}
> >> +
> >>  	for (i = 0; i < adapter->num_rx_queues; i++)
> >>  		xchg(&adapter->rx_ring[i]->xdp_prog, adapter->xdp_prog);
> >>    
> > 
> > In case of disabling XDP I assume ixgbe_setup_tc() will free the rings
> > before the xdp_prog on the rings is swapped to NULL.  Is there anything
> > preventing TX in that time window?  I think usual ordering would be to
> > install the prog after reconfig but uninstall before.
> >   
> 
> Well in the ixgbe_setup_tc() case we set the rx_ring->xdp_prog in
> ixgbe_setup_rx_resorources(), while the dma engine is disabled, so the for
> loop is just doing another set on the rx_ring assigning it to the program
> already set previously.
> 
> Its not really buggy its just extra useless work so I'll change it to this,
> 
> 	if (!!prog != !!old_prog) {
> 		...
> 	} else {
> 		for ( ... )
> 			swap xdp prog
> 	}
> 
> Nice spot, thanks for reviewing. And I missed a build error so I'll roll these
> fixes in a resend.

Ah, thanks for explaining.  No bugs that I can spot then :)
