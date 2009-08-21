From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH RFC 1/6] gigaset: fix reject/hangup handling
Date: Fri, 21 Aug 2009 19:21:34 +0200 (CEST)
Message-ID: <20090821-patch-01.tilman@imap.cc>
References: <20090821-patch-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>
To: i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([195.227.45.7]:50972 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932534AbZHURVm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Aug 2009 13:21:42 -0400
In-Reply-To: <20090821-patch-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signal D channel disconnect in a few cases where it was missed,
including when an incoming call is disconnected before it was
accepted.

Impact: error handling improvement
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/ev-layer.c |   5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/isdn/gigaset/ev-layer.c b/drivers/isdn/gigaset/ev-layer.c
index 2d91049..31082a6 100644
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

