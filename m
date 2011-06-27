From: Jon Mason <mason@myri.com>
Subject: [PATCH 1/9] myri10ge: ensure tx queues remain stopped
Date: Mon, 27 Jun 2011 10:05:00 -0500
Message-ID: <1309187108-12715-1-git-send-email-mason@myri.com>
Cc: netdev@vger.kernel.org, Andrew Gallatin <gallatin@myri.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:45826 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118Ab1F0PFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jun 2011 11:05:14 -0400
Received: by pzk9 with SMTP id 9so3015778pzk.19
        for <netdev@vger.kernel.org>; Mon, 27 Jun 2011 08:05:14 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ensure that our tx queues remain stopped when we stop them in
myri10ge_close().  Not doing so can potentially lead to traffic being
transmitted when the interface is removed, which can lead to NULL
pointer dereferences.

Signed-off-by: Jon Mason <mason@myri.com>
---
 drivers/net/myri10ge/myri10ge.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/myri10ge/myri10ge.c b/drivers/net/myri10ge/myri10ge.c
index 3ed5f35..a8ae641 100644
--- a/drivers/net/myri10ge/myri10ge.c
+++ b/drivers/net/myri10ge/myri10ge.c
@@ -1461,7 +1461,8 @@ myri10ge_tx_done(struct myri10ge_slice_state *ss, int mcp_index)
 
 	/* start the queue if we've stopped it */
 	if (netif_tx_queue_stopped(dev_queue) &&
-	    tx->req - tx->done < (tx->mask >> 1)) {
+	    tx->req - tx->done < (tx->mask >> 1) &&
+	    ss->mgp->running == MYRI10GE_ETH_RUNNING) {
 		tx->wake_queue++;
 		netif_tx_wake_queue(dev_queue);
 	}
-- 
1.7.5.4

