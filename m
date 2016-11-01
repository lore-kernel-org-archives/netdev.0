From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH net-next v2 0/5] bpf: BPF for lightweight tunnel encapsulation
Date: Tue, 1 Nov 2016 11:51:44 -0700
Message-ID: <CACby=pmK9Pj00LYx9PQrgWe95xmy=qFhpjSYZT=QDnLQ55J=8w@mail.gmail.com>
References: <cover.1477959702.git.tgraf@suug.ch> <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Tom Herbert <tom@herbertland.com>,
        roopa <roopa@cumulusnetworks.com>,
        netdev <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f49.google.com ([209.85.213.49]:33923 "EHLO
        mail-vk0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752427AbcKASvq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 1 Nov 2016 14:51:46 -0400
Received: by mail-vk0-f49.google.com with SMTP id x186so78421656vkd.1
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2016 11:51:45 -0700 (PDT)
In-Reply-To: <c220b6b2-3f20-09ff-2068-6ecfe0b47b9e@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1 November 2016 at 03:54, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> I do fear the complexity and debugability introduced by this patch set
> quite a bit.

What is the complexity concern? This is pretty straight forward. I
agree on debugability. This is being worked on separately as Alexei
mentioned, to address this for all BPF integrations.

> I wonder if architecturally it would be more feasible to add a generic
> (bfp-)hook into into dst_output(_sk) and allow arbitrary metadata to be
> added into the dsts.
>
> BPF could then be able to access parts of the metadata in the attached
> metadata dst entries and performing the matching this way?

If I understand you correctly then a single BPF program would be
loaded which then applies to all dst_output() calls? This has a huge
drawback, instead of multiple small BPF programs which do exactly what
is required per dst, a large BPF program is needed which matches on
metadata. That's way slower and renders one of the biggest advantages
of BPF invalid, the ability to generate a a small program tailored to
a particular use. See Cilium.

> The reason why I would prefer an approach like this: irregardless of the
> routing lookup we would process the skb with bpf or not. This gives a
> single point to debug, where instead in your approach we first must
> figure out the corresponding bpf program and then check for it specifically.

Not sure I see what kind of advantage this actually provides. You can
dump the routes and see which programs get invoked and which section.
If it's based on metadata then you need to know the program logic and
associate it with the metadata in the dst. It actually doesn't get
much easier than to debug one of the samples, they are completely
static once compiled and it's very simple to verify if they do what
they are supposed to do.

If you like the single program approach, feel free to load the same
program for every dst. Perfectly acceptable but I don't see why we
should force everybody to use that model.
