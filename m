From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC 2/8] net-next: phy: dont auto handle carrier state when
 multiple phys are attached
Date: Tue, 24 Nov 2015 10:42:24 -0800
Message-ID: <5654AF90.9060500@gmail.com>
References: <1448181658-38111-1-git-send-email-blogic@openwrt.org> <1448181658-38111-2-git-send-email-blogic@openwrt.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Michael Lee <igvtee@gmail.com>,
	Felix Fietkau <nbd@openwrt.org>,
	=?UTF-8?B?IlN0ZXZlbiBMaXUgKOWKieS6uuixqiki?=
	<steven.liu@mediatek.com>,
	=?UTF-8?B?IkZyZWQgQ2hhbmcgKOW8teWYieWujyki?=
	<Fred.Chang@mediatek.com>, Andrew Lunn <andrew@lunn.ch>,
	jogo@openwrt.org
To: John Crispin <blogic@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:34570 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752375AbbKXSn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Nov 2015 13:43:29 -0500
Received: by padhx2 with SMTP id hx2so30139095pad.1
        for <netdev@vger.kernel.org>; Tue, 24 Nov 2015 10:43:29 -0800 (PST)
In-Reply-To: <1448181658-38111-2-git-send-email-blogic@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 22/11/15 00:40, John Crispin wrote:
> A network core might have more than one phy attached to its cpu port via a
> switch. The current code will set the carrier state to on/off when ever a
> cable is plugged into any of these ports.

Not really, no. The current PHY library implementation does not allow
more than one net_device instance to be bound to multiple PHY devices.
Since this is an integrated switch, you should really expose per-port
network devices, that is the paradigm we settled down on using for
Ethernet switches now (irrespective of using DSA or switchdev, or both).

> 
> The patch adds a new bool that allows the driver to tell the phy_device to not
> set the carrier state. Instead the driver can manually handle the carrier
> state.

I am missing the bigger picture of how this is used, also, if link down
is a problem, would not link up be for the same reasons?

> 
> Signed-off-by: John Crispin <blogic@openwrt.org>
> Signed-off-by: Felix Fietkau <nbd@openwrt.org>
> Signed-off-by: Michael Lee <igvtee@gmail.com>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/phy.c |    9 ++++++---
>  include/linux/phy.h   |    1 +
>  2 files changed, 7 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 48ce6ef..bd2df40 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -843,7 +843,8 @@ void phy_state_machine(struct work_struct *work)
>  		/* If the link is down, give up on negotiation for now */
>  		if (!phydev->link) {
>  			phydev->state = PHY_NOLINK;
> -			netif_carrier_off(phydev->attached_dev);
> +			if (!phydev->no_auto_carrier_off)
> +				netif_carrier_off(phydev->attached_dev);
>  			phydev->adjust_link(phydev->attached_dev);
>  			break;
>  		}
> @@ -926,7 +927,8 @@ void phy_state_machine(struct work_struct *work)
>  			netif_carrier_on(phydev->attached_dev);
>  		} else {
>  			phydev->state = PHY_NOLINK;
> -			netif_carrier_off(phydev->attached_dev);
> +			if (!phydev->no_auto_carrier_off)
> +				netif_carrier_off(phydev->attached_dev);
>  		}
>  
>  		phydev->adjust_link(phydev->attached_dev);
> @@ -938,7 +940,8 @@ void phy_state_machine(struct work_struct *work)
>  	case PHY_HALTED:
>  		if (phydev->link) {
>  			phydev->link = 0;
> -			netif_carrier_off(phydev->attached_dev);
> +			if (!phydev->no_auto_carrier_off)
> +				netif_carrier_off(phydev->attached_dev);
>  			phydev->adjust_link(phydev->attached_dev);
>  			do_suspend = true;
>  		}
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 05fde31..276ab8a 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -377,6 +377,7 @@ struct phy_device {
>  	bool is_pseudo_fixed_link;
>  	bool has_fixups;
>  	bool suspended;
> +	bool no_auto_carrier_off;
>  
>  	enum phy_state state;
>  
> 


-- 
Florian
