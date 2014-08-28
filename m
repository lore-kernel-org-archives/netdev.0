From: Julia Lawall <julia.lawall@lip6.fr>
Subject: question about drivers/net/ethernet/ti/cpsw.c
Date: Thu, 28 Aug 2014 21:26:55 +0200 (CEST)
Message-ID: <alpine.DEB.2.02.1408282118560.2226@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Daniel Mack <zonque@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:29650
	"EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751302AbaH1T06 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Aug 2014 15:26:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I wonder if the following patch:

commit aa1a15e2d9199711cdcc9399fdb22544ab835a83
Author: Daniel Mack <zonque@gmail.com>
Date:   Sat Sep 21 00:50:38 2013 +0530

introduced a race condition in drivers/net/ethernet/ti/cpsw.c.  I was 
looking at an old version of the file (Linux 3.10), and it has

 clean_irq_ret:
         for (i = 0; i < priv->num_irqs; i++)
                 free_irq(priv->irqs_table[i], priv);

at the beginning of the cleanup code of the probe function (cpsw_probe).  
The above patch replaces request_irq by devm_request_irq and gets rid of 
the above cleanup code.  But that moves the stopping of the interrupts 
after the following code at the end of the function:

free_netdev(priv->ndev);

The interrupt handler (cpsw_interrupt) does reference priv->ndev:

	if (netif_running(priv->ndev)) {
                napi_schedule(&priv->napi);
                return IRQ_HANDLED;
        }

so perhaps this could be a problem.  The same happens in the remove 
function.

julia
