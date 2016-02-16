From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 2/2] cxgb4vf: Use __dev_uc_sync/__dev_mc_sync to sync MAC address
Date: Tue, 16 Feb 2016 10:07:10 +0530
Message-ID: <1455597430-17173-3-git-send-email-hariprasad@chelsio.com>
References: <1455597430-17173-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nirranjan@chelsio.com, leedom@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:55089 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752410AbcBPEev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 23:34:51 -0500
In-Reply-To: <1455597430-17173-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4vf/adapter.h     |   8 ++
 .../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c    | 116 +++++++++++++--------
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h |  20 ++++
 drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c     |  88 +++++++++++++---
 4 files changed, 171 insertions(+), 61 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
index 6049f70e110c..4a707c32d76f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/adapter.h
@@ -348,6 +348,11 @@ struct sge {
 #define for_each_ethrxq(sge, iter) \
 	for (iter = 0; iter < (sge)->ethqsets; iter++)
 
+struct hash_mac_addr {
+	struct list_head list;
+	u8 addr[ETH_ALEN];
+};
+
 /*
  * Per-"adapter" (Virtual Function) information.
  */
@@ -381,6 +386,9 @@ struct adapter {
 
 	/* various locks */
 	spinlock_t stats_lock;
+
+	/* list of MAC addresses in MPS Hash */
+	struct list_head mac_hlist;
 };
 
 enum { /* adapter flags */
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
index 0cfa5d72cafd..8337514ababb 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c
@@ -741,6 +741,9 @@ static int adapter_up(struct adapter *adapter)
 	 */
 	enable_rx(adapter);
 	t4vf_sge_start(adapter);
+
+	/* Initialize hash mac addr list*/
+	INIT_LIST_HEAD(&adapter->mac_hlist);
 	return 0;
 }
 
@@ -905,51 +908,74 @@ static inline unsigned int collect_netdev_mc_list_addrs(const struct net_device
 	return naddr;
 }
 
-/*
- * Configure the exact and hash address filters to handle a port's multicast
- * and secondary unicast MAC addresses.
- */
-static int set_addr_filters(const struct net_device *dev, bool sleep)
+static inline int cxgb4vf_set_addr_hash(struct port_info *pi)
 {
-	u64 mhash = 0;
-	u64 uhash = 0;
-	bool free = true;
-	unsigned int offset, naddr;
-	const u8 *addr[7];
-	int ret;
-	const struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
+	u64 vec = 0;
+	bool ucast = false;
+	struct hash_mac_addr *entry;
 
-	/* first do the secondary unicast addresses */
-	for (offset = 0; ; offset += naddr) {
-		naddr = collect_netdev_uc_list_addrs(dev, addr, offset,
-						     ARRAY_SIZE(addr));
-		if (naddr == 0)
-			break;
+	/* Calculate the hash vector for the updated list and program it */
+	list_for_each_entry(entry, &adapter->mac_hlist, list) {
+		ucast |= is_unicast_ether_addr(entry->addr);
+		vec |= (1ULL << hash_mac_addr(entry->addr));
+	}
+	return t4vf_set_addr_hash(adapter, pi->viid, ucast, vec, false);
+}
 
-		ret = t4vf_alloc_mac_filt(pi->adapter, pi->viid, free,
-					  naddr, addr, NULL, &uhash, sleep);
-		if (ret < 0)
-			return ret;
+static int cxgb4vf_mac_sync(struct net_device *netdev, const u8 *mac_addr)
+{
+	struct port_info *pi = netdev_priv(netdev);
+	struct adapter *adapter = pi->adapter;
+	int ret;
+	u64 mhash = 0;
+	u64 uhash = 0;
+	bool free = false;
+	bool ucast = is_unicast_ether_addr(mac_addr);
+	const u8 *maclist[1] = {mac_addr};
+	struct hash_mac_addr *new_entry;
 
-		free = false;
+	ret = t4vf_alloc_mac_filt(adapter, pi->viid, free, 1, maclist,
+				  NULL, ucast ? &uhash : &mhash, false);
+	if (ret < 0)
+		goto out;
+	/* if hash != 0, then add the addr to hash addr list
+	 * so on the end we will calculate the hash for the
+	 * list and program it
+	 */
+	if (uhash || mhash) {
+		new_entry = kzalloc(sizeof(*new_entry), GFP_ATOMIC);
+		if (!new_entry)
+			return -ENOMEM;
+		ether_addr_copy(new_entry->addr, mac_addr);
+		list_add_tail(&new_entry->list, &adapter->mac_hlist);
+		ret = cxgb4vf_set_addr_hash(pi);
 	}
+out:
+	return ret < 0 ? ret : 0;
+}
 
-	/* next set up the multicast addresses */
-	for (offset = 0; ; offset += naddr) {
-		naddr = collect_netdev_mc_list_addrs(dev, addr, offset,
-						     ARRAY_SIZE(addr));
-		if (naddr == 0)
-			break;
+static int cxgb4vf_mac_unsync(struct net_device *netdev, const u8 *mac_addr)
+{
+	struct port_info *pi = netdev_priv(netdev);
+	struct adapter *adapter = pi->adapter;
+	int ret;
+	const u8 *maclist[1] = {mac_addr};
+	struct hash_mac_addr *entry, *tmp;
 
-		ret = t4vf_alloc_mac_filt(pi->adapter, pi->viid, free,
-					  naddr, addr, NULL, &mhash, sleep);
-		if (ret < 0)
-			return ret;
-		free = false;
+	/* If the MAC address to be removed is in the hash addr
+	 * list, delete it from the list and update hash vector
+	 */
+	list_for_each_entry_safe(entry, tmp, &adapter->mac_hlist, list) {
+		if (ether_addr_equal(entry->addr, mac_addr)) {
+			list_del(&entry->list);
+			kfree(entry);
+			return cxgb4vf_set_addr_hash(pi);
+		}
 	}
 
-	return t4vf_set_addr_hash(pi->adapter, pi->viid, uhash != 0,
-				  uhash | mhash, sleep);
+	ret = t4vf_free_mac_filt(adapter, pi->viid, 1, maclist, false);
+	return ret < 0 ? -EINVAL : 0;
 }
 
 /*
@@ -958,16 +984,18 @@ static int set_addr_filters(const struct net_device *dev, bool sleep)
  */
 static int set_rxmode(struct net_device *dev, int mtu, bool sleep_ok)
 {
-	int ret;
 	struct port_info *pi = netdev_priv(dev);
 
-	ret = set_addr_filters(dev, sleep_ok);
-	if (ret == 0)
-		ret = t4vf_set_rxmode(pi->adapter, pi->viid, -1,
-				      (dev->flags & IFF_PROMISC) != 0,
-				      (dev->flags & IFF_ALLMULTI) != 0,
-				      1, -1, sleep_ok);
-	return ret;
+	if (!(dev->flags & IFF_PROMISC)) {
+		__dev_uc_sync(dev, cxgb4vf_mac_sync, cxgb4vf_mac_unsync);
+		if (!(dev->flags & IFF_ALLMULTI))
+			__dev_mc_sync(dev, cxgb4vf_mac_sync,
+				      cxgb4vf_mac_unsync);
+	}
+	return t4vf_set_rxmode(pi->adapter, pi->viid, -1,
+			       (dev->flags & IFF_PROMISC) != 0,
+			       (dev->flags & IFF_ALLMULTI) != 0,
+			       1, -1, sleep_ok);
 }
 
 /*
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
index 88b8981b4751..6ce302fe1a61 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_common.h
@@ -285,6 +285,24 @@ static inline int is_t4(enum chip_type chip)
 	return CHELSIO_CHIP_VERSION(chip) == CHELSIO_T4;
 }
 
+/**
+ *	hash_mac_addr - return the hash value of a MAC address
+ *	@addr: the 48-bit Ethernet MAC address
+ *
+ *	Hashes a MAC address according to the hash function used by hardware
+ *	inexact (hash) address matching.
+ */
+static inline int hash_mac_addr(const u8 *addr)
+{
+	u32 a = ((u32)addr[0] << 16) | ((u32)addr[1] << 8) | addr[2];
+	u32 b = ((u32)addr[3] << 16) | ((u32)addr[4] << 8) | addr[5];
+
+	a ^= b;
+	a ^= (a >> 12);
+	a ^= (a >> 6);
+	return a & 0x3f;
+}
+
 int t4vf_wait_dev_ready(struct adapter *);
 int t4vf_port_init(struct adapter *, int);
 
@@ -320,6 +338,8 @@ int t4vf_set_rxmode(struct adapter *, unsigned int, int, int, int, int, int,
 		    bool);
 int t4vf_alloc_mac_filt(struct adapter *, unsigned int, bool, unsigned int,
 			const u8 **, u16 *, u64 *, bool);
+int t4vf_free_mac_filt(struct adapter *, unsigned int, unsigned int naddr,
+		       const u8 **, bool);
 int t4vf_change_mac(struct adapter *, unsigned int, int, const u8 *, bool);
 int t4vf_set_addr_hash(struct adapter *, unsigned int, bool, u64, bool);
 int t4vf_get_port_stats(struct adapter *, int, struct t4vf_port_stats *);
diff --git a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
index b6fa74aafe47..54220117dcba 100644
--- a/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4vf/t4vf_hw.c
@@ -236,23 +236,6 @@ int t4vf_wr_mbox_core(struct adapter *adapter, const void *cmd, int size,
 	return -ETIMEDOUT;
 }
 
-/**
- *	hash_mac_addr - return the hash value of a MAC address
- *	@addr: the 48-bit Ethernet MAC address
- *
- *	Hashes a MAC address according to the hash function used by hardware
- *	inexact (hash) address matching.
- */
-static int hash_mac_addr(const u8 *addr)
-{
-	u32 a = ((u32)addr[0] << 16) | ((u32)addr[1] << 8) | addr[2];
-	u32 b = ((u32)addr[3] << 16) | ((u32)addr[4] << 8) | addr[5];
-	a ^= b;
-	a ^= (a >> 12);
-	a ^= (a >> 6);
-	return a & 0x3f;
-}
-
 #define ADVERT_MASK (FW_PORT_CAP_SPEED_100M | FW_PORT_CAP_SPEED_1G |\
 		     FW_PORT_CAP_SPEED_10G | FW_PORT_CAP_SPEED_40G | \
 		     FW_PORT_CAP_SPEED_100G | FW_PORT_CAP_ANEG)
@@ -1266,6 +1249,77 @@ int t4vf_alloc_mac_filt(struct adapter *adapter, unsigned int viid, bool free,
 }
 
 /**
+ *	t4vf_free_mac_filt - frees exact-match filters of given MAC addresses
+ *	@adapter: the adapter
+ *	@viid: the VI id
+ *	@naddr: the number of MAC addresses to allocate filters for (up to 7)
+ *	@addr: the MAC address(es)
+ *	@sleep_ok: call is allowed to sleep
+ *
+ *	Frees the exact-match filter for each of the supplied addresses
+ *
+ *	Returns a negative error number or the number of filters freed.
+ */
+int t4vf_free_mac_filt(struct adapter *adapter, unsigned int viid,
+		       unsigned int naddr, const u8 **addr, bool sleep_ok)
+{
+	int offset, ret = 0;
+	struct fw_vi_mac_cmd cmd;
+	unsigned int nfilters = 0;
+	unsigned int max_naddr = adapter->params.arch.mps_tcam_size;
+	unsigned int rem = naddr;
+
+	if (naddr > max_naddr)
+		return -EINVAL;
+
+	for (offset = 0; offset < (int)naddr ; /**/) {
+		unsigned int fw_naddr = (rem < ARRAY_SIZE(cmd.u.exact) ?
+					 rem : ARRAY_SIZE(cmd.u.exact));
+		size_t len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
+						     u.exact[fw_naddr]), 16);
+		struct fw_vi_mac_exact *p;
+		int i;
+
+		memset(&cmd, 0, sizeof(cmd));
+		cmd.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_CMD_EXEC_V(0) |
+				     FW_VI_MAC_CMD_VIID_V(viid));
+		cmd.freemacs_to_len16 =
+				cpu_to_be32(FW_VI_MAC_CMD_FREEMACS_V(0) |
+					    FW_CMD_LEN16_V(len16));
+
+		for (i = 0, p = cmd.u.exact; i < (int)fw_naddr; i++, p++) {
+			p->valid_to_idx = cpu_to_be16(
+				FW_VI_MAC_CMD_VALID_F |
+				FW_VI_MAC_CMD_IDX_V(FW_VI_MAC_MAC_BASED_FREE));
+			memcpy(p->macaddr, addr[offset+i], sizeof(p->macaddr));
+		}
+
+		ret = t4vf_wr_mbox_core(adapter, &cmd, sizeof(cmd), &cmd,
+					sleep_ok);
+		if (ret)
+			break;
+
+		for (i = 0, p = cmd.u.exact; i < fw_naddr; i++, p++) {
+			u16 index = FW_VI_MAC_CMD_IDX_G(
+						be16_to_cpu(p->valid_to_idx));
+
+			if (index < max_naddr)
+				nfilters++;
+		}
+
+		offset += fw_naddr;
+		rem -= fw_naddr;
+	}
+
+	if (ret == 0)
+		ret = nfilters;
+	return ret;
+}
+
+/**
  *	t4vf_change_mac - modifies the exact-match filter for a MAC address
  *	@adapter: the adapter
  *	@viid: the Virtual Interface ID
-- 
2.3.4
