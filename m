From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 01/10] net: introduce time stamping wrapper for
 netif_rx.
Date: Fri, 10 Jun 2011 08:20:56 -0700
Message-ID: <20110610082056.5ab6b981@nehalam.ftrdhcpuser.net>
References: <cover.1307717675.git.richard.cochran@omicron.at>
	<34a4527448b3a36c88d0c1c3cb9ad8661e693d7a.1307717675.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:60352 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752259Ab1FJPU7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Jun 2011 11:20:59 -0400
In-Reply-To: <34a4527448b3a36c88d0c1c3cb9ad8661e693d7a.1307717675.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 10 Jun 2011 17:06:59 +0200
Richard Cochran <richardcochran@gmail.com> wrote:

> This commit adds a variation on netif_rx() designed to allow non-NAPI
> Ethernet MAC drivers to support hardware time stamping in PHY devices.
> Adapting a given driver requires two small changes, namely replacing
> netif_rx() with netif_rx_defer() and adding a call to skb_tx_timestamp()
> in the transmission path.
> 
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> ---
>  include/linux/netdevice.h |   21 +++++++++++++++++++++
>  1 files changed, 21 insertions(+), 0 deletions(-)
> 
> diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
> index ca333e7..9a56505 100644
> --- a/include/linux/netdevice.h
> +++ b/include/linux/netdevice.h
> @@ -2066,6 +2066,27 @@ extern void dev_kfree_skb_any(struct sk_buff *skb);
>  #define HAVE_NETIF_RX 1
>  extern int		netif_rx(struct sk_buff *skb);
>  extern int		netif_rx_ni(struct sk_buff *skb);
> +
> +/**
> + * netif_rx_defer() - post buffer to the network code
> + * @skb: buffer to post
> + *
> + * This function receives a packet from a device driver and queues it
> + * for the upper (protocol) levels to process.  All non-NAPI Ethernet
> + * MAC drivers should use this instead of netif_rx() since this method
> + * allows hardware timestamping to occur within the PHY.
> + *
> + * return values:
> + * NET_RX_SUCCESS  (no congestion)
> + * NET_RX_DROP     (packet was dropped)
> + */
> +static inline int netif_rx_defer(struct sk_buff *skb)
> +{
> +	if (skb_defer_rx_timestamp(skb))
> +		return NET_RX_SUCCESS;
> +	return netif_rx(skb);
> +}

Obvious question why not just put this in netif_rx.
