From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: Disabling msix interrupts
Date: Mon, 6 Feb 2017 08:26:42 -0800
Message-ID: <CAKgT0UeXXkUpsrF9gpf_gba56V+B8a1G84k0WWt5q85Rx2PVsA@mail.gmail.com>
References: <063D6719AE5E284EB5DD2968C1650D6DB027C936@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <linux-pci-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB027C936@AcuExch.aculab.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 6, 2017 at 7:33 AM, David Laight <David.Laight@aculab.com> wrote:
> netdev probably isn't the right list for this, but I suspect people
> reading it understand what happens.
>
> I'm fairly sure that an msix interrupt can get raised after
> the kernel thinks it has masked it.
>
> When an msix interrupt is disabled I think msi_set_mask_bit()
> (in drivers/pci/msi.c) is called to write a '1' to the card's
> hardware MSIX mask register (the last 32bit word of the entry).
> This function carefully reads back the mask register to flush
> the write through the pcie bus.
> Except it doesn't, it reads the 'address_lo' register instead! [1]

Reading any register will force the write to be flushed as all PCI
writes must be completed before a PCI read.  For example in the Intel
drivers we read register 0 to flush a write of any of the other
registers.

> While this will stop the hardware raising any more interrupts,
> it could easily be in the process of raising one.
> ie have read the mask, found it zero, read the address and
> data, and be in the process of issuing the pcie write.
>
> The pcie write (to disable the interrupt) and readback are seen
> by the hardware as (more or less) back to back transfers, so can
> both easily overtake the request to raise the interrupt.

I don't believe this is correct.  On the PCI bus what you should see
is the device aware that interrupts are disabled before the completion
arrives and any MSI messages should arrive before the last read
completion.

> The pcie bus is also allowed to make a read completion tlp
> overtake a write tlp.
> Add in any host-side delays in raising the hardware interrupt
> itself, and an interrupt could happen well after it was masked.

That is only if relaxed ordering is enabled, which I am not sure is
supported for MSI-X interrupts.  That being said though I believe
there are some platforms that could end up seeing a delay in handling
the interrupt if for example the CPU the interrupt was delivered to
was in a sleep state.

> More worrying would be any code that tries to change the address
> and data associated with an interrupt.
> You'd need moderate guard times after the disable and before the
> enable to ensure the hardware didn't raise an interrupt with
> a mismatch of the old and new values.
>
> [1] Maybe I'll look at the order those cycles actually arrive in.
>
>         David

So I have thrown in my $.02 on this, and added the linux-pci mailing
list.  That is a much better place to bring this up rather than
netdev.

Thanks.

- Alex
