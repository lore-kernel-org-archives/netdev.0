From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: [PATCH] atl1c:Atheros L1C Gigabit Ethernet driver
Date: Mon, 16 Feb 2009 07:37:09 -0600
Message-ID: <20090216073709.418b3957@osprey.hogchain.net>
References: <12347653231514-git-send-email-jie.yang@atheros.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <jirislaby@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	Jie Yang <jie.yang@atheros.com>
To: <jie.yang@atheros.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757984AbZBPNhe@vger.kernel.org>
In-Reply-To: <12347653231514-git-send-email-jie.yang@atheros.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Feb 2009 14:22:03 +0800
<jie.yang@atheros.com> wrote:

> From: Jie Yang <jie.yang@atheros.com>
> 
> Supporting AR8131, and AR8132.
> 
> Signed-off-by: Jie Yang <jie.yang@atheros.com>
> ---
> 
[...]

> +
> +static int atl1c_set_settings(struct net_device *netdev,
> +			      struct ethtool_cmd *ecmd)
> +{
> +	struct atl1c_adapter *adapter = netdev_priv(netdev);
> +	struct atl1c_hw *hw = &adapter->hw;
> +	u16  autoneg_advertised;
> +	while (test_and_set_bit(__AT_RESETTING, &adapter->flags))
> +		msleep(1);
> +
> +	if (ecmd->autoneg == AUTONEG_ENABLE) {
> +		autoneg_advertised = ADVERTISED_Autoneg;
> +	} else {
> +		if (ecmd->speed == SPEED_1000) {
> +			if (ecmd->duplex != DUPLEX_FULL) {
> +				printk(KERN_WARNING"1000M half is invalid\n");

Consider converting all printks to dev_*.

> +				clear_bit(__AT_RESETTING, &adapter->flags);
> +				return -EINVAL;
> +			}
> +			autoneg_advertised = ADVERTISED_1000baseT_Full;
> +		} else if (ecmd->speed == SPEED_100) {
> +			if (ecmd->duplex == DUPLEX_FULL)
> +				autoneg_advertised = ADVERTISED_100baseT_Full;
> +			else
> +				autoneg_advertised = ADVERTISED_100baseT_Half;
> +		} else {
> +			if (ecmd->duplex == DUPLEX_FULL)
> +				autoneg_advertised = ADVERTISED_10baseT_Full;
> +			else
> +				autoneg_advertised = ADVERTISED_10baseT_Half;
> +		}
> +	}
> +
> +	if (hw->autoneg_advertised != autoneg_advertised) {
> +		hw->autoneg_advertised = autoneg_advertised;
> +		if (atl1c_restart_autoneg(hw) != 0) {
> +			printk(KERN_WARNING
> +				"ethtool speed/duplex setting failed\n");
> +			clear_bit(__AT_RESETTING, &adapter->flags);
> +			return -EINVAL;
> +		}
> +	}
> +	clear_bit(__AT_RESETTING, &adapter->flags);
> +	return 0;
> +}
> +
> +static u32 atl1c_get_tx_csum(struct net_device *netdev)
> +{
> +	return (netdev->features & NETIF_F_HW_CSUM) != 0;
> +}
> +
> +static u32 atl1c_get_msglevel(struct net_device *netdev)
> +{
> +#ifdef DBG
> +	return 1;
> +#else
> +	return 0;
> +#endif
> +}
> +
> +static void atl1c_set_msglevel(struct net_device *netdev, u32 data)
> +{
> +}

Do-nothing function.  Remove?

[...]
> +
> +bool atl1c_write_eeprom(struct atl1c_hw *hw, u32 offset, u32 value)
> +{
> +	return true;
> +}

Ditto.

> +
> +bool atl1c_read_eeprom(struct atl1c_hw *hw, u32 offset, u32 *p_value)
> +{
> +	int i;
> +	int ret = false;
> +	u32 otp_ctrl_data;
> +	u32 control;
> +	u32 data;
> +
> +	if (offset & 3)
> +		return ret; /* address do not align */
> +
> +	AT_READ_REG(hw, REG_OTP_CTRL, &otp_ctrl_data);
> +	if (!(otp_ctrl_data & OTP_CTRL_CLK_EN))
> +		AT_WRITE_REG(hw, REG_OTP_CTRL,
> +				(otp_ctrl_data | OTP_CTRL_CLK_EN));
> +
> +	AT_WRITE_REG(hw, REG_EEPROM_DATA_LO, 0);
> +	control = (offset & EEPROM_CTRL_ADDR_MASK) << EEPROM_CTRL_ADDR_SHIFT;
> +	AT_WRITE_REG(hw, REG_EEPROM_CTRL, control);
> +
> +	for (i = 0; i < 10; i++) {
> +		udelay(100);
> +		AT_READ_REG(hw, REG_EEPROM_CTRL, &control);
> +		if (control & EEPROM_CTRL_RW)
> +			break;
> +	}
> +	if (control & EEPROM_CTRL_RW) {
> +		AT_READ_REG(hw, REG_EEPROM_CTRL, &data);
> +		AT_READ_REG(hw, REG_EEPROM_DATA_LO, p_value);
> +		data = data & 0xFFFF;
> +		*p_value = swab32((data << 16) | (*p_value >> 16));
> +		ret = true;
> +	}
> +	if (!(otp_ctrl_data & OTP_CTRL_CLK_EN))
> +		AT_WRITE_REG(hw, REG_OTP_CTRL, otp_ctrl_data);
> +
> +	return ret;
> +}
> +/*
> + * Reads the adapter's MAC address from the EEPROM
> + *
> + * hw - Struct containing variables accessed by shared code
> + */
> +int atl1c_read_mac_addr(struct atl1c_hw *hw)
> +{
> +	int err = 0;
> +
> +	err = atl1c_get_permanent_address(hw);
> +	if (err) {
> +		hw->perm_mac_addr[0] = 0x00;
> +		hw->perm_mac_addr[1] = 0x13;
> +		hw->perm_mac_addr[2] = 0x74;
> +		hw->perm_mac_addr[3] = 0x00;
> +		hw->perm_mac_addr[4] = 0x5c;
> +		hw->perm_mac_addr[5] = 0x38;
> +	}

Better to use random_ether_addr() here.

> +
> +	memcpy(hw->mac_addr, hw->perm_mac_addr, sizeof(hw->perm_mac_addr));
> +	return 0;
> +}
> +
> +/*
> + * atl1c_hash_mc_addr
> + *  purpose
> + *      set hash value for a multicast address
> + *      hash calcu processing :
> + *          1. calcu 32bit CRC for multicast address
> + *          2. reverse crc with MSB to LSB
> + */
> +u32 atl1c_hash_mc_addr(struct atl1c_hw *hw, u8 *mc_addr)
> +{
> +	u32 crc32;
> +	u32 value = 0;
> +	int i;
> +
> +	crc32 = ether_crc_le(6, mc_addr);
> +	for (i = 0; i < 32; i++)
> +		value |= (((crc32 >> i) & 1) << (31 - i));
> +
> +	return value;
> +}
> +
> +/*
> + * Sets the bit in the multicast table corresponding to the hash value.
> + * hw - Struct containing variables accessed by shared code
> + * hash_value - Multicast address hash value
> + */
> +void atl1c_hash_set(struct atl1c_hw *hw, u32 hash_value)
> +{
> +	u32 hash_bit, hash_reg;
> +	u32 mta;
> +
> +	/*
> +	 * The HASH Table  is a register array of 2 32-bit registers.
> +	 * It is treated like an array of 64 bits.  We want to set
> +	 * bit BitArray[hash_value]. So we figure out what register
> +	 * the bit is in, read it, OR in the new bit, then write
> +	 * back the new value.  The register is determined by the
> +	 * upper 7 bits of the hash value and the bit within that
> +	 * register are determined by the lower 5 bits of the value.
> +	 */

Comment is incorrect; the register is determined by the upper bit, not the upper 7 bits.

> +	hash_reg = (hash_value >> 31) & 0x1;
> +	hash_bit = (hash_value >> 26) & 0x1F;
> +
> +	mta = AT_READ_REG_ARRAY(hw, REG_RX_HASH_TABLE, hash_reg);
> +
> +	mta |= (1 << hash_bit);
> +
> +	AT_WRITE_REG_ARRAY(hw, REG_RX_HASH_TABLE, hash_reg, mta);
> +}
[...]
> diff --git a/drivers/net/atl1c/atl1c_hw.h b/drivers/net/atl1c/atl1c_hw.h
> new file mode 100644
> index 0000000..f5bbfce
> --- /dev/null
> +++ b/drivers/net/atl1c/atl1c_hw.h
> @@ -0,0 +1,866 @@
> +/*
> + * Copyright(c) 2008 - 2009 Atheros Corporation. All rights reserved.
> + *
> + * Derived from Intel e1000 driver
> + * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by the Free
> + * Software Foundation; either version 2 of the License, or (at your option)
> + * any later version.
> + *
> + * This program is distributed in the hope that it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License along with
> + * this program; if not, write to the Free Software Foundation, Inc., 59
> + * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + */
> +
> +#ifndef _ATL1C_HW_H_
> +#define _ATL1C_HW_H_
> +
> +#include <linux/types.h>
> +#include <linux/mii.h>
> +
> +struct atl1c_adapter;
> +struct atl1c_hw;
> +
> +/* function prototype */
> +void atl1c_phy_disable(struct atl1c_hw *hw);
> +void atl1c_hw_set_mac_addr(struct atl1c_hw *hw);
> +int atl1c_phy_reset(struct atl1c_hw *hw);
> +int atl1c_read_mac_addr(struct atl1c_hw *hw);
> +int atl1c_get_speed_and_duplex(struct atl1c_hw *hw, u16 *speed, u16 *duplex);
> +u32 atl1c_auto_get_fc(struct atl1c_adapter *adapter, u16 duplex);
> +u32 atl1c_hash_mc_addr(struct atl1c_hw *hw, u8 *mc_addr);
> +void atl1c_hash_set(struct atl1c_hw *hw, u32 hash_value);
> +int atl1c_read_phy_reg(struct atl1c_hw *hw, u16 reg_addr, u16 *phy_data);
> +int atl1c_write_phy_reg(struct atl1c_hw *hw, u32 reg_addr, u16 phy_data);
> +int atl1c_validate_mdi_setting(struct atl1c_hw *hw);
> +void atl1c_hw_set_mac_addr(struct atl1c_hw *hw);
> +bool atl1c_read_eeprom(struct atl1c_hw *hw, u32 offset, u32 *p_value);
> +bool atl1c_write_eeprom(struct atl1c_hw *hw, u32 offset, u32 value);
> +int atl1c_phy_enter_power_saving(struct atl1c_hw *hw);
> +int atl1c_phy_leave_power_saving(struct atl1c_hw *hw);
> +int atl1c_phy_init(struct atl1c_hw *hw);
> +int atl1c_check_eeprom_exist(struct atl1c_hw *hw);
> +void atl1c_force_ps(struct atl1c_hw *hw);
> +int atl1c_restart_autoneg(struct atl1c_hw *hw);

Are all these declarations needed?

[...]
> diff --git a/drivers/net/atl1c/atl1c_main.c b/drivers/net/atl1c/atl1c_main.c
> new file mode 100644
> index 0000000..21c17b4
> --- /dev/null
> +++ b/drivers/net/atl1c/atl1c_main.c
> @@ -0,0 +1,2769 @@
> +/*
> + * Copyright(c) 2008 - 2009 Atheros Corporation. All rights reserved.
> + *
> + * Derived from Intel e1000 driver
> + * Copyright(c) 1999 - 2005 Intel Corporation. All rights reserved.
> + *
> + * This program is free software; you can redistribute it and/or modify it
> + * under the terms of the GNU General Public License as published by the Free
> + * Software Foundation; either version 2 of the License, or (at your option)
> + * any later version.
> + *
> + * This program is distributed in the hope that it will be useful, but WITHOUT
> + * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
> + * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
> + * more details.
> + *
> + * You should have received a copy of the GNU General Public License along with
> + * this program; if not, write to the Free Software Foundation, Inc., 59
> + * Temple Place - Suite 330, Boston, MA  02111-1307, USA.
> + */
> +
> +#include "atl1c.h"
> +
> +#define DRV_VERSION "1.0.0.1-NAPI"
> +char atl1c_driver_name[] = "ATL1C";

Minor nit, but why is the driver name uppercase?

> +char atl1c_driver_version[] = DRV_VERSION;
> +#define PCI_DEVICE_ID_ATTANSIC_L2C      0x1062
> +#define PCI_DEVICE_ID_ATTANSIC_L1C      0x1063

The kconfig file indicates support for only the L1C.  Does this driver also support the L2C?  Is the L1C a gigabit device and the L2C a 10/100 device?

> +/*
> + * atl1c_pci_tbl - PCI Device ID Table
> + *
> + * Wildcard entries (PCI_ANY_ID) should come last
> + * Last entry must be all 0s
> + *
> + * { Vendor ID, Device ID, SubVendor ID, SubDevice ID,
> + *   Class, Class Mask, private data (not used) }
> + */
> +static struct pci_device_id atl1c_pci_tbl[] = {
> +	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L1C)},
> +	{PCI_DEVICE(PCI_VENDOR_ID_ATTANSIC, PCI_DEVICE_ID_ATTANSIC_L2C)},
> +	/* required last entry */
> +	{ 0 }
> +};
> +MODULE_DEVICE_TABLE(pci, atl1c_pci_tbl);
> +
> +MODULE_AUTHOR("Jie Yang <jie.yang@atheros.com>");
> +MODULE_DESCRIPTION("Atheros 1000M Ethernet Network Driver");
> +MODULE_LICENSE("GPL");
> +MODULE_VERSION(DRV_VERSION);
> +
> +static int atl1c_stop_mac(struct atl1c_hw *hw);
> +static void atl1c_enable_rx_ctrl(struct atl1c_hw *hw);
> +static void atl1c_enable_tx_ctrl(struct atl1c_hw *hw);
> +static void atl1c_disable_l0s_l1(struct atl1c_hw *hw);
> +static void atl1c_set_aspm(struct atl1c_hw *hw, bool linkup);
> +static void atl1c_setup_mac_ctrl(struct atl1c_adapter *adapter);
> +static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter, u8 que,
> +		   int *work_done, int work_to_do);

Please reorder the code to eliminate the need for these forward declarations.

[...]
> +static void atl1c_reset_task(struct work_struct *work)
> +{
> +	struct atl1c_adapter *adapter;
> +	u32 isr_data;
> +
> +	adapter = container_of(work, struct atl1c_adapter, reset_task);
> +
> +	if (netif_queue_stopped(adapter->netdev) &&
> +			netif_carrier_ok(adapter->netdev)) {
> +		AT_READ_REG(&adapter->hw, REG_ISR, &isr_data);
> +		printk(KERN_EMERG "TX STOPED!\n");
> +		printk(KERN_EMERG "reset hardware!\n");
> +		printk(KERN_EMERG "ISR is %x\n", isr_data);
> +		netif_wake_queue(adapter->netdev);
> +	}
> +}

This function doesn't seem to reset the hardware as the name and printks imply.  It just reads the ISR and wakes the tx queue.  Also s/STOPED/STOPPED.

[...]
> +static void atl1c_clean_rx_irq(struct atl1c_adapter *adapter, u8 que,
> +		   int *work_done, int work_to_do)
> +{
> +	u16 rfd_num, rfd_index;
> +	u16 count = 0;
> +	u16 length;
> +	struct pci_dev *pdev = adapter->pdev;
> +	struct net_device *netdev  = adapter->netdev;
> +	struct atl1c_rfd_ring *rfd_ring = &adapter->rfd_ring[que];
> +	struct atl1c_rrd_ring *rrd_ring = &adapter->rrd_ring[que];
> +	struct sk_buff *skb;
> +	struct atl1c_recv_ret_status *rrs;
> +	struct atl1c_buffer *buffer_info;
> +
> +	while (1) {
> +		if (*work_done >= work_to_do)
> +			break;
> +		rrs = ATL1C_RRD_DESC(rrd_ring, rrd_ring->next_to_clean);
> +		if (likely(RRS_RXD_IS_VALID(rrs->word3))) {
> +			rfd_num = (rrs->word0 >> RRS_RX_RFD_CNT_SHIFT) &
> +				RRS_RX_RFD_CNT_MASK;
> +			if (unlikely(rfd_num) != 1)
> +				/* TODO support mul rfd*/
> +				printk(KERN_EMERG "Multi rfd not support yet!\n");

"Mulitple rfd not supported"  And why KERN_EMERG?

> +			goto rrs_checked;
> +		} else {
> +			break;
> +		}
> +rrs_checked:
> +		atl1c_clean_rrd(rrd_ring, rrs, rfd_num);
> +		if (rrs->word3 & (RRS_RX_ERR_SUM | RRS_802_3_LEN_ERR)) {
> +			atl1c_clean_rfd(rfd_ring, rrs, rfd_num);
> +			printk(KERN_WARNING "wrong packet! rrs word3 is %x\n", rrs->word3);
> +			continue;
> +		}
> +
> +		length = le16_to_cpu((rrs->word3 >> RRS_PKT_SIZE_SHIFT) &
> +				RRS_PKT_SIZE_MASK);
> +		/* Good Receive */
> +		if (likely(rfd_num == 1)) {
> +			rfd_index = (rrs->word0 >> RRS_RX_RFD_INDEX_SHIFT) &
> +					RRS_RX_RFD_INDEX_MASK;
> +			buffer_info = &rfd_ring->buffer_info[rfd_index];
> +			pci_unmap_single(pdev, buffer_info->dma,
> +				buffer_info->length, PCI_DMA_FROMDEVICE);
> +			skb = buffer_info->skb;
> +		} else {
> +			/* TODO */
> +			printk(KERN_EMERG "Multil rfd not support yet!\n");

Ditto.

[...] 
> +
> +/*
> + * get next usable tpd
> + * Note: should call atl1c_tdp_avail to make sure
> + * there is enough tpd to use
> + */
> +static struct atl1c_tpd_desc *atl1c_get_tpd(struct atl1c_adapter *adapter,
> +	enum atl1c_trans_queue type)
> +{
> +	struct atl1c_tpd_ring *tpd_ring = &adapter->tpd_ring[type];
> +	struct atl1c_tpd_desc *tpd_desc;
> +	u16 next_to_use = 0;

Unnecessary initialization. (Lots and lots of other places, too.)

[...]
> +check_sum:
> +	if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
> +		u8 css, cso;
> +		cso = skb_transport_offset(skb);
> +
> +		if (unlikely(cso & 0x1)) {
> +			dev_err(&adapter->pdev->dev,
> +			   "pay load offset should not ant event number\n");

s/pay load/payload
s/ant/an

[...]
> +static int atl1c_open(struct net_device *netdev)
> +{
> +	struct atl1c_adapter *adapter = netdev_priv(netdev);
> +	int err;
> +
> +	/* disallow open during test */
> +	if (test_bit(__AT_TESTING, &adapter->flags))
> +		return -EBUSY;
> +
> +	/* allocate rx/tx dma buffer & descriptors */
> +	err = atl1c_setup_ring_resources(adapter);
> +	if (unlikely(err))
> +		return err;
> +
> +	err = atl1c_up(adapter);
> +	if (unlikely(err))
> +		goto err_up;
> +
> +	if (adapter->hw.ctrl_flags & ATL1C_FPGA_VERSION) {
> +		u32 phy_data;
> +
> +		AT_READ_REG(&adapter->hw, 0x1414, &phy_data);
> +		phy_data |= 0x10000000;
> +		AT_WRITE_REG(&adapter->hw, 0x1414, phy_data);

Please use the defined constant, REG_MDIO_CTRL.

> +	}
> +	return 0;
> +
> +err_up:
> +	atl1c_free_irq(adapter);
> +	atl1c_free_ring_resources(adapter);
> +	atl1c_reset_mac(&adapter->hw);
> +	return err;
> +}
> +
> +/*
> + * atl1c_close - Disables a network interface
> + * @netdev: network interface device structure
> + *
> + * Returns 0, this is not allowed to fail
> + *
> + * The close entry point is called when an interface is de-activated
> + * by the OS.  The hardware is still under the drivers control, but
> + * needs to be disabled.  A global MAC reset is issued to stop the
> + * hardware, and all transmit and receive resources are freed.
> + */
> +static int atl1c_close(struct net_device *netdev)
> +{
> +	struct atl1c_adapter *adapter = netdev_priv(netdev);
> +
> +	WARN_ON(test_bit(__AT_RESETTING, &adapter->flags));
> +	atl1c_down(adapter);
> +	atl1c_free_ring_resources(adapter);
> +	return 0;
> +}
> +
> +#ifdef CONFIG_PM
> +static int atl1c_suspend(struct pci_dev *pdev, pm_message_t state)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct atl1c_adapter *adapter = netdev_priv(netdev);
> +	struct atl1c_hw *hw = &adapter->hw;
> +	u32 ctrl = 0;
> +	u32 mac_ctrl_data = 0;
> +	u32 master_ctrl_data = 0;
> +	u32 wol_ctrl_data = 0;
> +	u16 mii_bmsr_data = 0;
> +	u16 save_autoneg_advertised;
> +	u16 mii_intr_status_data = 0;
> +	u32 wufc = adapter->wol;
> +	u32 i;
> +#ifdef CONFIG_PM
> +	int retval = 0;
> +#endif

Unnecessary ifdef/endif.

> +
> +	if (netif_running(netdev)) {
> +		WARN_ON(test_bit(__AT_RESETTING, &adapter->flags));
> +		atl1c_down(adapter);
> +	}
> +	netif_device_detach(netdev);
> +	atl1c_disable_l0s_l1(hw);
> +#ifdef CONFIG_PM
> +	retval = pci_save_state(pdev);
> +	if (retval)
> +		return retval;
> +#endif

Ditto.

[...]
> +static void atl1c_shutdown(struct pci_dev *pdev)
> +{
> +	atl1c_suspend(pdev, PMSG_SUSPEND);
> +}

I didn't try, but I don't think this will build without CONFIG_PM.

[...]
> +/*
> + * atl1c_io_slot_reset - called after the pci bus has been reset.
> + * @pdev: Pointer to PCI device
> + *
> + * Restart the card from scratch, as if from a cold-boot. Implementation
> + * resembles the first-half of the e1000_resume routine.
> + */
> +static pci_ers_result_t atl1c_io_slot_reset(struct pci_dev *pdev)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct atl1c_adapter *adapter = netdev_priv(netdev);
> +
> +	if (pci_enable_device(pdev)) {
> +		dev_err(&pdev->dev,
> +		       "ATL1e: Cannot re-enable PCI device after reset.\n");

Remove ATL1e.

> +		return PCI_ERS_RESULT_DISCONNECT;
> +	}
> +	pci_set_master(pdev);
> +
> +	pci_enable_wake(pdev, PCI_D3hot, 0);
> +	pci_enable_wake(pdev, PCI_D3cold, 0);
> +
> +	atl1c_reset_mac(&adapter->hw);
> +
> +	return PCI_ERS_RESULT_RECOVERED;
> +}
> +
> +/*
> + * atl1c_io_resume - called when traffic can start flowing again.
> + * @pdev: Pointer to PCI device
> + *
> + * This callback is called when the error recovery driver tells us that
> + * its OK to resume normal operation. Implementation resembles the
> + * second-half of the atl1c_resume routine.
> + */
> +static void atl1c_io_resume(struct pci_dev *pdev)
> +{
> +	struct net_device *netdev = pci_get_drvdata(pdev);
> +	struct atl1c_adapter *adapter = netdev_priv(netdev);
> +
> +	if (netif_running(netdev)) {
> +		if (atl1c_up(adapter)) {
> +			dev_err(&pdev->dev,
> +			  "ATL1e: can't bring device back up after reset\n");

Ditto.
