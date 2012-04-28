From: Karsten Keil <kkeil@linux-pingi.de>
Subject: [PATCH 1/8] mISDN: Added PH_* state info to tei manager.
Date: Sat, 28 Apr 2012 13:43:17 +0200
Message-ID: <1335613404-10187-2-git-send-email-kkeil@linux-pingi.de>
References: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Cc: netdev@vger.kernel.org, Andreas Eversberg <andreas@eversberg.eu>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.186]:58474 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753164Ab2D1LrZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 07:47:25 -0400
In-Reply-To: <1335613404-10187-1-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreas Eversberg <andreas@eversberg.eu>

Tei manager reports current layer 1 state on creation.
On state change it reports it to the socket interface.

Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/mISDN/tei.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/mISDN/tei.c b/drivers/isdn/mISDN/tei.c
index ba2bc0c..969766f 100644
--- a/drivers/isdn/mISDN/tei.c
+++ b/drivers/isdn/mISDN/tei.c
@@ -1023,6 +1023,8 @@ create_teimgr(struct manager *mgr, struct channel_req *crq)
 		mgr->up = crq->ch;
 		id = DL_INFO_L2_CONNECT;
 		teiup_create(mgr, DL_INFORMATION_IND, sizeof(id), &id);
+		if (test_bit(MGR_PH_ACTIVE, &mgr->options))
+			teiup_create(mgr, PH_ACTIVATE_IND, 0, NULL);
 		crq->ch = NULL;
 		if (!list_empty(&mgr->layer2)) {
 			read_lock_irqsave(&mgr->lock, flags);
@@ -1096,12 +1098,16 @@ mgr_send(struct mISDNchannel *ch, struct sk_buff *skb)
 		break;
 	case PH_ACTIVATE_IND:
 		test_and_set_bit(MGR_PH_ACTIVE, &mgr->options);
+		if (mgr->up)
+			teiup_create(mgr, PH_ACTIVATE_IND, 0, NULL);
 		mISDN_FsmEvent(&mgr->deact, EV_ACTIVATE_IND, NULL);
 		do_send(mgr);
 		ret = 0;
 		break;
 	case PH_DEACTIVATE_IND:
 		test_and_clear_bit(MGR_PH_ACTIVE, &mgr->options);
+		if (mgr->up)
+			teiup_create(mgr, PH_DEACTIVATE_IND, 0, NULL);
 		mISDN_FsmEvent(&mgr->deact, EV_DEACTIVATE_IND, NULL);
 		ret = 0;
 		break;
-- 
1.7.3.4
