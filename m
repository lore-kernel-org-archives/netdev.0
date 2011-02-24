From: Valdis.Kletnieks@vt.edu
Subject: linux-next IPv4 connect() call to dest routed over ppp broken
Date: Thu, 24 Feb 2011 01:27:45 -0500
Message-ID: <18288.1298528865@localhost>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1298528865_6002P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1298528865_6002P
Content-Type: text/plain; charset=us-ascii

l2.6.38-rc5-next-20110222 is giving me trouble with network - specifically IPv4
routed over a PPP link.  IPv6 seems to be OK, as does IPv4 not over PPP.
Problem entered sometime after -rc2-mmotm0125 (I didn't try -rc3 or -rc4 due to
time constraints that kept me from chasing down a different problem I had).

I'm at home, so I bring up a PPP link to our VPN endpoint, and route 2 /16s
via the PPP connection.  So ifconfig and routing look like this:

ppp0      Link encap:Point-to-Point Protocol  
          inet addr:128.173.34.98  P-t-P:128.173.32.21  Mask:255.255.255.255
          inet6 addr: 2001:468:c80:3b05:9559:2833:c9c6:4910/64 Scope:Global
          inet6 addr: fe80::9559:2833:c9c6:4910/10 Scope:Link
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1460  Metric:1
          RX packets:19709 errors:0 dropped:0 overruns:0 frame:0
          TX packets:14189 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:3 
          RX bytes:20541163 (19.5 MiB)  TX bytes:1294777 (1.2 MiB)

wlan0     Link encap:Ethernet  HWaddr 00:24:D6:53:C5:BA  
          inet addr:192.168.2.2  Bcast:192.168.2.255  Mask:255.255.255.0
          inet6 addr: fe80::224:d6ff:fe53:c5ba/64 Scope:Link
          UP BROADCAST RUNNING MULTICAST  MTU:1500  Metric:1
          RX packets:209585 errors:0 dropped:3 overruns:0 frame:0
          TX packets:205993 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000 
          RX bytes:169153434 (161.3 MiB)  TX bytes:105289986 (100.4 MiB)

% ip route show
default via 192.168.2.1 dev wlan0  metric 2 
128.173.0.0/16 dev ppp0  scope link 
128.173.32.21 via 192.168.2.1 dev wlan0  src 192.168.2.2 
128.173.32.21 dev ppp0  proto kernel  scope link  src 128.173.34.98 
192.168.2.0/24 dev wlan0  proto kernel  scope link  src 192.168.2.2 
198.82.0.0/16 dev ppp0  scope link 

strace ntpdate -q 198.82.1.201 (an NTP server of ours, UDP over ppp0):
....
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 3
connect(3, {sa_family=AF_INET, sin_port=htons(123), sin_addr=inet_addr("198.82.1.201")}, 16) = -1 EINVAL (Invalid argument)
.. and we're dead.

strace ping 198.82.1.201 (ICMP this time, over ppp0):
...
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
connect(4, {sa_family=AF_INET, sin_port=htons(1025), sin_addr=inet_addr("198.82.1.201")}, 16) = -1 EINVAL (Invalid argument)
and things fall over from there...

strace telnet telnet 198.82.161.192 25   (does TCP work?  SMTP to a mail host of ours)
...
socket(PF_INET, SOCK_STREAM, IPPROTO_TCP) = 3
setsockopt(3, SOL_IP, IP_TOS, [16], 4)  = 0
connect(3, {sa_family=AF_INET, sin_port=htons(25), sin_addr=inet_addr("198.82.161.192")}, 16) = -1 EINVAL (Invalid argument)

Not looking good for the home team, but going to hosts not routed via the PPP interface
works just fine:

strace ping www.google.com (goes out via wlan0 directly)
....
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
connect(4, {sa_family=AF_INET, sin_port=htons(1025), sin_addr=inet_addr("72.14.204.99")}, 16) = 0
getsockname(4, {sa_family=AF_INET, sin_port=htons(60231), sin_addr=inet_addr("192.168.2.2")}, [16]) = 0

If I take down the ppp link, my routing table looks like:

% ip route show
default via 192.168.2.1 dev wlan0  metric 2 
128.173.32.21 via 192.168.2.1 dev wlan0  src 192.168.2.2 
192.168.2.0/24 dev wlan0  proto kernel  scope link  src 192.168.2.2 

and IPv4 to the problem addresses starts working:

strace ping 198.82.1.201  (via wlan0 directly):
...
socket(PF_INET, SOCK_DGRAM, IPPROTO_IP) = 4
connect(4, {sa_family=AF_INET, sin_port=htons(1025), sin_addr=inet_addr("198.82.1.201")}, 16) = 0
getsockname(4, {sa_family=AF_INET, sin_port=htons(60404), sin_addr=inet_addr("192.168.2.2")}, [16]) = 0

Any ideas? I'll probably not have a chance to bisect this for several days...

--==_Exmh_1298528865_6002P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFNZfphcC3lWbTT17ARAtmjAKCiLq5ro6FynN2xcnQG0r+HySUlyACeMnhw
jfv0OxL8abRzdJyroKwRnyU=
=8nAf
-----END PGP SIGNATURE-----

--==_Exmh_1298528865_6002P--
