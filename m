From: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Subject: Re: [V4 PATCH 1/6] ACPI / scan: Parse _CCA and setup device coherency
Date: Mon, 18 May 2015 17:38:17 -0500
Message-ID: <555A69D9.7080508@amd.com>
References: <1431724994-21601-1-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1431724994-21601-2-git-send-email-Suravee.Suthikulpanit@amd.com>
 <1880793.yBqSWvxoqF@vostro.rjw.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <lenb@kernel.org>, <catalin.marinas@arm.com>,
	<will.deacon@arm.com>, <bhelgaas@google.com>,
	<thomas.lendacky@amd.com>, <herbert@gondor.apana.org.au>,
	<davem@davemloft.net>, <arnd@arndb.de>, <msalter@redhat.com>,
	<hanjun.guo@linaro.org>, <al.stone@linaro.org>,
	<grant.likely@linaro.org>, <leo.duran@amd.com>,
	<linux-arm-kernel@lists.infradead.org>,
	<linux-acpi@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<linaro-acpi@lists.linaro.org>, <netdev@vger.kernel.org>,
	<linux-crypto@vger.kernel.org>
To: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <1880793.yBqSWvxoqF@vostro.rjw.lan>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rafael,

On 5/15/2015 6:53 PM, Rafael J. Wysocki wrote:
> On Friday, May 15, 2015 04:23:09 PM Suravee Suthikulpanit wrote:
>> [...]
>> diff --git a/drivers/acpi/acpi_platform.c b/drivers/acpi/acpi_platform.c
>> index 4bf7559..f6bc438 100644
>> --- a/drivers/acpi/acpi_platform.c
>> +++ b/drivers/acpi/acpi_platform.c
>> @@ -103,14 +103,18 @@ struct platform_device *acpi_create_platform_device(struct acpi_device *adev)
>>   	pdevinfo.res = resources;
>>   	pdevinfo.num_res = count;
>>   	pdevinfo.fwnode = acpi_fwnode_handle(adev);
>> -	pdevinfo.dma_mask = DMA_BIT_MASK(32);
>> +	pdevinfo.dma_mask = acpi_dma_is_supported(adev) ? DMA_BIT_MASK(32) : 0;
>>   	pdev = platform_device_register_full(&pdevinfo);
>> -	if (IS_ERR(pdev))
>> +	if (IS_ERR(pdev)) {
>>   		dev_err(&adev->dev, "platform device creation failed: %ld\n",
>>   			PTR_ERR(pdev));
>> -	else
>> +	} else {
>> +		if (acpi_dma_is_supported(adev))
>> +			arch_setup_dma_ops(&pdev->dev, 0, 0, NULL,
>> +					   acpi_dma_is_coherent(adev));
>
> Shouldn't we generally do that in acpi_bind_one() for all bus types
> that don't have specific handling rather than here?

I think that would also work, and makes sense. However, I'm not sure if 
this would help in the case when we are creating PCI end-point devices, 
since the CCA is specified at the host bridge node, and there is no ACPI 
companion for the end-point devices. It seems that patch 3/6 of this 
series is still needed.


>> diff --git a/drivers/acpi/scan.c b/drivers/acpi/scan.c
>> index 849b699..c56e66a 100644
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
>> @@ -2137,6 +2138,44 @@ void acpi_free_pnp_ids(struct acpi_device_pnp *pnp)
>>   	kfree(pnp->unique_id);
>>   }
>>
>> +static void acpi_init_coherency(struct acpi_device *adev)
>> +{
>> +	unsigned long long cca = 0;
>> +	acpi_status status;
>> +	struct acpi_device *parent = adev->parent;
>> +	struct acpi_buffer buffer = { ACPI_ALLOCATE_BUFFER, NULL };
>> +
>> +	if (parent && parent->flags.cca_seen) {
>> +		/*
>> +		 * From ACPI spec, OSPM will ignore _CCA if an ancestor
>> +		 * already saw one.
>> +		 */
>> +		adev->flags.cca_seen = 1;
>> +		cca = acpi_dma_is_coherent(parent);
>
> Shouldn't the device's own _CCA take precedence?
According to the ACPI specification, the parent's _CCA take precedence.

>
>> +	} else {
>> +		status = acpi_evaluate_integer(adev->handle, "_CCA",
>> +					       NULL, &cca);
>> +		if (ACPI_SUCCESS(status)) {
>> +			adev->flags.cca_seen = 1;
>> +		} else if (!IS_ENABLED(CONFIG_ACPI_CCA_REQUIRED)) {
>> +			/*
>> +			 * If architecture does not specify that _CCA is
>> +			 * required for DMA-able devices (e.g. x86),
>> +			 * we default to _CCA=1.
>> +			 */
>> +			cca = 1;
>> +		} else {
>
> What about using acpi_handle_debug() here?
Ok I can do that.

>> [...]
>> diff --git a/include/acpi/acpi_bus.h b/include/acpi/acpi_bus.h
>> index 8de4fa9..2a05ffb 100644
>> --- a/include/acpi/acpi_bus.h
>> +++ b/include/acpi/acpi_bus.h
>> @@ -208,7 +208,9 @@ struct acpi_device_flags {
>>   	u32 visited:1;
>>   	u32 hotplug_notify:1;
>>   	u32 is_dock_station:1;
>> -	u32 reserved:23;
>> +	u32 is_coherent:1;
>
> I'd prefer to call this 'coherent_dma'.

OK.

Thanks,

Suravee
