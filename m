From: "Kumar Gopalpet-B05799" <B05799@freescale.com>
Subject: RE: [PATCH] gianfar: Fix tests of unsigneds in gfar_parse_group()
Date: Wed, 16 Dec 2009 10:32:46 +0530
Message-ID: <9F4C7D19E8361D4C94921B95BE08B81BA08D59@zin33exm22.fsl.freescale.net>
References: <4B27D87D.5070908@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
To: "Roel Kluin" <roel.kluin@gmail.com>, <netdev@vger.kernel.org>,
	"David Miller" <davem@davemloft.net>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"LKML" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751380AbZLPFCx@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4B27D87D.5070908@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 
>interruptTransmit, -Receive and -Error are unsigned so the 
>tests did not work.
>
>This also changes that if irq_of_parse_and_map(np, 0) returns 
>NO_IRQ, that
>gfar_parse_group() returns an -EINVAL.
>
>Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
>---
>Found using coccinelle: http://coccinelle.lip6.fr/
>
>diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c 
>index 6850dc0..c411682 100644
>--- a/drivers/net/gianfar.c
>+++ b/drivers/net/gianfar.c
>@@ -522,6 +522,7 @@ static int gfar_parse_group(struct 
>device_node *np,  {
> 	u32 *queue_mask;
> 	u64 addr, size;
>+	int irq;
> 
> 	addr = of_translate_address(np,
> 			of_get_address(np, 0, &size, NULL)); @@ 
>-530,20 +531,22 @@ static int gfar_parse_group(struct device_node *np,
> 	if (!priv->gfargrp[priv->num_grps].regs)
> 		return -ENOMEM;
> 
>-	priv->gfargrp[priv->num_grps].interruptTransmit =
>-			irq_of_parse_and_map(np, 0);
>+	irq = irq_of_parse_and_map(np, 0);
>+	if (irq < 0)
>+		return -EINVAL;
>+	priv->gfargrp[priv->num_grps].interruptTransmit = irq;
> 
> 	/* If we aren't the FEC we have multiple interrupts */
> 	if (model && strcasecmp(model, "FEC")) {
>-		priv->gfargrp[priv->num_grps].interruptReceive =
>-			irq_of_parse_and_map(np, 1);
>-		priv->gfargrp[priv->num_grps].interruptError =
>-			irq_of_parse_and_map(np,2);
>-		if 
>(priv->gfargrp[priv->num_grps].interruptTransmit < 0 ||
>-			
>priv->gfargrp[priv->num_grps].interruptReceive < 0 ||
>-			
>priv->gfargrp[priv->num_grps].interruptError < 0) {
>+		irq = irq_of_parse_and_map(np, 1);
>+		if (irq < 0)
> 			return -EINVAL;
>-		}
>+		priv->gfargrp[priv->num_grps].interruptReceive = irq;
>+
>+		irq = irq_of_parse_and_map(np, 2);
>+		if (irq < 0)
>+			return -EINVAL;
>+		priv->gfargrp[priv->num_grps].interruptError = irq;
> 	}
> 
> 	priv->gfargrp[priv->num_grps].grp_id = priv->num_grps;


Won't it be better to change types of interruptTransmit, -Receive and
-Error
in  struct gfar_priv_grp itself. Something like this:

struct gfar_priv_grp {
....
-	unsigned int interruptTransmit;
-	unsigned int interruptReceive;
-	unsigned int interruptError;

+	unsigned int interruptTransmit;
+	unsigned int interruptReceive;
+	unsigned int interruptError;
....
}

--

Thanks
Sandeep
