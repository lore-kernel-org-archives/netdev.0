From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Mon, 23 Jan 2017 19:13:01 -0800
Message-ID: <20170124031259.GA81720@ast-mbp.thefacebook.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>,
        David Ahern <dsa@cumulusnetworks.com>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36522 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750703AbdAXDNH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 22:13:07 -0500
Received: by mail-pg0-f66.google.com with SMTP id 75so15304299pgf.3
        for <netdev@vger.kernel.org>; Mon, 23 Jan 2017 19:13:06 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 06:42:27PM -0800, Andy Lutomirski wrote:
> On Mon, Jan 23, 2017 at 6:09 PM, Alexei Starovoitov
> <alexei.starovoitov@gmail.com> wrote:
> > On Mon, Jan 23, 2017 at 12:36:08PM -0800, Andy Lutomirski wrote:
> >> To see how cgroup+bpf interacts with network namespaces, I wrote a
> >> little program called show_bind that calls getsockopt(...,
> >> SO_BINDTODEVICE, ...) and prints the result.  It did this:
> >>
> >>  # ./ip link add dev vrf0 type vrf table 10
> >>  # ./ip vrf exec vrf0 ./show_bind
> >>  Default binding is "vrf0"
> >>  # ./ip vrf exec vrf0 unshare -n ./show_bind
> >>  show_bind: getsockopt: No such device
> >>
> >> What's happening here is that "ip vrf" looks up vrf0's ifindex in
> >> the init netns and installs a hook that binds sockets to that
> >> ifindex.  When the hook runs in a different netns, it sets
> >> sk_bound_dev_if to an ifindex from the wrong netns, resulting in
> >> incorrect behavior.  In this particular example, the ifindex was 4
> >> and there was no ifindex 4 in the new netns.  If there had been,
> >> this test would have malfunctioned differently
> >>
> >> Since it's rather late in the release cycle, let's punt.  This patch
> >> makes it impossible to install cgroup+bpf hooks outside the init
> >> netns and makes them not run on sockets that aren't in the init
> >> netns.
> >>
> >> In a future release, it should be relatively straightforward to make
> >> these hooks be local to a netns and, if needed, to add a flag so
> >> that hooks can be made global if necessary.  Global hooks should
> >> presumably be constrained so that they can't write to any ifindex
> >> fields.
> >>
> >> Cc: Daniel Borkmann <daniel@iogearbox.net>
> >> Cc: Alexei Starovoitov <ast@kernel.org>
> >> Cc: David Ahern <dsa@cumulusnetworks.com>
> >> Signed-off-by: Andy Lutomirski <luto@kernel.org>
> >> ---
> >>
> >> DaveM, this mitigates a bug in a feature that's new in 4.10, and the
> >> bug can be hit using current iproute2 -git.  please consider this for
> >> -net.
> >>
> >> Changes from v1:
> >>  - Fix the commit message.  'git commit' was very clever and thought that
> >>    all the interesting bits of the test case were intended to be comments
> >>    and stripped them.  Whoops!
> >>
> >> kernel/bpf/cgroup.c  | 21 +++++++++++++++++++++
> >>  kernel/bpf/syscall.c | 11 +++++++++++
> >>  2 files changed, 32 insertions(+)
> >>
> >> diff --git a/kernel/bpf/cgroup.c b/kernel/bpf/cgroup.c
> >> index a515f7b007c6..a824f543de69 100644
> >> --- a/kernel/bpf/cgroup.c
> >> +++ b/kernel/bpf/cgroup.c
> >> @@ -143,6 +143,17 @@ int __cgroup_bpf_run_filter_skb(struct sock *sk,
> >>       if (!sk || !sk_fullsock(sk))
> >>               return 0;
> >>
> >> +     /*
> >> +      * For now, socket bpf hooks attached to cgroups can only be
> >> +      * installed in the init netns and only affect the init netns.
> >> +      * This could be relaxed in the future once some semantic issues
> >> +      * are resolved.  For example, ifindexes belonging to one netns
> >> +      * should probably not be visible to hooks installed by programs
> >> +      * running in a different netns.
> >> +      */
> >> +     if (sock_net(sk) != &init_net)
> >> +             return 0;
> >
> > Nack.
> > Such check will create absolutely broken abi that we won't be able to fix later.
> 
> Please explain how the change results in a broken ABI and how the
> current ABI is better.  I gave a fully worked out example of how the
> current ABI misbehaves using only standard Linux networking tools.

I gave an example in the other thread that demonstrated
cgroup escape by the appliction when it changes netns.
If application became part of cgroup, it has to stay there,
no matter setns() calls afterwards.

> >
> >> diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
> >> index e89acea22ecf..c0bbc55e244d 100644
> >> --- a/kernel/bpf/syscall.c
> >> +++ b/kernel/bpf/syscall.c
> >> @@ -902,6 +902,17 @@ static int bpf_prog_attach(const union bpf_attr *attr)
> >>       struct cgroup *cgrp;
> >>       enum bpf_prog_type ptype;
> >>
> >> +     /*
> >> +      * For now, socket bpf hooks attached to cgroups can only be
> >> +      * installed in the init netns and only affect the init netns.
> >> +      * This could be relaxed in the future once some semantic issues
> >> +      * are resolved.  For example, ifindexes belonging to one netns
> >> +      * should probably not be visible to hooks installed by programs
> >> +      * running in a different netns.
> >
> > the comment is bogus and shows complete lack of understanding
> > how bpf is working and how it's being used.
> > See SKF_AD_IFINDEX that was in classic bpf forever.
> >
> 
> I think I disagree completely.
> 
> With classic BPF, a program creates a socket and binds a bpf program
> to it.  That program can see the ifindex, which is fine because that
> ifindex is scoped to the socket's netns, which is (unless the caller
> uses setns() or unshare()) the same as the caller's netns, so the
> ifindex means exactly what the caller thinks it means.
> 
> With cgroup+bpf, the program installing the hook can be completely
> unrelated to the program whose sockets are subject to the hook, and,
> if they're using different namespaces, it breaks.

Please also see ingress_ifindex, ifindex, bpf_redirect(), bpf_clone_redirect()
that all operate on the ifindex while the program can be detached from
the application. In general bpf program and application that loaded and
attached it are mostly disjoint in case of networking. We have tail_call
mechanism and master bpf prog may call programs installed by other apps
that may have exited already.
cls_bpf is scoped by netdev that belongs to some netns.
If after attaching a program with hardcoded if(ifindex==3) check
to such netdev, this netdev is moved into different netns, this 'if' check
and the program become bogus and won't do what program author
expected. It is expected behavior. The same thing with current 'ip vrf'
implementation that Dave is adjusting. It's not a bug in cgroup+bpf behavior.
