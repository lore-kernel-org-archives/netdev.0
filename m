From: Ivan Zahariev <famzah@icdsoft.com>
Subject: Unable to flush ICMP redirect routes in kernel 3.0+
Date: Tue, 15 Nov 2011 22:23:46 +0200
Message-ID: <4EC2CA52.6020104@icdsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from icdsoft.com ([64.14.68.165]:39247 "EHLO us.icdsoft.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932120Ab1KOUaa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Nov 2011 15:30:30 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

We have changed nothing in our network infrastructure but only upgraded 
from Linux kernel 2.6.36.2 to 3.0.3. Here is the problem we are 
experiencing:

ICMP redirected routes are cached forever, and they can be cleared only 
by a reboot.

Here is an example:

root@machine5:~# ip route get 1.1.1.1
1.1.1.1 via 9.0.0.1 dev eth0  src 5.5.5.5
     cache <redirected>  ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 10

root@machine5:~# ip route list cache match 1.1.1.1
1.1.1.1 tos lowdelay via 9.0.0.1 dev eth0  src 5.5.5.5
     cache <redirected>  ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 10
1.1.1.1 via 9.0.0.1 dev eth0  src 5.5.5.5
     cache <redirected>  ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 10
...(two more entries, all go via 9.0.0.1)...

1.1.1.1 is the test destination address
5.5.5.5 is the source IP address of "machine5" via dev eth0, the only 
interface besides "lo"
9.0.0.1 is the incorrect gateway which we were redirected to; we want to 
change the route to 9.0.0.8

I found no way to clear this route. What I tried:

root@machine5:~# ip route flush cache ### CACHE FLUSH ###
root@machine5:~# ip route list cache match 1.1.1.1 # empty

root@machine5:~# ip route flush cache ### CACHE FLUSH ###
root@machine5:~# echo 1 > /proc/sys/net/ipv4/route/flush
root@machine5:~# ip route list cache match 1.1.1.1 # empty

root@machine5:~# ip route get 1.1.1.1 # magically re-inserts the 
<redirected> route, tcpdump sees NO ICMP traffic
1.1.1.1 via 9.0.0.1 dev eth0  src 5.5.5.5
     cache <redirected>  ipid 0xfb5d rtt 1475ms rttvar 450ms cwnd 10

I also tried to force a scheduled route flush:

root@machine5:~# echo 1 > /proc/sys/net/ipv4/route/gc_timeout
root@machine5:~# echo 1 > /proc/sys/net/ipv4/route/gc_interval

A reboot fixed it all.

This may be related to the "Several major changes to our routing 
infrastructure" (https://lkml.org/lkml/2011/3/16/384).
Other users are reporting the same problem:
* https://plus.google.com/u/0/117161704068825702652/posts/1UK1Rp4KA4J
* http://lists.debian.org/debian-kernel/2011/10/msg00633.html
Other similar issues:
* http://www.spinics.net/lists/netdev/msg176966.html
* http://forums.gentoo.org/viewtopic-t-901024-start-0.html

This has been occurring on a few KVM guest machines and also on a 
regular Linux machine, so it's not KVM related.

Is this a bug, or it's me who's missing something?

Thanks.
--Ivan
