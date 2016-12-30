From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [net-next 12/21] ixgbevf: fix AER error handling
Date: Fri, 30 Dec 2016 13:38:46 +0300
Message-ID: <031ca6a8-a720-0e50-f16e-f02029e98547@cogentembedded.com>
References: <20161230093341.14674-1-jeffrey.t.kirsher@intel.com>
 <20161230093341.14674-13-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Emil Tantilov <emil.s.tantilov@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com,
        guru.anbalagane@oracle.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f51.google.com ([209.85.215.51]:36694 "EHLO
        mail-lf0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753541AbcL3Kit (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Dec 2016 05:38:49 -0500
Received: by mail-lf0-f51.google.com with SMTP id t196so235296570lff.3
        for <netdev@vger.kernel.org>; Fri, 30 Dec 2016 02:38:48 -0800 (PST)
In-Reply-To: <20161230093341.14674-13-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 12/30/2016 12:33 PM, Jeff Kirsher wrote:

> From: Emil Tantilov <emil.s.tantilov@intel.com>
>
> Make sure that we free the IRQs in ixgbevf_io_error_detected() when
> responding to an PCIe AER error and also restore them when the
> interface recovers from it.
>
> Previously it was possible to trigger BUG_ON() check in free_msix_irqs()
> in the case where we call ixgbevf_remove() after a failed recovery from
> AER error because the interrupts were not freed.
>
> Also moved the down and free functions into ixgbevf_close_suspend()
> same as with ixgbe.
>
> Signed-off-by: Emil Tantilov <emil.s.tantilov@intel.com>
> Tested-by: Andrew Bowers <andrewx.bowers@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c | 43 +++++++++++++----------
>  1 file changed, 25 insertions(+), 18 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> index 8574f21..7dfd1df 100644
> --- a/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> +++ b/drivers/net/ethernet/intel/ixgbevf/ixgbevf_main.c
> @@ -3228,6 +3228,21 @@ int ixgbevf_open(struct net_device *netdev)
>  }
>
>  /**
> + * ixgbevf_close_suspend - actions necessary to both suspend and close flows
> + * @adapter: the private adapter struct
> + *
> + * This function should contain the necessary work common to both suspending
> + * and closing of the device.
> + */
> +static void ixgbevf_close_suspend(struct ixgbevf_adapter *adapter)
> +{
> +		ixgbevf_down(adapter);
> +		ixgbevf_free_irq(adapter);
> +		ixgbevf_free_all_tx_resources(adapter);
> +		ixgbevf_free_all_rx_resources(adapter);

    Hum, why 2 tabs?

> +}
> +
> +/**
>   * ixgbevf_close - Disables a network interface
>   * @netdev: network interface device structure
>   *
[...]

MBR, Sergei
