From: Andrew Morton <akpm@osdl.org>
Subject: Re: New Qlogic qla3xxx NIC Driver v2.02.00k31 for upstream
 inclusion
Date: Wed, 21 Jun 2006 21:55:31 -0700
Message-ID: <20060621215531.14812d7c.akpm@osdl.org>
References: <0BB3E5E7462EEA4295BC02D49691DC07176751@AVEXCH1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, linux-driver@qlogic.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:50895 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932228AbWFVE4D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 00:56:03 -0400
To: "Ron Mercer" <ron.mercer@qlogic.com>
In-Reply-To: <0BB3E5E7462EEA4295BC02D49691DC07176751@AVEXCH1.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Jun 2006 14:24:27 -0700
"Ron Mercer" <ron.mercer@qlogic.com> wrote:

> Please add the qla3xxx NIC driver to the next netdev-2.6 GIT tree. 

- We won't be able to include this withot a Signed-off-by: as per section
  11 of Documentation/SubmittingPatches.

- The driver does a lot of:

static void ql_write_page0_reg(struct ql3_adapter *qdev,
			       volatile u32 * pRegister, u32 value)
{
	...
	writel(value, (u32 *) pRegister);

The volatile is undesirable (and, for writel, unneeded) (and ity has been
typecast away anwyay).

And the arg to writel is of the type `void __iomem *'.  Really, this
function should take an arg of type `void __iomem *pRegister' or `u32
__iomem *pRegister'.

Treat __iomem as a C type, and propagate it correctly from top to bottom
and you cannot go wrong.

- What's going on here?

static void fm93c56a_deselect(struct ql3_adapter *qdev)
{
	struct ql3xxx_port_registers *port_regs =
	    (struct ql3xxx_port_registers *)qdev->mem_map_registers;

  ->mem_map_registers is already of type `struct ql3xxx_port_registers
  __iomem *', so all the cast here does is to remove the __iomem, making
  the code incorrect...

  (many instances)

- Is there a better way of doing this?

static void ql_swap_mac_addr(u8 * macAddress)
{
#ifdef __BIG_ENDIAN
	u8 temp;
	temp = macAddress[0];
	macAddress[0] = macAddress[1];
	macAddress[1] = temp;
	temp = macAddress[2];
	macAddress[2] = macAddress[3];
	macAddress[3] = temp;
	temp = macAddress[4];
	macAddress[4] = macAddress[5];
	macAddress[5] = temp;
#endif
}

  It seems like a common sort of thing to do?

- ql_mii_write_reg_ex() has two up-to-10-millisecond busywaits.

- In fact, those up-to-10-millisecond busywaits are all over the place.

- The driver would be cleaner if it had a helper function rather than
  open-coding all those up-to-10-millisecond busywaits.


Have some random tweaks:


From: Andrew Morton <akpm@osdl.org>

- coding style

- use cpu_relax()

- use msleep()

Cc: "Ron Mercer" <ron.mercer@qlogic.com>
Cc: Jeff Garzik <jeff@garzik.org>
Cc: Stephen Hemminger <shemminger@osdl.org>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 drivers/net/qla3xxx.c |  164 +++++++++++++++-------------------------
 1 file changed, 65 insertions(+), 99 deletions(-)

diff -puN drivers/net/qla3xxx.c~qla3xxx-NIC-driver-tidy drivers/net/qla3xxx.c
--- a/drivers/net/qla3xxx.c~qla3xxx-NIC-driver-tidy
+++ a/drivers/net/qla3xxx.c
@@ -57,7 +57,7 @@ static int debug = -1;		/* defaults abov
 module_param(debug, int, 0);
 MODULE_PARM_DESC(debug, "Debug level (0=none,...,16=all)");
 
-static int msi = 0;
+static int msi;
 module_param(msi, int, 0);
 MODULE_PARM_DESC(msi, "Turn on Message Signaled Interrupts.");
 
@@ -84,6 +84,7 @@ static void ql_sem_spinlock(struct ql3_a
 		spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 		if ((value & (sem_mask >> 16)) == sem_bits)
 			break;
+		cpu_relax();
 	}
 }
 
@@ -121,12 +122,11 @@ static int ql_wait_for_drvr_lock(struct 
 				 (QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index)
 				  * 2) << 1)) {
 			if (i < 10) {
-				set_current_state(TASK_UNINTERRUPTIBLE);
-				schedule_timeout(1 * HZ);
+				msleep(1000);
 				i++;
 			} else {
-				printk(KERN_ERR PFX
-				       "%s: Timed out waiting for driver lock...\n",
+				printk(KERN_ERR PFX "%s: Timed out waiting for "
+				       "driver lock...\n",
 				       qdev->ndev->name);
 				return 0;
 			}
@@ -149,7 +149,7 @@ static u32 ql_read_common_reg(struct ql3
 	value = readl(pRegister);
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
 
-	return (value);
+	return value;
 }
 
 static u32 ql_read_page0_reg(struct ql3_adapter *qdev, volatile u32 * pRegister)
@@ -170,7 +170,7 @@ static u32 ql_read_page0_reg(struct ql3_
 	value = readl(pRegister);
 
 	spin_unlock_irqrestore(&qdev->hw_lock, hw_flags);
-	return (value);
+	return value;
 }
 
 static void ql_write_common_reg(struct ql3_adapter *qdev,
@@ -324,7 +324,7 @@ static struct ql_rcv_buf_cb *ql_get_from
 		qdev->lrg_buf_free_count--;
 	}
 
-	return (lrg_buf_cb);
+	return lrg_buf_cb;
 }
 
 static u32 addrBits = EEPROM_NO_ADDR_BITS;
@@ -439,7 +439,7 @@ static void fm93c56a_deselect(struct ql3
 {
 	struct ql3xxx_port_registers *port_regs =
 	    (struct ql3xxx_port_registers *)qdev->mem_map_registers;
-	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_0;
+  	qdev->eeprom_cmd_data = AUBURN_EEPROM_CS_0;
 	ql_write_common_reg(qdev, &port_regs->CommonRegs.serialPortInterfaceReg,
 			    ISP_NVRAM_MASK | qdev->eeprom_cmd_data);
 }
@@ -618,12 +618,11 @@ static int ql_mii_write_reg_ex(struct ql
 	count = 1000;
 	while (count) {
 		temp = ql_read_page0_reg(qdev, &port_regs->macMIIStatusReg);
-		if (!(temp & MAC_MII_STATUS_BSY)) {
+		if (!(temp & MAC_MII_STATUS_BSY))
 			break;
-		}
 		udelay(10);
 		count--;
-	};
+	}
 	if (!count) {
 		if (netif_msg_link(qdev))
 			printk(KERN_WARNING PFX
@@ -643,12 +642,11 @@ static int ql_mii_write_reg_ex(struct ql
 	count = 1000;
 	while (count) {
 		temp = ql_read_page0_reg(qdev, &port_regs->macMIIStatusReg);
-		if (!(temp & MAC_MII_STATUS_BSY)) {
+		if (!(temp & MAC_MII_STATUS_BSY))
 			break;
-		}
 		udelay(10);
 		count--;
-	};
+	}
 	if (!count) {
 		if (netif_msg_link(qdev))
 			printk(KERN_WARNING PFX
@@ -684,12 +682,11 @@ static int ql_mii_read_reg_ex(struct ql3
 	count = 1000;
 	while (count) {
 		temp = ql_read_page0_reg(qdev, &port_regs->macMIIStatusReg);
-		if (!(temp & MAC_MII_STATUS_BSY)) {
+		if (!(temp & MAC_MII_STATUS_BSY))
 			break;
-		}
 		udelay(10);
 		count--;
-	};
+	}
 	if (!count) {
 		if (netif_msg_link(qdev))
 			printk(KERN_WARNING PFX
@@ -713,12 +710,11 @@ static int ql_mii_read_reg_ex(struct ql3
 	count = 1000;
 	while (count) {
 		temp = ql_read_page0_reg(qdev, &port_regs->macMIIStatusReg);
-		if (!(temp & MAC_MII_STATUS_BSY)) {
+		if (!(temp & MAC_MII_STATUS_BSY))
 			break;
-		}
 		udelay(10);
 		count--;
-	};
+	}
 	if (!count) {
 		if (netif_msg_link(qdev))
 			printk(KERN_WARNING PFX
@@ -756,12 +752,11 @@ static int ql_mii_write_reg(struct ql3_a
 	count = 1000;
 	while (count) {
 		temp = ql_read_page0_reg(qdev, &port_regs->macMIIStatusReg);
-		if (!(temp & MAC_MII_STATUS_BSY)) {
+		if (!(temp & MAC_MII_STATUS_BSY))
 			break;
-		}
 		udelay(10);
 		count--;
-	};
+	}
 	if (!count) {
 		if (netif_msg_link(qdev))
 			printk(KERN_WARNING PFX
@@ -781,12 +776,11 @@ static int ql_mii_write_reg(struct ql3_a
 	count = 1000;
 	while (count) {
 		temp = ql_read_page0_reg(qdev, &port_regs->macMIIStatusReg);
-		if (!(temp & MAC_MII_STATUS_BSY)) {
+		if (!(temp & MAC_MII_STATUS_BSY))
 			break;
-		}
 		udelay(10);
 		count--;
-	};
+	}
 	if (!count) {
 		if (netif_msg_link(qdev))
 			printk(KERN_WARNING PFX
@@ -803,7 +797,7 @@ static int ql_mii_write_reg(struct ql3_a
 	return 0;
 }
 
-static int ql_mii_read_reg(struct ql3_adapter *qdev, u16 regAddr, u16 * value)
+static int ql_mii_read_reg(struct ql3_adapter *qdev, u16 regAddr, u16 *value)
 {
 	u32 temp;
 	struct ql3xxx_port_registers *port_regs =
@@ -819,12 +813,11 @@ static int ql_mii_read_reg(struct ql3_ad
 	count = 1000;
 	while (count) {
 		temp = ql_read_page0_reg(qdev, &port_regs->macMIIStatusReg);
-		if (!(temp & MAC_MII_STATUS_BSY)) {
+		if (!(temp & MAC_MII_STATUS_BSY))
 			break;
-		}
 		udelay(10);
 		count--;
-	};
+	}
 	if (!count) {
 		if (netif_msg_link(qdev))
 			printk(KERN_WARNING PFX
@@ -848,12 +841,11 @@ static int ql_mii_read_reg(struct ql3_ad
 	count = 1000;
 	while (count) {
 		temp = ql_read_page0_reg(qdev, &port_regs->macMIIStatusReg);
-		if (!(temp & MAC_MII_STATUS_BSY)) {
+		if (!(temp & MAC_MII_STATUS_BSY))
 			break;
-		}
 		udelay(10);
 		count--;
-	};
+	}
 	if (!count) {
 		if (netif_msg_link(qdev))
 			printk(KERN_WARNING PFX
@@ -992,11 +984,10 @@ static void ql_mac_enable(struct ql3_ada
 	else
 		value = (MAC_CONFIG_REG_PE << 16);
 
-	if (qdev->mac_index) {
+	if (qdev->mac_index)
 		ql_write_page0_reg(qdev, &port_regs->mac1ConfigReg, value);
-	} else {
+	else
 		ql_write_page0_reg(qdev, &port_regs->mac0ConfigReg, value);
-	}
 }
 
 static void ql_mac_cfg_soft_reset(struct ql3_adapter *qdev, u32 enable)
@@ -1010,11 +1001,10 @@ static void ql_mac_cfg_soft_reset(struct
 	else
 		value = (MAC_CONFIG_REG_SR << 16);
 
-	if (qdev->mac_index) {
+	if (qdev->mac_index)
 		ql_write_page0_reg(qdev, &port_regs->mac1ConfigReg, value);
-	} else {
+	else
 		ql_write_page0_reg(qdev, &port_regs->mac0ConfigReg, value);
-	}
 }
 
 static void ql_mac_cfg_gig(struct ql3_adapter *qdev, u32 enable)
@@ -1028,11 +1018,10 @@ static void ql_mac_cfg_gig(struct ql3_ad
 	else
 		value = (MAC_CONFIG_REG_GM << 16);
 
-	if (qdev->mac_index) {
+	if (qdev->mac_index)
 		ql_write_page0_reg(qdev, &port_regs->mac1ConfigReg, value);
-	} else {
+	else
 		ql_write_page0_reg(qdev, &port_regs->mac0ConfigReg, value);
-	}
 }
 
 static void ql_mac_cfg_full_dup(struct ql3_adapter *qdev, u32 enable)
@@ -1046,11 +1035,10 @@ static void ql_mac_cfg_full_dup(struct q
 	else
 		value = (MAC_CONFIG_REG_FD << 16);
 
-	if (qdev->mac_index) {
+	if (qdev->mac_index)
 		ql_write_page0_reg(qdev, &port_regs->mac1ConfigReg, value);
-	} else {
+	else
 		ql_write_page0_reg(qdev, &port_regs->mac0ConfigReg, value);
-	}
 }
 
 static void ql_mac_cfg_pause(struct ql3_adapter *qdev, u32 enable)
@@ -1066,11 +1054,10 @@ static void ql_mac_cfg_pause(struct ql3_
 	else
 		value = ((MAC_CONFIG_REG_TF | MAC_CONFIG_REG_RF) << 16);
 
-	if (qdev->mac_index) {
+	if (qdev->mac_index)
 		ql_write_page0_reg(qdev, &port_regs->mac1ConfigReg, value);
-	} else {
+	else
 		ql_write_page0_reg(qdev, &port_regs->mac0ConfigReg, value);
-	}
 }
 
 static int ql_is_fiber(struct ql3_adapter *qdev)
@@ -1166,18 +1153,16 @@ static u32 ql_get_link_speed(struct ql3_
 {
 	if (ql_is_fiber(qdev))
 		return SPEED_1000;
-	else {
+	else
 		return ql_phy_get_speed(qdev);
-	}
 }
 
 static int ql_is_link_full_dup(struct ql3_adapter *qdev)
 {
 	if (ql_is_fiber(qdev))
 		return 1;
-	else {
+	else
 		return ql_is_full_dup(qdev);
-	}
 }
 
 static int ql_link_down_detect(struct ql3_adapter *qdev)
@@ -1442,11 +1427,10 @@ static void ql_get_phy_owner(struct ql3_
 			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 7);
 
-	if (ql_this_adapter_controls_port(qdev, qdev->mac_index)) {
+	if (ql_this_adapter_controls_port(qdev, qdev->mac_index))
 		set_bit(QL_LINK_MASTER,&qdev->flags);
-	} else {
+	else
 		clear_bit(QL_LINK_MASTER,&qdev->flags);
-	}
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
 }
 
@@ -1461,13 +1445,11 @@ static void ql_init_scan_mode(struct ql3
 	ql_sem_unlock(qdev, QL_PHY_GIO_SEM_MASK);
 
 	if (test_bit(QL_LINK_OPTICAL,&qdev->flags)) {
-		if (ql_this_adapter_controls_port(qdev, qdev->mac_index)) {
+		if (ql_this_adapter_controls_port(qdev, qdev->mac_index))
 			ql_petbi_init_ex(qdev, qdev->mac_index);
-		}
 	} else {
-		if (ql_this_adapter_controls_port(qdev, qdev->mac_index)) {
+		if (ql_this_adapter_controls_port(qdev, qdev->mac_index))
 			ql_phy_init_ex(qdev, qdev->mac_index);
-		}
 	}
 }
 
@@ -1646,11 +1628,10 @@ static irqreturn_t ql3xxx_isr(int irq, v
 	} else if (value & ISP_IMR_DISABLE_CMPL_INT) {
 #ifdef CONFIG_QLA3XXX_NAPI
 		ql_disable_interrupts(qdev);
-		if (likely(netif_rx_schedule_prep(ndev))) {
+		if (likely(netif_rx_schedule_prep(ndev)))
 			__netif_rx_schedule(ndev);
-		} else {
+		else
 			ql_enable_interrupts(qdev);
-		}
 #else
 		handled = ql_intr_handler((unsigned long)qdev);
 #endif
@@ -1694,9 +1675,8 @@ static int ql_populate_free_queue(struct
 						  qdev->lrg_buffer_len -
 						  QL_HEADER_SPACE);
 				--qdev->lrg_buf_skb_check;
-				if (!qdev->lrg_buf_skb_check) {
+				if (!qdev->lrg_buf_skb_check)
 					return 1;
-				}
 			}
 		}
 		lrg_buf_cb = lrg_buf_cb->next;
@@ -1715,9 +1695,8 @@ static void ql_update_lrg_bufq_prod_inde
 	    && (qdev->lrg_buf_release_cnt >= 16)) {
 
 		if (qdev->lrg_buf_skb_check) {
-			if (!ql_populate_free_queue(qdev)) {
+			if (!ql_populate_free_queue(qdev))
 				return;
-			}
 		}
 
 		lrg_buf_q_ele = qdev->lrg_buf_next_free;
@@ -1726,7 +1705,6 @@ static void ql_update_lrg_bufq_prod_inde
 		       && (qdev->lrg_buf_free_count >= 8)) {
 
 			for (i = 0; i < 8; i++) {
-
 				lrg_buf_cb =
 				    ql_get_from_lrg_buf_free_list(qdev);
 				lrg_buf_q_ele->addr_high =
@@ -1799,9 +1777,8 @@ static void ql_process_mac_rx_intr(struc
 	 * Get the inbound address list (small buffer).
 	 */
 	offset = qdev->small_buf_index * QL_SMALL_BUFFER_SIZE;
-	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS) {
+	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS)
 		qdev->small_buf_index = 0;
-	}
 
 	curr_ial_ptr = (u32 *) (qdev->small_buf_virt_addr + offset);
 	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low + offset;
@@ -1811,9 +1788,8 @@ static void ql_process_mac_rx_intr(struc
 	lrg_buf_phy_addr_low = le32_to_cpu(*curr_ial_ptr);
 	lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
 	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS) {
+	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
 		qdev->lrg_buf_index = 0;
-	}
 	curr_ial_ptr++;		/* 64-bit pointers require two incs. */
 	curr_ial_ptr++;
 
@@ -1825,9 +1801,8 @@ static void ql_process_mac_rx_intr(struc
 	 * Second buffer gets sent up the stack.
 	 */
 	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS) {
+	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
 		qdev->lrg_buf_index = 0;
-	}
 	skb = lrg_buf_cb2->skb;
 
 	qdev->stats.rx_packets++;
@@ -1873,9 +1848,8 @@ static void ql_process_macip_rx_intr(str
 	 */
 
 	offset = qdev->small_buf_index * QL_SMALL_BUFFER_SIZE;
-	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS) {
+	if (++qdev->small_buf_index == NUM_SMALL_BUFFERS)
 		qdev->small_buf_index = 0;
-	}
 	curr_ial_ptr = (u32 *) (qdev->small_buf_virt_addr + offset);
 	qdev->last_rsp_offset = qdev->small_buf_phy_addr_low + offset;
 	qdev->small_buf_release_cnt++;
@@ -1885,9 +1859,8 @@ static void ql_process_macip_rx_intr(str
 	lrg_buf_cb1 = &qdev->lrg_buf[qdev->lrg_buf_index];
 
 	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS) {
+	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
 		qdev->lrg_buf_index = 0;
-	}
 	skb1 = lrg_buf_cb1->skb;
 	curr_ial_ptr++;		/* 64-bit pointers require two incs. */
 	curr_ial_ptr++;
@@ -1897,9 +1870,8 @@ static void ql_process_macip_rx_intr(str
 	lrg_buf_cb2 = &qdev->lrg_buf[qdev->lrg_buf_index];
 	skb2 = lrg_buf_cb2->skb;
 	qdev->lrg_buf_release_cnt++;
-	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS) {
+	if (++qdev->lrg_buf_index == NUM_LARGE_BUFFERS)
 		qdev->lrg_buf_index = 0;
-	}
 
 	qdev->stats.rx_packets++;
 	qdev->stats.rx_bytes += length;
@@ -1908,11 +1880,10 @@ static void ql_process_macip_rx_intr(str
 	 * Copy the ethhdr from first buffer to second. This
 	 * is necessary for IP completions.
 	 */
-	if (*((u16 *) skb1->data) != 0xFFFF) {
+	if (*((u16 *) skb1->data) != 0xFFFF)
 		size = VLAN_ETH_HLEN;
-	} else {
+	else
 		size = ETH_HLEN;
-	}
 
 	skb_put(skb2, length);	/* Just the second buffer length here. */
 	pci_unmap_single(qdev->pdev,
@@ -2010,9 +1981,8 @@ static int ql_intr_handler(unsigned long
 			qdev->small_buf_q_producer_index++;
 
 			if (qdev->small_buf_q_producer_index ==
-			    NUM_SBUFQ_ENTRIES) {
+			    NUM_SBUFQ_ENTRIES)
 				qdev->small_buf_q_producer_index = 0;
-			}
 			qdev->small_buf_release_cnt -= 8;
 		}
 
@@ -2027,7 +1997,7 @@ static int ql_intr_handler(unsigned long
 			    qdev->rsp_consumer_index);
 
 	spin_unlock(&qdev->adapter_lock);
-	return (10 - max_ios_per_intr);
+	return 10 - max_ios_per_intr;
 }
 
 #else				/* !CONFIG_QLA3XXX_NAPI */
@@ -2098,9 +2068,8 @@ static int ql_tx_rx_clean(struct ql3_ada
 			qdev->small_buf_q_producer_index++;
 
 			if (qdev->small_buf_q_producer_index ==
-			    NUM_SBUFQ_ENTRIES) {
+			    NUM_SBUFQ_ENTRIES)
 				qdev->small_buf_q_producer_index = 0;
-			}
 			qdev->small_buf_release_cnt -= 8;
 		}
 
@@ -2125,7 +2094,7 @@ static int ql_tx_rx_clean(struct ql3_ada
 		spin_unlock(&qdev->tx_lock);
 	}
 
-	return (*tx_cleaned + *rx_cleaned);
+	return *tx_cleaned + *rx_cleaned;
 }
 
 static int ql_poll(struct net_device *ndev, int *budget)
@@ -2210,6 +2179,7 @@ static int ql3xxx_send(struct sk_buff *s
 
 	return NETDEV_TX_OK;
 }
+
 static int ql_alloc_net_req_rsp_queues(struct ql3_adapter *qdev)
 {
 	qdev->req_q_size =
@@ -2797,7 +2767,7 @@ static int ql_adapter_initialize(struct 
 	ql_sem_spinlock(qdev, QL_DDR_RAM_SEM_MASK,
 			(QL_RESOURCE_BITS_BASE_CODE | (qdev->mac_index) *
 			 2) << 4);
-	clear_bit(QL_LINK_MASTER,&qdev->flags);
+	clear_bit(QL_LINK_MASTER, &qdev->flags);
 	value = ql_read_page0_reg(qdev, &port_regs->portStatus);
 	if ((value & PORT_STATUS_IC) == 0) {
 		/* Chip has not been configured yet, so let it rip. */
@@ -2971,15 +2941,13 @@ static int ql_adapter_reset(struct ql3_a
 			    ql_read_common_reg(qdev,
 					       &port_regs->CommonRegs.
 					       ispControlStatus);
-			if ((value & ISP_CONTROL_FSR) == 0) {
+			if ((value & ISP_CONTROL_FSR) == 0)
 				break;
-			}
 			msleep(1000);
 		} while ((--max_wait_time));
 	}
-	if (max_wait_time == 0) {
+	if (max_wait_time == 0)
 		status = 1;
-	}
 
 	clear_bit(QL_RESET_ACTIVE,&qdev->flags);
 	set_bit(QL_RESET_DONE,&qdev->flags);
@@ -3211,9 +3179,8 @@ static int ql3xxx_close(struct net_devic
 	 * Wait for device to recover from a reset.
 	 * (Rarely happens, but possible.)
 	 */
-	while (!test_bit(QL_ADAPTER_UP,&qdev->flags)) {
+	while (!test_bit(QL_ADAPTER_UP,&qdev->flags))
 		msleep(50);
-	}
 
 	ql_adapter_down(qdev,QL_DO_RESET);
 	return 0;
@@ -3644,10 +3611,9 @@ static void __devexit ql3xxx_remove(stru
 	/*
 	 * Wait for any resets to complete...
 	 */
-	while (test_bit((QL_RESET_ACTIVE | QL_RESET_START |	QL_RESET_PER_SCSI),
-					&qdev->flags)) {
+	while (test_bit((QL_RESET_ACTIVE | QL_RESET_START | QL_RESET_PER_SCSI),
+					&qdev->flags))
 		msleep(1000);
-	}
 
 	index = qdev->index;
 	if (qdev->workqueue) {
_

