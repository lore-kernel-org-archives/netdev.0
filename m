From: Ming Lei <ming.lei@canonical.com>
Subject: Re: usbnet transmit path problems
Date: Thu, 12 Sep 2013 09:56:53 +0800
Message-ID: <CACVXFVNrbeEthBH0vGKN2gymoSwu3jTkcGicKNU1-Oez8bNhvg@mail.gmail.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B7325@saturn3.aculab.com>
	<1378894312.28160.15.camel@linux-fkkt.site>
	<20130911193430.0825ac95@tom-ThinkPad-T410>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7326@saturn3.aculab.com>
	<CACVXFVN6ZHLesrsMVNMWrikRs1mMbk=aZD9qZybNn1gB7aFTZQ@mail.gmail.com>
	<AE90C24D6B3A694183C094C60CF0A2F6026B7329@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Oliver Neukum <oliver@neukum.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from youngberry.canonical.com ([91.189.89.112]:43672 "EHLO
	youngberry.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab3ILB44 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 21:56:56 -0400
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B7329@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 12, 2013 at 12:05 AM, David Laight <David.Laight@aculab.com> wrote:
>> On Wed, Sep 11, 2013 at 8:56 PM, David Laight <David.Laight@aculab.com> wrote:
>> >> > > 2) If 'length % dev->maxpacket == 0' for a multi-fragment packet then
>> >> > >    the extra byte isn't added correctly (the code probably falls off
>> >> > >    the end of the scatter-gather list).
>> >> >
>> >> > Indeed. Ming Lei, should usbnet handle this in the sg case or better
>> >> > leave it to the subdriver you introduced this for?
>> >
>> > Is the ZLP issue a problem with the host or with the target?
>>
>> Sorry, what do you mean the ZLP issue here? I understand Oliver
>> thinks one commit from me may break ZLP handling, are you discussing
>> this problem? If not, could you explain it in a bit detail?
>
> I was thinking of the general ZLP problem.

IMO the current approach should be general enough.

>
>> > If it is a host problem then the necessity comes from the host,
>> > but the fix needs to be target dependant.
>> > If it is a common target problem then generic code can apply
>> > a common fix.
>>
>> All usbnet device should have sent one ZLP in case the size of
>> bulk out transfer can be divided by max packet size, but the one
>> byte transfer might be introduced for avoiding some target problem
>> (can't deal with zlp well), as said by David, see below discussion:
>>
>>    http://marc.info/?l=linux-usb&m=127067487604112&w=2
>
> AFAICT the code avoids sending a zero length packet (that would
> terminate a USB bulk transfer packet) by increasing the length
> of the bulk packet by (at least) one byte.

No, the code on the link supports URB_ZERO_PACKET which
should be the decent approach for the problem.

>
>> > AFICT there are at least 3 fixes:
>> > 1) Extend the ethernet frame by one byte and hope the receiving
>> >    system doesn't object to the padding.

This is what usbnet is doing at default if both FLAG_SEND_ZLP and
FLAG_MULTI_PACKET aren't set.

>> >    This is probably the only option if tx_fixup() doesn't
>> >    add a header.
>> > 2) Put the ethernet frame length in the header and have the
>> >    target discard the added pad byte (ax88179_178a.c).

That is probably because the target need the padding flag, so that
it can skip the one byte padding frame.

>> > 3) Add a second zero-length frame in the same USB data block
>> >    (ax88172a.c).

Actually it is a 4byte frame added by the subdriver, instead of adding
one zlp.  Since the subdriver adds the termination packet by itself, usbnet
won't handle the case at all.

There is no much difference among the 3 appoaches, all of which take
the padding trick, and the difference is that if padding flag is required, and
if the padding length is one byte or others, and both are device-dependent.

So current approach is still general enough to cover all cases, isn't it?

>>
>> Why do we need the above 3 fixes? The patch in my last email can
>> fix the problem which is introduced recently, can't it?
>
> I meant there are 3 ways of avoiding the ZLP, each driver will
> pick one of them.

All the 3 ways are basically same or very similar, and the difference is
that drivers may need the padding flag or take different length termination
packet.

>
> I've just looked at all the drivers in net/usb.
> It doesn't look like they all handle fragmented skb, shared skb,
> or ZLP properly.
>
> A lot of common code could be removed if usbnet knew the size of the
> header and allocated it before calling tx_fixup().

Patches are always welcome, :-)

> None of this is helping me sort out why netperf udp rr tests with
> burst 19 are losing all the packets at once :-(

If you can share your test case, guys in list may help you to troubleshoot
it, :-)


Thanks,
--
Ming Lei
