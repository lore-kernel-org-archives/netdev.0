From: Roland Dreier <rdreier@cisco.com>
Subject: cxgb3: Fix sparse warning and micro-optimize is_pure_response()
Date: Fri, 28 Nov 2008 21:47:03 -0800
Message-ID: <ada3ahbccdk.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Divy Le Ray <divy@chelsio.com>, Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2.cisco.com ([171.71.176.71]:59315 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750701AbYK2FrG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Nov 2008 00:47:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The function is_pure_response() does "ntohl(var) & const" and then
essentially just tests whether the result is 0 or not; this can be done
more efficiently by computing "var & htonl(const)" instead and doing the
byte swap at compile time instead of run time.

This change slightly shrinks the compiled code; eg on x86-64 we save a
couple of bswapl instructions:

add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-8 (-8)
function                                     old     new   delta
t3_sge_intr_msix_napi                        544     536      -8

and this also has the pleasant side effect of fixing a sparse warning:

    drivers/net/cxgb3/sge.c:2313:15: warning: restricted degrades to integer

Signed-off-by: Roland Dreier <rolandd@cisco.com>
---
 drivers/net/cxgb3/sge.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cxgb3/sge.c b/drivers/net/cxgb3/sge.c
index c6480be..4181373 100644
--- a/drivers/net/cxgb3/sge.c
+++ b/drivers/net/cxgb3/sge.c
@@ -2308,7 +2308,7 @@ next_fl:
 
 static inline int is_pure_response(const struct rsp_desc *r)
 {
-	u32 n = ntohl(r->flags) & (F_RSPD_ASYNC_NOTIF | F_RSPD_IMM_DATA_VALID);
+	__be32 n = r->flags & htonl(F_RSPD_ASYNC_NOTIF | F_RSPD_IMM_DATA_VALID);
 
 	return (n | r->len_cq) == 0;
 }
