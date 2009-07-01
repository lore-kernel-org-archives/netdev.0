From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 1/2] gigaset: accept connection establishment messages in any order
Date: Wed,  1 Jul 2009 23:20:57 +0200 (CEST)
Message-ID: <20090701-patch-01.tilman@imap.cc>
References: <20090701-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:49492 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752684AbZGAVVH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jul 2009 17:21:07 -0400
In-Reply-To: <20090701-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

ISDN connection setup failed if the "connection active" and
"B channel up" messages from the device arrived in a different
order than expected. Modify the state machine to accept them in
any order.

Impact: bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
CC: stable <stable@kernel.org>
---
 drivers/isdn/gigaset/ev-layer.c |   44 +++++++++++++++++---------------------
 1 files changed, 20 insertions(+), 24 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index ec51696..2d91049 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -294,32 +294,33 @@ struct reply_t gigaset_tab_cid[] =
 	{RSP_OK,      604,604, -1,                605, 5, {ACT_CMD+AT_MSN}},
 	{RSP_OK,      605,605, -1,                606, 5, {ACT_CMD+AT_ISO}},
 	{RSP_NULL,    605,605, -1,                606, 5, {ACT_CMD+AT_ISO}},
-	{RSP_OK,      606,606, -1,                607, 5, {0},             "+VLS=17\r"}, /* set "Endgeraetemodus" */
+	{RSP_OK,      606,606, -1,                607, 5, {0}, "+VLS=17\r"},
 	{RSP_OK,      607,607, -1,                608,-1},
-	//{RSP_ZSAU,    608,608,ZSAU_PROCEEDING,    608, 0, {ACT_ERROR}},//DELETE
 	{RSP_ZSAU,    608,608,ZSAU_PROCEEDING,    609, 5, {ACT_CMD+AT_DIAL}},
 	{RSP_OK,      609,609, -1,                650, 0, {ACT_DIALING}},
 
-	{RSP_ZVLS,    608,608, 17,                 -1,-1, {ACT_DEBUG}},
-	{RSP_ZCTP,    609,609, -1,                 -1,-1, {ACT_DEBUG}},
-	{RSP_ZCPN,    609,609, -1,                 -1,-1, {ACT_DEBUG}},
 	{RSP_ERROR,   601,609, -1,                  0, 0, {ACT_ABORTDIAL}},
 	{EV_TIMEOUT,  601,609, -1,                  0, 0, {ACT_ABORTDIAL}},
 
-	/* dialing */
-	{RSP_ZCTP,    650,650, -1,                 -1,-1, {ACT_DEBUG}},
-	{RSP_ZCPN,    650,650, -1,                 -1,-1, {ACT_DEBUG}},
-	{RSP_ZSAU,    650,650,ZSAU_CALL_DELIVERED, -1,-1, {ACT_DEBUG}}, /* some devices don't send this */
-
-	/* connection established  */
-	{RSP_ZSAU,    650,650,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT}}, //FIXME -> DLE1
-	{RSP_ZSAU,    750,750,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT}}, //FIXME -> DLE1
-
-	{EV_BC_OPEN,  800,800, -1,                800,-1, {ACT_NOTIFY_BC_UP}}, //FIXME new constate + timeout
+	/* optional dialing responses */
+	{EV_BC_OPEN,  650,650, -1,                651,-1},
+	{RSP_ZVLS,    608,651, 17,                 -1,-1, {ACT_DEBUG}},
+	{RSP_ZCTP,    609,651, -1,                 -1,-1, {ACT_DEBUG}},
+	{RSP_ZCPN,    609,651, -1,                 -1,-1, {ACT_DEBUG}},
+	{RSP_ZSAU,    650,651,ZSAU_CALL_DELIVERED, -1,-1, {ACT_DEBUG}},
+
+	/* connect */
+	{RSP_ZSAU,    650,650,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT}},
+	{RSP_ZSAU,    651,651,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT,
+							   ACT_NOTIFY_BC_UP}},
+	{RSP_ZSAU,    750,750,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT}},
+	{RSP_ZSAU,    751,751,ZSAU_ACTIVE,        800,-1, {ACT_CONNECT,
+							   ACT_NOTIFY_BC_UP}},
+	{EV_BC_OPEN,  800,800, -1,                800,-1, {ACT_NOTIFY_BC_UP}},
 
 	/* remote hangup */
-	{RSP_ZSAU,    650,650,ZSAU_DISCONNECT_IND,  0, 0, {ACT_REMOTEREJECT}},
-	{RSP_ZSAU,    750,750,ZSAU_DISCONNECT_IND,  0, 0, {ACT_REMOTEHUP}},
+	{RSP_ZSAU,    650,651,ZSAU_DISCONNECT_IND,  0, 0, {ACT_REMOTEREJECT}},
+	{RSP_ZSAU,    750,751,ZSAU_DISCONNECT_IND,  0, 0, {ACT_REMOTEHUP}},
 	{RSP_ZSAU,    800,800,ZSAU_DISCONNECT_IND,  0, 0, {ACT_REMOTEHUP}},
 
 	/* hangup */
@@ -358,7 +359,8 @@ struct reply_t gigaset_tab_cid[] =
 	{RSP_ZSAU,    700,729,ZSAU_ACTIVE,          0, 0, {ACT_ABORTACCEPT}},
 	{RSP_ZSAU,    700,729,ZSAU_DISCONNECT_IND,  0, 0, {ACT_ABORTACCEPT}},
 
-	{EV_TIMEOUT,  750,750, -1,                  0, 0, {ACT_CONNTIMEOUT}},
+	{EV_BC_OPEN,  750,750, -1,                751,-1},
+	{EV_TIMEOUT,  750,751, -1,                  0, 0, {ACT_CONNTIMEOUT}},
 
 	/* B channel closed (general case) */
 	{EV_BC_CLOSED, -1, -1, -1,                 -1,-1, {ACT_NOTIFY_BC_DOWN}}, //FIXME
@@ -876,12 +878,6 @@ static void bchannel_down(struct bc_state *bcs)
 
 static void bchannel_up(struct bc_state *bcs)
 {
-	if (!(bcs->chstate & CHS_D_UP)) {
-		dev_notice(bcs->cs->dev, "%s: D channel not up\n", __func__);
-		bcs->chstate |= CHS_D_UP;
-		gigaset_i4l_channel_cmd(bcs, ISDN_STAT_DCONN);
-	}
-
 	if (bcs->chstate & CHS_B_UP) {
 		dev_notice(bcs->cs->dev, "%s: B channel already up\n",
 			   __func__);
-- 
1.6.2.1.214.ge986c

