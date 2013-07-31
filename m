From: Ming Lei <ming.lei@canonical.com>
Subject: Re: [PATCH 4/4] USBNET: ax88179_178a: enable tso if host supports sg dma
Date: Wed, 31 Jul 2013 21:50:54 +0800
Message-ID: <CACVXFVNk+h7kBWTFT2NiGy+2F6LPatda3oL9+uuaQnT-u5J8wg@mail.gmail.com>
References: <1375267909-30373-1-git-send-email-ming.lei@canonical.com>
	<1375267909-30373-5-git-send-email-ming.lei@canonical.com>
	<20130731124707.GA30635@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>,
	Oliver Neukum <oneukum@suse.de>,
	Freddy Xin <freddy@asix.com.tw>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Grant Grundler <grundler@google.com>, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:33814 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752226Ab3GaNu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Jul 2013 09:50:57 -0400
In-Reply-To: <20130731124707.GA30635@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 31, 2013 at 8:47 PM, Greg Kroah-Hartman
<gregkh@linuxfoundation.org> wrote:
> On Wed, Jul 31, 2013 at 06:51:49PM +0800, Ming Lei wrote:
>> This patch enables 'can_dma_sg' flag for ax88179_178a device
>> if the attached host controller supports building packet from
>> discontinuous buffers(DMA SG is possible), so both frame header
>> and skb data buffers can be passed to usb stack via urb->sg,
>> then skb data copy can be saved.
>>
>> With the patch, CPU utilization decreased much in iperf test at
>> client mode.
>
> What is "much"?

The data is platform dependent, on one dual-core ARM A15 board
at my hand, ~30~40% CPU utilization is saved with the patchset
when doing 'iperf -c' test on this board.

>
>> --- a/drivers/net/usb/ax88179_178a.c
>> +++ b/drivers/net/usb/ax88179_178a.c
>> @@ -1031,12 +1031,20 @@ static int ax88179_bind(struct usbnet *dev, struct usb_interface *intf)
>>       dev->mii.phy_id = 0x03;
>>       dev->mii.supports_gmii = 1;
>>
>> +     if (dev->udev->bus->no_sg_limit)
>> +             dev->can_dma_sg = 1;
>
> I don't feel comfortable with USB drivers poking about in the USB host
> controller structures like this.  If we really do this, please provide a
> function call for it to make to determine this.

OK, that is fine.

>
> But even then, is this really something that we want/need to do at all?
> If only some xhci controller support this, we will start to see more

It should be all xhci controllers support this, per xHCI spec.

> driver-specific changes just to handle one type of host controller.  Why

We already have this kind of changes, such as usbfs and mass storage
driver, the two drivers support both sg list and non-sg list cases(depends
on HCD).

> not have the USB core handle it instead and if the host controller can
> not do sg lists like this, fall back to a slower implementation?

In the usbnet case, the driver already supports non-sg well. Actually,
all current drivers should support non-sg well because urb->sg wasn't
introduced for very long time. We can think it as a new feature or DMA
enhancement for xHCI controller.

If you mean buffer debounce for dma sg support on ehci/uhci/ohci/..,
maybe we need to discuss and evaluate further.

Thanks,
--
Ming Lei
