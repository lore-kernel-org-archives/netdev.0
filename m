From: Phil Sutter <phil@nwl.cc>
Subject: ARM, AF_PACKET: caching problems on Marvell Kirkwood
Date: Fri, 8 Apr 2011 15:06:43 +0200
Message-ID: <20110408130643.GA8730@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ne@erfurth.eu
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
Content-Disposition: inline
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
	<mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: linux-arm-kernel-bounces@lists.infradead.org
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

Dear lists,

I am experiencing severe caching issues using the TX_RING feature of
AF_PACKET on a Kirkwood-based system (i.e., OpenRD). This may likely be
a bug of the CPU/SoC itself, at least it reacts a bit picky when using
the preload data instruction (pld) in rather useless cases (but that's a
different story).

There is simple testing code at the end of this email, effectively just
preparing a packet in the TX_RING and triggering it's delivery once per
second. The experienced symptom is that sporadically nothing goes out in
one iteration, and two packets in the following one.

It looks like the kernel doesn't get the changed value of tp_status in
time, although userspace sees the correct value. Note that moving the
sleep(1) from the end of the loop to just before calling sendto() fixes
the problem.

Another (more useful) workaround is to call flush_cache_all() at the
beginning of packet_sendmsg() in net/packet/af_packet.c. I was not able
to fix this with some more specific flushing at that place. Anyway, the
call to flush_dcache_page() from __packet_get_status() in the same
source file is meant to do the trick I guess. But somehow doesn't.

Feedback regardles of which kind is highly appreciated, of course!

Greetings, Phil

------------------[start of packet_mmap_test.c]--------------------
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <linux/if_ether.h>
#include <linux/if_packet.h>
#include <net/if.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <sys/socket.h>
#include <sys/types.h>

#define PERROR_EXIT(rc, mesg) { \
	perror(mesg); \
	return rc; \
}

int main(void)
{
	uint32_t size;
	struct sockaddr_ll sa;
	struct ifreq ifr;
	int index;
	int tmp;
	int fd;
	struct tpacket_req packet_req;
	struct tpacket2_hdr * ps_header_start, *ps_header;

	if ((fd = socket(AF_PACKET, SOCK_DGRAM, htons(ETH_P_ALL))) < 0)
		PERROR_EXIT(EXIT_FAILURE, "socket");

	/* retrieve eth0's interface index number */
	strncpy (ifr.ifr_name, "eth0", sizeof(ifr.ifr_name));
	if (ioctl(fd, SIOCGIFINDEX, &ifr) < 0)
		PERROR_EXIT(EXIT_FAILURE, "ioctl(SIOCGIFINDEX)");

	/* set sockaddr info */
	memset(&sa, 0, sizeof(sa));
	sa.sll_family = AF_PACKET;
	sa.sll_protocol = ETH_P_ALL;
	sa.sll_ifindex = ifr.ifr_ifindex;

	/* bind port */
	if (bind(fd, (struct sockaddr *)&sa, sizeof(sa)) < 0)
		PERROR_EXIT(EXIT_FAILURE, "bind()");

	tmp = TPACKET_V2;
	if (setsockopt(fd, SOL_PACKET, PACKET_VERSION, &tmp, sizeof(tmp)) < 0)
		PERROR_EXIT(EXIT_FAILURE, "setsockopt(PACKET_VERSION)");

	/* set packet loss option */
	tmp = 1;
	if (setsockopt(fd, SOL_PACKET, PACKET_LOSS, &tmp, sizeof(tmp)) < 0)
		PERROR_EXIT(EXIT_FAILURE, "setsockopt(PACKET_LOSS)");

	/* prepare Tx ring request */
	packet_req.tp_block_size = 1024 * 8;
	packet_req.tp_frame_size = 1024 * 8;
	packet_req.tp_block_nr = 1024;
	packet_req.tp_frame_nr = 1024;

	/* send TX ring request */
	if (setsockopt(fd, SOL_PACKET, PACKET_TX_RING,
	               &packet_req, sizeof(packet_req)) < 0)
		PERROR_EXIT(EXIT_FAILURE, "setsockopt: PACKET_TX_RING");

	/* calculate memory to mmap in the kernel */
	size = packet_req.tp_block_size * packet_req.tp_block_nr;

	/* mmap Tx ring buffers memory */
	ps_header_start = mmap(0, size,
			PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
	if (ps_header_start < 0)
		PERROR_EXIT(EXIT_FAILURE, "mmap");

	/* fill peer sockaddr for SOCK_DGRAM */
	sa.sll_family = AF_PACKET;
	sa.sll_protocol = htons(ETH_P_IP);
	sa.sll_ifindex = ifr.ifr_ifindex;
	sa.sll_halen = ETH_ALEN;
	memset(&sa.sll_addr, 0xff, ETH_ALEN);

	ps_header = ps_header_start;
	while (1) {
		int sendlen, j;

		char *data = (void*)ps_header + TPACKET_HDRLEN
		              - sizeof(struct sockaddr_ll);

		switch((volatile uint32_t)ps_header->tp_status)
		{
		case TP_STATUS_AVAILABLE:
			memset(data, 0x23, 150);
			break;

		case TP_STATUS_WRONG_FORMAT:
			printf("An error has occured during transfer\n");
			exit(EXIT_FAILURE);
			break;

		default:
			printf("Buffer is not available, aborting\n");
			exit(1);
			break;
		}
		ps_header->tp_len = 150;
		ps_header->tp_status = TP_STATUS_SEND_REQUEST;

		sendlen = sendto(fd, NULL, 0, 0,
				(struct sockaddr *)&sa, sizeof(sa));
		if (sendlen < 0)
			perror("sendto");
		else if (sendlen == 0)
			printf("sendto(): nothing sent!\n");
		else
			printf("sendto(): sent %d bytes out\n", sendlen);

#define ST_IS(x) ((volatile uint32_t)ps_header->tp_status == x)
		printf("tp_status after sending: %s\n",
				ST_IS(TP_STATUS_AVAILABLE) ? "AVAILABLE" :
				ST_IS(TP_STATUS_SEND_REQUEST) ? "SEND_REQUEST" :
				ST_IS(TP_STATUS_WRONG_FORMAT) ? "WRONG_FORMAT" :
				"unknown");
#undef ST_IS

		ps_header = (void *)ps_header + packet_req.tp_frame_size;
		if (ps_header >= ps_header_start + size)
			ps_header = ps_header_start;

		sleep(1);
	}
	return 0;
}
--------------------[end of packet_mmap_test.c]--------------------
