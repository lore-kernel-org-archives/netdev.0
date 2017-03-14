From: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Subject: [PATCH v4] {net,IB}/{rxe,usnic}: Utilize generic mac to eui32 function
Date: Tue, 14 Mar 2017 16:01:57 +0200
Message-ID: <1489500117-7937-1-git-send-email-yuval.shaia@oracle.com>
Cc: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
To: benve-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, dgoodell-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This logic seems to be duplicated in (at least) three separate files.
Move it to one place so code can be re-use.

Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
---
v0 -> v1:
	* Add missing #include
	* Rename to genaddrconf_ifid_eui48
v1 -> v2:
	* Reset eui[0] to default if dev_id is used
v2 -> v3:
	* Add helper function to avoid re-setting eui[0] to default if
	  dev_id is used
v3 -> v4:
	* Remove RXE wrappers
	* Remove addrconf_addr_eui48_xor and do the eui[0] ^= 2 in the
	  basic implementation
---
 drivers/infiniband/hw/usnic/usnic_common_util.h | 11 +++-------
 drivers/infiniband/sw/rxe/rxe.c                 |  4 +++-
 drivers/infiniband/sw/rxe/rxe_loc.h             |  2 --
 drivers/infiniband/sw/rxe/rxe_net.c             | 28 -------------------------
 drivers/infiniband/sw/rxe/rxe_verbs.c           |  4 +++-
 include/net/addrconf.h                          | 22 +++++++++++++++----
 6 files changed, 27 insertions(+), 44 deletions(-)

diff --git a/drivers/infiniband/hw/usnic/usnic_common_util.h b/drivers/infiniband/hw/usnic/usnic_common_util.h
index b54986d..d91b035 100644
--- a/drivers/infiniband/hw/usnic/usnic_common_util.h
+++ b/drivers/infiniband/hw/usnic/usnic_common_util.h
@@ -34,6 +34,8 @@
 #ifndef USNIC_CMN_UTIL_H
 #define USNIC_CMN_UTIL_H
 
+#include <net/addrconf.h>
+
 static inline void
 usnic_mac_to_gid(const char *const mac, char *raw_gid)
 {
@@ -57,14 +59,7 @@ usnic_mac_ip_to_gid(const char *const mac, const __be32 inaddr, char *raw_gid)
 	raw_gid[1] = 0x80;
 	memset(&raw_gid[2], 0, 2);
 	memcpy(&raw_gid[4], &inaddr, 4);
-	raw_gid[8] = mac[0]^2;
-	raw_gid[9] = mac[1];
-	raw_gid[10] = mac[2];
-	raw_gid[11] = 0xff;
-	raw_gid[12] = 0xfe;
-	raw_gid[13] = mac[3];
-	raw_gid[14] = mac[4];
-	raw_gid[15] = mac[5];
+	addrconf_addr_eui48(&raw_gid[8], mac);
 }
 
 static inline void
diff --git a/drivers/infiniband/sw/rxe/rxe.c b/drivers/infiniband/sw/rxe/rxe.c
index b12dd9b..e93f81f 100644
--- a/drivers/infiniband/sw/rxe/rxe.c
+++ b/drivers/infiniband/sw/rxe/rxe.c
@@ -31,6 +31,7 @@
  * SOFTWARE.
  */
 
+#include <net/addrconf.h>
 #include "rxe.h"
 #include "rxe_loc.h"
 
@@ -178,7 +179,8 @@ static int rxe_init_ports(struct rxe_dev *rxe)
 		return -ENOMEM;
 
 	port->pkey_tbl[0] = 0xffff;
-	port->port_guid = rxe_port_guid(rxe);
+	addrconf_addr_eui48((unsigned char *)&port->port_guid,
+			    rxe->ndev->dev_addr);
 
 	spin_lock_init(&port->port_lock);
 
diff --git a/drivers/infiniband/sw/rxe/rxe_loc.h b/drivers/infiniband/sw/rxe/rxe_loc.h
index 272337e..13ed8b5 100644
--- a/drivers/infiniband/sw/rxe/rxe_loc.h
+++ b/drivers/infiniband/sw/rxe/rxe_loc.h
@@ -145,7 +145,6 @@ int advance_dma_data(struct rxe_dma_info *dma, unsigned int length);
 int rxe_loopback(struct sk_buff *skb);
 int rxe_send(struct rxe_dev *rxe, struct rxe_pkt_info *pkt,
 	     struct sk_buff *skb);
-__be64 rxe_port_guid(struct rxe_dev *rxe);
 struct sk_buff *rxe_init_packet(struct rxe_dev *rxe, struct rxe_av *av,
 				int paylen, struct rxe_pkt_info *pkt);
 int rxe_prepare(struct rxe_dev *rxe, struct rxe_pkt_info *pkt,
@@ -153,7 +152,6 @@ int rxe_prepare(struct rxe_dev *rxe, struct rxe_pkt_info *pkt,
 enum rdma_link_layer rxe_link_layer(struct rxe_dev *rxe, unsigned int port_num);
 const char *rxe_parent_name(struct rxe_dev *rxe, unsigned int port_num);
 struct device *rxe_dma_device(struct rxe_dev *rxe);
-__be64 rxe_node_guid(struct rxe_dev *rxe);
 int rxe_mcast_add(struct rxe_dev *rxe, union ib_gid *mgid);
 int rxe_mcast_delete(struct rxe_dev *rxe, union ib_gid *mgid);
 
diff --git a/drivers/infiniband/sw/rxe/rxe_net.c b/drivers/infiniband/sw/rxe/rxe_net.c
index d8610960..43b1a0c 100644
--- a/drivers/infiniband/sw/rxe/rxe_net.c
+++ b/drivers/infiniband/sw/rxe/rxe_net.c
@@ -84,34 +84,6 @@ struct rxe_dev *get_rxe_by_name(const char *name)
 
 struct rxe_recv_sockets recv_sockets;
 
-static __be64 rxe_mac_to_eui64(struct net_device *ndev)
-{
-	unsigned char *mac_addr = ndev->dev_addr;
-	__be64 eui64;
-	unsigned char *dst = (unsigned char *)&eui64;
-
-	dst[0] = mac_addr[0] ^ 2;
-	dst[1] = mac_addr[1];
-	dst[2] = mac_addr[2];
-	dst[3] = 0xff;
-	dst[4] = 0xfe;
-	dst[5] = mac_addr[3];
-	dst[6] = mac_addr[4];
-	dst[7] = mac_addr[5];
-
-	return eui64;
-}
-
-__be64 rxe_node_guid(struct rxe_dev *rxe)
-{
-	return rxe_mac_to_eui64(rxe->ndev);
-}
-
-__be64 rxe_port_guid(struct rxe_dev *rxe)
-{
-	return rxe_mac_to_eui64(rxe->ndev);
-}
-
 struct device *rxe_dma_device(struct rxe_dev *rxe)
 {
 	struct net_device *ndev;
diff --git a/drivers/infiniband/sw/rxe/rxe_verbs.c b/drivers/infiniband/sw/rxe/rxe_verbs.c
index d2e2eff..09f1bec 100644
--- a/drivers/infiniband/sw/rxe/rxe_verbs.c
+++ b/drivers/infiniband/sw/rxe/rxe_verbs.c
@@ -31,6 +31,7 @@
  * SOFTWARE.
  */
 
+#include <net/addrconf.h>
 #include "rxe.h"
 #include "rxe_loc.h"
 #include "rxe_queue.h"
@@ -1236,7 +1237,8 @@ int rxe_register_device(struct rxe_dev *rxe)
 	dev->num_comp_vectors = RXE_NUM_COMP_VECTORS;
 	dev->dma_device = rxe_dma_device(rxe);
 	dev->local_dma_lkey = 0;
-	dev->node_guid = rxe_node_guid(rxe);
+	addrconf_addr_eui48((unsigned char *)&dev->node_guid,
+			    rxe->ndev->dev_addr);
 	dev->dma_ops = &rxe_dma_mapping_ops;
 
 	dev->uverbs_abi_ver = RXE_UVERBS_ABI_VERSION;
diff --git a/include/net/addrconf.h b/include/net/addrconf.h
index 17c6fd8..cb51bea 100644
--- a/include/net/addrconf.h
+++ b/include/net/addrconf.h
@@ -103,12 +103,24 @@ int addrconf_prefix_rcv_add_addr(struct net *net, struct net_device *dev,
 				 u32 addr_flags, bool sllao, bool tokenized,
 				 __u32 valid_lft, u32 prefered_lft);
 
+static inline void addrconf_addr_eui48_base(u8 *eui, const char *const addr)
+{
+	memcpy(eui, addr, 3);
+	eui[3] = 0xFF;
+	eui[4] = 0xFE;
+	memcpy(eui + 5, addr + 3, 3);
+}
+
+static inline void addrconf_addr_eui48(u8 *eui, const char *const addr)
+{
+	addrconf_addr_eui48_base(eui, addr);
+	eui[0] ^= 2;
+}
+
 static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
 {
 	if (dev->addr_len != ETH_ALEN)
 		return -1;
-	memcpy(eui, dev->dev_addr, 3);
-	memcpy(eui + 5, dev->dev_addr + 3, 3);
 
 	/*
 	 * The zSeries OSA network cards can be shared among various
@@ -123,14 +135,16 @@ static inline int addrconf_ifid_eui48(u8 *eui, struct net_device *dev)
 	 * case.  Hence the resulting interface identifier has local
 	 * scope according to RFC2373.
 	 */
+
+	addrconf_addr_eui48_base(eui, dev->dev_addr);
+
 	if (dev->dev_id) {
 		eui[3] = (dev->dev_id >> 8) & 0xFF;
 		eui[4] = dev->dev_id & 0xFF;
 	} else {
-		eui[3] = 0xFF;
-		eui[4] = 0xFE;
 		eui[0] ^= 2;
 	}
+
 	return 0;
 }
 
-- 
2.7.4

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
