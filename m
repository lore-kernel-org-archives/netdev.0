From: Zhangfei Gao <zhangfei.gao-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 25 Mar 2014 12:06:31 +0800
Message-ID: <CAMj5BkjbrHevQhf4kbFhN5THHLw4nQwdpt2h6WJH02mKhdq8oQ@mail.gmail.com>
References: <1395670496-17381-1-git-send-email-zhangfei.gao@linaro.org>
	<1395670496-17381-4-git-send-email-zhangfei.gao@linaro.org>
	<13743364.WZtdi2BZb3@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-arm-kernel <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Russell King - ARM Linux <linux-lFZ/pmaqli7XmaaqVzeoHQ@public.gmane.org>,
	Sergei Shtylyov <sergei.shtylyov-M4DtvfQ/ZS1MRgGoP+s0PdBPR1lH4CV8@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Zhangfei Gao <zhangfei.gao-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <13743364.WZtdi2BZb3@wuerfel>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Dear Arnd

On Mon, Mar 24, 2014 at 11:18 PM, Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org> wrote:
> On Monday 24 March 2014 22:14:56 Zhangfei Gao wrote:
>
>> +
>> +static void hip04_tx_reclaim(struct net_device *ndev, bool force)
>> +{
>> +     struct hip04_priv *priv = netdev_priv(ndev);
>> +     unsigned tx_head = priv->tx_head;
>> +     unsigned tx_tail = priv->tx_tail;
>> +     struct tx_desc *desc = &priv->tx_desc[priv->tx_tail];
>> +
>> +     while (tx_tail != tx_head) {
>> +             if (desc->send_addr != 0) {
>> +                     if (force)
>> +                             desc->send_addr = 0;
>> +                     else
>> +                             break;
>> +             }
>> +             if (priv->tx_phys[tx_tail]) {
>> +                     dma_unmap_single(&ndev->dev, priv->tx_phys[tx_tail],
>> +                             priv->tx_skb[tx_tail]->len, DMA_TO_DEVICE);
>> +                     priv->tx_phys[tx_tail] = 0;
>> +             }
>> +             dev_kfree_skb_irq(priv->tx_skb[tx_tail]);
>> +             priv->tx_skb[tx_tail] = NULL;
>> +             tx_tail = TX_NEXT(tx_tail);
>> +             priv->tx_count--;
>> +     }
>> +     priv->tx_tail = tx_tail;
>> +}
>
> I think you still need to find a solution to ensure that the tx reclaim is
> called eventually through a method other than start_xmit.

In the iperf stress test, if move reclaim to poll, there is some
error, sometimes sending zero packets.
While keep reclaim in the xmit to reclaim transmitted packets looks
stable in the test,
There TX_DESC_NUM desc can be used.

>
>> +
>> +     priv->map = syscon_regmap_lookup_by_compatible("hisilicon,hip04-ppe");
>> +     if (IS_ERR(priv->map)) {
>> +             dev_warn(d, "no hisilicon,hip04-ppe\n");
>> +             ret = PTR_ERR(priv->map);
>> +             goto init_fail;
>> +     }
>> +
>> +     n = of_parse_phandle(node, "port-handle", 0);
>> +     if (n) {
>> +             ret = of_property_read_u32(n, "reg", &priv->port);
>> +             if (ret) {
>> +                     dev_warn(d, "no reg info\n");
>> +                     goto init_fail;
>> +             }
>> +
>> +             ret = of_property_read_u32(n, "channel", &priv->chan);
>> +             if (ret) {
>> +                     dev_warn(d, "no channel info\n");
>> +                     goto init_fail;
>> +             }
>> +     } else {
>> +             dev_warn(d, "no port-handle\n");
>> +             ret = -EINVAL;
>> +             goto init_fail;
>> +     }
>
> Doing the lookup by "compatible" string doesn't really help you
> at solve the problem of single-instance ppe at all, because that
> function will only ever look at the first one. Use
> syscon_regmap_lookup_by_phandle instead and pass the phandle
> you get from the "port-handle" property.

Did some experiment, the only ppe base is got from syscon probe.
And looking up by "compatible" did work for three controllers at the same time.

>
> Also, since you decided to treat the ppe as a dump regmap, I would
> recommend moving the 'reg' and 'channel' properties into arguments
> of the port-handle link, and retting rid of the child nodes of
> the ppe, like:
>
> +       ppe: ppe@28c0000 {
> +               compatible = "hisilicon,hip04-ppe", "syscon";
> +               reg = <0x28c0000 0x10000>;
> +       };
> +
> +       fe: ethernet@28b0000 {
> +               compatible = "hisilicon,hip04-mac";
> +               reg = <0x28b0000 0x10000>;
> +               interrupts = <0 413 4>;
> +               phy-mode = "mii";
> +               port-handle = <&ppe 0xf1 0>;
> +       };
>

Would you mind giving more hints about how to parse the args.
I am thinking of using of_parse_phandle_with_args, is that correct method?

Thanks
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
