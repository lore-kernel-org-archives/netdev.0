From: Li Yang-R58472 <r58472@freescale.com>
Subject: RE: [PATCH 6/7] fsl_pmc: Add API to enable device as wakeup event
 source
Date: Tue, 8 Nov 2011 11:12:09 +0000
Message-ID: <3F607A5180246847A760FD34122A1E052BC9B1@039-SN1MPN1-004.039d.mgd.msft.net>
References: <1320410349-14600-1-git-send-email-chenhui.zhao@freescale.com>
 <4EB455B1.8030009@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>
To: Wood Scott-B07421 <B07421@freescale.com>,
	Zhao Chenhui-B35336 <B35336@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tx2ehsobe004.messaging.microsoft.com ([65.55.88.14]:9317 "EHLO
	TX2EHSOBE007.bigfish.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751546Ab1KHLMW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Nov 2011 06:12:22 -0500
In-Reply-To: <4EB455B1.8030009@freescale.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



>-----Original Message-----
>From: linuxppc-dev-bounces+leoli=freescale.com@lists.ozlabs.org
>[mailto:linuxppc-dev-bounces+leoli=freescale.com@lists.ozlabs.org] On
>Behalf Of Scott Wood
>Sent: Saturday, November 05, 2011 5:14 AM
>To: Zhao Chenhui-B35336
>Cc: netdev@vger.kernel.org; linuxppc-dev@lists.ozlabs.org
>Subject: Re: [PATCH 6/7] fsl_pmc: Add API to enable device as wakeup event
>source
>
>On 11/04/2011 07:39 AM, Zhao Chenhui wrote:
>> @@ -45,6 +46,72 @@ static int has_lossless;
>>   * code can be compatible with both 32-bit & 36-bit */  extern void
>> mpc85xx_enter_deep_sleep(u64 ccsrbar, u32 powmgtreq);
>>
>> +#ifdef CONFIG_FSL_PMC
>> +/**
>> + * pmc_enable_wake - enable OF device as wakeup event source
>> + * @pdev: platform device affected
>> + * @state: PM state from which device will issue wakeup events
>> + * @enable: True to enable event generation; false to disable
>> + *
>> + * This enables the device as a wakeup event source, or disables it.
>> + *
>> + * RETURN VALUE:
>> + * 0 is returned on success
>> + * -EINVAL is returned if device is not supposed to wake up the
>> +system
>> + * Error code depending on the platform is returned if both the
>> +platform and
>> + * the native mechanism fail to enable the generation of wake-up
>> +events  */ int pmc_enable_wake(struct platform_device *pdev,
>> +				suspend_state_t state, bool enable)
>
>"pmc" is too generic for a global function.  If this can be either enable
>or disable, perhaps it should be something like mpc85xx_pmc_set_wake().
>
>> +{
>> +	int ret = 0;
>> +	struct device_node *clk_np;
>> +	u32 *pmcdr_mask;
>> +
>> +	if (!pmc_regs) {
>> +		printk(KERN_WARNING "PMC is unavailable\n");
>> +		return -ENOMEM;
>> +	}
>
>-ENOMEM is not appropriate here, maybe -ENODEV?
>
>Should print __func__ so the user knows what's complaining.
>
>> +	if (enable && !device_may_wakeup(&pdev->dev))
>> +		return -EINVAL;
>> +
>> +	clk_np = of_parse_phandle(pdev->dev.of_node, "clk-handle", 0);
>> +	if (!clk_np)
>> +		return -EINVAL;
>> +
>> +	pmcdr_mask = (u32 *)of_get_property(clk_np, "fsl,pmcdr-mask", NULL);
>> +	if (!pmcdr_mask) {
>> +		ret = -EINVAL;
>> +		goto out;
>> +	}
>> +
>> +	/* clear to enable clock in low power mode */
>> +	if (enable)
>> +		clrbits32(&pmc_regs->pmcdr, *pmcdr_mask);
>> +	else
>> +		setbits32(&pmc_regs->pmcdr, *pmcdr_mask);
>
>We should probably initialize PMCDR to all bits set (or at least all ones
>we know are valid) -- the default should be "not a wakeup source".

Ideally I agree with you.  But currently we only have the UI of changing wake-up source for Ethernet device.  Will do when we can change all of the devices.

>
>> +/**
>> + * pmc_enable_lossless - enable lossless ethernet in low power mode
>> + * @enable: True to enable event generation; false to disable  */
>> +void pmc_enable_lossless(int enable) {
>> +	if (enable && has_lossless)
>> +		setbits32(&pmc_regs->pmcsr, PMCSR_LOSSLESS);
>> +	else
>> +		clrbits32(&pmc_regs->pmcsr, PMCSR_LOSSLESS); }
>> +EXPORT_SYMBOL_GPL(pmc_enable_lossless);
>> +#endif
>
>Won't we overwrite this later?

You are right.  Will remove the code that overwrite this.

- Leo
