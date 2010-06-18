From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH] socketcan: add a driver for FlexCAN controllers.
Date: Fri, 18 Jun 2010 13:53:03 +0200
Message-ID: <4C1B5E1F.5080702@grandegger.com>
References: <20100617105201.GA2015@bluebox.local>	<4C1B4098.3090800@grandegger.com>	<4C1B4796.3060506@pengutronix.de>
	<4C1B4B85.3010905@grandegger.com>	<4C1B4DF0.2090103@pengutronix.de>
	<4C1B52A7.3060607@grandegger.com> <4C1B56BC.1050303@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C1B56BC.1050303-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/18/2010 01:21 PM, Marc Kleine-Budde wrote:
> Wolfgang Grandegger wrote:
>> On 06/18/2010 12:44 PM, Marc Kleine-Budde wrote:
>>> Wolfgang Grandegger wrote:
>>>> On 06/18/2010 12:16 PM, Marc Kleine-Budde wrote:
>>>>> Wolfgang Grandegger wrote:
>>>>>> Hi Hans-J=FCrgen,
>>>>>>
>>>>>> On 06/17/2010 12:52 PM, Hans J. Koch wrote:
>>>>>>> This adds a driver for FlexCAN based CAN controllers,
>>>>>>> e.g. found in Freescale i.MX35 SoCs.
>>>>>>>
>>>>>>> The original version of this driver was posted by Sascha Hauer in J=
uly 2009:
>>>>>>> http://kerneltrap.org/mailarchive/linux-netdev/2009/7/29/6251621
>>>>>>>
>>>>>>> I took this version, added NAPI support, and fixed some problems fo=
und
>>>>>>> during testing. Well, here is the result. Please review.
>>>>>> I briefly browsed the patch and various bits and pieces are missing =
or
>>>>>> not correctly implemented. Marc already pointed out a few of them:
>>>>>>
>>>>>> - I do not find can_put/get_echo_skb functions in the code. How is
>>>>>>   IFF_ECHO supposed to work?
>>>>> the driver uses hardware loopback
>>>> OK, then
>>>>
>>>>   dev =3D alloc_candev(sizeof(struct flexcan_priv), 0);
>>>>
>>>> should be used (and TX_ECHO_SKB_MAX removed) in Hans-J=FCrgens driver.
>>>>
>>>>>> - Support for CAN_CTRLMODE_BERR_REPORTING and do_get_berr_counter()
>>>>>>   seems to be missing.
>>>>>>
>>>>>> - Make use of alloc_can_skb() and alloc_can_err_skb().
>>>>> the last two points are already addressed in my version of the driver.
>>>> I do not see support for CAN_CTRLMODE_BERR_REPORTING in your driver
>>>> (which has nothing to do with do_get_berr_counter).
>>> oh yes...sorry, got confused.
>>>
>>> However I implemented CAN_CTRLMODE_BERR_REPORTING, i.e. turning of the
>>> bit error interrupts by default. This has the effect that no bus warning
>>> and bus passive interrupt was signalled.
>>>
>>> I should add a comment to my driver.
>>
>> I'm confused, CAN_CTRLMODE_BERR_REPORTING means that the user can enable
>> bus error reporting, which seems not be handled in the driver your sent.
>> See:
>>
>> http://lxr.linux.no/linux/drivers/net/can/sja1000/sja1000.c#L134
>> http://lxr.linux.no/linux/drivers/net/can/sja1000/sja1000.c#L588
> =

> Which interrupts does "IRQ_BEI" include? What should
> CAN_CTRLMODE_BERR_REPORTING do?
> =

> Looking at:
> http://lxr.linux.no/linux+v2.6.34/drivers/net/can/sja1000/sja1000.c#L393
> it seems that BEI on the SJA just effects bit, form and stuff errors.

Yes, it effects *bus errors*... actually the one you handle in
at91_poll_err_frame(). Especially the AT91_IRQ_AERR does cause the
infamous interrupt flooding (which is, btw, not treated correctly as
bus error in your driver).

> If I disable the corresponding interrupt in the flexcan. This is
> ERR_MSK, (1 << 14 in CTRL), I don't get error warning or error passive
> interrupts either. I'm not sure about the bus off interrupt.

Hm, my understanding is that you can disable those bus error
interrupts individually via AT91_IRQ_ERR_FRAME.

> From my point of view this is not that what CAN_CTRLMODE_BERR_REPORTING
> should do, is it?

It should *not* disable state change interrupts, of course. I have
started to fix some issues in the at91 driver some time ago, which =

I have attached below.

Wolfgang.

---
diff --git a/drivers/net/can/at91_can.c b/drivers/net/can/at91_can.c
index a2f29a3..ad36b59 100644
--- a/drivers/net/can/at91_can.c
+++ b/drivers/net/can/at91_can.c
@@ -164,6 +164,7 @@ struct at91_priv {
 	void __iomem		*reg_base;
 =

 	u32			reg_sr;
+	u32			reg_ie_napi;
 	unsigned int		tx_next;
 	unsigned int		tx_echo;
 	unsigned int		rx_next;
@@ -273,7 +274,7 @@ static int at91_set_bittiming(struct net_device *dev)
 static void at91_chip_start(struct net_device *dev)
 {
 	struct at91_priv *priv =3D netdev_priv(dev);
-	u32 reg_mr, reg_ier;
+	u32 reg_mr;
 =

 	/* disable interrupts */
 	at91_write(priv, AT91_IDR, AT91_IRQ_ALL);
@@ -290,10 +291,12 @@ static void at91_chip_start(struct net_device *dev)
 =

 	priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
 =

-	/* Enable interrupts */
-	reg_ier =3D AT91_IRQ_MB_RX | AT91_IRQ_ERRP | AT91_IRQ_ERR_FRAME;
+	/* enable interrupts */
+	priv->reg_ir_napi =3D AT91_IRQ_MB_RX;
+	if (priv->can.ctrlmode & CAN_CTRLMODE_BERR_REPORTING)
+		priv->reg_ir_napi |=3D AT91_IRQ_ERR_FRAME;
 	at91_write(priv, AT91_IDR, AT91_IRQ_ALL);
-	at91_write(priv, AT91_IER, reg_ier);
+	at91_write(priv, AT91_IER, priv->reg_ir_napi | AT91_IRQ_ERRP);
 }
 =

 static void at91_chip_stop(struct net_device *dev, enum can_state state)
@@ -604,20 +607,21 @@ static void at91_poll_err_frame(struct net_device *de=
v,
 {
 	struct at91_priv *priv =3D netdev_priv(dev);
 =

+	priv->can.can_stats.bus_error++;
+	cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
+
 	/* CRC error */
 	if (reg_sr & AT91_IRQ_CERR) {
 		dev_dbg(dev->dev.parent, "CERR irq\n");
 		dev->stats.rx_errors++;
-		priv->can.can_stats.bus_error++;
-		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
+		cf->data[3] |=3D CAN_ERR_PROT_LOC_CRC_SEQ |
+			CAN_ERR_PROT_LOC_CRC_DEL;
 	}
 =

 	/* Stuffing Error */
 	if (reg_sr & AT91_IRQ_SERR) {
 		dev_dbg(dev->dev.parent, "SERR irq\n");
 		dev->stats.rx_errors++;
-		priv->can.can_stats.bus_error++;
-		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
 		cf->data[2] |=3D CAN_ERR_PROT_STUFF;
 	}
 =

@@ -626,14 +630,13 @@ static void at91_poll_err_frame(struct net_device *de=
v,
 		dev_dbg(dev->dev.parent, "AERR irq\n");
 		dev->stats.tx_errors++;
 		cf->can_id |=3D CAN_ERR_ACK;
+		cf->data[3] |=3D CAN_ERR_PROT_LOC_ACK;
 	}
 =

 	/* Form error */
 	if (reg_sr & AT91_IRQ_FERR) {
 		dev_dbg(dev->dev.parent, "FERR irq\n");
 		dev->stats.rx_errors++;
-		priv->can.can_stats.bus_error++;
-		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
 		cf->data[2] |=3D CAN_ERR_PROT_FORM;
 	}
 =

@@ -641,9 +644,7 @@ static void at91_poll_err_frame(struct net_device *dev,
 	if (reg_sr & AT91_IRQ_BERR) {
 		dev_dbg(dev->dev.parent, "BERR irq\n");
 		dev->stats.tx_errors++;
-		priv->can.can_stats.bus_error++;
-		cf->can_id |=3D CAN_ERR_PROT | CAN_ERR_BUSERROR;
-		cf->data[2] |=3D CAN_ERR_PROT_BIT;
+		cf->data[2] |=3D CAN_ERR_PROT_BIT0 | CAN_ERR_PROT_BIT1;
 	}
 }
 =

@@ -662,7 +663,6 @@ static int at91_poll_err(struct net_device *dev, int qu=
ota, u32 reg_sr)
 	at91_poll_err_frame(dev, cf, reg_sr);
 	netif_receive_skb(skb);
 =

-	dev->last_rx =3D jiffies;
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes +=3D cf->can_dlc;
 =

@@ -688,12 +688,10 @@ static int at91_poll(struct napi_struct *napi, int qu=
ota)
 		work_done +=3D at91_poll_err(dev, quota - work_done, reg_sr);
 =

 	if (work_done < quota) {
-		/* enable IRQs for frame errors and all mailboxes >=3D rx_next */
-		u32 reg_ier =3D AT91_IRQ_ERR_FRAME;
-		reg_ier |=3D AT91_IRQ_MB_RX & ~AT91_MB_RX_MASK(priv->rx_next);
-
 		napi_complete(napi);
-		at91_write(priv, AT91_IER, reg_ier);
+		/* enable IRQs for frame errors and all mailboxes >=3D rx_next */
+		at91_write(priv, AT91_IER, priv->reg_ir_napi &
+			   ~AT91_MB_RX_MASK(priv->rx_next));
 	}
 =

 	return work_done;
@@ -899,7 +897,6 @@ static void at91_irq_err(struct net_device *dev)
 	at91_irq_err_state(dev, cf, new_state);
 	netif_rx(skb);
 =

-	dev->last_rx =3D jiffies;
 	dev->stats.rx_packets++;
 	dev->stats.rx_bytes +=3D cf->can_dlc;
 =

@@ -933,8 +930,7 @@ static irqreturn_t at91_irq(int irq, void *dev_id)
 		 * save for later use.
 		 */
 		priv->reg_sr =3D reg_sr;
-		at91_write(priv, AT91_IDR,
-			   AT91_IRQ_MB_RX | AT91_IRQ_ERR_FRAME);
+		at91_write(priv, AT91_IDR, priv->reg_ir_napi);
 		napi_schedule(&priv->napi);
 	}
 =

@@ -1073,7 +1069,8 @@ static int __init at91_can_probe(struct platform_devi=
ce *pdev)
 	priv->can.bittiming_const =3D &at91_bittiming_const;
 	priv->can.do_set_bittiming =3D at91_set_bittiming;
 	priv->can.do_set_mode =3D at91_set_mode;
-	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_3_SAMPLES;
+	priv->can.ctrlmode_supported =3D CAN_CTRLMODE_3_SAMPLES |
+ 		CAN_CTRLMODE_BERR_REPORTING;
 	priv->reg_base =3D addr;
 	priv->dev =3D dev;
 	priv->clk =3D clk;
diff --git a/drivers/net/can/sja1000/sja1000.c b/drivers/net/can/sja1000/sj=
a1000.c
index 145b1a7..77b5fbc 100644
--- a/drivers/net/can/sja1000/sja1000.c
+++ b/drivers/net/can/sja1000/sja1000.c
@@ -89,8 +89,8 @@ static int sja1000_probe_chip(struct net_device *dev)
 	struct sja1000_priv *priv =3D netdev_priv(dev);
 =

 	if (priv->reg_base && (priv->read_reg(priv, 0) =3D=3D 0xFF)) {
-		printk(KERN_INFO "%s: probing @0x%lX failed\n",
-		       DRV_NAME, dev->base_addr);
+		dev_info(dev->dev.parent, "probing @0x%p failed\n",
+			 priv->reg_base);
 		return 0;
 	}
 	return -1;
@@ -254,7 +254,7 @@ static void chipset_init(struct net_device *dev)
  * [  can-id ] [flags] [len] [can data (up to 8 bytes]
  */
 static netdev_tx_t sja1000_start_xmit(struct sk_buff *skb,
-					    struct net_device *dev)
+				      struct net_device *dev)
 {
 	struct sja1000_priv *priv =3D netdev_priv(dev);
 	struct can_frame *cf =3D (struct can_frame *)skb->data;
@@ -602,9 +602,9 @@ void free_sja1000dev(struct net_device *dev)
 EXPORT_SYMBOL_GPL(free_sja1000dev);
 =

 static const struct net_device_ops sja1000_netdev_ops =3D {
-       .ndo_open               =3D sja1000_open,
-       .ndo_stop               =3D sja1000_close,
-       .ndo_start_xmit         =3D sja1000_start_xmit,
+	.ndo_open =3D sja1000_open,
+	.ndo_stop =3D sja1000_close,
+	.ndo_start_xmit =3D sja1000_start_xmit,
 };
 =

 int register_sja1000dev(struct net_device *dev)
