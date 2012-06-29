From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: l2tp_eth: provide tx_dropped counter
Date: Fri, 29 Jun 2012 08:15:13 +0200
Message-ID: <1340950513.29822.103.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:47688 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750991Ab2F2GPQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2012 02:15:16 -0400
Received: by eaak11 with SMTP id k11so1156019eaa.19
        for <netdev@vger.kernel.org>; Thu, 28 Jun 2012 23:15:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Change l2tp_xmit_skb() to return NET_XMIT_DROP in case skb is dropped.

Use kfree_skb() instead dev_kfree_skb() for drop_monitor pleasure.

Support tx_dropped counter for l2tp_eth

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: James Chapman <jchapman@katalix.com>
---
 net/l2tp/l2tp_core.c |   11 ++++++-----
 net/l2tp/l2tp_eth.c  |   15 ++++++++++-----
 2 files changed, 16 insertions(+), 10 deletions(-)

diff --git a/net/l2tp/l2tp_core.c b/net/l2tp/l2tp_core.c
index 32b2155..393355d 100644
--- a/net/l2tp/l2tp_core.c
+++ b/net/l2tp/l2tp_core.c
@@ -1128,6 +1128,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 	int headroom;
 	int uhlen = (tunnel->encap == L2TP_ENCAPTYPE_UDP) ? sizeof(struct udphdr) : 0;
 	int udp_len;
+	int ret = NET_XMIT_SUCCESS;
 
 	/* Check that there's enough headroom in the skb to insert IP,
 	 * UDP and L2TP headers. If not enough, expand it to
@@ -1137,8 +1138,8 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 		uhlen + hdr_len;
 	old_headroom = skb_headroom(skb);
 	if (skb_cow_head(skb, headroom)) {
-		dev_kfree_skb(skb);
-		goto abort;
+		kfree_skb(skb);
+		return NET_XMIT_DROP;
 	}
 
 	new_headroom = skb_headroom(skb);
@@ -1156,7 +1157,8 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 
 	bh_lock_sock(sk);
 	if (sock_owned_by_user(sk)) {
-		dev_kfree_skb(skb);
+		kfree_skb(skb);
+		ret = NET_XMIT_DROP;
 		goto out_unlock;
 	}
 
@@ -1215,8 +1217,7 @@ int l2tp_xmit_skb(struct l2tp_session *session, struct sk_buff *skb, int hdr_len
 out_unlock:
 	bh_unlock_sock(sk);
 
-abort:
-	return 0;
+	return ret;
 }
 EXPORT_SYMBOL_GPL(l2tp_xmit_skb);
 
diff --git a/net/l2tp/l2tp_eth.c b/net/l2tp/l2tp_eth.c
index 47b259f..f9ee74d 100644
--- a/net/l2tp/l2tp_eth.c
+++ b/net/l2tp/l2tp_eth.c
@@ -44,6 +44,7 @@ struct l2tp_eth {
 	struct list_head	list;
 	atomic_long_t		tx_bytes;
 	atomic_long_t		tx_packets;
+	atomic_long_t		tx_dropped;
 	atomic_long_t		rx_bytes;
 	atomic_long_t		rx_packets;
 	atomic_long_t		rx_errors;
@@ -92,12 +93,15 @@ static int l2tp_eth_dev_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct l2tp_eth *priv = netdev_priv(dev);
 	struct l2tp_session *session = priv->session;
+	unsigned int len = skb->len;
+	int ret = l2tp_xmit_skb(session, skb, session->hdr_len);
 
-	atomic_long_add(skb->len, &priv->tx_bytes);
-	atomic_long_inc(&priv->tx_packets);
-
-	l2tp_xmit_skb(session, skb, session->hdr_len);
-
+	if (likely(ret == NET_XMIT_SUCCESS)) {
+		atomic_long_add(len, &priv->tx_bytes);
+		atomic_long_inc(&priv->tx_packets);
+	} else {
+		atomic_long_inc(&priv->tx_dropped);
+	}
 	return NETDEV_TX_OK;
 }
 
@@ -108,6 +112,7 @@ static struct rtnl_link_stats64 *l2tp_eth_get_stats64(struct net_device *dev,
 
 	stats->tx_bytes   = atomic_long_read(&priv->tx_bytes);
 	stats->tx_packets = atomic_long_read(&priv->tx_packets);
+	stats->tx_dropped = atomic_long_read(&priv->tx_dropped);
 	stats->rx_bytes   = atomic_long_read(&priv->rx_bytes);
 	stats->rx_packets = atomic_long_read(&priv->rx_packets);
 	stats->rx_errors  = atomic_long_read(&priv->rx_errors);
