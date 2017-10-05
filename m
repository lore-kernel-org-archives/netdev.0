From: "Kalderon, Michal" <Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v2 net-next 06/12] qed: Add LL2 slowpath handling
Date: Thu, 5 Oct 2017 20:27:22 +0000
Message-ID: <CY1PR0701MB201241C43A192735A0F1EEDD88700@CY1PR0701MB2012.namprd07.prod.outlook.com>
References: <20171003.101712.715882117516958741.davem@davemloft.net>
        <CY1PR0701MB20128130D21FD3C54E45B5A188720@CY1PR0701MB2012.namprd07.prod.outlook.com>
        <CY1PR0701MB2012A2F8E3E923D98B1E1A6488700@CY1PR0701MB2012.namprd07.prod.outlook.com>,<20171005.120629.2161199733119811102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "Elior, Ariel" <Ariel.Elior-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20171005.120629.2161199733119811102.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sent: Thursday, October 5, 2017 10:06 PM
>> From: Kalderon, Michal
>> Sent: Tuesday, October 3, 2017 9:05 PM
>> To: David Miller
>>>From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
>>>Sent: Tuesday, October 3, 2017 8:17 PM
>>>>> @@ -423,6 +423,41 @@ static void qed_ll2_rxq_parse_reg(struct qed_hwf=
n *p_hwfn,
>>>>>  }
>>>>>
>>>>>  static int
>>>>> +qed_ll2_handle_slowpath(struct qed_hwfn *p_hwfn,
>>>>> +                     struct qed_ll2_info *p_ll2_conn,
>>>>> +                     union core_rx_cqe_union *p_cqe,
>>>>> +                     unsigned long *p_lock_flags)
>>>>> +{
>>>>...
>>>>> +     spin_unlock_irqrestore(&p_rx->lock, *p_lock_flags);
>>>>> +
>>>>
>>>>You can't drop this lock.
>>>>
>>>>Another thread can enter the loop of our caller and process RX queue
>>>>entries, then we would return from here and try to process the same
>>>>entries again.
>>>
>>>The lock is there to synchronize access to chains between qed_ll2_rxq_co=
mpletion
>>>and qed_ll2_post_rx_buffer. qed_ll2_rxq_completion can't be called from
>>>different threads, the light l2 uses the single sp status block we have.
>>>The reason we release the lock is to avoid a deadlock where as a result =
of calling
>>>upper-layer driver it will potentially post additional rx-buffers.
>>
>> Dave, is there anything else needed from me on this?
>> Noticed the series is still in "Changes Requested".
>
>I'm still not convinced that the lock dropping is legitimate.  What if a
>spurious interrupt arrives?
We're in the context of a dedicated tasklet here. So even if there is a spu=
rious
interrupt, we're covered.

>
>If the execution path in the caller is serialized for some reason, why
>are you using a spinlock and don't use that serialization for the mutual
>exclusion necessary for these queue indexes?
Posting of rx-buffers back to the light-l2 is not always serialized and can=
 be
called from different threads depending on the light-l2 client.
Unlocking before calling the callback enables the cb function to post rx bu=
ffers,
in this case, serialization protects us. The spinlock is required for the c=
ase
that rx buffers are posted from a different thread, where it could be run
simultaneously to the rxq_completion.

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
