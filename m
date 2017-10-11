From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: BUG:af_packet fails to TX TSO frames
Date: Wed, 11 Oct 2017 17:05:19 -0400
Message-ID: <CAF=yD-+gc5oQ=XT0+yw4Wt_h3rObETti3FvXm+V-nu=87zaMyA@mail.gmail.com>
References: <c3002d4f-62ff-1d0b-65fb-b366be45a6d8@cambridgegreys.com>
 <CAF=yD-+SxQTHxiU5Yi2f8dm6X1s7SA6PdkbeJP-K_9ZuTMAaTA@mail.gmail.com>
 <f2fe3f46-2ef1-0029-1c44-3576ca19d34b@cambridgegreys.com> <844d6e0f-6ee7-74bc-b961-faa77b240303@cambridgegreys.com>
 <CAF=yD-+JaS8JwEC2TyUG=Ebaho-MM+gjumrbHYM-H0EK1Hu62Q@mail.gmail.com>
 <23ace6d6-afa7-9a3a-aa61-1245ee6c0498@kot-begemot.co.uk> <CAF=yD-+MCLAoP5=orUyG0tQjXykde++QrOdE7v44srR54yP32Q@mail.gmail.com>
 <d6c1cda2-f7df-9132-304d-075c62d4d83d@kot-begemot.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Anton Ivanov <anton.ivanov@cambridgegreys.com>,
        Network Development <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>
To: Anton Ivanov <anton.ivanov@kot-begemot.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f50.google.com ([209.85.218.50]:49512 "EHLO
        mail-oi0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752236AbdJKVGA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 17:06:00 -0400
Received: by mail-oi0-f50.google.com with SMTP id w197so5264766oif.6
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 14:06:00 -0700 (PDT)
In-Reply-To: <d6c1cda2-f7df-9132-304d-075c62d4d83d@kot-begemot.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 11, 2017 at 3:39 PM, Anton Ivanov
<anton.ivanov@kot-begemot.co.uk> wrote:
> On 11/10/17 19:57, Willem de Bruijn wrote:
>> On Wed, Oct 11, 2017 at 2:39 PM, Anton Ivanov
>> <anton.ivanov@kot-begemot.co.uk> wrote:
>>> The check as now insists that the actual driver supports GSO_ROBUST, because
>>> we have marked the skb dodgy.
>>>
>>> The specific bit which does this check is in net_gso_ok()
>>>
>>> Now, lets's see how many Ethernet drivers set GSO_ROBUST.
>>>
>>> find drivers/net/ethernet -type f -name "*.[c,h]" -exec grep -H GSO_ROBUST
>>> {} \;
>>>
>>> That returns nothing in 4.x
>>>
>>> IMHO - af_packet allocates the skb, does all checks (and extra may be added)
>>> on the gso, why is this set dodgy in the first place?
>> It is set when the header has to be validated.
>>
>> The segmentation logic will validate and fixup gso_segs. See for
>> instance tcp_gso_segment:
>>
>>         if (skb_gso_ok(skb, features | NETIF_F_GSO_ROBUST)) {
>>                 /* Packet is from an untrusted source, reset gso_segs. */
>>
>>                 skb_shinfo(skb)->gso_segs = DIV_ROUND_UP(skb->len, mss);
>>
>>                 segs = NULL;
>>                 goto out;
>>         }
>>
>> If the device would have the robust bit set and otherwise supports the
>> required features, fix up gso_segs and pass the large packet to the
>> device.
>>
>> Else it continues to the software gso path.
>>
>> Large packets generated with psock_txring_vnet.c pass this test. I
>
> That test is indeed a different path

The test can be run both with and without ring:

  psock_txring_vnet -l 8000 -s $src_ip -d $dst_ip -v
  psock_txring_vnet -l 8000 -s $src_ip -d $dst_ip -v -N

both with and without qdisc bypass ('-q').

>  - this goes via the tpacket_snd
> which allocs via sock_alloc_send_skb. That results in a non-fragged skb
> as it calls pskb after that with data_len = 0 asking for a contiguous one.

but attached the ring slot as fragments in tpacket_fill_skb.

> My stuff is using sendmmsg which ends up via packet_snd which allocs
> via  sock_alloc_send_pskb which is invoked in a way which always creates
> 2 segments - one for the linear section and one for the rest (and more
> if needed). It is faster than tpacket by the way (several times).
>
> As a comparison tap and other virtual drivers use sock_alloc_send_pskb
> with non-zero data length which results in multiple frags. The code in
> packet_snd is in fact identical with tap (+/- some cosmetic differences).
>
> That is the difference between the tests and that is why your test works
> and mine fails.

All the above test cases work for me, including those that build skbs
with fragments. Could you try those.
