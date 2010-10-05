From: Steve Wise <swise@opengridcomputing.com>
Subject: Re: [PATCH] SIW: Object management
Date: Tue, 05 Oct 2010 10:02:37 -0500
Message-ID: <4CAB3E0D.8050609@opengridcomputing.com>
References: <1286261665-5175-1-git-send-email-bmt@zurich.ibm.com> <4CAB35A8.6080906@opengridcomputing.com> <OF706D1D5F.5849676F-ONC12577B3.004FB763-C12577B3.00521572@ch.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma@vger.kernel.org, netdev@vger.kernel.org
To: Bernard Metzler <BMT@zurich.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:42209 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752861Ab0JEPCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Oct 2010 11:02:43 -0400
In-Reply-To: <OF706D1D5F.5849676F-ONC12577B3.004FB763-C12577B3.00521572@ch.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2010 09:56 AM, Bernard Metzler wrote:
> Steve Wise<swise@opengridcomputing.com>  wrote on 10/05/2010 04:26:48 PM:
>
>    
>> Steve Wise<swise@opengridcomputing.com>
>> 10/05/2010 04:26 PM
>>
>> To
>>
>> Bernard Metzler<bmt@zurich.ibm.com>
>>
>> cc
>>
>> netdev@vger.kernel.org, linux-rdma@vger.kernel.org
>>
>> Subject
>>
>> Re: [PATCH] SIW: Object management
>>
>> On 10/05/2010 01:54 AM, Bernard Metzler wrote:
>>
>> <snip>+
>>      
>>> +
>>> +/***** routines for WQE handling ***/
>>> +
>>> +/*
>>> + * siw_wqe_get()
>>> + *
>>> + * Get new WQE. For READ RESPONSE, take it from the free list which
>>> + * has a maximum size of maximum inbound READs. All other WQE are
>>> + * malloc'ed which creates some overhead. Consider change to
>>> + *
>>> + * 1. malloc WR only if it cannot be synchonously completed, or
>>> + * 2. operate own cache of reuseable WQE's.
>>> + *
>>> + * Current code trusts on malloc efficiency.
>>> + */
>>> +inline struct siw_wqe *siw_wqe_get(struct siw_qp *qp, enum
>>>        
>> siw_wr_opcode op)
>>      
>>> +{
>>> +   struct siw_wqe *wqe;
>>> +
>>> +   if (op == SIW_WR_RDMA_READ_RESP) {
>>> +      spin_lock(&qp->freelist_lock);
>>> +      if (!(list_empty(&qp->wqe_freelist))) {
>>> +         wqe = list_entry(qp->wqe_freelist.next,
>>> +                struct siw_wqe, list);
>>> +         list_del(&wqe->list);
>>> +         spin_unlock(&qp->freelist_lock);
>>> +         wqe->processed = 0;
>>> +         dprint(DBG_OBJ|DBG_WR,
>>> +            "(QP%d): WQE from FreeList p: %p\n",
>>> +            QP_ID(qp), wqe);
>>> +      } else {
>>> +         spin_unlock(&qp->freelist_lock);
>>> +         wqe = NULL;
>>> +         dprint(DBG_ON|DBG_OBJ|DBG_WR,
>>> +            "(QP%d): FreeList empty!\n", QP_ID(qp));
>>> +      }
>>> +   } else {
>>> +      wqe = kzalloc(sizeof(struct siw_wqe), GFP_KERNEL);
>>> +      dprint(DBG_OBJ|DBG_WR, "(QP%d): New WQE p: %p\n",
>>> +         QP_ID(qp), wqe);
>>> +   }
>>>
>>>        
>> I think you can't allocate at GFP_KERNEL here if this is called from the
>>      
>    
>> post_ functions.  I think you might want to pre-allocate these when you
>> create the QP...
>>
>>      
> the idea was to keep the memory footprint small and flexible
> while using the linux/list.h routines to manipulate all queues
> (no ring buffers etc, just lists). at the same time we
> decided to take the provided uverbs_cmd-syscall path down to
> the driver even for the post_-functions (since we would have to ring a
> doorbell on the send path anyway, which in software, is a syscall).
> in that path, even ib_uverbs_post_send() does one kmalloc() per wr
> (it would be helpful if the provider could keep and reuse that wr of
> known size, freeing it later at its own premises. that would avoid
> the second kmalloc here.)
>
> currently only work queue elements which are needed to satisfy
> inbound read requests are pre-allocated (amount corresponding
> to inbound read queue depth), since the read response is
> scheduled in network softirq context which must not sleep.
>
> that discussion may relate to the spinlock at the entrance to the
> post_ verbs. going down the uverbs_cmd path may sleep anyway...?
>
>    


The uverb calls may sleep, but certain kernel verbs must not.  Remember, 
the post_send/recv and other functions in your driver are called 
directly (almost) by kernel users like NFSRDMA.  These users may be 
calling in an interrupt context and thus you cannot block/sleep.

Steve.
