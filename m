From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [PATCH]: Third (final?) release of Sun Neptune driver
Date: Mon, 08 Oct 2007 18:01:20 +0200
Message-ID: <470A5450.70403@hartkopp.net>
References: <20071005.031209.57156822.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:25816 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751184AbXJHQBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 12:01:23 -0400
In-Reply-To: <20071005.031209.57156822.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> +
> +static int link_status_1g(struct niu *np, int *link_up_p)
> +{
> +	u16 current_speed, bmsr;
> +	unsigned long flags;
> +	u8 current_duplex;
> +	int err, link_up;
> +
> +	if (np->link_config.loopback_mode != LOOPBACK_DISABLED)
> +		return -EINVAL;
>   

Should *link_up_p be set to any value before returning?

> +
> +	link_up = 0;
> +	current_speed = SPEED_INVALID;
> +	current_duplex = DUPLEX_INVALID;
> +
> +	spin_lock_irqsave(&np->lock, flags);
> +
> +	err = mii_read(np, np->phy_addr, MII_BMSR);
> +	if (err < 0)
> +		goto out;
> +
> +	bmsr = err;
> +	if (bmsr & BMSR_LSTATUS) {
> +		u16 adv, lpa, common, estat;
> +
> +		err = mii_read(np, np->phy_addr, MII_ADVERTISE);
> +		if (err < 0)
> +			goto out;
> +		adv = err;
> +
> +		err = mii_read(np, np->phy_addr, MII_LPA);
> +		if (err < 0)
> +			goto out;
> +		lpa = err;
> +
> +		common = adv & lpa;
> +
> +		err = mii_read(np, np->phy_addr, MII_ESTATUS);
> +		if (err < 0)
> +			goto out;
> +		estat = err;
> +
> +		if (estat & (ESTATUS_1000_TFULL | ESTATUS_1000_THALF)) {
> +			current_speed = SPEED_1000;
> +			if (estat == ESTATUS_1000_TFULL)
> +				current_duplex = DUPLEX_FULL;
> +			else
> +				current_duplex = DUPLEX_HALF;
> +		} else {
> +			if (common & ADVERTISE_100BASE4) {
> +				current_speed = SPEED_100;
> +				current_duplex = DUPLEX_HALF;
> +			} else if (common & ADVERTISE_100FULL) {
> +				current_speed = SPEED_100;
> +				current_duplex = DUPLEX_FULL;
> +			} else if (common & ADVERTISE_100HALF) {
> +				current_speed = SPEED_100;
> +				current_duplex = DUPLEX_HALF;
> +			} else if (common & ADVERTISE_10FULL) {
> +				current_speed = SPEED_10;
> +				current_duplex = DUPLEX_FULL;
> +			} else if (common & ADVERTISE_10HALF) {
> +				current_speed = SPEED_10;
> +				current_duplex = DUPLEX_HALF;
> +			} else
> +				goto out;
> +		}
> +		link_up = 1;
> +	}
> +
> +out:
> +	spin_unlock_irqrestore(&np->lock, flags);
> +
> +	*link_up_p = link_up;
> +	return 0;
> +}
> +
>   
Although you added a proper return value in link_status_10g() while 
fixing the locking issue, you should think about providing a similar 
return value for link_status_1g() to be constistent here.

Oliver



