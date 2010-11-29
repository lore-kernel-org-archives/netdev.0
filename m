From: David Shwatrz <dshwatrz@gmail.com>
Subject: Re: [net-next-2.6] XFRM: remove unused member in xfrm_encap_tmpl.
Date: Mon, 29 Nov 2010 22:09:48 +0200
Message-ID: <AANLkTimfUFuJKMwp6X65z_NRE4pPKy-6_fEu19Gaqycm@mail.gmail.com>
References: <AANLkTiknTcWaRykGOTbw6JpFZN-ePnRXd3iWz86yYHKi@mail.gmail.com>
	<4CF3EBF2.5060308@iki.fi>
	<AANLkTinQ1qbp9SyWgw7TdvH=5x_1AA6zqLkaa7c4PBGQ@mail.gmail.com>
	<4CF3FE85.6040406@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46690 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753218Ab0K2UJu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 15:09:50 -0500
Received: by wwa36 with SMTP id 36so5148078wwa.1
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 12:09:49 -0800 (PST)
In-Reply-To: <4CF3FE85.6040406@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Timo,
Thanks for your answer.

> Alternatively the other RFCs say that the checksum can be just
> recalculated. That's what the linux stack does: it throws the old
> checksum away (ignored on local receive and recalculated on send
> forward paths).

Sorry, something here seems to me still wrong; maybe I miss something.
We are talking about transport mode. Let's take TCP for example.
the packet is received by another peer. It is on port 4500 because of
NAT-T. Since it is ESP encrypted , it is it is decrypted. It reaches
the TCP layer. In TCP (as opposed to UDP), the checksum is mandatory.
But the checksum in that TCP header of the received
packet will not be correct, since the IP header of that packet is
**NOT** the original address ; the IP address was changed by the NAT.
The NAT  cannot change the TCP checksum since it is encrypted. So
wouldn't we have a checksum error in the case of TCP ?  It seems to me
that the purpose of NAT-OA was to pass the
original address, so that there will be no error in such a case.
But again, maybe I miss something, since I did not heard that
transport mode has any problems with NAT-T. Or maybe this was not
tested?


Rgs,
DS



2010/11/29 Timo Ter=E4s <timo.teras@iki.fi>:
> On 11/29/2010 09:15 PM, David Shwatrz wrote:
>> But isn't something wrong here ?
>>
>> According to RFC 3948:
>> ...
>> 3.1.2. =A0Transport Mode Decapsulation NAT Procedure
>>
>> When a transport mode has been used to transmit packets, contained
>> =A0 =A0TCP or UDP headers will have incorrect checksums due to the c=
hange of
>> =A0 =A0parts of the IP header during transit. =A0This procedure defi=
nes how to
>> =A0 =A0fix these checksums
>> ...
>> incrementally recompute the
>> =A0 =A0 =A0 =A0TCP/UDP checksum:
>>
>> =A0 =A0 =A0 =A0* =A0Subtract the IP source address in the received p=
acket from the
>> =A0 =A0 =A0 =A0 =A0 checksum.
>> =A0 =A0 =A0 =A0* =A0Add the real IP source address received via IKE =
to the
>> =A0 =A0 =A0 =A0 =A0 checksum (obtained from the NAT-OA)
>> ...
>>
>> So where do we pass the NAT-OA, received from IKE messages, =A0to th=
is
>> checksum recalculation process, which should be done in the kernel
>> (layer 4 TCP/UDP I suppose) ?
>>
>> Should'nt this process be done in the kernel ?
>>
>> Isn't there something missing here ?
>
> That's what the field was intended for. Also it's passed around by e.=
g.
> 'ip xfrm' command. The header change would break compilation of iprou=
te2
> too.
>
> Alternatively the other RFCs say that the checksum can be just
> recalculated. That's what the linux stack does: it throws the old
> checksum away (ignored on local receive and recalculated on send /
> forward paths). The ESP/AH packets are usually also configured to
> contain a cryptographic hash, so the packet modifications are detecte=
d
> even before trying to check the TCP/UDP checksum (making the check
> redundant).
>
> There's also probably some legacy reasons why the nat-oa field is use=
ful
> in kernel; and why the tcp/udp is not updated according the above
> mentioned scheme. I guess doing that might speed up forwarding from o=
ne
> tunnel to another where hardware checksum acceleration is not availab=
le;
> maybe no one just had the time to implement it.
>
> - Timo
>
