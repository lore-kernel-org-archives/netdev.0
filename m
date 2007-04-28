From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [RESEND] [PATCH v2] [1/5] pasemi_mac: minor bugfixes
Date: Sat, 28 Apr 2007 11:20:17 -0400
Message-ID: <46336631.9070501@pobox.com>
References: <20070428054952.GA22074@lixom.net> <20070428055023.GB22074@lixom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Olof Johansson <olof@lixom.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52045 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1031151AbXD1PUU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 11:20:20 -0400
In-Reply-To: <20070428055023.GB22074@lixom.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Olof Johansson wrote:
> Ethernet bugfixes:
> 
> * Move the was_full/wake_queue logic from tx_intr to clean_tx
> * Fix polarity in checks in pasemi_mac_close
> 
> 
> Signed-off-by: Olof Johansson <olof@lixom.net>
> 
> 
> Index: linux-2.6/drivers/net/pasemi_mac.c
> ===================================================================
> --- linux-2.6.orig/drivers/net/pasemi_mac.c
> +++ linux-2.6/drivers/net/pasemi_mac.c
> @@ -451,9 +451,12 @@ static int pasemi_mac_clean_tx(struct pa
>  	struct pas_dma_xct_descr *dp;
>  	int start, count;
>  	int flags;
> +	int was_full;
>  
>  	spin_lock_irqsave(&mac->tx->lock, flags);
>  
> +	was_full = mac->tx->next_to_clean - mac->tx->next_to_use == TX_RING_SIZE;
> +
>  	start = mac->tx->next_to_clean;
>  	count = 0;
>  
> @@ -478,6 +481,9 @@ static int pasemi_mac_clean_tx(struct pa
>  	mac->tx->next_to_clean += count;
>  	spin_unlock_irqrestore(&mac->tx->lock, flags);
>  
> +	if (was_full)
> +		netif_wake_queue(mac->netdev);
> +

Isn't this was_full check redundant?  Using standard test-and-clear 
atomic logic, netif_wake_queue() will not issue spurious wakeups.  Take 
a look at its implementation in include/linux/netdevice.h.

	Jeff



