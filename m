From: "Neftin, Sasha" <sasha.neftin@intel.com>
Subject: Re: [Intel-wired-lan] [PATCH] e1000e: apply burst mode settings only
 on default
Date: Sun, 27 Aug 2017 11:30:58 +0300
Message-ID: <291b863f-552e-2f3b-f658-e812d0848949@intel.com>
References: <20170825150626.2843-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Willem de Bruijn <willemb@google.com>,
        intel-wired-lan@lists.osuosl.org
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        "jeffrey.t.kirsher@intel.com; alexander.h.duyck@intel.com; raanan.avargil@intel.com; dima.ruinskiy"@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:48507 "EHLO mga14.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750797AbdH0IbB (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 27 Aug 2017 04:31:01 -0400
In-Reply-To: <20170825150626.2843-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/2017 18:06, Willem de Bruijn wrote:
> From: Willem de Bruijn <willemb@google.com>
>
> Devices that support FLAG2_DMA_BURST have different default values
> for RDTR and RADV. Apply burst mode default settings only when no
> explicit value was passed at module load.
>
> The RDTR default is zero. If the module is loaded for low latency
> operation with RxIntDelay=0, do not override this value with a burst
> default of 32.
>
> Move the decision to apply burst values earlier, where explicitly
> initialized module variables can be distinguished from defaults.
>
> Signed-off-by: Willem de Bruijn <willemb@google.com>
> ---
>   drivers/net/ethernet/intel/e1000e/e1000.h  |  4 ----
>   drivers/net/ethernet/intel/e1000e/netdev.c |  8 --------
>   drivers/net/ethernet/intel/e1000e/param.c  | 16 +++++++++++++++-
>   3 files changed, 15 insertions(+), 13 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/e1000e/e1000.h b/drivers/net/ethernet/intel/e1000e/e1000.h
> index 98e68888abb1..2311b31bdcac 100644
> --- a/drivers/net/ethernet/intel/e1000e/e1000.h
> +++ b/drivers/net/ethernet/intel/e1000e/e1000.h
> @@ -94,10 +94,6 @@ struct e1000_info;
>    */
>   #define E1000_CHECK_RESET_COUNT		25
>   
> -#define DEFAULT_RDTR			0
> -#define DEFAULT_RADV			8
> -#define BURST_RDTR			0x20
> -#define BURST_RADV			0x20
>   #define PCICFG_DESC_RING_STATUS		0xe4
>   #define FLUSH_DESC_REQUIRED		0x100
>   
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 327dfe5bedc0..47b89aac7969 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -3223,14 +3223,6 @@ static void e1000_configure_rx(struct e1000_adapter *adapter)
>   		 */
>   		ew32(RXDCTL(0), E1000_RXDCTL_DMA_BURST_ENABLE);
>   		ew32(RXDCTL(1), E1000_RXDCTL_DMA_BURST_ENABLE);
> -
> -		/* override the delay timers for enabling bursting, only if
> -		 * the value was not set by the user via module options
> -		 */
> -		if (adapter->rx_int_delay == DEFAULT_RDTR)
> -			adapter->rx_int_delay = BURST_RDTR;
> -		if (adapter->rx_abs_int_delay == DEFAULT_RADV)
> -			adapter->rx_abs_int_delay = BURST_RADV;
>   	}
>   
>   	/* set the Receive Delay Timer Register */
> diff --git a/drivers/net/ethernet/intel/e1000e/param.c b/drivers/net/ethernet/intel/e1000e/param.c
> index 6d8c39abee16..bb696c98f9b0 100644
> --- a/drivers/net/ethernet/intel/e1000e/param.c
> +++ b/drivers/net/ethernet/intel/e1000e/param.c
> @@ -73,17 +73,25 @@ E1000_PARAM(TxAbsIntDelay, "Transmit Absolute Interrupt Delay");
>   /* Receive Interrupt Delay in units of 1.024 microseconds
>    * hardware will likely hang if you set this to anything but zero.
>    *
> + * Burst variant is used as default if device has FLAG2_DMA_BURST.
> + *
>    * Valid Range: 0-65535
>    */
>   E1000_PARAM(RxIntDelay, "Receive Interrupt Delay");
> +#define DEFAULT_RDTR			0
> +#define BURST_RDTR			0x20
>   #define MAX_RXDELAY 0xFFFF
>   #define MIN_RXDELAY 0
>   
>   /* Receive Absolute Interrupt Delay in units of 1.024 microseconds
> + *
> + * Burst variant is used as default if device has FLAG2_DMA_BURST.
>    *
>    * Valid Range: 0-65535
>    */
>   E1000_PARAM(RxAbsIntDelay, "Receive Absolute Interrupt Delay");
> +#define DEFAULT_RADV			8
> +#define BURST_RADV			0x20
>   #define MAX_RXABSDELAY 0xFFFF
>   #define MIN_RXABSDELAY 0
>   
> @@ -297,6 +305,9 @@ void e1000e_check_options(struct e1000_adapter *adapter)
>   					 .max = MAX_RXDELAY } }
>   		};
>   
> +		if (adapter->flags2 & FLAG2_DMA_BURST)
> +			opt.def = BURST_RDTR;
> +
>   		if (num_RxIntDelay > bd) {
>   			adapter->rx_int_delay = RxIntDelay[bd];
>   			e1000_validate_option(&adapter->rx_int_delay, &opt,
> @@ -307,7 +318,7 @@ void e1000e_check_options(struct e1000_adapter *adapter)
>   	}
>   	/* Receive Absolute Interrupt Delay */
>   	{
> -		static const struct e1000_option opt = {
> +		static struct e1000_option opt = {
>   			.type = range_option,
>   			.name = "Receive Absolute Interrupt Delay",
>   			.err  = "using default of "
> @@ -317,6 +328,9 @@ void e1000e_check_options(struct e1000_adapter *adapter)
>   					 .max = MAX_RXABSDELAY } }
>   		};
>   
> +		if (adapter->flags2 & FLAG2_DMA_BURST)
> +			opt.def = BURST_RADV;
> +
>   		if (num_RxAbsIntDelay > bd) {
>   			adapter->rx_abs_int_delay = RxAbsIntDelay[bd];
>   			e1000_validate_option(&adapter->rx_abs_int_delay, &opt,

This patch looks good for me, but I would like hear second opinion.
