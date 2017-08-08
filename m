From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [PATCH net v2] net/mlx4_en: don't set CHECKSUM_COMPLETE on SCTP packets
Date: Tue, 8 Aug 2017 19:14:38 +0300
Message-ID: <CALzJLG8Q8MTn4OuspLwT4iCF-c68d0WJFJdORjBVbvarwyHWZA@mail.gmail.com>
References: <23ac3e005a8dc1a373971f1166fe6ba72d8abe4b.1501793448.git.dcaratti@redhat.com>
 <CALzJLG-1RLsw68QXbK=wMUYR9KpkcQx6LqQy_b96miTw5mjy4A@mail.gmail.com> <1502208390.2701.2.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Tariq Toukan <tariqt@mellanox.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>
To: Davide Caratti <dcaratti@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f47.google.com ([209.85.213.47]:35421 "EHLO
        mail-vk0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752138AbdHHQPA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 8 Aug 2017 12:15:00 -0400
Received: by mail-vk0-f47.google.com with SMTP id d124so15444498vkf.2
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 09:14:59 -0700 (PDT)
In-Reply-To: <1502208390.2701.2.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 7:06 PM, Davide Caratti <dcaratti@redhat.com> wrote:
> On Tue, 2017-08-08 at 18:07 +0300, Saeed Mahameed wrote:
>> >   {
>> >          __u16 length_for_csum = 0;
>> >          __wsum csum_pseudo_header = 0;
>> > +       __u8 ipproto = iph->protocol;
>> > +
>> > +       if (unlikely(ipproto == IPPROTO_SCTP))
>> > +               return -1;
>> >
>>
>> Hi Davide
>>
>
> hi Saeed,
>
> thank you for looking at this!
>
>> If you got to here then it means this is a non UDP/TCP ipv4 packet and
>> the HW failed to validate it's checksum but
>> you get from the connectx3 HW a 1's complement 16-bit sum of IP
>> Payload + IP pseudo-header.
>> so if you return -1 here the driver will report checksum none for this
>> packet (and you will abandon any checsum offload/help from HW).
>>
>> I am not an SCTP expert but it seems that you decided here that
>> connectX3 hw checksum (described above) can't be used to calculate
>> SCTP packet checksum
>> is that correct?
>>
> Yes, that's correct. SCTP uses CRC32c, not 1's complement (and does not use
> pseudo-headers): therefore, the checksum computed by the NIC hardware can't
> be used.
>
> The issue I observed is skb->ip_summed set to CHECKSUM_COMPLETE, that made
> CRC32c validation fail in my setup (that was a netfilter REJECT rule, matching
> SCTP packets). AFAIK, CHECKSUM_COMPLETE is valid only for the Internet Checksum;
> setting CHECKSUM_NONE on rx packets carrying IPPROTO_SCTP fixed my test scenario.
>
>> If so, then i am ok with this patch.
>
> I planned to post this some weeks ago, after agreeing v2 with Tariq
> (https://www.spinics.net/lists/netdev/msg441231.html), but took some time to
> find a ConnectX-3 (from what I saw the issue is not present on ConnectX-3 Pro,
> since it has MLX4_RX_CSUM_MODE_VAL_NON_TCP_UDP bit set to 0).
>

Thanks for the clarification, I will ack the patch.

> regards,
> --
> davide
>
