From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 14/23] e1000: handle manageability for pci-e adapters
 at PHY powerdown
Date: Tue, 19 Sep 2006 15:39:08 -0400
Message-ID: <4510475C.3080006@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172904.4605.26861.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:17340 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751053AbWISTjL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:39:11 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060919172904.4605.26861.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> When powering down the PHY (if WoL is disabled) we should only check
> copper PHY's and handle PCI-E adapters differently.
> 
> Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_main.c |   41 +++++++++++++++++++++++++++++++---------
>  1 files changed, 32 insertions(+), 9 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
> index 09f6662..9c41a44 100644
> --- a/drivers/net/e1000/e1000_main.c
> +++ b/drivers/net/e1000/e1000_main.c
> @@ -512,25 +512,48 @@ void e1000_power_up_phy(struct e1000_ada
>  
>  static void e1000_power_down_phy(struct e1000_adapter *adapter)
>  {
> -	boolean_t mng_mode_enabled = (adapter->hw.mac_type >= e1000_82571) &&
> -	                              e1000_check_mng_mode(&adapter->hw);
> -	/* Power down the PHY so no link is implied when interface is down
> -	 * The PHY cannot be powered down if any of the following is TRUE
> +	/* Power down the PHY so no link is implied when interface is down *
> +	 * The PHY cannot be powered down if any of the following is TRUE *
>  	 * (a) WoL is enabled
>  	 * (b) AMT is active
>  	 * (c) SoL/IDER session is active */
>  	if (!adapter->wol && adapter->hw.mac_type >= e1000_82540 &&
> -	    adapter->hw.mac_type != e1000_ich8lan &&
> -	    adapter->hw.media_type == e1000_media_type_copper &&
> -	    !(E1000_READ_REG(&adapter->hw, MANC) & E1000_MANC_SMBUS_EN) &&
> -	    !mng_mode_enabled &&
> -	    !e1000_check_phy_reset_block(&adapter->hw)) {
> +	   adapter->hw.media_type == e1000_media_type_copper) {
>  		uint16_t mii_reg = 0;
> +
> +		switch (adapter->hw.mac_type) {
> +		case e1000_82540:
> +		case e1000_82545:
> +		case e1000_82545_rev_3:
> +		case e1000_82546:
> +		case e1000_82546_rev_3:
> +		case e1000_82541:
> +		case e1000_82541_rev_2:
> +		case e1000_82547:
> +		case e1000_82547_rev_2:
> +			if (E1000_READ_REG(&adapter->hw, MANC) &
> +			    E1000_MANC_SMBUS_EN)
> +				goto out;
> +			break;
> +		case e1000_82571:
> +		case e1000_82572:
> +		case e1000_82573:
> +		case e1000_80003es2lan:
> +		case e1000_ich8lan:
> +			if (e1000_check_mng_mode(&adapter->hw) ||
> +			    e1000_check_phy_reset_block(&adapter->hw))
> +				goto out;
> +			break;
> +		default:
> +			goto out;
> +		}
>  		e1000_read_phy_reg(&adapter->hw, PHY_CTRL, &mii_reg);
>  		mii_reg |= MII_CR_POWER_DOWN;
>  		e1000_write_phy_reg(&adapter->hw, PHY_CTRL, mii_reg);
>  		mdelay(1);

NAK.  another obvious case where you should be testing a single feature 
bit, rather than adding a huge switch statement.


