From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH (net.git) 2/2] stmmac: fix MDIO settings
Date: Wed, 9 Mar 2016 11:39:25 +0100
Message-ID: <56DFFD5D.4010201@st.com>
References: <1457514007-32333-1-git-send-email-peppe.cavallaro@st.com> <1457514007-32333-3-git-send-email-peppe.cavallaro@st.com> <CAG374jCMZnn+brdka1iE2LyHTbvhLPE62L93r0GpLRchhaUf5Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	=?UTF-8?B?QW5kcmVhcyBGw6RyYmVy?= <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, Dinh Nguyen <dinh.linux@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: Gabriel Fernandez <gabriel.fernandez@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx07-00178001.pphosted.com ([62.209.51.94]:17488 "EHLO
	mx07-00178001.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752797AbcCIKjj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Mar 2016 05:39:39 -0500
In-Reply-To: <CAG374jCMZnn+brdka1iE2LyHTbvhLPE62L93r0GpLRchhaUf5Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Gabriel

On 3/9/2016 11:27 AM, Gabriel Fernandez wrote:
> Hi Peppe,
>
> You missed something like that in stmmac_main.c ?
>
> @@ -864,13 +864,12 @@ static int stmmac_init_phy(struct net_device *d=
ev)
>    phy_disconnect(phydev);
>    return -ENODEV;
>    }
>
>    /* If attached to a switch, there is no reason to poll phy handler=
 */
> - if (priv->plat->phy_bus_name)
> - if (!strcmp(priv->plat->phy_bus_name, "fixed"))
> - phydev->irq =3D PHY_IGNORE_INTERRUPT;
> + if (priv->plat->is_fixed_link)
> + phydev->irq =3D PHY_IGNORE_INTERRUPT;

this is for net.git where this if condition code is not present.
I will propose a patch for net-next later.
I'd like to try to fix the new regression on xmit.

thx to have spot this.

Regards
peppe

>
>
> Best regards
>
> Gabriel
>
>
> On 9 March 2016 at 10:00, Giuseppe Cavallaro <peppe.cavallaro@st.com>=
 wrote:
>> Initially the phy_bus_name was added to manipulate the
>> driver name but It was recently just used to manage the
>> fixed-link and then to take some decision at run-time
>> inside the main (for example to skip EEE).
>>
>> So the patch now introduces a new platforms boolean to
>> manage that and removes the phy_bus_name variable not
>> necessary anymore.
>>
>> The driver can manage the mdio registration by using phy-handle,
>> dwmac-mdio and own parameter e.g. snps,phy-addr.
>> This patch takes care about all these possible configurations
>> and fixes the mdio registration in case of there is a real
>> transceiver or a switch (that needs to be managed by using
>> fixed-link).
>>
>> Signed-off-by: Giuseppe Cavallaro <peppe.cavallaro@st.com>
>> Cc: Gabriel Fernandez <gabriel.fernandez@linaro.org>
>> Cc: Andreas F=C3=A4rber <afaerber@suse.de>
>> Cc: Frank Sch=C3=A4fer <fschaefer.oss@googlemail.com>
>> Cc: Dinh Nguyen <dinh.linux@gmail.com>
>> Cc: David S. Miller <davem@davemloft.net>
>> ---
>>   drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   11 +++-----=
---
>>   .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   15 ++++++--=
-------
>>   include/linux/stmmac.h                             |    2 +-
>>   3 files changed, 10 insertions(+), 18 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c b/dri=
vers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> index c21015b..87e4643 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_main.c
>> @@ -271,7 +271,6 @@ static void stmmac_eee_ctrl_timer(unsigned long =
arg)
>>    */
>>   bool stmmac_eee_init(struct stmmac_priv *priv)
>>   {
>> -       char *phy_bus_name =3D priv->plat->phy_bus_name;
>>          unsigned long flags;
>>          bool ret =3D false;
>>
>> @@ -283,7 +282,7 @@ bool stmmac_eee_init(struct stmmac_priv *priv)
>>                  goto out;
>>
>>          /* Never init EEE in case of a switch is attached */
>> -       if (phy_bus_name && (!strcmp(phy_bus_name, "fixed")))
>> +       if (priv->plat->is_fixed_link)
>>                  goto out;
>>
>>          /* MAC core supports the EEE feature. */
>> @@ -820,12 +819,8 @@ static int stmmac_init_phy(struct net_device *d=
ev)
>>                  phydev =3D of_phy_connect(dev, priv->plat->phy_node=
,
>>                                          &stmmac_adjust_link, 0, int=
erface);
>>          } else {
>> -               if (priv->plat->phy_bus_name)
>> -                       snprintf(bus_id, MII_BUS_ID_SIZE, "%s-%x",
>> -                                priv->plat->phy_bus_name, priv->pla=
t->bus_id);
>> -               else
>> -                       snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x=
",
>> -                                priv->plat->bus_id);
>> +               snprintf(bus_id, MII_BUS_ID_SIZE, "stmmac-%x",
>> +                        priv->plat->bus_id);
>>
>>                  snprintf(phy_id_fmt, MII_BUS_ID_SIZE + 3, PHY_ID_FM=
T, bus_id,
>>                           priv->plat->phy_addr);
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c b=
/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> index 6a52fa1..09684dd 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/stmmac_platform.c
>> @@ -138,7 +138,12 @@ stmmac_probe_config_dt(struct platform_device *=
pdev, const char **mac)
>>                          return ERR_PTR(-ENODEV);
>>
>>                  plat->phy_node =3D of_node_get(np);
>> -       }
>> +               plat->is_fixed_link =3D true;
>> +       } else
>> +               plat->mdio_bus_data =3D
>> +                       devm_kzalloc(&pdev->dev,
>> +                                    sizeof(struct stmmac_mdio_bus_d=
ata),
>> +                                    GFP_KERNEL);
>>
>>          /* "snps,phy-addr" is not a standard property. Mark it as d=
eprecated
>>           * and warn of its use. Remove this when phy node support i=
s added.
>> @@ -146,14 +151,6 @@ stmmac_probe_config_dt(struct platform_device *=
pdev, const char **mac)
>>          if (of_property_read_u32(np, "snps,phy-addr", &plat->phy_ad=
dr) =3D=3D 0)
>>                  dev_warn(&pdev->dev, "snps,phy-addr property is dep=
recated\n");
>>
>> -       if ((plat->phy_node && !of_phy_is_fixed_link(np)) || plat->p=
hy_bus_name)
>> -               plat->mdio_bus_data =3D NULL;
>> -       else
>> -               plat->mdio_bus_data =3D
>> -                       devm_kzalloc(&pdev->dev,
>> -                                    sizeof(struct stmmac_mdio_bus_d=
ata),
>> -                                    GFP_KERNEL);
>> -
>>          of_property_read_u32(np, "tx-fifo-depth", &plat->tx_fifo_si=
ze);
>>
>>          of_property_read_u32(np, "rx-fifo-depth", &plat->rx_fifo_si=
ze);
>> diff --git a/include/linux/stmmac.h b/include/linux/stmmac.h
>> index eead8ab..1550558 100644
>> --- a/include/linux/stmmac.h
>> +++ b/include/linux/stmmac.h
>> @@ -94,10 +94,10 @@ struct stmmac_dma_cfg {
>>   };
>>
>>   struct plat_stmmacenet_data {
>> -       char *phy_bus_name;
>>          int bus_id;
>>          int phy_addr;
>>          int interface;
>> +       bool is_fixed_link;
>>          struct stmmac_mdio_bus_data *mdio_bus_data;
>>          struct device_node *phy_node;
>>          struct stmmac_dma_cfg *dma_cfg;
>> --
>> 1.7.4.4
>>
>
>
