From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH 0/4] skb paged fragment destructors
Date: Fri, 23 Dec 2011 19:10:23 +0100
Message-ID: <CAHXqBFLp3ivefmYjUM87Sj6JT_nv0xjmueCoHqUyq_aGXmjo_A@mail.gmail.com>
References: <CAHXqBF+U8g16M8_MvFSmOWrLrfiAnuOzn0Mzn9uurLpQym+m4A@mail.gmail.com>
 <20111222.134344.1685328354280164155.davem@davemloft.net> <CAHXqBFL7oHgeUvKpV3Z2ddhMK-5KEqXJsp7p_geiYWTH_zwtaA@mail.gmail.com>
 <20111222.143422.1948369460874203875.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ian.Campbell@citrix.com, eric.dumazet@gmail.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-tul01m020-f174.google.com ([209.85.214.174]:39893 "EHLO
	mail-tul01m020-f174.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757571Ab1LWSKo convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Dec 2011 13:10:44 -0500
Received: by obcwo16 with SMTP id wo16so5229028obc.19
        for <netdev@vger.kernel.org>; Fri, 23 Dec 2011 10:10:44 -0800 (PST)
In-Reply-To: <20111222.143422.1948369460874203875.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/12/22 David Miller <davem@davemloft.net>:
> From: Micha=B3 Miros=B3aw <mirqus@gmail.com>
> Date: Thu, 22 Dec 2011 20:29:30 +0100
>
>> 2011/12/22 David Miller <davem@davemloft.net>:
>>> From: Micha=B3 Miros=B3aw <mirqus@gmail.com>
>>> Date: Thu, 22 Dec 2011 19:34:21 +0100
>>>
>>>> 2011/12/22 Ian Campbell <Ian.Campbell@citrix.com>:
>>>>> On Wed, 2011-12-21 at 19:28 +0000, David Miller wrote:
>>>>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>>>>> Date: Wed, 21 Dec 2011 15:02:18 +0100
>>>>>> > No idea on this +2 point.
>>>>>> I think I know, and I believe I instructed Alexey Kuznetsov to d=
o
>>>>>> this.
>>>>>>
>>>>>> When sendfile() is performed, we might start the SKB with the la=
st few
>>>>>> bytes of one page, and end the SKB with the first few bytes of a=
nother
>>>>>> page.
>>>>>>
>>>>>> In order to fit a full 64K frame into an SKB in this situation w=
e have
>>>>>> to accomodate this case.
>>>>> Thanks David, that makes sense.
>>>>>
>>>>> However I think you only actually need 1 extra page for that. If =
the
>>>>> data in frag[0] starts at $offset then frag[16] will need to have
>>>>> $offset bytes in it. e.g.
>>>>> =A0 =A0 =A0 =A04096-$offset + 4096*15 + $offset =3D 65536
>>>>> which =3D=3D 17 pages rather than 18.
>>>>>
>>>>> The following documents the status quo but I could update to swit=
ch to +
>>>>> 1 instead if there are no flaws in the above logic...
>>>>
>>>> Since max IP datagram is 64K-1, adding ethernet and possibly VLAN
>>>> headers makes the max size slightly above 64K and then you have
>>>> 64K/PAGE_SIZE+2 pages appear in worst case.
>>>
>>> Headers go into the linear area, so they are not relevant for these
>>> calculations.
>>
>> Does this hold for LRO'ed packets and packets sent via PF_PACKET soc=
ket?
>
> LRO is for receive, not packets we build on transmit, and in any even=
t
> have their headers also pulled into the linear area before the stack
> sees it.

Yes, but the drivers seem to first fill the data to frags[] and only
then move the packets header (I browsed myri10ge).

> For PF_PACKET, in the packet_snd() case it uses a linear SKB and in
> the tpacket_snd() case it uses a linear SKB as well.

I saw skb_fill_page_desc() in af_packet.c (called by
tpacket_fill_skb() which is called by tpacket_snd()), that's why I'm
asking.

Best Regards,
Micha=B3 Miros=B3aw
