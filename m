From: Sunil Kovvuri <sunil.kovvuri@gmail.com>
Subject: Re: [PATCH net-next 6/8] net: thunderx: Rework interrupt handler
Date: Sun, 30 Aug 2015 22:01:04 +0530
Message-ID: <CA+sq2CdEn4vq3FD5RyQwuagmE9TNu91XmamjEFLaF4SOyrp64A@mail.gmail.com>
References: <CALW4P++2cG5epoit8BXBjp7Z2PK=P5wqbxkDqrt6kCa7SaZK+g@mail.gmail.com>
	<55E2CAE6.1040305@auriga.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexey Klimov <klimov.linux@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Robert Richter <rric@kernel.org>,
	David Daney <david.daney@cavium.com>,
	Sunil Goutham <Sunil.Goutham@caviumnetworks.com>,
	Aleksey Makarov <aleksey.makarov@caviumnetworks.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Robert Richter <robert.richter@caviumnetworks.com>,
	Sunil Goutham <sgoutham@cavium.com>,
	LAKML <linux-arm-kernel@lists.infradead.org>
To: Aleksey Makarov <feumilieu@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <55E2CAE6.1040305@auriga.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 30, 2015 at 2:50 PM, Aleksey Makarov <feumilieu@gmail.com> wrote:
> On 29.08.2015 04:44, Alexey Klimov wrote:
>
>>> -static irqreturn_t nicvf_intr_handler(int irq, void *nicvf_irq)
>>> +static irqreturn_t nicvf_intr_handler(int irq, void *cq_irq)
>>> +{
>>> +       struct nicvf_cq_poll *cq_poll = (struct nicvf_cq_poll *)cq_irq;
>>> +       struct nicvf *nic = cq_poll->nicvf;
>>> +       int qidx = cq_poll->cq_idx;
>>> +
>>> +       nicvf_dump_intr_status(nic);
>>> +
>>> +       /* Disable interrupts */
>>> +       nicvf_disable_intr(nic, NICVF_INTR_CQ, qidx);
>>> +
>>> +       /* Schedule NAPI */
>>> +       napi_schedule(&cq_poll->napi);
>>> +
>>> +       /* Clear interrupt */
>>> +       nicvf_clear_intr(nic, NICVF_INTR_CQ, qidx);
>>> +
>>> +       return IRQ_HANDLED;
>>> +}
>>
>>
>> You're not considering spurious irqs in all new irq handlers here and
>> below and schedule napi/tasklets unconditionally. Is it correct?
>> For me it looks like previous implementation relied on reading of
>> NIC_VF_INT to understand irq type and what actions should be
>> performed. It generally had idea that no interrupt might occur.
>
>
> 1. The previous version of the handler did not handle spurious interrupts
> either.  Probably that means that the author of the patch knows for sure
> that they do not happen.

Yes, no spurious interrupts are expected from hardware.
Even if it does the NAPI poll routine will handle it as valid
descriptor count would be zero.
Don't think it makes sense to check for spurious interrupt upon every interrupt.

>
> 2. Instead of reading the status register new version registers different
> handlers for different irqs.  I don't see why it can be wrong.

Previous implementation results on scheduling multiple NAPI poll handlers
on the same CPU even if IRQ's affinities are set to different CPUs.
Hence they are seperated now.

>
> I am going to address your other suggestions in the next version of the
> patchset.
>
> Thank you
> Aleksey Makarov
>
