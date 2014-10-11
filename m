From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 12/12] isdn/gigaset: fix usb_gigaset write_cmd result race
Date: Sat, 11 Oct 2014 13:46:30 +0200 (CEST)
Message-ID: <2606e14cb61bc99f0f574b43ff6d9f585f199286.1413021631.git.tilman@imap.cc>
References: <cover.1413021630.git.tilman@imap.cc>
Cc: David Miller <davem@davemloft.net>, Dave Jones <davej@redhat.com>,
	Hansjoerg Lipp <hjlipp@web.de>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.pxnet.com ([89.1.7.7]:36362 "EHLO mail.pxnet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978AbaJKLrD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 11 Oct 2014 07:47:03 -0400
In-Reply-To: <cover.1413021630.git.tilman@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In usb_gigaset function gigaset_write_cmd(), the length field of
the command buffer structure could be cleared by the transmit
tasklet before it was used for the function's return value.
Fix by copying to a local variable before scheduling the tasklet.

Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/usb-gigaset.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/isdn/gigaset/usb-gigaset.c b/drivers/isdn/gigaset/usb-gigaset.c
index 82e91ba..a8e652d 100644
--- a/drivers/isdn/gigaset/usb-gigaset.c
+++ b/drivers/isdn/gigaset/usb-gigaset.c
@@ -497,6 +497,7 @@ static int send_cb(struct cardstate *cs, struct cmdbuf_t *cb)
 static int gigaset_write_cmd(struct cardstate *cs, struct cmdbuf_t *cb)
 {
 	unsigned long flags;
+	int len;
 
 	gigaset_dbg_buffer(cs->mstate != MS_LOCKED ?
 			   DEBUG_TRANSCMD : DEBUG_LOCKCMD,
@@ -515,10 +516,11 @@ static int gigaset_write_cmd(struct cardstate *cs, struct cmdbuf_t *cb)
 	spin_unlock_irqrestore(&cs->cmdlock, flags);
 
 	spin_lock_irqsave(&cs->lock, flags);
+	len = cb->len;
 	if (cs->connected)
 		tasklet_schedule(&cs->write_tasklet);
 	spin_unlock_irqrestore(&cs->lock, flags);
-	return cb->len;
+	return len;
 }
 
 static int gigaset_write_room(struct cardstate *cs)
-- 
1.9.2.459.g68773ac
