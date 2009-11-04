From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB accuracy on 10GbE
Date: Wed, 04 Nov 2009 18:03:07 +0100
Message-ID: <4AF1B3CB.1050008@gmail.com>
References: <b30d1c3b0911012322v5d553fd6va56575fcf5e3daf8@mail.gmail.com>	 <4AEEFE2E.7090706@trash.net> <20091102125345.3c39c42e@nehalam>	 <b30d1c3b0911031913k2c922935vc9605b76ac43168f@mail.gmail.com>	 <4AF10B1D.4050604@gmail.com> <4AF110CE.8070701@gmail.com>	 <b30d1c3b0911040019q14a007d4lbd1b695db8884b27@mail.gmail.com>	 <4AF1660E.1080401@gmail.com> <b30d1c3b0911040831y7aeac556raf7cae9106b5bc7b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	takano-ryousei@aist.go.jp
To: Ryousei Takano <ryousei@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:47677 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753372AbZKDRDL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 12:03:11 -0500
In-Reply-To: <b30d1c3b0911040831y7aeac556raf7cae9106b5bc7b@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ryousei Takano a =E9crit :
> Hi Eric,
>=20
> Thanks for your suggestion.
>=20
> On Wed, Nov 4, 2009 at 8:31 PM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>> Ryousei Takano a =E9crit :
>>
>>> I tried iperf with 60 seconds samples. I got the almost same result=
=2E
>>>
>>> Here is the result:
>>>       sender  receiver
>>> 1.000 1.00    1.00
>>> 2.000 2.01    2.01
>>> 3.000 3.03    3.02
>>> 4.000 4.07    4.07
>>> 5.000 5.05    5.05
>>> 6.000 6.16    6.16
>>> 7.000 7.22    7.22
>>> 8.000 8.15    8.15
>>> 9.000 9.23    9.23
>>> 9.900 9.69    9.69
>>>
>> One thing to consider is the estimation error in qdisc_l2t(), rate t=
able has only 256 slots
>>
>> static inline u32 qdisc_l2t(struct qdisc_rate_table* rtab, unsigned =
int pktlen)
>> {
>>        int slot =3D pktlen + rtab->rate.cell_align + rtab->rate.over=
head;
>>        if (slot < 0)
>>                slot =3D 0;
>>        slot >>=3D rtab->rate.cell_log;
>>        if (slot > 255)
>>                return (rtab->data[255]*(slot >> 8) + rtab->data[slot=
 & 0xFF]);
>>        return rtab->data[slot];
>> }
>>
>>
>> Maybe you can try changing class mtu to 40000 instead of 9000, and q=
uantum to 60000 too
>>
>> tc class add dev $DEV parent 1: classid 1:1 htb rate ${rate}mbit mtu=
 40000 quantum 60000
>>
>> (because your tcp stack sends large buffers ( ~ 60000 bytes) as your=
 NIC can offload tcp segmentation)
>>
>>
> You are right!
> I am using TSO. The myri10ge driver is passing 64KB packets to the NI=
C.
> I changed the class mtu parameter to 64000 instead of 9000.
>=20
> Here is the result:
> 1.000 1.00
> 2.000 2.01
> 3.000 2.99
> 4.000 4.01
> 5.000 5.01
> 6.000 6.04
> 7.000 7.06
> 8.000 8.09
> 9.000 9.11
> 9.900 9.64
>=20
> It's not so bad!
> For more information, I updated the results on my page.
>=20


In fact, I gave you 40000 because rtab will contain 256 elements from 0=
 to 65280

If you use 64000, you lose some precision (for small packets for exampl=
e)


