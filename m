From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net] bpf: rather use get_random_int for randomizations
Date: Wed, 18 May 2016 14:14:28 +0200
Message-ID: <24461974e8402395c12b3e36b9ac7935b88ef1c2.1463572456.git.daniel@iogearbox.net>
Cc: hannes@stressinduktion.org, alexei.starovoitov@gmail.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57807 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750790AbcERMOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2016 08:14:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Start address randomization and blinding in BPF currently use
prandom_u32(). prandom_u32() values are not exposed to unpriviledged
user space to my knowledge, but given other kernel facilities such as
ASLR, stack canaries, etc make use of stronger get_random_int(), we
better make use of it here as well given blinding requests successively
new random values. get_random_int() has minimal entropy pool depletion,
is not cryptographically secure, but doesn't need to be for our use
cases here.

Suggested-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/core.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index f1e8a0d..b94a365 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -231,7 +231,7 @@ bpf_jit_binary_alloc(unsigned int proglen, u8 **image_ptr,
 	hdr->pages = size / PAGE_SIZE;
 	hole = min_t(unsigned int, size - (proglen + sizeof(*hdr)),
 		     PAGE_SIZE - sizeof(*hdr));
-	start = (prandom_u32() % hole) & ~(alignment - 1);
+	start = (get_random_int() % hole) & ~(alignment - 1);
 
 	/* Leave a random number of instructions before BPF code. */
 	*image_ptr = &hdr->image[start];
@@ -251,7 +251,7 @@ static int bpf_jit_blind_insn(const struct bpf_insn *from,
 			      struct bpf_insn *to_buff)
 {
 	struct bpf_insn *to = to_buff;
-	u32 imm_rnd = prandom_u32();
+	u32 imm_rnd = get_random_int();
 	s16 off;
 
 	BUILD_BUG_ON(BPF_REG_AX  + 1 != MAX_BPF_JIT_REG);
-- 
1.9.3
