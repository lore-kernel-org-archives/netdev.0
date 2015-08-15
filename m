From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next v2 3/4] selftests/net: test classic bpf fanout mode
Date: Fri, 14 Aug 2015 22:31:36 -0400
Message-ID: <1439605897-28311-4-git-send-email-willemb@google.com>
References: <1439605897-28311-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, edumazet@google.com, daniel@iogearbox.net,
	ast@plumgrid.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f171.google.com ([209.85.220.171]:34565 "EHLO
	mail-qk0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752113AbbHOCbn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 22:31:43 -0400
Received: by qkcs67 with SMTP id s67so31537019qkc.1
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 19:31:42 -0700 (PDT)
In-Reply-To: <1439605897-28311-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Test PACKET_FANOUT_CBPF by inserting a cBPF program that selects a
socket by payload. Requires modifying the test program to send
packets with multiple payloads.

Also fix a bug in testing the return value of mmap()

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 tools/testing/selftests/net/psock_fanout.c | 16 ++++++++++++----
 tools/testing/selftests/net/psock_lib.h    | 29 +++++++++++++++++++++--------
 2 files changed, 33 insertions(+), 12 deletions(-)

diff --git a/tools/testing/selftests/net/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
index 08c2a36..baf46a2 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -19,6 +19,7 @@
  *   - PACKET_FANOUT_LB
  *   - PACKET_FANOUT_CPU
  *   - PACKET_FANOUT_ROLLOVER
+ *   - PACKET_FANOUT_CBPF
  *
  * Todo:
  * - functionality: PACKET_FANOUT_FLAG_DEFRAG
@@ -115,8 +116,8 @@ static char *sock_fanout_open_ring(int fd)
 
 	ring = mmap(0, req.tp_block_size * req.tp_block_nr,
 		    PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
-	if (!ring) {
-		fprintf(stderr, "packetsock ring mmap\n");
+	if (ring == MAP_FAILED) {
+		perror("packetsock ring mmap");
 		exit(1);
 	}
 
@@ -209,6 +210,7 @@ static int test_datapath(uint16_t typeflags, int port_off,
 {
 	const int expect0[] = { 0, 0 };
 	char *rings[2];
+	uint8_t type = typeflags & 0xFF;
 	int fds[2], fds_udp[2][2], ret;
 
 	fprintf(stderr, "test: datapath 0x%hx\n", typeflags);
@@ -219,6 +221,9 @@ static int test_datapath(uint16_t typeflags, int port_off,
 		fprintf(stderr, "ERROR: failed open\n");
 		exit(1);
 	}
+	if (type == PACKET_FANOUT_CBPF)
+		sock_setfilter(fds[0], SOL_PACKET, PACKET_FANOUT_DATA);
+
 	rings[0] = sock_fanout_open_ring(fds[0]);
 	rings[1] = sock_fanout_open_ring(fds[1]);
 	pair_udp_open(fds_udp[0], PORT_BASE);
@@ -227,11 +232,11 @@ static int test_datapath(uint16_t typeflags, int port_off,
 
 	/* Send data, but not enough to overflow a queue */
 	pair_udp_send(fds_udp[0], 15);
-	pair_udp_send(fds_udp[1], 5);
+	pair_udp_send_char(fds_udp[1], 5, DATA_CHAR_1);
 	ret = sock_fanout_read(fds, rings, expect1);
 
 	/* Send more data, overflow the queue */
-	pair_udp_send(fds_udp[0], 15);
+	pair_udp_send_char(fds_udp[0], 15, DATA_CHAR_1);
 	/* TODO: ensure consistent order between expect1 and expect2 */
 	ret |= sock_fanout_read(fds, rings, expect2);
 
@@ -275,6 +280,7 @@ int main(int argc, char **argv)
 	const int expect_rb[2][2]	= { { 15, 5 },  { 20, 15 } };
 	const int expect_cpu0[2][2]	= { { 20, 0 },  { 20, 0 } };
 	const int expect_cpu1[2][2]	= { { 0, 20 },  { 0, 20 } };
+	const int expect_bpf[2][2]	= { { 15, 5 },  { 15, 20 } };
 	int port_off = 2, tries = 5, ret;
 
 	test_control_single();
@@ -295,6 +301,8 @@ int main(int argc, char **argv)
 			     port_off, expect_lb[0], expect_lb[1]);
 	ret |= test_datapath(PACKET_FANOUT_ROLLOVER,
 			     port_off, expect_rb[0], expect_rb[1]);
+	ret |= test_datapath(PACKET_FANOUT_CBPF,
+			     port_off, expect_bpf[0], expect_bpf[1]);
 
 	set_cpuaffinity(0);
 	ret |= test_datapath(PACKET_FANOUT_CPU, port_off,
diff --git a/tools/testing/selftests/net/psock_lib.h b/tools/testing/selftests/net/psock_lib.h
index 37da54a..24bc7ec 100644
--- a/tools/testing/selftests/net/psock_lib.h
+++ b/tools/testing/selftests/net/psock_lib.h
@@ -30,6 +30,7 @@
 
 #define DATA_LEN			100
 #define DATA_CHAR			'a'
+#define DATA_CHAR_1			'b'
 
 #define PORT_BASE			8000
 
@@ -37,29 +38,36 @@
 # define __maybe_unused		__attribute__ ((__unused__))
 #endif
 
-static __maybe_unused void pair_udp_setfilter(int fd)
+static __maybe_unused void sock_setfilter(int fd, int lvl, int optnum)
 {
 	struct sock_filter bpf_filter[] = {
 		{ 0x80, 0, 0, 0x00000000 },  /* LD  pktlen		      */
-		{ 0x35, 0, 5, DATA_LEN   },  /* JGE DATA_LEN  [f goto nomatch]*/
+		{ 0x35, 0, 4, DATA_LEN   },  /* JGE DATA_LEN  [f goto nomatch]*/
 		{ 0x30, 0, 0, 0x00000050 },  /* LD  ip[80]		      */
-		{ 0x15, 0, 3, DATA_CHAR  },  /* JEQ DATA_CHAR [f goto nomatch]*/
-		{ 0x30, 0, 0, 0x00000051 },  /* LD  ip[81]		      */
-		{ 0x15, 0, 1, DATA_CHAR  },  /* JEQ DATA_CHAR [f goto nomatch]*/
+		{ 0x15, 1, 0, DATA_CHAR  },  /* JEQ DATA_CHAR   [t goto match]*/
+		{ 0x15, 0, 1, DATA_CHAR_1},  /* JEQ DATA_CHAR_1 [t goto match]*/
 		{ 0x06, 0, 0, 0x00000060 },  /* RET match	              */
 		{ 0x06, 0, 0, 0x00000000 },  /* RET no match		      */
 	};
 	struct sock_fprog bpf_prog;
 
+	if (lvl == SOL_PACKET && optnum == PACKET_FANOUT_DATA)
+		bpf_filter[5].code = 0x16;   /* RET A			      */
+
 	bpf_prog.filter = bpf_filter;
 	bpf_prog.len = sizeof(bpf_filter) / sizeof(struct sock_filter);
-	if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &bpf_prog,
+	if (setsockopt(fd, lvl, optnum, &bpf_prog,
 		       sizeof(bpf_prog))) {
 		perror("setsockopt SO_ATTACH_FILTER");
 		exit(1);
 	}
 }
 
+static __maybe_unused void pair_udp_setfilter(int fd)
+{
+	sock_setfilter(fd, SOL_SOCKET, SO_ATTACH_FILTER);
+}
+
 static __maybe_unused void pair_udp_open(int fds[], uint16_t port)
 {
 	struct sockaddr_in saddr, daddr;
@@ -96,11 +104,11 @@ static __maybe_unused void pair_udp_open(int fds[], uint16_t port)
 	}
 }
 
-static __maybe_unused void pair_udp_send(int fds[], int num)
+static __maybe_unused void pair_udp_send_char(int fds[], int num, char payload)
 {
 	char buf[DATA_LEN], rbuf[DATA_LEN];
 
-	memset(buf, DATA_CHAR, sizeof(buf));
+	memset(buf, payload, sizeof(buf));
 	while (num--) {
 		/* Should really handle EINTR and EAGAIN */
 		if (write(fds[0], buf, sizeof(buf)) != sizeof(buf)) {
@@ -118,6 +126,11 @@ static __maybe_unused void pair_udp_send(int fds[], int num)
 	}
 }
 
+static __maybe_unused void pair_udp_send(int fds[], int num)
+{
+	return pair_udp_send_char(fds, num, DATA_CHAR);
+}
+
 static __maybe_unused void pair_udp_close(int fds[])
 {
 	close(fds[0]);
-- 
2.5.0.276.gf5e568e
