From: David Miller <davem@davemloft.net>
Subject: Re: question about drivers/net/ethernet/ti/cpsw.c
Date: Mon, 01 Sep 2014 18:11:01 -0700 (PDT)
Message-ID: <20140901.181101.2132157946809255487.davem@davemloft.net>
References: <alpine.DEB.2.02.1408282118560.2226@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: zonque@gmail.com, netdev@vger.kernel.org
To: julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752777AbaIBBLC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Sep 2014 21:11:02 -0400
In-Reply-To: <alpine.DEB.2.02.1408282118560.2226@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julia Lawall <julia.lawall@lip6.fr>
Date: Thu, 28 Aug 2014 21:26:55 +0200 (CEST)

> I wonder if the following patch:
> 
> commit aa1a15e2d9199711cdcc9399fdb22544ab835a83
> Author: Daniel Mack <zonque@gmail.com>
> Date:   Sat Sep 21 00:50:38 2013 +0530
> 
> introduced a race condition in drivers/net/ethernet/ti/cpsw.c.  I was 
> looking at an old version of the file (Linux 3.10), and it has
> 
>  clean_irq_ret:
>          for (i = 0; i < priv->num_irqs; i++)
>                  free_irq(priv->irqs_table[i], priv);
> 
> at the beginning of the cleanup code of the probe function (cpsw_probe).  
> The above patch replaces request_irq by devm_request_irq and gets rid of 
> the above cleanup code.  But that moves the stopping of the interrupts 
> after the following code at the end of the function:
> 
> free_netdev(priv->ndev);
> 
> The interrupt handler (cpsw_interrupt) does reference priv->ndev:
> 
> 	if (netif_running(priv->ndev)) {
>                 napi_schedule(&priv->napi);
>                 return IRQ_HANDLED;
>         }
> 
> so perhaps this could be a problem.  The same happens in the remove 
> function.

It could definitely be a problem.

Probably it would be better for this device to request IRQs in open
and release them in close like so many other networking drivers do.
