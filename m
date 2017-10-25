From: Girish Moodalbail <girish.moodalbail@oracle.com>
Subject: [PATCH v2] tap: double-free in error path in tap_open()
Date: Wed, 25 Oct 2017 00:23:04 -0700
Message-ID: <1508916184-17473-1-git-send-email-girish.moodalbail@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net, jasowang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:43910 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751878AbdJYHp7 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 03:45:59 -0400
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
v1 -> v2:
  - took care of an another issue in failure path of skb_array_init
---
 drivers/net/tap.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/drivers/net/tap.c b/drivers/net/tap.c
index 21b71ae..98ee6cc 100644
--- a/drivers/net/tap.c
+++ b/drivers/net/tap.c
@@ -517,6 +517,10 @@ static int tap_open(struct inode *inode, struct file *file)
 					     &tap_proto, 0);
 	if (!q)
 		goto err;
+	if (skb_array_init(&q->skb_array, tap->dev->tx_queue_len, GFP_KERNEL)) {
+		sk_free(&q->sk);
+		goto err;
+	}
 
 	RCU_INIT_POINTER(q->sock.wq, &q->wq);
 	init_waitqueue_head(&q->wq.wait);
@@ -540,22 +544,18 @@ static int tap_open(struct inode *inode, struct file *file)
 	if ((tap->dev->features & NETIF_F_HIGHDMA) && (tap->dev->features & NETIF_F_SG))
 		sock_set_flag(&q->sk, SOCK_ZEROCOPY);
 
-	err = -ENOMEM;
-	if (skb_array_init(&q->skb_array, tap->dev->tx_queue_len, GFP_KERNEL))
-		goto err_array;
-
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
