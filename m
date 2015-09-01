From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 4/4] net: {cls,act}_bpf: make skb->priority writable
Date: Tue,  1 Sep 2015 18:34:25 +0200
Message-ID: <19fdf49b43457d6200556d64cdec08e8b1b748b6.1441123709.git.daniel@iogearbox.net>
References: <cover.1441123709.git.daniel@iogearbox.net>
Cc: john.fastabend@gmail.com, ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49548 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752649AbbIAQec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Sep 2015 12:34:32 -0400
In-Reply-To: <cover.1441123709.git.daniel@iogearbox.net>
In-Reply-To: <cover.1441123709.git.daniel@iogearbox.net>
References: <cover.1441123709.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Now with the new ->preclassify() handler in place, {cls,act}_bpf can
set the skb->priority from an eBPF program based on various critera,
so that qdiscs like mqprio can pick it up.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 3765ae1..a88ea8e 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1674,6 +1674,7 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 		switch (off) {
 		case offsetof(struct __sk_buff, mark):
 		case offsetof(struct __sk_buff, tc_index):
+		case offsetof(struct __sk_buff, priority):
 		case offsetof(struct __sk_buff, cb[0]) ...
 			offsetof(struct __sk_buff, cb[4]):
 			break;
@@ -1715,8 +1716,12 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
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
