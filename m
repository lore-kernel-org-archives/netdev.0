From: Amos Kong <akong@redhat.com>
Subject: [PATCH v5 2/3] net: split eth_mac_addr for better error handling
Date: Mon, 21 Jan 2013 19:17:22 +0800
Message-ID: <1358767043-24548-3-git-send-email-akong@redhat.com>
References: <1358767043-24548-1-git-send-email-akong@redhat.com>
Cc: mst@redhat.com, rusty@rustcorp.com.au, qemu-devel@nongnu.org,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42092 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752981Ab3AULRm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 06:17:42 -0500
In-Reply-To: <1358767043-24548-1-git-send-email-akong@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@gmail.com>

When we set mac address, software mac address in system and hardware mac
address all need to be updated. Current eth_mac_addr() doesn't allow
callers to implement error handling nicely.

This patch split eth_mac_addr() to prepare part and real commit part,
then we can prepare first, and try to change hardware address, then do
the real commit if hardware address is set successfully.

Signed-off-by: Stefan Hajnoczi <stefanha@gmail.com>
Signed-off-by: Amos Kong <akong@redhat.com>
---
 include/linux/etherdevice.h |    2 ++
 net/ethernet/eth.c          |   41 +++++++++++++++++++++++++++++++++++------
 2 files changed, 37 insertions(+), 6 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 1a43e1b..c623861 100644
--- a/include/linux/etherdevice.h
+++ b/include/linux/etherdevice.h
@@ -40,6 +40,8 @@ extern int eth_header_cache(const struct neighbour *neigh, struct hh_cache *hh,
 extern void eth_header_cache_update(struct hh_cache *hh,
 				    const struct net_device *dev,
 				    const unsigned char *haddr);
+extern int eth_prepare_mac_addr_change(struct net_device *dev, void *p);
+extern void eth_commit_mac_addr_change(struct net_device *dev, void *p);
 extern int eth_mac_addr(struct net_device *dev, void *p);
 extern int eth_change_mtu(struct net_device *dev, int new_mtu);
 extern int eth_validate_addr(struct net_device *dev);
diff --git a/net/ethernet/eth.c b/net/ethernet/eth.c
index bc39c8c..a36c85e 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -272,6 +272,36 @@ void eth_header_cache_update(struct hh_cache *hh,
 EXPORT_SYMBOL(eth_header_cache_update);
 
 /**
+ * eth_prepare_mac_addr_change - prepare for mac change
+ * @dev: network device
+ * @p: socket address
+ */
+int eth_prepare_mac_addr_change(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+
+	if (!(dev->priv_flags & IFF_LIVE_ADDR_CHANGE) && netif_running(dev))
+		return -EBUSY;
+	if (!is_valid_ether_addr(addr->sa_data))
+		return -EADDRNOTAVAIL;
+	return 0;
+}
+EXPORT_SYMBOL(eth_prepare_mac_addr_change);
+
+/**
+ * eth_commit_mac_addr_change - commit mac change
+ * @dev: network device
+ * @p: socket address
+ */
+void eth_commit_mac_addr_change(struct net_device *dev, void *p)
+{
+	struct sockaddr *addr = p;
+
+	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+}
+EXPORT_SYMBOL(eth_commit_mac_addr_change);
+
+/**
  * eth_mac_addr - set new Ethernet hardware address
  * @dev: network device
  * @p: socket address
@@ -283,13 +313,12 @@ EXPORT_SYMBOL(eth_header_cache_update);
  */
 int eth_mac_addr(struct net_device *dev, void *p)
 {
-	struct sockaddr *addr = p;
+	int ret;
 
-	if (!(dev->priv_flags & IFF_LIVE_ADDR_CHANGE) && netif_running(dev))
-		return -EBUSY;
-	if (!is_valid_ether_addr(addr->sa_data))
-		return -EADDRNOTAVAIL;
-	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
+	ret = eth_prepare_mac_addr_change(dev, p);
+	if (ret < 0)
+		return ret;
+	eth_commit_mac_addr_change(dev, p);
 	return 0;
 }
 EXPORT_SYMBOL(eth_mac_addr);
-- 
1.7.1
