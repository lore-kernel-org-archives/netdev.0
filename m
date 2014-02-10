From: Belisko Marek <marek.belisko@gmail.com>
Subject: Re: [PATCH] net: rfkill-regulator: Add devicetree support.
Date: Mon, 10 Feb 2014 22:35:02 +0100
Message-ID: <CAAfyv34Mh8nkZ19Ba0J9Ag39mz8jDCrO9m5x+UXQSF9Uyr5pkQ@mail.gmail.com>
References: <1391802529-29861-1-git-send-email-marek@goldelico.com>
	<20140210101842.GS25314@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "robh+dt@kernel.org" <robh+dt@kernel.org>,
	Pawel Moll <Pawel.Moll@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"rob@landley.net" <rob@landley.net>,
	"linville@tuxdriver.com" <linville@tuxdriver.com>,
	"johannes@sipsolutions.net" <johannes@sipsolutions.net>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"grant.likely@linaro.org" <grant.likely@linaro.org>,
	"neilb@suse.de" <neilb@suse.de>,
	"hns@goldelico.com" <hns@goldelico.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <20140210101842.GS25314@e106331-lin.cambridge.arm.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 10, 2014 at 11:18 AM, Mark Rutland <mark.rutland@arm.com> wrote:
> On Fri, Feb 07, 2014 at 07:48:49PM +0000, Marek Belisko wrote:
>> Signed-off-by: NeilBrown <neilb@suse.de>
>> Signed-off-by: Marek Belisko <marek@goldelico.com>
>> ---
>> Based on Neil's patch and extend for documentation and bindings include.
>>
>>  .../bindings/net/rfkill/rfkill-relugator.txt       | 28 ++++++++++++++++
>>  include/dt-bindings/net/rfkill-regulator.h         | 23 +++++++++++++
>>  net/rfkill/rfkill-regulator.c                      | 38 ++++++++++++++++++++++
>>  3 files changed, 89 insertions(+)
>>  create mode 100644 Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
>>  create mode 100644 include/dt-bindings/net/rfkill-regulator.h
>>
>> diff --git a/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
>> new file mode 100644
>> index 0000000..cdb7dd7
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/rfkill/rfkill-relugator.txt
>> @@ -0,0 +1,28 @@
>> +Regulator consumer for rfkill devices
>
> What exactly is an "rfkill" device? How is it used? How does it relate
> to other devices in the DT?
>
> To me, this looks like a leak of a Linux abstraction.
>
>> +
>> +Required properties:
>> +- compatible   : Must be "rfkill-regulator".
>> +- label  : Name of rfkill device.
>
> What's this for? Why does this need a label in the DT? Surely this can
> be implied by the relationship to a particular radio device?
This label is used by rfkill (converted to pdata->name in probe
function) and used for displaying.
Maybe label isn't correct name for that purpose.
>
>> +- type  : Type of rfkill device.
>> +
>> +Possible values (defined in include/dt-bindings/net/rfkill-regulator.h):
>> +     RFKILL_TYPE_ALL
>> +     RFKILL_TYPE_WLAN
>> +     RFKILL_TYPE_BLUETOOTH
>> +     RFKILL_TYPE_UWB
>> +     RFKILL_TYPE_WIMAX
>> +     RFKILL_TYPE_WWAN
>> +     RFKILL_TYPE_GPS
>> +     RFKILL_TYPE_FM
>> +     RFKILL_TYPE_NFC
>
> What do these mean? Why can these not be implied by a relationship to
> any devices of these particular types?
I did platform data -> DT mapping 1 : 1. Maybe we don't need to export
those to separate
include file and only use raw number instead.
>
>> +
>> +- vrfkill-supply - regulator device.
>
> Why isn't this described on the radio revice node? It's a supply to the
> radio, not to the rfkill concept.
rfkill-regulator in probe check for vrfkill regulator so I've added it
to description as without that rfkill-regulator doesn't make sense.
>
>> +
>> +Example:
>> +     gps-rfkill {
>> +             compatible = "rfkill-regulator";
>> +             label = "GPS";
>> +             type = <RFKILL_TYPE_GPS>;
>> +             vrfkill-supply = <&reg>;
>> +     };
>
> Why is this not bound to the particular GPS device in some way?
We can do something like:
gps-device {
    compatible = "my-desired-gps";
    <other device properties>
    rfkill = <&gps-rfkill>;
};
>
> What if I have more than one of any of the types of device this
> supports, which device is this expected to control?
rfkill-regulator is linked with regulator so if you have another
device it is probably controlled
with another regulator.

>
> Why is it described as a separate device in the device tree at all?
>
> I do not think this binding is the right way to describe this.
Some time ago was posted rfkill-gpio DT binding conversion and was
using the nearly the same bindings as
we propose and there was no issue with that.

>
> Thanks,
> Mark.
>
>> +
>> diff --git a/include/dt-bindings/net/rfkill-regulator.h b/include/dt-bindings/net/rfkill-regulator.h
>> new file mode 100644
>> index 0000000..ae32273
>> --- /dev/null
>> +++ b/include/dt-bindings/net/rfkill-regulator.h
>> @@ -0,0 +1,23 @@
>> +/*
>> + * This header provides macros for rfkill-regulator bindings.
>> + *
>> + * Copyright (C) 2014 Marek Belisko <marek@goldelico.com>
>> + *
>> + * GPLv2 only
>> + */
>> +
>> +#ifndef __DT_BINDINGS_RFKILL_REGULATOR_H__
>> +#define __DT_BINDINGS_RFKILL_REGULATOR_H__
>> +
>> +
>> +#define RFKILL_TYPE_ALL              (0)
>> +#define RFKILL_TYPE_WLAN     (1)
>> +#define RFKILL_TYPE_BLUETOOTH        (2)
>> +#define RFKILL_TYPE_UWB              (3)
>> +#define RFKILL_TYPE_WIMAX    (4)
>> +#define RFKILL_TYPE_WWAN     (5)
>> +#define RFKILL_TYPE_GPS              (6)
>> +#define RFKILL_TYPE_FM               (7)
>> +#define RFKILL_TYPE_NFC              (8)
>> +
>> +#endif /* __DT_BINDINGS_RFKILL_REGULATOR_H__ */
>> diff --git a/net/rfkill/rfkill-regulator.c b/net/rfkill/rfkill-regulator.c
>> index cf5b145..a04aff8 100644
>> --- a/net/rfkill/rfkill-regulator.c
>> +++ b/net/rfkill/rfkill-regulator.c
>> @@ -19,6 +19,7 @@
>>  #include <linux/regulator/consumer.h>
>>  #include <linux/rfkill.h>
>>  #include <linux/rfkill-regulator.h>
>> +#include <linux/of_platform.h>
>>
>>  struct rfkill_regulator_data {
>>       struct rfkill *rf_kill;
>> @@ -57,6 +58,31 @@ static struct rfkill_ops rfkill_regulator_ops = {
>>       .set_block = rfkill_regulator_set_block,
>>  };
>>
>> +#ifdef CONFIG_OF
>> +static struct rfkill_regulator_platform_data *
>> +rfkill_regulator_parse_pdata(struct device *dev)
>> +{
>> +     struct rfkill_regulator_platform_data *pdata;
>> +     struct device_node *np = dev->of_node;
>> +     u32 num;
>> +     if (!np)
>> +             return NULL;
>> +     pdata = devm_kzalloc(dev, sizeof(*pdata), GFP_KERNEL);
>> +     if (!pdata)
>> +             return NULL;
>> +     if (of_property_read_u32(np, "type", &num) == 0)
>> +             pdata->type = num;
>> +     of_property_read_string(np, "label", &pdata->name);
>> +     return pdata;
>> +}
>> +#else
>> +static inline struct rfkill_regulator_platform_data *
>> +rfkill_regulator_parse_pdata(struct device *dev)
>> +{
>> +     return NULL;
>> +}
>> +#endif
>> +
>>  static int rfkill_regulator_probe(struct platform_device *pdev)
>>  {
>>       struct rfkill_regulator_platform_data *pdata = pdev->dev.platform_data;
>> @@ -65,6 +91,9 @@ static int rfkill_regulator_probe(struct platform_device *pdev)
>>       struct rfkill *rf_kill;
>>       int ret = 0;
>>
>> +     if (!pdata)
>> +             pdata = rfkill_regulator_parse_pdata(&pdev->dev);
>> +
>>       if (pdata == NULL) {
>>               dev_err(&pdev->dev, "no platform data\n");
>>               return -ENODEV;
>> @@ -137,12 +166,21 @@ static int rfkill_regulator_remove(struct platform_device *pdev)
>>       return 0;
>>  }
>>
>> +#ifdef CONFIG_OF
>> +static const struct of_device_id rfkill_regulator_match[] = {
>> +     {.compatible = "rfkill-regulator"},
>> +     {}
>> +};
>> +MODULE_DEVICE_TABLE(of, rfkill_regulator_match);
>> +#endif
>> +
>>  static struct platform_driver rfkill_regulator_driver = {
>>       .probe = rfkill_regulator_probe,
>>       .remove = rfkill_regulator_remove,
>>       .driver = {
>>               .name = "rfkill-regulator",
>>               .owner = THIS_MODULE,
>> +             .of_match_table = of_match_ptr(rfkill_regulator_match),
>>       },
>>  };
>>
>> --
>> 1.8.3.2
>>
>>

BR,

marek

-- 
as simple and primitive as possible
-------------------------------------------------
Marek Belisko - OPEN-NANDRA
Freelance Developer

Ruska Nova Ves 219 | Presov, 08005 Slovak Republic
Tel: +421 915 052 184
skype: marekwhite
twitter: #opennandra
web: http://open-nandra.com
