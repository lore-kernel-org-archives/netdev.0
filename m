From: Paul Durrant <paul.durrant@citrix.com>
Subject: [PATCH net-next] xen-netfront: reject short packets and handle non-linear packets
Date: Wed, 25 Jan 2017 16:26:52 +0000
Message-ID: <1485361612-10154-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Paul Durrant <paul.durrant@citrix.com>,
        Boris Ostrovsky <boris.ostrovsky@oracle.com>,
        Juergen Gross <jgross@suse.com>
To: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:36469 "EHLO SMTP.CITRIX.COM"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750731AbdAYQ04 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 25 Jan 2017 11:26:56 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sowmini points out two vulnerabilities in xen-netfront:

a) The code assumes that skb->len is at least ETH_HLEN.
b) The code assumes that at least ETH_HLEN octets are in the linear
   port of the socket buffer.

This patch adds tests for both of these, and in the case of the latter
pulls sufficient bytes into the linear area.

Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
Reported-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Tested-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
---
Cc: Boris Ostrovsky <boris.ostrovsky@oracle.com>
Cc: Juergen Gross <jgross@suse.com>
---
 drivers/net/xen-netfront.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index 40f26b6..0478809 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -567,6 +567,10 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	u16 queue_index;
 	struct sk_buff *nskb;
 
+	/* Basic sanity check */
+	if (unlikely(skb->len < ETH_HLEN))
+		goto drop;
+
 	/* Drop the packet if no queues are set up */
 	if (num_queues < 1)
 		goto drop;
@@ -609,6 +613,11 @@ static int xennet_start_xmit(struct sk_buff *skb, struct net_device *dev)
 	}
 
 	len = skb_headlen(skb);
+	if (unlikely(len < ETH_HLEN)) {
+		if (!__pskb_pull_tail(skb, ETH_HLEN - len))
+			goto drop;
+		len = ETH_HLEN;
+	}
 
 	spin_lock_irqsave(&queue->tx_lock, flags);
 
-- 
2.1.4
