From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [RFC PATCH] usb: hcd: warn about URB buffers that are not DMA
 aligned and are about to be DMA mapped
Date: Sun, 16 Jun 2013 13:34:51 +0300
Message-ID: <51BD94CB.1030209@iki.fi>
References: <20130614133803.25747.98705.stgit@localhost6.localdomain6> <CACVXFVM4TsS-_qK_w01oajV1XcA_+OF8xdTX2xjjxOTFNAo6Sw@mail.gmail.com> <51BC3F9E.3010605@iki.fi> <CACVXFVMe9fgdiDTRC0rWvwZJM8aT7AZY8Q1MwiOTc4ks0PQPOg@mail.gmail.com> <51BC67D7.90006@iki.fi> <CACVXFVMwoNyNNMU6O2x8Hc+jTi8zXUT3iOW=SNJeu0_uCwzFUA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Network Development <netdev@vger.kernel.org>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sypressi.dnainternet.net ([83.102.40.135]:39023 "EHLO
	sypressi.dnainternet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755142Ab3FPKfA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Jun 2013 06:35:00 -0400
In-Reply-To: <CACVXFVMwoNyNNMU6O2x8Hc+jTi8zXUT3iOW=SNJeu0_uCwzFUA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.06.2013 16:47, Ming Lei wrote:
> On Sat, Jun 15, 2013 at 9:10 PM, Jussi Kivilinna <jussi.kivilinna@iki.fi> wrote:
>> On 15.06.2013 15:07, Ming Lei wrote:
>>> On Sat, Jun 15, 2013 at 6:19 PM, Jussi Kivilinna <jussi.kivilinna@iki.fi> wrote:
>>>> On 15.06.2013 10:41, Ming Lei wrote:
>>>>> Cc: netdev
>>>>>
>>>>> On Fri, Jun 14, 2013 at 9:38 PM, Jussi Kivilinna <jussi.kivilinna@iki.fi> wrote:
>>>>>> Appearently some out-of-tree USB host drivers do not handle DMA alignment for
>>>>>
>>>>> Looks these host drivers have to face the fact that the transfer buffer is often
>>>>> DMA non-aligned from network device drivers(in fact, the buffer is from
>>>>> network protocol stack), if you run usbnet, then you will get the added warning
>>>>> immediately.
>>>>>
>>>>
>>>> Yes, getting warning immediately, but once, and blaming host driver seems ok.
>>>
>>> We do know the fact of non-aligned transfer buffer from network, which has been
>>> for long time, so does it make sense to print warning and annoy people?
>>
>> It's only printed if host controller driver is not behaving correctly.
> 
> If you make sure the warning is only printed on broken controller,
> that is fine.
> 
>>
>> I have changed the message to be printed for v2-patch, and it is now:
>> dev_WARN_ONCE(hcd->self.controller, 1,
>>         "broken USB host controller driver; does not correctly handle DMA alignment for urb->transfer_buffer (offset: %d).\n",
>>         dma_offset);
>>
>> I sent the patch as RFC since I'm not sure.. maybe annoying warnings make
> 
> That is fine.
> 
>> people aware of issues that they don't yet know of and things get fixed?
> 
> I mean it isn't good to annoy people who are using good host controller, :-)
> 

Yes, and now it seems that this might very well be the case with this patch. It
would cause false warnings.

>>>
>>>>
>>>>>> URB buffers and let core/hcd.c to do the mapping on architectures that have
>>>>>> minimum DMA alignment requirements. This leads to random memory corruptions
>>>>>> and crashes when using USB device drivers that use unaligned URB buffers.
>>>>>
>>>>> Maybe you should check the dma mapping/unmapping implementation of
>>>>> the arch, non-aligned buffer should have be covered by the API easily.
>>>>>
>>>>> Also USB Host controller should have supported non-aligned DMA buffer.
>>>>
>>>> From what I found, there was some discussion about these issues around 2010:
>>>>  http://lists.infradead.org/pipermail/linux-arm-kernel/2010-August/022983.html
>>>
>>> From the discussion,  people think that HCD should handle the unaligned buffer,
>>> right?
>>
>> Yes, that's how I understood it.
>>
>>>
>>>>
>>>> To me, it seems that non-aligned buffers cannot be easily handled by all archs
>>>> at dma mapping/unmapping phase and that HCD driver should do the alignment on
>>>
>>> If the memory which shares cache line with transfer buffer can't be
>>> accessed during
>>> DMA transfer(between URB submit and complete), dma mapping/unmapping
>>> should have handled it.
>>>
>>> About the network transfer buffer case, I think it should be true,
>>> otherwise there
>>> should have lots of memory corruption reports about usb network drivers.
>>> Fortunately, there are seldom such reports.
>>>
>>
>> Another reason why rtl8192cu is so hard, is that it uses pre-allocated array
>> for buffers of multiple URBs, and more than one transfer buffer can reside on
>> same cache line.
> 
> If so, that should be bug inside rtl8192, and more than one transfer
> buffer shares
> one cache line should be avoided, I understand the buffer isn't from
> network stack,
> don't I?
> 

Buffer is not from network stack, but driver allocated array used for control message.

>>
>>>> archs that set ARCH_DMA_MINALIGN. For example, ehci_tegra does copy unaligned
>>>> transfer buffers to temporary aligned buffers before letting them to USB core.
>>>
>>> Yes, if host controller can't handle this, the HCD has to work around
>>> the problem. Anyway, most of host controllers can deal with the it,
>>> can't they?
>>
>> Can they? Maybe they can handle most cases of unaligned buffers, but not some
>> corner cases, like transfer buffers on same cache line.
> 
> Of course, most of in-tree host controller can handle non-aligned buffer.
> 
> If transfer buffers share one same cache line, it should be bug in driver,
> not fault of host controller.
> 

Ok.

>>
>>>
>>>>
>>>>>
>>>>>>
>>>>>> Instead of fixing host drivers, users end up posting bug reports against
>>>>>> those USB device drivers that use unaligned buffers for URB; such as with
>>>>>> rtl8192cu (http://thread.gmane.org/gmane.linux.kernel.wireless.general/105631).
>>>>>
>>>>> Not only rtl8192cu driver, all USB network device drivers have the problem.
>>>>>
>>>>>>
>>>>>> Patch makes this issue more visible at core level, and hopefully gives hint
>>>>>> for future hcd driver implementors about this problem.
>>>>>
>>>>> So please find the root cause first, and don't add the noise now.
>>>>
>>>> I think the root cause is that host driver is letting pass non-aligned buffers
>>>> to core on archs that have ARCH_DMA_MINALIGN set.
>>>
>>> No, I don't think so, about the problem, the dma alignment requirement should
>>> be from your host controller.
>>>
>>> As I said above, dma mapping/unmapping should be capable of dealing with
>>> the unaligned buffer if no one touches memory which shares cacheline with
>>> URB->transfer_buffer during URB transfer.
>>
>> How can you guarantee that when you allow unaligned URB buffers?
> 
> As far as the network driver is concerned, the network stack should guarantee
> memory shared cacheline with skb->data won't be accessed during transfer.
> 
>>
>> You can have the buffer as part of some larger structure and send out async URB.
> 
> That is bug in the driver, and not the situation I mentioned.
> 
> I mean if the non-aligned buffer is skb->data, it should be OK. But if
> the buffer is allocated inside driver itself and not skb buffer, it is better
> to keep aligned since driver can do it.
> 
>> Then while buffer is DMA mapped and send async to hw, you use other parts of
>> that structure even if it shares cacheline with the buffer. You might issue
>> multiple URBs with transfer buffers within same cacheline. I would expect that
>> to be acceptable or URB documentation should say something against such.
>>
>>>
>>> Looks you need to know why the memory corruption happens. Is it caused
>>> by non-aligned arch mapping/unmapping? or by host controller hardware when
>>> dealing with non-aligned transfer buffer?
>>>
>>>> The warning given just before such unaligned buffer is passed to dma_map_single,
>>>> which requires ARCH_DMA_MINALIGN alignment. This seems reasonable to me.
>>>
>>> ARCH_DMA_MINALIGN means that kmalloc() should return aligned dma buffer.
>>>
>>> Again, you have to accept the fact in which transfer buffer from
>>> network stack is
>>> non-aligned.
>>>
>>
>> Yes, that is the message I'm trying to make visible so that host drivers,
>> that don't handle such, get fixed.
> 
> Please only print the warning on the host controller which can't deal with
> non-aligned buffer.

If non-aligned buffers work even if arch has ARCH_DMA_MINALIGN, then the patch
would give false warnings.

> 
>> Hm.. rethink this a bit.
>>
>> Transfer buffer might be dma aligned but shorter than cacheline and end of cacheline
>> used as something else. Manual alignment by host driver does not catch that
>> or fix that.
>> So, yes.. dma mapping should work with unaligned buffers, but maybe the actual
>> problem is multiple buffers from same cacheline.
> 
> That is bug in driver.

I'll have to look at the device driver more closely. Thanks.

-Jussi

> 
> 
> Thanks,
> 
