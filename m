From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: [PATCH RFC 5/6] net: orphan frags on receive
Date: Mon, 7 May 2012 16:54:52 +0300
Message-ID: <a3353f6235d877c6b2d300eb5a914dbc9b78824d.1336397823.git.mst@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41059 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756826Ab2EGNyt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 May 2012 09:54:49 -0400
Content-Disposition: inline
In-Reply-To: <cover.1336397823.git.mst@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

zero copy packets are normally sent to the outside
network, but bridging, tun etc might loop them
back to host networking stack. If this happens
destructors will never be called, so orphan
the frags immediately on receive.

Signed-off-by: Michael S. Tsirkin <mst@redhat.com>
---
 net/core/dev.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index a2be59f..c0cdc00 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1630,6 +1630,8 @@ static inline int deliver_skb(struct sk_buff *skb,
 			      struct packet_type *pt_prev,
 			      struct net_device *orig_dev)
 {
+	if (unlikely(skb_orphan_frags(skb, GFP_ATOMIC)))
+		return -ENOMEM;
 	atomic_inc(&skb->users);
 	return pt_prev->func(skb, skb->dev, pt_prev, orig_dev);
 }
-- 
MST
