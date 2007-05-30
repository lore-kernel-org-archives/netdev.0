From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH 6/7] sky2: enable clocks before probe
Date: Wed, 30 May 2007 07:43:44 -0700
Message-ID: <465D8DA0.3050307@linux-foundation.org>
References: <20070524222242.555399884@linux-foundation.org> <20070524222538.812999691@linux-foundation.org> <465D8282.8090701@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([207.189.120.12]:55748 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752416AbXE3On6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 May 2007 10:43:58 -0400
In-Reply-To: <465D8282.8090701@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> Stephen Hemminger wrote:
>> Some chips need to have internal clocks enabled (via PCI config)
>> before the PCI space is readable.
>>
>> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
>>
>> ---
>>  drivers/net/sky2.c |  102 
>> ++++++++++++++++++++++++++++++++++++++---------------
>>  drivers/net/sky2.h |   19 +++++++++
>>  2 files changed, 92 insertions(+), 29 deletions(-)
>>
>> --- a/drivers/net/sky2.c    2007-05-24 15:22:14.000000000 -0700
>> +++ b/drivers/net/sky2.c    2007-05-24 15:22:33.000000000 -0700
>> @@ -2524,10 +2524,6 @@ static int __devinit sky2_init(struct sk
>>          dev_warn(&hw->pdev->dev, "this driver not yet tested on this 
>> chip type\n"
>>               "Please report success or failure to 
>> <netdev@vger.kernel.org>\n");
>>  
>> -    /* Make sure and enable all clocks */
>> -    if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == 
>> CHIP_ID_YUKON_EC_U)
>> -        sky2_pci_write32(hw, PCI_DEV_REG3, 0);
>> -
>>      hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
>>  
>>      /* This rev is really old, and requires untested workarounds */
>> @@ -3638,6 +3634,9 @@ static int __devinit sky2_probe(struct p
>>      if (!hw->st_le)
>>          goto err_out_iounmap;
>>  
>> +    /* On Yukon EC-U and EX need to force enabling all clocks */
>> +    pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
>> +
>>      err = sky2_init(hw);
>>      if (err)
>>          goto err_out_iounmap;
>> @@ -3822,8 +3821,7 @@ static int sky2_resume(struct pci_dev *p
>>      pci_enable_wake(pdev, PCI_D0, 0);
>>  
>>      /* Re-enable all clocks */
>> -    if (hw->chip_id == CHIP_ID_YUKON_EX || hw->chip_id == 
>> CHIP_ID_YUKON_EC_U)
>> -        sky2_pci_write32(hw, PCI_DEV_REG3, 0);
>> +    pci_write_config_dword(pdev, PCI_DEV_REG3, 0);
>
>
> No explanation as to why the chip identity tests went away.  And in 
> one of your code comments, it seems to imply that the chip tests are 
> still present.
>
Because you can't read chip idenity on 88e8071 when clocks are disabled 
(catch-22), and clearing
registers on other chips is no problem.

