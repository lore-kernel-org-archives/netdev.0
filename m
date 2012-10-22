From: "Skidmore, Donald C" <donald.c.skidmore@intel.com>
Subject: RE: [net-next 12/13] ixgbe: Add support for pipeline reset
Date: Mon, 22 Oct 2012 20:45:51 +0000
Message-ID: <F6FB0E698C9B3143BDF729DF222866462F153919@ORSMSX101.amr.corp.intel.com>
References: <1350714367-24208-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1350714367-24208-13-git-send-email-jeffrey.t.kirsher@intel.com>
 <CAP1qwHgSra4i=+O5JczYxHJLn40sqC4DdYX+_jijXSwTqYeuzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Martin Josefsson <gandalf@mjufs.se>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:55841 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754195Ab2JVUpx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2012 16:45:53 -0400
In-Reply-To: <CAP1qwHgSra4i=+O5JczYxHJLn40sqC4DdYX+_jijXSwTqYeuzg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org] On Behalf Of Martin Josefsson
Sent: Sunday, October 21, 2012 5:06 AM
To: Kirsher, Jeffrey T
Cc: davem@davemloft.net; Skidmore, Donald C; netdev@vger.kernel.org; gospo@redhat.com; sassmann@redhat.com
Subject: Re: [net-next 12/13] ixgbe: Add support for pipeline reset

On Sat, Oct 20, 2012 at 8:26 AM, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> From: Don Skidmore <donald.c.skidmore@intel.com>

Hi Jeff, Don,

> Calling the ixgbe_reset_pipeline_82599 function will ensure a full 
> pipeline reset on all 82599 devices.  This is necessary to avoid possible link issues.
> Since this patch accomplishes this by modifying AUTOC.LMS we need to 
> wrap all AUTOC writes when LESM is enabled.

The section below doesn't look right.
Old behaviour gave LMS == 011b (SFI)
New behaviour gives LMS == 000b (1 GbE link (no backplane auto-negotiation))

LMS is reset to 0 before ixgbe_reset_pipeline_82599() is called.
Looks like that part of the old code wasn't removed.

> @@ -137,28 +135,37 @@ static s32 ixgbe_setup_sfp_modules_82599(struct ixgbe_hw *hw)
>                 usleep_range(hw->eeprom.semaphore_delay * 1000,
>                              hw->eeprom.semaphore_delay * 2000);
>
> +               /* Need SW/FW semaphore around AUTOC writes if LESM on,
> +                * likewise reset_pipeline requires lock as it also writes
> +                * AUTOC.
> +                */
> +               if (ixgbe_verify_lesm_fw_enabled_82599(hw)) {
> +                       ret_val = hw->mac.ops.acquire_swfw_sync(hw,
> +                                                       IXGBE_GSSR_MAC_CSR_SM);
> +                       if (ret_val)
> +                               goto setup_sfp_out;
> +
> +                       got_lock = true;
> +               }
> +
>                 /* Now restart DSP by setting Restart_AN and clearing LMS */
>                 IXGBE_WRITE_REG(hw, IXGBE_AUTOC, ((IXGBE_READ_REG(hw,
>                                 IXGBE_AUTOC) & ~IXGBE_AUTOC_LMS_MASK) |
>                                 IXGBE_AUTOC_AN_RESTART));
>
> -               /* Wait for AN to leave state 0 */
> -               for (i = 0; i < 10; i++) {
> -                       usleep_range(4000, 8000);
> -                       reg_anlp1 = IXGBE_READ_REG(hw, IXGBE_ANLP1);
> -                       if (reg_anlp1 & IXGBE_ANLP1_AN_STATE_MASK)
> -                               break;
> +               ret_val = ixgbe_reset_pipeline_82599(hw);
> +
> +               if (got_lock) {
> +                       hw->mac.ops.release_swfw_sync(hw,
> +                                                     IXGBE_GSSR_MAC_CSR_SM);
> +                       got_lock = false;
>                 }
> -               if (!(reg_anlp1 & IXGBE_ANLP1_AN_STATE_MASK)) {
> -                       hw_dbg(hw, "sfp module setup not complete\n");
> +
> +               if (ret_val) {
> +                       hw_dbg(hw, " sfp module setup not 
> + complete\n");
>                         ret_val = IXGBE_ERR_SFP_SETUP_NOT_COMPLETE;
>                         goto setup_sfp_out;
>                 }
> -
> -               /* Restart DSP by setting Restart_AN and return to SFI mode */
> -               IXGBE_WRITE_REG(hw, IXGBE_AUTOC, (IXGBE_READ_REG(hw,
> -                               IXGBE_AUTOC) | IXGBE_AUTOC_LMS_10G_SERIAL |
> -                               IXGBE_AUTOC_AN_RESTART));
>         }
>
>  setup_sfp_out:

--
/Martin
--
To unsubscribe from this list: send the line "unsubscribe netdev" in the body of a message to majordomo@vger.kernel.org More majordomo info at  http://vger.kernel.org/majordomo-info.html

Hi Martin,

Thanks for pointing this problem out and I believe I see what is wrong.  I'll work with Jeff to get a new patch created and tested.

Thanks again,
-Don Skidmore <donald.c.skidmore@intel.com>
