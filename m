From: Alexey Ivanov <rbtz@yandex-team.ru>
Subject: Re: IPv6 flapping with kernel 3.3 (regression from 3.2.9)
Date: Fri, 25 May 2012 13:02:06 +0400
Message-ID: <43071337936526@webcorp7.yandex-team.ru>
References: <20120322073428.GA11510@torres.zugschlus.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Marc Haber <mh+linux-kernel@zugschlus.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120322073428.GA11510@torres.zugschlus.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday, March 22, 2012 12:20:02 PM UTC+4, Marc Haber wrote:
> Hi,
> 
> I have a host which has IPv6 misbehaving when running with Linux 3.3.
> It is flawlessly working with Linux 3.2.9.
> 
> The host
> - is running Debian stable (x64_64) with a few locally built and/or
>   backported packages, including the kernel.
> - has native IPv6 connectivity on eth0
> - is not doing SLAAC on eth0, both IP address (from 2a01/16) and
>   default gateway (fe80::1) are statically configured
> - is running a handful of VMs using KVM/libvirt
> - has IPv6 forwarding enabled
> - does IPv4 NAT
> - has a handful of iptables rules, both for v4 and v6. ICMP and ICMPv6
>   are fully open
> 
> - the gateway is not under my control
> - the VMs are either bridged to br0 or to br1
> - both br0 and br1 have an IPv6 /64 and radvd running to provide IPv6
>   to the VMs
> 
> This setup is unique in my machine list, my other machines either are
> no KVM hosts or do only have IPv6 tunneled.
> 
> When I run the box with kernel 3.3, it drops off the IPv6 network
> every few minutes and is not responding to pings any more. This state
> stays like 30 seconds to a minute and then IPv6 resumes. It looks to
> me that the box does not lose its default route though. Once in a
> while, I see "fe80::1 dev eth0  router FAILED" in the ip neigh output.

I think I observe similar problem on some of our boxes:
IPv6 default router on vlan gets stuck at FAILED state until I ping it.


I'm pinging some host on vlan763 and keep getting "Destination unreachable: No route":

user@host:~$ ping6 2a02:0000:0:a00::4d58:1602
PING 2a02:0000:0:a00::4d58:1602(2a02:0000:0:a00::4d58:1602) 56 data bytes
>From 2a02:0000:0:200::5 icmp_seq=1 Destination unreachable: No route
>From 2a02:0000:0:200::5 icmp_seq=2 Destination unreachable: No route
^C
--- 2a02:0000:0:a00::4d58:1602 ping statistics ---
2 packets transmitted, 0 received, +2 errors, 100% packet loss, time 1001ms


Somehow route happens to be eth2:

user@host:~$ ip route get 2a02:0000:0:a00::4d58:1602
2a02:0000:0:a00::4d58:1602 from :: via 2a02:0000:0:88d:: dev eth2  src 2a02:0000:0:88d:215:17ff:feb8:3b62  metric 0 
    cache  mtu 1450 advmss 1390


But routing table says it should be on vlan763:

user@host:~$ ip -6 route 
.. snip ...
2a02:0000:0:a0b::/64 dev vlan763  proto kernel  metric 256 
2a02:0000:0:a00::/59 via 2a02:0000:0:a0b::1 dev vlan763  metric 1024  mtu 8950 advmss 8890
.. snip ...
default via 2a02:0000:0:88d:: dev eth2  metric 1024  mtu 1450 advmss 1390
default via fe80::225:90ff:fe06:223c dev eth2  proto kernel  metric 1024  expires 0sec


Here is our culprit - default router on vlan763 is marked as FAILED:

user@host:~$ ip -6 neigh
fe80::225:90ff:fe06:223c dev eth2 lladdr 00:25:90:06:22:3c router REACHABLE
2a02:0000:0:88d:: dev eth2 lladdr 00:25:90:06:22:3c router STALE
2a02:0000:0:a0b::1 dev vlan763  router FAILED


Now lets ping it:

user@host:~$ ping6 2a02:0000:0:a0b::1
PING 2a02:0000:0:a0b::1(2a02:0000:0:a0b::1) 56 data bytes
64 bytes from 2a02:0000:0:a0b::1: icmp_seq=1 ttl=64 time=2.62 ms
64 bytes from 2a02:0000:0:a0b::1: icmp_seq=2 ttl=64 time=47.8 ms
64 bytes from 2a02:0000:0:a0b::1: icmp_seq=3 ttl=64 time=0.341 ms
..snip...
^C
--- 2a02:0000:0:a0b::1 ping statistics ---
5 packets transmitted, 5 received, 0% packet loss, time 4003ms
rtt min/avg/max/mdev = 0.330/10.303/47.801/18.769 ms


Now everything is back to normal.
Router is REACHABLE:

user@host:~$ ip -6 neigh
fe80::225:90ff:fe06:223c dev eth2 lladdr 00:25:90:06:22:3c router STALE
fe80::224:50ff:fe5b:e400 dev vlan763 lladdr 00:24:50:5b:e4:00 DELAY
2a02:0000:0:88d:: dev eth2 lladdr 00:25:90:06:22:3c router STALE
2a02:0000:0:a0b::1 dev vlan763 lladdr 00:24:50:5b:e4:00 router REACHABLE


Route is on vlan763:

user@host:~$ ip route get 2a02:0000:0:a00::4d58:1602
2a02:0000:0:a00::4d58:1602 from :: via 2a02:0000:0:a0b::1 dev vlan763  src 2a02:0000:0:a0b::5f6c:9c1a  metric 0 
    cache  mtu 8950 advmss 8890


And I can finally ping hosts on the other side of the router:

user@host:~$ ping6 2a02:0000:0:a00::4d58:1602
PING 2a02:0000:0:a00::4d58:1602(2a02:0000:0:a00::4d58:1602) 56 data bytes
64 bytes from 2a02:0000:0:a00::4d58:1602: icmp_seq=1 ttl=62 time=1.82 ms
64 bytes from 2a02:0000:0:a00::4d58:1602: icmp_seq=2 ttl=62 time=1.77 ms
64 bytes from 2a02:0000:0:a00::4d58:1602: icmp_seq=3 ttl=62 time=1.83 ms
..snip...
^C
--- 2a02:0000:0:a00::4d58:1602 ping statistics ---
9 packets transmitted, 9 received, 0% packet loss, time 8014ms
rtt min/avg/max/mdev = 1.511/1.671/1.852/0.141 ms


Kernel is:
Linux 3.2.0-23-server x86_64
This is copy of ubuntu 12.04 generic flavor with set of TCP patches that do not affect ND/routing: https://gist.github.com/2407652

user@host:~$ grep IPV6 /boot/config-3.2.0-23-server 
CONFIG_IPV6=y
CONFIG_IPV6_PRIVACY=y
CONFIG_IPV6_ROUTER_PREF=y
CONFIG_IPV6_ROUTE_INFO=y
# CONFIG_IPV6_OPTIMISTIC_DAD is not set
CONFIG_IPV6_MIP6=m
CONFIG_IPV6_SIT=m
CONFIG_IPV6_SIT_6RD=y
CONFIG_IPV6_NDISC_NODETYPE=y
CONFIG_IPV6_TUNNEL=m
CONFIG_IPV6_MULTIPLE_TABLES=y
CONFIG_IPV6_SUBTREES=y
CONFIG_IPV6_MROUTE=y
CONFIG_IPV6_MROUTE_MULTIPLE_TABLES=y
CONFIG_IPV6_PIMSM_V2=y

Sysctls:
net.ipv6.conf.all.accept_ra = 0
net.ipv6.conf.all.autoconf = 0

> 
> Running a continuous ping in either direction doesn't seem to help.
> 
> Booting the box back to 3.2.9 immediately fixes the issue.
> 
> I have not yet re-tried going back to 3.3 since a few of the VMs are
> too important to reboot again today. I tried running tcpdump on eth0
> over night but hit br1 instead, so I don't have any packet dumps to
> show.
> 
> I guess that something goes wrong with neighbor detection regarding
> the IPv6 gateway.
> 
> Was there a relevant change between 3.2.9 and 3.3? Where do I look for
> the issue?
> 
> Greetings
> Marc
> 
> -- 
> -----------------------------------------------------------------------------
> Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
> Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 31958061
> Nordisch by Nature |  How to make an American Quilt | Fax: *49 621 31958062
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Alexey Ivanov
Yandex Search Admin Team
*************
tel.: +7 (985) 120-35-83 (int. 7176)
http://staff.yandex-team.ru/rbtz
*************
