From: Boian Bonev <boian@bonev.com>
Subject: GRE Ethernet tunneling
Date: Wed,  9 Mar 2005 10:15:01 +0200
Message-ID: <20050309081501.5354.qmail@orange.bonev.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=_1_1110356101_5352"
Content-Transfer-Encoding: 8bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a MIME-formatted message.  If you see this text it means that your
E-mail software does not support MIME-formatted messages.

--=_1_1110356101_5352
Content-Type: text/plain; charset=windows-1251
Content-Transfer-Encoding: quoted-printable

hi,

first to explain why i need to make this stuff in kernel space:
 - userland ethernet tunneling provides more features like encryption but=
 not high performance and low latency
 - low MHz cpus choke on high traffic with userland tunnels (have a look =
at WRAP boards at www.pcengines.ch)
 - since we have many setups with 802.11a cards and 802.11a protocol does=
 not support direct bridging of interfaces the lack of kernel ethernet tu=
nnel limits linux use in this area

btw. mikrotik (www.mikrotik.com - a linux based closed source router os) =
implements a tunnel called eoip the gre way
btw2. 802.11a cards support mtus over 1500 so at least software fragmenta=
tion may be avoided. i am not sure what happens at lower layers but it pe=
rforms without much cpu usage increase or speed loss

before writing here i have made a concept proof - i cloned the ip_gre.c m=
odule and changed:
 - device creation to be ethernet alike (mtu 1500, ARPHRD_ETHER, hard_hea=
der, etc)
 - the protocol to be IPPROTO_GRE+1 (just for testing - not to interferre=
 with existing gre tunnels)
 - removed all code that mangled ttl, ecn, mtu etc
 - GRE protocol to 0x6558 (Ethernet over GRE)

then i dirty patched iproute to manage the new interfaces and here i disc=
overed something not very clean in interface management by iproute - when=
 listing interfaces iproute performs a SIOCGIFHWADDR and checks for ARPHR=
D_TUNNEL... this may be clean for ip tunnels but it cant work for etherne=
t tunnels.

now i am looking for a clean way to identify ethernet tunnels in iproute:=

 - if i change the type to APRHRD_TUNNEL this will break consistency with=
 both userland utils and kernel side.
 - SIOCDEVPRIVATE + x is not appropriate because it may conflict with som=
e real ethernet device
 - dev->flags are all defined
 - dev->priv_flags in not visible in userspace

i need help to choose a clean and consistent strategy for iproute <---> k=
ernel comm
then i will be able to integrate my concept proof code into ip_gre.c

another thing that comes to mind is to implement a small subset ot ethtoo=
l ioctls but this does not seem consistent to me...

b.
--=_1_1110356101_5352--
