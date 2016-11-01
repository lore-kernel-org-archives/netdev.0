From: Felipe Balbi <felipe.balbi@linux.intel.com>
Subject: Re: [PATCH] Revert "usb: dwc3: gadget: use allocated/queued reqs for LST bit"
Date: Tue, 01 Nov 2016 13:30:59 +0200
Message-ID: <87ins7phcc.fsf@linux.intel.com>
References: <20161027154016.GD4617@intel.com> <87pomksrrm.fsf@linux.intel.com> <20161028163332.GL4617@intel.com> <20161031.145150.1409050078488736200.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: linux-usb@vger.kernel.org, stable@vger.kernel.org,
        oneukum@suse.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ville.syrjala@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([134.134.136.100]:26290 "EHLO mga07.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1168914AbcKALbW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 1 Nov 2016 07:31:22 -0400
In-Reply-To: <20161031.145150.1409050078488736200.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--=-=-=
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable


Hi,

David Miller <davem@davemloft.net> writes:
> From: Ville Syrj=C3=A4l=C3=A4 <ville.syrjala@linux.intel.com>
> Date: Fri, 28 Oct 2016 19:33:32 +0300
>
>> On Fri, Oct 28, 2016 at 01:16:13PM +0300, Felipe Balbi wrote:
>>> Yeah, I'm guessing we're gonna need some help from networking folks. The
>>> only thing we did since v4.7 was actually respect req->no_interrupt flag
>>> coming from u_ether itself. No idea why that causes so much trouble for
>>> u_ether.
>>>=20
>>> BTW, Instead of reverting so many patches, you can just remove
>>> throttling:
>>>=20
>>> diff --git a/drivers/usb/gadget/function/u_ether.c b/drivers/usb/gadget=
/function/u_ether.c
>>> index f4a640216913..119a2e5848e8 100644
>>> --- a/drivers/usb/gadget/function/u_ether.c
>>> +++ b/drivers/usb/gadget/function/u_ether.c
>>> @@ -589,14 +589,6 @@ static netdev_tx_t eth_start_xmit(struct sk_buff *=
skb,
>>>=20=20
>>>         req->length =3D length;
>>>=20=20
>>> -       /* throttle high/super speed IRQ rate back slightly */
>>> -       if (gadget_is_dualspeed(dev->gadget))
>>> -               req->no_interrupt =3D (((dev->gadget->speed =3D=3D USB_=
SPEED_HIGH ||
>>> -                                      dev->gadget->speed =3D=3D USB_SP=
EED_SUPER)) &&
>>> -                                       !list_empty(&dev->tx_reqs))
>>> -                       ? ((atomic_read(&dev->tx_qlen) % dev->qmult) !=
=3D 0)
>>> -                       : 0;
>>> -
>>>         retval =3D usb_ep_queue(in, req, GFP_ATOMIC);
>>>         switch (retval) {
>>>         default:
>>=20
>> Ah cool. That indeed fixes the problem for me.
>>=20
>>>=20
>>> I'm adding netdev and couple other folks to the loop.
>>>=20
>>> Just to summarize, USB peripheral controller now actually throttles
>>> interrupt when requested to do so and that causes lags for USB
>>> networking gadgets.
>>>=20
>>> Without throttle we, potentially, call netif_wake_queue() more
>>> frequently than with throttling. I'm wondering if something changed in
>>> NET layer within the past few years but the USB networking gadgets ended
>>> up being forgotten.
>>>=20
>>> Anyway, if anybody has any hints, I'd be glad to hear about them.
>
> This throttling mechanism seems to have the same problem we've seen in
> The past with some ethernet drivers trying to do TX mitigation in
> software.
>
> If I understand correctly, the interrupt bit for TX completions is set
> only periodically.
>
> However, the networking stack has a hard requirement that all SKBs
> which are transmitted must have their completion signalled in a finite
> amount of time.  This is because, until the SKB is freed by the
> driver, it holds onto socket, netfilter, and other subsystem
> resources.
>
> So, for example, if your scheme is that only every 8th TX packet will
> generate an interrupt you run into problems if you suddenly have 7
> pending TX packets and no more traffic is generated for a long time.
>
> Those 7 packets will sit in the TX queue indefinitely, and this is the
> situation which drivers must avoid.
>
> Therefore, for devices with per-TX-queue-entry interrupt bit schemes,
> it's not easy to take advantage of this facility.  The safest thing to
> do is to interrupt for every queue entry.
>
> For the time being, this revert is the way to go and it should be
> submitted formally, with proper commit message and signoffs, via
> whatever tree this gadget driver's changes should be submitted via.
>
> It might be possible to elide TX queue entry interrupts using the
> skb->xmit_more state.  Basically, if the TX queue is not full and
> skb->xmit_more is set, you can skip the interrupt indication bit
> in the descriptor.

thanks for confirming, patch removing throttling sent. You're in Cc.

=2D-=20
balbi

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIcBAEBCAAGBQJYGHzzAAoJEMy+uJnhGpkGKjsP/iTJWMOjYzZ0dccEYuI8Nxya
Ur1gZiY5dKRwIsNZqZkk/9wT7QlolIo5DrwOw6N9Zwo4dk1nIcCMkQZCt5bumwrA
DSrhlZdVetAJZCvqlVcdSNCrnbUaav1djWEo60Zl9f319/gWgXkIjLuT9BWhd/vl
jCB8y4eBSANSnyiwoycwTRBQ+w4+YKNpAo7OJKMhZRDN2Wr+5BQoeKLfbyyOwCb/
DJge5f4ZTxlrhJro9B4lu9c7oetBPU9+so2ZaRQzw5FZNnsJ5Lym1KEz1LySb+mn
qHMpHHXMxg9CGmPSrtu2inxwTaCVYpXTCY8+N4VSZpLrnFR97ZCZ2QW+PFPxQSR1
ggqLYouz3Ln8j1DNl3tyCJ1Y3nr6aaShLsat8Sn31hQ6Gz6rmKqM7i7Kf/t7da48
/AMfKbKeUegbeE5UpqKEOfgeCr8lHrbaWbWATpBZfjOFeF1q7U1sgq1qO/iDfy8T
JY2imgK170HKkAPfUiw0/W2Ny70cMcJ7+2HZssj+gro7bdEttT/+W5Q15IlNoJBq
/5fVTrdRF1zww53kEM+HxED4HYxIg/hqXblIA4YGUk5d2HUsjal5r4l6jFSiPPO1
y3k7pR7wxmJNEb5f0NrftKN60qQogEOG55Eqptj/yYzVa46zaaQ/vRcYKwh26YKr
LjXv+Ot7VGhOQVFqYNCV
=S5J3
-----END PGP SIGNATURE-----
--=-=-=--
