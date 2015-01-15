From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [bisected regression] e1000e: "Detected Hardware Unit Hang"
Date: Thu, 15 Jan 2015 06:43:29 -0800
Message-ID: <1421333009.11734.53.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1719052.SGOfRAJhfQ@storm>
	 <1421256052.11734.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5229621.KczjbIR22Q@storm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: 'Linux Netdev List' <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	e1000-devel <e1000-devel@lists.sourceforge.net>
To: Thomas Jarosch <thomas.jarosch@intra2net.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f172.google.com ([209.85.223.172]:50116 "EHLO
	mail-ie0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753885AbbAOOnb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Jan 2015 09:43:31 -0500
Received: by mail-ie0-f172.google.com with SMTP id tr6so15114805ieb.3
        for <netdev@vger.kernel.org>; Thu, 15 Jan 2015 06:43:30 -0800 (PST)
In-Reply-To: <5229621.KczjbIR22Q@storm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-01-15 at 11:11 +0100, Thomas Jarosch wrote:
> On Wednesday, 14. January 2015 09:20:52 Eric Dumazet wrote:
> > I would try to use lower data per txd. I am not sure 24KB is really
> > supported.
> > 
> > ( check commit d821a4c4d11ad160925dab2bb009b8444beff484 for details)
> > 
> > diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> > b/drivers/net/ethernet/intel/e1000e/netdev.c index
> > e14fd85f64eb..8d973f7edfbd 100644
> > --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> > +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> > @@ -3897,7 +3897,7 @@ void e1000e_reset(struct e1000_adapter *adapter)
> >  	 * limit of 24KB due to receive synchronization limitations.
> >  	 */
> >  	adapter->tx_fifo_limit = min_t(u32, ((er32(PBA) >> 16) << 10) - 96,
> > -				       24 << 10);
> > +				       8 << 10);
> > 
> >  	/* Disable Adaptive Interrupt Moderation if 2 full packets cannot
> >  	 * fit in receive buffer.
> 
> Thanks for checking!
> 
> I just tried that change on top of git f800c25 (git HEAD), same problem. 
> Let's see what the Intel wizards come up with.
> 
> What "works" is to decrease the page size in git HEAD, too:
> 
> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> index 85ab7d7..9f0ef97 100644
> --- a/include/linux/skbuff.h
> +++ b/include/linux/skbuff.h
> @@ -2108,7 +2108,7 @@ static inline void __skb_queue_purge(struct 
> sk_buff_head *list)
>                 kfree_skb(skb);
>  }
>  
> -#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(32768)
> +#define NETDEV_FRAG_PAGE_MAX_ORDER get_order(4096)
>  #define NETDEV_FRAG_PAGE_MAX_SIZE  (PAGE_SIZE << NETDEV_FRAG_PAGE_MAX_ORDER)
>  #define NETDEV_PAGECNT_MAX_BIAS           NETDEV_FRAG_PAGE_MAX_SIZE
> 
> 
> 
> When I try a page size of 8192, it starts failing again. I'll now run
> a stress test with 4096 to see if the problem is really gone
> or just happens more rarely.

Sure, you basically reverted my patch.

You are not the first to report a problem caused by this patch.

This patch is known to have uncovered some driver bugs.

We are not going to revert it. We are going to fix the real bugs.

Thanks
