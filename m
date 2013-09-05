From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: r8169 OOPSen in rtl_rx
Date: Thu, 5 Sep 2013 17:20:26 +0200
Message-ID: <20130905152026.GB31370@twins.programming.kicks-ass.net>
References: <20130813094314.GW3008@twins.programming.kicks-ass.net>
 <20130813211534.GA5635@electric-eye.fr.zoreil.com>
 <20130814092915.GF24092@twins.programming.kicks-ass.net>
 <20130814095233.GH24092@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:54766 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753931Ab3IEPUc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 11:20:32 -0400
Content-Disposition: inline
In-Reply-To: <20130814095233.GH24092@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 11:52:33AM +0200, Peter Zijlstra wrote:
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 393f961..81e0bf4 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -6185,6 +6185,12 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
>  			else
>  				pkt_size = status & 0x00003fff;
>  
> +			if (!(pkt_size > 0 && pkt_size <= ETH_FRAME_LEN)) {
> +				dev->stats.rx_dropped++;
> +				printk("%s Funny sized packet: %d\n", dev->name, pkt_size);
> +				goto release_descriptor;
> +			}
> +
>  			/*
>  			 * The driver does not support incoming fragmented
>  			 * frames. They are seen as a symptom of over-mtu

Yay, it triggered..

$ dmesg | awk '/Funny sized packet/ { t[$6]++ } END { for (i in t) {
printf "%d %d\n", t[i], i; } }' | sort -n
1 4237
1 4983
1 5811
1 6062
1 6594
2 10709
2 12073
2 9197
4 14624
4 14870
266 16364

dev->name is always the same and the internal NIC (eth0, RTL8110s).

When it happens the NIC stops working as every packet is mal-sized,
however an ifconfig down; ifconfig up will restore it to working order.

It appears to happen when I saturate my outside link such that all
packets are fwd to the internal network -- I've got a 30Mbit/s down link
which isn't all that much given its a GBE capable card.

When I try and saturate the internal nic, with traffic from the firewall
to an internal machine we reach GBE speeds but nothing falls over.
