From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH RFC 1/3] xdp: Infrastructure to generalize XDP
Date: Wed, 21 Sep 2016 13:55:45 +0200
Message-ID: <20160921115545.GA12789@pox.localdomain>
References: <1474408824-418864-1-git-send-email-tom@herbertland.com>
 <1474408824-418864-2-git-send-email-tom@herbertland.com>
 <20160920224416.GF3291@pox.localdomain>
 <CALx6S36FVU7bNu3JudZuET-VdFND2ZO7n9A7k--qsZVyxTvcpQ@mail.gmail.com>
 <20160920230927.GG3291@pox.localdomain>
 <CALx6S37oniKp1JOeiygzr0RiQojj651ONqBgyvcJvqHj5-aT5g@mail.gmail.com>
 <20160920234347.GH3291@pox.localdomain>
 <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Tariq Toukan <tariqt@mellanox.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:37249 "EHLO
        mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932641AbcIULzs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 07:55:48 -0400
Received: by mail-wm0-f51.google.com with SMTP id b130so87465295wmc.0
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 04:55:47 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALx6S35LmUtwRA85Kg6s7OR=e5Pj9ssqmWLsjtmXfZTXeG02zQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/20/16 at 04:59pm, Tom Herbert wrote:
> Well, need to measure to ascertain the cost. As for complexity, this
> actually reduces complexity needed for XDP in the drivers which is a
> good thing because that's where most of the support and development
> pain will be.

I'm not objecting to anything that simplifies the process of adding
XDP capability to drivers. You have my full support here.

> I am looking at using this for ILA router. The problem I am hitting is
> that not all packets that we need to translate go through the XDP
> path. Some would go through the kernel path, some through XDP path but

When you say kernel path, what do you mean specifically? One aspect of
XDP I love is that XDP can act as an acceleration option for existing
BPF programs attached to cls_bpf. Support for direct packet read and
write at clsact level have made it straight forward to write programs
which are compatible or at minimum share a lot of common code. They
can share data structures, lookup functionality, etc.

> We can optimize for allowing only one hook, or maybe limit to only
> allowing one hook to be set. In any case this obviously requires a lot
> of performance evaluation, I am hoping to feedback on the design
> first. My question about using a linear list for this was real, do you
> know a better method off hand to implement a call list?

My main concern is that we overload the XDP hook. Instead of making use
of the programmable glue, we put a linked list in front where everybody
can attach a program to.

A possible alternative:
 1. The XDP hook always has single consumer controlled by the user
    through Netlink, BPF is one of them. If a user wants to hardcode
    the ILA router to that hook, he can do that.

 2. BPF for XDP is extended to allow returning a verdict which results
    in something else to be invoked. If user wants to invoke the ILA
    router for just some packets, he can do that.

That said, I see so much value in a BPF implementation of ILA at XDP
level with all of the parsing logic and exact semantics remain
flexible without the cost of translating some configuration to a set
of actions.
