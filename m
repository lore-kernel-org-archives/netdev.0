From: Mike Maloney <maloneykernel@gmail.com>
Subject: [PATCH netnext 3/3] selftests/net: add tests for PACKET_FANOUT_FLAG_UNIQUEID
Date: Thu, 20 Apr 2017 15:25:46 -0400
Message-ID: <20170420192546.5567-4-maloneykernel@gmail.com>
References: <20170420192546.5567-1-maloneykernel@gmail.com>
Cc: Mike Maloney <maloney@google.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f196.google.com ([209.85.213.196]:33911 "EHLO
        mail-yb0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S947039AbdDTT0K (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 15:26:10 -0400
Received: by mail-yb0-f196.google.com with SMTP id l192so4264997ybl.1
        for <netdev@vger.kernel.org>; Thu, 20 Apr 2017 12:26:10 -0700 (PDT)
In-Reply-To: <20170420192546.5567-1-maloneykernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

Create two groups with PACKET_FANOUT_FLAG_UNIQUEID, add a socket to one.
Ensure that the groups can only be joined if all options are consistent
with the original except for this flag.

Tested:
ran tools/testing/selftests/net/psock_fanout 10 times, all pass.

Signed-off-by: Mike Maloney <maloney@google.com>
Acked-by: Willem de Bruijn <willemb@google.com>

---
 tools/testing/selftests/net/psock_fanout.c | 95 ++++++++++++++++++++++++++----
 1 file changed, 84 insertions(+), 11 deletions(-)

diff --git a/tools/testing/selftests/net/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
index b475d87d3aa3..1c46a21a9b5e 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -71,7 +71,7 @@
 
 /* Open a socket in a given fanout mode.
  * @return -1 if mode is bad, a valid socket otherwise */
-static int sock_fanout_open(uint16_t typeflags)
+static int sock_fanout_open(uint16_t typeflags, uint16_t group_id)
 {
 	int fd, val;
 
@@ -81,8 +81,7 @@ static int sock_fanout_open(uint16_t typeflags)
 		exit(1);
 	}
 
-	/* fanout group ID is always 0: tests whether old groups are deleted */
-	val = ((int) typeflags) << 16;
+	val = (((int) typeflags) << 16) | group_id;
 	if (setsockopt(fd, SOL_PACKET, PACKET_FANOUT, &val, sizeof(val))) {
 		if (close(fd)) {
 			perror("close packet");
@@ -95,6 +94,20 @@ static int sock_fanout_open(uint16_t typeflags)
 	return fd;
 }
 
+static void sock_fanout_getopts(int fd, uint16_t *typeflags, uint16_t *group_id)
+{
+	int sockopt;
+	socklen_t sockopt_len = sizeof(sockopt);
+
+	if (getsockopt(fd, SOL_PACKET, PACKET_FANOUT,
+		       &sockopt, &sockopt_len)) {
+		perror("failed to getsockopt");
+		exit(1);
+	}
+	*typeflags = sockopt >> 16;
+	*group_id = sockopt & 0xfffff;
+}
+
 static void sock_fanout_set_ebpf(int fd)
 {
 	const int len_off = __builtin_offsetof(struct __sk_buff, len);
@@ -210,7 +223,7 @@ static void test_control_single(void)
 	fprintf(stderr, "test: control single socket\n");
 
 	if (sock_fanout_open(PACKET_FANOUT_ROLLOVER |
-			       PACKET_FANOUT_FLAG_ROLLOVER) != -1) {
+			       PACKET_FANOUT_FLAG_ROLLOVER, 0) != -1) {
 		fprintf(stderr, "ERROR: opened socket with dual rollover\n");
 		exit(1);
 	}
@@ -223,26 +236,26 @@ static void test_control_group(void)
 
 	fprintf(stderr, "test: control multiple sockets\n");
 
-	fds[0] = sock_fanout_open(PACKET_FANOUT_HASH);
+	fds[0] = sock_fanout_open(PACKET_FANOUT_HASH, 0);
 	if (fds[0] == -1) {
 		fprintf(stderr, "ERROR: failed to open HASH socket\n");
 		exit(1);
 	}
 	if (sock_fanout_open(PACKET_FANOUT_HASH |
-			       PACKET_FANOUT_FLAG_DEFRAG) != -1) {
+			       PACKET_FANOUT_FLAG_DEFRAG, 0) != -1) {
 		fprintf(stderr, "ERROR: joined group with wrong flag defrag\n");
 		exit(1);
 	}
 	if (sock_fanout_open(PACKET_FANOUT_HASH |
-			       PACKET_FANOUT_FLAG_ROLLOVER) != -1) {
+			       PACKET_FANOUT_FLAG_ROLLOVER, 0) != -1) {
 		fprintf(stderr, "ERROR: joined group with wrong flag ro\n");
 		exit(1);
 	}
-	if (sock_fanout_open(PACKET_FANOUT_CPU) != -1) {
+	if (sock_fanout_open(PACKET_FANOUT_CPU, 0) != -1) {
 		fprintf(stderr, "ERROR: joined group with wrong mode\n");
 		exit(1);
 	}
-	fds[1] = sock_fanout_open(PACKET_FANOUT_HASH);
+	fds[1] = sock_fanout_open(PACKET_FANOUT_HASH, 0);
 	if (fds[1] == -1) {
 		fprintf(stderr, "ERROR: failed to join group\n");
 		exit(1);
@@ -253,6 +266,61 @@ static void test_control_group(void)
 	}
 }
 
+/* Test creating a unique fanout group ids */
+static void test_unique_fanout_group_ids(void)
+{
+	int fds[3];
+	uint16_t typeflags, first_group_id, second_group_id;
+
+	fprintf(stderr, "test: unique ids\n");
+
+	fds[0] = sock_fanout_open(PACKET_FANOUT_HASH |
+				  PACKET_FANOUT_FLAG_UNIQUEID, 0);
+	if (fds[0] == -1) {
+		fprintf(stderr, "ERROR: failed to create a unique id group.\n");
+		exit(1);
+	}
+
+	sock_fanout_getopts(fds[0], &typeflags, &first_group_id);
+	if (typeflags != PACKET_FANOUT_HASH) {
+		fprintf(stderr, "ERROR: unexpected typeflags %x\n", typeflags);
+		exit(1);
+	}
+
+	if (sock_fanout_open(PACKET_FANOUT_CPU, first_group_id)) {
+		fprintf(stderr, "ERROR: joined group with wrong type.\n");
+		exit(1);
+	}
+
+	fds[1] = sock_fanout_open(PACKET_FANOUT_HASH, first_group_id);
+	if (fds[1] == -1) {
+		fprintf(stderr,
+			"ERROR: failed to join previously created group.\n");
+		exit(1);
+	}
+
+	fds[2] = sock_fanout_open(PACKET_FANOUT_HASH |
+				  PACKET_FANOUT_FLAG_UNIQUEID, 0);
+	if (fds[2] == -1) {
+		fprintf(stderr,
+			"ERROR: failed to create a second unique id group.\n");
+		exit(1);
+	}
+
+	sock_fanout_getopts(fds[2], &typeflags, &second_group_id);
+	if (sock_fanout_open(PACKET_FANOUT_HASH | PACKET_FANOUT_FLAG_UNIQUEID,
+			     second_group_id) != -1) {
+		fprintf(stderr,
+			"ERROR: specified a group id when requesting unique id\n");
+		exit(1);
+	}
+
+	if (close(fds[0]) || close(fds[1]) || close(fds[2])) {
+		fprintf(stderr, "ERROR: closing sockets\n");
+		exit(1);
+	}
+}
+
 static int test_datapath(uint16_t typeflags, int port_off,
 			 const int expect1[], const int expect2[])
 {
@@ -263,8 +331,8 @@ static int test_datapath(uint16_t typeflags, int port_off,
 
 	fprintf(stderr, "test: datapath 0x%hx\n", typeflags);
 
-	fds[0] = sock_fanout_open(typeflags);
-	fds[1] = sock_fanout_open(typeflags);
+	fds[0] = sock_fanout_open(typeflags, 0);
+	fds[1] = sock_fanout_open(typeflags, 0);
 	if (fds[0] == -1 || fds[1] == -1) {
 		fprintf(stderr, "ERROR: failed open\n");
 		exit(1);
@@ -331,10 +399,12 @@ int main(int argc, char **argv)
 	const int expect_cpu0[2][2]	= { { 20, 0 },  { 20, 0 } };
 	const int expect_cpu1[2][2]	= { { 0, 20 },  { 0, 20 } };
 	const int expect_bpf[2][2]	= { { 15, 5 },  { 15, 20 } };
+	const int expect_uniqueid[2][2] = { { 20, 20},  { 20, 20 } };
 	int port_off = 2, tries = 5, ret;
 
 	test_control_single();
 	test_control_group();
+	test_unique_fanout_group_ids();
 
 	/* find a set of ports that do not collide onto the same socket */
 	ret = test_datapath(PACKET_FANOUT_HASH, port_off,
@@ -365,6 +435,9 @@ int main(int argc, char **argv)
 		ret |= test_datapath(PACKET_FANOUT_CPU, port_off,
 				     expect_cpu1[0], expect_cpu1[1]);
 
+	ret |= test_datapath(PACKET_FANOUT_FLAG_UNIQUEID, port_off,
+			     expect_uniqueid[0], expect_uniqueid[1]);
+
 	if (ret)
 		return 1;
 
-- 
2.12.2.816.g2cccc81164-goog
