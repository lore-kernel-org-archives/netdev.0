From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH #2] [8021Q]: Turn off all the hardware VLAN features for
 promisc
Date: Thu, 20 Mar 2008 15:46:10 +0100
Message-ID: <47E278B2.1000102@trash.net>
References: <20080319081110.GA12081@tp61p-64>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Joonwoo Park <joonwpark81@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from viefep11-int.chello.at ([62.179.121.31]:59881 "EHLO
	viefep11-int.chello.at" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754409AbYCTOqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 10:46:15 -0400
In-Reply-To: <20080319081110.GA12081@tp61p-64>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Joonwoo Park wrote:
> ---
> This is the 2nd try for the issue about vlan & promisc
> resolve: http:/bugzilla.kernel.org/show_bug.cgi?id=8218
> 
> An interface which has promisc flag should get/show all the packets on the wire, I believe.
> But the hardware VLAN features are breaking it.
> We might need to make a compromise with a performance for stand againt it.
> 
> The kernel can be polite to tcpdump by turnning off
>  HW_TX & HW_RX: shows vlan header
>  HW_FILTER: shows vlan id packet that we didn't configure
> 
> Thanks,
> Joonwoo
> 
> ---
> [PATCH #2] [8021Q]: Turn off all the hardware VLAN features for promisc
> Makes the netdev to disable HW_VLAN_TX, HW_VLAN_RX, HW_VLAN_FILTER
> for the interfaces which goes into the promiscuous.
> 
> Signed-off-by: Joonwoo Park <joonwpark81@gmail.com>
> ---
>  include/linux/if_vlan.h |   24 +++++++++++----
>  net/8021q/vlan.c        |   74 +++++++++++++++++++++++++++++++++++++++++++++++
>  net/8021q/vlan.h        |    5 +++
>  net/8021q/vlan_dev.c    |    9 +++--
>  net/core/dev.c          |   11 +++++++
>  5 files changed, 113 insertions(+), 10 deletions(-)
> 
>  /* VLAN IOCTLs are found in sockios.h */
> diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
> index dbc81b9..b1f6fca 100644
> --- a/net/8021q/vlan.c
> +++ b/net/8021q/vlan.c
> @@ -470,6 +470,80 @@ out:
>  	return NOTIFY_DONE;
>  }
>  
> +void vlan_dev_disable_hwaccel(struct net_device *any_dev)
> +{
> +	struct vlan_group *grp;
> +	struct net_device *real_dev;
> +	int i;
> +
> +	ASSERT_RTNL();
> +
> +	if (any_dev->priv_flags & IFF_802_1Q_VLAN)
> +		return;
> +
> +	real_dev = any_dev;
> +
> +	grp = __vlan_find_group(real_dev->ifindex);
> +	if (!grp)
> +		return;


This doesn't look right. You check whether the device is
a VLAN device above, but then treat it as the underlying
device.

> +
> +	for (i = 0; i < VLAN_VID_MASK; i++) {
> +		struct net_device *dev = vlan_group_get_device(grp, i);
> +		if (dev) {
> +			if (real_dev->features &
> +			    (NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLAN_FILTER)) {
> +				real_dev->vlan_rx_kill_vid(real_dev, i);
> +				vlan_group_set_device(grp, i, dev);
> +			}
> +			if (real_dev->features & NETIF_F_HW_VLAN_TX) {
> +				dev->header_ops = &vlan_header_ops;
> +				dev->hard_header_len = real_dev->hard_header_len
> +					+ VLAN_HLEN;
> +				dev->hard_start_xmit = vlan_dev_hard_start_xmit;
> +			}
> +		}
> +	}
> +
> +	if (real_dev->features & NETIF_F_HW_VLAN_RX)
> +		real_dev->vlan_rx_register(real_dev, NULL);


I think a better way to handle this would be to make packet
sockets understand VLAN accerlation, similar to partial
checksums. This would mean on TX we get the tag from the
packets meta data and put it in the auxillary data.
RX should probably be handled by the driver by disabling
VLAN filtering when promiscous mode is enabled.

VLAN stripping would currently also have to be disabled,
but since its necessary to move the tag from the CB
to the skb anyways for avoiding qdiscs trampling over
it, once we've done that we could keep stripping enabled
and also store the VID on RX and make it visible to
packet sockets.

This would require to teach userspace about the new
auxillary data, but allows to use tcpdump and vlan
accerlation at the same time and doesn't require to
disabling accerlation when going to promiscous mode
for other reasons (like secondary unicast addresses).
