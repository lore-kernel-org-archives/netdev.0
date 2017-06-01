From: Djalal Harouni <tixxdz@gmail.com>
Subject: Re: [PATCH v4 next 1/3] modules:capabilities: allow
 __request_module() to take a capability argument
Date: Thu, 1 Jun 2017 16:56:30 +0200
Message-ID: <CAEiveUeKU-zxXUeeuTZ2Sf1NrbH+t9JjwaWOK_2varRDsfbEWg@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <1495454226-10027-2-git-send-email-tixxdz@gmail.com> <CAGXu5jL9jRDkHj20kf4O6VrjiEpvXGzN3nn5Lw4fT2sx_Xg=+A@mail.gmail.com>
 <CAEiveUe5cTCet6=Uzn64YANRZ2Qyqk5OSXqU3MybevbkbeNR3Q@mail.gmail.com>
 <CAGXu5j+L1aEWqi7DC4StwAorfG4da0XqrouMvbz07cJ7gYi0AQ@mail.gmail.com>
 <CAEiveUeZhHtPyLv8=3BsPh5Anr2ynnzD0bprUkeKUGygtRQKsw@mail.gmail.com> <CAGXu5jK5exWBV+ub8ys86Ubu1vKwN=miOZxwp3zdWaWEfuJddQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Cc: "Serge E. Hallyn" <serge@hallyn.com>, Rusty Russell <rusty@rustcorp.com.au>,
	"David S . Miller" <davem@davemloft.net>, Jessica Yu <jeyu@redhat.com>,
	LKML <linux-kernel@vger.kernel.org>, Network Development <netdev@vger.kernel.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andy Lutomirski <luto@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ingo Molnar <mingo@kernel.org>,
	Linux API <linux-api@vger.kernel.org>, Dongsu Park <dpark@posteo.net>,
	Casey Schaufler <casey@schaufler-ca.com>, Jonathan Corbet <corbet@lwn.net>,
	Arnaldo Carvalho de Melo <acme@r
To: Kees Cook <keescook@google.com>
Return-path: <kernel-hardening-return-8179-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5jK5exWBV+ub8ys86Ubu1vKwN=miOZxwp3zdWaWEfuJddQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Tue, May 30, 2017 at 7:59 PM, Kees Cook <keescook@google.com> wrote:
[...]
>>> I see a few options:
>>>
>>> 1) keep what you have for v4, and hope other places don't use
>>> __request_module. (I'm not a fan of this.)
>>
>> Yes even if it is documented I wouldn't bet on it, though. :-)
>
> Okay, we seem to agree: we'll not use #1.
>
>>> 2) switch the logic on autoload=3D=3D1 from OR to AND: both the specifi=
ed
>>> caps _and_ CAP_SYS_MODULE are required. (This seems like it might make
>>> autoload=3D=3D1 less useful.)
>>
>> That will restrict some userspace that works only with CAP_NET_ADMIN.
>
> Nor #2.
>
>>> 3) use the request_module_cap() outlined above, which requires that
>>> modules being loaded under a CAP_SYS_MODULE-aliased capability are at
>>> least restricted to a subset of kernel module names.
>>
>> This one tends to allow usability.
>
> Right, discussed below...
>
>>> 4) same as 3 but also insert autoload=3D=3D2 level that switches from O=
R
>>> to AND (bumping existing =3D=3D2 to =3D=3D3).
>>
>> I wouldn't expose autoload to callers, I think it is better if it
>> stays a property of the module subsystem. But lets use the bump idea,
>> please see below.
>
> If we can't agree below, I think #4 would be a good way to allow for
> both states.

Ok!


>>> What do you think?
>>
>> Ok so given that we already have modules_autoload_mode=3D2 disabled,
>> maybe we go with 3)  like this ?
>>
>> int __request_module(bool wait, int required_cap, const char *prefix,
>> const char *name, ...);
>> #define request_module(mod...) \
>>         __request_module(true, -1, NULL, mod)
>> #define request_module_cap(required_cap, prefix, mod...) \
>>         __request_module(true, required_cap, prefix, mod)
>>
>> and we require allow_cap and prefix to be set.
>>
>> request_module_cap(CAP_NET_ADMIN, "netdev-", "%s", name) for
>> net/core/dev_ioctl.c:dev_load()
>>
>> request_module_cap(CAP_NET_ADMIN, "tcp_", "%s", name) for
>> net/ipv4/tcp_cong.c  functions.
>>
>>
>> Then
>> __request_module()
>>   -> security_kernel_module_request(module_name, required_cap, prefix)
>>      -> may_autoload_module(current, module_name, required_cap, prefix)
>>
>>
>> And update may_autoload_module() as below ? we hard code CAP_NET_ADMIN
>> and CAP_SYS_MODULE inside and make them the only capabilities needed
>> for a privileged auto-load operation.
>
> I still think making a specific exception for CAP_NET_ADMIN is not the
> right solution, instead allowing for non-CAP_SYS_MODULE caps when
> using a distinct prefix.

Alright! I would have loved to avoid capabilities game, but these
patches also use them... so worst scenario is the per-task can always
be set, "task->module_autoload_mode=3D2" and block it if necessary.


>> request_module_cap(CAP_SYS_MODULE, ...) or
>> request_module_cap(CAP_NET_ADMIN, ...) if the autoload should be a
>> privileged operation.
>>
>> Kees will this work ?
>>
>> Jessica,  Rusty,  Serge. What do you think ? I definitively think that
>> module_autoload should be contained only inside the module subsystem..
>
> I'd change it like this:
>
>> +int may_autoload_module(struct task_struct *task, char *kmod_name,
>> +                       int require_cap, char *prefix)
>> +{
>> +       unsigned int autoload;
>> +       int module_require_cap =3D 0;
>
> I'd initialize this to module_require_cap =3D CAP_SYS_MODULE;

Ok, please see below.



>> +
>> +       if (require_cap > 0) {
>> +               if (prefix =3D=3D NULL || *prefix =3D=3D '\0')
>> +                       return -EPERM;
>
> Since an unprefixed module load should only be CAP_SYS_MODULE, change
> the above "if" to:
>
>     if (require_cap > 0 && prefix !=3D NULL && *prefix !=3D '\0')
>
>> +
>> +               /*
>> +                * We only allow CAP_SYS_MODULE or CAP_NET_ADMIN for
>> +                * 'netdev-%s' modules for backward compatibility.
>> +                * Please do not overload capabilities.
>> +                */
>> +               if (require_cap =3D=3D CAP_SYS_MODULE ||
>> +                   require_cap =3D=3D CAP_NET_ADMIN)
>> +                       module_require_cap =3D require_cap;
>> +               else
>> +                       return -EPERM;
>> +       }
>
> And then drop all these checks, leaving only:
>
>         module_require_cap =3D require_cap;
>
>> +
>> +       /* Get max value of sysctl and task "modules_autoload_mode" */
>> +       autoload =3D max_t(unsigned int, modules_autoload_mode,
>> +                        task->modules_autoload_mode);
>> +
>> +       /*
>> +        * If autoload is disabled then fail here and not bother at all
>> +        */
>> +       if (autoload =3D=3D MODULES_AUTOLOAD_DISABLED)
>> +               return -EPERM;
>> +
>> +       /*
>> +        * If caller require capabilities then we may not allow
>> +        * automatic module loading. We should not bypass callers.
>> +        * This allows to support networking code that uses CAP_NET_ADMI=
N
>> +        * for some aliased 'netdev-%s' modules.
>> +        *
>> +        * Explicitly bump autoload here if necessary
>> +        */
>> +       if (module_require_cap && autoload =3D=3D MODULES_AUTOLOAD_ALLOW=
ED)
>> +               autoload =3D MODULES_AUTOLOAD_PRIVILEGED;
>
> I don't see a reason to bump the autoload level.
>
>> +
>> +       if (autoload =3D=3D MODULES_AUTOLOAD_ALLOWED)
>> +               return 0;
>
> This test can be moved to above the AUTOLOAD_DISABLED test.
>
>> +       else if(autoload =3D=3D MODULES_AUTOLOAD_PRIVILEGED) {
>> +               /*
>> +                * If module auto-load is a privileged operation then ch=
eck
>> +                * if capabilities are set.
>> +                */
>> +               if (capable(CAP_SYS_MODULE) ||
>> +                   (module_require_cap && capable(module_require_cap)))
>> +                       return 0;
>> +       }
>
> This test could drop the explicit CAP_SYS_MODULE test and just rely on
> module_require_cap.
>
>> +
>> +       return -EPERM;
>> +}
>> +
>
> So, I would suggest:

Ok Kees, I will update based on your feedback, except for the
following, please see below and let me know :-)


>
> int may_autoload_module(struct task_struct *task, char *kmod_name,
>                        int require_cap, char *prefix)
> {
>         unsigned int autoload;
>         int module_require_cap;
>
>         if (autoload =3D=3D MODULES_AUTOLOAD_DISABLED)
>                 return -EPERM;
>
>         /* Get max value of sysctl and task "modules_autoload_mode" */
>         autoload =3D max_t(unsigned int, modules_autoload_mode,
>                         task->modules_autoload_mode);
>
>         if (autoload =3D=3D MODULES_AUTOLOAD_ALLOWED)
>                 return 0;

I don't think that the MODULES_AUTOLOAD_ALLOWED check here at this
place is the best thing to do.

If we remove the capable(CAP_NET_ADMIN) from net/core/dev_ioctl:dev_load()

http://elixir.free-electrons.com/linux/v4.12-rc3/source/net/core/dev_ioctl.=
c#L369

Or if future changes (accidental) remove that capable(CAP_NET_ADMIN)
and replace it with:
   request_module_cap(CAP_NET_ADMIN, "netdev-", "%s", name);


Then we will check the requested capability *after* autoload allowed
as it is in this example, it should be checked *before* the autoload
allowed:
        // Check required capability before this
        if (autoload =3D=3D MODULES_AUTOLOAD_ALLOWED)
                return 0;

This way we are still safe we do not downgrade the required capability
that was requested by the calling subsystem based on
MODULES_AUTOLOAD_ALLOWED. If networking code or any other code thinks
that we need CAP_X to load a module then we should honor it. So we do
not break current usage by introducing the "modules_autoload_mode", it
should be set regardless of the autoload mode. Especially since
modules autoload mode is 0 by default. This avoids breaking current
rule to require CAP_NET_ADMIN for 'netdev=C3=A8-%'


>         /*
>          * It should be impossible for autoload to have any other
>          * value at this point, so explicitly reject all other states.
>          */
>         if (autoload !=3D MODULES_AUTOLOAD_PRIVILEGED)
>                 return -EPERM;
>
>         /* Verify that alternate capabilities requirements had a prefix. =
*/
>         if (require_cap > 0 && prefix !=3D NULL && *prefix !=3D '\0')
>                 module_require_cap =3D require_cap;
>         else
>                 module_require_cap =3D CAP_SYS_MODULE;
>
>         return capable(module_require_cap);

So with your code, but I really think that we should treat
MODULES_AUTOLOAD_ALLOWED with special care in regard of the passed
capabilities, so:


        module_require_cap =3D 0;

        if (autoload =3D=3D MODULES_AUTOLOAD_DISABLED)
                return -EPERM;

        if (autoload =3D=3D MODULES_AUTOLOAD_PRIVILEGED || require_cap > 0)=
 {
                if (prefix !=3D NULL && *prefix !=3D '\0')
                        /*
                         * Allow non-CAP_SYS_MODULE caps when
                         * using a distinct prefix.
                         */
                        module_require_cap =3D require_cap;
                else
                        /*
                         * Otherwise always require CAP_SYS_MODULE if no
                         * valid prefix. Callers that do not provide a
valid prefix
                         * should not provide a require_cap > 0
                         */
                        module_require_cap =3D CAP_SYS_MODULE;
        }

        /* If autoload allowed and 'module_require_cap' was *never*
set, allow */
        if (module_require_cap =3D=3D 0 && autoload =3D=3D MODULES_AUTOLOAD=
_ALLOWED)
                return 0;

        return capable(module_require_cap) ? 0 : -EPERM;
> }
>

Maybe you will agree :-) ?

BTW Kees, also in next version I won't remove the
capable(CAP_NET_ADMIN) check from [1]
even if there is the new request_module_cap(), I would like it to be
in a different patches, this way we go incremental
and maybe it is better to merge what we have now ?  and follow up
later, and of course if other maintainers agree too!

I just need a bit of free time to check again everything and will send
a v5 with all requested changes.


Thank you Kees for your time!

[1] http://elixir.free-electrons.com/linux/v4.12-rc3/source/net/core/dev_io=
ctl.c#L369
