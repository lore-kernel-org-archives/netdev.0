From: akong@redhat.com
Subject: [PATCH v4 2/3] net: split eth_mac_addr for better error handling
Date: Sun, 20 Jan 2013 10:43:08 +0800
Message-ID: <1358649789-2338-3-git-send-email-akong@redhat.com>
References: <1358649789-2338-1-git-send-email-akong@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, qemu-devel@nongnu.org,
	virtualization@lists.linux-foundation.org, davem@davemloft.net
To: mst@redhat.com
Return-path: <virtualization-bounces@lists.linux-foundation.org>
In-Reply-To: <1358649789-2338-1-git-send-email-akong@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

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
 include/linux/etherdevice.h |  2 ++
 net/ethernet/eth.c          | 43 ++++++++++++++++++++++++++++++++++++-------
 2 files changed, 38 insertions(+), 7 deletions(-)

diff --git a/include/linux/etherdevice.h b/include/linux/etherdevice.h
index 243eea1..5cc6e0e 100644
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
index 4efad53..cce73eb 100644
--- a/net/ethernet/eth.c
+++ b/net/ethernet/eth.c
@@ -272,16 +272,11 @@ void eth_header_cache_update(struct hh_cache *hh,
 EXPORT_SYMBOL(eth_header_cache_update);
 
 /**
- * eth_mac_addr - set new Ethernet hardware address
+ * eth_prepare_mac_addr_change - prepare for mac change
  * @dev: network device
  * @p: socket address
- *
- * Change hardware address of device.
- *
- * This doesn't change hardware matching, so needs to be overridden
- * for most real devices.
  */
-int eth_mac_addr(struct net_device *dev, void *p)
+int eth_prepare_mac_addr_change(struct net_device *dev, void *p)
 {
 	struct sockaddr *addr = p;
 
@@ -289,9 +284,43 @@ int eth_mac_addr(struct net_device *dev, void *p)
 		return -EBUSY;
 	if (!is_valid_ether_addr(addr->sa_data))
 		return -EADDRNOTAVAIL;
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
 	memcpy(dev->dev_addr, addr->sa_data, ETH_ALEN);
 	/* if device marked as NET_ADDR_RANDOM, reset it */
 	dev->addr_assign_type &= ~NET_ADDR_RANDOM;
+}
+EXPORT_SYMBOL(eth_commit_mac_addr_change);
+
+/**
+ * eth_mac_addr - set new Ethernet hardware address
+ * @dev: network device
+ * @p: socket address
+ *
+ * Change hardware address of device.
+ *
+ * This doesn't change hardware matching, so needs to be overridden
+ * for most real devices.
+ */
+int eth_mac_addr(struct net_device *dev, void *p)
+{
+	int ret;
+
+	ret = eth_prepare_mac_addr_change(dev, p);
+	if (ret < 0)
+		return ret;
+	eth_commit_mac_addr_change(dev, p);
 	return 0;
 }
 EXPORT_SYMBOL(eth_mac_addr);
-- 
1.7.11.7
