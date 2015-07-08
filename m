From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net PATCH 1/1] drivers: net: cpsw: fix disabling of tx interrupt
 in rx isr
Date: Wed, 8 Jul 2015 14:21:27 +0530
Message-ID: <559CE48F.1070802@ti.com>
References: <1436338066-7685-1-git-send-email-mugunthanvnm@ti.com> <20150708073855.GA7277@saruman.tx.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stable@vger.kernel.org>
To: <balbi@ti.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150708073855.GA7277@saruman.tx.rr.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 08 July 2015 01:08 PM, Felipe Balbi wrote:
> Hi,
> 
> On Wed, Jul 08, 2015 at 12:17:46PM +0530, Mugunthan V N wrote:
>> With the below commit, common isr is split into tx and rx, but in
>> rx isr tx interrupt is also disabled. So tx packets are not handled
>> during rx interrupts and rx napi completion. Fixing by disabling on
>> rx interrupt in rx isr.
>>
>> Fixes: c03abd84634d ("net: ethernet: cpsw: don't requests IRQs we don't use")
> 
> why does this fix that commit ? What was the regression ? So RX IRQ fire
> and both RX and TX are disabled, sure that's bad. But it should cause
> lower throughput. At a minimum, I think your commit log needs some work.

Agreed, will change the commit and resubmit the patch as it affects
performance only and not a regression.

> 
> Also, disable_irq_nosync() shouldn't really be needed, you could just
> mask the IRQ in the IRQ Enable register, but I guess that'd be v4.3
> material.

This was needed because there is a latch inbetween CPSW interrupt line
and Interrupt Controller (to convert from pulse interrupt to level
interrupt), because of this even though interrupt is disabled from the
IP, CPU is held up in isr as it is not cleared or masked to Interrupt
controller. Because of disable_irq_nosync() was added initially. I will
revisit this but as you said it will be for 4.3

> 

With this patch I am able to see +3 Mbps with omap2plus_defconfig and
+40Mbps with having AM43xx SoC only and removing some kernel debugging
options.

*with omap2plus_defconfig*
[  5] local 192.168.10.116 port 5001 connected with 192.168.10.118 port
46470
[  5]  0.0-60.0 sec  1.03 GBytes   147 Mbits/sec

[  4] local 192.168.10.116 port 5001 connected with 192.168.10.118 port
45968
[ ID] Interval       Transfer     Bandwidth
[  4]  0.0-60.0 sec  1.05 GBytes   150 Mbits/sec


*with omap2plus_defconfig + removing other SoCs and Some debug options*
[  5] local 192.168.10.116 port 5001 connected with 192.168.10.118 port
53272
[  5]  0.0-60.0 sec  2.11 GBytes   302 Mbits/sec


[  4] local 192.168.10.116 port 5001 connected with 192.168.10.118 port
51896
[  4]  0.0-60.0 sec  2.40 GBytes   343 Mbits/sec

Regards
Mugunthan V N
