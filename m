From: Jie Yang <Jie.Yang@Atheros.com>
Subject: [PATCH 2.6.25.3 5/5] atl1e: Atheros L1E Gigabit Ethernet driver
Date: Thu, 26 Jun 2008 13:38:17 +0800
Message-ID: <72981EBCFD196144B7C6999B9FC34A9A3EE603B868@SHEXMB-01.global.atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "jeff@garzik.org" <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757265AbYFZFk0@vger.kernel.org>
Content-Language: zh-CN
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jie Yang <jie.yang@atheros.com>

Full patch for the Atheros L1E Gigabit Ethernet driver.
Supportring AR8121, AR8113 and AR8114

Signed-off-by: Jie Yang <jie.yang @atheros.com>
---
diff -uprN -X linux-2.6.25.3.orig/Documentation/dontdiff linux-2.6.25.3.orig/drivers/net/atl1e/atl1e_ethtool.c linux-2.6.25.3.atheros/drivers/net/atl1e/atl1e_ethtool.c
--- linux-2.6.25.3.orig/drivers/net/atl1e/atl1e_ethtool.c       1970-01-01 08:00:00.000000000 +0800
+++ linux-2.6.25.3.atheros/drivers/net/atl1e/atl1e_ethtool.c    2008-06-20 11:22:34.000000000 +0800
@@ -0,0 +1,473 @@
+/*
+ * Copyright(c) 2007 Atheros Corporation. All rights reserved.
+ *
+ * Derived from Intel e1000 driver
+ * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * There are a lot of defines in here that are unused and/or have cryptic
+ * names.  Please leave them alone, as they're the closest thing we have
+ * to a spec from Atheros at present. *ahem* -- CHS
+ */
+
+/* ethtool support for at */
+
+#include <linux/netdevice.h>
+#include <linux/ethtool.h>
+
+#include "atl1e.h"
+
+static int atl1e_get_settings(struct net_device *netdev,
+                             struct ethtool_cmd *ecmd)
+{
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+       struct atl1e_hw *hw = &adapter->hw;
+
+       ecmd->supported = (SUPPORTED_10baseT_Half  |
+                          SUPPORTED_10baseT_Full  |
+                          SUPPORTED_100baseT_Half |
+                          SUPPORTED_100baseT_Full |
+                          SUPPORTED_Autoneg       |
+                          SUPPORTED_TP);
+       if (hw->nic_type == athr_l1e)
+               ecmd->supported |= SUPPORTED_1000baseT_Full;
+
+       ecmd->advertising = ADVERTISED_TP;
+
+       ecmd->advertising |= ADVERTISED_Autoneg;
+       ecmd->advertising |= hw->autoneg_advertised;
+
+       ecmd->port = PORT_TP;
+       ecmd->phy_address = 0;
+       ecmd->transceiver = XCVR_INTERNAL;
+
+       if (adapter->link_speed != SPEED_0) {
+               ecmd->speed = adapter->link_speed;
+               if (adapter->link_duplex == FULL_DUPLEX)
+                       ecmd->duplex = DUPLEX_FULL;
+               else
+                       ecmd->duplex = DUPLEX_HALF;
+       } else {
+               ecmd->speed = -1;
+               ecmd->duplex = -1;
+       }
+
+       ecmd->autoneg = AUTONEG_ENABLE;
+       return 0;
+}
+
+static int atl1e_set_settings(struct net_device *netdev,
+                             struct ethtool_cmd *ecmd)
+{
+#define MY_ADV_MASK (ADVERTISE_10_HALF  |\
+                    ADVERTISE_10_FULL  |\
+                    ADVERTISE_100_HALF |\
+                    ADVERTISE_100_FULL |\
+                    ADVERTISE_1000_FULL)
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+       struct atl1e_hw *hw = &adapter->hw;
+
+       while (test_and_set_bit(__AT_RESETTING, &adapter->flags))
+               msleep(1);
+
+       if (ecmd->autoneg == AUTONEG_ENABLE) {
+               u16 adv4, adv9;
+
+               if ((ecmd->advertising&ADVERTISE_1000_FULL)) {
+                       if (hw->nic_type == athr_l1e) {
+                               hw->autoneg_advertised =
+                                       ecmd->advertising & MY_ADV_MASK;
+                       } else {
+                               clear_bit(__AT_RESETTING, &adapter->flags);
+                               return -EINVAL;
+                       }
+               } else if (ecmd->advertising&ADVERTISE_1000_HALF) {
+                       clear_bit(__AT_RESETTING, &adapter->flags);
+                       return -EINVAL;
+               } else {
+                       hw->autoneg_advertised =
+                               ecmd->advertising & MY_ADV_MASK;
+               }
+               ecmd->advertising = hw->autoneg_advertised |
+                                   ADVERTISED_TP | ADVERTISED_Autoneg;
+
+               adv4 = hw->mii_autoneg_adv_reg & ~MII_AR_SPEED_MASK;
+               adv9 = hw->mii_1000t_ctrl_reg & ~MII_AT001_CR_1000T_SPEED_MASK;
+               if (hw->autoneg_advertised & ADVERTISE_10_HALF)
+                       adv4 |= MII_AR_10T_HD_CAPS;
+               if (hw->autoneg_advertised & ADVERTISE_10_FULL)
+                       adv4 |= MII_AR_10T_FD_CAPS;
+               if (hw->autoneg_advertised & ADVERTISE_100_HALF)
+                       adv4 |= MII_AR_100TX_HD_CAPS;
+               if (hw->autoneg_advertised & ADVERTISE_100_FULL)
+                       adv4 |= MII_AR_100TX_FD_CAPS;
+               if (hw->autoneg_advertised & ADVERTISE_1000_FULL)
+                       adv9 |= MII_AT001_CR_1000T_FD_CAPS;
+
+               if (adv4 != hw->mii_autoneg_adv_reg ||
+                               adv9 != hw->mii_1000t_ctrl_reg) {
+                       hw->mii_autoneg_adv_reg = adv4;
+                       hw->mii_1000t_ctrl_reg = adv9;
+                       hw->re_autoneg = true;
+               }
+
+       } else {
+               clear_bit(__AT_RESETTING, &adapter->flags);
+               return -EINVAL;
+       }
+
+       /* reset the link */
+
+       if (netif_running(adapter->netdev)) {
+               atl1e_down(adapter);
+               atl1e_up(adapter);
+       } else
+               atl1e_reset_hw(&adapter->hw);
+
+       clear_bit(__AT_RESETTING, &adapter->flags);
+       return 0;
+#undef MY_ADV_MASK
+}
+
+static u32 atl1e_get_tx_csum(struct net_device *netdev)
+{
+       return (netdev->features & NETIF_F_HW_CSUM) != 0;
+}
+
+static u32 atl1e_get_msglevel(struct net_device *netdev)
+{
+#ifdef DBG
+       return 1;
+#else
+       return 0;
+#endif
+}
+
+
+static void atl1e_set_msglevel(struct net_device *netdev, u32 data)
+{
+}
+
+static int atl1e_get_regs_len(struct net_device *netdev)
+{
+#define AT_REGS_LEN 75
+       return AT_REGS_LEN * sizeof(u32);
+}
+
+static void atl1e_get_regs(struct net_device *netdev,
+               struct ethtool_regs *regs, void *p)
+{
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+       struct atl1e_hw *hw = &adapter->hw;
+       u32 *regs_buff = p;
+       u16 phy_data;
+
+       memset(p, 0, AT_REGS_LEN * sizeof(u32));
+
+       regs->version = (1 << 24) | (hw->revision_id << 16) | hw->device_id;
+
+       regs_buff[0]  = AT_READ_REG(hw, REG_VPD_CAP);
+       regs_buff[1]  = AT_READ_REG(hw, REG_SPI_FLASH_CTRL);
+       regs_buff[2]  = AT_READ_REG(hw, REG_SPI_FLASH_CONFIG);
+       regs_buff[3]  = AT_READ_REG(hw, REG_TWSI_CTRL);
+       regs_buff[4]  = AT_READ_REG(hw, REG_PCIE_DEV_MISC_CTRL);
+       regs_buff[5]  = AT_READ_REG(hw, REG_MASTER_CTRL);
+       regs_buff[6]  = AT_READ_REG(hw, REG_MANUAL_TIMER_INIT);
+       regs_buff[7]  = AT_READ_REG(hw, REG_IRQ_MODU_TIMER_INIT);
+       regs_buff[8]  = AT_READ_REG(hw, REG_GPHY_CTRL);
+       regs_buff[9]  = AT_READ_REG(hw, REG_CMBDISDMA_TIMER);
+       regs_buff[10] = AT_READ_REG(hw, REG_IDLE_STATUS);
+       regs_buff[11] = AT_READ_REG(hw, REG_MDIO_CTRL);
+       regs_buff[12] = AT_READ_REG(hw, REG_SERDES_LOCK);
+       regs_buff[13] = AT_READ_REG(hw, REG_MAC_CTRL);
+       regs_buff[14] = AT_READ_REG(hw, REG_MAC_IPG_IFG);
+       regs_buff[15] = AT_READ_REG(hw, REG_MAC_STA_ADDR);
+       regs_buff[16] = AT_READ_REG(hw, REG_MAC_STA_ADDR+4);
+       regs_buff[17] = AT_READ_REG(hw, REG_RX_HASH_TABLE);
+       regs_buff[18] = AT_READ_REG(hw, REG_RX_HASH_TABLE+4);
+       regs_buff[19] = AT_READ_REG(hw, REG_MAC_HALF_DUPLX_CTRL);
+       regs_buff[20] = AT_READ_REG(hw, REG_MTU);
+       regs_buff[21] = AT_READ_REG(hw, REG_WOL_CTRL);
+       regs_buff[22] = AT_READ_REG(hw, REG_SRAM_TRD_ADDR);
+       regs_buff[23] = AT_READ_REG(hw, REG_SRAM_TRD_LEN);
+       regs_buff[24] = AT_READ_REG(hw, REG_SRAM_RXF_ADDR);
+       regs_buff[25] = AT_READ_REG(hw, REG_SRAM_RXF_LEN);
+       regs_buff[26] = AT_READ_REG(hw, REG_SRAM_TXF_ADDR);
+       regs_buff[27] = AT_READ_REG(hw, REG_SRAM_TXF_LEN);
+       regs_buff[28] = AT_READ_REG(hw, REG_SRAM_TCPH_ADDR);
+       regs_buff[29] = AT_READ_REG(hw, REG_SRAM_PKTH_ADDR);
+       /*
+       // description address
+       regs_buff[30] = AT_READ_REG(hw, REG_DESC_BASE_ADDR_HI);
+       regs_buff[31] = AT_READ_REG(hw, REG_TPD_BASE_ADDR_LO);
+       regs_buff[32] = AT_READ_REG(hw, REG_TPD_RING_SIZE);
+       regs_buff[33] = AT_READ_REG(hw, REG_HOST_RXF_HEAD);
+       regs_buff[34] = AT_READ_REG(hw, REG_HOST_RXF_TAIL);
+       regs_buff[35] = AT_READ_REG(hw, REG_HOST_RXRAM_SIZE);
+       regs_buff[36] = AT_READ_REG(hw, REG_HOST_RXF1_HEAD);
+       regs_buff[37] = AT_READ_REG(hw, REG_HOST_RXF1_TAIL);
+       regs_buff[38] = AT_READ_REG(hw, REG_HOST_RXF2_HEAD);
+       regs_buff[39] = AT_READ_REG(hw, REG_HOST_RXF2_TAIL);
+       regs_buff[40] = AT_READ_REG(hw, REG_HOST_RXF3_HEAD);
+       regs_buff[41] = AT_READ_REG(hw, REG_HOST_RXF3_TAIL);
+       // mail box
+       regs_buff[42] = AT_READ_REG(hw, REG_HOST_RXF0_WADDR);
+       regs_buff[43] = AT_READ_REG(hw, REG_HOST_RXF1_WADDR);
+       regs_buff[44] = AT_READ_REG(hw, REG_HOST_RXF2_WADDR);
+       regs_buff[45] = AT_READ_REG(hw, REG_HOST_RXF3_WADDR);
+       regs_buff[46] = AT_READ_REG(hw, REG_TPD_CONS_IDX);
+       regs_buff[47] = AT_READ_REG(hw, REG_MB_RXF0_RADDR);
+       regs_buff[48] = AT_READ_REG(hw, REG_MB_RXF1_RADDR);
+       regs_buff[49] = AT_READ_REG(hw, REG_MB_RXF2_RADDR);
+       regs_buff[50] = AT_READ_REG(hw, REG_MB_RXF3_RADDR);
+       regs_buff[51] = AT_READ_REG(hw, REG_MB_TPD_PROD_IDX);
+       // RSS
+       regs_buff[52] = AT_READ_REG(hw, REG_RSS_KEY0);
+       regs_buff[53] = AT_READ_REG(hw, REG_RSS_KEY1);
+       regs_buff[54] = AT_READ_REG(hw, REG_RSS_KEY2);
+       regs_buff[55] = AT_READ_REG(hw, REG_RSS_KEY3);
+       regs_buff[56] = AT_READ_REG(hw, REG_RSS_HASH_VALUE);
+       regs_buff[57] = AT_READ_REG(hw, REG_RSS_HASH_FLAG);
+       regs_buff[58] = AT_READ_REG(hw, REG_IDT_TABLE);
+       regs_buff[59] = AT_READ_REG(hw, REG_BASE_CPU_NUMBER);
+       // TXQ
+       regs_buff[60] = AT_READ_REG(hw, REG_TXQ_CTRL);
+       regs_buff[61] = AT_READ_REG(hw, REG_TX_JUMBO_TASK_TH);
+       // RXQ
+       regs_buff[62] = AT_READ_REG(hw, REG_RXQ_CTRL);
+       regs_buff[63] = AT_READ_REG(hw, REG_RXQ_JMBOSZ_RRDTIM);
+       regs_buff[64] = AT_READ_REG(hw, REG_RXQ_RXF_PAUSE_THRESH);
+       // DMA
+       regs_buff[65] = AT_READ_REG(hw, REG_DMA_CTRL);
+       // misc
+       regs_buff[66] = AT_READ_REG(hw, REG_SMB_STAT_TIMER);
+       regs_buff[67] = AT_READ_REGW(hw, REG_TRIG_RRD_THRESH);
+       regs_buff[68] = AT_READ_REGW(hw, REG_TRIG_TPD_THRESH);
+       regs_buff[69] = AT_READ_REGW(hw, REG_TRIG_RXTIMER);
+       regs_buff[70] = AT_READ_REGW(hw, REG_TRIG_TXTIMER);
+       regs_buff[71] = AT_READ_REG(hw, REG_ISR);
+       regs_buff[72] = AT_READ_REG(hw, REG_IMR);
+        */
+       atl1e_read_phy_reg(hw, MII_BMCR, &phy_data);
+       regs_buff[73] = (u32)phy_data;
+       atl1e_read_phy_reg(hw, MII_BMSR, &phy_data);
+       regs_buff[74] = (u32)phy_data;
+}
+
+static int atl1e_get_eeprom_len(struct net_device *netdev)
+{
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+
+       if (!check_eeprom_exist(&adapter->hw))
+               return 512;
+       else
+               return 0;
+}
+
+static int atl1e_get_eeprom(struct net_device *netdev,
+               struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+       struct atl1e_hw *hw = &adapter->hw;
+       u32 *eeprom_buff;
+       int first_dword, last_dword;
+       int ret_val = 0;
+       int i;
+
+       if (eeprom->len == 0)
+               return -EINVAL;
+
+       if (check_eeprom_exist(hw))
+               return -EINVAL;
+
+       eeprom->magic = hw->vendor_id | (hw->device_id << 16);
+
+       first_dword = eeprom->offset >> 2;
+       last_dword = (eeprom->offset + eeprom->len - 1) >> 2;
+
+       eeprom_buff = kmalloc(sizeof(u32) *
+                       (last_dword - first_dword + 1), GFP_KERNEL);
+       if (eeprom_buff == NULL)
+               return -ENOMEM;
+
+       for (i = first_dword; i < last_dword; i++) {
+               if (!read_eeprom(hw, i * 4, &(eeprom_buff[i-first_dword])))
+                       return -EIO;
+       }
+
+       memcpy(bytes, (u8 *)eeprom_buff + (eeprom->offset & 3),
+                       eeprom->len);
+       kfree(eeprom_buff);
+
+       return ret_val;
+}
+
+static int atl1e_set_eeprom(struct net_device *netdev,
+               struct ethtool_eeprom *eeprom, u8 *bytes)
+{
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+       struct atl1e_hw *hw = &adapter->hw;
+       u32 *eeprom_buff;
+       u32 *ptr;
+       int max_len, first_dword, last_dword, ret_val = 0;
+       int i;
+
+       if (eeprom->len == 0)
+               return -EOPNOTSUPP;
+
+       if (eeprom->magic != (hw->vendor_id | (hw->device_id << 16)))
+               return -EFAULT;
+
+       max_len = 512;
+
+       first_dword = eeprom->offset >> 2;
+       last_dword = (eeprom->offset + eeprom->len - 1) >> 2;
+       eeprom_buff = kmalloc(max_len, GFP_KERNEL);
+       if (!eeprom_buff)
+               return -ENOMEM;
+
+       ptr = (u32 *)eeprom_buff;
+
+       if (eeprom->offset & 3) {
+               /* need read/modify/write of first changed EEPROM word */
+               /* only the second byte of the word is being modified */
+               if (!read_eeprom(hw, first_dword * 4, &(eeprom_buff[0])))
+                       return -EIO;
+               ptr++;
+       }
+       if (((eeprom->offset + eeprom->len) & 3)) {
+               /* need read/modify/write of last changed EEPROM word */
+               /* only the first byte of the word is being modified */
+
+               if (!read_eeprom(hw, last_dword * 4,
+                               &(eeprom_buff[last_dword - first_dword])))
+                       return -EIO;
+       }
+
+       /* Device's eeprom is always little-endian, word addressable */
+       memcpy(ptr, bytes, eeprom->len);
+
+       for (i = 0; i < last_dword - first_dword + 1; i++) {
+               if (!write_eeprom(hw, ((first_dword + i) * 4), eeprom_buff[i]))
+                       return -EIO;
+       }
+
+       kfree(eeprom_buff);
+       return ret_val;
+}
+
+static void atl1e_get_drvinfo(struct net_device *netdev,
+               struct ethtool_drvinfo *drvinfo)
+{
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+
+       strncpy(drvinfo->driver,  atl1e_driver_name, 32);
+       strncpy(drvinfo->version, atl1e_driver_version, 32);
+       strncpy(drvinfo->fw_version, "L1e", 32);
+       strncpy(drvinfo->bus_info, pci_name(adapter->pdev), 32);
+       drvinfo->n_stats = 0;
+       drvinfo->testinfo_len = 0;
+       drvinfo->regdump_len = atl1e_get_regs_len(netdev);
+       drvinfo->eedump_len = atl1e_get_eeprom_len(netdev);
+}
+
+static void atl1e_get_wol(struct net_device *netdev,
+                         struct ethtool_wolinfo *wol)
+{
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+
+       wol->supported = WAKE_MAGIC|WAKE_PHY;
+       wol->wolopts = 0;
+
+       if (adapter->wol & AT_WUFC_EX)
+               wol->wolopts |= WAKE_UCAST;
+       if (adapter->wol & AT_WUFC_MC)
+               wol->wolopts |= WAKE_MCAST;
+       if (adapter->wol & AT_WUFC_BC)
+               wol->wolopts |= WAKE_BCAST;
+       if (adapter->wol & AT_WUFC_MAG)
+               wol->wolopts |= WAKE_MAGIC;
+       if (adapter->wol & AT_WUFC_LNKC)
+               wol->wolopts |= WAKE_PHY;
+
+       return;
+}
+
+static int atl1e_set_wol(struct net_device *netdev, struct ethtool_wolinfo *wol)
+{
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+
+       if (wol->wolopts & (WAKE_ARP | WAKE_MAGICSECURE))
+               return -EOPNOTSUPP;
+
+       if (wol->wolopts & (WAKE_MCAST|WAKE_BCAST|WAKE_MCAST)) {
+               AT_DBG("Interface does not support broadcast/"
+                       "multicast frame wake-up packets\n");
+               return -EOPNOTSUPP;
+       }
+
+       /* these settings will always override what we currently have */
+       adapter->wol = 0;
+
+       if (wol->wolopts & WAKE_MAGIC) {
+               adapter->wol |= AT_WUFC_MAG;
+               DEBUGOUT("magic WOL enable");
+       }
+       if (wol->wolopts & WAKE_PHY) {
+               adapter->wol |= AT_WUFC_LNKC;
+               DEBUGOUT("linkchg WOL enable");
+       }
+
+       return 0;
+}
+
+static int atl1e_nway_reset(struct net_device *netdev)
+{
+       struct atl1e_adapter *adapter = netdev_priv(netdev);
+       if (netif_running(netdev))
+               atl1e_reinit_locked(adapter);
+       return 0;
+}
+
+
+static struct ethtool_ops atl1e_ethtool_ops = {
+       .get_settings           = atl1e_get_settings,
+       .set_settings           = atl1e_set_settings,
+       .get_drvinfo            = atl1e_get_drvinfo,
+       .get_regs_len           = atl1e_get_regs_len,
+       .get_regs               = atl1e_get_regs,
+       .get_wol                = atl1e_get_wol,
+       .set_wol                = atl1e_set_wol,
+       .get_msglevel           = atl1e_get_msglevel,
+       .set_msglevel           = atl1e_set_msglevel,
+       .nway_reset             = atl1e_nway_reset,
+       .get_link               = ethtool_op_get_link,
+       .get_eeprom_len         = atl1e_get_eeprom_len,
+       .get_eeprom             = atl1e_get_eeprom,
+       .set_eeprom             = atl1e_set_eeprom,
+       .get_tx_csum            = atl1e_get_tx_csum,
+       .get_sg                 = ethtool_op_get_sg,
+       .set_sg                 = ethtool_op_set_sg,
+#ifdef NETIF_F_TSO
+       .get_tso                = ethtool_op_get_tso,
+#endif
+};
+
+void atl1e_set_ethtool_ops(struct net_device *netdev)
+{
+       SET_ETHTOOL_OPS(netdev, &atl1e_ethtool_ops);
+}
+
diff -uprN -X linux-2.6.25.3.orig/Documentation/dontdiff linux-2.6.25.3.orig/drivers/net/atl1e/atl1e.h linux-2.6.25.3.atheros/drivers/net/atl1e/atl1e.h
--- linux-2.6.25.3.orig/drivers/net/atl1e/atl1e.h       1970-01-01 08:00:00.000000000 +0800
+++ linux-2.6.25.3.atheros/drivers/net/atl1e/atl1e.h    2008-06-20 11:22:34.000000000 +0800
@@ -0,0 +1,215 @@
+/*
+ * Copyright(c) 2007 Atheros Corporation. All rights reserved.
+ * Copyright(c) 2007 xiong huang <xiong.huang@atheros.com>
+ *
+ * Derived from Intel e1000 driver
+ * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
+ *
+ * This program is free software; you can redistribute it and/or modify it
+ * under the terms of the GNU General Public License as published by the Free
+ * Software Foundation; either version 2 of the License, or (at your option)
+ * any later version.
+ *
+ * This program is distributed in the hope that it will be useful, but WITHOUT
+ * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
+ * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
+ * more details.
+ *
+ * You should have received a copy of the GNU General Public License along with
+ * this program; if not, write to the Free Software Foundation, Inc., 59
+ * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
+ *
+ * There are a lot of defines in here that are unused and/or have cryptic
+ * names.  Please leave them alone, as they're the closest thing we have
+ * to a spec from Atheros at present. *ahem* -- CHS
+ */
+
+#ifndef _ATHEROS_H__
+#define _ATHEROS_H__
+
+#include <linux/version.h>
+#include <linux/init.h>
+#include <linux/types.h>
+#include <linux/errno.h>
+#include <linux/module.h>
+#include <linux/pci.h>
+#include <linux/netdevice.h>
+#include <linux/etherdevice.h>
+#include <linux/skbuff.h>
+#include <linux/ioport.h>
+#include <linux/slab.h>
+#include <linux/list.h>
+#include <linux/delay.h>
+#include <linux/sched.h>
+#include <linux/in.h>
+#include <linux/ip.h>
+#include <linux/ipv6.h>
+#include <linux/udp.h>
+#include <linux/mii.h>
+#include <linux/io.h>
+
+
+#include <linux/vmalloc.h>
+#include <linux/pagemap.h>
+#include <linux/tcp.h>
+#include <net/checksum.h>
+#include <net/ip6_checksum.h>
+#include <linux/mii.h>
+#include <linux/ethtool.h>
+#include <linux/if_vlan.h>
+
+
+#define BAR_0   0
+#define BAR_1   1
+#define BAR_5   5
+
+#define AT_TX_WATCHDOG  (5 * HZ)
+
+#define AT_VLAN_TAG_TO_TPD_TAG(_vlan, _tpd)    \
+       (_tpd) = (((_vlan) << 4) | (((_vlan) >> 13) & 7) |\
+                 (((_vlan) >> 9) & 8))
+
+#define AT_TPD_TAG_TO_VLAN_TAG(_tpd, _vlan)    \
+       (_vlan) = (((_tpd) >> 8) | (((_tpd) & 0x77) << 9) |\
+                  (((_tdp) & 0x88) << 5))
+
+#include "atl1e_hw.h"
+
+/* wrapper around a pointer to a socket buffer,
+ * so a DMA handle can be stored along with the buffer */
+
+#define AT_MAX_RECEIVE_QUEUE    4
+#define AT_PAGE_NUM_PER_QUEUE   2
+
+#define AT_DMA_HI_ADDR_MASK     0xffffffff00000000ULL
+#define AT_DMA_LO_ADDR_MASK     0x00000000ffffffffULL
+
+
+struct atl1e_tx_buffer {
+       struct sk_buff *skb;
+       u16 length;
+       dma_addr_t dma;
+};
+
+struct atl1e_rx_page {
+       dma_addr_t      dma;    /* receive rage DMA address */
+       u8              *addr;   /* receive rage virtual address */
+       dma_addr_t      write_offset_dma;  /* the DMA address which contain the
+                                             receive data offset in the page */
+       u32             *write_offset_addr; /* the virtaul address which contain
+                                            the receive data offset in the page */
+       u32             read_offset;       /* the offset where we have read */
+};
+
+struct atl1e_rx_page_desc {
+       struct atl1e_rx_page   rx_page[AT_PAGE_NUM_PER_QUEUE];
+       u8  rx_using;
+       u16 rx_nxseq;
+};
+
+/* transmit packet descriptor (tpd) ring */
+struct atl1e_tx_ring {
+       struct atl1e_tpd_desc *desc;  /* descriptor ring virtual address  */
+       dma_addr_t         dma;    /* descriptor ring physical address */
+       u16                count;  /* the count of transmit rings  */
+       rwlock_t           tx_lock;
+       u16                next_to_use;
+       atomic_t           next_to_clean;
+       struct atl1e_tx_buffer *tx_buffer;
+       dma_addr_t         cmb_dma;
+       u32                *cmb;
+};
+
+
+/* receive packet descriptor ring */
+struct atl1e_rx_ring {
+       void            *desc;
+       dma_addr_t      dma;
+       int             size;
+       u32             page_size; /* bytes length of rxf page */
+       u32             real_page_size; /* real_page_size = page_size + jumbo + aliagn */
+       struct atl1e_rx_page_desc       rx_page_desc[AT_MAX_RECEIVE_QUEUE];
+};
+/* board specific private data structure */
+
+struct atl1e_adapter {
+       struct net_device   *netdev;
+       struct pci_dev      *pdev;
+       struct vlan_group   *vlgrp;
+       struct atl1e_hw        hw;
+       struct atl1e_hw_stats  hw_stats;
+       struct net_device_stats net_stats;
+
+       bool pci_using_64;
+       bool have_msi;
+       u32 wol;
+       u16 link_speed;
+       u16 link_duplex;
+
+       spinlock_t mdio_lock;
+       spinlock_t tx_lock;
+       atomic_t irq_sem;
+
+       struct work_struct reset_task;
+       struct work_struct link_chg_task;
+       struct timer_list watchdog_timer;
+       struct timer_list phy_config_timer;
+
+       /* All Descriptor memory */
+       dma_addr_t      ring_dma;
+       void            *ring_vir_addr;
+       int             ring_size;
+
+       struct atl1e_tx_ring tx_ring;
+       struct atl1e_rx_ring rx_ring;
+       int num_rx_queues;
+
+#ifdef CONFIG_ATL1E_NAPI
+       struct napi_struct  napi;
+#endif
+
+       struct mii_if_info  mii;    /* MII interface info */
+       unsigned long flags;
+#define __AT_TESTING        0x0001
+#define __AT_RESETTING      0x0002
+#define __AT_DOWN           0x0003
+       u32 bd_number;     /* board number;*/
+
+       u32 pci_state[16];
+
+       u32 *config_space;
+};
+
+#define AT_MII_LOCK(_adapter)                          \
+       do {                                            \
+               spin_lock(&(_adapter)->mdio_lock);      \
+       } while (0)
+
+#define AT_MII_UNLOCK(_adapter)                                \
+       do {                                            \
+               spin_unlock(&(_adapter)->mdio_lock);    \
+       } while (0)
+
+#define AT_MII_LOCK_IRQSAVE(_adapter, _flags)                          \
+       do {                                                            \
+               spin_lock_irqsave(&(_adapter)->mdio_lock, (_flags));    \
+       } while (0)
+
+#define AT_MII_UNLOCK_IRQRESTORE(_adapter, _flags)                      \
+       do {                                                             \
+               spin_unlock_irqrestore(&(_adapter)->mdio_lock, (_flags));\
+       } while (0)
+
+extern char atl1e_driver_name[];
+extern char atl1e_driver_version[];
+
+extern void atl1e_check_options(struct atl1e_adapter *adapter);
+extern int cancel_work_sync(struct work_struct *work);
+extern int atl1e_up(struct atl1e_adapter *adapter);
+extern void atl1e_down(struct atl1e_adapter *adapter);
+extern void atl1e_reinit_locked(struct atl1e_adapter *adapter);
+extern s32 atl1e_reset_hw(struct atl1e_hw *hw);
+
+
+#endif /* _ATHEROS_H__ */
+
