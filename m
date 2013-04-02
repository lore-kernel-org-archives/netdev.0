From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next] selftests: net: add PF_PACKET TPACKET v1/v2/v3 selftests
Date: Wed,  3 Apr 2013 00:12:25 +0200
Message-ID: <1364940745-2426-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43543 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933191Ab3DBWM3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Apr 2013 18:12:29 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a simple test case that probes the packet socket's
TPACKET_V1, TPACKET_V2 and TPACKET_V3 behavior regarding mmap(2)'ed
I/O for a small burst of 100 packets. The test currently runs for ...

  TPACKET_V1: RX_RING, TX_RING
  TPACKET_V2: RX_RING, TX_RING
  TPACKET_V3: RX_RING

... and will output on success:

  test: TPACKET_V1 with PACKET_RX_RING .................... 100 pkts (9600 bytes)
  test: TPACKET_V1 with PACKET_TX_RING .................... 100 pkts (9600 bytes)
  test: TPACKET_V2 with PACKET_RX_RING .................... 100 pkts (9600 bytes)
  test: TPACKET_V2 with PACKET_TX_RING .................... 100 pkts (9600 bytes)
  test: TPACKET_V3 with PACKET_RX_RING .................... 100 pkts (9600 bytes)
  OK. All tests passed

Reusable parts of psock_fanout.c have been put into a psock_lib.h
file for common usage. Test case successfully tested on x86_64.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 tools/testing/selftests/net/Makefile          |   4 +-
 tools/testing/selftests/net/psock_fanout.c    |  88 +--
 tools/testing/selftests/net/psock_lib.h       | 127 ++++
 tools/testing/selftests/net/psock_tpacket.c   | 824 ++++++++++++++++++++++++++
 tools/testing/selftests/net/run_afpackettests |  10 +
 5 files changed, 966 insertions(+), 87 deletions(-)
 create mode 100644 tools/testing/selftests/net/psock_lib.h
 create mode 100644 tools/testing/selftests/net/psock_tpacket.c

diff --git a/tools/testing/selftests/net/Makefile b/tools/testing/selftests/net/Makefile
index bd6e272..750512b 100644
--- a/tools/testing/selftests/net/Makefile
+++ b/tools/testing/selftests/net/Makefile
@@ -1,11 +1,11 @@
 # Makefile for net selftests
 
 CC = $(CROSS_COMPILE)gcc
-CFLAGS = -Wall
+CFLAGS = -Wall -O2 -g
 
 CFLAGS += -I../../../../usr/include/
 
-NET_PROGS = socket psock_fanout
+NET_PROGS = socket psock_fanout psock_tpacket
 
 all: $(NET_PROGS)
 %: %.c
diff --git a/tools/testing/selftests/net/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
index 59bd636..57b9c2b 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -61,91 +61,9 @@
 #include <sys/types.h>
 #include <unistd.h>
 
-#define DATA_LEN			100
-#define DATA_CHAR			'a'
-#define RING_NUM_FRAMES			20
-#define PORT_BASE			8000
-
-static void pair_udp_open(int fds[], uint16_t port)
-{
-	struct sockaddr_in saddr, daddr;
-
-	fds[0] = socket(PF_INET, SOCK_DGRAM, 0);
-	fds[1] = socket(PF_INET, SOCK_DGRAM, 0);
-	if (fds[0] == -1 || fds[1] == -1) {
-		fprintf(stderr, "ERROR: socket dgram\n");
-		exit(1);
-	}
-
-	memset(&saddr, 0, sizeof(saddr));
-	saddr.sin_family = AF_INET;
-	saddr.sin_port = htons(port);
-	saddr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
-
-	memset(&daddr, 0, sizeof(daddr));
-	daddr.sin_family = AF_INET;
-	daddr.sin_port = htons(port + 1);
-	daddr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+#include "psock_lib.h"
 
-	/* must bind both to get consistent hash result */
-	if (bind(fds[1], (void *) &daddr, sizeof(daddr))) {
-		perror("bind");
-		exit(1);
-	}
-	if (bind(fds[0], (void *) &saddr, sizeof(saddr))) {
-		perror("bind");
-		exit(1);
-	}
-	if (connect(fds[0], (void *) &daddr, sizeof(daddr))) {
-		perror("connect");
-		exit(1);
-	}
-}
-
-static void pair_udp_send(int fds[], int num)
-{
-	char buf[DATA_LEN], rbuf[DATA_LEN];
-
-	memset(buf, DATA_CHAR, sizeof(buf));
-	while (num--) {
-		/* Should really handle EINTR and EAGAIN */
-		if (write(fds[0], buf, sizeof(buf)) != sizeof(buf)) {
-			fprintf(stderr, "ERROR: send failed left=%d\n", num);
-			exit(1);
-		}
-		if (read(fds[1], rbuf, sizeof(rbuf)) != sizeof(rbuf)) {
-			fprintf(stderr, "ERROR: recv failed left=%d\n", num);
-			exit(1);
-		}
-		if (memcmp(buf, rbuf, sizeof(buf))) {
-			fprintf(stderr, "ERROR: data failed left=%d\n", num);
-			exit(1);
-		}
-	}
-}
-
-static void sock_fanout_setfilter(int fd)
-{
-	struct sock_filter bpf_filter[] = {
-		{ 0x80, 0, 0, 0x00000000 },  /* LD  pktlen		      */
-		{ 0x35, 0, 5, DATA_LEN   },  /* JGE DATA_LEN  [f goto nomatch]*/
-		{ 0x30, 0, 0, 0x00000050 },  /* LD  ip[80]		      */
-		{ 0x15, 0, 3, DATA_CHAR  },  /* JEQ DATA_CHAR [f goto nomatch]*/
-		{ 0x30, 0, 0, 0x00000051 },  /* LD  ip[81]		      */
-		{ 0x15, 0, 1, DATA_CHAR  },  /* JEQ DATA_CHAR [f goto nomatch]*/
-		{ 0x6, 0, 0, 0x00000060  },  /* RET match	              */
-/* nomatch */	{ 0x6, 0, 0, 0x00000000  },  /* RET no match		      */
-	};
-	struct sock_fprog bpf_prog;
-
-	bpf_prog.filter = bpf_filter;
-	bpf_prog.len = sizeof(bpf_filter) / sizeof(struct sock_filter);
-	if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &bpf_prog,
-		       sizeof(bpf_prog))) {
-		perror("setsockopt SO_ATTACH_FILTER");
-		exit(1);
-	}
-}
+#define RING_NUM_FRAMES			20
 
 /* Open a socket in a given fanout mode.
  * @return -1 if mode is bad, a valid socket otherwise */
@@ -169,7 +87,7 @@ static int sock_fanout_open(uint16_t typeflags, int num_packets)
 		return -1;
 	}
 
-	sock_fanout_setfilter(fd);
+	pair_udp_setfilter(fd);
 	return fd;
 }
 
diff --git a/tools/testing/selftests/net/psock_lib.h b/tools/testing/selftests/net/psock_lib.h
new file mode 100644
index 0000000..37da54a
--- /dev/null
+++ b/tools/testing/selftests/net/psock_lib.h
@@ -0,0 +1,127 @@
+/*
+ * Copyright 2013 Google Inc.
+ * Author: Willem de Bruijn <willemb@google.com>
+ *         Daniel Borkmann <dborkman@redhat.com>
+ *
+ * License (GPLv2):
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+
+#ifndef PSOCK_LIB_H
+#define PSOCK_LIB_H
+
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <string.h>
+#include <arpa/inet.h>
+#include <unistd.h>
+
+#define DATA_LEN			100
+#define DATA_CHAR			'a'
+
+#define PORT_BASE			8000
+
+#ifndef __maybe_unused
+# define __maybe_unused		__attribute__ ((__unused__))
+#endif
+
+static __maybe_unused void pair_udp_setfilter(int fd)
+{
+	struct sock_filter bpf_filter[] = {
+		{ 0x80, 0, 0, 0x00000000 },  /* LD  pktlen		      */
+		{ 0x35, 0, 5, DATA_LEN   },  /* JGE DATA_LEN  [f goto nomatch]*/
+		{ 0x30, 0, 0, 0x00000050 },  /* LD  ip[80]		      */
+		{ 0x15, 0, 3, DATA_CHAR  },  /* JEQ DATA_CHAR [f goto nomatch]*/
+		{ 0x30, 0, 0, 0x00000051 },  /* LD  ip[81]		      */
+		{ 0x15, 0, 1, DATA_CHAR  },  /* JEQ DATA_CHAR [f goto nomatch]*/
+		{ 0x06, 0, 0, 0x00000060 },  /* RET match	              */
+		{ 0x06, 0, 0, 0x00000000 },  /* RET no match		      */
+	};
+	struct sock_fprog bpf_prog;
+
+	bpf_prog.filter = bpf_filter;
+	bpf_prog.len = sizeof(bpf_filter) / sizeof(struct sock_filter);
+	if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &bpf_prog,
+		       sizeof(bpf_prog))) {
+		perror("setsockopt SO_ATTACH_FILTER");
+		exit(1);
+	}
+}
+
+static __maybe_unused void pair_udp_open(int fds[], uint16_t port)
+{
+	struct sockaddr_in saddr, daddr;
+
+	fds[0] = socket(PF_INET, SOCK_DGRAM, 0);
+	fds[1] = socket(PF_INET, SOCK_DGRAM, 0);
+	if (fds[0] == -1 || fds[1] == -1) {
+		fprintf(stderr, "ERROR: socket dgram\n");
+		exit(1);
+	}
+
+	memset(&saddr, 0, sizeof(saddr));
+	saddr.sin_family = AF_INET;
+	saddr.sin_port = htons(port);
+	saddr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+
+	memset(&daddr, 0, sizeof(daddr));
+	daddr.sin_family = AF_INET;
+	daddr.sin_port = htons(port + 1);
+	daddr.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
+
+	/* must bind both to get consistent hash result */
+	if (bind(fds[1], (void *) &daddr, sizeof(daddr))) {
+		perror("bind");
+		exit(1);
+	}
+	if (bind(fds[0], (void *) &saddr, sizeof(saddr))) {
+		perror("bind");
+		exit(1);
+	}
+	if (connect(fds[0], (void *) &daddr, sizeof(daddr))) {
+		perror("connect");
+		exit(1);
+	}
+}
+
+static __maybe_unused void pair_udp_send(int fds[], int num)
+{
+	char buf[DATA_LEN], rbuf[DATA_LEN];
+
+	memset(buf, DATA_CHAR, sizeof(buf));
+	while (num--) {
+		/* Should really handle EINTR and EAGAIN */
+		if (write(fds[0], buf, sizeof(buf)) != sizeof(buf)) {
+			fprintf(stderr, "ERROR: send failed left=%d\n", num);
+			exit(1);
+		}
+		if (read(fds[1], rbuf, sizeof(rbuf)) != sizeof(rbuf)) {
+			fprintf(stderr, "ERROR: recv failed left=%d\n", num);
+			exit(1);
+		}
+		if (memcmp(buf, rbuf, sizeof(buf))) {
+			fprintf(stderr, "ERROR: data failed left=%d\n", num);
+			exit(1);
+		}
+	}
+}
+
+static __maybe_unused void pair_udp_close(int fds[])
+{
+	close(fds[0]);
+	close(fds[1]);
+}
+
+#endif /* PSOCK_LIB_H */
diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
new file mode 100644
index 0000000..a8d7ffa
--- /dev/null
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -0,0 +1,824 @@
+/*
+ * Copyright 2013 Red Hat, Inc.
+ * Author: Daniel Borkmann <dborkman@redhat.com>
+ *
+ * A basic test of packet socket's TPACKET_V1/TPACKET_V2/TPACKET_V3 behavior.
+ *
+ * Control:
+ *   Test the setup of the TPACKET socket with different patterns that are
+ *   known to fail (TODO) resp. succeed (OK).
+ *
+ * Datapath:
+ *   Open a pair of packet sockets and send resp. receive an a priori known
+ *   packet pattern accross the sockets and check if it was received resp.
+ *   sent correctly. Fanout in combination with RX_RING is currently not
+ *   tested here.
+ *
+ *   The test currently runs for
+ *   - TPACKET_V1: RX_RING, TX_RING
+ *   - TPACKET_V2: RX_RING, TX_RING
+ *   - TPACKET_V3: RX_RING
+ *
+ * License (GPLv2):
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ *
+ * This program is distributed in the hope it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE. * See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc.,
+ * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/socket.h>
+#include <sys/mman.h>
+#include <linux/if_packet.h>
+#include <linux/filter.h>
+#include <ctype.h>
+#include <fcntl.h>
+#include <unistd.h>
+#include <bits/wordsize.h>
+#include <net/ethernet.h>
+#include <netinet/ip.h>
+#include <arpa/inet.h>
+#include <stdint.h>
+#include <string.h>
+#include <assert.h>
+#include <net/if.h>
+#include <inttypes.h>
+#include <poll.h>
+
+#include "psock_lib.h"
+
+#ifndef bug_on
+# define bug_on(cond)		assert(!(cond))
+#endif
+
+#ifndef __aligned_tpacket
+# define __aligned_tpacket	__attribute__((aligned(TPACKET_ALIGNMENT)))
+#endif
+
+#ifndef __align_tpacket
+# define __align_tpacket(x)	__attribute__((aligned(TPACKET_ALIGN(x))))
+#endif
+
+#define BLOCK_STATUS(x)		((x)->h1.block_status)
+#define BLOCK_NUM_PKTS(x)	((x)->h1.num_pkts)
+#define BLOCK_O2FP(x)		((x)->h1.offset_to_first_pkt)
+#define BLOCK_LEN(x)		((x)->h1.blk_len)
+#define BLOCK_SNUM(x)		((x)->h1.seq_num)
+#define BLOCK_O2PRIV(x)		((x)->offset_to_priv)
+#define BLOCK_PRIV(x)		((void *) ((uint8_t *) (x) + BLOCK_O2PRIV(x)))
+#define BLOCK_HDR_LEN		(ALIGN_8(sizeof(struct block_desc)))
+#define ALIGN_8(x)		(((x) + 8 - 1) & ~(8 - 1))
+#define BLOCK_PLUS_PRIV(sz_pri)	(BLOCK_HDR_LEN + ALIGN_8((sz_pri)))
+
+#define NUM_PACKETS		100
+
+struct ring {
+	struct iovec *rd;
+	uint8_t *mm_space;
+	size_t mm_len, rd_len;
+	struct sockaddr_ll ll;
+	void (*walk)(int sock, struct ring *ring);
+	int type, rd_num, flen, version;
+	union {
+		struct tpacket_req  req;
+		struct tpacket_req3 req3;
+	};
+};
+
+struct block_desc {
+	uint32_t version;
+	uint32_t offset_to_priv;
+	struct tpacket_hdr_v1 h1;
+};
+
+union frame_map {
+	struct {
+		struct tpacket_hdr tp_h __aligned_tpacket;
+		struct sockaddr_ll s_ll __align_tpacket(sizeof(struct tpacket_hdr));
+	} *v1;
+	struct {
+		struct tpacket2_hdr tp_h __aligned_tpacket;
+		struct sockaddr_ll s_ll __align_tpacket(sizeof(struct tpacket2_hdr));
+	} *v2;
+	void *raw;
+};
+
+static unsigned int total_packets, total_bytes;
+
+static int pfsocket(int ver)
+{
+	int ret, sock = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
+	if (sock == -1) {
+		perror("socket");
+		exit(1);
+	}
+
+	ret = setsockopt(sock, SOL_PACKET, PACKET_VERSION, &ver, sizeof(ver));
+	if (ret == -1) {
+		perror("setsockopt");
+		exit(1);
+	}
+
+	return sock;
+}
+
+static void status_bar_update(void)
+{
+	if (total_packets % 10 == 0) {
+		fprintf(stderr, ".");
+		fflush(stderr);
+	}
+}
+
+static void test_payload(void *pay, size_t len)
+{
+	struct ethhdr *eth = pay;
+
+	if (len < sizeof(struct ethhdr)) {
+		fprintf(stderr, "test_payload: packet too "
+			"small: %zu bytes!\n", len);
+		exit(1);
+	}
+
+	if (eth->h_proto != htons(ETH_P_IP)) {
+		fprintf(stderr, "test_payload: wrong ethernet "
+			"type: 0x%x!\n", ntohs(eth->h_proto));
+		exit(1);
+	}
+}
+
+static void create_payload(void *pay, size_t *len)
+{
+	int i;
+	struct ethhdr *eth = pay;
+	struct iphdr *ip = pay + sizeof(*eth);
+
+	/* Lets create some broken crap, that still passes
+	 * our BPF filter.
+	 */
+
+	*len = DATA_LEN + 42;
+
+	memset(pay, 0xff, ETH_ALEN * 2);
+	eth->h_proto = htons(ETH_P_IP);
+
+	for (i = 0; i < sizeof(*ip); ++i)
+		((uint8_t *) pay)[i + sizeof(*eth)] = (uint8_t) rand();
+
+	ip->ihl = 5;
+	ip->version = 4;
+	ip->protocol = 0x11;
+	ip->frag_off = 0;
+	ip->ttl = 64;
+	ip->tot_len = htons((uint16_t) *len - sizeof(*eth));
+
+	ip->saddr = htonl(INADDR_LOOPBACK);
+	ip->daddr = htonl(INADDR_LOOPBACK);
+
+	memset(pay + sizeof(*eth) + sizeof(*ip),
+	       DATA_CHAR, DATA_LEN);
+}
+
+static inline int __v1_rx_kernel_ready(struct tpacket_hdr *hdr)
+{
+	return ((hdr->tp_status & TP_STATUS_USER) == TP_STATUS_USER);
+}
+
+static inline void __v1_rx_user_ready(struct tpacket_hdr *hdr)
+{
+	hdr->tp_status = TP_STATUS_KERNEL;
+	__sync_synchronize();
+}
+
+static inline int __v2_rx_kernel_ready(struct tpacket2_hdr *hdr)
+{
+	return ((hdr->tp_status & TP_STATUS_USER) == TP_STATUS_USER);
+}
+
+static inline void __v2_rx_user_ready(struct tpacket2_hdr *hdr)
+{
+	hdr->tp_status = TP_STATUS_KERNEL;
+	__sync_synchronize();
+}
+
+static inline int __v1_v2_rx_kernel_ready(void *base, int version)
+{
+	switch (version) {
+	case TPACKET_V1:
+		return __v1_rx_kernel_ready(base);
+	case TPACKET_V2:
+		return __v2_rx_kernel_ready(base);
+	default:
+		bug_on(1);
+		return 0;
+	}
+}
+
+static inline void __v1_v2_rx_user_ready(void *base, int version)
+{
+	switch (version) {
+	case TPACKET_V1:
+		__v1_rx_user_ready(base);
+		break;
+	case TPACKET_V2:
+		__v2_rx_user_ready(base);
+		break;
+	}
+}
+
+static void walk_v1_v2_rx(int sock, struct ring *ring)
+{
+	struct pollfd pfd;
+	int udp_sock[2];
+	union frame_map ppd;
+	unsigned int frame_num = 0;
+
+	bug_on(ring->type != PACKET_RX_RING);
+
+	pair_udp_open(udp_sock, PORT_BASE);
+	pair_udp_setfilter(sock);
+
+	memset(&pfd, 0, sizeof(pfd));
+	pfd.fd = sock;
+	pfd.events = POLLIN | POLLERR;
+	pfd.revents = 0;
+
+	pair_udp_send(udp_sock, NUM_PACKETS);
+
+	while (total_packets < NUM_PACKETS * 2) {
+		while (__v1_v2_rx_kernel_ready(ring->rd[frame_num].iov_base,
+					       ring->version)) {
+			ppd.raw = ring->rd[frame_num].iov_base;
+
+			switch (ring->version) {
+			case TPACKET_V1:
+				test_payload((uint8_t *) ppd.raw + ppd.v1->tp_h.tp_mac,
+					     ppd.v1->tp_h.tp_snaplen);
+				total_bytes += ppd.v1->tp_h.tp_snaplen;
+				break;
+
+			case TPACKET_V2:
+				test_payload((uint8_t *) ppd.raw + ppd.v2->tp_h.tp_mac,
+					     ppd.v2->tp_h.tp_snaplen);
+				total_bytes += ppd.v2->tp_h.tp_snaplen;
+				break;
+			}
+
+			status_bar_update();
+			total_packets++;
+
+			__v1_v2_rx_user_ready(ppd.raw, ring->version);
+
+			frame_num = (frame_num + 1) % ring->rd_num;
+		}
+
+		poll(&pfd, 1, 1);
+	}
+
+	pair_udp_close(udp_sock);
+
+	if (total_packets != 2 * NUM_PACKETS) {
+		fprintf(stderr, "walk_v%d_rx: received %u out of %u pkts\n",
+			ring->version, total_packets, NUM_PACKETS);
+		exit(1);
+	}
+
+	fprintf(stderr, " %u pkts (%u bytes)", NUM_PACKETS, total_bytes >> 1);
+}
+
+static inline int __v1_tx_kernel_ready(struct tpacket_hdr *hdr)
+{
+	return ((hdr->tp_status & TP_STATUS_AVAILABLE) == TP_STATUS_AVAILABLE);
+}
+
+static inline void __v1_tx_user_ready(struct tpacket_hdr *hdr)
+{
+	hdr->tp_status = TP_STATUS_SEND_REQUEST;
+	__sync_synchronize();
+}
+
+static inline int __v2_tx_kernel_ready(struct tpacket2_hdr *hdr)
+{
+	return ((hdr->tp_status & TP_STATUS_AVAILABLE) == TP_STATUS_AVAILABLE);
+}
+
+static inline void __v2_tx_user_ready(struct tpacket2_hdr *hdr)
+{
+	hdr->tp_status = TP_STATUS_SEND_REQUEST;
+	__sync_synchronize();
+}
+
+static inline int __v1_v2_tx_kernel_ready(void *base, int version)
+{
+	switch (version) {
+	case TPACKET_V1:
+		return __v1_tx_kernel_ready(base);
+	case TPACKET_V2:
+		return __v2_tx_kernel_ready(base);
+	default:
+		bug_on(1);
+		return 0;
+	}
+}
+
+static inline void __v1_v2_tx_user_ready(void *base, int version)
+{
+	switch (version) {
+	case TPACKET_V1:
+		__v1_tx_user_ready(base);
+		break;
+	case TPACKET_V2:
+		__v2_tx_user_ready(base);
+		break;
+	}
+}
+
+static void __v1_v2_set_packet_loss_discard(int sock)
+{
+	int ret, discard = 1;
+
+	ret = setsockopt(sock, SOL_PACKET, PACKET_LOSS, (void *) &discard,
+			 sizeof(discard));
+	if (ret == -1) {
+		perror("setsockopt");
+		exit(1);
+	}
+}
+
+static void walk_v1_v2_tx(int sock, struct ring *ring)
+{
+	struct pollfd pfd;
+	int rcv_sock, ret;
+	size_t packet_len;
+	union frame_map ppd;
+	char packet[1024];
+	unsigned int frame_num = 0, got = 0;
+	struct sockaddr_ll ll = {
+		.sll_family = PF_PACKET,
+		.sll_halen = ETH_ALEN,
+	};
+
+	bug_on(ring->type != PACKET_TX_RING);
+	bug_on(ring->rd_num < NUM_PACKETS);
+
+	rcv_sock = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_ALL));
+	if (rcv_sock == -1) {
+		perror("socket");
+		exit(1);
+	}
+
+	pair_udp_setfilter(rcv_sock);
+
+	ll.sll_ifindex = if_nametoindex("lo");
+	ret = bind(rcv_sock, (struct sockaddr *) &ll, sizeof(ll));
+	if (ret == -1) {
+		perror("bind");
+		exit(1);
+	}
+
+	memset(&pfd, 0, sizeof(pfd));
+	pfd.fd = sock;
+	pfd.events = POLLOUT | POLLERR;
+	pfd.revents = 0;
+
+	total_packets = NUM_PACKETS;
+	create_payload(packet, &packet_len);
+
+	while (total_packets > 0) {
+		while (__v1_v2_tx_kernel_ready(ring->rd[frame_num].iov_base,
+					       ring->version) &&
+		       total_packets > 0) {
+			ppd.raw = ring->rd[frame_num].iov_base;
+
+			switch (ring->version) {
+			case TPACKET_V1:
+				ppd.v1->tp_h.tp_snaplen = packet_len;
+				ppd.v1->tp_h.tp_len = packet_len;
+
+				memcpy((uint8_t *) ppd.raw + TPACKET_HDRLEN -
+				       sizeof(struct sockaddr_ll), packet,
+				       packet_len);
+				total_bytes += ppd.v1->tp_h.tp_snaplen;
+				break;
+
+			case TPACKET_V2:
+				ppd.v2->tp_h.tp_snaplen = packet_len;
+				ppd.v2->tp_h.tp_len = packet_len;
+
+				memcpy((uint8_t *) ppd.raw + TPACKET2_HDRLEN -
+				       sizeof(struct sockaddr_ll), packet,
+				       packet_len);
+				total_bytes += ppd.v2->tp_h.tp_snaplen;
+				break;
+			}
+
+			status_bar_update();
+			total_packets--;
+
+			__v1_v2_tx_user_ready(ppd.raw, ring->version);
+
+			frame_num = (frame_num + 1) % ring->rd_num;
+		}
+
+		poll(&pfd, 1, 1);
+	}
+
+	bug_on(total_packets != 0);
+
+	ret = sendto(sock, NULL, 0, 0, NULL, 0);
+	if (ret == -1) {
+		perror("sendto");
+		exit(1);
+	}
+
+	while ((ret = recvfrom(rcv_sock, packet, sizeof(packet),
+			       0, NULL, NULL)) > 0 &&
+	       total_packets < NUM_PACKETS) {
+		got += ret;
+		test_payload(packet, ret);
+
+		status_bar_update();
+		total_packets++;
+	}
+
+	close(rcv_sock);
+
+	if (total_packets != NUM_PACKETS) {
+		fprintf(stderr, "walk_v%d_rx: received %u out of %u pkts\n",
+			ring->version, total_packets, NUM_PACKETS);
+		exit(1);
+	}
+
+	fprintf(stderr, " %u pkts (%u bytes)", NUM_PACKETS, got);
+}
+
+static void walk_v1_v2(int sock, struct ring *ring)
+{
+	if (ring->type == PACKET_RX_RING)
+		walk_v1_v2_rx(sock, ring);
+	else
+		walk_v1_v2_tx(sock, ring);
+}
+
+static uint64_t __v3_prev_block_seq_num = 0;
+
+void __v3_test_block_seq_num(struct block_desc *pbd)
+{
+	if (__v3_prev_block_seq_num + 1 != BLOCK_SNUM(pbd)) {
+		fprintf(stderr, "\nprev_block_seq_num:%"PRIu64", expected "
+			"seq:%"PRIu64" != actual seq:%"PRIu64"\n",
+			__v3_prev_block_seq_num, __v3_prev_block_seq_num + 1,
+			(uint64_t) BLOCK_SNUM(pbd));
+		exit(1);
+	}
+
+	__v3_prev_block_seq_num = BLOCK_SNUM(pbd);
+}
+
+static void __v3_test_block_len(struct block_desc *pbd, uint32_t bytes, int block_num)
+{
+	if (BLOCK_NUM_PKTS(pbd)) {
+		if (bytes != BLOCK_LEN(pbd)) {
+			fprintf(stderr, "\nblock:%u with %upackets, expected "
+				"len:%u != actual len:%u\n", block_num,
+				BLOCK_NUM_PKTS(pbd), bytes, BLOCK_LEN(pbd));
+			exit(1);
+		}
+	} else {
+		if (BLOCK_LEN(pbd) != BLOCK_PLUS_PRIV(13)) {
+			fprintf(stderr, "\nblock:%u, expected len:%lu != "
+				"actual len:%u\n", block_num, BLOCK_HDR_LEN,
+				BLOCK_LEN(pbd));
+			exit(1);
+		}
+	}
+}
+
+static void __v3_test_block_header(struct block_desc *pbd, const int block_num)
+{
+	uint32_t block_status = BLOCK_STATUS(pbd);
+
+	if ((block_status & TP_STATUS_USER) == 0) {
+		fprintf(stderr, "\nblock %u: not in TP_STATUS_USER\n", block_num);
+		exit(1);
+	}
+
+	__v3_test_block_seq_num(pbd);
+}
+
+static void __v3_walk_block(struct block_desc *pbd, const int block_num)
+{
+	int num_pkts = BLOCK_NUM_PKTS(pbd), i;
+	unsigned long bytes = 0;
+	unsigned long bytes_with_padding = BLOCK_PLUS_PRIV(13);
+	struct tpacket3_hdr *ppd;
+
+	__v3_test_block_header(pbd, block_num);
+
+	ppd = (struct tpacket3_hdr *) ((uint8_t *) pbd + BLOCK_O2FP(pbd));
+	for (i = 0; i < num_pkts; ++i) {
+		bytes += ppd->tp_snaplen;
+
+		if (ppd->tp_next_offset)
+			bytes_with_padding += ppd->tp_next_offset;
+		else
+			bytes_with_padding += ALIGN_8(ppd->tp_snaplen + ppd->tp_mac);
+
+		test_payload((uint8_t *) ppd + ppd->tp_mac, ppd->tp_snaplen);
+
+		status_bar_update();
+		total_packets++;
+
+		ppd = (struct tpacket3_hdr *) ((uint8_t *) ppd + ppd->tp_next_offset);
+		__sync_synchronize();
+	}
+
+	__v3_test_block_len(pbd, bytes_with_padding, block_num);
+	total_bytes += bytes;
+}
+
+void __v3_flush_block(struct block_desc *pbd)
+{
+	BLOCK_STATUS(pbd) = TP_STATUS_KERNEL;
+	__sync_synchronize();
+}
+
+static void walk_v3_rx(int sock, struct ring *ring)
+{
+	unsigned int block_num = 0;
+	struct pollfd pfd;
+	struct block_desc *pbd;
+	int udp_sock[2];
+
+	bug_on(ring->type != PACKET_RX_RING);
+
+	pair_udp_open(udp_sock, PORT_BASE);
+	pair_udp_setfilter(sock);
+
+	memset(&pfd, 0, sizeof(pfd));
+	pfd.fd = sock;
+	pfd.events = POLLIN | POLLERR;
+	pfd.revents = 0;
+
+	pair_udp_send(udp_sock, NUM_PACKETS);
+
+	while (total_packets < NUM_PACKETS * 2) {
+		pbd = (struct block_desc *) ring->rd[block_num].iov_base;
+
+		while ((BLOCK_STATUS(pbd) & TP_STATUS_USER) == 0)
+			poll(&pfd, 1, 1);
+
+		__v3_walk_block(pbd, block_num);
+		__v3_flush_block(pbd);
+
+		block_num = (block_num + 1) % ring->rd_num;
+	}
+
+	pair_udp_close(udp_sock);
+
+	if (total_packets != 2 * NUM_PACKETS) {
+		fprintf(stderr, "walk_v3_rx: received %u out of %u pkts\n",
+			total_packets, NUM_PACKETS);
+		exit(1);
+	}
+
+	fprintf(stderr, " %u pkts (%u bytes)", NUM_PACKETS, total_bytes >> 1);
+}
+
+static void walk_v3(int sock, struct ring *ring)
+{
+	if (ring->type == PACKET_RX_RING)
+		walk_v3_rx(sock, ring);
+	else
+		bug_on(1);
+}
+
+static void __v1_v2_fill(struct ring *ring, unsigned int blocks)
+{
+	ring->req.tp_block_size = getpagesize() << 2;
+	ring->req.tp_frame_size = TPACKET_ALIGNMENT << 7;
+	ring->req.tp_block_nr = blocks;
+
+	ring->req.tp_frame_nr = ring->req.tp_block_size /
+				ring->req.tp_frame_size *
+				ring->req.tp_block_nr;
+
+	ring->mm_len = ring->req.tp_block_size * ring->req.tp_block_nr;
+	ring->walk = walk_v1_v2;
+	ring->rd_num = ring->req.tp_frame_nr;
+	ring->flen = ring->req.tp_frame_size;
+}
+
+static void __v3_fill(struct ring *ring, unsigned int blocks)
+{
+	ring->req3.tp_retire_blk_tov = 64;
+	ring->req3.tp_sizeof_priv = 13;
+	ring->req3.tp_feature_req_word |= TP_FT_REQ_FILL_RXHASH;
+
+	ring->req3.tp_block_size = getpagesize() << 2;
+	ring->req3.tp_frame_size = TPACKET_ALIGNMENT << 7;
+	ring->req3.tp_block_nr = blocks;
+
+	ring->req3.tp_frame_nr = ring->req3.tp_block_size /
+				 ring->req3.tp_frame_size *
+				 ring->req3.tp_block_nr;
+
+	ring->mm_len = ring->req3.tp_block_size * ring->req3.tp_block_nr;
+	ring->walk = walk_v3;
+	ring->rd_num = ring->req3.tp_block_nr;
+	ring->flen = ring->req3.tp_block_size;
+}
+
+static void setup_ring(int sock, struct ring *ring, int version, int type)
+{
+	int ret = 0;
+	unsigned int blocks = 256;
+
+	ring->type = type;
+	ring->version = version;
+
+	switch (version) {
+	case TPACKET_V1:
+	case TPACKET_V2:
+		if (type == PACKET_TX_RING)
+			__v1_v2_set_packet_loss_discard(sock);
+		__v1_v2_fill(ring, blocks);
+		ret = setsockopt(sock, SOL_PACKET, type, &ring->req,
+				 sizeof(ring->req));
+		break;
+
+	case TPACKET_V3:
+		__v3_fill(ring, blocks);
+		ret = setsockopt(sock, SOL_PACKET, type, &ring->req3,
+				 sizeof(ring->req3));
+		break;
+	}
+
+	if (ret == -1) {
+		perror("setsockopt");
+		exit(1);
+	}
+
+	ring->rd_len = ring->rd_num * sizeof(*ring->rd);
+	ring->rd = malloc(ring->rd_len);
+	if (ring->rd == NULL) {
+		perror("malloc");
+		exit(1);
+	}
+
+	total_packets = 0;
+	total_bytes = 0;
+}
+
+static void mmap_ring(int sock, struct ring *ring)
+{
+	int i;
+
+	ring->mm_space = mmap(0, ring->mm_len, PROT_READ | PROT_WRITE,
+			      MAP_SHARED | MAP_LOCKED | MAP_POPULATE, sock, 0);
+	if (ring->mm_space == MAP_FAILED) {
+		perror("mmap");
+		exit(1);
+	}
+
+	memset(ring->rd, 0, ring->rd_len);
+	for (i = 0; i < ring->rd_num; ++i) {
+		ring->rd[i].iov_base = ring->mm_space + (i * ring->flen);
+		ring->rd[i].iov_len = ring->flen;
+	}
+}
+
+static void bind_ring(int sock, struct ring *ring)
+{
+	int ret;
+
+	ring->ll.sll_family = PF_PACKET;
+	ring->ll.sll_protocol = htons(ETH_P_ALL);
+	ring->ll.sll_ifindex = if_nametoindex("lo");
+	ring->ll.sll_hatype = 0;
+	ring->ll.sll_pkttype = 0;
+	ring->ll.sll_halen = 0;
+
+	ret = bind(sock, (struct sockaddr *) &ring->ll, sizeof(ring->ll));
+	if (ret == -1) {
+		perror("bind");
+		exit(1);
+	}
+}
+
+static void walk_ring(int sock, struct ring *ring)
+{
+	ring->walk(sock, ring);
+}
+
+static void unmap_ring(int sock, struct ring *ring)
+{
+	munmap(ring->mm_space, ring->mm_len);
+	free(ring->rd);
+}
+
+static int test_kernel_bit_width(void)
+{
+	char in[512], *ptr;
+	int num = 0, fd;
+	ssize_t ret;
+
+	fd = open("/proc/kallsyms", O_RDONLY);
+	if (fd == -1) {
+		perror("open");
+		exit(1);
+	}
+
+	ret = read(fd, in, sizeof(in));
+	if (ret <= 0) {
+		perror("read");
+		exit(1);
+	}
+
+	close(fd);
+
+	ptr = in;
+	while(!isspace(*ptr)) {
+		num++;
+		ptr++;
+	}
+
+	return num * 4;
+}
+
+static int test_user_bit_width(void)
+{
+	return __WORDSIZE;
+}
+
+static const char *tpacket_str[] = {
+	[TPACKET_V1] = "TPACKET_V1",
+	[TPACKET_V2] = "TPACKET_V2",
+	[TPACKET_V3] = "TPACKET_V3",
+};
+
+static const char *type_str[] = {
+	[PACKET_RX_RING] = "PACKET_RX_RING",
+	[PACKET_TX_RING] = "PACKET_TX_RING",
+};
+
+static int test_tpacket(int version, int type)
+{
+	int sock;
+	struct ring ring;
+
+	fprintf(stderr, "test: %s with %s ", tpacket_str[version],
+		type_str[type]);
+	fflush(stderr);
+
+	if (version == TPACKET_V1 &&
+	    test_kernel_bit_width() != test_user_bit_width()) {
+		fprintf(stderr, "test: skip %s %s since user and kernel "
+			"space have different bit width\n",
+			tpacket_str[version], type_str[type]);
+		return 0;
+	}
+
+	sock = pfsocket(version);
+	memset(&ring, 0, sizeof(ring));
+	setup_ring(sock, &ring, version, type);
+	mmap_ring(sock, &ring);
+	bind_ring(sock, &ring);
+	walk_ring(sock, &ring);
+	unmap_ring(sock, &ring);
+	close(sock);
+
+	fprintf(stderr, "\n");
+	return 0;
+}
+
+int main(void)
+{
+	int ret = 0;
+
+	ret |= test_tpacket(TPACKET_V1, PACKET_RX_RING);
+	ret |= test_tpacket(TPACKET_V1, PACKET_TX_RING);
+
+	ret |= test_tpacket(TPACKET_V2, PACKET_RX_RING);
+	ret |= test_tpacket(TPACKET_V2, PACKET_TX_RING);
+
+	ret |= test_tpacket(TPACKET_V3, PACKET_RX_RING);
+
+	if (ret)
+		return 1;
+
+	printf("OK. All tests passed\n");
+	return 0;
+}
diff --git a/tools/testing/selftests/net/run_afpackettests b/tools/testing/selftests/net/run_afpackettests
index 7907824..5246e78 100644
--- a/tools/testing/selftests/net/run_afpackettests
+++ b/tools/testing/selftests/net/run_afpackettests
@@ -14,3 +14,13 @@ if [ $? -ne 0 ]; then
 else
 	echo "[PASS]"
 fi
+
+echo "--------------------"
+echo "running psock_tpacket test"
+echo "--------------------"
+./psock_tpacket
+if [ $? -ne 0 ]; then
+	echo "[FAIL]"
+else
+	echo "[PASS]"
+fi
-- 
1.7.11.7
