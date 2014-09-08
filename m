From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-next] skb: Add documentation for skb_clone_sk
Date: Mon, 08 Sep 2014 11:44:46 -0700
Message-ID: <540DF91E.7040005@intel.com>
References: <20140908161748.13099.29093.stgit@ahduyck-bv4.jf.intel.com> <1410196297.11872.119.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, richardcochran@gmail.com,
	davem@davemloft.net
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:56552 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752776AbaIHSor (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Sep 2014 14:44:47 -0400
In-Reply-To: <1410196297.11872.119.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/08/2014 10:11 AM, Eric Dumazet wrote:
> On Mon, 2014-09-08 at 12:18 -0400, Alexander Duyck wrote:
>> This change adds some documentation to the call skb_clone_sk.  This is
>> meant to help clarify the purpose of the function for other developers.
>>
>> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>> ---
>>  net/core/skbuff.c |   11 +++++++++++
>>  1 file changed, 11 insertions(+)
>>
>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
>> index a18dfb0..3f83a8a 100644
>> --- a/net/core/skbuff.c
>> +++ b/net/core/skbuff.c
>> @@ -3511,6 +3511,17 @@ struct sk_buff *sock_dequeue_err_skb(struct sock *sk)
>>  }
>>  EXPORT_SYMBOL(sock_dequeue_err_skb);
>>  
>> +/**
>> + * skb_clone_sk - create clone of skb, and take reference to socket
>> + * @skb: the skb to clone
>> + *
>> + * For functions such as timestamping it is necessary to clone an skb and
>> + * hold a reference to the socket for it until the hardware delivers the
>> + * actual timestamp or the timestamp is timed out.  As as such this
>> + * function is useful for creating a clone to later be handed off to
>> + * skb_complete_tx_timestamp or kfree_skb to take care of cleaning up
>> + * the reference handling for the socket.
>> + */
>>  struct sk_buff *skb_clone_sk(struct sk_buff *skb)
>>  {
>>  	struct sock *sk = skb->sk;
> 
> Note that I have serious doubts about the atomic_inc_not_zero() here.
> 
> At this point, we need to have consistent refcounting on the socket.
> 
> If we decide the reference is against sk_refcnt, then current sk_refcnt
> cannot be 0 at this point.

Isn't that what is guaranteed by using the atomic_inc_not_zero?  If it
is zero we abort and just return NULL.

> This might hide a very serious bug.
> 
> In TCP tx path for example, we do not take reference on sk_refcnt for
> each packet, but a reference on sk_wmem_alloc
> 
> If skb destructor is sock_wfree() or tcp_wfree(), then we should take an
> extra reference on sk_wmem_alloc instead of sk_refcnt.

My concern then would be what I should do about skb_tx_complete as I am
currently using sock_hold/sock_put to prevent the socket from being
freed due to the skb_orphan call in sock_queue_err_skb.

Would I need to change the logic there as well in order to prevent us
from using the wrong reference to keep the socket valid?

Thanks,

Alex
