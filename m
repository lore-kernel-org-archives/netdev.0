From: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCH net-next v6 06/11] seccomp,landlock: Handle Landlock
 events per process hierarchy
Date: Tue, 18 Apr 2017 16:48:16 -0700
Message-ID: <CAGXu5jJnsHXvvuqfb3Rcw7HvubUEPoNQUmUVuRoc4_hqPpg4WQ@mail.gmail.com>
References: <20170328234650.19695-1-mic@digikod.net> <20170328234650.19695-7-mic@digikod.net>
 <CAGXu5jJ36E8L9=sh62vPy+0t84Bx4n4Y9eiYZU+DtUZom1vpCQ@mail.gmail.com> <a3c71579-4238-0967-b61d-522859f740aa@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
        Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Casey Schaufler <casey-iSGtlc1asvQWG2LlvL+J4A@public.gmane.org>,
        Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
        David Drysdale <drysdale-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
        "David S . Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "Eric W . Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Jann Horn <jann-XZ1E9jl8jIdeoWH0uzbU5w@public.gmane.org>, Jonathan Corbet <corbet-T1hC0tSOHrs@public.gmane.org>,
        Matthew Garrett <mjg59-1xO5oi07KQx4cg9Nei1l7Q@public.gmane.org>,
        Michael Kerrisk <mtk.manpages-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Sargun Dhillon <sargun-GaZTRHToo+CzQB+pC5nmwQ@public.gmane.org>,
        "Serge E . Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>,
        Shuah Khan <shuah-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>, Will Drewry <wa
To: =?UTF-8?B?TWlja2HDq2wgU2FsYcO8bg==?= <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <a3c71579-4238-0967-b61d-522859f740aa-WFhQfpSGs3bR7s880joybQ@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 18, 2017 at 4:24 PM, Micka=C3=ABl Sala=C3=BCn <mic-WFhQfpSGs3bR7s880joybQ@public.gmane.org>=
 wrote:
> On 19/04/2017 00:53, Kees Cook wrote:
>> On Tue, Mar 28, 2017 at 4:46 PM, Micka=C3=ABl Sala=C3=BCn <mic@digikod.n=
et> wrote:
>>> +#ifdef CONFIG_SECCOMP_FILTER
>>
>> Isn't CONFIG_SECCOMP_FILTER already required for landlock?
>
> Yes it is, but Landlock could only/also be used through cgroups in the
> future. :)

Hm, okay. I still feel like the configs could be more sensible. :)

>>> @@ -1405,7 +1409,13 @@ static void copy_seccomp(struct task_struct *p)
>>>
>>>         /* Ref-count the new filter user, and assign it. */
>>>         get_seccomp_filter(current);
>>> -       p->seccomp =3D current->seccomp;
>>> +       p->seccomp.mode =3D current->seccomp.mode;
>>> +       p->seccomp.filter =3D current->seccomp.filter;
>>> +#if defined(CONFIG_SECCOMP_FILTER) && defined(CONFIG_SECURITY_LANDLOCK=
)
>>> +       p->seccomp.landlock_events =3D current->seccomp.landlock_events=
;
>>> +       if (p->seccomp.landlock_events)
>>> +               atomic_inc(&p->seccomp.landlock_events->usage);
>>> +#endif /* CONFIG_SECCOMP_FILTER && CONFIG_SECURITY_LANDLOCK */
>>
>> Hrm. So, this needs config cleanup as above. Also, I'm going to need
>> some help understanding the usage tracking on landlock_events (which
>> should use a get/put rather than open-coding the _inc). I don't see
>> why individual assignments are needed here. The only thing that
>> matters is the usage bump. I would have expected no changes at all in
>> this code, actually. The filter and the events share the same usage
>> don't they?
>
> Right, I can move the struct landlock_event into the struct
> seccomp_filter. This should make the code cleaner.

No, that wasn't my point. I meant that since landlock_events is
already in ->seccomp, it's already copied by p->seccomp =3D
current->seccomp. The only thing you need is a
get_seccomp_landlock(current) call before the copy:

get_seccomp_filter(current);
get_seccomp_landlock(current);
p->seccomp =3D current->seccomp;

done! :)

And get_seccomp_landlock() can do a check for landlock_events existing, etc=
 etc.

>>> +       if (!new_events) {
>>> +               /*
>>> +                * If there is no Landlock events used by the current t=
ask,
>>> +                * then create a new one.
>>> +                */
>>> +               new_events =3D new_landlock_events();
>>> +               if (IS_ERR(new_events))
>>> +                       goto put_rule;
>>
>> Shouldn't bpf_prog_put() get called in the face of a rule failure too?
>> Why separate exit paths?
>
> You're right but put_landlock_rule() call bpf_prog_put() by itself.

Ah! Missed that, thanks!

>>> +       } else if (atomic_read(&current_events->usage) > 1) {
>>> +               /*
>>> +                * If the current task is not the sole user of its Land=
lock
>>> +                * events, then duplicate them.
>>> +                */
>>> +               size_t i;
>>> +
>>> +               new_events =3D new_landlock_events();
>>> +               if (IS_ERR(new_events))
>>> +                       goto put_rule;
>>> +               for (i =3D 0; i < ARRAY_SIZE(new_events->rules); i++) {
>>> +                       new_events->rules[i] =3D
>>> +                               lockless_dereference(current_events->ru=
les[i]);
>>> +                       if (new_events->rules[i])
>>> +                               atomic_inc(&new_events->rules[i]->usage=
);
>>
>> I was going to ask: isn't the top-level usage counter sufficient to
>> track rule lifetime? But I think I see how things are tracked now:
>> each task_struct points to an array of rule list pointers. These
>> tables are duplicated when additions are made (which means each table
>> needs to be refcounted for the processes using it), and when a new
>> table is created, all the refcounters on the rules are bumped (to
>> track each table that references the rule), and when a new rule is
>> added, it's just prepended to the list for the new table to point at.
>
> That's right.

Okay, excellent. This should end up in a comment somewhere so when I
forget I can go read it again. ;)

>> Does this mean that rules are processed in reverse?
>
> Yes, the rules are processed from the newest to the oldest, as
> seccomp-bpf does with filters.

Cool. If not already mentioned, that should end up in the docs somewhere.

>>> +       if (copy_from_user(&bpf_fd, user_bpf_fd, sizeof(bpf_fd)))
>>> +               return -EFAULT;
>>
>> I think this can just be get_user()?
>
> Yes, I didn't know about that.

No worries. It's nice for small things. :)

>>> +       prog =3D bpf_prog_get(bpf_fd);
>>> +       if (IS_ERR(prog))
>>> +               return PTR_ERR(prog);
>>> +
>>> +       /*
>>> +        * We don't need to lock anything for the current process hiera=
rchy,
>>> +        * everything is guarded by the atomic counters.
>>> +        */
>>> +       new_events =3D landlock_append_prog(current->seccomp.landlock_e=
vents,
>>> +                       prog);
>>> +       /* @prog is managed/freed by landlock_append_prog() */
>>
>> Does kmemcheck notice this "leak"? (i.e. is further annotation needed?)
>
> I didn't enable kmemcheck, I will take a look at it.

Yeah, I'd turn on at least these while you're testing:

CONFIG_PROVE_LOCKING=3Dy
CONFIG_DEBUG_ATOMIC_SLEEP=3Dy
CONFIG_DEBUG_KMEMLEAK=3Dy

I'm sure people will suggest more, too. :)

-Kees

--=20
Kees Cook
Pixel Security
