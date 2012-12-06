From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next 0/1] fix vlan transmit performance
Date: Thu, 6 Dec 2012 23:42:01 +0000
Message-ID: <1354837321.2828.86.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354827296-12009-1-git-send-email-gallatin@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:47520 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751716Ab2LFXmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 18:42:05 -0500
In-Reply-To: <1354827296-12009-1-git-send-email-gallatin@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-12-06 at 15:54 -0500, Andrew Gallatin wrote:
> Hi,
> 
> When doing some 10GbE perf measurments on very old athlon64
> machines with myri10ge, I noticed that I was seeing CPU saturation
> when transmitting vlan tagged traffic.  I think I traced the
> problem to this line in netif_skb_features():
> 
> 	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_TX);
> 
> The problem seems to be that packets travel through this function
> twice, first on their way to the vlan xmit handler, and then on
> their way to the backing device's xmit handler.  On the first
> pass, "skb->dev" is the vlan device, and skb->dev->vlan_features
> is blank.  This causes netif_skb_features() to strip the offloads
> away.

On the first pass through dev_hard_start_xmit(), we should have:

	if (protocol == htons(ETH_P_8021Q)) {		// false
		...
	} else if (!vlan_tx_tag_present(skb)) {		// true
		return harmonize_features(skb, protocol, features);
	}
	// not executed
	features &= (skb->dev->vlan_features | NETIF_F_HW_VLAN_TX);
	...

Then the VLAN tag gets inserted in vlan_dev_hard_start_xmit(), and for
the second pass we used the vlan_features of the underlying device.

However, when reorder_hdr is off and the underlying device doesn't have
NETIF_F_VLAN_TX, the VLAN tag is inserted before the first pass, in
vlan_dev_hard_header().  Then, as you've seen, all TX offload features
get disabled.  (Prior to Linux 2.6.37 this configuration was
*completely* broken as the TX path didn't make consistent decisions
about whether offload features could be used.)

My answer would be: leave reorder_hdr enabled per default.  In fact,
perhaps the VLAN driver's TX path should ignore it if the underlying
device has non-zero vlan_features.  (It's already ignored if the
underlying device has NETIF_F_VLAN_TX.)

> The following patch (just copy dev->features to dev->vlan_features in
> vlan_dev_init()) seems to be the simplest way to fix it. Perhaps this
> is wrong, and there is a better way?
[...]

It's wrong, because those features would then be recursively transferred
to further stacked VLAN devices.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
