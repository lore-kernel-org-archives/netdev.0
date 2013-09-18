From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Wed, 18 Sep 2013 17:52:42 +0200
Message-ID: <87zjra5dpx.fsf@nemi.mork.no>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com>
	<878uyu6xjm.fsf@nemi.mork.no>
	<CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Oliver Neukum <oneukum@suse.de>,
	Network Development <netdev@vger.kernel.org>,
	linux-usb <linux-usb@vger.kernel.org>,
	Oliver Neukum <oliver@neukum.org>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:56604 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751218Ab3IRPwv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Sep 2013 11:52:51 -0400
In-Reply-To: <CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com>
	(Ming Lei's message of "Wed, 18 Sep 2013 23:09:26 +0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ming Lei <ming.lei@canonical.com> writes:

>> Are you really sure that the one driver/device using this really nee=
d
>> the padding byte?  If you could just make FLAG_SEND_ZLP part of the
>> condition for enabling can_dma_sg, then all this extra complexity wo=
uld
>> be unnecessary.  As the comment in front of the padding code says:
>
> At least for the effected driver of ax88179, the padding packet is ne=
eded
> since the driver does set the padding flag in the header, see
> ax88179_tx_fixup().

Yes, I noticed that the driver doesn't set the flag. I just didn't put
too much into that.  I don't think that necessarily means that the
padding is needed. It probably just means that the driver worked with
the default padding enabled, so the author left it there.

This flag should really have been inverted.  ZLP should be the default
for all new usbnet drivers.

Why don't you test it on the device you tested the SG patch with?  I am
pretty sure it works just fine using proper ZLP transfer termination.

>>   "strictly conforming cdc-ether devices should expect the ZLP here"
>>
>> There shouldn't be any problems requiring this conformance as a
>> precondition for allowing SG.  The requirements are already strict.
>
> There is no reason to forbid DMA SG for one driver which requires
> padding, right?

Yes there is: Added complexity for everybody, based on a combination of
features which just does not make any sense.

No modern device should need the padding.  No old device will be able t=
o
use the SG feature as implemented. You only enable it on USB3, don't
you? If this feature is restricted to USB3 capable devices, then it mos=
t
certainly can be restricted to ZLP capable devices with absolutely no
difference in the resulting set of supported devices.

Anyway, if you want to keep the padding for SG then maybe this will wor=
k
and allow you to drop the extra struct usbnet field and allocation:

                        if (skb_tailroom(skb) && !dev->can_dma_sg) {
                               skb->data[skb->len] =3D 0;
                               __skb_put(skb, 1);
                        } else if (dev->can_dma_sg) {
                              sg_set_buf(&urb->sg[urb->num_sgs++], skb-=
>data, 1);
                        }

I.e. cheat and use the skb->data buffer twice, if that is allowed?  The
actual value of the padding byte should not matter, I believe?



Bj=C3=B8rn
