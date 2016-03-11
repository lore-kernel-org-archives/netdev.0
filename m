From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 5/5] phy: fixed: Fix removal of phys.
Date: Fri, 11 Mar 2016 15:18:40 -0800
Message-ID: <56E35250.6020101@gmail.com>
References: <1457737300-23660-1-git-send-email-andrew@lunn.ch>
 <1457737300-23660-6-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:32967 "EHLO
	mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750744AbcCKXUO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 18:20:14 -0500
Received: by mail-pf0-f172.google.com with SMTP id 124so93945295pfg.0
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 15:20:14 -0800 (PST)
In-Reply-To: <1457737300-23660-6-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/03/16 15:01, Andrew Lunn wrote:
> The fixed phys delete function simply removed the fixed phy from the
> internal linked list and freed the memory. It however did not
> unregister the associated phy device. This meant it was still possible
> to find the phy device on the mdio bus.
> 
> Make fixed_phy_del() an internal function and add a
> fixed_phy_unregister() to unregisters the phy device and then uses
> fixed_phy_del() to free resources.
> 
> Modify DSA to use this new API function, so we don't leak phys.
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> ---
>  drivers/net/phy/fixed_phy.c | 11 +++++++++--
>  include/linux/phy_fixed.h   |  5 ++---
>  net/dsa/dsa.c               |  4 +---
>  3 files changed, 12 insertions(+), 8 deletions(-)
> 
> diff --git a/drivers/net/phy/fixed_phy.c b/drivers/net/phy/fixed_phy.c
> index ab9c473d75ea..fc07a8866020 100644
> --- a/drivers/net/phy/fixed_phy.c
> +++ b/drivers/net/phy/fixed_phy.c
> @@ -285,7 +285,7 @@ err_regs:
>  }
>  EXPORT_SYMBOL_GPL(fixed_phy_add);
>  
> -void fixed_phy_del(int phy_addr)
> +static void fixed_phy_del(int phy_addr)
>  {
>  	struct fixed_mdio_bus *fmb = &platform_fmb;
>  	struct fixed_phy *fp, *tmp;
> @@ -300,7 +300,6 @@ void fixed_phy_del(int phy_addr)
>  		}
>  	}
>  }
> -EXPORT_SYMBOL_GPL(fixed_phy_del);
>  
>  static int phy_fixed_addr;
>  static DEFINE_SPINLOCK(phy_fixed_addr_lock);
> @@ -371,6 +370,14 @@ struct phy_device *fixed_phy_register(unsigned int irq,
>  }
>  EXPORT_SYMBOL_GPL(fixed_phy_register);
>  
> +void fixed_phy_unregister(struct phy_device *phy)
> +{
> +	phy_device_remove(phy);
> +
> +	fixed_phy_del(phy->mdio.addr);

fixed_phy_del() should also make sure that there is no dangling
link_update callback registered, even though this is not fatal, as it
checks whether the phydev is NULL, we should automatically unregister
one by doing something like: fixed_phy_set_link_update(phydev, NULL) for
robustness.

LGTM to me otherwise, thanks!
-- 
Florian
