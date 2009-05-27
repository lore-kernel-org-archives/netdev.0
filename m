From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] net: ALIGN/PTR_ALIGN cleanup in alloc_netdev_mq()/netdev_priv()
Date: Wed, 27 May 2009 16:42:37 +0200
Message-ID: <4A1D515D.90309@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:49311 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759714AbZE0Omi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2009 10:42:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Use ALIGN() and PTR_ALIGN() macros instead of handcoding them.

Get rid of NETDEV_ALIGN_CONST ugly define

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 include/linux/netdevice.h |    5 +----
 net/core/dev.c            |    9 ++++-----
 net/mac80211/main.c       |    8 ++------
 3 files changed, 7 insertions(+), 15 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 371ece5..14efce3 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -905,7 +905,6 @@ struct net_device
 #define to_net_dev(d) container_of(d, struct net_device, dev)
 
 #define	NETDEV_ALIGN		32
-#define	NETDEV_ALIGN_CONST	(NETDEV_ALIGN - 1)
 
 static inline
 struct netdev_queue *netdev_get_tx_queue(const struct net_device *dev,
@@ -976,9 +975,7 @@ static inline bool netdev_uses_trailer_tags(struct net_device *dev)
  */
 static inline void *netdev_priv(const struct net_device *dev)
 {
-	return (char *)dev + ((sizeof(struct net_device)
-			       + NETDEV_ALIGN_CONST)
-			      & ~NETDEV_ALIGN_CONST);
+	return (char *)dev + ALIGN(sizeof(struct net_device), NETDEV_ALIGN);
 }
 
 /* Set the sysfs physical device reference for the network logical device
diff --git a/net/core/dev.c b/net/core/dev.c
index ed4550f..32ceee1 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4988,18 +4988,18 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	struct netdev_queue *tx;
 	struct net_device *dev;
 	size_t alloc_size;
-	void *p;
+	struct net_device *p;
 
 	BUG_ON(strlen(name) >= sizeof(dev->name));
 
 	alloc_size = sizeof(struct net_device);
 	if (sizeof_priv) {
 		/* ensure 32-byte alignment of private area */
-		alloc_size = (alloc_size + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST;
+		alloc_size = ALIGN(alloc_size, NETDEV_ALIGN);
 		alloc_size += sizeof_priv;
 	}
 	/* ensure 32-byte alignment of whole construct */
-	alloc_size += NETDEV_ALIGN_CONST;
+	alloc_size += NETDEV_ALIGN - 1;
 
 	p = kzalloc(alloc_size, GFP_KERNEL);
 	if (!p) {
@@ -5014,8 +5014,7 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 		goto free_p;
 	}
 
-	dev = (struct net_device *)
-		(((long)p + NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
+	dev = PTR_ALIGN(p, NETDEV_ALIGN);
 	dev->padded = (char *)dev - (char *)p;
 
 	if (dev_addr_init(dev))
diff --git a/net/mac80211/main.c b/net/mac80211/main.c
index 6b7e92e..e37770c 100644
--- a/net/mac80211/main.c
+++ b/net/mac80211/main.c
@@ -735,9 +735,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 	 * +-------------------------+
 	 *
 	 */
-	priv_size = ((sizeof(struct ieee80211_local) +
-		      NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST) +
-		    priv_data_len;
+	priv_size = ALIGN(sizeof(*local), NETDEV_ALIGN) + priv_data_len;
 
 	wiphy = wiphy_new(&mac80211_config_ops, priv_size);
 
@@ -754,9 +752,7 @@ struct ieee80211_hw *ieee80211_alloc_hw(size_t priv_data_len,
 
 	local->hw.wiphy = wiphy;
 
-	local->hw.priv = (char *)local +
-			 ((sizeof(struct ieee80211_local) +
-			   NETDEV_ALIGN_CONST) & ~NETDEV_ALIGN_CONST);
+	local->hw.priv = (char *)local + ALIGN(sizeof(*local), NETDEV_ALIGN);
 
 	BUG_ON(!ops->tx);
 	BUG_ON(!ops->start);
