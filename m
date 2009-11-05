From: Ryousei Takano <ryousei@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Thu, 5 Nov 2009 16:08:07 +0900
Message-ID: <b30d1c3b0911042308n616bc360v7b96b6543029f232@mail.gmail.com>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>
	 <4AEEFE2E.7090706@trash.net> <20091102125345.3c39c42e@nehalam>
	 <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>
	 <4AF10B1D.4050604@gmail.com> <4AF110CE.8070701@gmail.com>
	 <b30d1c3b0911040019q14a007d4lbd1b695db8884b27@mail.gmail.com>
	 <4AF1660E.1080401@gmail.com>
	 <b30d1c3b0911040831y7aeac556raf7cae9106b5bc7b@mail.gmail.com>
	 <4AF1B3CB.1050008@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f192.google.com ([209.85.212.192]:56149 "EHLO
	mail-vw0-f192.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825AbZKEHID convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 02:08:03 -0500
Received: by vws30 with SMTP id 30so2201333vws.33
        for <netdev@vger.kernel.org>; Wed, 04 Nov 2009 23:08:07 -0800 (PST)
In-Reply-To: <4AF1B3CB.1050008@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Thu, Nov 5, 2009 at 2:03 AM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Ryousei Takano a =E9crit :
>> Hi Eric,
>>
>> Thanks for your suggestion.
>>
>> On Wed, Nov 4, 2009 at 8:31 PM, Eric Dumazet <eric.dumazet@gmail.com=
> wrote:
>>> Ryousei Takano a =E9crit :
>>>
>>>> I tried iperf with 60 seconds samples. I got the almost same resul=
t.
>>>>
>>>> Here is the result:
>>>> =A0 =A0 =A0 sender =A0receiver
>>>> 1.000 1.00 =A0 =A01.00
>>>> 2.000 2.01 =A0 =A02.01
>>>> 3.000 3.03 =A0 =A03.02
>>>> 4.000 4.07 =A0 =A04.07
>>>> 5.000 5.05 =A0 =A05.05
>>>> 6.000 6.16 =A0 =A06.16
>>>> 7.000 7.22 =A0 =A07.22
>>>> 8.000 8.15 =A0 =A08.15
>>>> 9.000 9.23 =A0 =A09.23
>>>> 9.900 9.69 =A0 =A09.69
>>>>
>>> One thing to consider is the estimation error in qdisc_l2t(), rate =
table has only 256 slots
>>>
>>> static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned=
 int pktlen)
>>> {
>>> =A0 =A0 =A0 =A0int slot =3D pktlen + rtab->rate.cell_align + rtab->=
rate.overhead;
>>> =A0 =A0 =A0 =A0if (slot < 0)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0slot =3D 0;
>>> =A0 =A0 =A0 =A0slot >>=3D rtab->rate.cell_log;
>>> =A0 =A0 =A0 =A0if (slot > 255)
>>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return (rtab->data[255]*(slot >> 8) =
+ rtab->data[slot & 0xFF]);
>>> =A0 =A0 =A0 =A0return rtab->data[slot];
>>> }
>>>
>>>
>>> Maybe you can try changing class mtu to 40000 instead of 9000, and =
quantum to 60000 too
>>>
>>> tc class add dev $DEV parent 1: classid 1:1 htb rate ${rate}mbit mt=
u 40000 quantum 60000
>>>
>>> (because your tcp stack sends large buffers ( ~ 60000 bytes) as you=
r NIC can offload tcp segmentation)
>>>
>>>
>> You are right!
>> I am using TSO. The myri10ge driver is passing 64KB packets to the N=
IC.
>> I changed the class mtu parameter to 64000 instead of 9000.
>>
>> Here is the result:
>> 1.000 1.00
>> 2.000 2.01
>> 3.000 2.99
>> 4.000 4.01
>> 5.000 5.01
>> 6.000 6.04
>> 7.000 7.06
>> 8.000 8.09
>> 9.000 9.11
>> 9.900 9.64
>>
>> It's not so bad!
>> For more information, I updated the results on my page.
>>
>
>
> In fact, I gave you 40000 because rtab will contain 256 elements from=
 0 to 65280
>
> If you use 64000, you lose some precision (for small packets for exam=
ple)
>
I see.

In my experiment, it is not very big problem.  I do not send short pack=
ets.
I got the almost same result in the both cases "mtu 64000" and "mtu
40000 quantum 60000".

Anyway, setting larger mtu size than the physical mtu does not quiet ma=
ke sense.

Best regards,
Ryousei
