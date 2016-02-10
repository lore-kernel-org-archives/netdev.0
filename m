From: John Holland <jotihojr@gmail.com>
Subject: Re: [Intel-wired-lan] [next] igb: allow setting MAC address on i211 using a device tree blob
Date: Wed, 10 Feb 2016 09:52:46 +0100
Message-ID: <07CF7015-72DA-4095-9E54-915132D667BC@gmail.com>
References: <56ABE3A8.4010602@gmail.com> <1455015744.3592.46.camel@intel.com>
Mime-Version: 1.0 (1.0)
Content-Type: text/plain;
	charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:37874 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751671AbcBJIwu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Feb 2016 03:52:50 -0500
Received: by mail-wm0-f49.google.com with SMTP id g62so16789596wme.0
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 00:52:49 -0800 (PST)
In-Reply-To: <1455015744.3592.46.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Feb 9, 2016, at 12:02, Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> 
>> On Fri, 2016-01-29 at 23:11 +0100, John Holland wrote:
>> The Intel i211 LOM pcie ethernet controllers' iNVM operates as an
>> OTP 
>> and has no externel EEPROM interface [1]. The following allows the 
>> driver to pickup the MAC address from a device tree blob when
>> CONFIG_OF 
>> has been enabled.
>> 
>> [1] 
>> http://www.intel.com/content/www/us/en/embedded/products/networking/i
>> 211-ethernet-controller-datasheet.html
>> 
>> Signed-off-by: John Holland <jotihojr@gmail.com>
>> ---
>>   drivers/net/ethernet/intel/igb/igb_main.c | 30 
>> ++++++++++++++++++++++++++++++
>>   1 file changed, 30 insertions(+)
>> 
>> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c 
>> b/drivers/net/ethernet/intel/igb/igb_main.c
>> index 31e5f39..9c92443 100644
>> --- a/drivers/net/ethernet/intel/igb/igb_main.c
>> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
>> @@ -56,6 +56,11 @@
>>   #include <linux/i2c.h>
>>   #include "igb.h"
>> 
>> +#ifdef defined(CONFIG_OF)
>> +#include <linux/of_net.h>
>> +#include <linux/etherdevice.h>
>> +#endif
>> +
>>   #define MAJ 5
>>   #define MIN 3
>>   #define BUILD 0
>> @@ -2217,6 +2222,26 @@ static s32 igb_init_i2c(struct igb_adapter
>> *adapter)
>>   }
>> 
>>   /**
>> + *  igb_read_mac_addr_dts - Read mac addres from the device tree
>> blob.
> 
> Address is mis-spelled above

Correct. Will fix this.

> 
>> + *  @hw: pointer to the e1000 hardware structure
>> + **/
>> +#ifdef defined(CONFIG_OF)
> 
> Minor nitpick, you should have the function comment header wrapped in
> the #ifdef as well.

No problem...
I'll do that right too.

> 
>> +static void igb_read_mac_addr_dts(struct e1000_hw *hw)
>> +{
>> +       const u8 *mac;
>> +       struct device_node *dn;
>> +
>> +       dn = of_find_compatible_node(NULL, NULL, "intel,i211");
>> +       if (!dn)
>> +               return;
>> +
>> +       mac = of_get_mac_address(dn);
>> +       if (mac)
>> +               ether_addr_copy(hw->mac.addr, mac);
>> +}
>> +#endif
>> +
>> +/**
>>    *  igb_probe - Device Initialization Routine
>>    *  @pdev: PCI device information struct
>>    *  @ent: entry in igb_pci_tbl
>> @@ -2420,6 +2445,11 @@ static int igb_probe(struct pci_dev *pdev,
>> const 
>> struct pci_device_id *ent)
>>          if (hw->mac.ops.read_mac_addr(hw))
>>                  dev_err(&pdev->dev, "NVM Read Error\n");
>> 
>> +#ifdef defined(CONFIG_OF)
>> +       if (!is_valid_ether_addr(hw->mac.addr))
>> +               igb_read_mac_addr_dts(hw);
>> +#endif
>> +
>>          memcpy(netdev->dev_addr, hw->mac.addr, netdev->addr_len);
>> 
>>          if (!is_valid_ether_addr(netdev->dev_addr)) {
>> _______________________________________________
>> Intel-wired-lan mailing list
>> Intel-wired-lan@lists.osuosl.org
>> http://lists.osuosl.org/mailman/listinfo/intel-wired-lan
