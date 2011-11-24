From: jasowang <jasowang@redhat.com>
Subject: Re: [PATCH] macvtap: Fix macvtap_get_queue to use rxhash first
Date: Thu, 24 Nov 2011 17:36:40 +0800
Message-ID: <4ECE1028.9000700@redhat.com>
References: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, mst@redhat.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	levinsasha928@gmail.com, davem@davemloft.net
To: Krishna Kumar <krkumar2@in.ibm.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <20111124081714.26635.68141.sendpatchset@krkumar2.in.ibm.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 11/24/2011 04:17 PM, Krishna Kumar wrote:
> It was reported that the macvtap device selects a
> different vhost (when used with multiqueue feature)
> for incoming packets of a single connection. Use
> packet hash first. Patch tested on MQ virtio_net.
>
> Signed-off-by: Krishna Kumar<krkumar2@in.ibm.com>
> ---
>   drivers/net/macvtap.c |   16 ++++++++--------
>   1 file changed, 8 insertions(+), 8 deletions(-)
>
> diff -ruNp org/drivers/net/macvtap.c new/drivers/net/macvtap.c
> --- org/drivers/net/macvtap.c	2011-10-22 08:38:01.000000000 +0530
> +++ new/drivers/net/macvtap.c	2011-11-16 18:34:51.000000000 +0530
> @@ -175,6 +175,14 @@ static struct macvtap_queue *macvtap_get
>   	if (!numvtaps)
>   		goto out;
>
> +	/* Check if we can use flow to select a queue */
> +	rxq = skb_get_rxhash(skb);
> +	if (rxq) {
> +		tap = rcu_dereference(vlan->taps[rxq % numvtaps]);
> +		if (tap)
> +			goto out;
> +	}
> +
>   	if (likely(skb_rx_queue_recorded(skb))) {
>   		rxq = skb_get_rx_queue(skb);
>   

Looks reasonable and we can improve this further by implementing  
smarter queue selection with the co-operation of guest. I think one 
initiate of this is to let the packets of a flow to be handled by the 
same guest cpu/vhost thread. This can be done by using accelerate rfs in 
virtio-net driver and 'tell' the macvtap/tap which queue should a packet 
go. I've started  working on prototype of this, it should solves the 
issue of packet steering in guest.

One more thought on this is,  If a nic (such as ixgbe) with flow 
director or similar technology is used, it can make sure the packet 
belongs to a flow to be handled by host cpu. If we can make use of this 
feature, more cache locality would be gained.
> @@ -186,14 +194,6 @@ static struct macvtap_queue *macvtap_get
>   			goto out;
>   	}
>
> -	/* Check if we can use flow to select a queue */
> -	rxq = skb_get_rxhash(skb);
> -	if (rxq) {
> -		tap = rcu_dereference(vlan->taps[rxq % numvtaps]);
> -		if (tap)
> -			goto out;
> -	}
> -
>   	/* Everything failed - find first available queue */
>   	for (rxq = 0; rxq<  MAX_MACVTAP_QUEUES; rxq++) {
>   		tap = rcu_dereference(vlan->taps[rxq]);
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
