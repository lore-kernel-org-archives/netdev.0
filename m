From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH v2 net-next 06/12] qed: Add LL2 slowpath handling
Date: Thu, 05 Oct 2017 12:06:29 -0700 (PDT)
Message-ID: <20171005.120629.2161199733119811102.davem@davemloft.net>
References: <20171003.101712.715882117516958741.davem@davemloft.net>
        <CY1PR0701MB20128130D21FD3C54E45B5A188720@CY1PR0701MB2012.namprd07.prod.outlook.com>
        <CY1PR0701MB2012A2F8E3E923D98B1E1A6488700@CY1PR0701MB2012.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CY1PR0701MB2012A2F8E3E923D98B1E1A6488700-UpKza+2NMNLHMJvQ0dyT705OhdzP3rhOnBOFsp37pqbUKgpGm//BTAC/G2K4zDHf@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Thu, 5 Oct 2017 18:59:04 +0000

> From: Kalderon, Michal
> Sent: Tuesday, October 3, 2017 9:05 PM
> To: David Miller
>>From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>>Sent: Tuesday, October 3, 2017 8:17 PM
>>>> @@ -423,6 +423,41 @@ static void qed_ll2_rxq_parse_reg(struct qed_hwfn *p_hwfn,
>>>>  }
>>>>
>>>>  static int
>>>> +qed_ll2_handle_slowpath(struct qed_hwfn *p_hwfn,
>>>> +                     struct qed_ll2_info *p_ll2_conn,
>>>> +                     union core_rx_cqe_union *p_cqe,
>>>> +                     unsigned long *p_lock_flags)
>>>> +{
>>>...
>>>> +     spin_unlock_irqrestore(&p_rx->lock, *p_lock_flags);
>>>> +
>>>
>>>You can't drop this lock.
>>>
>>>Another thread can enter the loop of our caller and process RX queue
>>>entries, then we would return from here and try to process the same
>>>entries again.
>>
>>The lock is there to synchronize access to chains between qed_ll2_rxq_completion
>>and qed_ll2_post_rx_buffer. qed_ll2_rxq_completion can't be called from
>>different threads, the light l2 uses the single sp status block we have.
>>The reason we release the lock is to avoid a deadlock where as a result of calling
>>upper-layer driver it will potentially post additional rx-buffers.
> 
> Dave, is there anything else needed from me on this? 
> Noticed the series is still in "Changes Requested". 

I'm still not convinced that the lock dropping is legitimate.  What if a
spurious interrupt arrives?

If the execution path in the caller is serialized for some reason, why
are you using a spinlock and don't use that serialization for the mutual
exclusion necessary for these queue indexes?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
