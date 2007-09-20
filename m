From: Valentine Barshak <vbarshak@ru.mvista.com>
Subject: Re: [PATCH] pci: Fix e100 interrupt quirk
Date: Thu, 20 Sep 2007 15:33:22 +0400
Message-ID: <46F25A82.8090300@ru.mvista.com>
References: <20070918111737.GA7026@ru.mvista.com> <20070919233726.9d81b674.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Auke Kok <auke-jan.h.kok@intel.com>,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rtsoft3.corbina.net ([85.21.88.6]:14085 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750758AbXITLe0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 07:34:26 -0400
In-Reply-To: <20070919233726.9d81b674.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton wrote:
> On Tue, 18 Sep 2007 15:17:37 +0400 Valentine Barshak <vbarshak@ru.mvista.com> wrote:
> 
>> PCI memory space may have a 64-bit offset on some architectures
>> (for example, PowerPC 440) and the actual PCI memory address
>> has to fixed up (an offset to PCI mem space shuld be added)
>> before remapping. So, pci_iomap should be used instead of
>> reading and remapping PCI BAR directly. This has been tested
>> on Sequoia PowerPC 440EPx board.
>>
>> Signed-off-by: Valentine Barshak <vbarshak@ru.mvista.com>
>> ---
>>
>> --- linux-2.6.orig/drivers/pci/quirks.c	2007-09-04 21:15:43.000000000 +0400
>> +++ linux-2.6.bld/drivers/pci/quirks.c	2007-09-05 20:46:14.000000000 +0400
>> @@ -1444,9 +1444,9 @@
>>  static void __devinit quirk_e100_interrupt(struct pci_dev *dev)
>>  {
>>  	u16 command;
>> -	u32 bar;
>>  	u8 __iomem *csr;
>>  	u8 cmd_hi;
>> +	int rc;
>>  
>>  	switch (dev->device) {
>>  	/* PCI IDs taken from drivers/net/e100.c */
>> @@ -1476,16 +1476,17 @@
>>  	 * re-enable them when it's ready.
>>  	 */
>>  	pci_read_config_word(dev, PCI_COMMAND, &command);
>> -	pci_read_config_dword(dev, PCI_BASE_ADDRESS_0, &bar);
>>  
>> -	if (!(command & PCI_COMMAND_MEMORY) || !bar)
>> +	rc = pci_request_region(dev, 0, "e100_quirk");
>> +
>> +	if (!(command & PCI_COMMAND_MEMORY) || (rc < 0))
>>  		return;
> 
> Really?  So if pci_request_region() failed and !(command & PCI_COMMAND_MEMORY),
> we leak the region?  So the next call to this function will fail?
> 

I've split command and request region checks and submitted new patch:
http://lkml.org/lkml/2007/9/19/106
Please, take a look,
Thanks,
Valentine.

> 
>> -	csr = ioremap(bar, 8);
>> +	csr = pci_iomap(dev, 0, 8);
>>  	if (!csr) {
>>  		printk(KERN_WARNING "PCI: Can't map %s e100 registers\n",
>>  			pci_name(dev));
>> -		return;
>> +		goto e100_quirk_exit;
>>  	}
>>  
>>  	cmd_hi = readb(csr + 3);
>> @@ -1495,7 +1496,9 @@
>>  		writeb(1, csr + 3);
>>  	}
>>  
>> -	iounmap(csr);
>> +	pci_iounmap(dev, csr);
>> +e100_quirk_exit:
>> +	pci_release_region(dev, 0);
>>  }
>>  DECLARE_PCI_FIXUP_FINAL(PCI_VENDOR_ID_INTEL, PCI_ANY_ID, quirk_e100_interrupt);
>>  
>> -
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/

