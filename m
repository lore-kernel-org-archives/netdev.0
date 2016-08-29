From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [net-next RFC v2 4/9] bpf, security: Add Checmate security LSM
 and BPF program type
Date: Mon, 29 Aug 2016 16:16:13 -0700
Message-ID: <CALCETrVDRwBOvDuAZW=bBUs+9eSN7LdyjWvh2=mMMrX0p2atqQ@mail.gmail.com>
References: <20160829114705.GA20877@ircssh.c.rugged-nimbus-611.internal>
 <20160829170118.GB28713@mtj.duckdns.org> <20160829184905.GA25396@ircssh.c.rugged-nimbus-611.internal>
 <20160829192443.GD28713@mtj.duckdns.org> <57C4ADDD.3070003@fb.com> <57C4B4F4.8030304@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57C4B4F4.8030304-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Aug 29, 2016 3:19 PM, "Micka=C3=ABl Sala=C3=BCn" <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org> wrote=
:
>
>
> On 29/08/2016 23:49, Alexei Starovoitov wrote:
> > On 8/29/16 12:24 PM, Tejun Heo wrote:
> >> Hello, Sargun.
> >>
> >> On Mon, Aug 29, 2016 at 11:49:07AM -0700, Sargun Dhillon wrote:
> >>> It would be a separate hook per LSM hook. Why wouldn't we want a
> >>> separate bpf
> >>> hook per lsm hook? I think if one program has to handle them all, the
> >>> first
> >>> program would be looking up the hook program in a bpf prog array. If
> >>> you think
> >>> it's better to have this logic in the BPF program, that makes sense.
> >>>
> >>> I had a version of this patch that allowed you to attach a prog array
> >>> instead,
> >>> but I think that it's cleaner attaching a program per lsm hook. In
> >>> addition,
> >>> there's a performance impact that comes from these hooks, so I
> >>> wouldn't want to
> >>> execute unneccessary code if it's avoidable.
> >>
> >> Hmm... it doesn't really matter how the backend part looks like and if
> >> we need to implement per-call hooks to lower runtime overhead, sure.
> >> I was mostly worried about the approach propagating through the
> >> userland visible interface.
> >>
> >>> The prog array approach also makes stacking filters difficult. If
> >>> people want
> >>> multiple filters per hook, the orchestrator would have to rewrite the
> >>> existing
> >>> filters to be cooperative.
> >>
> >> I'm not really sure "stacking" in the kernel side is a good idea.
> >> Please see below.
> >>
> >>>> I'm not convinced about the approach.  It's an approach which pretty
> >>>> much requires future extensions while being rigid.  Not a good
> >>>> combination.
> >>>
> >>> Do you have an alternative recommendation? Maybe just a set of 5 u64s
> >>> as the context object along with the hook ID?
> >>
> >> cgroup fs doesn't seem like the right interface for this but if it
> >> were I'd go for named hook IDs instead of opaque numbers.
> >>
> >>>> Unless this is properly delegatable, IOW, it's safe to fully delegat=
e
> >>>> to a lesser security domain for all operations including program
> >>>> loading and assignment (I can't see how that'd be the case), making =
it
> >>>> an explicit controller doens't work in terms of userland interface.
> >>>> It's fine for bpf / lsm / whatever to attach to cgroups by extending
> >>>> struct cgroup itself or implementing an implicit controller but to b=
e
> >>>> visible as an explicit controller it must be able to follow cgroup
> >>>> interface rules including delegation.  If not, it's best to come
> >>>> through the interface which enforces the required permission checks
> >>>> and then talk to cgroup from there.  This was also an issue with
> >>>> network cgroup bpf programs that Daniel Mack is working on.  Please
> >>>> chat with him.
> >>>
> >>> Program assignment is possible by lesser security domains. Program
> >>> loading is
> >>> limited to CAP_SYS_ADMIN in init_user_ns. We could make it accessible=
 to
> >>> CAP_SYS_ADMIN in any userns, but it the reasoning behind this is that
> >>> Checmate
> >>> BPF programs can leak kernel pointers.
> >>
> >> That doesn't make much sense to me.  Delegation doesn't mean much if a
> >> delegatee can't load its own program (and I don't see how one can
> >> delegate kernel pointer access to !root).  Also, unless there's
> >> per-program fine control on who can load it, it seems pretty dangerous
> >> to let anyone load any program.
> >>
> >>> Could we potentially restrict it to only CAP_MAC_OVERRIDE, while
> >>> still meeting
> >>> cgroup delegation requirements?
> >>
> >> Wouldn't it make far more sense to pass cgroup fd to bpf syscall so
> >> that "load this program" and "attach this program to the cgroup
> >> identified by this fd" through the same interface and permission
> >> checks?  cgroup participating in bpf operations is all fine but
> >> splitting the userland interface across two domains seems like a bad
> >> idea.
> >>
> >>> Filters which are higher up in the heirarchy will still be enforced
> >>> during
> >>> delegation. This was an explicit design, as the "Orchestrator in
> >>> Orchestrator"
> >>> use case needs to be supported.
> >>
> >> Given that program loading is restricted to root, wouldn't it be an a
> >> lot more efficient approach to let userland multiplex multiple
> >> programs?  Walking the tree executing bpf programs each time one of
> >> these operations runs can be pretty expensive.  Imagine a tree like
> >> the following.
> >>
> >>     A - B - C
> >>           \ D
> >>
> >> Let's say program is currently loaded on D.  If someone wants to add a
> >> program on B, userland can load the program on B, combine B's and D's
> >> program and compile them into a single program and load it on D.  The
> >> only thing kernel would need to do in terms of hierarchy is finding
> >> what's the closest program to execute.  In the above example, C would
> >> need to use B's program and that can be determined on program
> >> assignment time rather than on each operation.
> >
> > I think that's exactly what Daniel's patches are doing and imo
> > it makes sense to keep this style for lsm as well
> > and also apply the concept of hook_id.
> > Daniel adds two commands to bpf syscall to attach/detach from cgroup
> > with hook_id.
> > Initially two hooks will be for socket rx and tx.
> > Then all interesting lsm hooks can be added one by one.
> > Daniel's prog type will be bpf_prog_type_cgroup_socket_filter.
> > LSM's prog type will be bpf_prog_type_lsm.
> > And verifier can check type safety since the lsm hook_id will be
> > passed at the program load time.
> > See another thread we had with Mickael.
> >
> > landlock and checmate are very similar and should really be
> > single lsm as long as we agree that both are cgroup based.
> > The main difference between the two:
> > - landlock is proposing unpriveleged mode
> > - checmate is proposing writing into arguments from the program
> > These differences can be flags/options to one lsm.
> > Implementations of course are different so far, but
> > instead of arguing landlock vs checmate, I'd like us
> > to focus on how we can make one lsm that solves all use cases.
>
> Thanks for putting me in the loop. I am agree that both approaches can
> be combined and I'm working on a new RFC for Landlock in which it would
> be possible to manage unprivileged and privileged eBPF programs
> according to extra flags. Sargun's network manipulation and checks (from
> Checmate) could then sit on top of it.
>
> However, for this to work, I'm keeping the main Landlock design to be
> able to manage unprivileged rules, which is a touchy part. The next RFC
> will also contains cgroup handling thanks to Daniel Mack's
> BPF_PROG_ATTACH feature.
>
> Basically, the main constraints for an unprivileged LSM are:
> * must use and check no_new_priv for all impacted processes, including
> moving from and to a cgroup (which get more complicated when dealing
> with different privileged eBPF programs);

...which is vastly simplified if you just don't let the unprivileged
stuff interact with cgroups.  If the only use case so far is to add
restrictions to unsuspecting processes, I would suggest addressing
that differently (LD_PRELOAD, new syscall, or simply don't support
it).  I still feel like this is a lot of effort to go through to try
to get cgroups and unprivileged sandboxing to play nice together, and
I'm not yet seeing the point.
