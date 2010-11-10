From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH] macvlan: lockless tx path
Date: Wed, 10 Nov 2010 13:35:29 -0800
Message-ID: <4CDB1021.507@candelatech.com>
References: <1289403709.2860.216.camel@edumazet-laptop>	 <4CDAD8C8.20807@candelatech.com>	 <1289411027.2860.248.camel@edumazet-laptop>	 <4CDADC17.6070506@candelatech.com>	 <1289413120.2469.12.camel@edumazet-laptop>	 <4CDAE713.7020309@candelatech.com> <1289421187.2469.127.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:40330 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756475Ab0KJVfl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 16:35:41 -0500
In-Reply-To: <1289421187.2469.127.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/10/2010 12:33 PM, Eric Dumazet wrote:
> Le mercredi 10 novembre 2010 =C3=A0 10:40 -0800, Ben Greear a =C3=A9c=
rit :
>
>> In my opinion, the kernel and/or driver should deal with this such t=
hat
>> at worst the user has to deal with 32 v/s 64 bits based on whether t=
he
>> kernel is compiled for 32 or 64 bit CPUs.  (Let the driver sample at
>> intervals needed to never wrap it's counters more than once and upda=
te
>> software stats of well-defined bit-width, and present those software
>> counters to users.
>>
>
> How so ? Are you willing to provide patches for all network drivers ?

I'm willing to attempt to fix something that I use and can test.

Either way, I think it's legitimate to document at least the desired
behaviour so that driver writers know what to aim for.

>> In practice, this seems to be the case, at least for the NICs I've u=
sed
>> (mostly Intel).  But, please don't propagate the idea that any width=
 of
>> counters is OK to present to user-space:  It is completely unfair to
>> make app writers have to know the network driver and/or hardware qui=
rks to
>> know how often it must sample stats.
>>
>
> I am sorry Ben, but /proc/net/dev doesnt publish each counter effecti=
ve
> width. Its unfair, but its like that.
>
> An appplication must be able to cope for wrap arounds, running on a 3=
2
> or 64bit kernel. Our duty is to provide 64bit counters for high speed
> interfaces where possible.
> For a 10Mb adapter, there is no need, since a 32bit counter doesnt wr=
ap
> in less than one hour (RFC1902 suggestion)

So an application that must deal with wraps must poll at the minimal
time interval for wrapping 32-bit counters at whatever speed, or it
must pay attention to the driver to somehow know that this magic driver
can *really* do 64-bit stats properly?

Please note that just because a counter is less than the previous read,
that doesn't by itself tell us if it wrapped once or twice.  And, if we
don't know at which number of bits it wraps, then we don't know how man=
y
to add even if we are certain it wrapped only once.

In general, I want to treat eth0 the same as eth5, and not worry that o=
ne
is 10/100 realtek and the other a 10G Intel.

If netlink reports stats64, then those should only wrap at 64 bits,
and if it reports stats32, then wrap at 32-bits.

> As I said, many drivers counters are not 32bit or 64bit. I did many
> driver get_stats() checks lately...
>
> Why should we cap them to 32bit if they really are 36 or 40 bits ?
>
>
>> Well, maybe using u32 would have positive benefits on 64-bit kernels=
 then?
>>
>
> But we want to handle 40/100Gbps devices, and keep SNMP apps happy.
>
> We really need 64bit for them, and MACVLAN might be used on top of su=
ch
> devices.
>
> Or are you suggesting using u32 instead of "unsigned long" for
> rx_errors/tx_dropped ?
>
> This would indeed save 8 bytes per cpu per macvlan.

Yes, that was what I was trying to suggest.  I'm all for 64-bit numbers
in anything that can wrap anytime soon, and anywhere you think 32-bits
is enough, just use u32 so we don't have to worry about the number of
bits in 'unsigned long' on different platforms.

Thanks,
Ben


--=20
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

