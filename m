From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 5/8] net: bpf: add neq jump operations to bpf machine
Date: Mon, 31 Dec 2012 14:59:45 +0100
Message-ID: <ce1ddcbf8c0effcfa561b224630e3645504a6ad4.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:45562 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751286Ab2LaN77 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 08:59:59 -0500
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds jump operations for neq (!=) that compare A
with K resp. X in order to facilitate filter programming with
conditional jumps, since currently only eq (==) is present in
the BPF machine. For user-space filter programming / compilers,
it might be good to also have this complementary operation.
They don't need to be as ancillary, since they fit into the
instruction encoding directly. Follow-up BPF JIT patches are
welcomed.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/filter.h      |  2 ++
 include/uapi/linux/filter.h |  1 +
 net/core/filter.c           | 14 ++++++++++++++
 3 files changed, 17 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 36630bc..256c01f 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -105,6 +105,8 @@ enum {
 	BPF_S_JMP_JA,
 	BPF_S_JMP_JEQ_K,
 	BPF_S_JMP_JEQ_X,
+	BPF_S_JMP_JNEQ_K,
+	BPF_S_JMP_JNEQ_X,
 	BPF_S_JMP_JGE_K,
 	BPF_S_JMP_JGE_X,
 	BPF_S_JMP_JGT_K,
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 3ebcc2e..d909a6f 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -80,6 +80,7 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_JSET        0x40
 #define         BPF_JLT         0x50
 #define         BPF_JLE         0x60
+#define         BPF_JNEQ        0x70
 
 #define BPF_SRC(code)   ((code) & 0x08)
 #define         BPF_K           0x00
diff --git a/net/core/filter.c b/net/core/filter.c
index 2122eba..b360fb3 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -228,6 +228,9 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
 		case BPF_S_JMP_JEQ_K:
 			fentry += (A == K) ? fentry->jt : fentry->jf;
 			continue;
+		case BPF_S_JMP_JNEQ_K:
+			fentry += (A != K) ? fentry->jt : fentry->jf;
+			continue;
 		case BPF_S_JMP_JSET_K:
 			fentry += (A & K) ? fentry->jt : fentry->jf;
 			continue;
@@ -246,6 +249,9 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
 		case BPF_S_JMP_JEQ_X:
 			fentry += (A == X) ? fentry->jt : fentry->jf;
 			continue;
+		case BPF_S_JMP_JNEQ_X:
+			fentry += (A != X) ? fentry->jt : fentry->jf;
+			continue;
 		case BPF_S_JMP_JSET_X:
 			fentry += (A & X) ? fentry->jt : fentry->jf;
 			continue;
@@ -454,6 +460,8 @@ static int check_load_and_stores(struct sock_filter *filter, int flen)
 			break;
 		case BPF_S_JMP_JEQ_K:
 		case BPF_S_JMP_JEQ_X:
+		case BPF_S_JMP_JNEQ_K:
+		case BPF_S_JMP_JNEQ_X:
 		case BPF_S_JMP_JGE_K:
 		case BPF_S_JMP_JGE_X:
 		case BPF_S_JMP_JGT_K:
@@ -540,6 +548,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		[BPF_JMP|BPF_JA]         = BPF_S_JMP_JA,
 		[BPF_JMP|BPF_JEQ|BPF_K]  = BPF_S_JMP_JEQ_K,
 		[BPF_JMP|BPF_JEQ|BPF_X]  = BPF_S_JMP_JEQ_X,
+		[BPF_JMP|BPF_JNEQ|BPF_K] = BPF_S_JMP_JNEQ_K,
+		[BPF_JMP|BPF_JNEQ|BPF_X] = BPF_S_JMP_JNEQ_X,
 		[BPF_JMP|BPF_JGE|BPF_K]  = BPF_S_JMP_JGE_K,
 		[BPF_JMP|BPF_JGE|BPF_X]  = BPF_S_JMP_JGE_X,
 		[BPF_JMP|BPF_JGT|BPF_K]  = BPF_S_JMP_JGT_K,
@@ -599,6 +609,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 			break;
 		case BPF_S_JMP_JEQ_K:
 		case BPF_S_JMP_JEQ_X:
+		case BPF_S_JMP_JNEQ_K:
+		case BPF_S_JMP_JNEQ_X:
 		case BPF_S_JMP_JGE_K:
 		case BPF_S_JMP_JGE_X:
 		case BPF_S_JMP_JGT_K:
@@ -852,6 +864,8 @@ static void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 		[BPF_S_JMP_JA]		= BPF_JMP|BPF_JA,
 		[BPF_S_JMP_JEQ_K]	= BPF_JMP|BPF_JEQ|BPF_K,
 		[BPF_S_JMP_JEQ_X]	= BPF_JMP|BPF_JEQ|BPF_X,
+		[BPF_S_JMP_JNEQ_K]	= BPF_JMP|BPF_JNEQ|BPF_K,
+		[BPF_S_JMP_JNEQ_X]	= BPF_JMP|BPF_JNEQ|BPF_X,
 		[BPF_S_JMP_JGE_K]	= BPF_JMP|BPF_JGE|BPF_K,
 		[BPF_S_JMP_JGE_X]	= BPF_JMP|BPF_JGE|BPF_X,
 		[BPF_S_JMP_JGT_K]	= BPF_JMP|BPF_JGT|BPF_K,
-- 
1.7.11.7
