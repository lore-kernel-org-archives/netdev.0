From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 10/13] igb: Tidy up wrapping for CONFIG_IGB_PTP.
Date: Thu, 23 Aug 2012 13:03:57 +0200
Message-ID: <20120823110357.GB2238@netboy.at.omicron.at>
References: <1345715813-20757-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Matthew Vick <matthew.vick@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:46254 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933950Ab2HWLEE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Aug 2012 07:04:04 -0400
Received: by wgbdr13 with SMTP id dr13so513512wgb.1
        for <netdev@vger.kernel.org>; Thu, 23 Aug 2012 04:04:01 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1345715813-20757-11-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 23, 2012 at 02:56:50AM -0700, Jeff Kirsher wrote:
> From: Matthew Vick <matthew.vick@intel.com>
> 
> For users without CONFIG_IGB_PTP=y, we should not be compiling any PTP
> code into the driver. Tidy up the wrapping in igb to support this.

Actually, you are doing more than that. You are adding a bunch of
comments onto the already existing #endifs.
 
> Signed-off-by: Matthew Vick <matthew.vick@intel.com>
> Acked-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Jeff Pieper  <jeffrey.e.pieper@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h         |  8 ++++++--
>  drivers/net/ethernet/intel/igb/igb_ethtool.c |  4 ++--
>  drivers/net/ethernet/intel/igb/igb_main.c    | 23 +++++++++++++++++------
>  3 files changed, 25 insertions(+), 10 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
> index 0c9f62c..a3b5b90 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -34,9 +34,11 @@
>  #include "e1000_mac.h"
>  #include "e1000_82575.h"
>  
> +#ifdef CONFIG_IGB_PTP
>  #include <linux/clocksource.h>
>  #include <linux/net_tstamp.h>
>  #include <linux/ptp_clock_kernel.h>
> +#endif /* CONFIG_IGB_PTP */
>  #include <linux/bitops.h>
>  #include <linux/if_vlan.h>
>  
> @@ -376,12 +378,15 @@ struct igb_adapter {
>  	int node;
>  	u32 *shadow_vfta;
>  
> +#ifdef CONFIG_IGB_PTP
>  	struct ptp_clock *ptp_clock;
>  	struct ptp_clock_info caps;
>  	struct delayed_work overflow_work;
>  	spinlock_t tmreg_lock;
>  	struct cyclecounter cc;
>  	struct timecounter tc;
> +#endif /* CONFIG_IGB_PTP */
> +

This is legitimate, to reduce memory footprint.

>  	char fw_version[32];
>  };
>  
> @@ -436,12 +441,11 @@ extern void igb_set_fw_version(struct igb_adapter *);
>  #ifdef CONFIG_IGB_PTP
>  extern void igb_ptp_init(struct igb_adapter *adapter);
>  extern void igb_ptp_remove(struct igb_adapter *adapter);
> -
>  extern void igb_systim_to_hwtstamp(struct igb_adapter *adapter,
>  				   struct skb_shared_hwtstamps *hwtstamps,
>  				   u64 systim);
> +#endif /* CONFIG_IGB_PTP */
>  
> -#endif
>  static inline s32 igb_reset_phy(struct e1000_hw *hw)
>  {
>  	if (hw->phy.ops.reset)
> diff --git a/drivers/net/ethernet/intel/igb/igb_ethtool.c b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> index c4def55..6adb0f7 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ethtool.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ethtool.c
> @@ -2323,8 +2323,8 @@ static int igb_ethtool_get_ts_info(struct net_device *dev,
>  
>  	return 0;
>  }
> +#endif /* CONFIG_IGB_PTP */
>  
> -#endif
>  static const struct ethtool_ops igb_ethtool_ops = {
>  	.get_settings           = igb_get_settings,
>  	.set_settings           = igb_set_settings,
> @@ -2355,7 +2355,7 @@ static const struct ethtool_ops igb_ethtool_ops = {
>  	.complete		= igb_ethtool_complete,
>  #ifdef CONFIG_IGB_PTP
>  	.get_ts_info		= igb_ethtool_get_ts_info,
> -#endif
> +#endif /* CONFIG_IGB_PTP */
>  };
>  
>  void igb_set_ethtool_ops(struct net_device *netdev)
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index 73cc273..03477d7 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -2180,11 +2180,12 @@ static int __devinit igb_probe(struct pci_dev *pdev,
>  	}
>  
>  #endif
> +
>  #ifdef CONFIG_IGB_PTP
>  	/* do hw tstamp init after resetting */
>  	igb_ptp_init(adapter);
> +#endif /* CONFIG_IGB_PTP */
>  
> -#endif

But this is just churn. You aren't actually improving anything
here. It is already clear that the #endif belongs to the #ifdef just
three lines above.

If you are on some kind of campaign to comment all the endifs, then
you should say so, and, to be consistent, you should not overlook the
CONFIG_IGB_DCA blocks.

But I think it really isn't needed.

Thanks,
Richard
