From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Subject: Re: [PATCH] netlink: enable skb header refcounting before sending
 first broadcast
Date: Fri, 10 Jul 2015 17:08:32 +0300
Message-ID: <559FD1E0.40909@yandex-team.ru>
References: <20150710115141.12980.88829.stgit@buzz> <1436536187.24939.50.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from forward-corp1o.mail.yandex.net ([37.140.190.172]:46614 "EHLO
	forward-corp1o.mail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754467AbbGJOIj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jul 2015 10:08:39 -0400
In-Reply-To: <1436536187.24939.50.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10.07.2015 16:49, Eric Dumazet wrote:
> On Fri, 2015-07-10 at 14:51 +0300, Konstantin Khlebnikov wrote:
>> This fixes race between non-atomic updates of adjacent bit-fields:
>> skb->cloned could be lost because netlink broadcast clones skb after
>> sending it to the first listener who sets skb->peeked at the same skb.
>> As a result atomic refcounting of skb header stays disabled and
>> skb_release_data() frees it twice. Race leads to double-free in kmalloc-xxx.
>>
>> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
>> Fixes: b19372273164 ("net: reorganize sk_buff for faster __copy_skb_header()")
>> ---
>>   net/netlink/af_netlink.c |    6 ++++++
>>   1 file changed, 6 insertions(+)
>>
>> diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
>> index dea925388a5b..921e0d8dfe3a 100644
>> --- a/net/netlink/af_netlink.c
>> +++ b/net/netlink/af_netlink.c
>> @@ -2028,6 +2028,12 @@ int netlink_broadcast_filtered(struct sock *ssk, struct sk_buff *skb, u32 portid
>>   	info.tx_filter = filter;
>>   	info.tx_data = filter_data;
>>
>> +	/* Enable atomic refcounting in skb_release_data() before first send:
>> +	 * non-atomic set of that bit-field in __skb_clone() could race with
>> +	 * __skb_recv_datagram() which touches the same set of bit-fields.
>> +	 */
>> +	skb->cloned = 1;
>> +
>>   	/* While we sleep in clone, do not allow to change socket list */
>>
>>   	netlink_lock_table();
>
> Wow, this is tricky.
>
> I wonder how you found this bug ????

In some setups race happens quite often: once or twice per hour.
I guess the main trigger was the openvswitch which generates a
lot of netlink traffic. Though debugging was a real pain.

>
> Acked-by: Eric Dumazet <edumazet@google.com>
>
>
>


-- 
Konstantin
