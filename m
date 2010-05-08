From: Bryan Wu <bryan.wu@canonical.com>
Subject: Re: [PATCH 1/2] netdev/fec: fix performance impact from mdio poll
 operation
Date: Sat, 08 May 2010 18:07:30 +0800
Message-ID: <4BE537E2.6010809@canonical.com>
References: <1273199239-11057-1-git-send-email-bryan.wu@canonical.com>	 <1273199239-11057-2-git-send-email-bryan.wu@canonical.com> <i2l2acbd3e41005070906me50416bapd8154a567406b886@mail.gmail.com>
Reply-To: bryan.wu@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	Sascha Hauer <s.hauer@pengutronix.de>,
	Greg Ungerer <gerg@uclinux.org>,
	Amit Kucheria <amit.kucheria@canonical.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:47125 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752426Ab0EHKIA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 May 2010 06:08:00 -0400
In-Reply-To: <i2l2acbd3e41005070906me50416bapd8154a567406b886@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/08/2010 12:06 AM, Andy Fleming wrote:
> On Thursday, May 6, 2010, Bryan Wu<bryan.wu@canonical.com>  wrote:
>> BugLink: http://bugs.launchpad.net/bugs/546649
>> BugLink: http://bugs.launchpad.net/bugs/457878
>>
>> After introducing phylib supporting, users experienced performace drop. That is
>> because of the mdio polling operation of phylib. Use msleep to replace the busy
>> waiting cpu_relax() and remove the warning message.
>
> I'm a little confused by this patch.  In order to improve performance,
> you made the mdio functions fail silently?  Why are you getting
> timeouts at all?

 From the BugLink, we experienced a lot of error message about mdio_read 
timeout. Actually, the logical in this function is quite simple and I still have 
no idea about why mdio_read timeout. That might be hardware defect.

> The Phy lib is not going to respond well if an mdio
> write times out without returning an error.  And returning an error
> means the whole state machine has to reset, as a failed write is not
> something we currently handle gracefully.
>

Right, if we return error to phylib due to mdio read times out, the performance 
will drop a lot.

> Is it possible to use an interrupt to get the phy state change?  This
> would allow the phy lib to stop its incessant polling.  It doesn't
> solve the question of why it's timing out, though.
>

I'm going to try the interrupt, but fec driver is shared by several SoCs. It 
might be a little complicated and still cannot fix the timing out issue. Is 
there any example driver to use an interrupt to get the phy state change?

Thanks,
-Bryan

>>
>> Signed-off-by: Bryan Wu<bryan.wu@canonical.com>
>> Acked-by: Andy Whitcroft<apw@canonical.com>
>> ---
>>   drivers/net/fec.c |   45 +++++++++++++++++++++------------------------
>>   1 files changed, 21 insertions(+), 24 deletions(-)
>>
>> diff --git a/drivers/net/fec.c b/drivers/net/fec.c
>> index 2b1651a..9c58f6b 100644
>> --- a/drivers/net/fec.c
>> +++ b/drivers/net/fec.c
>> @@ -203,7 +203,7 @@ static void fec_stop(struct net_device *dev);
>>   #define FEC_MMFR_TA            (2<<  16)
>>   #define FEC_MMFR_DATA(v)       (v&  0xffff)
>>
>> -#define FEC_MII_TIMEOUT                10000
>> +#define FEC_MII_TIMEOUT                10
>>
>>   /* Transmitter timeout */
>>   #define TX_TIMEOUT (2 * HZ)
>> @@ -611,13 +611,29 @@ spin_unlock:
>>   /*
>>    * NOTE: a MII transaction is during around 25 us, so polling it...
>>    */
>> -static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
>> +static int fec_enet_mdio_poll(struct fec_enet_private *fep)
>>   {
>> -       struct fec_enet_private *fep = bus->priv;
>>          int timeout = FEC_MII_TIMEOUT;
>>
>>          fep->mii_timeout = 0;
>>
>> +       /* wait for end of transfer */
>> +       while (!(readl(fep->hwp + FEC_IEVENT)&  FEC_ENET_MII)) {
>> +               msleep(1);
>> +               if (timeout--<  0) {
>> +                       fep->mii_timeout = 1;
>> +                       break;
>> +               }
>> +       }
>> +
>> +       return 0;
>> +}
>> +
>> +static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
>> +{
>> +       struct fec_enet_private *fep = bus->priv;
>> +
>> +
>>          /* clear MII end of transfer bit*/
>>          writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
>>
>> @@ -626,15 +642,7 @@ static int fec_enet_mdio_read(struct mii_bus *bus, int mii_id, int regnum)
>>                  FEC_MMFR_PA(mii_id) | FEC_MMFR_RA(regnum) |
>>                  FEC_MMFR_TA, fep->hwp + FEC_MII_DATA);
>>
>> -       /* wait for end of transfer */
>> -       while (!(readl(fep->hwp + FEC_IEVENT)&  FEC_ENET_MII)) {
>> -               cpu_relax();
>> -               if (timeout--<  0) {
>> -                       fep->mii_timeout = 1;
>> -                       printk(KERN_ERR "FEC: MDIO read timeout\n");
>> -                       return -ETIMEDOUT;
>> -               }
>> -       }
>> +       fec_enet_mdio_poll(fep);
>>
>>          /* return value */
>>          return FEC_MMFR_DATA(readl(fep->hwp + FEC_MII_DATA));
>> @@ -644,9 +652,6 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
>>                             u16 value)
>>   {
>>          struct fec_enet_private *fep = bus->priv;
>> -       int timeout = FEC_MII_TIMEOUT;
>> -
>> -       fep->mii_timeout = 0;
>>
>>          /* clear MII end of transfer bit*/
>>          writel(FEC_ENET_MII, fep->hwp + FEC_IEVENT);
>> @@ -657,15 +662,7 @@ static int fec_enet_mdio_write(struct mii_bus *bus, int mii_id, int regnum,
>>                  FEC_MMFR_TA | FEC_MMFR_DATA(value),
>>                  fep->hwp + FEC_MII_DATA);
>>
>> -       /* wait for end of transfer */
>> -       while (!(readl(fep->hwp + FEC_IEVENT)&  FEC_ENET_MII)) {
>> -               cpu_relax();
>> -               if (timeout--<  0) {
>> -                       fep->mii_timeout = 1;
>> -                       printk(KERN_ERR "FEC: MDIO write timeout\n");
>> -                       return -ETIMEDOUT;
>> -               }
>> -       }
>> +       fec_enet_mdio_poll(fep);
>>
>>          return 0;
>>   }
>> --
>> 1.7.0.1
>>
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>>
>
