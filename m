From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Subject: Re: [Intel-wired-lan] [PATCH net] i40e: avoid NULL pointer
 dereference and recursive errors on early PCI error
Date: Tue, 27 Sep 2016 20:09:57 -0300
Message-ID: <57EAFC45.4040303@linux.vnet.ibm.com>
References: <1475010871-31682-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
 <1475016118.22933.1.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-001b2d01.pphosted.com ([148.163.158.5]:54227 "EHLO
        mx0a-001b2d01.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1756301AbcI0XKI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 19:10:08 -0400
Received: from pps.filterd (m0098420.ppops.net [127.0.0.1])
        by mx0b-001b2d01.pphosted.com (8.16.0.17/8.16.0.17) with SMTP id u8RN7urP075454
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 19:10:08 -0400
Received: from e24smtp01.br.ibm.com (e24smtp01.br.ibm.com [32.104.18.85])
        by mx0b-001b2d01.pphosted.com with ESMTP id 25qv5xfcvq-1
        (version=TLSv1.2 cipher=AES256-SHA bits=256 verify=NOT)
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 19:10:07 -0400
Received: from localhost
        by e24smtp01.br.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
        for <netdev@vger.kernel.org> from <gpiccoli@linux.vnet.ibm.com>;
        Tue, 27 Sep 2016 20:10:05 -0300
Received: from d24relay02.br.ibm.com (d24relay02.br.ibm.com [9.13.184.26])
        by d24dlp01.br.ibm.com (Postfix) with ESMTP id 0D24C352005F
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 19:09:37 -0400 (EDT)
Received: from d24av04.br.ibm.com (d24av04.br.ibm.com [9.8.31.97])
        by d24relay02.br.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id u8RNA1Dl33620398
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 20:10:01 -0300
Received: from d24av04.br.ibm.com (localhost [127.0.0.1])
        by d24av04.br.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id u8RNA0lA004372
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 20:10:01 -0300
In-Reply-To: <1475016118.22933.1.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2016 07:41 PM, Keller, Jacob E wrote:
> On Tue, 2016-09-27 at 18:14 -0300, Guilherme G. Piccoli wrote:
>> Although rare, it's possible to hit PCI error early on device
>> probe, meaning possibly some structs are not entirely initialized,
>> and some might even be completely uninitialized, leading to NULL
>> pointer dereference.
>>
>> The i40e driver currently presents a "bad" behavior if device hits
>> such early PCI error: firstly, the struct i40e_pf might not be
>> attached to pci_dev yet, leading to a NULL pointer dereference on
>> access to pf->state.
>>
> 
> Oops! Nice find!
> 
>> Even checking if the struct is NULL and avoiding the access in that
>> case isn't enough, since the driver cannot recover from PCI error
>> that early; in our experiments we saw multiple failures on kernel
>> log, like:
>>
>>   [549.664] i40e 0007:01:00.1: Initial pf_reset failed: -15
>>   [549.664] i40e: probe of 0007:01:00.1 failed with error -15
>>   [...]
>>   [871.644] i40e 0007:01:00.1: The driver for the device stopped
>> because the
>>   device firmware failed to init. Try updating your NVM image.
>>   [871.644] i40e: probe of 0007:01:00.1 failed with error -32
>>   [...]
>>   [872.516] i40e 0007:01:00.0: ARQ: Unknown event 0x0000 ignored
>>
>> Between the first probe failure (error -15) and the second (error
>> -32)
>> another PCI error happened due to the first bad probe. Also, driver
>> started to flood console with those ARQ event messages.
>>
>> This patch will prevent these issues by allowing error recovery
>> mechanism to remove the failed device from the system instead of
>> trying to recover from early PCI errors during device probe.
>>
> 
> This seems reasonable.
> 
>> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
>> ---
>>  drivers/net/ethernet/intel/i40e/i40e_main.c | 6 ++++++
>>  1 file changed, 6 insertions(+)
>>
>> diff --git a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> index d0b3a1b..dad15b6 100644
>> --- a/drivers/net/ethernet/intel/i40e/i40e_main.c
>> +++ b/drivers/net/ethernet/intel/i40e/i40e_main.c
>> @@ -11360,6 +11360,12 @@ static pci_ers_result_t
>> i40e_pci_error_detected(struct pci_dev *pdev,
>>  
>>  	dev_info(&pdev->dev, "%s: error %d\n", __func__, error);
>>  
>> +	if (!pf) {
>> +		dev_info(&pdev->dev,
>> +			 "Cannot recover - error happened during
>> device probe\n");
>> +		return PCI_ERS_RESULT_DISCONNECT;
>> +	}
>> +
> 
> Looks good to me.
> 
> Acked-by: Jacob Keller <jacob.e.keller@intel.com>
> 
> Thanks for the bug fix and detailed explanation!

Nice Jacob, thanks very much for the review and ack.

Cheers,



Guilherme


> Regards,
> Jake
> 
>>  	/* shutdown all operations */
>>  	if (!test_bit(__I40E_SUSPENDED, &pf->state)) {
>>  		rtnl_lock();
