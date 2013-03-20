From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next] net: fix psock_fanout selftest hash collision
Date: Wed, 20 Mar 2013 02:42:44 -0400
Message-ID: <1363761764-4374-1-git-send-email-willemb@google.com>
References: <CA+FuTSeN1wXrSP8-piCdnv8MuqgokndSYsiidvdtC=d2tCqcDQ@mail.gmail.com>
Cc: Willem de Bruijn <willemb@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gg0-f202.google.com ([209.85.161.202]:39004 "EHLO
	mail-gg0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750902Ab3CTGsq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Mar 2013 02:48:46 -0400
Received: by mail-gg0-f202.google.com with SMTP id l4so126526ggi.5
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 23:48:45 -0700 (PDT)
In-Reply-To: <CA+FuTSeN1wXrSP8-piCdnv8MuqgokndSYsiidvdtC=d2tCqcDQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix flaky results with PACKET_FANOUT_HASH depending on whether the
two flows hash into the same packet socket or not.

Also adds tests for PACKET_FANOUT_LB and PACKET_FANOUT_CPU and
replaces the counting method with a packet ring.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 .../testing/selftests/net-afpacket/psock_fanout.c  | 160 +++++++++++++++------
 1 file changed, 120 insertions(+), 40 deletions(-)

diff --git a/tools/testing/selftests/net-afpacket/psock_fanout.c b/tools/testing/selftests/net-afpacket/psock_fanout.c
index af9b019..f765f09 100644
--- a/tools/testing/selftests/net-afpacket/psock_fanout.c
+++ b/tools/testing/selftests/net-afpacket/psock_fanout.c
@@ -16,11 +16,11 @@
  *   The test currently runs for
  *   - PACKET_FANOUT_HASH
  *   - PACKET_FANOUT_HASH with PACKET_FANOUT_FLAG_ROLLOVER
+ *   - PACKET_FANOUT_LB
+ *   - PACKET_FANOUT_CPU
  *   - PACKET_FANOUT_ROLLOVER
  *
  * Todo:
- * - datapath: PACKET_FANOUT_LB
- * - datapath: PACKET_FANOUT_CPU
  * - functionality: PACKET_FANOUT_FLAG_DEFRAG
  *
  * License (GPLv2):
@@ -39,18 +39,23 @@
  * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
  */
 
+#define _GNU_SOURCE		/* for sched_setaffinity */
+
 #include <arpa/inet.h>
 #include <errno.h>
+#include <fcntl.h>
 #include <linux/filter.h>
 #include <linux/if_packet.h>
 #include <net/ethernet.h>
 #include <netinet/ip.h>
 #include <netinet/udp.h>
-#include <fcntl.h>
+#include <poll.h>
+#include <sched.h>
 #include <stdint.h>
 #include <stdio.h>
 #include <stdlib.h>
 #include <string.h>
+#include <sys/mman.h>
 #include <sys/socket.h>
 #include <sys/stat.h>
 #include <sys/types.h>
@@ -58,6 +63,8 @@
 
 #define DATA_LEN			100
 #define DATA_CHAR			'a'
+#define RING_NUM_FRAMES			20
+#define PORT_BASE			8000
 
 static void pair_udp_open(int fds[], uint16_t port)
 {
@@ -162,37 +169,55 @@ static int sock_fanout_open(uint16_t typeflags, int num_packets)
 		return -1;
 	}
 
-	val = sizeof(struct iphdr) + sizeof(struct udphdr) + DATA_LEN;
-	val *= num_packets;
-	/* hack: apparently, the above calculation is too small (TODO: fix) */
-	val *= 3;
-	if (setsockopt(fd, SOL_SOCKET, SO_RCVBUF, &val, sizeof(val))) {
-		perror("setsockopt SO_RCVBUF");
-		exit(1);
-	}
-
 	sock_fanout_setfilter(fd);
 	return fd;
 }
 
-static void sock_fanout_read(int fds[], const int expect[])
+static char *sock_fanout_open_ring(int fd)
 {
-	struct tpacket_stats stats;
-	socklen_t ssize;
-	int ret[2];
+	struct tpacket_req req = {
+		.tp_block_size = getpagesize(),
+		.tp_frame_size = getpagesize(),
+		.tp_block_nr   = RING_NUM_FRAMES,
+		.tp_frame_nr   = RING_NUM_FRAMES,
+	};
+	char *ring;
 
-	ssize = sizeof(stats);
-	if (getsockopt(fds[0], SOL_PACKET, PACKET_STATISTICS, &stats, &ssize)) {
-		perror("getsockopt statistics 0");
+	if (setsockopt(fd, SOL_PACKET, PACKET_RX_RING, (void *) &req,
+		       sizeof(req))) {
+		perror("packetsock ring setsockopt");
 		exit(1);
 	}
-	ret[0] = stats.tp_packets - stats.tp_drops;
-	ssize = sizeof(stats);
-	if (getsockopt(fds[1], SOL_PACKET, PACKET_STATISTICS, &stats, &ssize)) {
-		perror("getsockopt statistics 1");
+
+	ring = mmap(0, req.tp_block_size * req.tp_block_nr,
+		    PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
+	if (!ring) {
+		fprintf(stderr, "packetsock ring mmap\n");
 		exit(1);
 	}
-	ret[1] = stats.tp_packets - stats.tp_drops;
+
+	return ring;
+}
+
+static int sock_fanout_read_ring(int fd, void *ring)
+{
+	struct tpacket_hdr *header = ring;
+	int count = 0;
+
+	while (header->tp_status & TP_STATUS_USER && count < RING_NUM_FRAMES) {
+		count++;
+		header = ring + (count * getpagesize());
+	}
+
+	return count;
+}
+
+static int sock_fanout_read(int fds[], char *rings[], const int expect[])
+{
+	int ret[2];
+
+	ret[0] = sock_fanout_read_ring(fds[0], rings[0]);
+	ret[1] = sock_fanout_read_ring(fds[1], rings[1]);
 
 	fprintf(stderr, "info: count=%d,%d, expect=%d,%d\n",
 			ret[0], ret[1], expect[0], expect[1]);
@@ -200,8 +225,10 @@ static void sock_fanout_read(int fds[], const int expect[])
 	if ((!(ret[0] == expect[0] && ret[1] == expect[1])) &&
 	    (!(ret[0] == expect[1] && ret[1] == expect[0]))) {
 		fprintf(stderr, "ERROR: incorrect queue lengths\n");
-		exit(1);
+		return 1;
 	}
+
+	return 0;
 }
 
 /* Test illegal mode + flag combination */
@@ -253,11 +280,12 @@ static void test_control_group(void)
 	}
 }
 
-static void test_datapath(uint16_t typeflags,
-			  const int expect1[], const int expect2[])
+static int test_datapath(uint16_t typeflags, int port_off,
+			 const int expect1[], const int expect2[])
 {
 	const int expect0[] = { 0, 0 };
-	int fds[2], fds_udp[2][2];
+	char *rings[2];
+	int fds[2], fds_udp[2][2], ret;
 
 	fprintf(stderr, "test: datapath 0x%hx\n", typeflags);
 
@@ -267,41 +295,93 @@ static void test_datapath(uint16_t typeflags,
 		fprintf(stderr, "ERROR: failed open\n");
 		exit(1);
 	}
-	pair_udp_open(fds_udp[0], 8000);
-	pair_udp_open(fds_udp[1], 8002);
-	sock_fanout_read(fds, expect0);
+	rings[0] = sock_fanout_open_ring(fds[0]);
+	rings[1] = sock_fanout_open_ring(fds[1]);
+	pair_udp_open(fds_udp[0], PORT_BASE);
+	pair_udp_open(fds_udp[1], PORT_BASE + port_off);
+	sock_fanout_read(fds, rings, expect0);
 
 	/* Send data, but not enough to overflow a queue */
 	pair_udp_send(fds_udp[0], 15);
 	pair_udp_send(fds_udp[1], 5);
-	sock_fanout_read(fds, expect1);
+	ret = sock_fanout_read(fds, rings, expect1);
 
 	/* Send more data, overflow the queue */
 	pair_udp_send(fds_udp[0], 15);
 	/* TODO: ensure consistent order between expect1 and expect2 */
-	sock_fanout_read(fds, expect2);
+	ret |= sock_fanout_read(fds, rings, expect2);
 
+	if (munmap(rings[1], RING_NUM_FRAMES * getpagesize()) ||
+	    munmap(rings[0], RING_NUM_FRAMES * getpagesize())) {
+		fprintf(stderr, "close rings\n");
+		exit(1);
+	}
 	if (close(fds_udp[1][1]) || close(fds_udp[1][0]) ||
 	    close(fds_udp[0][1]) || close(fds_udp[0][0]) ||
 	    close(fds[1]) || close(fds[0])) {
 		fprintf(stderr, "close datapath\n");
 		exit(1);
 	}
+
+	return ret;
+}
+
+static int set_cpuaffinity(int cpuid)
+{
+	cpu_set_t mask;
+
+	CPU_ZERO(&mask);
+	CPU_SET(cpuid, &mask);
+	if (sched_setaffinity(0, sizeof(mask), &mask)) {
+		if (errno != EINVAL) {
+			fprintf(stderr, "setaffinity %d\n", cpuid);
+			exit(1);
+		}
+		return 1;
+	}
+
+	return 0;
 }
 
 int main(int argc, char **argv)
 {
-	const int expect_hash[2][2]	= { { 15, 5 }, { 5, 0 } };
-	const int expect_hash_rb[2][2]	= { { 15, 5 }, { 5, 10 } };
-	const int expect_rb[2][2]	= { { 20, 0 }, { 0, 15 } };
+	const int expect_hash[2][2]	= { { 15, 5 },  { 20, 5 } };
+	const int expect_hash_rb[2][2]	= { { 15, 5 },  { 20, 15 } };
+	const int expect_lb[2][2]	= { { 10, 10 }, { 18, 17 } };
+	const int expect_rb[2][2]	= { { 20, 0 },  { 20, 15 } };
+	const int expect_cpu0[2][2]	= { { 20, 0 },  { 20, 0 } };
+	const int expect_cpu1[2][2]	= { { 0, 20 },  { 0, 20 } };
+	int port_off = 2, tries = 5, ret;
 
 	test_control_single();
 	test_control_group();
 
-	test_datapath(PACKET_FANOUT_HASH, expect_hash[0], expect_hash[1]);
-	test_datapath(PACKET_FANOUT_HASH | PACKET_FANOUT_FLAG_ROLLOVER,
-		      expect_hash_rb[0], expect_hash_rb[1]);
-	test_datapath(PACKET_FANOUT_ROLLOVER, expect_rb[0], expect_rb[1]);
+	/* find a set of ports that do not collide onto the same socket */
+	ret = test_datapath(PACKET_FANOUT_HASH, port_off,
+			    expect_hash[0], expect_hash[1]);
+	while (ret && tries--) {
+		fprintf(stderr, "info: trying alternate ports (%d)\n", tries);
+		ret = test_datapath(PACKET_FANOUT_HASH, ++port_off,
+				    expect_hash[0], expect_hash[1]);
+	}
+
+	ret |= test_datapath(PACKET_FANOUT_HASH | PACKET_FANOUT_FLAG_ROLLOVER,
+			     port_off, expect_hash_rb[0], expect_hash_rb[1]);
+	ret |= test_datapath(PACKET_FANOUT_LB,
+			     port_off, expect_lb[0], expect_lb[1]);
+	ret |= test_datapath(PACKET_FANOUT_ROLLOVER,
+			     port_off, expect_rb[0], expect_rb[1]);
+
+	set_cpuaffinity(0);
+	ret |= test_datapath(PACKET_FANOUT_CPU, port_off,
+			     expect_cpu0[0], expect_cpu0[1]);
+	if (!set_cpuaffinity(1))
+		/* TODO: test that choice alternates with previous */
+		ret |= test_datapath(PACKET_FANOUT_CPU, port_off,
+				     expect_cpu1[0], expect_cpu1[1]);
+
+	if (ret)
+		return 1;
 
 	printf("OK. All tests passed\n");
 	return 0;
-- 
1.8.1.3
