From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: trivial: fix fsl fec_main mdio write return value
Date: Mon, 26 Sep 2016 18:00:32 -0300
Message-ID: <CAOMZO5BikGA9e6goMs0wqNVHvWW9Mf3SpykA=DWfD4Q2gBbkag@mail.gmail.com>
References: <20160926191140.12107-1-albert.aribaud@3adev.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Jiri Kosina <trivial@kernel.org>,
        Fugang Duan <fugang.duan@nxp.com>
To: "Albert ARIBAUD (3ADEV)" <albert.aribaud@3adev.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f67.google.com ([209.85.213.67]:35417 "EHLO
        mail-vk0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034924AbcIZVAf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 17:00:35 -0400
Received: by mail-vk0-f67.google.com with SMTP id 192so3452960vkl.2
        for <netdev@vger.kernel.org>; Mon, 26 Sep 2016 14:00:33 -0700 (PDT)
In-Reply-To: <20160926191140.12107-1-albert.aribaud@3adev.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Albert,

On Mon, Sep 26, 2016 at 4:11 PM, Albert ARIBAUD (3ADEV)
<albert.aribaud@3adev.fr> wrote:
> If the MDIO enf-of-transfer wait loop does not time out,
> 0 should be returned to the caller through ret, but ret
> was not reset to 0 after receiving the return value of
> pm_runtime_get_sync(). Reset ret when no time out occurred.Is this really needed?

Commit 42ea4457 ("net: fec: normalize return value of
pm_runtime_get_sync() in MDIO write") does the following:

diff --git a/drivers/net/ethernet/freescale/fec_main.c
b/drivers/net/ethernet/freescale/fec_main.c
index 91925e3..6cc3340 100644
--- a/drivers/net/ethernet/freescale/fec_main.c
+++ b/drivers/net/ethernet/freescale/fec_main.c
@@ -1816,11 +1816,13 @@ static int fec_enet_mdio_write(struct mii_bus
*bus, int mii_id, int regnum,
        struct fec_enet_private *fep = bus->priv;
        struct device *dev = &fep->pdev->dev;
        unsigned long time_left;
-       int ret = 0;
+       int ret;

        ret = pm_runtime_get_sync(dev);
        if (ret < 0)
                return ret;
+       else
+               ret = 0;

> diff --git a/drivers/net/ethernet/freescale/fec_main.c b/drivers/net/ethernet/freescale/fec_main.c
> index 01f7e81..0413c05 100644
> --- a/drivers/net/ethernet/freescale/fec_main.c
> +++ b/drivers/net/ethernet/freescale/fec_main.c
> @@ -1818,6 +1818,8 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
>                 netdev_err(fep->netdev, "MDIO write timeout\n");
>                 ret  = -ETIMEDOUT;
>         }
> +       else
> +               ret = 0;

, so is this really needed? ret should be 0 at this point.
