From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 14:57:50 -0400
Message-ID: <CAF=yD-+MCLAoP5=orUyG0tQjXykde++QrOdE7v44srR54yP32Q@mail.gmail.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com> <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
 <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com> <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f45.google.com ([209.85.218.45]:48909 "EHLO
        mail-oi0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752434AbdJKS6c (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 14:58:32 -0400
Received: by mail-oi0-f45.google.com with SMTP id m198so4707668oig.5
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 11:58:31 -0700 (PDT)
In-Reply-To: <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 2:39 PM, Anton Ivanov
<anton.ivanov@kot-begemot.co.uk> wrote:
> The check as now insists that the actual driver supports GSO_ROBUST, because
> we have marked the skb dodgy.
>
> The specific bit which does this check is in net_gso_ok()
>
> Now, lets's see how many Ethernet drivers set GSO_ROBUST.
>
> find drivers/net/ethernet -type f -name "*.[c,h]" -exec grep -H GSO_ROBUST
> {} \;
>
> That returns nothing in 4.x
>
> IMHO - af_packet allocates the skb, does all checks (and extra may be added)
> on the gso, why is this set dodgy in the first place?

It is set when the header has to be validated.

The segmentation logic will validate and fixup gso_segs. See for
instance tcp_gso_segment:

        if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
                /* Packet is from an untrusted source, reset gso_segs. */

                skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);

                segs = NULL;
                goto out;
        }

If the device would have the robust bit set and otherwise supports the
required features, fix up gso_segs and pass the large packet to the
device.

Else it continues to the software gso path.

Large packets generated with psock_txring_vnet.c pass this test. I
suspect that there is a subtle difference in the virtio_net_hdr fields
that that generates vs. your program.
