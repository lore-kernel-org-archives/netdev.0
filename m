From: Romain Perier <romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v1 3/4] net: stmmac: dwmac-rk: Use standard devicetree
 property for phy regulator
Date: Tue, 20 Jan 2015 07:55:45 +0100
Message-ID: <CABgxDoLY3hkj5=QP1s8h4fotx7vSfOiP6xZd9L=t8ZffteO8QQ@mail.gmail.com>
References: <1421690889-11901-1-git-send-email-romain.perier@gmail.com>
	<1421690889-11901-4-git-send-email-romain.perier@gmail.com>
	<4603622.ltPA9iTIiK@phil>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: peppe.cavallaro-qxv4g6HH51o@public.gmane.org, netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	"linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
	<linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	roger.chen-TNX95d0MmH7DzftRWevZcw@public.gmane.org
To: =?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4603622.ltPA9iTIiK@phil>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

Ok I will do these changes. However, the property "phy_regulator" was
not documented in
Documentation/devicetree/bindings/net/rockchip-dwmac.txt ... I can
document it anyway, it has probably been forgotten.

Thanks !

2015-01-19 21:12 GMT+01:00 Heiko St=C3=BCbner <heiko-4mtYJXux2i+zQB+pC5nmwQ@public.gmane.org>:
> Am Montag, 19. Januar 2015, 18:08:08 schrieb Romain Perier:
>> Currently, dwmac-rk uses a custom propety "phy_regulator" to get the=
 name of
>> the right regulator to use to power on or power off the phy. This co=
mmit
>> converts the driver to use phy-supply devicetree property and the
>> corresponding API, it cleans the code a bit and make it simpler to
>> maintain.
>>
>> Signed-off-by: Romain Perier <romain.perier-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
> I don't see updated binding documentation in here.
>
> Secondly I think patch4 which changes the property in the evb-rk808 c=
ould be
> in here. The change is simple enough and would keep it bisectable wit=
hout
> needing transistional patches.
>
> And there is the one warning down below.
>
>
>> ---
>>  drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c | 61
>> ++++++++------------------ 1 file changed, 19 insertions(+), 42
>> deletions(-)
>>
>> diff --git a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c index 06e1637..8a80=
91c
>> 100644
>> --- a/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> +++ b/drivers/net/ethernet/stmicro/stmmac/dwmac-rk.c
>> @@ -32,7 +32,7 @@
>>  struct rk_priv_data {
>>       struct platform_device *pdev;
>>       int phy_iface;
>> -     char regulator[32];
>> +     struct regulator *regulator;
>>
>>       bool clk_enabled;
>>       bool clock_input;
>> @@ -287,46 +287,25 @@ static int gmac_clk_enable(struct rk_priv_data
>> *bsp_priv, bool enable)
>>
>>  static int phy_power_on(struct rk_priv_data *bsp_priv, bool enable)
>>  {
>> -     struct regulator *ldo;
>> -     char *ldostr =3D bsp_priv->regulator;
>> +     struct regulator *ldo =3D bsp_priv->regulator;
>>       int ret;
>>       struct device *dev =3D &bsp_priv->pdev->dev;
>>
>> -     if (!ldostr) {
>> -             dev_err(dev, "%s: no ldo found\n", __func__);
>> +     if (!ldo) {
>> +             dev_err(dev, "%s: no regulator found\n", __func__);
>>               return -1;
>>       }
>>
>> -     ldo =3D regulator_get(NULL, ldostr);
>> -     if (!ldo) {
>> -             dev_err(dev, "\n%s get ldo %s failed\n", __func__, ldo=
str);
>> +     if (enable) {
>> +             ret =3D regulator_enable(ldo);
>> +             if (ret)
>> +                     dev_err(dev, "%s: fail to enable phy-supply\n"=
,
>> +                             __func__);
>>       } else {
>> -             if (enable) {
>> -                     if (!regulator_is_enabled(ldo)) {
>> -                             ret =3D regulator_enable(ldo);
>> -                             if (ret !=3D 0)
>> -                                     dev_err(dev, "%s: fail to enab=
le %s\n",
>> -                                             __func__, ldostr);
>> -                             else
>> -                                     dev_info(dev, "turn on ldo don=
e.\n");
>> -                     } else {
>> -                             dev_warn(dev, "%s is enabled before en=
able",
>> -                                      ldostr);
>> -                     }
>> -             } else {
>> -                     if (regulator_is_enabled(ldo)) {
>> -                             ret =3D regulator_disable(ldo);
>> -                             if (ret !=3D 0)
>> -                                     dev_err(dev, "%s: fail to disa=
ble %s\n",
>> -                                             __func__, ldostr);
>> -                             else
>> -                                     dev_info(dev, "turn off ldo do=
ne.\n");
>> -                     } else {
>> -                             dev_warn(dev, "%s is disabled before d=
isable",
>> -                                      ldostr);
>> -                     }
>> -             }
>> -             regulator_put(ldo);
>> +             ret =3D regulator_disable(ldo);
>> +             if (ret)
>> +                     dev_err(dev, "%s: fail to disable phy-supply\n=
",
>> +                             __func__);
>>       }
>>
>>       return 0;
>> @@ -346,14 +325,12 @@ static void *rk_gmac_setup(struct platform_dev=
ice
>> *pdev)
>>
>>       bsp_priv->phy_iface =3D of_get_phy_mode(dev->of_node);
>>
>> -     ret =3D of_property_read_string(dev->of_node, "phy_regulator",=
 &strings);
>> -     if (ret) {
>> -             dev_warn(dev, "%s: Can not read property: phy_regulato=
r.\n",
>> -                      __func__);
>> -     } else {
>> -             dev_info(dev, "%s: PHY power controlled by regulator(%=
s).\n",
>> -                      __func__, strings);
>> -             strcpy(bsp_priv->regulator, strings);
>> +     bsp_priv->regulator =3D devm_regulator_get_optional(dev, "phy"=
);
>> +     if (IS_ERR(bsp_priv->regulator)) {
>> +             if (PTR_ERR(bsp_priv->regulator) =3D=3D -EPROBE_DEFER)
>> +                     return -EPROBE_DEFER;
>
> this should be return ERR_PTR(-EPROBE_DEFER) and produces a warning i=
n its
> current state
>
>
>> +             dev_err(dev, "no regulator found\n");
>> +             bsp_priv->regulator =3D NULL;
>>       }
>>
>>       ret =3D of_property_read_string(dev->of_node, "clock_in_out", =
&strings);
>
--
To unsubscribe from this list: send the line "unsubscribe devicetree" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
