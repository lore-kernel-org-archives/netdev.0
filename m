From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH NET] net/hns:bugfix of ethtool -t phy self_test
Date: Mon, 19 Jun 2017 14:00:43 -0700
Message-ID: <7500513f-e263-838c-12a1-4343f7281f1a@gmail.com>
References: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, xuwei5@hisilicon.com,
        liguozhu@hisilicon.com, Yisen.Zhuang@huawei.com,
        gabriele.paoloni@huawei.com, john.garry@huawei.com,
        linuxarm@huawei.com, salil.mehta@huawei.com, lipeng321@huawei.com,
        yankejian@huawei.com, tremyfr@gmail.com, xieqianqian@huawei.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Andrew Lunn <andrew@lunn.ch>
To: Lin Yun Sheng <linyunsheng@huawei.com>, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1497605091-94725-1-git-send-email-linyunsheng@huawei.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/16/2017 02:24 AM, Lin Yun Sheng wrote:
> This patch fixes the phy loopback self_test failed issue. when
> Marvell Phy Module is loaded, it will powerdown fiber when doing
> phy loopback self test, which cause phy loopback self_test fail.
> 
> Signed-off-by: Lin Yun Sheng <linyunsheng@huawei.com>
> ---
>  drivers/net/ethernet/hisilicon/hns/hns_ethtool.c | 16 ++++++++++++++--
>  1 file changed, 14 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> index b8fab14..e95795b 100644
> --- a/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> +++ b/drivers/net/ethernet/hisilicon/hns/hns_ethtool.c
> @@ -288,9 +288,15 @@ static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)

The question really is, why is not this properly integrated into the PHY
driver and PHYLIB such that the only thing the Ethernet MAC driver has
to call is a function of the PHY driver putting it in self-test?

>  
>  		/* Force 1000M Link, Default is 0x0200 */
>  		phy_write(phy_dev, 7, 0x20C);
> -		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
>  
> -		/* Enable PHY loop-back */
> +		/* Powerup Fiber */
> +		phy_write(phy_dev, HNS_PHY_PAGE_REG, 1);
> +		val = phy_read(phy_dev, COPPER_CONTROL_REG);
> +		val &= ~PHY_POWER_DOWN;
> +		phy_write(phy_dev, COPPER_CONTROL_REG, val);
> +
> +		/* Enable Phy Loopback */
> +		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
>  		val = phy_read(phy_dev, COPPER_CONTROL_REG);
>  		val |= PHY_LOOP_BACK;
>  		val &= ~PHY_POWER_DOWN;
> @@ -299,6 +305,12 @@ static int hns_nic_config_phy_loopback(struct phy_device *phy_dev, u8 en)
>  		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0xFA);
>  		phy_write(phy_dev, 1, 0x400);
>  		phy_write(phy_dev, 7, 0x200);
> +
> +		phy_write(phy_dev, HNS_PHY_PAGE_REG, 1);
> +		val = phy_read(phy_dev, COPPER_CONTROL_REG);
> +		val |= PHY_POWER_DOWN;
> +		phy_write(phy_dev, COPPER_CONTROL_REG, val);
> +
>  		phy_write(phy_dev, HNS_PHY_PAGE_REG, 0);
>  		phy_write(phy_dev, 9, 0xF00);
>  
> 


-- 
Florian
