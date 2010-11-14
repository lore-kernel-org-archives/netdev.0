From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH/RFC] netfilter: nf_conntrack_sip: Handle quirky Cisco
 phones
Date: Sun, 14 Nov 2010 20:57:44 +0100
Message-ID: <1289764664.2743.110.camel@edumazet-laptop>
References: <28d666269c390965f1a4edca42f93c12@localhost>
	 <1289725175.2743.65.camel@edumazet-laptop>
	 <AANLkTik4PLga8mX73c8iONPeOtpDiuDhfu3xiPmF07jC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	coreteam@netfilter.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Kevin Cernekee <cernekee@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f48.google.com ([74.125.82.48]:58310 "EHLO
	mail-ww0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756920Ab0KNT6D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Nov 2010 14:58:03 -0500
In-Reply-To: <AANLkTik4PLga8mX73c8iONPeOtpDiuDhfu3xiPmF07jC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le dimanche 14 novembre 2010 =C3=A0 10:33 -0800, Kevin Cernekee a =C3=A9=
crit :
> On Sun, Nov 14, 2010 at 12:59 AM, Eric Dumazet <eric.dumazet@gmail.co=
m> wrote:
> > I would like to get an exact SIP exchange to make sure their is not
> > another way to handle this without adding a "Cisco" string somewher=
e...
> >
> > Please provide a pcap or tcpdump -A
>=20
> Existing nf_nat_sip: phone sends unauthenticated REGISTER requests
> over and over again, because it is not seeing the replies sent back t=
o
> port 50070:
>=20
> 10:05:53.496479 IP 192.168.2.28.50070 > 67.215.241.250.5060: SIP, len=
gth: 723
> E`...[..@.r.....C...........REGISTER sip:losangeles.voip.ms SIP/2.0
> Via: SIP/2.0/
>=20

Hmm, partial tcpdump... you should use" tcpdump -s 1000 -A"=20

We miss the

Via: SIP/2.0/UDP 192.168.2.28:5060;branch=3Dxxxxxxxx


Maybe a fix would be to use this "5060" port, instead of hardcoding it
like you did ?


>=20
> Patched nf_nat_sip: router sends the replies back to port 5060, so th=
e
> phone is now able to register itself and make calls:
>=20
> 10:09:46.221631 IP 192.168.2.28.50618 > 67.215.241.250.5060: SIP, len=
gth: 723
> E`...G..@.p.....C...........REGISTER sip:losangeles.voip.ms SIP/2.0
> Via: SIP/2.0/
>=20
> 10:09:46.253052 IP 67.215.241.250.5060 > 192.168.2.28.5060: SIP, leng=
th: 491
> E....+..4..$C...............SIP/2.0 100 Trying
> Via: SIP/2.0/UDP 192.168.2.28:5060
>=20
> 10:09:46.253472 IP 67.215.241.250.5060 > 192.168.2.28.5060: SIP, leng=
th: 550
> E..B.,..4...C...............SIP/2.0 401 Unauthorized
> Via: SIP/2.0/UDP 192.168.2.2
>=20
> 10:09:46.261602 IP 192.168.2.28.50618 > 67.215.241.250.5060: SIP, len=
gth: 900
> E`...H..@.p.....C...........REGISTER sip:losangeles.voip.ms SIP/2.0
> Via: SIP/2.0/
>=20
> 10:09:46.290211 IP 67.215.241.250.5060 > 192.168.2.28.5060: SIP, leng=
th: 491
> E....-..4.."C...............SIP/2.0 100 Trying
> Via: SIP/2.0/UDP 192.168.2.28:5060
>=20
> 10:09:46.295041 IP 67.215.241.250.5060 > 192.168.2.28.5060: SIP, leng=
th: 579
> E.._....4...C............K..SIP/2.0 200 OK
> Via: SIP/2.0/UDP 192.168.2.28:5060;bra
>=20
>=20
> BTW, I thought of two possible issues with the original patch:
>=20
> 1) Might need to call skb_make_writable() prior to modifying the
> packet.  Presumably the second invocation inside
> nf_nat_mangle_udp_packet() will have no effect.
>=20
> (Is there a cleaner way to mangle just the port number?  Most of the
> utility functions only help with modifying the data area.)
>=20
> 2) I should probably be checking to make sure request =3D=3D 0 before
> mangling the packet.  The current behavior is harmless if the SIP
> proxy is on port 5060, but that might not always be the case.
>=20
> I can roll these, along with any other suggestions, into v2.


