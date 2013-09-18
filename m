From: Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: Re: [PATCH] USBNET: fix handling padding packet
Date: Thu, 19 Sep 2013 01:03:31 +0800
Message-ID: <CACVXFVNp5Qj-EV+L=FezwFqRnFa7uRFca7Ju9=iTqU+DS1r-fg@mail.gmail.com>
References: <1379409002-7698-1-git-send-email-ming.lei@canonical.com>
	<878uyu6xjm.fsf@nemi.mork.no>
	<CACVXFVNzTGbCV2wQ4RwxXK1q7+eD2KkOS_G3NvL4uAzdd21SUg@mail.gmail.com>
	<87zjra5dpx.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-usb <linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87zjra5dpx.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 18, 2013 at 11:52 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> Ming Lei <ming.lei-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org> writes:
>
>>> Are you really sure that the one driver/device using this really ne=
ed
>>> the padding byte?  If you could just make FLAG_SEND_ZLP part of the
>>> condition for enabling can_dma_sg, then all this extra complexity w=
ould
>>> be unnecessary.  As the comment in front of the padding code says:
>>
>> At least for the effected driver of ax88179, the padding packet is n=
eeded
>> since the driver does set the padding flag in the header, see
>> ax88179_tx_fixup().
>
> Yes, I noticed that the driver doesn't set the flag. I just didn't pu=
t
> too much into that.  I don't think that necessarily means that the
> padding is needed. It probably just means that the driver worked with
> the default padding enabled, so the author left it there.
>
> This flag should really have been inverted.  ZLP should be the defaul=
t
> for all new usbnet drivers.

In theory, it is, but who knows the reality.

>
> Why don't you test it on the device you tested the SG patch with?  I =
am
> pretty sure it works just fine using proper ZLP transfer termination.

I should have planned to test it, but didn't know how to build TCP TSO
to make the whole frame length plus 8 dividable by 1024.

Could you or other guys share how to build such packet so that I can
do the test?

Once we can confirm the padding isn't needed, we can remove the
padding flag. But if the padding flag is still there, this patch should=
 be
dropped.

>
>>>   "strictly conforming cdc-ether devices should expect the ZLP here=
"
>>>
>>> There shouldn't be any problems requiring this conformance as a
>>> precondition for allowing SG.  The requirements are already strict.
>>
>> There is no reason to forbid DMA SG for one driver which requires
>> padding, right?
>
> Yes there is: Added complexity for everybody, based on a combination =
of
> features which just does not make any sense.
>
> No modern device should need the padding.  No old device will be able=
 to
> use the SG feature as implemented. You only enable it on USB3, don't
> you? If this feature is restricted to USB3 capable devices, then it m=
ost
> certainly can be restricted to ZLP capable devices with absolutely no
> difference in the resulting set of supported devices.

See above, if we can prove that padding isn't needed, we can remove
the padding, then the patch can be dropped. If we can't, the patch is n=
eeded.

>
> Anyway, if you want to keep the padding for SG then maybe this will w=
ork
> and allow you to drop the extra struct usbnet field and allocation:
>
>                         if (skb_tailroom(skb) && !dev->can_dma_sg) {
>                                skb->data[skb->len] =3D 0;
>                                __skb_put(skb, 1);
>                         } else if (dev->can_dma_sg) {
>                               sg_set_buf(&urb->sg[urb->num_sgs++], sk=
b->data, 1);
>                         }
>
> I.e. cheat and use the skb->data buffer twice, if that is allowed?  T=
he
> actual value of the padding byte should not matter, I believe?

If so, we can remove the assignment of zero to skb->data[skb->len],
but probably it might cause regression, that is why I wouldn't like to
do that.  Also looks introducing one extra dev->padding_frame doesn't
cause much complexity.

Thanks
--
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
