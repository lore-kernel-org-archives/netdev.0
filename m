From: Ivan Zahariev <famzah@icdsoft.com>
Subject: Re: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Thu, 17 Nov 2011 00:32:18 +0200
Message-ID: <4EC439F2.3080809@icdsoft.com>
References: <4EC2CA52.6020104@icdsoft.com> <1321391355.2602.0.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from icdsoft.com ([64.14.68.165]:36826 "EHLO us.icdsoft.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753136Ab1KPWcU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Nov 2011 17:32:20 -0500
In-Reply-To: <1321391355.2602.0.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/15/2011 11:09 PM, Eric Dumazet wrote:
> Le mardi 15 novembre 2011 =E0 22:23 +0200, Ivan Zahariev a =E9crit :
>> Hello,
>>
>> We have changed nothing in our network infrastructure but only upgra=
ded
>> from Linux kernel 2.6.36.2 to 3.0.3. Here is the problem we are
>> experiencing:
>>
>> ICMP redirected routes are cached forever, and they can be cleared o=
nly
>> by a reboot.
>>
>> Here is an example:
>>
>> root@machine5:~# ip route get 1.1.1.1
>> 1.1.1.1 via 9.0.0.1 dev eth0  src 5.5.5.5
>>       cache<redirected>   ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 1=
0
>>
>> root@machine5:~# ip route list cache match 1.1.1.1
>> 1.1.1.1 tos lowdelay via 9.0.0.1 dev eth0  src 5.5.5.5
>>       cache<redirected>   ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 1=
0
>> 1.1.1.1 via 9.0.0.1 dev eth0  src 5.5.5.5
>>       cache<redirected>   ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 1=
0
>> ...(two more entries, all go via 9.0.0.1)...
>>
>> 1.1.1.1 is the test destination address
>> 5.5.5.5 is the source IP address of "machine5" via dev eth0, the onl=
y
>> interface besides "lo"
>> 9.0.0.1 is the incorrect gateway which we were redirected to; we wan=
t to
>> change the route to 9.0.0.8
>>
>> I found no way to clear this route. What I tried:
>>
>> root@machine5:~# ip route flush cache ### CACHE FLUSH ###
>> root@machine5:~# ip route list cache match 1.1.1.1 # empty
>>
>> root@machine5:~# ip route flush cache ### CACHE FLUSH ###
>> root@machine5:~# echo 1>  /proc/sys/net/ipv4/route/flush
>> root@machine5:~# ip route list cache match 1.1.1.1 # empty
>>
>> root@machine5:~# ip route get 1.1.1.1 # magically re-inserts the
>> <redirected>  route, tcpdump sees NO ICMP traffic
>> 1.1.1.1 via 9.0.0.1 dev eth0  src 5.5.5.5
>>       cache<redirected>   ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 1=
0
>>
>> I also tried to force a scheduled route flush:
>>
>> root@machine5:~# echo 1>  /proc/sys/net/ipv4/route/gc_timeout
>> root@machine5:~# echo 1>  /proc/sys/net/ipv4/route/gc_interval
>>
>> A reboot fixed it all.
>>
>> This may be related to the "Several major changes to our routing
>> infrastructure" (https://lkml.org/lkml/2011/3/16/384).
>> Other users are reporting the same problem:
>> * https://plus.google.com/u/0/117161704068825702652/posts/1UK1Rp4KA4=
J
>> * http://lists.debian.org/debian-kernel/2011/10/msg00633.html
>> Other similar issues:
>> * http://www.spinics.net/lists/netdev/msg176966.html
>> * http://forums.gentoo.org/viewtopic-t-901024-start-0.html
>>
>> This has been occurring on a few KVM guest machines and also on a
>> regular Linux machine, so it's not KVM related.
>>
>> Is this a bug, or it's me who's missing something?
>>
> It is a bug, and as such could you provide needed information for us =
to
> reproduce it ?
>
> What is your network setup ?

Network setup is nothing fancy. We have the following machines on a=20
single /24 ethernet segment:
* 192.168.0.244 (machine5) -- the machine on which we reproduce the=20
kernel routing bug; kernel: 3.0.3-grsec
* 192.168.0.8   (router8)  -- the default gw for the whole=20
192.168.0.0/24 network; does SNAT; kernel: 2.6.32-5-686
* 192.168.0.120 -- another host with disabled ip_forwarding; must be up=
=20
and reachable

There are two bugs actually:
1. Basically, *any* ICMP redirect is cached forever.
2. The output of "ip route" is not consistent with the kernel's routing=
=20
behavior.

Quick fix: Disabling "net.ipv4.conf.*.accept_redirects" on all=20
interfaces works OK and prevents ICMP redirects from affecting the=20
internal route cache.

Here is a sample test-case scenario:

### right after a clean machine reboot
root@machine5:~# ip route list cache match 8.8.4.4

root@machine5:~# ip route get 8.8.4.4
8.8.4.4 via 192.168.0.8 dev eth0  src 192.168.0.244
     cache

### make a TCP request; the TCP packets go to the default gw=20
192.168.0.8; we see this with a tcpdump at 192.168.0.8
root@machine5:~# telnet 8.8.4.4

### route is still OK and as expected
root@machine5:~# ip route list cache match 8.8.4.4
8.8.4.4 from 192.168.0.244 tos lowdelay via 192.168.0.8 dev eth0
     cache  ipid 0x303a
8.8.4.4 tos lowdelay via 192.168.0.8 dev eth0  src 192.168.0.244
     cache  ipid 0x303a
8.8.4.4 via 192.168.0.8 dev eth0  src 192.168.0.244
     cache

root@machine5:~# ip route get 8.8.4.4
8.8.4.4 via 192.168.0.8 dev eth0  src 192.168.0.244
     cache

### change route to a fake host on the same subnet, so that an ICMP=20
redirect will follow later
### we also disable NAT for 192.168.0.244, so that an ICMP redirect is=20
sent accordingly
root@router8:~# route add -host 8.8.4.4 gw 192.168.0.120

### first TCP packet goes to the default gw 192.168.0.8; we see this=20
with a tcpdump at 192.168.0.8
root@machine5:~# telnet 8.8.4.4

### at machine5: we got the ICMP redirect from the default gw, as expec=
ted
# tcpdump: IP 192.168.0.8 > 192.168.0.244: ICMP redirect 8.8.4.4 to hos=
t=20
192.168.0.120, length 68

### the TCP packets now start to use the <redirected> route=20
192.168.0.120; we see this with a tcpdump at 192.168.0.120
root@machine5:~# telnet 8.8.4.4

### (bug #2) what "ip route" returns is inconsistent, because we are=20
using the <redirected> route 192.168.0.120 in reality
### note that the count of the route lines increased with one
root@machine5:~# ip route list cache match 8.8.4.4
8.8.4.4 from 192.168.0.244 tos lowdelay via 192.168.0.8 dev eth0
     cache  ipid 0x303a
8.8.4.4 tos lowdelay via 192.168.0.8 dev eth0  src 192.168.0.244
     cache  ipid 0x303a
8.8.4.4 via 192.168.0.8 dev eth0  src 192.168.0.244
     cache
8.8.4.4 from 192.168.0.244 tos lowdelay via 192.168.0.8 dev eth0
     cache  ipid 0x303a

root@machine5:~# ip route get 8.8.4.4
8.8.4.4 via 192.168.0.8 dev eth0  src 192.168.0.244
     cache

### restore the route on the default gw 192.168.0.8, so that it accepts=
=20
8.8.4.4 as destination again
### restore NAT for 192.168.0.244
root@router8:~# route del -host 8.8.4.4 gw 192.168.0.120

### (bug #1) even though we flushed the route cache, the <redirected>=20
route resurrects from somewhere; even without making any TCP requests
### this time what "ip" returns is consistent with the real (incorrect)=
=20
routing behavior of machine5
root@machine5:~# ip route flush cache
root@machine5:~# ip route list cache match 8.8.4.4
root@machine5:~# ip route get 8.8.4.4
8.8.4.4 via 192.168.0.120 dev eth0  src 192.168.0.244
     cache <redirected>  ipid 0x303a

### the TCP packets STILL use the <redirected> route 192.168.0.120; we=20
see this with a tcpdump at 192.168.0.120
root@machine5:~# telnet 8.8.4.4

### only a reboot clears the cached <redirected> routes


Cheers.
--Ivan
