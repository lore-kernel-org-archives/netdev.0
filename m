From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: use RTAX_CWND for outgoing connections properly
Date: Wed, 22 Dec 2010 12:29:43 +0100
Message-ID: <1293017383.3027.75.camel@edumazet-laptop>
References: <alpine.LNX.2.00.1012172310400.16569@pobox.suse.cz>
	 <alpine.LNX.2.00.1012221059340.16569@pobox.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Vojtech Pavlik <vojtech@suse.cz>
To: Jiri Kosina <jkosina@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.00.1012221059340.16569@pobox.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mercredi 22 d=C3=A9cembre 2010 =C3=A0 11:00 +0100, Jiri Kosina a =C3=
=A9crit :
> On Fri, 17 Dec 2010, Jiri Kosina wrote:
>=20
> > For outgoing connections, the initial value of cwnd is always set t=
o 2 (in=20
> > tcp_v4_init_sock()) regardless of setting of RTAX_CWND. For incomin=
g=20
> > connections, this is handled properly in tcp_init_metrics().
> >=20
> > As a result of this, Linux TCP stack always uses cwnd =3D=3D 2 at t=
he beginning of
> > outgoing TCP session (i.e. waits for ACK after 2 packets once the c=
onnection
> > has been established) and grows it in accordance with slow-start al=
gorithm
> > only after it receives ACK for first two packets.
> >=20
> > When slow-start triggers later during the connection (e.g. after id=
le),=20
> > cwnd is properly re-initialized to RTAX_CWND value (if specified) t=
hrough=20
> > tcp_cwnd_restart() -> tcp_init_cwnd().
> >=20
> > Initialize tp->snd_cwnd properly so that RTAX_CWND value is being u=
sed=20
> > also in the slow-start phase for the first packets in the connectio=
n.
>=20
> This should of course read RTAX_INITCWND instead of RTAX_CWND in the =
whole=20
> changelog, sorry.
>=20
> Besides that, any comments on this, please?
>=20

Its a bit strange, here is what I have with two net-next-2.6 machines
(without your patch)

192.168.20.0/24 dev eth1  scope link  initcwnd 10

12:13:46.855786 IP 192.168.20.110.39146 > 192.168.20.108.59636: S 16158=
62982:1615862982(0) win 14600 <mss 1460,sackOK,timestamp 277530 0,nop,w=
scale 8>
12:13:46.855807 IP 192.168.20.108.59636 > 192.168.20.110.39146: S 16030=
53412:1603053412(0) ack 1615862983 win 14480 <mss 1460,sackOK,timestamp=
 744840 277530,nop,wscale 7>
12:13:46.855878 IP 192.168.20.110.39146 > 192.168.20.108.59636: . ack 1=
 win 58 <nop,nop,timestamp 277530 744840>
12:13:46.856779 IP 192.168.20.110.39146 > 192.168.20.108.59636: P 1:144=
81(14480) ack 1 win 58 <nop,nop,timestamp 277530 744840>
12:13:46.856794 IP 192.168.20.108.59636 > 192.168.20.110.39146: . ack 1=
4481 win 136 <nop,nop,timestamp 744841 277530>
12:13:46.856901 IP 192.168.20.110.39146 > 192.168.20.108.59636: . 14481=
:15929(1448) ack 1 win 58 <nop,nop,timestamp 277531 744841>
12:13:46.856912 IP 192.168.20.108.59636 > 192.168.20.110.39146: . ack 1=
5929 win 159 <nop,nop,timestamp 744841 277531>
12:13:46.856930 IP 192.168.20.110.39146 > 192.168.20.108.59636: . 15929=
:18825(2896) ack 1 win 58 <nop,nop,timestamp 277531 744841>


We can see 192.168.20.110 sends 14480 bytes in its first frame.

Are you sure your patch still needed after commit 356f039822b8d802138f
(TCP: increase default initial receive window.)
