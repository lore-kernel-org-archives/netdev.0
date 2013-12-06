From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFCv2 3/6] net: phy: provide phy_resume/phy_suspend helpers
Date: Thu, 5 Dec 2013 16:08:44 -0800
Message-ID: <CAGVrzcaTVbHCty2RWZM9jvETYVHV8fFRV1RXOYVauzf0-Arj7g@mail.gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com> <1386171888-28190-4-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Mugunthan V N <mugunthanvnm@ti.com>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1386171888-28190-4-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/12/4 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>:
> This adds helper functions to resume and suspend a given phy_device
> by calling the corresponding driver callbacks if available.
>
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Changelog:
> RFCv1->RFCv2:
> - only suspend if WOL is not enabled
> - remove EXPORT_SYMBOL for phy_suspend/resume
>
> Cc: David Miller <davem@davemloft.net>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: Mugunthan V N <mugunthanvnm@ti.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/phy/phy_device.c |   24 ++++++++++++++++++++++++
>  include/linux/phy.h          |    2 ++
>  2 files changed, 26 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index d6447b3..6f0e9e4 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -625,6 +625,30 @@ void phy_detach(struct phy_device *phydev)
>  }
>  EXPORT_SYMBOL(phy_detach);
>
> +int phy_suspend(struct phy_device *phydev)
> +{
> +       struct phy_driver *phydrv = to_phy_driver(phydev->dev.driver);
> +       struct ethtool_wolinfo wol;
> +
> +       /* If the device has WOL enabled, we cannot suspend the PHY */
> +       wol.cmd = ETHTOOL_GWOL;
> +       phy_ethtool_get_wol(phydev, &wol);
> +       if (wol.wolopts)
> +               return -EBUSY;

I wonder if we should not set a flag in the phy device structure which
says "someone called my phydrv->set_wol() callback, this succeeded and
WoL is now enabled for me", rather than using this potentially racy
call? This would have to be modified in phy_ethtool_set_wol() for
instance?

This is kind of theoretical though as I can't picture a case where
this sequence of events would happen in real-life.
--
Florian
