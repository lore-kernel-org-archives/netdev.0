From: Willem de Bruijn <willemb@google.com>
Subject: [PATCH net-next 4/4] selftests/net: test eBPF fanout mode
Date: Fri, 14 Aug 2015 11:50:27 -0400
Message-ID: <1439567427-19504-5-git-send-email-willemb@google.com>
References: <1439567427-19504-1-git-send-email-willemb@google.com>
Cc: davem@davemloft.net, edumazet@google.com, dborkman@redhat.com,
	ast@plumgrid.com, Willem de Bruijn <willemb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f181.google.com ([209.85.220.181]:35880 "EHLO
	mail-qk0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755515AbbHNPuh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Aug 2015 11:50:37 -0400
Received: by qkdv3 with SMTP id v3so26768526qkd.3
        for <netdev@vger.kernel.org>; Fri, 14 Aug 2015 08:50:37 -0700 (PDT)
In-Reply-To: <1439567427-19504-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>

Test PACKET_FANOUT_EBPF by inserting a program into the the kernel
with bpf(), then attaching it to the fanout group. Observe the same
payload-based distribution as in the PACKET_FANOUT_BPF test.

Signed-off-by: Willem de Bruijn <willemb@google.com>
---
 tools/testing/selftests/net/psock_fanout.c | 53 ++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

diff --git a/tools/testing/selftests/net/psock_fanout.c b/tools/testing/selftests/net/psock_fanout.c
index 7270132..ed609bf 100644
--- a/tools/testing/selftests/net/psock_fanout.c
+++ b/tools/testing/selftests/net/psock_fanout.c
@@ -20,6 +20,7 @@
  *   - PACKET_FANOUT_CPU
  *   - PACKET_FANOUT_ROLLOVER
  *   - PACKET_FANOUT_BPF
+ *   - PACKET_FANOUT_EBPF
  *
  * Todo:
  * - functionality: PACKET_FANOUT_FLAG_DEFRAG
@@ -45,7 +46,9 @@
 #include <arpa/inet.h>
 #include <errno.h>
 #include <fcntl.h>
+#include <linux/unistd.h>	/* for __NR_bpf */
 #include <linux/filter.h>
+#include <linux/bpf.h>
 #include <linux/if_packet.h>
 #include <net/ethernet.h>
 #include <netinet/ip.h>
@@ -92,6 +95,51 @@ static int sock_fanout_open(uint16_t typeflags, int num_packets)
 	return fd;
 }
 
+static void sock_fanout_set_ebpf(int fd)
+{
+	const int len_off = __builtin_offsetof(struct __sk_buff, len);
+	struct bpf_insn prog[] = {
+		{ BPF_ALU64 | BPF_MOV | BPF_X,   6, 1, 0, 0 },
+		{ BPF_LDX   | BPF_W   | BPF_MEM, 0, 6, len_off, 0 },
+		{ BPF_JMP   | BPF_JGE | BPF_K,   0, 0, 1, DATA_LEN },
+		{ BPF_JMP   | BPF_JA  | BPF_K,   0, 0, 4, 0 },
+		{ BPF_LD    | BPF_B   | BPF_ABS, 0, 0, 0, 0x50 },
+		{ BPF_JMP   | BPF_JEQ | BPF_K,   0, 0, 2, DATA_CHAR },
+		{ BPF_JMP   | BPF_JEQ | BPF_K,   0, 0, 1, DATA_CHAR_1 },
+		{ BPF_ALU   | BPF_MOV | BPF_K,   0, 0, 0, 0 },
+		{ BPF_JMP   | BPF_EXIT,          0, 0, 0, 0 }
+	};
+	char log_buf[512];
+	union bpf_attr attr;
+	int pfd;
+
+	memset(&attr, 0, sizeof(attr));
+	attr.prog_type = BPF_PROG_TYPE_SOCKET_FILTER;
+	attr.insns = (unsigned long) prog;
+	attr.insn_cnt = sizeof(prog) / sizeof(prog[0]);
+	attr.license = (unsigned long) "GPL";
+	attr.log_buf = (unsigned long) log_buf,
+	attr.log_size = sizeof(log_buf),
+	attr.log_level = 1,
+
+	pfd = syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
+	if (pfd < 0) {
+		perror("bpf");
+		fprintf(stderr, "bpf verifier:\n%s\n", log_buf);
+		exit(1);
+	}
+
+	if (setsockopt(fd, SOL_PACKET, PACKET_FANOUT_DATA, &pfd, sizeof(pfd))) {
+		perror("fanout data ebpf");
+		exit(1);
+	}
+
+	if (close(pfd)) {
+		perror("close ebpf");
+		exit(1);
+	}
+}
+
 static char *sock_fanout_open_ring(int fd)
 {
 	struct tpacket_req req = {
@@ -223,6 +271,8 @@ static int test_datapath(uint16_t typeflags, int port_off,
 	}
 	if (type == PACKET_FANOUT_BPF)
 		sock_setfilter(fds[0], SOL_PACKET, PACKET_FANOUT_DATA);
+	else if (type == PACKET_FANOUT_EBPF)
+		sock_fanout_set_ebpf(fds[0]);
 
 	rings[0] = sock_fanout_open_ring(fds[0]);
 	rings[1] = sock_fanout_open_ring(fds[1]);
@@ -301,8 +351,11 @@ int main(int argc, char **argv)
 			     port_off, expect_lb[0], expect_lb[1]);
 	ret |= test_datapath(PACKET_FANOUT_ROLLOVER,
 			     port_off, expect_rb[0], expect_rb[1]);
+
 	ret |= test_datapath(PACKET_FANOUT_BPF,
 			     port_off, expect_bpf[0], expect_bpf[1]);
+	ret |= test_datapath(PACKET_FANOUT_EBPF,
+			     port_off, expect_bpf[0], expect_bpf[1]);
 
 	set_cpuaffinity(0);
 	ret |= test_datapath(PACKET_FANOUT_CPU, port_off,
-- 
2.5.0.276.gf5e568e
