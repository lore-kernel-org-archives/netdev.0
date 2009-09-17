From: "Choi, David" <David.Choi@Micrel.Com>
Subject: RE: [PATCH] ks8851_ml ethernet network driver
Date: Thu, 17 Sep 2009 12:11:26 -0700
Message-ID: <C43529A246480145B0A6D0234BDB0F0DE89F@MELANITE.micrel.com>
References: <20090916210315.04dc743e@s6510>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Greg KH" <greg@kroah.com>, <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>, <Choi@kroah.com>,
	"Jeff Garzik" <jgarzik@redhat.com>
To: "Stephen Hemminger" <shemminger@vyatta.com>,
	"Li, Charles" <Charles.Li@Micrel.Com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p01c12o143.mxlogic.net ([208.65.145.66]:48125 "EHLO
	p01c12o143.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894AbZIQTPo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Sep 2009 15:15:44 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20090916210315.04dc743e@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Stephen Hemminger,

My fix up is as followings;
	Even if the irq is not shared, it is safe not to process
	when there is no interrupt status change in the hardware.

====================
@@ -818,6 +811,11 @@ static irqreturn_t ks_irq(int irq, void 
 	ks_save_cmd_reg(ks);
 
 	status = ks_rdreg16(ks, KS_ISR);
+	if (unlikely(!status)) {
+		ks_restore_cmd_reg(ks);
+		return IRQ_NONE;
+	}
+
 	ks_wrreg16(ks, KS_ISR, status);
 
 	if (likely(status & IRQ_RXI))



Regards,
David J. Choi


-----Original Message-----
From: Stephen Hemminger [mailto:shemminger@vyatta.com] 
Sent: Wednesday, September 16, 2009 9:03 PM
To: Li, Charles
Cc: Greg KH; netdev@vger.kernel.org; David S. Miller; Choi@kroah.com;
Choi, David; Jeff Garzik
Subject: Re: [PATCH] ks8851_ml ethernet network driver

On Wed, 16 Sep 2009 19:38:36 -0700
Greg KH <greg@kroah.com> wrote:

> /**
> + * ks_irq - device interrupt handler
> + * @irq: Interrupt number passed from the IRQ hnalder.
> + * @pw: The private word passed to register_irq(), our struct ks_net.
> + *
> + * This is the handler invoked to find out what happened
> + *
> + * Read the interrupt status, work out what needs to be done and then
clear
> + * any of the interrupts that are not needed.
> + */
> +
> +static irqreturn_t ks_irq(int irq, void *pw)
> +{
> +	struct ks_net *ks = pw;
> +	struct net_device *netdev = ks->netdev;
> +	u16 status;
> +
> +	/*this should be the first in IRQ handler */
> +	ks_save_cmd_reg(ks);
> +
> +	status = ks_rdreg16(ks, KS_ISR);
> +	ks_wrreg16(ks, KS_ISR, status);

if status == 0 or status == ~0 then device should not return
IRQ_HANDLED.
In the former case, the IRQ is shared, in later case the device is not
present
on the bus (hotplug).
