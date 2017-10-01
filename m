From: Yotam Gigi <yotamg@mellanox.com>
Subject: Re: [patch net-next 3/7] ipv4: ipmr: Don't forward packets already
 forwarded by hardware
Date: Sun, 1 Oct 2017 11:51:58 +0300
Message-ID: <d1bf0ca6-5bf9-6490-fbcd-dfc184b6ceec@mellanox.com>
References: <20170928173415.15551-1-jiri@resnulli.us>
 <20170928173415.15551-4-jiri@resnulli.us>
 <bb37f353-8f15-f570-a35e-ed76c56f1180@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, idosch@mellanox.com, mlxsw@mellanox.com,
        nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, fw@strlen.de, gfree.wind@vip.163.com
To: Florian Fainelli <f.fainelli@gmail.com>,
        Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0055.outbound.protection.outlook.com ([104.47.2.55]:60111
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751078AbdJAIwM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 1 Oct 2017 04:52:12 -0400
In-Reply-To: <bb37f353-8f15-f570-a35e-ed76c56f1180@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2017 08:56 PM, Florian Fainelli wrote:
> On 09/28/2017 10:34 AM, Jiri Pirko wrote:
>> From: Yotam Gigi <yotamg@mellanox.com>
>>
>> Change the ipmr module to not forward packets if:
>>  - The packet is marked with the offload_mr_fwd_mark, and
>>  - Both input interface and output interface share the same parent ID.
>>
>> This way, a packet can go through partial multicast forwarding in the
>> hardware, where it will be forwarded only to the devices that share the
>> same parent ID (AKA, reside inside the same hardware). The kernel will
>> forward the packet to all other interfaces.
>>
>> To do this, add the ipmr_offload_forward helper, which per skb, ingress VIF
>> and egress VIF, returns whether the forwarding was offloaded to hardware.
>> The ipmr_queue_xmit frees the skb and does not forward it if the result is
>> a true value.
>>
>> All the forwarding path code compiles out when the CONFIG_NET_SWITCHDEV is
>> not set.
>>
>> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
>> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
>> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
>> ---
>>  net/ipv4/ipmr.c | 37 ++++++++++++++++++++++++++++++++-----
>>  1 file changed, 32 insertions(+), 5 deletions(-)
>>
>> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
>> index 4566c54..deba569 100644
>> --- a/net/ipv4/ipmr.c
>> +++ b/net/ipv4/ipmr.c
>> @@ -1857,10 +1857,33 @@ static inline int ipmr_forward_finish(struct net *net, struct sock *sk,
>>  	return dst_output(net, sk, skb);
>>  }
>>  
>> +#ifdef CONFIG_NET_SWITCHDEV
>> +static bool ipmr_forward_offloaded(struct sk_buff *skb, struct mr_table *mrt,
>> +				   int in_vifi, int out_vifi)
>> +{
>> +	struct vif_device *out_vif = &mrt->vif_table[out_vifi];
>> +	struct vif_device *in_vif = &mrt->vif_table[in_vifi];
> Nit: in_vifi and out_vifi may be better named as in_vif_idx and
> out_vif_idx, oh well you are just replicating the existing naming
> conventions used down below, never mind then.


Yes, unfortunately, the acronym "vifi" is pretty common in the file. I would
also prefer something like vif_index, but vifi would better match the current
convention in the code.
