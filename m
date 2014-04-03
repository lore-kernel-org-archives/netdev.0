From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: Bug(s) with netconsole (using mv643xx_eth on Kirkwood)
Date: Thu, 03 Apr 2014 20:21:14 +0200
Message-ID: <533DA69A.2010402@gmail.com>
References: <1396396559-6971-1-git-send-email-holler@ahsoftware.de> <CAGVrzcZd9tBtcTY_2PRHVb9kJAjVHqn+EubUy4NGL66M_UuCDg@mail.gmail.com> <533BD3CD.1010905@ahsoftware.de> <CAGVrzcZi5aNq8fR795fKhu2TAc1tQCa2YEorErZRLf2n9DPZuw@mail.gmail.com> <533C721E.1080004@gmail.com> <533C8B49.8080704@ahsoftware.de> <533C8ECB.4090900@gmail.com> <533D0B09.9040602@ahsoftware.de> <533D207E.9020909@gmail.com> <533D790C.5000104@ahsoftware.de> <533D8207.2050108@gmail.com> <533D8518.1010306@ahsoftware.de> <533DA12B.8090904@ahsoftware.de>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>,
	David Miller <davem@davemloft.net>
To: Alexander Holler <holler@ahsoftware.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:39382 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753292AbaDCSVU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2014 14:21:20 -0400
In-Reply-To: <533DA12B.8090904@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/2014 07:58 PM, Alexander Holler wrote:
[...]
> I already knew about problems with netconsole and mv643xx_eth since
> 4 years, but didn't care a lot because everything else worked flawless,
> I even had forgotten that I've enabled netconsole. (But the bugs I've
> experienced 4 years ago, seeing no msgs remotely from netconsole seem to
> have disappeared).

Alexander,

you need to be more specific. You cannot just say "problems" and "bugs".

I can run the very same board with v3.14.0 and netconsole enabled. No
PHY hickups, plenty netconsole messages, no dying PHY at any time.

> But now, using 3.14, I hit a bug which killed the ethernet with a 100%
> success rate, and, after digging a bit, I've come to the conclusion
> that netconsole (together with a maybe broken initialization of the PHY)
> is the source of the problem.

Given the fact that I can use above two just fine, I still doubt it is
related.

> The kernel is 3.14 (mainline) with one reverted patch (7cd1463). This
> patch changed the initialization of the PHY such, that the ethernet dies
> 100% reproducible on a Kirkwood 88F6281 based machine. Reverting that
> patch gives me a oneline bug-enabler:
> 
> ------
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c
> b/drivers/net/ethernet/marvell/mv643xx_eth.c
> index e891b48..246f065 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -2095,7 +2095,8 @@ static void port_start(struct mv643xx_eth_private
> *mp)
>                 struct ethtool_cmd cmd;
> 
>                 mv643xx_eth_get_settings(mp->dev, &cmd);
> -               phy_reset(mp);
> +               //phy_reset(mp);
> +               phy_init_hw(mp->phy);
>                 mv643xx_eth_set_settings(mp->dev, &cmd);
>                 phy_start(mp->phy);
>         }
> ------
> 
> First I describe what happens at boot:
> 
> - Bootloader (U-Boot) enables (somehow) the network such that is usable
> as a console for the bootloader,
> - Kernel is loaded and started with netconsole enabled through the
> kernel command line (netconsole=...),

Please provide full cmdline. I can use netconsole on it with

console=ttyS0,115200 root=/dev/sda2 rootwait rw
netconsole=@192.168.1.54/,@192.168.1.101/

.54 and .101 are netconsole sender and receiver, respectively.
/dev/sda2 is ext4 on a 4G usb stick. Also, my dockstar runs on
a power-supply that provides more power than the original one.

I mention this, because if you e.g. run a usb hdd on the dockstar,
it _can_ draw a lot of power and possibly cause the PHY to hard-reset.

Just to make sure: can you also provide above information or even
better change your setup to boot from usb stick?

> - eth driver probe => PHY reset
> - netconsole initializes the network (netpoll_setup) => PHY reset,
> - userland starts,
> - userland configures network (ip addr add fixedIP ..., a hack used for
> a very early ntpdate before the rootfs becomes rw), I'm not sure if
> that's end up again in a PHY reset.
> - userland starts network by using dhcpcd => PHY reset
> 
> Now several use cases:
> 
> Case 1:
> Using plain 3.14 the last step fails with no carrier, because the PHY
> ends up in a never ending reset (BMCR_RESET always set) in
> m88e1111_config_init() called by phy_init_hw() in port_start() in

PHY on Dockstar is 88E1116R so above should have been
m88r1116r_config_init()?

> mv643xx_eth.
> 
> Case 2:
> Without enabling netconsole through the kernel command line, I see no
> problems.

I can even enable netconsole and see no issues.

> Case 3:
> If I enable the old phy_reset() in mv643xx_eth, I see no problems.
> 
> Case 4:
> If I reduce the time the newly used reset in phy_init_hw() spends in
> calling mdelay(500) twice to some milliseconds m88e1111_config_init by
> polling for a cleared BMCR_RESET, I see no problems.
> 
> Case 5:
> If I disable the initialization of the network in the bootloader,
> netconsole even worked 4 years ago. But I haven't looked into that case
> further, because I always want to use the network as a console for the
> bootloader.

Ok, that one is actually different from my setup. I have no netconsole
support for u-boot. Is your statement from _now_ or _4 years ago_, i.e.
does disabling u-boot netconsole _now_ change anything?

> Current assumption:
> 
[...]
> 
> I hope everyone who missed some more information is happy now, otherwise
> I (again) wasted time to type a problem description (not to speak about
> the already spent time trying to diagnose the problem)
> 
> So go on and try to take the almost low hanging fruit. I'm not sure if I
> will spend more time on that topic as I already have a working
> patch/workaround and the discussion has become a bit tiresome. Sorry.

Alexander, please stop f*cking around here. Florian, David, and me
already showed a lot patience. None of your patches deals with the
real issue. Either help others to properly reproduce it or leave it.

Sebastian
