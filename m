From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCHv3 3/7] ethtool: Use the full 32 bit speed range in
 ethtool's set_settings
Date: Thu, 28 Apr 2011 03:10:50 +0100
Message-ID: <1303956650.3032.426.camel@localhost>
References: <1303954043-17440-1-git-send-email-decot@google.com>
	 <1303954043-17440-4-git-send-email-decot@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, mirq-linux@rere.qmqm.pl,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	Grant Grundler <grundler@parisc-linux.org>,
	e1000-devel@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Decotigny <decot@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1303954043-17440-4-git-send-email-decot@google.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2011-04-27 at 18:27 -0700, David Decotigny wrote:
> This makes sure the ethtool's set_settings() callback of network
> drivers don't ignore the 16 most significant bits when ethtool calls
> their set_settings().
> 
> All drivers compiled with make allyesconfig on x86_64 have been
> updated.
> 
> Tested: make allyesconfig compiles + e1000e and bnx2x work
> Signed-off-by: David Decotigny <decot@google.com>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

*But* this and patch 4 should be applied in the opposite order, so that
this doesn't break:

[...]
> diff --git a/drivers/net/pch_gbe/pch_gbe_ethtool.c b/drivers/net/pch_gbe/pch_gbe_ethtool.c
> index c35d105..21a2a04 100644
> --- a/drivers/net/pch_gbe/pch_gbe_ethtool.c
> +++ b/drivers/net/pch_gbe/pch_gbe_ethtool.c
> @@ -109,12 +109,15 @@ static int pch_gbe_set_settings(struct net_device *netdev,
>  {
>  	struct pch_gbe_adapter *adapter = netdev_priv(netdev);
>  	struct pch_gbe_hw *hw = &adapter->hw;
> +	u32 speed = ethtool_cmd_speed(ecmd);
>  	int ret;
>  
>  	pch_gbe_hal_write_phy_reg(hw, MII_BMCR, BMCR_RESET);
>  
> -	if (ecmd->speed == USHRT_MAX) {
> -		ecmd->speed = SPEED_1000;
> +	/* when set_settings() is called with a ethtool_cmd previously
> +	 * filled by get_settings() on a down link, speed is -1: */
> +	if (speed == UINT_MAX) {
> +		speed = SPEED_1000;
>  		ecmd->duplex = DUPLEX_FULL;
>  	}
>  	ret = mii_ethtool_sset(&adapter->mii, ecmd);
[...]

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
