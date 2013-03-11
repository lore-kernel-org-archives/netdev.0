From: Florian Fainelli <florian@openwrt.org>
Subject: Re: Fwd: [PATCH] phydev: Add sysctl variable for polling interval
 of phy
Date: Mon, 11 Mar 2013 11:45:29 +0100
Message-ID: <513DB5C9.9020807@openwrt.org>
References: <2566257.7001362959040495.JavaMail.weblogic@epv6ml10>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eunb.song@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:41845 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753330Ab3CKKs6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Mar 2013 06:48:58 -0400
Received: by mail-bk0-f46.google.com with SMTP id j5so1622050bkw.33
        for <netdev@vger.kernel.org>; Mon, 11 Mar 2013 03:48:57 -0700 (PDT)
In-Reply-To: <2566257.7001362959040495.JavaMail.weblogic@epv6ml10>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On 03/11/2013 12:44 AM, EUNBONG SONG wrote:
>
>  From d55a22be52e5a768409aa0999d6636cdfc369676 Mon Sep 17 00:00:00 2001
> From: eunbonsong
> Date: Sun, 10 Mar 2013 04:57:39 -0700
> Subject: [PATCH] phydev: Add sysctl variable for polling interval of phy state
>
> This adds a dev.phy.phy_poll_interval sysctl variable. This value is represented in milliseconds.
> And phy_state_machine() is scheduled as this variable.
> I think HZ is enough for PC. But sometimes especially in network devices
> such as switches,routers, needs more granularity for detecting phy state change.

This patch should be submitted according to the rules described in: 
https://www.kernel.org/doc/Documentation/SubmittingPatches

Besides that, I do not think that a system-wide knob here is 
appropriate, you may rather introduce a new ethtool ioctl() to change 
the PHY device polling interval on a per-PHY device basis.

Having said that don't your devices support a dedicated PHY interrupt 
line? This would definitively be the way to get better latency with 
respect to PHY events reported back to the host.

>
>
> ---
> drivers/net/phy/phy.c        |    4 +++-
> drivers/net/phy/phy_device.c |   43 ++++++++++++++++++++++++++++++++++++++++++
> include/linux/phy.h          |    1 -
> 3 files changed, 46 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/phy/phy.c b/drivers/net/phy/phy.c
> index ef9ea92..126a69f 100644
> --- a/drivers/net/phy/phy.c
> +++ b/drivers/net/phy/phy.c
> @@ -42,6 +42,8 @@
> #include
> #include
>
> +extern unsigned long sysctl_phy_poll_interval;
> +
> /**
>    * phy_print_status - Convenience function to print out the current phy status
>    * @phydev: the phy_device struct
> @@ -966,7 +968,7 @@ void phy_state_machine(struct work_struct *work)
>          if (err < 0)
>                  phy_error(phydev);
>
> -       schedule_delayed_work(&phydev->state_queue, PHY_STATE_TIME * HZ);
> +       schedule_delayed_work(&phydev->state_queue, msecs_to_jiffies(sysctl_phy_poll_interval));
> }
>
> static inline void mmd_phy_indirect(struct mii_bus *bus, int prtad, int devad,
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 3657b4a..c2697e2 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -33,6 +33,7 @@
> #include
> #include
> #include
> +#include
>
> #include
> #include
> @@ -42,6 +43,45 @@ MODULE_DESCRIPTION("PHY library");
> MODULE_AUTHOR("Andy Fleming");
> MODULE_LICENSE("GPL");
>
> +unsigned long sysctl_phy_poll_interval = 1000;
> +static unsigned long min_phy_poll_interval = 1;
> +static unsigned long max_phy_poll_interval = 10000;

1 millisecond sounds like we are going to eat up a lot of CPU time 
polling PHY registers. Do you need that much reactivity?
--
Florian
