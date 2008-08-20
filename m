From: David Miller <davem@davemloft.net>
Subject: Re: [RFC][PATCH] netconsole: avoid deadlock on printk from driver
 code
Date: Wed, 20 Aug 2008 13:58:32 -0700 (PDT)
Message-ID: <20080820.135832.93663823.davem@davemloft.net>
References: <Pine.LNX.4.64.0808141643200.3164@sbz-30.cs.Helsinki.FI>
	<20080814.151502.251134900.davem@davemloft.net>
	<Pine.LNX.4.64.0808202051550.3501@melkki.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vegard.nossum@gmail.com, vegardno@ifi.uio.no,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jgarzik@pobox.com, adobriyan@gmail.com
To: penberg@cs.helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41134
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751442AbYHTU6d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2008 16:58:33 -0400
In-Reply-To: <Pine.LNX.4.64.0808202051550.3501@melkki.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pekka J Enberg <penberg@cs.helsinki.fi>
Date: Wed, 20 Aug 2008 20:54:01 +0300 (EEST)

> @@ -1721,7 +1723,8 @@ static int rtl8139_start_xmit (struct sk
>  		return 0;
>  	}
>  
> -	spin_lock_irqsave(&tp->lock, flags);
> +	local_irq_save(flags);
> +	netif_tx_lock(dev);
>  	RTL_W32_F (TxStatus0 + (entry * sizeof (u32)),
>  		   tp->tx_flag | max(len, (unsigned int)ETH_ZLEN));

The generic networking takes the TX lock for you, you don't
need to take it explicitly here.

You also cannot depend upon IRQ disabled locking, the generic
TX lock is only softirq safe, not hard IRQ safe.

This means you have to move TX descriptor reclaim into a
soft IRQ context, such as NAPI ->poll().
