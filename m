From: Filipe Manco <filipe.manco@neclab.eu>
Subject: [PATCH v2] xen-netback: fix error handling on netback_probe()
Date: Thu, 15 Sep 2016 17:10:46 +0200
Message-ID: <1473952246-27037-1-git-send-email-filipe.manco@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <wei.liu2@citrix.com>, <xen-devel@lists.xenproject.org>,
        Filipe Manco <filipe.manco@neclab.eu>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:55166 "EHLO mailer1.neclab.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751085AbcIOPK6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 11:10:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case of error during netback_probe() (e.g. an entry missing on the
xenstore) netback_remove() is called on the new device, which will set
the device backend state to XenbusStateClosed by calling
set_backend_state(). However, the backend state wasn't initialized by
netback_probe() at this point, which will cause and invalid transaction
and set_backend_state() to BUG().

Initialize the backend state at the beginning of netback_probe() to
XenbusStateInitialising, and create two new valid state transitions on
set_backend_state(), from XenbusStateInitialising to XenbusStateClosed,
and from XenbusStateInitialising to XenbusStateInitWait.

Signed-off-by: Filipe Manco <filipe.manco@neclab.eu>
---
 drivers/net/xen-netback/xenbus.c | 46 ++++++++++++++++++++++++++--------------
 1 file changed, 30 insertions(+), 16 deletions(-)

diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
index 6a31f2610c23..daf4c7867102 100644
--- a/drivers/net/xen-netback/xenbus.c
+++ b/drivers/net/xen-netback/xenbus.c
@@ -271,6 +271,11 @@ static int netback_probe(struct xenbus_device *dev,
 	be->dev = dev;
 	dev_set_drvdata(&dev->dev, be);
 
+	be->state = XenbusStateInitialising;
+	err = xenbus_switch_state(dev, XenbusStateInitialising);
+	if (err)
+		goto fail;
+
 	sg = 1;
 
 	do {
@@ -383,11 +388,6 @@ static int netback_probe(struct xenbus_device *dev,
 
 	be->hotplug_script = script;
 
-	err = xenbus_switch_state(dev, XenbusStateInitWait);
-	if (err)
-		goto fail;
-
-	be->state = XenbusStateInitWait;
 
 	/* This kicks hotplug scripts, so do it immediately. */
 	err = backend_create_xenvif(be);
@@ -492,20 +492,20 @@ static inline void backend_switch_state(struct backend_info *be,
 
 /* Handle backend state transitions:
  *
- * The backend state starts in InitWait and the following transitions are
+ * The backend state starts in Initialising and the following transitions are
  * allowed.
  *
- * InitWait -> Connected
- *
- *    ^    \         |
- *    |     \        |
- *    |      \       |
- *    |       \      |
- *    |        \     |
- *    |         \    |
- *    |          V   V
+ * Initialising -> InitWait -> Connected
+ *          \
+ *           \        ^    \         |
+ *            \       |     \        |
+ *             \      |      \       |
+ *              \     |       \      |
+ *               \    |        \     |
+ *                \   |         \    |
+ *                 V  |          V   V
  *
- *  Closed  <-> Closing
+ *                  Closed  <-> Closing
  *
  * The state argument specifies the eventual state of the backend and the
  * function transitions to that state via the shortest path.
@@ -515,6 +515,20 @@ static void set_backend_state(struct backend_info *be,
 {
 	while (be->state != state) {
 		switch (be->state) {
+		case XenbusStateInitialising:
+			switch (state) {
+			case XenbusStateInitWait:
+			case XenbusStateConnected:
+			case XenbusStateClosing:
+				backend_switch_state(be, XenbusStateInitWait);
+				break;
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
