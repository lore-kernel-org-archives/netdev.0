From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 NEXT 1/1] net: ethtool support to configure number of
 channels
Date: Wed, 06 Apr 2011 21:20:47 +0100
Message-ID: <1302121247.2840.50.camel@bwh-desktop>
References: <1301720283-25038-1-git-send-email-amit.salecha@qlogic.com>
	 <20110406.125637.70201394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: amit.salecha@qlogic.com, netdev@vger.kernel.org,
	ameen.rahman@qlogic.com, anirban.chakraborty@qlogic.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:19395 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756612Ab1DFUUv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 16:20:51 -0400
In-Reply-To: <20110406.125637.70201394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2011-04-06 at 12:56 -0700, David Miller wrote:
> From: Amit Kumar Salecha <amit.salecha@qlogic.com>
> Date: Fri,  1 Apr 2011 21:58:03 -0700
> 
> > o There exist ETHTOOL_GRXRINGS command for getting number of RX rings,
> >   but it is tigtly coupled with RX flow hash configuration.
> > o Patches for qlcnic and netxen_nic driver supporting rx channel will follow
> >   soon.
> > o This patch is reworked on Ben Hutchings "ethtool: NUMA affinity control" patch,
> >   dropping the affinity control from it.
> > 
> > Ben Hutching:
> > o define 'combined' and 'other' types.  Most multiqueue drivers pair up RX and TX
> >   queues so that most channels combine RX and TX work.
> > o Please could you use a kernel-doc comment to describe the structure.
> > 
> > Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> > Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>
> 
> Ben, are you currently OK with this patch?
> 
> There was some back and forth, and I just want to make sure all of the
> issues you raised were addressed to your satisfaction.

I'm afraid not.

On Fri, 2011-04-01 at 21:58 -0700, Amit Kumar Salecha wrote:
o There exist ETHTOOL_GRXRINGS command for getting number of RX rings,
>   but it is tigtly coupled with RX flow hash configuration.
> o Patches for qlcnic and netxen_nic driver supporting rx channel will follow
>   soon.
> o This patch is reworked on Ben Hutchings "ethtool: NUMA affinity control" patch,
>   dropping the affinity control from it.
> 
> Ben Hutching:
> o define 'combined' and 'other' types.  Most multiqueue drivers pair up RX and TX
>   queues so that most channels combine RX and TX work.
> o Please could you use a kernel-doc comment to describe the structure.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: Amit Kumar Salecha <amit.salecha@qlogic.com>

Amit, I told you already that you must not use my Signed-off-by line
since you are changing the patch significantly.

> ---
>  include/linux/ethtool.h |   41 +++++++++++++++++++++++++++++++++++++++++
>  net/core/ethtool.c      |   41 +++++++++++++++++++++++++++++++++++++++++
>  2 files changed, 82 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
> index c8fcbdd..3c4d968 100644
> --- a/include/linux/ethtool.h
> +++ b/include/linux/ethtool.h
> @@ -229,6 +229,42 @@ struct ethtool_ringparam {
>  	__u32	tx_pending;
>  };
>  
> +/**
> + * struct ethtool_channels - configuring number of network channel
> + * @cmd: ETHTOOL_{G,S}CHANNELS
> + * @type: Channel type defined in ethtool_channel_type
> + * @max_XX: Read only. Maximum number of channel the driver support
> + * @XX_count: Valid values are in the range 1 to the "max_XX" counterpart above.

The kernel-doc tools are going to complain about these field names with
'XX' in them.  You'll have to describe each field individually.

> + * This can be used to configure RX,TX and other channels.
> + */
> +
> +struct ethtool_channels {
> +	__u32	cmd;
> +	__u32	type;
> +	__u32	max_rx;
> +	__u32	max_tx;
> +	__u32	max_other;
> +	__u32	rx_count;
> +	__u32	tx_count;
> +	__u32	other_count;
> +};
> +
> +/* Channel type */
> +/* Channel type should be pass in type field of ethtool_channels.
> + * TYPE_ALL indicates set all channels to XX_count values.
> + * TYPE_RX and TYPE_TX is to get and set RX and TX channels correspondingly.
> + * TYPE_COMBINED is to set both RX and TX channels to rx_count and tx_count
> + * correspondingly.

That's not what I meant by 'combined'.  I meant a set of RX queues and
TX queues (usually 1 of each) with an IRQ and maybe an event queue
shared between them.  It should be possible for ethtool to distinguish
combined channels, so it doesn't just report 'Invalid argument' if the
user tries to set rx_count != tx_count.

I think this requires that there are max_combined and combined_count (or
similar) fields in struct ethtool_channels, so a driver that only
supports combined channels can report max_rx = 0, max_tx = 0,
max_combined = N.

> TYPE_OTHER is to configure other channel.
> + */
> +enum ethtool_channel_type {
> +	ETH_CHAN_TYPE_ALL	= 0,
> +	ETH_CHAN_TYPE_RX,
> +	ETH_CHAN_TYPE_TX,
> +	ETH_CHAN_TYPE_COMBINED,
> +	ETH_CHAN_TYPE_OTHER,
> +};
[...]

Really I'm not sure whether there's a need to be able to specify which
channel counts are being changed.  ethtool or whatever utility is used
can do ETHTOOL_GCHANNELS, modify channel counts, ETHTOOL_SCHANNELS and
all the counts the user didn't want to change will be unchanged.  If you
still think it is useful then use flags for the different channel types
so there is no arbitrary restriction on which counts can be changed at
the same time.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

