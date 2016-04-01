From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net-next 1/6] net: skbuff: don't use union for napi_id and
 sender_cpu
Date: Fri, 1 Apr 2016 10:46:56 +0800
Message-ID: <56FDE120.1000403@redhat.com>
References: <1459403439-6011-1-git-send-email-jasowang@redhat.com>
 <1459403439-6011-2-git-send-email-jasowang@redhat.com>
 <1459420341.6473.225.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160331.160115.1737831060132252055.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160331.160115.1737831060132252055.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 04/01/2016 04:01 AM, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 31 Mar 2016 03:32:21 -0700
>
>> On Thu, 2016-03-31 at 13:50 +0800, Jason Wang wrote:
>>> We use a union for napi_id and send_cpu, this is ok for most of the
>>> cases except when we want to support busy polling for tun which needs
>>> napi_id to be stored and passed to socket during tun_net_xmit(). In
>>> this case, napi_id was overridden with sender_cpu before tun_net_xmit()
>>> was called if XPS was enabled. Fixing by not using union for napi_id
>>> and sender_cpu.
>>>
>>> Signed-off-by: Jason Wang <jasowang@redhat.com>
>>> ---
>>>  include/linux/skbuff.h | 10 +++++-----
>>>  1 file changed, 5 insertions(+), 5 deletions(-)
>>>
>>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
>>> index 15d0df9..8aee891 100644
>>> --- a/include/linux/skbuff.h
>>> +++ b/include/linux/skbuff.h
>>> @@ -743,11 +743,11 @@ struct sk_buff {
>>>  	__u32			hash;
>>>  	__be16			vlan_proto;
>>>  	__u16			vlan_tci;
>>> -#if defined(CONFIG_NET_RX_BUSY_POLL) || defined(CONFIG_XPS)
>>> -	union {
>>> -		unsigned int	napi_id;
>>> -		unsigned int	sender_cpu;
>>> -	};
>>> +#if defined(CONFIG_NET_RX_BUSY_POLL)
>>> +	unsigned int		napi_id;
>>> +#endif
>>> +#if defined(CONFIG_XPS)
>>> +	unsigned int		sender_cpu;
>>>  #endif
>>>  	union {
>>>  #ifdef CONFIG_NETWORK_SECMARK
>> Hmmm...
>>
>> This is a serious problem.
>>
>> Making skb bigger (8 bytes because of alignment) was not considered
>> valid for sender_cpu introduction. We worked quite hard to avoid this,
>> if you take a look at git history :(
>>
>> Can you describe more precisely the problem and code path ?
> From what I can see they are doing busy poll loops in the TX code paths,
> as well as the RX code paths, of vhost.
>
> Doing this in the TX side makes little sense to me.  The busy poll
> implementations in the drivers only process their RX queues when
> ->ndo_busy_poll() is invoked.  So I wonder what this is accomplishing
> for the vhost TX case?

In vhost TX case, it's possible that new packets were arrived at rx
queue during tx polling. Consider tx and rx were processed in one
thread, poll rx looks feasible to me.
