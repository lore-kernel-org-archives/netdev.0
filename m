From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 7/9] isdn/gigaset: unclog bas_gigaset AT response pipe
Date: Fri,  1 Oct 2010 01:35:31 +0200 (CEST)
Message-ID: <20100930-patch-gigaset-07.tilman@imap.cc>
References: <20100930-patch-gigaset-00.tilman@imap.cc>
Cc: Hansjoerg Lipp <hjlipp@web.de>, Karsten Keil <keil@b1-systems.de>,
	i4ldeveloper@listserv.isdn4linux.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gimli.pxnet.com ([89.1.7.7]:34819 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755106Ab0JAAbF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Sep 2010 20:31:05 -0400
In-Reply-To: <20100930-patch-gigaset-00.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recover from a lost HD_RECEIVEATDATA_ACK message by sending a
zero-length HD_READ_ATMESSAGE command when ev_layer sends "+++".

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/bas-gigaset.c |   22 ++++++++++++++++++++++
 1 files changed, 22 insertions(+), 0 deletions(-)

diff --git a/drivers/isdn/gigaset/bas-gigaset.c b/drivers/isdn/gigaset/bas-gigaset.c
index 7520bc6..540f6d0 100644
--- a/drivers/isdn/gigaset/bas-gigaset.c
+++ b/drivers/isdn/gigaset/bas-gigaset.c
@@ -1896,6 +1896,28 @@ static int gigaset_write_cmd(struct cardstate *cs, struct cmdbuf_t *cb)
 	 * The next command will reopen the AT channel automatically.
 	 */
 	if (cb->len == 3 && !memcmp(cb->buf, "+++", 3)) {
+		/* If an HD_RECEIVEATDATA_ACK message remains unhandled
+		 * because of an error, the base never sends another one.
+		 * The response channel is thus effectively blocked.
+		 * Closing and reopening the AT channel does *not* clear
+		 * this condition.
+		 * As a stopgap measure, submit a zero-length AT read
+		 * before closing the AT channel. This has the undocumented
+		 * effect of triggering a new HD_RECEIVEATDATA_ACK message
+		 * from the base if necessary.
+		 * The subsequent AT channel close then discards any pending
+		 * messages.
+		 */
+		spin_lock_irqsave(&cs->lock, flags);
+		if (!(cs->hw.bas->basstate & BS_ATRDPEND)) {
+			kfree(cs->hw.bas->rcvbuf);
+			cs->hw.bas->rcvbuf = NULL;
+			cs->hw.bas->rcvbuf_size = 0;
+			cs->hw.bas->retry_cmd_in = 0;
+			atread_submit(cs, 0);
+		}
+		spin_unlock_irqrestore(&cs->lock, flags);
+
 		rc = req_submit(cs->bcs, HD_CLOSE_ATCHANNEL, 0, BAS_TIMEOUT);
 		if (cb->wake_tasklet)
 			tasklet_schedule(cb->wake_tasklet);
-- 
1.7.3.15.g442cb

