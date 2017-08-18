From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/2] bpf: improve htab inlining for future 32 bit jits
Date: Sat, 19 Aug 2017 01:51:55 +0200
Message-ID: <a2a1360af1df20e5a11269441656b5daffabdd77.1503100047.git.daniel@iogearbox.net>
References: <cover.1503100047.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48202 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750967AbdHRXwC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 19:52:02 -0400
In-Reply-To: <cover.1503100047.git.daniel@iogearbox.net>
In-Reply-To: <cover.1503100047.git.daniel@iogearbox.net>
References: <cover.1503100047.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lets future proof htab lookup inlining, commit 9015d2f59535 ("bpf:
inline htab_map_lookup_elem()") was making the assumption that a
direct call emission to __htab_map_lookup_elem() will always work
out for JITs. This is currently true since all JITs we have are
for 64 bit archs, but in case of 32 bit JITs like upcoming arm32,
we get a NULL pointer dereference when executing the call to
__htab_map_lookup_elem() since passed arguments are of a different
size (unsigned long vs. u64 for pointers) than what we do out of
BPF. Thus, lets do a proper BPF_CALL_2() declaration such that we
don't need to make any such assumptions.

Reported-by: Shubham Bansal <illusionist.neo@gmail.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/hashtab.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/hashtab.c b/kernel/bpf/hashtab.c
index 4fb4631..cabf37b 100644
--- a/kernel/bpf/hashtab.c
+++ b/kernel/bpf/hashtab.c
@@ -437,7 +437,8 @@ static struct htab_elem *lookup_nulls_elem_raw(struct hlist_nulls_head *head,
  * The return value is adjusted by BPF instructions
  * in htab_map_gen_lookup().
  */
-static void *__htab_map_lookup_elem(struct bpf_map *map, void *key)
+static __always_inline void *__htab_map_lookup_elem(struct bpf_map *map,
+						    void *key)
 {
 	struct bpf_htab *htab = container_of(map, struct bpf_htab, map);
 	struct hlist_nulls_head *head;
@@ -479,12 +480,17 @@ static void *htab_map_lookup_elem(struct bpf_map *map, void *key)
  * bpf_prog
  *   __htab_map_lookup_elem
  */
+BPF_CALL_2(bpf_htab_lookup_helper, struct bpf_map *, map, void *, key)
+{
+	return (unsigned long) __htab_map_lookup_elem(map, key);
+}
+
 static u32 htab_map_gen_lookup(struct bpf_map *map, struct bpf_insn *insn_buf)
 {
 	struct bpf_insn *insn = insn_buf;
 	const int ret = BPF_REG_0;
 
-	*insn++ = BPF_EMIT_CALL((u64 (*)(u64, u64, u64, u64, u64))__htab_map_lookup_elem);
+	*insn++ = BPF_EMIT_CALL(bpf_htab_lookup_helper);
 	*insn++ = BPF_JMP_IMM(BPF_JEQ, ret, 0, 1);
 	*insn++ = BPF_ALU64_IMM(BPF_ADD, ret,
 				offsetof(struct htab_elem, key) +
-- 
1.9.3
