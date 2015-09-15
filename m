From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: [PATCH net-next] xen-netfront: always set num queues if possible
Date: Tue, 15 Sep 2015 10:49:01 -0400
Message-ID: <1442328541.3494.19.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f51.google.com ([209.85.192.51]:36009 "EHLO
	mail-qg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752531AbbIOOtE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2015 10:49:04 -0400
Received: by qgx61 with SMTP id 61so144822159qgx.3
        for <netdev@vger.kernel.org>; Tue, 15 Sep 2015 07:49:02 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If netfront connects with two (or more) queues and then reconnects with
only one queue it fails to delete or rewrite the multi-queue-num-queues
key and netback will try to use the wrong number of queues.

Always write the num-queues field if the backend has multi-queue support.

Signed-off-by: Chas Williams <3chas3@gmail.com>
---
 drivers/net/xen-netfront.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f821a97..7f8b7bd 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1819,11 +1819,7 @@ again:
 		goto destroy_ring;
 	}
 
-	if (num_queues == 1) {
-		err = write_queue_xenstore_keys(&info->queues[0], &xbt, 0); /* flat */
-		if (err)
-			goto abort_transaction_no_dev_fatal;
-	} else {
+	if (xenbus_exists(xbt, dev->nodename, "multi-queue-max-queues")) {
 		/* Write the number of queues */
 		err = xenbus_printf(xbt, dev->nodename, "multi-queue-num-queues",
 				    "%u", num_queues);
@@ -1831,7 +1827,13 @@ again:
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
