From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [Patch v3 02/11] irqchip: axi-intc: Clean up irqdomain argument
 and read/write
Date: Thu, 1 Sep 2016 11:41:03 +0100
Message-ID: <97c89803-915f-5f3b-ceaf-b7697d5f6bca@imgtec.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472661352-11983-3-git-send-email-Zubair.Kakakhel@imgtec.com>
 <57C70B43.6010107@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <michal.simek@xilinx.com>,
        <netdev@vger.kernel.org>
To: Marc Zyngier <marc.zyngier@arm.com>, <monstr@monstr.eu>,
        <ralf@linux-mips.org>, <tglx@linutronix.de>, <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57C70B43.6010107@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Thank you for the reviews.

Some comments below

On 08/31/2016 05:52 PM, Marc Zyngier wrote:
> On 31/08/16 17:35, Zubair Lutfullah Kakakhel wrote:
>> The drivers read/write function handling is a bit quirky.
>> And the irqmask is passed directly to the handler.
>>
>> Add a new irqchip struct to pass to the handler and
>> cleanup read/write handling.
>>
>> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
>>
>> ---
>> V2 -> V3
>> New patch. Cleans up driver structure
>> ---
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
>
> Now that you dynamically allocate things, how are you handling failures?
>
>> +	if (!irqc)
>> +		return -ENOMEM;
>> +
>> +	xintc_irqc = irqc;
>>
>> -	intc_baseaddr = of_iomap(intc, 0);
>> -	BUG_ON(!intc_baseaddr);
>> +	irqc->base = of_iomap(intc, 0);
>> +	BUG_ON(!irqc->base);
>>
>>  	ret = of_property_read_u32(intc, "xlnx,num-intr-inputs", &nr_irq);
>>  	if (ret < 0) {
>> @@ -150,43 +176,40 @@ static int __init xilinx_intc_of_init(struct device_node *intc,
>>  		return ret;
>
> All the return paths should now take care of releasing the allocated
> resources.
>

Thanks for pointing it out. I'll fix it in the next series.

>>  	}
>>
>> -	ret = of_property_read_u32(intc, "xlnx,kind-of-intr", &intr_mask);
>> +	ret = of_property_read_u32(intc, "xlnx,kind-of-intr", &irqc->intr_mask);
>>  	if (ret < 0) {
>>  		pr_err("%s: unable to read xlnx,kind-of-intr\n", __func__);
>>  		return ret;
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
>>
>>  	irq_set_default_host(root_domain);
>>
>>
>
> You haven't addressed the comment on get_irq() which could be static (at
> least from solely looking at this file).

Apologies. In a rush to get a series out before heading home, it slipped my mind.
It is needed as it is used in arch/microblaze/kernel/irq.c

But I'll add a patch to rename it correctly. get_irq is far too generic outside arch code.

Thanks,
ZubairLK

>
> Thanks,
>
> 	M.
>
