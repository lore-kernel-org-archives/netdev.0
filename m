From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 07/12] ixgbe: Enable timesync clock-out feature for
 PPS support on X540
Date: Thu, 10 May 2012 16:17:21 +0200
Message-ID: <20120510141721.GC3392@localhost.localdomain>
References: <1336632413-19135-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1336632413-19135-8-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jacob E Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54097 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752131Ab2EJOR0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 10:17:26 -0400
Received: by eaaq12 with SMTP id q12so547001eaa.19
        for <netdev@vger.kernel.org>; Thu, 10 May 2012 07:17:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1336632413-19135-8-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 09, 2012 at 11:46:48PM -0700, Jeff Kirsher wrote:
> From: Jacob E Keller <jacob.e.keller@intel.com>
> 
> This patch enables the PPS system in the PHC framework, by enabling
> the clock-out feature on the X540 device. Causes the SDP0 to be set as
> a 1Hz clock. Also configures the timesync interrupt cause in order to
> report each pulse to the PPS via the PHC framework, which can be used
> for general system clock synchronization. (This allows a stable method
> for tuning the general system time via the on-board SYSTIM register
> based clock.)

Glad to see the PPS output and internal PPS support.

> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 9a83c40..1ad6e2a 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c

...

>  /**
> + * ixgbe_ptp_check_pps_event
> + * @adapter - the private adapter structure
> + * @eicr - the interrupt cause register value
> + *
> + * This function is called by the interrupt routine when checking for
> + * interrupts. It will check and handle a pps event.
> + */
> +void ixgbe_ptp_check_pps_event(struct ixgbe_adapter *adapter, u32 eicr)
> +{
> +	struct ixgbe_hw *hw = &adapter->hw;
> +	struct ptp_clock_event event;
> +
> +	event.type = PTP_CLOCK_PPS;
> +
> +	/* Make sure ptp clock is valid, and PPS event enabled */
> +	if (!adapter->ptp_clock ||
> +	    !(adapter->flags2 & IXGBE_FLAG2_PTP_PPS_ENABLED))
> +		return;
> +
> +	switch (hw->mac.type) {
> +	case ixgbe_mac_X540:
> +		if (eicr & IXGBE_EICR_TIMESYNC)

Since this function is called in every interrupt, I would check this
flag first thing.

> +			ptp_clock_event(adapter->ptp_clock, &event);
> +		break;
> +	default:
> +		break;
> +	}
> +}

Thanks,
Richard
