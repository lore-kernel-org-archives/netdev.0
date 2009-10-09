From: Rob Townley <rob.townley-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Ping Is Broken
Date: Fri, 9 Oct 2009 11:34:35 -0500
Message-ID: <7e84ed60910090934y2a0d422cr158aa8d15e452f97@mail.gmail.com>
References: <7e84ed60910090316ne9224fat81d9c79c58fc713b@mail.gmail.com>
Reply-To: CentOS mailing list <centos-IFYaIzF+flcdnm+yROfE0A@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0386000311=="
Cc: CentOS mailing list <centos-IFYaIzF+flcdnm+yROfE0A@public.gmane.org>,
	Omaha Linux User Group <olug-u8lKhlSLHjY@public.gmane.org>
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <centos-bounces-IFYaIzF+flcdnm+yROfE0A@public.gmane.org>
In-Reply-To: <7e84ed60910090316ne9224fat81d9c79c58fc713b-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
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

--===============0386000311==
Content-Type: multipart/alternative; boundary=00c09f8e5ba2cd6eed047583278d

--00c09f8e5ba2cd6eed047583278d
Content-Type: text/plain; charset=ISO-8859-1

The following deals with bug in ping that made it very difficult to set up a
system with two gateways.

ping -I is broken

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

--00c09f8e5ba2cd6eed047583278d
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

The following deals with bug in ping that made it very difficult to set up =
a system with two gateways.=A0 <br><br><h1>ping -I is broken</h1> <br>
<br>
Demonstration that <b>ping -I is broken</b>.  When specifying the source <b=
r>
interface using -I with an <b>ethX</b> alias and that interface is not the =
default gateway <br>
interface, then ping fails.  When specifying the interface as an ip address=
, <br>
ping works.  Search for &quot;Destination Host Unreachable&quot; to find th=
e bug. <br>
<br>
<br>
eth<u>0</u> =3D 4.3.2.8 and the default gateway is accessed through a diffe=
rent interface eth<u>1</u>. <br>
eth<u>1</u> =3D 192.168.168.155 is used as the device to get to the default=
 gateway. <br>
<b>FAILS=A0</b>: ping <b>-I eth0</b> 208.67.222.222 <br>
<b>WORKS</b>: ping <b>-I 4.3.2.8</b> 208.67.222.222 <br>
<b>WORKS</b>: ping <b>-I eth1</b> 208.67.222.222 <br>
<b>WORKS</b>: ping <b>-I 192.168.168.155</b> 208.67.222.222 <br>
<br>
The following are actual results which can be reproduced from an up-to-date=
 <br>
Fedora 11 or CentOS 5.3 box.  Caused a very very long episode of frustratio=
n <br>
when setting up multi gatewayed systems. <br><br>
<br> <b> ping using  eth0 </b>:
<pre>ping -c 2 -B -I  eth0 208.67.222.222<br>PING 208.67.222.222 (208.67.22=
2.222) from 4.3.2.8 eth0: 56(84) bytes of data.<br>From 4.3.2.8 icmp_seq=3D=
1 Destination Host Unreachable<br>From 4.3.2.8 icmp_seq=3D2 Destination Hos=
t Unreachable<br>
<br>--- 208.67.222.222 ping statistics ---<br>2 packets transmitted, 0 rece=
ived, +2 errors, 100% packet loss, time 999ms<br>, pipe 2<br></pre>
<br> <b> ping using  4.3.2.8 </b>:
<pre>ping -c 2 -B -I  4.3.2.8 208.67.222.222<br>PING 208.67.222.222 (208.67=
.222.222) from 4.3.2.8 : 56(84) bytes of data.<br>64 bytes from <a href=3D"=
http://208.67.222.222/" target=3D"_blank">208.67.222.222</a>: icmp_seq=3D1 =
ttl=3D55 time=3D562 ms<br>
64 bytes from <a href=3D"http://208.67.222.222/" target=3D"_blank">208.67.2=
22.222</a>: icmp_seq=3D2 ttl=3D55 time=3D642 ms<br><br>--- 208.67.222.222 p=
ing statistics ---<br>2 packets transmitted, 2 received, 0% packet loss, ti=
me 999ms<br>
rtt min/avg/max/mdev =3D 562.546/602.400/642.255/39.862 ms<br></pre>
<br> <b> ping using  eth1 </b>:
<pre>ping -c 2 -B -I  eth1 208.67.222.222<br>PING 208.67.222.222 (208.67.22=
2.222) from 192.168.168.155 eth1: 56(84) bytes of data.<br>64 bytes from <a=
 href=3D"http://208.67.222.222/" target=3D"_blank">208.67.222.222</a>: icmp=
_seq=3D1 ttl=3D54 time=3D270 ms<br>
64 bytes from <a href=3D"http://208.67.222.222/" target=3D"_blank">208.67.2=
22.222</a>: icmp_seq=3D2 ttl=3D54 time=3D629 ms<br><br>--- 208.67.222.222 p=
ing statistics ---<br>2 packets transmitted, 2 received, 0% packet loss, ti=
me 1000ms<br>
rtt min/avg/max/mdev =3D 270.128/449.766/629.405/179.639 ms<br></pre>
<br> <b> ping using  192.168.168.155 </b>:
<pre>ping -c 2 -B -I  192.168.168.155 208.67.222.222<br>PING 208.67.222.222=
 (208.67.222.222) from 192.168.168.155 : 56(84) bytes of data.<br>64 bytes =
from <a href=3D"http://208.67.222.222/" target=3D"_blank">208.67.222.222</a=
>: icmp_seq=3D1 ttl=3D54 time=3D585 ms<br>
64 bytes from <a href=3D"http://208.67.222.222/" target=3D"_blank">208.67.2=
22.222</a>: icmp_seq=3D2 ttl=3D54 time=3D554 ms<br><br>--- 208.67.222.222 p=
ing statistics ---<br>2 packets transmitted, 2 received, 0% packet loss, ti=
me 999ms<br>
rtt min/avg/max/mdev =3D 554.098/569.655/585.212/15.557 ms<br></pre>
<h3>My source route policy rules:</h3>
<pre>/sbin/ip rule show<br>0:	from all lookup 255 <br>32762:	from 4.3.2.8 l=
ookup nic0 <br>32763:	from 192.168.168.155 lookup nic1 <br>32764:	from 192.=
168.168.155 lookup nic1 <br>32765:	from 4.3.2.8 lookup nic0 <br>32766:	from=
 all lookup main <br>
32767:	from all lookup default <br></pre>
<pre> <br><br>Print out routing tables using /sbin/ip route show table TABL=
ENAME:<br>routing table  nic0 :<br>/sbin/ip route show table nic0<br>defaul=
t via 4.3.2.1 dev eth0 <br><br>routing table  nic1 :<br>/sbin/ip route show=
 table nic1<br>
default via 192.168.168.1 dev eth1 <br><br>routing table  main :<br>/sbin/i=
p route show table main<br><a href=3D"http://4.3.2.1/27" target=3D"_blank">=
4.3.2.1/27</a> dev eth0  proto kernel  scope link  src 4.3.2.8 <br><a href=
=3D"http://192.168.168.0/24" target=3D"_blank">192.168.168.0/24</a> dev eth=
1  proto kernel  scope link  src 192.168.168.155 <br>
<a href=3D"http://169.254.0.0/16" target=3D"_blank">169.254.0.0/16</a> dev =
eth1  scope link <br>default via 192.168.168.1 dev eth1 <br><br>routing tab=
le  default :<br>/sbin/ip route show table default<br><br></pre> <br>
<br>
<br>
NOTES:
cat /etc/iproute2/rt_tables to get your own table names. <br>
<br>
ping Maintainer YOSHIFUJI Hideaki / USAGI/WIDE Project <br>
<a href=3D"http://www.skbuff.net/iputils/" target=3D"_blank"> http://www.sk=
buff.net/iputils/ </a> <br>
Mailing List <a href=3D"mailto:netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" target=3D"_blank">ne=
tdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org</a> <br>
<pre>man ping:<br>   -I interface address<br>        Set source address to =
specified interface address. <br>        Argument may be <b>numeric IP addr=
ess or name of device</b>.<br>        When  pinging  IPv6  link-local  addr=
ess  this option is required. <br>
</pre>
ping -V returns the latest available on CentOS and Fedora and the maintaine=
rs website: <br>
<code> <br>
ping utility, iputils-ss020927
</code> <br>
<br><div class=3D"gmail_quote"><br><br></div><br><input id=3D"gwProxy" type=
=3D"hidden"><input onclick=3D"jsCall();" id=3D"jsProxy" type=3D"hidden"><di=
v id=3D"refHTML"></div>

--00c09f8e5ba2cd6eed047583278d--

--===============0386000311==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
CentOS mailing list
CentOS-IFYaIzF+flcdnm+yROfE0A@public.gmane.org
http://lists.centos.org/mailman/listinfo/centos

--===============0386000311==--
