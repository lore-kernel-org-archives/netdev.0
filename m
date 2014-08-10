From: Anca Emanuel <anca.emanuel@gmail.com>
Subject: Re: [PATCH RESEND] staging: et131x: Fix errors caused by phydev->addr
 accesses before initialisation
Date: Mon, 11 Aug 2014 00:32:55 +0300
Message-ID: <CAJL_dMub6FN+HvueQ4ZJCT2TPi9-86x8VF2hG00K8CDm5bR7rw@mail.gmail.com>
References: <1407705415-14886-1-git-send-email-mark.einon@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: STAGING SUBSYSTEM <devel@driverdev.osuosl.org>,
 "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
 LKML <linux-kernel@vger.kernel.org>, stable <stable@vger.kernel.org>,
 netdev@vger.kernel.org
To: Mark Einon <mark.einon@gmail.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1407705415-14886-1-git-send-email-mark.einon@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Do you have this hardware ? And did you test this ?

How can you cc stable without an Tested by somebody else ?

On Mon, Aug 11, 2014 at 12:16 AM, Mark Einon <mark.einon@gmail.com> wrote:
> Fix two reported bugs, caused by et131x_adapter->phydev->addr being accessed
> before it is initialised, by:
>
> - letting et131x_mii_write() take a phydev address, instead of using the one
>   stored in adapter by default. This is so et131x_mdio_write() can use it's own
>   addr value.
> - removing implementation of et131x_mdio_reset(), as it's not needed.
> - moving a call to et131x_disable_phy_coma() in et131x_pci_setup(), which uses
>   phydev->addr, until after the mdiobus has been registered.
>
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=80751
> Link: https://bugzilla.kernel.org/show_bug.cgi?id=77121
> Cc: stable@vger.kernel.org
> Signed-off-by: Mark Einon <mark.einon@gmail.com>
> ---
>  drivers/staging/et131x/et131x.c | 68 ++++++++++++++++-------------------------
>  1 file changed, 27 insertions(+), 41 deletions(-)
>
> diff --git a/drivers/staging/et131x/et131x.c b/drivers/staging/et131x/et131x.c
> index 8bf1eb4..831b7c6 100644
> --- a/drivers/staging/et131x/et131x.c
> +++ b/drivers/staging/et131x/et131x.c
> @@ -1421,22 +1421,16 @@ static int et131x_mii_read(struct et131x_adapter *adapter, u8 reg, u16 *value)
>   * @reg: the register to read
>   * @value: 16-bit value to write
>   */
> -static int et131x_mii_write(struct et131x_adapter *adapter, u8 reg, u16 value)
> +static int et131x_mii_write(struct et131x_adapter *adapter, u8 addr, u8 reg,
> +                           u16 value)
>  {
>         struct mac_regs __iomem *mac = &adapter->regs->mac;
> -       struct phy_device *phydev = adapter->phydev;
>         int status = 0;
> -       u8 addr;
>         u32 delay = 0;
>         u32 mii_addr;
>         u32 mii_cmd;
>         u32 mii_indicator;
>
> -       if (!phydev)
> -               return -EIO;
> -
> -       addr = phydev->addr;
> -
>         /* Save a local copy of the registers we are dealing with so we can
>          * set them back
>          */
> @@ -1631,17 +1625,7 @@ static int et131x_mdio_write(struct mii_bus *bus, int phy_addr,
>         struct net_device *netdev = bus->priv;
>         struct et131x_adapter *adapter = netdev_priv(netdev);
>
> -       return et131x_mii_write(adapter, reg, value);
> -}
> -
> -static int et131x_mdio_reset(struct mii_bus *bus)
> -{
> -       struct net_device *netdev = bus->priv;
> -       struct et131x_adapter *adapter = netdev_priv(netdev);
> -
> -       et131x_mii_write(adapter, MII_BMCR, BMCR_RESET);
> -
> -       return 0;
> +       return et131x_mii_write(adapter, phy_addr, reg, value);
>  }
>
>  /*     et1310_phy_power_switch -       PHY power control
> @@ -1656,18 +1640,20 @@ static int et131x_mdio_reset(struct mii_bus *bus)
>  static void et1310_phy_power_switch(struct et131x_adapter *adapter, bool down)
>  {
>         u16 data;
> +       struct  phy_device *phydev = adapter->phydev;
>
>         et131x_mii_read(adapter, MII_BMCR, &data);
>         data &= ~BMCR_PDOWN;
>         if (down)
>                 data |= BMCR_PDOWN;
> -       et131x_mii_write(adapter, MII_BMCR, data);
> +       et131x_mii_write(adapter, phydev->addr, MII_BMCR, data);
>  }
>
>  /* et131x_xcvr_init - Init the phy if we are setting it into force mode */
>  static void et131x_xcvr_init(struct et131x_adapter *adapter)
>  {
>         u16 lcr2;
> +       struct  phy_device *phydev = adapter->phydev;
>
>         /* Set the LED behavior such that LED 1 indicates speed (off =
>          * 10Mbits, blink = 100Mbits, on = 1000Mbits) and LED 2 indicates
> @@ -1688,7 +1674,7 @@ static void et131x_xcvr_init(struct et131x_adapter *adapter)
>                 else
>                         lcr2 |= (LED_VAL_LINKON << LED_TXRX_SHIFT);
>
> -               et131x_mii_write(adapter, PHY_LED_2, lcr2);
> +               et131x_mii_write(adapter, phydev->addr, PHY_LED_2, lcr2);
>         }
>  }
>
> @@ -3643,14 +3629,14 @@ static void et131x_adjust_link(struct net_device *netdev)
>
>                         et131x_mii_read(adapter, PHY_MPHY_CONTROL_REG,
>                                          &register18);
> -                       et131x_mii_write(adapter, PHY_MPHY_CONTROL_REG,
> -                                        register18 | 0x4);
> -                       et131x_mii_write(adapter, PHY_INDEX_REG,
> +                       et131x_mii_write(adapter, phydev->addr,
> +                                        PHY_MPHY_CONTROL_REG, register18 | 0x4);
> +                       et131x_mii_write(adapter, phydev->addr, PHY_INDEX_REG,
>                                          register18 | 0x8402);
> -                       et131x_mii_write(adapter, PHY_DATA_REG,
> +                       et131x_mii_write(adapter, phydev->addr, PHY_DATA_REG,
>                                          register18 | 511);
> -                       et131x_mii_write(adapter, PHY_MPHY_CONTROL_REG,
> -                                        register18);
> +                       et131x_mii_write(adapter, phydev->addr,
> +                                        PHY_MPHY_CONTROL_REG, register18);
>                 }
>
>                 et1310_config_flow_control(adapter);
> @@ -3662,7 +3648,8 @@ static void et131x_adjust_link(struct net_device *netdev)
>                         et131x_mii_read(adapter, PHY_CONFIG, &reg);
>                         reg &= ~ET_PHY_CONFIG_TX_FIFO_DEPTH;
>                         reg |= ET_PHY_CONFIG_FIFO_DEPTH_32;
> -                       et131x_mii_write(adapter, PHY_CONFIG, reg);
> +                       et131x_mii_write(adapter, phydev->addr, PHY_CONFIG,
> +                                        reg);
>                 }
>
>                 et131x_set_rx_dma_timer(adapter);
> @@ -3675,14 +3662,14 @@ static void et131x_adjust_link(struct net_device *netdev)
>
>                         et131x_mii_read(adapter, PHY_MPHY_CONTROL_REG,
>                                          &register18);
> -                       et131x_mii_write(adapter, PHY_MPHY_CONTROL_REG,
> -                                        register18 | 0x4);
> -                       et131x_mii_write(adapter, PHY_INDEX_REG,
> -                                        register18 | 0x8402);
> -                       et131x_mii_write(adapter, PHY_DATA_REG,
> -                                        register18 | 511);
> -                       et131x_mii_write(adapter, PHY_MPHY_CONTROL_REG,
> -                                        register18);
> +                       et131x_mii_write(adapter, phydev->addr,
> +                                       PHY_MPHY_CONTROL_REG, register18 | 0x4);
> +                       et131x_mii_write(adapter, phydev->addr,
> +                                       PHY_INDEX_REG, register18 | 0x8402);
> +                       et131x_mii_write(adapter, phydev->addr,
> +                                       PHY_DATA_REG, register18 | 511);
> +                       et131x_mii_write(adapter, phydev->addr,
> +                                       PHY_MPHY_CONTROL_REG, register18);
>                 }
>
>                 /* Free the packets being actively sent & stopped */
> @@ -4644,10 +4631,6 @@ static int et131x_pci_setup(struct pci_dev *pdev,
>         /* Copy address into the net_device struct */
>         memcpy(netdev->dev_addr, adapter->addr, ETH_ALEN);
>
> -       /* Init variable for counting how long we do not have link status */
> -       adapter->boot_coma = 0;
> -       et1310_disable_phy_coma(adapter);
> -
>         rc = -ENOMEM;
>
>         /* Setup the mii_bus struct */
> @@ -4663,7 +4646,6 @@ static int et131x_pci_setup(struct pci_dev *pdev,
>         adapter->mii_bus->priv = netdev;
>         adapter->mii_bus->read = et131x_mdio_read;
>         adapter->mii_bus->write = et131x_mdio_write;
> -       adapter->mii_bus->reset = et131x_mdio_reset;
>         adapter->mii_bus->irq = kmalloc_array(PHY_MAX_ADDR, sizeof(int),
>                                               GFP_KERNEL);
>         if (!adapter->mii_bus->irq)
> @@ -4687,6 +4669,10 @@ static int et131x_pci_setup(struct pci_dev *pdev,
>         /* Setup et1310 as per the documentation */
>         et131x_adapter_setup(adapter);
>
> +       /* Init variable for counting how long we do not have link status */
> +       adapter->boot_coma = 0;
> +       et1310_disable_phy_coma(adapter);
> +
>         /* We can enable interrupts now
>          *
>          *  NOTE - Because registration of interrupt handler is done in the
> --
> 2.1.0.rc1
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
