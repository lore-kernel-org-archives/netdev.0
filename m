From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 13/23] e1000: gather hardware bit tweaks.
Date: Tue, 19 Sep 2006 15:36:44 -0400
Message-ID: <451046CC.3050101@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172901.4605.36283.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:6076 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751980AbWISTgs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:36:48 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060919172901.4605.36283.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Several hardware bits were set all over the driver and have been
> consolidated into a single function.

> diff --git a/drivers/net/e1000/e1000_hw.c b/drivers/net/e1000/e1000_hw.c
> index 9422864..a143b49 100644
> --- a/drivers/net/e1000/e1000_hw.c
> +++ b/drivers/net/e1000/e1000_hw.c
> @@ -61,6 +61,7 @@ static int32_t e1000_id_led_init(struct 
>  static int32_t e1000_init_lcd_from_nvm_config_region(struct e1000_hw *hw, uint32_t cnf_base_addr, uint32_t cnf_size);
>  static int32_t e1000_init_lcd_from_nvm(struct e1000_hw *hw);
>  static void e1000_init_rx_addrs(struct e1000_hw *hw);
> +static void e1000_initialize_hardware_bits(struct e1000_hw *hw);
>  static boolean_t e1000_is_onboard_nvm_eeprom(struct e1000_hw *hw);
>  static int32_t e1000_kumeran_lock_loss_workaround(struct e1000_hw *hw);
>  static int32_t e1000_mng_enable_host_if(struct e1000_hw *hw);
> @@ -716,6 +717,110 @@ e1000_reset_hw(struct e1000_hw *hw)
>  }
>  
>  /******************************************************************************
> + *
> + * Initialize a number of hardware-dependent bits
> + *
> + * hw: Struct containing variables accessed by shared code
> + *
> + *****************************************************************************/
> +static void
> +e1000_initialize_hardware_bits(struct e1000_hw *hw)
> +{
> +    if ((hw->mac_type >= e1000_82571) && (!hw->initialize_hw_bits_disable)) {
> +        /* Settings common to all silicon */
> +        uint32_t reg_ctrl, reg_ctrl_ext;
> +        uint32_t reg_tarc0, reg_tarc1;
> +        uint32_t reg_tctl;
> +        uint32_t reg_txdctl, reg_txdctl1;
> +
> +        reg_tarc0 = E1000_READ_REG(hw, TARC0);
> +        reg_tarc0 &= ~0x78000000;           /* Clear bits 30, 29, 28, and 27 */
> +
> +        reg_txdctl = E1000_READ_REG(hw, TXDCTL);
> +        reg_txdctl |= E1000_TXDCTL_COUNT_DESC;       /* Set bit 22 */
> +        E1000_WRITE_REG(hw, TXDCTL, reg_txdctl);
> +
> +        reg_txdctl1 = E1000_READ_REG(hw, TXDCTL1);
> +        reg_txdctl1 |= E1000_TXDCTL_COUNT_DESC;      /* Set bit 22 */
> +        E1000_WRITE_REG(hw, TXDCTL1, reg_txdctl1);
> +
> +        switch (hw->mac_type) {
> +            case e1000_82571:
> +            case e1000_82572:
> +                reg_tarc1 = E1000_READ_REG(hw, TARC1);
> +                reg_tctl = E1000_READ_REG(hw, TCTL);
> +
> +                /* Set the phy Tx compatible mode bits */
> +                reg_tarc1 &= ~0x60000000;   /* Clear bits 30 and 29 */
> +
> +                reg_tarc0 |= 0x07800000;    /* Set TARC0 bits 23-26 */
> +                reg_tarc1 |= 0x07000000;    /* Set TARC1 bits 24-26 */
> +
> +                if (reg_tctl & E1000_TCTL_MULR)
> +                    reg_tarc1 &= ~0x10000000;   /* Clear bit 28 if MULR is 1b */
> +                else
> +                    reg_tarc1 |= 0x10000000;    /* Set bit 28 if MULR is 0b */
> +
> +                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
> +                break;
> +            case e1000_82573:
> +                reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
> +                reg_ctrl = E1000_READ_REG(hw, CTRL);
> +
> +                reg_ctrl_ext &= ~0x00800000;    /* Clear bit 23 */
> +                reg_ctrl_ext |= 0x00400000;     /* Set bit 22 */
> +                reg_ctrl &= ~0x20000000;        /* Clear bit 29 */
> +
> +                E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
> +                E1000_WRITE_REG(hw, CTRL, reg_ctrl);
> +                break;
> +            case e1000_80003es2lan:
> +                if ((hw->media_type == e1000_media_type_fiber) ||
> +                    (hw->media_type == e1000_media_type_internal_serdes)) {
> +                    reg_tarc0 &= ~0x00100000;   /* Clear bit 20 */
> +                }
> +
> +                reg_tctl = E1000_READ_REG(hw, TCTL);
> +                reg_tarc1 = E1000_READ_REG(hw, TARC1);
> +                if (reg_tctl & E1000_TCTL_MULR)
> +                    reg_tarc1 &= ~0x10000000;   /* Clear bit 28 if MULR is 1b */
> +                else
> +                    reg_tarc1 |= 0x10000000;    /* Set bit 28 if MULR is 0b */
> +
> +                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
> +                break;
> +            case e1000_ich8lan:
> +                if ((hw->revision_id < 3) ||
> +                    ((hw->device_id != E1000_DEV_ID_ICH8_IGP_M_AMT) &&
> +                     (hw->device_id != E1000_DEV_ID_ICH8_IGP_M)))
> +                    reg_tarc0 |= 0x30000000;    /* Set TARC0 bits 29 and 28 */
> +                reg_ctrl_ext = E1000_READ_REG(hw, CTRL_EXT);
> +                reg_ctrl_ext |= 0x00400000;     /* Set bit 22 */
> +                E1000_WRITE_REG(hw, CTRL_EXT, reg_ctrl_ext);
> +
> +                reg_tarc0 |= 0x0d800000;    /* Set TARC0 bits 23, 24, 26, 27 */
> +
> +                reg_tarc1 = E1000_READ_REG(hw, TARC1);
> +                reg_tctl = E1000_READ_REG(hw, TCTL);
> +
> +                if (reg_tctl & E1000_TCTL_MULR)
> +                    reg_tarc1 &= ~0x10000000;   /* Clear bit 28 if MULR is 1b */
> +                else
> +                    reg_tarc1 |= 0x10000000;    /* Set bit 28 if MULR is 0b */
> +
> +                reg_tarc1 |= 0x45000000;        /* Set bit 24, 26 and 30 */
> +
> +                E1000_WRITE_REG(hw, TARC1, reg_tarc1);
> +                break;
> +            default:
> +                break;
> +        }

Overall this is a positive change.  However, NAK'd for two superficial 
reasons:

1) the comments are completely useless.  We can see from reading the 
code what the comments tell us.  What the comments DON'T tell us are (a) 
a description of the bit being set, and (b) why that bit is being set.

2) the easy-for-humans-to-read notation for bit setting is

	(1 << n)

not a hex constant.

