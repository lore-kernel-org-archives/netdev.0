From: "Naveen N. Rao" <naveen.n.rao@linux.vnet.ibm.com>
Subject: [PATCH 2/2] bpf samples: update tracex5 sample to use __seccomp_filter
Date: Sat, 24 Sep 2016 02:10:05 +0530
Message-ID: <8e5ab9853508240e901260b1af36243c4d744083.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
References: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
Cc: "Michael Ellerman" <mpe@ellerman.id.au>,
        "Alexei Starovoitov" <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "Ananth N Mavinakayanahalli" <ananth@in.ibm.com>
To: linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:32950 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1758970AbcIWUlS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 16:41:18 -0400
Received: from pps.filterd (m0098416.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8NKWtw3100580
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 16:41:17 -0400
Received: from e23smtp01.au.ibm.com (e23smtp01.au.ibm.com [202.81.31.143])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25mqb61a6w-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 16:41:17 -0400
Received: from localhost
        by e23smtp01.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <naveen.n.rao@linux.vnet.ibm.com>;
        Sat, 24 Sep 2016 06:41:14 +1000
In-Reply-To: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
In-Reply-To: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
References: <7b29fba6073924dc4c9e7d639eefb0b15a98660d.1474661952.git.naveen.n.rao@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

seccomp_phase1() does not exist anymore. Instead, update sample to use
__seccomp_filter(). While at it, set max locked memory to unlimited.

Signed-off-by: Naveen N. Rao <naveen.n.rao@linux.vnet.ibm.com>
---
I am not completely sure if __seccomp_filter is the right place to hook
in. This works for me though. Please review.

Thanks,
Naveen


 samples/bpf/tracex5_kern.c | 16 +++++++---------
 samples/bpf/tracex5_user.c |  3 +++
 2 files changed, 10 insertions(+), 9 deletions(-)

diff --git a/samples/bpf/tracex5_kern.c b/samples/bpf/tracex5_kern.c
index f95f232..fd12d71 100644
--- a/samples/bpf/tracex5_kern.c
+++ b/samples/bpf/tracex5_kern.c
@@ -19,20 +19,18 @@ struct bpf_map_def SEC("maps") progs = {
 	.max_entries = 1024,
 };
 
-SEC("kprobe/seccomp_phase1")
+SEC("kprobe/__seccomp_filter")
 int bpf_prog1(struct pt_regs *ctx)
 {
-	struct seccomp_data sd;
-
-	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM1(ctx));
+	int sc_nr = (int)PT_REGS_PARM1(ctx);
 
 	/* dispatch into next BPF program depending on syscall number */
-	bpf_tail_call(ctx, &progs, sd.nr);
+	bpf_tail_call(ctx, &progs, sc_nr);
 
 	/* fall through -> unknown syscall */
-	if (sd.nr >= __NR_getuid && sd.nr <= __NR_getsid) {
+	if (sc_nr >= __NR_getuid && sc_nr <= __NR_getsid) {
 		char fmt[] = "syscall=%d (one of get/set uid/pid/gid)\n";
-		bpf_trace_printk(fmt, sizeof(fmt), sd.nr);
+		bpf_trace_printk(fmt, sizeof(fmt), sc_nr);
 	}
 	return 0;
 }
@@ -42,7 +40,7 @@ PROG(__NR_write)(struct pt_regs *ctx)
 {
 	struct seccomp_data sd;
 
-	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM1(ctx));
+	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM2(ctx));
 	if (sd.args[2] == 512) {
 		char fmt[] = "write(fd=%d, buf=%p, size=%d)\n";
 		bpf_trace_printk(fmt, sizeof(fmt),
@@ -55,7 +53,7 @@ PROG(__NR_read)(struct pt_regs *ctx)
 {
 	struct seccomp_data sd;
 
-	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM1(ctx));
+	bpf_probe_read(&sd, sizeof(sd), (void *)PT_REGS_PARM2(ctx));
 	if (sd.args[2] > 128 && sd.args[2] <= 1024) {
 		char fmt[] = "read(fd=%d, buf=%p, size=%d)\n";
 		bpf_trace_printk(fmt, sizeof(fmt),
diff --git a/samples/bpf/tracex5_user.c b/samples/bpf/tracex5_user.c
index a04dd3c..36b5925 100644
--- a/samples/bpf/tracex5_user.c
+++ b/samples/bpf/tracex5_user.c
@@ -6,6 +6,7 @@
 #include <sys/prctl.h>
 #include "libbpf.h"
 #include "bpf_load.h"
+#include <sys/resource.h>
 
 /* install fake seccomp program to enable seccomp code path inside the kernel,
  * so that our kprobe attached to seccomp_phase1() can be triggered
@@ -27,8 +28,10 @@ int main(int ac, char **argv)
 {
 	FILE *f;
 	char filename[256];
+	struct rlimit r = {RLIM_INFINITY, RLIM_INFINITY};
 
 	snprintf(filename, sizeof(filename), "%s_kern.o", argv[0]);
+	setrlimit(RLIMIT_MEMLOCK, &r);
 
 	if (load_bpf_file(filename)) {
 		printf("%s", bpf_log_buf);
-- 
2.9.3
