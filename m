From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 02/10] tipc: eliminate aggregate
 sk_receive_queue limit
Date: Fri, 07 Dec 2012 12:36:44 -0500 (EST)
Message-ID: <20121207.123644.431593821406881255.davem@davemloft.net>
References: <1354890498-6448-1-git-send-email-paul.gortmaker@windriver.com>
	<1354890498-6448-3-git-send-email-paul.gortmaker@windriver.com>
	<20121207160733.GD29819@shamino.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, netdev@vger.kernel.org,
	jon.maloy@ericsson.com, ying.xue@windriver.com
To: nhorman@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56798 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932837Ab2LGRgq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 12:36:46 -0500
In-Reply-To: <20121207160733.GD29819@shamino.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neil Horman <nhorman@tuxdriver.com>
Date: Fri, 7 Dec 2012 11:07:33 -0500

> On Fri, Dec 07, 2012 at 09:28:10AM -0500, Paul Gortmaker wrote:
>> From: Ying Xue <ying.xue@windriver.com>
>> 
>> As a complement to the per-socket sk_recv_queue limit, TIPC keeps a
>> global atomic counter for the sum of sk_recv_queue sizes across all
>> tipc sockets. When incremented, the counter is compared to an upper
>> threshold value, and if this is reached, the message is rejected
>> with error code TIPC_OVERLOAD.
>> 
>> This check was originally meant to protect the node against
>> buffer exhaustion and general CPU overload. However, all experience
>> indicates that the feature not only is redundant on Linux, but even
>> harmful. Users run into the limit very often, causing disturbances
>> for their applications, while removing it seems to have no negative
>> effects at all. We have also seen that overall performance is
>> boosted significantly when this bottleneck is removed.
>> 
>> Furthermore, we don't see any other network protocols maintaining
>> such a mechanism, something strengthening our conviction that this
>> control can be eliminated.
>> 
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
>> Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
 ...
>> @@ -1241,11 +1241,6 @@ static u32 filter_rcv(struct sock *sk, struct sk_buff *buf)
>>  	}
>>  
>>  	/* Reject message if there isn't room to queue it */
>> -	recv_q_len = (u32)atomic_read(&tipc_queue_size);
>> -	if (unlikely(recv_q_len >= OVERLOAD_LIMIT_BASE)) {
>> -		if (rx_queue_full(msg, recv_q_len, OVERLOAD_LIMIT_BASE))
>> -			return TIPC_ERR_OVERLOAD;
>> -	}
> If you're going to remove the one place that you read this variable, don't you
> also want to remove the points where you increment/decrement the atomic as well,
> and for that matter eliminate the definition itself?

There's another reader, a getsockopt() call.

I would just make it return zero or similar.

Paul please do so and respin this series.

Thanks.
