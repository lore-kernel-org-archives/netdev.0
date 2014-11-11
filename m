From: Javier Martinez Canillas <javier@dowhile0.org>
Subject: Re: [PATCH] smsc911x: power-up phydev before doing a software reset.
Date: Tue, 11 Nov 2014 12:20:38 +0100
Message-ID: <CABxcv==Tf04vFyN975z8TseY2hmY7EKsDrAdAtPzOZ5m0Kg6Ng@mail.gmail.com>
References: <1415643789-5367-1-git-send-email-eballetbo@iseebcn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org,
	Steve Glendinning <steve.glendinning@shawell.net>,
	Enrico Butera <ebutera@gmail.com>
To: Enric Balletbo i Serra <eballetbo@iseebcn.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f172.google.com ([209.85.212.172]:35448 "EHLO
	mail-wi0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752832AbaKKLUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Nov 2014 06:20:39 -0500
Received: by mail-wi0-f172.google.com with SMTP id bs8so1262919wib.17
        for <netdev@vger.kernel.org>; Tue, 11 Nov 2014 03:20:38 -0800 (PST)
In-Reply-To: <1415643789-5367-1-git-send-email-eballetbo@iseebcn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Enric,

On Mon, Nov 10, 2014 at 7:23 PM, Enric Balletbo i Serra
<eballetbo@iseebcn.com> wrote:
> With commit be9dad1f9f26604fb ("net: phy: suspend phydev when going
> to HALTED"), the PHY device will be put in a low-power mode using
> BMCR_PDOWN if the the interface is set down. The smsc911x driver does
> a software_reset opening the device driver (ndo_open). In such case,
> the PHY must be powered-up before access to any register and before
> calling the software_reset function. Otherwise, as the PHY is powered
> down the software reset fails and the interface can not be enabled
> again.
>

The patch looks good to me, I just have a small comment.

> +
> +       /* If the PHY general power-down bit is not set is not necessary to
> +        * disable the general power down-mode.
> +        */
> +       if (rc & BMCR_PDOWN) {
> +               rc = phy_write(pdata->phy_dev, MII_BMCR, rc & ~BMCR_PDOWN);
> +               if (rc < 0) {
> +                       SMSC_WARN(pdata, drv, "Failed writing PHY control reg");
> +                       return rc;
> +               }
> +
> +               mdelay(1);

According to Documentation/timers/timers-howto.txt, the *delay()
family of functions should only be used in atomic context since those
are implemented as a busy-wait loop to achieve the desired delay.

AFAICT smsc911x_soft_reset() is only called from process context so
usleep_range() should be used instead.

Best regards,
Javier
