From: fgao@ikuai8.com
Subject: [PATCH net 1/1] driver: veth: Return the actual value instead return NETDEV_TX_OK always
Date: Wed,  2 Nov 2016 17:59:16 +0800
Message-ID: <1478080756-16789-1-git-send-email-fgao@ikuai8.com>
Cc: gfree.wind@gmail.com, Gao Feng <fgao@ikuai8.com>
To: davem@davemloft.net, cwang@twopensource.com, vijayp@vijayp.ca,
        ej@evanjones.ca, pabeni@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from SMTPBG181.QQ.COM ([119.147.193.88]:58943 "EHLO smtpbg181.qq.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752656AbcKBKJJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Nov 2016 06:09:09 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gao Feng <fgao@ikuai8.com>

Current veth_xmit always returns NETDEV_TX_OK whatever if it is really
sent successfully. Now return the actual value instead of NETDEV_TX_OK
always.

Signed-off-by: Gao Feng <fgao@ikuai8.com>
---
 drivers/net/veth.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/net/veth.c b/drivers/net/veth.c
index fbc853e..769a3bd 100644
--- a/drivers/net/veth.c
+++ b/drivers/net/veth.c
@@ -111,15 +111,18 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 	struct veth_priv *priv = netdev_priv(dev);
 	struct net_device *rcv;
 	int length = skb->len;
+	int ret = NETDEV_TX_OK;
 
 	rcu_read_lock();
 	rcv = rcu_dereference(priv->peer);
 	if (unlikely(!rcv)) {
 		kfree_skb(skb);
+		ret = NET_RX_DROP;
 		goto drop;
 	}
 
-	if (likely(dev_forward_skb(rcv, skb) == NET_RX_SUCCESS)) {
+	ret = dev_forward_skb(rcv, skb);
+	if (likely(ret == NET_RX_SUCCESS)) {
 		struct pcpu_vstats *stats = this_cpu_ptr(dev->vstats);
 
 		u64_stats_update_begin(&stats->syncp);
@@ -131,7 +134,7 @@ static netdev_tx_t veth_xmit(struct sk_buff *skb, struct net_device *dev)
 		atomic64_inc(&priv->dropped);
 	}
 	rcu_read_unlock();
-	return NETDEV_TX_OK;
+	return ret;
 }
 
 /*
-- 
1.9.1
