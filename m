From: Benoit PAPILLAULT <benoit.papillault@free.fr>
Subject: Re: [Bugme-new] [Bug 14837] New: gretap does not fragment IP packets
Date: Mon, 21 Dec 2009 02:17:31 +0100
Message-ID: <4B2ECCAB.8010702@free.fr>
References: <bug-14837-10286@http.bugzilla.kernel.org/>	 <20091218153209.45042a58.akpm@linux-foundation.org> <1261227303.11973.2.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from 27.mail-out.ovh.net ([91.121.30.210]:43245 "HELO
	27.mail-out.ovh.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1756398AbZLUBYY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Dec 2009 20:24:24 -0500
In-Reply-To: <1261227303.11973.2.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

jamal a =E9crit :
> Sending back an ICMP is good behavior. Sending it "who knows" is not =
;->
> Make sure it is sent to the originator of the packet. The originator =
of
> the packet should play nice and reduce the path mtu.
>
> One work around is to reduce the gre device mtu to something less tha=
n
> 1500B.
>
> cheers,
> jamal
>
>
>  =20
As I explained in my original message, the gre device MTU must be 1500=20
bytes (since it is used in an Ethernet bridge). To reproduce the=20
problem, I did a very simple setup with two machines (A & B) connected=20
with an Ethernet cable (so no router between them).

On machine A :
# ip link add gre0 type gretap local <A> remote <B>
# ifconfig gre0 mtu 1500
# ifconfig gre0 192.192.192.1 up

On machine B:
# ip link add gre0 type gretap local <B> remote <A>
# ifconfig gre0 mtu 1500
# ifconfig gre0 192.192.192.2 up

On machine A:
# ping 192.192.192.2 =3D> working
# ping -s 1434 192.192.192.2 =3D> working, match a GRE packet of 1500 b=
ytes
# ping -s 1435 192.192.192.2 =3D> not working, match a GRE packet of 15=
01=20
bytes (1435+8+20+38)
# ping -s 1472 192.192.192.2 =3D> not working, match an IP packet of 15=
00=20
bytes


Doing a tcpdump on the machine (like tcpdump -pni any) shows that ICMP=20
packets are simply dropped!

Using tracepath 192.192.192.2, a tcpdump -pni lo shows :
IP 192.192.192.1 > 192.192.192.1: ICMP 192.192.192.2 unreachable - need=
=20
to frag (mtu 1500), length 556

Regards,
Benoit
