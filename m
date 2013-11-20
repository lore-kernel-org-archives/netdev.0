From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC v1 7/7] net: cpsw: resume/suspend PHY on port start/stop
Date: Wed, 20 Nov 2013 12:48:08 -0800
Message-ID: <CAGVrzcZ+5oaucp+OSeGGe=6MBjEwi4K=E_NbCm3PjR_Owyxstw@mail.gmail.com>
References: <1384978913-8052-1-git-send-email-sebastian.hesselbarth@gmail.com> <1384978913-8052-8-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1384978913-8052-8-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/11/20 Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>:
> Network PHYs consume a noticable amount of power. This adds phy_resume
> on slave_open and phy_suspend on slave_stop to save this power if the
> port is down anyway.
>
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> ---
> Cc: David S. Miller <davem@davemloft.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  drivers/net/ethernet/ti/cpsw.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/ti/cpsw.c b/drivers/net/ethernet/ti/cpsw.c
> index 90d41d2..f1dc54f 100644
> --- a/drivers/net/ethernet/ti/cpsw.c
> +++ b/drivers/net/ethernet/ti/cpsw.c
> @@ -1013,6 +1013,7 @@ static void cpsw_slave_open(struct cpsw_slave *slave, struct cpsw_priv *priv)
>         } else {
>                 dev_info(priv->dev, "phy found : id is : 0x%x\n",
>                          slave->phy->phy_id);
> +               phy_resume(slave->phy);
>                 phy_start(slave->phy);

Cannot phy_start() figure this out for us based on the internal PHY
device state machine?

I would imagine that you would want to call phy_suspend/resume from an
Ethernet driver's PM suspend/resume callbacks to make sure that the
PHY also enters a low power mode, but I do not want to have to
remember that I need to call phy_resume before phy_start for instance.
As of today we have PHY_HALTED/PHY_RESUMING, and I think we certainly
need at least a PHY_SUSPENDED state to help us with that.

>
>                 /* Configure GMII_SEL register */
> @@ -1081,6 +1082,7 @@ static void cpsw_slave_stop(struct cpsw_slave *slave, struct cpsw_priv *priv)
>         if (!slave->phy)
>                 return;
>         phy_stop(slave->phy);
> +       phy_suspend(slave->phy);

Same here, why is not that hidden in phy_stop? If there is any fear
that this breaks setups where WoL is used or such, we could add a new
argument to phy_connect() and friends which says whether it is okay to
auto-suspend the PHY upon PHY_stop

>         phy_disconnect(slave->phy);
>         slave->phy = NULL;
>  }
> --
> 1.7.2.5
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/



-- 
Florian
