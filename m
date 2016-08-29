From: Tejun Heo <tj@kernel.org>
Subject: Re: [net-next RFC v2 4/9] bpf, security: Add Checmate security LSM
 and BPF program type
Date: Mon, 29 Aug 2016 15:24:43 -0400
Message-ID: <20160829192443.GD28713@mtj.duckdns.org>
References: <20160829114705.GA20877@ircssh.c.rugged-nimbus-611.internal>
 <20160829170118.GB28713@mtj.duckdns.org>
 <20160829184905.GA25396@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
        linux-security-module@vger.kernel.org, daniel@iogearbox.net,
        ast@fb.com
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <linux-security-module-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160829184905.GA25396@ircssh.c.rugged-nimbus-611.internal>
Sender: owner-linux-security-module@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Sargun.

On Mon, Aug 29, 2016 at 11:49:07AM -0700, Sargun Dhillon wrote:
> It would be a separate hook per LSM hook. Why wouldn't we want a separate bpf 
> hook per lsm hook? I think if one program has to handle them all, the first 
> program would be looking up the hook program in a bpf prog array. If you think 
> it's better to have this logic in the BPF program, that makes sense. 
> 
> I had a version of this patch that allowed you to attach a prog array instead, 
> but I think that it's cleaner attaching a program per lsm hook. In addition, 
> there's a performance impact that comes from these hooks, so I wouldn't want to 
> execute unneccessary code if it's avoidable.

Hmm... it doesn't really matter how the backend part looks like and if
we need to implement per-call hooks to lower runtime overhead, sure.
I was mostly worried about the approach propagating through the
userland visible interface.

> The prog array approach also makes stacking filters difficult. If people want 
> multiple filters per hook, the orchestrator would have to rewrite the existing 
> filters to be cooperative.

I'm not really sure "stacking" in the kernel side is a good idea.
Please see below.

> > I'm not convinced about the approach.  It's an approach which pretty
> > much requires future extensions while being rigid.  Not a good
> > combination.
>
> Do you have an alternative recommendation? Maybe just a set of 5 u64s
> as the context object along with the hook ID?

cgroup fs doesn't seem like the right interface for this but if it
were I'd go for named hook IDs instead of opaque numbers.

> > Unless this is properly delegatable, IOW, it's safe to fully delegate
> > to a lesser security domain for all operations including program
> > loading and assignment (I can't see how that'd be the case), making it
> > an explicit controller doens't work in terms of userland interface.
> > It's fine for bpf / lsm / whatever to attach to cgroups by extending
> > struct cgroup itself or implementing an implicit controller but to be
> > visible as an explicit controller it must be able to follow cgroup
> > interface rules including delegation.  If not, it's best to come
> > through the interface which enforces the required permission checks
> > and then talk to cgroup from there.  This was also an issue with
> > network cgroup bpf programs that Daniel Mack is working on.  Please
> > chat with him.
>
> Program assignment is possible by lesser security domains. Program loading is 
> limited to CAP_SYS_ADMIN in init_user_ns. We could make it accessible to 
> CAP_SYS_ADMIN in any userns, but it the reasoning behind this is that Checmate
> BPF programs can leak kernel pointers. 

That doesn't make much sense to me.  Delegation doesn't mean much if a
delegatee can't load its own program (and I don't see how one can
delegate kernel pointer access to !root).  Also, unless there's
per-program fine control on who can load it, it seems pretty dangerous
to let anyone load any program.

> Could we potentially restrict it to only CAP_MAC_OVERRIDE, while still meeting 
> cgroup delegation requirements?

Wouldn't it make far more sense to pass cgroup fd to bpf syscall so
that "load this program" and "attach this program to the cgroup
identified by this fd" through the same interface and permission
checks?  cgroup participating in bpf operations is all fine but
splitting the userland interface across two domains seems like a bad
idea.

> Filters which are higher up in the heirarchy will still be enforced during 
> delegation. This was an explicit design, as the "Orchestrator in Orchestrator" 
> use case needs to be supported.

Given that program loading is restricted to root, wouldn't it be an a
lot more efficient approach to let userland multiplex multiple
programs?  Walking the tree executing bpf programs each time one of
these operations runs can be pretty expensive.  Imagine a tree like
the following.

	A - B - C
	      \ D

Let's say program is currently loaded on D.  If someone wants to add a
program on B, userland can load the program on B, combine B's and D's
program and compile them into a single program and load it on D.  The
only thing kernel would need to do in terms of hierarchy is finding
what's the closest program to execute.  In the above example, C would
need to use B's program and that can be determined on program
assignment time rather than on each operation.

Thanks.

-- 
tejun
