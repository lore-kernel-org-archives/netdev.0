From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware
	Unit Hang"
Date: Thu, 15 Jan 2015 18:37:10 +0100
Message-ID: <1951915.1kCMSXLj6g@storm>
References: <1719052.SGOfRAJhfQ@storm> <1837410.pEGIH05mML@storm>
	<1421342437.11734.79.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel <e1000-devel@lists.sourceforge.net>,
	'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
In-Reply-To: <1421342437.11734.79.camel@edumazet-glaptop2.roam.corp.google.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Thursday, 15. January 2015 09:20:37 Eric Dumazet wrote:
> > for the sake of completeness:
> > 1: hang
> 
> This is weird : This should have same effect then GRO off (at most one
> segment per packet)

I thought so, too. OTOH the code path was changed from
"goto merge" to "return -E2BIG". I didn't look at the code
what happens at the "merge" label.

> Could you try the following ?
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> b/drivers/net/ethernet/intel/e1000e/netdev.c index
> 38cb586b1bf42fa7a50e19f3e650e8c139788820..6d93facddab78f8db7000fddaa24322
> 651a0eae9 100644 --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -1264,7 +1264,7 @@ static bool e1000_clean_tx_irq(struct e1000_ring
> *tx_ring)
> 
>  	netdev_completed_queue(netdev, pkts_compl, bytes_compl);
> 
> -#define TX_WAKE_THRESHOLD 32
> +#define TX_WAKE_THRESHOLD (MAX_SKB_FRAGS * 3 + 2)
>  	if (count && netif_carrier_ok(netdev) &&
>  	    e1000_desc_unused(tx_ring) >= TX_WAKE_THRESHOLD) {
>  		/* Make sure that anybody stopping the queue after this
> @@ -5650,10 +5650,7 @@ static netdev_tx_t e1000_xmit_frame(struct sk_buff
> *skb, netdev_sent_queue(netdev, skb->len);
>  		e1000_tx_queue(tx_ring, tx_flags, count);
>  		/* Make sure there is space in the ring for the next send. */
> -		e1000_maybe_stop_tx(tx_ring,
> -				    (MAX_SKB_FRAGS *
> -				     DIV_ROUND_UP(PAGE_SIZE,
> -						  adapter->tx_fifo_limit) + 2));
> +		e1000_maybe_stop_tx(tx_ring, 3 * MAX_SKB_FRAGS + 2);
>  	} else {
>  		dev_kfree_skb_any(skb);
>  		tx_ring->buffer_info[first].time_stamp = 0;

I was just about to leave the office... and switched the test box back on.

Also reverted to vanilla 3.19-rc4+ and applied the above patch instead.
Still hangs. Grrr. More testing tomorrow.


------------------------------------------------------------------------------
New Year. New Location. New Benefits. New Data Center in Ashburn, VA.
GigeNET is offering a free month of service with a new server in Ashburn.
Choose from 2 high performing configs, both with 100TB of bandwidth.
Higher redundancy.Lower latency.Increased capacity.Completely compliant.
http://p.sf.net/sfu/gigenet
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
