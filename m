From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Tue, 30 Aug 2016 14:45:14 -0700
Message-ID: <CALCETrX6hPFZwdnypkPA0p9VjdcK=ZFYpR8zXpzOYS6f=fx3_g@mail.gmail.com>
References: <20160827180642.GA38754@ast-mbp.thefacebook.com>
 <57C1EB72.2050703@digikod.net> <20160827204307.GA43714@ast-mbp.thefacebook.com>
 <57C202BF.7000207@digikod.net> <CALCETrXgQ+njtupXiKcOXG8ZRzD=n2LhT45NiJr1Ehob7bHskQ@mail.gmail.com>
 <57C2B21E.9040705@digikod.net> <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>
 <57C5EAA3.5090901@digikod.net> <CALCETrWAYyx_5Axyeqiz6tQa0kqTeNTuHRrERcM2G8ROhaphVw@mail.gmail.com>
 <57C5ED9B.3040303@digikod.net> <20160830205552.GB71063@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>,
        Daniel Mack <daniel-cYrQPVfZoowdnm+yROfE0A@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org"
        <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
To: Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20160830205552.GB71063-+o4/htvd0TDFYCXBM6kdu7fOX0fSgVTm@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Aug 30, 2016 1:56 PM, "Alexei Starovoitov"
<alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>
> On Tue, Aug 30, 2016 at 10:33:31PM +0200, Micka=C3=ABl Sala=C3=BCn wrote:
> >
> >
> > On 30/08/2016 22:23, Andy Lutomirski wrote:
> > > On Tue, Aug 30, 2016 at 1:20 PM, Micka=C3=ABl Sala=C3=BCn <mic@digiko=
d.net> wrote:
> > >>
> > >> On 30/08/2016 20:55, Andy Lutomirski wrote:
> > >>> On Sun, Aug 28, 2016 at 2:42 AM, Micka=C3=ABl Sala=C3=BCn <mic@digi=
kod.net> wrote:
> > >>>>
> > >>>>
> > >>>> On 28/08/2016 10:13, Andy Lutomirski wrote:
> > >>>>> On Aug 27, 2016 11:14 PM, "Micka=C3=ABl Sala=C3=BCn" <mic@digikod=
.net> wrote:
> > >>>>>>
> > >>>>>>
> > >>>>>> On 27/08/2016 22:43, Alexei Starovoitov wrote:
> > >>>>>>> On Sat, Aug 27, 2016 at 09:35:14PM +0200, Micka=C3=ABl Sala=C3=
=BCn wrote:
> > >>>>>>>> On 27/08/2016 20:06, Alexei Starovoitov wrote:
> > >>>>>>>>> On Sat, Aug 27, 2016 at 04:06:38PM +0200, Micka=C3=ABl Sala=
=C3=BCn wrote:
> > >>>>>>>>>> As said above, Landlock will not run an eBPF programs when n=
ot strictly
> > >>>>>>>>>> needed. Attaching to a cgroup will have the same performance=
 impact as
> > >>>>>>>>>> attaching to a process hierarchy.
> > >>>>>>>>>
> > >>>>>>>>> Having a prog per cgroup per lsm_hook is the only scalable wa=
y I
> > >>>>>>>>> could come up with. If you see another way, please propose.
> > >>>>>>>>> current->seccomp.landlock_prog is not the answer.
> > >>>>>>>>
> > >>>>>>>> Hum, I don't see the difference from a performance point of vi=
ew between
> > >>>>>>>> a cgroup-based or a process hierarchy-based system.
> > >>>>>>>>
> > >>>>>>>> Maybe a better option should be to use an array of pointers wi=
th N
> > >>>>>>>> entries, one for each supported hook, instead of a unique poin=
ter list?
> > >>>>>>>
> > >>>>>>> yes, clearly array dereference is faster than link list walk.
> > >>>>>>> Now the question is where to keep this prog_array[num_lsm_hooks=
] ?
> > >>>>>>> Since we cannot keep it inside task_struct, we have to allocate=
 it.
> > >>>>>>> Every time the task is creted then. What to do on the fork? Tha=
t
> > >>>>>>> will require changes all over. Then the obvious optimization wo=
uld be
> > >>>>>>> to share this allocated array of prog pointers across multiple =
tasks...
> > >>>>>>> and little by little this new facility will look like cgroup.
> > >>>>>>> Hence the suggestion to put this array into cgroup from the sta=
rt.
> > >>>>>>
> > >>>>>> I see your point :)
> > >>>>>>
> > >>>>>>>
> > >>>>>>>> Anyway, being able to attach an LSM hook program to a cgroup t=
hanks to
> > >>>>>>>> the new BPF_PROG_ATTACH seems a good idea (while keeping the p=
ossibility
> > >>>>>>>> to use a process hierarchy). The downside will be to handle an=
 LSM hook
> > >>>>>>>> program which is not triggered by a seccomp-filter, but this s=
hould be
> > >>>>>>>> needed anyway to handle interruptions.
> > >>>>>>>
> > >>>>>>> what do you mean 'not triggered by seccomp' ?
> > >>>>>>> You're not suggesting that this lsm has to enable seccomp to be=
 functional?
> > >>>>>>> imo that's non starter due to overhead.
> > >>>>>>
> > >>>>>> Yes, for now, it is triggered by a new seccomp filter return val=
ue
> > >>>>>> RET_LANDLOCK, which can take a 16-bit value called cookie. This =
must not
> > >>>>>> be needed but could be useful to bind a seccomp filter security =
policy
> > >>>>>> with a Landlock one. Waiting for Kees's point of view=E2=80=A6
> > >>>>>>
> > >>>>>
> > >>>>> I'm not Kees, but I'd be okay with that.  I still think that doin=
g
> > >>>>> this by process hierarchy a la seccomp will be easier to use and =
to
> > >>>>> understand (which is quite important for this kind of work) than =
doing
> > >>>>> it by cgroup.
> > >>>>>
> > >>>>> A feature I've wanted to add for a while is to have an fd that
> > >>>>> represents a seccomp layer, the idea being that you would set up =
your
> > >>>>> seccomp layer (with syscall filter, landlock hooks, etc) and then=
 you
> > >>>>> would have a syscall to install that layer.  Then an unprivileged
> > >>>>> sandbox manager could set up its layer and still be able to injec=
t new
> > >>>>> processes into it later on, no cgroups needed.
> > >>>>
> > >>>> A nice thing I didn't highlight about Landlock is that a process c=
an
> > >>>> prepare a layer of rules (arraymap of handles + Landlock programs)=
 and
> > >>>> pass the file descriptors of the Landlock programs to another proc=
ess.
> > >>>> This process could then apply this programs to get sandboxed. Howe=
ver,
> > >>>> for now, because a Landlock program is only triggered by a seccomp
> > >>>> filter (which do not follow the Landlock programs as a FD), they w=
ill be
> > >>>> useless.
> > >>>>
> > >>>> The FD referring to an arraymap of handles can also be used to upd=
ate a
> > >>>> map and change the behavior of a Landlock program. A master proces=
s can
> > >>>> then add or remove restrictions to another process hierarchy on th=
e fly.
> > >>>
> > >>> Maybe this could be extended a little bit.  The fd could hold the
> > >>> seccomp filter *and* the LSM hook filters.  FMODE_EXECUTE could giv=
e
> > >>> the ability to install it and FMODE_WRITE could give the ability to
> > >>> modify it.
> > >>>
> > >>
> > >> This is interesting! It should be possible to append the seccomp sta=
ck
> > >> of a source process to the seccomp stack of the target process when =
a
> > >> Landlock program is passed and then activated through seccomp(2).
> > >>
> > >> For the FMODE_EXECUTE/FMODE_WRITE, are you suggesting to manage
> > >> permission of the eBPF program FD in a specific way?
> > >>
> > >
> > > This wouldn't be an eBPF program FD -- it would be an FD encapsulatin=
g
> > > an entire configuration including seccomp BPF program, whatever
> > > landlock stuff is associated, and eventual seccomp monitor
> > > configuration (once I write that code), etc.
> > >
> > > You wouldn't say "attach this process's seccomp stack to me" -- you'd
> > > say "attach this seccomp layer to me".
> > >
> > > A decision that we'd have to make would be whether the FD links to th=
e
> > > parent layer or whether it can be attached without regard to what the
> > > parent layer is.
> >
> > OK, I like that, but I think it could be done on a second time. :)
>
> I don't. Single FD that is a collection of objects seems an odd abstracti=
on
> to me. I also don't see what it actually solves.
> I think lsm and seccomp should be orthogonal and not tied into each other=
.
>

It's not a random collection of objects.  It's a fully configured
sandboxing layer.

One might argue that landlock shouldn't be tied to seccomp (in theory,
attached progs could be given access to syscall_get_xyz()), but I
think that the seccomp attachment mechanism is the right way to
install unprivileged filters.  It handles the no_new_privs stuff, it
allows TSYNC, it's totally independent of systemwide policy, etc.

Trying to use cgroups or similar for this is going to be much nastier.
Some tighter sandboxes (Sandstorm, etc) aren't even going to dream of
putting cgroupfs in their containers, so requiring cgroups or similar
would be a mess for that type of application.

--Andy
