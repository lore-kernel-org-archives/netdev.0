From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] ARM: i.MX6: Add OF configuration support for ksz9031
Date: Wed, 23 Apr 2014 09:38:10 -0700
Message-ID: <CAGVrzcZk-LmkepEkjX4TD9CndcijH0DW-7VOpuUfdE7cYcdMEg@mail.gmail.com>
References: <1398181748-6500-1-git-send-email-hchaumette@adeneo-embedded.com>
 <CAGVrzcZbN+XP5kLb=cEL__+T9W8AY2ZWCtdZCMk9YUwo1r8Cnw@mail.gmail.com> <1398238558.3347.22.camel@EMBLYSD005.adetelgroup.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	netdev <netdev@vger.kernel.org>
To: Hubert Chaumette <hchaumette@adeneo-embedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398238558.3347.22.camel@EMBLYSD005.adetelgroup.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-04-23 0:35 GMT-07:00 Hubert Chaumette <hchaumette@adeneo-embedded.=
com>:
> Le mardi 22 avril 2014 =C3=A0 09:10 -0700, Florian Fainelli a =C3=A9c=
rit :
>> 2014-04-22 8:49 GMT-07:00 Hubert Chaumette <hchaumette@adeneo-embedd=
ed.com>:
>> > Adds support for ksz9031 PAD skew configuration over devicetree.
>> >
>> > Changes since v1:
>> > - Removed ksz9021 and ksz9031 fixup deletions from arch/arm/mach-i=
mx/mach-imx6q.c
>>
>> You should probably update the existing binding document in
>> Documentation/devicetree/bindings/net/micrel-ksz9021.txt to cover th=
e
>> KSZ9031 PHY too.
>
> Should it be renamed in the process (micrel-ksz90x1.txt) ?

That's a good question, I suppose that you could proceed to a rename
after checking that this document is not referenced directly somewhere
else in Documentation/devicetree/bindings/

>
>> >
>> > Signed-off-by: Hubert Chaumette <hchaumette@adeneo-embedded.com>
>> > ---
>> >  drivers/net/phy/micrel.c | 185 ++++++++++++++++++++++++++++++++++=
++++++++++++-
>> >  1 file changed, 184 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>> > index 5a8993b..df56b26 100644
>> > --- a/drivers/net/phy/micrel.c
>> > +++ b/drivers/net/phy/micrel.c
>> > @@ -242,6 +242,189 @@ static int ksz9021_config_init(struct phy_de=
vice *phydev)
>> >         return 0;
>> >  }
>> >
>> > +#define MII_KSZ9031RN_MMD_CTRL_REG     0x0d
>> > +#define MII_KSZ9031RN_MMD_REGDATA_REG  0x0e
>> > +#define OP_DATA                                1
>> > +#define KSZ9031_PS_TO_REG              60
>> > +
>> > +/* Extended registers */
>> > +#define MII_KSZ9031RN_CONTROL_PAD_SKEW 4
>> > +#define MII_KSZ9031RN_RX_DATA_PAD_SKEW 5
>> > +#define MII_KSZ9031RN_TX_DATA_PAD_SKEW 6
>> > +#define MII_KSZ9031RN_CLK_PAD_SKEW     8
>> > +
>> > +static int ksz9031_extended_write(struct phy_device *phydev,
>> > +                                 u8 mode, u32 dev_addr, u32 regnu=
m, u16 val)
>> > +{
>> > +       phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, dev_addr);
>> > +       phy_write(phydev, MII_KSZ9031RN_MMD_REGDATA_REG, regnum);
>> > +       phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, (mode << 14)=
 | dev_addr);
>> > +       return phy_write(phydev, MII_KSZ9031RN_MMD_REGDATA_REG, va=
l);
>> > +}
>> > +
>> > +static int ksz9031_extended_read(struct phy_device *phydev,
>> > +                                u8 mode, u32 dev_addr, u32 regnum=
)
>> > +{
>> > +       phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, dev_addr);
>> > +       phy_write(phydev, MII_KSZ9031RN_MMD_REGDATA_REG, regnum);
>> > +       phy_write(phydev, MII_KSZ9031RN_MMD_CTRL_REG, (mode << 14)=
 | dev_addr);
>> > +       return phy_read(phydev, MII_KSZ9031RN_MMD_REGDATA_REG);
>> > +}
>> > +
>> > +/* Two 5-bit fields register */
>> > +static int ksz9031_load_clk_skew_values(struct phy_device *phydev=
,
>> > +                                       struct device_node *of_nod=
e,
>> > +                                       char *field1, char *field2=
)
>> > +{
>> > +       int val1 =3D -1;
>> > +       int val2 =3D -2;
>> > +       int newval;
>> > +       int matches =3D 0;
>> > +
>> > +       if (!of_property_read_u32(of_node, field1, &val1))
>> > +               matches++;
>> > +
>> > +       if (!of_property_read_u32(of_node, field2, &val2))
>> > +               matches++;
>> > +
>> > +       if (!matches)
>> > +               return 0;
>> > +
>> > +       if (matches < 2)
>> > +               newval =3D ksz9031_extended_read(phydev, OP_DATA, =
2,
>> > +                               MII_KSZ9031RN_CLK_PAD_SKEW);
>> > +       else
>> > +               newval =3D 0;
>> > +
>> > +       if (val1 !=3D -1)
>> > +               newval =3D (newval & 0xffe0) |
>> > +                        ((val1 / KSZ9031_PS_TO_REG) & 0x1f);
>> > +
>> > +       if (val2 !=3D -2)
>> > +               newval =3D (newval & 0xfc1f) |
>> > +                        (((val2 / KSZ9031_PS_TO_REG) & 0x1f) << 5=
);
>> > +
>> > +       return ksz9031_extended_write(phydev, OP_DATA, 2,
>> > +                       MII_KSZ9031RN_CLK_PAD_SKEW, newval);
>> > +}
>> > +
>> > +/* Four 4-bit fields register */
>> > +static int ksz9031_load_data_skew_values(struct phy_device *phyde=
v,
>> > +                                        struct device_node *of_no=
de, u16 reg,
>> > +                                        char *field1, char *field=
2,
>> > +                                        char *field3, char *field=
4)
>> > +{
>> > +       int val1 =3D -1;
>> > +       int val2 =3D -2;
>> > +       int val3 =3D -3;
>> > +       int val4 =3D -4;
>> > +       int newval;
>> > +       int matches =3D 0;
>> > +
>> > +       if (!of_property_read_u32(of_node, field1, &val1))
>> > +               matches++;
>> > +
>> > +       if (!of_property_read_u32(of_node, field2, &val2))
>> > +               matches++;
>> > +
>> > +       if (!of_property_read_u32(of_node, field3, &val3))
>> > +               matches++;
>> > +
>> > +       if (!of_property_read_u32(of_node, field4, &val4))
>> > +               matches++;
>> > +
>> > +       if (!matches)
>> > +               return 0;
>> > +
>> > +       if (matches < 4)
>> > +               newval =3D ksz9031_extended_read(phydev, OP_DATA, =
2, reg);
>> > +       else
>> > +               newval =3D 0;
>> > +
>> > +       if (val1 !=3D -1)
>> > +               newval =3D (newval & 0xfff0) |
>> > +                        (((val1 / KSZ9031_PS_TO_REG) & 0xf) << 0)=
;
>> > +
>> > +       if (val2 !=3D -2)
>> > +               newval =3D (newval & 0xff0f) |
>> > +                        (((val2 / KSZ9031_PS_TO_REG) & 0xf) << 4)=
;
>> > +
>> > +       if (val3 !=3D -3)
>> > +               newval =3D (newval & 0xf0ff) |
>> > +                        (((val3 / KSZ9031_PS_TO_REG) & 0xf) << 8)=
;
>> > +
>> > +       if (val4 !=3D -4)
>> > +               newval =3D (newval & 0x0fff) |
>> > +                        (((val4 / KSZ9031_PS_TO_REG) & 0xf) << 12=
);
>>
>> How about something like this:
>>
>> for (i =3D 0; i < 4; i++) {
>>             if (val[i] !=3D -i) {
>>                     mask =3D 0xffff;
>>                     mask <<=3D (0 << (i * 4));
>>                     newval =3D (newval & mask) |
>>                            (((val[i] / KSZ9031_PS_TO_REG) & 0xf) << =
(i *4);
>>             }
>> }
>>
>> Such that you could factor ksz9031_load_ctrl_skew_values() and
>> ksz9031_load_data_skew_values() to specify the number of matches the=
y
>> should have?
>
> I'm on it.
>
> We could go further along this path and add a field length parameter =
to
> also factor ksz9031_load_clk_skew_values()?

Absolutely, that would be more future-proof and compact, so I am all
for it. Thanks!

> A similar loop could be used in ksz9021_load_values_from_of().
>
--=20
=46lorian
