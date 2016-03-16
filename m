From: Yegor Yefremov <yegorslists@googlemail.com>
Subject: Re: [PATCH] net: phy: fix PHY_RUNNING in phy_state_machine
Date: Wed, 16 Mar 2016 16:59:23 +0100
Message-ID: <CAGm1_kufFr0SsVwVcABXkL0ABJahiwz4EZ70=ywrtC9Bffbfng@mail.gmail.com>
References: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Shaohui Xie <Shaohui.Xie@freescale.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	"N, Mugunthan V" <mugunthanvnm@ti.com>, drivshin@allworx.com
To: shh.xie@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f42.google.com ([209.85.213.42]:35898 "EHLO
	mail-vk0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751911AbcCPP7o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Mar 2016 11:59:44 -0400
Received: by mail-vk0-f42.google.com with SMTP id c3so67374636vkb.3
        for <netdev@vger.kernel.org>; Wed, 16 Mar 2016 08:59:43 -0700 (PDT)
In-Reply-To: <1439526220-31458-1-git-send-email-shh.xie@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2015 at 6:23 AM,  <shh.xie@gmail.com> wrote:
> From: Shaohui Xie <Shaohui.Xie@freescale.com>
>
> Currently, if phy state is PHY_RUNNING, we always register a CHANGE
> when phy works in polling or interrupt ignored, this will make the
> adjust_link being called even the phy link did Not changed.
>
> checking the phy link to make sure the link did changed before we
> register a CHANGE, if link did not changed, we do nothing.
>
> Signed-off-by: Shaohui Xie <Shaohui.Xie@freescale.com>
> ---
>  drivers/net/phy/phy.c | 16 ++++++++++++----
>  1 file changed, 12 insertions(+), 4 deletions(-)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index 84b1fba..d972851 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -814,6 +814,7 @@ void phy_state_machine(struct work_struct *work)
>         bool needs_aneg = false, do_suspend = false;
>         enum phy_state old_state;
>         int err = 0;
> +       int old_link;
>
>         mutex_lock(&phydev->lock);
>
> @@ -899,11 +900,18 @@ void phy_state_machine(struct work_struct *work)
>                 phydev->adjust_link(phydev->attached_dev);
>                 break;
>         case PHY_RUNNING:
> -               /* Only register a CHANGE if we are
> -                * polling or ignoring interrupts
> +               /* Only register a CHANGE if we are polling or ignoring
> +                * interrupts and link changed since latest checking.
>                  */
> -               if (!phy_interrupt_is_valid(phydev))
> -                       phydev->state = PHY_CHANGELINK;
> +               if (!phy_interrupt_is_valid(phydev)) {
> +                       old_link = phydev->link;
> +                       err = phy_read_status(phydev);
> +                       if (err)
> +                               break;
> +
> +                       if (old_link != phydev->link)
> +                               phydev->state = PHY_CHANGELINK;
> +               }
>                 break;
>         case PHY_CHANGELINK:
>                 err = phy_read_status(phydev);

This patch breaks my am335x based board, where one of the CPSW slaves
is connected to IP175D switch chip via RMII interface. Since this
patch packet reception is not working.

Yegor
