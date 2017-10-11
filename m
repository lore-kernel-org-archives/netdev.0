From: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 20:39:57 +0100
Message-ID: <d6c1cda2-f7df-9132-304d-075c62d4d83d@kot-begemot.co.uk>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com>
 <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
 <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
 <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk>
 <CAF=yD-+MCLAoP5=orUyG0tQjXykde++QrOdE7v44srR54yP32Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ivanoab5.miniserver.com ([78.31.111.25]:36650 "EHLO
        www.kot-begemot.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752236AbdJKTkL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 15:40:11 -0400
In-Reply-To: <CAF=yD-+MCLAoP5=orUyG0tQjXykde++QrOdE7v44srR54yP32Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/17 19:57, Willem de Bruijn wrote:
> On Wed, Oct 11, 2017 at 2:39 PM, Anton Ivanov
> <anton.ivanov@kot-begemot.co.uk> wrote:
>> The check as now insists that the actual driver supports GSO_ROBUST, because
>> we have marked the skb dodgy.
>>
>> The specific bit which does this check is in net_gso_ok()
>>
>> Now, lets's see how many Ethernet drivers set GSO_ROBUST.
>>
>> find drivers/net/ethernet -type f -name "*.[c,h]" -exec grep -H GSO_ROBUST
>> {} \;
>>
>> That returns nothing in 4.x
>>
>> IMHO - af_packet allocates the skb, does all checks (and extra may be added)
>> on the gso, why is this set dodgy in the first place?
> It is set when the header has to be validated.
>
> The segmentation logic will validate and fixup gso_segs. See for
> instance tcp_gso_segment:
>
>         if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
>                 /* Packet is from an untrusted source, reset gso_segs. */
>
>                 skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>
>                 segs = NULL;
>                 goto out;
>         }
>
> If the device would have the robust bit set and otherwise supports the
> required features, fix up gso_segs and pass the large packet to the
> device.
>
> Else it continues to the software gso path.
>
> Large packets generated with psock_txring_vnet.c pass this test. I

That test is indeed a different path - this goes via the tpacket_snd
which allocs via sock_alloc_send_skb. That results in a non-fragged skb
as it calls pskb after that with data_len = 0 asking for a contiguous one.

My stuff is using sendmmsg which ends up via packet_snd which allocs
via  sock_alloc_send_pskb which is invoked in a way which always creates
2 segments - one for the linear section and one for the rest (and more
if needed). It is faster than tpacket by the way (several times).

As a comparison tap and other virtual drivers use sock_alloc_send_pskb
with non-zero data length which results in multiple frags. The code in
packet_snd is in fact identical with tap (+/- some cosmetic differences).

That is the difference between the tests and that is why your test works
and mine fails.

Now, alloc-ing a 64k contiguous skb every time IMHO is wrong.

So the logic in the xmit check at present works only because it is given
only a very corner case for a GSO frame and tested versus it. It should
work with the generic case which is what comes out of
sock_alloc_send_pskb (same as in tap).

A.



> suspect that there is a subtle difference in the virtio_net_hdr fields
> that that generates vs. your program.
>
