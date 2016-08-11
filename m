From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net] macvtap: fix use after free for skb_array during release
Date: Thu, 11 Aug 2016 18:15:56 +0800
Message-ID: <1470910556-11872-1-git-send-email-jasowang@redhat.com>
Cc: borntraeger@de.ibm.com, cornelia.huck@de.ibm.com, mst@redhat.com,
	Jason Wang <jasowang@redhat.com>
To: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:46664 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752590AbcHKKQC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Aug 2016 06:16:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We've clean skb_array in macvtap_put_queue() but still try to pop from
it during macvtap_sock_destruct(). Fix this use after free by moving
the skb array cleanup to macvtap_sock_destruct() instead.

Fixes: 362899b8725b ("macvtap: switch to use skb array")
Reported-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Tested-by: Cornelia Huck <cornelia.huck@de.ibm.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a38c0da..070e329 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -275,7 +275,6 @@ static void macvtap_put_queue(struct macvtap_queue *q)
 	rtnl_unlock();
 
 	synchronize_rcu();
-	skb_array_cleanup(&q->skb_array);
 	sock_put(&q->sk);
 }
 
@@ -533,10 +532,8 @@ static void macvtap_sock_write_space(struct sock *sk)
 static void macvtap_sock_destruct(struct sock *sk)
 {
 	struct macvtap_queue *q = container_of(sk, struct macvtap_queue, sk);
-	struct sk_buff *skb;
 
-	while ((skb = skb_array_consume(&q->skb_array)) != NULL)
-		kfree_skb(skb);
+	skb_array_cleanup(&q->skb_array);
 }
 
 static int macvtap_open(struct inode *inode, struct file *file)
-- 
2.7.4
