From: Tom Herbert <tom@herbertland.com>
Subject: Re: [net-next PATCH v3 2/3] e1000: add initial XDP support
Date: Tue, 13 Sep 2016 10:55:00 -0700
Message-ID: <CALx6S36Vrmcv23Q0fZxK4gO5bz8nVH5DSyQwbe_E6DQrr8AB=Q@mail.gmail.com>
References: <20160912220312.5610.77528.stgit@john-Precision-Tower-5810>
 <20160912221351.5610.29043.stgit@john-Precision-Tower-5810>
 <1473720399.18970.91.camel@edumazet-glaptop3.roam.corp.google.com>
 <20160912230745.GA24171@ast-mbp.thefacebook.com> <1473723968.18970.111.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S35CE+ZYbGm96Y5YKnTqU0zfhg9_h0VSpD3ot8xB-scdFQ@mail.gmail.com>
 <20160913012815.GB25756@ast-mbp.thefacebook.com> <CALx6S36u+tQUEVhu0BaLZ6-_0=GSMwxd4m89-H+brVZ-rr-U2g@mail.gmail.com>
 <20160913171340.GA37341@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        "David S. Miller" <davem@davemloft.net>,
        Cong Wang <xiyou.wangcong@gmail.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        William Tu <u9012063@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f177.google.com ([209.85.220.177]:34142 "EHLO
        mail-qk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755300AbcIMRzC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Sep 2016 13:55:02 -0400
Received: by mail-qk0-f177.google.com with SMTP id h8so95524868qka.1
        for <netdev@vger.kernel.org>; Tue, 13 Sep 2016 10:55:01 -0700 (PDT)
In-Reply-To: <20160913171340.GA37341@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 13, 2016 at 10:13 AM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Tue, Sep 13, 2016 at 09:21:47AM -0700, Tom Herbert wrote:
>> On Mon, Sep 12, 2016 at 6:28 PM, Alexei Starovoitov
>> <alexei.starovoitov@gmail.com> wrote:
>> > On Mon, Sep 12, 2016 at 05:03:25PM -0700, Tom Herbert wrote:
>> >> On Mon, Sep 12, 2016 at 4:46 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>> >> > On Mon, 2016-09-12 at 16:07 -0700, Alexei Starovoitov wrote:
>> >> >
>> >> >> yep. there are various ways to shoot yourself in the foot with xdp.
>> >> >> The simplest program that drops all the packets will make the box unpingable.
>> >> >
>> >> > Well, my comment was about XDP_TX only, not about XDP_DROP or driving a
>> >> > scooter on 101 highway ;)
>> >> >
>> >> > This XDP_TX thing was one of the XDP marketing stuff, but there is
>> >> > absolutely no documentation on it, warning users about possible
>> >> > limitations/outcomes.
>> >> >
>> >> > BTW, I am not sure mlx4 implementation even works, vs BQL :
>> >> >
>> >> > mlx4_en_xmit_frame() does not call netdev_tx_sent_queue(),
>> >> > but tx completion will call netdev_tx_completed_queue() -> crash
>> >> >
>> >> > Do we have one test to validate that a XDP_TX implementation is actually
>> >> > correct ?
>> >> >
>> >> Obviously not for e1000 :-(. We really need some real test and
>> >> performance results and analysis on the interaction between the stack
>> >> data path and XDP data path.
>> >
>> > no. we don't need it for e1k and we cannot really do it.
>> > <broken record mode on> this patch is for debugging of xdp programs only.
>> >
>> You can say this "only for a debugging" a thousand times and that
>> still won't justify putting bad code into the kernel. Material issues
>> have been raised with these patches, I have proposed a fix for one
>> core issue, and we have requested a lot more testing. So, please, if
>> you really want to move these patches forward start addressing the
>> concerns being raised by reviewers.
>
> I'm afraid the point 'only for debugging' still didn't make it across.
> xdp+e1k is for development (and debugging) of xdp-type of bpf
> programs and _not_ for debugging of xdp itself, kernel or anything else.
> The e1k provided interfaces and behavior needs to match exactly
> what real hw nics (like mlx4, mlx5, igxbe, i40e) will do.
> Doing special hacks are not acceptable. Therefore your
> 'proposed fix' misses the mark, since:
> 1. ignoring bql/qdisc is not a bug, but the requirement

You don't seem to understand the problem. In the shared queue scenario
if one party (the stack) implements qdiscs, BQL, and such and the
other (XDP) just throws packets onto the queue then these are
incompatible behaviors and something will break. I suppose it's
possible that some how this does not affect the stack path, but
remains to be proven. In any case the patches under review look very
much like they break things; either a fix is needed or tests run to
show it's not a problem. Until this is resolved I am going to nack the
patch.

Tom

> 2. such 'fix' goes against the goal above since behaviors will be
> different and xdp developer won't be able to build something like
> xdp loadbalancer in the kvm.
>
> If you have other concerns please raise them or if you have
> suggestions on how to develop xdp programs without this e1k patch
> I would love hear them.
> Alexander's review comments are discussed in separate thread.
>
