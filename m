From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH NET] net/hns:bugfix of ethtool -t phy self_test
Date: Wed, 21 Jun 2017 05:13:20 +0200
Message-ID: <20170621031320.GA1487@lunn.ch>
References: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
 <7500513f-e263-838c-12a1-4343f7281f1a@gmail.com>
 <08ef77fc-29ab-8262-2126-c547960d5628@huawei.com>
 <20170620132705.GD13704@lunn.ch>
 <524e1181-f90d-0f05-200a-44cfa179dbf3@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
        huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        yankejian@huawei.com, tremyfr@gmail.com, xieqianqian@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: l00371289 <linyunsheng@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:58080 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752990AbdFUDNk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 20 Jun 2017 23:13:40 -0400
Content-Disposition: inline
In-Reply-To: <524e1181-f90d-0f05-200a-44cfa179dbf3@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 21, 2017 at 10:03:29AM +0800, l00371289 wrote:
> Hi, Andrew
> 
> On 2017/6/20 21:27, Andrew Lunn wrote:
> > On Tue, Jun 20, 2017 at 11:05:54AM +0800, l00371289 wrote:
> >> hi, Florian
> >>
> >> On 2017/6/20 5:00, Florian Fainelli wrote:
> >>> On 06/16/2017 02:24 AM, Lin Yun Sheng wrote:
> >>>> This patch fixes the phy loopback self_test failed issue. when
> >>>> Marvell Phy Module is loaded, it will powerdown fiber when doing
> >>>> phy loopback self test, which cause phy loopback self_test fail.
> >>>>
> >>>> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
> >>>> ---
> >>>>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 16 ++++++++++++++--
> >>>>  1 file changed, 14 insertions(+), 2 deletions(-)
> >>>>
> >>>> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> >>>> index b8fab14..e95795b 100644
> >>>> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> >>>> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> >>>> @@ -288,9 +288,15 @@ static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
> >>>
> >>> The question really is, why is not this properly integrated into the PHY
> >>> driver and PHYLIB such that the only thing the Ethernet MAC driver has
> >>> to call is a function of the PHY driver putting it in self-test?
> >> Do you meaning calling phy_dev->drv->resume and phy_dev->drv->suspend function?
> > 
> > No. Florian is saying you should add support for phylib and the
> > drivers to enable/disable loopback.
> > 
> > The BMCR loopback bit is pretty much standardised. So you can
> > implement a genphy_loopback(phydev, enable), which most drivers can
> > use. Those that need there own can implement it in there driver.
> 
> I tried to add the genphy_loopback support you mentioned, please look
> at it if that is what you mean. If Yes, I will try to send out a new patch.
> 
> Best Regards
> Yinsheng Lin
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 1219eea..54fecad 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -1628,6 +1628,31 @@ static int gen10g_resume(struct phy_device *phydev)
>         return 0;
>  }
> 
> +int genphy_loopback(struct phy_device *phydev, bool enable)
> +{
> +       int value;
> +
> +       mutex_lock(&phydev->lock);

Do you look at the other genphy_ functions? How many take the mutex?

> +       if (enable) {
> +               value = phy_read(phydev, MII_BMCR);
> +               phy_write(phydev, MII_BMCR, value | BMCR_LOOPBACK);
> +       } else {
> +               value = phy_read(phydev, MII_BMCR);
> +               phy_write(phydev, MII_BMCR, value & ~BMCR_LOOPBACK);
> +       }
> +
> +       mutex_unlock(&phydev->lock);
> +
> +       return 0;
> +}
> +EXPORT_SYMBOL(genphy_loopback);
> +
> +static int gen10g_loopback(struct phy_device *phydev, bool enable)
> +{
> +       return 0;
> +}
> +
>  static int __set_phy_supported(struct phy_device *phydev, u32 max_speed)
>  {
>         /* The default values for phydev->supported are provided by the PHY
> @@ -1874,6 +1899,7 @@ void phy_drivers_unregister(struct phy_driver *drv, int n)
>         .read_status    = genphy_read_status,
>         .suspend        = genphy_suspend,
>         .resume         = genphy_resume,
> +       .set_loopback   = genphy_loopback,
>  }, {
>         .phy_id         = 0xffffffff,
>         .phy_id_mask    = 0xffffffff,
> @@ -1885,6 +1911,7 @@ void phy_drivers_unregister(struct phy_driver *drv, int n)
>         .read_status    = gen10g_read_status,
>         .suspend        = gen10g_suspend,
>         .resume         = gen10g_resume,
> +       .set_loopback   = gen10g_loopback,
>  } };
> 
>  static int __init phy_init(void)
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index e76e4ad..fc7a5c8 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -639,6 +639,7 @@ struct phy_driver {
>         int (*set_tunable)(struct phy_device *dev,
>                             struct ethtool_tunable *tuna,
>                             const void *data);
> +       int (*set_loopback(struct phy_device *dev, bool enable);

Does this even compile? It looks to be missing a )

Also, where is the exported function the MAC driver should call?

     Andrew
