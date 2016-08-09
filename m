From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: Re: [PATCH net] bnx2x: don't reset chip on cleanup if PCI function is
 offline
Date: Tue, 9 Aug 2016 10:27:07 -0300
Message-ID: <57A9DA2B.7080908@linux.vnet.ibm.com>
References: <1470687227-21024-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
 <CO2PR11MB0088856E58DAADE7064F28AF971C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Yuval Mintz <Yuval.Mintz@qlogic.com>,
	Ariel Elior <Ariel.Elior@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:30211 "EHLO
	mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S932389AbcHIN1Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Aug 2016 09:27:16 -0400
Received: from pps.filterd (m0098419.ppops.net [127.0.0.1])
	by mx0b-001b2d01.pphosted.com (8.16.0.11/8.16.0.11) with SMTP id u79DOUgq024089
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2016 09:27:15 -0400
Received: from e24smtp01.br.ibm.com (e24smtp01.br.ibm.com [32.104.18.85])
	by mx0b-001b2d01.pphosted.com with ESMTP id 24qe85nup4-1
	(version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 09 Aug 2016 09:27:15 -0400
Received: from localhost
	by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
	Tue, 9 Aug 2016 10:27:13 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
	by d24dlp01.br.ibm.com (Postfix) with ESMTP id 42027352006C
	for <netdev@vger.kernel.org>; Tue,  9 Aug 2016 09:26:49 -0400 (EDT)
Received: from d24av05.br.ibm.com (d24av05.br.ibm.com [9.18.232.44])
	by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u79DR93H61866006
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2016 10:27:09 -0300
Received: from d24av05.br.ibm.com (localhost [127.0.0.1])
	by d24av05.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u79DR9SR014714
	for <netdev@vger.kernel.org>; Tue, 9 Aug 2016 10:27:09 -0300
In-Reply-To: <CO2PR11MB0088856E58DAADE7064F28AF971C0@CO2PR11MB0088.namprd11.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/09/2016 09:14 AM, Yuval Mintz wrote:
>> When PCI error is detected, in some architectures (like PowerPC) a slot reset is
>> performed - the driver's error handlers are in charge of "disable"
>> device before the reset, and re-enable it after a successful slot reset.
>>
>> There are two cases though that another path is taken on the code: if the slot
>> reset is not successful or if too many errors already happened in the specific
>> adapter (meaning that possibly the device is experiencing a HW failure that slot
>> reset is not able to solve), the core PCI error mechanism (called EEH in PowerPC)
>> will remove the adapter from the system, since it will consider this as a
>> permanent failure on device.
> Why would the published resume()  from pci_error_handlers be called in this scenario?

It isn't. That's why I specifically commented on commit message: "There 
are two cases though that another path is taken on the code".

The code path reach bnx2x_chip_cleanup() on device removal from the 
system, as seen in the below call trace:

bnx2x_chip_cleanup+0x3c0/0x910 [bnx2x]
bnx2x_nic_unload+0x268/0xaf0 [bnx2x]
bnx2x_close+0x34/0x50 [bnx2x]
__dev_close_many+0xd4/0x150
dev_close_many+0xa8/0x160
rollback_registered_many+0x174/0x3f0
rollback_registered+0x40/0x70
unregister_netdevice_queue+0x98/0x110
unregister_netdev+0x34/0x50
__bnx2x_remove+0xa8/0x3a0 [bnx2x]
pci_device_remove+0x70/0x110


>
>> Also, we avoid the MCP information dump in case of non-recoverable PCI error
>> (when adapter is about to be removed), since it will certainly fail.
>
> We should probably avoid several things here; Why specifically only this?

For example, we shouldn't execute bnx2x_timer() in this scenario. But I 
thought it'd be too much to check every call of a timer function against 
PCI channel state just to avoid it's execution on this scenario, so I 
just let it execute, since it seems harmless.

On the other hand, MCP dump is, as you said below, a slowpath and surely 
will fail in the following conditional (since addresses are all like 
0xFFF...):

        /* sanity */
         if (trace_shmem_base < MCPR_SCRATCH_BASE(bp) + 
MCPR_TRACE_BUFFER_SIZE ||
             trace_shmem_base >= MCPR_SCRATCH_BASE(bp) +
                                 SCRATCH_BUFFER_SIZE(bp))

So, I added the check to at least be more informative on logs on why it 
failed. If you desire, we can avoid the timer execution (maybe a 
del_timer() instead of checking for PCI state?) and bnx2x_period_task() 
run in case of PCI permanent failure. I'm open to suggestions!


>> +	if (unlikely(pci_channel_offline(bp->pdev))) {
>> +		BNX2X_ERR("Cannot dump MCP info while in PCI error\n");
>> +		return;
>> +	}
>> +
> Nitpicky, but I don't think there's reason to add 'unlikely' to a purely slowpath
> Configuration.

OK, your call. I can remove it on v2, no problem.


>
>>   	val = REG_RD(bp, MCP_REG_MCPR_CPU_PROGRAM_COUNTER);
>>   	if (val == REG_RD(bp, MCP_REG_MCPR_CPU_PROGRAM_COUNTER))
>>   		BNX2X_ERR("%s" "MCP PC at 0x%x\n", lvl, val); @@ -9415,10
>> +9420,16 @@ unload_error:
>
>
>> -	/* Reset the chip */
>> -	rc = bnx2x_reset_hw(bp, reset_code);
>> -	if (rc)
>> -		BNX2X_ERR("HW_RESET failed\n");
>> +	/* Reset the chip, unless PCI function is offline. If we reach this
>> +	 * point following a PCI error handling, it means device is really
>> +	 * in a bad state and we're about to remove it, so reset the chip
>> +	 * is not a good idea.
>> +	 */
>> +	if (!pci_channel_offline(bp->pdev)) {
>> +		rc = bnx2x_reset_hw(bp, reset_code);
>> +		if (rc)
>> +			BNX2X_ERR("HW_RESET failed\n");
>> +	}
>
> Why not simply check this at the beginning of the function?

Because I wasn't sure if I could drop the entire execution of 
chip_cleanup(). I tried to keep the most of this function aiming to 
shutdown the module in a gentle way, like cleaning MAC, stopping 
queues...but again, I'm open to suggestions and gladly will change this 
in v2 if you think it's for the best.

Thanks for your review,


Guilherme
