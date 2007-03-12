From: Tejun Heo <htejun@gmail.com>
Subject: Re: 2.6.21-rc3-git4 ata1.00: qc timeout (cmd 0xef) (crashdump	kernel)
Date: Tue, 13 Mar 2007 01:56:36 +0900
Message-ID: <45F58644.1070905@gmail.com>
References: <6bffcb0e0703090857r14eda34bj92f3fd1d0008edb8@mail.gmail.com>	 <45F51218.9030907@gmail.com>  <45F5805A.5080509@googlemail.com> <1173718012.13341.95.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	Jeff Garzik <jeff@garzik.org>, linux-ide@vger.kernel.org,
	Ingo Molnar <mingo@elte.hu>,
	Bartlomiej Zolnierkiewicz <bzolnier@gmail.com>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org, Alan Cox <alan@lxorguk.ukuu.org.uk>
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from wx-out-0506.google.com ([66.249.82.238]:17643 "EHLO
	wx-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030708AbXCLQ4h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Mar 2007 12:56:37 -0400
Received: by wx-out-0506.google.com with SMTP id h31so1732819wxd
        for <netdev@vger.kernel.org>; Mon, 12 Mar 2007 09:56:36 -0700 (PDT)
In-Reply-To: <1173718012.13341.95.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thomas Gleixner wrote:
> On Mon, 2007-03-12 at 17:31 +0100, Michal Piotrowski wrote:
>> Calling initcall 0xc19154d8: piix_ide_init+0x0/0xbb()
>> Calling initcall 0xc19155b6: generic_ide_init+0x0/0x16()
>> Calling initcall 0xc191572e: ide_init+0x0/0x81()
>> Uniform Multi-Platform E-IDE driver Revision: 7.00alpha2
>> ide: Assuming 33MHz system bus speed for PIO modes; override with idebus=xx
>> ICH5: IDE controller at PCI slot 0000:00:1f.1
>> irq 5: nobody cared (try booting with the "irqpoll" option)
>>  [<c1604556>] show_trace_log_lvl+0x1a/0x2f
>>  [<c1604c2c>] show_trace+0x12/0x14
>>  [<c1604cde>] dump_stack+0x16/0x18
>>  [<c164341c>] __report_bad_irq+0x39/0x79
>>  [<c16435eb>] note_interrupt+0x18f/0x1c8
>>  [<c1643ec6>] handle_level_irq+0x95/0xcb
>>  [<c1605dd8>] do_IRQ+0xb4/0xe0
>>  =======================
>> handlers:
>> [<c174f55e>] (skge_intr+0x0/0x3ff)
>> Disabling IRQ #5
> 
> I know this one :( 
> 
> It seems to be related to the BIOS spinning up the CDROM and leaving the
> IDE controller in some weird state. When we come back the interrupt is
> screaming and nobody cares, so it gets disabled. I have no clue yet, how
> to handle this.
> 
> Disabling the interrupt across suspend/resume helps, but does not work,
> when the interrupt is shared with some other device.

Similar thing can happen during initialization.  I haven't actually
instrumented the code but I think what happens is

1. the controller has IRQ stuck high (infrequent but possible)
2. the IRQ is already requested by another device
3. the IRQ gets disabled due to screaming interrupts at the moment
ata_piix does pci_enable_device().

I think we can be much more resilient to screaming interrupts if we
enable device with IRQ disabled and enable it after the device is
initialized to some level, possibly when requesting IRQ.

-- 
tejun
