From: Andy Fleming <afleming@gmail.com>
Subject: Re: ICMP echo reply fails
Date: Fri, 26 Mar 2010 19:56:17 -0500
Message-ID: <2acbd3e41003261756n5da16b8erf701893b1bfc771e@mail.gmail.com>
References: <2acbd3e41003261448q26cb19d4w63487894b24f0254@mail.gmail.com>
	 <1269641190.2256.1.camel@edumazet-laptop>
	 <1269643575.2256.19.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:49777 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab0C0A4T convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Mar 2010 20:56:19 -0400
Received: by wwe15 with SMTP id 15so7028009wwe.19
        for <netdev@vger.kernel.org>; Fri, 26 Mar 2010 17:56:17 -0700 (PDT)
In-Reply-To: <1269643575.2256.19.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 26, 2010 at 5:46 PM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
> Le vendredi 26 mars 2010 =E0 23:06 +0100, Eric Dumazet a =E9crit :
>> Le vendredi 26 mars 2010 =E0 16:48 -0500, Andy Fleming a =E9crit :
>> > For various reasons, we have been running a stress test on one of =
our
>> > boards. =A0The test consists of initiating 2-3 flood pings from a
>> > Windows box running Cygwin, plus one additional ping we use as a
>> > "heartbeat". =A0The ping flood is overwhelming our board (we're dr=
opping
>> > packets at a prodigious rate), but the board continues to respond =
for
>> > a while. =A0In addition, we are running a script on the =A0board w=
hich
>> > alternates bringing up and bringing down the interface every ten
>> > seconds. =A0After a highly variable amount of time, the board stop=
s
>> > replying to the pings. =A0We suspected a driver issue, however, on
>> > closer inspection, we are still able to send and receive packets (=
I
>> > can ping *from* the board to the PC, and I can *telnet* from the P=
C to
>> > the board). =A0We tried pinging the board from another PC, and it =
also
>> > failed. =A0Essentially, ICMP echo requests are being ignored (A gl=
ance
>> > at memory indicates that packets are arriving, but no packets are
>> > being enqueued to the ethernet controller). =A0We still have a lot=
 more
>> > debugging to do, but I was wondering if anyone had ever seen somet=
hing
>> > like this, or might be quicker to realize the obvious mistake we'r=
e
>> > making.
>> >
>> > Thanks,
>> > Andy Fleming
>>
>>
>> kernel version ?
>>
>> NIC driver ?
>>
>> Are ICMP echo request received ? (grep Icmp /proc/net/snmp)
>>
>
> vi +1166 net/ipv4/icmp.c
>
> =A0 =A0 =A0 =A0/* Enough space for 2 64K ICMP packets, including
> =A0 =A0 =A0 =A0 * sk_buff struct overhead.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0sk->sk_sndbuf =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(2 * ((64 * 1024) + sizeof(struct sk_b=
uff)));
>
>
> If many ICMP replies are lost/leaked by your driver when doing up/dow=
n
> things, ICMP socket can consume all its sndbuf reserve and no more ic=
mp
> replies can be sent (a reboot is needed)
>
> You could try changing sk->sk_sndbuf to 0x7FFFFFFF =A0to see if the i=
cmp
> replies survive longer to your tests. If this is the case, then find =
the
> leaks in your driver (tx path, maybe you forgot to free skbs in some
> reset cases ?)
>

Ah, that makes a bunch of sense.  I had a feeling the socket was
involved.  Thank you so much for your help.  I will test this as soon
as I have access to the board again!
