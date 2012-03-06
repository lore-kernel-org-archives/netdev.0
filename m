From: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Subject: Re: rds cq event handler issue
Date: Tue, 06 Mar 2012 13:18:55 -0600
Message-ID: <4F56631F.8050500@opengridcomputing.com>
References: <4F5651E5.1020005@opengridcomputing.com> <4F565E3D.8030206@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Vipul Pandya <vipul-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>
To: Venkat Venkatsubra <venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4F565E3D.8030206-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 03/06/2012 12:58 PM, Venkat Venkatsubra wrote:
> On 3/6/2012 12:05 PM, Steve Wise wrote:
>> Hey Venkat,
>>
>> I think I see a bug in the RDS RDMA module where RDS is not adhering to the RDMA locking context.  From the kernel 
>> tree Documentation/infiniband/core_locking.txt:
>>
>> ---
>>   The context in which completion event and asynchronous event
>>   callbacks run is not defined.  Depending on the low-level driver, it
>>   may be process context, softirq context, or interrupt context.
>>   Upper level protocol consumers may not sleep in a callback.
>> ---
>>
>> So RDMA ULPs cannot assume any certain context for their callback functions.  Yet I get a BUG_ON() when running RDS 
>> with iw_cxgb3 where RDS is bugging in rds_rdma_free_op():
>>
>> ---
>>                 /* Mark page dirty if it was possibly modified, which
>>                  * is the case for a RDMA_READ which copies from remote
>>                  * to local memory */
>>                 if (!ro->op_write) {
>>                         BUG_ON(irqs_disabled());
>>                         set_page_dirty(page);
>>                 }
>> ---
>>
>> And rds_rdma_free_op() can be called in the cq callback path.  Here's a stack trace when it bugged:
>>
>> ---
>> Call Trace:
>> <IRQ> [<ffffffff886ca0fc>] :rds:rds_message_purge+0x54/0x79
>> [<ffffffff886ca162>] :rds:rds_message_put+0x41/0x4c
>> [<ffffffff886f616b>] :rds_rdma:rds_iw_send_unmap_rm+0xe2/0xf2
>> [<ffffffff886f63c4>] :rds_rdma:rds_iw_send_cq_comp_handler+0x193/0x2e5
>> [<ffffffff88698a56>] :iw_cxgb3:iwch_ev_dispatch+0x1df/0x2b1
>> [<ffffffff8869f0b2>] :iw_cxgb3:cxio_hal_ev_handler+0x6b/0xb4
>> [<ffffffff882746cd>] :cxgb3:process_rx+0x3d/0xa0
>> [<ffffffff8827b28c>] :cxgb3:process_responses+0x120c/0x1350
>> ---
>>
>> iwch_ev_dispatch() explicitly disables irqs to ensure proper serialization:
>>
>> ---
>>         spin_lock_irqsave(&chp->comp_handler_lock, flag);
>>         (*chp->ibcq.comp_handler)(&chp->ibcq, chp->ibcq.cq_context);
>>         spin_unlock_irqrestore(&chp->comp_handler_lock, flag);
>> ---
>>
>> I'm not sure if that BUG_ON() in rds_rdma_free_op() is valid or not.  If it is valid, then RDS needs to run this 
>> logic in a safe context, not in the context of the CQ callback.  It BUG_ON() is not valid, we can remove it :).
>>
>> Can you comment?
>>
>> Thanks,
>>
>> Steve.
>>
> Hi Steve,
>
> Our internal latest code has a WARN_ON instead:
> ---------------------
>                 /* Mark page dirty if it was possibly modified, which
>                  * is the case for a RDMA_READ which copies from remote
>                  * to local memory */
>                 if (!ro->op_write) {
>                         WARN_ON_ONCE(page_mapping(page) && irqs_disabled());
>                         set_page_dirty(page);
>                 }
> ---------------------
>
> Venkat

That helps with the crashing. :)   Does set_page_dirty() require irqs enabled?  If so, RDS needs to change such that it 
doesn't do this work in the CQ event handler callback context.

Steve.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
