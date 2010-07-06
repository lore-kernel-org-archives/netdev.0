From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 08/11] isdn/gigaset: reduce syslog spam
Date: Tue,  6 Jul 2010 02:19:14 +0200 (CEST)
Message-ID: <20100705-patch-gigaset-08.tilman@imap.cc>
References: <20100705-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:41997 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756993Ab0GFATb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Jul 2010 20:19:31 -0400
In-Reply-To: <20100705-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Downgrade some error messages which occur frequently during
normal operation to debug messages.

Impact: logging
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/capi.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/gigaset/capi.c b/drivers/isdn/gigaset/capi.c
index 3714aef..b459ed3 100644
--- a/drivers/isdn/gigaset/capi.c
+++ b/drivers/isdn/gigaset/capi.c
@@ -383,13 +383,13 @@ void gigaset_skb_sent(struct bc_state *bcs, struct sk_buff *dskb)
 	++bcs->trans_up;
 
 	if (!ap) {
-		dev_err(cs->dev, "%s: no application\n", __func__);
+		gig_dbg(DEBUG_MCMD, "%s: application gone", __func__);
 		return;
 	}
 
 	/* don't send further B3 messages if disconnected */
 	if (bcs->apconnstate < APCONN_ACTIVE) {
-		gig_dbg(DEBUG_MCMD, "disconnected, discarding ack");
+		gig_dbg(DEBUG_MCMD, "%s: disconnected", __func__);
 		return;
 	}
 
@@ -427,13 +427,14 @@ void gigaset_skb_rcvd(struct bc_state *bcs, struct sk_buff *skb)
 	bcs->trans_down++;
 
 	if (!ap) {
-		dev_err(cs->dev, "%s: no application\n", __func__);
+		gig_dbg(DEBUG_MCMD, "%s: application gone", __func__);
+		dev_kfree_skb_any(skb);
 		return;
 	}
 
 	/* don't send further B3 messages if disconnected */
 	if (bcs->apconnstate < APCONN_ACTIVE) {
-		gig_dbg(DEBUG_MCMD, "disconnected, discarding data");
+		gig_dbg(DEBUG_MCMD, "%s: disconnected", __func__);
 		dev_kfree_skb_any(skb);
 		return;
 	}
@@ -752,7 +753,7 @@ void gigaset_isdn_connD(struct bc_state *bcs)
 	ap = bcs->ap;
 	if (!ap) {
 		spin_unlock_irqrestore(&bcs->aplock, flags);
-		dev_err(cs->dev, "%s: no application\n", __func__);
+		gig_dbg(DEBUG_CMD, "%s: application gone", __func__);
 		return;
 	}
 	if (bcs->apconnstate == APCONN_NONE) {
@@ -848,7 +849,7 @@ void gigaset_isdn_connB(struct bc_state *bcs)
 	ap = bcs->ap;
 	if (!ap) {
 		spin_unlock_irqrestore(&bcs->aplock, flags);
-		dev_err(cs->dev, "%s: no application\n", __func__);
+		gig_dbg(DEBUG_CMD, "%s: application gone", __func__);
 		return;
 	}
 	if (!bcs->apconnstate) {
@@ -906,13 +907,12 @@ void gigaset_isdn_connB(struct bc_state *bcs)
  */
 void gigaset_isdn_hupB(struct bc_state *bcs)
 {
-	struct cardstate *cs = bcs->cs;
 	struct gigaset_capi_appl *ap = bcs->ap;
 
 	/* ToDo: assure order of DISCONNECT_B3_IND and DISCONNECT_IND ? */
 
 	if (!ap) {
-		dev_err(cs->dev, "%s: no application\n", __func__);
+		gig_dbg(DEBUG_CMD, "%s: application gone", __func__);
 		return;
 	}
 
-- 
1.6.5.3.298.g39add

