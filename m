From: Michal Schmidt <mschmidt@redhat.com>
Subject: [PATCH net] bnx2x: really disable TPA if 'disable_tpa' option is set
Date: Mon, 27 Apr 2015 17:20:38 +0200
Message-ID: <1430148038-25695-1-git-send-email-mschmidt@redhat.com>
Cc: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>,
	Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34091 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752321AbbD0PUl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Apr 2015 11:20:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

bnx2x's 'disable_tpa=1' module option is not respected properly and TPA
(transparent packet aggregation) remains enabled. Even though the
module option causes LRO to be disabled, TPA is enabled in GRO mode.

Additionally, disabling GRO via ethtool then has no effect. One can
still observe tpa_* statistics increase and large packets being received
in tcpdump.

The bug was an unintended consequence of commit aebf6244cd39 "bnx2x: Be
more forgiving toward SW GRO".

Fix it by following the bp->disable_tpa flag when initializing fp's.

Signed-off-by: Michal Schmidt <mschmidt@redhat.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
index 6f7dc81581..3558a36b1c 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
@@ -2485,8 +2485,10 @@ static void bnx2x_bz_fp(struct bnx2x *bp, int index)
 	else if (bp->flags & GRO_ENABLE_FLAG)
 		fp->mode = TPA_MODE_GRO;
 
-	/* We don't want TPA on an FCoE L2 ring */
-	if (IS_FCOE_FP(fp))
+	/* We don't want TPA if it's disabled in bp
+	 * or if this is an FCoE L2 ring.
+	 */
+	if (bp->disable_tpa || IS_FCOE_FP(fp))
 		fp->disable_tpa = 1;
 }
 
-- 
2.1.0
