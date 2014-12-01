From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v2 net-next 3/6] samples: bpf: example of stateful socket filtering
Date: Mon,  1 Dec 2014 15:06:36 -0800
Message-ID: <1417475199-15950-4-git-send-email-ast@plumgrid.com>
References: <1417475199-15950-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417475199-15950-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this socket filter example does:
- creates arraymap in kernel with key 4 bytes and value 8 bytes

- loads eBPF program which assumes that packet is IPv4 and loads one byte of
  IP->proto from the packet and uses it as a key in a map

  r0 = skb->data[ETH_HLEN + offsetof(struct iphdr, protocol)];
  *(u32*)(fp - 4) = r0;
  value = bpf_map_lookup_elem(map_fd, fp - 4);
  if (value)
       (*(u64*)value) += 1;

- attaches this program to raw socket

- every second user space reads map[IPPROTO_TCP], map[IPPROTO_UDP], map[IPPROTO_ICMP]
  to see how many packets of given protocol were seen on loopback interface

Usage:
$sudo samples/bpf/sock_example
TCP 0 UDP 0 ICMP 0 packets
TCP 187600 UDP 0 ICMP 4 packets
TCP 376504 UDP 0 ICMP 8 packets
TCP 563116 UDP 0 ICMP 12 packets
TCP 753144 UDP 0 ICMP 16 packets

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
V1->V2:

fixed comments and replaced constants in:
BPF_LD_ABS(BPF_B, 14 + 9 /* R0 = ip->proto */),
with:
BPF_LD_ABS(BPF_B, ETH_HLEN + offsetof(struct iphdr, protocol) /* R0 = ip->proto */),

 samples/bpf/Makefile       |    2 +
 samples/bpf/libbpf.c       |   28 ++++++++++++
 samples/bpf/libbpf.h       |   13 ++++++
 samples/bpf/sock_example.c |  101 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 144 insertions(+)
 create mode 100644 samples/bpf/sock_example.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index 0718d9ce4619..f46d3492d032 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -3,9 +3,11 @@ obj- := dummy.o
 
 # List of programs to build
 hostprogs-y := test_verifier test_maps
+hostprogs-y += sock_example
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
+sock_example-objs := sock_example.o libbpf.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 17bb520eb57f..46d50b7ddf79 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -7,6 +7,10 @@
 #include <linux/netlink.h>
 #include <linux/bpf.h>
 #include <errno.h>
+#include <net/ethernet.h>
+#include <net/if.h>
+#include <linux/if_packet.h>
+#include <arpa/inet.h>
 #include "libbpf.h"
 
 static __u64 ptr_to_u64(void *ptr)
@@ -93,3 +97,27 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 
 	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
 }
+
+int open_raw_sock(const char *name)
+{
+	struct sockaddr_ll sll;
+	int sock;
+
+	sock = socket(PF_PACKET, SOCK_RAW | SOCK_NONBLOCK | SOCK_CLOEXEC, htons(ETH_P_ALL));
+	if (sock < 0) {
+		printf("cannot create raw socket\n");
+		return -1;
+	}
+
+	memset(&sll, 0, sizeof(sll));
+	sll.sll_family = AF_PACKET;
+	sll.sll_ifindex = if_nametoindex(name);
+	sll.sll_protocol = htons(ETH_P_ALL);
+	if (bind(sock, (struct sockaddr *)&sll, sizeof(sll)) < 0) {
+		printf("bind to %s: %s\n", name, strerror(errno));
+		close(sock);
+		return -1;
+	}
+
+	return sock;
+}
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index f8678e5f48bf..cc62ad4d95de 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -99,6 +99,16 @@ extern char bpf_log_buf[LOG_BUF_SIZE];
 	BPF_LD_IMM64_RAW(DST, BPF_PSEUDO_MAP_FD, MAP_FD)
 
 
+/* Direct packet access, R0 = *(uint *) (skb->data + imm32) */
+
+#define BPF_LD_ABS(SIZE, IMM)					\
+	((struct bpf_insn) {					\
+		.code  = BPF_LD | BPF_SIZE(SIZE) | BPF_ABS,	\
+		.dst_reg = 0,					\
+		.src_reg = 0,					\
+		.off   = 0,					\
+		.imm   = IMM })
+
 /* Memory load, dst_reg = *(uint *) (src_reg + off16) */
 
 #define BPF_LDX_MEM(SIZE, DST, SRC, OFF)			\
@@ -169,4 +179,7 @@ extern char bpf_log_buf[LOG_BUF_SIZE];
 		.off   = 0,					\
 		.imm   = 0 })
 
+/* create RAW socket and bind to interface 'name' */
+int open_raw_sock(const char *name);
+
 #endif
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
new file mode 100644
index 000000000000..c8ad0404416f
--- /dev/null
+++ b/samples/bpf/sock_example.c
@@ -0,0 +1,101 @@
+/* eBPF example program:
+ * - creates arraymap in kernel with key 4 bytes and value 8 bytes
+ *
+ * - loads eBPF program:
+ *   r0 = skb->data[ETH_HLEN + offsetof(struct iphdr, protocol)];
+ *   *(u32*)(fp - 4) = r0;
+ *   // assuming packet is IPv4, lookup ip->proto in a map
+ *   value = bpf_map_lookup_elem(map_fd, fp - 4);
+ *   if (value)
+ *        (*(u64*)value) += 1;
+ *
+ * - attaches this program to eth0 raw socket
+ *
+ * - every second user space reads map[tcp], map[udp], map[icmp] to see
+ *   how many packets of given protocol were seen on eth0
+ */
+#include <stdio.h>
+#include <unistd.h>
+#include <assert.h>
+#include <linux/bpf.h>
+#include <string.h>
+#include <stdlib.h>
+#include <errno.h>
+#include <sys/socket.h>
+#include <arpa/inet.h>
+#include <linux/if_ether.h>
+#include <linux/ip.h>
+#include <stddef.h>
+#include "libbpf.h"
+
+static int test_sock(void)
+{
+	int sock = -1, map_fd, prog_fd, i, key;
+	long long value = 0, tcp_cnt, udp_cnt, icmp_cnt;
+
+	map_fd = bpf_create_map(BPF_MAP_TYPE_ARRAY, sizeof(key), sizeof(value),
+				256);
+	if (map_fd < 0) {
+		printf("failed to create map '%s'\n", strerror(errno));
+		goto cleanup;
+	}
+
+	struct bpf_insn prog[] = {
+		BPF_MOV64_REG(BPF_REG_6, BPF_REG_1),
+		BPF_LD_ABS(BPF_B, ETH_HLEN + offsetof(struct iphdr, protocol) /* R0 = ip->proto */),
+		BPF_STX_MEM(BPF_W, BPF_REG_10, BPF_REG_0, -4), /* *(u32 *)(fp - 4) = r0 */
+		BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
+		BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -4), /* r2 = fp - 4 */
+		BPF_LD_MAP_FD(BPF_REG_1, map_fd),
+		BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
+		BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
+		BPF_MOV64_IMM(BPF_REG_1, 1), /* r1 = 1 */
+		BPF_RAW_INSN(BPF_STX | BPF_XADD | BPF_DW, BPF_REG_0, BPF_REG_1, 0, 0), /* xadd r0 += r1 */
+		BPF_MOV64_IMM(BPF_REG_0, 0), /* r0 = 0 */
+		BPF_EXIT_INSN(),
+	};
+
+	prog_fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
+				"GPL");
+	if (prog_fd < 0) {
+		printf("failed to load prog '%s'\n", strerror(errno));
+		goto cleanup;
+	}
+
+	sock = open_raw_sock("lo");
+
+	if (setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, &prog_fd,
+		       sizeof(prog_fd)) < 0) {
+		printf("setsockopt %s\n", strerror(errno));
+		goto cleanup;
+	}
+
+	for (i = 0; i < 10; i++) {
+		key = IPPROTO_TCP;
+		assert(bpf_lookup_elem(map_fd, &key, &tcp_cnt) == 0);
+
+		key = IPPROTO_UDP;
+		assert(bpf_lookup_elem(map_fd, &key, &udp_cnt) == 0);
+
+		key = IPPROTO_ICMP;
+		assert(bpf_lookup_elem(map_fd, &key, &icmp_cnt) == 0);
+
+		printf("TCP %lld UDP %lld ICMP %lld packets\n",
+		       tcp_cnt, udp_cnt, icmp_cnt);
+		sleep(1);
+	}
+
+cleanup:
+	/* maps, programs, raw sockets will auto cleanup on process exit */
+	return 0;
+}
+
+int main(void)
+{
+	FILE *f;
+
+	f = popen("ping -c5 localhost", "r");
+	(void)f;
+
+	return test_sock();
+}
-- 
1.7.9.5
