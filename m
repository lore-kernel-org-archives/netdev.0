From: Jakub Kicinski <kubakici@wp.pl>
Subject: Re: [PATCH 1/2] ixgbe: add XDP support for pass and drop actions
Date: Sun, 23 Apr 2017 21:05:06 -0700
Message-ID: <20170423210506.79168335@laptop>
References: <20170424013004.8354.34893.stgit@john-Precision-Tower-5810>
        <20170424013119.8354.18750.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.wp.pl ([212.77.101.10]:7855 "EHLO mx3.wp.pl"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750786AbdDXEFN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 24 Apr 2017 00:05:13 -0400
In-Reply-To: <20170424013119.8354.18750.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Sun, 23 Apr 2017 18:31:19 -0700, John Fastabend wrote:
> +static int ixgbe_xdp_setup(struct net_device *dev, struct bpf_prog *prog)
> +{
> +	int i, frame_size = dev->mtu + ETH_HLEN + ETH_FCS_LEN + VLAN_HLEN;
> +	struct ixgbe_adapter *adapter = netdev_priv(dev);
> +	struct bpf_prog *old_prog;
> +
> +	if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED)
> +		return -EINVAL;
> +
> +	if (adapter->flags & IXGBE_FLAG_DCB_ENABLED)
> +		return -EINVAL;
> +
> +	/* verify ixgbe ring attributes are sufficient for XDP */
> +	for (i = 0; i < adapter->num_rx_queues; i++) {
> +		struct ixgbe_ring *ring = adapter->rx_ring[i];
> +
> +		if (ring_is_rsc_enabled(ring))
> +			return -EINVAL;
> +
> +		if (frame_size > ixgbe_rx_bufsz(ring))
> +			return -EINVAL;
> +	}

I was just looking through the drivers, working on extended ack
reporting, trying to bring out the driver XDP error messages out
directly to iproute2.  It seems that multiple drivers are only 
checking that MTU/buffer size is appropriate in the XDP_SETUP 
function, and ignore XDP in case user tries to change MTU later.  
And I think it's the same story with LRO?
