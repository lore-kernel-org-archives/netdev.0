From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: fix loss of frames due to wrong assumption in raw_rcv
Date: Sun, 21 Jun 2015 00:42:21 +0200
Message-ID: <5585EC4D.40103@hartkopp.net>
References: <5585A104.1090201@gmx.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Manfred Schlaegl <manfred.schlaegl@ginzinger.com>,
	"David S. Miller" <davem@davemloft.net>
To: Manfred Schlaegl <manfred.schlaegl@gmx.at>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo4-p00-ob.smtp.rzone.de ([81.169.146.220]:41053 "EHLO
	mo4-p00-ob.smtp.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752234AbbFTWm2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Jun 2015 18:42:28 -0400
In-Reply-To: <5585A104.1090201@gmx.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Manfred,

On 06/20/2015 07:21 PM, Manfred Schlaegl wrote:
> I've detected a massive loss of can frames on i.MX6 using flexcan
> driver with 4.1-rc8 and tracked this down to following commit:
> 514ac99c64b22d83b52dfee3b8becaa69a92bc4a - "can: fix multiple delivery
> of a single CAN frame for overlapping CAN filters"

thanks for detecting this issue!

> 514ac99c64b22d83b52dfee3b8becaa69a92bc4a introduces a frame equality
> check. Since the sk_buff pointer is not sufficient to do this (buffers
> are reused), the check also compares time stamps.
> In short: pointer+time stamp was assumed as unique key to a specific
> frame.
> The problem with this is, that the time stamp is an optional property
> and not set per default.
> In our case (flexcan) the time stamp is always zero, so the equality
> check is reduced to equality of buffer pointers, resulting in a lot of
> dropped frames.

The question is why your system did not generate a timestamp at the time of
skb reception.

Usually when netif_rx(), netif_rx_ni() is invoked the timestamp is set in the
following reception process.

flexcan.c only uses netif_receive_skb() - but all theses functions set the
timestamp

	net_timestamp_check(netdev_tstamp_prequeue, skb);

depending on netdev_tstamp_prequeue which is configured by

/proc/sys/net/core/netdev_tstamp_prequeue

See the idea of netdev_tstamp_prequeue here:

http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/net/core/sysctl_net_core.c?id=3b098e2d7c693796cc4dffb07caa249fc0f70771

Can you tell me the output of /proc/sys/net/core/netdev_tstamp_prequeue on
your machine?

If it's not '1' can you set it to '1' for a test?

> 
> Possible solutions I thought of:
>  1. Every driver has to set a time stamp
>     (possibly error prone and hard to enforce?)
>  2. Change the equality check
>  3. Fulfil the requirements of the equality check by setting a
>     time stamp per default.
> 
> This patch fixes the problem with solution 3. A time stamp is set at
> time of allocation in alloc_can_skb.

That's a feasible way if won't find a better way to make sure the timestamps
are generally set before the skb is processed in the NET_RX softirq.

> The time stamp may be overridden later, but the function of the equality
> check is ensured.
> 
> I'm not really deep in linux network subsystem, so there may exists
> more elegant solutions for the problem.
> 
> Signed-off-by: Manfred Schlaegl <manfred.schlaegl@gmx.at>
> ---
>  drivers/net/can/dev.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index b0f6924..282e2e7 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
> @@ -575,6 +575,7 @@ struct sk_buff *alloc_can_skb(struct net_device *dev, struct can_frame **cf)
>  	if (unlikely(!skb))
>  		return NULL;
>  
> +	__net_timestamp(skb);
>  	skb->protocol = htons(ETH_P_CAN);
>  	skb->pkt_type = PACKET_BROADCAST;
>  	skb->ip_summed = CHECKSUM_UNNECESSARY;
> 

Please check the netdev_tstamp_prequeue value first.

If we would need solution 3 the __net_timestamp(skb) should be placed in
alloc_canfd_skb() too.

Thanks again for your investigation!

Best regards,
Oliver
