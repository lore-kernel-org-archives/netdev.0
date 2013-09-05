From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH V2 net-next 2/2] tuntap: orphan frags before trying to set tx timestamp
Date: Thu,  5 Sep 2013 17:54:00 +0800
Message-ID: <1378374840-39130-2-git-send-email-jasowang@redhat.com>
References: <1378374840-39130-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Richard Cochran <richardcochran@gmail.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38584 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S935623Ab3IEKFt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 06:05:49 -0400
In-Reply-To: <1378374840-39130-1-git-send-email-jasowang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sock_tx_timestamp() will clear all zerocopy flags of skb which may lead the
frags never to be orphaned. This will break guest to guest traffic when zerocopy
is enabled. Fix this by orphaning the frags before trying to set tx time stamp.

The issue were introduced by commit eda297729171fe16bf34fe5b0419dfb69060f623
(tun: Support software transmit time stamping).

Cc: Richard Cochran <richardcochran@gmail.com>
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Acked-by: Richard Cochran <richardcochran@gmail.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
Changes from v1:
- correct the comment location and style
---
 drivers/net/tun.c |    8 +++++---
 1 files changed, 5 insertions(+), 3 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 2dddb1b..a639de8 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -749,15 +749,17 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 			  >= dev->tx_queue_len / tun->numqueues)
 		goto drop;
 
+	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+		goto drop;
+
 	if (skb->sk) {
 		sock_tx_timestamp(skb->sk, &skb_shinfo(skb)->tx_flags);
 		sw_tx_timestamp(skb);
 	}
 
 	/* Orphan the skb - required as we might hang on to it
-	 * for indefinite time. */
-	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
-		goto drop;
+	 * for indefinite time.
+	 */
 	skb_orphan(skb);
 
 	nf_reset(skb);
-- 
1.7.1
