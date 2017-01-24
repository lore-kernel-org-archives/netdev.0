From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 19:37:50 -0800
Message-ID: <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com> <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:36852 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXDiM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 22:38:12 -0500
Received: by mail-ua0-f173.google.com with SMTP id 96so125180252uaq.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 19:38:12 -0800 (PST)
In-Reply-To: <20170124031259.GA81720@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 7:13 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Mon, Jan 23, 2017 at 06:42:27PM -0800, Andy Lutomirski wrote:
>> Please explain how the change results in a broken ABI and how the
>> current ABI is better.  I gave a fully worked out example of how the
>> current ABI misbehaves using only standard Linux networking tools.
>
> I gave an example in the other thread that demonstrated
> cgroup escape by the appliction when it changes netns.
> If application became part of cgroup, it has to stay there,
> no matter setns() calls afterwards.

The other thread is out of control.  Can you restate your example?
Please keep in mind that uprivileged programs can unshare their netns.

>
>> >
>> >> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
>> >> index e89acea22ecf..c0bbc55e244d 100644
>> >> --- a/kernel/bpf/syscall.c
>> >> +++ b/kernel/bpf/syscall.c
>> >> @@ -902,6 +902,17 @@ static int bpf_prog_attach(const union bpf_attr *attr)
>> >>       struct cgroup *cgrp;
>> >>       enum bpf_prog_type ptype;
>> >>
>> >> +     /*
>> >> +      * For now, socket bpf hooks attached to cgroups can only be
>> >> +      * installed in the init netns and only affect the init netns.
>> >> +      * This could be relaxed in the future once some semantic issues
>> >> +      * are resolved.  For example, ifindexes belonging to one netns
>> >> +      * should probably not be visible to hooks installed by programs
>> >> +      * running in a different netns.
>> >
>> > the comment is bogus and shows complete lack of understanding
>> > how bpf is working and how it's being used.
>> > See SKF_AD_IFINDEX that was in classic bpf forever.
>> >
>>
>> I think I disagree completely.
>>
>> With classic BPF, a program creates a socket and binds a bpf program
>> to it.  That program can see the ifindex, which is fine because that
>> ifindex is scoped to the socket's netns, which is (unless the caller
>> uses setns() or unshare()) the same as the caller's netns, so the
>> ifindex means exactly what the caller thinks it means.
>>
>> With cgroup+bpf, the program installing the hook can be completely
>> unrelated to the program whose sockets are subject to the hook, and,
>> if they're using different namespaces, it breaks.
>
> Please also see ingress_ifindex, ifindex, bpf_redirect(), bpf_clone_redirect()
> that all operate on the ifindex while the program can be detached from
> the application. In general bpf program and application that loaded and
> attached it are mostly disjoint in case of networking. We have tail_call
> mechanism and master bpf prog may call programs installed by other apps
> that may have exited already.

If program A acquires a BPF object from program B where program B runs
in a different netns from program A, and program B uses or tail-calls
that BPF object, then A is either doing it intentionally and is
netns-aware or it is terminally buggy and deserves what it gets.

> cls_bpf is scoped by netdev that belongs to some netns.
> If after attaching a program with hardcoded if(ifindex==3) check
> to such netdev, this netdev is moved into different netns, this 'if' check
> and the program become bogus and won't do what program author
> expected. It is expected behavior. The same thing with current 'ip vrf'
> implementation that Dave is adjusting. It's not a bug in cgroup+bpf behavior.
>

Yes, it is a bug because cgroup+bpf causes unwitting programs to be
subject to BPF code installed by a different, potentially unrelated
process.  That's a new situation.  The failure can happen when a
privileged supervisor (whoever runs ip vrf) runs a clueless or
unprivileged program (the thing calling unshare()).

If the way cgroup+bpf worked was that a program did a prctl() or
similar to opt in to being managed by a provided cgroup-aware BPF
program, then I'd agree with everything you're saying.  But that's not
at all how this code works.
