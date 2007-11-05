From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 1/2] NET: Re-add VLAN tag for devices incapable of keeping
 it
Date: Mon, 05 Nov 2007 19:00:19 +0100
Message-ID: <472F5A33.20906@trash.net>
References: <472A49BD.6000802@hp.com>	<20071101.145956.63020380.davem@davemloft.net>	<472A4D5C.2070301@hp.com>	<20071101.150723.30590053.davem@davemloft.net>	<472A6089.7020104@hp.com> <18223.22291.622615.129374@zeus.sw.starentnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jes@trained-monkey.org,
	mchan@broadcom.com, ram.vepa@neterion.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	bguo@sw.starentnetworks.com
To: Dave Johnson <djohnson+linux-kernel@sw.starentnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:40372 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950AbXKESAf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Nov 2007 13:00:35 -0500
In-Reply-To: <18223.22291.622615.129374@zeus.sw.starentnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Johnson wrote:
> +/* VLAN rx hw acceleration helper.  This acts like netif_{rx,receive_skb}(). */
> +static inline int __vlan_hwaccel_rx(struct sk_buff *skb,
> +				    struct vlan_group *grp,
> +				    unsigned short vlan_tag, int polling)
> +{
> ...
> +		/* Driver removed vlan tag from the packet, but we have no
> +		 * vlan device for this VID.
> +		 *
> +		 * This can occur for 2 reasons:
> +		 * 1) Have a vlan group, we want some VIDs, just not this VID.
> +		 * 2) Have no vlan group, but hardware limitation requires it
> +		 *    to remove vlan tags anyway.
> +		 *
> +		 * Normally if no vlan group is configured, the underlying
> +		 * driver will configure the hardware to NOT strip out the
> +		 * vlan tag.  It can then call netif_receive_skb/netif_rx
> +		 * with the vlan tag still intact.  However some devices
> +		 * cannot be configured to keep the vlan tag and must not
> +		 * call netif_receive_skb/netif_rx with the vlan tag
> +		 * missing.  This would allow the normal protocol handlers
> +		 * to process this tagged packet as if it arived without a
> +		 * vlan tag.
> +		 *
> +		 * We need to re-add the TAG and hand the packet off to the
> +		 * base device with the TAG present so any protocol handlers
> +		 * (PF_PACKET, etc...) will get a chance to see it.
> +		 */


This looks like a rather expensive operation for the unlikely case
that packets will be received by a packet socket. IMO it should only
be reconstructed if actually needed, by af_packet itself.

As we discussed some time back storing the VLAN tag in the CB on
TX clashes with other users of the CB like qdiscs, so we need a
new field in the skb for this anyway.

