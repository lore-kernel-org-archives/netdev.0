From: Radu Rendec <radu.rendec@ines.ro>
Subject: [PATCH] [PKT_SCHED] CLS_U32: Use ffs() instead of C code on hash mask to get first set bit.
Date: Thu,  8 Nov 2007 13:07:47 +0200
Message-ID: <1194520067-20868-1-git-send-email-radu.rendec@ines.ro>
Cc: hadi@cyberus.ca, jarkao2@o2.pl, davem@davemloft.net,
	Radu Rendec <radu.rendec@ines.ro>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from NAT-173-Unkn.Local.iNES.RO ([80.86.100.173]:58293 "EHLO
	vix-test.ines.ro" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754787AbXKHLIl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 06:08:41 -0500
In-Reply-To: 20071107.012220.17723288.davem@davemloft.net
References: 20071107.012220.17723288.davem@davemloft.net
In-Reply-To: <20071107.012220.17723288.davem@davemloft.net>
References: <20071107.012220.17723288.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Computing the rank of the first set bit in the hash mask (for using later
in u32_hash_fold()) was done with plain C code. Using ffs() instead makes
the code more readable and improves performance (since ffs() is better
optimized in assembler).

Using the conditional operator on hash mask before applying ntohl() also
saves one ntohl() call if mask is 0.

Signed-off-by: Radu Rendec <radu.rendec@ines.ro>
---
 net/sched/cls_u32.c |   12 +-----------
 1 files changed, 1 insertions(+), 11 deletions(-)

diff --git a/net/sched/cls_u32.c b/net/sched/cls_u32.c
index 5317102..c390082 100644
--- a/net/sched/cls_u32.c
+++ b/net/sched/cls_u32.c
@@ -613,17 +613,7 @@ static int u32_change(struct tcf_proto *tp, unsigned long base, u32 handle,
 	memcpy(&n->sel, s, sizeof(*s) + s->nkeys*sizeof(struct tc_u32_key));
 	n->ht_up = ht;
 	n->handle = handle;
-{
-	u8 i = 0;
-	u32 mask = ntohl(s->hmask);
-	if (mask) {
-		while (!(mask & 1)) {
-			i++;
-			mask>>=1;
-		}
-	}
-	n->fshift = i;
-}
+	n->fshift = s->hmask ? ffs(ntohl(s->hmask)) - 1 : 0;
 
 #ifdef CONFIG_CLS_U32_MARK
 	if (tb[TCA_U32_MARK-1]) {
-- 
1.5.3.2

