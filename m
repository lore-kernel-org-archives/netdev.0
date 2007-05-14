From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [patch] ip_local_port_range sysctl has annoying default
Date: Mon, 14 May 2007 11:47:05 -0700
Message-ID: <4648AEA9.4040805@hp.com>
References: <20070512124039.2155c593@chirp>	<4648979B.3080000@hp.com> <20070514113328.7dcd4272@chirp>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@coreworks.de
To: Mark Glines <mark@glines.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel13.hp.com ([156.153.255.238]:33943 "EHLO palrel13.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754355AbXENSrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 14:47:11 -0400
In-Reply-To: <20070514113328.7dcd4272@chirp>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Note that the high-order bit is set for all ports above 32768, so this
> dragon would be stepped on pretty badly by Linux's default (and
> indeed, the default for most OS's).
> 
> However, by "the very top", I think he was referring to the range
> 61000-65535, not all ports from 32768 up.  Alan Cox clarified (in
> http://www.ussg.iu.edu/hypermail/linux/kernel/0705.1/2597.html), "The
> top space is reserved when using masquerading and used for the
> masquerading ports normally in that situation. Clipping them off avoids
> differing behaviour with masquerading on/off."  So I think that's the
> dragon in question, and NAT is a big ugly scary dragon indeed.

NAT, why does there have to be NAT... :)  yeah, it is big and ugly, shame we 
cannot put a stake through its heart :(

> [snip]
> 
>>Oddly enough, it seems that on a system with a 2.6.21.1 kernel, the
>>32768-61000 is already there:
>>
>>hpcpc102:~# sysctl -a | grep port
>>error: permission denied on key 'net.ipv4.route.flush'
>>net.ipv4.ip_local_port_range = 32768    61000
> 
> 
> Yes, Linux does use the range of 32768-61000 in most cases, and it
> works great.  The problem is, this default is determined at runtime by
> tcp_init() (in net/ipv4/tcp.c), based on the bind hash size.  If the
> bind hash size is above a certain threshold, it will use 32768-61000,
> which seems to be the common case these days.  Otherwise, it will use a
> range of 3072-4999, 2048-4999, or 1024-4999, depending on how small the
> bind hash is.

Ah (insert suitable emily litella reference here)  All the systems with which I 
play are probably considered "large" - even the ones I consider "small."

> I have a box here with 128M of RAM, which, running the same kernel rev,
> *doesn't* have this default (because the bind hash size is too small),
> which causes problems because its range (2048-4999) stomps on NFS's UDP
> port (2049) by default. So I was getting a weird failure where nfsd
> wouldn't start when klive was running.  But only on that machine.  The
> same setup works great on all of my other machines.

Hmm, those small values feel like variations on the old BSD defaults theme.  I 
don't recall issues with NFS there, but it is very likely that NFS would have 
been started well before most anything else so it would "win" the race to 2049.

> I think the range of 32768-61000 is smart, and I am hoping Linux can
> use this default range *everywhere* by default, regardless of the bind
> hash size.  This is what my patch does.
> 
> If the list doesn't like this idea, I will happily submit another patch
> which uses a dynamic range of the same size as before, but moves the
> beginning of that range up to 32768.  (Or maybe moves the end of the
> range up to 61000.)

Unless the memory size changes the hash algorithm itself (which bits are used, 
that sort of thing) I wouldn't think that the values in the port number range 
would particularly matter.

> 
> 
>>Solaris:
>># ndd /dev/tcp tcp_smallest_anon_port
>>32768
>># ndd /dev/tcp tcp_largest_anon_port
>>65535
>># uname -a
>>SunOS competitive10 5.10 Generic_118833-36 sun4v sparc
>>SUNW,Sun-Fire-T200
>>
>>HP-UX:
>>
>># ndd /dev/tcp tcp_smallest_anon_port
>>49152
>># ndd /dev/tcp tcp_largest_anon_port
>>65535
>># uname -a
>>HP-UX loiter B.11.23 U ia64 4283463096 unlimited-user license
>>
>>no idea about AIX or BSD or Windows...
> 
> 
> Interesting!
> 
> net.inet.ip.portrange.lowfirst: 1023
> net.inet.ip.portrange.lowlast: 600
> net.inet.ip.portrange.first: 1024
> net.inet.ip.portrange.last: 5000
> net.inet.ip.portrange.hifirst: 49152
> net.inet.ip.portrange.hilast: 65535
> DragonFly dfly181.tahoe 1.8.1-RELEASE DragonFly 1.8.1-RELEASE #2: Mon Mar 26 08:03:12 PDT 2007     root@:/usr/obj/usr/src/sys/GENERIC  i386
> 
> net.inet.ip.portrange.lowfirst: 1023
> net.inet.ip.portrange.lowlast: 600
> net.inet.ip.portrange.first: 49152
> net.inet.ip.portrange.last: 65535
> net.inet.ip.portrange.hifirst: 49152
> net.inet.ip.portrange.hilast: 65535
> net.inet.ip.portrange.reservedhigh: 1023
> net.inet.ip.portrange.reservedlow: 0
> FreeBSD fbsd62.tahoe 6.2-RELEASE FreeBSD 6.2-RELEASE #0: Fri Jan 12 10:40:27 UTC 2007     root@dessler.cse.buffalo.edu:/usr/obj/usr/src/sys/GENERIC i386
> 
> ...whatever that means.
> 
> Mark

