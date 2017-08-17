From: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
Subject: Re: [PATCH v4 1/4] can: dev: Add support for limiting configured
 bitrate
Date: Thu, 17 Aug 2017 12:54:48 -0500
Message-ID: <b1082666-6cdf-374e-2c83-8d520e0996ad@ti.com>
References: <20170810005916.27163-1-fcooper@ti.com>
 <20170810005916.27163-2-fcooper@ti.com>
 <9a6f4fdf-a4f6-283b-0e5a-693cc7d263ef@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
        <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>, <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        <quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org>,
        <dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org>, <andrew-g2DYL2Zd6BY@public.gmane.org>,
        <socketcan-fJ+pQTUTwRTk1uMJSBkQmQ@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <9a6f4fdf-a4f6-283b-0e5a-693cc7d263ef-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org



On 08/10/2017 05:05 AM, Sergei Shtylyov wrote:
> Hello!
> 
> On 8/10/2017 3:59 AM, Franklin S Cooper Jr wrote:
> 
>> Various CAN or CAN-FD IP may be able to run at a faster rate than
>> what the transceiver the CAN node is connected to. This can lead to
>> unexpected errors. However, CAN transceivers typically have fixed
>> limitations and provide no means to discover these limitations at
>> runtime. Therefore, add support for a can-transceiver node that
>> can be reused by other CAN peripheral drivers to determine for both
>> CAN and CAN-FD what the max bitrate that can be used. If the user
>> tries to configure CAN to pass these maximum bitrates it will throw
>> an error.
>>
>> Signed-off-by: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
>> ---
>> Version 4 changes:
>> Used can-transceiver instead of fixed-transceiver.
>>
>>   drivers/net/can/dev.c   | 50
>> +++++++++++++++++++++++++++++++++++++++++++++++++
>>   include/linux/can/dev.h |  5 +++++
>>   2 files changed, 55 insertions(+)
>>
>> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
>> index 365a8cc..372108f 100644
>> --- a/drivers/net/can/dev.c
>> +++ b/drivers/net/can/dev.c
> [...]
>> @@ -814,6 +815,39 @@ int open_candev(struct net_device *dev)
>>   }
>>   EXPORT_SYMBOL_GPL(open_candev);
>>   +#ifdef CONFIG_OF
>> +/*
>> + * Common function that can be used to understand the limitation of
>> + * a transceiver when it provides no means to determine these
>> limitations
>> + * at runtime.
>> + */
>> +void of_can_transceiver(struct net_device *dev)
>> +{
>> +    struct device_node *dn;
>> +    struct can_priv *priv = netdev_priv(dev);
>> +    struct device_node *np;
>> +    unsigned int max_bitrate;
>> +    int ret;
>> +
>> +    np = dev->dev.parent->of_node;
> 
>    I'd do that as an initializer.

Ok
> 
>> +
>> +    dn = of_get_child_by_name(np, "can-transceiver");
>> +    if (!dn)
>> +        return;
>> +
>> +    max_bitrate = 0;
>> +    ret = of_property_read_u32(dn, "max-bitrate", &max_bitrate);
> 
>    I'd initialize max_bitrate to 0 as iff of_property_read_u32() fails,
> it'll leave the variable unset...>
>> +
>> +    if (max_bitrate > 0) {
> 
>    You risk checking unset variable here.

Four lines up I am already setting max_bitrate to a default value of 0.

> 
>> +        priv->max_bitrate = max_bitrate;
>> +        priv->is_bitrate_limited = true;
>> +    } else if (ret != -EINVAL) {
>> +        netdev_warn(dev, "Invalid value for transceiver max bitrate\n");
>> +    }
>> +}
>> +EXPORT_SYMBOL(of_can_transceiver);
>> +#endif
>> +
>>   /*
>>    * Common close function for cleanup before the device gets closed.
>>    *
> [...]
> 
> MBR, Sergei
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
