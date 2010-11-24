From: Casey Leedom <leedom@chelsio.com>
Subject: [PATCH net-26] cxgb4vf: fix setting unicast/multicast addresses ...
Date: Wed, 24 Nov 2010 14:23:57 -0800
Message-ID: <1290637437-2415-1-git-send-email-leedom@chelsio.com>
Cc: davem@davemloft.net, Casey Leedom <leedom@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:11581 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353Ab0KXWYB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Nov 2010 17:24:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We were truncating the number of unicast and multicast MAC addresses
supported.  Additionally, we were incorrectly computing the MAC Address
hash (a "1 << N" where we needed a "1ULL << N").

Signed-off-by: Casey Leedom <leedom@chelsio.com>
---
 drivers/net/cxgb4vf/cxgb4vf_main.c |   73 +++++++++++++++++----------
 drivers/net/cxgb4vf/t4vf_hw.c      |   96 ++++++++++++++++++++++-------------
 2 files changed, 105 insertions(+), 64 deletions(-)

diff --git a/drivers/net/cxgb4vf/cxgb4vf_main.c b/drivers/net/cxgb4vf/cxgb4vf_main.c
index 9246d2f..f54af48 100644
--- a/drivers/net/cxgb4vf/cxgb4vf_main.c
+++ b/drivers/net/cxgb4vf/cxgb4vf_main.c
@@ -814,40 +814,48 @@ static struct net_device_stats *cxgb4vf_get_stats(struct net_device *dev)
 }
 
 /*
- * Collect up to maxaddrs worth of a netdevice's unicast addresses into an
- * array of addrss pointers and return the number collected.
+ * Collect up to maxaddrs worth of a netdevice's unicast addresses, starting
+ * at a specified offset within the list, into an array of addrss pointers and
+ * return the number collected.
  */
-static inline int collect_netdev_uc_list_addrs(const struct net_device *dev,
-					       const u8 **addr,
-					       unsigned int maxaddrs)
+static inline unsigned int collect_netdev_uc_list_addrs(const struct net_device *dev,
+							const u8 **addr,
+							unsigned int offset,
+							unsigned int maxaddrs)
 {
+	unsigned int index = 0;
 	unsigned int naddr = 0;
 	const struct netdev_hw_addr *ha;
 
-	for_each_dev_addr(dev, ha) {
-		addr[naddr++] = ha->addr;
-		if (naddr >= maxaddrs)
-			break;
-	}
+	for_each_dev_addr(dev, ha)
+		if (index++ >= offset) {
+			addr[naddr++] = ha->addr;
+			if (naddr >= maxaddrs)
+				break;
+		}
 	return naddr;
 }
 
 /*
- * Collect up to maxaddrs worth of a netdevice's multicast addresses into an
- * array of addrss pointers and return the number collected.
+ * Collect up to maxaddrs worth of a netdevice's multicast addresses, starting
+ * at a specified offset within the list, into an array of addrss pointers and
+ * return the number collected.
  */
-static inline int collect_netdev_mc_list_addrs(const struct net_device *dev,
-					       const u8 **addr,
-					       unsigned int maxaddrs)
+static inline unsigned int collect_netdev_mc_list_addrs(const struct net_device *dev,
+							const u8 **addr,
+							unsigned int offset,
+							unsigned int maxaddrs)
 {
+	unsigned int index = 0;
 	unsigned int naddr = 0;
 	const struct netdev_hw_addr *ha;
 
-	netdev_for_each_mc_addr(ha, dev) {
-		addr[naddr++] = ha->addr;
-		if (naddr >= maxaddrs)
-			break;
-	}
+	netdev_for_each_mc_addr(ha, dev)
+		if (index++ >= offset) {
+			addr[naddr++] = ha->addr;
+			if (naddr >= maxaddrs)
+				break;
+		}
 	return naddr;
 }
 
@@ -860,16 +868,20 @@ static int set_addr_filters(const struct net_device *dev, bool sleep)
 	u64 mhash = 0;
 	u64 uhash = 0;
 	bool free = true;
-	u16 filt_idx[7];
+	unsigned int offset, naddr;
 	const u8 *addr[7];
-	int ret, naddr = 0;
+	int ret;
 	const struct port_info *pi = netdev_priv(dev);
 
 	/* first do the secondary unicast addresses */
-	naddr = collect_netdev_uc_list_addrs(dev, addr, ARRAY_SIZE(addr));
-	if (naddr > 0) {
+	for (offset = 0; ; offset += naddr) {
+		naddr = collect_netdev_uc_list_addrs(dev, addr, offset,
+						     ARRAY_SIZE(addr));
+		if (naddr == 0)
+			break;
+
 		ret = t4vf_alloc_mac_filt(pi->adapter, pi->viid, free,
-					  naddr, addr, filt_idx, &uhash, sleep);
+					  naddr, addr, NULL, &uhash, sleep);
 		if (ret < 0)
 			return ret;
 
@@ -877,12 +889,17 @@ static int set_addr_filters(const struct net_device *dev, bool sleep)
 	}
 
 	/* next set up the multicast addresses */
-	naddr = collect_netdev_mc_list_addrs(dev, addr, ARRAY_SIZE(addr));
-	if (naddr > 0) {
+	for (offset = 0; ; offset += naddr) {
+		naddr = collect_netdev_mc_list_addrs(dev, addr, offset,
+						     ARRAY_SIZE(addr));
+		if (naddr == 0)
+			break;
+
 		ret = t4vf_alloc_mac_filt(pi->adapter, pi->viid, free,
-					  naddr, addr, filt_idx, &mhash, sleep);
+					  naddr, addr, NULL, &mhash, sleep);
 		if (ret < 0)
 			return ret;
+		free = false;
 	}
 
 	return t4vf_set_addr_hash(pi->adapter, pi->viid, uhash != 0,
diff --git a/drivers/net/cxgb4vf/t4vf_hw.c b/drivers/net/cxgb4vf/t4vf_hw.c
index f7d7f97..35fc803 100644
--- a/drivers/net/cxgb4vf/t4vf_hw.c
+++ b/drivers/net/cxgb4vf/t4vf_hw.c
@@ -1014,48 +1014,72 @@ int t4vf_alloc_mac_filt(struct adapter *adapter, unsigned int viid, bool free,
 			unsigned int naddr, const u8 **addr, u16 *idx,
 			u64 *hash, bool sleep_ok)
 {
-	int i, ret;
+	int offset, ret = 0;
+	unsigned nfilters = 0;
+	unsigned int rem = naddr;
 	struct fw_vi_mac_cmd cmd, rpl;
-	struct fw_vi_mac_exact *p;
-	size_t len16;
 
-	if (naddr > ARRAY_SIZE(cmd.u.exact))
+	if (naddr > FW_CLS_TCAM_NUM_ENTRIES)
 		return -EINVAL;
-	len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
-				      u.exact[naddr]), 16);
 
-	memset(&cmd, 0, sizeof(cmd));
-	cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_MAC_CMD) |
-				     FW_CMD_REQUEST |
-				     FW_CMD_WRITE |
-				     (free ? FW_CMD_EXEC : 0) |
-				     FW_VI_MAC_CMD_VIID(viid));
-	cmd.freemacs_to_len16 = cpu_to_be32(FW_VI_MAC_CMD_FREEMACS(free) |
-					    FW_CMD_LEN16(len16));
+	for (offset = 0; offset < naddr; /**/) {
+		unsigned int fw_naddr = (rem < ARRAY_SIZE(cmd.u.exact)
+					 ? rem
+					 : ARRAY_SIZE(cmd.u.exact));
+		size_t len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
+						     u.exact[fw_naddr]), 16);
+		struct fw_vi_mac_exact *p;
+		int i;
 
-	for (i = 0, p = cmd.u.exact; i < naddr; i++, p++) {
-		p->valid_to_idx =
-			cpu_to_be16(FW_VI_MAC_CMD_VALID |
-				    FW_VI_MAC_CMD_IDX(FW_VI_MAC_ADD_MAC));
-		memcpy(p->macaddr, addr[i], sizeof(p->macaddr));
-	}
+		memset(&cmd, 0, sizeof(cmd));
+		cmd.op_to_viid = cpu_to_be32(FW_CMD_OP(FW_VI_MAC_CMD) |
+					     FW_CMD_REQUEST |
+					     FW_CMD_WRITE |
+					     (free ? FW_CMD_EXEC : 0) |
+					     FW_VI_MAC_CMD_VIID(viid));
+		cmd.freemacs_to_len16 =
+			cpu_to_be32(FW_VI_MAC_CMD_FREEMACS(free) |
+				    FW_CMD_LEN16(len16));
+
+		for (i = 0, p = cmd.u.exact; i < fw_naddr; i++, p++) {
+			p->valid_to_idx = cpu_to_be16(
+				FW_VI_MAC_CMD_VALID |
+				FW_VI_MAC_CMD_IDX(FW_VI_MAC_ADD_MAC));
+			memcpy(p->macaddr, addr[offset+i], sizeof(p->macaddr));
+		}
+
+
+		ret = t4vf_wr_mbox_core(adapter, &cmd, sizeof(cmd), &rpl,
+					sleep_ok);
+		if (ret && ret != -ENOMEM)
+			break;
 
-	ret = t4vf_wr_mbox_core(adapter, &cmd, sizeof(cmd), &rpl, sleep_ok);
-	if (ret)
-		return ret;
-
-	for (i = 0, p = rpl.u.exact; i < naddr; i++, p++) {
-		u16 index = FW_VI_MAC_CMD_IDX_GET(be16_to_cpu(p->valid_to_idx));
-
-		if (idx)
-			idx[i] = (index >= FW_CLS_TCAM_NUM_ENTRIES
-				  ? 0xffff
-				  : index);
-		if (index < FW_CLS_TCAM_NUM_ENTRIES)
-			ret++;
-		else if (hash)
-			*hash |= (1 << hash_mac_addr(addr[i]));
+		for (i = 0, p = rpl.u.exact; i < fw_naddr; i++, p++) {
+			u16 index = FW_VI_MAC_CMD_IDX_GET(
+				be16_to_cpu(p->valid_to_idx));
+
+			if (idx)
+				idx[offset+i] =
+					(index >= FW_CLS_TCAM_NUM_ENTRIES
+					 ? 0xffff
+					 : index);
+			if (index < FW_CLS_TCAM_NUM_ENTRIES)
+				nfilters++;
+			else if (hash)
+				*hash |= (1ULL << hash_mac_addr(addr[offset+i]));
+		}
+
+		free = false;
+		offset += fw_naddr;
+		rem -= fw_naddr;
 	}
+
+	/*
+	 * If there were no errors or we merely ran out of room in our MAC
+	 * address arena, return the number of filters actually written.
+	 */
+	if (ret == 0 || ret == -ENOMEM)
+		ret = nfilters;
 	return ret;
 }
 
-- 
1.7.0.4

