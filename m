From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] ixp4xx_eth: set the device dma_coherent_mask
Date: Tue, 19 Mar 2013 23:35:46 +0100
Message-ID: <m3sj3rdnlp.fsf@intrepid.localdomain>
References: <1363708765-20778-1-git-send-email-c.aeschlimann@acn-group.ch>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Christophe Aeschlimann <c.aeschlimann@acn-group.ch>
To: Christophe Aeschlimann <aeschlimann@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1363708765-20778-1-git-send-email-c.aeschlimann@acn-group.ch>
	(Christophe Aeschlimann's message of "Tue, 19 Mar 2013 16:59:25
	+0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Christophe Aeschlimann <aeschlimann@gmail.com> writes:

> Without the mask it is impossible to take the network interface up
> since it returns the following error:
>
>> net eth1: coherent DMA mask is unset
>> ifconfig: SIOCSIFFLAGS: Cannot allocate memory
>
> +++ b/drivers/net/ethernet/xscale/ixp4xx_eth.c
> @@ -1398,6 +1398,7 @@ static int eth_init_one(struct platform_device *pdev)
>  		return -ENOMEM;
>  
>  	SET_NETDEV_DEV(dev, &pdev->dev);
> +	dev->dev.coherent_dma_mask = DMA_BIT_MASK(32);
>  	port = netdev_priv(dev);
>  	port->netdev = dev;
>  	port->id = pdev->id;

This happens to work but seems to me like a bad "solution". The real
issue is that current ARM coherent_dma_mask (and regular dma_mask)
handling is just broken (at least on platforms with
CONFIG_ARCH_HAS_DMA_SET_COHERENT_MASK). I'm thinking how can it be
fixed.

The problematic parts include the dmabouncer (which takes over DMA
operations and provide services similar to swiotlb), the host DMA and
coherent DMA masks (which are property of the buses) and the device
masks, which should be ANDed with bus masks (but aren't).

What the driver should use is:
	err = dma_set_coherent_mask(xxx);

(but the subsystem have to be fixed first).
Also, according to DMA-API, 32-bit is the default.
-- 
Krzysztof Halasa
