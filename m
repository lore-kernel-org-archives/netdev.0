From: Stefan Assmann <sassmann@kpanic.de>
Subject: Re: [E1000-devel] i40e: crash on NMI by continuous module reload
Date: Mon, 02 Mar 2015 09:08:54 +0100
Message-ID: <54F41A96.4020605@kpanic.de>
References: <54F07630.1010802@kpanic.de> <54F078DF.5020100@gmail.com>	<54F07C29.8010805@kpanic.de> <54F082C8.8040407@gmail.com> <FC41C24E35F18A40888AACA1A36F3E418ADF339C@fmsmsx115.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>
To: "Nelson, Shannon" <shannon.nelson@intel.com>,
	nick <xerofoify@gmail.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from app1b.xlhost.de ([84.200.252.162]:46167 "EHLO app1b.xlhost.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751088AbbCBII7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Mar 2015 03:08:59 -0500
In-Reply-To: <FC41C24E35F18A40888AACA1A36F3E418ADF339C@fmsmsx115.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27.02.2015 20:42, Nelson, Shannon wrote:
>> From: nick [mailto:xerofoify@gmail.com]
>> On 2015-02-27 09:16 AM, Stefan Assmann wrote:
>>> On 27.02.2015 15:02, nick wrote:
>>>
>>> [...]
>>>
>>>>>     i40e: Fix a bug where Rx would stop after some time
>>>>> [...]
>>>>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> b/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>>> index f7464e8..ff6d94d 100644
>>>>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>>>>> [...]
>>>>> @@ -9169,6 +9178,13 @@ static int i40e_probe(struct pci_dev *pdev,
>> const struct pci_device_id *ent)
>>>>>  	if (err)
>>>>>  		dev_info(&pf->pdev->dev, "set phy mask fail, aq_err %d\n",
>> err);
>>>>>
>>>>> +	msleep(75);
>>>>> +	err = i40e_aq_set_link_restart_an(&pf->hw, true, NULL);
>>>>> +	if (err) {
>>>>> +		dev_info(&pf->pdev->dev, "link restart failed, aq_err=%d\n",
>>>>> +			 pf->hw.aq.asq_last_status);
>>>>> +	}
>>>>> +
>>>>>  	/* The main driver is (mostly) up and happy. We need to set this
>> state
>>>>>  	 * before setting up the misc vector or we get a race and the
>> vector
>>>>>  	 * ends up disabled forever.
>>>>>
>>>>> With this hunk removed the driver successfully unloaded/reloaded a
>>>>> couple of hundred times. Would it be safe to just remove this hunk?
>>>>> I haven't seen any negative effects by removing this yet.
>>>>>
>>>>>   Stefan
>>>>>
>>>> Stefan,
>>>> I wouldn't remove them yet as this does look like a valid idea to
>> check to see if the link is
>>>> restarting successfully. On the other hand can you try removing the
>> msleep line as this one is
>>>> most likely causing the issue due to sleeping for some long in a
>> probe function is generally a
>>>> bad idea.
>>>> Thanks,
>>>> Nick
>>>
>>> Thanks Nick for the quick reply. I tested removing the msleep but that
>>> didn't make a difference. You actually need to remove the complete
>> hunk
>>> to get a stable driver reload.
>>>
>>>   Stefan
>>>
>> Stefan,
>> Basically there are a few things that could be going wrong
>> 1. You are getting a error return for the
>> function,i40e_aq_set_link_restart_an
>> 2. You are trying to re able the device again when not needed
>> 3. You are sending a NULL value to a field for command arguments that
>> takes a 0 and not NULL
>> to take no arguments
>> Nick
> 
> First of all, I would make sure you've got a short sleep in between each load and unload in this stress test.  There's a lot going on under the covers in the Firmware that really should be allowed to settle out before jostling it again with another load/unload command.  

If a short delay is needed I think this should be implemented by the
driver. Triggering this kind of bug from userspace shouldn't be
possible. I'm using this reload loop regularly on driver backports to
test for regressions.
Btw, I noticed this problem during a normal reboot and used the
reloading while looking for a reproducer.

> It would help to know what Firmware you have on your NIC - can you give us the output from "ethtool -i <ethX>"?

# ethtool -i eth6
driver: i40e
version: 1.2.9-k
firmware-version: f4.22 a1.1 n04.26 e800014b1
bus-info: 0000:07:00.0
supports-statistics: yes
supports-test: yes
supports-eeprom-access: yes
supports-register-dump: yes
supports-priv-flags: yes

> The out-of-tree driver has just (finally!) been updated on SourceForge, so you might give this version 1.2.37 driver a try to see if it changes your result.  That code still has the hunk in question, but protected by a FW version check.  The related patch will be headed upstream to net-next very soon.

1.2.37 fails the same way.

> Firmware updates have also just been released, but I'm not sure they've made it to the Intel Downloads site yet.  Updating your FW will make a difference.

If you could point me to the firmware updates and instructions I can
perform the update.

Thanks!

  Stefan
