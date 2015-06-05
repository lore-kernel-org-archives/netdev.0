From: Hariprasad Shenai <hariprasad@chelsio.com>
Subject: [PATCH net-next 4/6] cxgb4: Set mac addr from vpd, when we can't contact firmware
Date: Fri,  5 Jun 2015 14:24:50 +0530
Message-ID: <1433494492-7638-5-git-send-email-hariprasad@chelsio.com>
References: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Cc: davem@davemloft.net, leedom@chelsio.com, nirranjan@chelsio.com,
	Hariprasad Shenai <hariprasad@chelsio.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26086 "EHLO
	stargate3.asicdesigners.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754169AbbFEDlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jun 2015 23:41:46 -0400
In-Reply-To: <1433494492-7638-1-git-send-email-hariprasad@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Grab the Adapter MAC Address out of the VPD and use it for the "debug"
network interface when either we can't contact the firmware

Signed-off-by: Hariprasad Shenai <hariprasad@chelsio.com>
---
 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      | 32 +++++++++++++----
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 21 +++++++++--
 drivers/net/ethernet/chelsio/cxgb4/t4_hw.c      | 47 +++++++++++++++++++------
 3 files changed, 81 insertions(+), 19 deletions(-)

diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
index 4ab5a2d..4d627a8 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4.h
@@ -46,17 +46,19 @@
 #include <linux/spinlock.h>
 #include <linux/timer.h>
 #include <linux/vmalloc.h>
+#include <linux/etherdevice.h>
 #include <asm/io.h>
 #include "cxgb4_uld.h"
 
 #define CH_WARN(adap, fmt, ...) dev_warn(adap->pdev_dev, fmt, ## __VA_ARGS__)
 
 enum {
-	MAX_NPORTS = 4,     /* max # of ports */
-	SERNUM_LEN = 24,    /* Serial # length */
-	EC_LEN     = 16,    /* E/C length */
-	ID_LEN     = 16,    /* ID length */
-	PN_LEN     = 16,    /* Part Number length */
+	MAX_NPORTS	= 4,     /* max # of ports */
+	SERNUM_LEN	= 24,    /* Serial # length */
+	EC_LEN		= 16,    /* E/C length */
+	ID_LEN		= 16,    /* ID length */
+	PN_LEN		= 16,    /* Part Number length */
+	MACADDR_LEN	= 12,    /* MAC Address length */
 };
 
 enum {
@@ -280,6 +282,7 @@ struct vpd_params {
 	u8 sn[SERNUM_LEN + 1];
 	u8 id[ID_LEN + 1];
 	u8 pn[PN_LEN + 1];
+	u8 na[MACADDR_LEN + 1];
 };
 
 struct pci_params {
@@ -946,6 +949,22 @@ static inline void t4_write_reg64(struct adapter *adap, u32 reg_addr, u64 val)
 }
 
 /**
+ * t4_set_hw_addr - store a port's MAC address in SW
+ * @adapter: the adapter
+ * @port_idx: the port index
+ * @hw_addr: the Ethernet address
+ *
+ * Store the Ethernet address of the given port in SW.  Called by the common
+ * code when it retrieves a port's Ethernet address from EEPROM.
+ */
+static inline void t4_set_hw_addr(struct adapter *adapter, int port_idx,
+				  u8 hw_addr[])
+{
+	ether_addr_copy(adapter->port[port_idx]->dev_addr, hw_addr);
+	ether_addr_copy(adapter->port[port_idx]->perm_addr, hw_addr);
+}
+
+/**
  * netdev2pinfo - return the port_info structure associated with a net_device
  * @dev: the netdev
  *
@@ -1251,7 +1270,8 @@ unsigned int t4_get_regs_len(struct adapter *adapter);
 void t4_get_regs(struct adapter *adap, void *buf, size_t buf_size);
 
 int t4_seeprom_wp(struct adapter *adapter, bool enable);
-int get_vpd_params(struct adapter *adapter, struct vpd_params *p);
+int t4_get_raw_vpd_params(struct adapter *adapter, struct vpd_params *p);
+int t4_get_vpd_params(struct adapter *adapter, struct vpd_params *p);
 int t4_read_flash(struct adapter *adapter, unsigned int addr,
 		  unsigned int nwords, u32 *data, int byte_oriented);
 int t4_load_fw(struct adapter *adapter, const u8 *fw_data, unsigned int size);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
index 4cb7eed..3897e28 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c
@@ -3712,7 +3712,7 @@ static int adap_init0(struct adapter *adap)
 	 * the firmware.  On the other hand, we need these fairly early on
 	 * so we do this right after getting ahold of the firmware.
 	 */
-	ret = get_vpd_params(adap, &adap->params.vpd);
+	ret = t4_get_vpd_params(adap, &adap->params.vpd);
 	if (ret < 0)
 		goto bye;
 
@@ -4735,10 +4735,25 @@ static int init_one(struct pci_dev *pdev, const struct pci_device_id *ent)
 		err = t4_port_init(adapter, func, func, 0);
 		if (err)
 			goto out_free_dev;
+	} else if (adapter->params.nports == 1) {
+		/* If we don't have a connection to the firmware -- possibly
+		 * because of an error -- grab the raw VPD parameters so we
+		 * can set the proper MAC Address on the debug network
+		 * interface that we've created.
+		 */
+		u8 hw_addr[ETH_ALEN];
+		u8 *na = adapter->params.vpd.na;
+
+		err = t4_get_raw_vpd_params(adapter, &adapter->params.vpd);
+		if (!err) {
+			for (i = 0; i < ETH_ALEN; i++)
+				hw_addr[i] = (hex2val(na[2 * i + 0]) * 16 +
+					      hex2val(na[2 * i + 1]));
+			t4_set_hw_addr(adapter, 0, hw_addr);
+		}
 	}
 
-	/*
-	 * Configure queues and allocate tables now, they can be needed as
+	/* Configure queues and allocate tables now, they can be needed as
 	 * soon as the first register_netdev completes.
 	 */
 	cfg_queues(adapter);
diff --git a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
index 6d5b0f4..da65e76 100644
--- a/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
+++ b/drivers/net/ethernet/chelsio/cxgb4/t4_hw.c
@@ -1729,17 +1729,16 @@ int t4_seeprom_wp(struct adapter *adapter, bool enable)
 }
 
 /**
- *	get_vpd_params - read VPD parameters from VPD EEPROM
+ *	t4_get_raw_vpd_params - read VPD parameters from VPD EEPROM
  *	@adapter: adapter to read
  *	@p: where to store the parameters
  *
  *	Reads card parameters stored in VPD EEPROM.
  */
-int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
+int t4_get_raw_vpd_params(struct adapter *adapter, struct vpd_params *p)
 {
-	u32 cclk_param, cclk_val;
-	int i, ret, addr;
-	int ec, sn, pn;
+	int i, ret = 0, addr;
+	int ec, sn, pn, na;
 	u8 *vpd, csum;
 	unsigned int vpdr_len, kw_offset, id_len;
 
@@ -1747,6 +1746,9 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	if (!vpd)
 		return -ENOMEM;
 
+	/* Card information normally starts at VPD_BASE but early cards had
+	 * it at 0.
+	 */
 	ret = pci_read_vpd(adapter->pdev, VPD_BASE, sizeof(u32), vpd);
 	if (ret < 0)
 		goto out;
@@ -1812,6 +1814,7 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	FIND_VPD_KW(ec, "EC");
 	FIND_VPD_KW(sn, "SN");
 	FIND_VPD_KW(pn, "PN");
+	FIND_VPD_KW(na, "NA");
 #undef FIND_VPD_KW
 
 	memcpy(p->id, vpd + PCI_VPD_LRDT_TAG_SIZE, id_len);
@@ -1824,18 +1827,42 @@ int get_vpd_params(struct adapter *adapter, struct vpd_params *p)
 	i = pci_vpd_info_field_size(vpd + pn - PCI_VPD_INFO_FLD_HDR_SIZE);
 	memcpy(p->pn, vpd + pn, min(i, PN_LEN));
 	strim(p->pn);
+	memcpy(p->na, vpd + na, min(i, MACADDR_LEN));
+	strim((char *)p->na);
 
-	/*
-	 * Ask firmware for the Core Clock since it knows how to translate the
+out:
+	vfree(vpd);
+	return ret;
+}
+
+/**
+ *	t4_get_vpd_params - read VPD parameters & retrieve Core Clock
+ *	@adapter: adapter to read
+ *	@p: where to store the parameters
+ *
+ *	Reads card parameters stored in VPD EEPROM and retrieves the Core
+ *	Clock.  This can only be called after a connection to the firmware
+ *	is established.
+ */
+int t4_get_vpd_params(struct adapter *adapter, struct vpd_params *p)
+{
+	u32 cclk_param, cclk_val;
+	int ret;
+
+	/* Grab the raw VPD parameters.
+	 */
+	ret = t4_get_raw_vpd_params(adapter, p);
+	if (ret)
+		return ret;
+
+	/* Ask firmware for the Core Clock since it knows how to translate the
 	 * Reference Clock ('V2') VPD field into a Core Clock value ...
 	 */
 	cclk_param = (FW_PARAMS_MNEM_V(FW_PARAMS_MNEM_DEV) |
 		      FW_PARAMS_PARAM_X_V(FW_PARAMS_PARAM_DEV_CCLK));
-	ret = t4_query_params(adapter, adapter->mbox, 0, 0,
+	ret = t4_query_params(adapter, adapter->mbox, adapter->pf, 0,
 			      1, &cclk_param, &cclk_val);
 
-out:
-	vfree(vpd);
 	if (ret)
 		return ret;
 	p->cclk = cclk_val;
-- 
2.3.4
