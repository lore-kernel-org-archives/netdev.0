From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [PATCH] PCI legacy I/O port free driver - Making Intel e1000
 driver legacy I/O port free
Date: Thu, 10 May 2007 20:09:34 -0700
Message-ID: <4643DE6E.9090706@intel.com>
References: <4642EDED.7020109@jp.fujitsu.com> <46433090.8050205@intel.com> <4643DB5A.7090104@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: cramerj@intel.com, john.ronciak@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	gregkh@suse.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:26671 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757252AbXEKDJk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 23:09:40 -0400
In-Reply-To: <4643DB5A.7090104@jp.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tomohiro Kusumi wrote:
> Dear Auke
> 
>  > I'm ok with the bottom part of the patch, but I do not like
>  > the modification of the pci device ID table in this way. As
>  > Arjan van der Ven previously commented as well, this makes
>  > it hard for future device ID's to be bound to the driver.
> 
>   I googled the previous comment by Arjan. Now I understand
>   that the patch makes it difficult to add PCI ID's to the
>   driver at runtime.
> 
>  > On top of that, there is no logical correlation between the
>  > mapping and chipsets, so a lot of information is lost in that
>  > table. It really does not show which _chipsets_ support this
>  > functionality.
> 
>   Thanks for pointing out the problem, but I can't quite understand
>   what you are trying to say. What do you mean by the chipset?
>   Are you talking about the chipset of the NIC? or the South bridge?
>   I'd be glad if you can explain it to me.

perhaps my wording was poor. I was referring to the NIC chip. Since there are 
about 12 different physical e1000 NIC chips (and lots of different pci IDs per 
e1000 NIC chip), it would be best to correlate the capability of each NIC chip 
number to be able to work without legacy IO mode instead of providing this 
mapping based on the PCI device ID.

It would serve two purposes: new pci id's for a chipset of which we already know 
that it can work without legacy IO can automatically inherit this property from 
the NIC chipset properties, and new e1000 chips would automatically get a 
default property for this value.

I will (time permitting) try to reverse your matrix to chip numbers and see if 
we can add this property in a much easier way.

Auke

> 
> Tomohiro Kusumi
> 
> 
> Kok, Auke wrote:
>> Tomohiro Kusumi wrote:
>>> Hi
>>>
>>> As you can see in the "10. pci_enable_device_bars() and Legacy I/O
>>> Port space" of the Documentation/pci.txt, the latest kernel has
>>> interfaces for PCI device drivers to tell the kernel which resource
>>> the driver want to use, ex. I/O port or MMIO.
>>>
>>> I've made a patch which makes Intel e1000 driver legacy I/O port
>>> free by using the PCI core changes I mentioned above. The Intel
>>> e1000 driver can handle some of its devices without using I/O port.
>>> So this patch changes the driver not to enable/request I/O port
>>> region depending on the device id.
>>>
>>> As a result, the driver can handle its device even when there are
>>> huge number of PCI devices being used on the system and no I/O
>>> port region assigned to the device.
>> Tomohiro,
>>
>> I'm ok with the bottom part of the patch, but I do not like the 
>> modification of the pci device ID table in this way. As Arjan van der 
>> Ven previously commented as well, this makes it hard for future device 
>> ID's to be bound to the driver.
>>
>> On top of that, there is no logical correlation between the mapping and 
>> chipsets, so a lot of information is lost in that table. It really does 
>> not show which _chipsets_ support this functionality.
>>
>> I think if we want to work with this, we need some way of mapping the 
>> device ID's back to chipsets, and enable the feature on that basis.
>>
>> Auke
>>
>>> Tomohiro Kusumi
>>>
>>> Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
>>>
>>> ---
>>>  e1000.h      |    6 +-
>>>  e1000_main.c |  152 
>>> +++++++++++++++++++++++++++++++----------------------------
>>>  2 files changed, 86 insertions(+), 72 deletions(-)
>>>
>>> diff -uprN linux-2.6.21.orig/drivers/net/e1000/e1000.h 
>>> linux-2.6.21/drivers/net/e1000/e1000.h
>>> --- linux-2.6.21.orig/drivers/net/e1000/e1000.h    2007-05-09 
>>> 18:02:26.000000000 +0900
>>> +++ linux-2.6.21/drivers/net/e1000/e1000.h    2007-05-09 
>>> 18:02:59.000000000 +0900
>>> @@ -74,8 +74,9 @@
>>>  #define BAR_1        1
>>>  #define BAR_5        5
>>>
>>> -#define INTEL_E1000_ETHERNET_DEVICE(device_id) {\
>>> -    PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
>>> +#define E1000_USE_IOPORT       (1 << 0)
>>> +#define INTEL_E1000_ETHERNET_DEVICE(device_id, flags) {\
>>> +       PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id), .driver_data = flags}
>>>
>>>  struct e1000_adapter;
>>>
>>> @@ -347,6 +348,7 @@ struct e1000_adapter {
>>>      boolean_t quad_port_a;
>>>      unsigned long flags;
>>>      uint32_t eeprom_wol;
>>> +    int bars;               /* BARs to be enabled */
>>>  };
>>>
>>>  enum e1000_state_t {
>>> diff -uprN linux-2.6.21.orig/drivers/net/e1000/e1000_main.c 
>>> linux-2.6.21/drivers/net/e1000/e1000_main.c
>>> --- linux-2.6.21.orig/drivers/net/e1000/e1000_main.c    2007-05-09 
>>> 18:02:27.000000000 +0900
>>> +++ linux-2.6.21/drivers/net/e1000/e1000_main.c    2007-05-09 
>>> 18:03:00.000000000 +0900
>>> @@ -48,65 +48,65 @@ static char e1000_copyright[] = "Copyrig
>>>   *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
>>>   */
>>>  static struct pci_device_id e1000_pci_tbl[] = {
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1000),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1001),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1004),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1008),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1009),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x100C),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x100D),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x100E),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x100F),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1010),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1011),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1012),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1013),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1014),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1015),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1016),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1017),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1018),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1019),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x101A),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x101D),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x101E),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1026),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1027),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1028),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1049),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x104A),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x104B),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x104C),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x104D),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x105E),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x105F),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1060),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1075),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1076),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1077),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1078),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1079),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107A),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107B),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107C),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107D),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107E),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107F),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x108A),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x108B),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x108C),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1096),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1098),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1099),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x109A),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10A4),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10B5),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10B9),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10BA),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10BB),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10BC),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10C4),
>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10C5),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1000, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1001, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1004, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1008, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1009, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x100C, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x100D, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x100E, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x100F, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1010, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1011, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1012, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1013, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1014, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1015, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1016, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1017, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1018, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1019, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x101A, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x101D, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x101E, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1026, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1027, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1028, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1049, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x104A, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x104B, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x104C, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x104D, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x105E, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x105F, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1060, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1075, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1076, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1077, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1078, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1079, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107A, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107B, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107C, E1000_USE_IOPORT),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107D, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107E, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107F, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x108A, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x108B, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x108C, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1096, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1098, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1099, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x109A, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10A4, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10B5, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10B9, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10BA, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10BB, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10BC, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10C4, 0),
>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10C5, 0),
>>>      /* required last entry */
>>>      {0,}
>>>  };
>>> @@ -879,7 +879,14 @@ e1000_probe(struct pci_dev *pdev,
>>>      int i, err, pci_using_dac;
>>>      uint16_t eeprom_data = 0;
>>>      uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
>>> -    if ((err = pci_enable_device(pdev)))
>>> +    int bars;
>>> +
>>> +    if (ent->driver_data & E1000_USE_IOPORT)
>>> +        bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
>>> +    else
>>> +        bars = pci_select_bars(pdev, IORESOURCE_MEM);
>>> +
>>> +    if ((err = pci_enable_device_bars(pdev, bars)))
>>>          return err;
>>>
>>>      if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
>>> @@ -894,7 +901,8 @@ e1000_probe(struct pci_dev *pdev,
>>>          pci_using_dac = 0;
>>>      }
>>>
>>> -    if ((err = pci_request_regions(pdev, e1000_driver_name)))
>>> +    err = pci_request_selected_regions(pdev, bars, e1000_driver_name);
>>> +    if (err)
>>>          goto err_pci_reg;
>>>
>>>      pci_set_master(pdev);
>>> @@ -913,6 +921,7 @@ e1000_probe(struct pci_dev *pdev,
>>>      adapter->pdev = pdev;
>>>      adapter->hw.back = adapter;
>>>      adapter->msg_enable = (1 << debug) - 1;
>>> +    adapter->bars = bars;
>>>
>>>      mmio_start = pci_resource_start(pdev, BAR_0);
>>>      mmio_len = pci_resource_len(pdev, BAR_0);
>>> @@ -922,12 +931,15 @@ e1000_probe(struct pci_dev *pdev,
>>>      if (!adapter->hw.hw_addr)
>>>          goto err_ioremap;
>>>
>>> -    for (i = BAR_1; i <= BAR_5; i++) {
>>> -        if (pci_resource_len(pdev, i) == 0)
>>> -            continue;
>>> -        if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
>>> -            adapter->hw.io_base = pci_resource_start(pdev, i);
>>> -            break;
>>> +    if (ent->driver_data & E1000_USE_IOPORT) {
>>> +        for (i = BAR_1; i <= BAR_5; i++) {
>>> +            if (pci_resource_len(pdev, i) == 0)
>>> +                continue;
>>> +            if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
>>> +                adapter->hw.io_base =
>>> +                    pci_resource_start(pdev, i);
>>> +                break;
>>> +            }
>>>          }
>>>      }
>>>
>>> @@ -1190,7 +1202,7 @@ err_sw_init:
>>>  err_ioremap:
>>>      free_netdev(netdev);
>>>  err_alloc_etherdev:
>>> -    pci_release_regions(pdev);
>>> +    pci_release_selected_regions(pdev, bars);
>>>  err_pci_reg:
>>>  err_dma:
>>>      pci_disable_device(pdev);
>>> @@ -1242,7 +1254,7 @@ e1000_remove(struct pci_dev *pdev)
>>>      iounmap(adapter->hw.hw_addr);
>>>      if (adapter->hw.flash_address)
>>>          iounmap(adapter->hw.flash_address);
>>> -    pci_release_regions(pdev);
>>> +    pci_release_selected_regions(pdev, adapter->bars);
>>>
>>>      free_netdev(netdev);
>>>
>>> @@ -5172,7 +5184,7 @@ e1000_resume(struct pci_dev *pdev)
>>>
>>>      pci_set_power_state(pdev, PCI_D0);
>>>      pci_restore_state(pdev);
>>> -    if ((err = pci_enable_device(pdev))) {
>>> +    if ((err = pci_enable_device_bars(pdev, adapter->bars))) {
>>>          printk(KERN_ERR "e1000: Cannot enable PCI device from 
>>> suspend\n");
>>>          return err;
>>>      }
>>
