From: Johan Hovold <johan@kernel.org>
Subject: Re: [PATCH] net: qcom/emac: grab a reference to the phydev on ACPI
 systems
Date: Tue, 10 Jan 2017 09:45:27 +0100
Message-ID: <20170110084527.GB3501@localhost>
References: <1484005926-26673-1-git-send-email-timur@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, johan@kernel.org,
        netdev@vger.kernel.org
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:35808 "EHLO
        mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1760214AbdAJIpa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Jan 2017 03:45:30 -0500
Received: by mail-lf0-f65.google.com with SMTP id v186so7852933lfa.2
        for <netdev@vger.kernel.org>; Tue, 10 Jan 2017 00:45:30 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1484005926-26673-1-git-send-email-timur@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 09, 2017 at 05:52:06PM -0600, Timur Tabi wrote:
> Commit 6ffe1c4cd0a7 ("net: qcom/emac: fix of_node and phydev leaks")
> fixed the problem with reference leaks on phydev, but the fix is
> device-tree specific.  When the driver unloads, the reference is
> dropped only on DT systems.
> 
> Instead, it's cleaner if up grab an reference on ACPI systems.
> When the driver unloads, we can drop the reference without having
> to check whether we're on a DT system.
> 
> Signed-off-by: Timur Tabi <timur@codeaurora.org>
> ---
>  drivers/net/ethernet/qualcomm/emac/emac-phy.c | 6 ++++++
>  drivers/net/ethernet/qualcomm/emac/emac.c     | 6 ++----
>  2 files changed, 8 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/ethernet/qualcomm/emac/emac-phy.c b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
> index 99a14df..af485f1 100644
> --- a/drivers/net/ethernet/qualcomm/emac/emac-phy.c
> +++ b/drivers/net/ethernet/qualcomm/emac/emac-phy.c
> @@ -201,6 +201,12 @@ int emac_phy_config(struct platform_device *pdev, struct emac_adapter *adpt)
>  		else
>  			adpt->phydev = mdiobus_get_phy(mii_bus, phy_addr);
>  
> +		/* of_phy_find_device() claims a reference to the phydev,
> +		 * so we do that here manually as well. When the driver
> +		 * unloads, it can unilaterally drops the reference
> +		 * without worrying about ACPI vs DT.
> +		 */
> +		get_device(&adpt->phydev->mdio.dev);

But you cannot do this unconditionally as adpt->phydev can be NULL here.

Looks good to me otherwise.

Thanks,
Johan
