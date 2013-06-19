From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH 2/5] SLIP: Handle error codes from the TTY layer
Date: Wed, 19 Jun 2013 16:34:28 +0100
Message-ID: <1371656071-27754-3-git-send-email-Dean_Jenkins@mentor.com>
References: <1371656071-27754-1-git-send-email-Dean_Jenkins@mentor.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc6-farn7-2-0-cust119.6-2.cable.virginmedia.com ([81.110.26.120]:37738
	"EHLO localhost.localdomain" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756959Ab3FSPlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 11:41:31 -0400
In-Reply-To: <1371656071-27754-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears that SLIP does not handle error codes from the TTY layer.
This will result in a malfunction because the remaining length of
data will be corrupted by the negative error code values from the TTY
layer.

Therefore, add error code checks in sl_encaps() and sl_encaps_wakeup()
to prevent the corruption of the sent data length.

Note that SLIP is connectionless so on TTY error indicate that all data
was sent. It seems SLIP does not return error codes to the network
layer.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
---
 drivers/net/slip/slip.c | 26 ++++++++++++++++++++++----
 1 file changed, 22 insertions(+), 4 deletions(-)

diff --git a/drivers/net/slip/slip.c b/drivers/net/slip/slip.c
index a34d6bf..bed819f 100644
--- a/drivers/net/slip/slip.c
+++ b/drivers/net/slip/slip.c
@@ -374,7 +374,7 @@ static void sl_bump(struct slip *sl)
 static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
 {
 	unsigned char *p;
-	int actual, count;
+	int actual, count, err;
 
 	if (len > sl->mtu) {		/* Sigh, shouldn't occur BUT ... */
 		printk(KERN_WARNING "%s: truncating oversized transmit packet!\n", sl->dev->name);
@@ -404,7 +404,16 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
 	 *       14 Oct 1994  Dmitry Gorodchanin.
 	 */
 	set_bit(TTY_DO_WRITE_WAKEUP, &sl->tty->flags);
-	actual = sl->tty->ops->write(sl->tty, sl->xbuff, count);
+	err = sl->tty->ops->write(sl->tty, sl->xbuff, count);
+
+	if (err < 0) {
+		/* error case, say all was sent as connectionless */
+		actual = count;
+	} else {
+		/* good case, err contains the number sent */
+		actual = err;
+	}
+
 #ifdef SL_CHECK_TRANSMIT
 	sl->dev->trans_start = jiffies;
 #endif
@@ -422,7 +431,7 @@ static void sl_encaps(struct slip *sl, unsigned char *icp, int len)
  */
 static void slip_write_wakeup(struct tty_struct *tty)
 {
-	int actual;
+	int actual, err;
 	struct slip *sl = tty->disc_data;
 
 	/* First make sure we're connected. */
@@ -438,7 +447,16 @@ static void slip_write_wakeup(struct tty_struct *tty)
 		return;
 	}
 
-	actual = tty->ops->write(tty, sl->xhead, sl->xleft);
+	err = tty->ops->write(tty, sl->xhead, sl->xleft);
+
+	if (err < 0) {
+		/* error case, say all was sent as connectionless */
+		actual = sl->xleft;
+	} else {
+		/* good case, err contains the number sent */
+		actual = err;
+	}
+
 	sl->xleft -= actual;
 	sl->xhead += actual;
 }
-- 
1.8.1.5
