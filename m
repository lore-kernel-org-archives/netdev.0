From: Thomas Jarosch <thomas.jarosch@intra2net.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Thu, 15 Jan 2015 11:11:09 +0100
Message-ID: <5229621.KczjbIR22Q@storm>
References: <1719052.SGOfRAJhfQ@storm> <1421256052.11734.22.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rs04.intra2net.com ([85.214.66.2]:59901 "EHLO
	rs04.intra2net.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbbAOKLO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 05:11:14 -0500
In-Reply-To: <1421256052.11734.22.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday, 14. January 2015 09:20:52 Eric Dumazet wrote:
> I would try to use lower data per txd. I am not sure 24KB is really
> supported.
> 
> ( check commit d821a4c4d11ad160925dab2bb009b8444beff484 for details)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> b/drivers/net/ethernet/intel/e1000e/netdev.c index
> e14fd85f64eb..8d973f7edfbd 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -3897,7 +3897,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
>  	 * limit of 24KB due to receive synchronization limitations.
>  	 */
>  	adapter->tx_fifo_limit = min_t(u32, ((er32(PBA) >> 16) << 10) - 96,
> -				       24 << 10);
> +				       8 << 10);
> 
>  	/* Disable Adaptive Interrupt Moderation if 2 full packets cannot
>  	 * fit in receive buffer.

Thanks for checking!

I just tried that change on top of git f800c25 (git HEAD), same problem. 
Let's see what the Intel wizards come up with.

What "works" is to decrease the page size in git HEAD, too:

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 85ab7d7..9f0ef97 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -2108,7 +2108,7 @@ static inline void __skb_queue_purge(struct 
sk_buff_head *list)
                kfree_skb(skb);
 }
 
-#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
+#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(4096)
 #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
 #define NETDEV_PAGECNT_MAX_BIAS           NETDEV_FRAG_PAGE_MAX_SIZE



When I try a page size of 8192, it starts failing again. I'll now run
a stress test with 4096 to see if the problem is really gone
or just happens more rarely.

Cheers,
Thomas
