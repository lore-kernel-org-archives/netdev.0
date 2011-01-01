From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Sat, 01 Jan 2011 23:23:21 +0100
Message-ID: <1293920601.2535.64.camel@edumazet-laptop>
References: <1293918276-28773-1-git-send-email-stefani@seibold.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org,
	davem@davemloft.net, netdev@vger.kernel.org, shemminger@vyatta.com
To: stefani@seibold.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1293918276-28773-1-git-send-email-stefani@seibold.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le samedi 01 janvier 2011 =C3=A0 22:44 +0100, stefani@seibold.net a =C3=
=A9crit :
> From: Stefani Seibold <stefani@seibold.net>
>=20
> Changelog:
> 31.12.2010 first proposal
> 01.01.2011 code cleanup and fixes suggest by Eric Dumazet
>=20
> UDPCP is a communication protocol specified by the Open Base Station
> Architecture Initiative Special Interest Group (OBSAI SIG). The
> protocol is based on UDP and is designed to meet the needs of "Mobile
> Communcation Base Station" internal communications. It is widely used=
 by
> the major networks infrastructure supplier.
>=20
> The UDPCP communication service supports the following features:
>=20
> -Connectionless communication for serial mode data transfer
> -Acknowledged and unacknowledged transfer modes
> -Retransmissions Algorithm
> -Checksum Algorithm using Adler32
> -Fragmentation of long messages (disassembly/reassembly) to match to =
the MTU
>  during transport:
> -Broadcasting and multicasting messages to multiple peers in unacknow=
ledged
>  transfer mode
>=20
> UDPCP supports application level messages up to 64 KBytes (limited by=
 16-bit
> packet data length field). Messages that are longer than the MTU will=
 be
> fragmented to the MTU.
>=20
> UDPCP provides a reliable transport service that will perform message
> retransmissions in case transport failures occur.
>=20
> The code is also a nice example how to implement a UDP based protocol=
 as
> a kernel socket modules.
>=20
> Due the nature of UDPCP which has no sliding windows support, the lat=
ency has a
> huge impact. The perfomance increase by implementing as a kernel modu=
le is
> about the factor 10, because there are no context switches and data p=
ackets or
> ACKs will be handled in the interrupt service.
>=20
> There are no side effects to the network subsystems so i ask for merg=
e it
> into linux-next. Hope you like it.
>=20
> The patch is against 2.6.37-rc8
>=20

Hi Stefani

1) Please base your next trys on net-next-2.6 : This is the reference
for stuff like that. It probably does not matter a lot, but still...


2) I still see some _irq() variants of spinlock(). Its not necessary in
network stack at the level you are working (process context, and
softirqs)

Please only use _bh() variants, it's enough.

3) I see UDPLITE references in your code. Are you sure UDPCP protocol
can really work on top of UDPLITE ? I think not, so please remove dead
code.

4) udpcp_release_sock() seems expensive to me. Why not testing
usk->timeout before releasing sock lock, and save a lock/unlock pair ?

static inline void udpcp_release_sock(struct sock *sk)
{
	struct udpcp_sock *usk =3D udpcp_sk(sk);

	if (usk->timeout)
		udpcp_handle_timeout(sk);
	release_sock(sk);
}

5) In udpcp_timeout(), if you find socket is locked by user, you set
timeout to one and rearm a timer to udpcp_timer(sk, jiffies + 1);=20

Why is it needed, since user process is going to handle the timeout
indication from udpcp_release_sock() ?

Thanks
