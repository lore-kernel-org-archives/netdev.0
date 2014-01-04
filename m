From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: [PATCH v2 5/5] bgmac: add support for Northstar SoC (BCM4707, BCM53018)
Date: Sat, 4 Jan 2014 23:24:29 +0100
Message-ID: <CACna6rwswGirfw7NU0UZEpNgMFzfcSFHQydga3xPHWF+_zZMKQ@mail.gmail.com>
References: <1388859238-22808-1-git-send-email-hauke@hauke-m.de>
	<1388859238-22808-6-git-send-email-hauke@hauke-m.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>
To: Hauke Mehrtens <hauke@hauke-m.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f169.google.com ([209.85.214.169]:63816 "EHLO
	mail-ob0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753656AbaADWY3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Jan 2014 17:24:29 -0500
Received: by mail-ob0-f169.google.com with SMTP id wm4so17055793obc.28
        for <netdev@vger.kernel.org>; Sat, 04 Jan 2014 14:24:29 -0800 (PST)
In-Reply-To: <1388859238-22808-6-git-send-email-hauke@hauke-m.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2014/1/4 Hauke Mehrtens <hauke@hauke-m.de>:
> @@ -909,9 +926,14 @@ static void bgmac_chip_reset(struct bgmac *bgmac)
>                         flags |= BGMAC_BCMA_IOCTL_SW_RESET;
>         }
>
> -       bcma_core_enable(core, flags);
> +       /* 3GMAC: for BCM4707, only do core reset at bgmac_probe() */
> +       if (ci->id != BCMA_CHIP_ID_BCM4707)
> +               bcma_core_enable(core, flags);

You can do better :) Why calculate flags if you're not going to use
them? Put that calculation code inside non-4707 block. You can also
move "u32 flags = 0;" to that block.


> @@ -1427,8 +1454,16 @@ static int bgmac_probe(struct bcma_device *core)
>         }
>         bgmac->cmn = core->bus->drv_gmac_cmn.core;
>
> -       bgmac->phyaddr = core->core_unit ? sprom->et1phyaddr :
> -                        sprom->et0phyaddr;
> +       /*
> +        * Too much can go wrong in scanning MDC/MDIO playing "whos my phy?" .
> +        * Instead, explicitly use the phy address 30.
> +        */
> +       if (ci->id == BCMA_CHIP_ID_BCM4707 || ci->id == BCMA_CHIP_ID_BCM53018)
> +               bgmac->phyaddr = BGMAC_PHY_NOREGS;
> +       else
> +               bgmac->phyaddr = core->core_unit ? sprom->et1phyaddr :
> +                                sprom->et0phyaddr;

I'm not sure if we really want that. AFAIU it's just a workaround of
the lack of NVRAM (and SPROM in the result) on BCM4707 (& family).
After adding NVRAM support you're have to revert that change, am I
right? Also this hack is not magically making 4707 work, as there are
many other issues (also related to the lack of NVRAM), correct?
