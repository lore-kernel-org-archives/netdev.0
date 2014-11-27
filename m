From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH net-next 5/6] samples: bpf: trivial eBPF program in C
Date: Wed, 26 Nov 2014 21:42:30 -0800
Message-ID: <1417066951-1999-6-git-send-email-ast@plumgrid.com>
References: <1417066951-1999-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo@kernel.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Eric Dumazet <edumazet@google.com>, linux-api@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:45534 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753958AbaK0Fmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Nov 2014 00:42:47 -0500
Received: by mail-pa0-f49.google.com with SMTP id eu11so4292345pac.22
        for <netdev@vger.kernel.org>; Wed, 26 Nov 2014 21:42:46 -0800 (PST)
In-Reply-To: <1417066951-1999-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

this example does the same task as previous socket example
in assembler, but this one does it in C.

eBPF program in kernel does:
    int index = load_byte(skb, 14 + 9); /* ip_proto */
    long *value;

    value = bpf_map_lookup_elem(&my_map, &index);
    if (value)
        __sync_fetch_and_add(value, 1);

Corresponding user space reads map[tcp], map[udp], map[icmp]
and prints protocol stats every second

Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 samples/bpf/Makefile       |   14 +++++++++++++
 samples/bpf/libbpf.h       |    2 +-
 samples/bpf/sockex1_kern.c |   23 +++++++++++++++++++++
 samples/bpf/sockex1_user.c |   49 ++++++++++++++++++++++++++++++++++++++++++++
 4 files changed, 87 insertions(+), 1 deletion(-)
 create mode 100644 samples/bpf/sockex1_kern.c
 create mode 100644 samples/bpf/sockex1_user.c

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index f46d3492d032..770d145186c3 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -4,12 +4,26 @@ obj- := dummy.o
 # List of programs to build
 hostprogs-y := test_verifier test_maps
 hostprogs-y += sock_example
+hostprogs-y += sockex1
 
 test_verifier-objs := test_verifier.o libbpf.o
 test_maps-objs := test_maps.o libbpf.o
 sock_example-objs := sock_example.o libbpf.o
+sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
+always += sockex1_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
+
+HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
+HOSTLOADLIBES_sockex1 += -lelf
+
+# point this to your LLVM backend with bpf support
+LLC=$(srctree)/tools/bpf/llvm/bld/Debug+Asserts/bin/llc
+
+%.o: %.c
+	clang $(NOSTDINC_FLAGS) $(LINUXINCLUDE) $(EXTRA_CFLAGS) \
+		-D__KERNEL__ -Wno-unused-value -Wno-pointer-sign \
+		-O2 -emit-llvm -c $< -o -| $(LLC) -march=bpf -filetype=obj -o $@
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index cc62ad4d95de..58c5fe1bdba1 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -15,7 +15,7 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 		  const struct bpf_insn *insns, int insn_len,
 		  const char *license);
 
-#define LOG_BUF_SIZE 8192
+#define LOG_BUF_SIZE 65536
 extern char bpf_log_buf[LOG_BUF_SIZE];
 
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
diff --git a/samples/bpf/sockex1_kern.c b/samples/bpf/sockex1_kern.c
new file mode 100644
index 000000000000..e662779467de
--- /dev/null
+++ b/samples/bpf/sockex1_kern.c
@@ -0,0 +1,23 @@
+#include <uapi/linux/bpf.h>
+#include "bpf_helpers.h"
+
+struct bpf_map_def SEC("maps") my_map = {
+	.type = BPF_MAP_TYPE_ARRAY,
+	.key_size = sizeof(u32),
+	.value_size = sizeof(long),
+	.max_entries = 256,
+};
+
+SEC("socket1")
+int bpf_prog1(struct sk_buff *skb)
+{
+	int index = load_byte(skb, 14 + 9);
+	long *value;
+
+	value = bpf_map_lookup_elem(&my_map, &index);
+	if (value)
+		__sync_fetch_and_add(value, 1);
+
+	return 0;
+}
+char _license[] SEC("license") = "GPL";
diff --git a/samples/bpf/sockex1_user.c b/samples/bpf/sockex1_user.c
new file mode 100644
index 000000000000..34a443ff3831
--- /dev/null
+++ b/samples/bpf/sockex1_user.c
@@ -0,0 +1,49 @@
+#include <stdio.h>
+#include <assert.h>
+#include <linux/bpf.h>
+#include "libbpf.h"
+#include "bpf_load.h"
+#include <unistd.h>
+#include <arpa/inet.h>
+
+int main(int ac, char **argv)
+{
+	char filename[256];
+	FILE *f;
+	int i, sock;
+
+	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+
+	if (load_bpf_file(filename)) {
+		printf("%s", bpf_log_buf);
+		return 1;
+	}
+
+	sock = open_raw_sock("lo");
+
+	assert(setsockopt(sock, SOL_SOCKET, SO_ATTACH_BPF, prog_fd,
+			  sizeof(prog_fd[0])) == 0);
+
+	f = popen("ping -c5 localhost", "r");
+	(void) f;
+
+	for (i = 0; i < 5; i++) {
+		long long tcp_cnt, udp_cnt, icmp_cnt;
+		int key;
+
+		key = IPPROTO_TCP;
+		assert(bpf_lookup_elem(map_fd[0], &key, &tcp_cnt) == 0);
+
+		key = IPPROTO_UDP;
+		assert(bpf_lookup_elem(map_fd[0], &key, &udp_cnt) == 0);
+
+		key = IPPROTO_ICMP;
+		assert(bpf_lookup_elem(map_fd[0], &key, &icmp_cnt) == 0);
+
+		printf("TCP %lld UDP %lld ICMP %lld packets\n",
+		       tcp_cnt, udp_cnt, icmp_cnt);
+		sleep(1);
+	}
+
+	return 0;
+}
-- 
1.7.9.5
