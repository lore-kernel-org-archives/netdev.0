From: Arend van Spriel <arend@broadcom.com>
Subject: Re: Wireless scanning while turning off the radio problem..
Date: Sun, 18 Jan 2015 11:55:37 +0100
Message-ID: <54BB9129.5010103@broadcom.com>
References: <CA+55aFyr9LC7oLoJeyFwK4KRURbbUyO63jznTTAkQF+9LBAsfg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>,
	David Miller <davem@davemloft.net>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw2-out.broadcom.com ([216.31.210.63]:64482 "EHLO
	mail-gw2-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbbARKzk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 05:55:40 -0500
In-Reply-To: <CA+55aFyr9LC7oLoJeyFwK4KRURbbUyO63jznTTAkQF+9LBAsfg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/15 04:25, Linus Torvalds wrote:
> So there seems to be some issue with unlucky timing when turning off
> wireless while the driver is busy scanning. I can't reproduce this, so
> it's a one-off, but it's not just ugly warnings, the kernel woudln't
> scan any wireless on that device afterwards and I had to reboot to get
> networking back, so there is some long-term damage.
>
> This is with Intel wireless (iwlwifi, it's a iwl N7260 thing, rev
> 0x144 if anybody cares) , but the warning callbacks don't seem to be
> iwl-specific.
>
> This was a recent top-of-git kernel (3.19.0-rc4-00241-gfc7f0dd38172 to
> be exact).
>
> Anybody have any ideas? Anything in particular I should try out to
> help possibly get more information?

If I am not mistaken the "iwl N7260 thing" is a PCIe device.

iwl_pcie_irq_handler
	iwl_trans_pcie_rf_kill
		if (iwl_op_mode_hw_rf_kill)
			iwl_trans_pcie_stop_device

The function iwl_trans_pcie_stop_device() put device in low-power and 
resets the cpu on the device. So iwl_op_mode_hw_rf_kill ends up in
iwl_mvm_set_hw_rfkill_state which schedules cfg80211_rfkill_sync_work 
and returns true if firmware is running. The patch below might work.

Regards,
Arend

diff --git a/drivers/net/wireless/iwlwifi/mvm/ops.c 
b/drivers/net/wireless/iwlwi
index 97dfba5..685217a 100644
--- a/drivers/net/wireless/iwlwifi/mvm/ops.c
+++ b/drivers/net/wireless/iwlwifi/mvm/ops.c
@@ -779,6 +779,9 @@ static bool iwl_mvm_set_hw_rfkill_state(struct 
iwl_op_mode *
         if (calibrating)
                 iwl_abort_notification_waits(&mvm->notif_wait);

+       /* stop scheduled scan */
+       iwl_mvm_scan_offload_stop(mvm, true);
+
         /*
          * Stop the device if we run OPERATIONAL firmware or if we are 
in the
          * middle of the calibrations.
