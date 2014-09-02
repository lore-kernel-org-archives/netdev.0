From: Daniel Mack <zonque@gmail.com>
Subject: Re: question about drivers/net/ethernet/ti/cpsw.c
Date: Tue, 02 Sep 2014 11:34:16 +0200
Message-ID: <54058F18.8060709@gmail.com>
References: <alpine.DEB.2.02.1408282118560.2226@localhost6.localdomain6> <20140901.181101.2132157946809255487.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, julia.lawall@lip6.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f172.google.com ([74.125.82.172]:46145 "EHLO
	mail-we0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752076AbaIBJeT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 05:34:19 -0400
Received: by mail-we0-f172.google.com with SMTP id q59so6677720wes.3
        for <netdev@vger.kernel.org>; Tue, 02 Sep 2014 02:34:18 -0700 (PDT)
In-Reply-To: <20140901.181101.2132157946809255487.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/02/2014 03:11 AM, David Miller wrote:
> From: Julia Lawall <julia.lawall@lip6.fr>
> Date: Thu, 28 Aug 2014 21:26:55 +0200 (CEST)
> 
>> I wonder if the following patch:
>>
>> commit aa1a15e2d9199711cdcc9399fdb22544ab835a83
>> Author: Daniel Mack <zonque@gmail.com>
>> Date:   Sat Sep 21 00:50:38 2013 +0530
>>
>> introduced a race condition in drivers/net/ethernet/ti/cpsw.c.  I was 
>> looking at an old version of the file (Linux 3.10), and it has
>>
>>  clean_irq_ret:
>>          for (i = 0; i < priv->num_irqs; i++)
>>                  free_irq(priv->irqs_table[i], priv);
>>
>> at the beginning of the cleanup code of the probe function (cpsw_probe).  
>> The above patch replaces request_irq by devm_request_irq and gets rid of 
>> the above cleanup code.  But that moves the stopping of the interrupts 
>> after the following code at the end of the function:
>>
>> free_netdev(priv->ndev);
>>
>> The interrupt handler (cpsw_interrupt) does reference priv->ndev:
>>
>> 	if (netif_running(priv->ndev)) {
>>                 napi_schedule(&priv->napi);
>>                 return IRQ_HANDLED;
>>         }
>>
>> so perhaps this could be a problem.  The same happens in the remove 
>> function.
> 
> It could definitely be a problem.
> 
> Probably it would be better for this device to request IRQs in open
> and release them in close like so many other networking drivers do.

Thanks for spotting this, Julia!
I'll be working on a fix for this as soon as I can.


Best regards,
Daniel
