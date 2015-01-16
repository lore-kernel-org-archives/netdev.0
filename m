From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net 1/2] sh_eth: Fix promiscuous mode on chips without
 TSU
Date: Fri, 16 Jan 2015 22:27:57 +0300
Message-ID: <54B9663D.2040008@cogentembedded.com>
References: <1421430592.1222.190.camel@xylophone.i.decadent.org.uk> <1421430672.1222.191.camel@xylophone.i.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Hisashi Nakamura <hisashi.nakamura.ak@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>
To: Ben Hutchings <ben.hutchings@codethink.co.uk>,
	ct178-internal@lists.codethink.co.uk,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f46.google.com ([209.85.215.46]:64658 "EHLO
	mail-la0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756128AbbAPT2C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jan 2015 14:28:02 -0500
Received: by mail-la0-f46.google.com with SMTP id ge10so10828044lab.5
        for <netdev@vger.kernel.org>; Fri, 16 Jan 2015 11:28:00 -0800 (PST)
In-Reply-To: <1421430672.1222.191.camel@xylophone.i.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 01/16/2015 08:51 PM, Ben Hutchings wrote:

> Currently net_device_ops::set_rx_mode is only implemented for
> chips with a TSU (multiple address table).  However we do need
> to turn the PRM (promiscuous) flag on and off for other chips.

> - Remove the unlikely() from the TSU functions that we may safely
>    call for chips without a TSU

    This is just optimization, worth pushing thru net-next instead.

> - Make setting of the MCT flag conditional on the tsu capability flag
> - Rename sh_eth_set_multicast_list() to sh_eth_set_rx_mode() and plumb
>    it into both net_device_ops structures
> - Remove the previously-unreachable branch in sh_eth_rx_mode() that
>    would otherwise reset the flags to defaults for non-TSU chips

    It couldn't be default for non-TSU chips, they don't seem to have 
ECMR.MCT. So it was just wrong.

    It would have been better if you did one thing per patch or at least 
didn't mix fixes with clean-ups...

> Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> ---
>   drivers/net/ethernet/renesas/sh_eth.c |   18 +++++++++---------
>   1 file changed, 9 insertions(+), 9 deletions(-)

> diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> index 167737f..0c4d5b5 100644
> --- a/drivers/net/ethernet/renesas/sh_eth.c
> +++ b/drivers/net/ethernet/renesas/sh_eth.c
> @@ -2417,7 +2417,7 @@ static int sh_eth_tsu_purge_all(struct net_device *ndev)
>   	struct sh_eth_private *mdp = netdev_priv(ndev);
>   	int i, ret;
>
> -	if (unlikely(!mdp->cd->tsu))
> +	if (!mdp->cd->tsu)
>   		return 0;
>
>   	for (i = 0; i < SH_ETH_TSU_CAM_ENTRIES; i++) {
> @@ -2440,7 +2440,7 @@ static void sh_eth_tsu_purge_mcast(struct net_device *ndev)
>   	void *reg_offset = sh_eth_tsu_get_offset(mdp, TSU_ADRH0);
>   	int i;
>
> -	if (unlikely(!mdp->cd->tsu))
> +	if (!mdp->cd->tsu)

    But we don't call this function on non-TSU SoCs, do we?

[...]

> @@ -2462,7 +2462,9 @@ static void sh_eth_set_multicast_list(struct net_device *ndev)
>   	/* Initial condition is MCT = 1, PRM = 0.
>   	 * Depending on ndev->flags, set PRM or clear MCT
>   	 */
> -	ecmr_bits = (sh_eth_read(ndev, ECMR) & ~ECMR_PRM) | ECMR_MCT;
> +	ecmr_bits = sh_eth_read(ndev, ECMR) & ~ECMR_PRM;
> +	if (mdp->cd->tsu)
> +		ecmr_bits |= ECMR_MCT;

    Seems OK, looking at the RZ/A1H manuals (this SoC does have TSU and this 
bit too).

[...]

WBR, Sergei
