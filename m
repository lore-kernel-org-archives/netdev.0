From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: speed regression in udp_lib_lport_inuse()
Date: Fri, 23 Jan 2009 01:20:13 +0100
Message-ID: <49790D3D.8060400@cosmosbay.com>
References: <m3sknbuqf9.wl%vmayatsk@redhat.com> <4978EE03.9040207@cosmosbay.com> <20090122221434.GB1651@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Vitaly Mayatskikh <v.mayatskih@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw2.cosmosbay.com ([86.64.20.130]:36290 "EHLO gw2.cosmosbay.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753060AbZAWAUW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 19:20:22 -0500
In-Reply-To: <20090122221434.GB1651@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Evgeniy Polyakov a =E9crit :
> Hi Eric.
>=20
> On Thu, Jan 22, 2009 at 11:06:59PM +0100, Eric Dumazet (dada1@cosmosb=
ay.com) wrote:
>> Hello Vitaly, thanks for this excellent report.
>>
>> Yes, current code is really not good when all ports are in use :
>>
>> We now have to scan 28232 [1] times long chains of 220 sockets.
>> Thats very long (but at least thread is preemptable)
>>
>> In the past (before patches), only one thread was allowed to run in =
kernel while scanning
>> udp port table (we had only one global lock udp_hash_lock protecting=
 the whole udp table).
>> This thread was faster because it was not slowed down by other threa=
ds.
>> (But the rwlock we used was responsible for starvations of writers i=
f many UDP frames
>> were received)
> =20
> I believe problem is in the port searching algorithm, when we
> have exponentially grow of the number of ports to check after random
> selection of the first one. This allows to have small chains but setu=
p
> time will be very long. Not sure if bind chais should be that small
> actually. In the 64k patch, which allows to have more than 64k bound
> sockets per system I store rough amount of bound sockets and when it
> becomes larger than sysctl limit I just randomly select a bundle.
> This works for the bind(0) for the sockets with reuse option though.
> I posted a picture of the bind(0) time for the .28 kernel iirc.
>=20
> Or is this a different issue?
>=20

Well, this is not exactly the same issue, udp bind() code is slightly d=
ifferent
than tcp. (Probably not so many machines use lot of udp sockets)

Since UDP hash table is really small (128 slots), we can try to allocat=
e UDP ports
chains per chain, instead of port per port, to reduce number of chain l=
ookups.
In tcp, most machines have 64k slots for bind table so this wont help

