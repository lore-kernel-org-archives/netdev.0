From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/7] net: phy: mdio-bcm-unimac: factor busy
 polling loop
Date: Mon, 31 Jul 2017 17:33:03 -0700
Message-ID: <30212438-4567-d60c-4724-3d6ab7760247@gmail.com>
References: <201708010804.i8lcwBCE%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, netdev@vger.kernel.org, davem@davemloft.net,
        opendmb@gmail.com, jaedon.shin@gmail.com, pgynther@google.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:36651 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751102AbdHAAdI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2017 20:33:08 -0400
Received: by mail-qk0-f195.google.com with SMTP id d136so171042qkg.3
        for <netdev@vger.kernel.org>; Mon, 31 Jul 2017 17:33:08 -0700 (PDT)
In-Reply-To: <201708010804.i8lcwBCE%fengguang.wu@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/31/2017 05:28 PM, kbuild test robot wrote:
> Hi Florian,
> 
> [auto build test ERROR on net-next/master]
> 
> url:    https://github.com/0day-ci/linux/commits/Florian-Fainelli/net-bcmgenet-utilize-MDIO-unimac-driver/20170801-075847
> config: xtensa-allmodconfig (attached as .config)
> compiler: xtensa-linux-gcc (GCC) 4.9.0
> reproduce:
>         wget https://raw.githubusercontent.com/01org/lkp-tests/master/sbin/make.cross -O ~/bin/make.cross
>         chmod +x ~/bin/make.cross
>         # save the attached .config to linux build tree
>         make.cross ARCH=xtensa 
> 
> Note: the linux-review/Florian-Fainelli/net-bcmgenet-utilize-MDIO-unimac-driver/20170801-075847 HEAD 68043f6ab1b54d29abc5555fc56fdec46d280b76 builds fine.
>       It only hurts bisectibility.
> 
> All errors (new ones prefixed by >>):
> 
>    drivers/net/phy/mdio-bcm-unimac.c: In function 'unimac_mdio_read':
>>> drivers/net/phy/mdio-bcm-unimac.c:89:2: error: 'ret' undeclared (first use in this function)
>      ret = unimac_mdio_poll(priv);
>      ^
>    drivers/net/phy/mdio-bcm-unimac.c:89:2: note: each undeclared identifier is reported only once for each function it appears in
> 
> vim +/ret +89 drivers/net/phy/mdio-bcm-unimac.c

This is "just" a bisectability problem, patch 4 does actually add the
int ret variable to store the return value...

I will still fix the unmet dependency warning, depends on would actually
be more correct here anyway.

> 
>     76	
>     77	static int unimac_mdio_read(struct mii_bus *bus, int phy_id, int reg)
>     78	{
>     79		struct unimac_mdio_priv *priv = bus->priv;
>     80		u32 cmd;
>     81	
>     82		/* Prepare the read operation */
>     83		cmd = MDIO_RD | (phy_id << MDIO_PMD_SHIFT) | (reg << MDIO_REG_SHIFT);
>     84		__raw_writel(cmd, priv->base + MDIO_CMD);
>     85	
>     86		/* Start MDIO transaction */
>     87		unimac_mdio_start(priv);
>     88	
>   > 89		ret = unimac_mdio_poll(priv);
>     90		if (ret)
>     91			return ret;
>     92	
>     93		cmd = __raw_readl(priv->base + MDIO_CMD);
>     94	
>     95		/* Some broken devices are known not to release the line during
>     96		 * turn-around, e.g: Broadcom BCM53125 external switches, so check for
>     97		 * that condition here and ignore the MDIO controller read failure
>     98		 * indication.
>     99		 */
>    100		if (!(bus->phy_ignore_ta_mask & 1 << phy_id) && (cmd & MDIO_READ_FAIL))
>    101			return -EIO;
>    102	
>    103		return cmd & 0xffff;
>    104	}
>    105	
> 
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
> 


-- 
Florian
