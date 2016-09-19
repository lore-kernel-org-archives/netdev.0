From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/3] bpf, verifier: enforce larger zero range for pkt on overloading stack buffs
Date: Tue, 20 Sep 2016 00:26:12 +0200
Message-ID: <38d9d2062be58c2fbc4407c8c2a3f2842fd49bc4.1474323281.git.daniel@iogearbox.net>
References: <cover.1474323281.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, tgraf@suug.ch,
        jakub.kicinski@netronome.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49347 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752504AbcISW01 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Sep 2016 18:26:27 -0400
In-Reply-To: <cover.1474323281.git.daniel@iogearbox.net>
In-Reply-To: <cover.1474323281.git.daniel@iogearbox.net>
References: <cover.1474323281.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Current contract for the following two helper argument types is:

  * ARG_CONST_STACK_SIZE: passed argument pair must be (ptr, >0).
  * ARG_CONST_STACK_SIZE_OR_ZERO: passed argument pair can be either
    (NULL, 0) or (ptr, >0).

With 6841de8b0d03 ("bpf: allow helpers access the packet directly"), we can
pass also raw packet data to helpers, so depending on the argument type
being PTR_TO_PACKET, we now either assert memory via check_packet_access()
or check_stack_boundary(). As a result, the tests in check_packet_access()
currently allow more than intended with regards to reg->imm.

Back in 969bf05eb3ce ("bpf: direct packet access"), check_packet_access()
was fine to ignore size argument since in check_mem_access() size was
bpf_size_to_bytes() derived and prior to the call to check_packet_access()
guaranteed to be larger than zero.

However, for the above two argument types, it currently means, we can have
a <= 0 size and thus breaking current guarantees for helpers. Enforce a
check for size <= 0 and bail out if so.

check_stack_boundary() doesn't have such an issue since it already tests
for access_size <= 0 and bails out, resp. access_size == 0 in case of NULL
pointer passed when allowed.

Fixes: 6841de8b0d03 ("bpf: allow helpers access the packet directly")
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 Affected commit sits in net-next only.

 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 90493a6..bc138f3 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -671,7 +671,7 @@ static int check_packet_access(struct verifier_env *env, u32 regno, int off,
 	struct reg_state *reg = &regs[regno];
 
 	off += reg->off;
-	if (off < 0 || off + size > reg->range) {
+	if (off < 0 || size <= 0 || off + size > reg->range) {
 		verbose("invalid access to packet, off=%d size=%d, R%d(id=%d,off=%d,r=%d)\n",
 			off, size, regno, reg->id, reg->off, reg->range);
 		return -EACCES;
-- 
1.9.3
