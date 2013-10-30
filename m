From: Jiri Pirko <jiri@resnulli.us>
Subject: Re: [patch net-next RFC] netfilter: ip6_tables: use reasm skb for
 matching
Date: Wed, 30 Oct 2013 15:13:54 +0100
Message-ID: <20131030141354.GB1456@minipsycho.orion>
References: <1383130201-6198-1-git-send-email-jiri@resnulli.us>
 <20131030134100.GD16615@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, pablo@netfilter.org,
	netfilter-devel@vger.kernel.org, yoshfuji@linux-ipv6.org,
	kadlec@blackhole.kfki.hu, kaber@trash.net, mleitner@redhat.com
To: Florian Westphal <fw@strlen.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131030134100.GD16615@breakpoint.cc>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Oct 30, 2013 at 02:41:00PM CET, fw@strlen.de wrote:
>Jiri Pirko <jiri@resnulli.us> wrote:
>> Currently, when ipv6 fragment goes through the netfilter, match
>> functions are called on them directly. This might cause match function
>> to fail. So benefit from the fact that nf_defrag_ipv6 constructs
>> reassembled skb for us and use this reassembled skb for matching.
>> 
>> This patch fixes for example following situation:
>> On HOSTA do:
>> ip6tables -I INPUT -p icmpv6 -j DROP
>> ip6tables -I INPUT -p icmpv6 -m icmp6 --icmpv6-type 128 -j ACCEPT
>> 
>> and on HOSTB you do:
>> ping6 HOSTA -s2000    (MTU is 1500)
>> 
>> Incoming echo requests will be filtered out on HOSTA. This issue does
>> not occur with smaller packets than MTU (where fragmentation does not happen).
>
>[..]
>> diff --git a/net/ipv6/netfilter/ip6_tables.c b/net/ipv6/netfilter/ip6_tables.c
>> index 44400c2..5421beb0 100644
>> --- a/net/ipv6/netfilter/ip6_tables.c
>> +++ b/net/ipv6/netfilter/ip6_tables.c
>> @@ -328,6 +328,7 @@ ip6t_do_table(struct sk_buff *skb,
>>  	const struct xt_table_info *private;
>>  	struct xt_action_param acpar;
>>  	unsigned int addend;
>> +	struct sk_buff *reasm = skb->nfct_reasm ? skb->nfct_reasm : skb;
>>  
>>  	/* Initialization */
>>  	indev = in ? in->name : nulldevname;
>> @@ -363,7 +364,7 @@ ip6t_do_table(struct sk_buff *skb,
>>  
>>  		IP_NF_ASSERT(e);
>>  		acpar.thoff = 0;
>> -		if (!ip6_packet_match(skb, indev, outdev, &e->ipv6,
>> +		if (!ip6_packet_match(reasm, indev, outdev, &e->ipv6,
>>  		    &acpar.thoff, &acpar.fragoff, &acpar.hotdrop)) {
>
>[..]
>
>This is a bit backwards, I think.
>- We gather frags
>- Then we invoke ip6t_do_table for each individual fragment
>
>So basically your patch is equivalent to
>for_each_frag( )
>  ip6t_do_table(reassembled_skb)
>
>Which makes no sense to me - why traverse the ruleset n times with the same
>packet?


Because each fragment need to be pushed through separately.

What different approach would you suggest?

Thanks

Jiri
