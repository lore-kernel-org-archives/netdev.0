From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 05/13]: [IPV4/6]: Netfilter IPsec output hooks
Date: Tue, 22 Nov 2005 06:13:43 +0100
Message-ID: <4382A907.2080806@trash.net>
References: <20051120163128.16666.38111.sendpatchset@localhost.localdomain>
	<20051120163134.16666.9265.sendpatchset@localhost.localdomain>
	<20051122044046.GA29166@gondor.apana.org.au>
	<4382A44F.9000105@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	davem@davemloft.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <4382A44F.9000105@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Herbert Xu wrote:
> 
>> On Sun, Nov 20, 2005 at 04:31:34PM +0000, Patrick McHardy wrote:
>>
>>> diff --git a/net/ipv4/netfilter.c b/net/ipv4/netfilter.c
>>> index ae0779d..b93e7cd 100644
>>> --- a/net/ipv4/netfilter.c
>>> +++ b/net/ipv4/netfilter.c
>>> @@ -78,6 +79,34 @@ int ip_route_me_harder(struct sk_buff **
>>> }
>>> EXPORT_SYMBOL(ip_route_me_harder);
>>>
>>> +#ifdef CONFIG_XFRM
>>> +static inline int __ip_dst_output(struct sk_buff *skb)
>>
>>
>>
>> I'd like to suggest an alternative way of doing this that
>>
>> 1) Keeps this XFRM stuff in xfrm*.c.
>> 2) Removes the need for ip_dst_output.
>>
>> Please see the attached patch.
>>
>>
>>> +    do {
>>> +        err = skb->dst->output(skb);
>>> +
>>> +        if (likely(err == 0))
>>> +            return err;
>>> +        if (unlikely(err != NET_XMIT_BYPASS))
>>> +            return err;
>>> +    } while (skb->dst->xfrm && !skb->dst->xfrm->props.mode);
>>> +
>>> +    return NF_HOOK(PF_INET, NF_IP_LOCAL_OUT, skb, NULL, skb->dst->dev,
>>> +                   ip_dst_output);
>>
>>
>>
>> The idea is simply to put this stuff in xfrm[46]_output directly.
>> So for your patch you would simply need to add the two NF_HOOK
>> calls at the beginning and end of xfrm[46]_output once they've
>> been modified in the way I outline below.
> 
> 
> This looks nice, but placing the hooks at the end of the xfrm[46]
> functions doesn't work with queueing without recursively calling
> dst_output (as okfn) since we have to provide an okfn but also
> have to return ownership of the skb back to dst_output.

I should add, the same affects ip_dst_output/__ip_dst_output of
course, which is why they do call themselves recursively. But since
__ip_dst_output is an inline function and is not called through the
function pointer except from a different context (ip_queue), the
compiler does a good job at eliminating the recursion for the
inlined version. This probably wouldn't work if we used a recursive
dst_output call in xfrm[46]_output. But your patch looks like a nice
idea anyway, so how about we move the looping to xfrm[46]_input and
keep ip/ip6_dst_output for the hooks?
