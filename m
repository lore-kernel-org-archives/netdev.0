From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.9 SMP: via-rhine cannot be upped
Date: Wed, 27 Oct 2004 09:16:01 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041027091601.476ee3ca@guest-251-240.pdx.osdl.net>
References: <200410271000.24390.vda@port.imtp.ilyichevsk.odessa.ua>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com,
        Jeff Garzik
 <jgarzik@pobox.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua>
In-Reply-To: <200410271000.24390.vda@port.imtp.ilyichevsk.odessa.ua>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 27 Oct 2004 10:00:24 +0300
Denis Vlasenko <vda@port.imtp.ilyichevsk.odessa.ua> wrote:

> [sorry, threading will be broken]
> 
> >>I have an onboard VIA eth:
> >>
> >># lspci
> >>00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II] (rev 74)
> >>
> >>It cannot be upped:
> >>
> >># ip l set dev if up
> >>SIOCSIFFLAGS: Function not implemented
> >># ifconfig if up
> >>SIOCSIFFLAGS: Function not implemented
> >># busybox ip l set dev if up
> >>SIOCSIFFLAGS: Function not implemented
> >
> >My suspicion is that the eth0 device is not actually the VIA driver
> >at all. Since your config builds many drivers directly into the kernel,
> >probably one of the others created an eth0 device.  There is no
> >guarantee of initialization order about which device gets created first
> >(at least the way network devices are done in 2.6). 
> >
> >You should investigate if there are multiple devices present
> >(ifconfig -a or ls /sys/class/net).  Perhaps one of the other drivers
> >does not correctly handle the case of hardware not being present
> >and leaves a ghost behind..
> >
> >One way to find out would be to look at:
> >	/sys/class/net/eth0/device/vendor
> >	/sys/class/net/eth0/device/device
> >	/sys/class/net/eth0/device/subsystem_vendor
> >	/sys/class/net/eth0/device/subsystem_device
> 
> Thanks! This was an excellent advice.
> 
> 2.6.9-smp did get right the device as Via Rhine, but IRQ is 16
> now! This must be source of my problems.
> 
> I had to check dmesg in the first place instead of
> mailing lkml...

So the summary is the via-rhine could not get irq so it
was not any attempt bring it up would fail.

> +eth0: VIA Rhine II at 0xe400, 00:0a:e6:7c:dd:79, IRQ 16.
...
> +eth0: could not install IRQ handler
> +prism54: probe of 0000:00:0c.0 failed with error -5

The failure -ENOSYS comes from:

int setup_irq(unsigned int irq, struct irqaction * new)
{
        struct irq_desc *desc = irq_desc + irq;
        struct irqaction *old, **p;
        unsigned long flags;
        int shared = 0;

        if (desc->handler == &no_irq_type)
                return -ENOSYS;

Looks like IRQ 16 is not a valid interrupt source.  Since SMP
kernel needs an APIC (an UP doesn't). 

+PCI->APIC IRQ transform: (B0,I12,P0) -> 16

Maybe either your motherboard APIC support doesn't work, or
ACPI is confused.

Do you really need to run SMP kernels on this board?
