From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] ebpf: add prandom helper for packet sampling
Date: Fri, 13 Mar 2015 14:22:03 +0100
Message-ID: <83348b7717b2f044140539fc7faa36bebcc3da58.1426249641.git.daniel@iogearbox.net>
References: <cover.1426249641.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59361 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751093AbbCMNWK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2015 09:22:10 -0400
In-Reply-To: <cover.1426249641.git.daniel@iogearbox.net>
In-Reply-To: <cover.1426249641.git.daniel@iogearbox.net>
References: <cover.1426249641.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This work is similar to commit 4cd3675ebf74 ("filter: added BPF
random opcode") and adds a possibility for packet sampling in eBPF.

Currently, this is only possible in classic BPF and useful to
combine sampling with f.e. packet sockets, possible also with tc.

Given classic BPF operates in 32bit space only, we leave the
option to the eBPF application developer whether he needs a single
or double word wide random number since eBPF is in 64bit space.

Example function proto-type looks like:

  static u64 (*get_rnd)(bool dw) = (void *) BPF_FUNC_random;

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/bpf.h      |  2 ++
 include/uapi/linux/bpf.h |  1 +
 kernel/bpf/core.c        |  2 ++
 kernel/bpf/helpers.c     | 13 +++++++++++++
 net/core/filter.c        |  2 ++
 5 files changed, 20 insertions(+)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 80f2e0f..6da2145 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -154,4 +154,6 @@ extern const struct bpf_func_proto bpf_map_lookup_elem_proto;
 extern const struct bpf_func_proto bpf_map_update_elem_proto;
 extern const struct bpf_func_proto bpf_map_delete_elem_proto;
 
+extern const struct bpf_func_proto bpf_random_proto;
+
 #endif /* _LINUX_BPF_H */
diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 3fa1af8..4efc41f 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -165,6 +165,7 @@ enum bpf_func_id {
 	BPF_FUNC_map_lookup_elem, /* void *map_lookup_elem(&map, &key) */
 	BPF_FUNC_map_update_elem, /* int map_update_elem(&map, &key, &value, flags) */
 	BPF_FUNC_map_delete_elem, /* int map_delete_elem(&map, &key) */
+	BPF_FUNC_random,	  /* prandom() as u32 or u64 */
 	__BPF_FUNC_MAX_ID,
 };
 
diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 50603ae..cc1f3f8 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -661,6 +661,8 @@ const struct bpf_func_proto bpf_map_lookup_elem_proto __weak;
 const struct bpf_func_proto bpf_map_update_elem_proto __weak;
 const struct bpf_func_proto bpf_map_delete_elem_proto __weak;
 
+const struct bpf_func_proto bpf_random_proto __weak;
+
 /* To execute LD_ABS/LD_IND instructions __bpf_prog_run() may call
  * skb_copy_bits(), so provide a weak definition of it for NET-less config.
  */
diff --git a/kernel/bpf/helpers.c b/kernel/bpf/helpers.c
index a3c7701..9b0e6eb 100644
--- a/kernel/bpf/helpers.c
+++ b/kernel/bpf/helpers.c
@@ -11,6 +11,7 @@
  */
 #include <linux/bpf.h>
 #include <linux/rcupdate.h>
+#include <linux/random.h>
 
 /* If kernel subsystem is allowing eBPF programs to call this function,
  * inside its own verifier_ops->get_func_proto() callback it should return
@@ -87,3 +88,15 @@ const struct bpf_func_proto bpf_map_delete_elem_proto = {
 	.arg1_type = ARG_CONST_MAP_PTR,
 	.arg2_type = ARG_PTR_TO_MAP_KEY,
 };
+
+static u64 bpf_random(u64 dw, u64 r2, u64 r3, u64 r4, u64 r5)
+{
+	return prandom_u32() | (dw ? ((u64)prandom_u32() << 32) : 0);
+}
+
+const struct bpf_func_proto bpf_random_proto = {
+	.func		= bpf_random,
+	.gpl_only	= false,
+	.ret_type	= RET_INTEGER,
+	.arg1_type	= ARG_ANYTHING,
+};
diff --git a/net/core/filter.c b/net/core/filter.c
index 7a4eb70..c8f1efd 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1139,6 +1139,8 @@ sk_filter_func_proto(enum bpf_func_id func_id)
 		return &bpf_map_update_elem_proto;
 	case BPF_FUNC_map_delete_elem:
 		return &bpf_map_delete_elem_proto;
+	case BPF_FUNC_random:
+		return &bpf_random_proto;
 	default:
 		return NULL;
 	}
-- 
1.9.3
