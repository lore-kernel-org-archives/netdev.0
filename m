From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] [2.4] forcedeth network driver
Date: Sat, 24 Jan 2004 18:57:08 -0500
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <40130654.2070106@pobox.com>
References: <4012BF44.9@colorfullife.com> <4012D3C6.1050805@pobox.com> <4012E9BF.90102@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	linux-kernel@vger.kernel.org, Netdev <netdev@oss.sgi.com>
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
To: Carl-Daniel Hailfinger <c-d.hailfinger.kernel.2004@gmx.net>
In-Reply-To: <4012E9BF.90102@gmx.net>
List-Id: netdev.vger.kernel.org

Carl-Daniel Hailfinger wrote:
> Jeff Garzik wrote:
> 
>>Manfred Spraul wrote:
>>
>>
>>>Jeff wrote:
>>>
>>>
>>>>* Interrupt handler is SCARY.  You can potentially take and release
>>>>the spinlock -many times- during a single interrupt.
>>>>
>>>
>>>I think that can happen only in theory: A new packet is completed
>>>while the driver processes rx packets. I all normal cases there should
>>>be one spinlock operation per tx irq, and 0 per rx irq.
>>>And error handling IMHO doesn't count: it should be rare.
>>>Or do I overlook a common case?
>>
>>
>>Any amount of load at all will lead to multiple interations of the
>>master loop in the interrupt handler.
> 
> 
> +static int max_interrupt_work = 5;
> [...]
> +       for (i=0; ; i++) {
> +               if (i > max_interrupt_work) {
> +                       spin_lock(&np->lock);
> +                       /* disable interrupts on the nic */
> +                       writel(0, base + NvRegIrqMask);
> +                       pci_push(base);
> +
> +                       if (!np->in_shutdown)
> +                               mod_timer(&np->nic_poll, jiffies + POLL_WAIT);
> +                       printk(KERN_DEBUG "%s: too many iterations (%d) in
> nic_irq.\n", dev->name, i);
> +                       spin_unlock(&np->lock);
> +                       break;
> +               }
> 
> So actually it should not happen that often since we exit the master loop
> after 5 iterations.

<shrug>  Well, it's not a must-change item IMO


>>>>>+#define NV_MIIPHY_DELAY    10
>>>>>+#define NV_MIIPHY_DELAYMAX    10000
>>>>
>>>>
>>>>
>>>>Style:  it's fairly silly to mix enums and constants.
>>>> 
>>>>
>>>
>>>Right now: enum for the nic registers, #define for the rest. If you
>>>don't like it I can change it.
>>
>>
>>enums are definitely preferred...  communicates more type/symbol
>>information to the compiler and more symbol info to the debugger.
> 
> 
> The current order has the benefit that the values which might be written
> to a register (most of which are constants) are located next to the enum
> for the register.

You can do this with enums, too :)

>>Fair enough.  You may wish to (after testing!) increase DEFAULT_MTU by 4
>>bytes, to support VLAN.
> 
> 
> Already tried. If we increase the length of the packet the nic has to send
> beyond 1500 bytes, we simply get an TX error/timeout. So far, I have not
> seen any hints that the nic might do VLAN tagging internally.

The current limit sounds correct, then.


> Jeff, there is another bug in some hardware revisions: For every received
> packet it reports 1500 bytes length regardless of the real length. We take
> this len as correct and hope for the best. At best, it ruins our RX
> statistics. At worst, it might leak kernel memory to userspace since the
> unused remainder of the 1500 bytes is not initialized with anything, yet
> passed up with netif_rx(skb). Does the networking core provide any
> built-in function to address this problem?
> 
> +               prd = &np->rx_ring[i];
> [...]
> +               len = le16_to_cpu(prd->Length);
> [...]
> +               skb_put(skb, len);
> [...]
> +               netif_rx(skb);
> 
> The above code would be correct if the hardware actually gave us the right
> values. I know that at least some nForce2 systems suffer from this.

Peek at the ethernet frame header and see what it thinks the payload 
length is?  If less than 1500...

	Jeff
