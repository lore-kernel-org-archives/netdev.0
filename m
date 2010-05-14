From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH v3 3/3] ptp: Added a clock that uses the eTSEC found on
 the	MPC85xx.
Date: Fri, 14 May 2010 12:46:57 -0500
Message-ID: <4BED8C91.8020107@freescale.com>
References: <cover.1273855016.git.richard.cochran@omicron.at> <ee6c3edca3ee6aa86565e59da999375f79c9de1b.1273855017.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree-discuss@lists.ozlabs.org,
	linuxppc-dev@lists.ozlabs.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:57688 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756753Ab0ENRq7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 May 2010 13:46:59 -0400
Received: from az33smr02.freescale.net (az33smr02.freescale.net [10.64.34.200])
	by az33egw02.freescale.net (8.14.3/az33egw02) with ESMTP id o4EHkx0s027210
	for <netdev@vger.kernel.org>; Fri, 14 May 2010 10:46:59 -0700 (MST)
Received: from az33exm25.fsl.freescale.net (az33exm25.am.freescale.net [10.64.32.16])
	by az33smr02.freescale.net (8.13.1/8.13.0) with ESMTP id o4EHl3jR005073
	for <netdev@vger.kernel.org>; Fri, 14 May 2010 12:47:03 -0500 (CDT)
In-Reply-To: <ee6c3edca3ee6aa86565e59da999375f79c9de1b.1273855017.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/14/2010 11:46 AM, Richard Cochran wrote:
> diff --git a/Documentation/powerpc/dts-bindings/fsl/tsec.txt b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
> index edb7ae1..b09ba66 100644
> --- a/Documentation/powerpc/dts-bindings/fsl/tsec.txt
> +++ b/Documentation/powerpc/dts-bindings/fsl/tsec.txt
> @@ -74,3 +74,59 @@ Example:
>   		interrupt-parent =<&mpic>;
>   		phy-handle =<&phy0>
>   	};
> +
> +* Gianfar PTP clock nodes
> +
> +General Properties:
> +
> +  - device_type  Should be "ptp_clock"

Device_type is deprecated in most contexts for flat device trees.

> +  - model        Model of the device.  Must be "eTSEC"

Model, while abused by the current gianfar binding code, is not supposed 
to be something that is ordinarily used to bind on.  It is supposed to 
be a freeform field for indicating the specific model of hardware, 
mainly for human consumption or as a last resort for working around 
problems.

Get rid of both device_type and model, and specify a compatible string 
instead (e.g. "fsl,etsec-ptp").  Or perhaps this should just be some 
additional properties on the existing gianfar nodes, rather than 
presenting it as a separate device?  How do you associate a given ptp 
block with the corresponding gianfar node?  If there are differences in 
ptp implementation between different versions of etsec, can the ptp 
driver see the etsec version register?

> +  - reg          Offset and length of the register set for the device
> +  - interrupts   There should be at least two and as many as four
> +                 PTP related interrupts
> +
> +Clock Properties:
> +
> +  - tclk_period  Timer reference clock period in nanoseconds.
> +  - tmr_prsc     Prescaler, divides the output clock.
> +  - tmr_add      Frequency compensation value.
> +  - cksel        0= external clock, 1= eTSEC system clock, 3= RTC clock input.
> +                 Currently the driver only supports choice "1".
> +  - tmr_fiper1   Fixed interval period pulse generator.
> +  - tmr_fiper2   Fixed interval period pulse generator.

Dashes are more typical in OF names than underscores, and it's generally 
better to be a little more verbose -- these aren't local loop iterators.

They should probably have an "fsl,ptp-" prefix as well.

> +  These properties set the operational parameters for the PTP
> +  clock. You must choose these carefully for the clock to work right.

Do these values describe the way the hardware is, or how it's been 
configured by firmware, or a set of values that are clearly optimal for 
this particular board?  If it's just configuration for the Linux driver, 
that could reasonably differ based on what a given user or OS will want, 
the device tree probably isn't the right place for it.

> diff --git a/arch/powerpc/boot/dts/p2020ds.dts b/arch/powerpc/boot/dts/p2020ds.dts
> index 1101914..f72353a 100644
> --- a/arch/powerpc/boot/dts/p2020ds.dts
> +++ b/arch/powerpc/boot/dts/p2020ds.dts
> @@ -336,6 +336,20 @@
>   			phy_type = "ulpi";
>   		};
>
> +		ptp_clock@24E00 {
> +			device_type = "ptp_clock";
> +			model = "eTSEC";
> +			reg = <0x24E00 0xB0>;
> +			interrupts = <68 2 69 2 70 2>;
> +			interrupt-parent = < &mpic >;
> +			tclk_period = <5>;
> +			tmr_prsc = <200>;
> +			tmr_add = <0xCCCCCCCD>;
> +			cksel = <1>;
> +			tmr_fiper1 = <0x3B9AC9FB>;
> +			tmr_fiper2 = <0x0001869B>;
> +		};
> +

This one has 3 interrupts?  The driver supports only two.

> +/* Private globals */
> +static struct ptp_clock *gianfar_clock;

Do you not support more than one of these?

> +static struct etsects the_clock;

"The" clock?  As oppsed to the "other" clock one line above? :-)

> +static irqreturn_t isr(int irq, void *priv)
> +{
> +	struct etsects *etsects = priv;
> +	struct ptp_clock_event event;
> +	u64 ns;
> +	u32 ack=0, lo, hi, mask, val;
> +
> +	val = gfar_read(&etsects->regs->tmr_tevent);
> +
> +	if (val&  ETS1) {
> +		ack |= ETS1;
> +		hi = gfar_read(&etsects->regs->tmr_etts1_h);
> +		lo = gfar_read(&etsects->regs->tmr_etts1_l);
> +		event.type = PTP_CLOCK_EXTTS;
> +		event.index = 0;
> +		event.timestamp = ((u64) hi)<<  32;
> +		event.timestamp |= lo;
> +		ptp_clock_event(gianfar_clock,&event);
> +	}
> +
> +	if (val&  ETS2) {
> +		ack |= ETS2;
> +		hi = gfar_read(&etsects->regs->tmr_etts2_h);
> +		lo = gfar_read(&etsects->regs->tmr_etts2_l);
> +		event.type = PTP_CLOCK_EXTTS;
> +		event.index = 1;
> +		event.timestamp = ((u64) hi)<<  32;
> +		event.timestamp |= lo;
> +		ptp_clock_event(gianfar_clock,&event);
> +	}
> +
> +	if (val&  ALM2) {
> +		ack |= ALM2;
> +		if (etsects->alarm_value) {
> +			event.type = PTP_CLOCK_ALARM;
> +			event.index = 0;
> +			event.timestamp = etsects->alarm_value;
> +			ptp_clock_event(gianfar_clock,&event);
> +		}
> +		if (etsects->alarm_interval) {
> +			ns = etsects->alarm_value + etsects->alarm_interval;
> +			hi = ns>>  32;
> +			lo = ns&  0xffffffff;
> +			spin_lock(&register_lock);
> +			gfar_write(&etsects->regs->tmr_alarm2_l, lo);
> +			gfar_write(&etsects->regs->tmr_alarm2_h, hi);
> +			spin_unlock(&register_lock);
> +			etsects->alarm_value = ns;
> +		} else {
> +			gfar_write(&etsects->regs->tmr_tevent, ALM2);
> +			spin_lock(&register_lock);
> +			mask = gfar_read(&etsects->regs->tmr_temask);
> +			mask&= ~ALM2EN;
> +			gfar_write(&etsects->regs->tmr_temask, mask);
> +			spin_unlock(&register_lock);
> +			etsects->alarm_value = 0;
> +			etsects->alarm_interval = 0;
> +		}
> +	}
> +
> +	gfar_write(&etsects->regs->tmr_tevent, ack);
> +
> +	return IRQ_HANDLED;

Should only return IRQ_HANDLED if you found an event.

> +	if (get_of_u32(node, "tclk_period",&etsects->tclk_period) ||
> +	    get_of_u32(node, "tmr_prsc",&etsects->tmr_prsc) ||
> +	    get_of_u32(node, "tmr_add",&etsects->tmr_add) ||
> +	    get_of_u32(node, "cksel",&etsects->cksel) ||
> +	    get_of_u32(node, "tmr_fiper1",&etsects->tmr_fiper1) ||
> +	    get_of_u32(node, "tmr_fiper2",&etsects->tmr_fiper2))
> +		return -ENODEV;

Might want to print an error so the user knows what's missing.

> +	for (i = 0; i<  N_IRQS; i++) {
> +
> +		etsects->irq[i] = irq_of_parse_and_map(node, i);
> +
> +		if (etsects->irq[i] == NO_IRQ) {
> +			pr_err("irq[%d] not in device tree", i);
> +			return -ENODEV;
> +		}
> +
> +		if (request_irq(etsects->irq[i], isr, 0, DRIVER, etsects)) {
> +			pr_err("request_irq failed irq %d", etsects->irq[i]);
> +			return -ENODEV;
> +		}

You've got two IRQs, with the same handler, and the same dev_id?  From 
the manual it looks like there's one PTP interrupt per eTSEC (which 
would explain 3 interrupts on p2020).

> +static struct of_device_id match_table[] = {
> +	{ .type = "ptp_clock" },
> +	{},
> +};

This driver controls every possible PTP implementation?

-Scott
