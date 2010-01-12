From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v3] can: Unify droping of invalid tx skbs
	and netdev stats
Date: Tue, 12 Jan 2010 09:32:11 +0100
Message-ID: <4B4C338B.7000808@hartkopp.net>
References: <4B4BB1F9.3010808@hartkopp.net>
	<20100111.155537.166350032.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org,
	wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <20100111.155537.166350032.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
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

David Miller wrote:
> From: Oliver Hartkopp <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
> Date: Tue, 12 Jan 2010 00:19:21 +0100
> 
>>  static netdev_tx_t vcan_tx(struct sk_buff *skb, struct net_device *dev)
>>  {
>> +	struct can_frame *cf = (struct can_frame *)skb->data;
>>  	struct net_device_stats *stats = &dev->stats;
>>  	int loop;
>>  
>> +	if (unlikely(skb->len != sizeof(*cf) || cf->can_dlc > 8)) {
>> +		kfree_skb(skb);
>> +		stats->tx_dropped++;
>> +		return NETDEV_TX_OK;
>> +	}
>> +
>  ...
>> +/* Drop a given socketbuffer if it does not contain a valid CAN frame. */
>> +static inline int can_dropped_invalid_skb(struct net_device *dev,
>> +					  struct sk_buff *skb)
>> +{
>> +	const struct can_frame *cf = (struct can_frame *)skb->data;
>> +
>> +	if (unlikely(skb->len != sizeof(*cf) || cf->can_dlc > 8)) {
>> +		kfree_skb(skb);
>> +		dev->stats.tx_dropped++;
>> +		return 1;
>> +	}
>> +
>> +	return 0;
>> +}
>> +
>>  struct net_device *alloc_candev(int sizeof_priv, unsigned int echo_skb_max);
> 
> Why are you not using the new helper function in vcan_tx()?

I just wanted the vcan driver keep off including "include/linux/can/dev.h"
which is intended for 'real' CAN hardware.

As the vcan software devices do not need the bitrate-setting and skb echo
handling from the driver library for real CAN devices, this inline function
would be the only reason to include ".../dev.h"

But i don't have a strong preference to do it like this. Do you think i
should change it to used the defined inline function?

Regards,
Oliver
