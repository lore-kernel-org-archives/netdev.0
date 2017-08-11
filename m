From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net 2/2] bpf: fix two missing target_size settings in bpf_convert_ctx_access
Date: Fri, 11 Aug 2017 18:31:25 +0200
Message-ID: <2ab20524b90c301ec3f9dc0f30ad56785f7f3fae.1502468639.git.daniel@iogearbox.net>
References: <cover.1502468639.git.daniel@iogearbox.net>
Cc: ast@fb.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41698 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753665AbdHKQbc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 11 Aug 2017 12:31:32 -0400
In-Reply-To: <cover.1502468639.git.daniel@iogearbox.net>
In-Reply-To: <cover.1502468639.git.daniel@iogearbox.net>
References: <cover.1502468639.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When CONFIG_NET_SCHED or CONFIG_NET_RX_BUSY_POLL is /not/ set and
we try a narrow __sk_buff load of tc_index or napi_id, respectively,
then verifier rightfully complains that it's misconfigured, because
we need to set target_size in each of the two cases. The rewrite
for the ctx access is just a dummy op, but needs to pass, so fix
this up.

Fixes: f96da09473b5 ("bpf: simplify narrower ctx access")
Reported-by: Shubham Bansal <illusionist.neo@gmail.com>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 net/core/filter.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/filter.c b/net/core/filter.c
index f44fc22..6280a60 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -3505,6 +3505,7 @@ static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 					      bpf_target_off(struct sk_buff, tc_index, 2,
 							     target_size));
 #else
+		*target_size = 2;
 		if (type == BPF_WRITE)
 			*insn++ = BPF_MOV64_REG(si->dst_reg, si->dst_reg);
 		else
@@ -3520,6 +3521,7 @@ static u32 bpf_convert_ctx_access(enum bpf_access_type type,
 		*insn++ = BPF_JMP_IMM(BPF_JGE, si->dst_reg, MIN_NAPI_ID, 1);
 		*insn++ = BPF_MOV64_IMM(si->dst_reg, 0);
 #else
+		*target_size = 4;
 		*insn++ = BPF_MOV64_IMM(si->dst_reg, 0);
 #endif
 		break;
-- 
1.9.3
