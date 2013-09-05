From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethernet/arc/arc_emac: optimize the Tx/Tx-reclaim
 paths a bit
Date: Thu, 05 Sep 2013 14:24:36 -0400 (EDT)
Message-ID: <20130905.142436.685399325201245026.davem@davemloft.net>
References: <1378299791-24598-1-git-send-email-vgupta@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Alexey.Brodkin@synopsys.com,
	romieu@fr.zoreil.com, linux-kernel@vger.kernel.org,
	arc-linux-dev@synopsys.com
To: Vineet.Gupta1@synopsys.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378299791-24598-1-git-send-email-vgupta@synopsys.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vineet Gupta <Vineet.Gupta1@synopsys.com>
Date: Wed, 4 Sep 2013 18:33:11 +0530

> This came out of staring at code due to recent performance fix.
> 
> * TX BD reclaim can call netif_wake_queue() once, outside the loop if
>   one/more BDs were freed, NO need to do this each iteration.
> 
> * TX need not look at next BD to stop the netif queue. It rather be done
>   in the next tx call, when it actually fails as the queue seldom gets
>   full but the check nevertheless needs to be done for each packet Tx.
>   Profiled this under heavy traffic (big tar file cp, LMBench betworking
>   tests) and saw not a single hit to that code.
> 
> Signed-off-by: Vineet Gupta <vgupta@synopsys.com>

You should keep the check in the transmit queueing code as a BUG check,
almost every driver has code of the form (using NIU as an example):

	if (niu_tx_avail(rp) <= (skb_shinfo(skb)->nr_frags + 1)) {
		netif_tx_stop_queue(txq);
		dev_err(np->device, "%s: BUG! Tx ring full when queue awake!\n", dev->name);
		rp->tx_errors++;
		return NETDEV_TX_BUSY;
	}

and arc_emac should too.

Otherwise queue management bugs are incredibly hard to diagnose.

I'm not applying this patch.
