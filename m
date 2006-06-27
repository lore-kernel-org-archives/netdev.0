From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 18/21] e1000: integrate ich8 support into driver
Date: Mon, 26 Jun 2006 21:54:36 -0400
Message-ID: <44A08FDC.2080201@pobox.com>
References: <20060622051815.25497.89192.stgit@gitlost.site> <20060622052046.25497.11216.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52436 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1030605AbWF0Byj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 21:54:39 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060622052046.25497.11216.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> @@ -4225,6 +4396,35 @@ e1000_init_eeprom_params(struct e1000_hw
>          eeprom->use_eerd = TRUE;
>          eeprom->use_eewr = FALSE;
>          break;
> +    case e1000_ich8lan:
> +    {
> +        int32_t  i = 0;
> +        uint32_t flash_size = E1000_READ_ICH8_REG(hw, ICH8_FLASH_GFPREG);
> +
> +        eeprom->type = e1000_eeprom_ich8;
> +        eeprom->use_eerd = FALSE;
> +        eeprom->use_eewr = FALSE;
> +        eeprom->word_size = E1000_SHADOW_RAM_WORDS;
> +
> +        /* Zero the shadow RAM structure. But don't load it from NVM
> +         * so as to save time for driver init */
> +        if (hw->eeprom_shadow_ram != NULL) {
> +            for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
> +                hw->eeprom_shadow_ram[i].modified = FALSE;
> +                hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
> +            }
> +        }
> +
> +        hw->flash_base_addr = (flash_size & ICH8_GFPREG_BASE_MASK) *
> +                              ICH8_FLASH_SECTOR_SIZE;
> +
> +        hw->flash_bank_size = ((flash_size >> 16) & ICH8_GFPREG_BASE_MASK) + 1;
> +        hw->flash_bank_size -= (flash_size & ICH8_GFPREG_BASE_MASK);
> +        hw->flash_bank_size *= ICH8_FLASH_SECTOR_SIZE;
> +        hw->flash_bank_size /= 2 * sizeof(uint16_t);
> +
> +        break;
> +    }

seems to warrant a separate function, called from this callsite (perhaps 
stored in e1000-ich8.c?)


> @@ -4645,7 +4845,10 @@ e1000_read_eeprom(struct e1000_hw *hw,
>          return ret_val;
>      }
>  
> -    if(eeprom->type == e1000_eeprom_spi) {
> +    if (eeprom->type == e1000_eeprom_ich8)
> +        return e1000_read_eeprom_ich8(hw, offset, words, data);
> +
> +    if (eeprom->type == e1000_eeprom_spi) {
>          uint16_t word_in;
>          uint8_t read_opcode = EEPROM_READ_OPCODE_SPI;
>  
> @@ -4812,7 +5015,10 @@ e1000_is_onboard_nvm_eeprom(struct e1000
>  
>      DEBUGFUNC("e1000_is_onboard_nvm_eeprom");
>  
> -    if(hw->mac_type == e1000_82573) {
> +    if (hw->mac_type == e1000_ich8lan)
> +        return FALSE;
> +
> +    if (hw->mac_type == e1000_82573) {
>          eecd = E1000_READ_REG(hw, EECD);
>  
>          /* Isolate bits 15 & 16 */
> @@ -4862,8 +5068,22 @@ e1000_validate_eeprom_checksum(struct e1
>          }
>      }
>  
> -    for(i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++) {
> -        if(e1000_read_eeprom(hw, i, 1, &eeprom_data) < 0) {
> +    if (hw->mac_type == e1000_ich8lan) {
> +        /* Drivers must allocate the shadow ram structure for the
> +         * EEPROM checksum to be updated.  Otherwise, this bit as well
> +         * as the checksum must both be set correctly for this
> +         * validation to pass.
> +         */
> +        e1000_read_eeprom(hw, 0x19, 1, &eeprom_data);
> +        if ((eeprom_data & 0x40) == 0) {
> +            eeprom_data |= 0x40;
> +            e1000_write_eeprom(hw, 0x19, 1, &eeprom_data);
> +            e1000_update_eeprom_checksum(hw);
> +        }
> +    }
> +
> +    for (i = 0; i < (EEPROM_CHECKSUM_REG + 1); i++) {
> +        if (e1000_read_eeprom(hw, i, 1, &eeprom_data) < 0) {
>              DEBUGOUT("EEPROM Read Error\n");
>              return -E1000_ERR_EEPROM;
>          }
> @@ -4889,6 +5109,7 @@ e1000_validate_eeprom_checksum(struct e1
>  int32_t
>  e1000_update_eeprom_checksum(struct e1000_hw *hw)
>  {
> +    uint32_t ctrl_ext;
>      uint16_t checksum = 0;
>      uint16_t i, eeprom_data;
>  
> @@ -4907,6 +5128,14 @@ e1000_update_eeprom_checksum(struct e100
>          return -E1000_ERR_EEPROM;
>      } else if (hw->eeprom.type == e1000_eeprom_flash) {
>          e1000_commit_shadow_ram(hw);
> +    } else if (hw->eeprom.type == e1000_eeprom_ich8) {
> +        e1000_commit_shadow_ram(hw);
> +        /* Reload the EEPROM, or else modifications will not appear
> +         * until after next adapter reset. */
> +        ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
> +        ctrl_ext |= E1000_CTRL_EXT_EE_RST;
> +        E1000_WRITE_REG(hw, CTRL_EXT, ctrl_ext);
> +        msec_delay(10);
>      }
>      return E1000_SUCCESS;
>  }
> @@ -4946,6 +5175,9 @@ e1000_write_eeprom(struct e1000_hw *hw,
>      if(eeprom->use_eewr == TRUE)
>          return e1000_write_eeprom_eewr(hw, offset, words, data);
>  
> +    if (eeprom->type == e1000_eeprom_ich8)
> +        return e1000_write_eeprom_ich8(hw, offset, words, data);
> +
>      /* Prepare the EEPROM for writing  */
>      if (e1000_acquire_eeprom(hw) != E1000_SUCCESS)
>          return -E1000_ERR_EEPROM;
> @@ -5133,11 +5365,17 @@ e1000_commit_shadow_ram(struct e1000_hw 
>      uint32_t flop = 0;
>      uint32_t i = 0;
>      int32_t error = E1000_SUCCESS;
> -
> -    /* The flop register will be used to determine if flash type is STM */
> -    flop = E1000_READ_REG(hw, FLOP);
> +    uint32_t old_bank_offset = 0;
> +    uint32_t new_bank_offset = 0;
> +    uint32_t sector_retries = 0;
> +    uint8_t low_byte = 0;
> +    uint8_t high_byte = 0;
> +    uint8_t temp_byte = 0;
> +    boolean_t sector_write_failed = FALSE;
>  
>      if (hw->mac_type == e1000_82573) {
> +        /* The flop register will be used to determine if flash type is STM */
> +        flop = E1000_READ_REG(hw, FLOP);
>          for (i=0; i < attempts; i++) {
>              eecd = E1000_READ_REG(hw, EECD);
>              if ((eecd & E1000_EECD_FLUPD) == 0) {
> @@ -5171,6 +5409,106 @@ e1000_commit_shadow_ram(struct e1000_hw 
>          }
>      }
>  
> +    if (hw->mac_type == e1000_ich8lan && hw->eeprom_shadow_ram != NULL) {
> +        /* We're writing to the opposite bank so if we're on bank 1,
> +         * write to bank 0 etc.  We also need to erase the segment that
> +         * is going to be written */
> +        if (!(E1000_READ_REG(hw, EECD) & E1000_EECD_SEC1VAL)) {
> +            new_bank_offset = hw->flash_bank_size * 2;
> +            old_bank_offset = 0;
> +            e1000_erase_ich8_4k_segment(hw, 1);
> +        } else {
> +            old_bank_offset = hw->flash_bank_size * 2;
> +            new_bank_offset = 0;
> +            e1000_erase_ich8_4k_segment(hw, 0);
> +        }
> +
> +        do {
> +            sector_write_failed = FALSE;
> +            /* Loop for every byte in the shadow RAM,
> +             * which is in units of words. */
> +            for (i = 0; i < E1000_SHADOW_RAM_WORDS; i++) {
> +                /* Determine whether to write the value stored
> +                 * in the other NVM bank or a modified value stored
> +                 * in the shadow RAM */
> +                if (hw->eeprom_shadow_ram[i].modified == TRUE) {
> +                    low_byte = (uint8_t)hw->eeprom_shadow_ram[i].eeprom_word;
> +                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset,
> +                                         &temp_byte);
> +                    udelay(100);
> +                    error = e1000_verify_write_ich8_byte(hw,
> +                                                 (i << 1) + new_bank_offset,
> +                                                 low_byte);
> +                    if (error != E1000_SUCCESS)
> +                        sector_write_failed = TRUE;
> +                    high_byte =
> +                        (uint8_t)(hw->eeprom_shadow_ram[i].eeprom_word >> 8);
> +                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset + 1,
> +                                         &temp_byte);
> +                    udelay(100);
> +                } else {
> +                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset,
> +                                         &low_byte);
> +                    udelay(100);
> +                    error = e1000_verify_write_ich8_byte(hw,
> +                                 (i << 1) + new_bank_offset, low_byte);
> +                    if (error != E1000_SUCCESS)
> +                        sector_write_failed = TRUE;
> +                    e1000_read_ich8_byte(hw, (i << 1) + old_bank_offset + 1,
> +                                         &high_byte);
> +                }
> +
> +                /* If the word is 0x13, then make sure the signature bits
> +                 * (15:14) are 11b until the commit has completed.
> +                 * This will allow us to write 10b which indicates the
> +                 * signature is valid.  We want to do this after the write
> +                 * has completed so that we don't mark the segment valid
> +                 * while the write is still in progress */
> +                if (i == E1000_ICH8_NVM_SIG_WORD)
> +                    high_byte = E1000_ICH8_NVM_SIG_MASK | high_byte;
> +
> +                error = e1000_verify_write_ich8_byte(hw,
> +                             (i << 1) + new_bank_offset + 1, high_byte);
> +                if (error != E1000_SUCCESS)
> +                    sector_write_failed = TRUE;
> +
> +                if (sector_write_failed == FALSE) {
> +                    /* Clear the now not used entry in the cache */
> +                    hw->eeprom_shadow_ram[i].modified = FALSE;
> +                    hw->eeprom_shadow_ram[i].eeprom_word = 0xFFFF;
> +                }
> +            }
> +
> +            /* Don't bother writing the segment valid bits if sector
> +             * programming failed. */
> +            if (sector_write_failed == FALSE) {
> +                /* Finally validate the new segment by setting bit 15:14
> +                 * to 10b in word 0x13 , this can be done without an
> +                 * erase as well since these bits are 11 to start with
> +                 * and we need to change bit 14 to 0b */
> +                e1000_read_ich8_byte(hw,
> +                    E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
> +                    &high_byte);
> +                high_byte &= 0xBF;
> +                error = e1000_verify_write_ich8_byte(hw,
> +                            E1000_ICH8_NVM_SIG_WORD * 2 + 1 + new_bank_offset,
> +                            high_byte);
> +                if (error != E1000_SUCCESS)
> +                    sector_write_failed = TRUE;
> +
> +                /* And invalidate the previously valid segment by setting
> +                 * its signature word (0x13) high_byte to 0b. This can be
> +                 * done without an erase because flash erase sets all bits
> +                 * to 1's. We can write 1's to 0's without an erase */
> +                error = e1000_verify_write_ich8_byte(hw,
> +                            E1000_ICH8_NVM_SIG_WORD * 2 + 1 + old_bank_offset,
> +                            0);
> +                if (error != E1000_SUCCESS)
> +                    sector_write_failed = TRUE;
> +            }
> +        } while (++sector_retries < 10 && sector_write_failed == TRUE);
> +    }
> +

obviously warrants a separate function for new ich8 code...



