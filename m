From: Marc Haber <mh+netdev@zugschlus.de>
Subject: Re: IPv6 route to gateway on fe80::1%eth0 when I have fe80::1%br0
 locally
Date: Mon, 22 Feb 2016 16:04:43 +0100
Message-ID: <20160222150443.GV26042@torres.zugschlus.de>
References: <20151212195830.GA18286@torres.zugschlus.de>
 <56796902.8080703@stressinduktion.org>
 <20151222212843.GE4424@torres.zugschlus.de>
 <5679C58C.2090308@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from torres.zugschlus.de ([85.214.131.164]:48108 "EHLO
	torres.zugschlus.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752474AbcBVPgu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Feb 2016 10:36:50 -0500
Content-Disposition: inline
In-Reply-To: <5679C58C.2090308@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Hannes,

On Tue, Dec 22, 2015 at 10:50:04PM +0100, Hannes Frederic Sowa wrote:
> Thanks but no need to do that, I already cooked a patch and will submit
> tomorrow after some testing. We don't need to enhance the sysctl,
> default should be to simply check the interface too if a route with
> link-local address is received.

Kernel bugzilla #112751 is related to this.

The following is snipped to the relevant parts and was obtained on a
Debian system running kernel 4.4.2

[1/501]mh@fan:~$ for f in /proc/sys/net/ipv6/conf/*/{accept_ra,accept_ra_from_local,forwarding}; do echo $f; cat $f; done
/proc/sys/net/ipv6/conf/all/accept_ra
1
/proc/sys/net/ipv6/conf/br0/accept_ra
0
/proc/sys/net/ipv6/conf/default/accept_ra
1
/proc/sys/net/ipv6/conf/eth0/accept_ra
2
/proc/sys/net/ipv6/conf/all/accept_ra_from_local
0
/proc/sys/net/ipv6/conf/br0/accept_ra_from_local
0
/proc/sys/net/ipv6/conf/default/accept_ra_from_local
0
/proc/sys/net/ipv6/conf/eth0/accept_ra_from_local
1
[2/502]mh@fan:~$ ip a
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    inet6 2a01:238:4071:328d:5604:a6ff:fe82:2100/64 scope global mngtmpaddr noprefixroute dynamic
       valid_lft 86038sec preferred_lft 14038sec
    inet6 2a01:238:4071:3282:5604:a6ff:fe82:2100/64 scope global mngtmpaddr noprefixroute dynamic
       valid_lft 86372sec preferred_lft 14372sec
3: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP group default qlen 1000
    inet6 2a01:238:4071:328d::1d:153/64 scope global
       valid_lft forever preferred_lft forever
    inet6 2a01:238:4071:328d::1d:100/64 scope global
       valid_lft forever preferred_lft forever
[3/503]mh@fan:~$ ip -6 r
default via fe80::1 dev eth0  proto ra  metric 1024  pref medium
default via fe80::c4f4:98ff:fedc:5e21 dev eth0  proto ra  metric 1024  pref medium
[4/504]mh@fan:~$

In prose:

The host is a host for KVM VMs. It receives IPv6 connectivity via RA
on eth0, where the default gateway announces its address as fe80::1.
It also provides IPv6 connectivity to the VMs via the br0 interface.
It is running radvd on br0, and for statically configured VMs it has
also fe80::1 on br0.

If accept_ra_from_local on eth0 were 0, the system would not accept
the RA from the default gateway and and up with no IPv6 since fe80::1
is locally configured with br0.

If accept_ra_from_local on eth0 is 1, the system accepts both the RA
from the default gateway on eth0 _AND_ its own RA sent out and
received on br0, and, making things worse, is setting the IP address
and default route not on br0, but on eth0.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Leimen, Germany    |  lose things."    Winona Ryder | Fon: *49 6224 1600402
Nordisch by Nature |  How to make an American Quilt | Fax: *49 6224 1600421
