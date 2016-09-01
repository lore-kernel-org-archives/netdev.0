From: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
Subject: Re: [Patch v3 03/11] irqchip: axi-intc: Add support for parent intc
Date: Thu, 1 Sep 2016 14:52:56 +0100
Message-ID: <f45ffb5f-fb66-4083-4754-f8e50689216b@imgtec.com>
References: <1472661352-11983-1-git-send-email-Zubair.Kakakhel@imgtec.com>
 <1472661352-11983-4-git-send-email-Zubair.Kakakhel@imgtec.com>
 <57C70C71.3060603@arm.com> <81b5f75c-51b5-0482-50d1-f51c5687edbc@imgtec.com>
 <57C81BB5.3060807@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <soren.brinkmann@xilinx.com>, <linux-kernel@vger.kernel.org>,
        <linux-mips@linux-mips.org>, <michal.simek@xilinx.com>,
        <netdev@vger.kernel.org>
To: Marc Zyngier <marc.zyngier@arm.com>, <monstr@monstr.eu>,
        <ralf@linux-mips.org>, <tglx@linutronix.de>, <jason@lakedaemon.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <57C81BB5.3060807@arm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On 09/01/2016 01:14 PM, Marc Zyngier wrote:
> On 01/09/16 12:01, Zubair Lutfullah Kakakhel wrote:
>> Hi,
>>
>> Thanks for the review
>> Comments inline.
>>
>> On 08/31/2016 05:57 PM, Marc Zyngier wrote:
>>> On 31/08/16 17:35, Zubair Lutfullah Kakakhel wrote:
>>>> The MIPS based xilfpga platform has the following IRQ structure
>>>>
>>>> Peripherals --> xilinx_intcontroller -> mips_cpu_int controller
>>>>
>>>> Add support for the driver to chain the irq handler
>>>>
>>>> Signed-off-by: Zubair Lutfullah Kakakhel <Zubair.Kakakhel@imgtec.com>
>>>>
>>>> ---
>>>> V2 -> V3
>>>> Reused existing parent node instead of finding again.
>>>> Cleanup up handler based on review
>>>>
>>>> V1 -> V2
>>>>
>>>> No change
>>>> ---
>>>>  drivers/irqchip/irq-axi-intc.c | 24 +++++++++++++++++++++++-
>>>>  1 file changed, 23 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/irqchip/irq-axi-intc.c b/drivers/irqchip/irq-axi-intc.c
>>>> index cb69241..30bb084 100644
>>>> --- a/drivers/irqchip/irq-axi-intc.c
>>>> +++ b/drivers/irqchip/irq-axi-intc.c
>>>> @@ -15,6 +15,7 @@
>>>>  #include <linux/of_address.h>
>>>>  #include <linux/io.h>
>>>>  #include <linux/bug.h>
>>>> +#include <linux/of_irq.h>
>>>>
>>>>  /* No one else should require these constants, so define them locally here. */
>>>>  #define ISR 0x00			/* Interrupt Status Register */
>>>> @@ -154,11 +155,23 @@ static const struct irq_domain_ops xintc_irq_domain_ops = {
>>>>  	.map = xintc_map,
>>>>  };
>>>>
>>>> +static void xil_intc_irq_handler(struct irq_desc *desc)
>>>> +{
>>>> +	u32 pending;
>>>> +
>>>> +	do {
>>>> +		pending = get_irq();
>>>> +		if (pending == -1U)
>>>> +			break;
>>>> +		generic_handle_irq(pending);
>>>> +	} while (true);
>>>> +}
>>>> +
>>>>  static int __init xilinx_intc_of_init(struct device_node *intc,
>>>>  					     struct device_node *parent)
>>>>  {
>>>>  	u32 nr_irq;
>>>> -	int ret;
>>>> +	int ret, irq;
>>>>  	struct xintc_irq_chip *irqc;
>>>>
>>>>  	irqc = kzalloc(sizeof(*irqc), GFP_KERNEL);
>>>> @@ -211,6 +224,15 @@ static int __init xilinx_intc_of_init(struct device_node *intc,
>>>>  	root_domain = irq_domain_add_linear(intc, nr_irq, &xintc_irq_domain_ops,
>>>>  					    irqc);
>>>>
>>>> +	if (parent) {
>>>> +		irq = irq_of_parse_and_map(intc, 0);
>>>> +		if (irq)
>>>> +			irq_set_chained_handler_and_data(irq,
>>>> +							 xil_intc_irq_handler,
>>>> +							 root_domain);
>>>> +
>>>> +	}
>>>> +
>>>>  	irq_set_default_host(root_domain);
>>>>
>>>>  	return 0;
>>>>
>>>
>>> This doesn't seem right. You've now overridden the xintc_irqc pointer,
>>> so I don't know how you can still process interrupts once you've
>>> discovered a secondary interrupt controller. You've also allocated a
>>> second root_domain, changed the default domain to point to the secondary
>>> controller...
>>>
>>> Have you tested this code? Or am I missing something obvious?
>>
>> Yes it works. I'll try to explain the platform setup a bit.
>> Perhaps that will make it clear about what I'm trying to do.
>>
>> UART IRQ -> AXI INTC -> MIPS internal INTC -> CPU
>>
>> MIPS Internal Interrupt controller in drivers/irqchip/irq-mips-cpu.c
>> uses irq_domain_add_legacy while AXI Intc uses irq_domain_add_linear
>>
>> My aim was to set up a chained irq handler with least disturbance.
>>
>> Hence the above code.
>>
>> Your concerns are valid. The code is working because read/writes rely
>> on the static xintc_irqc in the file.
>> And the second root domain is also not breaking the platform because
>> the irq-mips-cpu.c uses irq_domain_add_legacy and doesn't use
>> irq_set_default_host.
>>
>> # cat /proc/interrupts
>>             CPU0
>>    7:      43493      MIPS   7  timer
>>    8:         83  Xilinx INTC   1-level     eth0
>>    9:        417  Xilinx INTC   0-level     serial
>>   10:         15  Xilinx INTC   4-level     10a00000.i2c
>> ERR:          0
>> #
>>
>> Given the above concerns. How about doing things this way?
>>
>> 	if (parent) {
>> 		irq = irq_of_parse_and_map(intc, 0);
>> 		if (irq)
>> 			irq_set_chained_handler_and_data(irq,
>> 							 xil_intc_irq_handler,
>> 							 irqc);
>>
>> 	} else
>> 		irq_set_default_host(root_domain);
>>
>> default host is only set if no parent exists.
>> And the irqc pointer is passed as the data.
>
> But that still doesn't address the case I had in mind, which is when you
> have *two* AXI-intc, one cascaded into the other. Is that something that
> could be built? You should at least make sure that there is a big fat
> warning if you don't want to support that case, because that will be
> hell to debug.

Oo. I didn't think of that one. tbh, I'm not sure if that is currently supported
because this driver came out of arch/microblaze. And it didn't have any code that
looked supportive of chained interrupt handling.

'Technically', it should be possible to synthesize two daisy chained axi interrupt
controllers on an FPGA. But I don't see it being supported before.

A warning would be nice. Any suggestions on the most suitable way?

Thanks,
ZubairLK

>
> Thanks,
>
> 	M.
>
