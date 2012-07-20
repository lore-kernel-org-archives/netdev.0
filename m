From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCHv3 5/6] net: orphan frags on receive
Date: Fri, 20 Jul 2012 22:23:17 +0300
Message-ID: <05e85615ac224ff6d47414c7f512b9c6b991fabc.1342812067.git.mst@redhat.com>
References: <cover.1342812067.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jason Wang <jasowang@redhat.com>, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ebiederm@xmission.com, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <cover.1342812067.git.mst@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

zero copy packets are normally sent to the outside
network, but bridging, tun etc might loop them
back to host networking stack. If this happens
destructors will never be called, so orphan
the frags immediately on receive.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/dev.c | 7 ++++++-
 1 file changed, 6 insertions(+), 1 deletion(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index d70e4a3..cca02ae 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1632,6 +1632,8 @@ static inline int deliver_skb(struct sk_buff *skb,
 			      struct packet_type *pt_prev,
 			      struct net_device *orig_dev)
 {
+	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+		return -ENOMEM;
 	atomic_inc(&skb->users);
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
@@ -3262,7 +3264,10 @@ ncls:
 	}
 
 	if (pt_prev) {
-		ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
+		if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+			ret = -ENOMEM;
+		else
+			ret = pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 	} else {
 		atomic_long_inc(&skb->dev->rx_dropped);
 		kfree_skb(skb);
-- 
MST
