From: Anand Moon <linux.amoon-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net 1/3] net: phy: realtek: add eee advertisement disable options
Date: Thu, 17 Nov 2016 23:30:34 +0530
Message-ID: <CANAwSgTB5=8tVj1FrZF3EgjK5mjUMwLYb90NeWSFDCsRjsuB6A@mail.gmail.com>
References: <1479220154-25851-1-git-send-email-jbrunet@baylibre.com>
 <1479220154-25851-2-git-send-email-jbrunet@baylibre.com> <CANAwSgTjG8G0U+A1p7hOKND9rjY4BzZfPgyWWHAEryYkHj_UOw@mail.gmail.com>
 <1479378055.17538.57.camel@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>,
        Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>,
        Kevin Hilman <khilman-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>,
        Linux Kernel <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        linux-amlogic-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org, Carlo Caione <carlo-KA+7E9HrN00dnm+yROfE0A@public.gmane.org>,
        Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>
To: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1479378055.17538.57.camel-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Jerone,

On 17 November 2016 at 15:50, Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org> wrote:
> On Wed, 2016-11-16 at 22:36 +0530, Anand Moon wrote:
>>  Hi Jerome.
>>
>> On 15 November 2016 at 19:59, Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
>> wrote:
>> >
>> > On some platforms, energy efficient ethernet with rtl8211 devices
>> > is
>> > causing issue, like throughput drop or broken link.
>> >
>> > This was reported on the OdroidC2 (DWMAC + RTL8211F). While the
>> > issue root
>> > cause is not fully understood yet, disabling EEE advertisement
>> > prevent auto
>> > negotiation from enabling EEE.
>> >
>> > This patch provides options to disable 1000T and 100TX EEE
>> > advertisement
>> > individually for the realtek phys supporting this feature.
>> >
>> > Reported-by: Martin Blumenstingl <martin.blumenstingl-gM/Ye1E23myhRSP0FMvGiw@public.gmane.org
>> > m>
>> > Cc: Giuseppe Cavallaro <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>
>> > Cc: Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
>> > Signed-off-by: Jerome Brunet <jbrunet-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
>> > Signed-off-by: Neil Armstrong <narmstrong-rdvid1DuHRBWk0Htik3J/w@public.gmane.org>
>> > Tested-by: Andre Roth <neolynx-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>> > ---
>> >  drivers/net/phy/realtek.c | 65
>> > ++++++++++++++++++++++++++++++++++++++++++++++-
>> >  1 file changed, 64 insertions(+), 1 deletion(-)
>> >
>> > diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
>> > index aadd6e9f54ad..77235fd5faaf 100644
>> > --- a/drivers/net/phy/realtek.c
>> > +++ b/drivers/net/phy/realtek.c
>> > @@ -15,6 +15,12 @@
>> >   */
>> >  #include <linux/phy.h>
>> >  #include <linux/module.h>
>> > +#include <linux/of.h>
>> > +
>> > +struct rtl8211x_phy_priv {
>> > +       bool eee_1000t_disable;
>> > +       bool eee_100tx_disable;
>> > +};
>> >
>> >  #define RTL821x_PHYSR          0x11
>> >  #define RTL821x_PHYSR_DUPLEX   0x2000
>> > @@ -93,12 +99,44 @@ static int rtl8211f_config_intr(struct
>> > phy_device *phydev)
>> >         return err;
>> >  }
>> >
>> > +static void rtl8211x_clear_eee_adv(struct phy_device *phydev)
>> > +{
>> > +       struct rtl8211x_phy_priv *priv = phydev->priv;
>> > +       u16 val;
>> > +
>> > +       if (priv->eee_1000t_disable || priv->eee_100tx_disable) {
>> > +               val = phy_read_mmd_indirect(phydev,
>> > MDIO_AN_EEE_ADV,
>> > +                                           MDIO_MMD_AN);
>> > +
>> > +               if (priv->eee_1000t_disable)
>> > +                       val &= ~MDIO_AN_EEE_ADV_1000T;
>> > +               if (priv->eee_100tx_disable)
>> > +                       val &= ~MDIO_AN_EEE_ADV_100TX;
>> > +
>> > +               phy_write_mmd_indirect(phydev, MDIO_AN_EEE_ADV,
>> > +                                      MDIO_MMD_AN, val);
>> > +       }
>> > +}
>> > +
>> > +static int rtl8211x_config_init(struct phy_device *phydev)
>> > +{
>> > +       int ret;
>> > +
>> > +       ret = genphy_config_init(phydev);
>> > +       if (ret < 0)
>> > +               return ret;
>> > +
>> > +       rtl8211x_clear_eee_adv(phydev);
>> > +
>> > +       return 0;
>> > +}
>> > +
>> >  static int rtl8211f_config_init(struct phy_device *phydev)
>> >  {
>> >         int ret;
>> >         u16 reg;
>> >
>> > -       ret = genphy_config_init(phydev);
>> > +       ret = rtl8211x_config_init(phydev);
>> >         if (ret < 0)
>> >                 return ret;
>> >
>> > @@ -115,6 +153,26 @@ static int rtl8211f_config_init(struct
>> > phy_device *phydev)
>> >         return 0;
>> >  }
>> >
>> > +static int rtl8211x_phy_probe(struct phy_device *phydev)
>> > +{
>> > +       struct device *dev = &phydev->mdio.dev;
>> > +       struct device_node *of_node = dev->of_node;
>> > +       struct rtl8211x_phy_priv *priv;
>> > +
>> > +       priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
>> > +       if (!priv)
>> > +               return -ENOMEM;
>> > +
>> > +       priv->eee_1000t_disable =
>> > +               of_property_read_bool(of_node, "realtek,disable-
>> > eee-1000t");
>> > +       priv->eee_100tx_disable =
>> > +               of_property_read_bool(of_node, "realtek,disable-
>> > eee-100tx");
>> > +
>> > +       phydev->priv = priv;
>> > +
>> > +       return 0;
>> > +}
>> > +
>> >  static struct phy_driver realtek_drvs[] = {
>> >         {
>> >                 .phy_id         = 0x00008201,
>> > @@ -140,7 +198,9 @@ static struct phy_driver realtek_drvs[] = {
>> >                 .phy_id_mask    = 0x001fffff,
>> >                 .features       = PHY_GBIT_FEATURES,
>> >                 .flags          = PHY_HAS_INTERRUPT,
>> > +               .probe          = &rtl8211x_phy_probe,
>> >                 .config_aneg    = genphy_config_aneg,
>> > +               .config_init    = &rtl8211x_config_init,
>> >                 .read_status    = genphy_read_status,
>> >                 .ack_interrupt  = rtl821x_ack_interrupt,
>> >                 .config_intr    = rtl8211e_config_intr,
>> > @@ -152,7 +212,9 @@ static struct phy_driver realtek_drvs[] = {
>> >                 .phy_id_mask    = 0x001fffff,
>> >                 .features       = PHY_GBIT_FEATURES,
>> >                 .flags          = PHY_HAS_INTERRUPT,
>> > +               .probe          = &rtl8211x_phy_probe,
>> >                 .config_aneg    = &genphy_config_aneg,
>> > +               .config_init    = &rtl8211x_config_init,
>> >                 .read_status    = &genphy_read_status,
>> >                 .ack_interrupt  = &rtl821x_ack_interrupt,
>> >                 .config_intr    = &rtl8211e_config_intr,
>> > @@ -164,6 +226,7 @@ static struct phy_driver realtek_drvs[] = {
>> >                 .phy_id_mask    = 0x001fffff,
>> >                 .features       = PHY_GBIT_FEATURES,
>> >                 .flags          = PHY_HAS_INTERRUPT,
>> > +               .probe          = &rtl8211x_phy_probe,
>> >                 .config_aneg    = &genphy_config_aneg,
>> >                 .config_init    = &rtl8211f_config_init,
>> >                 .read_status    = &genphy_read_status,
>> > --
>> > 2.7.4
>> >
>>
>> How about adding callback functionality for .soft_reset to handle
>> BMCR
>> where we update the Auto-Negotiation for the phy,
>> as per the datasheet of the rtl8211f.
>
> I'm not sure I understand how this would help with our issue (and EEE).
> Am I missing something or is it something unrelated that you would like
> to see happening on this driver ?
>
[snip]

I was just tying other phy module to understand the feature.
But in order to improve  the throughput I tried to integrate blow u-boot commit.

commit 3d6af748ebd831524cb22a29433e9092af469ec7
Author: Shengzhou Liu <Shengzhou.Liu-KZfg59tc24xl57MIdRCFDg@public.gmane.org>
Date:   Thu Mar 12 18:54:59 2015 +0800

    net/phy: Add support for realtek RTL8211F

    RTL8211F has different registers from RTL8211E.
    This patch adds support for RTL8211F PHY which
    can be found on Freescale's T1023 RDB board.

And added the similar functionality to  .config_aneg    = &rtl8211f_config_aneg,

And I seem to have better results in through put with periodic drop
but it recovers.
-----
odroid@odroid64:~$ iperf3 -c 10.0.0.102 -p 2006 -i 1 -t 100 -V
iperf 3.0.11
Linux odroid64 4.9.0-rc5-xc2ml #18 SMP PREEMPT Thu Nov 17 22:56:00 IST
2016 aarch64 aarch64 aarch64 GNU/Linux
Time: Thu, 17 Nov 2016 17:35:25 GMT
Connecting to host 10.0.0.102, port 2006
      Cookie: odroid64.1479404125.404729.3b45146e7
      TCP MSS: 1448 (default)
[  4] local 10.0.0.105 port 40238 connected to 10.0.0.102 port 2006
Starting Test: protocol: TCP, 1 streams, 131072 byte blocks, omitting
0 seconds, 100 second test
[ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
[  4]   0.00-1.00   sec   114 MBytes   952 Mbits/sec    0    368 KBytes
[  4]   1.00-2.00   sec   112 MBytes   937 Mbits/sec    0    368 KBytes
[  4]   2.00-3.00   sec   111 MBytes   935 Mbits/sec    0    368 KBytes
[  4]   3.00-4.00   sec   112 MBytes   936 Mbits/sec    0    368 KBytes
[  4]   4.00-5.00   sec   112 MBytes   939 Mbits/sec    0    368 KBytes
[  4]   5.00-6.00   sec   112 MBytes   936 Mbits/sec    0    368 KBytes
[  4]   6.00-7.00   sec   111 MBytes   933 Mbits/sec    0    368 KBytes
[  4]   7.00-8.00   sec   112 MBytes   942 Mbits/sec    0    368 KBytes
[  4]   8.00-9.00   sec   111 MBytes   935 Mbits/sec    0    368 KBytes
[  4]   9.00-10.00  sec   111 MBytes   932 Mbits/sec    0    368 KBytes
[  4]  10.00-11.00  sec   112 MBytes   937 Mbits/sec    0    368 KBytes
[  4]  11.00-12.00  sec   111 MBytes   935 Mbits/sec    0    368 KBytes
[  4]  12.00-13.00  sec   112 MBytes   938 Mbits/sec    0    368 KBytes
[  4]  13.00-14.00  sec   112 MBytes   940 Mbits/sec    0    368 KBytes
[  4]  14.00-15.00  sec   111 MBytes   934 Mbits/sec    0    368 KBytes
[  4]  15.00-16.00  sec   111 MBytes   935 Mbits/sec    0    368 KBytes
[  4]  16.00-17.00  sec   112 MBytes   939 Mbits/sec    0    368 KBytes
[  4]  17.00-18.00  sec   112 MBytes   936 Mbits/sec    0    368 KBytes
[  4]  18.00-19.00  sec   111 MBytes   934 Mbits/sec    0    368 KBytes
[  4]  19.00-20.00  sec   112 MBytes   940 Mbits/sec    0    368 KBytes
[  4]  20.00-21.00  sec   111 MBytes   933 Mbits/sec    0    368 KBytes
[  4]  21.00-22.00  sec   112 MBytes   941 Mbits/sec    0    368 KBytes
[  4]  22.00-23.00  sec   111 MBytes   931 Mbits/sec    0    368 KBytes
[  4]  23.00-24.00  sec   112 MBytes   938 Mbits/sec    0    368 KBytes
[  4]  24.00-25.00  sec   112 MBytes   938 Mbits/sec    0    368 KBytes
[  4]  25.00-26.00  sec   111 MBytes   934 Mbits/sec    0    368 KBytes
[  4]  26.00-27.00  sec   112 MBytes   940 Mbits/sec    0    368 KBytes
[  4]  27.00-28.00  sec   112 MBytes   936 Mbits/sec    0    368 KBytes
[  4]  28.00-29.00  sec   111 MBytes   934 Mbits/sec    0    368 KBytes
[  4]  29.00-30.00  sec   112 MBytes   937 Mbits/sec    0    368 KBytes
[  4]  30.00-31.00  sec   111 MBytes   934 Mbits/sec    0    368 KBytes
[  4]  31.00-32.00  sec   112 MBytes   942 Mbits/sec    0    368 KBytes
[  4]  32.00-33.00  sec   111 MBytes   933 Mbits/sec    0    368 KBytes
[  4]  33.00-34.00  sec   111 MBytes   935 Mbits/sec    0    368 KBytes
[  4]  34.00-35.00  sec   112 MBytes   941 Mbits/sec    0    368 KBytes
[  4]  35.00-36.00  sec   107 MBytes   896 Mbits/sec    0    368 KBytes
[  4]  36.00-37.00  sec  0.00 Bytes  0.00 bits/sec    2   1.41 KBytes
[  4]  37.00-38.00  sec  0.00 Bytes  0.00 bits/sec    1   1.41 KBytes
[  4]  38.00-39.00  sec  0.00 Bytes  0.00 bits/sec    0   1.41 KBytes
[  4]  39.00-40.00  sec  38.0 MBytes   319 Mbits/sec    1    385 KBytes
[  4]  40.00-41.00  sec   112 MBytes   939 Mbits/sec    0    385 KBytes
[  4]  41.00-42.00  sec   112 MBytes   939 Mbits/sec    0    385 KBytes
[  4]  42.00-43.00  sec   112 MBytes   937 Mbits/sec    0    385 KBytes
[  4]  43.00-44.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  44.00-45.00  sec   112 MBytes   939 Mbits/sec    0    385 KBytes
[  4]  45.00-46.00  sec   112 MBytes   939 Mbits/sec    0    385 KBytes
[  4]  46.00-47.00  sec   111 MBytes   931 Mbits/sec    0    385 KBytes
[  4]  47.00-48.00  sec   112 MBytes   936 Mbits/sec    0    385 KBytes
[  4]  48.00-49.00  sec   112 MBytes   939 Mbits/sec    0    385 KBytes
[  4]  49.00-50.00  sec   112 MBytes   936 Mbits/sec    0    385 KBytes
[  4]  50.00-51.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  51.00-52.00  sec   111 MBytes   934 Mbits/sec    0    385 KBytes
[  4]  52.00-53.00  sec   112 MBytes   941 Mbits/sec    0    385 KBytes
[  4]  53.00-54.00  sec   112 MBytes   937 Mbits/sec    0    385 KBytes
[  4]  54.00-55.00  sec   111 MBytes   930 Mbits/sec    0    385 KBytes
[  4]  55.00-56.00  sec   112 MBytes   941 Mbits/sec    0    385 KBytes
[  4]  56.00-57.00  sec   112 MBytes   936 Mbits/sec    0    385 KBytes
[  4]  57.00-58.00  sec   111 MBytes   933 Mbits/sec    0    385 KBytes
[  4]  58.00-59.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  59.00-60.00  sec   112 MBytes   940 Mbits/sec    0    385 KBytes
[  4]  60.00-61.00  sec   112 MBytes   936 Mbits/sec    0    385 KBytes
[  4]  61.00-62.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  62.00-63.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  63.00-64.00  sec   112 MBytes   938 Mbits/sec    0    385 KBytes
[  4]  64.00-65.00  sec   111 MBytes   932 Mbits/sec    0    385 KBytes
[  4]  65.00-66.00  sec   112 MBytes   940 Mbits/sec    0    385 KBytes
[  4]  66.00-67.00  sec   112 MBytes   938 Mbits/sec    0    385 KBytes
[  4]  67.00-68.00  sec   111 MBytes   934 Mbits/sec    0    385 KBytes
[  4]  68.00-69.00  sec   111 MBytes   933 Mbits/sec    0    385 KBytes
[  4]  69.00-70.00  sec   112 MBytes   937 Mbits/sec    0    385 KBytes
[  4]  70.00-71.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  71.00-72.00  sec   112 MBytes   941 Mbits/sec    0    385 KBytes
[  4]  72.00-73.00  sec   111 MBytes   933 Mbits/sec    0    385 KBytes
[  4]  73.00-74.00  sec   112 MBytes   939 Mbits/sec    0    385 KBytes
[  4]  74.00-75.00  sec   111 MBytes   934 Mbits/sec    0    385 KBytes
[  4]  75.00-76.00  sec   111 MBytes   934 Mbits/sec    0    385 KBytes
[  4]  76.00-77.00  sec   112 MBytes   937 Mbits/sec    0    385 KBytes
[  4]  77.00-78.00  sec   112 MBytes   938 Mbits/sec    0    385 KBytes
[  4]  78.00-79.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  79.00-80.00  sec   111 MBytes   934 Mbits/sec    0    385 KBytes
[  4]  80.00-81.00  sec   112 MBytes   939 Mbits/sec    0    385 KBytes
[  4]  81.00-82.00  sec   112 MBytes   936 Mbits/sec    0    385 KBytes
[  4]  82.00-83.00  sec   111 MBytes   934 Mbits/sec    0    385 KBytes
[  4]  83.00-84.00  sec   112 MBytes   937 Mbits/sec    0    385 KBytes
[  4]  84.00-85.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  85.00-86.00  sec   112 MBytes   937 Mbits/sec    0    385 KBytes
[  4]  86.00-87.00  sec   112 MBytes   939 Mbits/sec    0    385 KBytes
[  4]  87.00-88.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  88.00-89.00  sec   112 MBytes   937 Mbits/sec    0    385 KBytes
[  4]  89.00-90.00  sec   112 MBytes   936 Mbits/sec    0    385 KBytes
[  4]  90.00-91.00  sec   112 MBytes   937 Mbits/sec    0    385 KBytes
[  4]  91.00-92.00  sec   111 MBytes   934 Mbits/sec    0    385 KBytes
[  4]  92.00-93.00  sec   112 MBytes   939 Mbits/sec    0    385 KBytes
[  4]  93.00-94.00  sec   111 MBytes   935 Mbits/sec    0    385 KBytes
[  4]  94.00-95.00  sec   112 MBytes   936 Mbits/sec    0    385 KBytes
[  4]  95.00-96.00  sec   112 MBytes   936 Mbits/sec    0    385 KBytes
[  4]  96.00-97.00  sec   112 MBytes   936 Mbits/sec    0    385 KBytes
[  4]  97.00-98.00  sec   113 MBytes   945 Mbits/sec    0    559 KBytes
[  4]  98.00-99.00  sec   112 MBytes   937 Mbits/sec    0    559 KBytes
[  4]  99.00-100.00 sec   111 MBytes   928 Mbits/sec    0    559 KBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
Test Complete. Summary Results:
[ ID] Interval           Transfer     Bandwidth       Retr
[  4]   0.00-100.00 sec  10.5 GBytes   902 Mbits/sec    4             sender
[  4]   0.00-100.00 sec  10.5 GBytes   902 Mbits/sec                  receiver
CPU Utilization: local/sender 5.6% (0.2%u/5.4%s), remote/receiver
17.1% (1.2%u/15.9%s)

Can your confirm this at your end.
Once confirm I will try to send this as a fix for this issue.

-Best Regards
Anand Moon
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
