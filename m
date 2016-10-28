From: Daniel Mack <daniel@zonque.org>
Subject: Re: [PATCH v7 0/6] Add eBPF hooks for cgroups
Date: Fri, 28 Oct 2016 14:07:13 +0200
Message-ID: <b7f9cfb7-129b-afaa-8d56-47bc4ee65363@zonque.org>
References: <1477390454-12553-1-git-send-email-daniel@zonque.org>
 <20161026195933.GA2031@salvia>
 <c9683122-d770-355b-e275-7c446e6d1d0f@zonque.org>
 <20161028115311.GB29798@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: htejun@fb.com, daniel@iogearbox.net, ast@fb.com,
        davem@davemloft.net, kafai@fb.com, fw@strlen.de, harald@redhat.com,
        netdev@vger.kernel.org, sargun@sargun.me, cgroups@vger.kernel.org
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from svenfoo.org ([82.94.215.22]:47620 "EHLO mail.zonque.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756575AbcJ1MHS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Oct 2016 08:07:18 -0400
In-Reply-To: <20161028115311.GB29798@salvia>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/28/2016 01:53 PM, Pablo Neira Ayuso wrote:
> On Thu, Oct 27, 2016 at 10:40:14AM +0200, Daniel Mack wrote:

>> It's not anything new. These hooks live on the very same level as
>> SO_ATTACH_FILTER. The only differences are that the BPF programs are
>> stored in the cgroup, and not in the socket, and that they exist for
>> egress as well.
> 
> Can we agree this is going further than SO_ATTACH_FILTER?

It's the same level. Only the way of setting the program(s) is different.

>> Adding it there would mean we need to early-demux *every* packet as soon
>> as there is *any* such rule installed, and that renders many
>> optimizations in the kernel to drop traffic that has no local receiver
>> useless.
> 
> I think such concern applies to doing early demux inconditionally in
> all possible scenarios (such as UDP broadcast/multicast), that implies
> wasted cycles for people not requiring this.

If you have a rule that acts on a condition based on a local receiver
detail such as a cgroup membership, then the INPUT filter *must* know
the local receiver for *all* packets passing by, otherwise it cannot act
upon it. And that means that you have to early-demux in any case as long
as at least one such a rule exists.

> If we can do what demuxing in an optional way, ie. only when socket
> filtering is required, then only those that need it would pay that
> price. Actually, if we can do this demux very early, from ingress,
> performance numbers would be also good to perform any socket-based
> filtering.

For multicast, rules have to be executed for each receiver, which is
another reason why the INPUT path is the wrong place to solve to problem.

You actually convinced me yourself about these details, but you seem to
constantly change your opinion about all this. Why is this such a
whack-a-mole game?

> I guess you're using an old kernel and refering to iptables, this is
> not true for some time, so we don't have any impact now with loaded
> iptables modules.

My point is that the performance decrease introduced by my patch set is
not really measurable, even if you pipe all the wire-saturating test
traffic through the example program. At least not with my setup here. If
a local receiver has no applicable bpf in its cgroup, the logic bails
out way earlier, leading a lot less overhead even. And if no cgroup has
any program attached, the code is basically no-op thanks to the static
branch. I really see no reason to block this patch set due to unfounded
claims of bad performance.


Thanks,
Daniel
