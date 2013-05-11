From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH] igb: add a method to get the nic hw time stamping policy
Date: Sat, 11 May 2013 20:51:47 +0400
Message-ID: <518E7723.5010003@cogentembedded.com>
References: <20130511140219.GG8399@zhudong.nay.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Bruce Allan <bruce.w.allan@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	Greg Rose <gregory.v.rose@intel.com>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>,
	Alex Duyck <alexander.h.duyck@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Tushar Dave <tushar.n.dave@intel.com>,
	Matthew Vick <matthew.vick@intel.com>,
	Jacob Keller <Jacob.e.keller@intel.com>,
	Richard Cochran <richardcochran@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	David Howells <dhowells@redhat.com>,
	Dave Jones <davej@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org
To: Dong Zhu <bluezhudong@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130511140219.GG8399@zhudong.nay.redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11-05-2013 18:02, Dong Zhu wrote:

>  From e6a55411486de8a09b859e73140bf35c0ee36047 Mon Sep 17 00:00:00 2001
> From: Dong Zhu <bluezhudong@gmail.com>
> Date: Sat, 11 May 2013 21:44:54 +0800
> Subject: [PATCH] igb: add a method to get the nic hw time stamping policy

    Please, don't send this header with your patches.

> Currently kernel only support setting the hw time stamping policy
> through ioctl,now add a method to check which packets(Outgoing and
> Incoming) are time stamped by nic.

> Signed-off-by: Dong Zhu <bluezhudong@gmail.com>
> ---
>   drivers/net/ethernet/intel/igb/igb_ptp.c | 29 +++++++++++++++++++++++++++++
>   include/uapi/linux/net_tstamp.h          |  4 +++-
>   2 files changed, 32 insertions(+), 1 deletion(-)

> diff --git a/drivers/net/ethernet/intel/igb/igb_ptp.c b/drivers/net/ethernet/intel/igb/igb_ptp.c
> index 7e8c477..8c06346 100644
> --- a/drivers/net/ethernet/intel/igb/igb_ptp.c
> +++ b/drivers/net/ethernet/intel/igb/igb_ptp.c
> @@ -577,6 +577,34 @@ int igb_ptp_hwtstamp_ioctl(struct net_device *netdev,
>   	if (config.flags)
>   		return -EINVAL;
>
> +	if (config.rw == 0)
> +		goto set_policy;
> +	else if (config.rw == 1) {

    Both arms of the *if* statement should have {} if one does, 
according to Documentation/CodingStyle.

> +		if (config.tx_type || config.rx_filter)
> +			return -EINVAL;
> +
> +		regval = rd32(E1000_TSYNCTXCTL);
> +

    Empty line not needed here.

> +		if (regval & E1000_TSYNCTXCTL_ENABLED)
> +			config.tx_type = HWTSTAMP_TX_ON;
> +		else
> +			config.tx_type = HWTSTAMP_TX_OFF;
> +
> +		regval = rd32(E1000_TSYNCRXCTL);
> +

    ... and here.

> +		if (!(regval & E1000_TSYNCRXCTL_ENABLED))
> +			config.rx_filter = HWTSTAMP_FILTER_NONE;
> +		else if (E1000_TSYNCRXCTL_TYPE_ALL ==
> +				(regval & E1000_TSYNCRXCTL_TYPE_MASK))
> +			config.rx_filter = HWTSTAMP_FILTER_ALL;
> +		else
> +			return -ERANGE;
> +
> +		goto end;
> +	} else
> +		return -EINVAL;

    Same comment about missing {}. This *if*, however, asks to be 
converted to *switch*...

> diff --git a/include/uapi/linux/net_tstamp.h b/include/uapi/linux/net_tstamp.h
> index ae5df12..77147da 100644
> --- a/include/uapi/linux/net_tstamp.h
> +++ b/include/uapi/linux/net_tstamp.h
> @@ -28,9 +28,10 @@ enum {
>   /**
>    * struct hwtstamp_config - %SIOCSHWTSTAMP parameter
>    *
> + * @rw:        0/1 represents set/get the hw time stamp policy
>    * @flags:	no flags defined right now, must be zero
>    * @tx_type:	one of HWTSTAMP_TX_*
> - * @rx_type:	one of one of HWTSTAMP_FILTER_*
> + * @rx_filter:	one of one of HWTSTAMP_FILTER_*

    You don't mention this change in the changelog. Most probably it 
should be in a separate patch.

> @@ -39,6 +40,7 @@ enum {
>   * 32 and 64 bit systems, don't break this!
>   */
>  struct hwtstamp_config {
> +	int rw;

    Why not 'bool'?

WBR, Sergei
