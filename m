From: Jean Sacren <sakiwit@gmail.com>
Subject: [PATCH net-next] ieee802154: use helper function to get rid of redundancy
Date: Sat, 31 May 2014 17:39:02 -0600
Message-ID: <1401579542-17108-1-git-send-email-sakiwit@gmail.com>
Cc: Alexander Aring <alex.aring@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f51.google.com ([209.85.160.51]:51246 "EHLO
	mail-pb0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755481AbaEaXjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 31 May 2014 19:39:11 -0400
Received: by mail-pb0-f51.google.com with SMTP id ma3so2978987pbc.10
        for <netdev@vger.kernel.org>; Sat, 31 May 2014 16:39:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In some call sites of at86rf230_write_subreg(), they are rather
redundant. Use a helper function to replace those call sites for
efficiency.

With at86rf230_write_subreg_by_page(), now ->rssi_base_val is
assigned before at86rf230_write_subreg() is evaluated. Looking at
at86rf230_write_subreg(), that change could possibly affect

		__at86rf230_read_subreg()
and
		__at86rf230_write()

only or vice versa. Yet by the definition of

		struct at86rf230_local

changing ->rssi_base_val will in no way affect those two functions
above and evaluation of those two has no impact on ->rssi_base_val.
Thus, at86rf230_write_subreg_by_page() itself is safe.

Additionally at86rf230_write_subreg_by_channel() is simple and safe.

Signed-off-by: Jean Sacren <sakiwit@gmail.com>
---
 drivers/net/ieee802154/at86rf230.c | 34 +++++++++++++++++++++++-----------
 1 file changed, 23 insertions(+), 11 deletions(-)

diff --git a/drivers/net/ieee802154/at86rf230.c b/drivers/net/ieee802154/at86rf230.c
index 4517b149ed07..5aecbd1c402c 100644
--- a/drivers/net/ieee802154/at86rf230.c
+++ b/drivers/net/ieee802154/at86rf230.c
@@ -597,25 +597,37 @@ at86rf230_set_channel(struct at86rf230_local *lp, int page, int channel)
 	return at86rf230_write_subreg(lp, SR_CHANNEL, channel);
 }
 
+static int at86rf230_write_subreg_by_channel(struct at86rf230_local *lp,
+					     int channel)
+{
+	if (channel)
+		channel = 1;
+
+	return at86rf230_write_subreg(lp, SR_SUB_MODE, channel);
+}
+
+static int at86rf230_write_subreg_by_page(struct at86rf230_local *lp, int page)
+{
+	if (page) {
+		lp->rssi_base_val = -98;
+		page = 1;
+	} else {
+		lp->rssi_base_val = -100;
+	}
+
+	return at86rf230_write_subreg(lp, SR_BPSK_QPSK, page);
+}
+
 static int
 at86rf212_set_channel(struct at86rf230_local *lp, int page, int channel)
 {
 	int rc;
 
-	if (channel == 0)
-		rc = at86rf230_write_subreg(lp, SR_SUB_MODE, 0);
-	else
-		rc = at86rf230_write_subreg(lp, SR_SUB_MODE, 1);
+	rc = at86rf230_write_subreg_by_channel(lp, channel);
 	if (rc < 0)
 		return rc;
 
-	if (page == 0) {
-		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 0);
-		lp->rssi_base_val = -100;
-	} else {
-		rc = at86rf230_write_subreg(lp, SR_BPSK_QPSK, 1);
-		lp->rssi_base_val = -98;
-	}
+	rc = at86rf230_write_subreg_by_page(lp, page);
 	if (rc < 0)
 		return rc;
 
