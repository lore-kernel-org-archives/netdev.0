From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 07:19:52 -0700
Message-ID: <CALx6S35Xctd-aA8DF1_vypMDejiGXcud6=UO33dqgvO60W0DZQ@mail.gmail.com>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com> <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
 <20160920230927.GG3291@pox.localdomain> <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
 <20160920234347.GH3291@pox.localdomain> <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
 <20160921115545.GA12789@pox.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f178.google.com ([209.85.216.178]:33000 "EHLO
        mail-qt0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751449AbcIUOTy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 10:19:54 -0400
Received: by mail-qt0-f178.google.com with SMTP id 11so23058193qtc.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 07:19:53 -0700 (PDT)
In-Reply-To: <20160921115545.GA12789@pox.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 21, 2016 at 4:55 AM, Thomas Graf <tgraf@suug.ch> wrote:
> On 09/20/16 at 04:59pm, Tom Herbert wrote:
>> Well, need to measure to ascertain the cost. As for complexity, this
>> actually reduces complexity needed for XDP in the drivers which is a
>> good thing because that's where most of the support and development
>> pain will be.
>
> I'm not objecting to anything that simplifies the process of adding
> XDP capability to drivers. You have my full support here.
>
>> I am looking at using this for ILA router. The problem I am hitting is
>> that not all packets that we need to translate go through the XDP
>> path. Some would go through the kernel path, some through XDP path but
>
> When you say kernel path, what do you mean specifically? One aspect of
> XDP I love is that XDP can act as an acceleration option for existing
> BPF programs attached to cls_bpf. Support for direct packet read and
> write at clsact level have made it straight forward to write programs
> which are compatible or at minimum share a lot of common code. They
> can share data structures, lookup functionality, etc.
>
>> We can optimize for allowing only one hook, or maybe limit to only
>> allowing one hook to be set. In any case this obviously requires a lot
>> of performance evaluation, I am hoping to feedback on the design
>> first. My question about using a linear list for this was real, do you
>> know a better method off hand to implement a call list?
>
> My main concern is that we overload the XDP hook. Instead of making use
> of the programmable glue, we put a linked list in front where everybody
> can attach a program to.
>
> A possible alternative:
>  1. The XDP hook always has single consumer controlled by the user
>     through Netlink, BPF is one of them. If a user wants to hardcode
>     the ILA router to that hook, he can do that.
>
>  2. BPF for XDP is extended to allow returning a verdict which results
>     in something else to be invoked. If user wants to invoke the ILA
>     router for just some packets, he can do that.
>
> That said, I see so much value in a BPF implementation of ILA at XDP
> level with all of the parsing logic and exact semantics remain
> flexible without the cost of translating some configuration to a set
> of actions.

Thomas,

As I mentioned though, not all packets we need to translate are going
to go through XDP. ILA already integrates with the routing table via
LWT and that solution works incredibly well especially when we are
sourcing connections (ILA is by far the fastest most efficient
technique of network virtualization). We already have a lookup table
and the translation process coded in the kernel and configuration is
already implemented by netlink and iproute. So I'm not yet sure I want
to redesign all of this around BPF, maybe that is the right answer
maybe it isn't; but, my point is I don't want to be _forced_ into a
certain design that because of constraints on one kernel interface. As
a kernel developer I want flexibility on how we design and implement
things!

I think there are two questions that this patch set poses for the
community wrt XDP:

#1: Should we allow alternate code to run in XDP other than BPF?
#2: If #1 is true what is the best way to implement that?

If the answer to #1 is "no" then the answer to #2 is irrelevant. So
with this RFC I'm hoping we can come the agreement on questions #1.

IMO, there are at least three factors that would motivate the answer
to #1 be yes

1) There is precedence in nfhooks in creating generic hooks in the
critical data path that can have other uses than those originally
intended by the authors. I would take it as general principle that
hooks in the data path should be as generic as possible to get the
most utility.
2) The changes to make XDP work in drivers are quite invasive and as
we've seen in at least one attempt to modify a driver to support XDP
it is easy to break other mechanisms. If we're going to be modifying a
lot of drivers we really want to get the most value for that work.
3) The XDP interface is well designed and really has no dependencies
on BPF. Writing code to directly parse packets is not rocket science.
So it seems reasonable to me that a subsystem may want to use XDP
interface to accelerate existing functionality without introducing
additional dependencies on BPF or other non-kernel mechanisms

In any case, I ask everyone to be open minded. If there is agreement
that BPF is sufficient for all XDP use cases then I wont' pursue these
patches. But given the ramifications of XDP, especially the
considering the changes required across drivers to support it, I
really would like to get input from the community on this.

Thanks,
Tom
