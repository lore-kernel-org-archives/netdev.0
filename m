From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next v3 1/3] can: mscan: fix improper return if dlc
	< 8 in start_xmit function
Date: Thu, 07 Jan 2010 19:10:38 +0100
Message-ID: <4B46239E.2000403@hartkopp.net>
References: <1262873421-6863-1-git-send-email-wg@grandegger.com>
	<1262873421-6863-2-git-send-email-wg@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Devicetree-discuss-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, Linuxppc-dev-uLR06cmDAlY/bJ5BZ2RsiQ@public.gmane.org,
	Wolfgang Grandegger <wg-ynQEQJNshbs@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1262873421-6863-2-git-send-email-wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Wolfgang Grandegger wrote:

> The start_xmit function of the MSCAN Driver did return improperly if
> the CAN dlc check failed (skb not freed and invalid return code). This
> patch adds a proper check of the frame lenght and data size and returns
> now correctly. 

> @@ -177,8 +177,13 @@ static netdev_tx_t mscan_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  	int i, rtr, buf_id;
>  	u32 can_id;
>  
> -	if (frame->can_dlc > 8)
> -		return -EINVAL;
> +	if (skb->len != sizeof(*frame) || frame->can_dlc > 8) {
> +		dev_err(dev->dev.parent,
> +			"Dropping non-conform packet: len %u, can_dlc %u\n",
> +			skb->len, frame->can_dlc);
> +		kfree_skb(skb);
> +		return NETDEV_TX_OK;
> +	}
>  

Hi Wolfgang,

i would suggest to remove the dev_err() which may flood the kernel log and add

   dev->stats.tx_dropped++;

instead.

As discussed with DaveM on netdev-ML this 'silent' handling seems to be the
most appropriate approach to deal with invalid skbs.

We should update the other CAN drivers in a similar way, if this is ok for you.

Best regards,
Oliver
