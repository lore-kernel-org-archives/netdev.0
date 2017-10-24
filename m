From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH] tap: double-free in error path in tap_open()
Date: Tue, 24 Oct 2017 14:41:10 -0700
Message-ID: <1508881270-4124-1-git-send-email-girish.moodalbail@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:49028 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932141AbdJXWDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Oct 2017 18:03:41 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Double free of skb_array in tap module is causing kernel panic. When
tap_set_queue() fails we free skb_array right away by calling
skb_array_cleanup(). However, later on skb_array_cleanup() is called
again by tap_sock_destruct through sock_put(). This patch fixes that
issue.

Fixes: 362899b8725b35e3 (macvtap: switch to use skb array)
Signed-off-by: Girish Moodalbail <girish.moodalbail@oracle.com>
---
 drivers/net/tap.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 21b71ae..878520b 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -542,20 +542,20 @@ static int tap_open(struct inode *inode, struct file *file)
 
 	err = -ENOMEM;
 	if (skb_array_init(&q->skb_array, tap->dev->tx_queue_len, GFP_KERNEL))
-		goto err_array;
+		goto err_put;
 
 	err = tap_set_queue(tap, file, q);
-	if (err)
-		goto err_queue;
+	if (err) {
+		/* tap_sock_destruct() will take care of freeing skb_array */
+		goto err_put;
+	}
 
 	dev_put(tap->dev);
 
 	rtnl_unlock();
 	return err;
 
-err_queue:
-	skb_array_cleanup(&q->skb_array);
-err_array:
+err_put:
 	sock_put(&q->sk);
 err:
 	if (tap)
-- 
1.8.3.1
