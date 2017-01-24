From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Tue, 24 Jan 2017 09:48:26 -0800
Message-ID: <20170124174823.GA17813@ast-mbp.thefacebook.com>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com>
 <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Ahern <dsa@cumulusnetworks.com>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f65.google.com ([74.125.83.65]:32983 "EHLO
        mail-pg0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750775AbdAXRsr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 12:48:47 -0500
Received: by mail-pg0-f65.google.com with SMTP id 194so17208161pgd.0
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 09:48:36 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 23, 2017 at 08:32:02PM -0800, Andy Lutomirski wrote:
> On Mon, Jan 23, 2017 at 8:05 PM, David Ahern <dsa@cumulusnetworks.com> wrote:
> > On 1/23/17 8:37 PM, Andy Lutomirski wrote:
> >> Yes, it is a bug because cgroup+bpf causes unwitting programs to be
> >> subject to BPF code installed by a different, potentially unrelated
> >> process.  That's a new situation.  The failure can happen when a
> >> privileged supervisor (whoever runs ip vrf) runs a clueless or
> >> unprivileged program (the thing calling unshare()).
> >
> > There are many, many ways to misconfigure networking and to run programs in a context or with an input argument that causes the program to not work at all, not work as expected or stop working. This situation is no different.
> >
> > For example, the only aspect of BPF_PROG_TYPE_CGROUP_SOCK filters that are namespace based is the ifindex. You brought up the example of changing namespaces where the ifindex is not defined. Alexei mentioned an example where interfaces can be moved to another namespace breaking any ifindex based programs. Another example is the interface can be deleted. Deleting an interface with sockets bound to it does not impact the program in any way - no notification, no wakeup, nothing. The sockets just don't work.
> 
> And if you use 'ip vrf' to bind to a vrf with ifindex 4 and a program
> unshares netns and creates an interface with ifindex 4, then that
> program will end up with its sockets magically bound to ifindex 4 and
> will silently malfunction.
> 
> I can think of multiple ways to address this problem.  You could scope
> the hooks to a netns (which is sort of what my patch does).  You could
> find a way to force programs in a given cgroup to only execute in a
> single netns, although that would probably cause other breakage.  You
> could improve the BPF hook API to be netns-aware, which could plausbly
> address issues related to unshare() but might get very tricky when
> setns() is involved.

scoping cgroup to netns will create weird combination of cgroup and netns
which was never done before. cgroup and netns scopes have to be able
to overlap in arbitrary way. Application shouldn't not be able to escape
cgroup scope by changing netns. They are orthogonal scoping constructs.
What we can do instead is to do add bpf helper function to retrieve
the netns id, so that program created for specific netns and specific
ifindex will be more resilient to netns changes.
Note that this ifindex behavior has been present since classic bpf
and its shortcomings are understood. We need to improve it for all bpf
users. It really has nothing to do with cgroups.
cls_bpf filters can do packet redirect into ifindex and they can break
if user process changes.
The 'malfunction' scenario describe above is no different than
cls_bpf is using bpf_skb_under_cgroup() to scope particular
skb->sk->cgroup and doing redirect into ifindex.
It will 'malfunction' exactly the same way if application stays
in the same cgroup, but moves from one netns into another.

> My point is that, in 4.10-rc, it doesn't work right, and I doubt this
> problem is restricted to just 'ip vrf'.  Without some kind of change
> to the way that netns and cgroup+bpf interact, anything that uses
> sk_bound_dev_if or reads the ifindex on an skb will be subject to a
> huge footgun that unprivileged programs can trigger and any future
> attempt to make the cgroup+bpf work for unprivileged users is going to
> be more complicated than it deserves to be.

For n-th time, the current BPF_PROG_TYPE_CGROUP* is root only and
speculation about unprivileged usage are not helping the discussion.

> things up so that unshare will malfunction.  It should avoid
> malfunctioning when running Linux programs that are unaware of it.

I agree that for VRF use case it will help to make programs netns
aware by adding new bpf_get_current_netns_id() or something helper,
but it's up to the program to function properly or be broken.
Adding weird netns restrictions is not going to make bpf programs
any more sane. The program author can always shoot in the foot.

I will work on the patch to add that.
