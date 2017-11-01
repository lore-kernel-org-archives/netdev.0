From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [RFC 03/12] bpf: report offload info to user space
Date: Tue, 31 Oct 2017 18:52:08 -0700
Message-ID: <20171101015217.10666-4-jakub.kicinski@netronome.com>
References: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, bblanco@gmail.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:55361 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932892AbdKABxB (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2017 21:53:01 -0400
Received: by mail-pg0-f66.google.com with SMTP id 15so778314pgc.12
        for <netdev@vger.kernel.org>; Tue, 31 Oct 2017 18:53:01 -0700 (PDT)
In-Reply-To: <20171101015217.10666-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Extend struct bpf_prog_info to contain information about program
being bound to a device.  Since the netdev may get destroyed while
program still exists we need a flag to indicate the program is
loaded for a device, even if the device is gone.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Quentin Monnet <quentin.monnet@netronome.com>
---
 include/linux/bpf.h      |  1 +
 include/uapi/linux/bpf.h |  6 ++++++
 kernel/bpf/offload.c     | 12 ++++++++++++
 kernel/bpf/syscall.c     |  5 +++++
 4 files changed, 24 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index e45d43f9ec92..98bacd0fa5cc 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -506,6 +506,7 @@ static inline int cpu_map_enqueue(struct bpf_cpu_map_entry *rcpu,
 
 int bpf_prog_offload_compile(struct bpf_prog *prog);
 void bpf_prog_offload_destroy(struct bpf_prog *prog);
+u32 bpf_prog_offload_ifindex(struct bpf_prog *prog);
 
 #if defined(CONFIG_NET) && defined(CONFIG_BPF_SYSCALL)
 int bpf_prog_offload_init(struct bpf_prog *prog, union bpf_attr *attr);
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index d6775e0da8a5..b6f34204cd2e 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -896,6 +896,10 @@ enum sk_action {
 
 #define BPF_TAG_SIZE	8
 
+enum bpf_prog_status {
+	BPF_PROG_STATUS_DEV_BOUND	= (1 << 0),
+};
+
 struct bpf_prog_info {
 	__u32 type;
 	__u32 id;
@@ -909,6 +913,8 @@ struct bpf_prog_info {
 	__u32 nr_map_ids;
 	__aligned_u64 map_ids;
 	char name[BPF_OBJ_NAME_LEN];
+	__u32 ifindex;
+	__u32 status;
 } __attribute__((aligned(8)));
 
 struct bpf_map_info {
diff --git a/kernel/bpf/offload.c b/kernel/bpf/offload.c
index 0287cd52287d..d46b7c1eb768 100644
--- a/kernel/bpf/offload.c
+++ b/kernel/bpf/offload.c
@@ -144,6 +144,18 @@ int bpf_prog_offload_compile(struct bpf_prog *prog)
 	return bpf_prog_offload_translate(prog);
 }
 
+u32 bpf_prog_offload_ifindex(struct bpf_prog *prog)
+{
+	struct bpf_dev_offload *offload = prog->aux->offload;
+	u32 ifindex;
+
+	rtnl_lock();
+	ifindex = offload->netdev ? offload->netdev->ifindex : 0;
+	rtnl_unlock();
+
+	return ifindex;
+}
+
 const struct bpf_prog_ops bpf_offload_prog_ops = {
 };
 
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index a806b10b9235..6712df2aa057 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -1592,6 +1592,11 @@ static int bpf_prog_get_info_by_fd(struct bpf_prog *prog,
 			return -EFAULT;
 	}
 
+	if (bpf_prog_is_dev_bound(prog->aux)) {
+		info.status |= BPF_PROG_STATUS_DEV_BOUND;
+		info.ifindex = bpf_prog_offload_ifindex(prog);
+	}
+
 done:
 	if (copy_to_user(uinfo, &info, info_len) ||
 	    put_user(info_len, &uattr->info.info_len))
-- 
2.14.1
