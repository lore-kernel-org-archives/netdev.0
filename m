From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 02/12] gigaset: fix reject/hangup handling
Date: Sun,  6 Sep 2009 20:58:52 +0200 (CEST)
Message-ID: <20090906-patch-gigaset-02.tilman@imap.cc>
References: <20090906-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758267AbZIFS75@vger.kernel.org>
In-Reply-To: <20090906-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signal D channel disconnect in a few cases where it was missed,
including when an incoming call is disconnected before it was
accepted.

Impact: error handling improvement
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 2d91049..ff2ec2c 100644
--- a/drivers/isdn/gigaset/ev-layer.c
+++ b/drivers/isdn/gigaset/ev-layer.c
@@ -707,6 +707,11 @@ static void disconnect(struct at_state_t **at_state_p)
 	if (bcs) {
 		/* B channel assigned: invoke hardware specific handler */
 		cs->ops->close_bchannel(bcs);
+		/* notify LL */
+		if (bcs->chstate & (CHS_D_UP | CHS_NOTIFY_LL)) {
+			bcs->chstate &= ~(CHS_D_UP | CHS_NOTIFY_LL);
+			gigaset_i4l_channel_cmd(bcs, ISDN_STAT_DHUP);
+		}
 	} else {
 		/* no B channel assigned: just deallocate */
 		spin_lock_irqsave(&cs->lock, flags);
-- 
1.6.2.1.214.ge986c
