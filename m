From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [net-next 14/16] i40e: enable PTP
Date: Fri, 10 Jan 2014 15:55:05 +0000
Message-ID: <1389369305.2025.64.camel@bwh-desktop.uk.level5networks.com>
References: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1389344336-1558-15-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Jacob Keller <jacob.e.keller@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>,
	<sassmann@redhat.com>, Richard Cochran <richardcochran@gmail.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8583 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750877AbaAJPzL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 10:55:11 -0500
In-Reply-To: <1389344336-1558-15-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-01-10 at 00:58 -0800, Jeff Kirsher wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> New feature: Enable PTP support in the i40e driver.
> 
> Change-ID: I6a8e799f582705191f9583afb1b9231a8db96cc8
> Cc: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
> Tested-by: Kavindya Deegala <kavindya.s.deegala@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/i40e/Makefile       |   2 +
>  drivers/net/ethernet/intel/i40e/i40e.h         |  24 +
>  drivers/net/ethernet/intel/i40e/i40e_ethtool.c |  33 +-
>  drivers/net/ethernet/intel/i40e/i40e_main.c    |  45 +-
>  drivers/net/ethernet/intel/i40e/i40e_ptp.c     | 640 +++++++++++++++++++++++++
>  drivers/net/ethernet/intel/i40e/i40e_txrx.c    |  53 ++
>  drivers/net/ethernet/intel/i40e/i40e_txrx.h    |   3 +
>  7 files changed, 798 insertions(+), 2 deletions(-)
>  create mode 100644 drivers/net/ethernet/intel/i40e/i40e_ptp.c

This is missing a Kconfig update to select PTP_1588_CLOCK.

[...]
> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
> @@ -1698,6 +1698,25 @@ static int i40e_change_mtu(struct net_device *netdev, int new_mtu)
>  }
>  
>  /**
> + * i40e_ioctl - Access the hwtstamp interface
> + * @netdev: network interface device structure
> + * @ifr: interface request data
> + * @cmd: ioctl command
> + **/
> +int i40e_ioctl(struct net_device *netdev, struct ifreq *ifr, int cmd)
> +{
> +	struct i40e_netdev_priv *np = netdev_priv(netdev);
> +	struct i40e_pf *pf = np->vsi->back;
> +
> +	switch (cmd) {
> +	case SIOCSHWTSTAMP:
> +		return i40e_ptp_hwtstamp_ioctl(pf, ifr, cmd);
> +	default:
> +		return -EOPNOTSUPP;
> +	}
> +}

Please implement SIOCGHWTSTAMP as well.

[...]
> --- /dev/null
> +++ b/drivers/net/ethernet/intel/i40e/i40e_ptp.c
[...]
> +void i40e_ptp_init(struct i40e_pf *pf)
> +{
> +	struct i40e_hw *hw = &pf->hw;
> +	struct net_device *netdev = pf->vsi[pf->lan_vsi]->netdev;
> +
> +	snprintf(pf->ptp_caps.name, 16, "%pm", netdev->dev_addr);
[...]

Use sizeof(), not a magic number.  Also the clock name should perhaps be
the driver name, not the MAC address.

Is the clock shared between multiple PFs or are there independent clocks
for each PF?

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
