From: Larry Finger <larry.finger@lwfinger.net>
Subject: Re: [PATCH] bcm43xx: Fix failure to deliver PCI-E interrupts
Date: Fri, 12 Jan 2007 10:36:36 -0600
Message-ID: <45A7B914.4030804@lwfinger.net>
References: <45a713f4.CVklfeegOYfmrIW+%Larry.Finger@lwfinger.net> <200701121517.40539.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtiwmhc11.worldnet.att.net ([204.127.131.115]:38588 "EHLO
	mtiwmhc11.worldnet.att.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750983AbXALQiL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Jan 2007 11:38:11 -0500
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200701121517.40539.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:

I have one general question before I address your comments. Does a BCM43xx chip always have either a
PCI or a PCI-E core? I've seen discussion on this list that makes me wonder. That is why I had some
explicit tests for PCI-E in the code.

> On Friday 12 January 2007 05:52, Larry Finger wrote:
>> The PCI-E modifications to bcm43xx do not set up the interrupt vector
>> correctly.
>>
>> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
>> ---
>>
>> John,
>>
>> This fix should be applied to wireless-2.6 _AND_ pushed upstream to
>> 2.6.20-rcX. Without this patch, none of the PCI-E interfaces will work.
>>
>> Larry
>>
>>
>> Index: linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> ===================================================================
>> --- linux-2.6.orig/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> +++ linux-2.6/drivers/net/wireless/bcm43xx/bcm43xx_main.c
>> @@ -2704,7 +2704,7 @@ static int bcm43xx_probe_cores(struct bc
>>  		sb_id_hi = bcm43xx_read32(bcm, BCM43xx_CIR_SB_ID_HI);
>>  
>>  		/* extract core_id, core_rev, core_vendor */
>> -		core_id = (sb_id_hi & 0xFFF0) >> 4;
>> +		core_id = (sb_id_hi & 0x8FF0) >> 4;
> 
> ACK. That one fixes a bug.
> 
>>  		core_rev = (sb_id_hi & 0xF);
> 
> This is also buggy. Should be something like:
> 
> 	core_rev = ((sb_id_hi & 0xF) | ((sb_id_hi & 0x7000) >> 8));

Is this in the specs?

>>  		core_vendor = (sb_id_hi & 0xFFFF0000) >> 16;
>>  
>> @@ -2717,7 +2717,7 @@ static int bcm43xx_probe_cores(struct bc
>>  		case BCM43xx_COREID_PCIE:
>>  			core = &bcm->core_pci;
>>  			if (core->available) {
>> -				printk(KERN_WARNING PFX "Multiple PCI cores found.\n");
>> +				printk(KERN_WARNING PFX "Multiple PCI/PCI-E cores found.\n");
>>  				continue;
>>  			}
>>  			break;
>> @@ -2872,11 +2872,14 @@ static int bcm43xx_wireless_core_init(st
>>  	u32 sbimconfiglow;
>>  	u8 limit;
>>  
>> -	if (bcm->core_pci.rev <= 5 && bcm->core_pci.id != BCM43xx_COREID_PCIE) {
>> +	if (bcm->core_pci.rev <= 5 && bcm->core_pci.id == BCM43xx_COREID_PCI) {
> 
> That's semantically equal.

True, as long as a particular chip has one or the other core.

>>  		sbimconfiglow = bcm43xx_read32(bcm, BCM43xx_CIR_SBIMCONFIGLOW);
>>  		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_REQUEST_TOUT_MASK;
>>  		sbimconfiglow &= ~ BCM43xx_SBIMCONFIGLOW_SERVICE_TOUT_MASK;
>> -		sbimconfiglow |= 0x32;
>> +		if (bcm->bustype == BCM43xx_BUSTYPE_PCI)
>> +			sbimconfiglow |= 0x32;
>> +		else
>> +			sbimconfiglow |= 0x53;
> 
> That used to be there until someone ripped it out (not me). Not sure why.

I'm not sure either. I just found it in the wireless-dev code and in the specs, but not here.

>>  		bcm43xx_write32(bcm, BCM43xx_CIR_SBIMCONFIGLOW, sbimconfiglow);
>>  	}
>>  
>> @@ -3070,6 +3073,7 @@ static int bcm43xx_setup_backplane_pci_c
>>  	u32 backplane_flag_nr;
>>  	u32 value;
>>  	struct bcm43xx_coreinfo *old_core;
>> +	struct bcm43xx_coreinfo *pci_core = &bcm->core_pci ;
>>  	int err = 0;
>>  
>>  	value = bcm43xx_read32(bcm, BCM43xx_CIR_SBTPSFLAG);
>> @@ -3080,26 +3084,22 @@ static int bcm43xx_setup_backplane_pci_c
>>  	if (err)
>>  		goto out;
>>  
>> -	if (bcm->current_core->rev < 6 ||
>> -		bcm->current_core->id == BCM43xx_COREID_PCI) {
>> -		value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
>> -		value |= (1 << backplane_flag_nr);
>> -		bcm43xx_write32(bcm, BCM43xx_CIR_SBINTVEC, value);
>> -	} else {
>> +	if ((pci_core->rev >= 6) || (pci_core->id == BCM43xx_COREID_PCIE)) {
>>  		err = bcm43xx_pci_read_config32(bcm, BCM43xx_PCICFG_ICR, &value);
>> -		if (err) {
>> -			printk(KERN_ERR PFX "Error: ICR setup failure!\n");
>> +		if (err)
>>  			goto out_switch_back;
>> -		}
>>  		value |= core_mask << 8;
>>  		err = bcm43xx_pci_write_config32(bcm, BCM43xx_PCICFG_ICR, value);
>> -		if (err) {
>> -			printk(KERN_ERR PFX "Error: ICR setup failure!\n");
>> +		if (err)
>>  			goto out_switch_back;
>> -		}
>> +	} else {
>> +                err = -EINVAL;
>> +                value = bcm43xx_read32(bcm, BCM43xx_CIR_SBINTVEC);
>> +		value |= 1 << backplane_flag_nr;
>> +                bcm43xx_write32(bcm, BCM43xx_CIR_SBINTVEC, value);
>>  	}
> 
> The above doesn't change semantics. Or am I simply not seeing it? :)
> Seems that it just shuffles the code.

I thought so too and skipped over this section many times while trying to find the bug, but this is
the change that makes the interface work.

If the original structure was

if A or B
    clause 1
else
    clause 2

My patch changed it into

if not A or not B
    clause 2
else
    clause 1

Obviously, clause 2 will be executed if A or B is false. Accordingly, the test can be restructured into

if A && B
    clause 1
else
    clause 2

Now we can see the bug in the original. I always knew that the course in symbolic logic that I took
many decades ago was useful.

>> -	if (bcm->current_core->id == BCM43xx_COREID_PCI) {
>> +	if (pci_core->id == BCM43xx_COREID_PCI) {
> 
> That's semantically equal.

True. I can pull the pci_core out and substitute bcm->current_core for it.

>>  		value = bcm43xx_read32(bcm, BCM43xx_PCICORE_SBTOPCI2);
>>  		value |= BCM43xx_SBTOPCI2_PREFETCH | BCM43xx_SBTOPCI2_BURST;
>>  		bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
>> @@ -3118,21 +3118,21 @@ static int bcm43xx_setup_backplane_pci_c
>>  			value |= BCM43xx_SBTOPCI2_MEMREAD_MULTI;
>>  			bcm43xx_write32(bcm, BCM43xx_PCICORE_SBTOPCI2, value);
>>  		}
>> -	} else {
>> -		if (bcm->current_core->rev == 0 || bcm->current_core->rev == 1) {
>> +	} else if (pci_core->id == BCM43xx_COREID_PCIE) {
> 
> That's redundant. If it's not a PCI core, it must be a PCIE core.
> 
>> +		if (pci_core->rev == 0 || pci_core->rev == 1) {
> 
> Semantically equal.

True.
> 
>>  			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_TLP_WORKAROUND);
>>  			value |= 0x8;
>>  			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_TLP_WORKAROUND,
>>  					       value);
>>  		}
>> -		if (bcm->current_core->rev == 0) {
>> +		if (pci_core->rev == 0) {
> 
> dito
> 
>>  			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
>>  						BCM43xx_SERDES_RXTIMER, 0x8128);
>>  			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
>>  						BCM43xx_SERDES_CDR, 0x0100);
>>  			bcm43xx_pcie_mdio_write(bcm, BCM43xx_MDIO_SERDES_RX,
>>  						BCM43xx_SERDES_CDR_BW, 0x1466);
>> -		} else if (bcm->current_core->rev == 1) {
>> +		} else if (pci_core->rev == 1) {
> 
> dito
> 
>>  			value = bcm43xx_pcie_reg_read(bcm, BCM43xx_PCIE_DLLP_LINKCTL);
>>  			value |= 0x40;
>>  			bcm43xx_pcie_reg_write(bcm, BCM43xx_PCIE_DLLP_LINKCTL,
>> @@ -3141,6 +3141,7 @@ static int bcm43xx_setup_backplane_pci_c
>>  	}
>>  out_switch_back:
>>  	err = bcm43xx_switch_core(bcm, old_core);
>> +	printk(KERN_ERR PFX "Error: ICR setup failure!\n");
>>  out:
>>  	return err;
>>  }
>>
>> ---
>>
>>
> 

I will submit a revised patch as soon as I sort out the core_rev situation.

Larry

