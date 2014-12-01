From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V4 net-next] tun/macvtap: use consume_skb() instead of kfree_skb() when needed
Date: Mon,  1 Dec 2014 16:53:15 +0800
Message-ID: <1417423995-4765-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

To be more friendly with drop monitor, we should only call kfree_skb() when
the packets were dropped and use consume_skb() in other cases.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
Changes from V3:
- rebase to net-next.git
Changes from V2:
- use unlikely() when necessary
Changes from V1:
- check the return value of tun/macvtap_put_user()
---
 drivers/net/macvtap.c | 5 ++++-
 drivers/net/tun.c     | 5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 22b4cf2..ba1e5db 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -859,7 +859,10 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
 	}
 	if (skb) {
 		ret = macvtap_put_user(q, skb, to);
-		kfree_skb(skb);
+		if (unlikely(ret < 0))
+			kfree_skb(skb);
+		else
+			consume_skb(skb);
 	}
 	if (!noblock)
 		finish_wait(sk_sleep(&q->sk), &wait);
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 6d44da1..9c58286 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1362,7 +1362,10 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 		return 0;
 
 	ret = tun_put_user(tun, tfile, skb, to);
-	kfree_skb(skb);
+	if (unlikely(ret < 0))
+		kfree_skb(skb);
+	else
+		consume_skb(skb);
 
 	return ret;
 }
-- 
1.9.1
