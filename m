From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] net: phy: Add sysfs attribute to prevent PHY suspend
Date: Fri, 7 Mar 2014 17:09:24 -0800
Message-ID: <CAGVrzcaf3_AzgxJ=HPVc0SHcY-tndF+ejeMJCR6CO_RMysCsxA@mail.gmail.com>
References: <1393174719-20806-1-git-send-email-sebastian.hesselbarth@gmail.com>
 <1394192092-27461-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>, Rob Landley <rob@landley.net>,
	Andrew Lunn <andrew@lunn.ch>, netdev <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394192092-27461-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-03-07 3:34 GMT-08:00 Sebastian Hesselbarth
<sebastian.hesselbarth@gmail.com>:
> commit 1211ce53077164e0d34641d0ca5fb4d4a7574498
>   ("net: phy: resume/suspend PHYs on attach/detach")
> introduced a feature to suspend PHYs when entering halted state.
>
> Unfortunately, not all bootloaders properly power-up PHYs on reset
> and fail to access ethernet because the PHY is still powered down.
>
> Therefore, this adds code and documentation for a sysfs attribute to
> allow/deny PHYs to be suspended on a per-PHY basis. Disabling that
> attribute prevents PHYs from being suspended when entering halted state.
>
> Signed-off-by: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
> Reported-by: Andrew Lunn <andrew@lunn.ch>

Looks good to me, thanks Sebastian!

Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>

> ---
> David,
>
> I know I am late, but I still consider this as a fix for v3.14, therefore
> this is based on v3.14-rc1. If you are already done with taking fixes for
> v3.14, I can, of course, rebase this upon net-next.
>
> Cc: David Miller <davem@davemloft.net>
> Cc: Rob Landley <rob@landley.net>
> Cc: Andrew Lunn <andrew@lunn.ch>
> Cc: Florian Fainelli <f.fainelli@gmail.com>
> Cc: netdev@vger.kernel.org
> Cc: linux-doc@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org
> ---
>  Documentation/ABI/testing/sysfs-bus-mdio | 10 ++++++++++
>  drivers/net/phy/mdio_bus.c               | 26 ++++++++++++++++++++++++++
>  drivers/net/phy/phy_device.c             |  5 +++++
>  include/linux/phy.h                      |  2 ++
>  4 files changed, 43 insertions(+)
>
> diff --git a/Documentation/ABI/testing/sysfs-bus-mdio b/Documentation/ABI/testing/sysfs-bus-mdio
> index 6349749ebc29..e85a3d350cb1 100644
> --- a/Documentation/ABI/testing/sysfs-bus-mdio
> +++ b/Documentation/ABI/testing/sysfs-bus-mdio
> @@ -7,3 +7,13 @@ Description:
>                 by the device during bus enumeration, encoded in hexadecimal.
>                 This ID is used to match the device with the appropriate
>                 driver.
> +
> +What:          /sys/bus/mdio_bus/devices/.../phy_allow_suspend
> +Date:          March 2014
> +KernelVersion: 3.14
> +Contact:       netdev@vger.kernel.org
> +Description:
> +               This attribute contains a boolean parameter to allow (1) or
> +               deny (0) MDIO bus attached PHYs to be suspended. Some
> +               bootloaders fail to properly resume a suspended PHY, so this
> +               can be used to prevent the PHY from being suspended.
> diff --git a/drivers/net/phy/mdio_bus.c b/drivers/net/phy/mdio_bus.c
> index 71e49000fbf3..811d35185596 100644
> --- a/drivers/net/phy/mdio_bus.c
> +++ b/drivers/net/phy/mdio_bus.c
> @@ -432,8 +432,34 @@ phy_id_show(struct device *dev, struct device_attribute *attr, char *buf)
>  }
>  static DEVICE_ATTR_RO(phy_id);
>
> +static ssize_t phy_allow_suspend_show(struct device *dev,
> +               struct device_attribute *attr, char *buf)
> +{
> +       struct phy_device *phydev = to_phy_device(dev);
> +
> +       return sprintf(buf, "%d\n", phydev->allow_suspend);
> +}
> +
> +static ssize_t phy_allow_suspend_store(struct device *dev,
> +               struct device_attribute *attr, const char *buf, size_t count)
> +{
> +       struct phy_device *phydev = to_phy_device(dev);
> +       bool val;
> +       int ret;
> +
> +       ret = strtobool(buf, &val);
> +       if (ret < 0)
> +               return ret;
> +
> +       phydev->allow_suspend = val;
> +
> +       return count;
> +}
> +static DEVICE_ATTR_RW(phy_allow_suspend);
> +
>  static struct attribute *mdio_dev_attrs[] = {
>         &dev_attr_phy_id.attr,
> +       &dev_attr_phy_allow_suspend.attr,
>         NULL,
>  };
>  ATTRIBUTE_GROUPS(mdio_dev);
> diff --git a/drivers/net/phy/phy_device.c b/drivers/net/phy/phy_device.c
> index 4b03e63639b7..1c83d34d848b 100644
> --- a/drivers/net/phy/phy_device.c
> +++ b/drivers/net/phy/phy_device.c
> @@ -173,6 +173,7 @@ struct phy_device *phy_device_create(struct mii_bus *bus, int addr, int phy_id,
>         dev->phy_id = phy_id;
>         if (c45_ids)
>                 dev->c45_ids = *c45_ids;
> +       dev->allow_suspend = true;
>         dev->bus = bus;
>         dev->dev.parent = bus->parent;
>         dev->dev.bus = &mdio_bus_type;
> @@ -685,6 +686,10 @@ int phy_suspend(struct phy_device *phydev)
>         struct phy_driver *phydrv = to_phy_driver(phydev->dev.driver);
>         struct ethtool_wolinfo wol;
>
> +       /* Do not suspend PHYs, if user disabled it */
> +       if (!phydev->allow_suspend)
> +               return -ENOSYS;
> +
>         /* If the device has WOL enabled, we cannot suspend the PHY */
>         wol.cmd = ETHTOOL_GWOL;
>         phy_ethtool_get_wol(phydev, &wol);
> diff --git a/include/linux/phy.h b/include/linux/phy.h
> index 565188ca328f..c472e750c023 100644
> --- a/include/linux/phy.h
> +++ b/include/linux/phy.h
> @@ -272,6 +272,7 @@ struct phy_c45_device_ids {
>   * c45_ids: 802.3-c45 Device Identifers if is_c45.
>   * is_c45:  Set to true if this phy uses clause 45 addressing.
>   * is_internal: Set to true if this phy is internal to a MAC.
> + * allow_suspend: Set to false to prevent PHY suspend.
>   * state: state of the PHY for management purposes
>   * dev_flags: Device-specific flags used by the PHY driver.
>   * addr: Bus address of PHY
> @@ -308,6 +309,7 @@ struct phy_device {
>         struct phy_c45_device_ids c45_ids;
>         bool is_c45;
>         bool is_internal;
> +       bool allow_suspend;
>
>         enum phy_state state;
>
> --
> 1.8.5.3
>



-- 
Florian
