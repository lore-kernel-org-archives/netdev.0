From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: Use __dev_uc_sync/__dev_mc_sync to sync MAC address
Date: Tue, 16 Feb 2016 10:07:09 +0530
Message-ID: <1455597430-17173-2-git-send-email-hariprasad@chelsio.com>
References: <1455597430-17173-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, nirranjan@chelsio.com, leedom@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([12.32.117.8]:33534 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751967AbcBPEet (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Feb 2016 23:34:49 -0500
In-Reply-To: <1455597430-17173-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  27 +++++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 138 ++++++++++++++----------
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      |  92 +++++++++++++---
 3 files changed, 184 insertions(+), 73 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index ec6e849676c1..1dac6c6111bf 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -702,6 +702,11 @@ struct doorbell_stats {
 	u32 db_full;
 };
 
+struct hash_mac_addr {
+	struct list_head list;
+	u8 addr[ETH_ALEN];
+};
+
 struct adapter {
 	void __iomem *regs;
 	void __iomem *bar2;
@@ -740,6 +745,7 @@ struct adapter {
 	void *uld_handle[CXGB4_ULD_MAX];
 	struct list_head list_node;
 	struct list_head rcu_node;
+	struct list_head mac_hlist; /* list of MAC addresses in MPS Hash */
 
 	struct tid_info tids;
 	void **tid_release_head;
@@ -1207,6 +1213,24 @@ static inline int t4_wr_mbox_ns(struct adapter *adap, int mbox, const void *cmd,
 	return t4_wr_mbox_meat(adap, mbox, cmd, size, rpl, false);
 }
 
+/**
+ *	hash_mac_addr - return the hash value of a MAC address
+ *	@addr: the 48-bit Ethernet MAC address
+ *
+ *	Hashes a MAC address according to the hash function used by HW inexact
+ *	(hash) address matching.
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
 void t4_write_indirect(struct adapter *adap, unsigned int addr_reg,
 		       unsigned int data_reg, const u32 *vals,
 		       unsigned int nregs, unsigned int start_idx);
@@ -1389,6 +1413,9 @@ int t4_set_rxmode(struct adapter *adap, unsigned int mbox, unsigned int viid,
 int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 		      unsigned int viid, bool free, unsigned int naddr,
 		      const u8 **addr, u16 *idx, u64 *hash, bool sleep_ok);
+int t4_free_mac_filt(struct adapter *adap, unsigned int mbox,
+		     unsigned int viid, unsigned int naddr,
+		     const u8 **addr, bool sleep_ok);
 int t4_change_mac(struct adapter *adap, unsigned int mbox, unsigned int viid,
 		  int idx, const u8 *addr, bool persist, bool add_smt);
 int t4_set_addr_hash(struct adapter *adap, unsigned int mbox, unsigned int viid,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index b8a5fb0c32d4..adad73f7c8cd 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -338,84 +338,108 @@ void t4_os_portmod_changed(const struct adapter *adap, int port_id)
 		netdev_info(dev, "%s module inserted\n", mod_str[pi->mod_type]);
 }
 
+int dbfifo_int_thresh = 10; /* 10 == 640 entry threshold */
+module_param(dbfifo_int_thresh, int, 0644);
+MODULE_PARM_DESC(dbfifo_int_thresh, "doorbell fifo interrupt threshold");
+
 /*
- * Configure the exact and hash address filters to handle a port's multicast
- * and secondary unicast MAC addresses.
+ * usecs to sleep while draining the dbfifo
  */
-static int set_addr_filters(const struct net_device *dev, bool sleep)
+static int dbfifo_drain_delay = 1000;
+module_param(dbfifo_drain_delay, int, 0644);
+MODULE_PARM_DESC(dbfifo_drain_delay,
+		 "usecs to sleep while draining the dbfifo");
+
+static inline int cxgb4_set_addr_hash(struct port_info *pi)
 {
+	struct adapter *adap = pi->adapter;
+	u64 vec = 0;
+	bool ucast = false;
+	struct hash_mac_addr *entry;
+
+	/* Calculate the hash vector for the updated list and program it */
+	list_for_each_entry(entry, &adap->mac_hlist, list) {
+		ucast |= is_unicast_ether_addr(entry->addr);
+		vec |= (1ULL << hash_mac_addr(entry->addr));
+	}
+	return t4_set_addr_hash(adap, adap->mbox, pi->viid, ucast,
+				vec, false);
+}
+
+static int cxgb4_mac_sync(struct net_device *netdev, const u8 *mac_addr)
+{
+	struct port_info *pi = netdev_priv(netdev);
+	struct adapter *adap = pi->adapter;
+	int ret;
 	u64 mhash = 0;
 	u64 uhash = 0;
-	bool free = true;
-	u16 filt_idx[7];
-	const u8 *addr[7];
-	int ret, naddr = 0;
-	const struct netdev_hw_addr *ha;
-	int uc_cnt = netdev_uc_count(dev);
-	int mc_cnt = netdev_mc_count(dev);
-	const struct port_info *pi = netdev_priv(dev);
-	unsigned int mb = pi->adapter->pf;
+	bool free = false;
+	bool ucast = is_unicast_ether_addr(mac_addr);
+	const u8 *maclist[1] = {mac_addr};
+	struct hash_mac_addr *new_entry;
 
-	/* first do the secondary unicast addresses */
-	netdev_for_each_uc_addr(ha, dev) {
-		addr[naddr++] = ha->addr;
-		if (--uc_cnt == 0 || naddr >= ARRAY_SIZE(addr)) {
-			ret = t4_alloc_mac_filt(pi->adapter, mb, pi->viid, free,
-					naddr, addr, filt_idx, &uhash, sleep);
-			if (ret < 0)
-				return ret;
-
-			free = false;
-			naddr = 0;
-		}
+	ret = t4_alloc_mac_filt(adap, adap->mbox, pi->viid, free, 1, maclist,
+				NULL, ucast ? &uhash : &mhash, false);
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
+		list_add_tail(&new_entry->list, &adap->mac_hlist);
+		ret = cxgb4_set_addr_hash(pi);
 	}
+out:
+	return ret < 0 ? ret : 0;
+}
 
-	/* next set up the multicast addresses */
-	netdev_for_each_mc_addr(ha, dev) {
-		addr[naddr++] = ha->addr;
-		if (--mc_cnt == 0 || naddr >= ARRAY_SIZE(addr)) {
-			ret = t4_alloc_mac_filt(pi->adapter, mb, pi->viid, free,
-					naddr, addr, filt_idx, &mhash, sleep);
-			if (ret < 0)
-				return ret;
+static int cxgb4_mac_unsync(struct net_device *netdev, const u8 *mac_addr)
+{
+	struct port_info *pi = netdev_priv(netdev);
+	struct adapter *adap = pi->adapter;
+	int ret;
+	const u8 *maclist[1] = {mac_addr};
+	struct hash_mac_addr *entry, *tmp;
 
-			free = false;
-			naddr = 0;
+	/* If the MAC address to be removed is in the hash addr
+	 * list, delete it from the list and update hash vector
+	 */
+	list_for_each_entry_safe(entry, tmp, &adap->mac_hlist, list) {
+		if (ether_addr_equal(entry->addr, mac_addr)) {
+			list_del(&entry->list);
+			kfree(entry);
+			return cxgb4_set_addr_hash(pi);
 		}
 	}
 
-	return t4_set_addr_hash(pi->adapter, mb, pi->viid, uhash != 0,
-				uhash | mhash, sleep);
+	ret = t4_free_mac_filt(adap, adap->mbox, pi->viid, 1, maclist, false);
+	return ret < 0 ? -EINVAL : 0;
 }
 
-int dbfifo_int_thresh = 10; /* 10 == 640 entry threshold */
-module_param(dbfifo_int_thresh, int, 0644);
-MODULE_PARM_DESC(dbfifo_int_thresh, "doorbell fifo interrupt threshold");
-
-/*
- * usecs to sleep while draining the dbfifo
- */
-static int dbfifo_drain_delay = 1000;
-module_param(dbfifo_drain_delay, int, 0644);
-MODULE_PARM_DESC(dbfifo_drain_delay,
-		 "usecs to sleep while draining the dbfifo");
-
 /*
  * Set Rx properties of a port, such as promiscruity, address filters, and MTU.
  * If @mtu is -1 it is left unchanged.
  */
 static int set_rxmode(struct net_device *dev, int mtu, bool sleep_ok)
 {
-	int ret;
 	struct port_info *pi = netdev_priv(dev);
+	struct adapter *adapter = pi->adapter;
 
-	ret = set_addr_filters(dev, sleep_ok);
-	if (ret == 0)
-		ret = t4_set_rxmode(pi->adapter, pi->adapter->pf, pi->viid, mtu,
-				    (dev->flags & IFF_PROMISC) ? 1 : 0,
-				    (dev->flags & IFF_ALLMULTI) ? 1 : 0, 1, -1,
-				    sleep_ok);
-	return ret;
+	if (!(dev->flags & IFF_PROMISC)) {
+		__dev_uc_sync(dev, cxgb4_mac_sync, cxgb4_mac_unsync);
+		if (!(dev->flags & IFF_ALLMULTI))
+			__dev_mc_sync(dev, cxgb4_mac_sync, cxgb4_mac_unsync);
+	}
+
+	return t4_set_rxmode(adapter, adapter->mbox, pi->viid, mtu,
+			     (dev->flags & IFF_PROMISC) ? 1 : 0,
+			     (dev->flags & IFF_ALLMULTI) ? 1 : 0, 1, -1,
+			     sleep_ok);
 }
 
 /**
@@ -2677,6 +2701,8 @@ static int cxgb_up(struct adapter *adap)
 #if IS_ENABLED(CONFIG_IPV6)
 	update_clip(adap);
 #endif
+	/* Initialize hash mac addr list*/
+	INIT_LIST_HEAD(&adap->mac_hlist);
  out:
 	return err;
  irq_err:
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 636b4691f252..cc1736bece0f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -4433,23 +4433,6 @@ void t4_intr_disable(struct adapter *adapter)
 }
 
 /**
- *	hash_mac_addr - return the hash value of a MAC address
- *	@addr: the 48-bit Ethernet MAC address
- *
- *	Hashes a MAC address according to the hash function used by HW inexact
- *	(hash) address matching.
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
-/**
  *	t4_config_rss_range - configure a portion of the RSS mapping table
  *	@adapter: the adapter
  *	@mbox: mbox to use for the FW command
@@ -6738,6 +6721,81 @@ int t4_alloc_mac_filt(struct adapter *adap, unsigned int mbox,
 }
 
 /**
+ *	t4_free_mac_filt - frees exact-match filters of given MAC addresses
+ *	@adap: the adapter
+ *	@mbox: mailbox to use for the FW command
+ *	@viid: the VI id
+ *	@naddr: the number of MAC addresses to allocate filters for (up to 7)
+ *	@addr: the MAC address(es)
+ *	@sleep_ok: call is allowed to sleep
+ *
+ *	Frees the exact-match filter for each of the supplied addresses
+ *
+ *	Returns a negative error number or the number of filters freed.
+ */
+int t4_free_mac_filt(struct adapter *adap, unsigned int mbox,
+		     unsigned int viid, unsigned int naddr,
+		     const u8 **addr, bool sleep_ok)
+{
+	int offset, ret = 0;
+	struct fw_vi_mac_cmd c;
+	unsigned int nfilters = 0;
+	unsigned int max_naddr = is_t4(adap->params.chip) ?
+				       NUM_MPS_CLS_SRAM_L_INSTANCES :
+				       NUM_MPS_T5_CLS_SRAM_L_INSTANCES;
+	unsigned int rem = naddr;
+
+	if (naddr > max_naddr)
+		return -EINVAL;
+
+	for (offset = 0; offset < (int)naddr ; /**/) {
+		unsigned int fw_naddr = (rem < ARRAY_SIZE(c.u.exact)
+					 ? rem
+					 : ARRAY_SIZE(c.u.exact));
+		size_t len16 = DIV_ROUND_UP(offsetof(struct fw_vi_mac_cmd,
+						     u.exact[fw_naddr]), 16);
+		struct fw_vi_mac_exact *p;
+		int i;
+
+		memset(&c, 0, sizeof(c));
+		c.op_to_viid = cpu_to_be32(FW_CMD_OP_V(FW_VI_MAC_CMD) |
+				     FW_CMD_REQUEST_F |
+				     FW_CMD_WRITE_F |
+				     FW_CMD_EXEC_V(0) |
+				     FW_VI_MAC_CMD_VIID_V(viid));
+		c.freemacs_to_len16 =
+				cpu_to_be32(FW_VI_MAC_CMD_FREEMACS_V(0) |
+					    FW_CMD_LEN16_V(len16));
+
+		for (i = 0, p = c.u.exact; i < (int)fw_naddr; i++, p++) {
+			p->valid_to_idx = cpu_to_be16(
+				FW_VI_MAC_CMD_VALID_F |
+				FW_VI_MAC_CMD_IDX_V(FW_VI_MAC_MAC_BASED_FREE));
+			memcpy(p->macaddr, addr[offset+i], sizeof(p->macaddr));
+		}
+
+		ret = t4_wr_mbox_meat(adap, mbox, &c, sizeof(c), &c, sleep_ok);
+		if (ret)
+			break;
+
+		for (i = 0, p = c.u.exact; i < fw_naddr; i++, p++) {
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
  *	t4_change_mac - modifies the exact-match filter for a MAC address
  *	@adap: the adapter
  *	@mbox: mailbox to use for the FW command
-- 
2.3.4
