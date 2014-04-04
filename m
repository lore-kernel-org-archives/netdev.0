From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net] net: filter: be more defensive on div/mod by X==0
Date: Sat,  5 Apr 2014 01:04:03 +0200
Message-ID: <1396652643-15647-1-git-send-email-dborkman@redhat.com>
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:11782 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752861AbaDDXEM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2014 19:04:12 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The old interpreter behaviour was that we returned with 0
whenever we found a division by 0 would take place. In the new
interpreter we would currently just skip that instead and
continue execution.

It's true that a value of 0 as return might not be appropriate
in all cases, but current users (socket filters -> drop
packet, seccomp -> SECCOMP_RET_KILL, cls_bpf -> unclassified,
etc) seem fine with that behaviour. Better this than undefined
BPF program behaviour as it's expected that A contains the
result of the division. In future, as more use cases open up,
we could further adapt this return value to our needs, if
necessary.

So reintroduce return of 0 for division by 0 as in the old
interpreter. Also in case of K which is guaranteed to be 32bit
wide, sk_chk_filter() already takes care of preventing division
by 0 invoked through K, so we can generally spare us these tests.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
Reviewed-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c | 32 ++++++++++++++++----------------
 1 file changed, 16 insertions(+), 16 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 765556b..e08b382 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -295,43 +295,43 @@ select_insn:
 		(*(s64 *) &A) >>= K;
 		CONT;
 	BPF_ALU64_BPF_MOD_BPF_X:
+		if (unlikely(X == 0))
+			return 0;
 		tmp = A;
-		if (X)
-			A = do_div(tmp, X);
+		A = do_div(tmp, X);
 		CONT;
 	BPF_ALU_BPF_MOD_BPF_X:
+		if (unlikely(X == 0))
+			return 0;
 		tmp = (u32) A;
-		if (X)
-			A = do_div(tmp, (u32) X);
+		A = do_div(tmp, (u32) X);
 		CONT;
 	BPF_ALU64_BPF_MOD_BPF_K:
 		tmp = A;
-		if (K)
-			A = do_div(tmp, K);
+		A = do_div(tmp, K);
 		CONT;
 	BPF_ALU_BPF_MOD_BPF_K:
 		tmp = (u32) A;
-		if (K)
-			A = do_div(tmp, (u32) K);
+		A = do_div(tmp, (u32) K);
 		CONT;
 	BPF_ALU64_BPF_DIV_BPF_X:
-		if (X)
-			do_div(A, X);
+		if (unlikely(X == 0))
+			return 0;
+		do_div(A, X);
 		CONT;
 	BPF_ALU_BPF_DIV_BPF_X:
+		if (unlikely(X == 0))
+			return 0;
 		tmp = (u32) A;
-		if (X)
-			do_div(tmp, (u32) X);
+		do_div(tmp, (u32) X);
 		A = (u32) tmp;
 		CONT;
 	BPF_ALU64_BPF_DIV_BPF_K:
-		if (K)
-			do_div(A, K);
+		do_div(A, K);
 		CONT;
 	BPF_ALU_BPF_DIV_BPF_K:
 		tmp = (u32) A;
-		if (K)
-			do_div(tmp, (u32) K);
+		do_div(tmp, (u32) K);
 		A = (u32) tmp;
 		CONT;
 	BPF_ALU_BPF_END_BPF_TO_BE:
-- 
1.7.11.7
