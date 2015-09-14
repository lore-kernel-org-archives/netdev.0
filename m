From: "Charles (Chas) Williams" <3chas3@gmail.com>
Subject: [PATCH net-next] xen-netfront: always set num queues if possible
Date: Mon, 14 Sep 2015 17:28:16 -0400
Message-ID: <1442266096.3494.15.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, xen-devel@lists.xenproject.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f53.google.com ([209.85.192.53]:35440 "EHLO
	mail-qg0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751061AbbINV2R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2015 17:28:17 -0400
Received: by qgt47 with SMTP id 47so126887537qgt.2
        for <netdev@vger.kernel.org>; Mon, 14 Sep 2015 14:28:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The xen store preserves this information across module invocations.
If you insmod netfront with two queues and later insmod again with one
queue, the backend will still believe you asked for two queues.

Signed-off-by: Chas Williams <3chas3@gmail.com>
---
 drivers/net/xen-netfront.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index f821a97..b53a681 100644
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
+	if (xenbus_exists(xbt, dev->nodename, "multi-queue-num-queues")) {
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
