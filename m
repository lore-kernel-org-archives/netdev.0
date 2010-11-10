From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 14:53:30 -0800
Message-ID: <4CDB226A.8080903@candelatech.com>
References: <1289403709.2860.216.camel@edumazet-laptop>	 <4CDAD8C8.20807@candelatech.com>	 <1289411027.2860.248.camel@edumazet-laptop>	 <4CDADC17.6070506@candelatech.com>	 <1289413120.2469.12.camel@edumazet-laptop>	 <4CDAE713.7020309@candelatech.com>	 <1289421187.2469.127.camel@edumazet-laptop>  <4CDB1021.507@candelatech.com> <1289427705.17691.52.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:43010 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757318Ab0KJWxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 17:53:32 -0500
In-Reply-To: <1289427705.17691.52.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2010 02:21 PM, Eric Dumazet wrote:
> Le mercredi 10 novembre 2010 =C3=A0 13:35 -0800, Ben Greear a =C3=A9c=
rit :

NOTE:  I trimmed the CC list..this has nothing in particular to
do with mac-vlans now.

>> So an application that must deal with wraps must poll at the minimal
>> time interval for wrapping 32-bit counters at whatever speed, or it
>> must pay attention to the driver to somehow know that this magic dri=
ver
>> can *really* do 64-bit stats properly?
>>
>
> Are you aware that you speak of something that is not specified at al=
l
> in linux ?
>
> Frequency of polling is not part of any RFC. This usually is tunable =
in
> the _application_. Some people sample stats every 5 minutes, some sam=
ple
> every second, and hit the "xxx driver updates its stats every two
> seconds, this sucks"

These '2 sec' granularity bugs are a pain and should be (and have been)
fixed.

> I wrote SNMP apps based on /proc/net/dev and all just work, with any
> versions, any driver. Of course, some of them broke 6 years ago becau=
se
> they were 32bit legacy application, running on a 64bit kernel. I neve=
r
> asked David to change /proc/net/dev to cap counters to 32bit.

I did similar, and then wrote extra code to detect a 64-bit kernel and =
if
so assume that the counters wrap at 64 bits so I didn't have to poll so
often to make sure I didn't miss a wrap for a 10G NIC.  If instead one =
wraps at 33
bits and the other at 36, there is no way for me to deal with the wrap
properly w/out explicitly knowing about that 33 and 36.

If the old 32-bit counters in /proc/net/dev instead had a driver that
managed to wrap them at 28 bits, I can't see how your application could
have worked properly, so you must have been assuming that the kernel wo=
uld
always return a full 32-bit counter.

Now, I'm trying to use netlink api since I'm hoping that is more effici=
ent
and controllable than just reading /proc/net/dev over and over.  Netlin=
k
explicitly can return a set of 32-bit counters or 64-bit.

All I want is to ensure than they are actually 32 or 64 bit, not 36 bit=
 crammed in a
64-bit counter.  In other words, make the driver and/or kernel do it's
job and abstract access to hardware and return a consistent interface.

>> Please note that just because a counter is less than the previous re=
ad,
>> that doesn't by itself tell us if it wrapped once or twice.  And, if=
 we
>> don't know at which number of bits it wraps, then we don't know how =
many
>> to add even if we are certain it wrapped only once.
>>
>
> I repeat : Nothing in /proc/net/dev can tell you when a counter will
> wrap (the counter width).

My primary concern is netlink API now, and even for proc/net/dev, there=
 is no
good reason to show 32-bit counters mixed with 64-bit counters on 64-bi=
t systems.
The kernel can deal with this easily enough, and it should.

>> If netlink reports stats64, then those should only wrap at 64 bits,
>> and if it reports stats32, then wrap at 32-bits.
>>
>
> I believe you are mistaken. We provide stats64 for all drivers, even
> 32bit legacy ones. rtnetlink has no way to report counter widths,
> because nobody cared.

Then it's busted.  If it claims to return stats64, but instead is retur=
ning
something different, it is wrong.  Netlink API still defines a stats32,=
 so
the kernel should use that if it can't reliably deal with 64-bit counte=
rs.

Thanks,
Ben

--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

