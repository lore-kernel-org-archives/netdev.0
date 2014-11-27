From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V3] tun/macvtap: use consume_skb() instead of kfree_skb() when needed
Date: Thu, 27 Nov 2014 14:36:06 +0800
Message-ID: <1417070166-7026-1-git-send-email-jasowang@redhat.com>
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
Changes from V2:
- use unlikely() when necessary
Changes from V1:
- check the return value of tun/macvtap_put_user()
---
 drivers/net/macvtap.c | 5 ++++-
 drivers/net/tun.c     | 5 ++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 42a80d3..86f6bf8 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -862,7 +862,10 @@ static ssize_t macvtap_do_read(struct macvtap_queue *q,
 		}
 		iov_iter_init(&iter, READ, iv, segs, len);
 		ret = macvtap_put_user(q, skb, &iter);
-		kfree_skb(skb);
+		if (unlikely(ret < 0))
+			kfree_skb(skb);
+		else
+			consume_skb(skb);
 		break;
 	}
 
diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index ac53a73..82a9bf0 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1363,7 +1363,10 @@ static ssize_t tun_do_read(struct tun_struct *tun, struct tun_file *tfile,
 
 	iov_iter_init(&iter, READ, iv, segs, len);
 	ret = tun_put_user(tun, tfile, skb, &iter);
-	kfree_skb(skb);
+	if (unlikely(ret < 0))
+		kfree_skb(skb);
+	else
+		consume_skb(skb);
 
 	return ret;
 }
-- 
1.9.1
