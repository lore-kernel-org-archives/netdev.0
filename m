From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 3/4] ethoc: align received packet to make IP header at
 word boundary
Date: Wed, 7 Oct 2009 09:13:37 -0700
Message-ID: <20091007091337.532d9ed1@nehalam>
References: <1254735200-2718-1-git-send-email-thomas@wytron.com.tw>
	<1254735200-2718-2-git-send-email-thomas@wytron.com.tw>
	<1254735200-2718-3-git-send-email-thomas@wytron.com.tw>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Thomas Chou <thomas@wytron.com.tw>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43285 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752982AbZJGQOT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Oct 2009 12:14:19 -0400
In-Reply-To: <1254735200-2718-3-git-send-email-thomas@wytron.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon,  5 Oct 2009 17:33:19 +0800
Thomas Chou <thomas@wytron.com.tw> wrote:

> The packet buffer is allocated at 4 bytes boundary, but the IP header
> length and version bits is located at byte 14. These bit fields access
> as 32 bits word and caused exception on processors that do not support
> unaligned access.
> 
> The patch adds 2 bytes offset to make the bit fields word aligned.
> 
> Signed-off-by: Thomas Chou <thomas@wytron.com.tw>
> ---
>  drivers/net/ethoc.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethoc.c b/drivers/net/ethoc.c
> index f92747f..0c6c7f4 100644
> --- a/drivers/net/ethoc.c
> +++ b/drivers/net/ethoc.c
> @@ -399,6 +399,10 @@ static int ethoc_rx(struct net_device *dev, int limit)
>  		if (ethoc_update_rx_stats(priv, &bd) == 0) {
>  			int size = bd.stat >> 16;
>  			struct sk_buff *skb = netdev_alloc_skb(dev, size);
> +
> +			size -= 4; /* strip the CRC */
> +			skb_reserve(skb, 2); /* align TCP/IP header */

Please use NET_IP_ALIGN rather than hard coding 2 so that the value
can be changed on a per-cpu architecture basis if desired.

-- 
