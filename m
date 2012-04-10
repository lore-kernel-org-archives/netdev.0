From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: re: Ethernet driver for the WIZnet W5100 chip
Date: Tue, 10 Apr 2012 11:40:06 +0300
Message-ID: <20120410084006.GA27006@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: msink@permonline.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet15.oracle.com ([141.146.126.227]:41522 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752253Ab2DJIkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2012 04:40:17 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Mike Sinkovsky,

This is a semi-automatic email about new static checker warnings.

The patch 8b1467a31343: "Ethernet driver for the WIZnet W5100 chip" 
from Apr 4, 2012, leads to the following Smatch complaint:

drivers/net/ethernet/wiznet/w5100.c:685 w5100_hw_probe()
	 error: we previously assumed 'data' could be null (see line 637)

drivers/net/ethernet/wiznet/w5100.c
   636	
   637		if (data && is_valid_ether_addr(data->mac_addr)) {
                    ^^^^
New check.

   638			memcpy(ndev->dev_addr, data->mac_addr, ETH_ALEN);
   639		} else {
   640			random_ether_addr(ndev->dev_addr);
   641			ndev->addr_assign_type |= NET_ADDR_RANDOM;
   642		}
   643	
   644		mem = platform_get_resource(pdev, IORESOURCE_MEM, 0);
   645		if (!mem)
   646			return -ENXIO;
   647		mem_size = resource_size(mem);
   648		if (!devm_request_mem_region(&pdev->dev, mem->start, mem_size, name))
   649			return -EBUSY;
   650		priv->base = devm_ioremap(&pdev->dev, mem->start, mem_size);
   651		if (!priv->base)
   652			return -EBUSY;
   653	
   654		spin_lock_init(&priv->reg_lock);
   655		priv->indirect = mem_size < W5100_BUS_DIRECT_SIZE;
   656		if (priv->indirect) {
   657			priv->read     = w5100_read_indirect;
   658			priv->write    = w5100_write_indirect;
   659			priv->read16   = w5100_read16_indirect;
   660			priv->write16  = w5100_write16_indirect;
   661			priv->readbuf  = w5100_readbuf_indirect;
   662			priv->writebuf = w5100_writebuf_indirect;
   663		} else {
   664			priv->read     = w5100_read_direct;
   665			priv->write    = w5100_write_direct;
   666			priv->read16   = w5100_read16_direct;
   667			priv->write16  = w5100_write16_direct;
   668			priv->readbuf  = w5100_readbuf_direct;
   669			priv->writebuf = w5100_writebuf_direct;
   670		}
   671	
   672		w5100_hw_reset(priv);
   673		if (w5100_read16(priv, W5100_RTR) != RTR_DEFAULT)
   674			return -ENODEV;
   675	
   676		irq = platform_get_irq(pdev, 0);
   677		if (irq < 0)
   678			return irq;
   679		ret = request_irq(irq, w5100_interrupt,
   680				  IRQ_TYPE_LEVEL_LOW, name, ndev);
   681		if (ret < 0)
   682			return ret;
   683		priv->irq = irq;
   684	
   685		priv->link_gpio = data->link_gpio;
                                  ^^^^^^^^^^^^^^^
New unchecked dereference.

   686		if (gpio_is_valid(priv->link_gpio)) {
   687			char *link_name = devm_kzalloc(&pdev->dev, 16, GFP_KERNEL);

regards,
dan carpenter
