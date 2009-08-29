From: Rasesh Mody <rmody@brocade.com>
Subject: Subject: [PATCH 2/9] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 28 Aug 2009 22:18:39 -0700
Message-ID: <200908290518.n7T5IdUM031878@blc-10-10.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: amathur@brocade.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.83]:35854 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751152AbZH2FX5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Aug 2009 01:23:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rasesh Mody <rmody@brocade.com>

This is patch 2/9 which contains linux driver source for 
Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.

We wish this patch to be considered for inclusion in 2.6.30 

Signed-off-by: Rasesh Mody <rmody@brocade.com>
---


diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna_fn.c linux-2.6.30.5-mod/drivers/net/bna/bna_fn.c
--- linux-2.6.30.5-orig/drivers/net/bna/bna_fn.c	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna_fn.c	2009-08-28 21:09:22.647957000 -0700
@@ -0,0 +1,2178 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ *    Copyright (c) 2007-2008 Brocade Communications Systems, Inc.
+ *    All rights reserved.
+ *
+ *    @file bna_fn.c BNA Rx and Tx Function Management
+ */
+
+#include <bna_os.h>
+#include <bna_log_trc.h>
+#include "bna.h"
+#include "bna_hwreg.h"
+#include "bna_priv.h"
+#include "bna_trcmod.h"
+#include <bfi/bfi_ll.h>
+#include <bfi/bfi_cee.h>
+
+BNA_TRC_FILE(HAL, FN);
+
+/*
+ * 12 bit Max VLAN Id mask used to
+ * wrap overflowing VLANs wraps around the
+ * max value of 4095
+ */
+#define BNA_MAX_VLAN_ID_MASK	0x00000fff
+
+const struct bna_chip_regs_offset reg_offset[] =
+	{ {HOST_PAGE_NUM_FN0, HOSTFN0_INT_STATUS,
+	   HOSTFN0_INT_MASK, HOST_MSIX_ERR_INDEX_FN0},
+{HOST_PAGE_NUM_FN1, HOSTFN1_INT_STATUS,
+ HOSTFN1_INT_MASK, HOST_MSIX_ERR_INDEX_FN1},
+{HOST_PAGE_NUM_FN2, HOSTFN2_INT_STATUS,
+ HOSTFN2_INT_MASK, HOST_MSIX_ERR_INDEX_FN2},
+{HOST_PAGE_NUM_FN3, HOSTFN3_INT_STATUS,
+ HOSTFN3_INT_MASK, HOST_MSIX_ERR_INDEX_FN3},
+};
+
+/**
+ * bna_init()
+ *
+ *   Called by the driver during initialization. The driver is
+ *   expected to allocate struct bna_dev_s structure for the BNA layer.
+ *
+ * @param[in]  bar0        - BAR0 value
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ *      		     allocated by the calling driver
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_init(struct bna_dev_s *dev, void *bar0, void *stats,
+	 struct bna_dma_addr stats_dma, struct bfa_trc_mod_s *trcmod)
+{
+	u32 pcifn;
+
+	memset(dev, 0, sizeof(struct bna_dev_s));
+
+	dev->trcmod = trcmod;
+
+	dev->bar0 = (u8 *) bar0;
+	dev->hw_stats = (struct bfi_ll_stats *) stats;
+	dev->hw_stats_dma.msb = stats_dma.msb;
+	dev->hw_stats_dma.lsb = stats_dma.lsb;
+
+	dev->rxf_promiscuous_id = BNA_RXF_ID_NONE;
+	dev->rxf_default_id = BNA_RXF_ID_NONE;
+
+	pcifn = bna_reg_read(dev->bar0 + FNC_ID_REG);
+	pcifn = bna_reg_read(dev->bar0 + FNC_ID_REG);
+	BNA_ASSERT(pcifn <= 3);
+
+	dev->regs.page_addr = dev->bar0 + reg_offset[pcifn].page_addr;
+	dev->regs.fn_int_status = dev->bar0 + reg_offset[pcifn].fn_int_status;
+	dev->regs.fn_int_mask = dev->bar0 + reg_offset[pcifn].fn_int_mask;
+
+	if (pcifn < 3)
+		dev->port = 0;
+	else
+		dev->port = 1;
+
+	dev->pci_fn = pcifn;
+	BNA_LOG_DEBUG(("LL Driver Using PCI fn (%d)\n", dev->pci_fn));
+
+	dev->ioc_disable_pending = 0;
+}
+
+/**
+ * bna_uninit()
+ *
+ *   Called by the driver during removal/unload.
+ *
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ *      		     allocated by the calling driver
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_uninit(void *bna_handle)
+{
+	return BNA_OK;
+}
+
+/**
+ *  bna_rit_config_set()
+ *
+ *  Loads RIT entries "rit" into RIT starting from RIT index "rit_id".
+ *  Care must be taken not to overlap regions within the RIT.
+ *
+ * @param[in]  dev          - pointer to BNA device structure
+ * @param[in]  rit_offset   - offset into the RIT
+ * @param[in]  rit          - RIT entry
+ * @param[in]  rit_size     - size of RIT entry
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_rit_config_set(struct bna_dev_s *dev, unsigned int rit_offset,
+		   const struct bna_rit_entry rit[], unsigned int rit_size)
+{
+	int i;
+
+	struct bna_rit_mem *rit_mem;
+
+	BNA_ASSERT(BNA_POWER_OF_2(rit_size));
+	BNA_ASSERT((rit_offset + rit_size) < BNA_RIT_SIZE);
+
+	rit_mem = (struct bna_rit_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, FUNCTION_TO_RXQ_TRANSLATE);
+
+	dev->rit_size[rit_offset] = rit_size;
+
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(RXA0_MEM_BLK_BASE_PG_NUM + dev->port,
+				       FUNCTION_TO_RXQ_TRANSLATE));
+
+	for (i = 0; i < rit_size; i++) {
+		bna_mem_writew(&rit_mem[i + rit_offset],
+			       rit[i].large_rxq_id << 6 | rit[i].small_rxq_id);
+	}
+}
+
+/**
+ * bna_rxf_config_set()
+ *
+ *   For RxF "rxf_id", it configures RxF based on "cfg_ptr", and indicates
+ *   to the statistics collector to collect statistics for this Rx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  cfg_ptr - pointer to rx-function configuration.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_config_set(struct bna_dev_s *dev, unsigned int rxf_id,
+		   const struct bna_rxf_config *cfg_ptr)
+{
+	u32 i;
+
+	struct bna_rss_mem *rss_mem;
+	struct bna_rx_fndb_ram *rx_fndb_ram;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	rss_mem = (struct bna_rss_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RSS_TABLE_BASE_OFFSET);
+	rx_fndb_ram = (struct bna_rx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RX_FNDB_RAM_BASE_OFFSET);
+
+	/* Need to revisit, don't do this check */
+	if (((cfg_ptr->flags & BNA_RXF_CF_SM_LG_RXQ))
+	    && (cfg_ptr->hds.type == 1)) {
+		/* HDS and small-large RxQs are mutually exclusive */
+		BNA_LOG_ERROR(("Small/Large & HDS cannot be set simultaneously\n"));
+		return (BNA_FAIL);
+	}
+
+	if (cfg_ptr->flags & BNA_RXF_CF_RSS_ENABLE) {
+		BNA_ASSERT(cfg_ptr->rss.hash_mask ==
+			   dev->rit_size[cfg_ptr->rit_offset] - 1);
+
+		/* configure RSS Table */
+		bna_reg_write(dev->regs.page_addr,
+			      BNA_GET_PAGE_NUM(RAD0_MEM_BLK_BASE_PG_NUM +
+					       dev->port,
+					       RSS_TABLE_BASE_OFFSET));
+
+		/* temporarily disable RSS, while hash value is being written */
+		bna_mem_writew(&rss_mem[0].type_n_hash, 0);
+
+		for (i = 0; i < BNA_RSS_HASH_KEY_LEN; i++) {
+			bna_mem_writew(&rss_mem[0].
+				       hash_key[(BNA_RSS_HASH_KEY_LEN - 1) - i],
+				       bna_os_htonl(cfg_ptr->rss.
+						    toeplitz_hash_key[i]));
+		}
+
+		bna_mem_writew(&rss_mem[0].type_n_hash, cfg_ptr->rss.type |
+			       cfg_ptr->rss.hash_mask);
+
+	}
+	/* configure RxF based on "cfg_ptr" */
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2),
+				       RX_FNDB_RAM_BASE_OFFSET));
+
+	/* we always use RSS table 0 */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].rss_prop,
+		       cfg_ptr->flags & BNA_RXF_CF_RSS_ENABLE);
+
+	/* small large buffer enable/disable */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].size_routing_props,
+		       (cfg_ptr->flags & BNA_RXF_CF_SM_LG_RXQ) | 0x80);
+
+	/* RIT offset, HDS forced offset, multicast RxQ Id */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].rit_hds_mcastq,
+		       (cfg_ptr->rit_offset << 16) |
+		       (cfg_ptr->hds.forced_offset << 8) |
+		       (cfg_ptr->hds.type & BNA_HDS_FORCED) |
+		       cfg_ptr->mcast_rxq_id);
+
+	/* default vlan tag, default function enable, strip vlan bytes,
+	   HDS type, header size */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].control_flags,
+		       (cfg_ptr->default_vlan << 16) | (cfg_ptr->flags &
+							(BNA_RXF_CF_DEFAULT_VLAN
+							 |
+							 BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE
+							 |
+							 BNA_RXF_CF_VLAN_STRIP))
+		       | (cfg_ptr->hds.type & ~BNA_HDS_FORCED) | cfg_ptr->hds.
+		       header_size);
+
+	/* turn on statistics collection for this RxF */
+	dev->rxf_active |= ((u64) 1 << rxf_id);
+	return (BNA_OK);
+}
+
+/**
+ * bna_rxf_config_clear()
+ *
+ *   For RxF "rxf_id", it clear its configuration and indicates to the
+ *   statistics collector to stop collecting statistics for this
+ *   Rx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_rxf_config_clear(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bna_rx_fndb_ram *rx_fndb_ram;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	rx_fndb_ram = (struct bna_rx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RX_FNDB_RAM_BASE_OFFSET);
+
+	/* clear configuration of RxF base */
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2),
+				       RX_FNDB_RAM_BASE_OFFSET));
+
+	/* we always use RSS table 0 */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].rss_prop, 0);
+
+	/* small large buffer enable/disable */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].size_routing_props, 0x80);
+
+	/* RIT offset, HDS forced offset, multicast RxQ Id */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].rit_hds_mcastq, 0);
+
+	/* default vlan tag, default function enable, strip vlan bytes,
+	   HDS type, header size */
+	bna_mem_writew(&rx_fndb_ram[rxf_id].control_flags, 0);
+
+	/* turn off statistics collection for this RxF */
+	dev->rxf_active &= ~((u64) 1 << rxf_id);
+}
+
+/**
+ * bna_rxf_disable()
+ *
+ *  Disables the Rx Function without clearing the configuration
+ *  Also disables collection of statistics.
+ *
+ * @param[in] dev   	- Pointer to BNA device handle
+ * @param[in] rxf_id    - Id of the Rx Function to be disabled
+ *
+ * @return    BNA_OK if mbox command succeeded, else BNA_FAIL
+ */
+enum bna_status_e
+bna_rxf_disable(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bfi_ll_rxf_multi_req ll_req;
+	u64 bit_mask = 1 << rxf_id;
+	enum bna_status_e status;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_RX_REQ, 0);
+	ll_req.rxf_id_mask[0] = bna_os_htonl((u32) bit_mask);
+	ll_req.rxf_id_mask[1] = bna_os_htonl((u32) (bit_mask >> 32));
+	ll_req.enable = 0;
+
+	status = bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+	if (!status)
+		dev->rxf_active &= ~bit_mask;
+
+	return status;
+}
+
+
+/* TODO : Delete when Windows migration is complete */
+void
+bna_rxf_disable_old(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bna_rx_fndb_ram *rx_fndb_ram;
+	u32 ctl_flags;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	/* Clear the vlan table first, before writing to the Rx Fn DB */
+	bna_rxf_vlan_del_all(dev, rxf_id);
+
+	rx_fndb_ram = (struct bna_rx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RX_FNDB_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2),
+				       RX_FNDB_RAM_BASE_OFFSET));
+
+	ctl_flags = bna_mem_readw(&rx_fndb_ram[rxf_id].control_flags);
+
+	/* Enable setting of the default vlan tag for untagged packets */
+	/* Don't need to store these already there in the BNA config */
+	ctl_flags |= BNA_RXF_CF_DEFAULT_VLAN;
+
+	bna_mem_writew(&rx_fndb_ram[rxf_id].control_flags, ctl_flags);
+
+	/* turn off statistics collection for this RxF */
+	dev->rxf_active &= ~((u64) 1 << rxf_id);
+}
+
+/**
+ * bna_rxf_enable()
+ *
+ *  Enables the Rx Function
+ *
+ * @param[in] dev   	- Pointer to BNA device handle
+ * @param[in] rxf_id    - Id of the Rx Function to be disabled
+ *
+ * @return    BNA_OK if mbox command succeeded, else BNA_FAIL
+ */
+enum bna_status_e
+bna_rxf_enable(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bfi_ll_rxf_multi_req ll_req;
+	u64 bit_mask = 1 << rxf_id;
+	enum bna_status_e status;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_RX_REQ, 0);
+	ll_req.rxf_id_mask[0] = bna_os_htonl((u32) bit_mask);
+	ll_req.rxf_id_mask[1] = bna_os_htonl((u32) (bit_mask >> 32));
+	ll_req.enable = 1;
+
+	status = bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+	if (!status) {
+		dev->rxf_active |= bit_mask;
+	}
+	return status;
+}
+
+
+enum bna_status_e
+bna_multi_rxf_active(struct bna_dev_s *dev, u64 rxf_id_mask, u8 enable)
+{
+	struct bfi_ll_rxf_multi_req ll_req;
+	enum bna_status_e status;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_RX_REQ, 0);
+	ll_req.rxf_id_mask[0] = bna_os_htonl((u32) rxf_id_mask);
+	ll_req.rxf_id_mask[1] = bna_os_htonl((u32) (rxf_id_mask >> 32));
+	ll_req.enable = enable;
+
+	status = bna_mbox_send(dev, &ll_req, sizeof(ll_req), dev->cbarg);
+	if (!status) {
+		if (enable)
+			dev->rxf_active |= rxf_id_mask;
+		else
+			dev->rxf_active &= ~rxf_id_mask;
+	}
+	return status;
+}
+
+/* TODO : Delete when Windows migration is complete */
+void
+bna_rxf_enable_old(struct bna_dev_s *dev, unsigned int rxf_id,
+		   const struct bna_rxf_config *cfg_ptr)
+{
+	struct bna_rx_fndb_ram *rx_fndb_ram;
+	u32 ctl_flags;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	/* Restore the vlan filter before writing to Fn DB */
+	bna_rxf_vlan_filter(dev, rxf_id, dev->vlan_filter_enable[rxf_id]);
+
+	rx_fndb_ram = (struct bna_rx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RX_FNDB_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2),
+				       RX_FNDB_RAM_BASE_OFFSET));
+
+	ctl_flags = bna_mem_readw(&rx_fndb_ram[rxf_id].control_flags);
+
+	if (cfg_ptr->flags & BNA_RXF_CF_DEFAULT_VLAN)
+		ctl_flags |= BNA_RXF_CF_DEFAULT_VLAN;
+	else
+		ctl_flags &= ~BNA_RXF_CF_DEFAULT_VLAN;
+
+	bna_mem_writew(&rx_fndb_ram[rxf_id].control_flags, ctl_flags);
+
+	/* turn on statistics collection for this RxF */
+	dev->rxf_active |= ((u64) 1 << rxf_id);
+}
+
+
+/**
+ * bna_rxf_ucast_mac_get()
+ *
+ *  For RxF "rxf_id", it overwrites the burnt-in unicast MAC with
+ *  the one specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID
+ * @param[in]  entry   - offset into UCAM to read
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to set
+ *
+ * @return 	void
+ */
+void
+bna_rxf_ucast_mac_get(struct bna_dev_s *dev, unsigned int *rxf_id,
+		      unsigned int entry, const bna_mac_t *mac_addr_ptr)
+{
+	u32 mac_47_32, mac_31_0;
+	u8 *mac_ptr = (u8 *) mac_addr_ptr;
+	struct bna_cam *ucam;
+	struct bna_ucast_mem *ucam_ram;
+
+	ucam = (struct bna_cam *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, UCAST_CAM_BASE_OFFSET);
+	ucam_ram = (struct bna_ucast_mem *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, UCAST_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2), UCAST_RAM_BASE_OFFSET));
+
+	/* turn on the bit corresponding to the given RxF */
+	*rxf_id = (bna_mem_readw(&ucam_ram[entry]) & 0x3f);
+
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2), UCAST_CAM_BASE_OFFSET));
+
+	/* add unicast MAC */
+	mac_47_32 = (bna_mem_readw(&ucam[entry].cam_mac_addr_47_32) & 0xffff);
+	mac_31_0 = bna_mem_readw(&ucam[entry].cam_mac_addr_31_0);
+
+
+	mac_ptr[0] = mac_47_32 >> 8;
+	mac_ptr[1] = mac_47_32 & 0xff;
+
+	mac_ptr[2] = mac_31_0 >> 24;
+	mac_ptr[3] = (mac_31_0 >> 16) & 0xff;
+	mac_ptr[4] = (mac_31_0 >> 8) & 0xff;
+	mac_ptr[5] = mac_31_0 & 0xff;
+}
+
+/**
+ * bna_rxf_ucast_mac_set()
+ *
+ *  For RxF "rxf_id", it overwrites the burnt-in unicast MAC with
+ *  the one specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to set
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_ucast_mac_set(struct bna_dev_s *dev, unsigned int rxf_id,
+		      const bna_mac_t *mac_addr_ptr)
+{
+	struct bfi_ll_mac_addr_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	/* we are supposed to set MAC adresses for default RxF only */
+	if (dev->rxf_default_id == BNA_RXF_ID_NONE) {
+		if (rxf_id != BNA_DEFAULT_RXF_ID) {
+			BNA_LOG_ERROR(("RxF Id [%d] Not Default RxF Id\n",
+				       rxf_id));
+			return BNA_FAIL;
+		}
+	} else {
+		if (rxf_id != dev->rxf_default_id) {
+			BNA_LOG_ERROR(("RxF Id[%d] Not current Default RxF Id"
+				       "[%d]\n", rxf_id, dev->rxf_default_id));
+			return BNA_FAIL;
+		}
+	}
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_UCAST_SET_REQ, 0);
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_ucast_mac_add()
+ *
+ *  For RxF "rxf_id", it adds the unicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to add
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_ucast_mac_add(struct bna_dev_s *dev, unsigned int rxf_id,
+		      const bna_mac_t *mac_addr_ptr)
+{
+	struct bfi_ll_mac_addr_req cmd;
+
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+	/* we are not supposed to add MAC adresses to default RxF */
+	if (rxf_id == dev->rxf_default_id) {
+		BNA_LOG_ERROR(("Cannot add MAC address for default RxF[%d]\n",
+			       rxf_id));
+		return BNA_FAIL;
+	}
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_UCAST_ADD_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_ucast_mac_del()
+ *
+ *  For RxF "rxf_id", it deletes the unicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to add
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_ucast_mac_del(struct bna_dev_s *dev, unsigned int rxf_id,
+		      const bna_mac_t *mac_addr_ptr)
+{
+	struct bfi_ll_mac_addr_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	/* we are not supposed to delete MAC adresses from default RxF */
+	if (rxf_id == dev->rxf_default_id) {
+		BNA_LOG_ERROR(("Cannot del MAC address for default RxF[%d]\n",
+			       rxf_id));
+		return BNA_FAIL;
+	}
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_UCAST_DEL_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_mcast_mac_add()
+ *
+ *  For RxF "rxf_id", it adds the multicast MAC specified by
+ *  "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to add
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_mac_add(struct bna_dev_s *dev, unsigned int rxf_id,
+		      const bna_mac_t *mac_addr_ptr)
+{
+	u32 mac_47_32, mac_31_0, i;
+	u8 *mac_ptr = (u8 *) mac_addr_ptr;
+	struct bfi_ll_mac_addr_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	mac_47_32 = (mac_ptr[0] << 8) | mac_ptr[1];
+	mac_31_0 = (mac_ptr[2] << 24) | (mac_ptr[3] << 16) |
+		(mac_ptr[4] << 8) | mac_ptr[5];
+
+	for (i = 0; i < BNA_MCAST_TABLE_SIZE; i++) {
+		if ((mac_47_32 == dev->mcast_47_32[i]) &&
+		    (mac_31_0 == dev->mcast_31_0[i])) {
+			/* existing entry found, stop and use it */
+			break;
+		}
+	}
+
+	if (i == BNA_MCAST_TABLE_SIZE) {
+		/* no existing entry found we need to find the
+		   first unused entry */
+		for (i = 0; i < BNA_MCAST_TABLE_SIZE; i++) {
+			if ((dev->mcast_47_32[i] == 0)
+			    && (dev->mcast_31_0[i] == 0)) {
+				/* unused entry found, stop and use it */
+				break;
+			}
+		}
+	}
+
+	if (i == BNA_MCAST_TABLE_SIZE) {
+		/* no entry available, table full */
+		BNA_LOG_ERROR(("Multicast MAC table is full\n"));
+		return BNA_FAIL;
+	}
+
+	dev->mcast_47_32[i] = mac_47_32;
+	dev->mcast_31_0[i] = mac_31_0;
+
+	BNA_TRACE(dev, dev->mcast_47_32[i]);
+	BNA_TRACE(dev, dev->mcast_31_0[i]);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_MCAST_ADD_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_mcast_mac_del()
+ *
+ *  For RxF "rxf_id", it deletes the multicast MAC specified by
+ *  "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to add
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_mac_del(struct bna_dev_s *dev, unsigned int rxf_id,
+		      const bna_mac_t *mac_addr_ptr)
+{
+	u32 mac_47_32, mac_31_0, i;
+	u8 *mac_ptr = (u8 *) mac_addr_ptr;
+	struct bfi_ll_mac_addr_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	mac_47_32 = (mac_ptr[0] << 8) | mac_ptr[1];
+	mac_31_0 = (mac_ptr[2] << 24) | (mac_ptr[3] << 16) |
+		(mac_ptr[4] << 8) | mac_ptr[5];
+
+	for (i = 0; i < BNA_MCAST_TABLE_SIZE; i++) {
+		if ((mac_47_32 == dev->mcast_47_32[i]) &&
+		    (mac_31_0 == dev->mcast_31_0[i])) {
+			/* existing entry found, stop and use it */
+			break;
+		}
+	}
+
+	if (i == BNA_MCAST_TABLE_SIZE) {
+		/* no existing entry found */
+		BNA_LOG_ERROR(("MAC 0x%x:%x not found\n", mac_47_32, mac_31_0));
+		return BNA_FAIL;
+	}
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_MCAST_DEL_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	bna_os_memcpy(&cmd.mac_addr, mac_addr_ptr, sizeof(cmd.mac_addr));
+
+	BNA_TRACE(dev, dev->mcast_47_32[i]);
+	BNA_TRACE(dev, dev->mcast_31_0[i]);
+
+	dev->mcast_47_32[i] = 0;
+	dev->mcast_31_0[i] = 0;
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+static void
+bna_mac_addr_to_string(u32 mac_47_32, u32 mac_31_0, bna_mac_t *mac)
+{
+	u8 *mac_ptr = (u8 *) mac;
+	int i;
+
+	for (i = 1; i >= 0; i--)
+		mac_ptr[1 - i] = ((mac_47_32) & (0xff << (i * 8))) >> (i * 8);
+
+	mac_ptr = &mac_ptr[2];
+	for (i = 3; i >= 0; i--)
+		mac_ptr[3 - i] = ((mac_31_0) & (0xff << (i * 8))) >> (i * 8);
+}
+
+/**
+ * bna_rxf_mcast_mac_set_list()
+ *
+ *  For RxF "rxf_id", it sets the multicast MAC addresses
+ *  specified by "mac_addr_ptr". The function first deletes the MAC addresses in
+ *  the existing list that is not found in the new list. It then adds the new
+ *  addresses that are in the new list but not in the old list. It then replaces
+ *  the old list with the new list in the bna_dev structure.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to the list of mac
+ *       adddresses to set
+ * @param[in]  mac_addr_num - number of mac addresses in the
+ *       list
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_mac_set_list(struct bna_dev_s *dev, unsigned int rxf_id,
+			   const bna_mac_t *mac_addr_ptr,
+			   unsigned int mac_addr_num)
+{
+	u32 *mcast_47_32 = &dev->tmp_mc_47_32[0];
+	u32 *mcast_31_0 = &dev->tmp_mc_31_0[0];
+	u32 i, j;
+	u8 *mac_ptr = (u8 *) mac_addr_ptr;
+	int found;
+	struct bfi_ll_mac_addr_req cmd;
+	bna_mac_t tmp_mac;
+
+	bna_os_memset(mcast_47_32, 0, sizeof(u32) * BNA_MCAST_TABLE_SIZE);
+	bna_os_memset(mcast_31_0, 0, sizeof(u32) * BNA_MCAST_TABLE_SIZE);
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+	if (mac_addr_num > BNA_MCAST_TABLE_SIZE) {
+		BNA_LOG_ERROR(("Too many Multicast Addresses [%d]\n",
+			       mac_addr_num));
+		return BNA_FAIL;
+	}
+
+	for (i = 0; i < mac_addr_num; i++) {
+		if (!BNA_MAC_IS_MULTICAST(mac_ptr[i * 6]))
+			return BNA_FAIL;
+		mcast_47_32[i] = (mac_ptr[i * 6] << 8) | mac_ptr[i * 6 + 1];
+		mcast_31_0[i] = (mac_ptr[i * 6 + 2] << 24) |
+			(mac_ptr[i * 6 + 3] << 16) |
+			(mac_ptr[i * 6 + 4] << 8) | mac_ptr[i * 6 + 5];
+		if ((mcast_47_32[i] == 0) && (mcast_31_0[i] == 0))
+			return BNA_FAIL;
+		BNA_LOG_DEBUG(("Multicast Addr %d : 0x%x:0x%x\n", i,
+			       mcast_47_32[i], mcast_31_0[i]));
+	}
+
+	/* find MAC addresses to delete */
+	for (i = 0; i < BNA_MCAST_TABLE_SIZE; i++) {
+		if ((dev->mcast_47_32[i] == 0) && (dev->mcast_31_0[i] == 0))
+			continue;
+
+		found = 0;
+		for (j = 0; j < mac_addr_num; j++) {
+			if ((mcast_47_32[j] == dev->mcast_47_32[i]) &&
+			    (mcast_31_0[j] == dev->mcast_31_0[i])) {
+				found = 1;
+				break;
+			}
+		}
+		if (!found) {
+			bfi_h2i_set(cmd.mh, BFI_MC_LL,
+				    BFI_LL_H2I_MAC_MCAST_DEL_REQ, 0);
+			cmd.rxf_id = rxf_id;
+			bna_mac_addr_to_string(dev->mcast_47_32[i],
+					       dev->mcast_31_0[i], &tmp_mac);
+			bna_os_memcpy(&cmd.mac_addr, &tmp_mac,
+				      sizeof(cmd.mac_addr));
+
+			BNA_LOG_INFO(("Deleting MCAST MAC 0x%x:0x%x on port %u RxF %u\n", dev->mcast_47_32[i], dev->mcast_31_0[i], dev->port, rxf_id));
+
+			BNA_TRACE(dev, dev->mcast_47_32[i]);
+			BNA_TRACE(dev, dev->mcast_31_0[i]);
+
+			if (BNA_FAIL ==
+			    bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg)) {
+				BNA_LOG_ERROR(("Failed to add to cmd [%d/%d] "
+					       "for RxF %d to Q.. Aborting\n",
+					       cmd.mh.msg_class, cmd.mh.msg_id,
+					       cmd.rxf_id));
+				return BNA_FAIL;
+			}
+		}
+	}
+
+	/* find MAC addresses to add */
+	for (i = 0; i < mac_addr_num; i++) {
+		found = 0;
+
+		for (j = 0; j < BNA_MCAST_TABLE_SIZE; j++) {
+			if ((mcast_47_32[i] == dev->mcast_47_32[j]) &&
+			    (mcast_31_0[i] == dev->mcast_31_0[j])) {
+				found = 1;
+				break;
+			}
+		}
+		if (!found) {
+			bfi_h2i_set(cmd.mh, BFI_MC_LL,
+				    BFI_LL_H2I_MAC_MCAST_ADD_REQ, 0);
+			cmd.rxf_id = rxf_id;
+			bna_mac_addr_to_string(mcast_47_32[i], mcast_31_0[i],
+					       &tmp_mac);
+			bna_os_memcpy(&cmd.mac_addr, &tmp_mac,
+				      sizeof(cmd.mac_addr));
+
+			BNA_LOG_INFO(("Adding MCAST MAC 0x%x:0x%x on port %u RxF %u\n", mcast_47_32[i], mcast_31_0[i], dev->port, rxf_id));
+
+			BNA_TRACE(dev, mcast_47_32[i]);
+			BNA_TRACE(dev, mcast_31_0[i]);
+
+			if (BNA_FAIL ==
+			    bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg)) {
+				BNA_LOG_ERROR(("Failed to add to cmd [%d/%d] "
+					       "for RxF %d to Q.. Aborting\n",
+					       cmd.mh.msg_class, cmd.mh.msg_id,
+					       cmd.rxf_id));
+				return BNA_FAIL;
+			}
+		}
+	}
+
+	bna_os_memset(&dev->mcast_47_32[0], 0,
+		      sizeof(u32) * BNA_MCAST_TABLE_SIZE);
+	bna_os_memset(&dev->mcast_31_0[0], 0,
+		      sizeof(u32) * BNA_MCAST_TABLE_SIZE);
+
+	bna_os_memcpy(&dev->mcast_47_32[0], &mcast_47_32[0],
+		      sizeof(u32) * mac_addr_num);
+	bna_os_memcpy(&dev->mcast_31_0[0], &mcast_31_0[0],
+		      sizeof(u32) * mac_addr_num);
+
+	return BNA_OK;
+}
+
+/**
+ * bna_mcast_mac_reset_list()
+ *
+ *  Resets the multicast MAC address list kept by driver.
+ *  Called when the hw gets reset.
+ *
+ * @param[in]  dev  - pointer to BNA device structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_mcast_mac_reset_list(struct bna_dev_s *dev)
+{
+
+	bna_os_memset(&dev->mcast_47_32[0], 0,
+		      sizeof(u32) * BNA_MCAST_TABLE_SIZE);
+	bna_os_memset(&dev->mcast_31_0[0], 0,
+		      sizeof(u32) * BNA_MCAST_TABLE_SIZE);
+}
+
+/**
+ *  bna_rxf_broadcast()
+ *
+ *  For RxF "rxf_id", it enables/disables the broadcast address.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable broadcast address
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_broadcast(struct bna_dev_s *dev, unsigned int rxf_id,
+		  enum bna_enable_e enable)
+{
+	const bna_mac_t broadcast_addr = { 0xff, 0xff, 0xff, 0xff, 0xff, 0xff };
+
+	if (enable)
+		return (bna_rxf_mcast_mac_add(dev, rxf_id, &broadcast_addr));
+
+	return (bna_rxf_mcast_mac_del(dev, rxf_id, &broadcast_addr));
+}
+
+/**
+ *  bna_rxf_vlan_add()
+ *
+ *  For RxF "rxf_id", it adds this function as a member of the
+ *  specified "vlan_id".
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  vlan_id - VLAN id to be added
+ *
+ * @return void
+ */
+void
+bna_rxf_vlan_add(struct bna_dev_s *dev, unsigned int rxf_id,
+		 unsigned int vlan_id)
+{
+
+	u32 new_vlan_id;
+
+	BNA_ASSERT((rxf_id <= BNA_RXF_ID_MAX));
+	BNA_TRACE(dev, vlan_id);
+	/*
+	 * wrap the vlan_id around in case it
+	 * overflows the max limit
+	 */
+	new_vlan_id = vlan_id & BNA_VLAN_ID_MAX;
+	BNA_BIT_TABLE_SET(dev->vlan_table[rxf_id], new_vlan_id);
+
+	if (dev->vlan_filter_enable[rxf_id] &&
+	    (dev->rxf_active & ((u64) 1 << rxf_id))) {
+		/* add VLAN ID on this function */
+		bna_reg_write(dev->regs.page_addr,
+			      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+					       (dev->port * 2),
+					       VLAN_RAM_BASE_OFFSET));
+		bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR
+			       (dev->bar0, rxf_id, new_vlan_id),
+			       dev->vlan_table[rxf_id][new_vlan_id / 32]);
+	}
+}
+
+/**
+ *  bna_rxf_vlan_del()
+ *
+ *  For RxF "rxf_id", it removes this function as a member of the
+ *  specified "vlan_id".
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  vlan_id - VLAN id to be removed
+ *
+ * @return void
+ */
+void
+bna_rxf_vlan_del(struct bna_dev_s *dev, unsigned int rxf_id,
+		 unsigned int vlan_id)
+{
+
+	u32 new_vlan_id;
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	BNA_TRACE(dev, vlan_id);
+	new_vlan_id = vlan_id & BNA_VLAN_ID_MAX;
+	BNA_BIT_TABLE_CLEAR(dev->vlan_table[rxf_id], new_vlan_id);
+
+	if (dev->vlan_filter_enable[rxf_id]
+	    && (dev->rxf_active & ((u64) 1 << rxf_id))) {
+		bna_reg_write(dev->regs.page_addr,
+			      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+					       (dev->port * 2),
+					       VLAN_RAM_BASE_OFFSET));
+		bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR
+			       (dev->bar0, rxf_id, new_vlan_id),
+			       dev->vlan_table[rxf_id][new_vlan_id / 32]);
+	}
+}
+
+/**
+ *  bna_rxf_vlan_filter()
+ *
+ *   For RxF "rxf_id", it enables/disables the VLAN filter.
+ *   Disabling the VLAN Filter allows reception of any VLAN-tagged frame.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable VLAN Filtering.
+ *
+ * @return void
+ */
+void
+bna_rxf_vlan_filter(struct bna_dev_s *dev, unsigned int rxf_id,
+		    enum bna_enable_e enable)
+{
+	u32 i;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	dev->vlan_filter_enable[rxf_id] = enable;
+
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2), VLAN_RAM_BASE_OFFSET));
+
+	if (enable) {
+		/* enable VLAN filtering on this function */
+		for (i = 0; i <= BNA_VLAN_ID_MAX / 32; i++) {
+			bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR(dev->bar0,
+								   rxf_id,
+								   i * 32),
+				       dev->vlan_table[rxf_id][i]);
+		}
+	} else {
+		/* disable VLAN filtering on this function */
+		for (i = 0; i <= BNA_VLAN_ID_MAX / 32; i++) {
+			bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR(dev->bar0,
+								   rxf_id,
+								   i * 32),
+				       0xffffffff);
+		}
+	}
+}
+
+/**
+ * bna_rxf_vlan_del_all()
+ *
+ *   For RxF "rxf_id", it clears all the VLANs.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ *
+ * @return void
+ */
+void
+bna_rxf_vlan_del_all(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	u32 i;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2), VLAN_RAM_BASE_OFFSET));
+
+	/* clear all VLANs for this function */
+	for (i = 0; i <= BNA_VLAN_ID_MAX / 32; i++) {
+		bna_mem_writew(BNA_GET_VLAN_MEM_ENTRY_ADDR
+			       (dev->bar0, rxf_id, i * 32), 0);
+	}
+}
+
+
+/**
+ *  bna_rxf_mcast_filter()
+ *
+ *   For RxF "rxf_id", it enables/disables the multicast filter.
+ *   Disabling the multicast filter allows reception of any
+ *   multicast frame.
+ *
+ * @param[in]  dev      - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable multicast Filtering.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_filter(struct bna_dev_s *dev, unsigned int rxf_id,
+		     enum bna_enable_e enable)
+{
+
+	struct bfi_ll_mcast_filter_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_MCAST_FILTER_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	cmd.enable = enable;
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_mcast_del_all()
+ *
+ *   For RxF "rxf_id", it clears the MCAST cam and MVT.
+ *   This functionality is required by some of the drivers.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_mcast_del_all(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bfi_ll_mcast_del_all_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_MAC_MCAST_DEL_ALL_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ *  bna_rxf_promiscuous()
+ *
+ *  For RxF "rxf_id", it enables/disables promiscuous mode.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable promiscious mode
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_promiscuous(struct bna_dev_s *dev, unsigned int rxf_id,
+		    enum bna_enable_e enable)
+{
+	struct bfi_ll_rxf_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	BNA_TRACE(dev, dev->port);
+	BNA_TRACE(dev, rxf_id);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_RXF_PROMISCUOUS_SET_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	cmd.enable = enable;
+
+
+	/*
+	 * Need to revisit.
+	 * Can the second check be an ASSERT ?
+	 */
+	if (enable && (dev->rxf_promiscuous_id == BNA_RXF_ID_NONE)) {
+		dev->rxf_promiscuous_id = rxf_id;
+
+		/* allow all VLANs */
+		bna_rxf_vlan_filter(dev, rxf_id, BNA_DISABLE);
+
+		return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+	} else if (!enable && (dev->rxf_promiscuous_id == rxf_id)) {
+		dev->rxf_promiscuous_id = BNA_RXF_ID_NONE;
+
+		/* Revert VLAN filtering */
+		bna_rxf_vlan_filter(dev, rxf_id,
+				    dev->vlan_filter_enable[rxf_id]);
+
+		return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+	}
+
+	return (BNA_FAIL);
+}
+
+/**
+ *  bna_rxf_default_mode()
+ *
+ *  For RxF "rxf_id", it enables/disables default mode.
+ *  Must be called after the RxF has been configured.
+ *  Must remove all unicast MAC associated to this RxF.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable default mode
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_default_mode(struct bna_dev_s *dev, unsigned int rxf_id,
+		     enum bna_enable_e enable)
+{
+	struct bna_rx_fndb_ram *rx_fndb_ram;
+	u32 i, ctl_flags;
+	struct bfi_ll_rxf_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	BNA_TRACE(dev, dev->port);
+	BNA_TRACE(dev, rxf_id);
+
+	rx_fndb_ram = (struct bna_rx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, RX_FNDB_RAM_BASE_OFFSET);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_RXF_DEFAULT_SET_REQ, 0);
+
+	cmd.rxf_id = rxf_id;
+	cmd.enable = enable;
+
+	/*
+	 * Need to revisit.
+	 * Can the second check be an ASSERT ?
+	 */
+	if (enable && (dev->rxf_default_id == BNA_RXF_ID_NONE)) {
+		dev->rxf_default_id = rxf_id;
+
+		/* allow all VLANs */
+		bna_rxf_vlan_filter(dev, rxf_id, BNA_DISABLE);
+
+		bna_reg_write(dev->regs.page_addr,
+			      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+					       (dev->port * 2),
+					       RX_FNDB_RAM_BASE_OFFSET));
+
+		for (i = 0; i < BNA_RXF_ID_MAX; i++) {
+			if (i == rxf_id)
+				continue;
+
+			ctl_flags =
+				bna_mem_readw(&rx_fndb_ram[i].control_flags);
+			ctl_flags |= BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE;
+			bna_mem_writew(&rx_fndb_ram[i].control_flags,
+				       ctl_flags);
+		}
+		return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+	} else if (!enable && (dev->rxf_default_id == rxf_id)) {
+		dev->rxf_default_id = BNA_RXF_ID_NONE;
+
+		/* Revert  VLAN filtering */
+		bna_rxf_vlan_filter(dev, rxf_id,
+				    dev->vlan_filter_enable[rxf_id]);
+
+		bna_reg_write(dev->regs.page_addr,
+			      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+					       (dev->port * 2),
+					       RX_FNDB_RAM_BASE_OFFSET));
+
+		for (i = 0; i < BNA_RXF_ID_MAX; i++) {
+			ctl_flags =
+				bna_mem_readw(&rx_fndb_ram[i].control_flags);
+			ctl_flags &= ~BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE;
+			bna_mem_writew(&rx_fndb_ram[i].control_flags,
+				       ctl_flags);
+		}
+		return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+	}
+
+	return (BNA_FAIL);
+}
+
+/**
+ *  bna_rxf_frame_stats_get()
+ *
+ *  For RxF "rxf_id", it loads frame statistics into "stats_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[out]  stats_ptr - pointer to stats structure to fill
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_rxf_frame_stats_get(struct bna_dev_s *dev, unsigned int rxf_id,
+			struct bna_stats_rxf **stats_ptr)
+{
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	*stats_ptr = &dev->stats.rxf_stats[rxf_id];
+}
+
+/**
+ * bna_txf_frame_stats_get()
+ *
+ *   For TxF "txf_id", it loads frame statistics into "stats_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id    - tx-function ID.
+ * @param[out] stats_ptr - pointer to tx-function statistics.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_txf_frame_stats_get(struct bna_dev_s *dev, unsigned int txf_id,
+			struct bna_stats_txf **stats_ptr)
+{
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	*stats_ptr = &dev->stats.txf_stats[txf_id];
+}
+
+/**
+ *  bna_mac_rx_stats_get()
+ *
+ *  Loads MAC Rx statistics into "stats_ptr".
+ *
+ * @param[in]  dev       - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure to fill
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_mac_rx_stats_get(struct bna_dev_s *dev, struct cna_stats_mac_rx **stats_ptr)
+{
+	*stats_ptr = &dev->stats.mac_rx_stats;
+}
+
+/**
+ *  bna_mac_tx_stats_get()
+ *
+ *  Loads MAC Tx statistics into "stats_ptr".
+ *
+ * @param[in]  dev       - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure to fill
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void
+bna_mac_tx_stats_get(struct bna_dev_s *dev, struct cna_stats_mac_tx **stats_ptr)
+{
+	*stats_ptr = &dev->stats.mac_tx_stats;
+}
+
+/**
+ *  bna_all_stats_get()
+ *
+ *  Loads all statistics into "stats_ptr".
+ *
+ * @param[in]  dev       - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure
+ *
+ * @return void
+ */
+void
+bna_all_stats_get(struct bna_dev_s *dev, struct bna_stats **stats_ptr)
+{
+	*stats_ptr = &dev->stats;
+}
+
+/**
+ * bna_stats_get()
+ *
+ *   Get the statistics from the device. This function needs to
+ *   be scheduled every second to get periodic update of the
+ *   statistics data from hardware.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_stats_get(struct bna_dev_s *dev)
+{
+	struct bfi_ll_stats_req cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_STATS_GET_REQ, 0);
+
+	cmd.stats_mask = bna_os_htons(BFI_LL_STATS_ALL);
+	cmd.rxf_id_mask[0] = bna_os_htonl((u32) (dev->rxf_active & 0xffffffff));
+	cmd.rxf_id_mask[1] = bna_os_htonl((u32) (dev->rxf_active >> 32));
+
+	cmd.txf_id_mask[0] = bna_os_htonl((u32) (dev->txf_active & 0xffffffff));
+	cmd.txf_id_mask[1] = bna_os_htonl((u32) (dev->txf_active >> 32));
+
+	cmd.host_buffer.a32.addr_hi = dev->hw_stats_dma.msb;
+	cmd.host_buffer.a32.addr_lo = dev->hw_stats_dma.lsb;
+
+	dev->rxf_active_last = dev->rxf_active;
+	dev->txf_active_last = dev->txf_active;
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_stats_clear()
+ *
+ *   Clear the statistics in the device.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_stats_clear(struct bna_dev_s *dev)
+{
+	struct bfi_ll_stats_req cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_STATS_CLEAR_REQ, 0);
+
+	cmd.stats_mask = bna_os_htons(BFI_LL_STATS_ALL);
+	cmd.rxf_id_mask[0] = bna_os_htonl((u32) (dev->rxf_active & 0xffffffff));
+	cmd.rxf_id_mask[1] = bna_os_htonl((u32) (dev->rxf_active >> 32));
+
+	cmd.txf_id_mask[0] = bna_os_htonl((u32) (dev->txf_active & 0xffffffff));
+	cmd.txf_id_mask[1] = bna_os_htonl((u32) (dev->txf_active >> 32));
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_rxf_stats_clear()
+ *
+ *   Clear the statistics for specified txf.
+ *
+ * @param[in]   dev        - pointer to BNA device structure.
+ * @param[in]  rxf_id      - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_rxf_stats_clear(struct bna_dev_s *dev, unsigned int rxf_id)
+{
+	struct bfi_ll_stats_req cmd;
+
+	BNA_ASSERT(rxf_id < BNA_RXF_ID_MAX);
+
+	bfi_h2i_set(cmd.mh, BFI_MC_LL, BFI_LL_H2I_STATS_CLEAR_REQ, 0);
+
+	cmd.stats_mask = 0;
+
+	if (rxf_id < 32) {
+		cmd.rxf_id_mask[0] = bna_os_htonl((u32) (1 << rxf_id));
+		cmd.rxf_id_mask[1] = 0;
+	} else {
+		cmd.rxf_id_mask[0] = 0;
+		cmd.rxf_id_mask[1] = bna_os_htonl((u32) (1 << (rxf_id - 32)));
+	}
+
+	cmd.txf_id_mask[0] = 0;
+	cmd.txf_id_mask[1] = 0;
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_lldp_stats_clear()
+ *
+ *   Clear the DCBCX-LLDP statistics in the f/w.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_lldp_stats_clear(struct bna_dev_s *dev)
+{
+	struct bfi_lldp_reset_stats_s cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_CEE, BFI_CEE_H2I_RESET_STATS, 0);
+
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_get_cfg_req()
+ *
+ *   Request to get the LLDP-DCBCX Config.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ * @param[in]   dma_ddr   - dma address in "bna_dma_addr_t" format.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_get_cfg_req(struct bna_dev_s *dev, struct bna_dma_addr *dma_addr)
+{
+	struct bfi_cee_get_req_s cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_CEE, BFI_CEE_H2I_GET_CFG_REQ, 0);
+	cmd.dma_addr.a32.addr_lo = dma_addr->lsb;
+	cmd.dma_addr.a32.addr_hi = dma_addr->msb;
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_get_cee_stats_req()
+ *
+ *   Request to get the LLDP-DCBCX stats.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ * @param[in]   dma_ddr   - dma address in "bna_dma_addr_t" format.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+bna_get_cee_stats_req(struct bna_dev_s *dev, struct bna_dma_addr *dma_addr)
+{
+	struct bfi_cee_get_req_s cmd;
+
+	bfi_h2i_set(cmd.mh, BFI_MC_CEE, BFI_CEE_H2I_GET_STATS_REQ, 0);
+	cmd.dma_addr.a32.addr_lo = dma_addr->lsb;
+	cmd.dma_addr.a32.addr_hi = dma_addr->msb;
+	/* send command to firmware */
+	return bna_mbox_send(dev, &cmd, sizeof(cmd), dev->cbarg);
+}
+
+/**
+ * bna_stats_process()
+ *
+ *   Process the statistics data DMAed from the device. This
+ *   function needs to be scheduled upon getting an asynchronous
+ *   notification from the firmware.
+ *
+ * @param[in]   dev       - pointer to BNA device structure.
+ *
+ * @return void
+ */
+void
+bna_stats_process(struct bna_dev_s *dev)
+{
+#if 1
+	u32 i, j;
+	struct bna_stats_rxf *rxf_hw_stats;
+	struct bna_stats_txf *txf_hw_stats;
+
+	dev->stats.fc_tx_stats.txf_ucast_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.
+				      txf_ucast_octets);
+	dev->stats.fc_tx_stats.txf_ucast =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.txf_ucast);
+	dev->stats.fc_tx_stats.txf_ucast_vlan =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.
+				      txf_ucast_vlan);
+
+	dev->stats.fc_tx_stats.txf_mcast_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.
+				      txf_mcast_octets);
+	dev->stats.fc_tx_stats.txf_mcast =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.txf_mcast);
+	dev->stats.fc_tx_stats.txf_mcast_vlan =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.
+				      txf_mcast_vlan);
+
+	dev->stats.fc_tx_stats.txf_bcast_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.
+				      txf_bcast_octets);
+	dev->stats.fc_tx_stats.txf_bcast =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.txf_bcast);
+	dev->stats.fc_tx_stats.txf_bcast_vlan =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.
+				      txf_bcast_vlan);
+
+	dev->stats.fc_tx_stats.txf_parity_errors =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.
+				      txf_parity_errors);
+	dev->stats.fc_tx_stats.txf_timeout =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.txf_timeout);
+	dev->stats.fc_tx_stats.txf_fid_parity_errors =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_tx_stats.
+				      txf_fid_parity_errors);
+
+	for (i = 0; i < 8; i++) {
+		dev->stats.bpc_tx_stats.tx_pause[i] =
+			bna_hw_stats_to_stats(dev->hw_stats->bpc_stats.
+					      tx_pause[i]);
+		dev->stats.bpc_tx_stats.tx_zero_pause[i] =
+			bna_hw_stats_to_stats(dev->hw_stats->bpc_stats.
+					      tx_zero_pause[i]);
+		dev->stats.bpc_tx_stats.tx_first_pause[i] =
+			bna_hw_stats_to_stats(dev->hw_stats->bpc_stats.
+					      tx_first_pause[i]);
+	}
+
+	dev->stats.mac_tx_stats.tx_bytes =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_bytes);
+	dev->stats.mac_tx_stats.tx_packets =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_packets);
+	dev->stats.mac_tx_stats.tx_multicast =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_multicast);
+	dev->stats.mac_tx_stats.tx_broadcast =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_broadcast);
+	dev->stats.mac_tx_stats.tx_pause =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_pause);
+	dev->stats.mac_tx_stats.tx_deferral =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_deferral);
+	dev->stats.mac_tx_stats.tx_excessive_deferral =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      tx_excessive_deferral);
+	dev->stats.mac_tx_stats.tx_single_collision =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      tx_single_collision);
+	dev->stats.mac_tx_stats.tx_muliple_collision =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      tx_muliple_collision);
+	dev->stats.mac_tx_stats.tx_late_collision =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      tx_late_collision);
+	dev->stats.mac_tx_stats.tx_excessive_collision =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      tx_excessive_collision);
+	dev->stats.mac_tx_stats.tx_total_collision =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      tx_total_collision);
+	dev->stats.mac_tx_stats.tx_pause_honored =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      tx_pause_honored);
+	dev->stats.mac_tx_stats.tx_drop =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_drop);
+	dev->stats.mac_tx_stats.tx_jabber =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_jabber);
+	dev->stats.mac_tx_stats.tx_fcs_error =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_fcs_error);
+	dev->stats.mac_tx_stats.tx_control_frame =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      tx_control_frame);
+	dev->stats.mac_tx_stats.tx_oversize =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_oversize);
+	dev->stats.mac_tx_stats.tx_undersize =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_undersize);
+	dev->stats.mac_tx_stats.tx_fragments =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.tx_fragments);
+
+	dev->stats.fc_rx_stats.rxf_ucast_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_rx_stats.
+				      rxf_ucast_octets);
+	dev->stats.fc_rx_stats.rxf_ucast =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_rx_stats.rxf_ucast);
+	dev->stats.fc_rx_stats.rxf_ucast_vlan =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_rx_stats.
+				      rxf_ucast_vlan);
+
+	dev->stats.fc_rx_stats.rxf_mcast_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_rx_stats.
+				      rxf_mcast_octets);
+	dev->stats.fc_rx_stats.rxf_mcast =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_rx_stats.rxf_mcast);
+	dev->stats.fc_rx_stats.rxf_mcast_vlan =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_rx_stats.
+				      rxf_mcast_vlan);
+
+	dev->stats.fc_rx_stats.rxf_bcast_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_rx_stats.
+				      rxf_bcast_octets);
+	dev->stats.fc_rx_stats.rxf_bcast =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_rx_stats.rxf_bcast);
+	dev->stats.fc_rx_stats.rxf_bcast_vlan =
+		bna_hw_stats_to_stats(dev->hw_stats->fc_rx_stats.
+				      rxf_bcast_vlan);
+
+	for (i = 0; i < 8; i++) {
+		dev->stats.bpc_rx_stats.rx_pause[i] =
+			bna_hw_stats_to_stats(dev->hw_stats->bpc_stats.
+					      rx_pause[i]);
+		dev->stats.bpc_rx_stats.rx_zero_pause[i] =
+			bna_hw_stats_to_stats(dev->hw_stats->bpc_stats.
+					      rx_zero_pause[i]);
+		dev->stats.bpc_rx_stats.rx_first_pause[i] =
+			bna_hw_stats_to_stats(dev->hw_stats->bpc_stats.
+					      rx_first_pause[i]);
+	}
+
+	dev->stats.rad_stats.rx_frames =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_frames);
+	dev->stats.rad_stats.rx_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_octets);
+	dev->stats.rad_stats.rx_vlan_frames =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_vlan_frames);
+
+	dev->stats.rad_stats.rx_ucast =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_ucast);
+	dev->stats.rad_stats.rx_ucast_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_ucast_octets);
+	dev->stats.rad_stats.rx_ucast_vlan =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_ucast_vlan);
+
+	dev->stats.rad_stats.rx_mcast =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_mcast);
+	dev->stats.rad_stats.rx_mcast_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_mcast_octets);
+	dev->stats.rad_stats.rx_mcast_vlan =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_mcast_vlan);
+
+	dev->stats.rad_stats.rx_bcast =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_bcast);
+	dev->stats.rad_stats.rx_bcast_octets =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_bcast_octets);
+	dev->stats.rad_stats.rx_bcast_vlan =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_bcast_vlan);
+
+	dev->stats.rad_stats.rx_drops =
+		bna_hw_stats_to_stats(dev->hw_stats->rad_stats.rx_drops);
+
+	dev->stats.mac_rx_stats.frame_64 =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.frame_64);
+	dev->stats.mac_rx_stats.frame_65_127 =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.frame_65_127);
+	dev->stats.mac_rx_stats.frame_128_255 =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.frame_128_255);
+	dev->stats.mac_rx_stats.frame_256_511 =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.frame_256_511);
+	dev->stats.mac_rx_stats.frame_512_1023 =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.frame_512_1023);
+	dev->stats.mac_rx_stats.frame_1024_1518 =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.frame_1024_1518);
+	dev->stats.mac_rx_stats.frame_1518_1522 =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.frame_1519_1522);
+	dev->stats.mac_rx_stats.rx_bytes =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_bytes);
+	dev->stats.mac_rx_stats.rx_packets =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_packets);
+	dev->stats.mac_rx_stats.rx_fcs_error =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_fcs_error);
+	dev->stats.mac_rx_stats.rx_multicast =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_multicast);
+	dev->stats.mac_rx_stats.rx_broadcast =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_broadcast);
+	dev->stats.mac_rx_stats.rx_control_frames =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      rx_control_frames);
+	dev->stats.mac_rx_stats.rx_pause =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_pause);
+	dev->stats.mac_rx_stats.rx_unknown_opcode =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      rx_unknown_opcode);
+	dev->stats.mac_rx_stats.rx_alignment_error =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      rx_alignment_error);
+	dev->stats.mac_rx_stats.rx_frame_length_error =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      rx_frame_length_error);
+	dev->stats.mac_rx_stats.rx_code_error =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_code_error);
+	dev->stats.mac_rx_stats.rx_carrier_sense_error =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.
+				      rx_carrier_sense_error);
+	dev->stats.mac_rx_stats.rx_undersize =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_undersize);
+	dev->stats.mac_rx_stats.rx_oversize =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_oversize);
+	dev->stats.mac_rx_stats.rx_fragments =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_jabber);
+	dev->stats.mac_rx_stats.rx_jabber =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_jabber);
+	dev->stats.mac_rx_stats.rx_drop =
+		bna_hw_stats_to_stats(dev->hw_stats->mac_stats.rx_drop);
+
+	rxf_hw_stats = (struct bna_stats_rxf *) &dev->hw_stats->rxf_stats[0];
+	j = 0;
+
+	for (i = 0; i < BNA_RXF_ID_MAX; i++) {
+		if (dev->rxf_active_last & ((u64) 1 << i)) {
+			dev->stats.rxf_stats[i].ucast_octets =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].
+						      ucast_octets);
+			dev->stats.rxf_stats[i].ucast =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].ucast);
+			dev->stats.rxf_stats[i].ucast_vlan =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].
+						      ucast_vlan);
+
+			dev->stats.rxf_stats[i].mcast_octets =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].
+						      mcast_octets);
+			dev->stats.rxf_stats[i].mcast =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].mcast);
+			dev->stats.rxf_stats[i].mcast_vlan =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].
+						      mcast_vlan);
+
+			dev->stats.rxf_stats[i].bcast_octets =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].
+						      bcast_octets);
+			dev->stats.rxf_stats[i].bcast =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].bcast);
+			dev->stats.rxf_stats[i].bcast_vlan =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].
+						      bcast_vlan);
+
+			dev->stats.rxf_stats[i].frame_drops =
+				bna_hw_stats_to_stats(rxf_hw_stats[j].
+						      frame_drops);
+
+			j++;
+		}
+	}
+
+	txf_hw_stats = (struct bna_stats_txf *) &rxf_hw_stats[j];
+	j = 0;
+
+	for (i = 0; i < BNA_TXF_ID_MAX; i++) {
+		if (dev->txf_active_last & ((u64) 1 << i)) {
+			dev->stats.txf_stats[i].ucast_octets =
+				bna_hw_stats_to_stats(txf_hw_stats[j].
+						      ucast_octets);
+			dev->stats.txf_stats[i].ucast =
+				bna_hw_stats_to_stats(txf_hw_stats[j].ucast);
+			dev->stats.txf_stats[i].ucast_vlan =
+				bna_hw_stats_to_stats(txf_hw_stats[j].
+						      ucast_vlan);
+
+			dev->stats.txf_stats[i].mcast_octets =
+				bna_hw_stats_to_stats(txf_hw_stats[j].
+						      mcast_octets);
+			dev->stats.txf_stats[i].mcast =
+				bna_hw_stats_to_stats(txf_hw_stats[j].mcast);
+			dev->stats.txf_stats[i].mcast_vlan =
+				bna_hw_stats_to_stats(txf_hw_stats[j].
+						      mcast_vlan);
+
+			dev->stats.txf_stats[i].bcast_octets =
+				bna_hw_stats_to_stats(txf_hw_stats[j].
+						      bcast_octets);
+			dev->stats.txf_stats[i].bcast =
+				bna_hw_stats_to_stats(txf_hw_stats[j].bcast);
+			dev->stats.txf_stats[i].bcast_vlan =
+				bna_hw_stats_to_stats(txf_hw_stats[j].
+						      bcast_vlan);
+
+			dev->stats.txf_stats[i].errors =
+				bna_hw_stats_to_stats(txf_hw_stats[j].errors);
+			dev->stats.txf_stats[i].filter_vlan =
+				bna_hw_stats_to_stats(txf_hw_stats[j].
+						      filter_vlan);
+			dev->stats.txf_stats[i].filter_mac_sa =
+				bna_hw_stats_to_stats(txf_hw_stats[j].
+						      filter_mac_sa);
+
+			j++;
+		}
+	}
+#else
+	u64 *p_stats = (u64 *) &dev->stats;
+	u64 *p_hw_stats = (u64 *) &dev->hw_stats;
+	int i;
+
+	for (i = 0; i < sizeof(dev->stats) / sizeof(u64); i++) {
+		p_stats[i] = bna_hw_stats_to_stats(p_hw_stats[i]);
+	}
+#endif
+}
+
+/**
+ * bna_txf_config_set()
+ *
+ *   For TxF "txf_id", it configures the TxF specified by "cfg_ptr" and
+ *   indicates to the statistics collector to collect statistics for this
+ *   Tx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id  - tx-function ID.
+ * @param[in]  cfg_ptr - pointer to tx-function configuration.
+ *
+ * @return void
+ */
+void
+bna_txf_config_set(struct bna_dev_s *dev, unsigned int txf_id,
+		   const struct bna_txf_config *cfg_ptr)
+{
+
+	struct bna_tx_fndb_ram *tx_fndb;
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	tx_fndb = (struct bna_tx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, TX_FNDB_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2),
+				       TX_FNDB_RAM_BASE_OFFSET));
+
+	bna_mem_writew(&tx_fndb[txf_id],
+		       (cfg_ptr->vlan << 16) | cfg_ptr->flags);
+
+	/* turn on statistics collection */
+	dev->txf_active |= ((u64) 1 << txf_id);
+}
+
+/**
+ * bna_txf_config_clear()
+ *
+ *   For TxF "txf_id", it clears its configuration and indicates to the
+ *   statistics collector to stop collecting statistics for this
+ *   Tx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id  - tx-function ID.
+ *
+ * @return void
+ */
+void
+bna_txf_config_clear(struct bna_dev_s *dev, unsigned int txf_id)
+{
+
+	struct bna_tx_fndb_ram *tx_fndb;
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	tx_fndb = (struct bna_tx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, TX_FNDB_RAM_BASE_OFFSET);
+
+	bna_reg_write(dev->regs.page_addr,
+		      BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				       (dev->port * 2),
+				       TX_FNDB_RAM_BASE_OFFSET));
+
+	bna_mem_writew(&tx_fndb[txf_id], 0);
+
+	/* turn off statistics collection */
+	dev->txf_active &= ~((u64) 1 << txf_id);
+}
+
+/**
+ * bna_txf_disable()
+ *
+ *  Disables the Tx Function without clearing the configuration
+ *  Also disables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA device handle
+ * @param[in] txf_id    - Id of the Tx Function to be disabled
+ *
+ * @return void
+ */
+void
+bna_txf_disable(struct bna_dev_s *dev, unsigned int txf_id)
+{
+	struct bna_tx_fndb_ram *tx_fndb;
+	u32 page_num, ctl_flags;
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	tx_fndb = (struct bna_tx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, TX_FNDB_RAM_BASE_OFFSET);
+
+	/* Write the page number register */
+	page_num =
+		BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM + (dev->port * 2),
+				 TX_FNDB_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, page_num);
+
+	ctl_flags = bna_mem_readw(&tx_fndb[txf_id].vlan_n_ctrl_flags);
+
+	ctl_flags &= ~BNA_TXF_CF_ENABLE;
+
+	bna_mem_writew(&tx_fndb[txf_id].vlan_n_ctrl_flags, ctl_flags);
+
+	/* turn off statistics collection */
+	dev->txf_active &= ~((u64) 1 << txf_id);
+}
+
+/**
+ * bna_txf_enable()
+ *
+ *  Enables the Tx Function without reconfiguring.
+ *  Also disables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA device handle
+ * @param[in] txf_id    - Id of the Tx Function to be disabled
+ *
+ * @return void
+ */
+void
+bna_txf_enable(struct bna_dev_s *dev, unsigned int txf_id)
+{
+	struct bna_tx_fndb_ram *tx_fndb;
+	u32 page_num, ctl_flags;
+
+	BNA_ASSERT(txf_id < BNA_TXF_ID_MAX);
+
+	tx_fndb = (struct bna_tx_fndb_ram *)
+		BNA_GET_MEM_BASE_ADDR(dev->bar0, TX_FNDB_RAM_BASE_OFFSET);
+
+	/* Write the page number register */
+	page_num = BNA_GET_PAGE_NUM(LUT0_MEM_BLK_BASE_PG_NUM +
+				    (dev->port * 2), TX_FNDB_RAM_BASE_OFFSET);
+	bna_reg_write(dev->regs.page_addr, page_num);
+
+	ctl_flags = bna_mem_readw(&tx_fndb[txf_id].vlan_n_ctrl_flags);
+
+	ctl_flags |= BNA_TXF_CF_ENABLE;
+
+	bna_mem_writew(&tx_fndb[txf_id].vlan_n_ctrl_flags, ctl_flags);
+
+	/* turn on statistics collection */
+	dev->txf_active |= ((u64) 1 << txf_id);
+}
+
+/**
+ * bna_set_pause_config()
+ *
+ *   Enable/disable Tx/Rx pause through F/W
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[in]   pause 	  - pointer to struct bna_pause_config
+ *
+ * @return BNA_OK in case of success BNA_FAIL otherwise.
+ */
+enum bna_status_e
+bna_set_pause_config(struct bna_dev_s *dev, struct bna_pause_config *pause,
+		     void *cbarg)
+{
+	struct bfi_ll_set_pause_req ll_req;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_SET_PAUSE_REQ, 0);
+
+	ll_req.tx_pause = pause->tx_pause;
+	ll_req.rx_pause = pause->rx_pause;
+
+	BNA_TRACE_INFO(dev, dev->port, ("Port %d tx_pause %d rx_pause %d\n",
+					dev->port, ll_req.tx_pause,
+					ll_req.rx_pause));
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), cbarg);
+}
+
+/**
+ * bna_mtu_info()
+ *
+ *   Send MTU information to F/W.
+ *   This is required to do PAUSE efficiently.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[in]   mtu	  - current mtu size
+ * @param[in]   cbarg	  - argument for the callback function
+ *
+ * @return BNA_OK in case of success BNA_FAIL otherwise.
+ */
+enum bna_status_e
+bna_mtu_info(struct bna_dev_s *dev, u16 mtu, void *cbarg)
+{
+	struct bfi_ll_mtu_info_req ll_req;
+
+	bfi_h2i_set(ll_req.mh, BFI_MC_LL, BFI_LL_H2I_MTU_INFO_REQ, 0);
+	ll_req.mtu = bna_os_htons(mtu);
+
+	BNA_TRACE_INFO(dev, dev->port, ("Port %d MTU %d\n", dev->port, mtu));
+
+	/* send to f/w */
+	return bna_mbox_send(dev, &ll_req, sizeof(ll_req), cbarg);
+}
+
+
+#ifdef BNA_DYN_INTR_MOD
+/* Currently we assume just 2 columns, col 0 = small, col 1 = large */
+#ifdef BNAD_NAPI
+u32 intr_mod_vector[BNA_LOAD_TYPES + 1][BNA_BIAS_TYPES] = {
+	{12, 12}
+	,
+	{6, 10}
+	,
+	{5, 10}
+	,
+	{4, 8}
+	,
+	{3, 6}
+	,
+	{3, 6}
+	,
+	{2, 4}
+	,
+	{1, 2}
+	,
+};
+#else
+u32 intr_mod_vector[BNA_LOAD_TYPES + 1][BNA_BIAS_TYPES] = {
+	{12, 20}
+	,
+	{10, 18}
+	,
+	{8, 16}
+	,
+	{6, 12}
+	,
+	{4, 8}
+	,
+	{3, 6}
+	,
+	{2, 4}
+	,
+	{1, 2}
+	,
+};
+#endif
+
+/**
+ * Returns the coalescing timer value
+ */
+u8
+bna_calc_coalescing_timer(struct bna_dev_s *dev, struct bna_pkt_rate *pkt)
+{
+	u32 load, bias;
+	u32 pkt_rt = 0, small_rt, large_rt;
+
+
+	small_rt = pkt->small_pkt_cnt;
+	large_rt = pkt->large_pkt_cnt;
+
+	pkt_rt = small_rt + large_rt;
+
+	if (pkt_rt < BNA_10K_PKT_RATE)
+		load = BNA_LOW_LOAD_4;
+	else if (pkt_rt < BNA_20K_PKT_RATE)
+		load = BNA_LOW_LOAD_3;
+	else if (pkt_rt < BNA_30K_PKT_RATE)
+		load = BNA_LOW_LOAD_2;
+	else if (pkt_rt < BNA_40K_PKT_RATE)
+		load = BNA_LOW_LOAD_1;
+	else if (pkt_rt < BNA_50K_PKT_RATE)
+		load = BNA_HIGH_LOAD_1;
+	else if (pkt_rt < BNA_60K_PKT_RATE)
+		load = BNA_HIGH_LOAD_2;
+	else if (pkt_rt < BNA_80K_PKT_RATE)
+		load = BNA_HIGH_LOAD_3;
+	else
+		load = BNA_HIGH_LOAD_4;
+
+	if (small_rt > (large_rt << 1))
+		bias = 0;
+	else
+		bias = 1;
+
+	pkt->small_pkt_cnt = pkt->large_pkt_cnt = 0;
+	return intr_mod_vector[load][bias];
+}
+#endif
diff -ruP linux-2.6.30.5-orig/drivers/net/bna/bna.h linux-2.6.30.5-mod/drivers/net/bna/bna.h
--- linux-2.6.30.5-orig/drivers/net/bna/bna.h	1969-12-31 16:00:00.000000000 -0800
+++ linux-2.6.30.5-mod/drivers/net/bna/bna.h	2009-08-28 21:09:22.607958000 -0700
@@ -0,0 +1,2416 @@
+/*
+ * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
+ * All rights reserved
+ * www.brocade.com
+ *
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
+ *    Copyright (c) 2008- Brocade Communications Systems, Inc.
+ *    All rights reserved.
+ *
+ *    @file bna.h
+ *    BNA Exported Definitions & Prototypes
+ */
+
+#ifndef __BNA_H__
+#define __BNA_H__
+#define DEBUG
+#define BNA_ASSERT_PRINTK_ONLY
+#define CATAPULT_BRINGUP
+#define BNAD_NAPI
+
+#include <bfa.h>
+#include <bfa_timer.h>
+#include <bfa_ioc.h>
+#include <bna_log_trc.h>
+#include <pstats/phyport_defs.h>
+#include <pstats/ethport_defs.h>
+#include <cee/bfa_cee.h>
+
+#define BNA_VLAN_ID_MAX 	4095
+
+#define BNA_TXQ_ID_MAX  	64
+#define BNA_RXQ_ID_MAX  	64
+#define BNA_CQ_ID_MAX   	64
+
+#define BNA_IB_ID_MAX   	128
+#define BNA_RIT_SIZE		256
+#define BNA_RIT_ID_MAX  	64
+
+#define BNA_UCAST_TABLE_SIZE	256
+#define BNA_MCAST_TABLE_SIZE	256
+
+#define BNA_HW_STATS_SIZE   	16384
+#define BNA_DEFAULT_RXF_ID  	0
+#define BNA_DEFAULT_TXF_ID  	0
+
+#define BNA_RXF_ID_NONE		255
+
+
+typedef unsigned char bna_mac_t[6];
+
+struct bna_dma_addr {
+	u32 msb;
+	u32 lsb;
+};
+
+struct bna_dma_addr_le {
+	u32 le_lsb;
+	u32 le_msb;
+};
+
+#define BNA_MIN(x, y) (((x) < (y)) ? (x) : (y))
+
+#define BNA_MAC_IS_MULTICAST(_mac_ms_octet)	\
+					((_mac_ms_octet) & 0x01)
+#define BNA_MAC_IS_UNICAST(_mac_ms_octet)	\
+			(!BNA_MAC_IS_MULTICAST((_mac_ms_octet)))
+
+#define BNA_POWER_OF_2(x) (((x) & ((x) - 1)) == 0)
+#define BNA_TO_POWER_OF_2(x)		\
+do {					\
+	int _shift = 0;			\
+	while ((x) && (x) != 1) {      \
+		(x) >>= 1;		\
+		_shift++;		\
+	}				\
+	(x) <<= _shift;			\
+} while (0)
+
+#define BNA_TO_POWER_OF_2_HIGH(x)       \
+do {                                    \
+        int n = 1;                      \
+        while (n < (x)) {      		\
+        	n <<= 1;                \
+        }                               \
+        (x) = n;                        \
+} while (0)
+
+/**
+ * BNA_SET_DMA_ADDR()
+ *
+ *  Converts a dma address _addr from the host
+ *  endian format to the bna_dma_addr_t format.
+ *
+ * @param[in] _addr 	- DMA'able address in host endian format
+ * @param[in] _bna_dma_addr - Pointer to bna_dma_addr_t where address
+ *  			- will be stored.
+ */
+#define BNA_SET_DMA_ADDR(_addr, _bna_dma_addr)  			\
+do {									\
+	u64 tmp_addr = 						\
+	bna_os_dma_addr64((u64)(_addr));      \
+	(_bna_dma_addr)->msb = ((struct bna_dma_addr *)&tmp_addr)->msb;	\
+	(_bna_dma_addr)->lsb = ((struct bna_dma_addr *)&tmp_addr)->lsb;	\
+} while (0)
+
+/**
+ * BNA_GET_DMA_ADDR()
+ *
+ *  Converts a dma address _addr from the host
+ *  endian format to the bna_dma_addr_t format.
+ *
+ * @parma[in] _bna_dma_addr	- Pointer to bna_dma_addr_t where address will
+ * 				be stored.
+ * @param[in] _addr 		- DMA'able address in host endian format
+ */
+#define BNA_GET_DMA_ADDR(_bna_dma_addr, _addr)  			\
+do {									\
+	(_addr) = ((u64)(bna_os_ntohl((_bna_dma_addr)->msb)) << 32)\
+		| ((bna_os_ntohl((_bna_dma_addr)->lsb) & 0xffffffff));      \
+} while (0)
+
+/**
+ * BNA_ALIGN()
+ *
+ *	Aligns a size to a given value
+ *
+ * @param[in] _x	- Actual size to align
+ * @param[in] _a	- Value to which size should be aligned
+ *
+ */
+#define BNA_ALIGN(x, a)     (((x) + (a) - 1) & ~((a) - 1))
+
+enum bna_enable_e { BNA_DISABLE = 0, BNA_ENABLE = 1 };
+
+enum bna_status_e {
+	BNA_OK = 0,
+	BNA_FAIL = 1,
+	BNA_DUPLICATE = 2,
+	BNA_BUSY = 3
+};
+
+enum bna_bool_e {
+	BNA_FALSE = 0,
+	BNA_TRUE = 1
+};
+
+#ifdef BNA_DYN_INTR_MOD
+#define BNA_LARGE_PKT_SIZE 1000
+/**
+ * This structure is for dynamic interrupt moderation
+ * Should be part of the driver private structure.
+ */
+struct bna_pkt_rate {
+	u32 small_pkt_cnt;
+	u32 large_pkt_cnt;
+};
+#define BNA_UPDATE_PKT_CNT(_pkt, _len)		\
+do {						\
+	if ((_len) > BNA_LARGE_PKT_SIZE) {      \
+		(_pkt)->large_pkt_cnt++;	\
+	} else {				\
+		(_pkt)->small_pkt_cnt++;	\
+	}					\
+} while (0)
+#endif /* BNA_DYN_INTR_MOD */
+
+/**
+ *  BNA callback function prototype The driver registers this
+ *  callback with BNA. This is called from the mailbox/error
+ *  handler routine of BNA, for further driver processing.
+ *
+ * @param[in] cbarg - Opaque cookie used by the driver to identify the callback.
+ * @param[in] cmd_code - Command code for the callback
+ * @param[in] status - Status as returned by the f/w
+ *
+ * @return    void
+ */
+
+typedef void (*bna_cbfn_t) (void *cbarg, u8 status);
+typedef void (*bna_diag_cbfn_t) (void *cbarg, void *data, u8 status);
+
+/**
+ *	Structure of callbacks implemented by the driver
+ */
+struct bna_mbox_cbfn {
+	bna_cbfn_t ucast_set_cb;
+	bna_cbfn_t ucast_add_cb;
+	bna_cbfn_t ucast_del_cb;
+
+	bna_cbfn_t mcast_add_cb;
+	bna_cbfn_t mcast_del_cb;
+	bna_cbfn_t mcast_filter_cb;
+	bna_cbfn_t mcast_del_all_cb;
+
+	bna_cbfn_t set_promisc_cb;
+	bna_cbfn_t set_default_cb;
+
+	bna_cbfn_t txq_stop_cb;
+	bna_cbfn_t rxq_stop_cb;
+
+	bna_cbfn_t port_admin_cb;
+	bna_cbfn_t link_up_cb;
+	bna_cbfn_t link_down_cb;
+
+	bna_cbfn_t stats_get_cb;
+	bna_cbfn_t stats_clr_cb;
+
+	bna_cbfn_t hw_error_cb;
+
+	bna_cbfn_t lldp_get_cfg_cb;
+	bna_cbfn_t cee_get_stats_cb;
+
+	bna_cbfn_t set_diag_lb_cb;	/* Diagnostics */
+
+	bna_cbfn_t set_pause_cb;
+
+	bna_cbfn_t mtu_info_cb;
+
+	bna_cbfn_t rxf_cb;
+
+	bna_diag_cbfn_t diag_get_temp_cb;
+	bna_diag_cbfn_t diag_sfpshow_cb;
+	bna_diag_cbfn_t diag_fwping_cb;
+	bna_diag_cbfn_t diag_ledtest_cb;
+};
+
+struct bna_chip_regs_offset {
+	u32 page_addr;
+	u32 fn_int_status;
+	u32 fn_int_mask;
+	u32 msix_idx;
+};
+/**
+ * Memory mapped addresses of often used chip registers
+ */
+struct bna_chip_regs {
+	u8 *page_addr;
+	u8 *fn_int_status;
+	u8 *fn_int_mask;
+};
+
+#define BNA_MAX_MBOX_CMD_QUEUE  256
+#define BNA_MAX_MBOX_CMD_LEN	(BFI_IOC_MSGSZ * 4)	/* 32 bytes */
+
+struct bna_mbox_cmd_qe {
+	struct bfa_mbox_cmd_s cmd;
+	u32 cmd_len;		/*  Length of the message in bytes */
+	void *cbarg;		/* non-default callback argument */
+};
+
+struct bna_mbox_q {
+	u32 producer_index;
+	u32 consumer_index;
+	void *posted;		/* Pointer to the posted element */
+	struct bna_mbox_cmd_qe mb_qe[BNA_MAX_MBOX_CMD_QUEUE];
+};
+
+/**
+ * BNA device structure
+ */
+struct bna_dev_s {
+	u8 *bar0;
+
+	u8 pci_fn;
+	u8 port;
+
+	u8 rxf_promiscuous_id;
+	u8 rxf_default_id;
+	u8 rit_size[BNA_RIT_ID_MAX];
+	u32 vlan_table[BNA_RXF_ID_MAX][(BNA_VLAN_ID_MAX + 1) / 32];
+	enum bna_enable_e vlan_filter_enable[BNA_RXF_ID_MAX];
+	u64 rxf_active;
+	u64 txf_active;
+	u64 rxf_active_last;
+	u64 txf_active_last;
+
+	struct bfi_ll_stats *hw_stats;
+	struct bna_dma_addr hw_stats_dma;
+
+	struct bna_stats stats;
+
+	u32 mcast_47_32[BNA_MCAST_TABLE_SIZE];
+	u32 mcast_31_0[BNA_MCAST_TABLE_SIZE];
+
+	u32 tmp_mc_47_32[BNA_MCAST_TABLE_SIZE];
+	u32 tmp_mc_31_0[BNA_MCAST_TABLE_SIZE];
+
+	u32 rxa_arb_pri;	/* RxA Arbitration Priority */
+
+	struct bna_chip_regs regs;	/* Pointer to oft used registers */
+
+	struct bna_mbox_q mbox_q;
+	struct bna_mbox_cbfn mb_cbfns;
+	void *cbarg;		/* Argument to callback function */
+
+	/* IOC integration */
+	struct bfa_ioc_s ioc;
+	struct bfa_timer_mod_s timer_mod;
+	struct bfa_trc_mod_s *trcmod;
+#ifdef BNA_DYN_INTR_MOD
+	struct bna_pkt_rate pkt_rate;	/* Packet rate structure */
+#endif
+	u8 ioc_disable_pending;
+
+
+	u16 msg_ctr;		/* Counter for mailbox messages posted */
+	struct bfa_cee_s *cee;
+};
+
+#define bna_get_handle_size() (sizeof(struct bna_dev_s))
+
+#ifdef BNA_DYN_INTR_MOD
+u8 bna_calc_coalescing_timer(struct bna_dev_s *dev, struct bna_pkt_rate *pkt);
+#endif
+
+/**
+ * bna_reg_read()
+ *
+ *	Function to read the value of a register.
+ *	Returns value in little-endian format.
+ *
+ * @param[in] _raddr	- Absolute address of the register to read
+ *
+ * @return    u32	- Value of the register read
+ */
+#define bna_reg_read(_raddr)	bna_os_reg_read(_raddr)
+
+/**
+ * bna_reg_write()
+ *
+ *	Function to write the value to a register.
+ *	Writes in little-endian format.
+ *
+ * @param[in] _raddr	- Absolute address of the register to write.
+ * @param[in] _val	- Value to be written.
+ *
+ * @return    void
+ */
+#define bna_reg_write(_raddr, _val) bna_os_reg_write(_raddr, _val)
+
+/**
+ * bna_mem_readw()
+ *
+ *	Function to read the value of a memory location word by word.
+ *	Returns value in big-endian format.
+ *
+ * @param[in] _raddr	- Absolute address of the memory location to read.
+ *
+ * @return    u32	- Value (word) of the memory location read.
+ */
+/* #define bna_mem_readw(_raddr)	  bna_os_mem_readw(_raddr) */
+#define bna_mem_readw(_raddr)	  bna_os_reg_read(_raddr)
+
+/**
+ * bna_mem_writew()
+ *
+ *	Function to write a value to a given memory location.
+ *	Writes in big-endian format.
+ *
+ * @param[in] _raddr	- Absolute address of the memory location to write.
+ * @param[in] _val	- Value to be written.
+ *
+ * @return    void
+ */
+/* #define bna_mem_writew(_raddr, _val)	bna_os_mem_writew(_raddr, _val) */
+#define bna_mem_writew(_raddr, _val)	bna_os_reg_write(_raddr, _val)
+
+/**
+ *	Holds DMA physical and virtual memory addresses
+ *	and length. This is used for making IOC calls.
+ */
+struct bna_meminfo {
+	u8 *kva;		/* Kernel virtual address */
+	u64 dma;		/* Actual physical address */
+	u32 len;		/* Memory size in bytes */
+};
+
+enum bna_dma_mem_type {
+	BNA_DMA_MEM_T_DIAG = 0,
+	BNA_DMA_MEM_T_FLASH = 1,
+	BNA_DMA_MEM_T_ATTR = 2,
+	BNA_KVA_MEM_T_FWTRC = 3,
+	BNA_MEM_T_MAX,
+};
+
+
+
+
+/**
+ * bna_register_callback()
+ *
+ *  Function called by the driver to register a callback with
+ *  the BNA
+ *
+ * @param[in] dev    - Opaque handle to BNA private device.
+ * @param[in] cbfns  - Structure of callbacks from drivers.
+ * @param[in] cbarg  - Argument to use with the callback.
+ *
+ * @return    BNA_OK or BNA_FAIL
+ */
+void bna_register_callback(struct bna_dev_s *dev,
+			   struct bna_mbox_cbfn *cbfns, void *cbarg);
+
+/**
+ * Ethernet / Ethernet & VLAN header used by diag loopback
+ */
+struct bna_ether_hdr {
+	bna_mac_t dst;		/* destination mac address      */
+	bna_mac_t src;		/* source mac address           */
+	u16 proto;		/* ethernet protocol            */
+};
+
+struct bna_ether_vlan_hdr {
+	bna_mac_t dst;		/* destination mac address      */
+	bna_mac_t src;		/* source mac address           */
+	u16 vlan_proto;		/* vlan ethernet protocol       */
+	u16 vlan_tci;		/* vlan tag/priority            */
+	u16 proto;		/* ethernet protocol            */
+};
+
+/**
+ * Structure used to create loopback packet
+ */
+struct bna_lb_pkt_info {
+	u8 *buf;		/* allocated by driver */
+	u32 buflen;		/* buffer length */
+	u32 pattern;		/* pattern to be filled in */
+	u32 vlan_tag;		/* 0 for no tag */
+	bna_mac_t mac;		/* SA & DA to be used for lb pkt */
+};
+
+struct bna_diag_lb_pkt_stats {
+	u64 pkts_to_send;
+	volatile u64 pkts_sent;
+	volatile u64 pkts_rcvd;
+	volatile u64 tx_drops;
+	volatile u64 rx_drops;
+};
+
+/**
+ * API called to create a loopback packet */
+enum bna_status_e bna_create_lb_pkt(void *dev, struct bna_lb_pkt_info *pktinfo);
+
+/**
+ * bna_diag_ll_loopback()
+ *
+ *  Send mailbox message to enable / disable LL diag loopback mode
+ *
+ * @param[in]  dev	- pointer to BNA device structure
+ * @param[in]  port 	- port on which loopback is enabled/disabled
+ * @param[in]  enable 	- enable/disable diag loopback mode
+ *
+ * @return BNA_OK or BNA_FAIL
+ */
+enum bna_status_e bna_diag_ll_loopback(void *dev, u8 mode,
+				       u8 enable, void *cbarg);
+
+
+
+/* Port Management */
+
+struct bna_port_stats {
+	u64 rx_frame_64;
+	u64 rx_frame_65_127;
+	u64 rx_frame_128_255;
+	u64 rx_frame_256_511;
+	u64 rx_frame_512_1023;
+	u64 rx_frame_1024_1518;
+	u64 rx_frame_1518_1522;
+	u64 rx_bytes;
+	u64 rx_packets;
+	u64 rx_fcs_error;
+	u64 rx_multicast;
+	u64 rx_broadcast;
+	u64 rx_control_frames;
+	u64 rx_pause;
+	u64 rx_unknown_opcode;
+	u64 rx_alignment_error;
+	u64 rx_frame_length_error;
+	u64 rx_code_error;
+	u64 rx_carrier_sense_error;
+	u64 rx_undersize;
+	u64 rx_oversize;
+	u64 rx_fragments;
+	u64 rx_jabber;
+	u64 rx_drop;
+
+	u64 tx_bytes;
+	u64 tx_packets;
+	u64 tx_multicast;
+	u64 tx_broadcast;
+	u64 tx_pause;
+	u64 tx_deferral;
+	u64 tx_excessive_deferral;
+	u64 tx_single_collision;
+	u64 tx_muliple_collision;
+	u64 tx_late_collision;
+	u64 tx_excessive_collision;
+	u64 tx_total_collision;
+	u64 tx_pause_honored;
+	u64 tx_drop;
+	u64 tx_jabber;
+	u64 tx_fcs_error;
+	u64 tx_control_frame;
+	u64 tx_oversize;
+	u64 tx_undersize;
+	u64 tx_fragments;
+};
+
+
+#define BNA_LINK_SPEED_10Gbps	10000
+struct bna_port_param {
+	u32 supported;		/* Speeds and Flow Control supported */
+	u32 advertising;	/* speeds and Flow-Control advertised */
+	u32 speed;
+	u32 duplex;
+	u32 autoneg;
+	u32 port;
+};
+
+/**
+ * bna_port_param_get()
+ *
+ *   Get the port parameters.
+ *
+ * @param[in]   dev		- pointer to BNA device structure
+ * @param[out]  param_ptr	- pointer to where the parameters will be
+ *       			  returned.
+ * @return void
+ */
+void bna_port_param_get(struct bna_dev_s *dev,
+			struct bna_port_param *param_ptr);
+
+
+/**
+ * bna_port_mac_get()
+ *
+ *   Get the Burnt-in or permanent MAC address.  This function does not return
+ *   the MAC set thru bna_rxf_ucast_mac_set() but the one that is assigned to
+ *   the port upon reset.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[out] mac_ptr - Burnt-in or permanent MAC address.
+ *
+ * @return void
+ */
+void bna_port_mac_get(struct bna_dev_s *dev, bna_mac_t * mac_ptr);
+
+
+/**
+ * bna_port_admin()
+ *
+ *   Enable (up) or disable (down) the interface administratively.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  enable - enable/disable the interface.
+ *
+ * @return void
+ */
+enum bna_status_e bna_port_admin(struct bna_dev_s *dev,
+				 enum bna_enable_e enable);
+
+
+/**
+ * bna_port_stats_get()
+ *
+ *   Get the port statistics.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[out]  stats_ptr - pointer to where the statistics will be returned.
+ *
+ * @return void
+ */
+void bna_port_stats_get(void *dev, struct bna_port_stats *stats_ptr);
+
+/**
+ * Ethernet 802.3X PAUSE confiiguration
+ */
+struct bna_pause_config {
+	u8 tx_pause;
+	u8 rx_pause;
+};
+
+/**
+ * bna_set_pause_config()
+ *
+ *   Enable/disable Tx/Rx pause through F/W
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[in]   pause 	  - pointer to struct bna_pause_config
+ * @param[in]   cbarg	  - argument for the callback function
+ *
+ * @return BNA_OK in case of success BNA_FAIL otherwise.
+ */
+enum bna_status_e bna_set_pause_config(struct bna_dev_s *dev,
+				       struct bna_pause_config *pause,
+				       void *cbarg);
+
+/**
+ * bna_mtu_info()
+ *
+ *   Send MTU information to F/W.
+ *   This is required to do PAUSE efficiently.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure
+ * @param[in]   mtu	  - current mtu size
+ * @param[in]   cbarg	  - argument for the callback function
+ *
+ * @return BNA_OK in case of success BNA_FAIL otherwise.
+ */
+enum bna_status_e bna_mtu_info(struct bna_dev_s *dev, u16 mtu, void *cbarg);
+
+/*
+ *
+ *
+ *   D O O R B E L L   D E F I N E S
+ *
+ *
+ */
+
+/**
+ * These macros build the data portion of the TxQ/RxQ doorbell.
+ */
+#define BNA_DOORBELL_Q_PRD_IDX(_producer_index) (0x80000000 | (_producer_index))
+#define BNA_DOORBELL_Q_STOP			(0x40000000)
+
+/* These macros build the data portion of the IB doorbell. */
+#define BNA_DOORBELL_IB_INT_ACK(_timeout, _events) \
+				(0x80000000 | ((_timeout) << 16) | (_events))
+#define BNA_DOORBELL_IB_INT_DISABLE 		(0x40000000)
+
+
+/*
+ *
+ *
+ *   I N T E R R U P T   B L O C K   D E F I N E S
+ *
+ *
+ */
+
+/* IB Structure */
+struct bna_ib {
+	void __iomem *doorbell_addr;	/* PCI address for IB doorbell */
+	u32 doorbell_ack;	/* ack data format except for #
+				   of events */
+};
+
+
+/* IB Control Flags in IB Configuration */
+#define bna_ib_cf_t u8
+
+#define BNA_IB_CF_RESERVED1 		(1 << 7)
+#define BNA_IB_CF_ACK_PENDING		(1 << 6)	/* Read Only */
+#define BNA_IB_CF_INTER_PKT_DMA		(1 << 5)	/* DMA segment w/o
+							   issuing interrupt */
+#define BNA_IB_CF_INT_ENABLE		(1 << 4)	/* Interrupt enable */
+#define BNA_IB_CF_INTER_PKT_ENABLE	(1 << 3)	/* Inter Packet
+							   Mechanism enable */
+#define BNA_IB_CF_COALESCING_MODE	(1 << 2)	/* 1 = Continuous Mode;
+							   0 = One-shot */
+#define BNA_IB_CF_MSIX_MODE		(1 << 1)	/* 1 = MSIX mode;
+							   0 = INTx mode */
+#define BNA_IB_CF_MASTER_ENABLE		(1 << 0)	/* Master Enable */
+
+
+/* IB Configuration Structure */
+struct bna_ib_config {
+	struct bna_dma_addr ib_seg_addr;	/* Host Address of IB Segment */
+	u8 coalescing_timer;
+	bna_ib_cf_t control_flags;
+	u8 msix_vector;
+	u8 interpkt_count;
+	u8 interpkt_timer;
+	u8 seg_size;		/* No. of entries */
+	u8 index_table_offset;
+};
+
+
+/*
+ * bna_ib_idx_reset()
+ *
+ *   For the specified IB, it clears the IB index
+ *
+ * @param[in] cfg_ptr - pointer to IB Configuration Structure.
+ *
+ * @return none
+ */
+void
+  bna_ib_idx_reset(struct bna_dev_s *dev, const struct bna_ib_config *cfg_ptr);
+
+/**
+ * bna_ib_config_set()
+ *
+ *   For IB "ib_id", it configures the Interrupt Block specified by "cfg_ptr".
+ *
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ * @param[in] ib_id   - interrupt-block ID
+ * @param[in] cfg_ptr - pointer to IB Configuration Structure.
+ *
+ * @return None
+ */
+void bna_ib_config_set(struct bna_dev_s *bna_dev, struct bna_ib *ib_ptr,
+		       unsigned int ib_id, const struct bna_ib_config *cfg_ptr);
+
+
+/**
+ * bna_ib_ack()
+ *
+ *   Acknowledges the number of events triggered by the current interrupt.
+ *
+ * @param[in] bna_dev   - Opaque handle to bna device.
+ * @param[in] ib_ptr	- pointer to IB Data Structure.
+ * @param[in] events	- number of events to acknowledge.
+ *
+ * @return None
+ */
+static inline void
+bna_ib_ack(struct bna_dev_s *bna_dev, const struct bna_ib *ib_ptr, u16 events)
+{
+	/*
+	 * bna_os_reg_write is defined in a header
+	 * included later
+	 */
+	bna_os_reg_write(ib_ptr->doorbell_addr,
+			 (ib_ptr->doorbell_ack | events));
+}
+
+
+/**
+ * bna_ib_coalescing_timer_set()
+ *
+ *   Sets the timeout value in the coalescing timer
+ *
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ * @param[in] timeout - coalescing timer value.
+ *
+ * @return None
+ */
+static inline void
+bna_ib_coalescing_timer_set(struct bna_dev_s *dev,
+			    struct bna_ib *ib_ptr, u8 cls_timer)
+{
+	ib_ptr->doorbell_ack = BNA_DOORBELL_IB_INT_ACK(cls_timer, 0);
+}
+
+
+
+/**
+ * bna_ib_disable()
+ *
+ *   Disables the Interrupt Block "ib_id".
+ *
+ * @param[in] bna_dev - pointer to BNA private handle.
+ * @param[in] ib_ptr  - pointer to IB Data Structure.
+ *
+ * @return None
+ */
+void bna_ib_disable(struct bna_dev_s *bna_dev, const struct bna_ib *ib_ptr);
+
+
+/**
+ * Interrupt status register, mailbox status bits
+ */
+#define __LPU02HOST_MBOX0_STATUS_BITS 0x00100000
+#define __LPU12HOST_MBOX0_STATUS_BITS 0x00200000
+#define __LPU02HOST_MBOX1_STATUS_BITS 0x00400000
+#define __LPU12HOST_MBOX1_STATUS_BITS 0x00800000
+
+#define __LPU02HOST_MBOX0_MASK_BITS	0x00100000
+#define __LPU12HOST_MBOX0_MASK_BITS	0x00200000
+#define __LPU02HOST_MBOX1_MASK_BITS	0x00400000
+#define __LPU12HOST_MBOX1_MASK_BITS	0x00800000
+
+#define __LPU2HOST_MBOX_MASK_BITS			 \
+	(__LPU02HOST_MBOX0_MASK_BITS | __LPU02HOST_MBOX1_MASK_BITS |	\
+	  __LPU12HOST_MBOX0_MASK_BITS | __LPU12HOST_MBOX1_MASK_BITS)
+
+#define __LPU2HOST_IB_STATUS_BITS	0x0000ffff
+
+#define BNA_IS_LPU0_MBOX_INTR(_intr_status) \
+	((_intr_status) & (__LPU02HOST_MBOX0_STATUS_BITS | \
+			__LPU02HOST_MBOX1_STATUS_BITS))
+
+#define BNA_IS_LPU1_MBOX_INTR(_intr_status) \
+	((_intr_status) & (__LPU12HOST_MBOX0_STATUS_BITS | \
+		__LPU12HOST_MBOX1_STATUS_BITS))
+
+/**
+ * BNA_IS_MBOX_INTR()
+ *
+ *  Checks if the mailbox interrupt status bits
+ *  are set
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_IS_MBOX_INTR(_intr_status)		\
+	((_intr_status) &  			\
+	(__LPU02HOST_MBOX0_STATUS_BITS |	\
+	 __LPU02HOST_MBOX1_STATUS_BITS |	\
+	 __LPU12HOST_MBOX0_STATUS_BITS |	\
+	 __LPU12HOST_MBOX1_STATUS_BITS))
+
+#define __EMC_ERROR_STATUS_BITS		0x00010000
+#define __LPU0_ERROR_STATUS_BITS	0x00020000
+#define __LPU1_ERROR_STATUS_BITS	0x00040000
+#define __PSS_ERROR_STATUS_BITS		0x00080000
+
+#define __HALT_STATUS_BITS		0x01000000
+
+#define __EMC_ERROR_MASK_BITS		0x00010000
+#define __LPU0_ERROR_MASK_BITS		0x00020000
+#define __LPU1_ERROR_MASK_BITS		0x00040000
+#define __PSS_ERROR_MASK_BITS		0x00080000
+
+#define __HALT_MASK_BITS		0x01000000
+
+#define __ERROR_MASK_BITS		\
+	(__EMC_ERROR_MASK_BITS | __LPU0_ERROR_MASK_BITS | \
+	  __LPU1_ERROR_MASK_BITS | __PSS_ERROR_MASK_BITS | \
+	  __HALT_MASK_BITS)
+
+/**
+ * BNA_IS_ERR_INTR()
+ *
+ *  Checks if the error interrupt status bits
+ *  are set
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_IS_ERR_INTR(_intr_status)	\
+	((_intr_status) &  		\
+	(__EMC_ERROR_STATUS_BITS |  	\
+	 __LPU0_ERROR_STATUS_BITS | 	\
+	 __LPU1_ERROR_STATUS_BITS | 	\
+	 __PSS_ERROR_STATUS_BITS  | 	\
+	 __HALT_STATUS_BITS))
+
+/**
+ * BNA_IS_MBOX_ERR_INTR()
+ *
+ *  Checks if the mailbox and error interrupt status bits
+ *  are set
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_IS_MBOX_ERR_INTR(_intr_status)	\
+	(BNA_IS_MBOX_INTR((_intr_status)) |	\
+	 BNA_IS_ERR_INTR((_intr_status)))	\
+
+/**
+ * BNA_IS_INTX_DATA_INTR()
+ *
+ *  Checks if the data bits (low 16 bits)
+ *  are set in case of INTx
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_IS_INTX_DATA_INTR(_intr_status)	\
+	((_intr_status) & __LPU2HOST_IB_STATUS_BITS)
+
+/**
+ * BNA_INTR_STATUS_MBOX_CLR()
+ *
+ *  Clears the mailbox bits in _intr_status
+ *  Does not write to hardware
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_INTR_STATUS_MBOX_CLR(_intr_status)			\
+do {								\
+	(_intr_status) &= ~(__LPU02HOST_MBOX0_STATUS_BITS |	\
+			__LPU02HOST_MBOX1_STATUS_BITS | 	\
+			__LPU12HOST_MBOX0_STATUS_BITS | 	\
+			__LPU12HOST_MBOX1_STATUS_BITS);      \
+} while (0)
+
+/**
+ * BNA_INTR_STATUS_ERR_CLR()
+ *
+ *  Clears the error bits in _intr_status
+ *  Does not write to hardware
+ *
+ * @param[in] _intr_status - Interrupt Status Register
+ */
+#define BNA_INTR_STATUS_ERR_CLR(_intr_status)		\
+do {							\
+	(_intr_status) &= ~(__EMC_ERROR_STATUS_BITS |	\
+		__LPU0_ERROR_STATUS_BITS |		\
+		__LPU1_ERROR_STATUS_BITS |		\
+		__PSS_ERROR_STATUS_BITS  |		\
+		__HALT_STATUS_BITS);      \
+} while (0)
+
+
+/**
+ * bna_mbox_err_handler()
+ *
+ *    The driver calls this API back after processing the
+ *    mailbox/error interrupt for MSIX and INTx types.
+ *    Should be called with a lock held.
+ *    This will do the following for mbox interrupt :
+ *  1) Read the contents of the mbox
+ *  	2) Call a function registered by the OS driver to handle
+ *     the mailbox command.
+ *  3) Queue the next mbox command
+ *    This will do the following for error interrupt :
+ *  1) Interpret the type of error & call the
+ *     right BNA handler.
+ *  2) Call the driver defined callback.
+ *
+ * @param[in] bna_dev   - Pointer to BNA private handle.
+ * @param[in] status	- Interrupt status register.
+ *
+ * @return void
+ */
+void bna_mbox_err_handler(struct bna_dev_s *bna_dev, u32 status);
+
+/**
+ * bna_mbox_send()
+ *
+ *    The driver calls this API to send a command to the
+ *    firmware
+ *
+ * @param[in] bna_dev   - Pointer to BNA private handle.
+ * @param[in] cmd   	- pointer to the command structur
+ * @param[in] cmd_len   - length of the command structure
+ *
+ * @return BNA_OK or BNA_FAIL
+ */
+enum bna_status_e bna_mbox_send(struct bna_dev_s *bna_dev, void *cmd,
+				u32 cmd_len, void *cbarg);
+
+
+
+/*******************************************************************/
+/*
+ *
+ *
+ *   Q U E U E   D E F I N E S
+ *
+ *
+ */
+#define BNA_TXQ_ENTRY_SIZE	64	/* bytes */
+#define BNA_RXQ_ENTRY_SIZE	8	/* bytes */
+#define BNA_CQ_ENTRY_SIZE	16	/* bytes */
+/**
+ *  Queue Page Table (QPT)
+ */
+struct bna_qpt {		/* Queue Page Table */
+	struct bna_dma_addr hw_qpt_ptr;	/* Pointer to QPT used by HW */
+	bna_os_addr_t kv_qpt_ptr;	/* Kernel virtual pointer to
+					   hw QPT */
+	void **qpt_ptr;		/* Pointer to S/W QPT for page
+				   segmented Q's */
+	u16 page_count;		/* Size of QPT (i.e., number of
+				   pages) */
+	u16 page_size;		/* Size of each page */
+};
+
+#define BNA_QPT_SIZE(_queue_size, _page_size)	\
+			(((_queue_size) + (_page_size) - 1)/(_page_size))
+
+struct bna_q {
+	u16 producer_index;
+	u16 consumer_index;
+	u32 q_depth;		/* Depth of the q */
+	void **qpt_ptr;		/* pointer to SW QPT for Page-segmented
+				   queue */
+};
+
+
+/**
+ * BNA_TXQ_QPGE_PTR_GET()
+ *
+ *   Gets the pointer corresponding to an queue-entry index for a
+ *   page-segmented queue.
+ *
+ *   NOTE:  _q_depth, sizeof(_cast) and BNA_PAGE_SIZE must be power of two.
+ *  		_q_depth * sizeof(_cast) must be multiple of a BNA_PAGE_SIZE.
+ *
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_ptr   	 - pointer to page-segmented queue structure
+ * @param[out] _qe_ptr  	 - producer/consumer queue-entry pointer
+ * @param[out] _qe_ptr_range	 - number of entries addressable by
+ *                                 queue-entry pointer (warns going beyond the
+ *                                 page-size)
+ */
+#define BNA_TXQ_PAGE_INDEX_MAX (BNA_PAGE_SIZE >> 6)	/* TxQ element is 64 bytes */
+#define BNA_TXQ_PAGE_INDEX_MAX_SHIFT (BNA_PAGE_SHIFT - 6)
+
+#define BNA_TXQ_QPGE_PTR_GET(_qe_idx, _q_ptr, _qe_ptr, _qe_ptr_range) \
+{ \
+      unsigned int page_index;        /* index within a page */ \
+      void *page_addr; \
+      \
+      page_index = (_qe_idx) & (BNA_TXQ_PAGE_INDEX_MAX - 1);      \
+      (_qe_ptr_range) = (BNA_TXQ_PAGE_INDEX_MAX - page_index);      \
+      page_addr = (_q_ptr)->qpt_ptr[((_qe_idx) >> BNA_TXQ_PAGE_INDEX_MAX_SHIFT)]; \
+      (_qe_ptr) = &((struct bna_txq_entry *)(page_addr))[page_index]; \
+}
+
+/**
+ * BNA_RXQ_QPGE_PTR_GET()
+ *
+ *   Gets the pointer corresponding to an queue-entry index for a
+ *   page-segmented queue.
+ *
+ *   NOTE:  _q_depth, sizeof(_cast) and BNA_PAGE_SIZE must be power of two.
+ *  		_q_depth * sizeof(_cast) must be multiple of a BNA_PAGE_SIZE.
+ *
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_ptr   	 - pointer to page-segmented queue structure
+ * @param[out] _qe_ptr  	 - producer/consumer queue-entry pointer
+ * @param[out] _qe_ptr_range	 - number of entries addressable by
+ *                                 queue-entry pointer (warns going beyond the
+ *                                 page-size)
+ */
+#define BNA_RXQ_PAGE_INDEX_MAX (BNA_PAGE_SIZE >> 3)	/* RxQ element is 8 bytes */
+#define BNA_RXQ_PAGE_INDEX_MAX_SHIFT (BNA_PAGE_SHIFT - 3)
+
+#define BNA_RXQ_QPGE_PTR_GET(_qe_idx, _q_ptr, _qe_ptr, _qe_ptr_range) \
+{ \
+      unsigned int page_index;        /* index within a page */ \
+      void *page_addr; \
+      \
+      page_index = (_qe_idx) & (BNA_RXQ_PAGE_INDEX_MAX - 1);      \
+      (_qe_ptr_range) = (BNA_RXQ_PAGE_INDEX_MAX - page_index);      \
+      page_addr = (_q_ptr)->qpt_ptr[((_qe_idx) >> BNA_RXQ_PAGE_INDEX_MAX_SHIFT)]; \
+      (_qe_ptr) = &((struct bna_rxq_entry *)(page_addr))[page_index]; \
+}
+
+/**
+ * BNA_CQ_QPGE_PTR_GET()
+ *
+ *   Gets the pointer corresponding to an queue-entry index for a
+ *   page-segmented queue.
+ *
+ *   NOTE:  _q_depth, sizeof(_cast) and BNA_PAGE_SIZE must be power of two.
+ *  		_q_depth * sizeof(_cast) must be multiple of a BNA_PAGE_SIZE.
+ *
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_ptr   	 - pointer to page-segmented queue structure
+ * @param[out] _qe_ptr  	 - producer/consumer queue-entry pointer
+ * @param[out] _qe_ptr_range	 - number of entries addressable by
+ *                                 queue-entry pointer (warns going beyond the
+ *                                 page-size)
+ */
+#define BNA_CQ_PAGE_INDEX_MAX (BNA_PAGE_SIZE >> 4)	/* CQ element is 16 bytes */
+#define BNA_CQ_PAGE_INDEX_MAX_SHIFT (BNA_PAGE_SHIFT - 4)
+
+#define BNA_CQ_QPGE_PTR_GET(_qe_idx, _q_ptr, _qe_ptr, _qe_ptr_range) \
+{ \
+      unsigned int page_index;        /* index within a page */ \
+      void *page_addr; \
+      \
+      page_index = (_qe_idx) & (BNA_CQ_PAGE_INDEX_MAX - 1);      \
+      (_qe_ptr_range) = (BNA_CQ_PAGE_INDEX_MAX - page_index);      \
+      page_addr = (_q_ptr)->qpt_ptr[((_qe_idx) >> BNA_CQ_PAGE_INDEX_MAX_SHIFT)]; \
+      (_qe_ptr) = &((struct bna_cq_entry *)(page_addr))[page_index]; \
+}
+
+/**
+ * BNA_QE_INDX_2_PTR()
+ *
+ *   Gets the pointer corresponding to an queue-entry index for a virtually-
+ *   contiguous queue.
+ *
+ *   NOTE:  _q_depth must be power of two.
+ *
+ * @param[in]  _cast		 - type cast of the entry.
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_base  	 - queue base address
+ */
+#define BNA_QE_INDX_2_PTR(_cast, _qe_idx, _q_base) \
+	&((_cast *)(_q_base))[(_qe_idx)]
+
+
+/**
+ * BNA_QE_INDX_RANGE()
+ *
+ *   Returns number of entries that can be consecutively addressed for the
+ *   specified queue.  This function indicates when BNA_QE_INDX_2_PTR() must
+ *   be called again get a new pointer due to the effect of wrapping around
+ *   the queue.
+ *
+ *   NOTE:  _q_depth must be power of two.
+ *
+ * @param[in]  _qe_idx  	 - producer/consumer queue entry index
+ * @param[in]  _q_depth 	 - queue size in number of entries
+ */
+#define BNA_QE_INDX_RANGE(_qe_idx, _q_depth) \
+	((_q_depth) - (_qe_idx))
+
+
+/**
+ * BNA_QE_INDX_ADD()
+ *
+ *   Adds to a producer or consumer queue-entry index for either
+ *   virtually-contiguous or page-segmented queue.
+ *
+ *   NOTE:  _q_depth must power of two.
+ *
+ * @param[in]  _qe_idx  - producer/consumer queue entry index
+ * @param[out] _qe_idx  - updated producer/consumer queue entry index
+ * @param[in]  _q_depth - queue size in number of entries
+ */
+#define BNA_QE_INDX_ADD(_qe_idx, _qe_num, _q_depth) \
+	(_qe_idx) = ((_qe_idx) + (_qe_num)) & ((_q_depth) - 1)
+
+
+/**
+ * BNA_QE_FREE_CNT
+ *
+ *   Returns the number of entries that can be added into the queue.
+ *
+ *   NOTE:  Must reserved one entry to distinguish between an empty
+ *  		and a full queue.
+ *
+ * @param[in]  _q_ptr   - pointer to queue structure
+ * @param[in]  _q_depth - queue size in number of entries
+ */
+#define BNA_QE_FREE_CNT(_q_ptr, _q_depth) \
+  (((_q_ptr)->consumer_index - (_q_ptr)->producer_index - 1) & ((_q_depth) - 1))
+
+/**
+ * BNA_QE_IN_USE_CNT
+ *
+ *    Returns the number of entries in the queue.
+ *
+ * @param[in]  _q_ptr   - pointer to queue structure
+ * @param[in]  _q_depth - queue size in number of entries
+ */
+#define BNA_QE_IN_USE_CNT(_q_ptr, _q_depth) \
+   ((((_q_ptr)->producer_index - (_q_ptr)->consumer_index)) & (_q_depth - 1))
+
+
+/**
+ * BNA_Q_GET_CI
+ *
+ *    Returns the current consumer index for that queue.
+ *
+ * @param[in]  _q_ptr   - pointer to queue (Tx/Rx/C) structure
+ */
+#define BNA_Q_GET_CI(_q_ptr)   \
+	(_q_ptr)->q.consumer_index
+
+/**
+ * BNA_Q_GET_PI
+ *
+ *    Returns the current producer index for that queue.
+ *
+ * @param[in]  _q_ptr   - pointer to queue (Tx/Rx/C) structure
+ */
+#define BNA_Q_GET_PI(_q_ptr)   \
+	(_q_ptr)->q.producer_index
+
+/**
+ * BNA_Q_PI_ADD
+ *
+ *   Increments the producer index of the queue by a certain number
+ *
+ * @param[in]  _q_ptr   - pointer to queue (Tx/Rx/C) structure
+ * @param[in]  _num 	- the number by which CI needs to be incremented
+ */
+#define BNA_Q_PI_ADD(_q_ptr, _num) 		\
+	(_q_ptr)->q.producer_index =			\
+		(((_q_ptr)->q.producer_index + (_num))  \
+		& ((_q_ptr)->q.q_depth - 1))
+
+/**
+ * BNA_Q_CI_ADD
+ *
+ *   Increments the consumer index of the queue by a certain number
+ *
+ * @param[in]  _q_ptr   - pointer to queue (Tx/Rx/C) structure
+ * @param[in]  _num 	- the number by which CI needs to be incremented
+ */
+#define BNA_Q_CI_ADD(_q_ptr, _num) 		\
+	(_q_ptr)->q.consumer_index =			\
+		(((_q_ptr)->q.consumer_index + (_num))  \
+		& ((_q_ptr)->q.q_depth - 1))
+
+/**
+ * BNA_Q_FREE_COUNT()
+ *
+ *  Returns the number of free entries for TxQ/RxQ/CQ
+ *
+ * @param[in] _q_ptr	- pointer to TxQ/RxQ/CQ
+ */
+#define BNA_Q_FREE_COUNT(_q_ptr)			\
+	(BNA_QE_FREE_CNT(&((_q_ptr)->q), (_q_ptr)->q.q_depth))
+
+/**
+ * BNA_Q_FREE_COUNT()
+ *
+ *  Returns the number of entries in use for the queue.
+ *
+ * @param[in] _q_ptr	- pointer to TxQ/RxQ/CQ
+ */
+#define BNA_Q_IN_USE_COUNT(_q_ptr)  		\
+	(BNA_QE_IN_USE_CNT(&(_q_ptr)->q, (_q_ptr)->q.q_depth))
+/*
+ *
+ *
+ *   T X   Q U E U E   D E F I N E S
+ *
+ *
+ */
+/* TxQ Vector (a.k.a. Tx-Buffer Descriptor) */
+struct bna_txq_wi_vector {	/* Tx Buffer Descriptor */
+	u16 reserved;
+	u16 length;		/* Only 14 LSB are valid */
+	struct bna_dma_addr host_addr;	/* Tx-Buffer DMA address */
+};
+
+
+/* TxQ Entry Opcodes */
+#define BNA_TXQ_WI_SEND 		(0x402)	/* Single Frame Transmission */
+#define BNA_TXQ_WI_SEND_LSO 		(0x403)	/* Multi-Frame Transmission */
+#define BNA_TXQ_WI_EXTENSION		(0x104)	/* Extension WI */
+#define bna_txq_wi_opcode_t u16
+
+
+/* TxQ Entry Control Flags */
+#define BNA_TXQ_WI_CF_FCOE_CRC  	(1 << 8)
+#define BNA_TXQ_WI_CF_IPID_MODE 	(1 << 5)
+#define BNA_TXQ_WI_CF_INS_PRIO  	(1 << 4)
+#define BNA_TXQ_WI_CF_INS_VLAN  	(1 << 3)
+#define BNA_TXQ_WI_CF_UDP_CKSUM 	(1 << 2)
+#define BNA_TXQ_WI_CF_TCP_CKSUM 	(1 << 1)
+#define BNA_TXQ_WI_CF_IP_CKSUM  	(1 << 0)
+#define bna_txq_wi_ctrl_flag_t u16
+
+
+/**
+ *  TxQ Entry Structure
+ *
+ *  BEWARE:  Load values into this structure with correct endianess.
+ */
+struct bna_txq_entry {
+	union {
+		struct {
+			u8 reserved;
+			u8 num_vectors;	/* number of vectors present */
+			bna_txq_wi_opcode_t opcode;	/* Either BNA_TXQ_WI_SEND or
+							   BNA_TXQ_WI_SEND_LSO */
+			bna_txq_wi_ctrl_flag_t flags;	/* OR of all the flags */
+			u16 l4_hdr_size_n_offset;
+			u16 vlan_tag;
+			u16 lso_mss;	/* Only 14 LSB are valid */
+			u32 frame_length;	/* Only 24 LSB are valid */
+		} wi;
+
+		struct {
+			u16 reserved;
+			bna_txq_wi_opcode_t opcode;	/* Must be
+							   BNA_TXQ_WI_EXTENSION */
+			u32 reserved2[3];	/* Place holder for
+						   removed vector (12 bytes) */
+		} wi_ext;
+	} hdr;
+	struct bna_txq_wi_vector vector[4];
+};
+#define wi_hdr  	hdr.wi
+#define wi_ext_hdr  hdr.wi_ext
+
+#define BNA_TXQ_WI_L4_HDR_N_OFFSET(_hdr_size, _offset) \
+		(((_hdr_size) << 10) | ((_offset) & 0x3FF))
+
+/* TxQ Structure */
+struct bna_txq {
+	u32 *doorbell;
+	struct bna_q q;
+};
+
+
+/* TxQ Configuration */
+struct bna_txq_config {
+	struct bna_qpt qpt;
+	u16 ib_id;
+	u8 ib_seg_index;	/* index into IB segment */
+	u8 txf_id;		/* Tx-Function ID */
+	u8 priority;		/* frame or scheduling priority? FIXME */
+	u16 wrr_quota;		/* Weighted Round-Robin Quota */
+};
+
+
+/**
+ * bna_txq_config()
+ *
+ * For TxQ "txq_id", it configures the Tx-Queue as specified by "cfg_ptr".
+ */
+void bna_txq_config(struct bna_dev_s *dev, struct bna_txq *q_ptr,
+		    unsigned int txq_id, const struct bna_txq_config *cfg_ptr);
+
+
+
+/**
+ * bna_txq_pg_prod_ptr()
+ *
+ * Returns the producer pointer and its range for the specified page-segmented
+ * queue.
+ */
+static inline struct bna_txq_entry *
+bna_txq_pg_prod_ptr(const struct bna_txq *q_ptr, unsigned int *ptr_range)
+{
+	struct bna_txq_entry *qe_ptr;
+
+	BNA_TXQ_QPGE_PTR_GET(q_ptr->q.producer_index,
+			     &q_ptr->q, qe_ptr, *ptr_range);
+	return (qe_ptr);
+}
+
+/**
+ * bna_txq_prod_indx_doorbell()
+ *
+ * Informs Catapult ASIC about queued entries.
+ */
+static inline void
+bna_txq_prod_indx_doorbell(const struct bna_txq *q_ptr)
+{
+	bna_os_reg_write(q_ptr->doorbell,
+			 BNA_DOORBELL_Q_PRD_IDX(q_ptr->q.producer_index));
+}
+
+
+/**
+ * bna_txq_pg_cons_ptr()
+ *
+ * Returns the consumer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_txq_entry *
+bna_txq_pg_cons_ptr(const struct bna_txq *q_ptr, unsigned int *ptr_range)
+{
+	struct bna_txq_entry *qe_ptr;
+
+	BNA_TXQ_QPGE_PTR_GET(q_ptr->q.consumer_index,
+			     &q_ptr->q, qe_ptr, *ptr_range);
+	return (qe_ptr);
+}
+
+/**
+ * bna_txq_stop()
+ *
+ * 	Stops the RxQ identified by the RxQ Id.
+ *  	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	know if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the TxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e bna_txq_stop(struct bna_dev_s *bna_dev, u32 txq_id);
+
+/*
+ *
+ *
+ *   R X   Q U E U E   D E F I N E S
+ *
+ *
+ */
+/* RxQ Entry (Rx-Vector, Rx-Buffer Address) */
+struct bna_rxq_entry {		/* Rx-Buffer */
+	struct bna_dma_addr host_addr;	/* Rx-Buffer DMA address */
+};
+
+
+/* RxQ Structure */
+struct bna_rxq {
+	u32 *doorbell;
+	struct bna_q q;
+};
+
+
+/* RxQ Configuration */
+struct bna_rxq_config {
+	struct bna_qpt qpt;
+	u8 cq_id;		/* Completion Queue ID */
+	u16 buffer_size;	/* Rx-Buffer Length */
+};
+
+/**
+ *  bna_rxq_config()
+ *
+ *  For RxQ "rxq_id", it configures the Rx-Queue as specified by "cfg_ptr".
+ */
+void bna_rxq_config(struct bna_dev_s *dev, struct bna_rxq *q_ptr,
+		    unsigned int rxq_id, const struct bna_rxq_config *cfg_ptr);
+
+/**
+ * bna_rxq_pg_prod_ptr()
+ *
+ * Returns the producer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_rxq_entry *
+bna_rxq_pg_prod_ptr(const struct bna_rxq *q_ptr, unsigned int *ptr_range)
+{
+	struct bna_rxq_entry *qe_ptr;
+
+	BNA_RXQ_QPGE_PTR_GET(q_ptr->q.producer_index,
+			     &q_ptr->q, qe_ptr, *ptr_range);
+	return (qe_ptr);
+}
+
+/**
+ * bna_rxq_pg_cons_ptr()
+ *
+ * Returns the consumer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_rxq_entry *
+bna_rxq_pg_cons_ptr(const struct bna_rxq *q_ptr, unsigned int *ptr_range)
+{
+	struct bna_rxq_entry *qe_ptr;
+
+	BNA_RXQ_QPGE_PTR_GET(q_ptr->q.consumer_index,
+			     &q_ptr->q, qe_ptr, *ptr_range);
+	return (qe_ptr);
+}
+
+/**
+ * bna_rxq_prod_indx_doorbell()
+ *
+ * Informs Catapult ASIC about queued entries.
+ */
+static inline void
+bna_rxq_prod_indx_doorbell(const struct bna_rxq *q_ptr)
+{
+	bna_os_reg_write(q_ptr->doorbell,
+			 BNA_DOORBELL_Q_PRD_IDX(q_ptr->q.producer_index));
+}
+
+
+/**
+ * bna_rxq_stop()
+ *
+ * 	Stops the RxQ identified by the RxQ Id.
+ *	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	know if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the RxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e bna_rxq_stop(struct bna_dev_s *bna_dev, u32 rxq_id);
+
+/**
+ * bna_multi_rxq_stop()
+ *
+ * 	Stops the set of RxQs identified by rxq_id_mask
+ *	Should be called with a lock held
+ *	The driver should wait for the response to
+ *	know if the Q stop is successful or not.
+ *
+ * @param[in] q_id	- Id of the RxQ
+ *
+ * @return    BNA_OK in case of success, else BNA_FAIL
+ */
+enum bna_status_e bna_multi_rxq_stop(struct bna_dev_s *dev, u64 rxq_id_mask);
+/*
+ *
+ *
+ *   R X   C O M P L E T I O N   Q U E U E   D E F I N E S
+ *
+ *
+ */
+/* CQ Entry Flags */
+#define	BNA_CQ_EF_MAC_ERROR 	(1 <<  0)
+#define	BNA_CQ_EF_FCS_ERROR 	(1 <<  1)
+#define	BNA_CQ_EF_TOO_LONG  	(1 <<  2)
+#define	BNA_CQ_EF_FC_CRC_OK 	(1 <<  3)
+
+#define	BNA_CQ_EF_RSVD1 	(1 <<  4)
+#define	BNA_CQ_EF_L4_CKSUM_OK	(1 <<  5)
+#define	BNA_CQ_EF_L3_CKSUM_OK	(1 <<  6)
+#define	BNA_CQ_EF_HDS_HEADER	(1 <<  7)
+
+#define	BNA_CQ_EF_UDP   	(1 <<  8)
+#define	BNA_CQ_EF_TCP   	(1 <<  9)
+#define	BNA_CQ_EF_IP_OPTIONS	(1 << 10)
+#define	BNA_CQ_EF_IPV6  	(1 << 11)
+
+#define	BNA_CQ_EF_IPV4  	(1 << 12)
+#define	BNA_CQ_EF_VLAN  	(1 << 13)
+#define	BNA_CQ_EF_RSS   	(1 << 14)
+#define	BNA_CQ_EF_RSVD2 	(1 << 15)
+
+#define	BNA_CQ_EF_MCAST_MATCH   (1 << 16)
+#define	BNA_CQ_EF_MCAST 	(1 << 17)
+#define BNA_CQ_EF_BCAST 	(1 << 18)
+#define	BNA_CQ_EF_REMOTE 	(1 << 19)
+
+#define	BNA_CQ_EF_LOCAL		(1 << 20)
+#define bna_cq_e_flag_t u32
+
+
+/* CQ Entry Structure */
+struct bna_cq_entry {
+	bna_cq_e_flag_t flags;
+	u16 vlan_tag;
+	u16 length;
+	u32 rss_hash;
+	u8 valid;
+	u8 reserved1;
+	u8 reserved2;
+	u8 rxq_id;
+};
+
+
+/* CQ Structure */
+struct bna_cq {
+	struct bna_q q;
+};
+
+
+/* CQ Configuration */
+struct bna_cq_config {
+	struct bna_qpt qpt;
+	u16 ib_id;
+	u8 ib_seg_index;	/* index into IB segment */
+};
+
+/**
+ *  bna_cq_config()
+ *
+ *  For CQ "cq_id", it configures the Rx-Completion Queue as specified by
+ *  "cfg_ptr".
+ */
+void bna_cq_config(struct bna_dev_s *dev, struct bna_cq *q_ptr,
+		   unsigned int cq_id, const struct bna_cq_config *cfg_ptr);
+
+
+/**
+ * bna_cq_pg_prod_ptr()
+ *
+ * Returns the producer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_cq_entry *
+bna_cq_pg_prod_ptr(const struct bna_cq *q_ptr, unsigned int *ptr_range)
+{
+	struct bna_cq_entry *qe_ptr;
+
+	BNA_CQ_QPGE_PTR_GET(q_ptr->q.producer_index, &q_ptr->q, qe_ptr,
+			    *ptr_range);
+	return (qe_ptr);
+}
+
+/**
+ * bna_cq_pg_cons_ptr()
+ *
+ * Returns the consumer pointer and its range for the specified
+ * page-segmented
+ * queue.
+ */
+static inline struct bna_cq_entry *
+bna_cq_pg_cons_ptr(const struct bna_cq *q_ptr, unsigned int *ptr_range)
+{
+	struct bna_cq_entry *qe_ptr;
+
+	BNA_CQ_QPGE_PTR_GET(q_ptr->q.consumer_index, &q_ptr->q, qe_ptr,
+			    *ptr_range);
+	return (qe_ptr);
+}
+
+/*
+ *
+ *
+ *   T X   F U N C T I O N   D E F I N E S
+ *
+ *
+ */
+
+/**
+ * TxF Control Flags
+ *
+ * BNA_TXF_CF_VLAN_INSERT & BNA_TXF_CF_VLAN_ADMIT are only applicable when
+ * BNA_TXF_CF_VLAN_WI_BASED == 0 (i.e., VLAN MODE = By Tx-Function).
+ */
+#define	BNA_TXF_CF_VSWITCH_UCAST	(1 << 15)
+#define	BNA_TXF_CF_VSWITCH_MCAST	(1 << 14)
+#define	BNA_TXF_CF_VLAN_WI_BASED	(1 << 13)	/*  else Tx-Function Based */
+#define	BNA_TXF_CF_MAC_SA_CHECK 	(1 << 12)
+#define	BNA_TXF_CF_RSVD1		(1 << 11)
+#define	BNA_TXF_CF_VLAN_INSERT  (1 << 10)	/*  Insert function's VLAN ID */
+#define	BNA_TXF_CF_VLAN_ADMIT   (1 <<  9)	/*  process VLAN frames from Host */
+#define	BNA_TXF_CF_VLAN_FILTER  (1 <<  8)	/*  check against Rx VLAN Table */
+#define	BNA_TXF_CF_RSVD2		(0x7F << 1)
+#define	BNA_TXF_CF_ENABLE   		(1 <<  0)
+#define bna_txf_ctrl_flag_t u16
+
+
+/* TxF Configuration */
+struct bna_txf_config {
+	bna_txf_ctrl_flag_t flags;	/* OR of bna_txf_ctrl_flag_t */
+	u16 vlan;		/* valid when BNA_TXF_CF_VLAN_WI_BASED == 0 */
+	u8 rxf_id;		/* validate BNA_TXF_CF_VSWITCH_UCAST */
+};
+
+/**
+ * bna_txf_config_set()
+ *
+ *   For TxF "txf_id", it configures the TxF specified by "cfg_ptr" and
+ *   indicates to the statistics collector to collect statistics for this
+ *   Tx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id  - tx-function ID.
+ * @param[in]  cfg_ptr - pointer to tx-function configuration.
+ *
+ * @return void
+ */
+void bna_txf_config_set(struct bna_dev_s *dev, unsigned int txf_id,
+			const struct bna_txf_config *cfg_ptr);
+
+
+/**
+ * bna_txf_config_clear()
+ *
+ *   For TxF "txf_id", it clears its configuration and indicates to the
+ *   statistics collector to stop collecting statistics for this
+ *   Tx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id  - tx-function ID.
+ *
+ * @return void
+ */
+void bna_txf_config_clear(struct bna_dev_s *dev, unsigned int txf_id);
+
+
+
+/**
+ * bna_txf_disable()
+ *
+ *  Disables the Tx Function without clearing the configuration
+ *  Also disables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] txf_id	- Id of the Tx Function to be disabled
+ *
+ * @return void
+ */
+void bna_txf_disable(struct bna_dev_s *bna_dev, unsigned int txf_id);
+
+/**
+ * bna_txf_enable()
+ *
+ *  Enables the Tx Function
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] txf_id	- Id of the Tx Function to be disabled
+ *
+ * @return void
+ */
+void bna_txf_enable(struct bna_dev_s *bna_dev, unsigned int txf_id);
+
+/*
+ *
+ *
+ *   R X   I N D I R E C T I O N   T A B L E   D E F I N E S
+ *
+ *
+ */
+/**
+ *  Receive-Function RIT (Receive Indirection Table)
+ *
+ *  RIT is required by RSS.  However, in Catapult-LL, RIT must still be
+ *  present for non-RSS.  For non-RSS it just defines the unicast RxQs
+ *  associated to a function.
+ *
+ *  Each entry in the RIT holds two RxQs which are either Small and Large
+ *  Buffer RxQs or Header and Data Buffer RxQs.  "large_rxq_id" is used when
+ *  neither Small/Large or Header-Data Split is configured.
+ */
+struct bna_rit_entry {
+	u8 large_rxq_id;	/* used for either large or data buffers */
+	u8 small_rxq_id;	/* used for either small or header buffers */
+};
+
+
+/**
+ * bna_rit_config_set()
+ *
+ *   Loads RIT entries "rit" into RIT starting from RIT index "rit_offset".
+ *   Care must be taken not to overlap regions within the RIT.
+ *
+ * @param[in]  dev  	  - pointer to BNA device structure
+ * @param[in]  rit_offset - receive-indirection-table index.
+ * @param[in]  rit[]	  - receive-indirection-table segment.
+ * @param[in]  rit_size   - size of receive-indirection-table segment.
+ *
+ * @return void
+ */
+void bna_rit_config_set(struct bna_dev_s *dev, unsigned int rit_offset,
+			const struct bna_rit_entry rit[],
+			unsigned int rit_size);
+
+
+/*
+ *******************************************************************************
+ *
+ *   R X   F U N C T I O N   D E F I N E S
+ *
+ *******************************************************************************
+ */
+
+/* RxF RSS (Receive Side Scaling) */
+#define	BNA_RSS_V4_TCP  	(1 << 11)
+#define	BNA_RSS_V4_IP   	(1 << 10)
+#define	BNA_RSS_V6_TCP  	(1 <<  9)
+#define	BNA_RSS_V6_IP   	(1 <<  8)
+#define bna_rxf_rss_type_t u16
+
+#define BNA_RSS_HASH_KEY_LEN 10	/* in words */
+
+struct bna_rxf_rss {
+	bna_rxf_rss_type_t type;
+	u8 hash_mask;
+	u32 toeplitz_hash_key[BNA_RSS_HASH_KEY_LEN];
+};
+
+
+/* RxF HDS (Header Data Split) */
+#define	BNA_HDS_V4_TCP  	(1 << 11)
+#define	BNA_HDS_V4_UDP  	(1 << 10)
+#define	BNA_HDS_V6_TCP  	(1 <<  9)
+#define	BNA_HDS_V6_UDP  	(1 <<  8)
+#define	BNA_HDS_FORCED  	(1 <<  7)
+#define bna_rxf_hds_type_t u16
+
+
+#define BNA_HDS_FORCE_OFFSET_MIN	24	/* bytes */
+#define BNA_HDS_FORCE_OFFSET_MAX	60	/* bytes */
+
+
+struct bna_rxf_hds {
+	bna_rxf_hds_type_t type;	/* OR of bna_rxf_hds_type_t */
+	u8 header_size;		/* max header size for split */
+	u8 forced_offset;	/* HDS at a force offset */
+};
+
+
+/* RxF Control Flags */
+#define	BNA_RXF_CF_SM_LG_RXQ			(1 << 15)
+#define	BNA_RXF_CF_DEFAULT_VLAN 		(1 << 14)
+#define	BNA_RXF_CF_DEFAULT_FUNCTION_ENABLE	(1 << 13)
+#define	BNA_RXF_CF_VLAN_STRIP   		(1 << 12)
+#define	BNA_RXF_CF_RSS_ENABLE   		(1 <<  8)
+#define bna_rxf_ctrl_flag_t u16
+
+
+/* RxF Configuration Structure */
+struct bna_rxf_config {
+	u8 rit_offset;		/* offset into RIT */
+	u8 mcast_rxq_id;	/* multicast RxQ ID */
+	u16 default_vlan;	/* default VLAN for untagged frames */
+	bna_rxf_ctrl_flag_t flags;	/* OR of bna_rxf_ctrl_flag_t */
+	struct bna_rxf_hds hds;	/* valid when BNA_RXF_SM_LG_RXQ == 0 */
+	struct bna_rxf_rss rss;	/* valid when BNA_RXF_RSS_ENABLE == 1 */
+};
+
+
+/**
+ * bna_rxf_config_set()
+ *
+ *   For RxF "rxf_id", it configures RxF based on "cfg_ptr", and indicates
+ *   to the statistics collector to collect statistics for this Rx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  cfg_ptr - pointer to rx-function configuration.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_config_set(struct bna_dev_s *dev,
+				     unsigned int rxf_id,
+				     const struct bna_rxf_config *cfg_ptr);
+
+
+/**
+ * bna_rxf_config_clear()
+ *
+ *   For RxF "rxf_id", it clear its configuration and indicates to the
+ *   statistics collector to stop collecting statistics for this
+ *   Rx-Function.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ *
+ * @return  void
+ */
+void bna_rxf_config_clear(struct bna_dev_s *dev, unsigned int rxf_id);
+
+/**
+ * bna_multi_rxf_active()
+ *
+ *  Disables/Enables the Rx Function without clearing the configuration
+ *  Also disables/enables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] rxf_id	- Id of the Rx Function to be disabled
+ * @param[in] enable	- 1 = enable, 0 = disable
+ *
+ * @return BNA_OK if mbox command succeeded else BNA_FAIL
+ */
+enum bna_status_e bna_multi_rxf_active(struct bna_dev_s *dev, u64 rxf_id_mask,
+				       u8 enable);
+/**
+ * bna_rxf_disable()
+ *
+ *  Disables the Rx Function without clearing the configuration
+ *  Also disables collection of statistics.
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] rxf_id	- Id of the Rx Function to be disabled
+ *
+ * @return BNA_OK if mbox command succeeded else BNA_FAIL
+ */
+enum bna_status_e bna_rxf_disable(struct bna_dev_s *bna_dev,
+				  unsigned int rxf_id);
+
+/**
+ * bna_multi_rxf_disable()
+ *
+ *  Disables multiple Rx Functions as per the mask
+ *  Also disables collection of statistics.
+ *
+ * @param[in] dev 		- Pointer to BNA device handle
+ * @param[in] rxf_id_mask    	- Mask of the functions to be
+				  disabled
+ *
+ * @return    BNA_OK if mbox command succeeded, else BNA_FAIL
+ */
+#define bna_multi_rxf_disable(dev, rxf_id_mask)	\
+		bna_multi_rxf_active((dev), (rxf_id_mask), 0)
+
+/**
+ * bna_rxf_enable()
+ *
+ *  Enables the Rx Function
+ *
+ * @param[in] bna_dev   - Pointer to BNA BNA device handle
+ * @param[in] rxf_id	- Id of the Rx Function to be disabled
+ *
+ * @return BNA_OK if mbox command succeeded else BNA_FAIL
+ */
+enum bna_status_e bna_rxf_enable(struct bna_dev_s *bna_dev,
+				 unsigned int rxf_id);
+
+/**
+ * bna_multi_rxf_enable()
+ *
+ *  Enables multiple Rx Functions as per the mask
+ *  Also enables collection of statistics.
+ *
+ * @param[in] dev               - Pointer to BNA device handle
+ * @param[in] rxf_id_mask       - Mask of the functions to be
+                                  enabled
+ *
+ * @return    BNA_OK if mbox command succeeded, else BNA_FAIL
+ */
+#define bna_multi_rxf_enable(dev, rxf_id_mask)	\
+		bna_multi_rxf_active((dev), (rxf_id_mask), 1)
+
+
+/* TODO : Delete when windows migration is complete */
+void bna_rxf_disable_old(struct bna_dev_s *dev, unsigned int rxf_id);
+void bna_rxf_enable_old(struct bna_dev_s *dev, unsigned int rxf_id,
+			const struct bna_rxf_config *cfg_ptr);
+
+
+/**
+ * bna_rxf_ucast_mac_get()
+ *
+ *  For RxF "rxf_id", it overwrites the burnt-in unicast MAC with
+ *  the one specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID
+ * @param[in]  entry   - offset into UCAM to read
+ * @param[in]  mac_addr_ptr - pointer to mac adddress to set
+ *
+ * @return void
+ */
+void
+  bna_rxf_ucast_mac_get(struct bna_dev_s *bna_dev, unsigned int *rxf_id,
+			unsigned int entry, const bna_mac_t * mac_addr_ptr);
+
+/**
+ * bna_rxf_ucast_mac_set()
+ *
+ *   For RxF "rxf_id", it overwrites the burnt-in unicast MAC with
+ *   the one specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to unicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_ucast_mac_set(struct bna_dev_s *dev,
+					unsigned int rxf_id,
+					const bna_mac_t * mac_ptr);
+
+
+/**
+ * bna_rxf_ucast_mac_add()
+ *
+ *   For RxF "rxf_id", it adds the unicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to unicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_ucast_mac_add(struct bna_dev_s *dev,
+					unsigned int rxf_id,
+					const bna_mac_t * mac_ptr);
+
+
+/**
+ * bna_rxf_ucast_mac_del()
+ *
+ *   For RxF "rxf_id", it deletes the unicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to unicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_ucast_mac_del(struct bna_dev_s *dev,
+					unsigned int rxf_id,
+					const bna_mac_t * mac_ptr);
+
+
+/**
+ * bna_rxf_mcast_mac_add()
+ *
+ *   For RxF "rxf_id", it adds the multicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to multicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_mcast_mac_add(struct bna_dev_s *dev,
+					unsigned int rxf_id,
+					const bna_mac_t * mac_ptr);
+
+
+/**
+ * bna_rxf_mcast_mac_del()
+ *
+ *   For RxF "rxf_id", it deletes the multicast MAC specified by "mac_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_ptr - pointer to multicast MAC address.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_mcast_mac_del(struct bna_dev_s *dev,
+					unsigned int rxf_id,
+					const bna_mac_t * mac_ptr);
+
+/**
+ *  bna_rxf_broadcast()
+ *
+ *  For RxF "rxf_id", it enables/disables the broadcast address.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable broadcast address
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+  bna_rxf_broadcast(struct bna_dev_s *bna_dev, unsigned int rxf_id,
+		    enum bna_enable_e enable);
+
+/**
+ * bna_rxf_mcast_mac_set_list()
+ *
+ *  For RxF "rxf_id", it sets the multicast MAC addresses
+ *  specified by "mac_addr_ptr". The function first deletes the
+ *  MAC addresses in the existing list that is not found in the
+ *  new list. It then adds the new addresses that ar ein the new
+ *  list but not in the old list. It then replaces the old list
+ *  with the new list in the bna_dev structure.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  mac_addr_ptr - pointer to the list of mac
+ *  	 adddresses to set
+ * @param[in]  mac_addr_num - number of mac addresses in the
+ *  	 list
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e
+  bna_rxf_mcast_mac_set_list(struct bna_dev_s *bna_dev, unsigned int rxf_id,
+			     const bna_mac_t * mac_addr_ptr,
+			     unsigned int mac_addr_num);
+
+/**
+ * bna_mcast_mac_reset_list()
+ *
+ *  Resets the multicast MAC address list kept by driver.
+ *  Called when the hw gets reset.
+ *
+ * @param[in]  dev  - pointer to BNA device structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_mcast_mac_reset_list(struct bna_dev_s *bna_dev);
+
+/**
+ * bna_rxf_mcast_filter()
+ *
+ *   For RxF "rxf_id", it enables/disables the Multicast Filter.
+ *   Disabling the Multicast Filter allows reception of any multicast frame.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable Multicast Filtering.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_mcast_filter(struct bna_dev_s *dev,
+				       unsigned int rxf_id,
+				       enum bna_enable_e enable);
+
+/**
+ * bna_rxf_mcast_del_all()
+ *
+ *   For RxF "rxf_id", it clears the MCAST cam and MVT.
+ *   This functionality is required by some of the drivers.
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_mcast_del_all(struct bna_dev_s *dev,
+					unsigned int rxf_id);
+
+
+/**
+ * bna_rxf_vlan_add()
+ *
+ *   For RxF "rxf_id", it adds this function as a member of the
+ *   specified "vlan_id".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  vlan_id - VLAN ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_rxf_vlan_add(struct bna_dev_s *dev, unsigned int rxf_id,
+		      unsigned int vlan_id);
+
+
+/**
+ * bna_rxf_vlan_del()
+ *
+ *   For RxF "rxf_id", it removes this function as a member of the
+ *   specified "vlan_id".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  rxf_id  - rx-function ID.
+ * @param[in]  vlan_id - VLAN ID.
+ *
+ * @return void
+ */
+void bna_rxf_vlan_del(struct bna_dev_s *dev, unsigned int rxf_id,
+		      unsigned int vlan_id);
+
+
+/**
+ * bna_rxf_vlan_filter()
+ *
+ *   For RxF "rxf_id", it enables/disables the VLAN filter.
+ *   Disabling the VLAN Filter allows reception of any VLAN-tagged frame.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable VLAN Filtering.
+ *
+ * @return void
+ */
+void bna_rxf_vlan_filter(struct bna_dev_s *dev, unsigned int rxf_id,
+			 enum bna_enable_e enable);
+
+/**
+ * bna_rxf_vlan_del_all()
+ *
+ *   For RxF "rxf_id", it clears all the VLANs.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+
+ *
+ * @return void
+ */
+void bna_rxf_vlan_del_all(struct bna_dev_s *bna_dev, unsigned int rxf_id);
+
+/**
+ * bna_rxf_promiscuous_mode()
+ *
+ *   For RxF "rxf_id", it enables/disables promiscuous-mode.
+ *   Only one RxF is allowed to be in promiscuous-mode, and will only disable
+ *   the promiscuous-mode if the RxF ID is the one in promiscuous-mode.
+ *   Must be called after the RxF has been configured.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable promiscuous-mode..
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_promiscuous(struct bna_dev_s *dev,
+				      unsigned int rxf_id,
+				      enum bna_enable_e enable);
+
+
+/* FIXME : Remove BNA_VM_OS */
+#ifdef BNA_VM_OS
+/**
+ * bna_rxf_default_mode()
+ *
+ *   For RxF "rxf_id", it enables/disables default mode.
+ *   Only one RxF is allowed to be in default-mode, and will only disable
+ *   the default-mode if the RxF ID is the one in default-mode.
+ *   Must be called after the RxF has been configured.
+ *   Must remove all unicast MAC associated to this RxF.
+ *
+ * @param[in]  dev    - pointer to BNA device structure
+ * @param[in]  rxf_id - rx-function ID.
+ * @param[in]  enable - enable/disable default mode..
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_default_mode(struct bna_dev_s *dev,
+				       unsigned int rxf_id,
+				       enum bna_enable_e enable);
+#endif /* BNA_VM_OS */
+
+
+struct bna_cee_stats_req_arg_s {
+	void *buffer;
+	void *bnad;
+};
+
+#define bna_cee_stats_req_arg_t struct bna_cee_stats_req_arg_s
+struct bna_cee_cfg_req_arg_s {
+	void *buffer;
+	void *bnad;
+};
+#define bna_cee_cfg_req_arg_t struct bna_cee_cfg_req_arg_s
+
+
+/**
+ * bna_rxf_frame_stats_get()
+ *
+ *   For RxF "rxf_id", it loads frame statistics into "stats_ptr".
+ *
+ * @param[in]  dev  	 - pointer to BNA device structure
+ * @param[in]  rxf_id    - rx-function ID.
+ * @param[out] stats_ptr - pointer to rx-function statistics structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_rxf_frame_stats_get(struct bna_dev_s *dev, unsigned int rxf_id,
+			     struct bna_stats_rxf **stats_ptr);
+
+/**
+ * bna_txf_frame_stats_get()
+ *
+ *   For TxF "txf_id", it loads frame statistics into "stats_ptr".
+ *
+ * @param[in]  dev     - pointer to BNA device structure
+ * @param[in]  txf_id    - tx-function ID.
+ * @param[out] stats_ptr - pointer to tx-function statistics structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_txf_frame_stats_get(struct bna_dev_s *dev, unsigned int txf_id,
+			     struct bna_stats_txf **stats_ptr);
+
+/**
+ *  bna_mac_rx_stats_get()
+ *
+ *  Loads MAC Rx statistics into "stats_ptr".
+ *
+ * @param[in]  dev	 - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_mac_rx_stats_get(struct bna_dev_s *bna_dev,
+			  struct cna_stats_mac_rx **stats_ptr);
+
+/**
+ *  bna_mac_tx_stats_get()
+ *
+ *  Loads MAC Tx statistics into "stats_ptr".
+ *
+ * @param[in]  dev	 - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_mac_tx_stats_get(struct bna_dev_s *bna_dev,
+			  struct cna_stats_mac_tx **stats_ptr);
+
+/**
+ *  bna_all_stats_get()
+ *
+ *  Loads all statistics into "stats_ptr".
+ *
+ * @param[in]  dev	 - pointer to BNA device structure
+
+ * @param[out]  stats_ptr - pointer to stats structure
+ *
+ * @return void
+ */
+void bna_all_stats_get(struct bna_dev_s *bna_dev, struct bna_stats **stats_ptr);
+/**
+ * bna_stats_get()
+ *
+ *   Get the statistics from the device. This function needs to
+ *   be scheduled every second to get periodic update of the
+ *   statistics data from hardware.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure.
+ *
+ * @return void
+ */
+enum bna_status_e bna_stats_get(struct bna_dev_s *dev);
+
+/**
+ * bna_stats_clear()
+ *
+ *   Clear the statistics in the device.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_stats_clear(struct bna_dev_s *bna_dev);
+
+/**
+ * bna_rxf_stats_clear()
+ *
+ *   Clear the statistics for specified txf.
+ *
+ * @param[in]   dev        - pointer to BNA device structure.
+ * @param[in]  rxf_id      - rx-function ID.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_rxf_stats_clear(struct bna_dev_s *dev,
+				      unsigned int rxf_id);
+
+/**
+ * bna_lldp_stats_clear()
+ *
+ *   Clear the lldp-dcbcx statistics in the device.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_lldp_stats_clear(struct bna_dev_s *bna_dev);
+
+/**
+ * bna_get_cfg_req()
+ *
+ *   Gets the LLDP-DCBCXP Config from the f/w.
+ *
+ * @param[in]   dev 	      - pointer to BNA device structure.
+ * @param[in]   dma_addr_bna  - dma address to return the config.
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_get_cfg_req(struct bna_dev_s *bna_dev,
+				  struct bna_dma_addr *dma_addr_bna);
+
+/**
+
+* bna_get_cee_stats_req()
+*
+*   Gets the LLDP-DCBCXP stats from the f/w.
+*
+* @param[in]   dev           - pointer to BNA device structure.
+* @param[in]   dma_addr_bna  - dma address to return the config.
+*
+* @return BNA_OK   - successful
+* @return BNA_FAIL - failed on sanity checks.
+*/
+enum bna_status_e bna_get_cee_stats_req(struct bna_dev_s *bna_dev,
+					struct bna_dma_addr *dma_addr_bna);
+
+/**
+ * bna_stats_process()
+ *
+ *   Process the statistics data DMAed from the device. This
+ *   function needs to be scheduled upon getting an asynchronous
+ *   notification from the firmware.
+ *
+ * @param[in]   dev 	  - pointer to BNA device structure.
+ *
+ * @return void
+ */
+void bna_stats_process(struct bna_dev_s *bna_dev);
+
+/**
+ * bna_init()
+ *
+ *   Called by the driver during initialization. The driver is
+ *   expected to allocate struct bna_dev_s structure for the BNA layer.
+ *   Should be called with the lock held.
+ *
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ * 			     allocated by the calling driver
+ * @param[in]  bar0 	   - BAR0 value
+ * @param[in]  stats	   - pointer to stats host buffer
+ * @param[in]  stats_dma   - pointer to DMA value for stats
+ * @param[in]  trcmod      - pointer to struct bfa_trc_mod_s
+ *			     (for Interrupt Moderation)
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+void bna_init(struct bna_dev_s *bna_handle, void *bar0,
+	      void *stats, struct bna_dma_addr stats_dma,
+	      struct bfa_trc_mod_s *trcmod);
+
+/**
+ * bna_uninit()
+ *
+ *   Called by the driver during removal/unload.
+ *
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ * 			     allocated by the calling driver
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_uninit(void *bna_handle);
+
+/**
+ * bna_cleanup()
+ *
+ *   Called by the driver from the hb_fail callback to
+ *   to let bna do the cleanup.
+ *   This should be called before driver frees memory.
+ *   Should be called with the lock held.
+ *
+ * @param[in]  bna_handle  - pointer to BNA device structure
+ * 			     allocated by the calling driver
+ *
+ * @return BNA_OK   - successful
+ * @return BNA_FAIL - failed on sanity checks.
+ */
+enum bna_status_e bna_cleanup(void *bna_handle);
+
+#endif /* __BNA_H__ */
