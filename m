From: Marc Kleine-Budde <mkl@pengutronix.de>
Subject: Re: [PATCH v2 1/3] can: sja1000: of: add per-compatible init hook
Date: Tue, 12 Jan 2016 17:24:09 +0100
Message-ID: <FC7CB655-2FD3-401C-BF22-A8556A002D8F@pengutronix.de>
References: <1450978973-30417-1-git-send-email-damien.riegel@savoirfairelinux.com> <1450978973-30417-2-git-send-email-damien.riegel@savoirfairelinux.com> <5694B0A6.8070200@pengutronix.de> <20160112155329.GB6050@localhost>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>,
	Wolfgang Grandegger <wg@grandegger.com>,
	kernel@savoirfairelinux.com
To: Damien Riegel <damien.riegel@savoirfairelinux.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <20160112155329.GB6050@localhost>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On January 12, 2016 4:53:30 PM GMT+01:00, Damien Riegel <damien.riegel@savoirfairelinux.com> wrote:
>On Tue, Jan 12, 2016 at 08:52:06AM +0100, Marc Kleine-Budde wrote:
>> On 12/24/2015 06:42 PM, Damien Riegel wrote:
>> > This commit adds the capability to allocate and init private data
>> > embedded in the sja1000_priv structure on a per-compatible basis.
>The
>> > device node is passed as a parameter of the init callback to allow
>> > parsing of custom device tree properties.
>> > 
>> > Signed-off-by: Damien Riegel <damien.riegel@savoirfairelinux.com>
>> > ---
>> >  drivers/net/can/sja1000/sja1000_platform.c | 39
>++++++++++++++++++++++++++++--
>> >  1 file changed, 37 insertions(+), 2 deletions(-)
>> > 
>> > diff --git a/drivers/net/can/sja1000/sja1000_platform.c
>b/drivers/net/can/sja1000/sja1000_platform.c
>> > index 0552ed4..e0572d0 100644
>> > --- a/drivers/net/can/sja1000/sja1000_platform.c
>> > +++ b/drivers/net/can/sja1000/sja1000_platform.c
>> > @@ -40,6 +40,11 @@ MODULE_DESCRIPTION("Socket-CAN driver for
>SJA1000 on the platform bus");
>> >  MODULE_ALIAS("platform:" DRV_NAME);
>> >  MODULE_LICENSE("GPL v2");
>> >  
>> > +struct sja1000_of_data {
>> > +	size_t  priv_sz;
>> > +	int     (*init)(struct sja1000_priv *priv, struct device_node
>*of);
>> > +};
>> > +
>> >  static u8 sp_read_reg8(const struct sja1000_priv *priv, int reg)
>> >  {
>> >  	return ioread8(priv->reg_base + reg);
>> > @@ -154,7 +159,8 @@ static void sp_populate_of(struct sja1000_priv
>*priv, struct device_node *of)
>> >  		priv->cdr |= CDR_CBP; /* default */
>> >  }
>> >  
>> > -static int sp_probe(struct platform_device *pdev)
>> > +static int __sp_probe(struct platform_device *pdev,
>> > +		      const struct sja1000_of_data *of_data)
>> >  {
>> >  	int err, irq = 0;
>> >  	void __iomem *addr;
>> > @@ -163,6 +169,7 @@ static int sp_probe(struct platform_device
>*pdev)
>> >  	struct resource *res_mem, *res_irq = NULL;
>> >  	struct sja1000_platform_data *pdata;
>> >  	struct device_node *of = pdev->dev.of_node;
>> > +	size_t priv_sz = of_data ? of_data->priv_sz : 0;
>> >  
>> >  	pdata = dev_get_platdata(&pdev->dev);
>> >  	if (!pdata && !of) {
>> > @@ -191,7 +198,7 @@ static int sp_probe(struct platform_device
>*pdev)
>> >  	if (!irq && !res_irq)
>> >  		return -ENODEV;
>> >  
>> > -	dev = alloc_sja1000dev(0);
>> > +	dev = alloc_sja1000dev(priv_sz);
>> >  	if (!dev)
>> >  		return -ENOMEM;
>> >  	priv = netdev_priv(dev);
>> > @@ -213,6 +220,12 @@ static int sp_probe(struct platform_device
>*pdev)
>> >  	else
>> >  		sp_populate(priv, pdata, res_mem->flags);
>> >  
>> > +	if (of_data && of_data->init) {
>> > +		err = of_data->init(priv, of);
>> > +		if (err)
>> > +			goto exit_free;
>> > +	}
>> > +
>> >  	platform_set_drvdata(pdev, dev);
>> >  	SET_NETDEV_DEV(dev, &pdev->dev);
>> >  
>> > @@ -248,6 +261,28 @@ static const struct of_device_id sp_of_table[]
>= {
>> >  };
>> >  MODULE_DEVICE_TABLE(of, sp_of_table);
>> >  
>> > +static const struct sja1000_of_data *sp_get_of_data(struct
>device_node *of)
>> > +{
>> > +	const struct of_device_id *id;
>> > +
>> > +	if (!of)
>> > +		return NULL;
>> > +
>> > +	id = of_match_node(sp_of_table, of);
>> > +	if (!id)
>> > +		return NULL;
>> > +
>> > +	return id->data;
>> > +}
>> > +
>> > +static int sp_probe(struct platform_device *pdev)
>> > +{
>> > +	struct device_node *of = pdev->dev.of_node;
>> > +	const struct sja1000_of_data *of_data = sp_get_of_data(of);
>> > +
>> > +	return __sp_probe(pdev, of_data);
>> > +}
>> 
>> Please merge these two into the original sp_probe function, as there
>> already is a test for pdev->dev.of_node.
>
>Ok. sp_get_of_data makes use of sp_of_table, so either I move sp_probe
>below sp_of_table, or I use a forward declaration. Which one do you
>prefer?

Please move sp_of_table.

Marc

