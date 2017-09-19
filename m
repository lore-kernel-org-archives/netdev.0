From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net v2] bpf: fix ri->map_owner pointer on bpf_prog_realloc
Date: Wed, 20 Sep 2017 00:44:21 +0200
Message-ID: <19ba0964a02127c74fbf6fb41f06ab68117d9989.1505860401.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@kernel.org, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38538 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdISWoi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 18:44:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 109980b894e9 ("bpf: don't select potentially stale
ri->map from buggy xdp progs") passed the pointer to the prog
itself to be loaded into r4 prior on bpf_redirect_map() helper
call, so that we can store the owner into ri->map_owner out of
the helper.

Issue with that is that the actual address of the prog is still
subject to change when subsequent rewrites occur that require
slow path in bpf_prog_realloc() to alloc more memory, e.g. from
patching inlining helper functions or constant blinding. Thus,
we really need to take prog->aux as the address we're holding,
which also works with prog clones as they share the same aux
object.

Instead of then fetching aux->prog during runtime, which could
potentially incur cache misses due to false sharing, we are
going to just use aux for comparison on the map owner. This
will also keep the patchlet of the same size, and later check
in xdp_map_invalid() only accesses read-only aux pointer from
the prog, it's also in the same cacheline already from prior
access when calling bpf_func.

Fixes: 109980b894e9 ("bpf: don't select potentially stale ri->map from buggy xdp progs")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 v1->v2:
  - Decided to go with prog->aux instead.

 kernel/bpf/verifier.c |  7 ++++++-
 net/core/filter.c     | 24 +++++++++++++++---------
 2 files changed, 21 insertions(+), 10 deletions(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 799b245..b914fbe 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -4205,7 +4205,12 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 		}
 
 		if (insn->imm == BPF_FUNC_redirect_map) {
-			u64 addr = (unsigned long)prog;
+			/* Note, we cannot use prog directly as imm as subsequent
+			 * rewrites would still change the prog pointer. The only
+			 * stable address we can use is aux, which also works with
+			 * prog clones during blinding.
+			 */
+			u64 addr = (unsigned long)prog->aux;
 			struct bpf_insn r4_ld[] = {
 				BPF_LD_IMM64(BPF_REG_4, addr),
 				*insn,
diff --git a/net/core/filter.c b/net/core/filter.c
index 24dd33d..82edad5 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1794,7 +1794,7 @@ struct redirect_info {
 	u32 flags;
 	struct bpf_map *map;
 	struct bpf_map *map_to_flush;
-	const struct bpf_prog *map_owner;
+	unsigned long   map_owner;
 };
 
 static DEFINE_PER_CPU(struct redirect_info, redirect_info);
@@ -2500,11 +2500,17 @@ void xdp_do_flush_map(void)
 }
 EXPORT_SYMBOL_GPL(xdp_do_flush_map);
 
+static inline bool xdp_map_invalid(const struct bpf_prog *xdp_prog,
+				   unsigned long aux)
+{
+	return (unsigned long)xdp_prog->aux != aux;
+}
+
 static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 			       struct bpf_prog *xdp_prog)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
-	const struct bpf_prog *map_owner = ri->map_owner;
+	unsigned long map_owner = ri->map_owner;
 	struct bpf_map *map = ri->map;
 	struct net_device *fwd = NULL;
 	u32 index = ri->ifindex;
@@ -2512,9 +2518,9 @@ static int xdp_do_redirect_map(struct net_device *dev, struct xdp_buff *xdp,
 
 	ri->ifindex = 0;
 	ri->map = NULL;
-	ri->map_owner = NULL;
+	ri->map_owner = 0;
 
-	if (unlikely(map_owner != xdp_prog)) {
+	if (unlikely(xdp_map_invalid(xdp_prog, map_owner))) {
 		err = -EFAULT;
 		map = NULL;
 		goto err;
@@ -2574,7 +2580,7 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 			    struct bpf_prog *xdp_prog)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
-	const struct bpf_prog *map_owner = ri->map_owner;
+	unsigned long map_owner = ri->map_owner;
 	struct bpf_map *map = ri->map;
 	struct net_device *fwd = NULL;
 	u32 index = ri->ifindex;
@@ -2583,10 +2589,10 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 
 	ri->ifindex = 0;
 	ri->map = NULL;
-	ri->map_owner = NULL;
+	ri->map_owner = 0;
 
 	if (map) {
-		if (unlikely(map_owner != xdp_prog)) {
+		if (unlikely(xdp_map_invalid(xdp_prog, map_owner))) {
 			err = -EFAULT;
 			map = NULL;
 			goto err;
@@ -2632,7 +2638,7 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 	ri->ifindex = ifindex;
 	ri->flags = flags;
 	ri->map = NULL;
-	ri->map_owner = NULL;
+	ri->map_owner = 0;
 
 	return XDP_REDIRECT;
 }
@@ -2646,7 +2652,7 @@ int xdp_do_generic_redirect(struct net_device *dev, struct sk_buff *skb,
 };
 
 BPF_CALL_4(bpf_xdp_redirect_map, struct bpf_map *, map, u32, ifindex, u64, flags,
-	   const struct bpf_prog *, map_owner)
+	   unsigned long, map_owner)
 {
 	struct redirect_info *ri = this_cpu_ptr(&redirect_info);
 
-- 
1.9.3
