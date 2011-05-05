From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ARM, AF_PACKET: caching problems on Marvell Kirkwood
Date: Thu, 05 May 2011 16:56:02 +0200
Message-ID: <1304607362.3032.84.camel@edumazet-laptop>
References: <20110408130643.GA8730@orbit.nwl.cc>
	 <20110505141107.GC30443@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	ne@erfurth.eu, Johann Baudy <johann.baudy@gnu-log.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Nicolas Pitre <nico@fluxnic.net>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:56403 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753160Ab1EEO4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 May 2011 10:56:06 -0400
Received: by wya21 with SMTP id 21so1679216wya.19
        for <netdev@vger.kernel.org>; Thu, 05 May 2011 07:56:05 -0700 (PDT)
In-Reply-To: <20110505141107.GC30443@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 05 mai 2011 =C3=A0 16:11 +0200, Phil Sutter a =C3=A9crit :
> Hi,
>=20
> Hasn't anyone experienced this bug but me? Can anyone reproduce the
> described behaviour on his Kirkwood-based (or even generic ARM) machi=
ne?
> I am still not sure if this is a problem of just my CPU or common
> amongst Kirkwood/VIPT/ARM machines.
>=20
> My workaround looks like this:
> | diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
> | index b5362e9..0672f50 100644
> | --- a/net/packet/af_packet.c
> | +++ b/net/packet/af_packet.c
> | @@ -1298,10 +1298,13 @@ static int packet_sendmsg(struct kiocb *ioc=
b, struct socket *sock,
> |  {
> |         struct sock *sk =3D sock->sk;
> |         struct packet_sock *po =3D pkt_sk(sk);
> | -       if (po->tx_ring.pg_vec)
> | -               return tpacket_snd(po, msg);
> | -       else
> | -               return packet_snd(sock, msg, len);
> | +       int rc;
> | +
> | +       flush_cache_all();
> | +       rc =3D po->tx_ring.pg_vec ? tpacket_snd(po, msg) :
> | +                       packet_snd(sock, msg, len);
> | +       flush_cache_all();
> | +       return rc;
> |  }
> | =20
> |  /*
>=20
> Greetings, Phil
>=20
> (Full-quoting here because I've added the TX ring author and the Kirk=
wood
> maintainers to Cc.)
>=20
> On Fri, Apr 08, 2011 at 03:06:43PM +0200, Phil Sutter wrote:
> > Dear lists,
> >=20
> > I am experiencing severe caching issues using the TX_RING feature o=
f
> > AF_PACKET on a Kirkwood-based system (i.e., OpenRD). This may likel=
y be
> > a bug of the CPU/SoC itself, at least it reacts a bit picky when us=
ing
> > the preload data instruction (pld) in rather useless cases (but tha=
t's a
> > different story).
> >=20
> > There is simple testing code at the end of this email, effectively =
just
> > preparing a packet in the TX_RING and triggering it's delivery once=
 per
> > second. The experienced symptom is that sporadically nothing goes o=
ut in
> > one iteration, and two packets in the following one.
> >=20
> > It looks like the kernel doesn't get the changed value of tp_status=
 in
> > time, although userspace sees the correct value. Note that moving t=
he
> > sleep(1) from the end of the loop to just before calling sendto() f=
ixes
> > the problem.
> >=20
> > Another (more useful) workaround is to call flush_cache_all() at th=
e
> > beginning of packet_sendmsg() in net/packet/af_packet.c. I was not =
able
> > to fix this with some more specific flushing at that place. Anyway,=
 the
> > call to flush_dcache_page() from __packet_get_status() in the same
> > source file is meant to do the trick I guess. But somehow doesn't.
> >=20
> > Feedback regardles of which kind is highly appreciated, of course!
> >=20
> > Greetings, Phil
> >=20
> > ------------------[start of packet_mmap_test.c]--------------------
> > #include <stdint.h>
> > #include <stdio.h>
> > #include <stdlib.h>
> > #include <string.h>
> > #include <linux/if_ether.h>
> > #include <linux/if_packet.h>
> > #include <net/if.h>
> > #include <sys/ioctl.h>
> > #include <sys/mman.h>
> > #include <sys/socket.h>
> > #include <sys/types.h>
> >=20
> > #define PERROR_EXIT(rc, mesg) { \
> > 	perror(mesg); \
> > 	return rc; \
> > }
> >=20
> > int main(void)
> > {
> > 	uint32_t size;
> > 	struct sockaddr_ll sa;
> > 	struct ifreq ifr;
> > 	int index;
> > 	int tmp;
> > 	int fd;
> > 	struct tpacket_req packet_req;
> > 	struct tpacket2_hdr * ps_header_start, *ps_header;
> >=20
> > 	if ((fd =3D socket(AF_PACKET, SOCK_DGRAM, htons(ETH_P_ALL))) < 0)
> > 		PERROR_EXIT(EXIT_FAILURE, "socket");
> >=20
> > 	/* retrieve eth0's interface index number */
> > 	strncpy (ifr.ifr_name, "eth0", sizeof(ifr.ifr_name));
> > 	if (ioctl(fd, SIOCGIFINDEX, &ifr) < 0)
> > 		PERROR_EXIT(EXIT_FAILURE, "ioctl(SIOCGIFINDEX)");
> >=20
> > 	/* set sockaddr info */
> > 	memset(&sa, 0, sizeof(sa));
> > 	sa.sll_family =3D AF_PACKET;
> > 	sa.sll_protocol =3D ETH_P_ALL;
> > 	sa.sll_ifindex =3D ifr.ifr_ifindex;
> >=20
> > 	/* bind port */
> > 	if (bind(fd, (struct sockaddr *)&sa, sizeof(sa)) < 0)
> > 		PERROR_EXIT(EXIT_FAILURE, "bind()");
> >=20
> > 	tmp =3D TPACKET_V2;
> > 	if (setsockopt(fd, SOL_PACKET, PACKET_VERSION, &tmp, sizeof(tmp)) =
< 0)
> > 		PERROR_EXIT(EXIT_FAILURE, "setsockopt(PACKET_VERSION)");
> >=20
> > 	/* set packet loss option */
> > 	tmp =3D 1;
> > 	if (setsockopt(fd, SOL_PACKET, PACKET_LOSS, &tmp, sizeof(tmp)) < 0=
)
> > 		PERROR_EXIT(EXIT_FAILURE, "setsockopt(PACKET_LOSS)");
> >=20
> > 	/* prepare Tx ring request */
> > 	packet_req.tp_block_size =3D 1024 * 8;
> > 	packet_req.tp_frame_size =3D 1024 * 8;
> > 	packet_req.tp_block_nr =3D 1024;
> > 	packet_req.tp_frame_nr =3D 1024;
> >=20
> > 	/* send TX ring request */
> > 	if (setsockopt(fd, SOL_PACKET, PACKET_TX_RING,
> > 	               &packet_req, sizeof(packet_req)) < 0)
> > 		PERROR_EXIT(EXIT_FAILURE, "setsockopt: PACKET_TX_RING");
> >=20
> > 	/* calculate memory to mmap in the kernel */
> > 	size =3D packet_req.tp_block_size * packet_req.tp_block_nr;
> >=20
> > 	/* mmap Tx ring buffers memory */
> > 	ps_header_start =3D mmap(0, size,
> > 			PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
> > 	if (ps_header_start < 0)
> > 		PERROR_EXIT(EXIT_FAILURE, "mmap");
> >=20
> > 	/* fill peer sockaddr for SOCK_DGRAM */
> > 	sa.sll_family =3D AF_PACKET;
> > 	sa.sll_protocol =3D htons(ETH_P_IP);
> > 	sa.sll_ifindex =3D ifr.ifr_ifindex;
> > 	sa.sll_halen =3D ETH_ALEN;
> > 	memset(&sa.sll_addr, 0xff, ETH_ALEN);
> >=20
> > 	ps_header =3D ps_header_start;
> > 	while (1) {
> > 		int sendlen, j;
> >=20
> > 		char *data =3D (void*)ps_header + TPACKET_HDRLEN
> > 		              - sizeof(struct sockaddr_ll);
> >=20
> > 		switch((volatile uint32_t)ps_header->tp_status)
> > 		{
> > 		case TP_STATUS_AVAILABLE:
> > 			memset(data, 0x23, 150);
> > 			break;
> >=20
> > 		case TP_STATUS_WRONG_FORMAT:
> > 			printf("An error has occured during transfer\n");
> > 			exit(EXIT_FAILURE);
> > 			break;
> >=20
> > 		default:
> > 			printf("Buffer is not available, aborting\n");
> > 			exit(1);
> > 			break;
> > 		}
> > 		ps_header->tp_len =3D 150;
> > 		ps_header->tp_status =3D TP_STATUS_SEND_REQUEST;
> >=20
> > 		sendlen =3D sendto(fd, NULL, 0, 0,
> > 				(struct sockaddr *)&sa, sizeof(sa));
> > 		if (sendlen < 0)
> > 			perror("sendto");
> > 		else if (sendlen =3D=3D 0)
> > 			printf("sendto(): nothing sent!\n");
> > 		else
> > 			printf("sendto(): sent %d bytes out\n", sendlen);
> >=20
> > #define ST_IS(x) ((volatile uint32_t)ps_header->tp_status =3D=3D x)
> > 		printf("tp_status after sending: %s\n",
> > 				ST_IS(TP_STATUS_AVAILABLE) ? "AVAILABLE" :
> > 				ST_IS(TP_STATUS_SEND_REQUEST) ? "SEND_REQUEST" :
> > 				ST_IS(TP_STATUS_WRONG_FORMAT) ? "WRONG_FORMAT" :
> > 				"unknown");
> > #undef ST_IS
> >=20
> > 		ps_header =3D (void *)ps_header + packet_req.tp_frame_size;
> > 		if (ps_header >=3D ps_header_start + size)
> > 			ps_header =3D ps_header_start;
> >=20
> > 		sleep(1);
> > 	}
> > 	return 0;
> > }
> > --------------------[end of packet_mmap_test.c]--------------------

Hi Phil

I assume you use latest linux-2.6 or net-next-2.6 ?

Could you try to force vmalloc() use ?

diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index b5362e9..0b5a89c 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -2383,7 +2383,7 @@ static inline char *alloc_one_pg_vec_page(unsigne=
d long order)
 	gfp_t gfp_flags =3D GFP_KERNEL | __GFP_COMP |
 			  __GFP_ZERO | __GFP_NOWARN | __GFP_NORETRY;
=20
-	buffer =3D (char *) __get_free_pages(gfp_flags, order);
+	buffer =3D NULL;
=20
 	if (buffer)
 		return buffer;


