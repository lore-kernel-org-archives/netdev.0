From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Mon, 19 Sep 2016 21:30:02 +0200
Message-ID: <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org>
References: <1474303441-3745-1-git-send-email-daniel@zonque.org>
 <1474303441-3745-6-git-send-email-daniel@zonque.org>
 <20160919191910.GA984@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:34908 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751008AbcISTaF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 19 Sep 2016 15:30:05 -0400
In-Reply-To: <20160919191910.GA984@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/19/2016 09:19 PM, Pablo Neira Ayuso wrote:
> On Mon, Sep 19, 2016 at 06:44:00PM +0200, Daniel Mack wrote:
>> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
>> index 6001e78..5dc90aa 100644
>> --- a/net/ipv6/ip6_output.c
>> +++ b/net/ipv6/ip6_output.c
>> @@ -39,6 +39,7 @@
>>  #include <linux/module.h>
>>  #include <linux/slab.h>
>>  
>> +#include <linux/bpf-cgroup.h>
>>  #include <linux/netfilter.h>
>>  #include <linux/netfilter_ipv6.h>
>>  
>> @@ -143,6 +144,7 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>>  {
>>  	struct net_device *dev = skb_dst(skb)->dev;
>>  	struct inet6_dev *idev = ip6_dst_idev(skb_dst(skb));
>> +	int ret;
>>  
>>  	if (unlikely(idev->cnf.disable_ipv6)) {
>>  		IP6_INC_STATS(net, idev, IPSTATS_MIB_OUTDISCARDS);
>> @@ -150,6 +152,12 @@ int ip6_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>>  		return 0;
>>  	}
>>  
>> +	ret = cgroup_bpf_run_filter(sk, skb, BPF_CGROUP_INET_EGRESS);
>> +	if (ret) {
>> +		kfree_skb(skb);
>> +		return ret;
>> +	}
> 
> 1) If your goal is to filter packets, why so late? The sooner you
>    enforce your policy, the less cycles you waste.
> 
> Actually, did you look at Google's approach to this problem?  They
> want to control this at socket level, so you restrict what the process
> can actually bind. That is enforcing the policy way before you even
> send packets. On top of that, what they submitted is infrastructured
> so any process with CAP_NET_ADMIN can access that policy that is being
> applied and fetch a readable policy through kernel interface.

Yes, I've seen what they propose, but I want this approach to support
accounting, and so the code has to look at each and every packet in
order to count bytes and packets. Do you know of any better place to put
the hook then?

That said, I can well imagine more hooks types that also operate at port
bind time. That would be easy to add on top.

> 2) This will turn the stack into a nightmare to debug I predict. If
>    any process with CAP_NET_ADMIN can potentially attach bpf blobs
>    via these hooks, we will have to include in the network stack
>    traveling documentation something like: "Probably you have to check
>    that your orchestrator is not dropping your packets for some
>    reason". So I wonder how users will debug this and how the policy that
>    your orchestrator applies will be exposed to userspace.

Sure, every new limitation mechanism adds another knob to look at if
things don't work. But apart from taking care at userspace level to make
the behavior as obvious as possible, I'm open to suggestions of how to
improve the transparency of attached eBPF programs on the kernel side.


Thanks,
Daniel
