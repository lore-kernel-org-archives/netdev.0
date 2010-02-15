From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 4/4] Staging: Octeon:  Free transmit SKBs in a timely
 manner.
Date: Mon, 15 Feb 2010 14:05:22 -0800
Message-ID: <4B79C522.4040405@caviumnetworks.com>
References: <4B79AAA6.60005@caviumnetworks.com>	 <1266264799-3510-4-git-send-email-ddaney@caviumnetworks.com>	 <1266265673.2859.5.camel@edumazet-laptop>	 <4B79B15F.7030506@caviumnetworks.com> <1266268271.2859.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ralf@linux-mips.org, linux-mips@linux-mips.org,
	netdev@vger.kernel.org, gregkh@suse.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3.caviumnetworks.com ([12.108.191.235]:2444 "EHLO
	mail3.caviumnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756067Ab0BOWF3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2010 17:05:29 -0500
In-Reply-To: <1266268271.2859.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2010 01:11 PM, Eric Dumazet wrote:
> Le lundi 15 f=C3=A9vrier 2010 =C3=A0 12:41 -0800, David Daney a =C3=A9=
crit :
>> On 02/15/2010 12:27 PM, Eric Dumazet wrote:
>>> Le lundi 15 f=C3=A9vrier 2010 =C3=A0 12:13 -0800, David Daney a =C3=
=A9crit :
>>>> If we wait for the once-per-second cleanup to free transmit SKBs,
>>>> sockets with small transmit buffer sizes might spend most of their
>>>> time blocked waiting for the cleanup.
>>>>
>>>> Normally we do a cleanup for each transmitted packet.  We add a
>>>> watchdog type timer so that we also schedule a timeout for 150uS a=
fter
>>>> a packet is transmitted.  The watchdog is reset for each transmitt=
ed
>>>> packet, so for high packet rates, it never expires.  At these high
>>>> rates, the cleanups are done for each packet so the extra watchdog
>>>> initiated cleanups are not needed.
>>>
>>> s/needed/fired/
>>>
>>
>> or perhaps s/are not needed/are neither needed nor fired/
>>
>>> Hmm, but re-arming a timer for each transmited packet must have a c=
ost ?
>>>
>>
>> The cost is fairly low (less than 10 processor clock cycles).  We di=
dn't
>> add this for amusement, people actually do things like only send UDP
>> packets from userspace.  Since we can fill the transmit queue faster
>> than it is emptied, the socket transmit buffer is quickly consumed. =
 If
>> we don't free the SKBs in short order, the transmitting process get =
to
>> take a long sleep (until our previous once per second clean up task =
was
>> run).
>
> I understand this, but traditionaly, NIC drivers dont use a timer, bu=
t a
> 'TX complete' interrupt, that usually fires a few us after packet
> submission on Gigabit speed.
>

Indeed.  Lacking this type of interrupt, the watchdog seemed the best=20
short term solution.

I am investigating the possibility of feeding TX complete notifications=
=20
back through the RX path where it is possible to generate interrupts.=20
The drawback to this is that it takes a lot more CPU cycles as well as=20
added cache pressure.

> A fast program could try to send X small udp packets in less than 150
> us, X being greater than the size of your TX ring.

My TX queue (it is not a ring) size can be made arbitrarily large=20
(currently 1000).  64bytes * 1000 packets * 10 bits/packet / 10e9=20
bits/sec  =3D=3D 640uS.  My watchdog will fire after less than 1/4 of t=
he=20
ring capacity is freed.

>
> So your patch makes the window smaller, but it still is there (at
> physical layer, we'll see a burst of packets, a ~100us delay, then a
> second burst)
>

With this patch, there will be no burstiness using default socket buffe=
r=20
sizes and packets of arbitrary size on a standard 1gig port.

On the 10gig ports there is the possibility for burstiness as you aptly=
=20
explain.  However, in practice it would be difficult to arrange things=20
to achieve sufficiently high packet rates, so we can live with it like =
this.

David Daney
