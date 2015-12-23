From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/1] ixgbe: force to synchronize reporting "link on" and
 getting speed and duplex
Date: Wed, 23 Dec 2015 15:17:29 +0300
Message-ID: <567A90D9.9040204@cogentembedded.com>
References: <1450853205-27133-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: venkat.viswanathan@windriver.com, Boris.Shteinbock@windriver.com,
	Vincent.Bourg@windriver.com
To: zyjzyj2000@gmail.com, jeffrey.t.kirsher@intel.com,
	jesse.brandeburg@intel.com, shannon.nelson@intel.com,
	carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
	bruce.w.allan@intel.com, john.ronciak@intel.com,
	mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
	netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f172.google.com ([209.85.217.172]:33098 "EHLO
	mail-lb0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752028AbbLWMRe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Dec 2015 07:17:34 -0500
Received: by mail-lb0-f172.google.com with SMTP id sv6so38759668lbb.0
        for <netdev@vger.kernel.org>; Wed, 23 Dec 2015 04:17:33 -0800 (PST)
In-Reply-To: <1450853205-27133-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 12/23/2015 9:46 AM, zyjzyj2000@gmail.com wrote:

> From: Zhu Yanjun <zyjzyj2000@gmail.com>
>
> In X540 NIC, there is a time span between reporting "link on" and
> getting the speed and duplex. To a bonding driver in 802.3ad mode,
> this time span will make it not work well if the time span is big
> enough. The big time span will make bonding driver change the state of
> the slave device to up while the speed and duplex of the slave device
> can not be gotten. Later the bonding driver will not have change to
> get the speed and duplex of the slave device. The speed and duplex of
> the slave device are important to a bonding driver in 802.3ad mode.
>
> To 82599_SFP NIC and other kinds of NICs, this problem does
> not exist. As such, it is necessary for X540 to report"link on" when
> the link speed is not IXGBE_LINK_SPEED_UNKNOWN.
>
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> ---
>   drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |   16 +++++++++++++++-
>   1 file changed, 15 insertions(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index aed8d02..cb9d310 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -6479,7 +6479,21 @@ static void ixgbe_watchdog_link_is_up(struct ixgbe_adapter *adapter)
>   	       (flow_rx ? "RX" :
>   	       (flow_tx ? "TX" : "None"))));
>
> -	netif_carrier_on(netdev);
> +	/*
> +	 * In X540 NIC, there is a time span between reporting "link on"
> +	 * and getting the speed and duplex. To a bonding driver in 802.3ad
> +	 * mode, this time span will make it not work well if the time span
> +	 * is big enough. To 82599_SFP NIC and other kinds of NICs, this
> +	 * problem does not exist. As such, it is better for X540 to report
> +	 * "link on" when the link speed is not IXGBE_LINK_SPEED_UNKNOWN.
> +	 */
> +	if ((hw->mac.type == ixgbe_mac_X540) &&
> +	    (link_speed != IXGBE_LINK_SPEED_UNKNOWN)) {
> +		netif_carrier_on(netdev);
> +	} else {
> +		netif_carrier_on(netdev);
> +	}
> +

    {} not needed here. And you do the same thing regardless of whether your 
check succeeds or not, this doesn't make sense.

[...]

MBR, Sergei
