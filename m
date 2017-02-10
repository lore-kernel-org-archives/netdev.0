From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net] at803x: insure minimum delay for SGMII link AN
 completion ckeck
Date: Fri, 10 Feb 2017 09:46:17 -0800
Message-ID: <05e62e93-ac16-8000-ea36-dfdc6fb4d306@gmail.com>
References: <1486744943-12474-1-git-send-email-claudiu.manoil@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f193.google.com ([209.85.216.193]:34014 "EHLO
        mail-qt0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752116AbdBJS4o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 13:56:44 -0500
Received: by mail-qt0-f193.google.com with SMTP id w20so5603766qtb.1
        for <netdev@vger.kernel.org>; Fri, 10 Feb 2017 10:56:44 -0800 (PST)
In-Reply-To: <1486744943-12474-1-git-send-email-claudiu.manoil@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/10/2017 08:42 AM, Claudiu Manoil wrote:
> Commit: f62265b "at803x: double check SGMII side autoneg"
> introduced a regression for the p1010rdb board which has
> two of the ethernet controllers (eTSEC) connected through
> SGMII links to external Atheros SGMII AR8033 PHYs.
> The issue consists in a dead link for these ports, and is
> 100% reproducible on kernel 4.9 (and later):
> 
> root@p1010rdb-pb:~# ifconfig eth2 172.16.1.1
> [  203.274263] IPv6: ADDRCONF(NETDEV_UP): eth2: link is not ready
> root@p1010rdb-pb:~# [  206.408255] 803x_aneg_done: SGMII link is not ok
> 
> root@p1010rdb-pb:~# ethtool eth2
> Settings for eth2:
>         Supported ports: [ MII ]
>         Supported link modes:   10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Full
>         Supported pause frame use: Symmetric Receive-only
>         Supports auto-negotiation: Yes
>         Advertised link modes:  10baseT/Half 10baseT/Full
>                                 100baseT/Half 100baseT/Full
>                                 1000baseT/Full
>         Advertised pause frame use: No
>         Advertised auto-negotiation: Yes
>         Link partner advertised link modes:  10baseT/Half 10baseT/Full
>                                              100baseT/Half 100baseT/Full
>                                              1000baseT/Half 1000baseT/Full
>         Link partner advertised pause frame use: Symmetric Receive-only
>         Link partner advertised auto-negotiation: Yes
>         Speed: 1000Mb/s
>         Duplex: Full
>         Port: MII
>         PHYAD: 2
>         Transceiver: internal
>         Auto-negotiation: on
>         Supports Wake-on: g
>         Wake-on: d
>         Current message level: 0x0000003f (63)
>                                drv probe link timer ifdown ifup
>         Link detected: no
> 
> Insuring up to 100 usecs for the SGMII link side AN to complete
> proves to be enough to have a working SGMII link, for this board.
> The need for a delay for the SGMII link side may be explained by
> the fact that there are two levels of auto-negotiation (AN) for a
> SGMII link.  First the PHY autonegotiates the link parameters w/
> its link partner over the copper link. In the second stage, the
> AN results are then passed to the eTSEC MAC over the SGMII link
> using the Clause 37 auto-negotiation functionality.  While the
> aneg_done() hook is called by the phylib state machine to check
> for the completion of the 1st stage AN of the external PHY,
> there's no mechanism to insure proper AN completion of the internal
> SGMII link (which is actually handled on the eTSEC side by a
> "internal PHY", called TBI).
> 
> Fixes: f62265b "at803x: double check SGMII side autoneg"
> 
> Signed-off-by: Claudiu Manoil <claudiu.manoil@nxp.com>
> ---
>  drivers/net/phy/at803x.c | 9 ++++++++-
>  1 file changed, 8 insertions(+), 1 deletion(-)
> 
> diff --git a/drivers/net/phy/at803x.c b/drivers/net/phy/at803x.c
> index a52b560..55fa7c4 100644
> --- a/drivers/net/phy/at803x.c
> +++ b/drivers/net/phy/at803x.c
> @@ -366,6 +366,7 @@ static void at803x_link_change_notify(struct phy_device *phydev)
>  static int at803x_aneg_done(struct phy_device *phydev)
>  {
>  	int ccr;
> +	int timeout = 100; /* usecs */

unsigned int, and use reverse christmas tree declarations, order from
longest variable to shortest.

-- 
Florian
