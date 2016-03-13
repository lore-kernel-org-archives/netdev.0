From: Caesar Wang <caesar.upstream@gmail.com>
Subject: Re: [PATCH 3/6] net: arc_emac: support the phy reset for emac driver
Date: Sun, 13 Mar 2016 11:57:51 +0800
Message-ID: <56E4E53F.2060307@gmail.com>
References: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
 <1457693731-6966-4-git-send-email-wxt@rock-chips.com>
 <56E30FE5.1080607@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Caesar Wang <wxt@rock-chips.com>, Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>,
	Alexander Kochetkov <al.kochet@gmail.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <56E30FE5.1080607@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Sergei,

=E5=9C=A8 2016=E5=B9=B403=E6=9C=8812=E6=97=A5 02:35, Sergei Shtylyov =E5=
=86=99=E9=81=93:
> On 03/11/2016 01:55 PM, Caesar Wang wrote:
>
>> This patch adds to support the emac phy reset.
>>
>> 1) phy-reset-gpios:
>> The phy-reset-gpios is an optional property for arc emac device tree=
=20
>> boot.
>> Change the binding document to match the driver code.
>
>    The binding document is apparently changed in another patch. Not=20
> sure what you wanted to say here...
>
>> 2) phy-reset-duration:
>> Different boards may require different phy reset duration. Add prope=
rty
>> phy-reset-duration for device tree probe, so that the boards that ne=
ed
>> a longer reset duration can specify it in their device tree.
>>
>> 3) phy-reset-active-high:
>> We need that for a custom hardware that needs the reverse reset=20
>> sequence.
>
>    No, we don't really need that, "phy-reset-gpio" prop can contain=20
> this data.
>
>> Of course, this patch will fix the issue on
>> https://patchwork.kernel.org/patch/8186801/.
>>
>> In some cases, the emac couldn't work if you don't have reset the ph=
y.
>> Let's add it to happy work.
>>
>> Signed-off-by: Caesar Wang <wxt@rock-chips.com>
>> ---
>>
>>   drivers/net/ethernet/arc/emac_main.c | 41=20
>> ++++++++++++++++++++++++++++++++++++
>>   1 file changed, 41 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/arc/emac_main.c=20
>> b/drivers/net/ethernet/arc/emac_main.c
>> index 6446af1..42384f6a 100644
>> --- a/drivers/net/ethernet/arc/emac_main.c
>> +++ b/drivers/net/ethernet/arc/emac_main.c
>> @@ -764,6 +764,45 @@ static const struct net_device_ops=20
>> arc_emac_netdev_ops =3D {
>>   #endif
>>   };
>>
>> +#ifdef CONFIG_OF
>> +static void emac_reset_phy(struct net_device *pdev)
>> +{
>> +    int err, phy_reset;
>> +    bool active_high =3D false;
>> +    int msec =3D 10;
>> +    struct device *dev =3D pdev->dev.parent;
>> +    struct device_node *np =3D dev->of_node;
>> +
>> +    if (!np)
>> +        return;
>> +
>> +    of_property_read_u32(np, "phy-reset-duration", &msec);
>> +    /* A sane reset duration should not be longer than 1s */
>> +    if (msec > 1000)
>> +        msec =3D 1;
>> +
>> +    phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
>
>    Forgot to say that these old integer-base GPIO APIs shouldn't be=20
> used by the new code, there's new 'struct gpio_desc' based APIs, like=
=20
> devm_gpiod_get() etc.
>
>> +    if (!gpio_is_valid(phy_reset))
>> +        return;
>> +
>> +    active_high =3D of_property_read_bool(np, "phy-reset-active-hig=
h");
>
>    Well, I still don't understand why this prop is needed, while the=20
> GPIO sense is transparently handled by the gpiolib (at least when=20
> using DT).

Okay, I have to admit that reference the exist way to do...


wxt@nb:~/kernel/drivers/net/ethernet$ ag reset-gpios
micrel/ks8851.c
1427:    gpio =3D of_get_named_gpio_flags(spi->dev.of_node, "reset-gpio=
s",

arc/emac_main.c
787:    phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
797:        dev_err(dev, "failed to get phy-reset-gpios: %d\n", err);

arc/emac_main.c~
784:    phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
794:        dev_err(dev, "failed to get phy-reset-gpios: %d\n", err);

davicom/dm9000.c
1451:    reset_gpios =3D of_get_named_gpio_flags(dev->of_node,=20
"reset-gpios", 0,

freescale/fec_main.c
3206:    phy_reset =3D of_get_named_gpio(np, "phy-reset-gpios", 0);
3216:        dev_err(&pdev->dev, "failed to get phy-reset-gpios: %d\n",=
=20
err);

cadence/macb.c
2958:        int gpio =3D of_get_named_gpio(phy_node, "reset-gpios", 0)=
;

=2E..

Yep, the gpiolib that can include the prop to work with the same ways.



>
> [...]
>
> MBR, Sergei
>
>
> _______________________________________________
> Linux-rockchip mailing list
> Linux-rockchip@lists.infradead.org
> http://lists.infradead.org/mailman/listinfo/linux-rockchip


--=20
Thanks,
Caesar
