From: <Bryan.Whitehead@microchip.com>
Subject: RE: [PATCH net-next,V2] Add LAN9352 Ethernet Driver
Date: Fri, 12 Feb 2016 19:10:52 +0000
Message-ID: <90A7E81AE28BAE4CBDDB3B35F187D264402EF62A@CHN-SV-EXMX02.mchp-main.com>
References: <90A7E81AE28BAE4CBDDB3B35F187D264402EF4A2@CHN-SV-EXMX02.mchp-main.com>
 <56BD23E0.1090403@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: <LinoSanfilippo@gmx.de>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exsmtp01.microchip.com ([198.175.253.37]:62679 "EHLO
	email.microchip.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750853AbcBLTKy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Feb 2016 14:10:54 -0500
In-Reply-To: <56BD23E0.1090403@gmx.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lino,

Regarding "a matching smp_rmb() in the irq handler"
There is a smp_wmb() in the irq handler, since in both cases we are forcing a write operation on software_irq_signal.

I suppose using atomic operations on software_irq_signal would also work, but this driver was based on 
drivers/net/ethernet/smsc/smsc911x.c
And if possible I'd prefer to keep logical changes to a minimum.
Plus this is not a "read modify write" scenario so I think the memory barrier is sufficient.
Do you agree?

Regarding register_netdev.
I'll move register_netdev till after the mac address is set.

Thanks,
Bryan

-----Original Message-----
From: Lino Sanfilippo [mailto:LinoSanfilippo@gmx.de] 
Sent: Thursday, February 11, 2016 7:14 PM
To: Bryan Whitehead - C21958; davem@davemloft.net
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH net-next,V2] Add LAN9352 Ethernet Driver

Hi,

> +static int mchp9352_open(struct net_device *dev) {

> +
> +	MCHP_TRACE(pdata, ifup, "Testing irq handler using IRQ %d", dev->irq);
> +	pdata->software_irq_signal = 0;
> +
> +	/* Testing irq handler */
> +	smp_wmb();

Should not there at least be a matching smp_rmb() in the irq handler?
Maybe an atomic_t would be a better choice for a flag like software_irq_signal here.

> +
> +static int mchp9352_drv_probe(struct platform_device *pdev)

> +
> +	netif_carrier_off(dev);
> +
> +	retval = register_netdev(dev);
> +	if (retval) {
> +		MCHP_WARN(pdata, probe, "Error %i registering device", retval);
> +		goto out_free_irq;
> +	} else {
> +		MCHP_TRACE(pdata, probe,
> +			   "Network interface: \"%s\"", dev->name);
> +	}

Note that as soon as the network device is registered "open" may be called so everything should be set up already. In this case the mac address (dev->dev_addr) is accessed in open but may not yet contain valid data when register_netdev is called.

Regards,
Lino
