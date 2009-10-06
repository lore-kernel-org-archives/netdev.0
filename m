From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 01/11] gigaset: fix reject/hangup handling
Date: Wed,  7 Oct 2009 00:18:26 +0200 (CEST)
Message-ID: <20091006-patch-gigaset-01.tilman@imap.cc>
References: <20091006-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <isdn@linux-pingi.de>,
	Karsten Keil <keil@b1-systems.de>,
	isdn4linux@listserv.isdn4linux.de,
	i4ldeveloper@listserv.isdn4linux.de
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S933575AbZJFWTR@vger.kernel.org>
In-Reply-To: <20091006-patch-gigaset-00.tilman@imap.cc>
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
