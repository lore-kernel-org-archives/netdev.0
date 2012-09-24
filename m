From: Daniel Borkmann <dxchgb@gmail.com>
Subject: [PATCH net-next] filter: add XOR instruction for use with X/K
Date: Mon, 24 Sep 2012 14:23:59 +0200
Message-ID: <20120924122359.GB25156@thinkbox>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:50078 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754686Ab2IXMYE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Sep 2012 08:24:04 -0400
Received: by wibhq12 with SMTP id hq12so1792877wib.1
        for <netdev@vger.kernel.org>; Mon, 24 Sep 2012 05:24:03 -0700 (PDT)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

BPF_S_ANC_ALU_XOR_X has been added a while ago, but as an 'ancillary'
operation that is invoked through a negative offset in K within BPF
load operations. Since BPF_MOD has recently been added, BPF_XOR should
also be part of the common ALU operations. Removing BPF_S_ANC_ALU_XOR_X
might not be an option since this is exposed to user space.

Signed-off-by: Daniel Borkmann <daniel.borkmann@tik.ee.ethz.ch>
---
 include/linux/filter.h |    3 +++
 net/core/filter.c      |   12 +++++++++---
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 3cf5fd5..2ded090 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -75,6 +75,7 @@ struct sock_fprog {	/* Required for SO_ATTACH_FILTER. */
 #define         BPF_RSH         0x70
 #define         BPF_NEG         0x80
 #define		BPF_MOD		0x90
+#define		BPF_XOR		0xa0
 
 #define         BPF_JA          0x00
 #define         BPF_JEQ         0x10
@@ -204,6 +205,8 @@ enum {
 	BPF_S_ALU_AND_X,
 	BPF_S_ALU_OR_K,
 	BPF_S_ALU_OR_X,
+	BPF_S_ALU_XOR_K,
+	BPF_S_ALU_XOR_X,
 	BPF_S_ALU_LSH_K,
 	BPF_S_ALU_LSH_X,
 	BPF_S_ALU_RSH_K,
diff --git a/net/core/filter.c b/net/core/filter.c
index fbe3a8d..3d92ebb 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -187,6 +187,13 @@ unsigned int sk_run_filter(const struct sk_buff *skb,
 		case BPF_S_ALU_OR_K:
 			A |= K;
 			continue;
+		case BPF_S_ANC_ALU_XOR_X:
+		case BPF_S_ALU_XOR_X:
+			A ^= X;
+			continue;
+		case BPF_S_ALU_XOR_K:
+			A ^= K;
+			continue;
 		case BPF_S_ALU_LSH_X:
 			A <<= X;
 			continue;
@@ -334,9 +341,6 @@ load_b:
 		case BPF_S_ANC_CPU:
 			A = raw_smp_processor_id();
 			continue;
-		case BPF_S_ANC_ALU_XOR_X:
-			A ^= X;
-			continue;
 		case BPF_S_ANC_NLATTR: {
 			struct nlattr *nla;
 
@@ -483,6 +487,8 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		[BPF_ALU|BPF_AND|BPF_X]  = BPF_S_ALU_AND_X,
 		[BPF_ALU|BPF_OR|BPF_K]   = BPF_S_ALU_OR_K,
 		[BPF_ALU|BPF_OR|BPF_X]   = BPF_S_ALU_OR_X,
+		[BPF_ALU|BPF_XOR|BPF_K]  = BPF_S_ALU_XOR_K,
+		[BPF_ALU|BPF_XOR|BPF_X]  = BPF_S_ALU_XOR_X,
 		[BPF_ALU|BPF_LSH|BPF_K]  = BPF_S_ALU_LSH_K,
 		[BPF_ALU|BPF_LSH|BPF_X]  = BPF_S_ALU_LSH_X,
 		[BPF_ALU|BPF_RSH|BPF_K]  = BPF_S_ALU_RSH_K,
