From: =?UTF-8?Q?Fredrik_Markstr=C3=B6m?= <fredrik.markstrom@gmail.com>
Subject: Re: [PATCH 0/2] net: Set maximum receive packet size on
	veth interfaces
Date: Wed, 10 May 2017 02:38:27 +0200
Message-ID: <CAKdL+dTZ3+GMrm04W0KwcoC65KEFdeC15Ofki3jfcsN+9ZnjxA@mail.gmail.com>
References: <20170509124439.45674-1-fredrik.markstrom@gmail.com>
	<20170509.134839.2008658486655854998.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/alternative; boundary=94eb2c084c98a1abbd054f20b23c
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
	bridge@lists.linux-foundation.org, Alexei Starovoitov <ast@kernel.org>,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <20170509.134839.2008658486655854998.davem@davemloft.net>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

--94eb2c084c98a1abbd054f20b23c
Content-Type: text/plain; charset=UTF-8

On Tue, May 9, 2017 at 7:48 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Fredrik Markstrom <fredrik.markstrom@gmail.com>
> Date: Tue,  9 May 2017 14:44:36 +0200
>
> > Currently veth drops all packets larger then the mtu set on the
> > receiving end of the pair. This is inconsistent with most hardware
> > ethernet drivers.
>
> False.
>
> In fact, many pieces of ethernet hardware a not physically capable of
> sending even VLAN packets that are above the normal base ethernet MTU.
>

Maybe I was unclear, the veth implementation drops all packers larger then
the
configured MTU (on the receiving interface).
Most ethernet drivers accepts packets up to the ethernet MTU no matter the
configured MTU. As far as I can tell from the RFC:s that is ok.

A simpler solution would be to only drop packets larger then ethernet MTU
(like
most network drivers), but I guess that will break existing stuff already
out there.

The example below demonstrates what behaviour I'm referring to.

Example:
---- 8< ------
# veth0 and veth1 is a veth pair and veth1 has ben moved to a separate
network namespace.
% # NS A
% ip address add 1.2.3.4/24 dev veth0
% ip link set veth0 mtu 300 up

% # NS B
% ip address add 1.2.3.5/24 dev veth1
% ip link set veth1 mtu 1000 up
% ping -c 1 -W 1 -s 400 1.2.3.4
PING 1.2.3.4 (1.2.3.4) 400(428) bytes of data.

--- 1.2.3.4 ping statistics ---
1 packets transmitted, 0 received, 100% packet loss, time 0ms
---- 8< ------

While it works fine in most setup:s with hw-interfaces:

---- 8< ------
# Host A eth2 and Host B eth0 is on the same network.

# On HOST A
% ip address add 1.2.3.4/24 dev eth2
% ip link set eth2 mtu 300 up

% # HOST B
% ip address add 1.2.3.5/24 dev eth0
% ip link set eth0 mtu 1000 up
% ping -c 1 -W 1 -s 400 1.2.3.4
PING 1.2.3.4 (1.2.3.4) 400(428) bytes of data.
408 bytes from 1.2.3.4: icmp_seq=1 ttl=64 time=1.57 ms

--- 1.2.3.4 ping statistics ---
1 packets transmitted, 1 received, 0% packet loss, time 0ms
rtt min/avg/max/mdev = 1.573/1.573/1.573/0.000 ms
---- 8< ------

>
> It is therefore untenable to remove this restriction univerally like
> this.

With the explaination above, do you still think it's untenable ?

/Fredrik

--94eb2c084c98a1abbd054f20b23c
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">On Tue, May 9, 2017 at 7:48 PM, David Miller &lt;<a href=
=3D"mailto:davem@davemloft.net">davem@davemloft.net</a>&gt; wrote:<br>&gt;<=
br>&gt; From: Fredrik Markstrom &lt;<a href=3D"mailto:fredrik.markstrom@gma=
il.com">fredrik.markstrom@gmail.com</a>&gt;<br>&gt; Date: Tue, =C2=A09 May =
2017 14:44:36 +0200<br>&gt;<br>&gt; &gt; Currently veth drops all packets l=
arger then the mtu set on the<br>&gt; &gt; receiving end of the pair. This =
is inconsistent with most hardware<br>&gt; &gt; ethernet drivers.<br>&gt;<b=
r>&gt; False.<br>&gt;<br>&gt; In fact, many pieces of ethernet hardware a n=
ot physically capable of<br>&gt; sending even VLAN packets that are above t=
he normal base ethernet MTU.<br>&gt;<br><br>Maybe I was unclear, the veth i=
mplementation drops all packers larger then the<br>configured MTU (on the r=
eceiving interface).<br>Most ethernet drivers accepts packets up to the eth=
ernet MTU no matter the<br>configured MTU. As far as I can tell from the RF=
C:s that is ok.<br><br>A simpler solution would be to only drop packets lar=
ger then ethernet MTU (like<br>most network drivers), but I guess that will=
 break existing stuff already out there.<br><br>The example below demonstra=
tes what behaviour I&#39;m referring to.<br><br>Example:<br>---- 8&lt; ----=
--<br># veth0 and veth1 is a veth pair and veth1 has ben moved to a separat=
e network namespace.<br>% # NS A<br>% ip address add <a href=3D"http://1.2.=
3.4/24">1.2.3.4/24</a> dev veth0<br>% ip link set veth0 mtu 300 up<br><br>%=
 # NS B<br>% ip address add <a href=3D"http://1.2.3.5/24">1.2.3.5/24</a> de=
v veth1<br>% ip link set veth1 mtu 1000 up<br>% ping -c 1 -W 1 -s 400 1.2.3=
.4<br>PING 1.2.3.4 (1.2.3.4) 400(428) bytes of data.<br><br>--- 1.2.3.4 pin=
g statistics ---<br>1 packets transmitted, 0 received, 100% packet loss, ti=
me 0ms<br>---- 8&lt; ------<br><br>While it works fine in most setup:s with=
 hw-interfaces:<br><br>---- 8&lt; ------<br># Host A eth2 and Host B eth0 i=
s on the same network.<br><br># On HOST A<br>% ip address add <a href=3D"ht=
tp://1.2.3.4/24">1.2.3.4/24</a> dev eth2<br>% ip link set eth2 mtu 300 up<b=
r><br>% # HOST B<br>% ip address add <a href=3D"http://1.2.3.5/24">1.2.3.5/=
24</a> dev eth0<br>% ip link set eth0 mtu 1000 up<br>% ping -c 1 -W 1 -s 40=
0 1.2.3.4<br>PING 1.2.3.4 (1.2.3.4) 400(428) bytes of data.<br>408 bytes fr=
om <a href=3D"http://1.2.3.4">1.2.3.4</a>: icmp_seq=3D1 ttl=3D64 time=3D1.5=
7 ms<br><br>--- 1.2.3.4 ping statistics ---<br>1 packets transmitted, 1 rec=
eived, 0% packet loss, time 0ms<br>rtt min/avg/max/mdev =3D 1.573/1.573/1.5=
73/0.000 ms<br>---- 8&lt; ------<br>=C2=A0<br>&gt;<br>&gt; It is therefore =
untenable to remove this restriction univerally like<br>&gt; this.<br><br>W=
ith the explaination above, do you still think it&#39;s untenable ?<br>=C2=
=A0<br>/Fredrik</div>

--94eb2c084c98a1abbd054f20b23c--
