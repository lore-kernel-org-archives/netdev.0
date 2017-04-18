From: Mike Maloney <maloneykernel@gmail.com>
Subject: [PATCH net] selftests/net: Fixes psock_fanout CBPF test case
Date: Tue, 18 Apr 2017 11:14:16 -0400
Message-ID: <20170418151416.17858-1-maloneykernel@gmail.com>
Cc: davem@davemloft.net,
        Sowmini Varadhan <sowmini.varadhan@oracle.com>,
        Mike Maloney <maloney@google.com>,
        'Mike Maloney <maloneykernel@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f195.google.com ([209.85.213.195]:33317 "EHLO
        mail-yb0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755799AbdDRPPF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Apr 2017 11:15:05 -0400
Received: by mail-yb0-f195.google.com with SMTP id 206so6808053ybe.0
        for <netdev@vger.kernel.org>; Tue, 18 Apr 2017 08:15:04 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Maloney <maloney@google.com>

'psock_fanout' has been failing since commit 4d7b9dc1f36a9 ("tools:
psock_lib: harden socket filter used by psock tests").  That commit
changed the CBPF filter to examine the full ethernet frame, and was
tested on 'psock_tpacket' which uses SOCK_RAW.  But 'psock_fanout' was
also using this same CBPF in two places, for filtering and fanout, on a
SOCK_DGRAM socket.

Change 'psock_fanout' to use SOCK_RAW so that the CBPF program used with
SO_ATTACH_FILTER can examine the entire frame.  Create a new CBPF
program for use with PACKET_FANOUT_DATA which ignores the header, as it
cannot see the ethernet header.

Tested: Ran tools/testing/selftests/net/psock_{fanout,tpacket} 10 times,
and they all passed.

Fixes: 4d7b9dc1f36a9 ("tools: psock_lib: harden socket filter used by psock tests")
Signed-off-by: 'Mike Maloney <maloneykernel@gmail.com>'

---
 tools/testing/selftests/net/psock_fanout.c | 22 ++++++++++++++++++++--
 tools/testing/selftests/net/psock_lib.h    | 13 +++----------
 2 files changed, 23 insertions(+), 12 deletions(-)

diff --git a/tools/testing/selftests/net/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
index 412459369686..e62bb354820c 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -75,7 +75,7 @@ static int sock_fanout_open(uint16_t typeflags, int num_packets)
 {
 	int fd, val;
 
-	fd = socket(PF_PACKET, SOCK_DGRAM, htons(ETH_P_IP));
+	fd = socket(PF_PACKET, SOCK_RAW, htons(ETH_P_IP));
 	if (fd < 0) {
 		perror("socket packet");
 		exit(1);
@@ -95,6 +95,24 @@ static int sock_fanout_open(uint16_t typeflags, int num_packets)
 	return fd;
 }
 
+static void sock_fanout_set_cbpf(int fd)
+{
+	struct sock_filter bpf_filter[] = {
+		BPF_STMT(BPF_LD+BPF_B+BPF_ABS, 80),	      /* ldb [80] */
+		BPF_STMT(BPF_RET+BPF_A, 0),		      /* ret A */
+	};
+	struct sock_fprog bpf_prog;
+
+	bpf_prog.filter = bpf_filter;
+	bpf_prog.len = sizeof(bpf_filter) / sizeof(struct sock_filter);
+
+	if (setsockopt(fd, SOL_PACKET, PACKET_FANOUT_DATA, &bpf_prog,
+		       sizeof(bpf_prog))) {
+		perror("fanout data cbpf");
+		exit(1);
+	}
+}
+
 static void sock_fanout_set_ebpf(int fd)
 {
 	const int len_off = __builtin_offsetof(struct __sk_buff, len);
@@ -270,7 +288,7 @@ static int test_datapath(uint16_t typeflags, int port_off,
 		exit(1);
 	}
 	if (type == PACKET_FANOUT_CBPF)
-		sock_setfilter(fds[0], SOL_PACKET, PACKET_FANOUT_DATA);
+		sock_fanout_set_cbpf(fds[0]);
 	else if (type == PACKET_FANOUT_EBPF)
 		sock_fanout_set_ebpf(fds[0]);
 
diff --git a/tools/testing/selftests/net/psock_lib.h b/tools/testing/selftests/net/psock_lib.h
index a77da88bf946..7d990d6c861b 100644
--- a/tools/testing/selftests/net/psock_lib.h
+++ b/tools/testing/selftests/net/psock_lib.h
@@ -38,7 +38,7 @@
 # define __maybe_unused		__attribute__ ((__unused__))
 #endif
 
-static __maybe_unused void sock_setfilter(int fd, int lvl, int optnum)
+static __maybe_unused void pair_udp_setfilter(int fd)
 {
 	/* the filter below checks for all of the following conditions that
 	 * are based on the contents of create_payload()
@@ -76,23 +76,16 @@ static __maybe_unused void sock_setfilter(int fd, int lvl, int optnum)
 	};
 	struct sock_fprog bpf_prog;
 
-	if (lvl == SOL_PACKET && optnum == PACKET_FANOUT_DATA)
-		bpf_filter[5].code = 0x16;   /* RET A			      */
-
 	bpf_prog.filter = bpf_filter;
 	bpf_prog.len = sizeof(bpf_filter) / sizeof(struct sock_filter);
-	if (setsockopt(fd, lvl, optnum, &bpf_prog,
+
+	if (setsockopt(fd, SOL_SOCKET, SO_ATTACH_FILTER, &bpf_prog,
 		       sizeof(bpf_prog))) {
 		perror("setsockopt SO_ATTACH_FILTER");
 		exit(1);
 	}
 }
 
-static __maybe_unused void pair_udp_setfilter(int fd)
-{
-	sock_setfilter(fd, SOL_SOCKET, SO_ATTACH_FILTER);
-}
-
 static __maybe_unused void pair_udp_open(int fds[], uint16_t port)
 {
 	struct sockaddr_in saddr, daddr;
-- 
2.12.2.762.g0e3151a226-goog
