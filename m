From: Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 3/3] net: phy: realtek: add RTL8201F phy-id and functions
Date: Sat, 9 Sep 2017 09:03:05 +0530
Message-ID: <CAJe_ZhciWBhw5npxEjTUGw2duS7DSfhzP5nzAOy_ig4-1XcPWw@mail.gmail.com>
References: <1504875731-3680-1-git-send-email-hayashi.kunihiko@socionext.com>
 <1504875731-3680-4-git-send-email-hayashi.kunihiko@socionext.com> <4173a876-3cff-205a-ce87-ce049f419aa0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>, Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
        "linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org"
        <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        lkml <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Devicetree List <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Masahiro Yamada <yamada.masahiro-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>,
        Masami Hiramatsu <masami.hiramatsu-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
        Jongsung Kim <neidhard.kim-Hm3cg6mZ9cc@public.gmane.org>
To: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4173a876-3cff-205a-ce87-ce049f419aa0-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 9 September 2017 at 00:21, Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> On 09/08/2017 06:02 AM, Kunihiko Hayashi wrote:
>> From: Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>>
>> Add RTL8201F phy-id and the related functions to the driver.
>>
>> The original patch is as follows:
>> https://patchwork.kernel.org/patch/2538341/
>>
>> Signed-off-by: Jongsung Kim <neidhard.kim-Hm3cg6mZ9cc@public.gmane.org>
>> Signed-off-by: Jassi Brar <jaswinder.singh-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
>> Signed-off-by: Kunihiko Hayashi <hayashi.kunihiko-uWyLwvC0a2jby3iVrkZq2A@public.gmane.org>
>> ---
>>  drivers/net/phy/realtek.c | 45 +++++++++++++++++++++++++++++++++++++++++++++
>>  1 file changed, 45 insertions(+)
>>
>> diff --git a/drivers/net/phy/realtek.c b/drivers/net/phy/realtek.c
>> index 9cbe645..d9974ce 100644
>> --- a/drivers/net/phy/realtek.c
>> +++ b/drivers/net/phy/realtek.c
>> @@ -29,10 +29,23 @@
>>  #define RTL8211F_PAGE_SELECT 0x1f
>>  #define RTL8211F_TX_DELAY    0x100
>>
>> +#define RTL8201F_ISR         0x1e
>> +#define RTL8201F_PAGE_SELECT 0x1f
>
> We have a page select register define for the RTL8211F right above, so
> surely we can make that a common definition?
>
That is just for the sake of consistency.
I mean RTL8211 wouldn't look neat among everything else RTL8201.

Also the page-select offsets just _happen_ to be same value...
RTL8211E_INER_LINK_STATUS and RTL8211F_INER_LINK_STATUS are very
different.

>> +#define RTL8201F_IER         0x13
>> +
>>  MODULE_DESCRIPTION("Realtek PHY driver");
>>  MODULE_AUTHOR("Johnson Leung");
>>  MODULE_LICENSE("GPL");
>>
>> +static int rtl8201_ack_interrupt(struct phy_device *phydev)
>> +{
>> +     int err;
>> +
>> +     err = phy_read(phydev, RTL8201F_ISR);
>> +
>> +     return (err < 0) ? err : 0;
>> +}
>> +
>>  static int rtl821x_ack_interrupt(struct phy_device *phydev)
>>  {
>>       int err;
>> @@ -54,6 +67,25 @@ static int rtl8211f_ack_interrupt(struct phy_device *phydev)
>>       return (err < 0) ? err : 0;
>>  }
>>
>> +static int rtl8201_config_intr(struct phy_device *phydev)
>> +{
>> +     int err;
>> +
>> +     /* switch to page 7 */
>> +     phy_write(phydev, RTL8201F_PAGE_SELECT, 0x7);
>> +
>> +     if (phydev->interrupts == PHY_INTERRUPT_ENABLED)
>> +             err = phy_write(phydev, RTL8201F_IER,
>> +                             BIT(13) | BIT(12) | BIT(11));
>
> Can you detail what bits 11, 12 and 13 do? Do they correspond to link,
> duplex and pause changes by any chance?
>
Sorry no idea. The datasheet would say, and other functions too use
such magic values.

>> +     else
>> +             err = phy_write(phydev, RTL8201F_IER, 0);
>> +
>> +     /* restore to default page 0 */
>> +     phy_write(phydev, RTL8201F_PAGE_SELECT, 0x0);
>> +
>> +     return err;
>> +}
>> +
>
> Other than that, LGTM:
>
> Reviewed-by: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>
Thank you.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
