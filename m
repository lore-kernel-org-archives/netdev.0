From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v6 5/6] net: ipv4, ipv6: run cgroup eBPF egress programs
Date: Thu, 22 Sep 2016 17:12:57 +0200
Message-ID: <57E3F4F9.70300@iogearbox.net>
References: <20160919191910.GA984@salvia> <ac88bb4c-ab7c-1f74-c7fd-79e523b50ae4@zonque.org> <20160919203533.GA888@salvia> <83afdc54-1bbe-3530-e5fd-b74fefe9a042@zonque.org> <20160920142931.GA31438@salvia> <6584b975-fa3e-8d98-f0c7-a2c6b194b2b6@zonque.org> <20160921154533.GA13656@salvia> <20160921184827.GA15732@pox.localdomain> <20160922092138.GA12108@salvia> <20160922095411.GA5654@pox.localdomain> <20160922120554.GA1738@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Mack <daniel@zonque.org>, htejun@fb.com, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>,
        Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47165 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933377AbcIVPNO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 22 Sep 2016 11:13:14 -0400
In-Reply-To: <20160922120554.GA1738@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/22/2016 02:05 PM, Pablo Neira Ayuso wrote:
> On Thu, Sep 22, 2016 at 11:54:11AM +0200, Thomas Graf wrote:
>> On 09/22/16 at 11:21am, Pablo Neira Ayuso wrote:
>>> I have a hard time to buy this new specific hook, I think we should
>>> shift focus of this debate, this is my proposal to untangle this:
>>>
>>> You add a net/netfilter/nft_bpf.c expression that allows you to run
>>> bpf programs from nf_tables. This expression can either run bpf
>>> programs in a similar fashion to tc+bpf or run the bpf program that
>>> you have attached to the cgroup.
>>
>> So for every packet processed, you want to require the user to load
>> and run a (unJITed) nft program acting as a wrapper to run a JITed
>> BPF program? What it the benefit of this model compared to what Daniel
>> is proposing? The hooking point is the same. This only introduces
>> additional per packet overhead in the fast path. Am I missing
>> something?
>
> Have a look at net/ipv4/netfilter/nft_chain_route_ipv4.c for instance.
> In your case, you have to add a new chain type:
>
> static const struct nf_chain_type nft_chain_bpf = {
>          .name           = "bpf",
>          .type           = NFT_CHAIN_T_BPF,
>          ...
>          .hooks          = {
>                  [NF_INET_LOCAL_IN]      = nft_do_bpf,
>                  [NF_INET_LOCAL_OUT]     = nft_do_bpf,
>                  [NF_INET_FORWARD]       = nft_do_bpf,
>                  [NF_INET_PRE_ROUTING]   = nft_do_bpf,
>                  [NF_INET_POST_ROUTING]  = nft_do_bpf,
>          },
> };
>
> nft_do_bpf() is the raw netfilter hook that you register, this hook
> will just execute to iterate over the list of bpf filters and run
> them.
>
> This new chain is created on demand, so no overhead if not needed, eg.
>
> nft add table bpf
> nft add chain bpf input { type bpf hook output priority 0\; }
>
> Then, you add a rule for each bpf program you want to run, just like
> tc+bpf.

But from a high-level point of view, this sounds like a huge hack to me,
in the sense that nft as a bytecode engine (from whole architecture I
mean) calls into another bytecode engine such as BPF as an extension. And
BPF code from there isn't using any of the features from nft besides being
invoked from the hook, yet it needs to be a hard dependency to be compiled
into the kernel when the only thing that is needed is to just load and
execute a BPF program that can do already everything needed by itself.

Also, if we look at history, at times such tings have been tried in the
past - just take tc calling into iptables as an example - I get goosebumps
(and probably you as well ;)), as the result looks worse than it would
have looked like when it would have been just kept separated.
I don't quite understand this detour, I mean, I would understand it when
the idea is that nft is using BPF as an intermediate to make use of all
the already existing JIT/offloading features that have been developed over
the years to not duplicate all the work for arch folks, but off-topic
in this discussion context here. I was hoping that nft would try to avoid
some of those exotic modules we have from xt, I would consider xt_bpf (no
offense ;)) as one of them; in the sense that in the context/model back
then of xt it made sense as most xt modules were kind of hard-coded, but
that was overcome with nft itself. So I'm not really keen on nft_bpf
idea besides that it also doesn't use anything else other than the hooks
themselves for what is proposed. Really, both are two different worlds
with different programming models and use-cases and it doesn't really make
sense to brute-force them together.

> Benefits are, rewording previous email:
>
> * You get access to all of the existing netfilter hooks in one go
>    to run bpf programs. No need for specific redundant hooks. This
>    provides raw access to the netfilter hook, you define the little
>    code that your hook runs before you bpf run invocation. So there
>    is *no need to bloat the stack with more hooks, we use what we
>    have.*

But also this doesn't really address the fundamental underlying problem
that is discussed here. nft doesn't even have cgroups v2 support, only
xt_cgroups has it so far, but even if it would have it, then it's still
a scalability issue that this model has over what is being proposed by
Daniel, since you still need to test linearly wrt cgroups v2 membership,
whereas in the set that is proposed it's integral part of cgroups and can
be extended further, also for non-networking users to use this facility.
Or would the idea be that the current netfilter hooks would be redone in
a way that they are generic enough so that any other user could make use
of it independent of netfilter?

Thanks,
Daniel
