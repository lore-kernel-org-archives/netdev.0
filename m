From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 5/5] alx: add stats to ethtool
Date: Thu, 2 Jan 2014 12:01:31 +0000
Message-ID: <1388664091.22017.17.camel@deadeye.wl.decadent.org.uk>
References: <1388619628-3373-1-git-send-email-sd@queasysnail.net>
	 <1388619628-3373-6-git-send-email-sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <johannes@sipsolutions.net>,
	<netdev@vger.kernel.org>
To: Sabrina Dubroca <sd@queasysnail.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:36671 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbaABMBe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jan 2014 07:01:34 -0500
In-Reply-To: <1388619628-3373-6-git-send-email-sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-01-02 at 00:40 +0100, Sabrina Dubroca wrote:
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
>  drivers/net/ethernet/atheros/alx/ethtool.c | 95 ++++++++++++++++++++++++++++++
>  1 file changed, 95 insertions(+)
> 
> diff --git a/drivers/net/ethernet/atheros/alx/ethtool.c b/drivers/net/ethernet/atheros/alx/ethtool.c
> index 45b3650..259056f 100644
> --- a/drivers/net/ethernet/atheros/alx/ethtool.c
> +++ b/drivers/net/ethernet/atheros/alx/ethtool.c
[...]
> +static void alx_get_ethtool_stats(struct net_device *netdev,
> +				  struct ethtool_stats *estats, u64 *data)
> +{
> +	struct alx_priv *alx = netdev_priv(netdev);
> +	struct alx_hw *hw = &alx->hw;
> +
> +	spin_lock(&alx->stats_lock);
> +
> +	__alx_update_hw_stats(hw);
> +	memcpy(data, &hw->stats, sizeof(hw->stats));

This definitely doesn't work if the members of hw->stats are typed as
unsigned long...

> +	spin_unlock(&alx->stats_lock);
> +}
> +
> +static void alx_get_strings(struct net_device *netdev, u32 stringset, u8 *buf)
> +{
> +	switch (stringset) {
> +	case ETH_SS_STATS:
> +		memcpy(buf, &alx_gstrings_stats, sizeof(alx_gstrings_stats));
> +		break;
> +	default:
> +		WARN_ON(1);
> +		break;
> +	}
> +}
> +
> +static int alx_get_sset_count(struct net_device *netdev, int sset)
> +{
> +	switch (sset) {
> +	case ETH_SS_STATS:
> +		return ALX_NUM_STATS;
> +	default:
> +		return -ENOTSUPP;
[...]

Never return error code ENOTSUPP; it's *not* the same thing as ENOTSUP
in userland and is not part of the userland ABI.  I would use EINVAL
here.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
