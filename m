From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH net-next-2.6] can: Unify droping of invalid tx skbs and
	netdev	stats
Date: Mon, 11 Jan 2010 14:00:19 +0100
Message-ID: <4B4B20E3.3070603@grandegger.com>
References: <4B477BB7.2030108@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: SocketCAN Core Mailing List <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4B477BB7.2030108-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
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

Hi Oliver,

Oliver Hartkopp wrote:
> To prevent the CAN drivers to operate on invalid socketbuffers the skbs are
> now checked and silently dropped at the xmit-function consistently.
> 
> Also the netdev stats are consistently using the CAN data length code (dlc)
> for [rx|tx]_bytes now.
> 
> Signed-off-by: Oliver Hartkopp <oliver-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
> 
> ---
> 
> diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
> index 166cc7e..95567be 100644
> --- a/drivers/net/can/at91_can.c
> +++ b/drivers/net/can/at91_can.c
> @@ -336,18 +336,24 @@ static void at91_chip_stop(struct net_device *dev, enum can_state state)
>   */
>  static netdev_tx_t at91_start_xmit(struct sk_buff *skb, struct net_device *dev)
>  {
>  	struct at91_priv *priv = netdev_priv(dev);
>  	struct net_device_stats *stats = &dev->stats;
>  	struct can_frame *cf = (struct can_frame *)skb->data;
>  	unsigned int mb, prio;
>  	u32 reg_mid, reg_mcr;
>  
> +	if (skb->len != sizeof(*cf) || cf->can_dlc > 8) {
> +		kfree_skb(skb);
> +		dev->stats.tx_dropped++;
> +		return NETDEV_TX_OK;
> +	}

A static inline function "invalid_can_skb(skb)" (or "no_can_skb") would
be handy here:

	if (invalid_can_skb(skb)) {
		kfree_skb(skb);
		dev->stats.tx_dropped++;
		return NETDEV_TX_OK;		
	}

Wolfgang.
