From: Govindarajulu Varadarajan <_govind@gmx.com>
Subject: Re: [PATCH net-next] enic: use atomic_t instead of spin_lock in busy
 poll
Date: Wed, 24 Jun 2015 15:56:17 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1506241401180.24620@ws.cisco>
References: <1435076270-14166-1-git-send-email-_govind@gmx.com> <20150624.012501.1398638370458478294.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: _govind@gmx.com, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.gmx.net ([212.227.15.19]:65063 "EHLO mout.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751732AbbFXK0l (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Jun 2015 06:26:41 -0400
In-Reply-To: <20150624.012501.1398638370458478294.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Jun 2015, David Miller wrote:

> From: Govindarajulu Varadarajan <_govind@gmx.com>
> Date: Tue, 23 Jun 2015 21:47:50 +0530
>
>> -static inline bool enic_poll_unlock_napi(struct vnic_rq *rq)
>> +static inline void enic_poll_unlock_napi(struct vnic_rq *rq,
>> +					 struct napi_struct *napi)
>>  {
>> -	bool rc = false;
>> -
>> -	spin_lock(&rq->bpoll_lock);
>> -	WARN_ON(rq->bpoll_state &
>> -		(ENIC_POLL_STATE_POLL | ENIC_POLL_STATE_NAPI_YIELD));
>> -	if (rq->bpoll_state & ENIC_POLL_STATE_POLL_YIELD)
>> -		rc = true;
>> -	rq->bpoll_state = ENIC_POLL_STATE_IDLE;
>> -	spin_unlock(&rq->bpoll_lock);
>> -
>> -	return rc;
>> +	WARN_ON(atomic_read(&rq->bpoll_state) != ENIC_POLL_STATE_NAPI);
>> +	napi_gro_flush(napi, false);
>> +	atomic_set(&rq->bpoll_state, ENIC_POLL_STATE_IDLE);
>>  }
>
> I don't understand why you needed to add this napi_gro_flush() call here,
> and regardless of the reason you must explain this, in detail, in your
> commit message,
>

In napi poll, if gro is enabled, we call napi_gro_receive() to deliver the
packets. Before we call napi_complete(), i.e while re-polling, if low
latency busy poll is called, we use netif_receive_skb() to deliver the packets.
At this point if there are some skb's held in GRO, busy poll could deliver the
packets out of order. So we call napi_gro_flush() to flush skbs before we
move the napi poll to idle.

Let me know if this change is OK, I will send new patch with detailed
description.

Thanks
Govind
