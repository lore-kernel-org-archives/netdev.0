From: Dean Jenkins <Dean_Jenkins@mentor.com>
Subject: [PATCH 1/5] Bluetooth: Add RFCOMM TTY write return error codes
Date: Wed, 19 Jun 2013 16:34:27 +0100
Message-ID: <1371656071-27754-2-git-send-email-Dean_Jenkins@mentor.com>
References: <1371656071-27754-1-git-send-email-Dean_Jenkins@mentor.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpc6-farn7-2-0-cust119.6-2.cable.virginmedia.com ([81.110.26.120]:37730
	"EHLO localhost.localdomain" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1756745Ab3FSPl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 11:41:29 -0400
In-Reply-To: <1371656071-27754-1-git-send-email-Dean_Jenkins@mentor.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It appears that rfcomm_tty_write() does not check that the
passed in TTY device_data is not NULL and also does not check
that the RFCOMM DLC serial data link pointer is not NULL.

A kernel crash was observed whilst SLIP was bound to /dev/rfcomm0
but the /dev/rfcomm0 had subsequently disconnected. Unfortunately,
SLIP attempted to write to the now non-existant RFCOMM TTY device
which caused a NULL pointer dereference because the device_data
no longer existed.

Therefore, add NULL pointer checks for the dev and dlc pointers
and output kernel error debug to show that NULL had been detected.

Signed-off-by: Dean Jenkins <Dean_Jenkins@mentor.com>
---
 net/bluetooth/rfcomm/tty.c | 14 +++++++++++++-
 1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/bluetooth/rfcomm/tty.c b/net/bluetooth/rfcomm/tty.c
index b6e44ad..56d28d1 100644
--- a/net/bluetooth/rfcomm/tty.c
+++ b/net/bluetooth/rfcomm/tty.c
@@ -761,12 +761,24 @@ static void rfcomm_tty_close(struct tty_struct *tty, struct file *filp)
 static int rfcomm_tty_write(struct tty_struct *tty, const unsigned char *buf, int count)
 {
 	struct rfcomm_dev *dev = (struct rfcomm_dev *) tty->driver_data;
-	struct rfcomm_dlc *dlc = dev->dlc;
+	struct rfcomm_dlc *dlc;
 	struct sk_buff *skb;
 	int err = 0, sent = 0, size;
 
 	BT_DBG("tty %p count %d", tty, count);
 
+	if (!dev) {
+		BT_ERR("RFCOMM TTY device data structure does not exist");
+		return -ENODEV;
+	}
+
+	dlc = dev->dlc;
+
+	if (!dlc) {
+		BT_ERR("RFCOMM serial data link does not exist");
+		return -ENOLINK;
+	}
+
 	while (count) {
 		size = min_t(uint, count, dlc->mtu);
 
-- 
1.8.1.5
