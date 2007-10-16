From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: MSI interrupts and disable_irq
Date: Tue, 16 Oct 2007 15:44:55 -0400
Message-ID: <471514B7.9080002@pobox.com>
References: <46FC15A9.1070803@nvidia.com> <46FDBCB4.9090802@pobox.com>	 <4710901F.8010206@colorfullife.com> <4713E713.9060702@pobox.com>	 <86802c440710161023p3fbd6832gdb6d10a1b5e9d932@mail.gmail.com>	 <4714F736.5000302@pobox.com> <86802c440710161059x17fdb4f2sb1b9582d64a883f9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Manfred Spraul <manfred@colorfullife.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>,
	nedev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36776 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760659AbXJPTpH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Oct 2007 15:45:07 -0400
In-Reply-To: <86802c440710161059x17fdb4f2sb1b9582d64a883f9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Yinghai Lu wrote:
> On 10/16/07, Jeff Garzik <jgarzik@pobox.com> wrote:
>> Yinghai Lu wrote:
>>> On 10/15/07, Jeff Garzik <jgarzik@pobox.com> wrote:
>>>> Manfred Spraul wrote:
>>>>> Jeff Garzik wrote:
>>>>>> I think the scenario you outline is an illustration of the approach's
>>>>>> fragility:  disable_irq() is a heavy hammer that originated with INTx,
>>>>>> and it relies on a chip-specific disable method (kernel/irq/manage.c)
>>>>>> that practically guarantees behavior will vary across MSI/INTx/etc.
>>>>>>
>>>>> I checked the code: IRQ_DISABLE is implemented in software, i.e.
>>>>> handle_level_irq() only calls handle_IRQ_event() [and then the nic irq
>>>>> handler] if IRQ_DISABLE is not set.
>>>>> OTHO: The last trace looks as if nv_do_nic_poll() is interrupted by an irq.
>>>>>
>>>>> Perhaps something corrupts dev->irq? The irq is requested with
>>>>>    request_irq(np->pci_dev->irq, handler, IRQF_SHARED, dev->name, dev)
>>>>> and disabled with
>>>>>    disable_irq_lockdep(dev->irq);
>>>>>
>>>>> Someone around with a MSI capable board? The forcedeth driver does
>>>>>    dev->irq = pci_dev->irq
>>>>> in nv_probe(), especially before pci_enable_msi().
>>>>> Does pci_enable_msi() change pci_dev->irq? Then we would disable the
>>>>> wrong interrupt....
>>>> Remember, fundamentally MSI-X is a one-to-many relationship, when you
>>>> consider a single PCI device might have multiple vectors.
>>> msi-x is using other entry
>>>
>>>                if (np->msi_flags & NV_MSI_X_ENABLED)
>>>
>>> enable_irq_lockdep(np->msi_x_entry[NV_MSI_X_VECTOR_ALL].vector);
>> Correct, but the overall point was that MSI-X conceptually conflicts
>> with the existing "lockless" disable_irq() schedule, which was written
>> when there was a one-one relationship between irq, PCI device, and work
>> to be done.
> 
> Can I use your new driver with RHEL 5 or RHEL 5.1?

Not without modification, since it depends on the napi_struct work 
currently in torvalds/linux-2.6.git.

But I am currently rewriting the fe-lock yet again, and most of those 
changes can be applied to pre-napi_struct forcedeth.

	Jeff



