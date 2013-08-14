From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: r8169 OOPSen in rtl_rx
Date: Wed, 14 Aug 2013 11:52:33 +0200
Message-ID: <20130814095233.GH24092@twins.programming.kicks-ass.net>
References: <20130813094314.GW3008@twins.programming.kicks-ass.net>
 <20130813211534.GA5635@electric-eye.fr.zoreil.com>
 <20130814092915.GF24092@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:49615 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759621Ab3HNJwl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 05:52:41 -0400
Content-Disposition: inline
In-Reply-To: <20130814092915.GF24092@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 14, 2013 at 11:29:15AM +0200, Peter Zijlstra wrote:
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 393f961..76d1c18 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -6185,6 +6185,8 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
>  			else
>  				pkt_size = status & 0x00003fff;
>  
> +			WARN_ON(!(pkt_size > 0 && pkt_size <= ETH_FRAME_LEN));
> +
>  			/*
>  			 * The driver does not support incoming fragmented
>  			 * frames. They are seen as a symptom of over-mtu

OK, I changed that to:

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index 393f961..81e0bf4 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6185,6 +6185,12 @@ static int rtl_rx(struct net_device *dev, struct rtl8169_private *tp, u32 budget
 			else
 				pkt_size = status & 0x00003fff;
 
+			if (!(pkt_size > 0 && pkt_size <= ETH_FRAME_LEN)) {
+				dev->stats.rx_dropped++;
+				printk("%s Funny sized packet: %d\n", dev->name, pkt_size);
+				goto release_descriptor;
+			}
+
 			/*
 			 * The driver does not support incoming fragmented
 			 * frames. They are seen as a symptom of over-mtu
