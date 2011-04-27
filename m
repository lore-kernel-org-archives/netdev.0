From: Rasesh Mody <rmody@brocade.com>
Subject: [RFC PATCH 1/1] bna: Generic Netlink Interface to collect FW trace
Date: Tue, 26 Apr 2011 18:51:57 -0700
Message-ID: <1303869117-780-1-git-send-email-rmody@brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <huangj@brocade.com>, <amathur@brocade.com>,
	Rasesh Mody <rmody@brocade.com>,
	Debashis Dutt <ddutt@brocade.com>
To: <netdev@vger.kernel.org>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:59597 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755707Ab1D0BxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2011 21:53:19 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a RFC patch to Brocade BNA 10G Ethernet driver. It adds the generic
netlink communication interface to the BNA driver to collect firmware traces
using the in-kernel generic netlink infrastructure. The driver uses the
"dumpit" handler provided by the generic netlink layer to accomplish this. The
driver can extend this interface later if required. 

As of today, there seems to be no standard mechanism to collect debug
information such as firmware trace for a given hardware. Generic Netlinki seems
to provide a suitable option to do the same, without any further
addition/modification to the existing kernel implementation.

This is a RFC patch inviting suggestions/opinions for improvement/modification
and requesting consideration for possible inclusion in net-next tree.

Signed-off-by: Debashis Dutt <ddutt@brocade.com>
Signed-off-by: Rasesh Mody <rmody@brocade.com>
---
 drivers/net/bna/bfa_ioc.c   |   59 +++++++++++
 drivers/net/bna/bfa_ioc.h   |    4 +
 drivers/net/bna/bfi.h       |    2 +
 drivers/net/bna/bnad.c      |   39 ++++++++
 drivers/net/bna/bnad.h      |    9 ++-
 drivers/net/bna/bnad_genl.c |  228 +++++++++++++++++++++++++++++++++++++++++++
 drivers/net/bna/bnad_genl.h |   63 ++++++++++++
 7 files changed, 402 insertions(+), 2 deletions(-)
 create mode 100644 drivers/net/bna/bnad_genl.c
 create mode 100644 drivers/net/bna/bnad_genl.h

diff --git a/drivers/net/bna/bfa_ioc.c b/drivers/net/bna/bfa_ioc.c
index fcb9bb3..766e48b 100644
--- a/drivers/net/bna/bfa_ioc.c
+++ b/drivers/net/bna/bfa_ioc.c
@@ -2209,6 +2209,65 @@ bfa_nw_ioc_get_mac(struct bfa_ioc *ioc)
 	return ioc->attr->mac;
 }
 
+static int
+bfa_nw_ioc_smem_read(struct bfa_ioc *ioc, void *tbuf, u32 soff, u32 sz)
+{
+	u32 pgnum, loff;
+	__be32 r32;
+	int i, len;
+	u32 *buf = tbuf;
+
+	pgnum = PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, soff);
+	loff = PSS_SMEM_PGOFF(soff);
+
+	/*
+	 *  Hold semaphore to serialize pll init and fwtrc.
+	 */
+	if (!(bfa_nw_ioc_sem_get(ioc->ioc_regs.ioc_init_sem_reg)))
+		return 1;
+
+	writel(pgnum, ioc->ioc_regs.host_page_num_fn);
+
+	len = sz/sizeof(u32);
+	for (i = 0; i < len; i++) {
+		r32 = swab32(readl(ioc->ioc_regs.smem_page_start + loff));
+		buf[i] = be32_to_cpu(r32);
+		loff += sizeof(u32);
+
+		/*
+		 * handle page offset wrap around
+		 */
+		loff = PSS_SMEM_PGOFF(loff);
+		if (loff == 0) {
+			pgnum++;
+			writel(pgnum, ioc->ioc_regs.host_page_num_fn);
+		}
+	}
+	writel(PSS_SMEM_PGNUM(ioc->ioc_regs.smem_pg0, 0),
+			ioc->ioc_regs.host_page_num_fn);
+	/*
+	 *  release semaphore.
+	 */
+	writel(1, ioc->ioc_regs.ioc_init_sem_reg);
+
+	return 0;
+}
+
+int
+bfa_nw_ioc_debug_fwtrc(struct bfa_ioc *ioc, void *trcdata, int *trclen)
+{
+	u32 loff = (BFI_IOC_TRC_OFF + BFA_DBG_FWTRC_LEN * (ioc->port_id));
+	int tlen, status = 0;
+
+	tlen = *trclen;
+	if (tlen > BFA_DBG_FWTRC_LEN)
+		tlen = BFA_DBG_FWTRC_LEN;
+
+	status = bfa_nw_ioc_smem_read(ioc, trcdata, loff, tlen);
+	*trclen = tlen;
+	return status;
+}
+
 /**
  * Firmware failure detected. Start recovery actions.
  */
diff --git a/drivers/net/bna/bfa_ioc.h b/drivers/net/bna/bfa_ioc.h
index bd48abe..383cd59 100644
--- a/drivers/net/bna/bfa_ioc.h
+++ b/drivers/net/bna/bfa_ioc.h
@@ -23,6 +23,9 @@
 #include "bfi.h"
 #include "cna.h"
 
+#define BFA_DBG_FWTRC_LEN	(BFI_IOC_TRC_ENTS * BFI_IOC_TRC_ENT_SZ + \
+				BFI_IOC_TRC_HDR_SZ)
+
 #define BFA_IOC_TOV		3000	/* msecs */
 #define BFA_IOC_HWSEM_TOV	500	/* msecs */
 #define BFA_IOC_HB_TOV		500	/* msecs */
@@ -269,6 +272,7 @@ void bfa_nw_ioc_hbfail_register(struct bfa_ioc *ioc,
 bool bfa_nw_ioc_sem_get(void __iomem *sem_reg);
 void bfa_nw_ioc_sem_release(void __iomem *sem_reg);
 void bfa_nw_ioc_hw_sem_release(struct bfa_ioc *ioc);
+int bfa_nw_ioc_debug_fwtrc(struct bfa_ioc *ioc, void *trcdata, int *trclen);
 void bfa_nw_ioc_fwver_get(struct bfa_ioc *ioc,
 			struct bfi_ioc_image_hdr *fwhdr);
 bool bfa_nw_ioc_fwver_cmp(struct bfa_ioc *ioc,
diff --git a/drivers/net/bna/bfi.h b/drivers/net/bna/bfi.h
index 6050379..ee73b6f 100644
--- a/drivers/net/bna/bfi.h
+++ b/drivers/net/bna/bfi.h
@@ -277,6 +277,8 @@ struct bfi_ioc_getattr_reply {
  */
 #define BFI_IOC_TRC_OFF		(0x4b00)
 #define BFI_IOC_TRC_ENTS	256
+#define BFI_IOC_TRC_ENT_SZ	16
+#define BFI_IOC_TRC_HDR_SZ	32
 
 #define BFI_IOC_FW_SIGNATURE	(0xbfadbfad)
 #define BFI_IOC_MD5SUM_SZ	4
diff --git a/drivers/net/bna/bnad.c b/drivers/net/bna/bnad.c
index e588511..d8d0da0 100644
--- a/drivers/net/bna/bnad.c
+++ b/drivers/net/bna/bnad.c
@@ -25,6 +25,7 @@
 #include <linux/ip.h>
 
 #include "bnad.h"
+#include "bnad_genl.h"
 #include "bna.h"
 #include "cna.h"
 
@@ -44,8 +45,12 @@ MODULE_PARM_DESC(bnad_ioc_auto_recover, "Enable / Disable auto recovery");
 /*
  * Global variables
  */
+u32 bna_id;
 u32 bnad_rxqs_per_cq = 2;
 
+struct mutex bnad_list_mutex;
+LIST_HEAD(bnad_list);
+
 static const u8 bnad_bcast_addr[] =  {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
 
 /*
@@ -72,6 +77,23 @@ do {								\
 
 #define BNAD_TXRX_SYNC_MDELAY	250	/* 250 msecs */
 
+static void
+bnad_add_to_list(struct bnad *bnad)
+{
+	mutex_lock(&bnad_list_mutex);
+	list_add_tail(&bnad->list_entry, &bnad_list);
+	bna_id++;
+	mutex_unlock(&bnad_list_mutex);
+}
+
+static void
+bnad_remove_from_list(struct bnad *bnad)
+{
+	mutex_lock(&bnad_list_mutex);
+	list_del(&bnad->list_entry);
+	mutex_unlock(&bnad_list_mutex);
+}
+
 /*
  * Reinitialize completions in CQ, once Rx is taken down
  */
@@ -3087,6 +3109,11 @@ bnad_pci_probe(struct pci_dev *pdev,
 	}
 	bnad = netdev_priv(netdev);
 
+	mutex_lock(&bnad_list_mutex);
+	bnad->id = bna_id;
+	mutex_unlock(&bnad_list_mutex);
+
+	bnad_add_to_list(bnad);
 	/*
 	 * PCI initialization
 	 * 	Output : using_dac = 1 for 64 bit DMA
@@ -3189,6 +3216,7 @@ disable_device:
 	bnad_res_free(bnad);
 	bnad_disable_msix(bnad);
 pci_uninit:
+	bnad_remove_from_list(bnad);
 	bnad_pci_uninit(pdev);
 	bnad_lock_uninit(bnad);
 	bnad_uninit(bnad);
@@ -3226,6 +3254,7 @@ bnad_pci_remove(struct pci_dev *pdev)
 
 	bnad_res_free(bnad);
 	bnad_disable_msix(bnad);
+	bnad_remove_from_list(bnad);
 	bnad_pci_uninit(pdev);
 	bnad_lock_uninit(bnad);
 	bnad_uninit(bnad);
@@ -3257,6 +3286,7 @@ bnad_module_init(void)
 
 	pr_info("Brocade 10G Ethernet driver\n");
 
+	mutex_init(&bnad_list_mutex);
 	bfa_nw_ioc_auto_recover(bnad_ioc_auto_recover);
 
 	err = pci_register_driver(&bnad_pci_driver);
@@ -3266,6 +3296,10 @@ bnad_module_init(void)
 		return err;
 	}
 
+	/* Register with generic netlink */
+	if (bnad_genl_init())
+		pr_err("bna: Generic Netlink Register failed\n");
+
 	return 0;
 }
 
@@ -3273,6 +3307,11 @@ static void __exit
 bnad_module_exit(void)
 {
 	pci_unregister_driver(&bnad_pci_driver);
+	mutex_destroy(&bnad_list_mutex);
+
+	/* Unegister with generic netlink */
+	if (bnad_genl_uninit())
+		pr_err("bna: Generic Netlink Unregister failed\n");
 
 	if (bfi_fw)
 		release_firmware(bfi_fw);
diff --git a/drivers/net/bna/bnad.h b/drivers/net/bna/bnad.h
index ccdabad..2afec2b 100644
--- a/drivers/net/bna/bnad.h
+++ b/drivers/net/bna/bnad.h
@@ -279,13 +279,18 @@ struct bnad {
 	char			adapter_name[BNAD_NAME_LEN];
 	char 			port_name[BNAD_NAME_LEN];
 	char			mbox_irq_name[BNAD_NAME_LEN];
+
+	int			id;
+	struct list_head	list_entry;
 };
 
 /*
  * EXTERN VARIABLES
  */
-extern struct firmware *bfi_fw;
-extern u32 		bnad_rxqs_per_cq;
+extern struct firmware		*bfi_fw;
+extern struct mutex		bnad_list_mutex;
+extern struct list_head		bnad_list;
+extern u32			bnad_rxqs_per_cq;
 
 /*
  * EXTERN PROTOTYPES
diff --git a/drivers/net/bna/bnad_genl.c b/drivers/net/bna/bnad_genl.c
new file mode 100644
index 0000000..d8e49ad
--- /dev/null
+++ b/drivers/net/bna/bnad_genl.c
@@ -0,0 +1,228 @@
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
+static struct genl_family bnad_genl_family = {
+	.id = GENL_ID_GENERATE,
+	.name = "BNAD_GENL",
+	.version = BNAD_GENL_VERSION,
+	.hdrsize = 0,
+	.maxattr = BNAD_GENL_ATTR_MAX,
+};
+
+struct bnad_fw_debug_info {
+	char	*debug_buffer;
+	u32	buffer_len;
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
+static int
+bnad_genl_fwtrc_msg_fill(struct sk_buff *skb, u32 pid, u32 seq, int flags,
+			struct bnad_fw_debug_info *fw_debug, long *offset)
+{
+	void *genl_msg_hdr = NULL;
+	int sk_buff_len, err = 0;
+
+	/* genlmsg_put */
+	genl_msg_hdr = genlmsg_put(skb, pid, seq, &bnad_genl_family, flags,
+							BNAD_GENL_CMD_FWTRC);
+	if (!genl_msg_hdr) {
+		pr_err("bna: Failed to get the genl_msg_header\n");
+		return -ENOMEM;
+	}
+
+	/* NLA_PUT
+	 * sk_buff_len - available lenth for attribute payload
+	 * offset - offset in fwtrc buffer
+	 */
+	sk_buff_len = skb_tailroom(skb) - NLA_HDRLEN;
+	if ((fw_debug->buffer_len - *offset) < sk_buff_len)
+		sk_buff_len = fw_debug->buffer_len - *offset;
+
+	NLA_PUT(skb, BNAD_GENL_ATTR_FWTRC, sk_buff_len,
+				((fw_debug->debug_buffer) + *offset));
+
+	*offset += sk_buff_len;
+
+	/* genlmsg_end */
+	err = genlmsg_end(skb, genl_msg_hdr);
+	if (err < 0) {
+		pr_err("bna: Failed to do genlmsg_end\n");
+		return -ENOMEM;
+	}
+
+	return 0;
+
+nla_put_failure:
+	pr_err("bna: Failed to do NLA_PUT\n");
+	genlmsg_cancel(skb, genl_msg_hdr);
+	return -EMSGSIZE;
+}
+
+static int
+bnad_genl_fwtrc_get(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	/*
+	 * cb->args[0] firmware trace offset
+	 * cb->args[1] firmware buffer pointer
+	 */
+	long offset = cb->args[0];
+	int err;
+	struct bnad *bnad = NULL;
+	struct bnad_fw_debug_info *fw_debug = NULL;
+	struct bnad_genl_debug *iocmd = NULL;
+
+	if (offset >= (long)BFA_DBG_FWTRC_LEN) {
+		fw_debug = (struct bnad_fw_debug_info *)cb->args[1];
+		vfree(fw_debug->debug_buffer);
+		fw_debug->debug_buffer = NULL;
+		kfree(fw_debug);
+		fw_debug = NULL;
+		return skb->len;
+	}
+
+	if (offset == 0) {
+		/* Get the driver instance */
+		iocmd = (struct bnad_genl_debug *)
+			(((char *)NLMSG_DATA(cb->nlh)) +
+			GENL_HDRLEN + NLA_HDRLEN);
+		bnad = bnad_get_bnadev(iocmd->inst_no);
+		if (!bnad) {
+			pr_warn("bna: Failed to get driver instance\n");
+			return -EINVAL;
+		}
+
+		/* Allocate memory for fwtrc structure and buffer */
+		fw_debug = kzalloc(sizeof(struct bnad_fw_debug_info),
+								GFP_KERNEL);
+		if (!fw_debug)
+			return -ENOMEM;
+
+		fw_debug->buffer_len = iocmd->bufsz;
+
+		fw_debug->debug_buffer = vzalloc(fw_debug->buffer_len);
+		if (!fw_debug->debug_buffer) {
+			kfree(fw_debug);
+			fw_debug = NULL;
+			pr_err("bnad[%d]: Failed to allocate fwtrc buffer\n",
+								bnad->id);
+			return -ENOMEM;
+		}
+
+		/* Get the firmware trace into the buffer */
+		err = bfa_nw_ioc_debug_fwtrc(&bnad->bna.device.ioc,
+				fw_debug->debug_buffer, &fw_debug->buffer_len);
+		if (err) {
+			vfree(fw_debug->debug_buffer);
+			fw_debug->debug_buffer = NULL;
+			kfree(fw_debug);
+			fw_debug = NULL;
+			pr_err("bnad[%d]: Failed to collect fwtrc\n", bnad->id);
+			return -ENOMEM;;
+		}
+
+		cb->args[1] = (long)fw_debug;
+	} else
+		fw_debug = (struct bnad_fw_debug_info *)cb->args[1];
+
+	err = bnad_genl_fwtrc_msg_fill(skb, NETLINK_CB(cb->skb).pid,
+			cb->nlh->nlmsg_seq, NLM_F_MULTI, fw_debug, &offset);
+	if (err < 0)
+		return err;
+
+	cb->args[0] = offset;
+	return skb->len;
+}
+
+static struct genl_ops bnad_genl_ops[] = {
+	{
+	.cmd = BNAD_GENL_CMD_FWTRC,
+	.flags = 0,
+	.policy = NULL,
+	.doit = NULL,
+	.dumpit = bnad_genl_fwtrc_get,
+	},
+};
+
+int
+bnad_genl_init(void)
+{
+	int i, err = 0;
+
+	/* Register family */
+	err = genl_register_family(&bnad_genl_family);
+	if (err) {
+		pr_err("bna: failed to register with Netlink\n");
+		return err;
+	}
+	pr_info("bna: registered with Netlink\n");
+
+	/* Register ops */
+	for (i = 0; i < sizeof(bnad_genl_ops) / sizeof(bnad_genl_ops[0]); i++) {
+		err = genl_register_ops(&bnad_genl_family, &bnad_genl_ops[i]);
+		if (err)
+			pr_err("bna: failed to register netlink op %u\n",
+				bnad_genl_ops[i].cmd);
+		else
+			pr_info("bna: registered netlink op %u\n",
+				bnad_genl_ops[i].cmd);
+	}
+
+	return err;
+}
+
+int
+bnad_genl_uninit(void)
+{
+	int i, err = 0;
+
+	for (i = 0; i < sizeof(bnad_genl_ops) / sizeof(bnad_genl_ops[0]); i++) {
+		err = genl_unregister_ops(&bnad_genl_family, &bnad_genl_ops[i]);
+		if (err)
+			pr_err("bna: failed to unregister netlink op %u)\n",
+				bnad_genl_ops[i].cmd);
+		else
+			pr_info("bna: unregistered netlink op %u\n",
+				bnad_genl_ops[i].cmd);
+	}
+
+	err = genl_unregister_family(&bnad_genl_family);
+	if (err)
+		pr_err("bna: failed to unregister with Netlink\n");
+	else
+		pr_info("bna: unregistered with Netlink\n");
+
+	return err;
+}
diff --git a/drivers/net/bna/bnad_genl.h b/drivers/net/bna/bnad_genl.h
new file mode 100644
index 0000000..fb75a6e
--- /dev/null
+++ b/drivers/net/bna/bnad_genl.h
@@ -0,0 +1,63 @@
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
+/* Attributes */
+enum {
+	BNAD_GENL_ATTR_UNSPEC,
+	BNAD_GENL_ATTR_FWTRC,
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
+	BNAD_GENL_CMD_FWTRC,
+	__BNAD_GENL_CMD_MAX,
+};
+
+struct bnad_genl_debug {
+	int		status;
+	u16		bnad_num;
+	u16		rsvd;
+	u32		bufsz;
+	int		inst_no;
+	u64		buf_ptr;
+	u64		offset;
+};
+
+extern int bnad_genl_init(void);
+extern int bnad_genl_uninit(void);
+
+#endif /* __BNAD_GENL_H__ */
-- 
1.7.1

