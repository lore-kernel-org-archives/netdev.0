From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v2] bpf: Restrict cgroup bpf hooks to the init netns
Date: Tue, 24 Jan 2017 17:18:16 -0500
Message-ID: <20170124221816.GA29982@htj.duckdns.org>
References: <ddd9e097f54e894197a2925731de02d1d3cae137.1485203708.git.luto@kernel.org>
 <20170124020950.GA72992@ast-mbp.thefacebook.com>
 <CALCETrUq_ZSso_252ixzjt+WbFOv_K57zbePUXneLv-Tgi5=jA@mail.gmail.com>
 <20170124031259.GA81720@ast-mbp.thefacebook.com>
 <CALCETrVZqqfMO+=HGgebbAJ0TY6c3XSyY1G-Ve+g3VQiEfGwyA@mail.gmail.com>
 <08f3f57e-8c51-c893-01ad-3ce23db8166d@cumulusnetworks.com>
 <CALCETrVsqktjiPkfpcm_5uL0UL2Lzr106ZteLchJVnsKH_e-aw@mail.gmail.com>
 <20170124174823.GA17813@ast-mbp.thefacebook.com>
 <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        David Ahern <dsa@cumulusnetworks.com>,
        Andy Lutomirski <luto@kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f196.google.com ([209.85.161.196]:34438 "EHLO
        mail-yw0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750861AbdAXWSS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 24 Jan 2017 17:18:18 -0500
Received: by mail-yw0-f196.google.com with SMTP id v73so22117547ywg.1
        for <netdev@vger.kernel.org>; Tue, 24 Jan 2017 14:18:18 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <CALCETrW-Sj9eM+Nm9PVpqJky_30YSGhzc8hnzmddPkhHzb5_Fg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, Andy.

On Tue, Jan 24, 2017 at 10:54:03AM -0800, Andy Lutomirski wrote:
> Tejun, I can see two basic ways that cgroup+bpf delegation could work
> down the road.  Both depend on unprivileged users being able to load
> BPF programs of the correct type, but that's mostly a matter of
> auditing the code and doesn't have any particularly interesting design
> challenges as far as I know.
> 
> Approach 1: Scope cgroup+bpf hooks to a netns and require
> ns_capable(CAP_NET_ADMIN), fs permissions, and (optionally) delegation
> to be enabled to install them.  This shouldn't have any particularly
> dangerous security implications because ns_capable(CAP_NET_ADMIN)
> means you already own the netns.
> 
> Approach 2: Keep cgroup+bpf hooks global.  This makes the delegation
> story much trickier.  There needs to be some mechanism to prevent some
> program that has delegated cgroup control from affecting the behavior
> of outside programs.  This isn't so easy.  Imagine that you've
> delegated /cgroup/foo to UID 1000.  A program with UID 1000 can now
> install a hook on /cgroup/foo, but there needs to be a mechanism to
> prevent UID 1000 from running in /cgroup/foo in the global netns and
> then running a tool like sudo.  This *might* be possible using just
> existing cgroup mechanisms, but it's going to be quite tricky to make
> sure it's done completely correctly and without dangerous races.
> 
> If cgroup+bpf stays global, then I think you're basically committing
> to approach 2.
> 
> I would suggest doing approach 1 (i.e. apply my patch) and then, if
> truly needed for some use case, add an option so that globally
> privileged programs can create hooks that affect all namespaces.

I thought about restricting according to namespaces and your ifindex
example.  While the ifindex issue seems broken and on the surface
seems to indicate that we need to segregate cgroup bpf programs per
netns as iptables does, the more I think about it, the less convinced
I'm that that is the only right way forward.

I'm not too familiar with netns but if you think about other
namespaces, !root namespaces nest inside the root one.  When you enter
a pid namespace, it adds its pid namespace on top of the global one.
It doesn't replace that, and that is an important characteristic which
allows the root namespace to maintain control over the nested ones.
This is the same with cgroupns, which basically is just nesting, or
mount namespace.  Namespaced objects don't disappear in the eyes of
the root namespace.  They just get additional scoped names.

Back to netns, if I'm understanding correctly, this doesn't seem to be
the case.  An interface belongs to a namespace and can be moved around
but it disappears from the root namespace once it enters a non-root
one.  I guess there are reasons, even if historical, for it but this
is what is breaking your ifindex example.  It's fine for an interface
to get a new scoped ifindex inside a netns, but that shouldn't
override the global one.  This, I think, should be fixable without
breaking existing APIs by introducing a new global index.

My opinion on this isn't very strong but what iptables is doing
actually seems wrong to me in that it actually precludes any way of
implementing global policies which encompasses the whole system.
Again, this is a fixable problem if ever necessary by introducing
properly global rule tables or even just adding a flag.

So, I don't think the situation is as clear as "ifindex is broken, so
cgroup bpf programs should be segregated per netns".

David, in another reply, you mentioned about fixing ifindex.  If I
understood correctly, we're talking about the same thing, right?  If
so, is this something easy to implement?

Thanks.

-- 
tejun
