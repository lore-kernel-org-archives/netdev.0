From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sun, 02 Jan 2011 12:17:03 +0100
Message-ID: <1293967023.29525.16.camel@wall-e>
References: <1293918276-28773-1-git-send-email-stefani@seibold.net>
	 <1293920601.2535.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www84.your-server.de ([213.133.104.84]:34446 "EHLO
	www84.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093Ab1ABLQD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Jan 2011 06:16:03 -0500
In-Reply-To: <1293920601.2535.64.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Samstag, den 01.01.2011, 23:23 +0100 schrieb Eric Dumazet:
> Le samedi 01 janvier 2011 =E0 22:44 +0100, stefani@seibold.net a =E9c=
rit :
> > From: Stefani Seibold <stefani@seibold.net>
> >=20
> > Changelog:
> > 31.12.2010 first proposal
> > 01.01.2011 code cleanup and fixes suggest by Eric Dumazet
> >=20
> > UDPCP is a communication protocol specified by the Open Base Statio=
n
> > Architecture Initiative Special Interest Group (OBSAI SIG). The
> > protocol is based on UDP and is designed to meet the needs of "Mobi=
le
> > Communcation Base Station" internal communications. It is widely us=
ed by
> > the major networks infrastructure supplier.
> >=20
> > The UDPCP communication service supports the following features:
> >=20
> > -Connectionless communication for serial mode data transfer
> > -Acknowledged and unacknowledged transfer modes
> > -Retransmissions Algorithm
> > -Checksum Algorithm using Adler32
> > -Fragmentation of long messages (disassembly/reassembly) to match t=
o the MTU
> >  during transport:
> > -Broadcasting and multicasting messages to multiple peers in unackn=
owledged
> >  transfer mode
> >=20
> > UDPCP supports application level messages up to 64 KBytes (limited =
by 16-bit
> > packet data length field). Messages that are longer than the MTU wi=
ll be
> > fragmented to the MTU.
> >=20
> > UDPCP provides a reliable transport service that will perform messa=
ge
> > retransmissions in case transport failures occur.
> >=20
> > The code is also a nice example how to implement a UDP based protoc=
ol as
> > a kernel socket modules.
> >=20
> > Due the nature of UDPCP which has no sliding windows support, the l=
atency has a
> > huge impact. The perfomance increase by implementing as a kernel mo=
dule is
> > about the factor 10, because there are no context switches and data=
 packets or
> > ACKs will be handled in the interrupt service.
> >=20
> > There are no side effects to the network subsystems so i ask for me=
rge it
> > into linux-next. Hope you like it.
> >=20
> > The patch is against 2.6.37-rc8
> >=20
>=20
> Hi Stefani
>=20
> 1) Please base your next trys on net-next-2.6 : This is the reference
> for stuff like that. It probably does not matter a lot, but still...
>=20

Okay.

>=20
> 2) I still see some _irq() variants of spinlock(). Its not necessary =
in
> network stack at the level you are working (process context, and
> softirqs)
>=20
> Please only use _bh() variants, it's enough.
>=20

Will be fixed...

> 3) I see UDPLITE references in your code. Are you sure UDPCP protocol
> can really work on top of UDPLITE ? I think not, so please remove dea=
d
> code.
>=20

I have not tested it yet. But i think i should work, the code is mostly
stolen from the udp.c file. Since the stack not depend on the len field
of the UDP header, it should not matter if UPD or UDP-Lite is used.

> 4) udpcp_release_sock() seems expensive to me. Why not testing
> usk->timeout before releasing sock lock, and save a lock/unlock pair =
?
>=20
> static inline void udpcp_release_sock(struct sock *sk)
> {
> 	struct udpcp_sock *usk =3D udpcp_sk(sk);
>=20
> 	if (usk->timeout)
> 		udpcp_handle_timeout(sk);
> 	release_sock(sk);
> }
>=20

No... What is when a timer occurs between exiting udpcp_handle_timeout(=
)
and release_sock(). This timer will not longer handled.

What about this:?

static inline void udpcp_release_sock(struct sock *sk)
{
	while (usk->timeout) {
		udpcp_handle_timeout(sk);
	release_sock(sk);
        check_timeout(sk);
}

> 5) In udpcp_timeout(), if you find socket is locked by user, you set
> timeout to one and rearm a timer to udpcp_timer(sk, jiffies + 1);=20
>=20
> Why is it needed, since user process is going to handle the timeout
> indication from udpcp_release_sock() ?
>=20

It is only for paranoid reasons, maybe there is a bug in my wonderful
code and than the stack will stop to work.... If it is okay, i didn't
want to remove it, my cuts feels a little bit nervous.=20


