From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 19/29] samples/bpf: Make samples more libbpf-centric
Date: Tue, 20 Dec 2016 14:03:48 -0300
Message-ID: <20161220170358.4350-20-acme@kernel.org>
References: <20161220170358.4350-1-acme@kernel.org>
Cc: linux-kernel@vger.kernel.org, Joe Stringer <joe@ovn.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161220170358.4350-1-acme@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Stringer <joe@ovn.org>

Switch all of the sample code to use the function names from
tools/lib/bpf so that they're consistent with that, and to declare their
own log buffers. This allow the next commit to be purely devoted to
getting rid of the duplicate library in samples/bpf.

Committer notes:

Testing it:

On a fedora rawhide container, with clang/llvm 3.9, sharing the host
linux kernel git tree:

  # make O=/tmp/build/linux/ headers_install
  # make O=/tmp/build/linux -C samples/bpf/

Since I forgot to make it privileged, just tested it outside the
container, using what it generated:

  # uname -a
  Linux jouet 4.9.0-rc8+ #1 SMP Mon Dec 12 11:20:49 BRT 2016 x86_64 x86_64 x86_64 GNU/Linux
  # cd /var/lib/docker/devicemapper/mnt/c43e09a53ff56c86a07baf79847f00e2cc2a17a1e2220e1adbf8cbc62734feda/rootfs/tmp/build/linux/samples/bpf/
  # ls -la offwaketime
  -rwxr-xr-x. 1 root root 24200 Dec 15 12:19 offwaketime
  # file offwaketime
  offwaketime: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=c940d3f127d5e66cdd680e42d885cb0b64f8a0e4, not stripped
  # readelf -SW offwaketime_kern.o  | grep PROGBITS
  [ 2] .text             PROGBITS        0000000000000000 000040 000000 00  AX  0   0  4
  [ 3] kprobe/try_to_wake_up PROGBITS        0000000000000000 000040 0000d8 00  AX  0   0  8
  [ 5] tracepoint/sched/sched_switch PROGBITS        0000000000000000 000118 000318 00  AX  0   0  8
  [ 7] maps              PROGBITS        0000000000000000 000430 000050 00  WA  0   0  4
  [ 8] license           PROGBITS        0000000000000000 000480 000004 00  WA  0   0  1
  [ 9] version           PROGBITS        0000000000000000 000484 000004 00  WA  0   0  4
  # ./offwaketime | head -5
  swapper/1;start_secondary;cpu_startup_entry;schedule_preempt_disabled;schedule;__schedule;-;---;; 106
  CPU 0/KVM;entry_SYSCALL_64_fastpath;sys_ioctl;do_vfs_ioctl;kvm_vcpu_ioctl;kvm_arch_vcpu_ioctl_run;kvm_vcpu_block;schedule;__schedule;-;try_to_wake_up;swake_up_locked;swake_up;apic_timer_expired;apic_timer_fn;__hrtimer_run_queues;hrtimer_interrupt;local_apic_timer_interrupt;smp_apic_timer_interrupt;__irqentry_text_start;cpuidle_enter;call_cpuidle;cpu_startup_entry;start_secondary;;swapper/3 2
  Compositor;entry_SYSCALL_64_fastpath;sys_futex;do_futex;futex_wait;futex_wait_queue_me;schedule;__schedule;-;try_to_wake_up;futex_requeue;do_futex;sys_futex;entry_SYSCALL_64_fastpath;;SoftwareVsyncTh 5
  firefox;entry_SYSCALL_64_fastpath;sys_poll;do_sys_poll;poll_schedule_timeout;schedule_hrtimeout_range;schedule_hrtimeout_range_clock;schedule;__schedule;-;try_to_wake_up;pollwake;__wake_up_common;__wake_up_sync_key;pipe_write;__vfs_write;vfs_write;sys_write;entry_SYSCALL_64_fastpath;;Timer 13
  JS Helper;entry_SYSCALL_64_fastpath;sys_futex;do_futex;futex_wait;futex_wait_queue_me;schedule;__schedule;-;try_to_wake_up;do_futex;sys_futex;entry_SYSCALL_64_fastpath;;firefox 2
  #

Signed-off-by: Joe Stringer <joe@ovn.org>
Tested-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20161214224342.12858-2-joe@ovn.org
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 samples/bpf/bpf_load.c                            | 17 +++++++++---
 samples/bpf/bpf_load.h                            |  3 +++
 samples/bpf/fds_example.c                         |  9 ++++---
 samples/bpf/lathist_user.c                        |  2 +-
 samples/bpf/libbpf.c                              | 23 ++++++++--------
 samples/bpf/libbpf.h                              | 18 ++++++-------
 samples/bpf/lwt_len_hist_user.c                   |  6 +++--
 samples/bpf/offwaketime_user.c                    |  8 +++---
 samples/bpf/sampleip_user.c                       |  4 +--
 samples/bpf/sock_example.c                        | 12 +++++----
 samples/bpf/sockex1_user.c                        |  6 ++---
 samples/bpf/sockex2_user.c                        |  4 +--
 samples/bpf/sockex3_user.c                        |  4 +--
 samples/bpf/spintest_user.c                       |  8 +++---
 samples/bpf/tc_l2_redirect_user.c                 |  4 +--
 samples/bpf/test_cgrp2_array_pin.c                |  4 +--
 samples/bpf/test_cgrp2_attach.c                   | 11 +++++---
 samples/bpf/test_cgrp2_attach2.c                  |  7 +++--
 samples/bpf/test_cgrp2_sock.c                     |  6 +++--
 samples/bpf/test_current_task_under_cgroup_user.c |  8 +++---
 samples/bpf/test_lru_dist.c                       | 32 +++++++++++------------
 samples/bpf/test_probe_write_user_user.c          |  2 +-
 samples/bpf/trace_event_user.c                    | 14 +++++-----
 samples/bpf/trace_output_user.c                   |  2 +-
 samples/bpf/tracex2_user.c                        | 10 +++----
 samples/bpf/tracex3_user.c                        |  4 +--
 samples/bpf/tracex4_user.c                        |  4 +--
 samples/bpf/tracex6_user.c                        |  2 +-
 samples/bpf/xdp1_user.c                           |  2 +-
 samples/bpf/xdp_tx_iptunnel_user.c                |  6 ++---
 30 files changed, 133 insertions(+), 109 deletions(-)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index e30b6de94f2e..f5b186c46b7c 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -22,7 +22,6 @@
 #include <poll.h>
 #include <ctype.h>
 #include "libbpf.h"
-#include "bpf_helpers.h"
 #include "bpf_load.h"
 
 #define DEBUGFS "/sys/kernel/debug/tracing/"
@@ -30,17 +29,26 @@
 static char license[128];
 static int kern_version;
 static bool processed_sec[128];
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
 int map_fd[MAX_MAPS];
 int prog_fd[MAX_PROGS];
 int event_fd[MAX_PROGS];
 int prog_cnt;
 int prog_array_fd = -1;
 
+struct bpf_map_def {
+	unsigned int type;
+	unsigned int key_size;
+	unsigned int value_size;
+	unsigned int max_entries;
+	unsigned int map_flags;
+};
+
 static int populate_prog_array(const char *event, int prog_fd)
 {
 	int ind = atoi(event), err;
 
-	err = bpf_update_elem(prog_array_fd, &ind, &prog_fd, BPF_ANY);
+	err = bpf_map_update_elem(prog_array_fd, &ind, &prog_fd, BPF_ANY);
 	if (err < 0) {
 		printf("failed to store prog_fd in prog_array\n");
 		return -1;
@@ -87,9 +95,10 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		return -1;
 	}
 
-	fd = bpf_prog_load(prog_type, prog, size, license, kern_version);
+	fd = bpf_load_program(prog_type, prog, size, license, kern_version,
+			      bpf_log_buf, BPF_LOG_BUF_SIZE);
 	if (fd < 0) {
-		printf("bpf_prog_load() err=%d\n%s", errno, bpf_log_buf);
+		printf("bpf_load_program() err=%d\n%s", errno, bpf_log_buf);
 		return -1;
 	}
 
diff --git a/samples/bpf/bpf_load.h b/samples/bpf/bpf_load.h
index fb46a421ab41..c827827299b3 100644
--- a/samples/bpf/bpf_load.h
+++ b/samples/bpf/bpf_load.h
@@ -1,12 +1,15 @@
 #ifndef __BPF_LOAD_H
 #define __BPF_LOAD_H
 
+#include "libbpf.h"
+
 #define MAX_MAPS 32
 #define MAX_PROGS 32
 
 extern int map_fd[MAX_MAPS];
 extern int prog_fd[MAX_PROGS];
 extern int event_fd[MAX_PROGS];
+extern char bpf_log_buf[BPF_LOG_BUF_SIZE];
 extern int prog_cnt;
 
 /* parses elf file compiled by llvm .c->.o
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index 625e797be6ef..8a4fc4ef3993 100644
--- a/samples/bpf/fds_example.c
+++ b/samples/bpf/fds_example.c
@@ -58,8 +58,9 @@ static int bpf_prog_create(const char *object)
 		assert(!load_bpf_file((char *)object));
 		return prog_fd[0];
 	} else {
-		return bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER,
-				     insns, sizeof(insns), "GPL", 0);
+		return bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER,
+					insns, sizeof(insns), "GPL", 0,
+					bpf_log_buf, BPF_LOG_BUF_SIZE);
 	}
 }
 
@@ -83,12 +84,12 @@ static int bpf_do_map(const char *file, uint32_t flags, uint32_t key,
 	}
 
 	if ((flags & BPF_F_KEY_VAL) == BPF_F_KEY_VAL) {
-		ret = bpf_update_elem(fd, &key, &value, 0);
+		ret = bpf_map_update_elem(fd, &key, &value, 0);
 		printf("bpf: fd:%d u->(%u:%u) ret:(%d,%s)\n", fd, key, value,
 		       ret, strerror(errno));
 		assert(ret == 0);
 	} else if (flags & BPF_F_KEY) {
-		ret = bpf_lookup_elem(fd, &key, &value);
+		ret = bpf_map_lookup_elem(fd, &key, &value);
 		printf("bpf: fd:%d l->(%u):%u ret:(%d,%s)\n", fd, key, value,
 		       ret, strerror(errno));
 		assert(ret == 0);
diff --git a/samples/bpf/lathist_user.c b/samples/bpf/lathist_user.c
index 65da8c1576de..6477bad5b4e2 100644
--- a/samples/bpf/lathist_user.c
+++ b/samples/bpf/lathist_user.c
@@ -73,7 +73,7 @@ static void get_data(int fd)
 	for (c = 0; c < MAX_CPU; c++) {
 		for (i = 0; i < MAX_ENTRIES; i++) {
 			key = c * MAX_ENTRIES + i;
-			bpf_lookup_elem(fd, &key, &value);
+			bpf_map_lookup_elem(fd, &key, &value);
 
 			cpu_hist[c].data[i] = value;
 			if (value > cpu_hist[c].max)
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 9ce707bf02a7..6f076abdca35 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -32,7 +32,7 @@ int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 	return syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
 }
 
-int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags)
+int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
@@ -44,7 +44,7 @@ int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags)
 	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_lookup_elem(int fd, void *key, void *value)
+int bpf_map_lookup_elem(int fd, void *key, void *value)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
@@ -55,7 +55,7 @@ int bpf_lookup_elem(int fd, void *key, void *value)
 	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_delete_elem(int fd, void *key)
+int bpf_map_delete_elem(int fd, void *key)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
@@ -65,7 +65,7 @@ int bpf_delete_elem(int fd, void *key)
 	return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
 }
 
-int bpf_get_next_key(int fd, void *key, void *next_key)
+int bpf_map_get_next_key(int fd, void *key, void *next_key)
 {
 	union bpf_attr attr = {
 		.map_fd = fd,
@@ -78,19 +78,18 @@ int bpf_get_next_key(int fd, void *key, void *next_key)
 
 #define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
 
-char bpf_log_buf[LOG_BUF_SIZE];
-
-int bpf_prog_load(enum bpf_prog_type prog_type,
-		  const struct bpf_insn *insns, int prog_len,
-		  const char *license, int kern_version)
+int bpf_load_program(enum bpf_prog_type prog_type,
+		     const struct bpf_insn *insns, int prog_len,
+		     const char *license, int kern_version,
+		     char *log_buf, size_t log_buf_sz)
 {
 	union bpf_attr attr = {
 		.prog_type = prog_type,
 		.insns = ptr_to_u64((void *) insns),
 		.insn_cnt = prog_len / sizeof(struct bpf_insn),
 		.license = ptr_to_u64((void *) license),
-		.log_buf = ptr_to_u64(bpf_log_buf),
-		.log_size = LOG_BUF_SIZE,
+		.log_buf = ptr_to_u64(log_buf),
+		.log_size = log_buf_sz,
 		.log_level = 1,
 	};
 
@@ -99,7 +98,7 @@ int bpf_prog_load(enum bpf_prog_type prog_type,
 	 */
 	attr.kern_version = kern_version;
 
-	bpf_log_buf[0] = 0;
+	log_buf[0] = 0;
 
 	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
 }
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 94a901d86fc2..20e3457857ca 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -6,14 +6,15 @@ struct bpf_insn;
 
 int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
 		   int max_entries, int map_flags);
-int bpf_update_elem(int fd, void *key, void *value, unsigned long long flags);
-int bpf_lookup_elem(int fd, void *key, void *value);
-int bpf_delete_elem(int fd, void *key);
-int bpf_get_next_key(int fd, void *key, void *next_key);
+int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags);
+int bpf_map_lookup_elem(int fd, void *key, void *value);
+int bpf_map_delete_elem(int fd, void *key);
+int bpf_map_get_next_key(int fd, void *key, void *next_key);
 
-int bpf_prog_load(enum bpf_prog_type prog_type,
-		  const struct bpf_insn *insns, int insn_len,
-		  const char *license, int kern_version);
+int bpf_load_program(enum bpf_prog_type prog_type,
+		     const struct bpf_insn *insns, int insn_len,
+		     const char *license, int kern_version,
+		     char *log_buf, size_t log_buf_sz);
 
 int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type);
 int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
@@ -21,8 +22,7 @@ int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
 int bpf_obj_pin(int fd, const char *pathname);
 int bpf_obj_get(const char *pathname);
 
-#define LOG_BUF_SIZE (256 * 1024)
-extern char bpf_log_buf[LOG_BUF_SIZE];
+#define BPF_LOG_BUF_SIZE (256 * 1024)
 
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
 
diff --git a/samples/bpf/lwt_len_hist_user.c b/samples/bpf/lwt_len_hist_user.c
index 05d783fc5daf..ec8f3bbcbef3 100644
--- a/samples/bpf/lwt_len_hist_user.c
+++ b/samples/bpf/lwt_len_hist_user.c
@@ -14,6 +14,8 @@
 #define MAX_INDEX 64
 #define MAX_STARS 38
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static void stars(char *str, long val, long max, int width)
 {
 	int i;
@@ -41,13 +43,13 @@ int main(int argc, char **argv)
 		return -1;
 	}
 
-	while (bpf_get_next_key(map_fd, &key, &next_key) == 0) {
+	while (bpf_map_get_next_key(map_fd, &key, &next_key) == 0) {
 		if (next_key >= MAX_INDEX) {
 			fprintf(stderr, "Key %lu out of bounds\n", next_key);
 			continue;
 		}
 
-		bpf_lookup_elem(map_fd, &next_key, values);
+		bpf_map_lookup_elem(map_fd, &next_key, values);
 
 		sum = 0;
 		for (i = 0; i < nr_cpus; i++)
diff --git a/samples/bpf/offwaketime_user.c b/samples/bpf/offwaketime_user.c
index 6f002a9c24fa..9cce2a66bd66 100644
--- a/samples/bpf/offwaketime_user.c
+++ b/samples/bpf/offwaketime_user.c
@@ -49,14 +49,14 @@ static void print_stack(struct key_t *key, __u64 count)
 	int i;
 
 	printf("%s;", key->target);
-	if (bpf_lookup_elem(map_fd[3], &key->tret, ip) != 0) {
+	if (bpf_map_lookup_elem(map_fd[3], &key->tret, ip) != 0) {
 		printf("---;");
 	} else {
 		for (i = PERF_MAX_STACK_DEPTH - 1; i >= 0; i--)
 			print_ksym(ip[i]);
 	}
 	printf("-;");
-	if (bpf_lookup_elem(map_fd[3], &key->wret, ip) != 0) {
+	if (bpf_map_lookup_elem(map_fd[3], &key->wret, ip) != 0) {
 		printf("---;");
 	} else {
 		for (i = 0; i < PERF_MAX_STACK_DEPTH; i++)
@@ -77,8 +77,8 @@ static void print_stacks(int fd)
 	struct key_t key = {}, next_key;
 	__u64 value;
 
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
-		bpf_lookup_elem(fd, &next_key, &value);
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_map_lookup_elem(fd, &next_key, &value);
 		print_stack(&next_key, value);
 		key = next_key;
 	}
diff --git a/samples/bpf/sampleip_user.c b/samples/bpf/sampleip_user.c
index 260a6bdd6413..5ac5adf75931 100644
--- a/samples/bpf/sampleip_user.c
+++ b/samples/bpf/sampleip_user.c
@@ -95,8 +95,8 @@ static void print_ip_map(int fd)
 
 	/* fetch IPs and counts */
 	key = 0, i = 0;
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
-		bpf_lookup_elem(fd, &next_key, &value);
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_map_lookup_elem(fd, &next_key, &value);
 		counts[i].ip = next_key;
 		counts[i++].count = value;
 		key = next_key;
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
index 28b60baa9fa8..d6b91e9a38ad 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -28,6 +28,8 @@
 #include <stddef.h>
 #include "libbpf.h"
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static int test_sock(void)
 {
 	int sock = -1, map_fd, prog_fd, i, key;
@@ -55,8 +57,8 @@ static int test_sock(void)
 		BPF_EXIT_INSN(),
 	};
 
-	prog_fd = bpf_prog_load(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
-				"GPL", 0);
+	prog_fd = bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
+				   "GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
 	if (prog_fd < 0) {
 		printf("failed to load prog '%s'\n", strerror(errno));
 		goto cleanup;
@@ -72,13 +74,13 @@ static int test_sock(void)
 
 	for (i = 0; i < 10; i++) {
 		key = IPPROTO_TCP;
-		assert(bpf_lookup_elem(map_fd, &key, &tcp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &key, &tcp_cnt) == 0);
 
 		key = IPPROTO_UDP;
-		assert(bpf_lookup_elem(map_fd, &key, &udp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &key, &udp_cnt) == 0);
 
 		key = IPPROTO_ICMP;
-		assert(bpf_lookup_elem(map_fd, &key, &icmp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &key, &icmp_cnt) == 0);
 
 		printf("TCP %lld UDP %lld ICMP %lld packets\n",
 		       tcp_cnt, udp_cnt, icmp_cnt);
diff --git a/samples/bpf/sockex1_user.c b/samples/bpf/sockex1_user.c
index 678ce4693551..9454448bf198 100644
--- a/samples/bpf/sockex1_user.c
+++ b/samples/bpf/sockex1_user.c
@@ -32,13 +32,13 @@ int main(int ac, char **argv)
 		int key;
 
 		key = IPPROTO_TCP;
-		assert(bpf_lookup_elem(map_fd[0], &key, &tcp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd[0], &key, &tcp_cnt) == 0);
 
 		key = IPPROTO_UDP;
-		assert(bpf_lookup_elem(map_fd[0], &key, &udp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd[0], &key, &udp_cnt) == 0);
 
 		key = IPPROTO_ICMP;
-		assert(bpf_lookup_elem(map_fd[0], &key, &icmp_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd[0], &key, &icmp_cnt) == 0);
 
 		printf("TCP %lld UDP %lld ICMP %lld bytes\n",
 		       tcp_cnt, udp_cnt, icmp_cnt);
diff --git a/samples/bpf/sockex2_user.c b/samples/bpf/sockex2_user.c
index 8a4085c2d117..6a40600d5a83 100644
--- a/samples/bpf/sockex2_user.c
+++ b/samples/bpf/sockex2_user.c
@@ -39,8 +39,8 @@ int main(int ac, char **argv)
 		int key = 0, next_key;
 		struct pair value;
 
-		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
-			bpf_lookup_elem(map_fd[0], &next_key, &value);
+		while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_map_lookup_elem(map_fd[0], &next_key, &value);
 			printf("ip %s bytes %lld packets %lld\n",
 			       inet_ntoa((struct in_addr){htonl(next_key)}),
 			       value.bytes, value.packets);
diff --git a/samples/bpf/sockex3_user.c b/samples/bpf/sockex3_user.c
index 3fcfd8c4b2a3..9099c4255f23 100644
--- a/samples/bpf/sockex3_user.c
+++ b/samples/bpf/sockex3_user.c
@@ -54,8 +54,8 @@ int main(int argc, char **argv)
 
 		sleep(1);
 		printf("IP     src.port -> dst.port               bytes      packets\n");
-		while (bpf_get_next_key(map_fd[2], &key, &next_key) == 0) {
-			bpf_lookup_elem(map_fd[2], &next_key, &value);
+		while (bpf_map_get_next_key(map_fd[2], &key, &next_key) == 0) {
+			bpf_map_lookup_elem(map_fd[2], &next_key, &value);
 			printf("%s.%05d -> %s.%05d %12lld %12lld\n",
 			       inet_ntoa((struct in_addr){htonl(next_key.src)}),
 			       next_key.port16[0],
diff --git a/samples/bpf/spintest_user.c b/samples/bpf/spintest_user.c
index 311ede532230..80676c25fa50 100644
--- a/samples/bpf/spintest_user.c
+++ b/samples/bpf/spintest_user.c
@@ -31,8 +31,8 @@ int main(int ac, char **argv)
 	for (i = 0; i < 5; i++) {
 		key = 0;
 		printf("kprobing funcs:");
-		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
-			bpf_lookup_elem(map_fd[0], &next_key, &value);
+		while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_map_lookup_elem(map_fd[0], &next_key, &value);
 			assert(next_key == value);
 			sym = ksym_search(value);
 			printf(" %s", sym->name);
@@ -41,8 +41,8 @@ int main(int ac, char **argv)
 		if (key)
 			printf("\n");
 		key = 0;
-		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0)
-			bpf_delete_elem(map_fd[0], &next_key);
+		while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0)
+			bpf_map_delete_elem(map_fd[0], &next_key);
 		sleep(1);
 	}
 
diff --git a/samples/bpf/tc_l2_redirect_user.c b/samples/bpf/tc_l2_redirect_user.c
index 4013c5337b91..28995a776560 100644
--- a/samples/bpf/tc_l2_redirect_user.c
+++ b/samples/bpf/tc_l2_redirect_user.c
@@ -60,9 +60,9 @@ int main(int argc, char **argv)
 	}
 
 	/* bpf_tunnel_key.remote_ipv4 expects host byte orders */
-	ret = bpf_update_elem(array_fd, &array_key, &ifindex, 0);
+	ret = bpf_map_update_elem(array_fd, &array_key, &ifindex, 0);
 	if (ret) {
-		perror("bpf_update_elem");
+		perror("bpf_map_update_elem");
 		goto out;
 	}
 
diff --git a/samples/bpf/test_cgrp2_array_pin.c b/samples/bpf/test_cgrp2_array_pin.c
index 70e86f7be69d..8a1b8b5d8def 100644
--- a/samples/bpf/test_cgrp2_array_pin.c
+++ b/samples/bpf/test_cgrp2_array_pin.c
@@ -85,9 +85,9 @@ int main(int argc, char **argv)
 		}
 	}
 
-	ret = bpf_update_elem(array_fd, &array_key, &cg2_fd, 0);
+	ret = bpf_map_update_elem(array_fd, &array_key, &cg2_fd, 0);
 	if (ret) {
-		perror("bpf_update_elem");
+		perror("bpf_map_update_elem");
 		goto out;
 	}
 
diff --git a/samples/bpf/test_cgrp2_attach.c b/samples/bpf/test_cgrp2_attach.c
index a19484c45b79..8283ef86d392 100644
--- a/samples/bpf/test_cgrp2_attach.c
+++ b/samples/bpf/test_cgrp2_attach.c
@@ -36,6 +36,8 @@ enum {
 	MAP_KEY_BYTES,
 };
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static int prog_load(int map_fd, int verdict)
 {
 	struct bpf_insn prog[] = {
@@ -67,8 +69,9 @@ static int prog_load(int map_fd, int verdict)
 		BPF_EXIT_INSN(),
 	};
 
-	return bpf_prog_load(BPF_PROG_TYPE_CGROUP_SKB,
-			     prog, sizeof(prog), "GPL", 0);
+	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SKB,
+				prog, sizeof(prog), "GPL", 0,
+				bpf_log_buf, BPF_LOG_BUF_SIZE);
 }
 
 static int usage(const char *argv0)
@@ -108,10 +111,10 @@ static int attach_filter(int cg_fd, int type, int verdict)
 	}
 	while (1) {
 		key = MAP_KEY_PACKETS;
-		assert(bpf_lookup_elem(map_fd, &key, &pkt_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &key, &pkt_cnt) == 0);
 
 		key = MAP_KEY_BYTES;
-		assert(bpf_lookup_elem(map_fd, &key, &byte_cnt) == 0);
+		assert(bpf_map_lookup_elem(map_fd, &key, &byte_cnt) == 0);
 
 		printf("cgroup received %lld packets, %lld bytes\n",
 		       pkt_cnt, byte_cnt);
diff --git a/samples/bpf/test_cgrp2_attach2.c b/samples/bpf/test_cgrp2_attach2.c
index ddfac42ed4df..fc6092fdc3b0 100644
--- a/samples/bpf/test_cgrp2_attach2.c
+++ b/samples/bpf/test_cgrp2_attach2.c
@@ -32,6 +32,8 @@
 #define BAR		"/foo/bar/"
 #define PING_CMD	"ping -c1 -w1 127.0.0.1"
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static int prog_load(int verdict)
 {
 	int ret;
@@ -40,8 +42,9 @@ static int prog_load(int verdict)
 		BPF_EXIT_INSN(),
 	};
 
-	ret = bpf_prog_load(BPF_PROG_TYPE_CGROUP_SKB,
-			     prog, sizeof(prog), "GPL", 0);
+	ret = bpf_load_program(BPF_PROG_TYPE_CGROUP_SKB,
+			       prog, sizeof(prog), "GPL", 0,
+			       bpf_log_buf, BPF_LOG_BUF_SIZE);
 
 	if (ret < 0) {
 		log_err("Loading program");
diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index d467b3c1c55c..43b4bde5d05c 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -23,6 +23,8 @@
 
 #include "libbpf.h"
 
+char bpf_log_buf[BPF_LOG_BUF_SIZE];
+
 static int prog_load(int idx)
 {
 	struct bpf_insn prog[] = {
@@ -34,8 +36,8 @@ static int prog_load(int idx)
 		BPF_EXIT_INSN(),
 	};
 
-	return bpf_prog_load(BPF_PROG_TYPE_CGROUP_SOCK, prog, sizeof(prog),
-			     "GPL", 0);
+	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SOCK, prog, sizeof(prog),
+				"GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
 }
 
 static int usage(const char *argv0)
diff --git a/samples/bpf/test_current_task_under_cgroup_user.c b/samples/bpf/test_current_task_under_cgroup_user.c
index 95aaaa846130..65b5fb51c1db 100644
--- a/samples/bpf/test_current_task_under_cgroup_user.c
+++ b/samples/bpf/test_current_task_under_cgroup_user.c
@@ -36,7 +36,7 @@ int main(int argc, char **argv)
 	if (!cg2)
 		goto err;
 
-	if (bpf_update_elem(map_fd[0], &idx, &cg2, BPF_ANY)) {
+	if (bpf_map_update_elem(map_fd[0], &idx, &cg2, BPF_ANY)) {
 		log_err("Adding target cgroup to map");
 		goto err;
 	}
@@ -50,7 +50,7 @@ int main(int argc, char **argv)
 	 */
 
 	sync();
-	bpf_lookup_elem(map_fd[1], &idx, &remote_pid);
+	bpf_map_lookup_elem(map_fd[1], &idx, &remote_pid);
 
 	if (local_pid != remote_pid) {
 		fprintf(stderr,
@@ -64,10 +64,10 @@ int main(int argc, char **argv)
 		goto err;
 
 	remote_pid = 0;
-	bpf_update_elem(map_fd[1], &idx, &remote_pid, BPF_ANY);
+	bpf_map_update_elem(map_fd[1], &idx, &remote_pid, BPF_ANY);
 
 	sync();
-	bpf_lookup_elem(map_fd[1], &idx, &remote_pid);
+	bpf_map_lookup_elem(map_fd[1], &idx, &remote_pid);
 
 	if (local_pid == remote_pid) {
 		fprintf(stderr, "BPF cgroup negative test did not work\n");
diff --git a/samples/bpf/test_lru_dist.c b/samples/bpf/test_lru_dist.c
index 316230a0ed23..d96dc88d3b04 100644
--- a/samples/bpf/test_lru_dist.c
+++ b/samples/bpf/test_lru_dist.c
@@ -134,7 +134,7 @@ static int pfect_lru_lookup_or_insert(struct pfect_lru *lru,
 	int seen = 0;
 
 	lru->total++;
-	if (!bpf_lookup_elem(lru->map_fd, &key, &node)) {
+	if (!bpf_map_lookup_elem(lru->map_fd, &key, &node)) {
 		if (node) {
 			list_move(&node->list, &lru->list);
 			return 1;
@@ -151,7 +151,7 @@ static int pfect_lru_lookup_or_insert(struct pfect_lru *lru,
 		node = list_last_entry(&lru->list,
 				       struct pfect_lru_node,
 				       list);
-		bpf_update_elem(lru->map_fd, &node->key, &null_node, BPF_EXIST);
+		bpf_map_update_elem(lru->map_fd, &node->key, &null_node, BPF_EXIST);
 	}
 
 	node->key = key;
@@ -159,10 +159,10 @@ static int pfect_lru_lookup_or_insert(struct pfect_lru *lru,
 
 	lru->nr_misses++;
 	if (seen) {
-		assert(!bpf_update_elem(lru->map_fd, &key, &node, BPF_EXIST));
+		assert(!bpf_map_update_elem(lru->map_fd, &key, &node, BPF_EXIST));
 	} else {
 		lru->nr_unique++;
-		assert(!bpf_update_elem(lru->map_fd, &key, &node, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(lru->map_fd, &key, &node, BPF_NOEXIST));
 	}
 
 	return seen;
@@ -285,11 +285,11 @@ static void do_test_lru_dist(int task, void *data)
 
 		pfect_lru_lookup_or_insert(&pfect_lru, key);
 
-		if (!bpf_lookup_elem(lru_map_fd, &key, &value))
+		if (!bpf_map_lookup_elem(lru_map_fd, &key, &value))
 			continue;
 
-		if (bpf_update_elem(lru_map_fd, &key, &value, BPF_NOEXIST)) {
-			printf("bpf_update_elem(lru_map_fd, %llu): errno:%d\n",
+		if (bpf_map_update_elem(lru_map_fd, &key, &value, BPF_NOEXIST)) {
+			printf("bpf_map_update_elem(lru_map_fd, %llu): errno:%d\n",
 			       key, errno);
 			assert(0);
 		}
@@ -358,19 +358,19 @@ static void test_lru_loss0(int map_type, int map_flags)
 	for (key = 1; key <= 1000; key++) {
 		int start_key, end_key;
 
-		assert(bpf_update_elem(map_fd, &key, value, BPF_NOEXIST) == 0);
+		assert(bpf_map_update_elem(map_fd, &key, value, BPF_NOEXIST) == 0);
 
 		start_key = 101;
 		end_key = min(key, 900);
 
 		while (start_key <= end_key) {
-			bpf_lookup_elem(map_fd, &start_key, value);
+			bpf_map_lookup_elem(map_fd, &start_key, value);
 			start_key++;
 		}
 	}
 
 	for (key = 1; key <= 1000; key++) {
-		if (bpf_lookup_elem(map_fd, &key, value)) {
+		if (bpf_map_lookup_elem(map_fd, &key, value)) {
 			if (key <= 100)
 				old_unused_losses++;
 			else if (key <= 900)
@@ -408,10 +408,10 @@ static void test_lru_loss1(int map_type, int map_flags)
 	value[0] = 1234;
 
 	for (key = 1; key <= 1000; key++)
-		assert(!bpf_update_elem(map_fd, &key, value, BPF_NOEXIST));
+		assert(!bpf_map_update_elem(map_fd, &key, value, BPF_NOEXIST));
 
 	for (key = 1; key <= 1000; key++) {
-		if (bpf_lookup_elem(map_fd, &key, value))
+		if (bpf_map_lookup_elem(map_fd, &key, value))
 			nr_losses++;
 	}
 
@@ -436,7 +436,7 @@ static void do_test_parallel_lru_loss(int task, void *data)
 	next_ins_key = stable_base;
 	value[0] = 1234;
 	for (i = 0; i < nr_stable_elems; i++) {
-		assert(bpf_update_elem(map_fd, &next_ins_key, value,
+		assert(bpf_map_update_elem(map_fd, &next_ins_key, value,
 				       BPF_NOEXIST) == 0);
 		next_ins_key++;
 	}
@@ -448,9 +448,9 @@ static void do_test_parallel_lru_loss(int task, void *data)
 
 		if (rn % 10) {
 			key = rn % nr_stable_elems + stable_base;
-			bpf_lookup_elem(map_fd, &key, value);
+			bpf_map_lookup_elem(map_fd, &key, value);
 		} else {
-			bpf_update_elem(map_fd, &next_ins_key, value,
+			bpf_map_update_elem(map_fd, &next_ins_key, value,
 					BPF_NOEXIST);
 			next_ins_key++;
 		}
@@ -458,7 +458,7 @@ static void do_test_parallel_lru_loss(int task, void *data)
 
 	key = stable_base;
 	for (i = 0; i < nr_stable_elems; i++) {
-		if (bpf_lookup_elem(map_fd, &key, value))
+		if (bpf_map_lookup_elem(map_fd, &key, value))
 			nr_losses++;
 		key++;
 	}
diff --git a/samples/bpf/test_probe_write_user_user.c b/samples/bpf/test_probe_write_user_user.c
index a44bf347bedd..b5bf178a6ecc 100644
--- a/samples/bpf/test_probe_write_user_user.c
+++ b/samples/bpf/test_probe_write_user_user.c
@@ -50,7 +50,7 @@ int main(int ac, char **argv)
 	mapped_addr_in->sin_port = htons(5555);
 	mapped_addr_in->sin_addr.s_addr = inet_addr("255.255.255.255");
 
-	assert(!bpf_update_elem(map_fd[0], &mapped_addr, &serv_addr, BPF_ANY));
+	assert(!bpf_map_update_elem(map_fd[0], &mapped_addr, &serv_addr, BPF_ANY));
 
 	assert(listen(serverfd, 5) == 0);
 
diff --git a/samples/bpf/trace_event_user.c b/samples/bpf/trace_event_user.c
index 9a130d31ecf2..704fe9fa77b2 100644
--- a/samples/bpf/trace_event_user.c
+++ b/samples/bpf/trace_event_user.c
@@ -61,14 +61,14 @@ static void print_stack(struct key_t *key, __u64 count)
 	int i;
 
 	printf("%3lld %s;", count, key->comm);
-	if (bpf_lookup_elem(map_fd[1], &key->kernstack, ip) != 0) {
+	if (bpf_map_lookup_elem(map_fd[1], &key->kernstack, ip) != 0) {
 		printf("---;");
 	} else {
 		for (i = PERF_MAX_STACK_DEPTH - 1; i >= 0; i--)
 			print_ksym(ip[i]);
 	}
 	printf("-;");
-	if (bpf_lookup_elem(map_fd[1], &key->userstack, ip) != 0) {
+	if (bpf_map_lookup_elem(map_fd[1], &key->userstack, ip) != 0) {
 		printf("---;");
 	} else {
 		for (i = PERF_MAX_STACK_DEPTH - 1; i >= 0; i--)
@@ -98,10 +98,10 @@ static void print_stacks(void)
 	int fd = map_fd[0], stack_map = map_fd[1];
 
 	sys_read_seen = sys_write_seen = false;
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
-		bpf_lookup_elem(fd, &next_key, &value);
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
+		bpf_map_lookup_elem(fd, &next_key, &value);
 		print_stack(&next_key, value);
-		bpf_delete_elem(fd, &next_key);
+		bpf_map_delete_elem(fd, &next_key);
 		key = next_key;
 	}
 
@@ -111,8 +111,8 @@ static void print_stacks(void)
 	}
 
 	/* clear stack map */
-	while (bpf_get_next_key(stack_map, &stackid, &next_id) == 0) {
-		bpf_delete_elem(stack_map, &next_id);
+	while (bpf_map_get_next_key(stack_map, &stackid, &next_id) == 0) {
+		bpf_map_delete_elem(stack_map, &next_id);
 		stackid = next_id;
 	}
 }
diff --git a/samples/bpf/trace_output_user.c b/samples/bpf/trace_output_user.c
index 661a7d052f2c..3bedd945def1 100644
--- a/samples/bpf/trace_output_user.c
+++ b/samples/bpf/trace_output_user.c
@@ -162,7 +162,7 @@ static void test_bpf_perf_event(void)
 	pmu_fd = perf_event_open(&attr, -1/*pid*/, 0/*cpu*/, -1/*group_fd*/, 0);
 
 	assert(pmu_fd >= 0);
-	assert(bpf_update_elem(map_fd[0], &key, &pmu_fd, BPF_ANY) == 0);
+	assert(bpf_map_update_elem(map_fd[0], &key, &pmu_fd, BPF_ANY) == 0);
 	ioctl(pmu_fd, PERF_EVENT_IOC_ENABLE, 0);
 }
 
diff --git a/samples/bpf/tracex2_user.c b/samples/bpf/tracex2_user.c
index 3e225e331f66..ded9804c5034 100644
--- a/samples/bpf/tracex2_user.c
+++ b/samples/bpf/tracex2_user.c
@@ -48,12 +48,12 @@ static void print_hist_for_pid(int fd, void *task)
 	long max_value = 0;
 	int i, ind;
 
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
 		if (memcmp(&next_key, task, SIZE)) {
 			key = next_key;
 			continue;
 		}
-		bpf_lookup_elem(fd, &next_key, values);
+		bpf_map_lookup_elem(fd, &next_key, values);
 		value = 0;
 		for (i = 0; i < nr_cpus; i++)
 			value += values[i];
@@ -83,7 +83,7 @@ static void print_hist(int fd)
 	int task_cnt = 0;
 	int i;
 
-	while (bpf_get_next_key(fd, &key, &next_key) == 0) {
+	while (bpf_map_get_next_key(fd, &key, &next_key) == 0) {
 		int found = 0;
 
 		for (i = 0; i < task_cnt; i++)
@@ -136,8 +136,8 @@ int main(int ac, char **argv)
 
 	for (i = 0; i < 5; i++) {
 		key = 0;
-		while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
-			bpf_lookup_elem(map_fd[0], &next_key, &value);
+		while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0) {
+			bpf_map_lookup_elem(map_fd[0], &next_key, &value);
 			printf("location 0x%lx count %ld\n", next_key, value);
 			key = next_key;
 		}
diff --git a/samples/bpf/tracex3_user.c b/samples/bpf/tracex3_user.c
index d0851cb4fa8d..8f7d199d5945 100644
--- a/samples/bpf/tracex3_user.c
+++ b/samples/bpf/tracex3_user.c
@@ -28,7 +28,7 @@ static void clear_stats(int fd)
 
 	memset(values, 0, sizeof(values));
 	for (key = 0; key < SLOTS; key++)
-		bpf_update_elem(fd, &key, values, BPF_ANY);
+		bpf_map_update_elem(fd, &key, values, BPF_ANY);
 }
 
 const char *color[] = {
@@ -89,7 +89,7 @@ static void print_hist(int fd)
 	int i;
 
 	for (key = 0; key < SLOTS; key++) {
-		bpf_lookup_elem(fd, &key, values);
+		bpf_map_lookup_elem(fd, &key, values);
 		value = 0;
 		for (i = 0; i < nr_cpus; i++)
 			value += values[i];
diff --git a/samples/bpf/tracex4_user.c b/samples/bpf/tracex4_user.c
index bc4a3bdea6ed..03449f773cb1 100644
--- a/samples/bpf/tracex4_user.c
+++ b/samples/bpf/tracex4_user.c
@@ -37,8 +37,8 @@ static void print_old_objects(int fd)
 	key = write(1, "\e[1;1H\e[2J", 12); /* clear screen */
 
 	key = -1;
-	while (bpf_get_next_key(map_fd[0], &key, &next_key) == 0) {
-		bpf_lookup_elem(map_fd[0], &next_key, &v);
+	while (bpf_map_get_next_key(map_fd[0], &key, &next_key) == 0) {
+		bpf_map_lookup_elem(map_fd[0], &next_key, &v);
 		key = next_key;
 		if (val - v.val < 1000000000ll)
 			/* object was allocated more then 1 sec ago */
diff --git a/samples/bpf/tracex6_user.c b/samples/bpf/tracex6_user.c
index 8ea4976cfcf1..179297cb4d35 100644
--- a/samples/bpf/tracex6_user.c
+++ b/samples/bpf/tracex6_user.c
@@ -36,7 +36,7 @@ static void test_bpf_perf_event(void)
 			goto exit;
 		}
 
-		bpf_update_elem(map_fd[0], &i, &pmu_fd[i], BPF_ANY);
+		bpf_map_update_elem(map_fd[0], &i, &pmu_fd[i], BPF_ANY);
 		ioctl(pmu_fd[i], PERF_EVENT_IOC_ENABLE, 0);
 	}
 
diff --git a/samples/bpf/xdp1_user.c b/samples/bpf/xdp1_user.c
index 5f040a0d7712..d2be65d1fd86 100644
--- a/samples/bpf/xdp1_user.c
+++ b/samples/bpf/xdp1_user.c
@@ -43,7 +43,7 @@ static void poll_stats(int interval)
 		for (key = 0; key < nr_keys; key++) {
 			__u64 sum = 0;
 
-			assert(bpf_lookup_elem(map_fd[0], &key, values) == 0);
+			assert(bpf_map_lookup_elem(map_fd[0], &key, values) == 0);
 			for (i = 0; i < nr_cpus; i++)
 				sum += (values[i] - prev[key][i]);
 			if (sum)
diff --git a/samples/bpf/xdp_tx_iptunnel_user.c b/samples/bpf/xdp_tx_iptunnel_user.c
index 7a71f5c74684..70e192fc61aa 100644
--- a/samples/bpf/xdp_tx_iptunnel_user.c
+++ b/samples/bpf/xdp_tx_iptunnel_user.c
@@ -51,7 +51,7 @@ static void poll_stats(unsigned int kill_after_s)
 		for (proto = 0; proto < nr_protos; proto++) {
 			__u64 sum = 0;
 
-			assert(bpf_lookup_elem(map_fd[0], &proto, values) == 0);
+			assert(bpf_map_lookup_elem(map_fd[0], &proto, values) == 0);
 			for (i = 0; i < nr_cpus; i++)
 				sum += (values[i] - prev[proto][i]);
 
@@ -237,8 +237,8 @@ int main(int argc, char **argv)
 
 	while (min_port <= max_port) {
 		vip.dport = htons(min_port++);
-		if (bpf_update_elem(map_fd[1], &vip, &tnl, BPF_NOEXIST)) {
-			perror("bpf_update_elem(&vip2tnl)");
+		if (bpf_map_update_elem(map_fd[1], &vip, &tnl, BPF_NOEXIST)) {
+			perror("bpf_map_update_elem(&vip2tnl)");
 			return 1;
 		}
 	}
-- 
2.9.3
