From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [RFC PATCH] usb: hcd: warn about URB buffers that are not DMA
 aligned and are about to be DMA mapped
Date: Sat, 15 Jun 2013 13:19:10 +0300
Message-ID: <51BC3F9E.3010605@iki.fi>
References: <20130614133803.25747.98705.stgit@localhost6.localdomain6> <CACVXFVM4TsS-_qK_w01oajV1XcA_+OF8xdTX2xjjxOTFNAo6Sw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Network Development <netdev@vger.kernel.org>
To: Ming Lei <tom.leiming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sinikuusama.dnainternet.net ([83.102.40.134]:45043 "EHLO
	sinikuusama.dnainternet.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753857Ab3FOKTR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Jun 2013 06:19:17 -0400
In-Reply-To: <CACVXFVM4TsS-_qK_w01oajV1XcA_+OF8xdTX2xjjxOTFNAo6Sw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 15.06.2013 10:41, Ming Lei wrote:
> Cc: netdev
> 
> On Fri, Jun 14, 2013 at 9:38 PM, Jussi Kivilinna <jussi.kivilinna@iki.fi> wrote:
>> Appearently some out-of-tree USB host drivers do not handle DMA alignment for
> 
> Looks these host drivers have to face the fact that the transfer buffer is often
> DMA non-aligned from network device drivers(in fact, the buffer is from
> network protocol stack), if you run usbnet, then you will get the added warning
> immediately.
> 

Yes, getting warning immediately, but once, and blaming host driver seems ok.

>> URB buffers and let core/hcd.c to do the mapping on architectures that have
>> minimum DMA alignment requirements. This leads to random memory corruptions
>> and crashes when using USB device drivers that use unaligned URB buffers.
> 
> Maybe you should check the dma mapping/unmapping implementation of
> the arch, non-aligned buffer should have be covered by the API easily.
> 
> Also USB Host controller should have supported non-aligned DMA buffer.

>From what I found, there was some discussion about these issues around 2010:
 http://lists.infradead.org/pipermail/linux-arm-kernel/2010-August/022983.html

To me, it seems that non-aligned buffers cannot be easily handled by all archs
at dma mapping/unmapping phase and that HCD driver should do the alignment on
archs that set ARCH_DMA_MINALIGN. For example, ehci_tegra does copy unaligned
transfer buffers to temporary aligned buffers before letting them to USB core.

> 
>>
>> Instead of fixing host drivers, users end up posting bug reports against
>> those USB device drivers that use unaligned buffers for URB; such as with
>> rtl8192cu (http://thread.gmane.org/gmane.linux.kernel.wireless.general/105631).
> 
> Not only rtl8192cu driver, all USB network device drivers have the problem.
> 
>>
>> Patch makes this issue more visible at core level, and hopefully gives hint
>> for future hcd driver implementors about this problem.
> 
> So please find the root cause first, and don't add the noise now.

I think the root cause is that host driver is letting pass non-aligned buffers
to core on archs that have ARCH_DMA_MINALIGN set.

The warning given just before such unaligned buffer is passed to dma_map_single,
which requires ARCH_DMA_MINALIGN alignment. This seems reasonable to me.

-Jussi

> 
> 
> Thanks,
> 
