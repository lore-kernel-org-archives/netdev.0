From: Mark Glines <mark@glines.org>
Subject: Re: [patch] ip_local_port_range sysctl has annoying default
Date: Mon, 14 May 2007 11:33:28 -0700
Message-ID: <20070514113328.7dcd4272@chirp>
References: <20070512124039.2155c593@chirp>
	<4648979B.3080000@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, kaber@coreworks.de
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from squawk.glines.org ([72.36.206.66]:41274 "EHLO squawk.glines.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757331AbXENSde (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 May 2007 14:33:34 -0400
In-Reply-To: <4648979B.3080000@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 14 May 2007 10:08:43 -0700
Rick Jones <rick.jones2@hp.com> wrote:
> >>I think the IANA range is considered too small in most cases; I
> >>suspect there is also a feeling that "there be dragons" near the
> >>very top.
> 
> About the only dragons which come to mind would be the very old,
> decrepit, barely able to puff wisps of steam let alone fire, dragons
> with the high-order bit set that would be misinterpreted by those
> treating port numbers as a short rather than an unsigned short.

Note that the high-order bit is set for all ports above 32768, so this
dragon would be stepped on pretty badly by Linux's default (and
indeed, the default for most OS's).

However, by "the very top", I think he was referring to the range
61000-65535, not all ports from 32768 up.  Alan Cox clarified (in
http://www.ussg.iu.edu/hypermail/linux/kernel/0705.1/2597.html), "The
top space is reserved when using masquerading and used for the
masquerading ports normally in that situation. Clipping them off avoids
differing behaviour with masquerading on/off."  So I think that's the
dragon in question, and NAT is a big ugly scary dragon indeed.


[snip]
> Oddly enough, it seems that on a system with a 2.6.21.1 kernel, the
> 32768-61000 is already there:
> 
> hpcpc102:~# sysctl -a | grep port
> error: permission denied on key 'net.ipv4.route.flush'
> net.ipv4.ip_local_port_range = 32768    61000

Yes, Linux does use the range of 32768-61000 in most cases, and it
works great.  The problem is, this default is determined at runtime by
tcp_init() (in net/ipv4/tcp.c), based on the bind hash size.  If the
bind hash size is above a certain threshold, it will use 32768-61000,
which seems to be the common case these days.  Otherwise, it will use a
range of 3072-4999, 2048-4999, or 1024-4999, depending on how small the
bind hash is.

I have a box here with 128M of RAM, which, running the same kernel rev,
*doesn't* have this default (because the bind hash size is too small),
which causes problems because its range (2048-4999) stomps on NFS's UDP
port (2049) by default. So I was getting a weird failure where nfsd
wouldn't start when klive was running.  But only on that machine.  The
same setup works great on all of my other machines.

I think the range of 32768-61000 is smart, and I am hoping Linux can
use this default range *everywhere* by default, regardless of the bind
hash size.  This is what my patch does.

If the list doesn't like this idea, I will happily submit another patch
which uses a dynamic range of the same size as before, but moves the
beginning of that range up to 32768.  (Or maybe moves the end of the
range up to 61000.)


> Solaris:
> # ndd /dev/tcp tcp_smallest_anon_port
> 32768
> # ndd /dev/tcp tcp_largest_anon_port
> 65535
> # uname -a
> SunOS competitive10 5.10 Generic_118833-36 sun4v sparc
> SUNW,Sun-Fire-T200
> 
> HP-UX:
> 
> # ndd /dev/tcp tcp_smallest_anon_port
> 49152
> # ndd /dev/tcp tcp_largest_anon_port
> 65535
> # uname -a
> HP-UX loiter B.11.23 U ia64 4283463096 unlimited-user license
> 
> no idea about AIX or BSD or Windows...

Interesting!

net.inet.ip.portrange.lowfirst: 1023
net.inet.ip.portrange.lowlast: 600
net.inet.ip.portrange.first: 1024
net.inet.ip.portrange.last: 5000
net.inet.ip.portrange.hifirst: 49152
net.inet.ip.portrange.hilast: 65535
DragonFly dfly181.tahoe 1.8.1-RELEASE DragonFly 1.8.1-RELEASE #2: Mon Mar 26 08:03:12 PDT 2007     root@:/usr/obj/usr/src/sys/GENERIC  i386

net.inet.ip.portrange.lowfirst: 1023
net.inet.ip.portrange.lowlast: 600
net.inet.ip.portrange.first: 49152
net.inet.ip.portrange.last: 65535
net.inet.ip.portrange.hifirst: 49152
net.inet.ip.portrange.hilast: 65535
net.inet.ip.portrange.reservedhigh: 1023
net.inet.ip.portrange.reservedlow: 0
FreeBSD fbsd62.tahoe 6.2-RELEASE FreeBSD 6.2-RELEASE #0: Fri Jan 12 10:40:27 UTC 2007     root@dessler.cse.buffalo.edu:/usr/obj/usr/src/sys/GENERIC i386

...whatever that means.

Mark
