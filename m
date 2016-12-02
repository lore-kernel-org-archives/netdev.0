From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH] net:phy fix driver reference count error when attach
 and detach phy device
Date: Fri, 2 Dec 2016 09:45:48 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DB0232613@AcuExch.aculab.com>
References: <1480501378-10172-1-git-send-email-maowenan@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
To: 'Mao Wenan' <maowenan@huawei.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "dingtianhong@huawei.com" <dingtianhong@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.184]:63790 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750917AbcLBJqO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Dec 2016 04:46:14 -0500
In-Reply-To: <1480501378-10172-1-git-send-email-maowenan@huawei.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mao Wenan
> Sent: 30 November 2016 10:23
> The nic in my board use the phy dev from marvell, and the system will
> load the marvell phy driver automatically, but when I remove the phy
> drivers, the system immediately panic:
> Call trace:
> [ 2582.834493] [<ffff800000715384>] phy_state_machine+0x3c/0x438 [
> 2582.851754] [<ffff8000000db3b8>] process_one_work+0x150/0x428 [
> 2582.868188] [<ffff8000000db7d4>] worker_thread+0x144/0x4b0 [
> 2582.883882] [<ffff8000000e1d0c>] kthread+0xfc/0x110
> 
> there should be proper reference counting in place to avoid that.
> I found that phy_attach_direct() forgets to add phy device driver
> reference count, and phy_detach() forgets to subtract reference count.
> This patch is to fix this bug, after that panic is disappeared when remove
> marvell.ko
> 
> Signed-off-by: Mao Wenan <maowenan@huawei.com>
> ---
>  drivers/net/phy/phy_device.c | 7 +++++++
>  1 file changed, 7 insertions(+)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 1a4bf8a..a7ec7c2 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -866,6 +866,11 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
>  		return -EIO;
>  	}
> 
> +	if (!try_module_get(d->driver->owner)) {
> +		dev_err(&dev->dev, "failed to get the device driver module\n");
> +		return -EIO;
> +	}

If this is the phy code, what stops the phy driver being unloaded
before the try_module_get() obtains a reference.
If it isn't the phy driver then there ought to be a reference count obtained
when the phy driver is located (by whatever decides which phy driver to use).
Even if that code later releases its reference (it probably shouldn't on success)
then you can't fail to get an extra reference here.

> +
>  	get_device(d);
> 
>  	/* Assume that if there is no driver, that it doesn't
> @@ -921,6 +926,7 @@ int phy_attach_direct(struct net_device *dev, struct phy_device *phydev,
> 
>  error:
>  	put_device(d);
> +	module_put(d->driver->owner);

Are those two in the wrong order ?

>  	module_put(bus->owner);
>  	return err;
>  }
> @@ -998,6 +1004,7 @@ void phy_detach(struct phy_device *phydev)
>  	bus = phydev->mdio.bus;
> 
>  	put_device(&phydev->mdio.dev);
> +	module_put(phydev->mdio.dev.driver->owner);
>  	module_put(bus->owner);

Where is this code called from?
You can't call it from the phy driver because the driver can be unloaded
as soon as the last reference is removed.
At that point the code memory is freed.

>  }
>  EXPORT_SYMBOL(phy_detach);
> --
> 2.7.0
> 
