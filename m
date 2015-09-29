From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 3/3] sched, bpf: make skb->priority writable
Date: Wed, 30 Sep 2015 01:41:52 +0200
Message-ID: <0b873b7842919655c28aa4837719ea0b3c67d726.1443567433.git.daniel@iogearbox.net>
References: <cover.1443567433.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59691 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751072AbbI2Xl6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 19:41:58 -0400
In-Reply-To: <cover.1443567433.git.daniel@iogearbox.net>
In-Reply-To: <cover.1443567433.git.daniel@iogearbox.net>
References: <cover.1443567433.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

{cls,act}_bpf can now set the skb->priority from an eBPF program based
on various critera, so that for example classful qdiscs like multiq can
update the skb's priority during enqueue time and further push it down
into subsequent qdiscs.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 45c69ce..53a5036 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1721,6 +1721,7 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 		switch (off) {
 		case offsetof(struct __sk_buff, mark):
 		case offsetof(struct __sk_buff, tc_index):
+		case offsetof(struct __sk_buff, priority):
 		case offsetof(struct __sk_buff, cb[0]) ...
 			offsetof(struct __sk_buff, cb[4]):
 			break;
@@ -1762,8 +1763,12 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 	case offsetof(struct __sk_buff, priority):
 		BUILD_BUG_ON(FIELD_SIZEOF(struct sk_buff, priority) != 4);
 
-		*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
-				      offsetof(struct sk_buff, priority));
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_W, dst_reg, src_reg,
+					      offsetof(struct sk_buff, priority));
+		else
+			*insn++ = BPF_LDX_MEM(BPF_W, dst_reg, src_reg,
+					      offsetof(struct sk_buff, priority));
 		break;
 
 	case offsetof(struct __sk_buff, ingress_ifindex):
-- 
1.9.3
