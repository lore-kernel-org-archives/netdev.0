From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next 2/2] tuntap: orphan frags before trying to set tx timestamp
Date: Wed,  4 Sep 2013 12:33:46 +0800
Message-ID: <1378269226-5969-2-git-send-email-jasowang@redhat.com>
References: <1378269226-5969-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1378269226-5969-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sock_tx_timestamp() will clear all zerocopy flags of skb which may lead the
frags never to be orphaned. This will break guest to guest traffic when zerocopy
is enabled. Fix this by orphaning the frags before trying to set tx time stamp.

The issue were introduced by commit eda297729171fe16bf34fe5b0419dfb69060f623
(tun: Support software transmit time stamping).

Cc: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |    9 +++++----
 1 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 2dddb1b..af9a096 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -749,15 +749,16 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 			  >= dev->tx_queue_len / tun->numqueues)
 		goto drop;
 
+	/* Orphan the skb - required as we might hang on to it
+	 * for indefinite time. */
+	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+		goto drop;
+
 	if (skb->sk) {
 		sock_tx_timestamp(skb->sk, &skb_shinfo(skb)->tx_flags);
 		sw_tx_timestamp(skb);
 	}
 
-	/* Orphan the skb - required as we might hang on to it
-	 * for indefinite time. */
-	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
-		goto drop;
 	skb_orphan(skb);
 
 	nf_reset(skb);
-- 
1.7.1
