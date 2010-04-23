From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
Subject: [PATCH 5/7] Topcliff GbE: Add The Hardware layer codes [1/2]
Date: Fri, 23 Apr 2010 21:00:58 +0900
Message-ID: <003401cae2dd$20a8e5b0$66f8800a@maildom.okisemi.com>
Mime-Version: 1.0
Content-Type: message/partial;
	total=2;
	id="01CAE2DD.1F1610B0@tsmail03";
	number=1
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>, "Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
To: "NETDEV" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sm-d311v.smileserver.ne.jp ([203.211.202.206]:34080 "EHLO
	sm-d311v.smileserver.ne.jp" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757304Ab0DWMEd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Apr 2010 08:04:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Masayuki Ohtake" <masa-korg@dsn.okisemi.com>
To: "NETDEV" <netdev@vger.kernel.org>
Cc: "Wang, Yong Y" <yong.y.wang@intel.com>,
	"Wang, Qi" <qi.wang@intel.com>,
	"Intel OTC" <joel.clark@intel.com>,
	"Andrew" <andrew.chih.howe.khor@intel.com>
Subject: [PATCH 5/7] Topcliff GbE: Add The Hardware layer codes
Date: Fri, 23 Apr 2010 21:00:58 +0900
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
X-Priority: 3
X-MSMail-Priority: Normal
X-Mailer: Microsoft Outlook Express 6.00.2800.1983
X-MimeOLE: Produced By Microsoft MimeOLE V6.00.2800.1983

From: Masayuki Ohtake <masa-korg@dsn.okisemi.com>

This patch adds the Hardware layer code of GbE driver for Topcliff.
The GbE driver needs all patch[1/7 to 7/7].

Signed-off-by: Masayuki Ohtake <masa-korg@dsn.okisemi.com>
---
 drivers/net/pch_gbe/pch_gbe_mac.c          | 524 ++
 drivers/net/pch_gbe/pch_gbe_mac.h          | 120
 drivers/net/pch_gbe/pch_gbe_nvm.c          | 129
 drivers/net/pch_gbe/pch_gbe_nvm.h          | 84
 drivers/net/pch_gbe/pch_gbe_phy.c          | 493
 drivers/net/pch_gbe/pch_gbe_phy.h          | 135
+++++++++++++++++++++++++++++++ 6 files changed, 1485 insertions(+)
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_mac.c
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_mac.c
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_mac.c 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_mac.c 2010-04-13
19:24:39.000000000 +0900
@@ -0,0 +1,524 @@
+/*!
+ * @file pch_gbe_mac.c
+ * @brief Linux PCH Gigabit Ethernet Driver HAL internal function (MAC)
source file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#include <linux/ethtool.h>
+#include "pch_debug.h"
+#include "pch_gbe_osdep.h"
+#include "pch_gbe_regs.h"
+#include "pch_gbe_defines.h"
+#include "pch_gbe_hw.h"
+#include "pch_gbe_mac.h"
+#include "pch_gbe_api.h"
+
+/* Pause packet value */
+#define PCH_GBE_PAUSE_PKT1_VALUE    0x00C28001
+#define PCH_GBE_PAUSE_PKT2_VALUE    0x00000100
+#define PCH_GBE_PAUSE_PKT4_VALUE    0x01000888
+#define PCH_GBE_PAUSE_PKT5_VALUE    0x0000FFFF
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
+ * @brief   Reset hardware
+ * @param   hw [INOUT] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ * @remarks
+ *  This resets the hardware into a known state (Reset only MAC).
+ *  This is a function pointer entry point called by the api module.
+ */
+void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
+{
+ u32 tmp = 0;
+
+ PCH_DEBUG("pch_gbe_mac_reset_hw\n");
+
+#ifndef CONFIG_PCH_PHUB
+ /* Read the MAC address. and store to the private data */
+ pch_gbe_mac_read_mac_addr(hw);
+#endif
+
+ PCH_GBE_WRITE_REG(hw, RESET, PCH_GBE_ALL_RST);
+#ifdef PCH_GBE_MAC_IFOP_RGMII
+ PCH_GBE_WRITE_REG(hw, MODE, PCH_GBE_MODE_GMII_ETHER);
+#endif
+ while ((PCH_GBE_READ_REG(hw, RESET)) != 0) {
+  udelay(1);
+  tmp++;
+  if (tmp == 5) {
+   PCH_LOG(KERN_ERR, "MAC HW RESET\n");
+   break;
+  }
+ }
+#ifndef CONFIG_PCH_PHUB
+ /* Setup the receive address */
+ pch_gbe_mac_mar_set(hw, hw->mac.addr, 0);
+#endif
+ return;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_init_rx_addrs(struct pch_gbe_hw *hw,
+ *                                         u16 mar_count)
+ * @brief   Initialize receive address's
+ * @param   hw        [INOUT] Pointer to the HW structure
+ * @param   mar_count [IN] Receive address registers
+ * @return  None
+ * @remarks
+ *  Setups the receive address registers by setting the base receive
address
+ *  register to the devices MAC address and clearing all the other receive
+ *  address registers to 0.
+ *  This is a function pointer entry point called by the api module.
+ */
+void pch_gbe_mac_init_rx_addrs(struct pch_gbe_hw *hw, u16 mar_count)
+{
+ u32 i;
+
+ PCH_DEBUG("pch_gbe_mac_init_rx_addrs\n");
+ PCH_DEBUG("Programming MAC Address into MAC_ADDR[0]\n");
+ PCH_DEBUG("Clearing MAC_ADDR[1-%u]\n", mar_count - 1);
+
+ /* Setup the receive address */
+ pch_gbe_hal_mar_set(hw, hw->mac.addr, 0);
+
+ /* Zero out the other (mar_entry_count - 1) receive addresses */
+ for (i = 1; i < mar_count; i++) {
+  PCH_GBE_WRITE_REG_ARRAY(hw, MAC_ADR, (i << 1), 0);
+  PCH_GBE_WRITE_REG_ARRAY(hw, MAC_ADR, ((i << 1) + 1), 0);
+ }
+ PCH_GBE_WRITE_REG(hw, ADDR_MASK, 0xFFFE);
+ /* wait busy */
+ while ((PCH_GBE_READ_REG(hw, ADDR_MASK) & PCH_GBE_BUSY) != 0)
+  ;
+#ifdef DEBUG_TEST
+ {
+  unsigned char ti;
+  PCH_DEBUG("ADDR_MASK reg(check index bit) : 0x%08x\n",
+    PCH_GBE_READ_REG(hw, ADDR_MASK));
+  for (ti = 0; ti < 16; ti++) {
+   PCH_DEBUG("MAC_ADR%dAB reg : 0x%08x 0x%08x\n",
+     (ti + 1),
+     PCH_GBE_READ_REG(hw,
+        MAC_ADR1A +
+        (0x08 * ti)),
+     PCH_GBE_READ_REG(hw,
+        MAC_ADR1B +
+        (0x08 * ti)));
+  }
+ }
+#endif
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 *addr, u32
index)
+ * @brief   Set MAC address register
+ * @param   hw     [INOUT] Pointer to the HW structure
+ * @param   addr   [IN] Pointer to the MAC address
+ * @param   index  [IN] MAC address array register
+ * @return  None
+ */
+void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 * addr, u32 index)
+{
+ u32 mar_low, mar_high, adrmask;
+
+ PCH_DEBUG("pch_gbe_mac_mar_set\n");
+ PCH_DEBUG("index : 0x%x\n", index);
+
+ /* HW expects these in little endian so we reverse the byte order
+  * from network order (big endian) to little endian
+  */
+ mar_low = ((u32) addr[0] |
+     ((u32) addr[1] << 8) |
+     ((u32) addr[2] << 16) | ((u32) addr[3] << 24));
+
+ mar_high = ((u32) addr[4] | ((u32) addr[5] << 8));
+ /* Stop the MAC Address of index. */
+ adrmask = PCH_GBE_READ_REG(hw, ADDR_MASK);
+ PCH_GBE_WRITE_REG(hw, ADDR_MASK, (adrmask | (0x0001 << index)));
+
+ PCH_DEBUG("ADDR_MASK reg : 0x%08x\n", adrmask);
+ PCH_DEBUG("ADDR_MASK reg(check index bit) : 0x%08x\n",
+   PCH_GBE_READ_REG(hw, ADDR_MASK));
+ /* wait busy */
+ while ((PCH_GBE_READ_REG(hw, ADDR_MASK) & PCH_GBE_BUSY) != 0)
+  ;
+ PCH_DEBUG("ADDR_MASK reg(check BUSY bit:1) : 0x%08x\n",
+   PCH_GBE_READ_REG(hw, ADDR_MASK));
+
+ /* Set the MAC address to the MAC address 1A/1B register */
+ PCH_GBE_WRITE_REG_ARRAY(hw, MAC_ADR, (index << 1), mar_low);
+ PCH_GBE_WRITE_REG_ARRAY(hw, MAC_ADR, ((index << 1) + 1), mar_high);
+ /* Start the MAC address of index */
+ PCH_GBE_WRITE_REG(hw, ADDR_MASK, (adrmask & ~(0x0001 << index)));
+ PCH_DEBUG("ADDR_MASK reg(check index bit:0) : 0x%08x\n",
+   PCH_GBE_READ_REG(hw, ADDR_MASK));
+ /* wait busy */
+ while ((PCH_GBE_READ_REG(hw, ADDR_MASK) & PCH_GBE_BUSY) != 0)
+  ;
+ PCH_DEBUG("ADDR_MASK reg(check BUSY bit) : 0x%08x\n",
+   PCH_GBE_READ_REG(hw, ADDR_MASK));
+ PCH_DEBUG("pch_gbe_mac_mar_set:End\n");
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_mc_addr_list_update(struct pch_gbe_hw *hw,
+ *                               u8 *mc_addr_list,   u32 mc_addr_count,
+ *                               u32 mar_used_count, u32 mar_total_num)
+ * @brief   Update Multicast addresses
+ * @param   hw             [INOUT] Pointer to the HW structure
+ * @param   mc_addr_list   [IN] Array of multicast addresses to program
+ * @param   mc_addr_count  [IN] Number of multicast addresses to program
+ * @param   mar_used_count [IN] The first MAC Address register free to
program
+ * @param   mar_total_num  [IN] Total number of supported MAC Address
Registers
+ * @return  None
+ */
+void
+pch_gbe_mac_mc_addr_list_update(struct pch_gbe_hw *hw,
+    u8 *mc_addr_list, u32 mc_addr_count,
+    u32 mar_used_count, u32 mar_total_num)
+{
+ u32 i, adrmask;
+
+ PCH_DEBUG("pch_gbe_mac_mc_addr_list_update\n");
+
+#ifdef DEBUG_TEST
+ {
+  u32 ti, tj;
+  PCH_DEBUG
+      ("mc_addr_count = %d  mar_used_count = %d  "
+       "mar_total_num = %d\n",
+       mc_addr_count, mar_used_count, mar_total_num);
+  for (ti = 0; ti < mc_addr_count; ti++) {
+   tj = ti * PCH_GBE_ETH_ALEN;
+   PCH_DEBUG
+       ("mc_addr_list[%d] = 0x%02x %02x %02x "
+        "%02x %02x %02x \n",
+        ti, mc_addr_list[tj], mc_addr_list[tj + 1],
+        mc_addr_list[tj + 2], mc_addr_list[tj + 3],
+        mc_addr_list[tj + 4], mc_addr_list[tj + 5]);
+  }
+ }
+#endif
+ /* Load the first set of multicast addresses into the exact
+  * filters (RAR).  If there are not enough to fill the RAR
+  * array, clear the filters.
+  */
+ for (i = mar_used_count; i < mar_total_num; i++) {
+  if (mc_addr_count != 0) {
+   pch_gbe_mac_mar_set(hw, mc_addr_list, i);
+   mc_addr_count--;
+   mc_addr_list += PCH_GBE_ETH_ALEN;
+  } else {
+   /* Clear MAC address mask */
+   adrmask = PCH_GBE_READ_REG(hw, ADDR_MASK);
+   PCH_GBE_WRITE_REG(hw, ADDR_MASK,
+       (adrmask | (0x0001 << i)));
+   /* wait busy */
+   while ((PCH_GBE_READ_REG(hw, ADDR_MASK) & PCH_GBE_BUSY)
+          != 0) {
+    ;
+   }
+   /* Clear MAC address */
+   PCH_GBE_WRITE_REG_ARRAY(hw, MAC_ADR, i << 1, 0);
+   PCH_GBE_WRITE_REG_ARRAY(hw, MAC_ADR, (i << 1) + 1, 0);
+  }
+ }
+#ifdef DEBUG_TEST
+ {
+  unsigned char ti;
+  PCH_DEBUG("ADDR_MASK reg(check index bit) : 0x%08x\n",
+    PCH_GBE_READ_REG(hw, ADDR_MASK));
+  for (ti = 0; ti < 16; ti++) {
+   PCH_DEBUG("MAC_ADR%dAB reg : 0x%08x 0x%08x\n",
+     (ti + 1),
+     PCH_GBE_READ_REG(hw,
+        MAC_ADR1A +
+        (0x08 * ti)),
+     PCH_GBE_READ_REG(hw,
+        MAC_ADR1B +
+        (0x08 * ti)));
+  }
+ }
+#endif
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_mac_setup_link(struct pch_gbe_hw *hw)
+ * @brief   Setup flow control and link settings
+ * @param   hw [INOUT] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ */
+s32 pch_gbe_mac_setup_link(struct pch_gbe_hw *hw)
+{
+ struct pch_gbe_functions *func = &hw->func;
+ s32 ret_val = PCH_GBE_SUCCESS;
+
+ PCH_DEBUG("pch_gbe_mac_setup_link\n");
+
+ /* Call the necessary media_type subroutine to configure the link. */
+ ret_val = func->setup_physical_interface(hw);
+
+ return ret_val;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_mac_force_mac_fc(struct pch_gbe_hw *hw)
+ * @brief   Force the MAC's flow control settings
+ * @param   hw [INOUT] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ */
+s32 pch_gbe_mac_force_mac_fc(struct pch_gbe_hw *hw)
+{
+ struct pch_gbe_mac_info *mac = &hw->mac;
+ u32 rx_fctrl;
+
+ PCH_DEBUG("pch_gbe_mac_force_mac_fc\n");
+ PCH_DEBUG("mac->fc = %u\n", mac->fc);
+
+ rx_fctrl = PCH_GBE_READ_REG(hw, RX_FCTRL);
+
+ switch (mac->fc) {
+ case pch_gbe_fc_none:
+  rx_fctrl &= ~PCH_GBE_FL_CTRL_EN;
+  mac->tx_fc_enable = FALSE;
+  break;
+ case pch_gbe_fc_rx_pause:
+  rx_fctrl |= PCH_GBE_FL_CTRL_EN;
+  mac->tx_fc_enable = FALSE;
+  break;
+ case pch_gbe_fc_tx_pause:
+  rx_fctrl &= ~PCH_GBE_FL_CTRL_EN;
+  mac->tx_fc_enable = TRUE;
+  break;
+ case pch_gbe_fc_full:
+  rx_fctrl |= PCH_GBE_FL_CTRL_EN;
+  mac->tx_fc_enable = TRUE;
+  break;
+ default:
+  PCH_LOG(KERN_ERR, "Flow control param set incorrectly\n");
+  return -PCH_GBE_ERR_CONFIG;
+ }
+ if (mac->link_duplex == DUPLEX_HALF)
+  rx_fctrl &= ~PCH_GBE_FL_CTRL_EN;
+ PCH_GBE_WRITE_REG(hw, RX_FCTRL, rx_fctrl);
+ PCH_DEBUG("RX_FCTRL reg : 0x%08x  mac->tx_fc_enable : %d\n",
+   PCH_GBE_READ_REG(hw, RX_FCTRL), mac->tx_fc_enable);
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_mac_config_fc_after_link_up(struct pch_gbe_hw *hw)
+ * @brief   Configures flow control after link
+ * @param   hw [INOUT] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ */
+s32 pch_gbe_mac_config_fc_after_link_up(struct pch_gbe_hw *hw)
+{
+ PCH_DEBUG("pch_gbe_mac_config_fc_after_link_up\n");
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_set_wol_event(struct pch_gbe_hw *hw, u32
wu_evt)
+ * @brief   Set wake-on-lan event
+ * @param   hw     [INOUT] Pointer to the HW structure
+ * @param   wu_evt [IN] Wake up event
+ * @return  None
+ */
+void pch_gbe_mac_set_wol_event(struct pch_gbe_hw *hw, u32 wu_evt)
+{
+ u32 addr_mask;
+
+ PCH_DEBUG("pch_gbe_mac_set_wol_event\n");
+ PCH_DEBUG("wu_evt : 0x%08x  ADDR_MASK reg : 0x%08x\n",
+   wu_evt, PCH_GBE_READ_REG(hw, ADDR_MASK));
+
+ if (wu_evt != 0) {
+  /* Set Wake-On-Lan address mask */
+  addr_mask = PCH_GBE_READ_REG(hw, ADDR_MASK);
+  PCH_GBE_WRITE_REG(hw, WOL_ADDR_MASK, addr_mask);
+  /* wait busy */
+  while ((PCH_GBE_READ_REG(hw, WOL_ADDR_MASK) & PCH_GBE_WLA_BUSY)
+         != 0) {
+   ;
+  }
+  PCH_GBE_WRITE_REG(hw, WOL_ST, 0);
+  PCH_GBE_WRITE_REG(hw, WOL_CTRL,
+      (wu_evt | PCH_GBE_WLC_WOL_MODE));
+  PCH_GBE_WRITE_REG(hw, INT_EN, PCH_GBE_INT_ENABLE_MASK);
+ } else {
+  PCH_GBE_WRITE_REG(hw, WOL_CTRL, 0);
+  PCH_GBE_WRITE_REG(hw, WOL_ST, 0);
+ }
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG
+     ("WOL_ADDR_MASK reg : 0x%08x  WOL_CTRL reg : 0x%08x  "
+      "WOL_ST reg : 0x%08x\n",
+      PCH_GBE_READ_REG(hw, WOL_ADDR_MASK),
+      PCH_GBE_READ_REG(hw, WOL_CTRL),
+      PCH_GBE_READ_REG(hw, WOL_ST));
+#endif
+ return;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      u16 pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw, u32 addr,
+ *                                    u32 dir, u32 reg, u16 data)
+ * @brief   Set wake-on-lan event
+ * @param   hw   [INOUT] Pointer to the HW structure
+ * @param   addr [IN] Address of PHY
+ * @param   dir  [IN] Operetion. (Write or Read)
+ * @param   reg  [IN] Access register of PHY
+ * @param   data [IN] Write data.
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ */
+u16
+pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw, u32 addr, u32 dir, u32 reg,
+   u16 data)
+{
+ u32 data_out = 0;
+ unsigned int i;
+ unsigned long flags;
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("pch_gbe_mac_ctrl_miim\n");
+#endif
+ spin_lock_irqsave(&hw->miim_lock, flags);
+
+ for (i = 100; i; --i) {
+  if ((PCH_GBE_READ_REG(hw, MIIM) & PCH_GBE_MIIM_OPER_READY) != 0)
+   break;
+  udelay(20);
+ }
+ if (i == 0) {
+  PCH_LOG(KERN_ERR, "pch-gbe.miim won't go Ready\n");
+  spin_unlock_irqrestore(&hw->miim_lock, flags);
+  return PCH_GBE_SUCCESS; /* No way to indicate timeout error */
+ }
+ PCH_GBE_WRITE_REG(hw, MIIM, ((reg << PCH_GBE_MIIM_REG_ADDR_SHIFT) |
+         (addr << PCH_GBE_MIIM_PHY_ADDR_SHIFT) |
+         dir | data));
+ for (i = 0; i < 100; i++) {
+  udelay(20);
+  data_out = PCH_GBE_READ_REG(hw, MIIM);
+  if ((data_out & PCH_GBE_MIIM_OPER_READY) != 0)
+   break;
+ }
+ spin_unlock_irqrestore(&hw->miim_lock, flags);
+
+ PCH_DEBUG("%s:addr=%d, reg=%d, data_in=0x%04X, data_out=0x%04X\n",
+   dir == PCH_GBE_MIIM_OPER_READ ? "READ" : "WRITE",
+   addr, reg, data, data_out);
+ return (u16) data_out;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
+ * @brief   Set pause packet
+ * @param   hw [INOUT] Pointer to the HW structure
+ * @return  None
+ */
+void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
+{
+ unsigned long tmp2, tmp3;
+
+ PCH_DEBUG("pch_gbe_mac_set_pause_packet\n");
+
+ /* Set Pause packet */
+ tmp2 = hw->mac.addr[1];
+ tmp2 = (tmp2 << 8) | hw->mac.addr[0];
+ tmp2 = PCH_GBE_PAUSE_PKT2_VALUE | (tmp2 << 16);
+
+ tmp3 = hw->mac.addr[5];
+ tmp3 = (tmp3 << 8) | hw->mac.addr[4];
+ tmp3 = (tmp3 << 8) | hw->mac.addr[3];
+ tmp3 = (tmp3 << 8) | hw->mac.addr[2];
+
+ PCH_GBE_WRITE_REG(hw, PAUSE_PKT1, PCH_GBE_PAUSE_PKT1_VALUE);
+ PCH_GBE_WRITE_REG(hw, PAUSE_PKT2, tmp2);
+ PCH_GBE_WRITE_REG(hw, PAUSE_PKT3, tmp3);
+ PCH_GBE_WRITE_REG(hw, PAUSE_PKT4, PCH_GBE_PAUSE_PKT4_VALUE);
+ PCH_GBE_WRITE_REG(hw, PAUSE_PKT5, PCH_GBE_PAUSE_PKT5_VALUE);
+
+ /* Transmit Pause Packet */
+ PCH_GBE_WRITE_REG(hw, PAUSE_REQ, PCH_GBE_PS_PKT_RQ);
+
+ PCH_DEBUG
+     ("PAUSE_PKT1-5 reg : 0x%08x 0x%08x 0x%08x 0x%08x 0x%08x\n",
+      PCH_GBE_READ_REG(hw, PAUSE_PKT1), PCH_GBE_READ_REG(hw, PAUSE_PKT2),
+      PCH_GBE_READ_REG(hw, PAUSE_PKT3), PCH_GBE_READ_REG(hw, PAUSE_PKT4),
+      PCH_GBE_READ_REG(hw, PAUSE_PKT5));
+
+ return;
+}
+
+#ifndef CONFIG_PCH_PHUB
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw)
+ * @brief   Read MAC address
+ * @param   hw [INOUT] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS
+ */
+s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw)
+{
+ u32  adr1a, adr1b;
+
+ PCH_DEBUG("pch_gbe_mac_read_mac_addr\n");
+
+ adr1a = PCH_GBE_READ_REG(hw, MAC_ADR1A);
+ adr1b = PCH_GBE_READ_REG(hw, MAC_ADR1B);
+
+ hw->mac.addr[0] = (u8)(adr1a & 0xFF);
+ hw->mac.addr[1] = (u8)((adr1a >> 8) & 0xFF);
+ hw->mac.addr[2] = (u8)((adr1a >> 16) & 0xFF);
+ hw->mac.addr[3] = (u8)((adr1a >> 24) & 0xFF);
+ hw->mac.addr[4] = (u8)(adr1b & 0xFF);
+ hw->mac.addr[5] = (u8)((adr1b >> 8) & 0xFF);
+
+ PCH_DEBUG("hw->mac.addr : 0x%02x %02x %02x %02x %02x %02x\n",
+  hw->mac.addr[0], hw->mac.addr[1], hw->mac.addr[2],
+  hw->mac.addr[3], hw->mac.addr[4], hw->mac.addr[5]);
+ return PCH_GBE_SUCCESS;
+}
+#endif /* CONFIG_PCH_PHUB */
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_mac.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_mac.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_mac.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_mac.h 2010-04-13
19:25:54.000000000 +0900
@@ -0,0 +1,120 @@
+/*!
+ * @file pch_gbe_mac.h
+ * @brief Linux PCH Gigabit Ethernet Driver HAL internal function (MAC)
header file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#ifndef _PCH_GBE_MAC_H_
+#define _PCH_GBE_MAC_H_
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw)
+ * @brief   Reset hardware
+ */
+void pch_gbe_mac_reset_hw(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_init_rx_addrs(struct pch_gbe_hw *hw,
+ *                                         u16 mar_count)
+ * @brief   Initialize receive address's
+ */
+void pch_gbe_mac_init_rx_addrs(struct pch_gbe_hw *hw, u16 mar_count);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 *addr, u32
index)
+ * @brief   Set MAC address register
+ */
+void pch_gbe_mac_mar_set(struct pch_gbe_hw *hw, u8 *addr, u32 index);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_mc_addr_list_update(struct pch_gbe_hw *hw,
+ *                                u8 *mc_addr_list,   u32 mc_addr_count,
+ *                                u32 mar_used_count, u32 mar_total_num)
+ * @brief   Update Multicast addresses
+ */
+void pch_gbe_mac_mc_addr_list_update(struct pch_gbe_hw *hw,
+         u8 *mc_addr_list, u32 mc_addr_count,
+         u32 mar_used_count, u32 mar_count);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_mac_setup_link(struct pch_gbe_hw *hw)
+ * @brief   Setup flow control and link settings
+ */
+s32 pch_gbe_mac_setup_link(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_mac_force_mac_fc(struct pch_gbe_hw *hw)
+ * @brief   Force the MAC's flow control settings
+ */
+s32 pch_gbe_mac_force_mac_fc(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_mac_config_fc_after_link_up(struct pch_gbe_hw *hw)
+ * @brief   Configures flow control after link
+ */
+s32 pch_gbe_mac_config_fc_after_link_up(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_set_wol_event(struct pch_gbe_hw *hw, u32
wu_evt)
+ * @brief   Set wake-on-lan event
+ */
+void pch_gbe_mac_set_wol_event(struct pch_gbe_hw *hw, u32 wu_evt);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      u16 pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw, u32 addr,
+ *                                    u32 dir, u32 reg, u16 data)
+ * @brief   Set wake-on-lan event
+ */
+u16 pch_gbe_mac_ctrl_miim(struct pch_gbe_hw *hw,
+     u32 addr, u32 dir, u32 reg, u16 data);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw)
+ * @brief   Set pause packet
+ */
+void pch_gbe_mac_set_pause_packet(struct pch_gbe_hw *hw);
+
+#ifndef CONFIG_PCH_PHUB
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw)
+ * @brief   Read MAC address
+ */
+s32 pch_gbe_mac_read_mac_addr(struct pch_gbe_hw *hw);
+#endif /* CONFIG_PCH_PHUB */
+
+#endif /* _PCH_GBE_MAC_H_ */
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_nvm.c
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_nvm.c
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_nvm.c 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_nvm.c 2010-04-13
18:43:52.000000000 +0900
@@ -0,0 +1,129 @@
+/*!
+ * @file pch_gbe_nvm.c
+ * @brief Linux PCH Gigabit Ethernet Driver HAL internal function (NVM)
source file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#include "pch_debug.h"
+#include "pch_gbe_osdep.h"
+#include "pch_gbe_defines.h"
+#include "pch_gbe_hw.h"
+#include "pch_gbe_nvm.h"
+
+#ifdef CONFIG_PCH_PHUB
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_nvm_read_mem(struct pch_gbe_hw *hw,
+ *                                   u32 offset, u8 *data)
+ * @brief   Read EEPROM
+ * @param   hw     [INOUT] Pointer to the HW structure
+ * @param   offset [IN] Offset of word in the EEPROM to read
+ * @param   data   [OUT] Word read from the EEPROM
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ */
+s32 pch_gbe_nvm_read_mem(struct pch_gbe_hw *hw, u32 offset, u8 *data)
+{
+ s32 ret;
+
+ PCH_DEBUG("pch_gbe_nvm_read_mem\n");
+ PCH_DEBUG("offset : 0x%04x\n", offset);
+ ret = pch_phub_read_gbe_mac_addr(offset, data);
+ return ret;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_nvm_write_mem(struct pch_gbe_hw *hw,
+ *                                    u32 offset, u8 *data)
+ * @brief   Write EEPROM
+ * @param   hw     [INOUT] Pointer to the HW structure
+ * @param   offset [IN] Offset of word in the EEPROM to read
+ * @param   data   [IN] 8bit word(s) to be written to the EEPROM
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ */
+s32 pch_gbe_nvm_write_mem(struct pch_gbe_hw *hw, u32 offset, u8 *data)
+{
+ s32 ret;
+
+ PCH_DEBUG("pch_gbe_nvm_write_mem\n");
+ PCH_DEBUG("offset : 0x%04x\n", offset);
+ ret = pch_phub_write_gbe_mac_addr(offset, *data);
+ return ret;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_nvm_read_mac_addr(struct pch_gbe_hw *hw)
+ * @brief   Read device MAC address
+ * @param   hw  [INOUT] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ */
+s32 pch_gbe_nvm_read_mac_addr(struct pch_gbe_hw *hw)
+{
+ s32 ret;
+ u8 i;
+ u8 *data;
+
+ PCH_DEBUG("pch_gbe_nvm_read_mac_addr\n");
+
+#ifdef NVM_MAC_FIX
+ hw->mac.addr[0] = (u8) (0x00);
+ hw->mac.addr[1] = (u8) (0x21);
+ hw->mac.addr[2] = (u8) (0x97);
+ hw->mac.addr[3] = (u8) (0x77);
+ hw->mac.addr[4] = (u8) (0x65);
+ hw->mac.addr[5] = (u8) (0x13);
+#else
+ data = hw->mac.addr;
+ for (i = 0; i < (hw->nvm.word_size * 2); i++) {
+  ret = pch_phub_read_gbe_mac_addr((u32) i, (data + i));
+  if (ret != 0)
+   break;
+ }
+#endif
+
+ PCH_DEBUG("hw->mac.addr : 0x%02x %02x %02x %02x %02x %02x\n",
+   hw->mac.addr[0], hw->mac.addr[1], hw->mac.addr[2],
+   hw->mac.addr[3], hw->mac.addr[4], hw->mac.addr[5]);
+ return ret;
+}
+#endif
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_nvm_validate_checksum(struct pch_gbe_hw *hw)
+ * @brief   Validate EEPROM checksum
+ * @param   hw  [INOUT] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ */
+s32 pch_gbe_nvm_validate_checksum(struct pch_gbe_hw *hw)
+{
+ PCH_DEBUG("pch_gbe_nvm_validate_checksum\n");
+ return PCH_GBE_SUCCESS;
+}
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_nvm.h
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_nvm.h
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_nvm.h 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_nvm.h 2010-04-13
18:43:54.000000000 +0900
@@ -0,0 +1,84 @@
+/*!
+ * @file pch_gbe_nvm.h
+ * @brief Linux PCH Gigabit Ethernet Driver HAL internal function (NVM)
header file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#ifndef _PCH_GBE_NVM_H_
+#define _PCH_GBE_NVM_H_
+
+#ifdef CONFIG_PCH_PHUB
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_nvm_read_mem(struct pch_gbe_hw *hw,
+ *                                   u32 offset, u8 *data)
+ * @brief   Read EEPROM
+ */
+s32 pch_gbe_nvm_read_mem(struct pch_gbe_hw *hw, u32 offset, u8 * data);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_nvm_write_mem(struct pch_gbe_hw *hw,
+ *                                    u32 offset, u8 *data)
+ * @brief   Write EEPROM
+ */
+s32 pch_gbe_nvm_write_mem(struct pch_gbe_hw *hw, u32 offset, u8 * data);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_nvm_read_mac_addr(struct pch_gbe_hw *hw)
+ * @brief   Read device MAC address
+ */
+s32 pch_gbe_nvm_read_mac_addr(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_nvm_validate_checksum(struct pch_gbe_hw *hw)
+ * @brief   Validate EEPROM checksum
+ */
+s32 pch_gbe_nvm_validate_checksum(struct pch_gbe_hw *hw);
+
+/*!
+ * @ingroup PCIe QoS Driver function
+ * @fn      int pch_phub_read_gbe_mac_addr (unsigned long offset_address,
+ *                                              unsigned char *data);
+ * @brief   Read MAC address from NVM
+ */
+int pch_phub_read_gbe_mac_addr(unsigned long offset_address,
+      unsigned char *data);
+
+/*!
+ * @ingroup PCIe QoS Driver function
+ * @fn      int pch_phub_write_gbe_mac_addr(unsigned long offset_address,
+ *                                              unsigned char data);
+ * @brief   Write MAC address from NVM
+ */
+int pch_phub_write_gbe_mac_addr(unsigned long offset_address,
+      unsigned char data);
+#endif /* CONFIG_PCH_PHUB */
+
+#endif /* _PCH_GBE_NVM_H_ */
diff -urN linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_phy.c
topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_phy.c
--- linux-2.6.33.1/drivers/net/pch_gbe/pch_gbe_phy.c 1970-01-01
09:00:00.000000000 +0900
+++ topcliff-2.6.33.1/drivers/net/pch_gbe/pch_gbe_phy.c 2010-04-13
18:17:53.000000000 +0900
@@ -0,0 +1,493 @@
+/*!
+ * @file pch_gbe_phy.c
+ * @brief Linux PCH Gigabit Ethernet Driver HAL internal function (PHY)
source file
+ *
+ * @version 1.00
+ *
+ * @section
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; version 2 of the License.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307,
USA.
+ */
+
+/*
+ * History:
+ * Copyright (C) 2010 OKI SEMICONDUCTOR CO., LTD.
+ *
+ * created:
+ *   OKI SEMICONDUCTOR 04/13/2010
+ * modified:
+ *
+ */
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+#include <linux/mii.h>
+
+#include "pch_debug.h"
+#include "pch_gbe_osdep.h"
+#include "pch_gbe_defines.h"
+#include "pch_gbe_hw.h"
+#include "pch_gbe_phy.h"
+#include "pch_gbe_api.h"
+#include "pch_gbe_regs.h"
+#include "pch_gbe.h"
+
+
+/*!
+ * @ingroup  HAL internal function
+ * @def      PHY_CONTROL_DEFAULT
+ * @brief    Default value of CONTROL register of PHY
+ */
+#define PHY_CONTROL_DEFAULT           0x1140 /* Control Register */
+
+/*!
+ * @ingroup  HAL internal function
+ * @def      PHY_AUTONEG_ADV_DEFAULT
+ * @brief    Default value of AUTONEG_ADV register of PHY
+ */
+#define PHY_AUTONEG_ADV_DEFAULT       0x01e0 /* Autoneg Advertisement */
+
+/*!
+ * @ingroup  HAL internal function
+ * @def      PHY_NEXT_PAGE_TX_DEFAULT
+ * @brief    Default value of NEXT_PAGE_TX register of PHY
+ */
+#define PHY_NEXT_PAGE_TX_DEFAULT      0x2001 /* Next Page TX */
+
+/*!
+ * @ingroup  HAL internal function
+ * @def      PHY_1000T_CTRL_DEFAULT
+ * @brief    Default value of 1000T_CTRL register of PHY
+ */
+#define PHY_1000T_CTRL_DEFAULT        0x0300 /* 1000Base-T Control Register
*/
+
+/*!
+ * @ingroup  HAL internal function
+ * @def      PHY_PHYSP_CONTROL_DEFAULT
+ * @brief    Default value of PHYSP_CONTROL register of PHY
+ */
+#ifdef FPGA
+#define PHY_PHYSP_CONTROL_DEFAULT     0x0078 /* PHY Specific Control
Register */
+#else
+#define PHY_PHYSP_CONTROL_DEFAULT     0x01EE /* PHY Specific Control
Register */
+#endif
+
+/*!
+ * @ingroup  HAL internal function
+ * @def      PHY_EXT_PHYSP_CONTROL_DEFAULT
+ * @brief    Default value of EXT_PHYSP_CONTROL register of PHY
+ */
+#define PHY_EXT_PHYSP_CONTROL_DEFAULT 0x0c60
+
+/*!
+ * @ingroup  HAL internal function
+ * @def      PHY_LED_CONTROL_DEFAULT
+ * @brief    Default value of LED_CONTROL register of PHY
+ */
+#define PHY_LED_CONTROL_DEFAULT       0x4100
+
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_get_id(struct pch_gbe_hw *hw)
+ * @brief   Retrieve the PHY ID and revision
+ * @param   hw   [IN] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ * @remarks
+ *  Reads the PHY registers and stores the PHY ID and possibly the PHY
+ *  revision in the hardware structure.
+ */
+s32
+pch_gbe_phy_get_id(struct pch_gbe_hw *hw)
+{
+ struct pch_gbe_phy_info *phy = &hw->phy;
+ s32 ret;
+ u16 phy_id1;
+ u16 phy_id2;
+
+ PCH_DEBUG("pch_gbe_phy_get_id\n");
+
+ ret = pch_gbe_hal_read_phy_reg(hw, PHY_ID1, &phy_id1);
+ if (ret != 0)
+  return ret;
+ ret = pch_gbe_hal_read_phy_reg(hw, PHY_ID2, &phy_id2);
+ if (ret != 0)
+  return ret;
+ /*
+  * PHY_ID1: [bit15-0:ID(21-6)]
+  * PHY_ID2: [bit15-10:ID(5-0)][bit9-4:Model][bit3-0:revision]
+  */
+ phy->id = (u32)phy_id1;
+ phy->id = ((phy->id << 6) | ((phy_id2 & 0xFC00) >> 10));
+ phy->revision = (u32) (phy_id2 & 0x000F);
+
+#ifdef DEBUG_TEST
+ PCH_DEBUG("phy->id : 0x%08x  phy->revision : 0x%08x\n",
+   phy->id, phy->revision);
+#endif
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_read_reg_miic(struct pch_gbe_hw *hw,
+ *                                        u32 offset, u16 *data)
+ * @brief   Read MII control register
+ * @param   hw      [IN] Pointer to the HW structure
+ * @param   offset  [IN] Register offset to be read
+ * @param   data    [OUT] Pointer to the read data
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ * @remarks
+ *  Reads the PHY registers and stores the PHY ID and possibly the PHY
+ *  revision in the hardware structure.
+ */
+s32
+pch_gbe_phy_read_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16 *data)
+{
+ struct pch_gbe_phy_info *phy = &hw->phy;
+ s32 ret_val = PCH_GBE_SUCCESS;
+
+ if (offset > PHY_MAX_REG_ADDRESS) {
+  PCH_DEBUG("PHY Address %d is out of range\n", offset);
+  ret_val = -PCH_GBE_ERR_PARAM;
+ } else {
+  *data = pch_gbe_hal_ctrl_miim(hw, phy->addr,
+     PCH_GBE_HAL_MIIM_READ, offset, (u16)0);
+ }
+ return ret_val;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_write_reg_miic(struct pch_gbe_hw *hw,
+ *                                         u32 offset, u16 data)
+ * @brief   Write MII control register
+ * @param   hw      [IN] Pointer to the HW structure
+ * @param   offset  [IN] Register offset to be read
+ * @param   data    [IN] data to write to register at offset
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ * @remarks
+ *  Writes data to MDI control register in the PHY at offset.
+ */
+s32
+pch_gbe_phy_write_reg_miic(struct pch_gbe_hw *hw, u32 offset, u16 data)
+{
+ struct pch_gbe_phy_info *phy = &hw->phy;
+ s32 ret_val = PCH_GBE_SUCCESS;
+
+ if (offset > PHY_MAX_REG_ADDRESS) {
+  PCH_DEBUG("PHY Address %d is out of range\n", offset);
+  ret_val = -PCH_GBE_ERR_PARAM;
+ } else {
+  pch_gbe_hal_ctrl_miim(hw, phy->addr,
+     PCH_GBE_HAL_MIIM_WRITE, offset, data);
+ }
+ return ret_val;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_setup_link_fpga(struct pch_gbe_hw *hw)
+ * @brief   Configure link settings for FPGA
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ * @return  Negative value:   Failed
+ * @remarks
+ *  Calls the appropriate function to configure the link for auto-neg or
forced
+ *  speed and duplex.  Then we check for link, once link is established
calls
+ *  to configure collision distance and flow control are called.  If link
is
+ *  not established, we return -PCH_GBE_ERR_PHY (-2).
+ */
+s32
+pch_gbe_phy_setup_link_fpga(struct pch_gbe_hw *hw)
+{
+
+ PCH_DEBUG("pch_gbe_phy_setup_link_fpga\n");
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_sw_reset(struct pch_gbe_hw *hw)
+ * @brief   PHY software reset
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  None
+ * @remarks
+ *  Does a software reset of the PHY by reading the PHY control register
and
+ *  setting/write the control register reset bit to the PHY.
+ */
+void
+pch_gbe_phy_sw_reset(struct pch_gbe_hw *hw)
+{
+ u16 phy_ctrl;
+
+ PCH_DEBUG("pch_gbe_phy_sw_reset\n");
+
+ pch_gbe_hal_read_phy_reg(hw, PHY_CONTROL, &phy_ctrl);
+ phy_ctrl |= MII_CR_RESET;
+ pch_gbe_hal_write_phy_reg(hw, PHY_CONTROL, phy_ctrl);
+ usec_delay(1);
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      void pch_gbe_phy_hw_reset(struct pch_gbe_hw *hw)
+ * @brief   PHY hardware reset
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  None
+ * @remarks
+ *  Verify the reset block is not blocking us from resetting.  Acquire
+ *  semaphore (if necessary) and read/set/write the device control reset
+ *  bit in the PHY.  Wait the appropriate delay time for the device to
+ *  reset and relase the semaphore (if necessary).
+ */
+void
+pch_gbe_phy_hw_reset(struct pch_gbe_hw *hw)
+{
+#ifndef PHY_RESET_REG_INIT
+ struct pch_gbe_phy_info *phy = &hw->phy;
+
+ PCH_DEBUG("pch_gbe_phy_hw_reset\n");
+
+ /* ISSUE: reset used GPIO driver */
+ usec_delay(phy->reset_delay_us);
+ /* ISSUE: release reset used GPIO driver */
+#else
+ PCH_DEBUG("pch_gbe_phy_hw_reset\n");
+
+ pch_gbe_hal_write_phy_reg(hw, PHY_CONTROL, PHY_CONTROL_DEFAULT);
+ pch_gbe_hal_write_phy_reg(hw, PHY_AUTONEG_ADV,
+     PHY_AUTONEG_ADV_DEFAULT);
+ pch_gbe_hal_write_phy_reg(hw, PHY_NEXT_PAGE_TX,
+     PHY_NEXT_PAGE_TX_DEFAULT);
+ pch_gbe_hal_write_phy_reg(hw, PHY_1000T_CTRL, PHY_1000T_CTRL_DEFAULT);
+ pch_gbe_hal_write_phy_reg(hw, PHY_PHYSP_CONTROL,
+     PHY_PHYSP_CONTROL_DEFAULT);
+#ifdef FPGA
+ pch_gbe_hal_write_phy_reg(hw, PHY_EXT_PHYSP_CONTROL,
+     PHY_EXT_PHYSP_CONTROL_DEFAULT);
+ pch_gbe_hal_write_phy_reg(hw, PHY_LED_CONTROL, PHY_LED_CONTROL_DEFAULT);
+#endif
+
+#endif
+
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_led_on(struct pch_gbe_hw *hw)
+ * @brief   Set ting of led on
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully
+ */
+s32
+pch_gbe_phy_led_on(struct pch_gbe_hw *hw)
+{
+ PCH_DEBUG("pch_gbe_phy_led_on\n");
+
+ pch_gbe_hal_write_phy_reg(hw, PHY_LED_CONTROL, PHY_LED_CTRL_ON);
+ return PCH_GBE_SUCCESS;
+}
+
+/*!
+ * @ingroup HAL internal function
+ * @fn      s32 pch_gbe_phy_led_off(struct pch_gbe_hw *hw)
+ * @brief   Set ting of led off
+ * @param   hw      [IN] Pointer to the HW structure
+ * @return  PCH_GBE_SUCCESS:  Successfully

