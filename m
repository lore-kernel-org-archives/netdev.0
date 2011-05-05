From: Phil Sutter <phil@nwl.cc>
Subject: Re: ARM, AF_PACKET: caching problems on Marvell Kirkwood
Date: Thu, 5 May 2011 16:11:07 +0200
Message-ID: <20110505141107.GC30443@orbit.nwl.cc>
References: <20110408130643.GA8730@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johann Baudy <johann.baudy@gnu-log.net>,
	Lennert Buytenhek <kernel@wantstofly.org>,
	Nicolas Pitre <nico@fluxnic.net>
To: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	ne@erfurth.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbit.nwl.cc ([91.121.141.167]:48082 "EHLO orbit.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754686Ab1EEOLI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 10:11:08 -0400
Content-Disposition: inline
In-Reply-To: <20110408130643.GA8730@orbit.nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Hasn't anyone experienced this bug but me? Can anyone reproduce the
described behaviour on his Kirkwood-based (or even generic ARM) machine?
I am still not sure if this is a problem of just my CPU or common
amongst Kirkwood/VIPT/ARM machines.

My workaround looks like this:
| diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
| index b5362e9..0672f50 100644
| --- a/net/packet/af_packet.c
| +++ b/net/packet/af_packet.c
| @@ -1298,10 +1298,13 @@ static int packet_sendmsg(struct kiocb *iocb, struct socket *sock,
|  {
|         struct sock *sk = sock->sk;
|         struct packet_sock *po = pkt_sk(sk);
| -       if (po->tx_ring.pg_vec)
| -               return tpacket_snd(po, msg);
| -       else
| -               return packet_snd(sock, msg, len);
| +       int rc;
| +
| +       flush_cache_all();
| +       rc = po->tx_ring.pg_vec ? tpacket_snd(po, msg) :
| +                       packet_snd(sock, msg, len);
| +       flush_cache_all();
| +       return rc;
|  }
|  
|  /*

Greetings, Phil

(Full-quoting here because I've added the TX ring author and the Kirkwood
maintainers to Cc.)

On Fri, Apr 08, 2011 at 03:06:43PM +0200, Phil Sutter wrote:
> Dear lists,
> 
> I am experiencing severe caching issues using the TX_RING feature of
> AF_PACKET on a Kirkwood-based system (i.e., OpenRD). This may likely be
> a bug of the CPU/SoC itself, at least it reacts a bit picky when using
> the preload data instruction (pld) in rather useless cases (but that's a
> different story).
> 
> There is simple testing code at the end of this email, effectively just
> preparing a packet in the TX_RING and triggering it's delivery once per
> second. The experienced symptom is that sporadically nothing goes out in
> one iteration, and two packets in the following one.
> 
> It looks like the kernel doesn't get the changed value of tp_status in
> time, although userspace sees the correct value. Note that moving the
> sleep(1) from the end of the loop to just before calling sendto() fixes
> the problem.
> 
> Another (more useful) workaround is to call flush_cache_all() at the
> beginning of packet_sendmsg() in net/packet/af_packet.c. I was not able
> to fix this with some more specific flushing at that place. Anyway, the
> call to flush_dcache_page() from __packet_get_status() in the same
> source file is meant to do the trick I guess. But somehow doesn't.
> 
> Feedback regardles of which kind is highly appreciated, of course!
> 
> Greetings, Phil
> 
> ------------------[start of packet_mmap_test.c]--------------------
> #include <stdint.h>
> #include <stdio.h>
> #include <stdlib.h>
> #include <string.h>
> #include <linux/if_ether.h>
> #include <linux/if_packet.h>
> #include <net/if.h>
> #include <sys/ioctl.h>
> #include <sys/mman.h>
> #include <sys/socket.h>
> #include <sys/types.h>
> 
> #define PERROR_EXIT(rc, mesg) { \
> 	perror(mesg); \
> 	return rc; \
> }
> 
> int main(void)
> {
> 	uint32_t size;
> 	struct sockaddr_ll sa;
> 	struct ifreq ifr;
> 	int index;
> 	int tmp;
> 	int fd;
> 	struct tpacket_req packet_req;
> 	struct tpacket2_hdr * ps_header_start, *ps_header;
> 
> 	if ((fd = socket(AF_PACKET, SOCK_DGRAM, htons(ETH_P_ALL))) < 0)
> 		PERROR_EXIT(EXIT_FAILURE, "socket");
> 
> 	/* retrieve eth0's interface index number */
> 	strncpy (ifr.ifr_name, "eth0", sizeof(ifr.ifr_name));
> 	if (ioctl(fd, SIOCGIFINDEX, &ifr) < 0)
> 		PERROR_EXIT(EXIT_FAILURE, "ioctl(SIOCGIFINDEX)");
> 
> 	/* set sockaddr info */
> 	memset(&sa, 0, sizeof(sa));
> 	sa.sll_family = AF_PACKET;
> 	sa.sll_protocol = ETH_P_ALL;
> 	sa.sll_ifindex = ifr.ifr_ifindex;
> 
> 	/* bind port */
> 	if (bind(fd, (struct sockaddr *)&sa, sizeof(sa)) < 0)
> 		PERROR_EXIT(EXIT_FAILURE, "bind()");
> 
> 	tmp = TPACKET_V2;
> 	if (setsockopt(fd, SOL_PACKET, PACKET_VERSION, &tmp, sizeof(tmp)) < 0)
> 		PERROR_EXIT(EXIT_FAILURE, "setsockopt(PACKET_VERSION)");
> 
> 	/* set packet loss option */
> 	tmp = 1;
> 	if (setsockopt(fd, SOL_PACKET, PACKET_LOSS, &tmp, sizeof(tmp)) < 0)
> 		PERROR_EXIT(EXIT_FAILURE, "setsockopt(PACKET_LOSS)");
> 
> 	/* prepare Tx ring request */
> 	packet_req.tp_block_size = 1024 * 8;
> 	packet_req.tp_frame_size = 1024 * 8;
> 	packet_req.tp_block_nr = 1024;
> 	packet_req.tp_frame_nr = 1024;
> 
> 	/* send TX ring request */
> 	if (setsockopt(fd, SOL_PACKET, PACKET_TX_RING,
> 	               &packet_req, sizeof(packet_req)) < 0)
> 		PERROR_EXIT(EXIT_FAILURE, "setsockopt: PACKET_TX_RING");
> 
> 	/* calculate memory to mmap in the kernel */
> 	size = packet_req.tp_block_size * packet_req.tp_block_nr;
> 
> 	/* mmap Tx ring buffers memory */
> 	ps_header_start = mmap(0, size,
> 			PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
> 	if (ps_header_start < 0)
> 		PERROR_EXIT(EXIT_FAILURE, "mmap");
> 
> 	/* fill peer sockaddr for SOCK_DGRAM */
> 	sa.sll_family = AF_PACKET;
> 	sa.sll_protocol = htons(ETH_P_IP);
> 	sa.sll_ifindex = ifr.ifr_ifindex;
> 	sa.sll_halen = ETH_ALEN;
> 	memset(&sa.sll_addr, 0xff, ETH_ALEN);
> 
> 	ps_header = ps_header_start;
> 	while (1) {
> 		int sendlen, j;
> 
> 		char *data = (void*)ps_header + TPACKET_HDRLEN
> 		              - sizeof(struct sockaddr_ll);
> 
> 		switch((volatile uint32_t)ps_header->tp_status)
> 		{
> 		case TP_STATUS_AVAILABLE:
> 			memset(data, 0x23, 150);
> 			break;
> 
> 		case TP_STATUS_WRONG_FORMAT:
> 			printf("An error has occured during transfer\n");
> 			exit(EXIT_FAILURE);
> 			break;
> 
> 		default:
> 			printf("Buffer is not available, aborting\n");
> 			exit(1);
> 			break;
> 		}
> 		ps_header->tp_len = 150;
> 		ps_header->tp_status = TP_STATUS_SEND_REQUEST;
> 
> 		sendlen = sendto(fd, NULL, 0, 0,
> 				(struct sockaddr *)&sa, sizeof(sa));
> 		if (sendlen < 0)
> 			perror("sendto");
> 		else if (sendlen == 0)
> 			printf("sendto(): nothing sent!\n");
> 		else
> 			printf("sendto(): sent %d bytes out\n", sendlen);
> 
> #define ST_IS(x) ((volatile uint32_t)ps_header->tp_status == x)
> 		printf("tp_status after sending: %s\n",
> 				ST_IS(TP_STATUS_AVAILABLE) ? "AVAILABLE" :
> 				ST_IS(TP_STATUS_SEND_REQUEST) ? "SEND_REQUEST" :
> 				ST_IS(TP_STATUS_WRONG_FORMAT) ? "WRONG_FORMAT" :
> 				"unknown");
> #undef ST_IS
> 
> 		ps_header = (void *)ps_header + packet_req.tp_frame_size;
> 		if (ps_header >= ps_header_start + size)
> 			ps_header = ps_header_start;
> 
> 		sleep(1);
> 	}
> 	return 0;
> }
> --------------------[end of packet_mmap_test.c]--------------------
> 
> _______________________________________________
> linux-arm-kernel mailing list
> linux-arm-kernel@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-arm-kernel
