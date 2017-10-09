From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next v2 6/7] bpf: don't rely on the verifier lock for metadata_dst allocation
Date: Mon,  9 Oct 2017 10:30:14 -0700
Message-ID: <20171009173015.23520-7-jakub.kicinski@netronome.com>
References: <20171009173015.23520-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com, alexei.starovoitov@gmail.com,
        daniel@iogearbox.net, Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f178.google.com ([209.85.192.178]:51886 "EHLO
        mail-pf0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755005AbdJIRac (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 13:30:32 -0400
Received: by mail-pf0-f178.google.com with SMTP id n14so12538397pfh.8
        for <netdev@vger.kernel.org>; Mon, 09 Oct 2017 10:30:32 -0700 (PDT)
In-Reply-To: <20171009173015.23520-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bpf_skb_set_tunnel_*() functions require allocation of per-cpu
metadata_dst.  The allocation happens upon verification of the
first program using those helpers.  In preparation for removing
the verifier lock, use cmpxchg() to make sure we only allocate
the metadata_dsts once.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
Reviewed-by: Simon Horman <simon.horman@netronome.com>
Acked-by: Alexei Starovoitov <ast@kernel.org>
Acked-by: Daniel Borkmann <daniel@iogearbox.net>
---
 include/net/dst_metadata.h |  1 +
 net/core/dst.c             | 16 ++++++++++++++++
 net/core/filter.c          | 16 +++++++++-------
 3 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
index 9fba2ebf6dda..87a0bb8d449f 100644
--- a/include/net/dst_metadata.h
+++ b/include/net/dst_metadata.h
@@ -87,6 +87,7 @@ static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
 void metadata_dst_free(struct metadata_dst *);
 struct metadata_dst *metadata_dst_alloc(u8 optslen, enum metadata_type type,
 					gfp_t flags);
+void metadata_dst_free_percpu(struct metadata_dst __percpu *md_dst);
 struct metadata_dst __percpu *
 metadata_dst_alloc_percpu(u8 optslen, enum metadata_type type, gfp_t flags);
 
diff --git a/net/core/dst.c b/net/core/dst.c
index a6c47da7d0f8..8b2eafac984d 100644
--- a/net/core/dst.c
+++ b/net/core/dst.c
@@ -322,3 +322,19 @@ metadata_dst_alloc_percpu(u8 optslen, enum metadata_type type, gfp_t flags)
 	return md_dst;
 }
 EXPORT_SYMBOL_GPL(metadata_dst_alloc_percpu);
+
+void metadata_dst_free_percpu(struct metadata_dst __percpu *md_dst)
+{
+	int cpu;
+
+#ifdef CONFIG_DST_CACHE
+	for_each_possible_cpu(cpu) {
+		struct metadata_dst *one_md_dst = per_cpu_ptr(md_dst, cpu);
+
+		if (one_md_dst->type == METADATA_IP_TUNNEL)
+			dst_cache_destroy(&one_md_dst->u.tun_info.dst_cache);
+	}
+#endif
+	free_percpu(md_dst);
+}
+EXPORT_SYMBOL_GPL(metadata_dst_free_percpu);
diff --git a/net/core/filter.c b/net/core/filter.c
index b7e8caa1e790..140fa9f9c0f4 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -43,6 +43,7 @@
 #include <linux/timer.h>
 #include <linux/uaccess.h>
 #include <asm/unaligned.h>
+#include <asm/cmpxchg.h>
 #include <linux/filter.h>
 #include <linux/ratelimit.h>
 #include <linux/seccomp.h>
@@ -2987,14 +2988,15 @@ static const struct bpf_func_proto *
 bpf_get_skb_set_tunnel_proto(enum bpf_func_id which)
 {
 	if (!md_dst) {
-		/* Race is not possible, since it's called from verifier
-		 * that is holding verifier mutex.
-		 */
-		md_dst = metadata_dst_alloc_percpu(IP_TUNNEL_OPTS_MAX,
-						   METADATA_IP_TUNNEL,
-						   GFP_KERNEL);
-		if (!md_dst)
+		struct metadata_dst __percpu *tmp;
+
+		tmp = metadata_dst_alloc_percpu(IP_TUNNEL_OPTS_MAX,
+						METADATA_IP_TUNNEL,
+						GFP_KERNEL);
+		if (!tmp)
 			return NULL;
+		if (cmpxchg(&md_dst, NULL, tmp))
+			metadata_dst_free_percpu(tmp);
 	}
 
 	switch (which) {
-- 
2.14.1
