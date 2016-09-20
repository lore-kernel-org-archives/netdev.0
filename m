From: Sargun Dhillon <sargun@sargun.me>
Subject: Re: [RFC v3 18/22] cgroup,landlock: Add CGRP_NO_NEW_PRIVS to handle
 unprivileged hooks
Date: Mon, 19 Sep 2016 21:37:46 -0700
Message-ID: <20160920043744.GA13906@ircssh.c.rugged-nimbus-611.internal>
References: <57D9CB25.1010103@digikod.net>
 <CALCETrVjyLaL-0H1AFsfYUtDGA8NSn4R8LkvBMQT7Gpmxeswgg@mail.gmail.com>
 <20160915021940.GA65119@ast-mbp.thefacebook.com>
 <CALCETrWXjJZZRj5XvDQ+-Grue+b4MW2TFKsfgYYFYoFBFVH71g@mail.gmail.com>
 <20160915040054.GA65308@ast-mbp.thefacebook.com>
 <CALCETrXTS8R1E2b9mmWzpOO6QOW5nWYW_RQRJYU1CGRsbNy+Yw@mail.gmail.com>
 <20160915043120.GA65819@ast-mbp.thefacebook.com>
 <CALCETrU=tGLx8s_eqji6SfXRi=3W8FkGC7wA6VMfD-_wAVb66w@mail.gmail.com>
 <20160915044852.GA66000@ast-mbp.thefacebook.com>
 <57DAF96D.3060609@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Lutomirski <luto@amacapital.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Alexei Starovoitov <ast@kernel.org>,
        Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>,
        David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>,
        Paul Moore <pmoore@redhat.com>,
        "Serge E . Hallyn" <serge@hallyn.com>, Tejun Heo <tj@kernel.org>,
        Will Drewry <wad@chromium.org>,
        "kernel-hardening@lists.openwall.com"
To: =?iso-8859-1?Q?Micka=EBl_Sala=FCn?= <mic@digikod.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <57DAF96D.3060609@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 15, 2016 at 09:41:33PM +0200, Mickaël Salaün wrote:
> 
> On 15/09/2016 06:48, Alexei Starovoitov wrote:
> > On Wed, Sep 14, 2016 at 09:38:16PM -0700, Andy Lutomirski wrote:
> >> On Wed, Sep 14, 2016 at 9:31 PM, Alexei Starovoitov
> >> <alexei.starovoitov@gmail.com> wrote:
> >>> On Wed, Sep 14, 2016 at 09:08:57PM -0700, Andy Lutomirski wrote:
> >>>> On Wed, Sep 14, 2016 at 9:00 PM, Alexei Starovoitov
> >>>> <alexei.starovoitov@gmail.com> wrote:
> >>>>> On Wed, Sep 14, 2016 at 07:27:08PM -0700, Andy Lutomirski wrote:
> >>>>>>>>>
> >>>>>>>>> This RFC handle both cgroup and seccomp approaches in a similar way. I
> >>>>>>>>> don't see why building on top of cgroup v2 is a problem. Is there
> >>>>>>>>> security issues with delegation?
> >>>>>>>>
> >>>>>>>> What I mean is: cgroup v2 delegation has a functionality problem.
> >>>>>>>> Tejun says [1]:
> >>>>>>>>
> >>>>>>>> We haven't had to face this decision because cgroup has never properly
> >>>>>>>> supported delegating to applications and the in-use setups where this
> >>>>>>>> happens are custom configurations where there is no boundary between
> >>>>>>>> system and applications and adhoc trial-and-error is good enough a way
> >>>>>>>> to find a working solution.  That wiggle room goes away once we
> >>>>>>>> officially open this up to individual applications.
> >>>>>>>>
> >>>>>>>> Unless and until that changes, I think that landlock should stay away
> >>>>>>>> from cgroups.  Others could reasonably disagree with me.
> >>>>>>>
> >>>>>>> Ours and Sargun's use cases for cgroup+lsm+bpf is not for security
> >>>>>>> and not for sandboxing. So the above doesn't matter in such contexts.
> >>>>>>> lsm hooks + cgroups provide convenient scope and existing entry points.
> >>>>>>> Please see checmate examples how it's used.
> >>>>>>>
> >>>>>>
> >>>>>> To be clear: I'm not arguing at all that there shouldn't be
> >>>>>> bpf+lsm+cgroup integration.  I'm arguing that the unprivileged
> >>>>>> landlock interface shouldn't expose any cgroup integration, at least
> >>>>>> until the cgroup situation settles down a lot.
> >>>>>
> >>>>> ahh. yes. we're perfectly in agreement here.
> >>>>> I'm suggesting that the next RFC shouldn't include unpriv
> >>>>> and seccomp at all. Once bpf+lsm+cgroup is merged, we can
> >>>>> argue about unpriv with cgroups and even unpriv as a whole,
> >>>>> since it's not a given. Seccomp integration is also questionable.
> >>>>> I'd rather not have seccomp as a gate keeper for this lsm.
> >>>>> lsm and seccomp are orthogonal hook points. Syscalls and lsm hooks
> >>>>> don't have one to one relationship, so mixing them up is only
> >>>>> asking for trouble further down the road.
> >>>>> If we really need to carry some information from seccomp to lsm+bpf,
> >>>>> it's easier to add eBPF support to seccomp and let bpf side deal
> >>>>> with passing whatever information.
> >>>>>
> >>>>
> >>>> As an argument for keeping seccomp (or an extended seccomp) as the
> >>>> interface for an unprivileged bpf+lsm: seccomp already checks off most
> >>>> of the boxes for safely letting unprivileged programs sandbox
> >>>> themselves.
> >>>
> >>> you mean the attach part of seccomp syscall that deals with no_new_priv?
> >>> sure, that's reusable.
> >>>
> >>>> Furthermore, to the extent that there are use cases for
> >>>> unprivileged bpf+lsm that *aren't* expressible within the seccomp
> >>>> hierarchy, I suspect that syscall filters have exactly the same
> >>>> problem and that we should fix seccomp to cover it.
> >>>
> >>> not sure what you mean by 'seccomp hierarchy'. The normal process
> >>> hierarchy ?
> >>
> >> Kind of.  I mean the filter layers that are inherited across fork(),
> >> the TSYNC mechanism, etc.
> >>
> >>> imo the main deficiency of secccomp is inability to look into arguments.
> >>> One can argue that it's a blessing, since composite args
> >>> are not yet copied into the kernel memory.
> >>> But in a lot of cases the seccomp arguments are FDs pointing
> >>> to kernel objects and if programs could examine those objects
> >>> the sandboxing scope would be more precise.
> >>> lsm+bpf solves that part and I'd still argue that it's
> >>> orthogonal to seccomp's pass/reject flow.
> >>> I mean if seccomp says 'ok' the syscall should continue executing
> >>> as normal and whatever LSM hooks were triggered by it may have
> >>> their own lsm+bpf verdicts.
> >>
> >> I agree with all of this...
> >>
> >>> Furthermore in the process hierarchy different children
> >>> should be able to set their own lsm+bpf filters that are not
> >>> related to parallel seccomp+bpf hierarchy of programs.
> >>> seccomp syscall can be an interface to attach programs
> >>> to lsm hooks, but nothing more than that.
> >>
> >> I'm not sure what you mean.  I mean that, logically, I think we should
> >> be able to do:
> >>
> >> seccomp(attach a syscall filter);
> >> fork();
> >> child does seccomp(attach some lsm filters);
> >>
> >> I think that they *should* be related to the seccomp+bpf hierarchy of
> >> programs in that they are entries in the same logical list of filter
> >> layers installed.  Some of those layers can be syscall filters and
> >> some of the layers can be lsm filters.  If we subsequently add a way
> >> to attach a removable seccomp filter or a way to attach a seccomp
> >> filter that logs failures to some fd watched by an outside monitor, I
> >> think that should work for lsm, too, with more or less the same
> >> interface.
> >>
> >> If we need a way for a sandbox manager to opt different children into
> >> different subsets of fancy filters, then I think that syscall filters
> >> and lsm filters should use the same mechanism.
> >>
> >> I think we might be on the same page here and just saying it different ways.
> > 
> > Sounds like it :)
> > All of the above makes sense to me.
> > The 'orthogonal' part is that the user should be able to use
> > this seccomp-managed hierarchy without actually enabling
> > TIF_SECCOMP for the task and syscalls should still go through
> > fast path and all the way till lsm hooks as normal.
> > I don't want to pay _any_ performance penalty for this feature
> > for lsm hooks (and all syscalls) that don't have bpf programs attached.
> 
> Yes, it seems that we are all on the same page here, and that match this
> RFC implementation. So, using the seccomp(2) *interface* to attach
> Landlock programs to a process hierarchy is still on track. :)
> 

So, I'm catching up on this after a little while away. I really like the 
simplicity of the approach Daniel took with his patches. I began to have 
difficulty reading your patchset once you got into using seccomp + unprivileged 
mode. I would love to see a separate patchset that only have the verifier, and
lsm hook changes. Do you think you could decompose your patchset into an MVP?
