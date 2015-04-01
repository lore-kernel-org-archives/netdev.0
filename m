From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next v2] tc, bpf: finalize eBPF support for cls and act front-end
Date: Wed,  1 Apr 2015 17:57:44 +0200
Message-ID: <e253218a3cd6e0885a3884ec6dbbaabafd1bfe43.1427903335.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, jiri@resnulli.us, jhs@mojatatu.com,
	tgraf@suug.ch, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59414 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752083AbbDAP5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Apr 2015 11:57:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work finalizes both eBPF front-ends for the classifier and action
part in tc, it allows for custom ELF section selection, a simplified tc
command frontend (while keeping compat), reusing of common maps between
classifier and actions residing in the same object file, and exporting
of all map fds to an eBPF agent for handing off further control in user
space.

It also adds an extensive example of how eBPF can be used, and a minimal
self-contained example agent that dumps map data. The example is well
documented and hopefully provides a good starting point into programming
cls_bpf and act_bpf.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Jiri Pirko <jiri@resnulli.us>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>
---
 ( Applies without header rebase, thanks! )
 v1 -> v2:
  - Reordered id member
  - Reduced code duplication
  - Added error msg on bpf_open_object(), thanks Alexei
  - Rest as is

 README.iproute2+tc        |   6 +-
 examples/bpf/bpf_agent.c  | 223 ++++++++++++++++++++++
 examples/bpf/bpf_funcs.h  |  58 ++++++
 examples/bpf/bpf_prog.c   | 463 ++++++++++++++++++++++++++++++++++++++++++++++
 examples/bpf/bpf_shared.h |  26 +++
 examples/bpf/bpf_sys.h    |  23 +++
 include/bpf_elf.h         |  33 ++++
 include/bpf_scm.h         |  75 ++++++++
 include/utils.h           |  14 ++
 tc/f_bpf.c                | 113 ++++++++---
 tc/m_bpf.c                | 128 +++++++++++--
 tc/tc_bpf.c               | 269 ++++++++++++++++++++++-----
 tc/tc_bpf.h               |  46 ++---
 13 files changed, 1354 insertions(+), 123 deletions(-)
 create mode 100644 examples/bpf/bpf_agent.c
 create mode 100644 examples/bpf/bpf_funcs.h
 create mode 100644 examples/bpf/bpf_prog.c
 create mode 100644 examples/bpf/bpf_shared.h
 create mode 100644 examples/bpf/bpf_sys.h
 create mode 100644 include/bpf_elf.h
 create mode 100644 include/bpf_scm.h

diff --git a/README.iproute2+tc b/README.iproute2+tc
index 6aa5d18..2a5638d 100644
--- a/README.iproute2+tc
+++ b/README.iproute2+tc
@@ -72,12 +72,16 @@ ip route add 10.11.12.0/24 dev eth1 via whatever realm 1
 etc. The same thing can be made with rules.
 I still did not test ipchains, but they should work too.
 
+
+Setup and code example of BPF classifier and action can be found under
+examples/bpf/, which should explain everything for getting started.
+
+
 Setup of rsvp and u32 classifiers is more hairy.
 If you read RSVP specs, you will understand how rsvp classifier
 works easily. What's about u32... That's example:
 
 
-
 #! /bin/sh
 
 TC=/home/root/tc
diff --git a/examples/bpf/bpf_agent.c b/examples/bpf/bpf_agent.c
new file mode 100644
index 0000000..0f481b1
--- /dev/null
+++ b/examples/bpf/bpf_agent.c
@@ -0,0 +1,223 @@
+/*
+ * eBPF user space agent part
+ *
+ * Simple, _self-contained_ user space agent for the eBPF kernel
+ * ebpf_prog.c program, which gets all map fds passed from tc via unix
+ * domain socket in one transaction and can thus keep referencing
+ * them from user space in order to read out (or possibly modify)
+ * map data. Here, just as a minimal example to display counters.
+ *
+ * The agent only uses the bpf(2) syscall API to read or possibly
+ * write to eBPF maps, it doesn't need to be aware of the low-level
+ * bytecode parts and/or ELF parsing bits.
+ *
+ * ! For more details, see header comment in bpf_prog.c !
+ *
+ * gcc bpf_agent.c -o bpf_agent -Wall -O2
+ *
+ * For example, a more complex user space agent could run on each
+ * host, reading and writing into eBPF maps used by tc classifier
+ * and actions. It would thus allow for implementing a distributed
+ * tc architecture, for example, which would push down central
+ * policies into eBPF maps, and thus altering run-time behaviour.
+ *
+ *   -- Happy eBPF hacking! ;)
+ */
+
+#include <stdio.h>
+#include <stdlib.h>
+#include <string.h>
+#include <errno.h>
+#include <unistd.h>
+#include <stdint.h>
+#include <assert.h>
+#include <sys/un.h>
+#include <sys/types.h>
+#include <sys/stat.h>
+#include <sys/socket.h>
+
+/* Just some misc macros as min(), offsetof(), etc. */
+#include "../../include/utils.h"
+/* Common code from fd passing. */
+#include "../../include/bpf_scm.h"
+/* Common, shared definitions with ebpf_prog.c */
+#include "bpf_shared.h"
+/* Mini syscall wrapper */
+#include "bpf_sys.h"
+
+static void bpf_dump_drops(int fd)
+{
+	int cpu, max;
+
+	max = sysconf(_SC_NPROCESSORS_ONLN);
+
+	printf(" `- number of drops:");
+	for (cpu = 0; cpu < max; cpu++) {
+		long drops;
+
+		assert(bpf_lookup_elem(fd, &cpu, &drops) == 0);
+		printf("\tcpu%d: %5ld", cpu, drops);
+	}
+	printf("\n");
+}
+
+static void bpf_dump_queue(int fd)
+{
+	/* Just for the same of the example. */
+	int max_queue = 4, i;
+
+	printf("  | nic queues:");
+	for (i = 0; i < max_queue; i++) {
+		struct count_queue cq;
+		int ret;
+
+		memset(&cq, 0, sizeof(cq));
+		ret = bpf_lookup_elem(fd, &i, &cq);
+		assert(ret == 0 || (ret < 0 && errno == ENOENT));
+
+		printf("\tq%d:[pkts: %ld, mis: %ld]",
+		       i, cq.total, cq.mismatch);
+	}
+	printf("\n");
+}
+
+static void bpf_dump_proto(int fd)
+{
+	uint8_t protos[] = { IPPROTO_TCP, IPPROTO_UDP, IPPROTO_ICMP };
+	char *names[] = { "tcp", "udp", "icmp" };
+	int i;
+
+	printf("  ` protos:");
+	for (i = 0; i < ARRAY_SIZE(protos); i++) {
+		struct count_tuple ct;
+		int ret;
+
+		memset(&ct, 0, sizeof(ct));
+		ret = bpf_lookup_elem(fd, &protos[i], &ct);
+		assert(ret == 0 || (ret < 0 && errno == ENOENT));
+
+		printf("\t%s:[pkts: %ld, bytes: %ld]",
+		       names[i], ct.packets, ct.bytes);
+	}
+	printf("\n");
+}
+
+static void bpf_info_loop(int *fds, struct bpf_map_aux *aux)
+{
+	int i, tfd[BPF_MAP_ID_MAX];
+
+	printf("ver: %d\nobj: %s\ndev: %lu\nino: %lu\nmaps: %u\n",
+	       aux->uds_ver, aux->obj_name, aux->obj_st.st_dev,
+	       aux->obj_st.st_ino, aux->num_ent);
+
+	for (i = 0; i < aux->num_ent; i++) {
+		printf("map%d:\n", i);
+		printf(" `- fd: %u\n", fds[i]);
+		printf("  | serial: %u\n", aux->ent[i].id);
+		printf("  | type: %u\n", aux->ent[i].type);
+		printf("  | max elem: %u\n", aux->ent[i].max_elem);
+		printf("  | size key: %u\n", aux->ent[i].size_key);
+		printf("  ` size val: %u\n", aux->ent[i].size_value);
+
+		tfd[aux->ent[i].id] = fds[i];
+	}
+
+	for (i = 0; i < 30; i++) {
+		int period = 5;
+
+		printf("data, period: %dsec\n", period);
+
+		bpf_dump_drops(tfd[BPF_MAP_ID_DROPS]);
+		bpf_dump_queue(tfd[BPF_MAP_ID_QUEUE]);
+		bpf_dump_proto(tfd[BPF_MAP_ID_PROTO]);
+
+		sleep(period);
+	}
+}
+
+static int bpf_map_set_recv(int fd, int *fds,  struct bpf_map_aux *aux,
+			    unsigned int entries)
+{
+	struct bpf_map_set_msg msg;
+	int *cmsg_buf, min_fd, i;
+	char *amsg_buf, *mmsg_buf;
+
+	cmsg_buf = bpf_map_set_init(&msg, NULL, 0);
+	amsg_buf = (char *)msg.aux.ent;
+	mmsg_buf = (char *)&msg.aux;
+
+	for (i = 0; i < entries; i += min_fd) {
+		struct cmsghdr *cmsg;
+		int ret;
+
+		min_fd = min(BPF_SCM_MAX_FDS * 1U, entries - i);
+
+		bpf_map_set_init_single(&msg, min_fd);
+
+		ret = recvmsg(fd, &msg.hdr, 0);
+		if (ret <= 0)
+			return ret ? : -1;
+
+		cmsg = CMSG_FIRSTHDR(&msg.hdr);
+		if (!cmsg || cmsg->cmsg_type != SCM_RIGHTS)
+			return -EINVAL;
+		if (msg.hdr.msg_flags & MSG_CTRUNC)
+			return -EIO;
+
+		min_fd = (cmsg->cmsg_len - sizeof(*cmsg)) / sizeof(fd);
+		if (min_fd > entries || min_fd <= 0)
+			return -1;
+
+		memcpy(&fds[i], cmsg_buf, sizeof(fds[0]) * min_fd);
+		memcpy(&aux->ent[i], amsg_buf, sizeof(aux->ent[0]) * min_fd);
+		memcpy(aux, mmsg_buf, offsetof(struct bpf_map_aux, ent));
+
+		if (i + min_fd == aux->num_ent)
+			break;
+	}
+
+	return 0;
+}
+
+int main(int argc, char **argv)
+{
+	int fds[BPF_SCM_MAX_FDS];
+	struct bpf_map_aux aux;
+	struct sockaddr_un addr;
+	int fd, ret, i;
+
+	if (argc < 2) {
+		fprintf(stderr, "Usage: %s <path-uds>\n", argv[0]);
+		exit(1);
+	}
+
+	fd = socket(AF_UNIX, SOCK_DGRAM, 0);
+	if (fd < 0) {
+		fprintf(stderr, "Cannot open socket: %s\n",
+			strerror(errno));
+		exit(1);
+	}
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sun_family = AF_UNIX;
+	strncpy(addr.sun_path, argv[argc - 1], sizeof(addr.sun_path));
+
+	ret = bind(fd, (struct sockaddr *)&addr, sizeof(addr));
+	if (ret < 0) {
+		fprintf(stderr, "Cannot bind to socket: %s\n",
+			strerror(errno));
+		exit(1);
+	}
+
+	memset(fds, 0, sizeof(fds));
+	memset(&aux, 0, sizeof(aux));
+
+	ret = bpf_map_set_recv(fd, fds, &aux, BPF_SCM_MAX_FDS);
+	if (ret >= 0)
+		bpf_info_loop(fds, &aux);
+
+	for (i = 0; i < aux.num_ent; i++)
+		close(fds[i]);
+	close(fd);
+	return 0;
+}
diff --git a/examples/bpf/bpf_funcs.h b/examples/bpf/bpf_funcs.h
new file mode 100644
index 0000000..1545fa9
--- /dev/null
+++ b/examples/bpf/bpf_funcs.h
@@ -0,0 +1,58 @@
+#ifndef __BPF_FUNCS__
+#define __BPF_FUNCS__
+
+/* Misc macros. */
+#ifndef __maybe_unused
+# define __maybe_unused		__attribute__ ((__unused__))
+#endif
+
+#ifndef __section
+# define __section(NAME)	__attribute__((section(NAME), used))
+#endif
+
+#ifndef offsetof
+# define offsetof		__builtin_offsetof
+#endif
+
+#ifndef htons
+# define htons(x)		__constant_htons((x))
+#endif
+
+#ifndef likely
+# define likely(x)		__builtin_expect(!!(x), 1)
+#endif
+
+#ifndef unlikely
+# define unlikely(x)		__builtin_expect(!!(x), 0)
+#endif
+
+/* The verifier will translate them to actual function calls. */
+static void *(*bpf_map_lookup_elem)(void *map, void *key) __maybe_unused =
+	(void *) BPF_FUNC_map_lookup_elem;
+
+static int (*bpf_map_update_elem)(void *map, void *key, void *value,
+				  unsigned long long flags) __maybe_unused =
+	(void *) BPF_FUNC_map_update_elem;
+
+static int (*bpf_map_delete_elem)(void *map, void *key) __maybe_unused =
+	(void *) BPF_FUNC_map_delete_elem;
+
+static unsigned int (*get_smp_processor_id)(void) __maybe_unused =
+	(void *) BPF_FUNC_get_smp_processor_id;
+
+static unsigned int (*get_prandom_u32)(void) __maybe_unused =
+	(void *) BPF_FUNC_get_prandom_u32;
+
+/* LLVM built-in functions that an eBPF C program may use to emit
+ * BPF_LD_ABS and BPF_LD_IND instructions.
+ */
+unsigned long long load_byte(void *skb, unsigned long long off)
+	asm ("llvm.bpf.load.byte");
+
+unsigned long long load_half(void *skb, unsigned long long off)
+	asm ("llvm.bpf.load.half");
+
+unsigned long long load_word(void *skb, unsigned long long off)
+	asm ("llvm.bpf.load.word");
+
+#endif /* __BPF_FUNCS__ */
diff --git a/examples/bpf/bpf_prog.c b/examples/bpf/bpf_prog.c
new file mode 100644
index 0000000..ca9b54f
--- /dev/null
+++ b/examples/bpf/bpf_prog.c
@@ -0,0 +1,463 @@
+/*
+ * eBPF kernel space program part
+ *
+ * Toy eBPF program for demonstration purposes, some parts derived from
+ * kernel tree's samples/bpf/sockex2_kern.c example.
+ *
+ * More background on eBPF, kernel tree: Documentation/networking/filter.txt
+ *
+ * Note, this file is rather large, and most classifier and actions are
+ * likely smaller to accomplish one specific use-case and are tailored
+ * for high performance. For performance reasons, you might also have the
+ * classifier and action already merged inside the classifier.
+ *
+ * In order to show various features it serves as a bigger programming
+ * example, which you should feel free to rip apart and experiment with.
+ *
+ * Compilation, configuration example:
+ *
+ *  Note: as long as the BPF backend in LLVM is still experimental,
+ *  you need to build LLVM with LLVM with --enable-experimental-targets=BPF
+ *  Also, make sure your 4.1+ kernel is compiled with CONFIG_BPF_SYSCALL=y,
+ *  and you have libelf.h and gelf.h headers and can link tc against -lelf.
+ *
+ *  In case you need to sync kernel headers, go to your kernel source tree:
+ *  # make headers_install INSTALL_HDR_PATH=/usr/
+ *
+ *  $ export PATH=/home/<...>/llvm/Debug+Asserts/bin/:$PATH
+ *  $ clang -O2 -emit-llvm -c bpf_prog.c -o - | llc -march=bpf -filetype=obj -o bpf.o
+ *  $ objdump -h bpf.o
+ *  [...]
+ *  3 classifier    000007f8  0000000000000000  0000000000000000  00000040  2**3
+ *                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
+ *  4 action-mark   00000088  0000000000000000  0000000000000000  00000838  2**3
+ *                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
+ *  5 action-rand   00000098  0000000000000000  0000000000000000  000008c0  2**3
+ *                  CONTENTS, ALLOC, LOAD, RELOC, READONLY, CODE
+ *  6 maps          00000030  0000000000000000  0000000000000000  00000958  2**2
+ *                  CONTENTS, ALLOC, LOAD, DATA
+ *  7 license       00000004  0000000000000000  0000000000000000  00000988  2**0
+ *                  CONTENTS, ALLOC, LOAD, DATA
+ *  [...]
+ *  # echo 1 > /proc/sys/net/core/bpf_jit_enable
+ *  $ gcc bpf_agent.c -o bpf_agent -Wall -O2
+ *  # ./bpf_agent /tmp/bpf-uds      (e.g. on a different terminal)
+ *  # tc filter add dev em1 parent 1: bpf obj bpf.o exp /tmp/bpf-uds flowid 1:1 \
+ *                             action bpf obj bpf.o sec action-mark            \
+ *                             action bpf obj bpf.o sec action-rand ok
+ *  # tc filter show dev em1
+ *  filter parent 1: protocol all pref 49152 bpf
+ *  filter parent 1: protocol all pref 49152 bpf handle 0x1 flowid 1:1 bpf.o:[classifier]
+ *    action order 1: bpf bpf.o:[action-mark] default-action pipe
+ *    index 52 ref 1 bind 1
+ *
+ *    action order 2: bpf bpf.o:[action-rand] default-action pipe
+ *    index 53 ref 1 bind 1
+ *
+ *    action order 3: gact action pass
+ *    random type none pass val 0
+ *    index 38 ref 1 bind 1
+ *
+ * BPF agent example output:
+ *
+ * ver: 1
+ * obj: bpf.o
+ * dev: 64770
+ * ino: 6045133
+ * maps: 3
+ * map0:
+ *  `- fd: 4
+ *   | serial: 1
+ *   | type: 1
+ *   | max elem: 256
+ *   | size key: 1
+ *   ` size val: 16
+ * map1:
+ *  `- fd: 5
+ *   | serial: 2
+ *   | type: 1
+ *   | max elem: 1024
+ *   | size key: 4
+ *   ` size val: 16
+ * map2:
+ *  `- fd: 6
+ *   | serial: 3
+ *   | type: 2
+ *   | max elem: 64
+ *   | size key: 4
+ *   ` size val: 8
+ * data, period: 5sec
+ *  `- number of drops:	cpu0:     0	cpu1:     0	cpu2:     0	cpu3:     0
+ *   | nic queues:	q0:[pkts: 0, mis: 0]	q1:[pkts: 0, mis: 0]	q2:[pkts: 0, mis: 0]	q3:[pkts: 0, mis: 0]
+ *   ` protos:	tcp:[pkts: 0, bytes: 0]	udp:[pkts: 0, bytes: 0]	icmp:[pkts: 0, bytes: 0]
+ * data, period: 5sec
+ *  `- number of drops:	cpu0:     5	cpu1:     0	cpu2:     0	cpu3:     1
+ *   | nic queues:	q0:[pkts: 0, mis: 0]	q1:[pkts: 0, mis: 0]	q2:[pkts: 24, mis: 14]	q3:[pkts: 0, mis: 0]
+ *   ` protos:	tcp:[pkts: 13, bytes: 1989]	udp:[pkts: 10, bytes: 710]	icmp:[pkts: 0, bytes: 0]
+ * data, period: 5sec
+ *  `- number of drops:	cpu0:     5	cpu1:     0	cpu2:     3	cpu3:     3
+ *   | nic queues:	q0:[pkts: 0, mis: 0]	q1:[pkts: 0, mis: 0]	q2:[pkts: 39, mis: 21]	q3:[pkts: 0, mis: 0]
+ *   ` protos:	tcp:[pkts: 20, bytes: 3549]	udp:[pkts: 18, bytes: 1278]	icmp:[pkts: 0, bytes: 0]
+ * [...]
+ *
+ * This now means, the below classifier and action pipeline has been loaded
+ * as eBPF bytecode into the kernel, the kernel has verified that the
+ * execution of the bytecode is "safe", and it has JITed the programs
+ * afterwards, so that upon invocation they're running on native speed. tc
+ * has transferred all map file descriptors to the bpf_agent via IPC and
+ * even after tc exits, the agent can read out or modify all map data.
+ *
+ * Note that the export to the uds is done only once in the classifier and
+ * not in the action. It's enough to export the (here) shared descriptors
+ * once.
+ *
+ * If you need to disassemble the generated JIT image (echo with 2), the
+ * kernel tree has under tools/net/ a small helper, you can invoke e.g.
+ * `bpf_jit_disasm -o`.
+ *
+ * Please find in the code below further comments.
+ *
+ *   -- Happy eBPF hacking! ;)
+ */
+#include <stdint.h>
+#include <stdbool.h>
+#include <sys/types.h>
+#include <sys/socket.h>
+#include <asm/types.h>
+#include <linux/in.h>
+#include <linux/if.h>
+#include <linux/if_ether.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/if_tunnel.h>
+#include <linux/bpf.h>
+
+/* Common, shared definitions with ebpf_agent.c. */
+#include "bpf_shared.h"
+/* Selection of BPF helper functions for our example. */
+#include "bpf_funcs.h"
+
+/* Could be defined here as well, or included from the header. */
+#define TC_ACT_UNSPEC		(-1)
+#define TC_ACT_OK		0
+#define TC_ACT_RECLASSIFY	1
+#define TC_ACT_SHOT		2
+#define TC_ACT_PIPE		3
+#define TC_ACT_STOLEN		4
+#define TC_ACT_QUEUED		5
+#define TC_ACT_REPEAT		6
+
+/* Other, misc stuff. */
+#define IP_MF			0x2000
+#define IP_OFFSET		0x1FFF
+
+/* eBPF map definitions, all placed in section "maps". */
+struct bpf_elf_map __section("maps") map_proto = {
+	.type		=	BPF_MAP_TYPE_HASH,
+	.id		=	BPF_MAP_ID_PROTO,
+	.size_key	=	sizeof(uint8_t),
+	.size_value	=	sizeof(struct count_tuple),
+	.max_elem	=	256,
+};
+
+struct bpf_elf_map __section("maps") map_queue = {
+	.type		=	BPF_MAP_TYPE_HASH,
+	.id		=	BPF_MAP_ID_QUEUE,
+	.size_key	=	sizeof(uint32_t),
+	.size_value	=	sizeof(struct count_queue),
+	.max_elem	=	1024,
+};
+
+struct bpf_elf_map __section("maps") map_drops = {
+	.type		=	BPF_MAP_TYPE_ARRAY,
+	.id		=	BPF_MAP_ID_DROPS,
+	.size_key	=	sizeof(uint32_t),
+	.size_value	=	sizeof(long),
+	.max_elem	=	64,
+};
+
+/* Helper functions and definitions for the flow dissector used by the
+ * example classifier. This resembles the kernel's flow dissector to
+ * some extend and is just used as an example to show what's possible
+ * with eBPF.
+ */
+struct sockaddr;
+
+struct vlan_hdr {
+	__be16 h_vlan_TCI;
+	__be16 h_vlan_encapsulated_proto;
+};
+
+struct flow_keys {
+	__u32 src;
+	__u32 dst;
+	union {
+		__u32 ports;
+		__u16 port16[2];
+	};
+	__u16 th_off;
+	__u8 ip_proto;
+};
+
+static inline int flow_ports_offset(__u8 ip_proto)
+{
+	switch (ip_proto) {
+	case IPPROTO_TCP:
+	case IPPROTO_UDP:
+	case IPPROTO_DCCP:
+	case IPPROTO_ESP:
+	case IPPROTO_SCTP:
+	case IPPROTO_UDPLITE:
+	default:
+		return 0;
+	case IPPROTO_AH:
+		return 4;
+	}
+}
+
+static inline bool flow_is_frag(struct __sk_buff *skb, __u32 nh_off)
+{
+	return !!(load_half(skb, nh_off + offsetof(struct iphdr, frag_off)) &
+		  (IP_MF | IP_OFFSET));
+}
+
+static inline __u32 flow_parse_ipv4(struct __sk_buff *skb, __u32 nh_off,
+				    __u8 *ip_proto, struct flow_keys *flow)
+{
+	__u8 ip_ver_len;
+
+	if (unlikely(flow_is_frag(skb, nh_off)))
+		*ip_proto = 0;
+	else
+		*ip_proto = load_byte(skb, nh_off + offsetof(struct iphdr,
+							     protocol));
+	if (*ip_proto != IPPROTO_GRE) {
+		flow->src = load_word(skb, nh_off + offsetof(struct iphdr, saddr));
+		flow->dst = load_word(skb, nh_off + offsetof(struct iphdr, daddr));
+	}
+
+	ip_ver_len = load_byte(skb, nh_off + 0 /* offsetof(struct iphdr, ihl) */);
+	if (likely(ip_ver_len == 0x45))
+		nh_off += 20;
+	else
+		nh_off += (ip_ver_len & 0xF) << 2;
+
+	return nh_off;
+}
+
+static inline __u32 flow_addr_hash_ipv6(struct __sk_buff *skb, __u32 off)
+{
+	__u32 w0 = load_word(skb, off);
+	__u32 w1 = load_word(skb, off + sizeof(w0));
+	__u32 w2 = load_word(skb, off + sizeof(w0) * 2);
+	__u32 w3 = load_word(skb, off + sizeof(w0) * 3);
+
+	return (__u32)(w0 ^ w1 ^ w2 ^ w3);
+}
+
+static inline __u32 flow_parse_ipv6(struct __sk_buff *skb, __u32 nh_off,
+				    __u8 *ip_proto, struct flow_keys *flow)
+{
+	*ip_proto = load_byte(skb, nh_off + offsetof(struct ipv6hdr, nexthdr));
+
+	flow->src = flow_addr_hash_ipv6(skb, nh_off + offsetof(struct ipv6hdr, saddr));
+	flow->dst = flow_addr_hash_ipv6(skb, nh_off + offsetof(struct ipv6hdr, daddr));
+
+	return nh_off + sizeof(struct ipv6hdr);
+}
+
+static inline bool flow_dissector(struct __sk_buff *skb,
+				  struct flow_keys *flow)
+{
+	__be16 proto = skb->protocol;
+	__u32 nh_off = ETH_HLEN;
+	__u8 ip_proto;
+	int poff;
+
+	/* TODO: check for skb->vlan_tci, skb->vlan_proto first */
+	if (proto == htons(ETH_P_8021AD)) {
+		proto = load_half(skb, nh_off +
+				  offsetof(struct vlan_hdr, h_vlan_encapsulated_proto));
+		nh_off += sizeof(struct vlan_hdr);
+	}
+	if (proto == htons(ETH_P_8021Q)) {
+		proto = load_half(skb, nh_off +
+				  offsetof(struct vlan_hdr, h_vlan_encapsulated_proto));
+		nh_off += sizeof(struct vlan_hdr);
+	}
+
+	if (likely(proto == htons(ETH_P_IP)))
+		nh_off = flow_parse_ipv4(skb, nh_off, &ip_proto, flow);
+	else if (proto == htons(ETH_P_IPV6))
+		nh_off = flow_parse_ipv6(skb, nh_off, &ip_proto, flow);
+	else
+		return false;
+
+	switch (ip_proto) {
+	case IPPROTO_GRE: {
+		struct gre_hdr {
+			__be16 flags;
+			__be16 proto;
+		};
+
+		__u16 gre_flags = load_half(skb, nh_off +
+					    offsetof(struct gre_hdr, flags));
+		__u16 gre_proto = load_half(skb, nh_off +
+					    offsetof(struct gre_hdr, proto));
+
+		if (gre_flags & (GRE_VERSION | GRE_ROUTING))
+			break;
+
+		nh_off += 4;
+		if (gre_flags & GRE_CSUM)
+			nh_off += 4;
+		if (gre_flags & GRE_KEY)
+			nh_off += 4;
+		if (gre_flags & GRE_SEQ)
+			nh_off += 4;
+
+		if (gre_proto == ETH_P_8021Q) {
+			gre_proto = load_half(skb, nh_off +
+					      offsetof(struct vlan_hdr,
+						       h_vlan_encapsulated_proto));
+			nh_off += sizeof(struct vlan_hdr);
+		}
+		if (gre_proto == ETH_P_IP)
+			nh_off = flow_parse_ipv4(skb, nh_off, &ip_proto, flow);
+		else if (gre_proto == ETH_P_IPV6)
+			nh_off = flow_parse_ipv6(skb, nh_off, &ip_proto, flow);
+		else
+			return false;
+		break;
+	}
+	case IPPROTO_IPIP:
+		nh_off = flow_parse_ipv4(skb, nh_off, &ip_proto, flow);
+		break;
+	case IPPROTO_IPV6:
+		nh_off = flow_parse_ipv6(skb, nh_off, &ip_proto, flow);
+	default:
+		break;
+	}
+
+	nh_off += flow_ports_offset(ip_proto);
+
+	flow->ports = load_word(skb, nh_off);
+	flow->th_off = (__u16)nh_off;
+	flow->ip_proto = ip_proto;
+
+	return true;
+}
+
+static inline void cls_update_proto_map(const struct __sk_buff *skb,
+					const struct flow_keys *flow)
+{
+	uint8_t proto = flow->ip_proto;
+	struct count_tuple *ct, _ct;
+
+	ct = bpf_map_lookup_elem(&map_proto, &proto);
+	if (likely(ct)) {
+		__sync_fetch_and_add(&ct->packets, 1);
+		__sync_fetch_and_add(&ct->bytes, skb->len);
+		return;
+	}
+
+	/* No hit yet, we need to create a new entry. */
+	_ct.packets = 1;
+	_ct.bytes = skb->len;
+
+	bpf_map_update_elem(&map_proto, &proto, &_ct, BPF_ANY);
+}
+
+static inline void cls_update_queue_map(const struct __sk_buff *skb)
+{
+	uint32_t queue = skb->queue_mapping;
+	struct count_queue *cq, _cq;
+	bool mismatch;
+
+	mismatch = skb->queue_mapping != get_smp_processor_id();
+
+	cq = bpf_map_lookup_elem(&map_queue, &queue);
+	if (likely(cq)) {
+		__sync_fetch_and_add(&cq->total, 1);
+		if (mismatch)
+			__sync_fetch_and_add(&cq->mismatch, 1);
+		return;
+	}
+
+	/* No hit yet, we need to create a new entry. */
+	_cq.total = 1;
+	_cq.mismatch = mismatch ? 1 : 0;
+
+	bpf_map_update_elem(&map_queue, &queue, &_cq, BPF_ANY);
+}
+
+/* eBPF program definitions, placed in various sections, which can
+ * have custom section names. If custom names are in use, it's
+ * required to point tc to the correct section, e.g.
+ *
+ *     tc filter add [...] bpf obj cls.o sec cls-tos [...]
+ *
+ * in case the program resides in __section("cls-tos").
+ *
+ * Default section for cls_bpf is: "classifier", for act_bpf is:
+ * "action". Naturally, if for example multiple actions are present
+ * in the same file, they need to have distinct section names.
+ *
+ * It is however not required to have multiple programs sharing
+ * a file.
+ */
+__section("classifier") int cls_main(struct __sk_buff *skb)
+{
+	struct flow_keys flow;
+
+	if (!flow_dissector(skb, &flow))
+		return 0; /* No match in cls_bpf. */
+
+	cls_update_proto_map(skb, &flow);
+	cls_update_queue_map(skb);
+
+	return flow.ip_proto;
+}
+
+static inline void act_update_drop_map(void)
+{
+	uint32_t *count, cpu = get_smp_processor_id();
+
+	count = bpf_map_lookup_elem(&map_drops, &cpu);
+	if (count)
+		/* Only this cpu is accessing this element. */
+		(*count)++;
+}
+
+__section("action-mark") int act_mark_main(struct __sk_buff *skb)
+{
+	/* You could also mangle skb data here with the helper function
+	 * BPF_FUNC_skb_store_bytes, etc. Or, alternatively you could
+	 * do that already in the classifier itself as a merged combination
+	 * of classifier'n'action model.
+	 */
+
+	if (skb->mark == 0xcafe) {
+		act_update_drop_map();
+		return TC_ACT_SHOT;
+	}
+
+	/* Default configured tc opcode. */
+	return TC_ACT_UNSPEC;
+}
+
+__section("action-rand") int act_rand_main(struct __sk_buff *skb)
+{
+	/* Sorry, we're near event horizon ... */
+	if ((get_prandom_u32() & 3) == 0) {
+		act_update_drop_map();
+		return TC_ACT_SHOT;
+	}
+
+	return TC_ACT_UNSPEC;
+}
+
+/* Last but not least, the file contains a license. Some future helper
+ * functions may only be available with a GPL license.
+ */
+char __license[] __section("license") = "GPL";
diff --git a/examples/bpf/bpf_shared.h b/examples/bpf/bpf_shared.h
new file mode 100644
index 0000000..46423ec
--- /dev/null
+++ b/examples/bpf/bpf_shared.h
@@ -0,0 +1,26 @@
+#ifndef __BPF_SHARED__
+#define __BPF_SHARED__
+
+#include <stdint.h>
+
+#include "../../include/bpf_elf.h"
+
+enum {
+	BPF_MAP_ID_PROTO,
+	BPF_MAP_ID_QUEUE,
+	BPF_MAP_ID_DROPS,
+	__BPF_MAP_ID_MAX,
+#define BPF_MAP_ID_MAX	__BPF_MAP_ID_MAX
+};
+
+struct count_tuple {
+	long packets; /* type long for __sync_fetch_and_add() */
+	long bytes;
+};
+
+struct count_queue {
+	long total;
+	long mismatch;
+};
+
+#endif /* __BPF_SHARED__ */
diff --git a/examples/bpf/bpf_sys.h b/examples/bpf/bpf_sys.h
new file mode 100644
index 0000000..6e4f09e
--- /dev/null
+++ b/examples/bpf/bpf_sys.h
@@ -0,0 +1,23 @@
+#ifndef __BPF_SYS__
+#define __BPF_SYS__
+
+#include <sys/syscall.h>
+#include <linux/bpf.h>
+
+static inline __u64 bpf_ptr_to_u64(const void *ptr)
+{
+	return (__u64) (unsigned long) ptr;
+}
+
+static inline int bpf_lookup_elem(int fd, void *key, void *value)
+{
+	union bpf_attr attr = {
+		.map_fd		= fd,
+		.key		= bpf_ptr_to_u64(key),
+		.value		= bpf_ptr_to_u64(value),
+	};
+
+	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
+}
+
+#endif /* __BPF_SYS__ */
diff --git a/include/bpf_elf.h b/include/bpf_elf.h
new file mode 100644
index 0000000..4bd6bb0
--- /dev/null
+++ b/include/bpf_elf.h
@@ -0,0 +1,33 @@
+#ifndef __BPF_ELF__
+#define __BPF_ELF__
+
+#include <asm/types.h>
+
+/* Note:
+ *
+ * Below ELF section names and bpf_elf_map structure definition
+ * are not (!) kernel ABI. It's rather a "contract" between the
+ * application and the BPF loader in tc. For compatibility, the
+ * section names should stay as-is. Introduction of aliases, if
+ * needed, are a possibility, though.
+ */
+
+/* ELF section names, etc */
+#define ELF_SECTION_LICENSE	"license"
+#define ELF_SECTION_MAPS	"maps"
+#define ELF_SECTION_CLASSIFIER	"classifier"
+#define ELF_SECTION_ACTION	"action"
+
+#define ELF_MAX_MAPS		64
+#define ELF_MAX_LICENSE_LEN	128
+
+/* ELF map definition */
+struct bpf_elf_map {
+	__u32 type;
+	__u32 size_key;
+	__u32 size_value;
+	__u32 max_elem;
+	__u32 id;
+};
+
+#endif /* __BPF_ELF__ */
diff --git a/include/bpf_scm.h b/include/bpf_scm.h
new file mode 100644
index 0000000..35117d1
--- /dev/null
+++ b/include/bpf_scm.h
@@ -0,0 +1,75 @@
+#ifndef __BPF_SCM__
+#define __BPF_SCM__
+
+#include <sys/types.h>
+#include <sys/socket.h>
+
+#include "utils.h"
+#include "bpf_elf.h"
+
+#define BPF_SCM_AUX_VER		1
+#define BPF_SCM_MAX_FDS		ELF_MAX_MAPS
+#define BPF_SCM_MSG_SIZE	1024
+
+struct bpf_elf_st {
+	dev_t st_dev;
+	ino_t st_ino;
+};
+
+struct bpf_map_aux {
+	unsigned short uds_ver;
+	unsigned short num_ent;
+	char obj_name[64];
+	struct bpf_elf_st obj_st;
+	struct bpf_elf_map ent[BPF_SCM_MAX_FDS];
+};
+
+struct bpf_map_set_msg {
+	struct msghdr hdr;
+	struct iovec iov;
+	char msg_buf[BPF_SCM_MSG_SIZE];
+	struct bpf_map_aux aux;
+};
+
+static inline int *bpf_map_set_init(struct bpf_map_set_msg *msg,
+				    struct sockaddr_un *addr,
+				    unsigned int addr_len)
+{
+	const unsigned int cmsg_ctl_len = sizeof(int) * BPF_SCM_MAX_FDS;
+	struct cmsghdr *cmsg;
+
+	msg->iov.iov_base = &msg->aux;
+	msg->iov.iov_len = sizeof(msg->aux);
+
+	msg->hdr.msg_iov = &msg->iov;
+	msg->hdr.msg_iovlen = 1;
+
+	msg->hdr.msg_name = (struct sockaddr *)addr;
+	msg->hdr.msg_namelen = addr_len;
+
+	BUILD_BUG_ON(sizeof(msg->msg_buf) < cmsg_ctl_len);
+	msg->hdr.msg_control = &msg->msg_buf;
+	msg->hdr.msg_controllen	= cmsg_ctl_len;
+
+	cmsg = CMSG_FIRSTHDR(&msg->hdr);
+	cmsg->cmsg_len = msg->hdr.msg_controllen;
+	cmsg->cmsg_level = SOL_SOCKET;
+	cmsg->cmsg_type	= SCM_RIGHTS;
+
+	return (int *)CMSG_DATA(cmsg);
+}
+
+static inline void bpf_map_set_init_single(struct bpf_map_set_msg *msg,
+					   int num)
+{
+	struct cmsghdr *cmsg;
+
+	msg->hdr.msg_controllen = CMSG_LEN(sizeof(int) * num);
+	msg->iov.iov_len = offsetof(struct bpf_map_aux, ent) +
+			   sizeof(struct bpf_elf_map) * num;
+
+	cmsg = CMSG_FIRSTHDR(&msg->hdr);
+	cmsg->cmsg_len = msg->hdr.msg_controllen;
+}
+
+#endif /* __BPF_SCM__ */
diff --git a/include/utils.h b/include/utils.h
index c21b59c..2277b74 100644
--- a/include/utils.h
+++ b/include/utils.h
@@ -171,6 +171,20 @@ void print_nlmsg_timestamp(FILE *fp, const struct nlmsghdr *n);
 
 #define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))
 
+#define BUILD_BUG_ON(cond) ((void)sizeof(char[1 - 2 * !!(cond)]))
+
+#ifndef offsetof
+# define offsetof(type, member) ((size_t) &((type *)0)->member)
+#endif
+
+#ifndef min
+# define min(x, y) ({			\
+	typeof(x) _min1 = (x);		\
+	typeof(y) _min2 = (y);		\
+	(void) (&_min1 == &_min2);	\
+	_min1 < _min2 ? _min1 : _min2; })
+#endif
+
 #ifndef __check_format_string
 # define __check_format_string(pos_str, pos_args) \
 	__attribute__ ((format (printf, (pos_str), (pos_args))))
diff --git a/tc/f_bpf.c b/tc/f_bpf.c
index 6d76580..8bdd602 100644
--- a/tc/f_bpf.c
+++ b/tc/f_bpf.c
@@ -14,6 +14,7 @@
 #include <unistd.h>
 #include <syslog.h>
 #include <fcntl.h>
+#include <libgen.h>
 #include <sys/socket.h>
 #include <netinet/in.h>
 #include <arpa/inet.h>
@@ -28,22 +29,36 @@
 #include "tc_util.h"
 #include "tc_bpf.h"
 
+static const enum bpf_prog_type bpf_type = BPF_PROG_TYPE_SCHED_CLS;
+
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... bpf ...\n");
 	fprintf(stderr, "\n");
-	fprintf(stderr, " [inline]:     run bytecode BPF_BYTECODE\n");
-	fprintf(stderr, " [from file]:  run bytecode-file FILE\n");
-	fprintf(stderr, " [from file]:  run object-file FILE\n");
+	fprintf(stderr, "BPF use case:\n");
+	fprintf(stderr, " bytecode BPF_BYTECODE\n");
+	fprintf(stderr, " bytecode-file FILE\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "eBPF use case:\n");
+	fprintf(stderr, " object-file FILE [ section CLS_NAME ] [ export UDS_FILE ]\n");
 	fprintf(stderr, "\n");
-	fprintf(stderr, "               [ action ACTION_SPEC ]\n");
-	fprintf(stderr, "               [ classid CLASSID ]\n");
+	fprintf(stderr, "Common remaining options:\n");
+	fprintf(stderr, " [ action ACTION_SPEC ]\n");
+	fprintf(stderr, " [ classid CLASSID ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
-	fprintf(stderr, "      c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
+	fprintf(stderr, "c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
+	fprintf(stderr, "\n");
 	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string,\n");
-	fprintf(stderr, "or an ELF file containing eBPF map definitions and bytecode.\n");
-	fprintf(stderr, "\nACTION_SPEC := ... look at individual actions\n");
+	fprintf(stderr, "an ELF file containing eBPF map definitions and bytecode.\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where CLS_NAME refers to the section name containing the\n");
+	fprintf(stderr, "classifier (default \'%s\').\n", bpf_default_section(bpf_type));
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where UDS_FILE points to a unix domain socket file in order\n");
+	fprintf(stderr, "to hand off control of all created eBPF maps to an agent.\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "ACTION_SPEC := ... look at individual actions\n");
 	fprintf(stderr, "NOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
@@ -51,8 +66,13 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 			 int argc, char **argv, struct nlmsghdr *n)
 {
 	struct tcmsg *t = NLMSG_DATA(n);
+	const char *bpf_uds_name = NULL;
+	const char *bpf_sec_name = NULL;
+	char *bpf_obj = NULL;
 	struct rtattr *tail;
+	bool seen_run = false;
 	long h = 0;
+	int ret = 0;
 
 	if (argc == 0)
 		return 0;
@@ -68,40 +88,76 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 
 	t->tcm_handle = h;
 
-	tail = (struct rtattr*)(((void*)n)+NLMSG_ALIGN(n->nlmsg_len));
+	tail = (struct rtattr *)(((void *)n) + NLMSG_ALIGN(n->nlmsg_len));
 	addattr_l(n, MAX_MSG, TCA_OPTIONS, NULL, 0);
 
 	while (argc > 0) {
 		if (matches(*argv, "run") == 0) {
-			bool from_file = true, ebpf;
 			struct sock_filter bpf_ops[BPF_MAXINSNS];
+			bool from_file, ebpf;
 			int ret;
 
 			NEXT_ARG();
-			if (strcmp(*argv, "bytecode-file") == 0) {
-				ebpf = false;
-			} else if (strcmp(*argv, "bytecode") == 0) {
+opt_bpf:
+			bpf_sec_name = bpf_default_section(bpf_type);
+			ebpf = false;
+			seen_run = true;
+
+			if (strcmp(*argv, "bytecode-file") == 0 ||
+			    strcmp(*argv, "bcf") == 0) {
+				from_file = true;
+			} else if (strcmp(*argv, "bytecode") == 0 ||
+				   strcmp(*argv, "bc") == 0) {
 				from_file = false;
-				ebpf = false;
-			} else if (strcmp(*argv, "object-file") == 0) {
+			} else if (strcmp(*argv, "object-file") == 0 ||
+				   strcmp(*argv, "obj") == 0) {
 				ebpf = true;
 			} else {
 				fprintf(stderr, "What is \"%s\"?\n", *argv);
 				explain();
 				return -1;
 			}
+
 			NEXT_ARG();
-			ret = ebpf ? bpf_open_object(*argv, BPF_PROG_TYPE_SCHED_CLS) :
-			             bpf_parse_ops(argc, argv, bpf_ops, from_file);
+			if (ebpf) {
+				bpf_obj = *argv;
+				NEXT_ARG();
+
+				if (strcmp(*argv, "section") == 0 ||
+				    strcmp(*argv, "sec") == 0) {
+					NEXT_ARG();
+					bpf_sec_name = *argv;
+					NEXT_ARG();
+				}
+				if (strcmp(*argv, "export") == 0 ||
+				    strcmp(*argv, "exp") == 0) {
+					NEXT_ARG();
+					bpf_uds_name = *argv;
+					NEXT_ARG();
+				}
+
+				PREV_ARG();
+			}
+
+			ret = ebpf ? bpf_open_object(bpf_obj, bpf_type, bpf_sec_name) :
+				     bpf_parse_ops(argc, argv, bpf_ops, from_file);
 			if (ret < 0) {
 				fprintf(stderr, "%s\n", ebpf ?
 					"Could not load object" :
 					"Illegal \"bytecode\"");
 				return -1;
 			}
+
 			if (ebpf) {
+				char bpf_name[256];
+
+				bpf_obj = basename(bpf_obj);
+
+				snprintf(bpf_name, sizeof(bpf_name), "%s:[%s]",
+					 bpf_obj, bpf_sec_name);
+
 				addattr32(n, MAX_MSG, TCA_BPF_FD, ret);
-				addattrstrz(n, MAX_MSG, TCA_BPF_NAME, *argv);
+				addattrstrz(n, MAX_MSG, TCA_BPF_NAME, bpf_name);
 			} else {
 				addattr16(n, MAX_MSG, TCA_BPF_OPS_LEN, ret);
 				addattr_l(n, MAX_MSG, TCA_BPF_OPS, &bpf_ops,
@@ -109,7 +165,8 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 			}
 		} else if (matches(*argv, "classid") == 0 ||
 			   strcmp(*argv, "flowid") == 0) {
-			unsigned handle;
+			unsigned int handle;
+
 			NEXT_ARG();
 			if (get_tc_classid(&handle, *argv)) {
 				fprintf(stderr, "Illegal \"classid\"\n");
@@ -134,15 +191,23 @@ static int bpf_parse_opt(struct filter_util *qu, char *handle,
 			explain();
 			return -1;
 		} else {
+			if (!seen_run)
+				goto opt_bpf;
+
 			fprintf(stderr, "What is \"%s\"?\n", *argv);
 			explain();
 			return -1;
 		}
-		argc--; argv++;
+		argc--;
+		argv++;
 	}
 
-	tail->rta_len = (((void*)n)+n->nlmsg_len) - (void*)tail;
-	return 0;
+	tail->rta_len = (((void *)n) + n->nlmsg_len) - (void *)tail;
+
+	if (bpf_uds_name)
+		ret = bpf_handoff_map_fds(bpf_uds_name, bpf_obj);
+
+	return ret;
 }
 
 static int bpf_print_opt(struct filter_util *qu, FILE *f,
@@ -169,9 +234,11 @@ static int bpf_print_opt(struct filter_util *qu, FILE *f,
 	else if (tb[TCA_BPF_FD])
 		fprintf(f, "pfd %u ", rta_getattr_u32(tb[TCA_BPF_FD]));
 
-	if (tb[TCA_BPF_OPS] && tb[TCA_BPF_OPS_LEN])
+	if (tb[TCA_BPF_OPS] && tb[TCA_BPF_OPS_LEN]) {
 		bpf_print_ops(f, tb[TCA_BPF_OPS],
 			      rta_getattr_u16(tb[TCA_BPF_OPS_LEN]));
+		fprintf(f, "\n");
+	}
 
 	if (tb[TCA_BPF_POLICE]) {
 		fprintf(f, "\n");
diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index bc6cc47..c817579 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -7,6 +7,7 @@
  *              2 of the License, or (at your option) any later version.
  *
  * Authors:     Jiri Pirko <jiri@resnulli.us>
+ *              Daniel Borkmann <daniel@iogearbox.net>
  */
 
 #include <stdio.h>
@@ -14,6 +15,8 @@
 #include <unistd.h>
 #include <string.h>
 #include <stdbool.h>
+#include <libgen.h>
+#include <linux/bpf.h>
 #include <linux/tc_act/tc_bpf.h>
 
 #include "utils.h"
@@ -21,16 +24,30 @@
 #include "tc_util.h"
 #include "tc_bpf.h"
 
+static const enum bpf_prog_type bpf_type = BPF_PROG_TYPE_SCHED_ACT;
+
 static void explain(void)
 {
 	fprintf(stderr, "Usage: ... bpf ...\n");
 	fprintf(stderr, "\n");
-	fprintf(stderr, " [inline]:     run bytecode BPF_BYTECODE\n");
-	fprintf(stderr, " [from file]:  run bytecode-file FILE\n");
+	fprintf(stderr, "BPF use case:\n");
+	fprintf(stderr, " bytecode BPF_BYTECODE\n");
+	fprintf(stderr, " bytecode-file FILE\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "eBPF use case:\n");
+	fprintf(stderr, " object-file FILE [ section ACT_NAME ] [ export UDS_FILE ]\n");
 	fprintf(stderr, "\n");
 	fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
-	fprintf(stderr, "      c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
-	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string\n");
+	fprintf(stderr, "c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string,\n");
+	fprintf(stderr, "an ELF file containing eBPF map definitions and bytecode.\n");
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where ACT_NAME refers to the section name containing the\n");
+	fprintf(stderr, "action (default \'%s\').\n", bpf_default_section(bpf_type));
+	fprintf(stderr, "\n");
+	fprintf(stderr, "Where UDS_FILE points to a unix domain socket file in order\n");
+	fprintf(stderr, "to hand off control of all created eBPF maps to an agent.\n");
 }
 
 static void usage(void)
@@ -42,12 +59,17 @@ static void usage(void)
 static int parse_bpf(struct action_util *a, int *argc_p, char ***argv_p,
 		     int tca_id, struct nlmsghdr *n)
 {
-	int argc = *argc_p;
-	char **argv = *argv_p;
+	char **argv = *argv_p, bpf_name[256];
 	struct rtattr *tail;
 	struct tc_act_bpf parm = { 0 };
 	struct sock_filter bpf_ops[BPF_MAXINSNS];
+	bool ebpf = false, seen_run = false;
+	const char *bpf_uds_name = NULL;
+	const char *bpf_sec_name = NULL;
+	char *bpf_obj = NULL;
+	int argc = *argc_p, ret = 0;
 	__u16 bpf_len = 0;
+	__u32 bpf_fd = 0;
 
 	if (matches(*argv, "bpf") != 0)
 		return -1;
@@ -60,25 +82,70 @@ static int parse_bpf(struct action_util *a, int *argc_p, char ***argv_p,
 			int ret;
 
 			NEXT_ARG();
-			if (strcmp(*argv, "bytecode-file") == 0) {
+opt_bpf:
+			bpf_sec_name = bpf_default_section(bpf_type);
+			seen_run = true;
+
+			if (strcmp(*argv, "bytecode-file") == 0 ||
+			    strcmp(*argv, "bcf") == 0) {
 				from_file = true;
-			} else if (strcmp(*argv, "bytecode") == 0) {
+			} else if (strcmp(*argv, "bytecode") == 0 ||
+				   strcmp(*argv, "bc") == 0) {
 				from_file = false;
+			} else if (strcmp(*argv, "object-file") == 0 ||
+				   strcmp(*argv, "obj") == 0) {
+				ebpf = true;
 			} else {
 				fprintf(stderr, "unexpected \"%s\"\n", *argv);
 				explain();
 				return -1;
 			}
+
 			NEXT_ARG();
-			ret = bpf_parse_ops(argc, argv, bpf_ops, from_file);
+			if (ebpf) {
+				bpf_obj = *argv;
+				NEXT_ARG();
+
+				if (strcmp(*argv, "section") == 0 ||
+				    strcmp(*argv, "sec") == 0) {
+					NEXT_ARG();
+					bpf_sec_name = *argv;
+					NEXT_ARG();
+				}
+				if (strcmp(*argv, "export") == 0 ||
+				    strcmp(*argv, "exp") == 0) {
+					NEXT_ARG();
+					bpf_uds_name = *argv;
+					NEXT_ARG();
+				}
+
+				PREV_ARG();
+			}
+
+			ret = ebpf ? bpf_open_object(bpf_obj, bpf_type, bpf_sec_name) :
+				     bpf_parse_ops(argc, argv, bpf_ops, from_file);
 			if (ret < 0) {
-				fprintf(stderr, "Illegal \"bytecode\"\n");
+				fprintf(stderr, "%s\n", ebpf ?
+					"Could not load object" :
+					"Illegal \"bytecode\"");
 				return -1;
 			}
-			bpf_len = ret;
+
+			if (ebpf) {
+				bpf_obj = basename(bpf_obj);
+
+				snprintf(bpf_name, sizeof(bpf_name), "%s:[%s]",
+					 bpf_obj, bpf_sec_name);
+
+				bpf_fd = ret;
+			} else {
+				bpf_len = ret;
+			}
 		} else if (matches(*argv, "help") == 0) {
 			usage();
 		} else {
+			if (!seen_run)
+				goto opt_bpf;
 			break;
 		}
 		argc--;
@@ -123,29 +190,42 @@ static int parse_bpf(struct action_util *a, int *argc_p, char ***argv_p,
 		}
 	}
 
-	if (!bpf_len) {
+	if ((!bpf_len && !ebpf) || (!bpf_fd && ebpf)) {
 		fprintf(stderr, "bpf: Bytecode needs to be passed\n");
 		explain();
 		return -1;
 	}
 
 	tail = NLMSG_TAIL(n);
+
 	addattr_l(n, MAX_MSG, tca_id, NULL, 0);
 	addattr_l(n, MAX_MSG, TCA_ACT_BPF_PARMS, &parm, sizeof(parm));
-	addattr16(n, MAX_MSG, TCA_ACT_BPF_OPS_LEN, bpf_len);
-	addattr_l(n, MAX_MSG, TCA_ACT_BPF_OPS, &bpf_ops,
-		  bpf_len * sizeof(struct sock_filter));
+
+	if (ebpf) {
+		addattr32(n, MAX_MSG, TCA_ACT_BPF_FD, bpf_fd);
+		addattrstrz(n, MAX_MSG, TCA_ACT_BPF_NAME, bpf_name);
+	} else {
+		addattr16(n, MAX_MSG, TCA_ACT_BPF_OPS_LEN, bpf_len);
+		addattr_l(n, MAX_MSG, TCA_ACT_BPF_OPS, &bpf_ops,
+			  bpf_len * sizeof(struct sock_filter));
+	}
+
 	tail->rta_len = (char *)NLMSG_TAIL(n) - (char *)tail;
 
 	*argc_p = argc;
 	*argv_p = argv;
-	return 0;
+
+	if (bpf_uds_name)
+		ret = bpf_handoff_map_fds(bpf_uds_name, bpf_obj);
+
+	return ret;
 }
 
 static int print_bpf(struct action_util *au, FILE *f, struct rtattr *arg)
 {
 	struct rtattr *tb[TCA_ACT_BPF_MAX + 1];
 	struct tc_act_bpf *parm;
+	SPRINT_BUF(action_buf);
 
 	if (arg == NULL)
 		return -1;
@@ -156,15 +236,25 @@ static int print_bpf(struct action_util *au, FILE *f, struct rtattr *arg)
 		fprintf(f, "[NULL bpf parameters]");
 		return -1;
 	}
+
 	parm = RTA_DATA(tb[TCA_ACT_BPF_PARMS]);
 
-	fprintf(f, " bpf ");
+	fprintf(f, "bpf ");
+
+	if (tb[TCA_ACT_BPF_NAME])
+		fprintf(f, "%s ", rta_getattr_str(tb[TCA_ACT_BPF_NAME]));
+	else if (tb[TCA_ACT_BPF_FD])
+		fprintf(f, "pfd %u ", rta_getattr_u32(tb[TCA_ACT_BPF_FD]));
 
-	if (tb[TCA_ACT_BPF_OPS] && tb[TCA_ACT_BPF_OPS_LEN])
+	if (tb[TCA_ACT_BPF_OPS] && tb[TCA_ACT_BPF_OPS_LEN]) {
 		bpf_print_ops(f, tb[TCA_ACT_BPF_OPS],
 			      rta_getattr_u16(tb[TCA_ACT_BPF_OPS_LEN]));
+		fprintf(f, " ");
+	}
 
-	fprintf(f, "\n\tindex %d ref %d bind %d", parm->index, parm->refcnt,
+	fprintf(f, "default-action %s\n", action_n2a(parm->action, action_buf,
+		sizeof(action_buf)));
+	fprintf(f, "\tindex %d ref %d bind %d", parm->index, parm->refcnt,
 		parm->bindcnt);
 
 	if (show_stats) {
diff --git a/tc/tc_bpf.c b/tc/tc_bpf.c
index 3778d6b..326d098 100644
--- a/tc/tc_bpf.c
+++ b/tc/tc_bpf.c
@@ -21,6 +21,7 @@
 #include <stdarg.h>
 #include <sys/types.h>
 #include <sys/stat.h>
+#include <sys/un.h>
 #include <linux/filter.h>
 #include <linux/netlink.h>
 #include <linux/rtnetlink.h>
@@ -31,6 +32,10 @@
 #endif
 
 #include "utils.h"
+
+#include "bpf_elf.h"
+#include "bpf_scm.h"
+
 #include "tc_util.h"
 #include "tc_bpf.h"
 
@@ -151,31 +156,48 @@ void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len)
 		fprintf(f, "%hu %hhu %hhu %u,", ops[i].code, ops[i].jt,
 			ops[i].jf, ops[i].k);
 
-	fprintf(f, "%hu %hhu %hhu %u\'\n", ops[i].code, ops[i].jt,
+	fprintf(f, "%hu %hhu %hhu %u\'", ops[i].code, ops[i].jt,
 		ops[i].jf, ops[i].k);
 }
 
-#ifdef HAVE_ELF
-struct bpf_elf_sec_data {
-	GElf_Shdr	sec_hdr;
-	char		*sec_name;
-	Elf_Data	*sec_data;
-};
-
-static char bpf_log_buf[8192];
-
-static const char *prog_type_section(enum bpf_prog_type type)
+const char *bpf_default_section(const enum bpf_prog_type type)
 {
 	switch (type) {
 	case BPF_PROG_TYPE_SCHED_CLS:
 		return ELF_SECTION_CLASSIFIER;
-	/* case BPF_PROG_TYPE_SCHED_ACT:   */
-	/*	return ELF_SECTION_ACTION; */
+	case BPF_PROG_TYPE_SCHED_ACT:
+		return ELF_SECTION_ACTION;
 	default:
 		return NULL;
 	}
 }
 
+#ifdef HAVE_ELF
+struct bpf_elf_sec_data {
+	GElf_Shdr sec_hdr;
+	char *sec_name;
+	Elf_Data *sec_data;
+};
+
+struct bpf_map_data {
+	int *fds;
+	const char *obj;
+	struct bpf_elf_st *st;
+	struct bpf_elf_map *ent;
+};
+
+/* If we provide a small buffer with log level enabled, the kernel
+ * could fail program load as no buffer space is available for the
+ * log and thus verifier fails. In case something doesn't pass the
+ * verifier we still want to hand something descriptive to the user.
+ */
+static char bpf_log_buf[65536];
+
+static struct bpf_elf_st bpf_st;
+
+static int map_fds[ELF_MAX_MAPS];
+static struct bpf_elf_map map_ent[ELF_MAX_MAPS];
+
 static void bpf_dump_error(const char *format, ...)  __check_format_string(1, 2);
 static void bpf_dump_error(const char *format, ...)
 {
@@ -185,10 +207,49 @@ static void bpf_dump_error(const char *format, ...)
 	vfprintf(stderr, format, vl);
 	va_end(vl);
 
-	fprintf(stderr, "%s", bpf_log_buf);
+	fprintf(stderr, "%s\n", bpf_log_buf);
 	memset(bpf_log_buf, 0, sizeof(bpf_log_buf));
 }
 
+static void bpf_save_finfo(int file_fd)
+{
+	struct stat st;
+	int ret;
+
+	memset(&bpf_st, 0, sizeof(bpf_st));
+
+	ret = fstat(file_fd, &st);
+	if (ret < 0) {
+		fprintf(stderr, "Stat of elf file failed: %s\n",
+			strerror(errno));
+		return;
+	}
+
+	bpf_st.st_dev = st.st_dev;
+	bpf_st.st_ino = st.st_ino;
+}
+
+static void bpf_clear_finfo(void)
+{
+	memset(&bpf_st, 0, sizeof(bpf_st));
+}
+
+static bool bpf_may_skip_map_creation(int file_fd)
+{
+	struct stat st;
+	int ret;
+
+	ret = fstat(file_fd, &st);
+	if (ret < 0) {
+		fprintf(stderr, "Stat of elf file failed: %s\n",
+			strerror(errno));
+		return false;
+	}
+
+	return (bpf_st.st_dev == st.st_dev) &&
+	       (bpf_st.st_ino == st.st_ino);
+}
+
 static int bpf_create_map(enum bpf_map_type type, unsigned int size_key,
 			  unsigned int size_value, unsigned int max_elem)
 {
@@ -240,30 +301,44 @@ static int bpf_map_attach(enum bpf_map_type type, unsigned int size_key,
 	return map_fd;
 }
 
-static void bpf_maps_init(int *map_fds, unsigned int max_fds)
+static void bpf_maps_init(void)
 {
 	int i;
 
-	for (i = 0; i < max_fds; i++)
+	memset(map_ent, 0, sizeof(map_ent));
+	for (i = 0; i < ARRAY_SIZE(map_fds); i++)
 		map_fds[i] = -1;
 }
 
-static void bpf_maps_destroy(const int *map_fds, unsigned int max_fds)
+static int bpf_maps_count(void)
+{
+	int i, count = 0;
+
+	for (i = 0; i < ARRAY_SIZE(map_fds); i++) {
+		if (map_fds[i] < 0)
+			break;
+		count++;
+	}
+
+	return count;
+}
+
+static void bpf_maps_destroy(void)
 {
 	int i;
 
-	for (i = 0; i < max_fds; i++) {
+	memset(map_ent, 0, sizeof(map_ent));
+	for (i = 0; i < ARRAY_SIZE(map_fds); i++) {
 		if (map_fds[i] >= 0)
 			close(map_fds[i]);
 	}
 }
 
-static int bpf_maps_attach(struct bpf_elf_map *maps, unsigned int num_maps,
-			   int *map_fds, unsigned int max_fds)
+static int bpf_maps_attach(struct bpf_elf_map *maps, unsigned int num_maps)
 {
 	int i, ret;
 
-	for (i = 0; i < num_maps && num_maps <= max_fds; i++) {
+	for (i = 0; (i < num_maps) && (num_maps <= ARRAY_SIZE(map_fds)); i++) {
 		struct bpf_elf_map *map = &maps[i];
 
 		ret = bpf_map_attach(map->type, map->size_key,
@@ -277,7 +352,7 @@ static int bpf_maps_attach(struct bpf_elf_map *maps, unsigned int num_maps,
 	return 0;
 
 err_unwind:
-	bpf_maps_destroy(map_fds, i);
+	bpf_maps_destroy();
 	return ret;
 }
 
@@ -316,7 +391,7 @@ static int bpf_fill_section_data(Elf *elf_fd, GElf_Ehdr *elf_hdr, int sec_index,
 
 static int bpf_apply_relo_data(struct bpf_elf_sec_data *data_relo,
 			       struct bpf_elf_sec_data *data_insn,
-			       Elf_Data *sym_tab, int *map_fds, int max_fds)
+			       Elf_Data *sym_tab)
 {
 	Elf_Data *idata = data_insn->sec_data;
 	GElf_Shdr *rhdr = &data_relo->sec_hdr;
@@ -342,7 +417,9 @@ static int bpf_apply_relo_data(struct bpf_elf_sec_data *data_relo,
 			return -EIO;
 
 		fnum = sym.st_value / sizeof(struct bpf_elf_map);
-		if (fnum >= max_fds)
+		if (fnum >= ARRAY_SIZE(map_fds))
+			return -EINVAL;
+		if (map_fds[fnum] < 0)
 			return -EINVAL;
 
 		insns[ioff].src_reg = BPF_PSEUDO_MAP_FD;
@@ -352,9 +429,8 @@ static int bpf_apply_relo_data(struct bpf_elf_sec_data *data_relo,
 	return 0;
 }
 
-static int bpf_fetch_ancillary(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
-			       int *map_fds, unsigned int max_fds,
-			       char *license, unsigned int lic_len,
+static int bpf_fetch_ancillary(int file_fd, Elf *elf_fd, GElf_Ehdr *elf_hdr,
+			       bool *sec_seen, char *license, unsigned int lic_len,
 			       Elf_Data **sym_tab)
 {
 	int sec_index, ret = -1;
@@ -368,14 +444,20 @@ static int bpf_fetch_ancillary(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 			continue;
 
 		/* Extract and load eBPF map fds. */
-		if (!strcmp(data_anc.sec_name, ELF_SECTION_MAPS)) {
-			struct bpf_elf_map *maps = data_anc.sec_data->d_buf;
-			unsigned int maps_num = data_anc.sec_data->d_size /
-						sizeof(*maps);
+		if (!strcmp(data_anc.sec_name, ELF_SECTION_MAPS) &&
+		    !bpf_may_skip_map_creation(file_fd)) {
+			struct bpf_elf_map *maps;
+			unsigned int maps_num;
+
+			if (data_anc.sec_data->d_size % sizeof(*maps) != 0)
+				return -EINVAL;
+
+			maps = data_anc.sec_data->d_buf;
+			maps_num = data_anc.sec_data->d_size / sizeof(*maps);
+			memcpy(map_ent, maps, data_anc.sec_data->d_size);
 
 			sec_seen[sec_index] = true;
-			ret = bpf_maps_attach(maps, maps_num, map_fds,
-					      max_fds);
+			ret = bpf_maps_attach(maps, maps_num);
 			if (ret < 0)
 				return ret;
 		}
@@ -399,8 +481,8 @@ static int bpf_fetch_ancillary(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 }
 
 static int bpf_fetch_prog_relo(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
-			       enum bpf_prog_type type, char *license,
-			       Elf_Data *sym_tab, int *map_fds, unsigned int max_fds)
+			       enum bpf_prog_type type, const char *sec,
+			       const char *license, Elf_Data *sym_tab)
 {
 	int sec_index, prog_fd = -1;
 
@@ -420,14 +502,13 @@ static int bpf_fetch_prog_relo(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 					    &data_insn);
 		if (ret < 0)
 			continue;
-		if (strcmp(data_insn.sec_name, prog_type_section(type)))
+		if (strcmp(data_insn.sec_name, sec))
 			continue;
 
 		sec_seen[sec_index] = true;
 		sec_seen[ins_index] = true;
 
-		ret = bpf_apply_relo_data(&data_relo, &data_insn, sym_tab,
-					  map_fds, max_fds);
+		ret = bpf_apply_relo_data(&data_relo, &data_insn, sym_tab);
 		if (ret < 0)
 			continue;
 
@@ -443,7 +524,8 @@ static int bpf_fetch_prog_relo(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 }
 
 static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
-			  enum bpf_prog_type type, char *license)
+			  enum bpf_prog_type type, const char *sec,
+			  const char *license)
 {
 	int sec_index, prog_fd = -1;
 
@@ -459,7 +541,7 @@ static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 					    &data_insn);
 		if (ret < 0)
 			continue;
-		if (strcmp(data_insn.sec_name, prog_type_section(type)))
+		if (strcmp(data_insn.sec_name, sec))
 			continue;
 
 		prog_fd = bpf_prog_attach(type, data_insn.sec_data->d_buf,
@@ -473,9 +555,8 @@ static int bpf_fetch_prog(Elf *elf_fd, GElf_Ehdr *elf_hdr, bool *sec_seen,
 	return prog_fd;
 }
 
-int bpf_open_object(const char *path, enum bpf_prog_type type)
+int bpf_open_object(const char *path, enum bpf_prog_type type, const char *sec)
 {
-	int map_fds[ELF_MAX_MAPS], max_fds = ARRAY_SIZE(map_fds);
 	char license[ELF_MAX_LICENSE_LEN];
 	int file_fd, prog_fd = -1, ret;
 	Elf_Data *sym_tab = NULL;
@@ -508,31 +589,119 @@ int bpf_open_object(const char *path, enum bpf_prog_type type)
 	}
 
 	memset(license, 0, sizeof(license));
-	bpf_maps_init(map_fds, max_fds);
+	if (!bpf_may_skip_map_creation(file_fd))
+		bpf_maps_init();
 
-	ret = bpf_fetch_ancillary(elf_fd, &elf_hdr, sec_seen, map_fds, max_fds,
+	ret = bpf_fetch_ancillary(file_fd, elf_fd, &elf_hdr, sec_seen,
 				  license, sizeof(license), &sym_tab);
 	if (ret < 0)
 		goto out_maps;
 	if (sym_tab)
 		prog_fd = bpf_fetch_prog_relo(elf_fd, &elf_hdr, sec_seen, type,
-					      license, sym_tab, map_fds, max_fds);
+					      sec, license, sym_tab);
 	if (prog_fd < 0)
-		prog_fd = bpf_fetch_prog(elf_fd, &elf_hdr, sec_seen, type,
+		prog_fd = bpf_fetch_prog(elf_fd, &elf_hdr, sec_seen, type, sec,
 					 license);
 	if (prog_fd < 0)
 		goto out_maps;
-out_sec:
+
+	bpf_save_finfo(file_fd);
+
+	free(sec_seen);
+
+	elf_end(elf_fd);
+	close(file_fd);
+
+	return prog_fd;
+
+out_maps:
+	bpf_maps_destroy();
 	free(sec_seen);
 out_elf:
 	elf_end(elf_fd);
 out:
 	close(file_fd);
+	bpf_clear_finfo();
 	return prog_fd;
+}
 
-out_maps:
-	bpf_maps_destroy(map_fds, max_fds);
-	goto out_sec;
+static int
+bpf_map_set_xmit(int fd, struct sockaddr_un *addr, unsigned int addr_len,
+		 const struct bpf_map_data *aux, unsigned int ents)
+{
+	struct bpf_map_set_msg msg;
+	int *cmsg_buf, min_fd;
+	char *amsg_buf;
+	int i;
+
+	memset(&msg, 0, sizeof(msg));
+
+	msg.aux.uds_ver = BPF_SCM_AUX_VER;
+	msg.aux.num_ent = ents;
+
+	strncpy(msg.aux.obj_name, aux->obj, sizeof(msg.aux.obj_name));
+	memcpy(&msg.aux.obj_st, aux->st, sizeof(msg.aux.obj_st));
+
+	cmsg_buf = bpf_map_set_init(&msg, addr, addr_len);
+	amsg_buf = (char *)msg.aux.ent;
+
+	for (i = 0; i < ents; i += min_fd) {
+		int ret;
+
+		min_fd = min(BPF_SCM_MAX_FDS * 1U, ents - i);
+
+		bpf_map_set_init_single(&msg, min_fd);
+
+		memcpy(cmsg_buf, &aux->fds[i], sizeof(aux->fds[0]) * min_fd);
+		memcpy(amsg_buf, &aux->ent[i], sizeof(aux->ent[0]) * min_fd);
+
+		ret = sendmsg(fd, &msg.hdr, 0);
+		if (ret <= 0)
+			return ret ? : -1;
+	}
+
+	return 0;
 }
 
+int bpf_handoff_map_fds(const char *path, const char *obj)
+{
+	struct sockaddr_un addr;
+	struct bpf_map_data bpf_aux;
+	int fd, ret;
+
+	fd = socket(AF_UNIX, SOCK_DGRAM, 0);
+	if (fd < 0) {
+		fprintf(stderr, "Cannot open socket: %s\n",
+			strerror(errno));
+		return -1;
+	}
+
+	memset(&addr, 0, sizeof(addr));
+	addr.sun_family = AF_UNIX;
+	strncpy(addr.sun_path, path, sizeof(addr.sun_path));
+
+	ret = connect(fd, (struct sockaddr *)&addr, sizeof(addr));
+	if (ret < 0) {
+		fprintf(stderr, "Cannot connect to %s: %s\n",
+			path, strerror(errno));
+		return -1;
+	}
+
+	memset(&bpf_aux, 0, sizeof(bpf_aux));
+
+	bpf_aux.fds = map_fds;
+	bpf_aux.ent = map_ent;
+
+	bpf_aux.obj = obj;
+	bpf_aux.st = &bpf_st;
+
+	ret = bpf_map_set_xmit(fd, &addr, sizeof(addr), &bpf_aux,
+			       bpf_maps_count());
+	if (ret < 0)
+		fprintf(stderr, "Cannot xmit fds to %s: %s\n",
+			path, strerror(errno));
+
+	close(fd);
+	return ret;
+}
 #endif /* HAVE_ELF */
diff --git a/tc/tc_bpf.h b/tc/tc_bpf.h
index ce64747..8b214b8 100644
--- a/tc/tc_bpf.h
+++ b/tc/tc_bpf.h
@@ -24,32 +24,6 @@
 
 #include "utils.h"
 
-/* Note:
- *
- * Below ELF section names and bpf_elf_map structure definition
- * are not (!) kernel ABI. It's rather a "contract" between the
- * application and the BPF loader in tc. For compatibility, the
- * section names should stay as-is. Introduction of aliases, if
- * needed, are a possibility, though.
- */
-
-/* ELF section names, etc */
-#define ELF_SECTION_LICENSE	"license"
-#define ELF_SECTION_MAPS	"maps"
-#define ELF_SECTION_CLASSIFIER	"classifier"
-#define ELF_SECTION_ACTION	"action"
-
-#define ELF_MAX_MAPS		64
-#define ELF_MAX_LICENSE_LEN	128
-
-/* ELF map definition */
-struct bpf_elf_map {
-	__u32 type;
-	__u32 size_key;
-	__u32 size_value;
-	__u32 max_elem;
-};
-
 int bpf_parse_string(char *arg, bool from_file, __u16 *bpf_len,
 		     char **bpf_string, bool *need_release,
 		     const char separator);
@@ -57,28 +31,40 @@ int bpf_parse_ops(int argc, char **argv, struct sock_filter *bpf_ops,
 		  bool from_file);
 void bpf_print_ops(FILE *f, struct rtattr *bpf_ops, __u16 len);
 
+const char *bpf_default_section(const enum bpf_prog_type type);
+
+#ifdef HAVE_ELF
+int bpf_open_object(const char *path, enum bpf_prog_type type,
+		    const char *sec);
+int bpf_handoff_map_fds(const char *path, const char *obj);
+
 static inline __u64 bpf_ptr_to_u64(const void *ptr)
 {
 	return (__u64) (unsigned long) ptr;
 }
 
-#ifdef HAVE_ELF
-int bpf_open_object(const char *path, enum bpf_prog_type type);
-
 static inline int bpf(int cmd, union bpf_attr *attr, unsigned int size)
 {
 #ifdef __NR_bpf
 	return syscall(__NR_bpf, cmd, attr, size);
 #else
+	fprintf(stderr, "No bpf syscall, kernel headers too old?\n");
 	errno = ENOSYS;
 	return -1;
 #endif
 }
 #else
-static inline int bpf_open_object(const char *path, enum bpf_prog_type type)
+static inline int bpf_open_object(const char *path, enum bpf_prog_type type,
+				  const char *sec)
 {
+	fprintf(stderr, "No ELF library support compiled in.\n");
 	errno = ENOSYS;
 	return -1;
 }
+
+static inline int bpf_handoff_map_fds(const char *path, const char *obj)
+{
+	return 0;
+}
 #endif /* HAVE_ELF */
 #endif /* _TC_BPF_H_ */
-- 
1.9.3
