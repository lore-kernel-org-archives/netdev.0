From: Anish Bhatt <anish@chelsio.com>
Subject: [PATCH net-next 1/2] cxgb4: Update ipv6 address handling api
Date: Tue, 13 Jan 2015 18:28:35 -0800
Message-ID: <1421202516-13862-2-git-send-email-anish@chelsio.com>
References: <1421202516-13862-1-git-send-email-anish@chelsio.com>
Cc: davem@davemloft.net, hariprasad@chelsio.com, kxie@chelsio.com,
	deepak.s@chelsio.com, Anish Bhatt <anish@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:31565 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752134AbbANC2s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 21:28:48 -0500
In-Reply-To: <1421202516-13862-1-git-send-email-anish@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch improves on previously added support for ipv6 addresses. The code
is consolidated to a single file and adds an api for use by dependent upper
level drivers such as cxgb4i/iw_cxgb4 etc.

Signed-off-by: Anish Bhatt <anish@chelsio.com>
Signed-off-by: Deepak Singh <deepak.s@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/Makefile        |   2 +-
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c      | 314 +++++++++++++++++++++
 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h      |  41 +++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h         |   3 +
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |  19 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c    | 228 +++++----------
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h     |   3 -
 7 files changed, 447 insertions(+), 163 deletions(-)
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
 create mode 100644 drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h

diff --git a/drivers/net/ethernet/chelsio/cxgb4/Makefile b/drivers/net/ethernet/chelsio/cxgb4/Makefile
index b85280775997..ae50cd72358c 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/Makefile
+++ b/drivers/net/ethernet/chelsio/cxgb4/Makefile
@@ -4,6 +4,6 @@
 
 obj-$(CONFIG_CHELSIO_T4) += cxgb4.o
 
-cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o
+cxgb4-objs := cxgb4_main.o l2t.o t4_hw.o sge.o clip_tbl.o
 cxgb4-$(CONFIG_CHELSIO_T4_DCB) +=  cxgb4_dcb.o
 cxgb4-$(CONFIG_DEBUG_FS) += cxgb4_debugfs.o
diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
new file mode 100644
index 000000000000..dacecba70f76
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.c
@@ -0,0 +1,314 @@
+/*
+ *  This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *  Copyright (C) 2003-2014 Chelsio Communications.  All rights reserved.
+ *
+ *  Written by Deepak (deepak.s@chelsio.com)
+ *
+ *  This program is distributed in the hope that it will be useful, but WITHOUT
+ *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ *  FITNESS FOR A PARTICULAR PURPOSE.  See the LICENSE file included in this
+ *  release for licensing terms and conditions.
+ */
+
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/jhash.h>
+#include <linux/if_vlan.h>
+#include <net/addrconf.h>
+#include "cxgb4.h"
+#include "clip_tbl.h"
+
+static inline unsigned int ipv4_clip_hash(struct clip_tbl *c, const u32 *key)
+{
+	unsigned int clipt_size_half = c->clipt_size / 2;
+
+	return jhash_1word(*key, 0) % clipt_size_half;
+}
+
+static inline unsigned int ipv6_clip_hash(struct clip_tbl *d, const u32 *key)
+{
+	unsigned int clipt_size_half = d->clipt_size / 2;
+	u32 xor = key[0] ^ key[1] ^ key[2] ^ key[3];
+
+	return clipt_size_half +
+		(jhash_1word(xor, 0) % clipt_size_half);
+}
+
+static unsigned int clip_addr_hash(struct clip_tbl *ctbl, const u32 *addr,
+				   int addr_len)
+{
+	return addr_len == 4 ? ipv4_clip_hash(ctbl, addr) :
+				ipv6_clip_hash(ctbl, addr);
+}
+
+static int clip6_get_mbox(const struct net_device *dev,
+			  const struct in6_addr *lip)
+{
+	struct adapter *adap = netdev2adap(dev);
+	struct fw_clip_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
+			FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
+	c.alloc_to_len16 = htonl(FW_CLIP_CMD_ALLOC_F | FW_LEN16(c));
+	*(__be64 *)&c.ip_hi = *(__be64 *)(lip->s6_addr);
+	*(__be64 *)&c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
+	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
+}
+
+static int clip6_release_mbox(const struct net_device *dev,
+			      const struct in6_addr *lip)
+{
+	struct adapter *adap = netdev2adap(dev);
+	struct fw_clip_cmd c;
+
+	memset(&c, 0, sizeof(c));
+	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
+			FW_CMD_REQUEST_F | FW_CMD_READ_F);
+	c.alloc_to_len16 = htonl(FW_CLIP_CMD_FREE_F | FW_LEN16(c));
+	*(__be64 *)&c.ip_hi = *(__be64 *)(lip->s6_addr);
+	*(__be64 *)&c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
+	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
+}
+
+int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6)
+{
+	struct adapter *adap = netdev2adap(dev);
+	struct clip_tbl *ctbl = adap->clipt;
+	struct clip_entry *ce, *cte;
+	u32 *addr = (u32 *)lip;
+	int hash;
+	int addr_len;
+	int ret = 0;
+
+	if (v6)
+		addr_len = 16;
+	else
+		addr_len = 4;
+
+	hash = clip_addr_hash(ctbl, addr, addr_len);
+
+	read_lock_bh(&ctbl->lock);
+	list_for_each_entry(cte, &ctbl->hash_list[hash], list) {
+		if (addr_len == cte->addr_len &&
+		    memcmp(lip, cte->addr, cte->addr_len) == 0) {
+			ce = cte;
+			read_unlock_bh(&ctbl->lock);
+			goto found;
+		}
+	}
+	read_unlock_bh(&ctbl->lock);
+
+	write_lock_bh(&ctbl->lock);
+	if (!list_empty(&ctbl->ce_free_head)) {
+		ce = list_first_entry(&ctbl->ce_free_head,
+				      struct clip_entry, list);
+		list_del(&ce->list);
+		INIT_LIST_HEAD(&ce->list);
+		spin_lock_init(&ce->lock);
+		atomic_set(&ce->refcnt, 0);
+		atomic_dec(&ctbl->nfree);
+		ce->addr_len = addr_len;
+		memcpy(ce->addr, lip, addr_len);
+		list_add_tail(&ce->list, &ctbl->hash_list[hash]);
+		if (v6) {
+			ret = clip6_get_mbox(dev, (const struct in6_addr *)lip);
+			if (ret) {
+				write_unlock_bh(&ctbl->lock);
+				return ret;
+			}
+		}
+	} else {
+		write_unlock_bh(&ctbl->lock);
+		return -ENOMEM;
+	}
+	write_unlock_bh(&ctbl->lock);
+found:
+	atomic_inc(&ce->refcnt);
+
+	return 0;
+}
+EXPORT_SYMBOL(cxgb4_clip_get);
+
+void cxgb4_clip_release(const struct net_device *dev, const u32 *lip, u8 v6)
+{
+	struct adapter *adap = netdev2adap(dev);
+	struct clip_tbl *ctbl = adap->clipt;
+	struct clip_entry *ce, *cte;
+	u32 *addr = (u32 *)lip;
+	int hash;
+	int addr_len;
+
+	if (v6)
+		addr_len = 16;
+	else
+		addr_len = 4;
+
+	hash = clip_addr_hash(ctbl, addr, addr_len);
+
+	read_lock_bh(&ctbl->lock);
+	list_for_each_entry(cte, &ctbl->hash_list[hash], list) {
+		if (addr_len == cte->addr_len &&
+		    memcmp(lip, cte->addr, cte->addr_len) == 0) {
+			ce = cte;
+			read_unlock_bh(&ctbl->lock);
+			goto found;
+		}
+	}
+	read_unlock_bh(&ctbl->lock);
+
+	return;
+found:
+	write_lock_bh(&ctbl->lock);
+	spin_lock_bh(&ce->lock);
+	if (atomic_dec_and_test(&ce->refcnt)) {
+		list_del(&ce->list);
+		INIT_LIST_HEAD(&ce->list);
+		list_add_tail(&ce->list, &ctbl->ce_free_head);
+		atomic_inc(&ctbl->nfree);
+		if (v6)
+			clip6_release_mbox(dev, (const struct in6_addr *)lip);
+	}
+	spin_unlock_bh(&ce->lock);
+	write_unlock_bh(&ctbl->lock);
+}
+EXPORT_SYMBOL(cxgb4_clip_release);
+
+/* Retrieves IPv6 addresses from a root device (bond, vlan) associated with
+ * a physical device.
+ * The physical device reference is needed to send the actul CLIP command.
+ */
+static int cxgb4_update_dev_clip(struct net_device *root_dev,
+				 struct net_device *dev)
+{
+	struct inet6_dev *idev = NULL;
+	struct inet6_ifaddr *ifa;
+	int ret = 0;
+
+	idev = __in6_dev_get(root_dev);
+	if (!idev)
+		return ret;
+
+	read_lock_bh(&idev->lock);
+	list_for_each_entry(ifa, &idev->addr_list, if_list) {
+		ret = cxgb4_clip_get(dev, (const u32 *)ifa->addr.s6_addr, 1);
+		if (ret < 0)
+			break;
+	}
+	read_unlock_bh(&idev->lock);
+
+	return ret;
+}
+
+int cxgb4_update_root_dev_clip(struct net_device *dev)
+{
+	struct net_device *root_dev = NULL;
+	int i, ret = 0;
+
+	/* First populate the real net device's IPv6 addresses */
+	ret = cxgb4_update_dev_clip(dev, dev);
+	if (ret)
+		return ret;
+
+	/* Parse all bond and vlan devices layered on top of the physical dev */
+	root_dev = netdev_master_upper_dev_get_rcu(dev);
+	if (root_dev) {
+		ret = cxgb4_update_dev_clip(root_dev, dev);
+		if (ret)
+			return ret;
+	}
+
+	for (i = 0; i < VLAN_N_VID; i++) {
+		root_dev = __vlan_find_dev_deep_rcu(dev, htons(ETH_P_8021Q), i);
+		if (!root_dev)
+			continue;
+
+		ret = cxgb4_update_dev_clip(root_dev, dev);
+		if (ret)
+			break;
+	}
+
+	return ret;
+}
+EXPORT_SYMBOL(cxgb4_update_root_dev_clip);
+
+int clip_tbl_show(struct seq_file *seq, void *v)
+{
+	struct adapter *adapter = seq->private;
+	struct clip_tbl *ctbl = adapter->clipt;
+	struct clip_entry *ce;
+	char ip[60];
+	int i;
+
+	read_lock_bh(&ctbl->lock);
+
+	seq_puts(seq, "IP Address                  Users\n");
+	for (i = 0 ; i < ctbl->clipt_size;  ++i) {
+		list_for_each_entry(ce, &ctbl->hash_list[i], list) {
+			ip[0] = '\0';
+			if (ce->addr_len == 16)
+				sprintf(ip, "%pI6c", ce->addr);
+			else
+				sprintf(ip, "%pI4c", ce->addr);
+			seq_printf(seq, "%-25s   %u\n", ip,
+				   atomic_read(&ce->refcnt));
+		}
+	}
+	seq_printf(seq, "Free clip entries : %d\n", atomic_read(&ctbl->nfree));
+
+	read_unlock_bh(&ctbl->lock);
+
+	return 0;
+}
+
+struct clip_tbl *t4_init_clip_tbl(unsigned int clipt_start,
+				  unsigned int clipt_end)
+{
+	struct clip_entry *cl_list;
+	struct clip_tbl *ctbl;
+	unsigned int clipt_size;
+	int i;
+
+	if (clipt_start >= clipt_end)
+		return NULL;
+	clipt_size = clipt_end - clipt_start + 1;
+	if (clipt_size < CLIPT_MIN_HASH_BUCKETS)
+		return NULL;
+
+	ctbl = t4_alloc_mem(sizeof(*ctbl) +
+				clipt_size*sizeof(struct list_head));
+	if (!ctbl)
+		return NULL;
+
+	ctbl->clipt_start = clipt_start;
+	ctbl->clipt_size = clipt_size;
+	INIT_LIST_HEAD(&ctbl->ce_free_head);
+
+	atomic_set(&ctbl->nfree, clipt_size);
+	rwlock_init(&ctbl->lock);
+
+	for (i = 0; i < ctbl->clipt_size; ++i)
+		INIT_LIST_HEAD(&ctbl->hash_list[i]);
+
+	cl_list = t4_alloc_mem(clipt_size*sizeof(struct clip_entry));
+	ctbl->cl_list = (void *)cl_list;
+
+	for (i = 0; i < clipt_size; i++) {
+		INIT_LIST_HEAD(&cl_list[i].list);
+		list_add_tail(&cl_list[i].list, &ctbl->ce_free_head);
+	}
+
+	return ctbl;
+}
+
+void t4_cleanup_clip_tbl(struct adapter *adap)
+{
+	struct clip_tbl *ctbl = adap->clipt;
+
+	if (ctbl) {
+		if (ctbl->cl_list)
+			t4_free_mem(ctbl->cl_list);
+		t4_free_mem(ctbl);
+	}
+}
+EXPORT_SYMBOL(t4_cleanup_clip_tbl);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h
new file mode 100644
index 000000000000..2eaba0161cf8
--- /dev/null
+++ b/drivers/net/ethernet/chelsio/cxgb4/clip_tbl.h
@@ -0,0 +1,41 @@
+/*
+ *  This file is part of the Chelsio T4 Ethernet driver for Linux.
+ *  Copyright (C) 2003-2014 Chelsio Communications.  All rights reserved.
+ *
+ *  Written by Deepak (deepak.s@chelsio.com)
+ *
+ *  This program is distributed in the hope that it will be useful, but WITHOUT
+ *  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ *  FITNESS FOR A PARTICULAR PURPOSE.  See the LICENSE file included in this
+ *  release for licensing terms and conditions.
+ */
+
+struct clip_entry {
+	spinlock_t lock;	/* Hold while modifying clip reference */
+	atomic_t refcnt;
+	struct list_head list;
+	u32 addr[4];
+	int addr_len;
+};
+
+struct clip_tbl {
+	unsigned int clipt_start;
+	unsigned int clipt_size;
+	rwlock_t lock;
+	atomic_t nfree;
+	struct list_head ce_free_head;
+	void *cl_list;
+	struct list_head hash_list[0];
+};
+
+enum {
+	CLIPT_MIN_HASH_BUCKETS = 2,
+};
+
+struct clip_tbl *t4_init_clip_tbl(unsigned int clipt_start,
+				  unsigned int clipt_end);
+int cxgb4_clip_get(const struct net_device *dev, const u32 *lip, u8 v6);
+void cxgb4_clip_release(const struct net_device *dev, const u32 *lip, u8 v6);
+int clip_tbl_show(struct seq_file *seq, void *v);
+int cxgb4_update_root_dev_clip(struct net_device *dev);
+void t4_cleanup_clip_tbl(struct adapter *adap);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 7c785b5e7757..e468f920892f 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -668,6 +668,9 @@ struct adapter {
 	unsigned int l2t_start;
 	unsigned int l2t_end;
 	struct l2t_data *l2t;
+	unsigned int clipt_start;
+	unsigned int clipt_end;
+	struct clip_tbl *clipt;
 	void *uld_handle[CXGB4_ULD_MAX];
 	struct list_head list_node;
 	struct list_head rcu_node;
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
index e9f348942eb0..6dabfe5ba44e 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c
@@ -41,6 +41,7 @@
 #include "t4_regs.h"
 #include "t4fw_api.h"
 #include "cxgb4_debugfs.h"
+#include "clip_tbl.h"
 #include "l2t.h"
 
 /* generic seq_file support for showing a table of size rows x width. */
@@ -563,6 +564,21 @@ static const struct file_operations mps_tcam_debugfs_fops = {
 	.release = seq_release,
 };
 
+#if IS_ENABLED(CONFIG_IPV6)
+static int clip_tbl_open(struct inode *inode, struct file *file)
+{
+	return single_open(file, clip_tbl_show, PDE_DATA(inode));
+}
+
+static const struct file_operations clip_tbl_debugfs_fops = {
+	.owner   = THIS_MODULE,
+	.open    = clip_tbl_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = single_release
+};
+#endif
+
 static ssize_t mem_read(struct file *file, char __user *buf, size_t count,
 			loff_t *ppos)
 {
@@ -646,6 +662,9 @@ int t4_setup_debugfs(struct adapter *adap)
 		{ "devlog", &devlog_fops, S_IRUSR, 0 },
 		{ "l2t", &t4_l2t_fops, S_IRUSR, 0},
 		{ "mps_tcam", &mps_tcam_debugfs_fops, S_IRUSR, 0 },
+#if IS_ENABLED(CONFIG_IPV6)
+		{ "clip_tbl", &clip_tbl_debugfs_fops, S_IRUSR, 0 },
+#endif
 	};
 
 	add_debugfs_files(adap,
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 082a596a4264..1147e1e88314 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -62,6 +62,7 @@
 #include <net/netevent.h>
 #include <net/addrconf.h>
 #include <net/bonding.h>
+#include <net/addrconf.h>
 #include <asm/uaccess.h>
 
 #include "cxgb4.h"
@@ -71,6 +72,7 @@
 #include "t4fw_api.h"
 #include "cxgb4_dcb.h"
 #include "cxgb4_debugfs.h"
+#include "clip_tbl.h"
 #include "l2t.h"
 
 #ifdef DRV_VERSION
@@ -3236,40 +3238,6 @@ static int tid_init(struct tid_info *t)
 	return 0;
 }
 
-int cxgb4_clip_get(const struct net_device *dev,
-		   const struct in6_addr *lip)
-{
-	struct adapter *adap;
-	struct fw_clip_cmd c;
-
-	adap = netdev2adap(dev);
-	memset(&c, 0, sizeof(c));
-	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
-			FW_CMD_REQUEST_F | FW_CMD_WRITE_F);
-	c.alloc_to_len16 = htonl(FW_CLIP_CMD_ALLOC_F | FW_LEN16(c));
-	c.ip_hi = *(__be64 *)(lip->s6_addr);
-	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
-	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
-}
-EXPORT_SYMBOL(cxgb4_clip_get);
-
-int cxgb4_clip_release(const struct net_device *dev,
-		       const struct in6_addr *lip)
-{
-	struct adapter *adap;
-	struct fw_clip_cmd c;
-
-	adap = netdev2adap(dev);
-	memset(&c, 0, sizeof(c));
-	c.op_to_write = htonl(FW_CMD_OP_V(FW_CLIP_CMD) |
-			FW_CMD_REQUEST_F | FW_CMD_READ_F);
-	c.alloc_to_len16 = htonl(FW_CLIP_CMD_FREE_F | FW_LEN16(c));
-	c.ip_hi = *(__be64 *)(lip->s6_addr);
-	c.ip_lo = *(__be64 *)(lip->s6_addr + 8);
-	return t4_wr_mbox_meat(adap, adap->mbox, &c, sizeof(c), &c, false);
-}
-EXPORT_SYMBOL(cxgb4_clip_release);
-
 /**
  *	cxgb4_create_server - create an IP server
  *	@dev: the device
@@ -4122,148 +4090,61 @@ int cxgb4_unregister_uld(enum cxgb4_uld type)
 }
 EXPORT_SYMBOL(cxgb4_unregister_uld);
 
-/* Check if netdev on which event is occured belongs to us or not. Return
- * success (true) if it belongs otherwise failure (false).
- * Called with rcu_read_lock() held.
- */
 #if IS_ENABLED(CONFIG_IPV6)
-static bool cxgb4_netdev(const struct net_device *netdev)
+static int cxgb4_inet6addr_handler(struct notifier_block *this,
+				   unsigned long event, void *data)
 {
+	struct inet6_ifaddr *ifa = data;
+	struct net_device *event_dev = ifa->idev->dev;
+	const struct device *parent = NULL;
+#if IS_ENABLED(CONFIG_BONDING)
 	struct adapter *adap;
-	int i;
-
-	list_for_each_entry_rcu(adap, &adap_rcu_list, rcu_node)
-		for (i = 0; i < MAX_NPORTS; i++)
-			if (adap->port[i] == netdev)
-				return true;
-	return false;
-}
+#endif
+	if (event_dev->priv_flags & IFF_802_1Q_VLAN)
+		event_dev = vlan_dev_real_dev(event_dev);
+#if IS_ENABLED(CONFIG_BONDING)
+	if (event_dev->flags & IFF_MASTER) {
+		list_for_each_entry(adap, &adapter_list, list_node) {
+			switch (event) {
+			case NETDEV_UP:
+				cxgb4_clip_get(adap->port[0],
+					       (const u32 *)ifa, 1);
+				break;
+			case NETDEV_DOWN:
+				cxgb4_clip_release(adap->port[0],
+						   (const u32 *)ifa, 1);
+				break;
+			default:
+				break;
+			}
+		}
+		return NOTIFY_OK;
+	}
+#endif
 
-static int clip_add(struct net_device *event_dev, struct inet6_ifaddr *ifa,
-		    unsigned long event)
-{
-	int ret = NOTIFY_DONE;
+	if (event_dev)
+		parent = event_dev->dev.parent;
 
-	rcu_read_lock();
-	if (cxgb4_netdev(event_dev)) {
+	if (parent && parent->driver == &cxgb4_driver.driver) {
 		switch (event) {
 		case NETDEV_UP:
-			ret = cxgb4_clip_get(event_dev, &ifa->addr);
-			if (ret < 0) {
-				rcu_read_unlock();
-				return ret;
-			}
-			ret = NOTIFY_OK;
+			cxgb4_clip_get(event_dev, (const u32 *)ifa, 1);
 			break;
 		case NETDEV_DOWN:
-			cxgb4_clip_release(event_dev, &ifa->addr);
-			ret = NOTIFY_OK;
+			cxgb4_clip_release(event_dev, (const u32 *)ifa, 1);
 			break;
 		default:
 			break;
 		}
 	}
-	rcu_read_unlock();
-	return ret;
-}
-
-static int cxgb4_inet6addr_handler(struct notifier_block *this,
-		unsigned long event, void *data)
-{
-	struct inet6_ifaddr *ifa = data;
-	struct net_device *event_dev;
-	int ret = NOTIFY_DONE;
-	struct bonding *bond = netdev_priv(ifa->idev->dev);
-	struct list_head *iter;
-	struct slave *slave;
-	struct pci_dev *first_pdev = NULL;
-
-	if (ifa->idev->dev->priv_flags & IFF_802_1Q_VLAN) {
-		event_dev = vlan_dev_real_dev(ifa->idev->dev);
-		ret = clip_add(event_dev, ifa, event);
-	} else if (ifa->idev->dev->flags & IFF_MASTER) {
-		/* It is possible that two different adapters are bonded in one
-		 * bond. We need to find such different adapters and add clip
-		 * in all of them only once.
-		 */
-		bond_for_each_slave(bond, slave, iter) {
-			if (!first_pdev) {
-				ret = clip_add(slave->dev, ifa, event);
-				/* If clip_add is success then only initialize
-				 * first_pdev since it means it is our device
-				 */
-				if (ret == NOTIFY_OK)
-					first_pdev = to_pci_dev(
-							slave->dev->dev.parent);
-			} else if (first_pdev !=
-				   to_pci_dev(slave->dev->dev.parent))
-					ret = clip_add(slave->dev, ifa, event);
-		}
-	} else
-		ret = clip_add(ifa->idev->dev, ifa, event);
-
-	return ret;
+	return NOTIFY_OK;
 }
 
+static bool inet6addr_registered;
 static struct notifier_block cxgb4_inet6addr_notifier = {
 	.notifier_call = cxgb4_inet6addr_handler
 };
 
-/* Retrieves IPv6 addresses from a root device (bond, vlan) associated with
- * a physical device.
- * The physical device reference is needed to send the actul CLIP command.
- */
-static int update_dev_clip(struct net_device *root_dev, struct net_device *dev)
-{
-	struct inet6_dev *idev = NULL;
-	struct inet6_ifaddr *ifa;
-	int ret = 0;
-
-	idev = __in6_dev_get(root_dev);
-	if (!idev)
-		return ret;
-
-	read_lock_bh(&idev->lock);
-	list_for_each_entry(ifa, &idev->addr_list, if_list) {
-		ret = cxgb4_clip_get(dev, &ifa->addr);
-		if (ret < 0)
-			break;
-	}
-	read_unlock_bh(&idev->lock);
-
-	return ret;
-}
-
-static int update_root_dev_clip(struct net_device *dev)
-{
-	struct net_device *root_dev = NULL;
-	int i, ret = 0;
-
-	/* First populate the real net device's IPv6 addresses */
-	ret = update_dev_clip(dev, dev);
-	if (ret)
-		return ret;
-
-	/* Parse all bond and vlan devices layered on top of the physical dev */
-	root_dev = netdev_master_upper_dev_get_rcu(dev);
-	if (root_dev) {
-		ret = update_dev_clip(root_dev, dev);
-		if (ret)
-			return ret;
-	}
-
-	for (i = 0; i < VLAN_N_VID; i++) {
-		root_dev = __vlan_find_dev_deep_rcu(dev, htons(ETH_P_8021Q), i);
-		if (!root_dev)
-			continue;
-
-		ret = update_dev_clip(root_dev, dev);
-		if (ret)
-			break;
-	}
-	return ret;
-}
-
 static void update_clip(const struct adapter *adap)
 {
 	int i;
@@ -4277,7 +4158,7 @@ static void update_clip(const struct adapter *adap)
 		ret = 0;
 
 		if (dev)
-			ret = update_root_dev_clip(dev);
+			ret = cxgb4_update_root_dev_clip(dev);
 
 		if (ret < 0)
 			break;
@@ -5391,6 +5272,14 @@ static int adap_init0(struct adapter *adap)
 	adap->tids.nftids = val[4] - val[3] + 1;
 	adap->sge.ingr_start = val[5];
 
+	params[0] = FW_PARAM_PFVF(CLIP_START);
+	params[1] = FW_PARAM_PFVF(CLIP_END);
+	ret = t4_query_params(adap, adap->mbox, adap->fn, 0, 2, params, val);
+	if (ret < 0)
+		goto bye;
+	adap->clipt_start = val[0];
+	adap->clipt_end = val[1];
+
 	/* query params related to active filter region */
 	params[0] = FW_PARAM_PFVF(ACTIVE_FILTER_START);
 	params[1] = FW_PARAM_PFVF(ACTIVE_FILTER_END);
@@ -6211,6 +6100,18 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		adapter->params.offload = 0;
 	}
 
+#if IS_ENABLED(CONFIG_IPV6)
+	adapter->clipt = t4_init_clip_tbl(adapter->clipt_start,
+					  adapter->clipt_end);
+	if (!adapter->clipt) {
+		/* We tolerate a lack of clip_table, giving up
+		 * some functionality
+		 */
+		dev_warn(&pdev->dev,
+			 "could not allocate Clip table, continuing\n");
+		adapter->params.offload = 0;
+	}
+#endif
 	if (is_offload(adapter) && tid_init(&adapter->tids) < 0) {
 		dev_warn(&pdev->dev, "could not allocate TID table, "
 			 "continuing\n");
@@ -6336,6 +6237,9 @@ static void remove_one(struct pci_dev *pdev)
 			cxgb_down(adapter);
 
 		free_some_resources(adapter);
+#if IS_ENABLED(CONFIG_IPV6)
+		t4_cleanup_clip_tbl(adapter);
+#endif
 		iounmap(adapter->regs);
 		if (!is_t4(adapter->params.chip))
 			iounmap(adapter->bar2);
@@ -6374,7 +6278,10 @@ static int __init cxgb4_init_module(void)
 		debugfs_remove(cxgb4_debugfs_root);
 
 #if IS_ENABLED(CONFIG_IPV6)
-	register_inet6addr_notifier(&cxgb4_inet6addr_notifier);
+	if (!inet6addr_registered) {
+		register_inet6addr_notifier(&cxgb4_inet6addr_notifier);
+		inet6addr_registered = true;
+	}
 #endif
 
 	return ret;
@@ -6383,7 +6290,10 @@ static int __init cxgb4_init_module(void)
 static void __exit cxgb4_cleanup_module(void)
 {
 #if IS_ENABLED(CONFIG_IPV6)
-	unregister_inet6addr_notifier(&cxgb4_inet6addr_notifier);
+	if (inet6addr_registered && list_empty(&adapter_list)) {
+		unregister_inet6addr_notifier(&cxgb4_inet6addr_notifier);
+		inet6addr_registered = false;
+	}
 #endif
 	pci_unregister_driver(&cxgb4_driver);
 	debugfs_remove(cxgb4_debugfs_root);  /* NULL ok */
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
index 152b4c4c7809..78ab4d406ce2 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_uld.h
@@ -173,9 +173,6 @@ int cxgb4_create_server_filter(const struct net_device *dev, unsigned int stid,
 			       unsigned char port, unsigned char mask);
 int cxgb4_remove_server_filter(const struct net_device *dev, unsigned int stid,
 			       unsigned int queue, bool ipv6);
-int cxgb4_clip_get(const struct net_device *dev, const struct in6_addr *lip);
-int cxgb4_clip_release(const struct net_device *dev,
-		       const struct in6_addr *lip);
 
 static inline void set_wr_txq(struct sk_buff *skb, int prio, int queue)
 {
-- 
2.2.1
