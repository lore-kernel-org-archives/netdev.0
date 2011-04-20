From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: [PATCH net-next 3/9] tg3: Nullify RSS for loopback test
Date: Wed, 20 Apr 2011 10:57:37 -0700
Message-ID: <1303322263-18991-4-git-send-email-mcarlson@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, mcarlson@broadcom.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:1891 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752280Ab1DTRs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Apr 2011 13:48:26 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The loopback test assumes all traffic goes to the first rx queue.  There
is a 1 in 4 chance this won't be true if RSS is enabled though.  This
patch reprograms the RSS indirection table to route all rx packets to
the first queue.

Signed-off-by: Matt Carlson <mcarlson@broadcom.com>
Reviewed-by: Michael Chan <mchan@broadcom.com>
---
 drivers/net/tg3.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tg3.c b/drivers/net/tg3.c
index 4aecb0a..1f233c4 100644
--- a/drivers/net/tg3.c
+++ b/drivers/net/tg3.c
@@ -11269,6 +11269,15 @@ static int tg3_test_loopback(struct tg3 *tp)
 		goto done;
 	}
 
+	if (tp->tg3_flags3 & TG3_FLG3_ENABLE_RSS) {
+		int i;
+
+		/* Reroute all rx packets to the 1st queue */
+		for (i = MAC_RSS_INDIR_TBL_0;
+		     i < MAC_RSS_INDIR_TBL_0 + TG3_RSS_INDIR_TBL_SIZE; i += 4)
+			tw32(i, 0x0);
+	}
+
 	/* Turn off gphy autopowerdown. */
 	if (tp->phy_flags & TG3_PHYFLG_ENABLE_APD)
 		tg3_phy_toggle_apd(tp, false);
-- 
1.7.3.4


