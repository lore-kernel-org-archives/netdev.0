From: Kumar Gala <galak@codeaurora.org>
Subject: Re: [PATCH v2] powerpc/83xx: gianfar_ptp: select 1588 clock source through dts file
Date: Wed, 25 Sep 2013 14:38:12 -0500
Message-ID: <9B020778-D8FB-4D71-9647-4D1505DCAE1E@codeaurora.org>
References: <1380093863-5388-1-git-send-email-aida.mynzhasova@skitlab.ru>
Mime-Version: 1.0 (Apple Message framework v1283)
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 8BIT
Cc: linuxppc-dev@lists.ozlabs.org, devicetree@vger.kernel.org,
	netdev@vger.kernel.org, richardcochran@gmail.com
To: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.11.231]:58188 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754503Ab3IYTiR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Sep 2013 15:38:17 -0400
In-Reply-To: <1380093863-5388-1-git-send-email-aida.mynzhasova@skitlab.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sep 25, 2013, at 2:24 AM, Aida Mynzhasova wrote:

> Currently IEEE 1588 timer reference clock source is determined through
> hard-coded value in gianfar_ptp driver. This patch allows to select ptp
> clock source by means of device tree file node.
> 
> For instance:
> 
> 	fsl,cksel = <0>;
> 
> for using external (TSEC_TMR_CLK input) high precision timer
> reference clock.
> 
> Other acceptable values:
> 
> 	<1> : eTSEC system clock
> 	<2> : eTSEC1 transmit clock
> 	<3> : RTC clock input

Do these value match some register field to select which clk?  If so please add that to the document.

- k

> 
> When this attribute isn't used, eTSEC system clock will serve as
> IEEE 1588 timer reference clock.
> 
> Signed-off-by: Aida Mynzhasova <aida.mynzhasova@skitlab.ru>
> ---
> Documentation/devicetree/bindings/net/fsl-tsec-phy.txt | 16 +++++++++++++++-
> drivers/net/ethernet/freescale/gianfar_ptp.c           |  4 +++-
> 2 files changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
> index 2c6be03..eb06059 100644
> --- a/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
> +++ b/Documentation/devicetree/bindings/net/fsl-tsec-phy.txt
> @@ -86,6 +86,7 @@ General Properties:
> 
> Clock Properties:
> 
> +  - fsl,cksel        Timer reference clock source.
>   - fsl,tclk-period  Timer reference clock period in nanoseconds.
>   - fsl,tmr-prsc     Prescaler, divides the output clock.
>   - fsl,tmr-add      Frequency compensation value.
> @@ -97,7 +98,7 @@ Clock Properties:
>   clock. You must choose these carefully for the clock to work right.
>   Here is how to figure good values:
> 
> -  TimerOsc     = system clock               MHz
> +  TimerOsc     = selected reference clock   MHz
>   tclk_period  = desired clock period       nanoseconds
>   NominalFreq  = 1000 / tclk_period         MHz
>   FreqDivRatio = TimerOsc / NominalFreq     (must be greater that 1.0)
> @@ -114,6 +115,18 @@ Clock Properties:
>   Pulse Per Second (PPS) signal, since this will be offered to the PPS
>   subsystem to synchronize the Linux clock.
> 
> +  "fsl,cksel" property allows to select different reference clock
> +  sources:
> +
> +  <0> - external high precision timer reference clock (TSEC_TMR_CLK
> +        input is used for this purpose);
> +  <1> - eTSEC system clock;
> +  <2> - eTSEC1 transmit clock;
> +  <3> - RTC clock input.
> +
> +  When this attribute is not used, eTSEC system clock will serve as
> +  IEEE 1588 timer reference clock.
> +
> Example:
> 
> 	ptp_clock@24E00 {
> @@ -121,6 +134,7 @@ Example:
> 		reg = <0x24E00 0xB0>;
> 		interrupts = <12 0x8 13 0x8>;
> 		interrupt-parent = < &ipic >;
> +		fsl,cksel       = <1>;
> 		fsl,tclk-period = <10>;
> 		fsl,tmr-prsc    = <100>;
> 		fsl,tmr-add     = <0x999999A4>;
> diff --git a/drivers/net/ethernet/freescale/gianfar_ptp.c b/drivers/net/ethernet/freescale/gianfar_ptp.c
> index 098f133..e006a09 100644
> --- a/drivers/net/ethernet/freescale/gianfar_ptp.c
> +++ b/drivers/net/ethernet/freescale/gianfar_ptp.c
> @@ -452,7 +452,9 @@ static int gianfar_ptp_probe(struct platform_device *dev)
> 	err = -ENODEV;
> 
> 	etsects->caps = ptp_gianfar_caps;
> -	etsects->cksel = DEFAULT_CKSEL;
> +
> +	if (get_of_u32(node, "fsl,cksel", &etsects->cksel))
> +		etsects->cksel = DEFAULT_CKSEL;
> 
> 	if (get_of_u32(node, "fsl,tclk-period", &etsects->tclk_period) ||
> 	    get_of_u32(node, "fsl,tmr-prsc", &etsects->tmr_prsc) ||
> -- 
> 1.8.1.2
> 
> --
> To unsubscribe from this list: send the line "unsubscribe devicetree" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Employee of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, hosted by The Linux Foundation
