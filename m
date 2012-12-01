From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [RFT PATCH] 8139cp: properly support change of MTU values
Date: Sat, 1 Dec 2012 22:49:02 +0100
Message-ID: <20121201214902.GA10513@electric-eye.fr.zoreil.com>
References: <1354308680-9236-1-git-send-email-jogreene@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: John Greene <jogreene@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:36521 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab2LAWNu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Dec 2012 17:13:50 -0500
Content-Disposition: inline
In-Reply-To: <1354308680-9236-1-git-send-email-jogreene@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

John Greene <jogreene@redhat.com> :
[...]
> Testing: has been test on virtual 8139cp setup without issue,
> have no access real hardware 8139cp, need testing help.

You should Cc: David Woodhouse <dwmw2@infradead.org> for testing.

[...]
> diff --git a/drivers/net/ethernet/realtek/8139cp.c b/drivers/net/ethernet/realtek/8139cp.c
> index 6cb96b4..7847c83 100644
> --- a/drivers/net/ethernet/realtek/8139cp.c
> +++ b/drivers/net/ethernet/realtek/8139cp.c
[...]
> @@ -1244,22 +1241,11 @@ static int cp_change_mtu(struct net_device *dev, int new_mtu)
>  		return 0;
>  	}
>  
> -	spin_lock_irqsave(&cp->lock, flags);
> -
> -	cp_stop_hw(cp);			/* stop h/w and free rings */
> -	cp_clean_rings(cp);
> -
> +	/* network IS up, close it, reset MTU, and come up again. */
> +	cp_close(dev);
>  	dev->mtu = new_mtu;
> -	cp_set_rxbufsize(cp);		/* set new rx buf size */
> -
> -	rc = cp_init_rings(cp);		/* realloc and restart h/w */
> -	cp_start_hw(cp);
> -
> -	spin_unlock_irqrestore(&cp->lock, flags);
> -
> -	return rc;
> +	return cp_open(dev);

netif_running is true since cp_close() is not running from dev_close.
Bad things will happen if cp_open fails while cp_interrupt was waiting
for the lock.

-- 
Ueimor
