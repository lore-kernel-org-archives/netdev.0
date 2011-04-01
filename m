From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net: ethtool support to configure number of channels
Date: Fri, 01 Apr 2011 18:10:24 +0100
Message-ID: <1301677824.4679.10.camel@bwh-desktop>
References: <1301652075-382-1-git-send-email-amit.salecha@qlogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, sucheta.chakraborty@qlogic.com,
	anirban.chakraborty@qlogic.com
To: Amit Kumar Salecha <amit.salecha@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:53061 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758412Ab1DARK1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 13:10:27 -0400
In-Reply-To: <1301652075-382-1-git-send-email-amit.salecha@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2011-04-01 at 03:01 -0700, Amit Kumar Salecha wrote:
> o Instead of cluttering struct ethtool_channels, defined channel type in
>   struct ethtool_channels, making it scalable for addition future channels.
>   Application needs to send different ioctl for each channel type.
> o There exist ETHTOOL_GRXRINGS command for getting number of RX rings,
>   but it is tigtly coupled with RX flow hash configuration.
> o New channel id can be added in ethtool_channel_id to make it configurable.
> o Patches for qlcnic and netxen_nic driver supporting rx channel will follow
>   soon.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Since you have modified this, you must not use my Signed-off-by without
explaining that you have done so.

> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> ---
>  include/linux/ethtool.h |   27 +++++++++++++++++++++++++++
>  net/core/ethtool.c      |   41 +++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 68 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index c8fcbdd..cdb69d6 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -229,6 +229,28 @@ struct ethtool_ringparam {
>  	__u32	tx_pending;
>  };
>  
> +/* for configuring number of network channel */
> +struct ethtool_channels {
> +	__u32	cmd;	/* ETHTOOL_{G,S}CHANNELS */
> +	__u32	type;	/* Channel type defined in ethtool_channel_id */
> +
> +	/* Read only attributes.  These indicate the maximum number
> +	 * of channel the driver will allow the user to set.
> +	 */
> +	__u32	max;

This is a single read-only attribute, not 'attributes'.

> +	/* Values changeable by the user.  The valid values are
> +	 * in the range 1 to the "*_max" counterpart above.
> +	 */
> +	__u32	pending;
> +};

Please could you use a kernel-doc comment to describe the structure.  I
know my earlier patch (and most of the existing structures in ethtool.h)
didn't, but I have been gradually changing that.

I'm not sure why you reduced this to a single count.  If if the driver
or hardware doesn't allow certain combinations of counts, it might be
necessary to configure several types at the same time 

> +/* Channel ID is made up of a type */
> +enum ethtool_channel_id {
> +	ETH_CHAN_TYPE_RX = 0x1,
> +	ETH_CHAN_TYPE_TX = 0x2
> +};
[...]

enum ethtool_channel_id was meant to be an identifier of a specific
channel.  An enumeration of channel types should be named differently.

This also omits the 'combined' and 'other' types.  Most multiqueue
drivers pair up RX and TX queues so that most channels combine RX and TX
work.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

