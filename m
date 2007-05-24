From: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
Subject: Re: [PATCH] PCI legacy I/O port free driver - Making Intel e1000
 driver legacy I/O port free
Date: Thu, 24 May 2007 21:43:22 +0900
Message-ID: <4655886A.80203@jp.fujitsu.com>
References: <4642EDED.7020109@jp.fujitsu.com> <46433090.8050205@intel.com> <4643DB5A.7090104@jp.fujitsu.com> <4643DE6E.9090706@intel.com> <464B3443.9070802@foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Kok, Auke" <auke-jan.h.kok@intel.com>, cramerj@intel.com,
	john.ronciak@intel.com, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, gregkh@suse.de,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "Kok, Auke" <sofar@foo-projects.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail5.fujitsu.co.jp ([192.51.44.35]:37212 "EHLO
	fgwmail5.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756091AbXEXMoO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 May 2007 08:44:14 -0400
In-Reply-To: <464B3443.9070802@foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Auke

I'm sorry for being so late. Let me answer your questions.

 > 82545's:
 >  82545EM_COPPER
 >  82545EM_FIBER
 > Here you skip 3 other 82545 device ID's, was that intentional?

   Maybe my understanding on the e1000 driver was wrong. I looked up the
   following code, and thought the device IDs whose chipset are 82545 rev3
   do not use I/O port. That's why I only put the first two device IDs on the
   USE_IOPORT list I submitted previously.

 > 82546's:
 >  82546EB_COPPER
 >  82546EB_FIBER
 >  82546EB_QUAD_COPPER
 > Here you skip over 9 82546 device ID's... same question.

   Same answer for the 82546. From the following code, I thought the device
   IDs whose chipset are 82546 rev3 do not use I/O port.

 > Do you think you can accomodate these changes?

   Yes I'll try it. But before I accomodate those changes, could you just tell
   me which device IDs I should use for this function?
   You said 82540, 82541, 82544 are okay, and I'm gonna add those 3 IDs for
   82545, and 6 IDs for 82546. Are there any other IDs that I'm missing?

Thanks
Tomohiro Kusumi


   drivers/net/e1000/e1000_hw.c
     303 /******************************************************************************
     304  * Set the mac type member in the hw struct.
     305  *
     306  * hw - Struct containing variables accessed by shared code
     307  *****************************************************************************/
     308 int32_t
     309 e1000_set_mac_type(struct e1000_hw *hw)
     310 {
     ...
     344         case E1000_DEV_ID_82545EM_COPPER:
     345         case E1000_DEV_ID_82545EM_FIBER:
     346                 hw->mac_type = e1000_82545;
     347                 break;
     348         case E1000_DEV_ID_82545GM_COPPER:  /* skipped */
     349         case E1000_DEV_ID_82545GM_FIBER:   /* skipped */
     350         case E1000_DEV_ID_82545GM_SERDES:  /* skipped */
     351                 hw->mac_type = e1000_82545_rev_3;
     352                 break;
     353         case E1000_DEV_ID_82546EB_COPPER:
     354         case E1000_DEV_ID_82546EB_FIBER:
     355         case E1000_DEV_ID_82546EB_QUAD_COPPER:
     356                 hw->mac_type = e1000_82546;
     357                 break;
     358         case E1000_DEV_ID_82546GB_COPPER:           /* skipped */
     359         case E1000_DEV_ID_82546GB_FIBER:            /* skipped */
     360         case E1000_DEV_ID_82546GB_SERDES:           /* skipped */
     361         case E1000_DEV_ID_82546GB_PCIE:             /* skipped */
     362         case E1000_DEV_ID_82546GB_QUAD_COPPER:      /* skipped */
     363         case E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3: /* skipped */
     364                 hw->mac_type = e1000_82546_rev_3;
     365                 break;

   drivers/net/e1000/e1000_hw.c
     519 /******************************************************************************
     520  * Reset the transmit and receive units; mask and clear all interrupts.
     521  *
     522  * hw - Struct containing variables accessed by shared code
     523  *****************************************************************************/
     524 int32_t
     525 e1000_reset_hw(struct e1000_hw *hw)
     526 {
     ...
     618     switch (hw->mac_type) {
     619         case e1000_82544:
     620         case e1000_82540:
     621         case e1000_82545:
     622         case e1000_82546:
     623         case e1000_82541:
     624         case e1000_82541_rev_2:
     625             /* These controllers can't ack the 64-bit write when issuing the
     626              * reset, so use IO-mapping as a workaround to issue the reset */
     627             E1000_WRITE_REG_IO(hw, CTRL, (ctrl | E1000_CTRL_RST));
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
                 /* Are these the ones using the I/O port? */

     628             break;
     629         case e1000_82545_rev_3:
     630         case e1000_82546_rev_3:
     631             /* Reset is performed on a shadow of the control register */
     632             E1000_WRITE_REG(hw, CTRL_DUP, (ctrl | E1000_CTRL_RST));
     633             break;

   drivers/net/e1000/e1000_hw.h
     451 #define E1000_DEV_ID_82545EM_COPPER      0x100F
     452 #define E1000_DEV_ID_82545EM_FIBER       0x1011
     453 #define E1000_DEV_ID_82545GM_COPPER      0x1026
     454 #define E1000_DEV_ID_82545GM_FIBER       0x1027
     455 #define E1000_DEV_ID_82545GM_SERDES      0x1028
     456 #define E1000_DEV_ID_82546EB_COPPER      0x1010
     457 #define E1000_DEV_ID_82546EB_FIBER       0x1012
     458 #define E1000_DEV_ID_82546EB_QUAD_COPPER 0x101D
     ...
     467 #define E1000_DEV_ID_82546GB_COPPER      0x1079
     468 #define E1000_DEV_ID_82546GB_FIBER       0x107A
     469 #define E1000_DEV_ID_82546GB_SERDES      0x107B
     470 #define E1000_DEV_ID_82546GB_PCIE        0x108A
     471 #define E1000_DEV_ID_82546GB_QUAD_COPPER 0x1099
     ...
     486 #define E1000_DEV_ID_82546GB_QUAD_COPPER_KSP3 0x10B5




Kok, Auke wrote:
> Kok, Auke wrote:
>> Tomohiro Kusumi wrote:
>>> Dear Auke
>>>
>>>  > I'm ok with the bottom part of the patch, but I do not like
>>>  > the modification of the pci device ID table in this way. As
>>>  > Arjan van der Ven previously commented as well, this makes
>>>  > it hard for future device ID's to be bound to the driver.
>>>
>>>   I googled the previous comment by Arjan. Now I understand
>>>   that the patch makes it difficult to add PCI ID's to the
>>>   driver at runtime.
>>>
>>>  > On top of that, there is no logical correlation between the
>>>  > mapping and chipsets, so a lot of information is lost in that
>>>  > table. It really does not show which _chipsets_ support this
>>>  > functionality.
>>>
>>>   Thanks for pointing out the problem, but I can't quite understand
>>>   what you are trying to say. What do you mean by the chipset?
>>>   Are you talking about the chipset of the NIC? or the South bridge?
>>>   I'd be glad if you can explain it to me.
>>
>> perhaps my wording was poor. I was referring to the NIC chip. Since 
>> there are about 12 different physical e1000 NIC chips (and lots of 
>> different pci IDs per e1000 NIC chip), it would be best to correlate 
>> the capability of each NIC chip number to be able to work without 
>> legacy IO mode instead of providing this mapping based on the PCI 
>> device ID.
>>
>> It would serve two purposes: new pci id's for a chipset of which we 
>> already know that it can work without legacy IO can automatically 
>> inherit this property from the NIC chipset properties, and new e1000 
>> chips would automatically get a default property for this value.
>>
>> I will (time permitting) try to reverse your matrix to chip numbers 
>> and see if we can add this property in a much easier way.
> 
> Okay, you appear to enable io for the following chipsets:
> 
> 82540 chips:
>  82540EM
>  82540EM_LOM
>  82540EP
>  82540EP_LOM
>  82540EP_LP
> those are all the 82540's, OK
> 
> 82541 chips:
>  82541EI
>  82541EI_MOBILE
>  82541ER
>  82541ER_LOM
>  82541GI
>  82541GI_LF
>  82541GI_MOBILE
> Those are all the 82541's, OK too
> 
> 82544 chips:
>  82544EI_COPPER
>  82544EI_FIBER
>  82544GC_COPPER
>  82544GC_LOM
> Those are all the 82543's, OK too
> 
> 82545's:
>  82545EM_COPPER
>  82545EM_FIBER
> Here you skip 3 other 82545 device ID's, was that intentional?
> 
> 82546's:
>  82546EB_COPPER
>  82546EB_FIBER
>  82546EB_QUAD_COPPER
> Here you skip over 9 82546 device ID's... same question.
> 
> It appears that probably the 82543's would also work under ioport, 82547 
> might be the odd one out that might work without IOport. I think 82542 
> definately needs it...
> 
> can you tell me how you created the initial list?
> 
> Summarizing, it appears that we should condense the list to: (sketch)
> 
>  switch (adapter->hw.mac.type) {
>  case e1000_82542 ... e1000_82541_rev_2:
>         adapter->ioport_capable = 1;
>     break;
>  default:
>     break;
>  }
> 
> I also would like this option to be non-default, IOW use legacy IO by 
> default, and allow the user to specify a module load option to disable 
> use of this feature:
> 
> static unsigned int use_ioport = 1;
> module_param(use_ioport, uint, 0644);
> MODULE_PARM_DESC(use_ioport, "Use Legacy IO port mapping (default: 1)");
> 
> or something like this to allow the feature to be tested before we turn 
> legacy ioport off for all adapters and everyone.
> 
> Do you think you can accomodate these changes?
> 
> Cheers,
> 
> Auke
> 
> 
> 
> 
>>
>> Auke
>>
>>> Tomohiro Kusumi
>>>
>>>
>>> Kok, Auke wrote:
>>>> Tomohiro Kusumi wrote:
>>>>> Hi
>>>>>
>>>>> As you can see in the "10. pci_enable_device_bars() and Legacy I/O
>>>>> Port space" of the Documentation/pci.txt, the latest kernel has
>>>>> interfaces for PCI device drivers to tell the kernel which resource
>>>>> the driver want to use, ex. I/O port or MMIO.
>>>>>
>>>>> I've made a patch which makes Intel e1000 driver legacy I/O port
>>>>> free by using the PCI core changes I mentioned above. The Intel
>>>>> e1000 driver can handle some of its devices without using I/O port.
>>>>> So this patch changes the driver not to enable/request I/O port
>>>>> region depending on the device id.
>>>>>
>>>>> As a result, the driver can handle its device even when there are
>>>>> huge number of PCI devices being used on the system and no I/O
>>>>> port region assigned to the device.
>>>> Tomohiro,
>>>>
>>>> I'm ok with the bottom part of the patch, but I do not like the 
>>>> modification of the pci device ID table in this way. As Arjan van 
>>>> der Ven previously commented as well, this makes it hard for future 
>>>> device ID's to be bound to the driver.
>>>>
>>>> On top of that, there is no logical correlation between the mapping 
>>>> and chipsets, so a lot of information is lost in that table. It 
>>>> really does not show which _chipsets_ support this functionality.
>>>>
>>>> I think if we want to work with this, we need some way of mapping 
>>>> the device ID's back to chipsets, and enable the feature on that basis.
>>>>
>>>> Auke
>>>>
>>>>> Tomohiro Kusumi
>>>>>
>>>>> Signed-off-by: Tomohiro Kusumi <kusumi.tomohiro@jp.fujitsu.com>
>>>>>
>>>>> ---
>>>>>  e1000.h      |    6 +-
>>>>>  e1000_main.c |  152 
>>>>> +++++++++++++++++++++++++++++++----------------------------
>>>>>  2 files changed, 86 insertions(+), 72 deletions(-)
>>>>>
>>>>> diff -uprN linux-2.6.21.orig/drivers/net/e1000/e1000.h 
>>>>> linux-2.6.21/drivers/net/e1000/e1000.h
>>>>> --- linux-2.6.21.orig/drivers/net/e1000/e1000.h    2007-05-09 
>>>>> 18:02:26.000000000 +0900
>>>>> +++ linux-2.6.21/drivers/net/e1000/e1000.h    2007-05-09 
>>>>> 18:02:59.000000000 +0900
>>>>> @@ -74,8 +74,9 @@
>>>>>  #define BAR_1        1
>>>>>  #define BAR_5        5
>>>>>
>>>>> -#define INTEL_E1000_ETHERNET_DEVICE(device_id) {\
>>>>> -    PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
>>>>> +#define E1000_USE_IOPORT       (1 << 0)
>>>>> +#define INTEL_E1000_ETHERNET_DEVICE(device_id, flags) {\
>>>>> +       PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id), .driver_data = 
>>>>> flags}
>>>>>
>>>>>  struct e1000_adapter;
>>>>>
>>>>> @@ -347,6 +348,7 @@ struct e1000_adapter {
>>>>>      boolean_t quad_port_a;
>>>>>      unsigned long flags;
>>>>>      uint32_t eeprom_wol;
>>>>> +    int bars;               /* BARs to be enabled */
>>>>>  };
>>>>>
>>>>>  enum e1000_state_t {
>>>>> diff -uprN linux-2.6.21.orig/drivers/net/e1000/e1000_main.c 
>>>>> linux-2.6.21/drivers/net/e1000/e1000_main.c
>>>>> --- linux-2.6.21.orig/drivers/net/e1000/e1000_main.c    2007-05-09 
>>>>> 18:02:27.000000000 +0900
>>>>> +++ linux-2.6.21/drivers/net/e1000/e1000_main.c    2007-05-09 
>>>>> 18:03:00.000000000 +0900
>>>>> @@ -48,65 +48,65 @@ static char e1000_copyright[] = "Copyrig
>>>>>   *   {PCI_DEVICE(PCI_VENDOR_ID_INTEL, device_id)}
>>>>>   */
>>>>>  static struct pci_device_id e1000_pci_tbl[] = {
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1000),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1001),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1004),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1008),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1009),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x100C),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x100D),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x100E),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x100F),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1010),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1011),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1012),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1013),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1014),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1015),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1016),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1017),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1018),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1019),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x101A),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x101D),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x101E),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1026),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1027),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1028),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1049),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x104A),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x104B),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x104C),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x104D),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x105E),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x105F),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1060),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1075),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1076),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1077),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1078),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1079),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107A),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107B),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107C),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107D),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107E),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x107F),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x108A),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x108B),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x108C),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1096),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1098),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x1099),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x109A),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10A4),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10B5),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10B9),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10BA),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10BB),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10BC),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10C4),
>>>>> -    INTEL_E1000_ETHERNET_DEVICE(0x10C5),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1000, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1001, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1004, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1008, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1009, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x100C, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x100D, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x100E, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x100F, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1010, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1011, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1012, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1013, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1014, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1015, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1016, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1017, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1018, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1019, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x101A, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x101D, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x101E, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1026, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1027, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1028, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1049, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x104A, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x104B, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x104C, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x104D, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x105E, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x105F, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1060, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1075, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1076, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1077, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1078, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1079, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107A, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107B, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107C, E1000_USE_IOPORT),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107D, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107E, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x107F, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x108A, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x108B, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x108C, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1096, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1098, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x1099, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x109A, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10A4, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10B5, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10B9, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10BA, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10BB, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10BC, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10C4, 0),
>>>>> +    INTEL_E1000_ETHERNET_DEVICE(0x10C5, 0),
>>>>>      /* required last entry */
>>>>>      {0,}
>>>>>  };
>>>>> @@ -879,7 +879,14 @@ e1000_probe(struct pci_dev *pdev,
>>>>>      int i, err, pci_using_dac;
>>>>>      uint16_t eeprom_data = 0;
>>>>>      uint16_t eeprom_apme_mask = E1000_EEPROM_APME;
>>>>> -    if ((err = pci_enable_device(pdev)))
>>>>> +    int bars;
>>>>> +
>>>>> +    if (ent->driver_data & E1000_USE_IOPORT)
>>>>> +        bars = pci_select_bars(pdev, IORESOURCE_MEM | IORESOURCE_IO);
>>>>> +    else
>>>>> +        bars = pci_select_bars(pdev, IORESOURCE_MEM);
>>>>> +
>>>>> +    if ((err = pci_enable_device_bars(pdev, bars)))
>>>>>          return err;
>>>>>
>>>>>      if (!(err = pci_set_dma_mask(pdev, DMA_64BIT_MASK)) &&
>>>>> @@ -894,7 +901,8 @@ e1000_probe(struct pci_dev *pdev,
>>>>>          pci_using_dac = 0;
>>>>>      }
>>>>>
>>>>> -    if ((err = pci_request_regions(pdev, e1000_driver_name)))
>>>>> +    err = pci_request_selected_regions(pdev, bars, 
>>>>> e1000_driver_name);
>>>>> +    if (err)
>>>>>          goto err_pci_reg;
>>>>>
>>>>>      pci_set_master(pdev);
>>>>> @@ -913,6 +921,7 @@ e1000_probe(struct pci_dev *pdev,
>>>>>      adapter->pdev = pdev;
>>>>>      adapter->hw.back = adapter;
>>>>>      adapter->msg_enable = (1 << debug) - 1;
>>>>> +    adapter->bars = bars;
>>>>>
>>>>>      mmio_start = pci_resource_start(pdev, BAR_0);
>>>>>      mmio_len = pci_resource_len(pdev, BAR_0);
>>>>> @@ -922,12 +931,15 @@ e1000_probe(struct pci_dev *pdev,
>>>>>      if (!adapter->hw.hw_addr)
>>>>>          goto err_ioremap;
>>>>>
>>>>> -    for (i = BAR_1; i <= BAR_5; i++) {
>>>>> -        if (pci_resource_len(pdev, i) == 0)
>>>>> -            continue;
>>>>> -        if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
>>>>> -            adapter->hw.io_base = pci_resource_start(pdev, i);
>>>>> -            break;
>>>>> +    if (ent->driver_data & E1000_USE_IOPORT) {
>>>>> +        for (i = BAR_1; i <= BAR_5; i++) {
>>>>> +            if (pci_resource_len(pdev, i) == 0)
>>>>> +                continue;
>>>>> +            if (pci_resource_flags(pdev, i) & IORESOURCE_IO) {
>>>>> +                adapter->hw.io_base =
>>>>> +                    pci_resource_start(pdev, i);
>>>>> +                break;
>>>>> +            }
>>>>>          }
>>>>>      }
>>>>>
>>>>> @@ -1190,7 +1202,7 @@ err_sw_init:
>>>>>  err_ioremap:
>>>>>      free_netdev(netdev);
>>>>>  err_alloc_etherdev:
>>>>> -    pci_release_regions(pdev);
>>>>> +    pci_release_selected_regions(pdev, bars);
>>>>>  err_pci_reg:
>>>>>  err_dma:
>>>>>      pci_disable_device(pdev);
>>>>> @@ -1242,7 +1254,7 @@ e1000_remove(struct pci_dev *pdev)
>>>>>      iounmap(adapter->hw.hw_addr);
>>>>>      if (adapter->hw.flash_address)
>>>>>          iounmap(adapter->hw.flash_address);
>>>>> -    pci_release_regions(pdev);
>>>>> +    pci_release_selected_regions(pdev, adapter->bars);
>>>>>
>>>>>      free_netdev(netdev);
>>>>>
>>>>> @@ -5172,7 +5184,7 @@ e1000_resume(struct pci_dev *pdev)
>>>>>
>>>>>      pci_set_power_state(pdev, PCI_D0);
>>>>>      pci_restore_state(pdev);
>>>>> -    if ((err = pci_enable_device(pdev))) {
>>>>> +    if ((err = pci_enable_device_bars(pdev, adapter->bars))) {
>>>>>          printk(KERN_ERR "e1000: Cannot enable PCI device from 
>>>>> suspend\n");
>>>>>          return err;
>>>>>      }
>> -
>> To unsubscribe from this list: send the line "unsubscribe 
>> linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
> 
> 


