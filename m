From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH v7 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Wed, 02 Nov 2016 02:17:17 +0100
Message-ID: <58193E9D.7040201@iogearbox.net>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>       <1477390454-12553-6-git-send-email-daniel@zonque.org> <20161031.124003.1361406552151798940.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: htejun-b10kYP2dOMg@public.gmane.org, ast-b10kYP2dOMg@public.gmane.org, kafai-b10kYP2dOMg@public.gmane.org, fw-HFFVJYpyMKqzQB+pC5nmwQ@public.gmane.org,
        pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org, harald-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161031.124003.1361406552151798940.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 10/31/2016 05:40 PM, David Miller wrote:
> From: Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>
> Date: Tue, 25 Oct 2016 12:14:13 +0200
>
>> @@ -312,6 +314,13 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>>   	skb->dev = dev;
>>   	skb->protocol = htons(ETH_P_IP);
>>
>> +	ret = cgroup_bpf_run_filter(sk_to_full_sk(sk), skb,
>> +				    BPF_CGROUP_INET_EGRESS);
>> +	if (ret) {
>> +		kfree_skb(skb);
>> +		return ret;
>> +	}
>> +
>>   	/*
>>   	 *	Multicasts are looped back for other local users
>>   	 */
>> @@ -364,12 +373,20 @@ int ip_mc_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>>   int ip_output(struct net *net, struct sock *sk, struct sk_buff *skb)
>>   {
>>   	struct net_device *dev = skb_dst(skb)->dev;
>> +	int ret;
>>
>>   	IP_UPD_PO_STATS(net, IPSTATS_MIB_OUT, skb->len);
>>
>>   	skb->dev = dev;
>>   	skb->protocol = htons(ETH_P_IP);
>>
>> +	ret = cgroup_bpf_run_filter(sk_to_full_sk(sk), skb,
>> +				    BPF_CGROUP_INET_EGRESS);
>> +	if (ret) {
>> +		kfree_skb(skb);
>> +		return ret;
>> +	}
>> +
>>   	return NF_HOOK_COND(NFPROTO_IPV4, NF_INET_POST_ROUTING,
>>   			    net, sk, skb, NULL, dev,
>>   			    ip_finish_output,
>
> The "sk" here is not necessarily the application socket.  It could be
> a UDP tunnel socket or similar encapsulation object.
>
> "skb->sk" is always the application socket, so is probably what you
> need to pass down into the cgroup bpf run filter hook.

Wouldn't that mean however, when you go through stacked devices that
you'd run the same eBPF cgroup program for skb->sk multiple times?
(Except for things like crossing netns due to the skb_orphan() there.)

For example, when you're doing accounting through this facility, then
TX part is counted X times instead of ideally just once, and for RX
afaik, we seem to short-cut sk_filter_trim_cap() on the encaps anyway.

I guess one could work around this by marking the skb with a verdict
once it was accounted for the first time, either from within eBPF prog
or from stack side. For eBPF we'd need to implement our own .is_valid_access()
callback for the verifier to allow writing into skb meta data like skb->mark
(sk filter can only write into cb[] for passing data between tail calls)
plus making sure in either case that no other user is mangling that flag
further on; hmm, probably rather unintuitive and fragile.

Unless I'm missing something obvious, I would currently think that just
passing "sk" might be more correct.
