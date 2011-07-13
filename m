From: chetan loke <loke.chetan@gmail.com>
Subject: Re: [PATCH net-next 1/1] af-packet: fix - avoid reading stale data
Date: Tue, 12 Jul 2011 22:19:10 -0400
Message-ID: <CAAsGZS4NReArr1z5pyYX+A4Oxto0_++158w=q-Mfpt94OeVxpg@mail.gmail.com>
References: <1310521339-1115-1-git-send-email-loke.chetan@gmail.com>
	<1310522190.2634.8.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org, lokechetan@gmail.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:52223 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756992Ab1GMCTL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 22:19:11 -0400
Received: by pzk9 with SMTP id 9so4402196pzk.19
        for <netdev@vger.kernel.org>; Tue, 12 Jul 2011 19:19:10 -0700 (PDT)
In-Reply-To: <1310522190.2634.8.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 12, 2011 at 9:56 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le mardi 12 juillet 2011 =C3=A0 21:42 -0400, Chetan Loke a =C3=A9crit=
 :
>> Currently we flush tp_status and then flush the remainder of the hea=
der+payload.
>> tp_status should be flushed in the end to avoid stale data being rea=
d by user-space.
>>
>>
>> Signed-off-by: Chetan Loke <loke.chetan@gmail.com>
>> ---
>> =C2=A0net/packet/af_packet.c | =C2=A0 =C2=A04 ++--
>> =C2=A01 files changed, 2 insertions(+), 2 deletions(-)
>>
>> diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
>> index d2294ad..f7be71f 100644
>> --- a/net/packet/af_packet.c
>> +++ b/net/packet/af_packet.c
>> @@ -1129,8 +1129,6 @@ static int tpacket_rcv(struct sk_buff *skb, st=
ruct net_device *dev,
>> =C2=A0 =C2=A0 =C2=A0 else
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 sll->sll_ifindex =3D=
 dev->ifindex;
>>
>> - =C2=A0 =C2=A0 __packet_set_status(po, h.raw, status);
>> - =C2=A0 =C2=A0 smp_mb();
>> =C2=A0#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE =3D=3D 1
>> =C2=A0 =C2=A0 =C2=A0 {
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 u8 *start, *end;
>> @@ -1140,6 +1138,8 @@ static int tpacket_rcv(struct sk_buff *skb, st=
ruct net_device *dev,
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 flush_dcache_page(pgv_to_page(start));
>> =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0#endif
>> + =C2=A0 =C2=A0 smp_mb();
>> + =C2=A0 =C2=A0 __packet_set_status(po, h.raw, status);
>>
>> =C2=A0 =C2=A0 =C2=A0 sk->sk_data_ready(sk, 0);
>>
>
> Are you sure we can perform the flush_dcache_page() before smp_mb() ?
>
> I believe we should do one smp_wmb() before __packet_set_status() as
> well.

Eric - something like this?

#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE =3D=3D 1
          smp_wmb();
#endif
__packet_set_status(po, h.raw, status);


Chetan Loke
