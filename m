From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: Re: [PATCH net] bnx2x: don't reset chip on cleanup if PCI function is
 offline
Date: Wed, 10 Aug 2016 10:28:49 -0300
Message-ID: <57AB2C11.1070706@linux.vnet.ibm.com>
References: <1470687227-21024-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
 <CO2PR11MB0088856E58DAADE7064F28AF971C0@CO2PR11MB0088.namprd11.prod.outlook.com>
 <57A9DA2B.7080908@linux.vnet.ibm.com>
 <CO2PR11MB008852D899DEF786AD7CB48C971D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:48242 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S933188AbcHJSNx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Aug 2016 14:13:53 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u7ADOBSE124824
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 09:28:54 -0400
Received: from e24smtp04.br.ibm.com (e24smtp04.br.ibm.com [32.104.18.25])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24qm9r7hy5-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 09:28:54 -0400
Received: from localhost
	by e24smtp04.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
	Wed, 10 Aug 2016 10:28:52 -0300
Received: from d24relay03.br.ibm.com (d24relay03.br.ibm.com [9.13.184.25])
	by d24dlp02.br.ibm.com (Postfix) with ESMTP id 0D7E31DC0054
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 09:28:41 -0400 (EDT)
Received: from d24av01.br.ibm.com (d24av01.br.ibm.com [9.8.31.91])
	by d24relay03.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u7ADSnAO15204818
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 10:28:49 -0300
Received: from d24av01.br.ibm.com (localhost [127.0.0.1])
	by d24av01.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u7ADSnej022770
	for <netdev@vger.kernel.org>; Wed, 10 Aug 2016 10:28:49 -0300
In-Reply-To: <CO2PR11MB008852D899DEF786AD7CB48C971D0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/10/2016 04:59 AM, Yuval Mintz wrote:
>>> Why would the published resume()  from pci_error_handlers be called in this
>> scenario?
>>
>> It isn't. That's why I specifically commented on commit message: "There are two
>> cases though that another path is taken on the code".
>>
>> The code path reach bnx2x_chip_cleanup() on device removal from the system,
>> as seen in the below call trace:
>>
>> bnx2x_chip_cleanup+0x3c0/0x910 [bnx2x]
>> bnx2x_nic_unload+0x268/0xaf0 [bnx2x]
>> bnx2x_close+0x34/0x50 [bnx2x]
>> __dev_close_many+0xd4/0x150
>> dev_close_many+0xa8/0x160
>> rollback_registered_many+0x174/0x3f0
>> rollback_registered+0x40/0x70
>> unregister_netdevice_queue+0x98/0x110
>> unregister_netdev+0x34/0x50
>> __bnx2x_remove+0xa8/0x3a0 [bnx2x]
>> pci_device_remove+0x70/0x110
>
> Makes sense.
>
>>>> Also, we avoid the MCP information dump in case of non-recoverable
>>>> PCI error (when adapter is about to be removed), since it will certainly fail.
>>>
>>> We should probably avoid several things here; Why specifically only this?
>>
>> For example, we shouldn't execute bnx2x_timer() in this scenario. But I thought
>> it'd be too much to check every call of a timer function against PCI channel state
>> just to avoid it's execution on this scenario, so I just let it execute, since it seems
>> harmless.
>>
>>>> +	/* Reset the chip, unless PCI function is offline. If we reach this
>>>> +	 * point following a PCI error handling, it means device is really
>>>> +	 * in a bad state and we're about to remove it, so reset the chip
>>>> +	 * is not a good idea.
>>>> +	 */
>>>> +	if (!pci_channel_offline(bp->pdev)) {
>>>> +		rc = bnx2x_reset_hw(bp, reset_code);
>>>> +		if (rc)
>>>> +			BNX2X_ERR("HW_RESET failed\n");
>>>> +	}
>>>
>>> Why not simply check this at the beginning of the function?
>>
>> Because I wasn't sure if I could drop the entire execution of chip_cleanup(). I
>> tried to keep the most of this function aiming to shutdown the module in a
>> gentle way, like cleaning MAC, stopping queues...but again, I'm open to
>> suggestions and gladly will change this in v2 if you think it's for the best.
>
> Problem is I won't be able to have a more thorough review of this in the next
> couple of days - and other than code-review I won't have a reasonable way
> of testing this [I can use aer_inject, but I don't have your magical EEH
> error injections, and I'm not at all certain it would suffice for a good testing ].
>
> I agree that even as-is, what you're suggesting is an improvement to the
> existing flow - so it's basically up to dave, i.e., whether to take a half fix
> or wait for a more thorough one.
>

Thanks for your consideration. The point is: the important part of this 
patch is avoiding the reset_hw() path, since it will clearly fail and 
generate soft lockups. This is the fix per se, the other part (regarding 
the MCP dump) is just an improvement; surely we have more potential 
improvements to explore, but they wouldn't be fixes, only code improvements.

So, I wouldn't call this a half fix, but yet, a completely fix with a 
small improvement as a bonus :)

Cheers,


Guilherme
