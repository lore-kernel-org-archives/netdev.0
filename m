From: Romain Perier <romain.perier@gmail.com>
Subject: Re: [PATCH] stmmac: Don't exit mdio registration when mdio subnode is
 not found in the DTS
Date: Sat, 2 Jan 2016 16:11:18 +0100
Message-ID: <CABgxDoLNWEtYtRTrYhp7T=tk3n-aPMCgOP2SL7+DoxFqTk7GuQ@mail.gmail.com>
References: <1451397935-23643-1-git-send-email-romain.perier@gmail.com>
	<0E6F98A1-B9F1-48B0-B5CA-A215803E827F@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: peppe.cavallaro@st.com, netdev <netdev@vger.kernel.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:35160 "EHLO
	mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751413AbcABPLT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2016 10:11:19 -0500
Received: by mail-lf0-f45.google.com with SMTP id c192so80322366lfe.2
        for <netdev@vger.kernel.org>; Sat, 02 Jan 2016 07:11:19 -0800 (PST)
In-Reply-To: <0E6F98A1-B9F1-48B0-B5CA-A215803E827F@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

2016-01-02 6:51 GMT+01:00 Florian Fainelli <f.fainelli@gmail.com>:
> On December 29, 2015 6:05:35 AM PST, Romain Perier <romain.perier@gmail.com> wrote:
>>Originally, most of the platforms using this driver did not define an
>>mdio subnode
>>in the devicetree. Commit e34d65 ("stmmac: create of compatible mdio
>>bus for stmmac driver")
>>introduced a backward compatibily issue by using of_mdiobus_register
>>explicitly
>>with an mdio subnode. This patch fixes the issue by calling the
>>function
>>mdiobus_register, when mdio subnode is not found. The driver is now
>>compatible
>>with both modes.
>
> Looks reasonable to me, though you will want to make sure the different DTSes get updated to include the proper compatible node for the MDIO bus.
>
>>
>>Signed-off-by: Romain Perier <romain.perier@gmail.com>
>
> Please include a Fixes tag to help keep track of changes.

Sure, sorry for my ignorance, but I did not know that we're supposed
to add a Fixes tag in this situation.

>
>>---
>> drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c | 8 +++++---
>> 1 file changed, 5 insertions(+), 3 deletions(-)
>>
>>diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>index 16c85cc..0034de44 100644
>>--- a/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>+++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c
>>@@ -218,8 +218,7 @@ int stmmac_mdio_register(struct net_device *ndev)
>>               if (mdio_node) {
>>                       netdev_dbg(ndev, "FOUND MDIO subnode\n");
>>               } else {
>>-                      netdev_err(ndev, "NO MDIO subnode\n");
>>-                      return 0;
>>+                      netdev_warn(ndev, "No MDIO subnode found\n");
>>               }
>>       }
>>
>>@@ -251,7 +250,10 @@ int stmmac_mdio_register(struct net_device *ndev)
>>       new_bus->phy_mask = mdio_bus_data->phy_mask;
>>       new_bus->parent = priv->device;
>>
>>-      err = of_mdiobus_register(new_bus, mdio_node);
>>+      if (IS_ENABLED(CONFIG_OF) && mdio_node)
>

> You should be able to drop the IS_ENABLED part since there is an inline provided in the non-OF case which does a fallback to mdiobus_register().

Good point

>
>>+              err = of_mdiobus_register(new_bus, mdio_node);
>>+      else
>>+              err = mdiobus_register(new_bus);
>>       if (err != 0) {
>
> This looks reasonable, does it work if we just assign mdio_node to the pdev->dev.of_node to be backwards compatible with DTSes which have not yet been updated?
>

I don't understand what you mean. Instead of defining mdio_node with
NULL, you propose to assign it to pdev->dev.of_node as its default
value... then it would be reassigned with "child_nod" if a subnode
with the compatible string "snps,dwmac-mdio" is found, or kept with
its default value otherwise... and in this case we could call
of_mdiobus_register(new_bus, mdio_node) all the time ? (it removes the
conditonnal branch)

Regards,
Romain
