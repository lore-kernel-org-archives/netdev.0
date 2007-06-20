From: David Gundersen <gundy@iinet.net.au>
Subject: Re: r8169 tx problem (1s pause with ping)
Date: Wed, 20 Jun 2007 18:57:43 +1000
Message-ID: <4678EC07.8050700@iinet.net.au>
References: <20070613004154.GA4187@kvack.org> <20070613211859.GA22521@electric-eye.fr.zoreil.com> <46715FBA.3070302@iinet.net.au> <20070614220050.GB23266@electric-eye.fr.zoreil.com> <20070619230641.GD14681@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Benjamin LaHaise <bcrl@kvack.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.icp-qv1-irony3.iinet.net.au ([203.59.1.108]:19437 "EHLO
	webmail.icp-qv1-irony3.iinet.net.au" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755726AbXFTI5O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Jun 2007 04:57:14 -0400
In-Reply-To: <20070619230641.GD14681@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 8f3e0da..8c0851f 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -2682,6 +2688,8 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
>  		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
>  			netif_wake_queue(dev);
>  		}
> +		if (tp->dirty_tx != tp->cur_rx)
> +			RTL_W8(TxPoll, NPQ);
>  	}
>  }
>  

Hi Francois,

A few things:

- Why are you checking dirty_tx against cur_rx (shouldn't it be cur_tx?)?

- Is there a possibility that the driver could be triggering the card to 
send invalid packets with that code?

I'm thinking in _start_xmit, the cur_tx pointer (assuming that's what 
you meant to include above) gets incremented when the packet is sent to 
the card (the RTL_W8(TxPoll,NPQ)) to indicate that the card _should_ be 
able to process packets up to that point in the queue.

The interrupt routine comes along later to clean up the buffers between 
dirty_tx (the last packet that the driver knows the card has sent) and 
cur_tx (the point that the card could potentially be up to).   What 
seems could happen with the code above is that the card gets told that a 
packet is ready to be sent when really it's not.  I'm not sure how it 
would deal with such a situation.

Regards,
Dave.
