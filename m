From: David Miller <davem@davemloft.net>
Subject: [PATCH 1/2] net: Push protocol type directly down to
 header_ops->cache()
Date: Wed, 13 Jul 2011 01:52:16 -0700 (PDT)
Message-ID: <20110713.015216.284680994364312553.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:48476 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965064Ab1GMIwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 04:52:17 -0400
Received: from localhost (74-93-104-98-Washington.hfc.comcastbusiness.net [74.93.104.98])
	(authenticated bits=0)
	by shards.monkeyblade.net (8.14.4/8.14.4) with ESMTP id p6D8qGOv016947
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 13 Jul 2011 01:52:16 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/firewire/net.c      |    6 +++---
 drivers/isdn/i4l/isdn_net.c |    5 +++--
 drivers/net/plip.c          |    6 +++---
 include/linux/etherdevice.h |    2 +-
 include/linux/netdevice.h   |    2 +-
 net/core/neighbour.c        |    2 +-
 net/ethernet/eth.c          |    3 +--
 7 files changed, 13 insertions(+), 13 deletions(-)

diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
index b9762d0..eced1c2 100644
--- a/drivers/firewire/net.c
+++ b/drivers/firewire/net.c
@@ -261,16 +261,16 @@ static int fwnet_header_rebuild(struct sk_buff *skb)
 }
 
 static int fwnet_header_cache(const struct neighbour *neigh,
-			      struct hh_cache *hh)
+			      struct hh_cache *hh, __be16 type)
 {
 	struct net_device *net;
 	struct fwnet_header *h;
 
-	if (hh->hh_type == cpu_to_be16(ETH_P_802_3))
+	if (type == cpu_to_be16(ETH_P_802_3))
 		return -1;
 	net = neigh->dev;
 	h = (struct fwnet_header *)((u8 *)hh->hh_data + 16 - sizeof(*h));
-	h->h_proto = hh->hh_type;
+	h->h_proto = type;
 	memcpy(h->h_dest, neigh->ha, net->addr_len);
 	hh->hh_len = FWNET_HLEN;
 
diff --git a/drivers/isdn/i4l/isdn_net.c b/drivers/isdn/i4l/isdn_net.c
index 9798811..48e9cc0 100644
--- a/drivers/isdn/i4l/isdn_net.c
+++ b/drivers/isdn/i4l/isdn_net.c
@@ -1983,13 +1983,14 @@ isdn_net_rebuild_header(struct sk_buff *skb)
 	return ret;
 }
 
-static int isdn_header_cache(const struct neighbour *neigh, struct hh_cache *hh)
+static int isdn_header_cache(const struct neighbour *neigh, struct hh_cache *hh,
+			     __be16 type)
 {
 	const struct net_device *dev = neigh->dev;
 	isdn_net_local *lp = netdev_priv(dev);
 
 	if (lp->p_encap == ISDN_NET_ENCAP_ETHER)
-		return eth_header_cache(neigh, hh);
+		return eth_header_cache(neigh, hh, type);
 	return -1;
 }
 
diff --git a/drivers/net/plip.c b/drivers/net/plip.c
index ca4df7f..a9e9ca8 100644
--- a/drivers/net/plip.c
+++ b/drivers/net/plip.c
@@ -152,7 +152,7 @@ static int plip_hard_header(struct sk_buff *skb, struct net_device *dev,
                             unsigned short type, const void *daddr,
 			    const void *saddr, unsigned len);
 static int plip_hard_header_cache(const struct neighbour *neigh,
-                                  struct hh_cache *hh);
+                                  struct hh_cache *hh, __be16 type);
 static int plip_open(struct net_device *dev);
 static int plip_close(struct net_device *dev);
 static int plip_ioctl(struct net_device *dev, struct ifreq *ifr, int cmd);
@@ -1026,11 +1026,11 @@ plip_hard_header(struct sk_buff *skb, struct net_device *dev,
 }
 
 static int plip_hard_header_cache(const struct neighbour *neigh,
-				  struct hh_cache *hh)
+				  struct hh_cache *hh, __be16 type)
 {
 	int ret;
 
-	ret = eth_header_cache(neigh, hh);
+	ret = eth_header_cache(neigh, hh, type);
 	if (ret == 0) {
 		struct ethhdr *eth;
 
diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index ab68f78..05955cf 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -38,7 +38,7 @@ extern int eth_header(struct sk_buff *skb, struct net_device *dev,
 		      const void *daddr, const void *saddr, unsigned len);
 extern int eth_rebuild_header(struct sk_buff *skb);
 extern int eth_header_parse(const struct sk_buff *skb, unsigned char *haddr);
-extern int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh);
+extern int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh, __be16 type);
 extern void eth_header_cache_update(struct hh_cache *hh,
 				    const struct net_device *dev,
 				    const unsigned char *haddr);
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 30f17e4..564d89f 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -308,7 +308,7 @@ struct header_ops {
 			   const void *saddr, unsigned len);
 	int	(*parse)(const struct sk_buff *skb, unsigned char *haddr);
 	int	(*rebuild)(struct sk_buff *skb);
-	int	(*cache)(const struct neighbour *neigh, struct hh_cache *hh);
+	int	(*cache)(const struct neighbour *neigh, struct hh_cache *hh, __be16 type);
 	void	(*cache_update)(struct hh_cache *hh,
 				const struct net_device *dev,
 				const unsigned char *haddr);
diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index 50bd960..8f7e1d8 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -1247,7 +1247,7 @@ static void neigh_hh_init(struct neighbour *n, struct dst_entry *dst,
 	hh->hh_type = protocol;
 	atomic_set(&hh->hh_refcnt, 2);
 
-	if (dev->header_ops->cache(n, hh)) {
+	if (dev->header_ops->cache(n, hh, protocol)) {
 		kfree(hh);
 		return;
 	}
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index 44d2b42..5cffb63 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -233,9 +233,8 @@ EXPORT_SYMBOL(eth_header_parse);
  * @hh: destination cache entry
  * Create an Ethernet header template from the neighbour.
  */
-int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh)
+int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh, __be16 type)
 {
-	__be16 type = hh->hh_type;
 	struct ethhdr *eth;
 	const struct net_device *dev = neigh->dev;
 
-- 
1.7.6

