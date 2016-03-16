From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/3] bpf: make skb->tc_classid also readable
Date: Wed, 16 Mar 2016 01:42:49 +0100
Message-ID: <73735195991a70e7b8177e9571d676f4b4a734b1.1458085814.git.daniel@iogearbox.net>
References: <cover.1458085814.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:38431 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122AbcCPAnG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2016 20:43:06 -0400
In-Reply-To: <cover.1458085814.git.daniel@iogearbox.net>
In-Reply-To: <cover.1458085814.git.daniel@iogearbox.net>
References: <cover.1458085814.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently, the tc_classid from eBPF skb context is write-only, but there's
no good reason for tc programs to limit it to write-only. For example,
it can be used to transfer its state via tail calls where the resulting
tc_classid gets filled gradually.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 net/core/filter.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 6fc3893..69c7b2f 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -2069,16 +2069,14 @@ static bool sk_filter_is_valid_access(int off, int size,
 static bool tc_cls_act_is_valid_access(int off, int size,
 				       enum bpf_access_type type)
 {
-	if (off == offsetof(struct __sk_buff, tc_classid))
-		return type == BPF_WRITE ? true : false;
-
 	if (type == BPF_WRITE) {
 		switch (off) {
 		case offsetof(struct __sk_buff, mark):
 		case offsetof(struct __sk_buff, tc_index):
 		case offsetof(struct __sk_buff, priority):
 		case offsetof(struct __sk_buff, cb[0]) ...
-			offsetof(struct __sk_buff, cb[4]):
+		     offsetof(struct __sk_buff, cb[4]):
+		case offsetof(struct __sk_buff, tc_classid):
 			break;
 		default:
 			return false;
@@ -2195,8 +2193,10 @@ static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 		ctx_off -= offsetof(struct __sk_buff, tc_classid);
 		ctx_off += offsetof(struct sk_buff, cb);
 		ctx_off += offsetof(struct qdisc_skb_cb, tc_classid);
-		WARN_ON(type != BPF_WRITE);
-		*insn++ = BPF_STX_MEM(BPF_H, dst_reg, src_reg, ctx_off);
+		if (type == BPF_WRITE)
+			*insn++ = BPF_STX_MEM(BPF_H, dst_reg, src_reg, ctx_off);
+		else
+			*insn++ = BPF_LDX_MEM(BPF_H, dst_reg, src_reg, ctx_off);
 		break;
 
 	case offsetof(struct __sk_buff, tc_index):
-- 
1.9.3
