From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 17/21] e1000: add ich8lan core functions
Date: Wed, 21 Jun 2006 22:20:44 -0700
Message-ID: <20060622052043.25497.85145.stgit@gitlost.site>
References: <20060622051815.25497.89192.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:61448 "EHLO gitlost.site")
	by vger.kernel.org with ESMTP id S932798AbWFVFOq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jun 2006 01:14:46 -0400
To: "Garzik, Jeff" <jgarzik@pobox.com>
In-Reply-To: <20060622051815.25497.89192.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This implements the core new functions needed for ich8's internal
NIC. This includes:

* ich8 specific read/write code
* flash/nvm access code
* software semaphore flag functions
* 10/100 PHY (fe - no gigabit speed) support for low-end versions
* A workaround for a powerdown sequence problem discovered that
affects a small number of motherboard.

Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
---

 drivers/net/e1000/e1000_hw.c    | 1000 +++++++++++++++++++++++++++++++++++++++
 drivers/net/e1000/e1000_hw.h    |  386 +++++++++++++++
 drivers/net/e1000/e1000_osdep.h |   13 +
 3 files changed, 1392 insertions(+), 7 deletions(-)

diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
index 784f950..a3f5ccd 100644
--- a/drivers/net/e1000/e1000_hw.c
+++ b/drivers/net/e1000/e1000_hw.c
@@ -3617,11 +3617,120 @@ e1000_phy_reset(struct e1000_hw *hw)
 }
 
 /******************************************************************************
+* Work-around for 82566 power-down: on D3 entry-
+* 1) disable gigabit link
+* 2) write VR power-down enable
+* 3) read it back
+* if successful continue, else issue LCD reset and repeat
+*
+* hw - struct containing variables accessed by shared code
+******************************************************************************/
+void
+e1000_phy_powerdown_workaround(struct e1000_hw *hw)
+{
+    int32_t reg;
+    uint16_t phy_data;
+    int32_t retry = 0;
+
+    DEBUGFUNC("e1000_phy_powerdown_workaround");
+
+    if (hw->phy_type != e1000_phy_igp_3)
+        return;
+
+    do {
+        /* Disable link */
+        reg = E1000_READ_REG(hw, PHY_CTRL);
+        E1000_WRITE_REG(hw, PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
+                        E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
+
+        /* Write VR power-down enable */
+        e1000_read_phy_reg(hw, IGP3_VR_CTRL, &phy_data);
+        e1000_write_phy_reg(hw, IGP3_VR_CTRL, phy_data |
+                            IGP3_VR_CTRL_MODE_SHUT);
+
+        /* Read it back and test */
+        e1000_read_phy_reg(hw, IGP3_VR_CTRL, &phy_data);
+        if ((phy_data & IGP3_VR_CTRL_MODE_SHUT) || retry)
+            break;
+
+        /* Issue PHY reset and repeat at most one more time */
+        reg = E1000_READ_REG(hw, CTRL);
+        E1000_WRITE_REG(hw, CTRL, reg | E1000_CTRL_PHY_RST);
+        retry++;
+    } while (retry);
+
+    return;
+
+}
+
+/******************************************************************************
+* Work-around for 82566 Kumeran PCS lock loss:
+* On link status change (i.e. PCI reset, speed change) and link is up and
+* speed is gigabit-
+* 0) if workaround is optionally disabled do nothing
+* 1) wait 1ms for Kumeran link to come up
+* 2) check Kumeran Diagnostic register PCS lock loss bit
+* 3) if not set the link is locked (all is good), otherwise...
+* 4) reset the PHY
+* 5) repeat up to 10 times
+* Note: this is only called for IGP3 copper when speed is 1gb.
+*
+* hw - struct containing variables accessed by shared code
+******************************************************************************/
+int32_t
+e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw)
+{
+    int32_t ret_val;
+    int32_t reg;
+    int32_t cnt;
+    uint16_t phy_data;
+
+    if (hw->kmrn_lock_loss_workaround_disabled)
+        return E1000_SUCCESS;
+
+    /* Make sure link is up before proceeding. If not just return.
+     * Attempting this while link is negotiating fouls up link
+     * stability */
+    ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &phy_data);
+    ret_val = e1000_read_phy_reg(hw, PHY_STATUS, &phy_data);
+
+    if (phy_data & MII_SR_LINK_STATUS) {
+        for (cnt = 0; cnt < 10; cnt++) {
+            /* read once to clear */
+            ret_val = e1000_read_phy_reg(hw, IGP3_KMRN_DIAG, &phy_data);
+            if (ret_val)
+                return ret_val;
+            /* and again to get new status */
+            ret_val = e1000_read_phy_reg(hw, IGP3_KMRN_DIAG, &phy_data);
+            if (ret_val)
+                return ret_val;
+
+            /* check for PCS lock */
+            if (!(phy_data & IGP3_KMRN_DIAG_PCS_LOCK_LOSS))
+                return E1000_SUCCESS;
+
+            /* Issue PHY reset */
+            e1000_phy_hw_reset(hw);
+            msec_delay_irq(5);
+        }
+        /* Disable GigE link negotiation */
+        reg = E1000_READ_REG(hw, PHY_CTRL);
+        E1000_WRITE_REG(hw, PHY_CTRL, reg | E1000_PHY_CTRL_GBE_DISABLE |
+                        E1000_PHY_CTRL_NOND0A_GBE_DISABLE);
+
+        /* unable to acquire PCS lock */
+        return E1000_ERR_PHY;
+    }
+
+    return E1000_SUCCESS;
+}
+
+/******************************************************************************
 * Probes the expected PHY address for known PHY IDs
 *
 * hw - Struct containing variables accessed by shared code
 ******************************************************************************/
-static int32_t
+int32_t
 e1000_detect_gig_phy(struct e1000_hw *hw)
 {
     int32_t phy_init_status, ret_val;
@@ -3804,6 +3913,53 @@ e1000_phy_igp_get_info(struct e1000_hw *
 }
 
 /******************************************************************************
+* Get PHY information from various PHY registers for ife PHY only.
+*
+* hw - Struct containing variables accessed by shared code
+* phy_info - PHY information structure
+******************************************************************************/
+int32_t
+e1000_phy_ife_get_info(struct e1000_hw *hw,
+                       struct e1000_phy_info *phy_info)
+{
+    int32_t ret_val;
+    uint16_t phy_data, polarity;
+
+    DEBUGFUNC("e1000_phy_ife_get_info");
+
+    phy_info->downshift = (e1000_downshift)hw->speed_downgraded;
+    phy_info->extended_10bt_distance = e1000_10bt_ext_dist_enable_normal;
+
+    ret_val = e1000_read_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, &phy_data);
+    if (ret_val)
+        return ret_val;
+    phy_info->polarity_correction =
+                        (phy_data & IFE_PSC_AUTO_POLARITY_DISABLE) >>
+                        IFE_PSC_AUTO_POLARITY_DISABLE_SHIFT;
+
+    if (phy_info->polarity_correction == e1000_polarity_reversal_enabled) {
+        ret_val = e1000_check_polarity(hw, &polarity);
+        if (ret_val)
+            return ret_val;
+    } else {
+        /* Polarity is forced. */
+        polarity = (phy_data & IFE_PSC_FORCE_POLARITY) >>
+                       IFE_PSC_FORCE_POLARITY_SHIFT;
+    }
+    phy_info->cable_polarity = polarity;
+
+    ret_val = e1000_read_phy_reg(hw, IFE_PHY_MDIX_CONTROL, &phy_data);
+    if (ret_val)
+        return ret_val;
+
+    phy_info->mdix_mode =
+                     (phy_data & (IFE_PMC_AUTO_MDIX | IFE_PMC_FORCE_MDIX)) >>
+                     IFE_PMC_MDIX_MODE_SHIFT;
+
+    return E1000_SUCCESS;
+}
+
+/******************************************************************************
 * Get PHY information from various PHY registers fot m88 PHY only.
 *
 * hw - Struct containing variables accessed by shared code
@@ -7630,4 +7786,846 @@ e1000_arc_subsystem_valid(struct e1000_h
 }
 
 
+/******************************************************************************
+ * Configure PCI-Ex no-snoop
+ *
+ * hw - Struct containing variables accessed by shared code.
+ * no_snoop - Bitmap of no-snoop events.
+ *
+ * returns: E1000_SUCCESS
+ *
+ *****************************************************************************/
+int32_t
+e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop)
+{
+    uint32_t gcr_reg = 0;
+
+    DEBUGFUNC("e1000_set_pci_ex_no_snoop");
+
+    if (hw->bus_type == e1000_bus_type_unknown)
+        e1000_get_bus_info(hw);
+
+    if (hw->bus_type != e1000_bus_type_pci_express)
+        return E1000_SUCCESS;
+
+    if (no_snoop) {
+        gcr_reg = E1000_READ_REG(hw, GCR);
+        gcr_reg &= ~(PCI_EX_NO_SNOOP_ALL);
+        gcr_reg |= no_snoop;
+        E1000_WRITE_REG(hw, GCR, gcr_reg);
+    }
+    if (hw->mac_type == e1000_ich8lan) {
+        uint32_t ctrl_ext;
+
+        E1000_WRITE_REG(hw, GCR, PCI_EX_82566_SNOOP_ALL);
+
+        ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
+        ctrl_ext |= E1000_CTRL_EXT_RO_DIS;
+        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
+    }
+
+    return E1000_SUCCESS;
+}
+
+/***************************************************************************
+ *
+ * Get software semaphore FLAG bit (SWFLAG).
+ * SWFLAG is used to synchronize the access to all shared resource between
+ * SW, FW and HW.
+ *
+ * hw: Struct containing variables accessed by shared code
+ *
+ ***************************************************************************/
+int32_t
+e1000_get_software_flag(struct e1000_hw *hw)
+{
+    int32_t timeout = PHY_CFG_TIMEOUT;
+    uint32_t extcnf_ctrl;
+
+    DEBUGFUNC("e1000_get_software_flag");
+
+    if (hw->mac_type == e1000_ich8lan) {
+        while (timeout) {
+            extcnf_ctrl = E1000_READ_REG(hw, EXTCNF_CTRL);
+            extcnf_ctrl |= E1000_EXTCNF_CTRL_SWFLAG;
+            E1000_WRITE_REG(hw, EXTCNF_CTRL, extcnf_ctrl);
+
+            extcnf_ctrl = E1000_READ_REG(hw, EXTCNF_CTRL);
+            if (extcnf_ctrl & E1000_EXTCNF_CTRL_SWFLAG)
+                break;
+            msec_delay_irq(1);
+            timeout--;
+        }
+
+        if (!timeout) {
+            DEBUGOUT("FW or HW locks the resource too long.\n");
+            return -E1000_ERR_CONFIG;
+        }
+    }
+
+    return E1000_SUCCESS;
+}
+
+/***************************************************************************
+ *
+ * Release software semaphore FLAG bit (SWFLAG).
+ * SWFLAG is used to synchronize the access to all shared resource between
+ * SW, FW and HW.
+ *
+ * hw: Struct containing variables accessed by shared code
+ *
+ ***************************************************************************/
+void
+e1000_release_software_flag(struct e1000_hw *hw)
+{
+    uint32_t extcnf_ctrl;
+
+    DEBUGFUNC("e1000_release_software_flag");
+
+    if (hw->mac_type == e1000_ich8lan) {
+        extcnf_ctrl= E1000_READ_REG(hw, EXTCNF_CTRL);
+        extcnf_ctrl &= ~E1000_EXTCNF_CTRL_SWFLAG;
+        E1000_WRITE_REG(hw, EXTCNF_CTRL, extcnf_ctrl);
+    }
+
+    return;
+}
+
+/***************************************************************************
+ *
+ * Disable dynamic power down mode in ife PHY.
+ * It can be used to workaround band-gap problem.
+ *
+ * hw: Struct containing variables accessed by shared code
+ *
+ ***************************************************************************/
+int32_t
+e1000_ife_disable_dynamic_power_down(struct e1000_hw *hw)
+{
+    uint16_t phy_data;
+    int32_t ret_val = E1000_SUCCESS;
+
+    DEBUGFUNC("e1000_ife_disable_dynamic_power_down");
+
+    if (hw->phy_type == e1000_phy_ife) {
+        ret_val = e1000_read_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, &phy_data);
+        if (ret_val)
+            return ret_val;
+
+        phy_data |=  IFE_PSC_DISABLE_DYNAMIC_POWER_DOWN;
+        ret_val = e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, phy_data);
+    }
+
+    return ret_val;
+}
+
+/***************************************************************************
+ *
+ * Enable dynamic power down mode in ife PHY.
+ * It can be used to workaround band-gap problem.
+ *
+ * hw: Struct containing variables accessed by shared code
+ *
+ ***************************************************************************/
+int32_t
+e1000_ife_enable_dynamic_power_down(struct e1000_hw *hw)
+{
+    uint16_t phy_data;
+    int32_t ret_val = E1000_SUCCESS;
+
+    DEBUGFUNC("e1000_ife_enable_dynamic_power_down");
+
+    if (hw->phy_type == e1000_phy_ife) {
+        ret_val = e1000_read_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, &phy_data);
+        if (ret_val)
+            return ret_val;
+
+        phy_data &=  ~IFE_PSC_DISABLE_DYNAMIC_POWER_DOWN;
+        ret_val = e1000_write_phy_reg(hw, IFE_PHY_SPECIAL_CONTROL, phy_data);
+    }
+
+    return ret_val;
+}
+
+/******************************************************************************
+ * Reads a 16 bit word or words from the EEPROM using the ICH8's flash access
+ * register.
+ *
+ * hw - Struct containing variables accessed by shared code
+ * offset - offset of word in the EEPROM to read
+ * data - word read from the EEPROM
+ * words - number of words to read
+ *****************************************************************************/
+int32_t
+e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
+                       uint16_t *data)
+{
+    int32_t  error = E1000_SUCCESS;
+    uint32_t flash_bank = 0;
+    uint32_t act_offset = 0;
+    uint32_t bank_offset = 0;
+    uint16_t word = 0;
+    uint16_t i = 0;
+
+    /* We need to know which is the valid flash bank.  In the event
+     * that we didn't allocate eeprom_shadow_ram, we may not be
+     * managing flash_bank.  So it cannot be trusted and needs
+     * to be updated with each read.
+     */
+    /* Value of bit 22 corresponds to the flash bank we're on. */
+    flash_bank = (E1000_READ_REG(hw, EECD) & E1000_EECD_SEC1VAL) ? 1 : 0;
+
+    /* Adjust offset appropriately if we're on bank 1 - adjust for word size */
+    bank_offset = flash_bank * (hw->flash_bank_size * 2);
+
+    error = e1000_get_software_flag(hw);
+    if (error != E1000_SUCCESS)
+        return error;
+
+    for (i = 0; i < words; i++) {
+        if (hw->eeprom_shadow_ram != NULL &&
+            hw->eeprom_shadow_ram[offset+i].modified == TRUE) {
+            data[i] = hw->eeprom_shadow_ram[offset+i].eeprom_word;
+        } else {
+            /* The NVM part needs a byte offset, hence * 2 */
+            act_offset = bank_offset + ((offset + i) * 2);
+            error = e1000_read_ich8_word(hw, act_offset, &word);
+            if (error != E1000_SUCCESS)
+                break;
+            data[i] = word;
+        }
+    }
+
+    e1000_release_software_flag(hw);
+
+    return error;
+}
+
+/******************************************************************************
+ * Writes a 16 bit word or words to the EEPROM using the ICH8's flash access
+ * register.  Actually, writes are written to the shadow ram cache in the hw
+ * structure hw->e1000_shadow_ram.  e1000_commit_shadow_ram flushes this to
+ * the NVM, which occurs when the NVM checksum is updated.
+ *
+ * hw - Struct containing variables accessed by shared code
+ * offset - offset of word in the EEPROM to write
+ * words - number of words to write
+ * data - words to write to the EEPROM
+ *****************************************************************************/
+int32_t
+e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset, uint16_t words,
+                        uint16_t *data)
+{
+    uint32_t i = 0;
+    int32_t error = E1000_SUCCESS;
+
+    error = e1000_get_software_flag(hw);
+    if (error != E1000_SUCCESS)
+        return error;
+
+    /* A driver can write to the NVM only if it has eeprom_shadow_ram
+     * allocated.  Subsequent reads to the modified words are read from
+     * this cached structure as well.  Writes will only go into this
+     * cached structure unless it's followed by a call to
+     * e1000_update_eeprom_checksum() where it will commit the changes
+     * and clear the "modified" field.
+     */
+    if (hw->eeprom_shadow_ram != NULL) {
+        for (i = 0; i < words; i++) {
+            if ((offset + i) < E1000_SHADOW_RAM_WORDS) {
+                hw->eeprom_shadow_ram[offset+i].modified = TRUE;
+                hw->eeprom_shadow_ram[offset+i].eeprom_word = data[i];
+            } else {
+                error = -E1000_ERR_EEPROM;
+                break;
+            }
+        }
+    } else {
+        /* Drivers have the option to not allocate eeprom_shadow_ram as long
+         * as they don't perform any NVM writes.  An attempt in doing so
+         * will result in this error.
+         */
+        error = -E1000_ERR_EEPROM;
+    }
+
+    e1000_release_software_flag(hw);
+
+    return error;
+}
+
+/******************************************************************************
+ * This function does initial flash setup so that a new read/write/erase cycle
+ * can be started.
+ *
+ * hw - The pointer to the hw structure
+ ****************************************************************************/
+int32_t
+e1000_ich8_cycle_init(struct e1000_hw *hw)
+{
+    union ich8_hws_flash_status hsfsts;
+    int32_t error = E1000_ERR_EEPROM;
+    int32_t i     = 0;
+
+    DEBUGFUNC("e1000_ich8_cycle_init");
+
+    hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+
+    /* May be check the Flash Des Valid bit in Hw status */
+    if (hsfsts.hsf_status.fldesvalid == 0) {
+        DEBUGOUT("Flash descriptor invalid.  SW Sequencing must be used.");
+        return error;
+    }
+
+    /* Clear FCERR in Hw status by writing 1 */
+    /* Clear DAEL in Hw status by writing a 1 */
+    hsfsts.hsf_status.flcerr = 1;
+    hsfsts.hsf_status.dael = 1;
+
+    E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFSTS, hsfsts.regval);
+
+    /* Either we should have a hardware SPI cycle in progress bit to check
+     * against, in order to start a new cycle or FDONE bit should be changed
+     * in the hardware so that it is 1 after harware reset, which can then be
+     * used as an indication whether a cycle is in progress or has been
+     * completed .. we should also have some software semaphore mechanism to
+     * guard FDONE or the cycle in progress bit so that two threads access to
+     * those bits can be sequentiallized or a way so that 2 threads dont
+     * start the cycle at the same time */
+
+    if (hsfsts.hsf_status.flcinprog == 0) {
+        /* There is no cycle running at present, so we can start a cycle */
+        /* Begin by setting Flash Cycle Done. */
+        hsfsts.hsf_status.flcdone = 1;
+        E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFSTS, hsfsts.regval);
+        error = E1000_SUCCESS;
+    } else {
+        /* otherwise poll for sometime so the current cycle has a chance
+         * to end before giving up. */
+        for (i = 0; i < ICH8_FLASH_COMMAND_TIMEOUT; i++) {
+            hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+            if (hsfsts.hsf_status.flcinprog == 0) {
+                error = E1000_SUCCESS;
+                break;
+            }
+            udelay(1);
+        }
+        if (error == E1000_SUCCESS) {
+            /* Successful in waiting for previous cycle to timeout,
+             * now set the Flash Cycle Done. */
+            hsfsts.hsf_status.flcdone = 1;
+            E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFSTS, hsfsts.regval);
+        } else {
+            DEBUGOUT("Flash controller busy, cannot get access");
+        }
+    }
+    return error;
+}
+
+/******************************************************************************
+ * This function starts a flash cycle and waits for its completion
+ *
+ * hw - The pointer to the hw structure
+ ****************************************************************************/
+int32_t
+e1000_ich8_flash_cycle(struct e1000_hw *hw, uint32_t timeout)
+{
+    union ich8_hws_flash_ctrl hsflctl;
+    union ich8_hws_flash_status hsfsts;
+    int32_t error = E1000_ERR_EEPROM;
+    uint32_t i = 0;
+
+    /* Start a cycle by writing 1 in Flash Cycle Go in Hw Flash Control */
+    hsflctl.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFCTL);
+    hsflctl.hsf_ctrl.flcgo = 1;
+    E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFCTL, hsflctl.regval);
+
+    /* wait till FDONE bit is set to 1 */
+    do {
+        hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+        if (hsfsts.hsf_status.flcdone == 1)
+            break;
+        udelay(1);
+        i++;
+    } while (i < timeout);
+    if (hsfsts.hsf_status.flcdone == 1 && hsfsts.hsf_status.flcerr == 0) {
+        error = E1000_SUCCESS;
+    }
+    return error;
+}
+
+/******************************************************************************
+ * Reads a byte or word from the NVM using the ICH8 flash access registers.
+ *
+ * hw - The pointer to the hw structure
+ * index - The index of the byte or word to read.
+ * size - Size of data to read, 1=byte 2=word
+ * data - Pointer to the word to store the value read.
+ *****************************************************************************/
+int32_t
+e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
+                     uint32_t size, uint16_t* data)
+{
+    union ich8_hws_flash_status hsfsts;
+    union ich8_hws_flash_ctrl hsflctl;
+    uint32_t flash_linear_address;
+    uint32_t flash_data = 0;
+    int32_t error = -E1000_ERR_EEPROM;
+    int32_t count = 0;
+
+    DEBUGFUNC("e1000_read_ich8_data");
+
+    if (size < 1  || size > 2 || data == 0x0 ||
+        index > ICH8_FLASH_LINEAR_ADDR_MASK)
+        return error;
+
+    flash_linear_address = (ICH8_FLASH_LINEAR_ADDR_MASK & index) +
+                           hw->flash_base_addr;
+
+    do {
+        udelay(1);
+        /* Steps */
+        error = e1000_ich8_cycle_init(hw);
+        if (error != E1000_SUCCESS)
+            break;
+
+        hsflctl.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFCTL);
+        /* 0b/1b corresponds to 1 or 2 byte size, respectively. */
+        hsflctl.hsf_ctrl.fldbcount = size - 1;
+        hsflctl.hsf_ctrl.flcycle = ICH8_CYCLE_READ;
+        E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFCTL, hsflctl.regval);
+
+        /* Write the last 24 bits of index into Flash Linear address field in
+         * Flash Address */
+        /* TODO: TBD maybe check the index against the size of flash */
+
+        E1000_WRITE_ICH8_REG(hw, ICH8_FLASH_FADDR, flash_linear_address);
+
+        error = e1000_ich8_flash_cycle(hw, ICH8_FLASH_COMMAND_TIMEOUT);
+
+        /* Check if FCERR is set to 1, if set to 1, clear it and try the whole
+         * sequence a few more times, else read in (shift in) the Flash Data0,
+         * the order is least significant byte first msb to lsb */
+        if (error == E1000_SUCCESS) {
+            flash_data = E1000_READ_ICH8_REG(hw, ICH8_FLASH_FDATA0);
+            if (size == 1) {
+                *data = (uint8_t)(flash_data & 0x000000FF);
+            } else if (size == 2) {
+                *data = (uint16_t)(flash_data & 0x0000FFFF);
+            }
+            break;
+        } else {
+            /* If we've gotten here, then things are probably completely hosed,
+             * but if the error condition is detected, it won't hurt to give
+             * it another try...ICH8_FLASH_CYCLE_REPEAT_COUNT times.
+             */
+            hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+            if (hsfsts.hsf_status.flcerr == 1) {
+                /* Repeat for some time before giving up. */
+                continue;
+            } else if (hsfsts.hsf_status.flcdone == 0) {
+                DEBUGOUT("Timeout error - flash cycle did not complete.");
+                break;
+            }
+        }
+    } while (count++ < ICH8_FLASH_CYCLE_REPEAT_COUNT);
+
+    return error;
+}
+
+/******************************************************************************
+ * Writes One /two bytes to the NVM using the ICH8 flash access registers.
+ *
+ * hw - The pointer to the hw structure
+ * index - The index of the byte/word to read.
+ * size - Size of data to read, 1=byte 2=word
+ * data - The byte(s) to write to the NVM.
+ *****************************************************************************/
+int32_t
+e1000_write_ich8_data(struct e1000_hw *hw, uint32_t index, uint32_t size,
+                      uint16_t data)
+{
+    union ich8_hws_flash_status hsfsts;
+    union ich8_hws_flash_ctrl hsflctl;
+    uint32_t flash_linear_address;
+    uint32_t flash_data = 0;
+    int32_t error = -E1000_ERR_EEPROM;
+    int32_t count = 0;
+
+    DEBUGFUNC("e1000_write_ich8_data");
+
+    if (size < 1  || size > 2 || data > size * 0xff ||
+        index > ICH8_FLASH_LINEAR_ADDR_MASK)
+        return error;
+
+    flash_linear_address = (ICH8_FLASH_LINEAR_ADDR_MASK & index) +
+                           hw->flash_base_addr;
+
+    do {
+        udelay(1);
+        /* Steps */
+        error = e1000_ich8_cycle_init(hw);
+        if (error != E1000_SUCCESS)
+            break;
+
+        hsflctl.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFCTL);
+        /* 0b/1b corresponds to 1 or 2 byte size, respectively. */
+        hsflctl.hsf_ctrl.fldbcount = size -1;
+        hsflctl.hsf_ctrl.flcycle = ICH8_CYCLE_WRITE;
+        E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFCTL, hsflctl.regval);
+
+        /* Write the last 24 bits of index into Flash Linear address field in
+         * Flash Address */
+        E1000_WRITE_ICH8_REG(hw, ICH8_FLASH_FADDR, flash_linear_address);
+
+        if (size == 1)
+            flash_data = (uint32_t)data & 0x00FF;
+        else
+            flash_data = (uint32_t)data;
+
+        E1000_WRITE_ICH8_REG(hw, ICH8_FLASH_FDATA0, flash_data);
+
+        /* check if FCERR is set to 1 , if set to 1, clear it and try the whole
+         * sequence a few more times else done */
+        error = e1000_ich8_flash_cycle(hw, ICH8_FLASH_COMMAND_TIMEOUT);
+        if (error == E1000_SUCCESS) {
+            break;
+        } else {
+            /* If we're here, then things are most likely completely hosed,
+             * but if the error condition is detected, it won't hurt to give
+             * it another try...ICH8_FLASH_CYCLE_REPEAT_COUNT times.
+             */
+            hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+            if (hsfsts.hsf_status.flcerr == 1) {
+                /* Repeat for some time before giving up. */
+                continue;
+            } else if (hsfsts.hsf_status.flcdone == 0) {
+                DEBUGOUT("Timeout error - flash cycle did not complete.");
+                break;
+            }
+        }
+    } while (count++ < ICH8_FLASH_CYCLE_REPEAT_COUNT);
+
+    return error;
+}
+
+/******************************************************************************
+ * Reads a single byte from the NVM using the ICH8 flash access registers.
+ *
+ * hw - pointer to e1000_hw structure
+ * index - The index of the byte to read.
+ * data - Pointer to a byte to store the value read.
+ *****************************************************************************/
+int32_t
+e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t* data)
+{
+    int32_t status = E1000_SUCCESS;
+    uint16_t word = 0;
+
+    status = e1000_read_ich8_data(hw, index, 1, &word);
+    if (status == E1000_SUCCESS) {
+        *data = (uint8_t)word;
+    }
+
+    return status;
+}
+
+/******************************************************************************
+ * Writes a single byte to the NVM using the ICH8 flash access registers.
+ * Performs verification by reading back the value and then going through
+ * a retry algorithm before giving up.
+ *
+ * hw - pointer to e1000_hw structure
+ * index - The index of the byte to write.
+ * byte - The byte to write to the NVM.
+ *****************************************************************************/
+int32_t
+e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t byte)
+{
+    int32_t error = E1000_SUCCESS;
+    int32_t program_retries;
+    uint8_t temp_byte;
+
+    e1000_write_ich8_byte(hw, index, byte);
+    udelay(100);
+
+    for (program_retries = 0; program_retries < 100; program_retries++) {
+        e1000_read_ich8_byte(hw, index, &temp_byte);
+        if (temp_byte == byte)
+            break;
+        udelay(10);
+        e1000_write_ich8_byte(hw, index, byte);
+        udelay(100);
+    }
+    if (program_retries == 100)
+        error = E1000_ERR_EEPROM;
+
+    return error;
+}
+
+/******************************************************************************
+ * Writes a single byte to the NVM using the ICH8 flash access registers.
+ *
+ * hw - pointer to e1000_hw structure
+ * index - The index of the byte to read.
+ * data - The byte to write to the NVM.
+ *****************************************************************************/
+int32_t
+e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index, uint8_t data)
+{
+    int32_t status = E1000_SUCCESS;
+    uint16_t word = (uint16_t)data;
+
+    status = e1000_write_ich8_data(hw, index, 1, word);
+
+    return status;
+}
+
+/******************************************************************************
+ * Reads a word from the NVM using the ICH8 flash access registers.
+ *
+ * hw - pointer to e1000_hw structure
+ * index - The starting byte index of the word to read.
+ * data - Pointer to a word to store the value read.
+ *****************************************************************************/
+int32_t
+e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t *data)
+{
+    int32_t status = E1000_SUCCESS;
+    status = e1000_read_ich8_data(hw, index, 2, data);
+    return status;
+}
+
+/******************************************************************************
+ * Writes a word to the NVM using the ICH8 flash access registers.
+ *
+ * hw - pointer to e1000_hw structure
+ * index - The starting byte index of the word to read.
+ * data - The word to write to the NVM.
+ *****************************************************************************/
+int32_t
+e1000_write_ich8_word(struct e1000_hw *hw, uint32_t index, uint16_t data)
+{
+    int32_t status = E1000_SUCCESS;
+    status = e1000_write_ich8_data(hw, index, 2, data);
+    return status;
+}
+
+/******************************************************************************
+ * Erases the bank specified. Each bank is a 4k block. Segments are 0 based.
+ * segment N is 4096 * N + flash_reg_addr.
+ *
+ * hw - pointer to e1000_hw structure
+ * segment - 0 for first segment, 1 for second segment, etc.
+ *****************************************************************************/
+int32_t
+e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t segment)
+{
+    union ich8_hws_flash_status hsfsts;
+    union ich8_hws_flash_ctrl hsflctl;
+    uint32_t flash_linear_address;
+    int32_t  count = 0;
+    int32_t  error = E1000_ERR_EEPROM;
+    int32_t  iteration, seg_size;
+    int32_t  sector_size;
+    int32_t  j = 0;
+    int32_t  error_flag = 0;
+
+    hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+
+    /* Determine HW Sector size: Read BERASE bits of Hw flash Status register */
+    /* 00: The Hw sector is 256 bytes, hence we need to erase 16
+     *     consecutive sectors.  The start index for the nth Hw sector can be
+     *     calculated as = segment * 4096 + n * 256
+     * 01: The Hw sector is 4K bytes, hence we need to erase 1 sector.
+     *     The start index for the nth Hw sector can be calculated
+     *     as = segment * 4096
+     * 10: Error condition
+     * 11: The Hw sector size is much bigger than the size asked to
+     *     erase...error condition */
+    if (hsfsts.hsf_status.berasesz == 0x0) {
+        /* Hw sector size 256 */
+        sector_size = seg_size = ICH8_FLASH_SEG_SIZE_256;
+        iteration = ICH8_FLASH_SECTOR_SIZE / ICH8_FLASH_SEG_SIZE_256;
+    } else if (hsfsts.hsf_status.berasesz == 0x1) {
+        sector_size = seg_size = ICH8_FLASH_SEG_SIZE_4K;
+        iteration = 1;
+    } else if (hsfsts.hsf_status.berasesz == 0x3) {
+        sector_size = seg_size = ICH8_FLASH_SEG_SIZE_64K;
+        iteration = 1;
+    } else {
+        return error;
+    }
+
+    for (j = 0; j < iteration ; j++) {
+        do {
+            count++;
+            /* Steps */
+            error = e1000_ich8_cycle_init(hw);
+            if (error != E1000_SUCCESS) {
+                error_flag = 1;
+                break;
+            }
+
+            /* Write a value 11 (block Erase) in Flash Cycle field in Hw flash
+             * Control */
+            hsflctl.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFCTL);
+            hsflctl.hsf_ctrl.flcycle = ICH8_CYCLE_ERASE;
+            E1000_WRITE_ICH8_REG16(hw, ICH8_FLASH_HSFCTL, hsflctl.regval);
+
+            /* Write the last 24 bits of an index within the block into Flash
+             * Linear address field in Flash Address.  This probably needs to
+             * be calculated here based off the on-chip segment size and the
+             * software segment size assumed (4K) */
+            /* TBD */
+            flash_linear_address = segment * sector_size + j * seg_size;
+            flash_linear_address &= ICH8_FLASH_LINEAR_ADDR_MASK;
+            flash_linear_address += hw->flash_base_addr;
+
+            E1000_WRITE_ICH8_REG(hw, ICH8_FLASH_FADDR, flash_linear_address);
+
+            error = e1000_ich8_flash_cycle(hw, 1000000);
+            /* Check if FCERR is set to 1.  If 1, clear it and try the whole
+             * sequence a few more times else Done */
+            if (error == E1000_SUCCESS) {
+                break;
+            } else {
+                hsfsts.regval = E1000_READ_ICH8_REG16(hw, ICH8_FLASH_HSFSTS);
+                if (hsfsts.hsf_status.flcerr == 1) {
+                    /* repeat for some time before giving up */
+                    continue;
+                } else if (hsfsts.hsf_status.flcdone == 0) {
+                    error_flag = 1;
+                    break;
+                }
+            }
+        } while ((count < ICH8_FLASH_CYCLE_REPEAT_COUNT) && !error_flag);
+        if (error_flag == 1)
+            break;
+    }
+    if (error_flag != 1)
+        error = E1000_SUCCESS;
+    return error;
+}
+
+/******************************************************************************
+ *
+ * Reverse duplex setting without breaking the link.
+ *
+ * hw: Struct containing variables accessed by shared code
+ *
+ *****************************************************************************/
+int32_t
+e1000_duplex_reversal(struct e1000_hw *hw)
+{
+    int32_t ret_val;
+    uint16_t phy_data;
+
+    if (hw->phy_type != e1000_phy_igp_3)
+        return E1000_SUCCESS;
+
+    ret_val = e1000_read_phy_reg(hw, PHY_CTRL, &phy_data);
+    if (ret_val)
+        return ret_val;
+
+    phy_data ^= MII_CR_FULL_DUPLEX;
+
+    ret_val = e1000_write_phy_reg(hw, PHY_CTRL, phy_data);
+    if (ret_val)
+        return ret_val;
+
+    ret_val = e1000_read_phy_reg(hw, IGP3E1000_PHY_MISC_CTRL, &phy_data);
+    if (ret_val)
+        return ret_val;
+
+    phy_data |= IGP3_PHY_MISC_DUPLEX_MANUAL_SET;
+    ret_val = e1000_write_phy_reg(hw, IGP3E1000_PHY_MISC_CTRL, phy_data);
+
+    return ret_val;
+}
+
+int32_t
+e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw,
+                                      uint32_t cnf_base_addr, uint32_t cnf_size)
+{
+    uint32_t ret_val = E1000_SUCCESS;
+    uint16_t word_addr, reg_data, reg_addr;
+    uint16_t i;
+
+    /* cnf_base_addr is in DWORD */
+    word_addr = (uint16_t)(cnf_base_addr << 1);
+
+    /* cnf_size is returned in size of dwords */
+    for (i = 0; i < cnf_size; i++) {
+        ret_val = e1000_read_eeprom(hw, (word_addr + i*2), 1, &reg_data);
+        if (ret_val)
+            return ret_val;
+
+        ret_val = e1000_read_eeprom(hw, (word_addr + i*2 + 1), 1, &reg_addr);
+        if (ret_val)
+            return ret_val;
+
+        ret_val = e1000_get_software_flag(hw);
+        if (ret_val != E1000_SUCCESS)
+            return ret_val;
+
+        ret_val = e1000_write_phy_reg_ex(hw, (uint32_t)reg_addr, reg_data);
+
+        e1000_release_software_flag(hw);
+    }
+
+    return ret_val;
+}
+
+
+int32_t
+e1000_init_lcd_from_nvm(struct e1000_hw *hw)
+{
+    uint32_t reg_data, cnf_base_addr, cnf_size, ret_val, loop;
+
+    if (hw->phy_type != e1000_phy_igp_3)
+          return E1000_SUCCESS;
+
+    /* Check if SW needs configure the PHY */
+    reg_data = E1000_READ_REG(hw, FEXTNVM);
+    if (!(reg_data & FEXTNVM_SW_CONFIG))
+        return E1000_SUCCESS;
+
+    /* Wait for basic configuration completes before proceeding*/
+    loop = 0;
+    do {
+        reg_data = E1000_READ_REG(hw, STATUS) & E1000_STATUS_LAN_INIT_DONE;
+        udelay(100);
+        loop++;
+    } while ((!reg_data) && (loop < 50));
+
+    /* Clear the Init Done bit for the next init event */
+    reg_data = E1000_READ_REG(hw, STATUS);
+    reg_data &= ~E1000_STATUS_LAN_INIT_DONE;
+    E1000_WRITE_REG(hw, STATUS, reg_data);
+
+    /* Make sure HW does not configure LCD from PHY extended configuration
+       before SW configuration */
+    reg_data = E1000_READ_REG(hw, EXTCNF_CTRL);
+    if ((reg_data & E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE) == 0x0000) {
+        reg_data = E1000_READ_REG(hw, EXTCNF_SIZE);
+        cnf_size = reg_data & E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH;
+        cnf_size >>= 16;
+        if (cnf_size) {
+            reg_data = E1000_READ_REG(hw, EXTCNF_CTRL);
+            cnf_base_addr = reg_data & E1000_EXTCNF_CTRL_EXT_CNF_POINTER;
+            /* cnf_base_addr is in DWORD */
+            cnf_base_addr >>= 16;
+
+            /* Configure LCD from extended configuration region. */
+            ret_val = e1000_init_lcd_from_nvm_config_region(hw, cnf_base_addr,
+                                                            cnf_size);
+            if (ret_val)
+                return ret_val;
+        }
+    }
+
+    return E1000_SUCCESS;
+}
+
+
 
diff --git a/drivers/net/e1000/e1000_hw.h b/drivers/net/e1000/e1000_hw.h
index bfbc7d8..8961e07 100644
--- a/drivers/net/e1000/e1000_hw.h
+++ b/drivers/net/e1000/e1000_hw.h
@@ -62,6 +62,7 @@ typedef enum {
     e1000_82572,
     e1000_82573,
     e1000_80003es2lan,
+    e1000_ich8lan,
     e1000_num_macs
 } e1000_mac_type;
 
@@ -70,6 +71,7 @@ typedef enum {
     e1000_eeprom_spi,
     e1000_eeprom_microwire,
     e1000_eeprom_flash,
+    e1000_eeprom_ich8,
     e1000_eeprom_none, /* No NVM support */
     e1000_num_eeprom_types
 } e1000_eeprom_type;
@@ -98,6 +100,11 @@ typedef enum {
     e1000_fc_default = 0xFF
 } e1000_fc_type;
 
+struct e1000_shadow_ram {
+    uint16_t    eeprom_word;
+    boolean_t   modified;
+};
+
 /* PCI bus types */
 typedef enum {
     e1000_bus_type_unknown = 0,
@@ -218,6 +225,8 @@ typedef enum {
     e1000_phy_igp,
     e1000_phy_igp_2,
     e1000_phy_gg82563,
+    e1000_phy_igp_3,
+    e1000_phy_ife,
     e1000_phy_undefined = 0xFF
 } e1000_phy_type;
 
@@ -313,6 +322,10 @@ int32_t e1000_read_phy_reg(struct e1000_
 int32_t e1000_write_phy_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t data);
 int32_t e1000_phy_hw_reset(struct e1000_hw *hw);
 int32_t e1000_phy_reset(struct e1000_hw *hw);
+void e1000_phy_powerdown_workaround(struct e1000_hw *hw);
+int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
+int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32_t cnf_base_addr, uint32_t cnf_size);
+int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
 int32_t e1000_phy_get_info(struct e1000_hw *hw, struct e1000_phy_info *phy_info);
 int32_t e1000_validate_mdi_setting(struct e1000_hw *hw);
 int32_t e1000_read_kmrn_reg(struct e1000_hw *hw, uint32_t reg_addr, uint16_t *data);
@@ -331,6 +344,7 @@ uint32_t e1000_enable_mng_pass_thru(stru
 #define E1000_MNG_DHCP_COOKIE_OFFSET	0x6F0   /* Cookie offset */
 #define E1000_MNG_DHCP_COOKIE_LENGTH	0x10    /* Cookie length */
 #define E1000_MNG_IAMT_MODE		0x3
+#define E1000_MNG_ICH_IAMT_MODE         0x2
 #define E1000_IAMT_SIGNATURE            0x544D4149 /* Intel(R) Active Management Technology signature */
 
 #define E1000_MNG_DHCP_COOKIE_STATUS_PARSING_SUPPORT 0x1 /* DHCP parsing enabled */
@@ -388,6 +402,8 @@ int32_t e1000_read_part_num(struct e1000
 int32_t e1000_read_mac_addr(struct e1000_hw * hw);
 int32_t e1000_swfw_sync_acquire(struct e1000_hw *hw, uint16_t mask);
 void e1000_swfw_sync_release(struct e1000_hw *hw, uint16_t mask);
+void e1000_release_software_flag(struct e1000_hw *hw);
+int32_t e1000_get_software_flag(struct e1000_hw *hw);
 
 /* Filters (multicast, vlan, receive) */
 void e1000_mc_addr_list_update(struct e1000_hw *hw, uint8_t * mc_addr_list, uint32_t mc_addr_count, uint32_t pad, uint32_t rar_used_count);
@@ -423,6 +439,29 @@ int32_t e1000_disable_pciex_master(struc
 int32_t e1000_get_software_semaphore(struct e1000_hw *hw);
 void e1000_release_software_semaphore(struct e1000_hw *hw);
 int32_t e1000_check_phy_reset_block(struct e1000_hw *hw);
+int32_t e1000_set_pci_ex_no_snoop(struct e1000_hw *hw, uint32_t no_snoop);
+
+int32_t e1000_read_ich8_byte(struct e1000_hw *hw, uint32_t index,
+                             uint8_t *data);
+int32_t e1000_verify_write_ich8_byte(struct e1000_hw *hw, uint32_t index,
+                                     uint8_t byte);
+int32_t e1000_write_ich8_byte(struct e1000_hw *hw, uint32_t index,
+                              uint8_t byte);
+int32_t e1000_read_ich8_word(struct e1000_hw *hw, uint32_t index,
+                             uint16_t *data);
+int32_t e1000_read_ich8_data(struct e1000_hw *hw, uint32_t index,
+                             uint32_t size, uint16_t *data);
+int32_t e1000_read_eeprom_ich8(struct e1000_hw *hw, uint16_t offset,
+                               uint16_t words, uint16_t *data);
+int32_t e1000_write_eeprom_ich8(struct e1000_hw *hw, uint16_t offset,
+                                uint16_t words, uint16_t *data);
+int32_t e1000_erase_ich8_4k_segment(struct e1000_hw *hw, uint32_t segment);
+
+
+#define E1000_READ_REG_IO(a, reg) \
+    e1000_read_reg_io((a), E1000_##reg)
+#define E1000_WRITE_REG_IO(a, reg, val) \
+    e1000_write_reg_io((a), E1000_##reg, val)
 
 /* PCI Device IDs */
 #define E1000_DEV_ID_82542               0x1000
@@ -447,6 +486,7 @@ int32_t e1000_check_phy_reset_block(stru
 #define E1000_DEV_ID_82546EB_QUAD_COPPER 0x101D
 #define E1000_DEV_ID_82541EI             0x1013
 #define E1000_DEV_ID_82541EI_MOBILE      0x1018
+#define E1000_DEV_ID_82541ER_LOM         0x1014
 #define E1000_DEV_ID_82541ER             0x1078
 #define E1000_DEV_ID_82547GI             0x1075
 #define E1000_DEV_ID_82541GI             0x1076
@@ -458,18 +498,28 @@ int32_t e1000_check_phy_reset_block(stru
 #define E1000_DEV_ID_82546GB_PCIE        0x108A
 #define E1000_DEV_ID_82546GB_QUAD_COPPER 0x1099
 #define E1000_DEV_ID_82547EI             0x1019
+#define E1000_DEV_ID_82547EI_MOBILE      0x101A
 #define E1000_DEV_ID_82571EB_COPPER      0x105E
 #define E1000_DEV_ID_82571EB_FIBER       0x105F
 #define E1000_DEV_ID_82571EB_SERDES      0x1060
 #define E1000_DEV_ID_82572EI_COPPER      0x107D
 #define E1000_DEV_ID_82572EI_FIBER       0x107E
 #define E1000_DEV_ID_82572EI_SERDES      0x107F
+#define E1000_DEV_ID_82572EI             0x10B9
 #define E1000_DEV_ID_82573E              0x108B
 #define E1000_DEV_ID_82573E_IAMT         0x108C
 #define E1000_DEV_ID_82573L              0x109A
 #define E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3 0x10B5
 #define E1000_DEV_ID_80003ES2LAN_COPPER_DPT     0x1096
 #define E1000_DEV_ID_80003ES2LAN_SERDES_DPT     0x1098
+#define E1000_DEV_ID_80003ES2LAN_COPPER_SPT     0x10BA
+#define E1000_DEV_ID_80003ES2LAN_SERDES_SPT     0x10BB
+
+#define E1000_DEV_ID_ICH8_IGP_M_AMT      0x1049
+#define E1000_DEV_ID_ICH8_IGP_AMT        0x104A
+#define E1000_DEV_ID_ICH8_IGP_C          0x104B
+#define E1000_DEV_ID_ICH8_IFE            0x104C
+#define E1000_DEV_ID_ICH8_IGP_M          0x104D
 
 
 #define NODE_ADDRESS_SIZE 6
@@ -540,6 +590,14 @@ int32_t e1000_check_phy_reset_block(stru
     E1000_IMS_RXSEQ  |    \
     E1000_IMS_LSC)
 
+/* Additional interrupts need to be handled for e1000_ich8lan:
+    DSW = The FW changed the status of the DISSW bit in FWSM
+    PHYINT = The LAN connected device generates an interrupt
+    EPRST = Manageability reset event */
+#define IMS_ICH8LAN_ENABLE_MASK (\
+    E1000_IMS_DSW   | \
+    E1000_IMS_PHYINT | \
+    E1000_IMS_EPRST)
 
 /* Number of high/low register pairs in the RAR. The RAR (Receive Address
  * Registers) holds the directed and multicast addresses that we monitor. We
@@ -547,6 +605,7 @@ int32_t e1000_check_phy_reset_block(stru
  * E1000_RAR_ENTRIES - 1 multicast addresses.
  */
 #define E1000_RAR_ENTRIES 15
+#define E1000_RAR_ENTRIES_ICH8LAN  7
 
 #define MIN_NUMBER_OF_DESCRIPTORS 8
 #define MAX_NUMBER_OF_DESCRIPTORS 0xFFF8
@@ -768,6 +827,9 @@ struct e1000_data_desc {
 #define E1000_MC_TBL_SIZE          128  /* Multicast Filter Table (4096 bits) */
 #define E1000_VLAN_FILTER_TBL_SIZE 128  /* VLAN Filter Table (4096 bits) */
 
+#define E1000_NUM_UNICAST_ICH8LAN  7
+#define E1000_MC_TBL_SIZE_ICH8LAN  32
+
 
 /* Receive Address Register */
 struct e1000_rar {
@@ -777,6 +839,7 @@ struct e1000_rar {
 
 /* Number of entries in the Multicast Table Array (MTA). */
 #define E1000_NUM_MTA_REGISTERS 128
+#define E1000_NUM_MTA_REGISTERS_ICH8LAN 32
 
 /* IPv4 Address Table Entry */
 struct e1000_ipv4_at_entry {
@@ -787,6 +850,7 @@ struct e1000_ipv4_at_entry {
 /* Four wakeup IP addresses are supported */
 #define E1000_WAKEUP_IP_ADDRESS_COUNT_MAX 4
 #define E1000_IP4AT_SIZE                  E1000_WAKEUP_IP_ADDRESS_COUNT_MAX
+#define E1000_IP4AT_SIZE_ICH8LAN          3
 #define E1000_IP6AT_SIZE                  1
 
 /* IPv6 Address Table Entry */
@@ -845,6 +909,7 @@ struct e1000_ffvt_entry {
 #define E1000_FLA      0x0001C  /* Flash Access - RW */
 #define E1000_MDIC     0x00020  /* MDI Control - RW */
 #define E1000_SCTL     0x00024  /* SerDes Control - RW */
+#define E1000_FEXTNVM  0x00028  /* Future Extended NVM register */
 #define E1000_FCAL     0x00028  /* Flow Control Address Low - RW */
 #define E1000_FCAH     0x0002C  /* Flow Control Address High -RW */
 #define E1000_FCT      0x00030  /* Flow Control Type - RW */
@@ -873,6 +938,8 @@ struct e1000_ffvt_entry {
 #define E1000_LEDCTL   0x00E00  /* LED Control - RW */
 #define E1000_EXTCNF_CTRL  0x00F00  /* Extended Configuration Control */
 #define E1000_EXTCNF_SIZE  0x00F08  /* Extended Configuration Size */
+#define E1000_PHY_CTRL     0x00F10  /* PHY Control Register in CSR */
+#define FEXTNVM_SW_CONFIG  0x0001
 #define E1000_PBA      0x01000  /* Packet Buffer Allocation - RW */
 #define E1000_PBS      0x01008  /* Packet Buffer Size */
 #define E1000_EEMNGCTL 0x01010  /* MNG EEprom Control */
@@ -900,11 +967,13 @@ struct e1000_ffvt_entry {
 #define E1000_RDH0     E1000_RDH   /* RX Desc Head (0) - RW */
 #define E1000_RDT0     E1000_RDT   /* RX Desc Tail (0) - RW */
 #define E1000_RDTR0    E1000_RDTR  /* RX Delay Timer (0) - RW */
-#define E1000_RXDCTL   0x02828  /* RX Descriptor Control - RW */
+#define E1000_RXDCTL   0x02828  /* RX Descriptor Control queue 0 - RW */
+#define E1000_RXDCTL1  0x02928  /* RX Descriptor Control queue 1 - RW */
 #define E1000_RADV     0x0282C  /* RX Interrupt Absolute Delay Timer - RW */
 #define E1000_RSRPD    0x02C00  /* RX Small Packet Detect - RW */
 #define E1000_RAID     0x02C08  /* Receive Ack Interrupt Delay - RW */
 #define E1000_TXDMAC   0x03000  /* TX DMA Control - RW */
+#define E1000_KABGTXD  0x03004  /* AFE Band Gap Transmit Ref Data */
 #define E1000_TDFH     0x03410  /* TX Data FIFO Head - RW */
 #define E1000_TDFT     0x03418  /* TX Data FIFO Tail - RW */
 #define E1000_TDFHS    0x03420  /* TX Data FIFO Head Saved - RW */
@@ -1051,6 +1120,7 @@ struct e1000_ffvt_entry {
 #define E1000_82542_FLA      E1000_FLA
 #define E1000_82542_MDIC     E1000_MDIC
 #define E1000_82542_SCTL     E1000_SCTL
+#define E1000_82542_FEXTNVM  E1000_FEXTNVM
 #define E1000_82542_FCAL     E1000_FCAL
 #define E1000_82542_FCAH     E1000_FCAH
 #define E1000_82542_FCT      E1000_FCT
@@ -1074,6 +1144,19 @@ struct e1000_ffvt_entry {
 #define E1000_82542_RDLEN0   E1000_82542_RDLEN
 #define E1000_82542_RDH0     E1000_82542_RDH
 #define E1000_82542_RDT0     E1000_82542_RDT
+#define E1000_82542_SRRCTL(_n) (0x280C + ((_n) << 8)) /* Split and Replication
+                                                       * RX Control - RW */
+#define E1000_82542_DCA_RXCTRL(_n) (0x02814 + ((_n) << 8))
+#define E1000_82542_RDBAH3   0x02B04 /* RX Desc Base High Queue 3 - RW */
+#define E1000_82542_RDBAL3   0x02B00 /* RX Desc Low Queue 3 - RW */
+#define E1000_82542_RDLEN3   0x02B08 /* RX Desc Length Queue 3 - RW */
+#define E1000_82542_RDH3     0x02B10 /* RX Desc Head Queue 3 - RW */
+#define E1000_82542_RDT3     0x02B18 /* RX Desc Tail Queue 3 - RW */
+#define E1000_82542_RDBAL2   0x02A00 /* RX Desc Base Low Queue 2 - RW */
+#define E1000_82542_RDBAH2   0x02A04 /* RX Desc Base High Queue 2 - RW */
+#define E1000_82542_RDLEN2   0x02A08 /* RX Desc Length Queue 2 - RW */
+#define E1000_82542_RDH2     0x02A10 /* RX Desc Head Queue 2 - RW */
+#define E1000_82542_RDT2     0x02A18 /* RX Desc Tail Queue 2 - RW */
 #define E1000_82542_RDTR1    0x00130
 #define E1000_82542_RDBAL1   0x00138
 #define E1000_82542_RDBAH1   0x0013C
@@ -1111,11 +1194,14 @@ struct e1000_ffvt_entry {
 #define E1000_82542_FLOP     E1000_FLOP
 #define E1000_82542_EXTCNF_CTRL  E1000_EXTCNF_CTRL
 #define E1000_82542_EXTCNF_SIZE  E1000_EXTCNF_SIZE
+#define E1000_82542_PHY_CTRL E1000_PHY_CTRL
 #define E1000_82542_ERT      E1000_ERT
 #define E1000_82542_RXDCTL   E1000_RXDCTL
+#define E1000_82542_RXDCTL1  E1000_RXDCTL1
 #define E1000_82542_RADV     E1000_RADV
 #define E1000_82542_RSRPD    E1000_RSRPD
 #define E1000_82542_TXDMAC   E1000_TXDMAC
+#define E1000_82542_KABGTXD  E1000_KABGTXD
 #define E1000_82542_TDFHS    E1000_TDFHS
 #define E1000_82542_TDFTS    E1000_TDFTS
 #define E1000_82542_TDFPC    E1000_TDFPC
@@ -1311,13 +1397,16 @@ struct e1000_hw_stats {
 
 /* Structure containing variables used by the shared code (e1000_hw.c) */
 struct e1000_hw {
-    uint8_t __iomem *hw_addr;
+    uint8_t *hw_addr;
     uint8_t *flash_address;
     e1000_mac_type mac_type;
     e1000_phy_type phy_type;
     uint32_t phy_init_script;
     e1000_media_type media_type;
     void *back;
+    struct e1000_shadow_ram *eeprom_shadow_ram;
+    uint32_t flash_bank_size;
+    uint32_t flash_base_addr;
     e1000_fc_type fc;
     e1000_bus_speed bus_speed;
     e1000_bus_width bus_width;
@@ -1329,6 +1418,7 @@ struct e1000_hw {
     uint32_t asf_firmware_present;
     uint32_t eeprom_semaphore_present;
     uint32_t swfw_sync_present;
+    uint32_t swfwhw_semaphore_present;
     unsigned long io_base;
     uint32_t phy_id;
     uint32_t phy_revision;
@@ -1388,6 +1478,7 @@ struct e1000_hw {
     boolean_t in_ifs_mode;
     boolean_t mng_reg_access_disabled;
     boolean_t leave_av_bit_off;
+    boolean_t kmrn_lock_loss_workaround_disabled;
 };
 
 
@@ -1436,6 +1527,7 @@ struct e1000_hw {
 #define E1000_CTRL_RTE      0x20000000  /* Routing tag enable */
 #define E1000_CTRL_VME      0x40000000  /* IEEE VLAN mode enable */
 #define E1000_CTRL_PHY_RST  0x80000000  /* PHY Reset */
+#define E1000_CTRL_SW2FW_INT 0x02000000  /* Initiate an interrupt to manageability engine */
 
 /* Device Status */
 #define E1000_STATUS_FD         0x00000001      /* Full duplex.0=half,1=full */
@@ -1450,6 +1542,8 @@ struct e1000_hw {
 #define E1000_STATUS_SPEED_10   0x00000000      /* Speed 10Mb/s */
 #define E1000_STATUS_SPEED_100  0x00000040      /* Speed 100Mb/s */
 #define E1000_STATUS_SPEED_1000 0x00000080      /* Speed 1000Mb/s */
+#define E1000_STATUS_LAN_INIT_DONE 0x00000200   /* Lan Init Completion
+                                                   by EEPROM/Flash */
 #define E1000_STATUS_ASDV       0x00000300      /* Auto speed detect value */
 #define E1000_STATUS_DOCK_CI    0x00000800      /* Change in Dock/Undock state. Clear on write '0'. */
 #define E1000_STATUS_GIO_MASTER_ENABLE 0x00080000 /* Status of Master requests. */
@@ -1507,6 +1601,10 @@ struct e1000_hw {
 #define E1000_STM_OPCODE     0xDB00
 #define E1000_HICR_FW_RESET  0xC0
 
+#define E1000_SHADOW_RAM_WORDS     2048
+#define E1000_ICH8_NVM_SIG_WORD    0x13
+#define E1000_ICH8_NVM_SIG_MASK    0xC0
+
 /* EEPROM Read */
 #define E1000_EERD_START      0x00000001 /* Start Read */
 #define E1000_EERD_DONE       0x00000010 /* Read Done */
@@ -1552,7 +1650,6 @@ struct e1000_hw {
 #define E1000_CTRL_EXT_WR_WMARK_320   0x01000000
 #define E1000_CTRL_EXT_WR_WMARK_384   0x02000000
 #define E1000_CTRL_EXT_WR_WMARK_448   0x03000000
-#define E1000_CTRL_EXT_CANC           0x04000000  /* Interrupt delay cancellation */
 #define E1000_CTRL_EXT_DRV_LOAD       0x10000000  /* Driver loaded bit for FW */
 #define E1000_CTRL_EXT_IAME           0x08000000  /* Interrupt acknowledge Auto-mask */
 #define E1000_CTRL_EXT_INT_TIMER_CLR  0x20000000  /* Clear Interrupt timers after IMS clear */
@@ -1592,12 +1689,31 @@ struct e1000_hw {
 #define E1000_KUMCTRLSTA_FIFO_CTRL_TX_BYPASS   0x00000800
 
 /* In-Band Control */
+#define E1000_KUMCTRLSTA_INB_CTRL_LINK_STATUS_TX_TIMEOUT_DEFAULT    0x00000500
 #define E1000_KUMCTRLSTA_INB_CTRL_DIS_PADDING  0x00000010
 
 /* Half-Duplex Control */
 #define E1000_KUMCTRLSTA_HD_CTRL_10_100_DEFAULT 0x00000004
 #define E1000_KUMCTRLSTA_HD_CTRL_1000_DEFAULT  0x00000000
 
+#define E1000_KUMCTRLSTA_OFFSET_K0S_CTRL       0x0000001E
+
+#define E1000_KUMCTRLSTA_DIAG_FELPBK           0x2000
+#define E1000_KUMCTRLSTA_DIAG_NELPBK           0x1000
+
+#define E1000_KUMCTRLSTA_K0S_100_EN            0x2000
+#define E1000_KUMCTRLSTA_K0S_GBE_EN            0x1000
+#define E1000_KUMCTRLSTA_K0S_ENTRY_LATENCY_MASK   0x0003
+
+#define E1000_KABGTXD_BGSQLBIAS                0x00050000
+
+#define E1000_PHY_CTRL_SPD_EN                  0x00000001
+#define E1000_PHY_CTRL_D0A_LPLU                0x00000002
+#define E1000_PHY_CTRL_NOND0A_LPLU             0x00000004
+#define E1000_PHY_CTRL_NOND0A_GBE_DISABLE      0x00000008
+#define E1000_PHY_CTRL_GBE_DISABLE             0x00000040
+#define E1000_PHY_CTRL_B2B_EN                  0x00000080
+
 /* LED Control */
 #define E1000_LEDCTL_LED0_MODE_MASK       0x0000000F
 #define E1000_LEDCTL_LED0_MODE_SHIFT      0
@@ -1667,6 +1783,9 @@ struct e1000_hw {
 #define E1000_ICR_RXD_FIFO_PAR1 0x01000000 /* queue 1 Rx descriptor FIFO parity error */
 #define E1000_ICR_TXD_FIFO_PAR1 0x02000000 /* queue 1 Tx descriptor FIFO parity error */
 #define E1000_ICR_ALL_PARITY    0x03F00000 /* all parity error bits */
+#define E1000_ICR_DSW           0x00000020 /* FW changed the status of DISSW bit in the FWSM */
+#define E1000_ICR_PHYINT        0x00001000 /* LAN connected device generates an interrupt */
+#define E1000_ICR_EPRST         0x00100000 /* ME handware reset occurs */
 
 /* Interrupt Cause Set */
 #define E1000_ICS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
@@ -1693,6 +1812,9 @@ struct e1000_hw {
 #define E1000_ICS_PB_PAR        E1000_ICR_PB_PAR        /* packet buffer parity error */
 #define E1000_ICS_RXD_FIFO_PAR1 E1000_ICR_RXD_FIFO_PAR1 /* queue 1 Rx descriptor FIFO parity error */
 #define E1000_ICS_TXD_FIFO_PAR1 E1000_ICR_TXD_FIFO_PAR1 /* queue 1 Tx descriptor FIFO parity error */
+#define E1000_ICS_DSW       E1000_ICR_DSW
+#define E1000_ICS_PHYINT    E1000_ICR_PHYINT
+#define E1000_ICS_EPRST     E1000_ICR_EPRST
 
 /* Interrupt Mask Set */
 #define E1000_IMS_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
@@ -1719,6 +1841,9 @@ struct e1000_hw {
 #define E1000_IMS_PB_PAR        E1000_ICR_PB_PAR        /* packet buffer parity error */
 #define E1000_IMS_RXD_FIFO_PAR1 E1000_ICR_RXD_FIFO_PAR1 /* queue 1 Rx descriptor FIFO parity error */
 #define E1000_IMS_TXD_FIFO_PAR1 E1000_ICR_TXD_FIFO_PAR1 /* queue 1 Tx descriptor FIFO parity error */
+#define E1000_IMS_DSW       E1000_ICR_DSW
+#define E1000_IMS_PHYINT    E1000_ICR_PHYINT
+#define E1000_IMS_EPRST     E1000_ICR_EPRST
 
 /* Interrupt Mask Clear */
 #define E1000_IMC_TXDW      E1000_ICR_TXDW      /* Transmit desc written back */
@@ -1745,6 +1870,9 @@ struct e1000_hw {
 #define E1000_IMC_PB_PAR        E1000_ICR_PB_PAR        /* packet buffer parity error */
 #define E1000_IMC_RXD_FIFO_PAR1 E1000_ICR_RXD_FIFO_PAR1 /* queue 1 Rx descriptor FIFO parity error */
 #define E1000_IMC_TXD_FIFO_PAR1 E1000_ICR_TXD_FIFO_PAR1 /* queue 1 Tx descriptor FIFO parity error */
+#define E1000_IMC_DSW       E1000_ICR_DSW
+#define E1000_IMC_PHYINT    E1000_ICR_PHYINT
+#define E1000_IMC_EPRST     E1000_ICR_EPRST
 
 /* Receive Control */
 #define E1000_RCTL_RST            0x00000001    /* Software reset */
@@ -1919,9 +2047,10 @@ struct e1000_hw {
 #define E1000_MRQC_RSS_FIELD_MASK           0xFFFF0000
 #define E1000_MRQC_RSS_FIELD_IPV4_TCP       0x00010000
 #define E1000_MRQC_RSS_FIELD_IPV4           0x00020000
-#define E1000_MRQC_RSS_FIELD_IPV6_TCP       0x00040000
+#define E1000_MRQC_RSS_FIELD_IPV6_TCP_EX    0x00040000
 #define E1000_MRQC_RSS_FIELD_IPV6_EX        0x00080000
 #define E1000_MRQC_RSS_FIELD_IPV6           0x00100000
+#define E1000_MRQC_RSS_FIELD_IPV6_TCP       0x00200000
 
 /* Definitions for power management and wakeup registers */
 /* Wake Up Control */
@@ -2011,6 +2140,15 @@ struct e1000_hw {
 #define E1000_FWSM_MODE_SHIFT            1
 #define E1000_FWSM_FW_VALID     0x00008000 /* FW established a valid mode */
 
+#define E1000_FWSM_RSPCIPHY        0x00000040 /* Reset PHY on PCI reset */
+#define E1000_FWSM_DISSW           0x10000000 /* FW disable SW Write Access */
+#define E1000_FWSM_SKUSEL_MASK     0x60000000 /* LAN SKU select */
+#define E1000_FWSM_SKUEL_SHIFT     29
+#define E1000_FWSM_SKUSEL_EMB      0x0 /* Embedded SKU */
+#define E1000_FWSM_SKUSEL_CONS     0x1 /* Consumer SKU */
+#define E1000_FWSM_SKUSEL_PERF_100 0x2 /* Perf & Corp 10/100 SKU */
+#define E1000_FWSM_SKUSEL_PERF_GBE 0x3 /* Perf & Copr GbE SKU */
+
 /* FFLT Debug Register */
 #define E1000_FFLT_DBG_INVC     0x00100000 /* Invalid /C/ code handling */
 
@@ -2083,6 +2221,8 @@ struct e1000_host_command_info {
                              E1000_GCR_TXDSCW_NO_SNOOP      | \
                              E1000_GCR_TXDSCR_NO_SNOOP)
 
+#define PCI_EX_82566_SNOOP_ALL PCI_EX_NO_SNOOP_ALL
+
 #define E1000_GCR_L1_ACT_WITHOUT_L0S_RX 0x08000000
 /* Function Active and Power State to MNG */
 #define E1000_FACTPS_FUNC0_POWER_STATE_MASK         0x00000003
@@ -2141,8 +2281,10 @@ struct e1000_host_command_info {
 #define EEPROM_PHY_CLASS_WORD         0x0007
 #define EEPROM_INIT_CONTROL1_REG      0x000A
 #define EEPROM_INIT_CONTROL2_REG      0x000F
+#define EEPROM_SWDEF_PINS_CTRL_PORT_1 0x0010
 #define EEPROM_INIT_CONTROL3_PORT_B   0x0014
 #define EEPROM_INIT_3GIO_3            0x001A
+#define EEPROM_SWDEF_PINS_CTRL_PORT_0 0x0020
 #define EEPROM_INIT_CONTROL3_PORT_A   0x0024
 #define EEPROM_CFG                    0x0012
 #define EEPROM_FLASH_VERSION          0x0032
@@ -2154,10 +2296,16 @@ struct e1000_host_command_info {
 /* Word definitions for ID LED Settings */
 #define ID_LED_RESERVED_0000 0x0000
 #define ID_LED_RESERVED_FFFF 0xFFFF
+#define ID_LED_RESERVED_82573  0xF746
+#define ID_LED_DEFAULT_82573   0x1811
 #define ID_LED_DEFAULT       ((ID_LED_OFF1_ON2 << 12) | \
                               (ID_LED_OFF1_OFF2 << 8) | \
                               (ID_LED_DEF1_DEF2 << 4) | \
                               (ID_LED_DEF1_DEF2))
+#define ID_LED_DEFAULT_ICH8LAN  ((ID_LED_DEF1_DEF2 << 12) | \
+                                 (ID_LED_DEF1_OFF2 <<  8) | \
+                                 (ID_LED_DEF1_ON2  <<  4) | \
+                                 (ID_LED_DEF1_DEF2))
 #define ID_LED_DEF1_DEF2     0x1
 #define ID_LED_DEF1_ON2      0x2
 #define ID_LED_DEF1_OFF2     0x3
@@ -2192,6 +2340,11 @@ struct e1000_host_command_info {
 #define EEPROM_WORD0F_ASM_DIR    0x2000
 #define EEPROM_WORD0F_ANE        0x0800
 #define EEPROM_WORD0F_SWPDIO_EXT 0x00F0
+#define EEPROM_WORD0F_LPLU       0x0001
+
+/* Mask bits for fields in Word 0x10/0x20 of the EEPROM */
+#define EEPROM_WORD1020_GIGA_DISABLE         0x0010
+#define EEPROM_WORD1020_GIGA_DISABLE_NON_D0A 0x0008
 
 /* Mask bits for fields in Word 0x1a of the EEPROM */
 #define EEPROM_WORD1A_ASPM_MASK  0x000C
@@ -2266,23 +2419,29 @@ struct e1000_host_command_info {
 #define E1000_EXTCNF_CTRL_D_UD_OWNER        0x00000010
 #define E1000_EXTCNF_CTRL_MDIO_SW_OWNERSHIP 0x00000020
 #define E1000_EXTCNF_CTRL_MDIO_HW_OWNERSHIP 0x00000040
-#define E1000_EXTCNF_CTRL_EXT_CNF_POINTER   0x1FFF0000
+#define E1000_EXTCNF_CTRL_EXT_CNF_POINTER   0x0FFF0000
 
 #define E1000_EXTCNF_SIZE_EXT_PHY_LENGTH    0x000000FF
 #define E1000_EXTCNF_SIZE_EXT_DOCK_LENGTH   0x0000FF00
 #define E1000_EXTCNF_SIZE_EXT_PCIE_LENGTH   0x00FF0000
+#define E1000_EXTCNF_CTRL_LCD_WRITE_ENABLE  0x00000001
+#define E1000_EXTCNF_CTRL_SWFLAG            0x00000020
 
 /* PBA constants */
+#define E1000_PBA_8K 0x0008    /* 8KB, default Rx allocation */
 #define E1000_PBA_12K 0x000C    /* 12KB, default Rx allocation */
 #define E1000_PBA_16K 0x0010    /* 16KB, default TX allocation */
 #define E1000_PBA_22K 0x0016
 #define E1000_PBA_24K 0x0018
 #define E1000_PBA_30K 0x001E
 #define E1000_PBA_32K 0x0020
+#define E1000_PBA_34K 0x0022
 #define E1000_PBA_38K 0x0026
 #define E1000_PBA_40K 0x0028
 #define E1000_PBA_48K 0x0030    /* 48KB, default RX allocation */
 
+#define E1000_PBS_16K E1000_PBA_16K
+
 /* Flow Control Constants */
 #define FLOW_CONTROL_ADDRESS_LOW  0x00C28001
 #define FLOW_CONTROL_ADDRESS_HIGH 0x00000100
@@ -2337,7 +2496,7 @@ struct e1000_host_command_info {
 /* Number of milliseconds we wait for Eeprom auto read bit done after MAC reset */
 #define AUTO_READ_DONE_TIMEOUT      10
 /* Number of milliseconds we wait for PHY configuration done after MAC reset */
-#define PHY_CFG_TIMEOUT             40
+#define PHY_CFG_TIMEOUT             100
 
 #define E1000_TX_BUFFER_SIZE ((uint32_t)1514)
 
@@ -3002,6 +3161,221 @@ struct e1000_host_command_info {
 #define L1LXT971A_PHY_ID   0x001378E0
 #define GG82563_E_PHY_ID   0x01410CA0
 
+
+/* Bits...
+ * 15-5: page
+ * 4-0: register offset
+ */
+#define PHY_PAGE_SHIFT        5
+#define PHY_REG(page, reg)    \
+        (((page) << PHY_PAGE_SHIFT) | ((reg) & MAX_PHY_REG_ADDRESS))
+
+#define IGP3_PHY_PORT_CTRL           \
+        PHY_REG(769, 17) /* Port General Configuration */
+#define IGP3_PHY_RATE_ADAPT_CTRL \
+        PHY_REG(769, 25) /* Rate Adapter Control Register */
+
+#define IGP3_KMRN_FIFO_CTRL_STATS \
+        PHY_REG(770, 16) /* KMRN FIFO's control/status register */
+#define IGP3_KMRN_POWER_MNG_CTRL \
+        PHY_REG(770, 17) /* KMRN Power Management Control Register */
+#define IGP3_KMRN_INBAND_CTRL \
+        PHY_REG(770, 18) /* KMRN Inband Control Register */
+#define IGP3_KMRN_DIAG \
+        PHY_REG(770, 19) /* KMRN Diagnostic register */
+#define IGP3_KMRN_DIAG_PCS_LOCK_LOSS 0x0002 /* RX PCS is not synced */
+#define IGP3_KMRN_ACK_TIMEOUT \
+        PHY_REG(770, 20) /* KMRN Acknowledge Timeouts register */
+
+#define IGP3_VR_CTRL \
+        PHY_REG(776, 18) /* Voltage regulator control register */
+#define IGP3_VR_CTRL_MODE_SHUT       0x0200 /* Enter powerdown, shutdown VRs */
+
+#define IGP3_CAPABILITY \
+        PHY_REG(776, 19) /* IGP3 Capability Register */
+
+/* Capabilities for SKU Control  */
+#define IGP3_CAP_INITIATE_TEAM       0x0001 /* Able to initiate a team */
+#define IGP3_CAP_WFM                 0x0002 /* Support WoL and PXE */
+#define IGP3_CAP_ASF                 0x0004 /* Support ASF */
+#define IGP3_CAP_LPLU                0x0008 /* Support Low Power Link Up */
+#define IGP3_CAP_DC_AUTO_SPEED       0x0010 /* Support AC/DC Auto Link Speed */
+#define IGP3_CAP_SPD                 0x0020 /* Support Smart Power Down */
+#define IGP3_CAP_MULT_QUEUE          0x0040 /* Support 2 tx & 2 rx queues */
+#define IGP3_CAP_RSS                 0x0080 /* Support RSS */
+#define IGP3_CAP_8021PQ              0x0100 /* Support 802.1Q & 802.1p */
+#define IGP3_CAP_AMT_CB              0x0200 /* Support active manageability and circuit breaker */
+
+#define IGP3_PPC_JORDAN_EN           0x0001
+#define IGP3_PPC_JORDAN_GIGA_SPEED   0x0002
+
+#define IGP3_KMRN_PMC_EE_IDLE_LINK_DIS         0x0001
+#define IGP3_KMRN_PMC_K0S_ENTRY_LATENCY_MASK   0x001E
+#define IGP3_KMRN_PMC_K0S_MODE1_EN_GIGA        0x0020
+#define IGP3_KMRN_PMC_K0S_MODE1_EN_100         0x0040
+
+#define IGP3E1000_PHY_MISC_CTRL                0x1B   /* Misc. Ctrl register */
+#define IGP3_PHY_MISC_DUPLEX_MANUAL_SET        0x1000 /* Duplex Manual Set */
+
+#define IGP3_KMRN_EXT_CTRL  PHY_REG(770, 18)
+#define IGP3_KMRN_EC_DIS_INBAND    0x0080
+
+#define IGP03E1000_E_PHY_ID  0x02A80390
+#define IFE_E_PHY_ID         0x02A80330 /* 10/100 PHY */
+#define IFE_PLUS_E_PHY_ID    0x02A80320
+#define IFE_C_E_PHY_ID       0x02A80310
+
+#define IFE_PHY_EXTENDED_STATUS_CONTROL   0x10  /* 100BaseTx Extended Status, Control and Address */
+#define IFE_PHY_SPECIAL_CONTROL           0x11  /* 100BaseTx PHY special control register */
+#define IFE_PHY_RCV_FALSE_CARRIER         0x13  /* 100BaseTx Receive False Carrier Counter */
+#define IFE_PHY_RCV_DISCONNECT            0x14  /* 100BaseTx Receive Disconnet Counter */
+#define IFE_PHY_RCV_ERROT_FRAME           0x15  /* 100BaseTx Receive Error Frame Counter */
+#define IFE_PHY_RCV_SYMBOL_ERR            0x16  /* Receive Symbol Error Counter */
+#define IFE_PHY_PREM_EOF_ERR              0x17  /* 100BaseTx Receive Premature End Of Frame Error Counter */
+#define IFE_PHY_RCV_EOF_ERR               0x18  /* 10BaseT Receive End Of Frame Error Counter */
+#define IFE_PHY_TX_JABBER_DETECT          0x19  /* 10BaseT Transmit Jabber Detect Counter */
+#define IFE_PHY_EQUALIZER                 0x1A  /* PHY Equalizer Control and Status */
+#define IFE_PHY_SPECIAL_CONTROL_LED       0x1B  /* PHY special control and LED configuration */
+#define IFE_PHY_MDIX_CONTROL              0x1C  /* MDI/MDI-X Control register */
+#define IFE_PHY_HWI_CONTROL               0x1D  /* Hardware Integrity Control (HWI) */
+
+#define IFE_PESC_REDUCED_POWER_DOWN_DISABLE  0x2000  /* Defaut 1 = Disable auto reduced power down */
+#define IFE_PESC_100BTX_POWER_DOWN           0x0400  /* Indicates the power state of 100BASE-TX */
+#define IFE_PESC_10BTX_POWER_DOWN            0x0200  /* Indicates the power state of 10BASE-T */
+#define IFE_PESC_POLARITY_REVERSED           0x0100  /* Indicates 10BASE-T polarity */
+#define IFE_PESC_PHY_ADDR_MASK               0x007C  /* Bit 6:2 for sampled PHY address */
+#define IFE_PESC_SPEED                       0x0002  /* Auto-negotiation speed result 1=100Mbs, 0=10Mbs */
+#define IFE_PESC_DUPLEX                      0x0001  /* Auto-negotiation duplex result 1=Full, 0=Half */
+#define IFE_PESC_POLARITY_REVERSED_SHIFT     8
+
+#define IFE_PSC_DISABLE_DYNAMIC_POWER_DOWN   0x0100  /* 1 = Dyanmic Power Down disabled */
+#define IFE_PSC_FORCE_POLARITY               0x0020  /* 1=Reversed Polarity, 0=Normal */
+#define IFE_PSC_AUTO_POLARITY_DISABLE        0x0010  /* 1=Auto Polarity Disabled, 0=Enabled */
+#define IFE_PSC_JABBER_FUNC_DISABLE          0x0001  /* 1=Jabber Disabled, 0=Normal Jabber Operation */
+#define IFE_PSC_FORCE_POLARITY_SHIFT         5
+#define IFE_PSC_AUTO_POLARITY_DISABLE_SHIFT  4
+
+#define IFE_PMC_AUTO_MDIX                    0x0080  /* 1=enable MDI/MDI-X feature, default 0=disabled */
+#define IFE_PMC_FORCE_MDIX                   0x0040  /* 1=force MDIX-X, 0=force MDI */
+#define IFE_PMC_MDIX_STATUS                  0x0020  /* 1=MDI-X, 0=MDI */
+#define IFE_PMC_AUTO_MDIX_COMPLETE           0x0010  /* Resolution algorthm is completed */
+#define IFE_PMC_MDIX_MODE_SHIFT              6
+#define IFE_PHC_MDIX_RESET_ALL_MASK          0x0000  /* Disable auto MDI-X */
+
+#define IFE_PHC_HWI_ENABLE                   0x8000  /* Enable the HWI feature */
+#define IFE_PHC_ABILITY_CHECK                0x4000  /* 1= Test Passed, 0=failed */
+#define IFE_PHC_TEST_EXEC                    0x2000  /* PHY launch test pulses on the wire */
+#define IFE_PHC_HIGHZ                        0x0200  /* 1 = Open Circuit */
+#define IFE_PHC_LOWZ                         0x0400  /* 1 = Short Circuit */
+#define IFE_PHC_LOW_HIGH_Z_MASK              0x0600  /* Mask for indication type of problem on the line */
+#define IFE_PHC_DISTANCE_MASK                0x01FF  /* Mask for distance to the cable problem, in 80cm granularity */
+#define IFE_PHC_RESET_ALL_MASK               0x0000  /* Disable HWI */
+#define IFE_PSCL_PROBE_MODE                  0x0020  /* LED Probe mode */
+#define IFE_PSCL_PROBE_LEDS_OFF              0x0006  /* Force LEDs 0 and 2 off */
+#define IFE_PSCL_PROBE_LEDS_ON               0x0007  /* Force LEDs 0 and 2 on */
+
+#define ICH8_FLASH_COMMAND_TIMEOUT           500   /* 500 ms , should be adjusted */
+#define ICH8_FLASH_CYCLE_REPEAT_COUNT        10    /* 10 cycles , should be adjusted */
+#define ICH8_FLASH_SEG_SIZE_256              256
+#define ICH8_FLASH_SEG_SIZE_4K               4096
+#define ICH8_FLASH_SEG_SIZE_64K              65536
+
+#define ICH8_CYCLE_READ                      0x0
+#define ICH8_CYCLE_RESERVED                  0x1
+#define ICH8_CYCLE_WRITE                     0x2
+#define ICH8_CYCLE_ERASE                     0x3
+
+#define ICH8_FLASH_GFPREG   0x0000
+#define ICH8_FLASH_HSFSTS   0x0004
+#define ICH8_FLASH_HSFCTL   0x0006
+#define ICH8_FLASH_FADDR    0x0008
+#define ICH8_FLASH_FDATA0   0x0010
+#define ICH8_FLASH_FRACC    0x0050
+#define ICH8_FLASH_FREG0    0x0054
+#define ICH8_FLASH_FREG1    0x0058
+#define ICH8_FLASH_FREG2    0x005C
+#define ICH8_FLASH_FREG3    0x0060
+#define ICH8_FLASH_FPR0     0x0074
+#define ICH8_FLASH_FPR1     0x0078
+#define ICH8_FLASH_SSFSTS   0x0090
+#define ICH8_FLASH_SSFCTL   0x0092
+#define ICH8_FLASH_PREOP    0x0094
+#define ICH8_FLASH_OPTYPE   0x0096
+#define ICH8_FLASH_OPMENU   0x0098
+
+#define ICH8_FLASH_REG_MAPSIZE      0x00A0
+#define ICH8_FLASH_SECTOR_SIZE      4096
+#define ICH8_GFPREG_BASE_MASK       0x1FFF
+#define ICH8_FLASH_LINEAR_ADDR_MASK 0x00FFFFFF
+
+/* ICH8 GbE Flash Hardware Sequencing Flash Status Register bit breakdown */
+/* Offset 04h HSFSTS */
+union ich8_hws_flash_status {
+    struct ich8_hsfsts {
+#ifdef E1000_BIG_ENDIAN
+        uint16_t reserved2      :6;
+        uint16_t fldesvalid     :1;
+        uint16_t flockdn        :1;
+        uint16_t flcdone        :1;
+        uint16_t flcerr         :1;
+        uint16_t dael           :1;
+        uint16_t berasesz       :2;
+        uint16_t flcinprog      :1;
+        uint16_t reserved1      :2;
+#else
+        uint16_t flcdone        :1;   /* bit 0 Flash Cycle Done */
+        uint16_t flcerr         :1;   /* bit 1 Flash Cycle Error */
+        uint16_t dael           :1;   /* bit 2 Direct Access error Log */
+        uint16_t berasesz       :2;   /* bit 4:3 Block/Sector Erase Size */
+        uint16_t flcinprog      :1;   /* bit 5 flash SPI cycle in Progress */
+        uint16_t reserved1      :2;   /* bit 13:6 Reserved */
+        uint16_t reserved2      :6;   /* bit 13:6 Reserved */
+        uint16_t fldesvalid     :1;   /* bit 14 Flash Descriptor Valid */
+        uint16_t flockdn        :1;   /* bit 15 Flash Configuration Lock-Down */
+#endif
+    } hsf_status;
+    uint16_t regval;
+};
+
+/* ICH8 GbE Flash Hardware Sequencing Flash control Register bit breakdown */
+/* Offset 06h FLCTL */
+union ich8_hws_flash_ctrl {
+    struct ich8_hsflctl {
+#ifdef E1000_BIG_ENDIAN
+        uint16_t fldbcount      :2;
+        uint16_t flockdn        :6;
+        uint16_t flcgo          :1;
+        uint16_t flcycle        :2;
+        uint16_t reserved       :5;
+#else
+        uint16_t flcgo          :1;   /* 0 Flash Cycle Go */
+        uint16_t flcycle        :2;   /* 2:1 Flash Cycle */
+        uint16_t reserved       :5;   /* 7:3 Reserved  */
+        uint16_t fldbcount      :2;   /* 9:8 Flash Data Byte Count */
+        uint16_t flockdn        :6;   /* 15:10 Reserved */
+#endif
+    } hsf_ctrl;
+    uint16_t regval;
+};
+
+/* ICH8 Flash Region Access Permissions */
+union ich8_hws_flash_regacc {
+    struct ich8_flracc {
+#ifdef E1000_BIG_ENDIAN
+        uint32_t gmwag          :8;
+        uint32_t gmrag          :8;
+        uint32_t grwa           :8;
+        uint32_t grra           :8;
+#else
+        uint32_t grra           :8;   /* 0:7 GbE region Read Access */
+        uint32_t grwa           :8;   /* 8:15 GbE region Write Access */
+        uint32_t gmrag          :8;   /* 23:16 GbE Master Read Access Grant  */
+        uint32_t gmwag          :8;   /* 31:24 GbE Master Write Access Grant */
+#endif
+    } hsf_flregacc;
+    uint16_t regval;
+};
+
 /* Miscellaneous PHY bit definitions. */
 #define PHY_PREAMBLE        0xFFFFFFFF
 #define PHY_SOF             0x01
diff --git a/drivers/net/e1000/e1000_osdep.h b/drivers/net/e1000/e1000_osdep.h
index 6130a42..78f54e3 100644
--- a/drivers/net/e1000/e1000_osdep.h
+++ b/drivers/net/e1000/e1000_osdep.h
@@ -130,4 +130,17 @@ typedef enum {
 
 #define E1000_WRITE_FLUSH(a) E1000_READ_REG(a, STATUS)
 
+#define E1000_WRITE_ICH8_REG(a, reg, value) ( \
+    writel((value), ((a)->flash_address + reg)))
+
+#define E1000_READ_ICH8_REG(a, reg) ( \
+    readl((a)->flash_address + reg))
+
+#define E1000_WRITE_ICH8_REG16(a, reg, value) ( \
+    writew((value), ((a)->flash_address + reg)))
+
+#define E1000_READ_ICH8_REG16(a, reg) ( \
+    readw((a)->flash_address + reg))
+
+
 #endif /* _E1000_OSDEP_H_ */



--
Auke Kok <auke-jan.h.kok@intel.com>
