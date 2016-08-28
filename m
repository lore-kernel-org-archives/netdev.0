From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Sun, 28 Aug 2016 01:13:13 -0700
Message-ID: <CALCETrXgQ+njtupXiKcOXG8ZRzD=n2LhT45NiJr1Ehob7bHskQ@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net> <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net> <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net> <20160827180642.GA38754@ast-mbp.thefacebook.com>
 <57C1EB72.2050703@digikod.net> <20160827204307.GA43714@ast-mbp.thefacebook.com>
 <57C202BF.7000207@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Alexei Starovoitov <ast@kernel.org>, Tejun Heo <tj@kernel.org>,
        Sargun Dhillon <sargun@sargun.me>,
        Network Development <netdev@vger.kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>,
        LSM List <linux-security-module@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "open list:CONTROL GROUP (CGROUP)" <cgroups@vger.kernel.org>,
        "David S . Miller" <davem@davemloft.net>,
        Daniel Mack <daniel@zonque.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic@digikod.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f179.google.com ([209.85.217.179]:35594 "EHLO
        mail-ua0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755316AbcH1INe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 28 Aug 2016 04:13:34 -0400
Received: by mail-ua0-f179.google.com with SMTP id i32so31781200uai.2
        for <netdev@vger.kernel.org>; Sun, 28 Aug 2016 01:13:34 -0700 (PDT)
In-Reply-To: <57C202BF.7000207@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Aug 27, 2016 11:14 PM, "Micka=C3=ABl Sala=C3=BCn" <mic@digikod.net> wrot=
e:
>
>
> On 27/08/2016 22:43, Alexei Starovoitov wrote:
> > On Sat, Aug 27, 2016 at 09:35:14PM +0200, Micka=C3=ABl Sala=C3=BCn wrot=
e:
> >> On 27/08/2016 20:06, Alexei Starovoitov wrote:
> >>> On Sat, Aug 27, 2016 at 04:06:38PM +0200, Micka=C3=ABl Sala=C3=BCn wr=
ote:
> >>>> As said above, Landlock will not run an eBPF programs when not stric=
tly
> >>>> needed. Attaching to a cgroup will have the same performance impact =
as
> >>>> attaching to a process hierarchy.
> >>>
> >>> Having a prog per cgroup per lsm_hook is the only scalable way I
> >>> could come up with. If you see another way, please propose.
> >>> current->seccomp.landlock_prog is not the answer.
> >>
> >> Hum, I don't see the difference from a performance point of view betwe=
en
> >> a cgroup-based or a process hierarchy-based system.
> >>
> >> Maybe a better option should be to use an array of pointers with N
> >> entries, one for each supported hook, instead of a unique pointer list=
?
> >
> > yes, clearly array dereference is faster than link list walk.
> > Now the question is where to keep this prog_array[num_lsm_hooks] ?
> > Since we cannot keep it inside task_struct, we have to allocate it.
> > Every time the task is creted then. What to do on the fork? That
> > will require changes all over. Then the obvious optimization would be
> > to share this allocated array of prog pointers across multiple tasks...
> > and little by little this new facility will look like cgroup.
> > Hence the suggestion to put this array into cgroup from the start.
>
> I see your point :)
>
> >
> >> Anyway, being able to attach an LSM hook program to a cgroup thanks to
> >> the new BPF_PROG_ATTACH seems a good idea (while keeping the possibili=
ty
> >> to use a process hierarchy). The downside will be to handle an LSM hoo=
k
> >> program which is not triggered by a seccomp-filter, but this should be
> >> needed anyway to handle interruptions.
> >
> > what do you mean 'not triggered by seccomp' ?
> > You're not suggesting that this lsm has to enable seccomp to be functio=
nal?
> > imo that's non starter due to overhead.
>
> Yes, for now, it is triggered by a new seccomp filter return value
> RET_LANDLOCK, which can take a 16-bit value called cookie. This must not
> be needed but could be useful to bind a seccomp filter security policy
> with a Landlock one. Waiting for Kees's point of view=E2=80=A6
>

I'm not Kees, but I'd be okay with that.  I still think that doing
this by process hierarchy a la seccomp will be easier to use and to
understand (which is quite important for this kind of work) than doing
it by cgroup.

A feature I've wanted to add for a while is to have an fd that
represents a seccomp layer, the idea being that you would set up your
seccomp layer (with syscall filter, landlock hooks, etc) and then you
would have a syscall to install that layer.  Then an unprivileged
sandbox manager could set up its layer and still be able to inject new
processes into it later on, no cgroups needed.

--Andy
