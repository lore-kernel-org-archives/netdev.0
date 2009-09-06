From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 06/12] gigaset: fix device ERROR response handling
Date: Sun,  6 Sep 2009 20:58:52 +0200 (CEST)
Message-ID: <20090906-patch-gigaset-06.tilman@imap.cc>
References: <20090906-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758235AbZIFS7k@vger.kernel.org>
In-Reply-To: <20090906-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Clear out pending command that got rejected with 'ERROR' response.
This fixes the bug where unloading the driver module would hang
with the message: "gigaset: not searching scheduled commands: busy"

Impact: error handling bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c |   16 ++++++++--------
 1 files changed, 8 insertions(+), 8 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index ff2ec2c..2d47ff4 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -207,7 +207,6 @@ struct reply_t gigaset_tab_nocid[] =
 	/* leave dle mode */
 	{RSP_INIT,      0,  0,SEQ_DLE0,           201, 5, {0},             "^SDLE=0\r"},
 	{RSP_OK,      201,201, -1,                202,-1},
-	//{RSP_ZDLE,    202,202,  0,                202, 0, {ACT_ERROR}},//DELETE
 	{RSP_ZDLE,    202,202,  0,                  0, 0, {ACT_DLE0}},
 	{RSP_NODEV,   200,249, -1,                  0, 0, {ACT_FAKEDLE0}},
 	{RSP_ERROR,   200,249, -1,                  0, 0, {ACT_FAILDLE0}},
@@ -265,6 +264,7 @@ struct reply_t gigaset_tab_nocid[] =
 	{EV_SHUTDOWN,  -1, -1, -1,                 -1,-1, {ACT_SHUTDOWN}}, //FIXME
 
 	/* misc. */
+	{RSP_ERROR,    -1, -1, -1,                 -1,-1, {ACT_ERROR}},
 	{RSP_EMPTY,    -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
 	{RSP_ZCFGT,    -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
 	{RSP_ZCFG,     -1, -1, -1,                 -1,-1, {ACT_DEBUG}}, //FIXME
@@ -328,10 +328,9 @@ struct reply_t gigaset_tab_cid[] =
 	{RSP_INIT,     -1, -1,SEQ_HUP,            401, 5, {0},             "+VLS=0\r"}, /* hang up */ //-1,-1?
 	{RSP_OK,      401,401, -1,                402, 5},
 	{RSP_ZVLS,    402,402,  0,                403, 5},
-	{RSP_ZSAU,    403,403,ZSAU_DISCONNECT_REQ, -1,-1, {ACT_DEBUG}}, /* if not remote hup */
-	//{RSP_ZSAU,    403,403,ZSAU_NULL,          401, 0, {ACT_ERROR}}, //DELETE//FIXME -> DLE0 // should we do this _before_ hanging up for base driver?
-	{RSP_ZSAU,    403,403,ZSAU_NULL,            0, 0, {ACT_DISCONNECT}}, //FIXME -> DLE0 // should we do this _before_ hanging up for base driver?
-	{RSP_NODEV,   401,403, -1,                  0, 0, {ACT_FAKEHUP}}, //FIXME -> DLE0 // should we do this _before_ hanging up for base driver?
+	{RSP_ZSAU,    403,403,ZSAU_DISCONNECT_REQ, -1,-1, {ACT_DEBUG}},
+	{RSP_ZSAU,    403,403,ZSAU_NULL,            0, 0, {ACT_DISCONNECT}},
+	{RSP_NODEV,   401,403, -1,                  0, 0, {ACT_FAKEHUP}},
 	{RSP_ERROR,   401,401, -1,                  0, 0, {ACT_ABORTHUP}},
 	{EV_TIMEOUT,  401,403, -1,                  0, 0, {ACT_ABORTHUP}},
 
@@ -1434,11 +1433,12 @@ static void do_action(int action, struct cardstate *cs,
 		cs->gotfwver = -1;
 		dev_err(cs->dev, "could not read firmware version.\n");
 		break;
-#ifdef CONFIG_GIGASET_DEBUG
 	case ACT_ERROR:
-		*p_genresp = 1;
-		*p_resp_code = RSP_ERROR;
+		gig_dbg(DEBUG_ANY, "%s: ERROR response in ConState %d",
+			__func__, at_state->ConState);
+		cs->cur_at_seq = SEQ_NONE;
 		break;
+#ifdef CONFIG_GIGASET_DEBUG
 	case ACT_TEST:
 		{
 			static int count = 3; //2; //1;
-- 
1.6.2.1.214.ge986c
