From: Markus Brunner <systemprogrammierung.brunner@gmail.com>
Subject: Re: [PATCH] drivers: net: cpsw: fix RMII/RGMII mode when used with fixed-link PHY
Date: Sat, 12 Dec 2015 16:44:19 +0100
Message-ID: <6416396.ZOturxhSar@localhost>
References: <20151209223115.6c5a400f.drivshin.allworx@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	linux-omap@vger.kernel.org, David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	Pascal Speck <kernel@iktek.de>,
	Daniel Trautmann <dtrautmann@ibhsoftec-sps.de>
To: "David Rivshin (Allworx)" <drivshin.allworx@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:34138 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751185AbbLLPqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Dec 2015 10:46:15 -0500
In-Reply-To: <20151209223115.6c5a400f.drivshin.allworx@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 09 December 2015 22:31:15 David Rivshin wrote:
...
> This patch was originally developed in parallel with 1f71e8c96fc6 to
> accomplish the same goal. When I replaced this patch with 1f71e8c96fc6,
> I found that it did not work on my hardware (which uses RGMII), so I
> am submitting this patch now as a bugfix. 

Your patch works fine on my board, which uses MII and dual_emac with a fixed_phy and a real one. 

> Besides fixing the bug mentioned in the commit log, there are a few other
> differences to note:
>  * If both "phy_id" and a "fixed-link" subnode are present this patch will
>    use the "phy_id" property. This should preserve current behavior with
>    existing devicetrees that might incorrectly have both. This motivates
>    the biggest difference in code organization from 1f71e8c96fc6.
>  * Some error messages have been tweaked to reflect the slightly changed
>    meanings of the checks.

I wanted to keep changes small and didn't spend too much thinking about already broken devicetrees. 
Since my patch is quite new, I don't see any problems with subtle changes like that. However you should update the documentation as well. 

>  * of_node_get() is called on slave_node before passing the result to
>    of_phy_find_device(). This increments the reference count, which I
>    believe is correct for this situation, but I'm not certain of that.
I think you are right. At least most other drivers calling of_phy_register_fixed_link(), call of_node_get afterwards. 
I can't remember where I got my "inspiration" for the patch. I made it almost a year ago and now 3 other guys tinker with the same feature? What a coincidence ;-)

>  * Uses the phy_device's 'addr' instead of 'phy_id' field when constructing
>    slave_data->phy_id. Pascal Speck separately came to the same conclusion
>    in another patch [1].
Clearly an improvement.
>  * [2] pointed out that the 'lenp' sanity check was wrong, and since this
>    patch re-arranged that check anyways I incorporated that fix as well.
> Although the last three items could be fixed separately, it seemed like that
> would be unnecessary churn since those same lines were already touched in
> this patch. Let me know if its preferred to fix them separately.
> 
> This patch is also very similar to one Daniel Trautmann submitted [3], with
> the biggest difference being that Daniel's patch uses the new priv->phy_node
> field and of_node_get(). While this seems like a better path overall it
> does not work if more than once CPSW slave is used, due to struct cpsw_priv
> being shared with all the slaves. I am under the impression that phy_node
> should really be in struct cpsw_slave instead, but I will leave that for
> another patch.
A lot of people will need both slaves.
...
> (Side note: This is my first patch submission, and any feedback on things
> to do differently in the future would be appreciated.)

> 
>  drivers/net/ethernet/ti/cpsw.c | 65
> +++++++++++++++++++++++++----------------- 1 file changed, 39
> insertions(+), 26 deletions(-)
> 
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 48b92c9..ba8d086 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -26,6 +26,7 @@
>  #include <linux/netdevice.h>
>  #include <linux/net_tstamp.h>
>  #include <linux/phy.h>
> +#include <linux/phy_fixed.h>

The prototypes for of_*_fixed_link are in linux/of_mdio.h, which is already included.
