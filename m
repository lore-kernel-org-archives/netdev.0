From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: [PATCH net-next v2] xen-netfront: always set num queues if possible
Date: Wed, 16 Sep 2015 16:28:25 -0400
Message-ID: <1442435305.3494.21.camel@gmail.com>
References: <1442266096.3494.15.camel@gmail.com>
	 <55F7FA2D.5040701@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:32992 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751965AbbIPU21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Sep 2015 16:28:27 -0400
Received: by qgev79 with SMTP id v79so182069571qge.0
        for <netdev@vger.kernel.org>; Wed, 16 Sep 2015 13:28:26 -0700 (PDT)
In-Reply-To: <55F7FA2D.5040701@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If netfront connects with two (or more) queues and then reconnects with
only one queue it fails to delete or rewrite the multi-queue-num-queues
key and netback will try to use the wrong number of queues.

Always write the num-queues field if the backend has multi-queue support.

Signed-off-by: Chas Williams <3chas3@gmail.com>
---
 drivers/net/xen-netfront.c | 17 ++++++++++-------
 1 file changed, 10 insertions(+), 7 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f821a97..9bf63c2 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1819,19 +1819,22 @@ again:
 		goto destroy_ring;
 	}
 
-	if (num_queues == 1) {
-		err = write_queue_xenstore_keys(&info->queues[0], &xbt, 0); /* flat */
-		if (err)
-			goto abort_transaction_no_dev_fatal;
-	} else {
+	if (xenbus_exists(XBT_NIL,
+			  info->xbdev->otherend, "multi-queue-max-queues")) {
 		/* Write the number of queues */
-		err = xenbus_printf(xbt, dev->nodename, "multi-queue-num-queues",
-				    "%u", num_queues);
+		err = xenbus_printf(xbt, dev->nodename,
+				    "multi-queue-num-queues", "%u", num_queues);
 		if (err) {
 			message = "writing multi-queue-num-queues";
 			goto abort_transaction_no_dev_fatal;
 		}
+	}
 
+	if (num_queues == 1) {
+		err = write_queue_xenstore_keys(&info->queues[0], &xbt, 0); /* flat */
+		if (err)
+			goto abort_transaction_no_dev_fatal;
+	} else {
 		/* Write the keys for each queue */
 		for (i = 0; i < num_queues; ++i) {
 			queue = &info->queues[i];
-- 
2.1.0
