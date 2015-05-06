From: Suravee Suthikulpanit <Suravee.Suthikulpanit@amd.com>
Subject: Re: [V2 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Tue, 5 May 2015 23:15:37 -0500
Message-ID: <55499569.8060403@amd.com>
References: <1430838729-21572-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1430838729-21572-2-git-send-email-Suravee.Suthikulpanit@amd.com>
 <3234610.3j3NfP3xpR@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lenb@kernel.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <thomas.lendacky@amd.com>,
	<herbert@gondor.apana.org.au>, <davem@davemloft.net>,
	<msalter@redhat.com>, <hanjun.guo@linaro.org>,
	<al.stone@linaro.org>, <grant.likely@linaro.org>, <arnd@arndb.de>,
	<leo.duran@amd.com>, <linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linaro-acpi@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>,
	Mika Westerberg <mika.westerberg@linux.intel.com>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <3234610.3j3NfP3xpR@vostro.rjw.lan>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[RESEND]

On 5/5/15 15:36, Rafael J. Wysocki wrote:
> On Tuesday, May 05, 2015 10:12:05 AM Suravee Suthikulpanit wrote:
>> diff --git a/drivers/acpi/Kconfig b/drivers/acpi/Kconfig
>> index ab2cbb5..dd386e9 100644
>> --- a/drivers/acpi/Kconfig
>> +++ b/drivers/acpi/Kconfig
>> @@ -54,6 +54,12 @@ config ACPI_GENERIC_GSI
>>   config ACPI_SYSTEM_POWER_STATES_SUPPORT
>>   	bool
>>
>> +config ACPI_MUST_HAVE_CCA
>
> ACPI_CCA_REQUIRED maybe?

Sure.

>
>> +	bool
>> +
>> +config ACPI_SUPPORT_CCA_ZERO
>
> I guess this means "we support devices that can DMA, but are not coherent".
> right?

Yes, basically when _CCA=0.

>> +	bool
>> +
>>   config ACPI_SLEEP
>>   	bool
>>   	depends on SUSPEND || HIBERNATION
>> diff --git a/drivers/acpi/acpi_platform.c b/drivers/acpi/acpi_platform.c
>> index 4bf7559..a6feca4 100644
>> --- a/drivers/acpi/acpi_platform.c
>> +++ b/drivers/acpi/acpi_platform.c
>> @@ -108,9 +108,11 @@ struct platform_device *acpi_create_platform_device(struct acpi_device *adev)
>>   	if (IS_ERR(pdev))
>>   		dev_err(&adev->dev, "platform device creation failed: %ld\n",
>>   			PTR_ERR(pdev));
>> -	else
>> +	else {
>
> Please add braces to both branches when making such changes (as per CodingStyle).
>

OK.

>> +		acpi_setup_device_dma(adev, &pdev->dev);
>
> Why do we need to do that here (for the second time)?

Because we are calling:
   acpi_create_platform_device()
     |--> platform_device_register_device_full()
       |-->platform_device_alloc()

This creates platform_device, which allocate a new platform_device->dev. 
This is not the same as the original acpi_device->dev that was created 
during acpi_add_single_object(). So, we have to set up the device 
coherency again.


>> diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
>> index 849b699..ac33b29 100644
>> --- a/drivers/acpi/scan.c
>> +++ b/drivers/acpi/scan.c
>> @@ -11,6 +11,7 @@
>>   #include <linux/kthread.h>
>>   #include <linux/dmi.h>
>>   #include <linux/nls.h>
>> +#include <linux/dma-mapping.h>
>>
>>   #include <asm/pgtable.h>
>>
>> @@ -2137,6 +2138,66 @@ void acpi_free_pnp_ids(struct acpi_device_pnp *pnp)
>>   	kfree(pnp->unique_id);
>>   }
>>
>> +void acpi_setup_device_dma(struct acpi_device *adev, struct device *dev)
>> +{
>> +	int coherent = acpi_dma_is_coherent(adev);
>> +
>> +	/**
>> +	 * Currently, we only support DMA for devices that _CCA=1
>> +	 * since this seems to be the case on most ACPI platforms.
>> +	 *
>> +	 * For the case when _CCA=0 (i.e. is_coherent=0 && cca_seen=1),
>> +	 * we would rely on arch-specific cache maintenance for
>> +	 * non-coherence DMA operations if architecture enables
>> +	 * CONFIG_ACPI_SUPPORT_CCA_ZERO.
>> +	 *
>> +	 * For the case when _CCA is missing but platform requires it
>> +	 * (i.e. is_coherent=0 && cca_seen=0), we do not call
>> +	 * arch_setup_dma_ops() and fallback to arch-specific default
>> +	 * handling.
>> +	 */
>> +	if (adev->flags.cca_seen) {
>> +		if (!coherent && !IS_ENABLED(CONFIG_ACPI_SUPPORT_CCA_ZERO))
>> +			return;
>> +		arch_setup_dma_ops(dev, 0, 0, NULL, coherent);
>
> Oh dear.

I made a mistake here. This logic should also call arch_setup_dma_ops() 
when cca_seen=0 and coherent=1 (e.g. when _CCA is not required and 
default to coherent when it is missing). The current logic doesn't do that.

>
> What about
>
> 	if (adev->flags.cca_seen && (coherent || IS_ENABLED(CONFIG_ACPI_SUPPORT_CCA_ZERO)))
> 		arch_setup_dma_ops(dev, 0, 0, NULL, coherent);

What about:
	if (coherent ||
	    (adev->flags.cca_seen &&
			IS_ENABLED(CONFIG_ACPI_SUPPORT_CCA_ZERO))
		arch_setup_dma_ops(dev, 0, 0, NULL, coherent);
	
> I wonder how this is going to affect x86/ia64 too?
>

This should not affect x86 since arch_setup_dma_ops() is currently not 
implement for x86, and default to NOP (see include/linux/dma-mapping.h). 
  Also, on x86, _CCA is not required and default to 1 if missing.

Thanks,

Suravee
