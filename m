From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net/phy: tune get_phy_c45_ids to support more c45
 phy
Date: Tue, 14 Apr 2015 10:45:05 -0700
Message-ID: <552D5221.1030703@gmail.com>
References: <1429006192-21403-1-git-send-email-Shengzhou.Liu@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Shengzhou Liu <Shengzhou.Liu@freescale.com>,
	netdev@vger.kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1429006192-21403-1-git-send-email-Shengzhou.Liu@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 14/04/15 03:09, Shengzhou Liu wrote:
> As some C45 10G PHYs(e.g. Cortina CS4315/CS4340 PHY) have
> zero Devices In package, current driver can't get correct
> devices_in_package value by non-zero Devices In package.
> so let's probe more with zero Devices In package to support
> more C45 PHYs.

I cannot remember exactly how many times this patch has been posted, but
it still is not clear to me what you are doing here is helping with
these Cortina PHYs.

Could you post a dump of the mdiobus_read() arguments and values for the
old code and the new code you are proposing? That way it might be
clearer what is the goal here?

> 
> Signed-off-by: Shengzhou Liu <Shengzhou.Liu@freescale.com>
> ---
> v2: use MDIO_DEVS1 and MDIO_DEVS2 instead of constant '6', '5'
> 
>  drivers/net/phy/phy_device.c | 25 +++++++++++++++++++++----
>  1 file changed, 21 insertions(+), 4 deletions(-)
> 
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index bdfe51f..c4f836f 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -242,12 +242,29 @@ static int get_phy_c45_ids(struct mii_bus *bus, int addr, u32 *phy_id,
>  			return -EIO;
>  		c45_ids->devices_in_package |= (phy_reg & 0xffff);
>  
> -		/* If mostly Fs, there is no device there,
> -		 * let's get out of here.
> +		/* If mostly Fs, let's continue to probe more
> +		 * as some c45 PHYs have zero Devices In package,
> +		 * e.g. Cortina CS4315/CS4340 PHY.
>  		 */
>  		if ((c45_ids->devices_in_package & 0x1fffffff) == 0x1fffffff) {
> -			*phy_id = 0xffffffff;
> -			return 0;
> +			reg_addr = MII_ADDR_C45 | 0 << 16 | MDIO_DEVS2;
> +			phy_reg = mdiobus_read(bus, addr, reg_addr);
> +			if (phy_reg < 0)
> +				return -EIO;
> +			c45_ids->devices_in_package = (phy_reg & 0xffff) << 16;
> +			reg_addr = MII_ADDR_C45 | 0 << 16 | MDIO_DEVS1;
> +			phy_reg = mdiobus_read(bus, addr, reg_addr);
> +			if (phy_reg < 0)
> +				return -EIO;
> +			c45_ids->devices_in_package |= (phy_reg & 0xffff);
> +			/* If mostly Fs, there is no device there,
> +			 * let's get out of here.
> +			 */
> +			if ((c45_ids->devices_in_package & 0x1fffffff) ==
> +							0x1fffffff) {
> +				*phy_id = 0xffffffff;
> +				return 0;
> +			}

Could not we somehow be a bit more clever and utilize the loop, with an
adjusted i = 0 during this condition? Some something like this (untested):


diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
index bdfe51fc3a65..4bb3d3084db1 100644
--- a/drivers/net/phy/phy_device.c
+++ b/drivers/net/phy/phy_device.c
@@ -230,6 +230,7 @@ static int get_phy_c45_ids(struct mii_bus *bus, int
addr, u32 *phy_id,
        for (i = 1;
             i < num_ids && c45_ids->devices_in_package == 0;
             i++) {
+again:
                reg_addr = MII_ADDR_C45 | i << 16 | MDIO_DEVS2;
                phy_reg = mdiobus_read(bus, addr, reg_addr);
                if (phy_reg < 0)
@@ -246,6 +247,11 @@ static int get_phy_c45_ids(struct mii_bus *bus, int
addr, u32 *phy_id,
                 * let's get out of here.
                 */
                if ((c45_ids->devices_in_package & 0x1fffffff) ==
0x1fffffff) {
+                       if (i == num_ids) {
+                               i = 0;
+                               goto again;
+                       }
+
                        *phy_id = 0xffffffff;
                        return 0;
                }
-- 
Florian
