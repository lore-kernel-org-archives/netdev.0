From: Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>
Subject: Re: [PATCH 1/4] can: dev: Add support for limiting configured bitrate
Date: Thu, 20 Jul 2017 12:52:12 +0300
Message-ID: <b04fea5c-c47b-4643-5305-090f5f17afe1@cogentembedded.com>
References: <20170719233654.25908-1-fcooper@ti.com>
 <20170719233654.25908-2-fcooper@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
        quentin.schulz-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, dev.kurt-yI9piX4KPfawT/RRk36CISFp6vIno51x@public.gmane.org,
        andrew-g2DYL2Zd6BY@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170719233654.25908-2-fcooper-l0cyMroinI0@public.gmane.org>
Content-Language: en-US
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello!

On 7/20/2017 2:36 AM, Franklin S Cooper Jr wrote:

> Various CAN or CAN-FD IP may be able to run at a faster rate than
> what the transceiver the CAN node is connected to. This can lead to
> unexpected errors. However, CAN transceivers typically have fixed
> limitations and provide no means to discover these limitations at
> runtime. Therefore, add support for a fixed-transceiver node that
> can be reused by other CAN peripheral drivers to determine for both
> CAN and CAN-FD what the max bitrate that can be used. If the user
> tries to configure CAN to pass these maximum bitrates it will throw
> an error.
> 
> Signed-off-by: Franklin S Cooper Jr <fcooper-l0cyMroinI0@public.gmane.org>
> ---
>   drivers/net/can/dev.c   | 48 ++++++++++++++++++++++++++++++++++++++++++++++++
>   include/linux/can/dev.h |  5 +++++
>   2 files changed, 53 insertions(+)
> 
> diff --git a/drivers/net/can/dev.c b/drivers/net/can/dev.c
> index 365a8cc..fbab87d 100644
> --- a/drivers/net/can/dev.c
> +++ b/drivers/net/can/dev.c
[...]
> @@ -814,6 +830,38 @@ int open_candev(struct net_device *dev)
>   }
>   EXPORT_SYMBOL_GPL(open_candev);
>   
> +#ifdef CONFIG_OF
> +void of_transceiver_is_fixed(struct net_device *dev)

    Strange name for a *void* function...
    Also, I think 'struct net_device *' variables are typically called 'ndev'.

> +{
> +	struct device_node *dn;
> +	struct can_priv *priv = netdev_priv(dev);
> +	u32 max_frequency;
> +	struct device_node *np;
> +
> +	np = dev->dev.parent->of_node;
> +
> +	/* New binding */
> +	dn = of_get_child_by_name(np, "fixed-transceiver");
> +	if (!dn)
> +		return;
> +
> +	of_property_read_u32(dn, "max-arbitration-speed", &max_frequency);

    In case this function fails, 'max_frequency' will have no value -- you'd 
better initialize it...

> +
> +	if (max_frequency > 0)
> +		priv->max_trans_arbitration_speed = max_frequency;
> +	else
> +		priv->max_trans_arbitration_speed = -1;
> +
> +	of_property_read_u32(dn, "max-data-speed", &max_frequency);

    Again, when that function fails, the variable will keep the value from the 
previous call...

[...]

MBR, Sergei
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
