From: Artie Hamilton <artiemhamilton@yahoo.com>
Subject: BUG: ip6tables IPv6-REDIRECT over bridges
Date: Thu, 20 Feb 2014 18:14:31 +0000 (GMT)
Message-ID: <1392920071.66303.YahooMailNeo@web172306.mail.ir2.yahoo.com>
Reply-To: Artie Hamilton <artiemhamilton@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	"\"David S. Miller\"" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"netfilter-devel@vger.kernel.org" <netfilter-devel@vger.kernel.org>,
	"netfilter@vger.kernel.org" <netfilter@vger.kernel.org>,
	"coreteam@netfilter.org" <coreteam@netfilter.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <netfilter-owner@vger.kernel.org>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I have currently following setup with three devices (actual 3 hardware =
boxes)

box1 =A0 =A0 =A0 box2 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0box3
client --> (eth0)[bridging device](eth1) --> service x


The bridging device checks the properties of "client" and maybe redirec=
ts
him to a=A0server on the bridging device (just assume HTTP for now). Th=
e
user is then=A0welcomed and some=A0instructions are shown. Before anyon=
e
asks: NO, this=A0is not a security=A0mechanism.

The bridging device is a linux device and currently works perfectly fin=
e with
IPv4 redirections. It is done (heavily simplified version) by running.

$ brctl addbr br0
$ brctl addif br0 eth0
$ brctl addif br0 eth1
$ ip addr add 192.168.1.42/24 dev br0
$ sysctl -w net.bridge.bridge-nf-call-iptables=3D1
$ iptables -t nat -A PREROUTING -p tcp -m tcp --dport 8080 -j REDIRECT =
--to-ports 81

This works perfectly fine with IPv4 services. Everyone is happy about t=
he
bridged setup and the extra functionality with special redirects for th=
is IPv4
service.

Now the same thing should be done for IPv6. It should works quite simil=
ar
(I just=A0assume the above mentioned steps are already done):

$ sysctl -w net.ipv6.conf.br0.accept_ra=3D2
$ sysctl -w net.bridge.bridge-nf-call-ip6tables=3D1
$ ip6tables -t nat -A PREROUTING -p tcp -m tcp --dport 8080 -j REDIRECT=
 --to-ports 81

But here is the problem: Connections will not be started. I see for exa=
mple
connections getting started to the service like this on the client:

$ curl -6 -D - 'http://\[2001:1234::1\]:8080/'
=2E.... nothing .....

A dump shows as first packet at tcp SYN to the service 2001:1234::1 wit=
h port
8080. And sometimes I see following too:

=A0* ICMPv6 redirect reply
=A0* SYN+ACK from fde9:....:d320 (one of the addresses of br0 but not
=A0 =A0from the actual range 2001:..../64) with port 81 !!!!!!!!!
=A0* RST from client to fde9:....:d320 with port 81

This seems to be a bug in nat or conntrack, right?

The conntrack event output show this:

=A0 =A0 [NEW] tcp =A0 =A0 =A06 120 SYN_SENT src=3D2001:...::3 sport=3D4=
9495 dport=3D8080 [UNREPLIED] src=3Dfde9:....:d320 sport=3D81 dport=3D4=
9495

I've also tried following setups:

=A0* bridge setup but DNAT to service y (some server next to service x)
=A0 =A0$ ip6tables -t nat -A PREROUTING -p tcp -m tcp --dport 8080 -j D=
NAT --to-dest [2001:1234::2]:81
=A0 =A0=3D> works
=A0* routing setup (br0 only contains eth0 and eth1 is a separate devic=
e)
=A0 =A0$ iptables -t nat -A PREROUTING -p tcp -m tcp --dport 8080 -j RE=
DIRECT --to-ports 81
=A0 =A0=3D> works

When I use curl on the IPv6 address of the bridge device (2001:1234::13=
37) then
it works on the actual server port 81 and the port which should get red=
irected
to 81 - port 8080:

$ curl -6 -D - 'http://\[2001:1234::1337)\]:81/'

HTTP/1.1 200 OK
=2E...
$ curl -6 -D - 'http://\[2001:1234::1337)\]:8080/'
HTTP/1.1 200 OK
=2E...

It really seems to be a bug when doing DNAT/REDIRECT with bridges and I=
Pv6. And
it is not possible for me to change the previously mentioned setup to a=
 routed
setup.

I've also read a little bit about TPROXY but found no good way to use i=
t
together with this bridged setup without routing rules (but worked quit=
e well in
routing).

