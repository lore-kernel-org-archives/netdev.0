From: Jeroen van Ingen <jeroen@zijndomein.nl>
Subject: Re: ipv4: broadcast sometimes leaves wrong interface (since commit
 e066008b38ca9ace1b6de8dbbac8ed460640791d)
Date: Wed, 30 Nov 2011 18:05:19 +0100
Message-ID: <1322672719.5749.36.camel@icts-sp-039>
References: <1322585087.25018.115.camel@icts-sp-039>
	 <alpine.LFD.2.00.1111300010150.2020@ja.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.utsp.utwente.nl ([130.89.2.9]:36102 "EHLO smtp.utwente.nl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757620Ab1K3RFd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Nov 2011 12:05:33 -0500
In-Reply-To: <alpine.LFD.2.00.1111300010150.2020@ja.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Julian,

Thanks for your assistance, it's very much appreciated.

> 	__ip_dev_find can cause problem if same IP is added on many
> interfaces because it uses hash table implemented with hlist.
> Old versions used only routing lookup and the routing returns
> the first created local route, i.e. the first device where this
> IP was added is returned.

Right, and all ppp interfaces get the same IP as the interface that the
clients use to connect to, which in our case is the "main" IP for the
server.

> 	And now it is risky to use __ip_dev_find in
> ip_route_output_slow when:
> 
> - saddr is provided
> - desired oif is 0
> - daddr is multicast/lbcast
> 
> 	We select oif by ignoring route ordering. May be some
> ppp device wins here because it has this saddr added last but
> is first in hlist.
> 
> 	What is the case after first client is connected, can
> you show output from:
> 
> ip addr show

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP
qlen 1000
    link/ether 00:08:02:91:c9:1f brd ff:ff:ff:ff:ff:ff
    inet 130.89.254.233/27 brd 130.89.254.255 scope global eth0
    inet 130.89.254.234/27 brd 130.89.254.255 scope global secondary
eth0:1
    inet 130.89.254.235/27 brd 130.89.254.255 scope global secondary
eth0:2
    inet 130.89.254.236/27 brd 130.89.254.255 scope global secondary
eth0:3
    inet6 fe80::208:2ff:fe91:c91f/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,PROMISC,UP,LOWER_UP> mtu 1500 qdisc mq
state UP qlen 1000
    link/ether 00:1e:0b:76:83:d6 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::21e:bff:fe76:83d6/64 scope link
       valid_lft forever preferred_lft forever
4: tap0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
master br0 state UP qlen 100
    link/ether 42:a7:29:fa:de:4a brd ff:ff:ff:ff:ff:ff
    inet6 fe80::40a7:29ff:fefa:de4a/64 scope link
       valid_lft forever preferred_lft forever
5: tap1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
master br0 state UP qlen 100
    link/ether 3e:1c:6f:5f:a2:a0 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::3c1c:6fff:fe5f:a2a0/64 scope link
       valid_lft forever preferred_lft forever
6: tap2: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
master br0 state UP qlen 100
    link/ether 6a:17:16:92:93:35 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::6817:16ff:fe92:9335/64 scope link
       valid_lft forever preferred_lft forever
7: tap3: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast
master br0 state UP qlen 100
    link/ether ce:99:a3:e6:32:cd brd ff:ff:ff:ff:ff:ff
    inet6 fe80::cc99:a3ff:fee6:32cd/64 scope link
       valid_lft forever preferred_lft forever
8: br0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state
UP
    link/ether 00:1e:0b:76:83:d6 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::21e:bff:fe76:83d6/64 scope link
       valid_lft forever preferred_lft forever
9: eth2: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 1000
    link/ether 00:1e:0b:76:83:d4 brd ff:ff:ff:ff:ff:ff
10: eth1.183@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
noqueue master br0 state UP
    link/ether 00:1e:0b:76:83:d6 brd ff:ff:ff:ff:ff:ff
    inet6 fe80::21e:bff:fe76:83d6/64 scope link
       valid_lft forever preferred_lft forever
11: eth1.184@eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc
noqueue state UP
    link/ether 00:1e:0b:76:83:d6 brd ff:ff:ff:ff:ff:ff
    inet 130.89.96.8/21 brd 130.89.103.255 scope global eth1.184
    inet6 fe80::21e:bff:fe76:83d6/64 scope link
       valid_lft forever preferred_lft forever
14: ppp0: <POINTOPOINT,MULTICAST,NOARP,UP,LOWER_UP> mtu 1400 qdisc
pfifo_fast state UNKNOWN qlen 3
    link/ppp
    inet 130.89.254.233 peer 130.89.100.119/32 scope global ppp0


> ip route list table local

broadcast 127.0.0.0 dev lo  proto kernel  scope link  src 127.0.0.1
local 127.0.0.0/8 dev lo  proto kernel  scope host  src 127.0.0.1
local 127.0.0.1 dev lo  proto kernel  scope host  src 127.0.0.1
broadcast 127.255.255.255 dev lo  proto kernel  scope link  src
127.0.0.1
broadcast 130.89.96.0 dev eth1.184  proto kernel  scope link  src
130.89.96.8
local 130.89.96.8 dev eth1.184  proto kernel  scope host  src
130.89.96.8
broadcast 130.89.103.255 dev eth1.184  proto kernel  scope link  src
130.89.96.8
broadcast 130.89.254.224 dev eth0  proto kernel  scope link  src
130.89.254.233
local 130.89.254.233 dev eth0  proto kernel  scope host  src
130.89.254.233
local 130.89.254.233 dev ppp0  proto kernel  scope host  src
130.89.254.233
local 130.89.254.234 dev eth0  proto kernel  scope host  src
130.89.254.233
local 130.89.254.235 dev eth0  proto kernel  scope host  src
130.89.254.233
local 130.89.254.236 dev eth0  proto kernel  scope host  src
130.89.254.233
broadcast 130.89.254.255 dev eth0  proto kernel  scope link  src
130.89.254.233


> 	If the above is true may be we have to find a
> way to return the first device where the IP is added.
> May be this is the main rule that is used when one adds
> same IP on many interfaces.
> 
> 	May be the solution is to convert inet_addr_lst
> from hlist to normal list, so that we can append new
> addresses at tail and __ip_dev_find to find the first
> device where IP was added.

Perhaps the solution in our case is indeed to have all PPTP clients
connect to a secondary IP on the server; then all PPP interfaces still
share the same address, but it probably won't be the address that our
server selects as source for broadcast traffic (DHCP or otherwise). We
already have a couple of secondaries on the interface in question (as
you can see in "ip addr show"). We'll try this tomorrow, it's also in
line with your later suggestion in reply to David.

Another workaround for us might be to tell Radius to use a different
source IP for the DHCP address allocation when a client connects. Just
tested with a second client, this seems to work.

I'll let you know the results tomorrow.


Regards,

Jeroen van Ingen
ICT Service Centre
University of Twente, P.O.Box 217, 7500 AE Enschede, The Netherlands
