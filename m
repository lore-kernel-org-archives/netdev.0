From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next 1/2] bpf: introduce bpf_skb_vlan_push/pop()
 helpers
Date: Fri, 17 Jul 2015 11:17:33 -0700
Message-ID: <55A946BD.4030008@plumgrid.com>
References: <1437101884-2081-1-git-send-email-ast@plumgrid.com>
 <1437101884-2081-2-git-send-email-ast@plumgrid.com>
 <1437120738.1026.16.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Michael Holzheu <holzheu@linux.vnet.ibm.com>,
	Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35668 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753765AbbGQSRg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Jul 2015 14:17:36 -0400
Received: by pactm7 with SMTP id tm7so65053990pac.2
        for <netdev@vger.kernel.org>; Fri, 17 Jul 2015 11:17:35 -0700 (PDT)
In-Reply-To: <1437120738.1026.16.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 7/17/15 1:12 AM, Eric Dumazet wrote:
> On Thu, 2015-07-16 at 19:58 -0700, Alexei Starovoitov wrote:
>> In order to let eBPF programs call skb_vlan_push/pop via helper functions
>
> Why should eBPF program do such thing ?
>
> Are BPF users in the kernel expecting skb being changed, and are we sure
> they reload all cached values when/if needed ?

well, classic BPF and even extended BPF with socket filters cannot use
these helpers. They are for TC ingress/egress only. There different
actions can already change skb->data while classifiers/actions are
running. btw, before we started discussing this topic at nfws,
I thought that bpf programs will never be able to change skb->data from
inside the programs, but turned out it's only JITs that needed
re-caching. Programs cannot see skb->data. They can access packet
only via ld_abs/ld_ind instructions and helper functions.
So any changes to internal fields of skb are invisible to programs.
skb->data/hlen cache that is part of JIT is also invisible to the
programs. It's an optimization that some JITs do. arm64 JIT doesn't
do this optimization, for example.
I'll reword commit log to better explain this.

One of the use cases is this phys2virt gateway I presented. There I
need to do vlan-learning and src mac forwarding. Currently I'm
creating as many as I can vlan netdevs on top of regular eth0
and attach tc+bpf to all of them. That's very inefficient.
With these helpers I'll attach tc+bpf to eth0 only and skip creation
of thousands of vlan netdevs.

>> eBPF JITs need to recognize helpers that change skb->data, since
>> skb->data and hlen are cached as part of JIT code generation.
>> - arm64 JIT is using bpf_load_pointer() without caching, so it's ok as-is.
>> - x64 JIT recognizes bpf_skb_vlan_push/pop() calls and re-caches skb->data/hlen
>>    after such calls (experiments showed that conditional re-caching is slower).
>> - s390 JIT falls back to interpreter for now when bpf_skb_vlan_push() is present
>>    in the program (re-caching is tbd).
>
>
>
>> +static u64 bpf_skb_vlan_push(u64 r1, u64 vlan_proto, u64 vlan_tci, u64 r4, u64 r5)
>> +{
>> +	struct sk_buff *skb = (struct sk_buff *) (long) r1;
>> +
>> +	if (unlikely(vlan_proto != htons(ETH_P_8021Q) &&
>> +		     vlan_proto != htons(ETH_P_8021AD)))
>> +		vlan_proto = htons(ETH_P_8021Q);
>
>
> This would raise sparse error, as vlan_proto is u64, and htons() __be16
>
> make C=2 CF=-D__CHECK_ENDIAN__ net/core/filter.o

yes.
When I wrote these lines I thought of the same, so I did run the sparse
and it spewed a lot of false positives and stopped on 'too many errors'
before reaching these lines.
So I downloaded the latest sparse, hacked it a little and tried again.
Still it didn't complain about the endianness. That was puzzling,
so I left the above lines as-is.
but since your eagle eyes caught it, I will add casts :)
