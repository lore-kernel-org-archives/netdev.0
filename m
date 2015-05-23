From: "Rafael J. Wysocki" <rjw@rjwysocki.net>
Subject: Re: [V5 PATCH 1/5] ACPI / scan: Parse _CCA and setup device coherency
Date: Sat, 23 May 2015 03:25:21 +0200
Message-ID: <9319342.HPcAml3MbA@vostro.rjw.lan>
References: <1432159758-4486-1-git-send-email-Suravee.Suthikulpanit@amd.com> <2939517.7sXtxU6TkU@vostro.rjw.lan> <555FC695.1000404@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7Bit
Cc: lenb@kernel.org, catalin.marinas@arm.com, will.deacon@arm.com,
	thomas.lendacky@amd.com, herbert@gondor.apana.org.au,
	davem@davemloft.net, arnd@arndb.de, msalter@redhat.com,
	hanjun.guo@linaro.org, al.stone@linaro.org,
	grant.likely@linaro.org, leo.duran@amd.com,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	linux-kernel@vger.kernel.org, linaro-acpi@lists.linaro.org,
	netdev@vger.kernel.org, linux-crypto@vger.kernel.org
To: Suravee Suthikulanit <suravee.suthikulpanit@amd.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
In-Reply-To: <555FC695.1000404@amd.com>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, May 22, 2015 07:15:17 PM Suravee Suthikulanit wrote:
> On 5/22/2015 6:05 PM, Rafael J. Wysocki wrote:
> > On Friday, May 22, 2015 05:24:15 PM Suravee Suthikulanit wrote:
> >> Not sure if this went out earlier. So I am resending.
> >>
> >> On 5/22/15 16:56, Rafael J. Wysocki wrote:
> >>>> diff --git a/drivers/acpi/glue.c b/drivers/acpi/glue.c
> >>>>> index 39c485b..b9657af 100644
> >>>>> --- a/drivers/acpi/glue.c
> >>>>> +++ b/drivers/acpi/glue.c
> >>>>> @@ -13,6 +13,7 @@
> >>>>>   #include <linux/slab.h>
> >>>>>   #include <linux/rwsem.h>
> >>>>>   #include <linux/acpi.h>
> >>>>> +#include <linux/dma-mapping.h>
> >>>>>
> >>>>>   #include "internal.h"
> >>>>>
> >>>>> @@ -167,6 +168,7 @@ int acpi_bind_one(struct device *dev, struct acpi_device *acpi_dev)
> >>>>>   	struct list_head *physnode_list;
> >>>>>   	unsigned int node_id;
> >>>>>   	int retval = -EINVAL;
> >>>>> +	bool coherent;
> >>>>>
> >>>>>   	if (has_acpi_companion(dev)) {
> >>>>>   		if (acpi_dev) {
> >>>>> @@ -223,6 +225,9 @@ int acpi_bind_one(struct device *dev, struct acpi_device *acpi_dev)
> >>>>>   	if (!has_acpi_companion(dev))
> >>>>>   		ACPI_COMPANION_SET(dev, acpi_dev);
> >>>>>
> >>>>> +	if (acpi_check_dma(acpi_dev, &coherent))
> >>>>> +		arch_setup_dma_ops(dev, 0, 0, NULL, coherent);
> >>>>> +
> >>> Well, so is this going to work for PCI too after all?
> >>>
> >>
> >> No, as Bjorn suggested, PCI changes for setting DMA coherent from _CCA
> >> (patch 3/6 in V4) will be submitted separately. We are working on
> >> cleaning up and up-streaming the PCI ACPI support for ARM64.
> >
> > OK, but acpi_bind_one() is called for PCI devices too.  Won't that be a problem?
> >
> >
>  >
> In this case, we would be going through the following call path:
> 
>    --> pci_device_add()
>     |--> pci_dma_configure() ** 1 **
>     |--> device_add()
>       |--> platform_notify()
>         |--> acpi_platform_notify()
>          |--> acpi_bind_one() ** 2 **
> 
> At (1), we would be calling arch_setup_dma_ops() with the PCI host 
> bridge _CCA information. So, it should have already taken care of 
> setting up device coherency here.
> 
> At (2), if there is no acpi_dev for endpoint devices (which I believe 
> this is normally the case), it would return early and skip 
> arch_setup_dma_ops().

That's not correct.  There may be ACPI companions for endpoint devices too.


> At (2), if there is an acpi_dev, the coherent_dma flag should have 
> already been setup by the acpi_init_device_object during ACPI scan.

That one sets the flag for the *ACPI* *companion* of the device, which
I'm still thinking is pointless, isn't it?


> However, I am not certain about this case since I don't have the DSDT 
> containing  PCI endpoint devices to test with.

Every x86 PC has them (as far as I can say), but in that case there's no
_CCA and they are all coherent.


-- 
I speak only for myself.
Rafael J. Wysocki, Intel Open Source Technology Center.
