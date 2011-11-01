From: "Ariel Elior" <ariele@broadcom.com>
Subject: [PATCH net-next] bnx2x: stop using on-stack napi struct
Date: Tue, 1 Nov 2011 18:04:10 +0200
Message-ID: <1320163450.11011.19.camel@lb-tlvb-ariel.il.broadcom.com>
Reply-To: ariele@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: eilong@broadcom.com
To: davem@davemlof.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:3452 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752718Ab1KAP4S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Nov 2011 11:56:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Napi structure was allocated on stack to hold temporary value of copied
fastpath. This can be avoided by using the source fastpath as a
scratchpad thus saving stack space and code.
Signed-off-by: Ariel Elior <ariele@broadcom.com>
Signed-off-by: Eilon Greenstein <eilong@broadcom.com>

---
 drivers/net/bnx2x/bnx2x_cmn.c |   12 +++++++-----
 1 files changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/bnx2x/bnx2x_cmn.c
b/drivers/net/bnx2x/bnx2x_cmn.c
index 2890443..ff67d9b 100644
--- a/drivers/net/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/bnx2x/bnx2x_cmn.c
@@ -56,19 +56,21 @@ static inline void bnx2x_bz_fp(struct bnx2x *bp, int
index)
  * @to:                destination FP index
  *
  * Makes sure the contents of the bp->fp[to].napi is kept
- * intact.
+ * intact. This is done by first copying the napi struct from
+ * the target to the source, and then mem copying the entire
+ * source onto the target
  */
 static inline void bnx2x_move_fp(struct bnx2x *bp, int from, int to)
 {
        struct bnx2x_fastpath *from_fp = &bp->fp[from];
        struct bnx2x_fastpath *to_fp = &bp->fp[to];
-       struct napi_struct orig_napi = to_fp->napi;
+
+       /* Copy the NAPI object as it has been already initialized */
+       from_fp->napi = to_fp->napi;
+
        /* Move bnx2x_fastpath contents */
        memcpy(to_fp, from_fp, sizeof(*to_fp));
        to_fp->index = to;
-
-       /* Restore the NAPI object as it has been already initialized */
-       to_fp->napi = orig_napi;
 }
 
 /* free skb in the packet ring at pos idx
-- 
1.7.4.1
