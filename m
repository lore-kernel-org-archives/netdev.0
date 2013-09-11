From: Ming Lei <ming.lei@canonical.com>
Subject: Re: usbnet transmit path problems
Date: Wed, 11 Sep 2013 23:11:57 +0800
Message-ID: <CACVXFVN6ZHLesrsMVNMWrikRs1mMbk=aZD9qZybNn1gB7aFTZQ@mail.gmail.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7325@saturn3.aculab.com>
	<1378894312.28160.15.camel@linux-fkkt.site>
	<20130911193430.0825ac95@tom-ThinkPad-T410>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7326@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oliver@neukum.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:40898 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754052Ab3IKPMA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 11:12:00 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7326@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 11, 2013 at 8:56 PM, David Laight <David.Laight@aculab.com> wrote:
>> > > 2) If 'length % dev->maxpacket == 0' for a multi-fragment packet then
>> > >    the extra byte isn't added correctly (the code probably falls off
>> > >    the end of the scatter-gather list).
>> >
>> > Indeed. Ming Lei, should usbnet handle this in the sg case or better
>> > leave it to the subdriver you introduced this for?
>
> Is the ZLP issue a problem with the host or with the target?

Sorry, what do you mean the ZLP issue here? I understand Oliver
thinks one commit from me may break ZLP handling, are you discussing
this problem? If not, could you explain it in a bit detail?

> If it is a host problem then the necessity comes from the host,
> but the fix needs to be target dependant.
> If it is a common target problem then generic code can apply
> a common fix.

All usbnet device should have sent one ZLP in case the size of
bulk out transfer can be divided by max packet size, but the one
byte transfer might be introduced for avoiding some target problem
(can't deal with zlp well), as said by David, see below discussion:

   http://marc.info/?l=linux-usb&m=127067487604112&w=2

>
> AFICT there are at least 3 fixes:
> 1) Extend the ethernet frame by one byte and hope the receiving
>    system doesn't object to the padding.
>    This is probably the only option if tx_fixup() doesn't
>    add a header.
> 2) Put the ethernet frame length in the header and have the
>    target discard the added pad byte (ax88179_178a.c).
> 3) Add a second zero-length frame in the same USB data block
>    (ax88172a.c).

Why do we need the above 3 fixes? The patch in my last email can
fix the problem which is introduced recently, can't it?

>
> Only the third requires that tx_fixup() append to the packet.
> For the other two actual pad can be added by usbnet.
>
>> IMO, it should be handled by usbnet, could you comment on below patch?
>
> Seems excessive to kmalloc() one byte!

It isn't strange, many usb drivers have to do that(maybe kmalloc
two or three, or four bytes) since the buffer is involved into DMA.

> If you can't assume that the 'dev' structure itself can be dma'd from
> allocate the extra byte in the sg list.

It is better to always obey rule of DMA-API, so don't do that since
one extra kmalloc() per device is needed, even though we can allocate
only one global buffer for this purpose.


Thanks,
--
Ming Lei
