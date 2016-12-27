From: David VomLehn <vomlehn@texas.net>
Subject: [PATCH 10/12] Hardware interface and utility functions
Date: Tue, 27 Dec 2016 05:17:46 -0800
Message-ID: <7ef8eca5f4c5cc3d28992d820a7a1d9e92590bb2.1482844668.git.vomlehn@texas.net>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
Cc: Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        David VomLehn <vomlehn@texas.net>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda5.aus1.datafoundry.com ([209.99.124.136]:38449 "EHLO
        barracuda.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1754785AbcL0Nbw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2016 08:31:52 -0500
In-Reply-To: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net>
In-Reply-To: <9936fa643d5f6a8f29b069847d052fcf5dc23513.1482844668.git.vomlehn@texas.net>
References: <9cc1565a3a398b4f70248ca98d12991071142682.1482844668.git.vomlehn@texas.net> <67f8be9c3f6a4fede2eefaa4a3c45f9dbaf9b411.1482844668.git.vomlehn@texas.net> <8aac6eaf6d90651f279392f301de85e6ab72a3cb.1482844668.git.vomlehn@texas.net> <206766987286d2c30b7f674dec4aafe1ed70a21b.1482844668.git.vomlehn@texas.net> <122d7e0633e8a8ddfbb0c233d6896254b2fa3eef.1482844668.git.vomlehn@texas.net> <726fb213b0f282fc4a6b997721c3022551783fe6.1482844668.git.vomlehn@texas.net> <61665299e584052d30bd1d623ebd4b138dd90694.1482844668.git.vomlehn@texas.net> <36c7868a58795880d5f6111e523c0136ace2ca91.1482844668.git.vomlehn@texas.net> <9936fa643d5f6a8f29b069847d052fcf5dc23513.1482844668.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add functions to interface with the hardware and some utility functions.

Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/atlantic/aq_hw.h     | 170 +++++++++++++++++++++
 .../net/ethernet/aquantia/atlantic/aq_hw_utils.c   |  70 +++++++++
 .../net/ethernet/aquantia/atlantic/aq_hw_utils.h   |  54 +++++++
 3 files changed, 294 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_hw.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.h

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_hw.h b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
new file mode 100644
index 0000000..15e35b1
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
@@ -0,0 +1,170 @@
+/*
+ * Aquantia Corporation Network Driver
+ * Copyright (C) 2014-2016 Aquantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/*
+ * File aq_hw.h: Declaraion of abstract interface for NIC hardware specific
+ * functions.
+ */
+
+#ifndef AQ_HW_H
+#define AQ_HW_H
+
+#include "aq_common.h"
+
+/* NIC H/W capabilities */
+struct aq_hw_caps_s {
+	u64 hw_features;
+	u64 link_speed_msk;
+	unsigned int hw_priv_flags;
+	u32 rxds;
+	u32 txds;
+	u32 txhwb_alignment;
+	u32 irq_mask;
+	u32 vecs;
+	u32 mtu;
+	u32 mac_regs_count;
+	u8 ports;
+	u8 msix_irqs;
+	u8 tcs;
+	u8 rxd_alignment;
+	u8 rxd_size;
+	u8 txd_alignment;
+	u8 txd_size;
+	u8 tx_rings;
+	u8 rx_rings;
+	bool flow_control;
+	bool is_64_dma;
+};
+
+struct aq_hw_link_status_s {
+	u64 bps;
+};
+
+#define AQ_HW_POWER_STATE_D0   0U
+#define AQ_HW_POWER_STATE_D3   3U
+
+#define AQ_HW_FLAG_STARTED     0x00000004U
+#define AQ_HW_FLAG_STOPPING    0x00000008U
+#define AQ_HW_FLAG_RESETTING   0x00000010U
+#define AQ_HW_FLAG_CLOSING     0x00000020U
+#define AQ_HW_LINK_DOWN        0x04000000U
+#define AQ_HW_FLAG_ERR_UNPLUG  0x40000000U
+#define AQ_HW_FLAG_ERR_HW      0x80000000U
+
+#define AQ_HW_FLAG_ERRORS      (AQ_HW_FLAG_ERR_HW | AQ_HW_FLAG_ERR_UNPLUG)
+
+struct aq_hw_s {
+	AQ_OBJ_HEADER;
+	struct aq_nic_cfg_s *aq_nic_cfg;
+	struct aq_pci_func_s *aq_pci_func;
+	void __iomem *mmio;
+	unsigned int not_ff_addr;
+	struct aq_hw_link_status_s aq_link_status;
+};
+
+struct aq_ring_s;
+struct aq_ring_param_s;
+struct aq_nic_cfg_s;
+struct sk_buff;
+
+struct aq_hw_ops {
+	struct aq_hw_s *(*create)(struct aq_pci_func_s *aq_pci_func,
+				  unsigned int port, struct aq_hw_ops *ops);
+
+	void (*destroy)(struct aq_hw_s *self);
+
+	int (*get_hw_caps)(struct aq_hw_s *self,
+			   struct aq_hw_caps_s *aq_hw_caps);
+
+	int (*hw_ring_tx_xmit)(struct aq_hw_s *self, struct aq_ring_s *aq_ring,
+			       unsigned int frags);
+
+	int (*hw_ring_rx_receive)(struct aq_hw_s *self,
+				  struct aq_ring_s *aq_ring);
+
+	int (*hw_ring_rx_fill)(struct aq_hw_s *self, struct aq_ring_s *aq_ring,
+			       unsigned int sw_tail_old);
+
+	int (*hw_ring_tx_head_update)(struct aq_hw_s *self,
+				      struct aq_ring_s *aq_ring);
+
+	int (*hw_get_mac_permanent)(struct aq_hw_s *self, u8 *mac);
+
+	int (*hw_set_mac_address)(struct aq_hw_s *self, u8 *mac_addr);
+
+	int (*hw_get_link_status)(struct aq_hw_s *self,
+				  struct aq_hw_link_status_s *link_status);
+
+	int (*hw_set_link_speed)(struct aq_hw_s *self, u32 speed);
+
+	int (*hw_reset)(struct aq_hw_s *self);
+
+	int (*hw_init)(struct aq_hw_s *self, struct aq_nic_cfg_s *aq_nic_cfg,
+		       u8 *mac_addr);
+
+	int (*hw_start)(struct aq_hw_s *self);
+
+	int (*hw_stop)(struct aq_hw_s *self);
+
+	int (*hw_ring_tx_init)(struct aq_hw_s *self, struct aq_ring_s *aq_ring,
+			       struct aq_ring_param_s *aq_ring_param);
+
+	int (*hw_ring_tx_start)(struct aq_hw_s *self,
+				struct aq_ring_s *aq_ring);
+
+	int (*hw_ring_tx_stop)(struct aq_hw_s *self,
+			       struct aq_ring_s *aq_ring);
+
+	int (*hw_ring_rx_init)(struct aq_hw_s *self,
+			       struct aq_ring_s *aq_ring,
+			       struct aq_ring_param_s *aq_ring_param);
+
+	int (*hw_ring_rx_start)(struct aq_hw_s *self,
+				struct aq_ring_s *aq_ring);
+
+	int (*hw_ring_rx_stop)(struct aq_hw_s *self,
+			       struct aq_ring_s *aq_ring);
+
+	int (*hw_irq_enable)(struct aq_hw_s *self, u64 mask);
+
+	int (*hw_irq_disable)(struct aq_hw_s *self, u64 mask);
+
+	int (*hw_irq_read)(struct aq_hw_s *self, u64 *mask);
+
+	int (*hw_packet_filter_set)(struct aq_hw_s *self,
+				    unsigned int packet_filter);
+
+	int (*hw_multicast_list_set)(struct aq_hw_s *self,
+				     u8 ar_mac[AQ_CFG_MULTICAST_ADDRESS_MAX]
+				     [ETH_ALEN],
+				     u32 count);
+
+	int (*hw_interrupt_moderation_set)(struct aq_hw_s *self,
+					   bool itr_enabled);
+
+	int (*hw_rss_set)(struct aq_hw_s *self,
+			  struct aq_receive_scale_parameters *rss_params);
+
+	int (*hw_rss_hash_set)(struct aq_hw_s *self,
+			       struct aq_receive_scale_parameters *rss_params);
+
+	int (*hw_get_regs)(struct aq_hw_s *self,
+			   struct aq_hw_caps_s *aq_hw_caps, u32 *regs_buff);
+
+	int (*hw_get_hw_stats)(struct aq_hw_s *self, u64 *data,
+			       unsigned int *p_count);
+
+	int (*hw_get_fw_version)(struct aq_hw_s *self, u32 *fw_version);
+
+	int (*hw_deinit)(struct aq_hw_s *self);
+
+	int (*hw_set_power)(struct aq_hw_s *self, unsigned int power_state);
+};
+
+#endif /* AQ_HW_H */
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.c b/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.c
new file mode 100644
index 0000000..d340f95
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.c
@@ -0,0 +1,70 @@
+/*
+ * Aquantia Corporation Network Driver
+ * Copyright (C) 2014-2016 Aquantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/*
+ * File aq_hw_utils.c: Definitions of helper functions used across
+ * hardware layer.
+ */
+
+#include "aq_hw_utils.h"
+#include "aq_hw.h"
+
+void aq_hw_utils_write_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk,
+			       u32 shft, u32 val)
+{
+	if (msk ^ ~0) {
+		u32 reg_old, reg_new;
+
+		reg_old = aq_hw_read_reg(aq_hw, addr);
+		reg_new = (reg_old & (~msk)) | (val << shft);
+
+		if (reg_old != reg_new)
+			aq_hw_write_reg(aq_hw, addr, reg_new);
+	} else {
+		aq_hw_write_reg(aq_hw, addr, val);
+	}
+}
+
+u32 aq_hw_utils_read_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk,
+			     u32 shift)
+{
+	return ((aq_hw_read_reg(aq_hw, addr) & msk) >> shift);
+}
+
+u32 aq_hw_read_reg(struct aq_hw_s *hw, u32 reg)
+{
+	u32 value = readl(hw->mmio + reg);
+
+	if ((~0U) == value && (~0U) == readl(hw->mmio + hw->not_ff_addr))
+		AQ_OBJ_SET(hw, AQ_HW_FLAG_ERR_UNPLUG);
+
+	return value;
+}
+
+inline void aq_hw_write_reg(struct aq_hw_s *hw, u32 reg, u32 value)
+{
+	writel(value, hw->mmio + reg);
+}
+
+int aq_hw_err_from_flags(struct aq_hw_s *hw)
+{
+	int err = 0;
+
+	if (AQ_OBJ_TST(hw, AQ_HW_FLAG_ERR_UNPLUG)) {
+		err = -ENXIO;
+		goto err_exit;
+	}
+	if (AQ_OBJ_TST(hw, AQ_HW_FLAG_ERR_HW)) {
+		err = -EIO;
+		goto err_exit;
+	}
+
+err_exit:
+	return err;
+}
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.h b/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.h
new file mode 100644
index 0000000..7a0eaff
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.h
@@ -0,0 +1,54 @@
+/*
+ * Aquantia Corporation Network Driver
+ * Copyright (C) 2014-2016 Aquantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/*
+ * File aq_hw_utils.h: Declaration of helper functions used across hardware
+ * layer.
+ */
+
+#ifndef AQ_HW_UTILS_H
+#define AQ_HW_UTILS_H
+
+#include "aq_common.h"
+
+#ifndef MBIT
+#define MBIT ((u64)1000000U)
+#define GBIT ((u64)1000000000U)
+#endif
+
+#ifndef HIDWORD
+#define LODWORD(_qw)    ((u32)(_qw))
+#define HIDWORD(_qw)    ((u32)(((_qw) >> 32) & 0xffffffff))
+#endif
+
+#define AQ_HW_SLEEP(_US_) mdelay(_US_)
+
+#define AQ_HW_WAIT_FOR(_B_, _US_, _N_) \
+do { \
+	unsigned int AQ_HW_WAIT_FOR_i; \
+	for (AQ_HW_WAIT_FOR_i = _N_; (!(_B_)) && (AQ_HW_WAIT_FOR_i);\
+	--AQ_HW_WAIT_FOR_i) {\
+		udelay(_US_); \
+	} \
+	if (!AQ_HW_WAIT_FOR_i) {\
+		err = ETIME; \
+	} \
+} while (0)
+
+struct aq_hw_s;
+
+void aq_hw_utils_write_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk,
+			       u32 shft, u32 val);
+u32 aq_hw_utils_read_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk,
+			     u32 shift);
+u32 aq_hw_read_reg(struct aq_hw_s *hw, u32 reg);
+inline void aq_hw_write_reg(struct aq_hw_s *hw, u32 reg, u32 value);
+int aq_hw_err_from_flags(struct aq_hw_s *hw);
+
+#endif /* AQ_HW_UTILS_H */
-- 
2.7.4
