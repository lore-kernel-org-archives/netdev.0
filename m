From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2 net-next] phy: fix the use of PHY_IGNORE_INTERRUPT
Date: Thu, 16 May 2013 15:05:46 -0700 (PDT)
Message-ID: <20130516.150546.1380610594436313255.davem@davemloft.net>
References: <1368727496-25638-1-git-send-email-f.fainelli@gmail.com>
	<1368727496-25638-2-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jogo@openwrt.org,
	thomas.petazzoni@free-electrons.com, afleming@freescale.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55788 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753473Ab3EPWFr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 May 2013 18:05:47 -0400
In-Reply-To: <1368727496-25638-2-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Florian Fainelli" <f.fainelli@gmail.com>
Date: Thu, 16 May 2013 18:04:55 +0000

> When a PHY device is registered with the special IRQ value
> PHY_IGNORE_INTERRUPT (-2) it will not properly be handled by the PHY
> library:
> 
> - it continues to poll its register, while we do not want this
>   because such PHY link events or register changes are serviced by an
>   Ethernet MAC interrupt line
> - it will still try to configure PHY interrupts at the PHY level, such
>   interrupts do not exist at the PHY but at the MAC level
> - the state machine only handles PHY_POLL, but should also handle
>   PHY_IGNORE_INTERRUPT similarly
> 
> This patch updates the PHY state machine and initialization paths to
> account for the specific PHY_IGNORE_INTERRUPT. Based on an earlier patch
> by Thomas Petazzoni, and reworked to add the missing bits.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>  drivers/net/phy/phy.c        | 6 +++---
>  drivers/net/phy/phy_device.c | 5 +++--
>  2 files changed, 6 insertions(+), 5 deletions(-)
> 
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index c14f147..2de4290 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -682,7 +682,7 @@ void phy_stop(struct phy_device *phydev)
>  	if (PHY_HALTED == phydev->state)
>  		goto out_unlock;
>  
> -	if (phydev->irq != PHY_POLL) {
> +	if (phydev->irq >= 0) {

This test, as well as the other two you changed in this file, have
a meaning.  But negative vs. non-negative does not convey what that
meaning actually is.

Add a helper function that says what this is testing, and I would add
a comment to that function referencing all of the special PHY_* values
that are relevant to the test.

> +	/* Disable the interrupt if the PHY doesn't support it
> +	 * but the interrupt is still a valid one */

Multi-line comments in the networking should be formatted:

	/* Like
	 * this.
	 */

Please fix this stuff up and resubmit the entire series, thanks.
