From: Filipe Manco <filipe.manco@neclab.eu>
Subject: [RFC PATCH] xen-netback: fix error handling on netback_probe()
Date: Tue, 13 Sep 2016 14:11:27 +0200
Message-ID: <1473768687-27384-1-git-send-email-filipe.manco@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wei.liu2@citrix.com>, <filipe.manco@neclab.eu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:48293 "EHLO mailer1.neclab.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751433AbcIMMYT (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 13 Sep 2016 08:24:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of error during netback_probe() (e.g. an entry missing on the
xenstore) netback_remove() is called on the new device, which will set
the device backend state to XenbusStateClosed by calling
set_backend_state(). However, the backend state wasn't initialized by
netback_probe() at this point, which will cause and invalid transaction
and set_backend_state() to BUG().

Initialize the backend state at the beginning of netback_probe() to
XenbusStateInitialising, and create a new valid state transaction on
set_backend_state(), from XenbusStateInitialising to XenbusStateClosed.

Signed-off-by: Filipe Manco <filipe.manco@neclab.eu>
---
 drivers/net/xen-netback/xenbus.c | 10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 6a31f2610c23..c0e5f6994d01 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -270,6 +270,7 @@ static int netback_probe(struct xenbus_device *dev,
 
 	be->dev = dev;
 	dev_set_drvdata(&dev->dev, be);
+	be->state = XenbusStateInitialising;
 
 	sg = 1;
 
@@ -515,6 +516,15 @@ static void set_backend_state(struct backend_info *be,
 {
 	while (be->state != state) {
 		switch (be->state) {
+		case XenbusStateInitialising:
+			switch (state) {
+			case XenbusStateClosed:
+				backend_switch_state(be, XenbusStateClosed);
+				break;
+			default:
+				BUG();
+			}
+			break;
 		case XenbusStateClosed:
 			switch (state) {
 			case XenbusStateInitWait:
-- 
2.7.4
