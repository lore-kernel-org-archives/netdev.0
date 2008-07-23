From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [build failure] hp-plus.c: (.text+0xd7c1a): undefined reference
	to `ei_close'
Date: Wed, 23 Jul 2008 12:45:20 +0200
Message-ID: <20080723104520.GA20672@elte.hu>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp> <20080721191519.GA15843@elte.hu> <20080721214258.787a67ca@lxorguk.ukuu.org.uk> <20080722072334.GA25241@elte.hu> <48865899.3030209@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Atsushi Nemoto <anemo@mba.ocn.ne.jp>, jgarzik@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:37333 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751433AbYGWKqf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Jul 2008 06:46:35 -0400
Content-Disposition: inline
In-Reply-To: <48865899.3030209@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Jeff Garzik <jeff@garzik.org> wrote:

>>>>> drivers/built-in.o: In function `ne_probe1':
>>>>> ne.c:(.init.text+0x2464): undefined reference to `NS8390_init'
>>>>> drivers/built-in.o: In function `ne_block_output':
>>>>> ne.c:(.text.ne_block_output+0x1b0): undefined reference to `NS8390_init'
>>>> i just triggered a similar build failure, but in a different  
>>>> ne2000-derived file:
>>> I'll take a look. Various odd things happened with the Makefile for  
>>> this patch and the follow up fixes. If the followup didn't get 
>>> applied then that might explain the breakage.
>>
>> ok. I also got:
>>
>>  drivers/built-in.o: In function `hp_probe1':
>>  hp.c:(.init.text+0xa280): undefined reference to `NS8390_init'
>>
>> so i suspect most of the 8390p.o library using ne2000 drivers are  
>> affected?
>>
>> i think instead of a manual review i think this is better to fix all 
>> the problems:
>>
>> cd drivers/net/; sed -i 's/NS8390_/NS8390p_/g' \
>>   $(grep -l NS8390_ $(grep 8390p.o Makefile | cut -d' ' -f3 | \
>>      sed 's/.o$/.c/g'))
>>
>> find the full tested patch below. It solves the build failures i  
>> triggered so far.
>>
>> 	Ingo
>>
>> ------------->
>> commit 79f2b8594df44a4f3f11085df656883525b74abd
>> Author: Ingo Molnar <mingo@elte.hu>
>> Date:   Tue Jul 22 09:19:31 2008 +0200
>>
>>     net 8390p: fix interface usage
>>         various drivers were using the wrong APIs:
>>          drivers/built-in.o: In function `hp_probe1':
>>      hp.c:(.init.text+0xa280): undefined reference to `NS8390_init'
>>         fixed via:
>>         cd drivers/net/; sed -i 's/NS8390_/NS8390p_/g' \
>>       $(grep -l NS8390_ $(grep 8390p.o Makefile | cut -d' ' -f3 | \
>>           sed 's/.o$/.c/g'))
>>         Signed-off-by: Ingo Molnar <mingo@elte.hu>
>> ---
>>  drivers/net/hp-plus.c |    2 +-
>>  drivers/net/hp.c      |    2 +-
>>  drivers/net/ne.c      |    2 +-
>>  drivers/net/ne2.c     |    2 +-
>>  4 files changed, 4 insertions(+), 4 deletions(-)
>>
>> diff --git a/drivers/net/hp-plus.c b/drivers/net/hp-plus.c
>> index c2c4f49..8239939 100644
>> --- a/drivers/net/hp-plus.c
>> +++ b/drivers/net/hp-plus.c
>> @@ -262,7 +262,7 @@ static int __init hpp_probe1(struct net_device *dev, int ioaddr)
>>  	}
>>   	outw(Perf_Page, ioaddr + HP_PAGING);
>> -	NS8390_init(dev, 0);
>> +	NS8390p_init(dev, 0);
>>  	/* Leave the 8390 and HP chip reset. */
>>  	outw(inw(ioaddr + HPP_OPTION) & ~EnableIRQ, ioaddr + HPP_OPTION);
>>  diff --git a/drivers/net/hp.c b/drivers/net/hp.c
>> index 8281209..0a8c649 100644
>> --- a/drivers/net/hp.c
>> +++ b/drivers/net/hp.c
>> @@ -389,7 +389,7 @@ static void __init
>>  hp_init_card(struct net_device *dev)
>>  {
>>  	int irq = dev->irq;
>> -	NS8390_init(dev, 0);
>> +	NS8390p_init(dev, 0);
>>  	outb_p(irqmap[irq&0x0f] | HP_RUN,
>>  		   dev->base_addr - NIC_OFFSET + HP_CONFIGURE);
>>  	return;
>> diff --git a/drivers/net/ne.c b/drivers/net/ne.c
>> index 3df231d..4a8a4b1 100644
>> --- a/drivers/net/ne.c
>> +++ b/drivers/net/ne.c
>> @@ -355,7 +355,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
>>  	}
>>   	/* Read the 16 bytes of station address PROM.
>> -	   We must first initialize registers, similar to NS8390_init(eifdev, 0).
>> +	   We must first initialize registers, similar to NS8390p_init(eifdev, 0).
>>  	   We can't reliably read the SAPROM address without this.
>>  	   (I learned the hard way!). */
>>  	{
>> diff --git a/drivers/net/ne2.c b/drivers/net/ne2.c
>> index 8f72563..332df75 100644
>> --- a/drivers/net/ne2.c
>> +++ b/drivers/net/ne2.c
>> @@ -404,7 +404,7 @@ static int __init ne2_probe1(struct net_device *dev, int slot)
>>   	/* Read the 16 bytes of station address PROM.
>>  	   We must first initialize registers, similar to
>> -	   NS8390_init(eifdev, 0).
>> +	   NS8390p_init(eifdev, 0).
>>  	   We can't reliably read the SAPROM address without this.
>>  	   (I learned the hard way!). */
>
> applied

thanks Jeff. I think the fix below from Atsushi-san might still be 
missing from upstream?

	Ingo

-------------------->
commit 994cd3a79a431f5ce234478e951856357f4bc94c
Author: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date:   Mon Jul 21 23:35:12 2008 +0900

    8390: Fix ne.c build
    
    Since commit 055e5110ae0c0c1176a75b78d789294f2ff2f7af ("8390: Split
    8390 support into a pausing and a non pausing driver core"), ne.c
    cause this build failure:
    
    drivers/built-in.o: In function `ne_probe1':
    ne.c:(.init.text+0x2464): undefined reference to `NS8390_init'
    drivers/built-in.o: In function `ne_block_output':
    ne.c:(.text.ne_block_output+0x1b0): undefined reference to `NS8390_init'
    
    Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
    Cc: jgarzik@redhat.com
    Cc: akpm@linux-foundation.org
    Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>
    Signed-off-by: Ingo Molnar <mingo@elte.hu>
---
 drivers/net/ne.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ne.c b/drivers/net/ne.c
index 2fec612..4a8a4b1 100644
--- a/drivers/net/ne.c
+++ b/drivers/net/ne.c
@@ -536,7 +536,7 @@ static int __init ne_probe1(struct net_device *dev, unsigned long ioaddr)
 #ifdef CONFIG_NET_POLL_CONTROLLER
 	dev->poll_controller = eip_poll;
 #endif
-	NS8390_init(dev, 0);
+	NS8390p_init(dev, 0);
 
 	ret = register_netdev(dev);
 	if (ret)
@@ -794,7 +794,7 @@ retry:
 		if (time_after(jiffies, dma_start + 2*HZ/100)) {		/* 20ms */
 			printk(KERN_WARNING "%s: timeout waiting for Tx RDC.\n", dev->name);
 			ne_reset_8390(dev);
-			NS8390_init(dev,1);
+			NS8390p_init(dev,1);
 			break;
 		}
 
@@ -855,7 +855,7 @@ static int ne_drv_resume(struct platform_device *pdev)
 
 	if (netif_running(dev)) {
 		ne_reset_8390(dev);
-		NS8390_init(dev, 1);
+		NS8390p_init(dev, 1);
 		netif_device_attach(dev);
 	}
 	return 0;
