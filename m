From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: Atheros 8035 PHY only works when at803x_config_init() is commented
 out
Date: Wed, 08 Apr 2015 10:29:49 -0700
Message-ID: <5525658D.7000709@gmail.com>
References: <5525571D.7060909@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Mugunthan <mugunthanvnm@ti.com>,
	"David S. Miller" <davem@davemloft.net>
To: Mason <slash.tmp@free.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:32827 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754089AbbDHRao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2015 13:30:44 -0400
Received: by paboj16 with SMTP id oj16so121242303pab.0
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2015 10:30:44 -0700 (PDT)
In-Reply-To: <5525571D.7060909@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/04/15 09:28, Mason wrote:
> Hello everyone,
> 
> I have a weird problem, that I've only started investigating, and I'd be
> grateful if anyone can help me along.
> 
> I have an ARM-based SoC that provides (AFAIU) an Atheros 8035 PHY.
> 
> If I enable the driver in my kernel (CONFIG_AT803X_PHY) then something
> goes wrong, and the system cannot load the nfsroot. Bizarrely, DHCP
> seems to work (so there is limited connectivity) but then the NFS
> server just times out.
> 
> However, if I just comment this line:
>     //.config_init = at803x_config_init,
> in at803x_driver[0]
> then everything seems to work. (At least, the system sets the PHY
> to Gbit, and manages to download the nfsroot.)
> 
> If I'm reading the code right (big "if"), when config_init is NULL,
> then phy_init_hw() turns into a NOP?
> 
> So either at803x_config_init() or something called from phy_init_hw()
> seems to be hosing this system's networking?
> 
> Sprinkling printk over phy_init_hw shows no errors (no premature exit)
> and phydev->drv->config_init(phydev) returns 0.
> 
> Maybe I didn't set something up correctly, and phy_write() is scribbling
> over the wrong register?
> 
> Does anyone see something I missed?

So one possibility could be that the bootloader initializes the PHY in a
certain way, typically by applying workarounds, and your config_init()
callback is not restoring any of theses, which is why, after
phy_init_hw(), which does a software reset of the PHY, all of these
workarounds are wiped out, and your PHY behaves funky.

The reason why config_init() needs to put the PHY back into a fully
functional state is because the PHY library should be able to software
reset the PHY when it needs to, but also be able to deal with deep sleep
modes etc.. where the PHY could loose its settings, yet the kernel
should be able to bring you back in a good state.

An easy way to bypass that is to provide a soft_reset calback which does
nothing, and see if calling either at803x_config_init(), or
genphy_config_init() is sufficient to preserve the PHY settings.
Although the real solution is to look at what the bootloader does on
that front and replicate it in the config_init() callback.

Hope this helps.
-- 
Florian
