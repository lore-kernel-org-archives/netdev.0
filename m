From: Andy Duan <fugang.duan@nxp.com>
Subject: RE: [PATCH net v1 2/2] net: fec: Let fec_ptp have its own interrupt
 routine
Date: Mon, 9 Oct 2017 02:55:30 +0000
Message-ID: <AM4PR0401MB226084D06C656E2B5EC1B22FFF740@AM4PR0401MB2260.eurprd04.prod.outlook.com>
References: <20171003000442.31841-1-troy.kisky@boundarydevices.com>
 <20171003000442.31841-2-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Fabio Estevam <fabio.estevam@nxp.com>,
        "lznuaa@gmail.com" <lznuaa@gmail.com>
To: Troy Kisky <troy.kisky@boundarydevices.com>,
        "shawn.guo@linaro.org" <shawn.guo@linaro.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr50055.outbound.protection.outlook.com ([40.107.5.55]:19904
        "EHLO EUR03-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753408AbdJICzk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 8 Oct 2017 22:55:40 -0400
In-Reply-To: <20171003000442.31841-2-troy.kisky@boundarydevices.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Troy Kisky <troy.kisky@boundarydevices.com> Sent: Tuesday, October 03=
, 2017 8:05 AM
>To: shawn.guo@linaro.org; Andy Duan <fugang.duan@nxp.com>;
>netdev@vger.kernel.org; davem@davemloft.net
>Cc: Fabio Estevam <fabio.estevam@nxp.com>; lznuaa@gmail.com; Troy Kisky
><troy.kisky@boundarydevices.com>
>Subject: [PATCH net v1 2/2] net: fec: Let fec_ptp have its own interrupt
>routine
>
>This is better for code locality and should slightly speed up normal inter=
rupts.
>
>This also allows PPS clock output to start working for i.mx7. This is beca=
use
>i.mx7 was already using the limit of 3 interrupts, and needed another.
>
>Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>
>
>---
>If this patch is taken before the corresponding dtb file patch than time
>stamping will be momentarily broken.
>---

The two patches for PPS seems=20

> drivers/net/ethernet/freescale/fec.h      |  1 -
> drivers/net/ethernet/freescale/fec_main.c | 15 +++---
>drivers/net/ethernet/freescale/fec_ptp.c  | 77 ++++++++++++++++++--------
>-----
> 3 files changed, 52 insertions(+), 41 deletions(-)
>
>diff --git a/drivers/net/ethernet/freescale/fec.h
>b/drivers/net/ethernet/freescale/fec.h
>index ede1876a9a19..782509041102 100644
>--- a/drivers/net/ethernet/freescale/fec.h
>+++ b/drivers/net/ethernet/freescale/fec.h
>@@ -587,7 +587,6 @@ void fec_ptp_stop(struct platform_device *pdev);
>void fec_ptp_start_cyclecounter(struct net_device *ndev);  int
>fec_ptp_set(struct net_device *ndev, struct ifreq *ifr);  int
>fec_ptp_get(struct net_device *ndev, struct ifreq *ifr); -uint
>fec_ptp_check_pps_event(struct fec_enet_private *fep);
>
>
>/**********************************************************
>******************/
> #endif /* FEC_H */
>diff --git a/drivers/net/ethernet/freescale/fec_main.c
>b/drivers/net/ethernet/freescale/fec_main.c
>index 3dc2d771a222..80fe04165ba0 100644
>--- a/drivers/net/ethernet/freescale/fec_main.c
>+++ b/drivers/net/ethernet/freescale/fec_main.c
>@@ -1602,10 +1602,6 @@ fec_enet_interrupt(int irq, void *dev_id)
> 		ret =3D IRQ_HANDLED;
> 		complete(&fep->mdio_done);
> 	}
>-
>-	if (fep->ptp_clock)
>-		if (fec_ptp_check_pps_event(fep))
>-			ret =3D IRQ_HANDLED;
> 	return ret;
> }
>
>@@ -3325,6 +3321,7 @@ fec_probe(struct platform_device *pdev)
> 	struct device_node *np =3D pdev->dev.of_node, *phy_node;
> 	int num_tx_qs;
> 	int num_rx_qs;
>+	int ptp_irq, j;
>
> 	fec_enet_get_queue_num(pdev, &num_tx_qs, &num_rx_qs);
>
>@@ -3472,20 +3469,24 @@ fec_probe(struct platform_device *pdev)
> 	if (ret)
> 		goto failed_init;
>
>-	for (i =3D 0; i < FEC_IRQ_NUM; i++) {
>-		irq =3D platform_get_irq(pdev, i);
>+	ptp_irq =3D platform_get_irq_byname(pdev, "ptp");

Here, interrupt-names property is required properties, it should update bin=
ding doc.
Also need to handle the return value checking.

>+	i =3D j =3D 0;
>+	while (i < FEC_IRQ_NUM) {
>+		irq =3D platform_get_irq(pdev, j++);
> 		if (irq < 0) {
> 			if (i)
> 				break;
> 			ret =3D irq;
> 			goto failed_irq;
> 		}
>+		if (irq =3D=3D ptp_irq)
>+			continue;
> 		ret =3D devm_request_irq(&pdev->dev, irq, fec_enet_interrupt,
> 				       0, pdev->name, ndev);
> 		if (ret)
> 			goto failed_irq;
>
>-		fep->irq[i] =3D irq;
>+		fep->irq[i++] =3D irq;

I think it is not necessary to split pps interrupt handler.
To support pps interrupt handler,  just change the maximum interrupt number=
 FEC_IRQ_NUM to 4 that minimize the code change.

> 	}
>
> 	init_completion(&fep->mdio_done);
>diff --git a/drivers/net/ethernet/freescale/fec_ptp.c
>b/drivers/net/ethernet/freescale/fec_ptp.c
>index 6ebad3fac81d..20e01a3ca453 100644
>--- a/drivers/net/ethernet/freescale/fec_ptp.c
>+++ b/drivers/net/ethernet/freescale/fec_ptp.c
>@@ -549,6 +549,38 @@ static void fec_time_keep(struct work_struct *work)
> 	schedule_delayed_work(&fep->time_keep, HZ);  }
>
>+/*
>+ * This function checks the pps event and reloads the timer compare count=
er.
>+ */
>+static irqreturn_t fec_ptp_interrupt(int irq, void *dev_id) {
>+	struct net_device *ndev =3D dev_id;
>+	struct fec_enet_private *fep =3D netdev_priv(ndev);
>+	u32 val;
>+	u8 channel =3D fep->pps_channel;
>+	struct ptp_clock_event event;
>+
>+	val =3D readl(fep->hwp + FEC_TCSR(channel));
>+	if (val & FEC_T_TF_MASK) {
>+		/* Write the next next compare(not the next according the
>spec)
>+		 * value to the register
>+		 */
>+		writel(fep->next_counter, fep->hwp + FEC_TCCR(channel));
>+		do {
>+			writel(val, fep->hwp + FEC_TCSR(channel));
>+		} while (readl(fep->hwp + FEC_TCSR(channel)) &
>FEC_T_TF_MASK);
>+
>+		/* Update the counter; */
>+		fep->next_counter =3D (fep->next_counter + fep-
>>reload_period) &
>+fep->cc.mask;
>+
>+		event.type =3D PTP_CLOCK_PPS;
>+		ptp_clock_event(fep->ptp_clock, &event);
>+		return IRQ_HANDLED;
>+	}
>+
>+	return IRQ_NONE;
>+}
>+
> /**
>  * fec_ptp_init
>  * @ndev: The FEC network adapter
>@@ -562,6 +594,8 @@ void fec_ptp_init(struct platform_device *pdev)  {
> 	struct net_device *ndev =3D platform_get_drvdata(pdev);
> 	struct fec_enet_private *fep =3D netdev_priv(ndev);
>+	int irq;
>+	int ret;
>
> 	fep->ptp_caps.owner =3D THIS_MODULE;
> 	snprintf(fep->ptp_caps.name, 16, "fec ptp"); @@ -587,6 +621,16 @@
>void fec_ptp_init(struct platform_device *pdev)
>
> 	INIT_DELAYED_WORK(&fep->time_keep, fec_time_keep);
>
>+	irq =3D platform_get_irq_byname(pdev, "ptp");
>+	if (irq < 0)
>+		return;

If dts don't set interrupt name, here break ptp function. Suppose PPS don't=
 break ptp.

>+	ret =3D devm_request_irq(&pdev->dev, irq, fec_ptp_interrupt,
>+			       0, pdev->name, ndev);
>+	if (ret < 0) {
>+		dev_warn(&pdev->dev, "request for ptp irq failed(%d)\n",
>ret);
>+		return;

Ditto...

>+	}
>+
> 	fep->ptp_clock =3D ptp_clock_register(&fep->ptp_caps, &pdev->dev);
> 	if (IS_ERR(fep->ptp_clock)) {
> 		fep->ptp_clock =3D NULL;
>@@ -605,36 +649,3 @@ void fec_ptp_stop(struct platform_device *pdev)
> 	if (fep->ptp_clock)
> 		ptp_clock_unregister(fep->ptp_clock);
> }
>-
>-/**
>- * fec_ptp_check_pps_event
>- * @fep: the fec_enet_private structure handle
>- *
>- * This function check the pps event and reload the timer compare counter=
.
>- */
>-uint fec_ptp_check_pps_event(struct fec_enet_private *fep) -{
>-	u32 val;
>-	u8 channel =3D fep->pps_channel;
>-	struct ptp_clock_event event;
>-
>-	val =3D readl(fep->hwp + FEC_TCSR(channel));
>-	if (val & FEC_T_TF_MASK) {
>-		/* Write the next next compare(not the next according the
>spec)
>-		 * value to the register
>-		 */
>-		writel(fep->next_counter, fep->hwp + FEC_TCCR(channel));
>-		do {
>-			writel(val, fep->hwp + FEC_TCSR(channel));
>-		} while (readl(fep->hwp + FEC_TCSR(channel)) &
>FEC_T_TF_MASK);
>-
>-		/* Update the counter; */
>-		fep->next_counter =3D (fep->next_counter + fep-
>>reload_period) & fep->cc.mask;
>-
>-		event.type =3D PTP_CLOCK_PPS;
>-		ptp_clock_event(fep->ptp_clock, &event);
>-		return 1;
>-	}
>-
>-	return 0;
>-}
>--
>2.11.0
