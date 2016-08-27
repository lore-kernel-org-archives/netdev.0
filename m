From: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Sat, 27 Aug 2016 11:06:44 -0700
Message-ID: <20160827180642.GA38754@ast-mbp.thefacebook.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net>
 <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net>
 <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <57C19E6E.6040908-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: cgroups-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Sat, Aug 27, 2016 at 04:06:38PM +0200, Mickaël Salaün wrote:
> 
> On 27/08/2016 01:05, Alexei Starovoitov wrote:
> > On Fri, Aug 26, 2016 at 05:10:40PM +0200, Mickaël Salaün wrote:
> >>
> >>>
> >>> - I don't think such 'for' loop can scale. The solution needs to work
> >>> with thousands of containers and thousands of cgroups.
> >>> In the patch 06/10 the proposal is to use 'current' as holder of
> >>> the programs:
> >>> +   for (prog = current->seccomp.landlock_prog;
> >>> +                   prog; prog = prog->prev) {
> >>> +           if (prog->filter == landlock_ret->filter) {
> >>> +                   cur_ret = BPF_PROG_RUN(prog->prog, (void *)&ctx);
> >>> +                   break;
> >>> +           }
> >>> +   }
> >>> imo that's the root of scalability issue.
> >>> I think to be able to scale the bpf programs have to be attached to
> >>> cgroups instead of tasks.
> >>> That would be very different api. seccomp doesn't need to be touched.
> >>> But that is the only way I see to be able to scale.
> >>
> >> Landlock is inspired from seccomp which also use a BPF program per
> >> thread. For seccomp, each BPF programs are executed for each syscall.
> >> For Landlock, some BPF programs are executed for some LSM hooks. I don't
> >> see why it is a scale issue for Landlock comparing to seccomp. I also
> >> don't see why storing the BPF program list pointer in the cgroup struct
> >> instead of the task struct change a lot here. The BPF programs execution
> >> will be the same anyway (for each LSM hook). Kees should probably have a
> >> better opinion on this.
> > 
> > seccomp has its own issues and copying them doesn't make this lsm any better.
> > Like seccomp bpf programs are all gigantic switch statement that looks
> > for interesting syscall numbers. All syscalls of a task are paying
> > non-trivial seccomp penalty due to such design. If bpf was attached per
> > syscall it would have been much cheaper. Of course doing it this way
> > for seccomp is not easy, but for lsm such facility is already there.
> > Blank call of a single bpf prog for all lsm hooks is unnecessary
> > overhead that can and should be avoided.
> 
> It's probably a misunderstanding. Contrary to seccomp which run all the
> thread's BPF programs for any syscall, Landlock only run eBPF programs
> for the triggered LSM hooks, if their type match. Indeed, thanks to the
> multiple eBPF program types and contrary to seccomp, Landlock only run
> an eBPF program when needed. Landlock will have almost no performance
> overhead if the syscalls do not trigger the watched LSM hooks for the
> current process.

that's not what I see in the patch 06/10:
all lsm_hooks in 'static struct security_hook_list landlock_hooks'
(which eventually means all lsm hooks) will call
static inline int landlock_hook_##NAME
which will call landlock_run_prog()
which does:
+ for (landlock_ret = current->seccomp.landlock_ret;
+      landlock_ret; landlock_ret = landlock_ret->prev) {
+    if (landlock_ret->triggered) {
+       ctx.cookie = landlock_ret->cookie;
+       for (prog = current->seccomp.landlock_prog;
+            prog; prog = prog->prev) {
+               if (prog->filter == landlock_ret->filter) {
+                       cur_ret = BPF_PROG_RUN(prog->prog, (void *)&ctx);
+                       break;
+               }
+       }

that is unacceptable overhead and not a scalable design.
It kinda works for 3 lsm_hooks as in patch 6, but doesn't scale
as soon as more lsm hooks are added.

> As said above, Landlock will not run an eBPF programs when not strictly
> needed. Attaching to a cgroup will have the same performance impact as
> attaching to a process hierarchy.

Having a prog per cgroup per lsm_hook is the only scalable way I
could come up with. If you see another way, please propose.
current->seccomp.landlock_prog is not the answer.
