From: Rob Townley <rob.townley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Ping Is Broken
Date: Fri, 9 Oct 2009 11:44:31 -0500
Message-ID: <7e84ed60910090944q5c66ea0w63ed55a72482bf2f@mail.gmail.com>
References: <7e84ed60910090316ne9224fat81d9c79c58fc713b@mail.gmail.com>
	<7e84ed60910090934y2a0d422cr158aa8d15e452f97@mail.gmail.com>
Reply-To: CentOS mailing list <centos-IFYaIzF+flcdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: CentOS mailing list <centos-IFYaIzF+flcdnm+yROfE0A@public.gmane.org>,
	Omaha Linux User Group <olug-u8lKhlSLHjY@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <centos-bounces-IFYaIzF+flcdnm+yROfE0A@public.gmane.org>
In-Reply-To: <7e84ed60910090934y2a0d422cr158aa8d15e452f97-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://lists.centos.org/mailman/listinfo/centos>,
	<mailto:centos-request-IFYaIzF+flcdnm+yROfE0A@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.centos.org/pipermail/centos>
List-Post: <mailto:centos-IFYaIzF+flcdnm+yROfE0A@public.gmane.org>
List-Help: <mailto:centos-request-IFYaIzF+flcdnm+yROfE0A@public.gmane.org?subject=help>
List-Subscribe: <http://lists.centos.org/mailman/listinfo/centos>,
	<mailto:centos-request-IFYaIzF+flcdnm+yROfE0A@public.gmane.org?subject=subscribe>
Sender: centos-bounces-IFYaIzF+flcdnm+yROfE0A@public.gmane.org
Errors-To: centos-bounces-IFYaIzF+flcdnm+yROfE0A@public.gmane.org
List-Id: netdev.vger.kernel.org

ping -I is broken

The following deals with bug in ping that made it very difficult to set up a
system with two gateways.

Demonstration that *ping -I is broken*. When specifying the source
interface using -I with an *ethX* alias and that interface is not the
default gateway
interface, then ping fails. When specifying the interface as an ip address,
ping works. Search for "Destination Host Unreachable" to find the bug.


eth*0* = 4.3.2.8 and the default gateway is accessed through a different
interface eth*1*.
eth*1* = 192.168.168.155 is used as the device to get to the default
gateway.
*FAILS *: ping *-I eth0* 208.67.222.222
*WORKS*: ping *-I 4.3.2.8* 208.67.222.222
*WORKS*: ping *-I eth1* 208.67.222.222
*WORKS*: ping *-I 192.168.168.155* 208.67.222.222

The following are actual results which can be reproduced from an up-to-date
Fedora 11 or CentOS 5.3 box. Caused a very very long episode of frustration
when setting up multi gatewayed systems.


* ping using eth0 *:

ping -c 2 -B -I  eth0 208.67.222.222
PING 208.67.222.222 (208.67.222.222) from 4.3.2.8 eth0: 56(84) bytes of data.
>From 4.3.2.8 icmp_seq=1 Destination Host Unreachable
>From 4.3.2.8 icmp_seq=2 Destination Host Unreachable

--- 208.67.222.222 ping statistics ---
2 packets transmitted, 0 received, +2 errors, 100% packet loss, time 999ms
, pipe 2

--------------------------------------
The Following all WORK:
* ping using 4.3.2.8 *:

ping -c 2 -B -I  4.3.2.8 208.67.222.222
PING 208.67.222.222 (208.67.222.222) from 4.3.2.8 : 56(84) bytes of data.
64 bytes from 208.67.222.222: icmp_seq=1 ttl=55 time=562 ms
64 bytes from 208.67.222.222: icmp_seq=2 ttl=55 time=642 ms

--- 208.67.222.222 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 562.546/602.400/642.255/39.862 ms


* ping using eth1 *:

ping -c 2 -B -I  eth1 208.67.222.222
PING 208.67.222.222 (208.67.222.222) from 192.168.168.155 eth1: 56(84)
bytes of data.
64 bytes from 208.67.222.222: icmp_seq=1 ttl=54 time=270 ms
64 bytes from 208.67.222.222: icmp_seq=2 ttl=54 time=629 ms

--- 208.67.222.222 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 1000ms
rtt min/avg/max/mdev = 270.128/449.766/629.405/179.639 ms


* ping using 192.168.168.155 *:

ping -c 2 -B -I  192.168.168.155 208.67.222.222
PING 208.67.222.222 (208.67.222.222) from 192.168.168.155 : 56(84)
bytes of data.
64 bytes from 208.67.222.222: icmp_seq=1 ttl=54 time=585 ms
64 bytes from 208.67.222.222: icmp_seq=2 ttl=54 time=554 ms

--- 208.67.222.222 ping statistics ---
2 packets transmitted, 2 received, 0% packet loss, time 999ms
rtt min/avg/max/mdev = 554.098/569.655/585.212/15.557 ms

My source route policy rules:

/sbin/ip rule show
0:	from all lookup 255
32762:	from 4.3.2.8 lookup nic0
32763:	from 192.168.168.155 lookup nic1
32764:	from 192.168.168.155 lookup nic1
32765:	from 4.3.2.8 lookup nic0
32766:	from all lookup main
32767:	from all lookup default



Print out routing tables using /sbin/ip route show table TABLENAME:
routing table  nic0 :
/sbin/ip route show table nic0
default via 4.3.2.1 dev eth0

routing table  nic1 :
/sbin/ip route show table nic1
default via 192.168.168.1 dev eth1

routing table  main :
/sbin/ip route show table main
4.3.2.1/27 dev eth0  proto kernel  scope link  src 4.3.2.8
192.168.168.0/24 dev eth1  proto kernel  scope link  src 192.168.168.155
169.254.0.0/16 dev eth1  scope link
default via 192.168.168.1 dev eth1

routing table  default :
/sbin/ip route show table default




NOTES: cat /etc/iproute2/rt_tables to get your own table names.

ping Maintainer YOSHIFUJI Hideaki / USAGI/WIDE Project
 http://www.skbuff.net/iputils/
Mailing List netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org

man ping:
   -I interface address
        Set source address to specified interface address.
        Argument may be *numeric IP address or name of device*.
        When  pinging  IPv6  link-local  address  this option is required.

ping -V returns the latest available on CentOS and Fedora and the
maintainers website:
ping utility, iputils-ss020927
