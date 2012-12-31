From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/8] net: bpf: add lt,le jump operations to bpf machine
Date: Mon, 31 Dec 2012 14:59:41 +0100
Message-ID: <f6c8c5a267c533185e6b866feaa078a8e124b04e.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Cc: netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:23142 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751177Ab2LaN7w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Dec 2012 08:59:52 -0500
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
In-Reply-To: <cover.1356960070.git.dborkman@redhat.com>
References: <cover.1356960070.git.dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds jump operations for lt (<) and le (<=) that
compare A with K resp. X in order to facilitate filter
programming with conditional jumps, since currently only
gt (>) and ge (>=) are present in the BPF machine. For
user-space filter programming / compilers, it might be good
to also have those complementary operations. They don't need
to be as ancillary, since they fit into the instruction
encoding directly. Follow-up BPF JIT patches are welcomed.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/linux/filter.h      |  4 ++++
 include/uapi/linux/filter.h |  3 +++
 net/core/filter.c           | 28 ++++++++++++++++++++++++++++
 3 files changed, 35 insertions(+)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index c45eabc..36630bc 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -109,6 +109,10 @@ enum {
 	BPF_S_JMP_JGE_X,
 	BPF_S_JMP_JGT_K,
 	BPF_S_JMP_JGT_X,
+	BPF_S_JMP_JLE_K,
+	BPF_S_JMP_JLE_X,
+	BPF_S_JMP_JLT_K,
+	BPF_S_JMP_JLT_X,
 	BPF_S_JMP_JSET_K,
 	BPF_S_JMP_JSET_X,
 	/* Ancillary data */
diff --git a/include/uapi/linux/filter.h b/include/uapi/linux/filter.h
index 9cfde69..3ebcc2e 100644
--- a/include/uapi/linux/filter.h
+++ b/include/uapi/linux/filter.h
@@ -78,6 +78,9 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_JGT         0x20
 #define         BPF_JGE         0x30
 #define         BPF_JSET        0x40
+#define         BPF_JLT         0x50
+#define         BPF_JLE         0x60
+
 #define BPF_SRC(code)   ((code) & 0x08)
 #define         BPF_K           0x00
 #define         BPF_X           0x08
diff --git a/net/core/filter.c b/net/core/filter.c
index 2ead2a9..2122eba 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -219,6 +219,12 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
 		case BPF_S_JMP_JGE_K:
 			fentry += (A >= K) ? fentry->jt : fentry->jf;
 			continue;
+		case BPF_S_JMP_JLT_K:
+			fentry += (A < K) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_JMP_JLE_K:
+			fentry += (A <= K) ? fentry->jt : fentry->jf;
+			continue;
 		case BPF_S_JMP_JEQ_K:
 			fentry += (A == K) ? fentry->jt : fentry->jf;
 			continue;
@@ -231,6 +237,12 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
 		case BPF_S_JMP_JGE_X:
 			fentry += (A >= X) ? fentry->jt : fentry->jf;
 			continue;
+		case BPF_S_JMP_JLT_X:
+			fentry += (A < X) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_JMP_JLE_X:
+			fentry += (A <= X) ? fentry->jt : fentry->jf;
+			continue;
 		case BPF_S_JMP_JEQ_X:
 			fentry += (A == X) ? fentry->jt : fentry->jf;
 			continue;
@@ -446,6 +458,10 @@ static int check_load_and_stores(struct sock_filter *filter, int flen)
 		case BPF_S_JMP_JGE_X:
 		case BPF_S_JMP_JGT_K:
 		case BPF_S_JMP_JGT_X:
+		case BPF_S_JMP_JLE_K:
+		case BPF_S_JMP_JLE_X:
+		case BPF_S_JMP_JLT_K:
+		case BPF_S_JMP_JLT_X:
 		case BPF_S_JMP_JSET_X:
 		case BPF_S_JMP_JSET_K:
 			/* a jump must set masks on targets */
@@ -528,6 +544,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		[BPF_JMP|BPF_JGE|BPF_X]  = BPF_S_JMP_JGE_X,
 		[BPF_JMP|BPF_JGT|BPF_K]  = BPF_S_JMP_JGT_K,
 		[BPF_JMP|BPF_JGT|BPF_X]  = BPF_S_JMP_JGT_X,
+		[BPF_JMP|BPF_JLE|BPF_K]  = BPF_S_JMP_JLE_K,
+		[BPF_JMP|BPF_JLE|BPF_X]  = BPF_S_JMP_JLE_X,
+		[BPF_JMP|BPF_JLT|BPF_K]  = BPF_S_JMP_JLT_K,
+		[BPF_JMP|BPF_JLT|BPF_X]  = BPF_S_JMP_JLT_X,
 		[BPF_JMP|BPF_JSET|BPF_K] = BPF_S_JMP_JSET_K,
 		[BPF_JMP|BPF_JSET|BPF_X] = BPF_S_JMP_JSET_X,
 	};
@@ -583,6 +603,10 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		case BPF_S_JMP_JGE_X:
 		case BPF_S_JMP_JGT_K:
 		case BPF_S_JMP_JGT_X:
+		case BPF_S_JMP_JLE_K:
+		case BPF_S_JMP_JLE_X:
+		case BPF_S_JMP_JLT_K:
+		case BPF_S_JMP_JLT_X:
 		case BPF_S_JMP_JSET_X:
 		case BPF_S_JMP_JSET_K:
 			/* for conditionals both must be safe */
@@ -832,6 +856,10 @@ static void sk_decode_filter(struct sock_filter *filt, struct sock_filter *to)
 		[BPF_S_JMP_JGE_X]	= BPF_JMP|BPF_JGE|BPF_X,
 		[BPF_S_JMP_JGT_K]	= BPF_JMP|BPF_JGT|BPF_K,
 		[BPF_S_JMP_JGT_X]	= BPF_JMP|BPF_JGT|BPF_X,
+		[BPF_S_JMP_JLE_K]	= BPF_JMP|BPF_JLE|BPF_K,
+		[BPF_S_JMP_JLE_X]	= BPF_JMP|BPF_JLE|BPF_X,
+		[BPF_S_JMP_JLT_K]	= BPF_JMP|BPF_JLT|BPF_K,
+		[BPF_S_JMP_JLT_X]	= BPF_JMP|BPF_JLT|BPF_X,
 		[BPF_S_JMP_JSET_K]	= BPF_JMP|BPF_JSET|BPF_K,
 		[BPF_S_JMP_JSET_X]	= BPF_JMP|BPF_JSET|BPF_X,
 	};
-- 
1.7.11.7
