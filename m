From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [2.4] forcedeth network driver
Date: Sat, 24 Jan 2004 19:01:03 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <4013073F.7030504@pobox.com>
References: <4012A738.2060009@gmx.net> <4012B25B.9060706@pobox.com> <4012E276.5030804@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        netdev@oss.sgi.com, Manfred Spraul <manfred@colorfullife.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
In-Reply-To: <4012E276.5030804@gmx.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Carl-Daniel Hailfinger wrote:
>>>+#if (LINUX_VERSION_CODE < KERNEL_VERSION(2,5,28))
>>>+static inline void synchronize_irq_wrapper(unsigned int irq) {
>>>synchronize_irq(); }
>>>+#undef synchronize_irq
>>>+#define synchronize_irq(irq)    synchronize_irq_wrapper(irq)
>>>+#endif
>>
>>
>>Just introduce a diff between 2.4 and 2.6 versions.
> 
> 
> The chunk above is the only difference between the 2.4 and the 2.6
> version. Should I remove the #ifdef or change the line calling
> synchronize_irq itself?

Just change the line itself, for the 2.4 and 2.6 kernel.org trees...


>>>+    dprintk(KERN_DEBUG "%s: start_xmit: packet packet %d queued for
>>>transmission.\n",
>>>+                dev->name, np->next_tx);
>>>+    {
>>>+        int j;
>>>+        for (j=0; j<64; j++) {
>>>+            if ((j%16) == 0)
>>>+                dprintk("\n%03x:", j);
>>>+            dprintk(" %02x", ((unsigned char*)skb->data)[j]);
>>>+        }
>>>+        dprintk("\n");
>>>+    }
>>
>>
>>would be nice if this loop was optimized out by the compiler.
> 
> 
> You mean it should be removed? AFAICS, we have
> #define dprintk(x...)          do { } while (0)
> so the compiler _should_ optimize it out if we use at least -O.

<shrug>  no biggie either way.  it's just the sorta code I would throw 
an ifdef or "if (static_constant)" around.


>>>+    if (!is_valid_ether_addr(dev->dev_addr)) {
>>>+        /*
>>>+         * Bad mac address. At least one bios sets the mac address
>>>+         * to 01:23:45:67:89:ab
>>>+         */
>>>+        printk(KERN_ERR "%s: Invalid Mac address detected:
>>>%02x:%02x:%02x:%02x:%02x:%02x\n",
>>>+            pci_name(pci_dev),
>>>+            dev->dev_addr[0], dev->dev_addr[1], dev->dev_addr[2],
>>>+            dev->dev_addr[3], dev->dev_addr[4], dev->dev_addr[5]);
>>>+        printk(KERN_ERR "Please complain to your hardware vendor.
>>>Switching to a random MAC.\n");
>>>+        dev->dev_addr[0] = 0x00;
>>>+        dev->dev_addr[1] = 0x00;
>>>+        dev->dev_addr[2] = 0x6c;
>>>+        get_random_bytes(&dev->dev_addr[3], 3);
>>>+    }
>>
>>
>>I don't like this random MAC address stuff.  Regardless of hardware
>>behavior, this breaks MAC address uniqueness.
>>
>>I would much rather that ->open() failed, if a valid MAC address were
>>not present.  Then a simple userspace program can be run by the admin
>>(policy!) that sets the MAC address, before bringing up the interface.
> 
> 
> This was a feature many users asked for. It seems broken hardware is very
> common for this chipset.

That's fine, but it doesn't have to be implemented in the kernel.  Users 
can just as easily download a generic userspace program that checks your 
MAC address, and attempts to assign you one if you don't already have one.

This is a good example of putting policy in the kernel, in fact :)


> Will take a look at other drivers. Do you have any good example?

e100, e1000, tg3, 8139cp, ...

	Jeff
