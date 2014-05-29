From: wenxiong@linux.vnet.ibm.com
Subject: Re: [PATCH V2 2/2] bnx2x: Fix kernel crash and data miscompare
 after EEH recovery
Date: Thu, 29 May 2014 10:50:07 -0400
Message-ID: <20140529105007.Horde.B6QFUJir309Th0kffIaRJlA@imap.linux.ibm.com>
References: <20140528155641.920171803@linux.vnet.ibm.com>
 <20140528155722.361752083@linux.vnet.ibm.com>
 <87B4DDAD5EAFA041BDC28F314593782D017497B2@avmb3.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed; DelSp=Yes
Cc: David Miller <davem@davemloft.net>,
	Ariel Elior <Ariel.Elior@qlogic.com>,
	netdev <netdev@vger.kernel.org>, Milton Miller <miltonm@bga.com>
To: Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:39390 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932940AbaE2OvL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 May 2014 10:51:11 -0400
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <wenxiong@linux.vnet.ibm.com>;
	Thu, 29 May 2014 10:51:11 -0400
Received: from b01cxnp23033.gho.pok.ibm.com (b01cxnp23033.gho.pok.ibm.com [9.57.198.28])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 010196E8047
	for <netdev@vger.kernel.org>; Thu, 29 May 2014 10:50:58 -0400 (EDT)
Received: from d01av05.pok.ibm.com (d01av05.pok.ibm.com [9.56.224.195])
	by b01cxnp23033.gho.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id s4TEov2p4653556
	for <netdev@vger.kernel.org>; Thu, 29 May 2014 14:51:06 GMT
Received: from d01av05.pok.ibm.com (localhost [127.0.0.1])
	by d01av05.pok.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s4TEoWmf027820
	for <netdev@vger.kernel.org>; Thu, 29 May 2014 10:50:33 -0400
In-Reply-To: <87B4DDAD5EAFA041BDC28F314593782D017497B2@avmb3.qlogic.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Quoting Dmitry Kravkov <Dmitry.Kravkov@qlogic.com>:

>> -----Original Message-----
>> From: netdev-owner@vger.kernel.org [mailto:netdev-
>> owner@vger.kernel.org] On Behalf Of wenxiong@linux.vnet.ibm.com
>> Sent: Wednesday, May 28, 2014 6:57 PM
>> To: David Miller
>> Cc: Ariel Elior; netdev; Milton Miller; Wen Xiong
>> Subject: [PATCH V2 2/2] bnx2x: Fix kernel crash and data miscompare after
>> EEH recovery
>>
>> A rmb() is required to ensure that the CQE is not read before it is  
>> written by
>> the adapter DMA.  PCI ordering rules will make sure the other fields are
>> written before the marker at the end of struct eth_fast_path_rx_cqe but
>> without rmb() a weakly ordered processor can process stale data.
>>
>> Without the barrier we have observed various crashes including
>> bnx2x_tpa_start being called on queues not stopped (resulting in message
>> start of bin not in stop) and NULL pointer exceptions from bnx2x_rx_int.
>>
>> Signed-off-by: Milton Miller <miltonm@bga.com>
>> Signed-off-by: Wen Xiong <wenxiong@linux.vnet.ibm.com>
>> ---
>>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c |   12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> Index: b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c
>> ===================================================================
>> --- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c 2014-05-23
>> 10:34:21.000000000 -0500
>> +++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_cmn.c 2014-05-28
>> 10:54:26.627766086 -0500
>> @@ -906,6 +906,18 @@ static int bnx2x_rx_int(struct bnx2x_fas
>>               bd_prod = RX_BD(bd_prod);
>>               bd_cons = RX_BD(bd_cons);
>>
>> +             /* A rmb() is required to ensure that the CQE is not read
>> +              * before it is written by the adapter DMA.  PCI ordering
>> +              * rules will make sure the other fields are written before
>> +              * the marker at the end of struct eth_fast_path_rx_cqe
>> +              * but without rmb() a weakly ordered processor can process
>> +              * stale data.  Without the barrier TPA state-machine might
>> +              * enter inconsistent state and kernel stack might be
>> +              * provided with incorrect packet description - these lead
>> +              * to various kernel crashed.
>> +             */
>> +             rmb();
>> +
>>               cqe_fp_flags = cqe_fp->type_error_flags;
>>               cqe_fp_type = cqe_fp_flags &
>> ETH_FAST_PATH_RX_CQE_TYPE;
>>
> The subject states 'EEH recovery', but looks like this is not the  
> only case. Other than that:
>
> Acked-by: Dmitry Kravkov <dmitry.kravkov@qlogic.com>
>
>
Hi Dmitry,

Can you check if you have any comments for 1/2 patch in this series?  
If you don't, can you ack the 1/2 patch as well?

Thanks,
Wendy
> ________________________________
>
> This message and any attached documents contain information from  
> QLogic Corporation or its wholly-owned subsidiaries that may be  
> confidential. If you are not the intended recipient, you may not  
> read, copy, distribute, or use this information. If you have  
> received this transmission in error, please notify the sender  
> immediately by reply e-mail and then delete this message.
