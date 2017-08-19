From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/2] bpf: make htab inlining more robust wrt assumptions
Date: Sat, 19 Aug 2017 03:12:45 +0200
Message-ID: <03f4e86a029058d0f674fd9bf288e55a5ec07df3.1503104831.git.daniel@iogearbox.net>
References: <cover.1503104831.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57141 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751054AbdHSBMw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 21:12:52 -0400
In-Reply-To: <cover.1503104831.git.daniel@iogearbox.net>
In-Reply-To: <cover.1503104831.git.daniel@iogearbox.net>
References: <cover.1503104831.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit 9015d2f59535 ("bpf: inline htab_map_lookup_elem()") was
making the assumption that a direct call emission to the function
__htab_map_lookup_elem() will always work out for JITs.

This is currently true since all JITs we have are for 64 bit archs,
but in case of 32 bit JITs like upcoming arm32, we get a NULL pointer
dereference when executing the call to __htab_map_lookup_elem()
since passed arguments are of a different size (due to pointer args)
than what we do out of BPF. Guard and thus limit this for now for
the current 64 bit JITs only.

Reported-by: Shubham Bansal <illusionist.neo@gmail.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/verifier.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 4f6e7eb..e42c096 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -4160,7 +4160,11 @@ static int fixup_bpf_calls(struct bpf_verifier_env *env)
 			continue;
 		}
 
-		if (ebpf_jit_enabled() && insn->imm == BPF_FUNC_map_lookup_elem) {
+		/* BPF_EMIT_CALL() assumptions in some of the map_gen_lookup
+		 * handlers are currently limited to 64 bit only.
+		 */
+		if (ebpf_jit_enabled() && BITS_PER_LONG == 64 &&
+		    insn->imm == BPF_FUNC_map_lookup_elem) {
 			map_ptr = env->insn_aux_data[i + delta].map_ptr;
 			if (map_ptr == BPF_MAP_PTR_POISON ||
 			    !map_ptr->ops->map_gen_lookup)
-- 
1.9.3
