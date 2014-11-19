From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/4] igb: enable internal PPS for the i210.
Date: Wed, 19 Nov 2014 07:37:24 +0100
Message-ID: <20141119063724.GB4109@localhost.localdomain>
References: <cover.1416265321.git.richardcochran@gmail.com>
 <e5b4ef7c56119e2d86e42f5680b1b82c9ec1a38e.1416265321.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bruce.w.allan@intel.com,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Matthew Vick <matthew.vick@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:43842 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754005AbaKSGha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2014 01:37:30 -0500
Received: by mail-wi0-f169.google.com with SMTP id r20so7877366wiv.2
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 22:37:28 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <e5b4ef7c56119e2d86e42f5680b1b82c9ec1a38e.1416265321.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 12:06:24AM +0100, Richard Cochran wrote:
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -5386,8 +5386,14 @@ void igb_update_stats(struct igb_adapter *adapter,
>  static void igb_tsync_interrupt(struct igb_adapter *adapter)
>  {
>  	struct e1000_hw *hw = &adapter->hw;
> +	struct ptp_clock_event event;
>  	u32 tsicr = rd32(E1000_TSICR);
>  
> +	if (tsicr & TSINTR_SYS_WRAP) {
> +		event.type = PTP_CLOCK_PPS;
> +		ptp_clock_event(adapter->ptp_clock, &event);

This causes a BUG for the 82580. When you enable E1000_TSICR_TXTS, it
seems that TSINTR_SYS_WRAP is also automatically enabled. Because the
82580 variant has no pps device enabled, the driver then dereferences
a null pointer.

So we need to make the call to ptp_clock_event() conditional based on
whether pps is enabled. I'll fix this in V2.

> +	}
> +

Thanks,
Richard
