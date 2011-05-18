From: Rasesh Mody <rmody@brocade.com>
Subject: [PATCH 2/2] bna: Add Generic Netlink Interface
Date: Tue, 17 May 2011 21:57:01 -0700
Message-ID: <1305694621-28023-3-git-send-email-rmody@brocade.com>
References: <1305694621-28023-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <adapter_linux_open_src_team@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:36688 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751907Ab1ERE6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 00:58:05 -0400
In-Reply-To: <1305694621-28023-1-git-send-email-rmody@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds the generic netlink communication interface to BNA driver. The
in-kernel generic netlink infrastructure can be used to collect hardware
specific control information and control attributes. The driver makes use of
the "doit" handler provided by the generic netlink layer to accomplish this.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/Makefile    |    2 +-
 drivers/net/bna/bfa_defs.h  |   18 +++
 drivers/net/bna/bfa_ioc.c   |    8 +-
 drivers/net/bna/bfa_ioc.h   |    1 +
 drivers/net/bna/bnad.c      |   11 ++-
 drivers/net/bna/bnad.h      |    1 +
 drivers/net/bna/bnad_genl.c |  345 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/bna/bnad_genl.h |   87 +++++++++++
 8 files changed, 466 insertions(+), 7 deletions(-)
 create mode 100644 drivers/net/bna/bnad_genl.c
 create mode 100644 drivers/net/bna/bnad_genl.h

diff --git a/drivers/net/bna/Makefile b/drivers/net/bna/Makefile
index 4bb0d5d..f3339dc 100644
--- a/drivers/net/bna/Makefile
+++ b/drivers/net/bna/Makefile
@@ -5,7 +5,7 @@
 
 obj-$(CONFIG_BNA) += bna.o
 
-bna-objs := bnad.o bnad_debugfs.o bnad_ethtool.o
+bna-objs := bnad.o bnad_debugfs.o bnad_ethtool.o bnad_genl.o
 bna-objs += bna_ctrl.o bna_txrx.o
 bna-objs += bfa_ioc.o bfa_ioc_ct.o bfa_cee.o cna_fwimg.o
 
diff --git a/drivers/net/bna/bfa_defs.h b/drivers/net/bna/bfa_defs.h
index 2ea0dfe..2dd0898 100644
--- a/drivers/net/bna/bfa_defs.h
+++ b/drivers/net/bna/bfa_defs.h
@@ -26,6 +26,24 @@
 #define BFA_STRING_32	32
 #define BFA_VERSION_LEN 64
 
+/*
+ * Check if the card having old wwn/mac handling
+ */
+#define bfa_mfg_is_old_wwn_mac_model(type) (( \
+	(type) == BFA_MFG_TYPE_CNA10P2 || \
+	(type) == BFA_MFG_TYPE_CNA10P1 || \
+	(type) == BFA_MFG_TYPE_WANCHESE))
+
+#define bfa_mfg_increment_wwn_mac(m, i)                         \
+do {                                                            \
+	u32 t = ((u32)(m)[0] << 16) | ((u32)(m)[1] << 8) | \
+		(u32)(m)[2];  \
+	t += (i);      \
+	(m)[0] = (t >> 16) & 0xFF;                              \
+	(m)[1] = (t >> 8) & 0xFF;                               \
+	(m)[2] = t & 0xFF;                                      \
+} while (0)
+
 /**
  * ---------------------- adapter definitions ------------
  */
diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index 15f9dec..eeb7250 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -82,8 +82,6 @@ static void bfa_ioc_pf_fwmismatch(struct bfa_ioc *ioc);
 static void bfa_ioc_boot(struct bfa_ioc *ioc, u32 boot_type,
 			 u32 boot_param);
 static u32 bfa_ioc_smem_pgnum(struct bfa_ioc *ioc, u32 fmaddr);
-static void bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc,
-						char *serial_num);
 static void bfa_ioc_get_adapter_fw_ver(struct bfa_ioc *ioc,
 						char *fw_ver);
 static void bfa_ioc_get_pci_chip_rev(struct bfa_ioc *ioc,
@@ -2045,7 +2043,7 @@ bfa_ioc_get_adapter_attr(struct bfa_ioc *ioc,
 
 	ioc_attr = ioc->attr;
 
-	bfa_ioc_get_adapter_serial_num(ioc, ad_attr->serial_num);
+	bfa_nw_ioc_get_adapter_serial_num(ioc, ad_attr->serial_num);
 	bfa_ioc_get_adapter_fw_ver(ioc, ad_attr->fw_ver);
 	bfa_ioc_get_adapter_optrom_ver(ioc, ad_attr->optrom_ver);
 	bfa_ioc_get_adapter_manufacturer(ioc, ad_attr->manufacturer);
@@ -2096,8 +2094,8 @@ bfa_ioc_get_type(struct bfa_ioc *ioc)
 	}
 }
 
-static void
-bfa_ioc_get_adapter_serial_num(struct bfa_ioc *ioc, char *serial_num)
+void
+bfa_nw_ioc_get_adapter_serial_num(struct bfa_ioc *ioc, char *serial_num)
 {
 	memset(serial_num, 0, BFA_ADAPTER_SERIAL_NUM_LEN);
 	memcpy(serial_num,
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index 49739cd..1f71865 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -280,6 +280,7 @@ mac_t bfa_nw_ioc_get_mac(struct bfa_ioc *ioc);
 void bfa_nw_ioc_debug_memclaim(struct bfa_ioc *ioc, void *dbg_fwsave);
 int bfa_nw_ioc_debug_fwtrc(struct bfa_ioc *ioc, void *trcdata, int *trclen);
 int bfa_nw_ioc_debug_fwsave(struct bfa_ioc *ioc, void *trcdata, int *trclen);
+void bfa_nw_ioc_get_adapter_serial_num(struct bfa_ioc *ioc, char *serial_num);
 
 /*
  * Timeout APIs
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index a997276..09aa132 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -25,6 +25,7 @@
 #include <linux/ip.h>
 
 #include "bnad.h"
+#include "bnad_genl.h"
 #include "bna.h"
 #include "cna.h"
 
@@ -721,7 +722,7 @@ bnad_disable_mbox_irq(struct bnad *bnad)
 	BNAD_UPDATE_CTR(bnad, mbox_intr_disabled);
 }
 
-static void
+void
 bnad_set_netdev_perm_addr(struct bnad *bnad)
 {
 	struct net_device *netdev = bnad->netdev;
@@ -3296,6 +3297,10 @@ bnad_module_init(void)
 		return err;
 	}
 
+	/* Register with generic netlink */
+	if (bnad_genl_init())
+		pr_err("bna: Generic Netlink Register failed\n");
+
 	return 0;
 }
 
@@ -3305,6 +3310,10 @@ bnad_module_exit(void)
 	pci_unregister_driver(&bnad_pci_driver);
 	mutex_destroy(&bnad_list_mutex);
 
+	/* Unegister with generic netlink */
+	if (bnad_genl_uninit())
+		pr_err("bna: Generic Netlink Unregister failed\n");
+
 	if (bfi_fw)
 		release_firmware(bfi_fw);
 }
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index 2c1f283..d3cb27b 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -302,6 +302,7 @@ extern u32 *cna_get_firmware_buf(struct pci_dev *pdev);
 extern void bnad_set_ethtool_ops(struct net_device *netdev);
 
 /* Configuration & setup */
+extern void bnad_set_netdev_perm_addr(struct bnad *bnad);
 extern void bnad_tx_coalescing_timeo_set(struct bnad *bnad);
 extern void bnad_rx_coalescing_timeo_set(struct bnad *bnad);
 
diff --git a/drivers/net/bna/bnad_genl.c b/drivers/net/bna/bnad_genl.c
new file mode 100644
index 0000000..eec2a56
--- /dev/null
+++ b/drivers/net/bna/bnad_genl.c
@@ -0,0 +1,345 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
+#include "bnad.h"
+#include "bnad_genl.h"
+#include "bna.h"
+
+static struct nla_policy bnad_genl_policy[BNAD_GENL_ATTR_MAX + 1] = {
+	[BNAD_GENL_ATTR_IOC_INFO]
+				= { .len = sizeof(struct bnad_genl_ioc_info) },
+	[BNAD_GENL_ATTR_IOC_ATTR]
+				= { .len = sizeof(struct bnad_genl_ioc_attr) },
+};
+
+static struct genl_family bnad_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.name = "BNAD_GENL",
+	.version = BNAD_GENL_VERSION,
+	.hdrsize = 0,
+	.maxattr = BNAD_GENL_ATTR_MAX,
+};
+
+static struct bnad *
+bnad_get_bnadev(int bna_id)
+{
+	struct bnad *bnad;
+
+	mutex_lock(&bnad_list_mutex);
+	list_for_each_entry(bnad, &bnad_list, list_entry) {
+		if (bnad->id == bna_id) {
+			mutex_unlock(&bnad_list_mutex);
+			return bnad;
+		}
+	}
+	mutex_unlock(&bnad_list_mutex);
+	return NULL;
+}
+
+static void
+bnad_hwpath_get(struct bnad *bnad, char *hwpath, char *adapter_hwpath)
+{
+	int i;
+
+	strcpy(hwpath, pci_name(bnad->pcidev));
+	strcpy(adapter_hwpath, pci_name(bnad->pcidev));
+	i = strlen(adapter_hwpath) - 1;
+	while (i && (adapter_hwpath[i] != '.'))
+		i--;
+	adapter_hwpath[i] = '\0';
+}
+
+static void
+bnad_get_pci_attr(struct bnad *bnad, struct bfa_ioc_pci_attr *pci_attr)
+{
+	pci_attr->vendor_id = bnad->pcidev->vendor;
+	pci_attr->device_id = bnad->pcidev->device;
+	pci_attr->ssid = bnad->pcidev->subsystem_device;
+	pci_attr->ssvid = bnad->pcidev->subsystem_vendor;
+	pci_attr->pcifn = PCI_FUNC(bnad->pcidev->devfn);
+}
+
+static int
+bnad_genl_ioc_info_rsp(struct genl_info *info,
+	struct bnad_genl_ioc_info *genlcmd, size_t attr_size, u8 cmd)
+{
+	struct sk_buff *rsp_skb = NULL;
+	void *genl_msg_hdr = NULL;
+	size_t msg_size;
+	int err = 0;
+
+	msg_size = nla_total_size(attr_size);
+
+	rsp_skb = genlmsg_new(msg_size, GFP_KERNEL);
+	if (!rsp_skb) {
+		pr_warn("bnad[%d]: Failed to get response skb\n",
+			genlcmd->bnad_num);
+		return -ENOMEM;
+	}
+
+	genl_msg_hdr = genlmsg_put(rsp_skb, info->snd_pid, info->snd_seq,
+		&bnad_genl_family, 0, cmd);
+	if (!genl_msg_hdr) {
+		pr_warn("bnad[%d]: Failed to get the genl_msg_header\n",
+			genlcmd->bnad_num);
+		err = -ENOMEM;
+		goto failure;
+	}
+
+	NLA_PUT(rsp_skb, BNAD_GENL_ATTR_IOC_INFO, attr_size, genlcmd);
+
+	err = genlmsg_end(rsp_skb, genl_msg_hdr);
+	if (err < 0) {
+		pr_warn("bnad[%d]: Failed to do genlmsg_end\n",
+			genlcmd->bnad_num);
+		goto failure;
+	}
+
+	err = genlmsg_reply(rsp_skb, info);
+	if (err)
+		pr_warn("bnad[%d]: Could not do genlmsg_reply (%d)\n",
+			genlcmd->bnad_num, err);
+
+	return err;
+
+nla_put_failure:
+	pr_warn("bnad[%d]: Failed to do NLA_PUT\n", genlcmd->bnad_num);
+	err = -EMSGSIZE;
+failure:
+	genlmsg_cancel(rsp_skb, genl_msg_hdr);
+	kfree_skb(rsp_skb);
+	return err;
+}
+
+static int
+bnad_genl_ioc_attr_rsp(struct genl_info *info,
+	struct bnad_genl_ioc_attr *genlcmd, size_t attr_size, u8 cmd)
+{
+	struct sk_buff *rsp_skb = NULL;
+	void *genl_msg_hdr = NULL;
+	size_t msg_size;
+	int err = 0;
+
+	msg_size = nla_total_size(attr_size);
+
+	rsp_skb = genlmsg_new(msg_size, GFP_KERNEL);
+	if (!rsp_skb) {
+		pr_warn("bnad[%d]: Failed to get response skb\n",
+			genlcmd->bnad_num);
+		return -ENOMEM;
+	}
+
+	genl_msg_hdr = genlmsg_put(rsp_skb, info->snd_pid, info->snd_seq,
+		&bnad_genl_family, 0, cmd);
+	if (!genl_msg_hdr) {
+		pr_warn("bnad[%d]: Failed to get the genl_msg_header\n",
+			genlcmd->bnad_num);
+		err = -ENOMEM;
+		goto failure;
+	}
+
+	NLA_PUT(rsp_skb, BNAD_GENL_ATTR_IOC_ATTR, attr_size, genlcmd);
+
+	err = genlmsg_end(rsp_skb, genl_msg_hdr);
+	if (err < 0) {
+		pr_warn("bnad[%d]: Failed to do genlmsg_end\n",
+			genlcmd->bnad_num);
+		goto failure;
+	}
+
+	err = genlmsg_reply(rsp_skb, info);
+	if (err)
+		pr_warn("bnad[%d]: Could not do genlmsg_reply (%d)\n",
+			genlcmd->bnad_num, err);
+
+	return err;
+
+nla_put_failure:
+	pr_warn("bnad[%d]: Failed to do NLA_PUT\n", genlcmd->bnad_num);
+	err = -EMSGSIZE;
+failure:
+	genlmsg_cancel(rsp_skb, genl_msg_hdr);
+	kfree_skb(rsp_skb);
+	return err;
+}
+
+/* Note: Should be called holding bnad_conf_lock */
+static int
+bnad_genl_ioc_get_info(struct sk_buff *skb, struct genl_info *info)
+{
+	struct bnad *bnad = NULL;
+	struct bnad_genl_ioc_info *genlcmd = NULL;
+	struct bfa_ioc *ioc = NULL;
+	unsigned long flags = 0;
+	int err;
+
+	genlcmd = (struct bnad_genl_ioc_info *)
+		nla_data(info->attrs[BNAD_GENL_ATTR_IOC_INFO]);
+
+	bnad = bnad_get_bnadev(genlcmd->bnad_num);
+	if (!bnad) {
+		pr_warn("bna: Failed to get driver instance\n");
+		return -EINVAL;
+	}
+	ioc = &bnad->bna.device.ioc;
+
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	bfa_nw_ioc_get_adapter_serial_num(ioc, genlcmd->serialnum);
+	genlcmd->mac = bfa_nw_ioc_get_mac(ioc);
+	/* Get manufacturing MAC */
+	genlcmd->factory_mac = ioc->attr->mfg_mac;
+	if (bfa_mfg_is_old_wwn_mac_model(ioc->attr->card_type))
+		genlcmd->factory_mac.mac[MAC_ADDRLEN - 1] += bfa_ioc_pcifn(ioc);
+	else
+		bfa_mfg_increment_wwn_mac(
+			&(genlcmd->factory_mac.mac[MAC_ADDRLEN-3]),
+			bfa_ioc_pcifn(ioc));
+
+	/* Get stack MAC */
+	if (is_zero_ether_addr(&bnad->perm_addr.mac[0])) {
+		bna_port_mac_get(&bnad->bna.port, &bnad->perm_addr);
+		bnad_set_netdev_perm_addr(bnad);
+	}
+	memcpy(&genlcmd->current_mac, bnad->netdev->dev_addr, sizeof(mac_t));
+
+	genlcmd->bnad_num = bnad->id;
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	bnad_hwpath_get(bnad, genlcmd->hwpath, genlcmd->adapter_hwpath);
+	sprintf(genlcmd->eth_name, "%s", bnad->netdev->name);
+	strncpy(genlcmd->name, bnad->adapter_name, sizeof(genlcmd->name) - 1);
+	strncpy(genlcmd->port_name, bnad->port_name,
+		sizeof(genlcmd->port_name) - 1);
+	genlcmd->ioc_type = BFA_IOC_TYPE_LL;
+	genlcmd->status = BFA_STATUS_OK;
+
+	err = bnad_genl_ioc_info_rsp(info, genlcmd,
+		sizeof(struct bnad_genl_ioc_info), BNAD_GENL_CMD_IOC_INFO);
+
+	return err;
+}
+
+/* Note: Should be called holding bnad_conf_lock */
+static int
+bnad_genl_ioc_get_attr(struct sk_buff *skb, struct genl_info *info)
+{
+	struct bnad *bnad = NULL;
+	struct bnad_genl_ioc_attr *genlcmd = NULL;
+	struct bfa_ioc *ioc = NULL;
+	unsigned long flags = 0;
+	int err = 0;
+
+	genlcmd = (struct bnad_genl_ioc_attr *)
+		nla_data(info->attrs[BNAD_GENL_ATTR_IOC_ATTR]);
+
+	bnad = bnad_get_bnadev(genlcmd->bnad_num);
+	if (!bnad) {
+		pr_warn("bna: Failed to get driver instance\n");
+		return -EINVAL;
+	}
+	ioc = &bnad->bna.device.ioc;
+
+	memset(&genlcmd->ioc_attr, 0, sizeof(genlcmd->ioc_attr));
+	spin_lock_irqsave(&bnad->bna_lock, flags);
+	bfa_nw_ioc_get_attr(&bnad->bna.device.ioc, &genlcmd->ioc_attr);
+	spin_unlock_irqrestore(&bnad->bna_lock, flags);
+	genlcmd->ioc_attr.ioc_type = BFA_IOC_TYPE_LL;
+	strcpy(genlcmd->ioc_attr.driver_attr.driver, BNAD_NAME);
+	strncpy(genlcmd->ioc_attr.driver_attr.driver_ver,
+		BNAD_VERSION, BFA_VERSION_LEN);
+	strcpy(genlcmd->ioc_attr.driver_attr.fw_ver,
+	       genlcmd->ioc_attr.adapter_attr.fw_ver);
+	strcpy(genlcmd->ioc_attr.driver_attr.bios_ver,
+	       genlcmd->ioc_attr.adapter_attr.optrom_ver);
+	bnad_get_pci_attr(bnad, &genlcmd->ioc_attr.pci_attr);
+	genlcmd->status = BFA_STATUS_OK;
+
+	err = bnad_genl_ioc_attr_rsp(info, genlcmd,
+		sizeof(struct bnad_genl_ioc_attr), BNAD_GENL_CMD_IOC_ATTR);
+
+	return err;
+}
+
+/* BNAD generic netlink ops */
+static struct genl_ops bnad_genl_ops[] = {
+	{
+	.cmd = BNAD_GENL_CMD_IOC_INFO,
+	.flags = 0,
+	.policy = bnad_genl_policy,
+	.doit = bnad_genl_ioc_get_info,
+	.dumpit = NULL,
+	},
+	{
+	.cmd = BNAD_GENL_CMD_IOC_ATTR,
+	.flags = 0,
+	.policy = bnad_genl_policy,
+	.doit = bnad_genl_ioc_get_attr,
+	.dumpit = NULL,
+	},
+};
+
+/* Initialize generic netlink for BNAD */
+int
+bnad_genl_init(void)
+{
+	int i, err = 0;
+
+	/* Register family */
+	err = genl_register_family(&bnad_genl_family);
+	if (err) {
+		pr_warn("bna: failed to register with Netlink\n");
+		return err;
+	}
+	pr_info("bna: registered with Netlink\n");
+
+	/* Register ops */
+	for (i = 0; i < sizeof(bnad_genl_ops) / sizeof(bnad_genl_ops[0]); i++) {
+		err = genl_register_ops(&bnad_genl_family, &bnad_genl_ops[i]);
+		if (err)
+			pr_warn("bna: failed to register netlink op %u\n",
+				bnad_genl_ops[i].cmd);
+		else
+			pr_info("bna: registered netlink op %u\n",
+				bnad_genl_ops[i].cmd);
+	}
+
+	return err;
+}
+
+/* Uninitialize generic netlink for BNAD */
+int
+bnad_genl_uninit(void)
+{
+	int i, err = 0;
+
+	for (i = 0; i < sizeof(bnad_genl_ops) / sizeof(bnad_genl_ops[0]); i++) {
+		err = genl_unregister_ops(&bnad_genl_family, &bnad_genl_ops[i]);
+		if (err)
+			pr_warn("bna: failed to unregister netlink op %u)\n",
+				bnad_genl_ops[i].cmd);
+		else
+			pr_info("bna: unregistered netlink op %u\n",
+				bnad_genl_ops[i].cmd);
+	}
+
+	err = genl_unregister_family(&bnad_genl_family);
+	if (err)
+		pr_warn("bna: failed to unregister with Netlink\n");
+	else
+		pr_info("bna: unregistered with Netlink\n");
+
+	return err;
+}
diff --git a/drivers/net/bna/bnad_genl.h b/drivers/net/bna/bnad_genl.h
new file mode 100644
index 0000000..d469fe5
--- /dev/null
+++ b/drivers/net/bna/bnad_genl.h
@@ -0,0 +1,87 @@
+/*
+ * Linux network driver for Brocade Converged Network Adapter.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License (GPL) Version 2 as
+ * published by the Free Software Foundation
+ *
+ * This program is distributed in the hope that it will be useful, but
+ * WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
+ * General Public License for more details.
+ */
+/*
+ * Copyright (c) 2005-2011 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ */
+#ifndef __BNAD_GENL_H__
+#define __BNAD_GENL_H__
+
+#include <linux/device.h>
+#include <linux/netdevice.h>
+#include <linux/gfp.h>
+#include <linux/skbuff.h>
+#include <linux/ethtool.h>
+#include <linux/rtnetlink.h>
+#include <net/genetlink.h>
+
+#include "cna.h"
+
+/* Attributes */
+enum {
+	BNAD_GENL_ATTR_UNSPEC,
+	BNAD_GENL_ATTR_IOC_INFO,
+	BNAD_GENL_ATTR_IOC_ATTR,
+	__BNAD_GENL_ATTR_MAX
+};
+
+/* Effectively a single attribute */
+#define BNAD_GENL_ATTR_MAX (__BNAD_GENL_ATTR_MAX - 1)
+
+enum {
+	BNAD_GENL_VERSION = 1,
+};
+
+/* Commands/Responses */
+enum {
+	BNAD_GENL_CMD_UNSPEC,
+	BNAD_GENL_CMD_IOC_INFO,
+	BNAD_GENL_CMD_IOC_ATTR,
+	__BNAD_GENL_CMD_MAX,
+};
+
+struct bnad_genl_ioc_info {
+	int		status;
+	u16		bnad_num;
+	u16		rsvd;
+	char		serialnum[64];
+	char		hwpath[BFA_STRING_32];
+	char		adapter_hwpath[BFA_STRING_32];
+	char		guid[BFA_ADAPTER_SYM_NAME_LEN*2];
+	char		name[BFA_ADAPTER_SYM_NAME_LEN];
+	char		port_name[BFA_ADAPTER_SYM_NAME_LEN];
+	char		eth_name[BFA_ADAPTER_SYM_NAME_LEN];
+	u64		rsvd1[4];
+	mac_t		mac;
+	mac_t		factory_mac;	/* Factory mac address */
+	mac_t		current_mac;	/* Currently assigned mac address */
+	enum bfa_ioc_type     ioc_type;
+	u16		pvid;		/* Port vlan id */
+	u16		rsvd2;
+	u32		host;
+	u32		bandwidth;	/* For PF support */
+	u32		rsvd3;
+};
+
+struct bnad_genl_ioc_attr {
+	int		status;
+	u16		bnad_num;
+	u16		rsvd;
+	struct bfa_ioc_attr  ioc_attr;
+};
+
+extern int bnad_genl_init(void);
+extern int bnad_genl_uninit(void);
+
+#endif /* __BNAD_GENL_H__ */
-- 
1.7.1

