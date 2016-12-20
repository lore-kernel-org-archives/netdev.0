From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 25/29] samples/bpf: Switch over to libbpf
Date: Tue, 20 Dec 2016 14:03:54 -0300
Message-ID: <20161220170358.4350-26-acme@kernel.org>
References: <20161220170358.4350-1-acme@kernel.org>
Cc: linux-kernel@vger.kernel.org, Joe Stringer <joe@ovn.org>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Wang Nan <wangnan0@huawei.com>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([198.137.202.9]:45141 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936469AbcLTREf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 20 Dec 2016 12:04:35 -0500
In-Reply-To: <20161220170358.4350-1-acme@kernel.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Stringer <joe@ovn.org>

Now that libbpf under tools/lib/bpf/* is synced with the version from
samples/bpf, we can get rid most of the libbpf library here.

Committer notes:

Built it in a docker fedora rawhide container and ran it in the f25 host, seems
to work just like it did before this patch, i.e. the switch to tools/lib/bpf/
doesn't seem to have introduced problems and Joe said he tested it with
all the entries in samples/bpf/ and other code he found:

  [root@f5065a7d6272 linux]# make -j4 O=/tmp/build/linux headers_install
  <SNIP>
  [root@f5065a7d6272 linux]# rm -rf /tmp/build/linux/samples/bpf/
  [root@f5065a7d6272 linux]# make -j4 O=/tmp/build/linux samples/bpf/
  make[1]: Entering directory '/tmp/build/linux'
    CHK     include/config/kernel.release
    HOSTCC  scripts/basic/fixdep
    GEN     ./Makefile
    CHK     include/generated/uapi/linux/version.h
    Using /git/linux as source for kernel
    CHK     include/generated/utsrelease.h
    HOSTCC  scripts/basic/bin2c
    HOSTCC  arch/x86/tools/relocs_32.o
    HOSTCC  arch/x86/tools/relocs_64.o
    LD      samples/bpf/built-in.o
  <SNIP>
    HOSTCC  samples/bpf/fds_example.o
    HOSTCC  samples/bpf/sockex1_user.o
  /git/linux/samples/bpf/fds_example.c: In function 'bpf_prog_create':
  /git/linux/samples/bpf/fds_example.c:63:6: warning: passing argument 2 of 'bpf_load_program' discards 'const' qualifier from pointer target type [-Wdiscarded-qualifiers]
        insns, insns_cnt, "GPL", 0,
        ^~~~~
  In file included from /git/linux/samples/bpf/libbpf.h:5:0,
                   from /git/linux/samples/bpf/bpf_load.h:4,
                   from /git/linux/samples/bpf/fds_example.c:15:
  /git/linux/tools/lib/bpf/bpf.h:31:5: note: expected 'struct bpf_insn *' but argument is of type 'const struct bpf_insn *'
   int bpf_load_program(enum bpf_prog_type type, struct bpf_insn *insns,
       ^~~~~~~~~~~~~~~~
    HOSTCC  samples/bpf/sockex2_user.o
  <SNIP>
    HOSTCC  samples/bpf/xdp_tx_iptunnel_user.o
  clang  -nostdinc -isystem /usr/lib/gcc/x86_64-redhat-linux/6.2.1/include -I/git/linux/arch/x86/include -I./arch/x86/include/generated/uapi -I./arch/x86/include/generated  -I/git/linux/include -I./include -I/git/linux/arch/x86/include/uapi -I/git/linux/include/uapi -I./include/generated/uapi -include /git/linux/include/linux/kconfig.h  \
	  -D__KERNEL__ -D__ASM_SYSREG_H -Wno-unused-value -Wno-pointer-sign \
	  -Wno-compare-distinct-pointer-types \
	  -Wno-gnu-variable-sized-type-not-at-end \
	  -Wno-address-of-packed-member -Wno-tautological-compare \
	  -O2 -emit-llvm -c /git/linux/samples/bpf/sockex1_kern.c -o -| llc -march=bpf -filetype=obj -o samples/bpf/sockex1_kern.o
    HOSTLD  samples/bpf/tc_l2_redirect
  <SNIP>
    HOSTLD  samples/bpf/lwt_len_hist
    HOSTLD  samples/bpf/xdp_tx_iptunnel
  make[1]: Leaving directory '/tmp/build/linux'
  [root@f5065a7d6272 linux]#

And then, in the host:

  [root@jouet bpf]# mount | grep "docker.*devicemapper\/"
  /dev/mapper/docker-253:0-1705076-9bd8aa1e0af33adce89ff42090847868ca676932878942be53941a06ec5923f9 on /var/lib/docker/devicemapper/mnt/9bd8aa1e0af33adce89ff42090847868ca676932878942be53941a06ec5923f9 type xfs (rw,relatime,context="system_u:object_r:container_file_t:s0:c73,c276",nouuid,attr2,inode64,sunit=1024,swidth=1024,noquota)
  [root@jouet bpf]# cd /var/lib/docker/devicemapper/mnt/9bd8aa1e0af33adce89ff42090847868ca676932878942be53941a06ec5923f9/rootfs/tmp/build/linux/samples/bpf/
  [root@jouet bpf]# file offwaketime
  offwaketime: ELF 64-bit LSB executable, x86-64, version 1 (SYSV), dynamically linked, interpreter /lib64/ld-linux-x86-64.so.2, for GNU/Linux 2.6.32, BuildID[sha1]=f423d171e0487b2f802b6a792657f0f3c8f6d155, not stripped
  [root@jouet bpf]# readelf -SW offwaketime
  offwaketime         offwaketime_kern.o  offwaketime_user.o
  [root@jouet bpf]# readelf -SW offwaketime_kern.o
  There are 11 section headers, starting at offset 0x700:

  Section Headers:
    [Nr] Name              Type            Address          Off    Size   ES Flg Lk Inf Al
    [ 0]                   NULL            0000000000000000 000000 000000 00      0   0  0
    [ 1] .strtab           STRTAB          0000000000000000 000658 0000a8 00      0   0  1
    [ 2] .text             PROGBITS        0000000000000000 000040 000000 00  AX  0   0  4
    [ 3] kprobe/try_to_wake_up PROGBITS        0000000000000000 000040 0000d8 00  AX  0   0  8
    [ 4] .relkprobe/try_to_wake_up REL             0000000000000000 0005a8 000020 10     10   3  8
    [ 5] tracepoint/sched/sched_switch PROGBITS        0000000000000000 000118 000318 00  AX  0   0  8
    [ 6] .reltracepoint/sched/sched_switch REL             0000000000000000 0005c8 000090 10     10   5  8
    [ 7] maps              PROGBITS        0000000000000000 000430 000050 00  WA  0   0  4
    [ 8] license           PROGBITS        0000000000000000 000480 000004 00  WA  0   0  1
    [ 9] version           PROGBITS        0000000000000000 000484 000004 00  WA  0   0  4
    [10] .symtab           SYMTAB          0000000000000000 000488 000120 18      1   4  8
  Key to Flags:
    W (write), A (alloc), X (execute), M (merge), S (strings)
    I (info), L (link order), G (group), T (TLS), E (exclude), x (unknown)
    O (extra OS processing required) o (OS specific), p (processor specific)
    [root@jouet bpf]# ./offwaketime | head -3
  qemu-system-x86;entry_SYSCALL_64_fastpath;sys_ppoll;do_sys_poll;poll_schedule_timeout;schedule_hrtimeout_range;schedule_hrtimeout_range_clock;schedule;__schedule;-;try_to_wake_up;hrtimer_wakeup;__hrtimer_run_queues;hrtimer_interrupt;local_apic_timer_interrupt;smp_apic_timer_interrupt;__irqentry_text_start;cpuidle_enter_state;cpuidle_enter;call_cpuidle;cpu_startup_entry;rest_init;start_kernel;x86_64_start_reservations;x86_64_start_kernel;start_cpu;;swapper/0 4
  firefox;entry_SYSCALL_64_fastpath;sys_poll;do_sys_poll;poll_schedule_timeout;schedule_hrtimeout_range;schedule_hrtimeout_range_clock;schedule;__schedule;-;try_to_wake_up;pollwake;__wake_up_common;__wake_up_sync_key;pipe_write;__vfs_write;vfs_write;sys_write;entry_SYSCALL_64_fastpath;;Timer 1
  swapper/2;start_cpu;start_secondary;cpu_startup_entry;schedule_preempt_disabled;schedule;__schedule;-;---;; 61
  [root@jouet bpf]#

Signed-off-by: Joe Stringer <joe@ovn.org>
Tested-by: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Wang Nan <wangnan0@huawei.com>
Cc: netdev@vger.kernel.org
Link: https://github.com/joestringer/linux/commit/5c40f54a52b1f437123c81e21873f4b4b1f9bd55.patch
Link: http://lkml.kernel.org/n/tip-xr8twtx7sjh5821g8qw47yxk@git.kernel.org
[ Use -I$(srctree)/tools/lib/ to support out of source code tree builds, as noticed by Wang Nan ]
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>

Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
---
 samples/bpf/Makefile             |  68 +++++++++++++-----------
 samples/bpf/README.rst           |   4 +-
 samples/bpf/bpf_load.c           |   3 +-
 samples/bpf/fds_example.c        |   3 +-
 samples/bpf/libbpf.c             | 111 ---------------------------------------
 samples/bpf/libbpf.h             |  19 +------
 samples/bpf/sock_example.c       |   3 +-
 samples/bpf/test_cgrp2_attach.c  |   3 +-
 samples/bpf/test_cgrp2_attach2.c |   3 +-
 samples/bpf/test_cgrp2_sock.c    |   3 +-
 10 files changed, 52 insertions(+), 168 deletions(-)

diff --git a/samples/bpf/Makefile b/samples/bpf/Makefile
index f2219c1489e5..81b0ef2f7994 100644
--- a/samples/bpf/Makefile
+++ b/samples/bpf/Makefile
@@ -35,40 +35,43 @@ hostprogs-y += tc_l2_redirect
 hostprogs-y += lwt_len_hist
 hostprogs-y += xdp_tx_iptunnel
 
-test_lru_dist-objs := test_lru_dist.o libbpf.o
-sock_example-objs := sock_example.o libbpf.o
-fds_example-objs := bpf_load.o libbpf.o fds_example.o
-sockex1-objs := bpf_load.o libbpf.o sockex1_user.o
-sockex2-objs := bpf_load.o libbpf.o sockex2_user.o
-sockex3-objs := bpf_load.o libbpf.o sockex3_user.o
-tracex1-objs := bpf_load.o libbpf.o tracex1_user.o
-tracex2-objs := bpf_load.o libbpf.o tracex2_user.o
-tracex3-objs := bpf_load.o libbpf.o tracex3_user.o
-tracex4-objs := bpf_load.o libbpf.o tracex4_user.o
-tracex5-objs := bpf_load.o libbpf.o tracex5_user.o
-tracex6-objs := bpf_load.o libbpf.o tracex6_user.o
-test_probe_write_user-objs := bpf_load.o libbpf.o test_probe_write_user_user.o
-trace_output-objs := bpf_load.o libbpf.o trace_output_user.o
-lathist-objs := bpf_load.o libbpf.o lathist_user.o
-offwaketime-objs := bpf_load.o libbpf.o offwaketime_user.o
-spintest-objs := bpf_load.o libbpf.o spintest_user.o
-map_perf_test-objs := bpf_load.o libbpf.o map_perf_test_user.o
-test_overhead-objs := bpf_load.o libbpf.o test_overhead_user.o
-test_cgrp2_array_pin-objs := libbpf.o test_cgrp2_array_pin.o
-test_cgrp2_attach-objs := libbpf.o test_cgrp2_attach.o
-test_cgrp2_attach2-objs := libbpf.o test_cgrp2_attach2.o cgroup_helpers.o
-test_cgrp2_sock-objs := libbpf.o test_cgrp2_sock.o
-test_cgrp2_sock2-objs := bpf_load.o libbpf.o test_cgrp2_sock2.o
-xdp1-objs := bpf_load.o libbpf.o xdp1_user.o
+# Libbpf dependencies
+LIBBPF := libbpf.o ../../tools/lib/bpf/bpf.o
+
+test_lru_dist-objs := test_lru_dist.o $(LIBBPF)
+sock_example-objs := sock_example.o $(LIBBPF)
+fds_example-objs := bpf_load.o $(LIBBPF) fds_example.o
+sockex1-objs := bpf_load.o $(LIBBPF) sockex1_user.o
+sockex2-objs := bpf_load.o $(LIBBPF) sockex2_user.o
+sockex3-objs := bpf_load.o $(LIBBPF) sockex3_user.o
+tracex1-objs := bpf_load.o $(LIBBPF) tracex1_user.o
+tracex2-objs := bpf_load.o $(LIBBPF) tracex2_user.o
+tracex3-objs := bpf_load.o $(LIBBPF) tracex3_user.o
+tracex4-objs := bpf_load.o $(LIBBPF) tracex4_user.o
+tracex5-objs := bpf_load.o $(LIBBPF) tracex5_user.o
+tracex6-objs := bpf_load.o $(LIBBPF) tracex6_user.o
+test_probe_write_user-objs := bpf_load.o $(LIBBPF) test_probe_write_user_user.o
+trace_output-objs := bpf_load.o $(LIBBPF) trace_output_user.o
+lathist-objs := bpf_load.o $(LIBBPF) lathist_user.o
+offwaketime-objs := bpf_load.o $(LIBBPF) offwaketime_user.o
+spintest-objs := bpf_load.o $(LIBBPF) spintest_user.o
+map_perf_test-objs := bpf_load.o $(LIBBPF) map_perf_test_user.o
+test_overhead-objs := bpf_load.o $(LIBBPF) test_overhead_user.o
+test_cgrp2_array_pin-objs := $(LIBBPF) test_cgrp2_array_pin.o
+test_cgrp2_attach-objs := $(LIBBPF) test_cgrp2_attach.o
+test_cgrp2_attach2-objs := $(LIBBPF) test_cgrp2_attach2.o cgroup_helpers.o
+test_cgrp2_sock-objs := $(LIBBPF) test_cgrp2_sock.o
+test_cgrp2_sock2-objs := bpf_load.o $(LIBBPF) test_cgrp2_sock2.o
+xdp1-objs := bpf_load.o $(LIBBPF) xdp1_user.o
 # reuse xdp1 source intentionally
-xdp2-objs := bpf_load.o libbpf.o xdp1_user.o
-test_current_task_under_cgroup-objs := bpf_load.o libbpf.o cgroup_helpers.o \
+xdp2-objs := bpf_load.o $(LIBBPF) xdp1_user.o
+test_current_task_under_cgroup-objs := bpf_load.o $(LIBBPF) cgroup_helpers.o \
 				       test_current_task_under_cgroup_user.o
-trace_event-objs := bpf_load.o libbpf.o trace_event_user.o
-sampleip-objs := bpf_load.o libbpf.o sampleip_user.o
-tc_l2_redirect-objs := bpf_load.o libbpf.o tc_l2_redirect_user.o
-lwt_len_hist-objs := bpf_load.o libbpf.o lwt_len_hist_user.o
-xdp_tx_iptunnel-objs := bpf_load.o libbpf.o xdp_tx_iptunnel_user.o
+trace_event-objs := bpf_load.o $(LIBBPF) trace_event_user.o
+sampleip-objs := bpf_load.o $(LIBBPF) sampleip_user.o
+tc_l2_redirect-objs := bpf_load.o $(LIBBPF) tc_l2_redirect_user.o
+lwt_len_hist-objs := bpf_load.o $(LIBBPF) lwt_len_hist_user.o
+xdp_tx_iptunnel-objs := bpf_load.o $(LIBBPF) xdp_tx_iptunnel_user.o
 
 # Tell kbuild to always build the programs
 always := $(hostprogs-y)
@@ -104,6 +107,7 @@ always += lwt_len_hist_kern.o
 always += xdp_tx_iptunnel_kern.o
 
 HOSTCFLAGS += -I$(objtree)/usr/include
+HOSTCFLAGS += -I$(srctree)/tools/lib/
 HOSTCFLAGS += -I$(srctree)/tools/testing/selftests/bpf/
 
 HOSTCFLAGS_bpf_load.o += -I$(objtree)/usr/include -Wno-unused-variable
diff --git a/samples/bpf/README.rst b/samples/bpf/README.rst
index a43eae3f0551..79f9a58f1872 100644
--- a/samples/bpf/README.rst
+++ b/samples/bpf/README.rst
@@ -1,8 +1,8 @@
 eBPF sample programs
 ====================
 
-This directory contains a mini eBPF library, test stubs, verifier
-test-suite and examples for using eBPF.
+This directory contains a test stubs, verifier test-suite and examples
+for using eBPF. The examples use libbpf from tools/lib/bpf.
 
 Build dependencies
 ==================
diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index f5b186c46b7c..1bfb43394013 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -66,6 +66,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 	bool is_perf_event = strncmp(event, "perf_event", 10) == 0;
 	bool is_cgroup_skb = strncmp(event, "cgroup/skb", 10) == 0;
 	bool is_cgroup_sk = strncmp(event, "cgroup/sock", 11) == 0;
+	size_t insns_cnt = size / sizeof(struct bpf_insn);
 	enum bpf_prog_type prog_type;
 	char buf[256];
 	int fd, efd, err, id;
@@ -95,7 +96,7 @@ static int load_and_attach(const char *event, struct bpf_insn *prog, int size)
 		return -1;
 	}
 
-	fd = bpf_load_program(prog_type, prog, size, license, kern_version,
+	fd = bpf_load_program(prog_type, prog, insns_cnt, license, kern_version,
 			      bpf_log_buf, BPF_LOG_BUF_SIZE);
 	if (fd < 0) {
 		printf("bpf_load_program() err=%d\n%s", errno, bpf_log_buf);
diff --git a/samples/bpf/fds_example.c b/samples/bpf/fds_example.c
index 8a4fc4ef3993..6245062844d1 100644
--- a/samples/bpf/fds_example.c
+++ b/samples/bpf/fds_example.c
@@ -53,13 +53,14 @@ static int bpf_prog_create(const char *object)
 		BPF_MOV64_IMM(BPF_REG_0, 1),
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(insns) / sizeof(struct bpf_insn);
 
 	if (object) {
 		assert(!load_bpf_file((char *)object));
 		return prog_fd[0];
 	} else {
 		return bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER,
-					insns, sizeof(insns), "GPL", 0,
+					insns, insns_cnt, "GPL", 0,
 					bpf_log_buf, BPF_LOG_BUF_SIZE);
 	}
 }
diff --git a/samples/bpf/libbpf.c b/samples/bpf/libbpf.c
index 6f076abdca35..3391225ad7e9 100644
--- a/samples/bpf/libbpf.c
+++ b/samples/bpf/libbpf.c
@@ -4,8 +4,6 @@
 #include <linux/unistd.h>
 #include <unistd.h>
 #include <string.h>
-#include <linux/netlink.h>
-#include <linux/bpf.h>
 #include <errno.h>
 #include <net/ethernet.h>
 #include <net/if.h>
@@ -13,96 +11,6 @@
 #include <arpa/inet.h>
 #include "libbpf.h"
 
-static __u64 ptr_to_u64(void *ptr)
-{
-	return (__u64) (unsigned long) ptr;
-}
-
-int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries, int map_flags)
-{
-	union bpf_attr attr = {
-		.map_type = map_type,
-		.key_size = key_size,
-		.value_size = value_size,
-		.max_entries = max_entries,
-		.map_flags = map_flags,
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_CREATE, &attr, sizeof(attr));
-}
-
-int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-		.value = ptr_to_u64(value),
-		.flags = flags,
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_UPDATE_ELEM, &attr, sizeof(attr));
-}
-
-int bpf_map_lookup_elem(int fd, void *key, void *value)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-		.value = ptr_to_u64(value),
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_LOOKUP_ELEM, &attr, sizeof(attr));
-}
-
-int bpf_map_delete_elem(int fd, void *key)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_DELETE_ELEM, &attr, sizeof(attr));
-}
-
-int bpf_map_get_next_key(int fd, void *key, void *next_key)
-{
-	union bpf_attr attr = {
-		.map_fd = fd,
-		.key = ptr_to_u64(key),
-		.next_key = ptr_to_u64(next_key),
-	};
-
-	return syscall(__NR_bpf, BPF_MAP_GET_NEXT_KEY, &attr, sizeof(attr));
-}
-
-#define ROUND_UP(x, n) (((x) + (n) - 1u) & ~((n) - 1u))
-
-int bpf_load_program(enum bpf_prog_type prog_type,
-		     const struct bpf_insn *insns, int prog_len,
-		     const char *license, int kern_version,
-		     char *log_buf, size_t log_buf_sz)
-{
-	union bpf_attr attr = {
-		.prog_type = prog_type,
-		.insns = ptr_to_u64((void *) insns),
-		.insn_cnt = prog_len / sizeof(struct bpf_insn),
-		.license = ptr_to_u64((void *) license),
-		.log_buf = ptr_to_u64(log_buf),
-		.log_size = log_buf_sz,
-		.log_level = 1,
-	};
-
-	/* assign one field outside of struct init to make sure any
-	 * padding is zero initialized
-	 */
-	attr.kern_version = kern_version;
-
-	log_buf[0] = 0;
-
-	return syscall(__NR_bpf, BPF_PROG_LOAD, &attr, sizeof(attr));
-}
-
 int bpf_prog_attach(int prog_fd, int target_fd, enum bpf_attach_type type)
 {
 	union bpf_attr attr = {
@@ -124,25 +32,6 @@ int bpf_prog_detach(int target_fd, enum bpf_attach_type type)
 	return syscall(__NR_bpf, BPF_PROG_DETACH, &attr, sizeof(attr));
 }
 
-int bpf_obj_pin(int fd, const char *pathname)
-{
-	union bpf_attr attr = {
-		.pathname	= ptr_to_u64((void *)pathname),
-		.bpf_fd		= fd,
-	};
-
-	return syscall(__NR_bpf, BPF_OBJ_PIN, &attr, sizeof(attr));
-}
-
-int bpf_obj_get(const char *pathname)
-{
-	union bpf_attr attr = {
-		.pathname	= ptr_to_u64((void *)pathname),
-	};
-
-	return syscall(__NR_bpf, BPF_OBJ_GET, &attr, sizeof(attr));
-}
-
 int open_raw_sock(const char *name)
 {
 	struct sockaddr_ll sll;
diff --git a/samples/bpf/libbpf.h b/samples/bpf/libbpf.h
index 20e3457857ca..cf7d2386d1f9 100644
--- a/samples/bpf/libbpf.h
+++ b/samples/bpf/libbpf.h
@@ -2,28 +2,13 @@
 #ifndef __LIBBPF_H
 #define __LIBBPF_H
 
-struct bpf_insn;
-
-int bpf_create_map(enum bpf_map_type map_type, int key_size, int value_size,
-		   int max_entries, int map_flags);
-int bpf_map_update_elem(int fd, void *key, void *value, unsigned long long flags);
-int bpf_map_lookup_elem(int fd, void *key, void *value);
-int bpf_map_delete_elem(int fd, void *key);
-int bpf_map_get_next_key(int fd, void *key, void *next_key);
+#include <bpf/bpf.h>
 
-int bpf_load_program(enum bpf_prog_type prog_type,
-		     const struct bpf_insn *insns, int insn_len,
-		     const char *license, int kern_version,
-		     char *log_buf, size_t log_buf_sz);
+struct bpf_insn;
 
 int bpf_prog_attach(int prog_fd, int attachable_fd, enum bpf_attach_type type);
 int bpf_prog_detach(int attachable_fd, enum bpf_attach_type type);
 
-int bpf_obj_pin(int fd, const char *pathname);
-int bpf_obj_get(const char *pathname);
-
-#define BPF_LOG_BUF_SIZE (256 * 1024)
-
 /* ALU ops on registers, bpf_add|sub|...: dst_reg += src_reg */
 
 #define BPF_ALU64_REG(OP, DST, SRC)				\
diff --git a/samples/bpf/sock_example.c b/samples/bpf/sock_example.c
index d6b91e9a38ad..5546f8aac37e 100644
--- a/samples/bpf/sock_example.c
+++ b/samples/bpf/sock_example.c
@@ -56,8 +56,9 @@ static int test_sock(void)
 		BPF_MOV64_IMM(BPF_REG_0, 0), /* r0 = 0 */
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
-	prog_fd = bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER, prog, sizeof(prog),
+	prog_fd = bpf_load_program(BPF_PROG_TYPE_SOCKET_FILTER, prog, insns_cnt,
 				   "GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
 	if (prog_fd < 0) {
 		printf("failed to load prog '%s'\n", strerror(errno));
diff --git a/samples/bpf/test_cgrp2_attach.c b/samples/bpf/test_cgrp2_attach.c
index 8283ef86d392..504058631ffc 100644
--- a/samples/bpf/test_cgrp2_attach.c
+++ b/samples/bpf/test_cgrp2_attach.c
@@ -68,9 +68,10 @@ static int prog_load(int map_fd, int verdict)
 		BPF_MOV64_IMM(BPF_REG_0, verdict), /* r0 = verdict */
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
 	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SKB,
-				prog, sizeof(prog), "GPL", 0,
+				prog, insns_cnt, "GPL", 0,
 				bpf_log_buf, BPF_LOG_BUF_SIZE);
 }
 
diff --git a/samples/bpf/test_cgrp2_attach2.c b/samples/bpf/test_cgrp2_attach2.c
index fc6092fdc3b0..6e69be37f87f 100644
--- a/samples/bpf/test_cgrp2_attach2.c
+++ b/samples/bpf/test_cgrp2_attach2.c
@@ -41,9 +41,10 @@ static int prog_load(int verdict)
 		BPF_MOV64_IMM(BPF_REG_0, verdict), /* r0 = verdict */
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
 	ret = bpf_load_program(BPF_PROG_TYPE_CGROUP_SKB,
-			       prog, sizeof(prog), "GPL", 0,
+			       prog, insns_cnt, "GPL", 0,
 			       bpf_log_buf, BPF_LOG_BUF_SIZE);
 
 	if (ret < 0) {
diff --git a/samples/bpf/test_cgrp2_sock.c b/samples/bpf/test_cgrp2_sock.c
index 43b4bde5d05c..0791b949cbe4 100644
--- a/samples/bpf/test_cgrp2_sock.c
+++ b/samples/bpf/test_cgrp2_sock.c
@@ -35,8 +35,9 @@ static int prog_load(int idx)
 		BPF_MOV64_IMM(BPF_REG_0, 1), /* r0 = verdict */
 		BPF_EXIT_INSN(),
 	};
+	size_t insns_cnt = sizeof(prog) / sizeof(struct bpf_insn);
 
-	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SOCK, prog, sizeof(prog),
+	return bpf_load_program(BPF_PROG_TYPE_CGROUP_SOCK, prog, insns_cnt,
 				"GPL", 0, bpf_log_buf, BPF_LOG_BUF_SIZE);
 }
 
-- 
2.9.3
