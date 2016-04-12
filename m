From: Phil Reid <preid@electromag.com.au>
Subject: Re: GMII2RGMII Converter support in macb driver
Date: Tue, 12 Apr 2016 21:37:30 +0800
Message-ID: <570CFA1A.80702@electromag.com.au>
References: <C246CAC1457055469EF09E3A7AC4E11A4A57592E@XAP-PVEXMBX01.xlnx.xilinx.com>
 <570CF663.4000908@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Punnaiah Choudary Kalluri <punnaia@xilinx.com>,
	Harini Katakam <harinik@xilinx.com>,
	Anirudha Sarangi <anirudh@xilinx.com>,
	Appana Durga Kedareswara Rao <appanad@xilinx.com>
To: Nicolas Ferre <nicolas.ferre@atmel.com>,
	Appana Durga Kedareswara Rao <appana.durga.rao@xilinx.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Michal Simek <michal.simek@xilinx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy2.45ru.net.au ([203.30.46.146]:38105 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932939AbcDLNhm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 09:37:42 -0400
In-Reply-To: <570CF663.4000908@atmel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2016 9:21 PM, Nicolas Ferre wrote:
> Le 12/04/2016 15:03, Appana Durga Kedareswara Rao a =E9crit :
>> Hi All,
>>
>>
>>
>>
>>
>>                 There is a Xilinx custom IP for GMII to RGMII conver=
sion
>> data sheet here
>> (http://www.xilinx.com/support/documentation/ip_documentation/gmii_t=
o_rgmii/v4_0/pg160-gmii-to-rgmii.pdf
>> )
>>
>>
>>
>>
>>
>>                 Unlike other Phy=92s this IP won=92t support auto ne=
gotiation
>> and other features that usually normal Phy=92s support.
>>
>> This IP has only one register (Control register) which needs to be
>> programmed based on the external phy auto negotiation
>>
>> (Based on the external phy negotiated speed).
>>
>>
>>
>> I am able to make it work for GEM driver by doing the below changes =
in
>> the driver (drivers/net/ethernet/cadence/macb.c).
>>
>>
>>
>> +#define XEMACPS_GMII2RGMII_FULLDPLX                         BMCR_FU=
LLDPLX
>>
>> +#define XEMACPS_GMII2RGMII_SPEED1000                       BMCR_SPE=
ED1000
>>
>> +#define XEMACPS_GMII2RGMII_SPEED100                         BMCR_SP=
EED100
>>
>> +#define
>> XEMACPS_GMII2RGMII_REG_NUM                                       0x1=
0
>>
>> +
>>
>> /*
>>
>>    * Graceful stop timeouts in us. We should allow up to
>>
>>    * 1 frame time (10 Mbits/s, full-duplex, ignoring collisions)
>>
>> @@ -311,8 +317,10 @@ static void macb_handle_link_change(struct
>> net_device *dev)
>>
>> {
>>
>>                struct macb *bp =3D netdev_priv(dev);
>>
>>                struct phy_device *phydev =3D bp->phy_dev;
>>
>> +             struct phy_device *gmii2rgmii_phydev =3D bp->gmii2rgmi=
i_phy_dev;
>>
>>                unsigned long flags;
>>
>>                int status_change =3D 0;
>>
>> +             u16 gmii2rgmii_reg =3D 0;
>>
>>                 spin_lock_irqsave(&bp->lock, flags);
>>
>> @@ -326,15 +334,27 @@ static void macb_handle_link_change(struct
>> net_device *dev)
>>
>>                                              if (macb_is_gem(bp))
>>
>>                                                             reg &=3D
>> ~GEM_BIT(GBE);
>>
>> -                                            if (phydev->duplex)
>>
>> +                                           if (phydev->duplex) {
>>
>>                                                             reg |=3D
>> MACB_BIT(FD);
>>
>> -                                            if (phydev->speed =3D=3D=
 SPEED_100)
>>
>> +
>> gmii2rgmii_reg |=3D XEMACPS_GMII2RGMII_FULLDPLX;
>>
>> +                                           }
>>
>> +                                           if (phydev->speed =3D=3D
>> SPEED_100) {
>>
>>                                                             reg |=3D
>> MACB_BIT(SPD);
>>
>> +
>> gmii2rgmii_reg |=3D XEMACPS_GMII2RGMII_SPEED100;
>>
>> +                                           }
>>
>>                                              if (phydev->speed =3D=3D
>> SPEED_1000 &&
>>
>> -                                                bp->caps &
>> MACB_CAPS_GIGABIT_MODE_AVAILABLE)
>>
>> +                                               bp->caps &
>> MACB_CAPS_GIGABIT_MODE_AVAILABLE) {
>>
>>                                                             reg |=3D
>> GEM_BIT(GBE);
>>
>> +
>> gmii2rgmii_reg |=3D XEMACPS_GMII2RGMII_SPEED1000;
>>
>> +                                           }
>>
>>                                               macb_or_gem_writel(bp,
>> NCFGR, reg);
>>
>> +                                           if (gmii2rgmii_phydev !=3D=
 NULL) {
>>
>> +
>> macb_mdio_write(bp->mii_bus,
>>
>> +                                                                   =
      gmii2rgmii_phydev->addr,
>>
>> +                                                                   =
      XEMACPS_GMII2RGMII_REG_NUM,
>>
>> +                                                                   =
      gmii2rgmii_reg);
>>
>> +                                           }
>>
>>                                               bp->speed =3D phydev->=
speed;
>>
>>                                              bp->duplex =3D phydev->=
duplex;
>>
>> @@ -382,6 +402,19 @@ static int macb_mii_probe(struct net_device *de=
v)
>>
>>                int phy_irq;
>>
>>                int ret;
>>
>> +             if (bp->gmii2rgmii_phy_node) {
>>
>> +                            phydev =3D of_phy_attach(bp->dev,
>>
>> +                                                                   =
      bp->gmii2rgmii_phy_node,
>>
>> +                                                                   =
      0,
>> 0);
>>
>> +                            if (!phydev) {
>>
>> +                                           dev_err(&bp->pdev->dev, =
"%s:
>> no gmii to rgmii converter found\n",
>>
>> +                                           dev->name);
>>
>> +                                           return -1;
>>
>> +                            }
>>
>> +                            bp->gmii2rgmii_phy_dev =3D phydev;
>>
>> +             } else
>>
>> +                            bp->gmii2rgmii_phy_dev =3D NULL;
>>
>> +
>>
>>                phydev =3D phy_find_first(bp->mii_bus);
>>
>>                if (!phydev) {
>>
>>                               netdev_err(dev, "no PHY found\n");
>>
>> @@ -402,6 +435,8 @@ static int macb_mii_probe(struct net_device *dev=
)
>>
>>
>>   bp->phy_interface);
>>
>>                if (ret) {
>>
>>                               netdev_err(dev, "Could not attach to P=
HY\n");
>>
>> +                            if (bp->gmii2rgmii_phy_dev)
>>
>> +
>> phy_disconnect(bp->gmii2rgmii_phy_dev);
>>
>>                               return ret;
>>
>>                }
>>
>> @@ -3368,6 +3403,9 @@ static int macb_probe(struct platform_device *=
pdev)
>>
>>                               bp->phy_interface =3D err;
>>
>>                }
>>
>> +             bp->gmii2rgmii_phy_node =3D
>> of_parse_phandle(bp->pdev->dev.of_node,
>>
>> +
>> "gmii2rgmii-phy-handle", 0);
>>
>> +
>>
>>                macb_reset_phy(pdev);
>>
>>                 /* IP specific init */
>>
>> @@ -3422,6 +3460,8 @@ static int macb_remove(struct platform_device =
*pdev)
>>
>>                               bp =3D netdev_priv(dev);
>>
>>                               if (bp->phy_dev)
>>
>>                                              phy_disconnect(bp->phy_=
dev);
>>
>> +                            if (bp->gmii2rgmii_phy_dev)
>>
>> +
>> phy_disconnect(bp->gmii2rgmii_phy_dev);
>>
>>
>>
>> But doing above changes making driver looks odd.
>>
>> could you please suggest any better option to add support for this I=
P in
>> the macb driver?
>
> Appana,
>
> I certainly can't prototype the solution based on your datasheet and =
the
> code sent... do a sensible proposal, then we can evaluate.
>
> As the IP is separated from the Eth controller, make it a separate
> driver (an emulated phy one for instance... even if I don't know if i=
t
> makes sense).
>
> I don't know if others have already made such an adaptation layer
> between GMII to RGMII but I'm pretty sure it can't be inserted into t=
he
> macb driver.
>
> Bye,
>
This sounds very similar to the altera emac-splitter.
See stmmac driver for how they handled this.


--=20
Regards
Phil Reid
