From: Andy Fleming <afleming@gmail.com>
Subject: Re: [PATCH 2/3] phylib: add support for shared PHY interrupts
Date: Tue, 17 Feb 2009 18:47:34 -0600
Message-ID: <2acbd3e40902171647i327e3a85m25bf7d9bcd8be987@mail.gmail.com>
References: <1234817631-7981-1-git-send-email-agust@denx.de>
	 <1234817631-7981-2-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Anatolij Gustschin <agust@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f222.google.com ([209.85.217.222]:62813 "EHLO
	mail-gx0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751118AbZBRArg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 19:47:36 -0500
Received: by gxk22 with SMTP id 22so4835630gxk.13
        for <netdev@vger.kernel.org>; Tue, 17 Feb 2009 16:47:34 -0800 (PST)
In-Reply-To: <1234817631-7981-2-git-send-email-agust@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 16, 2009 at 2:53 PM, Anatolij Gustschin <agust@denx.de> wrote:
> Marvell 88E1121R PHY device can be hardware-configured
> to use shared interrupt pin for both PHY ports. This
> patch adds support for shared PHY interrupts to the PHY
> framework to enable support for such PHY configurations.

Well, technically the phylib already supports shared interrupts (all
of my systems have only one interrupt for all of the PHYs).  This
patch adds support for some PHYs which can report which device caused
the interrupt.

>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>
> ---
>  drivers/net/phy/phy.c        |   13 +++++++++++++
>  drivers/net/phy/phy_device.c |    2 ++
>  include/linux/phy.h          |    4 ++++
>  3 files changed, 19 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index df4e625..93d387e 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -657,9 +657,17 @@ EXPORT_SYMBOL(phy_stop_interrupts);
>  static void phy_change(struct work_struct *work)
>  {
>        int err;
> +       int src;
>        struct phy_device *phydev =
>                container_of(work, struct phy_device, phy_queue);
>
> +       if (phydev->drv->flags & PHY_INTERRUPTS_SHARED
> +           && phydev->drv->interrupt_src) {
> +               src = phydev->drv->interrupt_src(phydev);
> +               if ((src == -1) || (src != phydev->addr))
> +                       goto ignore;
> +       }
> +


I don't agree with this approach to the problem.  First, it would
appear that phydev->drv->interrupt_src is redundant with
PHY_INTERRUPTS_SHARED.  So we probably don't need to add that bit.
Next, the result of interrupt_src isn't being used to do anything but
determine whether *this* PHY originated the interrupt.  So a minor
improvement would be to have a function ->did_interrupt(), which
returns 1 if the PHY generated an interrupt, and 0 otherwise.

For solving this problem, I'd prefer a solution that didn't appear to
be so closely tied to the specific hardware you are using.  The
->did_interrupt() method would allow any PHY with interrupts to report
whether it believes it created the interrupt.  It seems to me that
this is just creating more overhead, though.  There may be a way to
consolidate the various interrupt-related functions, and create a new
set which allows for this sort of "early-out".

Another possibility to consider is some way that each "global" device
could only read this register once per interrupt, and report that
status through the phy_device struct(s).  Maybe we need some sort of
container for multi-PHY devices?


Andy
