From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 6/6] bpf: show bpf programs
Date: Wed, 26 Apr 2017 20:24:19 +0200
Message-ID: <20170426182419.14574-7-hannes@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:34243 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933408AbdDZSYr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:24:47 -0400
In-Reply-To: <20170426182419.14574-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 include/uapi/linux/bpf.h | 32 +++++++++++++++++++-------------
 kernel/bpf/core.c        | 30 +++++++++++++++++++++++++++++-
 2 files changed, 48 insertions(+), 14 deletions(-)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index e553529929f683..d6506e320953d5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -101,20 +101,26 @@ enum bpf_map_type {
 	BPF_MAP_TYPE_HASH_OF_MAPS,
 };
 
+#define BPF_PROG_TYPES			\
+	X(BPF_PROG_TYPE_UNSPEC),	\
+	X(BPF_PROG_TYPE_SOCKET_FILTER),	\
+	X(BPF_PROG_TYPE_KPROBE),	\
+	X(BPF_PROG_TYPE_SCHED_CLS),	\
+	X(BPF_PROG_TYPE_SCHED_ACT),	\
+	X(BPF_PROG_TYPE_TRACEPOINT),	\
+	X(BPF_PROG_TYPE_XDP),		\
+	X(BPF_PROG_TYPE_PERF_EVENT),	\
+	X(BPF_PROG_TYPE_CGROUP_SKB),	\
+	X(BPF_PROG_TYPE_CGROUP_SOCK),	\
+	X(BPF_PROG_TYPE_LWT_IN),	\
+	X(BPF_PROG_TYPE_LWT_OUT),	\
+	X(BPF_PROG_TYPE_LWT_XMIT),
+
+
 enum bpf_prog_type {
-	BPF_PROG_TYPE_UNSPEC,
-	BPF_PROG_TYPE_SOCKET_FILTER,
-	BPF_PROG_TYPE_KPROBE,
-	BPF_PROG_TYPE_SCHED_CLS,
-	BPF_PROG_TYPE_SCHED_ACT,
-	BPF_PROG_TYPE_TRACEPOINT,
-	BPF_PROG_TYPE_XDP,
-	BPF_PROG_TYPE_PERF_EVENT,
-	BPF_PROG_TYPE_CGROUP_SKB,
-	BPF_PROG_TYPE_CGROUP_SOCK,
-	BPF_PROG_TYPE_LWT_IN,
-	BPF_PROG_TYPE_LWT_OUT,
-	BPF_PROG_TYPE_LWT_XMIT,
+#define X(type) type
+	BPF_PROG_TYPES
+#undef X
 };
 
 enum bpf_attach_type {
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 3ba175a24e971a..685c1d0f31e029 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -536,13 +536,41 @@ static void ebpf_proc_stop(struct seq_file *s, void *v)
 	rcu_read_unlock();
 }
 
+static const char *bpf_type_string(enum bpf_prog_type type)
+{
+	static const char *bpf_type_names[] = {
+#define X(type) #type
+		BPF_PROG_TYPES
+#undef X
+	};
+
+	if (type >= ARRAY_SIZE(bpf_type_names))
+		return "<unknown>";
+
+	return bpf_type_names[type];
+}
+
 static int ebpf_proc_show(struct seq_file *s, void *v)
 {
+	struct bpf_prog *prog;
+	struct bpf_prog_aux *aux;
+	char prog_tag[sizeof(prog->tag) * 2 + 1] = { };
+
 	if (v == SEQ_START_TOKEN) {
-		seq_printf(s, "# tag\n");
+		seq_printf(s, "# tag\t\t\ttype\t\t\truntime\tcap\tmemlock\n");
 		return 0;
 	}
 
+	aux = v;
+	prog = aux->prog;
+
+	bin2hex(prog_tag, prog->tag, sizeof(prog->tag));
+	seq_printf(s, "%s\t%s\t%s\t%s\t%llu\n", prog_tag,
+		   bpf_type_string(prog->type),
+		   prog->jited ? "jit" : "int",
+		   prog->priv_cap_sys_admin ? "priv" : "unpriv",
+		   prog->pages * 1ULL << PAGE_SHIFT);
+
 	return 0;
 }
 
-- 
2.9.3
