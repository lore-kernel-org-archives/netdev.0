From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: cat /proc/net/tcp takes 0.5 seconds on x86_64
Date: Tue, 26 Aug 2008 23:27:31 +0200
Message-ID: <48B47543.8080701@cosmosbay.com>
References: <bug-459782-176318@bugzilla.redhat.com> <200808261549.m7QFnVUN032543@bz-web1.app.phx.redhat.com> <20080826163719.GA25066@redhat.com> <48B44C3F.6020006@cosmosbay.com> <48B452ED.1000308@hhs.nl> <48B469EA.1010807@cosmosbay.com> <48B46E89.4030104@hhs.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, netdev@vger.kernel.org
To: Hans de Goede <j.w.r.degoede@hhs.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2e.orange.fr ([80.12.242.113]:19734 "EHLO smtp2e.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751865AbYHZVbV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 17:31:21 -0400
In-Reply-To: <48B46E89.4030104@hhs.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hans de Goede a =E9crit :
> Eric Dumazet wrote:
>> Hans de Goede a =E9crit :
>>> Eric Dumazet wrote:
>>>> Dave Jones a =E9crit :
>>>>> Just had this bug reported against our development tree..
>>> <snip>
>>>>>  > [hans@localhost devel]$ time cat /proc/net/tcp
>>>>>  > <snip>
>>>>>  > real    0m0.520s
>>>>>  > user    0m0.000s
>>>>>  > sys     0m0.446s
>>>>>  >  > Thats amazingly slow, esp as I only have 8 tcp connections =
open.
>>>>>  >  > Some maybe usefull info: top reports a very high load (50%)=
=20
>>>>> from soft IRQ's.
>>>>>  >  > Anyways changing this to a kernel bug.
>>>>>
>>>>
>>>> I wonder why this qualifies as a "kernel bug". This is a well know=
n=20
>>>> problem.
>>>>
>>>
>>> No its not, /proc/net/tcp may be slow in general but not *this* slo=
w ...
>>>
>>> <snip>
>>>
>>>>
>>>> Time difference between /proc/net/tcp and netlink on a 4GB x86_64=20
>>>> machine :
>>>>
>>>> # dmesg | grep "TCP established hash"
>>>> TCP established hash table entries: 262144 (order: 10, 4194304 byt=
es)
>>>> # time cat /proc/net/tcp >/dev/null
>>>>
>>>> real    0m0.091s
>>>> user    0m0.001s
>>>> sys     0m0.090s
>>>
>>> As quoted above my idle x86_64, using the exact same hash table siz=
e,=20
>>> running 2.6.27-rc2.git1 uses 0.520 seconds for that same command,=20
>>> thats a difference of more then a factor 50 !!
>>>
>>> This is not about /proc/net/tcp not being fast, this is about it=20
>>> haven gotten slower by a factor of 50!
>>>
>>> Also notice that this slowdown does not happen on i386.
>>
>> And your .config files on i386 and x86_64 are ?
>> Some configuration options can slow down all lock/unlock operations=20
>> (CONFIG_SMP, CONFIG_PREEMPT, CONFIG_PROVE_LOCKING,=20
>> CONFIG_DEBUG_SPINLOCK, CONFIG_NR_CPUS ...)
>>
>=20
> Attached
>=20
>> If you TCP hash table has 512.000 slots (I am just guessing, you did=
nt=20
>> provide this information), it can make a huge difference.
>=20
> I did provide that information: "using the exact same hash table size=
"=20
> and then quoting your first mail in this thread:
> "TCP established hash table entries: 262144 (order: 10, 4194304 bytes=
)"
>=20
>>>
>>> Anyways I'll try 2.6.27-rc4 and report back with its results.
>>>
>>
>> Yes, please, but nothing really changed in this area in the recent=20
>> times...
>>
>=20
> I'm afraid that atleast the Fedora rc4 build won't boot on my machine=
 ...
>=20
>> We added some checks so that softirqs can preempt us.
>> Latencies used to be very high, and are now bonded, at the price of=20
>> potential slowdown for the /proc/net/tcp reader.
>=20
> Slowdown as in 2x or 4x as slow I presume, not 50x ?

I dont know, you tell us 50x, but nowhere I saw your numbers on i386,
nor the amount of memory of your test machine.

One important thing to remember is that on i386, LOWMEM is less than 1G=
B,=20
so a 4GB server will give different hash sizes depending on being 32 or=
 64 bits.

With a 32 bits kernel:

# dmesg | grep "TCP established"
TCP established hash table entries: 131072 (order: 8, 1048576 bytes)
# time cat /proc/net/tcp >/dev/null

real    0m0.025s
user    0m0.000s
sys     0m0.017s


While on a 64 bits kernel :

# dmesg | grep "TCP established hash"
TCP established hash table entries: 262144 (order: 10, 4194304 bytes)
# time cat /proc/net/tcp >/dev/null

real    0m0.091s
user    0m0.001s
sys     0m0.090s=20

So I see a 3x on my machine, not a 50x as you ?




