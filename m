From: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
Subject: Re: [PATCH] [2.4] forcedeth network driver
Date: Sat, 24 Jan 2004 22:24:06 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4012E276.5030804@gmx.net>
References: <4012A738.2060009@gmx.net> <4012B25B.9060706@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
In-Reply-To: <4012B25B.9060706@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Carl-Daniel Hailfinger wrote:
> 
>> Marcelo,
>>
>> attached is the current version of forcedeth, a network driver for
>> nForce{,2,3} chipsets which are fairly common today.
>> So far, the only support for nForce chipsets has been a binary-only
>> driver
>> from NVidia.
> 
> 
>> The patch is against your current bk tree.
>> Please apply.
> 
> 
> I wish you'd mailed me first...  let's not be so hasty.

I'm sorry. Since I had not seen any net driver patches getting into
2.4.25-pre, I assumed you had set your priorities to 2.6. Looking again,
it seems the switch from 2.4.24-pre to 2.4.25-pre confused me and I forgot
to double check with the actual prepatches.

> 
> 
> General comments:
> 
> * This was suggested (and ignored), but IMO needs to be done -- the
> function names are -way- too generic.  If this driver oops's, people
> might see an oops in "open" or "close" functions, which is fairly
> useless information unless correlated with other info.  Please follow
> style and add a driver-specific prefix to your function names.

Will coordinate with Manfred so that we don't step on each other's toes
when changing function names.


>> +#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,5,28))
>> +static inline void synchronize_irq_wrapper(unsigned int irq) {
>> synchronize_irq(); }
>> +#undef synchronize_irq
>> +#define synchronize_irq(irq)    synchronize_irq_wrapper(irq)
>> +#endif
> 
> 
> Just introduce a diff between 2.4 and 2.6 versions.

The chunk above is the only difference between the 2.4 and the 2.6
version. Should I remove the #ifdef or change the line calling
synchronize_irq itself?


>> +    dprintk(KERN_DEBUG "%s: start_xmit: packet packet %d queued for
>> transmission.\n",
>> +                dev->name, np->next_tx);
>> +    {
>> +        int j;
>> +        for (j=0; j<64; j++) {
>> +            if ((j%16) == 0)
>> +                dprintk("\n%03x:", j);
>> +            dprintk(" %02x", ((unsigned char*)skb->data)[j]);
>> +        }
>> +        dprintk("\n");
>> +    }
> 
> 
> would be nice if this loop was optimized out by the compiler.

You mean it should be removed? AFAICS, we have
#define dprintk(x...)          do { } while (0)
so the compiler _should_ optimize it out if we use at least -O.


>> +    for (i = 0; i < DEVICE_COUNT_RESOURCE; i++) {
>> +        dprintk(KERN_DEBUG "%s: resource %d start %p len %ld flags 0x%08lx.\n",
>> +                pci_name(pci_dev), i, (void*)pci_resource_start(pci_dev, i),
>> +                pci_resource_len(pci_dev, i),
>> +                pci_resource_flags(pci_dev, i));
>> +        if (pci_resource_flags(pci_dev, i) & IORESOURCE_MEM &&
>> +                pci_resource_len(pci_dev, i) >= NV_PCI_REGSZ) {
>> +            addr = pci_resource_start(pci_dev, i);
>> +            break;
>> +        }
>> +    }
> 
> Do nForce NICs really put the registers on random PCI BARs???
> 
> I would rather just hardcode is the PCI BAR if at all possible.

No idea. None of us have the hardware available, so we entirely depend on
external testers. We could try to get a sampling by issuing an
unconditional printk instead.


>> +    if (!is_valid_ether_addr(dev->dev_addr)) {
>> +        /*
>> +         * Bad mac address. At least one bios sets the mac address
>> +         * to 01:23:45:67:89:ab
>> +         */
>> +        printk(KERN_ERR "%s: Invalid Mac address detected:
>> %02x:%02x:%02x:%02x:%02x:%02x\n",
>> +            pci_name(pci_dev),
>> +            dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
>> +            dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
>> +        printk(KERN_ERR "Please complain to your hardware vendor.
>> Switching to a random MAC.\n");
>> +        dev->dev_addr[0] = 0x00;
>> +        dev->dev_addr[1] = 0x00;
>> +        dev->dev_addr[2] = 0x6c;
>> +        get_random_bytes(&dev->dev_addr[3], 3);
>> +    }
> 
> 
> I don't like this random MAC address stuff.  Regardless of hardware
> behavior, this breaks MAC address uniqueness.
> 
> I would much rather that ->open() failed, if a valid MAC address were
> not present.  Then a simple userspace program can be run by the admin
> (policy!) that sets the MAC address, before bringing up the interface.

This was a feature many users asked for. It seems broken hardware is very
common for this chipset.


>> +static struct pci_device_id pci_tbl[] = {
>> +    {    /* nForce Ethernet Controller */
>> +        .vendor = PCI_VENDOR_ID_NVIDIA,
>> +        .device = 0x1C3,
>> +        .subvendor = PCI_ANY_ID,
>> +        .subdevice = PCI_ANY_ID,
>> +        .driver_data = DEV_IRQMASK_1|DEV_NEED_TIMERIRQ,
>> +    },
>> +    {    /* nForce2 Ethernet Controller */
>> +        .vendor = PCI_VENDOR_ID_NVIDIA,
>> +        .device = 0x0066,
>> +        .subvendor = PCI_ANY_ID,
>> +        .subdevice = PCI_ANY_ID,
>> +        .driver_data =
>> DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
>> +    },
>> +    {    /* nForce3 Ethernet Controller */
>> +        .vendor = PCI_VENDOR_ID_NVIDIA,
>> +        .device = 0x00D6,
>> +        .subvendor = PCI_ANY_ID,
>> +        .subdevice = PCI_ANY_ID,
>> +        .driver_data =
>> DEV_NEED_LASTPACKET1|DEV_IRQMASK_2|DEV_NEED_TIMERIRQ,
>> +    },
>> +    {0,},
>> +};
> 
> 
> You'll note this structure is wildly larger than most net drivers...
> maintainer's preference, but I think this is way too verbose.

Will take a look at other drivers. Do you have any good example?


>     Jeff

Carl-Daniel
-- 
http://www.hailfinger.org/carldani/linux/patches/forcedeth/
