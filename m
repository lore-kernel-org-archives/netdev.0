From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC PATCH] usb: hcd: warn about URB buffers that are not DMA
 aligned and are about to be DMA mapped
Date: Sat, 15 Jun 2013 20:07:31 +0800
Message-ID: <CACVXFVMe9fgdiDTRC0rWvwZJM8aT7AZY8Q1MwiOTc4ks0PQPOg@mail.gmail.com>
References: <20130614133803.25747.98705.stgit@localhost6.localdomain6>
	<CACVXFVM4TsS-_qK_w01oajV1XcA_+OF8xdTX2xjjxOTFNAo6Sw@mail.gmail.com>
	<51BC3F9E.3010605@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <51BC3F9E.3010605-X3B1VOXEql0@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Jun 15, 2013 at 6:19 PM, Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org> wrote:
> On 15.06.2013 10:41, Ming Lei wrote:
>> Cc: netdev
>>
>> On Fri, Jun 14, 2013 at 9:38 PM, Jussi Kivilinna <jussi.kivilinna-X3B1VOXEql0@public.gmane.org> wrote:
>>> Appearently some out-of-tree USB host drivers do not handle DMA alignment for
>>
>> Looks these host drivers have to face the fact that the transfer buffer is often
>> DMA non-aligned from network device drivers(in fact, the buffer is from
>> network protocol stack), if you run usbnet, then you will get the added warning
>> immediately.
>>
>
> Yes, getting warning immediately, but once, and blaming host driver seems ok.

We do know the fact of non-aligned transfer buffer from network, which has been
for long time, so does it make sense to print warning and annoy people?

>
>>> URB buffers and let core/hcd.c to do the mapping on architectures that have
>>> minimum DMA alignment requirements. This leads to random memory corruptions
>>> and crashes when using USB device drivers that use unaligned URB buffers.
>>
>> Maybe you should check the dma mapping/unmapping implementation of
>> the arch, non-aligned buffer should have be covered by the API easily.
>>
>> Also USB Host controller should have supported non-aligned DMA buffer.
>
> From what I found, there was some discussion about these issues around 2010:
>  http://lists.infradead.org/pipermail/linux-arm-kernel/2010-August/022983.html

>From the discussion,  people think that HCD should handle the unaligned buffer,
right?

>
> To me, it seems that non-aligned buffers cannot be easily handled by all archs
> at dma mapping/unmapping phase and that HCD driver should do the alignment on

If the memory which shares cache line with transfer buffer can't be
accessed during
DMA transfer(between URB submit and complete), dma mapping/unmapping
should have handled it.

About the network transfer buffer case, I think it should be true,
otherwise there
should have lots of memory corruption reports about usb network drivers.
Fortunately, there are seldom such reports.

> archs that set ARCH_DMA_MINALIGN. For example, ehci_tegra does copy unaligned
> transfer buffers to temporary aligned buffers before letting them to USB core.

Yes, if host controller can't handle this, the HCD has to work around
the problem. Anyway, most of host controllers can deal with the it,
can't they?

>
>>
>>>
>>> Instead of fixing host drivers, users end up posting bug reports against
>>> those USB device drivers that use unaligned buffers for URB; such as with
>>> rtl8192cu (http://thread.gmane.org/gmane.linux.kernel.wireless.general/105631).
>>
>> Not only rtl8192cu driver, all USB network device drivers have the problem.
>>
>>>
>>> Patch makes this issue more visible at core level, and hopefully gives hint
>>> for future hcd driver implementors about this problem.
>>
>> So please find the root cause first, and don't add the noise now.
>
> I think the root cause is that host driver is letting pass non-aligned buffers
> to core on archs that have ARCH_DMA_MINALIGN set.

No, I don't think so, about the problem, the dma alignment requirement should
be from your host controller.

As I said above, dma mapping/unmapping should be capable of dealing with
the unaligned buffer if no one touches memory which shares cacheline with
URB->transfer_buffer during URB transfer.

Looks you need to know why the memory corruption happens. Is it caused
by non-aligned arch mapping/unmapping? or by host controller hardware when
dealing with non-aligned transfer buffer?

> The warning given just before such unaligned buffer is passed to dma_map_single,
> which requires ARCH_DMA_MINALIGN alignment. This seems reasonable to me.

ARCH_DMA_MINALIGN means that kmalloc() should return aligned dma buffer.

Again, you have to accept the fact in which transfer buffer from
network stack is
non-aligned.


Thanks,
-- 
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
