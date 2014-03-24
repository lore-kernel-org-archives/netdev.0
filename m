From: Zhangfei Gao <zhangfei.gao@gmail.com>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Mon, 24 Mar 2014 16:17:42 +0800
Message-ID: <CAMj5Bkgc2ChK48QmqEEMEmxdF6iGZxMX0kVUqGFd8jYhEWCvOA@mail.gmail.com>
References: <1395132017-15928-1-git-send-email-zhangfei.gao@linaro.org>
	<4611515.XyVGvsaLcW@wuerfel>
	<CAMj5Bkiaw=BT_EUdjthPjgk_pp0z44yPjh4_AfHXqiJLUiDe=g@mail.gmail.com>
	<201403201531.20416.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Zhangfei Gao <zhangfei.gao@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f44.google.com ([74.125.83.44]:35140 "EHLO
	mail-ee0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936AbaCXIRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Mar 2014 04:17:43 -0400
In-Reply-To: <201403201531.20416.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Arnd

On Thu, Mar 20, 2014 at 10:31 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> On Thursday 20 March 2014, Zhangfei Gao wrote:
>> On Tue, Mar 18, 2014 at 7:25 PM, Arnd Bergmann <arnd@arndb.de> wrote:
>> > On Tuesday 18 March 2014 16:40:17 Zhangfei Gao wrote:
>> >
>> >> +
>> >> +static void __iomem *ppebase;
>> >
>> > The global 'ppebase' seems hacky. Isn't that a SoC-specific register area, while
>> > the rest of the driver is reusable across SoCs?
>> >
>> > What does 'ppe' stand for?
>> >
>> > What if there are multiple instances of this, which each have their own ppebase?
>>
>> In this specific platform,
>> ppe is the only module controlling all the fifos for all the net controller.
>> And each controller connect to specific port.
>> ppe has 2048 channels, sharing by all the controller, only if not overlapped.
>>
>> So the static ppebase is required, which I don't like too.
>> Two inputs required, one is port, which is connect to the controller.
>> The other is start channel, currently I use id, and start channel is
>> RX_DESC_NUM * priv->id;  /* start_addr */
>
> Ok, thanks for the explanation!
>
I thought you are fine with "static void __iomem *ppebase" here.

>> >
>> >> +     if (!ppebase) {
>> >> +             struct device_node *n;
>> >> +
>> >> +             n = of_find_compatible_node(NULL, NULL, "hisilicon,hip04-ppebase");
>> >> +             if (!n) {
>> >> +                     ret = -EINVAL;
>> >> +                     netdev_err(ndev, "not find hisilicon,ppebase\n");
>> >> +                     goto init_fail;
>> >> +             }
>> >> +             ppebase = of_iomap(n, 0);
>> >> +     }
>> >
>> > How about using syscon_regmap_lookup_by_phandle() here? That way, you can have
>> > a more generic abstraction of the ppe, and stick the port and id in there as
>> > well, e.g.
>> >
>> >         ppe-syscon = <&hip04ppe 1 4>; // ppe, port, id

Even if using syscon_regmap_lookup_by_phandle, there still have static
struct regmap, since three controllers
share one regmap.

> It's probably a little simpler to avoid the sub-nodes and instead do
>
>>               ppe: ppe@28c0000 {
>>                         compatible = "hisilicon,hip04-ppe";
>>                         reg = <0x28c0000 0x10000>;
>>                         #address-cells = <1>;
>>                         #size-cells = <0>;
>>                 };
>>                 fe: ethernet@28b0000 {
>>                         compatible = "hisilicon,hip04-mac";
>>                         reg = <0x28b0000 0x10000>;
>>                         interrupts = <0 413 4>;
>>                         phy-mode = "mii";
>>                         port-handle = <&ppe 31>;
>>                 };
>
> In the code, I would create a simple ppe driver that exports
> a few functions. you need. In the ethernet driver probe() function,
> you should get a handle to the ppe using
>
>         /* look up "port-handle" property of the current device, find ppe and port */
>         struct hip04_ppe *ppe = hip04_ppe_get(dev->of_node);
>         if (IS_ERR(ppe))
>                 return PTR_ERR(ptr); /* this handles -EPROBE_DEFER */
>
> and then in other code you can just do
>
>         hip04_ppe_set_foo(priv->ppe, foo_config);
>
> This is a somewhat more high-level abstraction that syscon, which
> just gives you a 'struct regmap' structure for doing register-level
> configuration like you have today.
>

Do you mean create one additional file like ppe.c with some exported
function to remove the static ppebase?
Since the ppe is specifically bounded with ethernet, and does not used
anywhere else,
the exported function may not be used anywhere else.
Is it make it more complicated since there are probe, remove etc.

So I may still prefer using "static void __iomem *ppebase", as it is simpler.

Thanks
