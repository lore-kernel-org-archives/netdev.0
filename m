From: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Subject: [PATCH stable v1 10/13] net: ethernet: aquantia: Hardware interface and utility functions
Date: Sat, 28 Jan 2017 21:09:10 -0800
Message-ID: <c6734891fa3538615f4137f1ac3938244b7d1b43.1485665881.git.vomlehn@texas.net>
References: <cover.1485665881.git.vomlehn@texas.net>
Cc: "David S . Miller" <davem@davemloft.net>,
        Simon Edelhaus <Simon.Edelhaus@aquantia.com>,
        Alexander Loktionov <Alexander.Loktionov@aquantia.com>,
        Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>,
        Pavel Belous <Pavel.Belous@aquantia.com>,
        Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
To: netdev@vger.kernel.org, David VomLehn <vomlehn@texas.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from barracuda1.aus1.datafoundry.com ([209.99.124.132]:38100 "EHLO
        milter.aus.datafoundry.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751230AbdA2Fp0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 29 Jan 2017 00:45:26 -0500
In-Reply-To: <cover.1485665881.git.vomlehn@texas.net>
In-Reply-To: <cover.1485665881.git.vomlehn@texas.net>
References: <cover.1485665881.git.vomlehn@texas.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David VomLehn <vomlehn@texas.net>

Add functions to interface with the hardware and some utility functions.

Signed-off-by: Alexander Loktionov <Alexander.Loktionov@aquantia.com>
Signed-off-by: Dmitrii Tarakanov <Dmitrii.Tarakanov@aquantia.com>
Signed-off-by: Pavel Belous <Pavel.Belous@aquantia.com>
Signed-off-by: Dmitry Bezrukov <Dmitry.Bezrukov@aquantia.com>
Signed-off-by: David M. VomLehn <vomlehn@texas.net>
---
 drivers/net/ethernet/aquantia/atlantic/aq_hw.h     | 177 +++++++++++++++++++++
 .../net/ethernet/aquantia/atlantic/aq_hw_utils.c   |  68 ++++++++
 .../net/ethernet/aquantia/atlantic/aq_hw_utils.h   |  47 ++++++
 3 files changed, 292 insertions(+)
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_hw.h
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.c
 create mode 100644 drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.h

diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_hw.h b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
new file mode 100644
index 0000000..fce0fd3
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_hw.h
@@ -0,0 +1,177 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_hw.h: Declaraion of abstract interface for NIC hardware specific
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
+	u32 fw_ver_expected;
+};
+
+struct aq_hw_link_status_s {
+	unsigned int mbps;
+};
+
+#define AQ_HW_IRQ_INVALID 0U
+#define AQ_HW_IRQ_LEGACY  1U
+#define AQ_HW_IRQ_MSI     2U
+#define AQ_HW_IRQ_MSIX    3U
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
+	struct aq_obj_s header;
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
+	int (*hw_get_mac_permanent)(struct aq_hw_s *self,
+				    struct aq_hw_caps_s *aq_hw_caps,
+				    u8 *mac);
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
+			  struct aq_rss_parameters *rss_params);
+
+	int (*hw_rss_hash_set)(struct aq_hw_s *self,
+			       struct aq_rss_parameters *rss_params);
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
index 0000000..5f13465
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.c
@@ -0,0 +1,68 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_hw_utils.c: Definitions of helper functions used across
+ * hardware layer.
+ */
+
+#include "aq_hw_utils.h"
+#include "aq_hw.h"
+
+void aq_hw_write_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk,
+			 u32 shift, u32 val)
+{
+	if (msk ^ ~0) {
+		u32 reg_old, reg_new;
+
+		reg_old = aq_hw_read_reg(aq_hw, addr);
+		reg_new = (reg_old & (~msk)) | (val << shift);
+
+		if (reg_old != reg_new)
+			aq_hw_write_reg(aq_hw, addr, reg_new);
+	} else {
+		aq_hw_write_reg(aq_hw, addr, val);
+	}
+}
+
+u32 aq_hw_read_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk, u32 shift)
+{
+	return ((aq_hw_read_reg(aq_hw, addr) & msk) >> shift);
+}
+
+u32 aq_hw_read_reg(struct aq_hw_s *hw, u32 reg)
+{
+	u32 value = readl(hw->mmio + reg);
+
+	if ((~0U) == value && (~0U) == readl(hw->mmio + hw->not_ff_addr))
+		aq_utils_obj_set(&hw->header.flags, AQ_HW_FLAG_ERR_UNPLUG);
+
+	return value;
+}
+
+void aq_hw_write_reg(struct aq_hw_s *hw, u32 reg, u32 value)
+{
+	writel(value, hw->mmio + reg);
+}
+
+int aq_hw_err_from_flags(struct aq_hw_s *hw)
+{
+	int err = 0;
+
+	if (aq_utils_obj_test(&hw->header.flags, AQ_HW_FLAG_ERR_UNPLUG)) {
+		err = -ENXIO;
+		goto err_exit;
+	}
+	if (aq_utils_obj_test(&hw->header.flags, AQ_HW_FLAG_ERR_HW)) {
+		err = -EIO;
+		goto err_exit;
+	}
+
+err_exit:
+	return err;
+}
diff --git a/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.h b/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.h
new file mode 100644
index 0000000..78fcc0c
--- /dev/null
+++ b/drivers/net/ethernet/aquantia/atlantic/aq_hw_utils.h
@@ -0,0 +1,47 @@
+/*
+ * aQuantia Corporation Network Driver
+ * Copyright (C) 2014-2017 aQuantia Corporation. All rights reserved
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms and conditions of the GNU General Public License,
+ * version 2, as published by the Free Software Foundation.
+ */
+
+/* File aq_hw_utils.h: Declaration of helper functions used across hardware
+ * layer.
+ */
+
+#ifndef AQ_HW_UTILS_H
+#define AQ_HW_UTILS_H
+
+#include "aq_common.h"
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
+void aq_hw_write_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk,
+			 u32 shift, u32 val);
+u32 aq_hw_read_reg_bit(struct aq_hw_s *aq_hw, u32 addr, u32 msk, u32 shift);
+u32 aq_hw_read_reg(struct aq_hw_s *hw, u32 reg);
+void aq_hw_write_reg(struct aq_hw_s *hw, u32 reg, u32 value);
+int aq_hw_err_from_flags(struct aq_hw_s *hw);
+
+#endif /* AQ_HW_UTILS_H */
-- 
2.9.3
