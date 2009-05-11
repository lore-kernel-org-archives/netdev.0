From: "Hong H. Pham" <hong.pham@windriver.com>
Subject: [PATCH 1/1] NIU: fix spurious interrupts
Date: Mon, 11 May 2009 15:00:53 -0400
Message-ID: <1242068453-5124-2-git-send-email-hong.pham@windriver.com>
References: <1242068453-5124-1-git-send-email-hong.pham@windriver.com>
Cc: "Hong H. Pham" <hong.pham@windriver.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39064 "EHLO mail.wrs.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754441AbZEKTAz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 May 2009 15:00:55 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.wrs.com (8.13.6/8.13.6) with ESMTP id n4BJ0t5G011654
	for <netdev@vger.kernel.org>; Mon, 11 May 2009 12:00:55 -0700 (PDT)
In-Reply-To: <1242068453-5124-1-git-send-email-hong.pham@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's possible for an interrupt to be triggered while NAPI is in progress
(at least on a SPARC64 SUN4V system).  Unconditionally call
__niu_fastpath_interrupt() in niu_schedule_napi() to mask out the logical
device being serviced to avoid further spurious interrupts from being
generated.

Signed-off-by: Hong H. Pham <hong.pham@windriver.com>
---
 drivers/net/niu.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/niu.c b/drivers/net/niu.c
index 2b17453..80d4fb6 100644
--- a/drivers/net/niu.c
+++ b/drivers/net/niu.c
@@ -4221,11 +4221,11 @@ static void niu_schedule_napi(struct niu *np, struct niu_ldg *lp,
 	if (likely(napi_schedule_prep(&lp->napi))) {
 		lp->v0 = v0;
 		lp->v1 = v1;
 		lp->v2 = v2;
-		__niu_fastpath_interrupt(np, lp->ldg_num, v0);
 		__napi_schedule(&lp->napi);
 	}
+	__niu_fastpath_interrupt(np, lp->ldg_num, v0);
 }
 
 static irqreturn_t niu_interrupt(int irq, void *dev_id)
 {
-- 
1.6.0.3

