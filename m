From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] ebpf: add helper for obtaining current processor id
Date: Fri, 13 Mar 2015 14:22:04 +0100
Message-ID: <870dce5d9b480d267c8b3de77bad1875adc6016c.1426249641.git.daniel@iogearbox.net>
References: <cover.1426249641.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59363 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752117AbbCMNWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 09:22:10 -0400
In-Reply-To: <cover.1426249641.git.daniel@iogearbox.net>
In-Reply-To: <cover.1426249641.git.daniel@iogearbox.net>
References: <cover.1426249641.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the possibility to obtain raw_smp_processor_id() in
eBPF. Currently, this is only possible in classic BPF where commit
da2033c28226 ("filter: add SKF_AD_RXHASH and SKF_AD_CPU") has added
facilities for this.

Single threaded packet socket applications (f.e. tcpdump, netsniff-ng)
e.g. writing to pcap files and making use of eBPF can use this helper
function to spread flows after RPS dispatch to several instances. It
would also allow to track per CPU statistics (or data) with eBPF maps.

Example function proto-type looks like:

  unsigned int (*get_cpu_id)(void) = (void *) BPF_FUNC_cpu_id;

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      |  1 +
 include/uapi/linux/bpf.h |  1 +
 kernel/bpf/core.c        |  1 +
 kernel/bpf/helpers.c     | 12 ++++++++++++
 net/core/filter.c        |  2 ++
 5 files changed, 17 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 6da2145..28e427d 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -155,5 +155,6 @@ extern const struct bpf_func_proto bpf_map_update_elem_proto;
 extern const struct bpf_func_proto bpf_map_delete_elem_proto;
 
 extern const struct bpf_func_proto bpf_random_proto;
+extern const struct bpf_func_proto bpf_cpu_id_proto;
 
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 4efc41f..9080cf5 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -166,6 +166,7 @@ enum bpf_func_id {
 	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
 	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
 	BPF_FUNC_random,	  /* prandom() as u32 or u64 */
+	BPF_FUNC_cpu_id,	  /* raw_smp_processor_id() */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index cc1f3f8..b303cf3 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -662,6 +662,7 @@ const struct bpf_func_proto bpf_map_update_elem_proto __weak;
 const struct bpf_func_proto bpf_map_delete_elem_proto __weak;
 
 const struct bpf_func_proto bpf_random_proto __weak;
+const struct bpf_func_proto bpf_cpu_id_proto __weak;
 
 /* To execute LD_ABS/LD_IND instructions __bpf_prog_run() may call
  * skb_copy_bits(), so provide a weak definition of it for NET-less config.
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index 9b0e6eb..ba7fab6 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -12,6 +12,7 @@
 #include <linux/bpf.h>
 #include <linux/rcupdate.h>
 #include <linux/random.h>
+#include <linux/smp.h>
 
 /* If kernel subsystem is allowing eBPF programs to call this function,
  * inside its own verifier_ops->get_func_proto() callback it should return
@@ -100,3 +101,14 @@ const struct bpf_func_proto bpf_random_proto = {
 	.ret_type	= RET_INTEGER,
 	.arg1_type	= ARG_ANYTHING,
 };
+
+static u64 bpf_cpu_id(u64 r1, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return raw_smp_processor_id();
+}
+
+const struct bpf_func_proto bpf_cpu_id_proto = {
+	.func		= bpf_cpu_id,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+};
diff --git a/net/core/filter.c b/net/core/filter.c
index c8f1efd..1643521 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1141,6 +1141,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 		return &bpf_map_delete_elem_proto;
 	case BPF_FUNC_random:
 		return &bpf_random_proto;
+	case BPF_FUNC_cpu_id:
+		return &bpf_cpu_id_proto;
 	default:
 		return NULL;
 	}
-- 
1.9.3
