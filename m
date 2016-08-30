From: Andy Lutomirski <luto@amacapital.net>
Subject: Re: [RFC v2 09/10] landlock: Handle cgroups (performance)
Date: Tue, 30 Aug 2016 11:55:13 -0700
Message-ID: <CALCETrXU64+UApeKL_NogpBYk5kN7zA7UwkypZt8SYfvkuQrbA@mail.gmail.com>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
 <1472121165-29071-10-git-send-email-mic@digikod.net> <20160826021432.GA8291@ast-mbp.thefacebook.com>
 <57C05BF0.8000706@digikod.net> <20160826230539.GA26683@ast-mbp.thefacebook.com>
 <57C19E6E.6040908@digikod.net> <20160827180642.GA38754@ast-mbp.thefacebook.com>
 <57C1EB72.2050703@digikod.net> <20160827204307.GA43714@ast-mbp.thefacebook.com>
 <57C202BF.7000207@digikod.net> <CALCETrXgQ+njtupXiKcOXG8ZRzD=n2LhT45NiJr1Ehob7bHskQ@mail.gmail.com>
 <57C2B21E.9040705@digikod.net>
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
Received: from mail-ua0-f175.google.com ([209.85.217.175]:36106 "EHLO
        mail-ua0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750825AbcH3Sze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 14:55:34 -0400
Received: by mail-ua0-f175.google.com with SMTP id m60so49111506uam.3
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 11:55:34 -0700 (PDT)
In-Reply-To: <57C2B21E.9040705@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 28, 2016 at 2:42 AM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.net>=
 wrote:
>
>
> On 28/08/2016 10:13, Andy Lutomirski wrote:
>> On Aug 27, 2016 11:14 PM, "Micka=C3=ABl Sala=C3=BCn" <mic@digikod.net> w=
rote:
>>>
>>>
>>> On 27/08/2016 22:43, Alexei Starovoitov wrote:
>>>> On Sat, Aug 27, 2016 at 09:35:14PM +0200, Micka=C3=ABl Sala=C3=BCn wro=
te:
>>>>> On 27/08/2016 20:06, Alexei Starovoitov wrote:
>>>>>> On Sat, Aug 27, 2016 at 04:06:38PM +0200, Micka=C3=ABl Sala=C3=BCn w=
rote:
>>>>>>> As said above, Landlock will not run an eBPF programs when not stri=
ctly
>>>>>>> needed. Attaching to a cgroup will have the same performance impact=
 as
>>>>>>> attaching to a process hierarchy.
>>>>>>
>>>>>> Having a prog per cgroup per lsm_hook is the only scalable way I
>>>>>> could come up with. If you see another way, please propose.
>>>>>> current->seccomp.landlock_prog is not the answer.
>>>>>
>>>>> Hum, I don't see the difference from a performance point of view betw=
een
>>>>> a cgroup-based or a process hierarchy-based system.
>>>>>
>>>>> Maybe a better option should be to use an array of pointers with N
>>>>> entries, one for each supported hook, instead of a unique pointer lis=
t?
>>>>
>>>> yes, clearly array dereference is faster than link list walk.
>>>> Now the question is where to keep this prog_array[num_lsm_hooks] ?
>>>> Since we cannot keep it inside task_struct, we have to allocate it.
>>>> Every time the task is creted then. What to do on the fork? That
>>>> will require changes all over. Then the obvious optimization would be
>>>> to share this allocated array of prog pointers across multiple tasks..=
.
>>>> and little by little this new facility will look like cgroup.
>>>> Hence the suggestion to put this array into cgroup from the start.
>>>
>>> I see your point :)
>>>
>>>>
>>>>> Anyway, being able to attach an LSM hook program to a cgroup thanks t=
o
>>>>> the new BPF_PROG_ATTACH seems a good idea (while keeping the possibil=
ity
>>>>> to use a process hierarchy). The downside will be to handle an LSM ho=
ok
>>>>> program which is not triggered by a seccomp-filter, but this should b=
e
>>>>> needed anyway to handle interruptions.
>>>>
>>>> what do you mean 'not triggered by seccomp' ?
>>>> You're not suggesting that this lsm has to enable seccomp to be functi=
onal?
>>>> imo that's non starter due to overhead.
>>>
>>> Yes, for now, it is triggered by a new seccomp filter return value
>>> RET_LANDLOCK, which can take a 16-bit value called cookie. This must no=
t
>>> be needed but could be useful to bind a seccomp filter security policy
>>> with a Landlock one. Waiting for Kees's point of view=E2=80=A6
>>>
>>
>> I'm not Kees, but I'd be okay with that.  I still think that doing
>> this by process hierarchy a la seccomp will be easier to use and to
>> understand (which is quite important for this kind of work) than doing
>> it by cgroup.
>>
>> A feature I've wanted to add for a while is to have an fd that
>> represents a seccomp layer, the idea being that you would set up your
>> seccomp layer (with syscall filter, landlock hooks, etc) and then you
>> would have a syscall to install that layer.  Then an unprivileged
>> sandbox manager could set up its layer and still be able to inject new
>> processes into it later on, no cgroups needed.
>
> A nice thing I didn't highlight about Landlock is that a process can
> prepare a layer of rules (arraymap of handles + Landlock programs) and
> pass the file descriptors of the Landlock programs to another process.
> This process could then apply this programs to get sandboxed. However,
> for now, because a Landlock program is only triggered by a seccomp
> filter (which do not follow the Landlock programs as a FD), they will be
> useless.
>
> The FD referring to an arraymap of handles can also be used to update a
> map and change the behavior of a Landlock program. A master process can
> then add or remove restrictions to another process hierarchy on the fly.

Maybe this could be extended a little bit.  The fd could hold the
seccomp filter *and* the LSM hook filters.  FMODE_EXECUTE could give
the ability to install it and FMODE_WRITE could give the ability to
modify it.
