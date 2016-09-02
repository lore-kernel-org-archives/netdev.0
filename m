From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [Patch v4 02/12] irqchip: axi-intc: Clean up irqdomain argument
 and read/write
Date: Fri, 2 Sep 2016 11:47:19 +0100
Message-ID: <3e4cf28a-2efd-84ab-9f78-6755dec9fb94@imgtec.com>
References: <1472748665-47774-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472748665-47774-3-git-send-email-Zubair.Kakakhel@imgtec.com>
 <57C86241.8000806@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <michal.simek@xilinx.com>,
        <netdev@vger.kernel.org>
To: Marc Zyngier <marc.zyngier@arm.com>, <monstr@monstr.eu>,
        <ralf@linux-mips.org>, <tglx@linutronix.de>, <jason@lakedaemon.net>
Return-path: <linux-mips-bounce@linux-mips.org>
In-Reply-To: <57C86241.8000806@arm.com>
Sender: linux-mips-bounce@linux-mips.org
Errors-to: linux-mips-bounce@linux-mips.org
List-help: <mailto:ecartis@linux-mips.org?Subject=help>
List-unsubscribe: <mailto:ecartis@linux-mips.org?subject=unsubscribe%20linux-mips>
List-software: Ecartis version 1.0.0
List-subscribe: <mailto:ecartis@linux-mips.org?subject=subscribe%20linux-mips>
List-owner: <mailto:ralf@linux-mips.org>
List-post: <mailto:linux-mips@linux-mips.org>
List-archive: <http://www.linux-mips.org/archives/linux-mips/>
List-Id: netdev.vger.kernel.org

Hi,

Thanks for the review.
Comments inline.

On 09/01/2016 06:15 PM, Marc Zyngier wrote:
> On 01/09/16 17:50, Zubair Lutfullah Kakakhel wrote:
>> The drivers read/write function handling is a bit quirky.
>> And the irqmask is passed directly to the handler.
>>
>> Add a new irqchip struct to pass to the handler and
>> cleanup read/write handling.
>>
>> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
>>
>> ---
>> V3 -> V4
>> Better error handling for kzalloc
>> Erroring out if the axi intc is probed twice as that isn't
>> supported
>>

...

>>  static int __init xilinx_intc_of_init(struct device_node *intc,
>>  					     struct device_node *parent)
>>  {
>> -	u32 nr_irq, intr_mask;
>> +	u32 nr_irq;
>>  	int ret;
>> +	struct xintc_irq_chip *irqc;
>> +
>> +	irqc = kzalloc(sizeof(*irqc), GFP_KERNEL);
>> +	if (!irqc)
>> +		return -ENOMEM;
>>
>> -	intc_baseaddr = of_iomap(intc, 0);
>> -	BUG_ON(!intc_baseaddr);
>> +	if (xintc_irqc) {
>> +		pr_err("%s: Multiple instances of axi_intc aren't supported\n");
>> +		ret = -EINVAL;
>> +		goto err_alloc;
>
> How about testing the variable first and error-ing early, rather than
> performing the allocation and undoing it later?
>

Sure. Thanks

>> +	} else {
>> +		xintc_irqc = irqc;
>> +	}
>> +
>> +	irqc->base = of_iomap(intc, 0);
>> +	BUG_ON(!irqc->base);
>>
>>  	ret = of_property_read_u32(intc, "xlnx,num-intr-inputs", &nr_irq);
>>  	if (ret < 0) {
>>  		pr_err("%s: unable to read xlnx,num-intr-inputs\n", __func__);
>> -		return ret;
>> +		goto err_alloc;
>>  	}
>>
>> -	ret = of_property_read_u32(intc, "xlnx,kind-of-intr", &intr_mask);
>> +	ret = of_property_read_u32(intc, "xlnx,kind-of-intr", &irqc->intr_mask);
>>  	if (ret < 0) {
>>  		pr_err("%s: unable to read xlnx,kind-of-intr\n", __func__);
>> -		return ret;
>> +		goto err_alloc;
>>  	}
>>
>> -	if (intr_mask >> nr_irq)
>> +	if (irqc->intr_mask >> nr_irq)
>>  		pr_warn("%s: mismatch in kind-of-intr param\n", __func__);
>>
>>  	pr_info("%s: num_irq=%d, edge=0x%x\n",
>> -		intc->full_name, nr_irq, intr_mask);
>> +		intc->full_name, nr_irq, irqc->intr_mask);
>>
>> -	write_fn = intc_write32;
>> -	read_fn = intc_read32;
>> +	irqc->read = intc_read32;
>> +	irqc->write = intc_write32;
>>
>>  	/*
>>  	 * Disable all external interrupts until they are
>>  	 * explicity requested.
>>  	 */
>> -	write_fn(0, intc_baseaddr + IER);
>> +	xintc_write(irqc, IER, 0);
>>
>>  	/* Acknowledge any pending interrupts just in case. */
>> -	write_fn(0xffffffff, intc_baseaddr + IAR);
>> +	xintc_write(irqc, IAR, 0xffffffff);
>>
>>  	/* Turn on the Master Enable. */
>> -	write_fn(MER_HIE | MER_ME, intc_baseaddr + MER);
>> -	if (!(read_fn(intc_baseaddr + MER) & (MER_HIE | MER_ME))) {
>> -		write_fn = intc_write32_be;
>> -		read_fn = intc_read32_be;
>> -		write_fn(MER_HIE | MER_ME, intc_baseaddr + MER);
>> +	xintc_write(irqc, MER, MER_HIE | MER_ME);
>> +	if (!(xintc_read(irqc, MER) & (MER_HIE | MER_ME))) {
>> +		irqc->read = intc_read32_be;
>> +		irqc->write = intc_write32_be;
>> +		xintc_write(irqc, MER, MER_HIE | MER_ME);
>>  	}
>>
>> -	/* Yeah, okay, casting the intr_mask to a void* is butt-ugly, but I'm
>> -	 * lazy and Michal can clean it up to something nicer when he tests
>> -	 * and commits this patch.  ~~gcl */
>>  	root_domain = irq_domain_add_linear(intc, nr_irq, &xintc_irq_domain_ops,
>> -							(void *)intr_mask);
>> +					    irqc);
>
> What if the domain allocation fails? You've now configured the HW for
> something you can't use. What are the side effects? Hint: handle
> everything that can fail first, and only then poke the HW.
>

Thanks for pointing it out. I'll add an error check.

>>
>>  	irq_set_default_host(root_domain);
>>
>>  	return 0;
>> +
>> +err_alloc:
>> +	xintc_irqc = NULL;
>> +	kfree(irqc);
>> +	return ret;
>> +
>>  }
>>
>>  IRQCHIP_DECLARE(xilinx_intc, "xlnx,xps-intc-1.00.a", xilinx_intc_of_init);
>>
>
> Instead of posting 3 versions in 3 days, please take the time to
> correctly address the comments, and review your own code before
> re-posting it. Rushing to get it merged for 4.9 is really not the best
> approach.

Apologies for the spam. Combination of some free time this week + window of opportunity.
To be fair, AFAIK, this driver has lived in arch/microblaze without receiving a full thorough
review by any irqchip maintainer.

Hence the various missing bits. e.g. the root_domain error check didn't exist before.
And I didn't see it.

Regards,
ZubairLK

>
> Thanks,
>
> 	M.
>
