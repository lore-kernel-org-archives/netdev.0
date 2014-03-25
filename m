From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 3/3] net: hisilicon: new hip04 ethernet driver
Date: Tue, 25 Mar 2014 09:12:38 +0100
Message-ID: <17142825.cN9DfpvuLc@wuerfel>
References: <1395670496-17381-1-git-send-email-zhangfei.gao@linaro.org>
 <13743364.WZtdi2BZb3@wuerfel>
 <CAMj5BkjbrHevQhf4kbFhN5THHLw4nQwdpt2h6WJH02mKhdq8oQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Mark Rutland <mark.rutland@arm.com>,
 "devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
 Florian Fainelli <f.fainelli@gmail.com>,
 Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
 netdev <netdev@vger.kernel.org>, Zhangfei Gao <zhangfei.gao@linaro.org>,
 "David S. Miller" <davem@davemloft.net>,
 linux-arm-kernel <linux-arm-kernel@lists.infradead.org>
To: Zhangfei Gao <zhangfei.gao@gmail.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <CAMj5BkjbrHevQhf4kbFhN5THHLw4nQwdpt2h6WJH02mKhdq8oQ@mail.gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On Tuesday 25 March 2014 12:06:31 Zhangfei Gao wrote:
> Dear Arnd
> 
> On Mon, Mar 24, 2014 at 11:18 PM, Arnd Bergmann <arnd@arndb.de> wrote:
> > On Monday 24 March 2014 22:14:56 Zhangfei Gao wrote:
> >
> >> +
> >> +static void hip04_tx_reclaim(struct net_device *ndev, bool force)
> >> +{
> >> +     struct hip04_priv *priv = netdev_priv(ndev);
> >> +     unsigned tx_head = priv->tx_head;
> >> +     unsigned tx_tail = priv->tx_tail;
> >> +     struct tx_desc *desc = &priv->tx_desc[priv->tx_tail];
> >> +
> >> +     while (tx_tail != tx_head) {
> >> +             if (desc->send_addr != 0) {
> >> +                     if (force)
> >> +                             desc->send_addr = 0;
> >> +                     else
> >> +                             break;
> >> +             }
> >> +             if (priv->tx_phys[tx_tail]) {
> >> +                     dma_unmap_single(&ndev->dev, priv->tx_phys[tx_tail],
> >> +                             priv->tx_skb[tx_tail]->len, DMA_TO_DEVICE);
> >> +                     priv->tx_phys[tx_tail] = 0;
> >> +             }
> >> +             dev_kfree_skb_irq(priv->tx_skb[tx_tail]);
> >> +             priv->tx_skb[tx_tail] = NULL;
> >> +             tx_tail = TX_NEXT(tx_tail);
> >> +             priv->tx_count--;
> >> +     }
> >> +     priv->tx_tail = tx_tail;
> >> +}
> >
> > I think you still need to find a solution to ensure that the tx reclaim is
> > called eventually through a method other than start_xmit.
> 
> In the iperf stress test, if move reclaim to poll, there is some
> error, sometimes sending zero packets.
> While keep reclaim in the xmit to reclaim transmitted packets looks
> stable in the test,
> There TX_DESC_NUM desc can be used.

What I meant is that you need a correct implementation, presumably
you added a bug when you moved the function to poll(), and also you
forgot to add a timer.

> >> +     priv->map = syscon_regmap_lookup_by_compatible("hisilicon,hip04-ppe");
> >> +     if (IS_ERR(priv->map)) {
> >> +             dev_warn(d, "no hisilicon,hip04-ppe\n");
> >> +             ret = PTR_ERR(priv->map);
> >> +             goto init_fail;
> >> +     }
> >> +
> >> +     n = of_parse_phandle(node, "port-handle", 0);
> >> +     if (n) {
> >> +             ret = of_property_read_u32(n, "reg", &priv->port);
> >> +             if (ret) {
> >> +                     dev_warn(d, "no reg info\n");
> >> +                     goto init_fail;
> >> +             }
> >> +
> >> +             ret = of_property_read_u32(n, "channel", &priv->chan);
> >> +             if (ret) {
> >> +                     dev_warn(d, "no channel info\n");
> >> +                     goto init_fail;
> >> +             }
> >> +     } else {
> >> +             dev_warn(d, "no port-handle\n");
> >> +             ret = -EINVAL;
> >> +             goto init_fail;
> >> +     }
> >
> > Doing the lookup by "compatible" string doesn't really help you
> > at solve the problem of single-instance ppe at all, because that
> > function will only ever look at the first one. Use
> > syscon_regmap_lookup_by_phandle instead and pass the phandle
> > you get from the "port-handle" property.
> 
> Did some experiment, the only ppe base is got from syscon probe.
> And looking up by "compatible" did work for three controllers at the same time.

The point is that it won't work for more than one ppe instance.

> > Also, since you decided to treat the ppe as a dump regmap, I would
> > recommend moving the 'reg' and 'channel' properties into arguments
> > of the port-handle link, and retting rid of the child nodes of
> > the ppe, like:
> >
> > +       ppe: ppe@28c0000 {
> > +               compatible = "hisilicon,hip04-ppe", "syscon";
> > +               reg = <0x28c0000 0x10000>;
> > +       };
> > +
> > +       fe: ethernet@28b0000 {
> > +               compatible = "hisilicon,hip04-mac";
> > +               reg = <0x28b0000 0x10000>;
> > +               interrupts = <0 413 4>;
> > +               phy-mode = "mii";
> > +               port-handle = <&ppe 0xf1 0>;
> > +       };
> >
> 
> Would you mind giving more hints about how to parse the args.
> I am thinking of using of_parse_phandle_with_args, is that correct method?

I would just use of_property_read_u32_array() to read all three cells,
then pass the first cell entry into syscon_regmap_lookup_by_phandle.
of_parse_phandle_with_args() is what you would use if you were registering
a higher-level driver for the ppe rather than using syscon.

	Arnd
