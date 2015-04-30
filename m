From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [PATCH 6/6] net: move qdisc ingress filtering on top of netfilter
 ingress hooks
Date: Wed, 29 Apr 2015 22:22:49 -0400
Message-ID: <554191F9.3010301@mojatatu.com>
References: <1430333589-4940-1-git-send-email-pablo@netfilter.org> <1430333589-4940-7-git-send-email-pablo@netfilter.org> <55413E99.5000807@iogearbox.net> <20150429233205.GA3416@salvia> <55417545.30103@iogearbox.net> <20150430003019.GE7025@acer.localdomain> <55417A3A.50405@iogearbox.net> <20150430004839.GG7025@acer.localdomain> <20150430011633.GA12674@Alexeis-MBP.westell.com> <20150430013452.GA7956@acer.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20150430013452.GA7956@acer.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/29/15 21:34, Patrick McHardy wrote:
> On 29.04, Alexei Starovoitov wrote:
>> On Thu, Apr 30, 2015 at 02:48:39AM +0200, Patrick McHardy wrote:
[..]
>>
>>> 840203pps 403Mb/sec
>>
>> this is 20 times less than what they should be.
>> Something else were measured together with netif_receive_skb.
>>
>> I've applied these patches and see the following
>> for eth0 + ingress + u32:
>>
>> 18.0 Mpps

[..]

>> without these patches:
>>
>> 22.4 Mpps
>>    25.89%  kpktgend_0   [kernel.vmlinux]  [k] __netif_receive_skb_core
>>    14.41%  kpktgend_0   [kernel.vmlinux]  [k] kfree_skb
>>    14.05%  kpktgend_0   [kernel.vmlinux]  [k] _raw_spin_lock
>>    11.75%  kpktgend_0   [cls_u32]         [k] u32_classify
>>     6.48%  kpktgend_0   [sch_ingress]     [k] ingress_enqueue
>>     6.06%  kpktgend_0   [kernel.vmlinux]  [k] tc_classify_compat
>>     4.16%  kpktgend_0   [kernel.vmlinux]  [k] tc_classify
>>     3.77%  kpktgend_0   [kernel.vmlinux]  [k] ip_rcv
>>
>> clearly nf_iterate/nf_hook_slow are slowing things down.
>>
>> I've spent more than a week trying to speedup ingress qdisc
>> and, so far, got from 22.4 Mpps to 27.2 Mpps,
>> so this 'generalization' is totally not acceptable to me.
>>
>> You're right that for 10 years no one cared about performance
>> of ingress qdisc, but that doesn't mean it's a wrong abstraction
>> and wrong architecture. Now I care about its performance and
>> I hope other people will do too.
>

Well, even if you didnt touch tc and got rid of the lock
it will still be about a magnitude faster than netfilter ;->
How about i call netfilter crap Patrick? It is slower than
molasses. For more than 10+ years no-one has found good ways
to bring it up to speed.

For sure the attempt to re-use netfilter code from tc has failed.
I think thats what you keep probably repeating as something that will
crash. Apart from some help from Pablo in recent times - this re-use
has been a disaster even when linking in user space (from lack of
backward incompatibilities mostly).
It seems to me we may just have to drop support for ipt and anything
netfilter from tc.
And at some point we are going to need those features, we'll just need
to write faster versions of them. ebpf maybe helpful.

> The wrong abstraction is using a qdisc for ingress. An abstraction
> is not about performance. Why do you thing ingress exists? For
> queueing? Or as providing a hooking point for a bunch of broken
> (at ingress) actions? You're (one of) the one who painfully realized
> how broken any kind of packet mangling at that point is. The
> infrastructure is simply crap and always has been.
>

What abstraction is broken? The ingress expects L3 headers. The egress
expects L2 headers. I dont think there is disagreement that the ingress
should see L2 headers. The view is that it will be a bit of work.
Discussion is ongoing to resolve this without penalizing performance.
You dont care about performance - netfilter is all about how to have
nice usability. I care about usability but not as much as i do
about performance.

>> So please leave ingress qdisc alone, this 'generalization'
>> is too costly.
>
> Sorry, we are of the opinion that TC classifiers suck, so we will
> not leave that path alone :) You're numbers are well appreciated,
> we will fix this and return with better numbers.
>
>> That doesn't mean that netfilter shouldn't have its own hook
>> on ingress. Without patch 6, the set looks good.
>
> I don't agree. It would be preferable to optimize the single hook
> case not only for ingress's sake, but for all the already existing
> hooks.
>

And i strongly disagree. Netfilter is slow as a boring hot day.
Please dont enforce it on us. I thought you were kidding when you said
you want to move the ingress back to netfilter. We run away from there
years ago.

cheers,
jamal


