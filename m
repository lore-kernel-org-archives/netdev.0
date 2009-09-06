From: Tilman Schmidt <tilman@imap.cc>
Subject: [PATCH 01/12] gigaset: really fix chars_in_buffer
Date: Sun,  6 Sep 2009 20:58:52 +0200 (CEST)
Message-ID: <20090906-patch-gigaset-01.tilman@imap.cc>
References: <20090906-patch-gigaset-00.tilman@imap.cc>
Cc: Alan Cox <alan@linux.intel.com>, Hansjoerg Lipp <hjlipp@web.de>
To: davem@davemloft.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758179AbZIFS7c@vger.kernel.org>
In-Reply-To: <20090906-patch-gigaset-00.tilman@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The tty_operation chars_in_buffer() is not allowed to return a
negative value to signal an error. Corrects the problem flagged
by commit 23198fda7182969b619613a555f8645fdc3dc334,
"tty: fix chars_in_buffers".

Impact: error handling bugfix
Signed-off-by: Tilman Schmidt <tilman@imap.cc>
---
 drivers/isdn/gigaset/interface.c |   19 +++++++------------
 1 files changed, 7 insertions(+), 12 deletions(-)

diff --git a/drivers/isdn/gigaset/interface.c b/drivers/isdn/gigaset/interface.c
index 8ff7e35..f33ac27 100644
--- a/drivers/isdn/gigaset/interface.c
+++ b/drivers/isdn/gigaset/interface.c
@@ -408,33 +408,28 @@ static int if_write_room(struct tty_struct *tty)
 	return retval;
 }
 
-/* FIXME: This function does not have error returns */
-
 static int if_chars_in_buffer(struct tty_struct *tty)
 {
 	struct cardstate *cs;
-	int retval = -ENODEV;
+	int retval = 0;
 
 	cs = (struct cardstate *) tty->driver_data;
 	if (!cs) {
 		pr_err("%s: no cardstate\n", __func__);
-		return -ENODEV;
+		return 0;
 	}
 
 	gig_dbg(DEBUG_IF, "%u: %s()", cs->minor_index, __func__);
 
-	if (mutex_lock_interruptible(&cs->mutex))
-		return -ERESTARTSYS; // FIXME -EINTR?
+	mutex_lock(&cs->mutex);
 
-	if (!cs->connected) {
+	if (!cs->connected)
 		gig_dbg(DEBUG_IF, "not connected");
-		retval = -ENODEV;
-	} else if (!cs->open_count)
+	else if (!cs->open_count)
 		dev_warn(cs->dev, "%s: device not opened\n", __func__);
-	else if (cs->mstate != MS_LOCKED) {
+	else if (cs->mstate != MS_LOCKED)
 		dev_warn(cs->dev, "can't write to unlocked device\n");
-		retval = -EBUSY;
-	} else
+	else
 		retval = cs->ops->chars_in_buffer(cs);
 
 	mutex_unlock(&cs->mutex);
-- 
1.6.2.1.214.ge986c
