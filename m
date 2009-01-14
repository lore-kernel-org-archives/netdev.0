From: David Miller <davem@davemloft.net>
Subject: Re: [i4l] stop address leakage when shutting down an i4l ppp
 interface
Date: Wed, 14 Jan 2009 14:50:35 -0800 (PST)
Message-ID: <20090114.145035.194024897.davem@davemloft.net>
References: <1231764889.7132.23.camel@test.thuisdomein>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58200
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753830AbZANWue (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 17:50:34 -0500
In-Reply-To: <1231764889.7132.23.camel@test.thuisdomein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Bolle <pebolle@tiscali.nl>
Date: Mon, 12 Jan 2009 13:54:49 +0100

> @@ -1336,6 +1336,13 @@ isdn_net_close(struct net_device *dev)
>  	}
>  	isdn_net_hangup(dev);
>  	isdn_unlock_drivers();
> +#ifdef CONFIG_ISDN_PPP
> +	/* make sure arp_mc_map() handles this device properly */
> +	if (dev->type == ARPHRD_PPP) {
> +		dev->type = ARPHRD_ETHER;
> +		dev->addr_len = ETH_ALEN;
> +	}
> +#endif
>  	return 0;
>  }

Just like the CONFIG_ISDN_PPP case, this code also changes the
p->dev->type and clears p->dev->addr_len for CONFIG_ISDN_X25

So at a minimum you'd need to add a case for that here as well.

I think it's pretty much illegal to change the device type after the
device has been registered.  Probably a lot of surgery is needed
here to correct this.

Althought what might work is to unregister then re-register the
device when the device type needs to be changed.  That should
work as long as it doesn't cause other undesirable side effects.

