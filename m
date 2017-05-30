From: Kees Cook <keescook@google.com>
Subject: Re: [PATCH v4 next 1/3] modules:capabilities: allow
 __request_module() to take a capability argument
Date: Tue, 30 May 2017 10:59:06 -0700
Message-ID: <CAGXu5jK5exWBV+ub8ys86Ubu1vKwN=miOZxwp3zdWaWEfuJddQ@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <1495454226-10027-2-git-send-email-tixxdz@gmail.com> <CAGXu5jL9jRDkHj20kf4O6VrjiEpvXGzN3nn5Lw4fT2sx_Xg=+A@mail.gmail.com>
 <CAEiveUe5cTCet6=Uzn64YANRZ2Qyqk5OSXqU3MybevbkbeNR3Q@mail.gmail.com>
 <CAGXu5j+L1aEWqi7DC4StwAorfG4da0XqrouMvbz07cJ7gYi0AQ@mail.gmail.com> <CAEiveUeZhHtPyLv8=3BsPh5Anr2ynnzD0bprUkeKUGygtRQKsw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Serge E. Hallyn" <serge@hallyn.com>,
        Rusty Russell <rusty@rustcorp.com.au>,
        "David S . Miller" <davem@davemloft.net>,
        Jessica Yu <jeyu@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-security-module <linux-security-module@vger.kernel.org>,
        "kernel-hardening@lists.openwall.com"
        <kernel-hardening@lists.openwall.com>,
        Andy Lutomirski <luto@kernel.org>,
        Andrew Morton <akpm@linux-foundation.org>,
        James Morris <james.l.morris@oracle.com>,
        Paul Moore <paul@paul-moore.com>,
        Stephen Smalley <sds@tycho.nsa.gov>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
        Ingo Molnar <mingo@kernel.org>,
        Linux API <linux-api@vger.kernel.org>,
        Dongsu Park <dpar
To: Djalal Harouni <tixxdz@gmail.com>
Return-path: <linux-doc-owner@vger.kernel.org>
In-Reply-To: <CAEiveUeZhHtPyLv8=3BsPh5Anr2ynnzD0bprUkeKUGygtRQKsw@mail.gmail.com>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 24, 2017 at 7:16 AM, Djalal Harouni <tixxdz@gmail.com> wrote:
> On Tue, May 23, 2017 at 9:19 PM, Kees Cook <keescook@google.com> wrote:
>> On Tue, May 23, 2017 at 3:29 AM, Djalal Harouni <tixxdz@gmail.com> wrote:
>> Even in the existing code, there is a sense about CAP_NET_ADMIN and
>> CAP_SYS_MODULE having different privilege levels, in that
>> CAP_NET_ADMIN can only load netdev-%s modules, but CAP_SYS_MODULE can
>> load any module. What about refining request_module_cap() to _require_
>> an explicit string prefix instead of an arbitrary format string? e.g.
>> request_module_cap(CAP_NET_ADMIN, "netdev", "%s", name) which would
>> make requests for ("netdev-%s", name)
>>
>> I see a few options:
>>
>> 1) keep what you have for v4, and hope other places don't use
>> __request_module. (I'm not a fan of this.)
>
> Yes even if it is documented I wouldn't bet on it, though. :-)

Okay, we seem to agree: we'll not use #1.

>> 2) switch the logic on autoload==1 from OR to AND: both the specified
>> caps _and_ CAP_SYS_MODULE are required. (This seems like it might make
>> autoload==1 less useful.)
>
> That will restrict some userspace that works only with CAP_NET_ADMIN.

Nor #2.

>> 3) use the request_module_cap() outlined above, which requires that
>> modules being loaded under a CAP_SYS_MODULE-aliased capability are at
>> least restricted to a subset of kernel module names.
>
> This one tends to allow usability.

Right, discussed below...

>> 4) same as 3 but also insert autoload==2 level that switches from OR
>> to AND (bumping existing ==2 to ==3).
>
> I wouldn't expose autoload to callers, I think it is better if it
> stays a property of the module subsystem. But lets use the bump idea,
> please see below.

If we can't agree below, I think #4 would be a good way to allow for
both states.

>> What do you think?
>
> Ok so given that we already have modules_autoload_mode=2 disabled,
> maybe we go with 3)  like this ?
>
> int __request_module(bool wait, int required_cap, const char *prefix,
> const char *name, ...);
> #define request_module(mod...) \
>         __request_module(true, -1, NULL, mod)
> #define request_module_cap(required_cap, prefix, mod...) \
>         __request_module(true, required_cap, prefix, mod)
>
> and we require allow_cap and prefix to be set.
>
> request_module_cap(CAP_NET_ADMIN, "netdev-", "%s", name) for
> net/core/dev_ioctl.c:dev_load()
>
> request_module_cap(CAP_NET_ADMIN, "tcp_", "%s", name) for
> net/ipv4/tcp_cong.c  functions.
>
>
> Then
> __request_module()
>   -> security_kernel_module_request(module_name, required_cap, prefix)
>      -> may_autoload_module(current, module_name, required_cap, prefix)
>
>
> And update may_autoload_module() as below ? we hard code CAP_NET_ADMIN
> and CAP_SYS_MODULE inside and make them the only capabilities needed
> for a privileged auto-load operation.

I still think making a specific exception for CAP_NET_ADMIN is not the
right solution, instead allowing for non-CAP_SYS_MODULE caps when
using a distinct prefix.

> request_module_cap(CAP_SYS_MODULE, ...) or
> request_module_cap(CAP_NET_ADMIN, ...) if the autoload should be a
> privileged operation.
>
> Kees will this work ?
>
> Jessica,  Rusty,  Serge. What do you think ? I definitively think that
> module_autoload should be contained only inside the module subsystem..

I'd change it like this:

> +int may_autoload_module(struct task_struct *task, char *kmod_name,
> +                       int require_cap, char *prefix)
> +{
> +       unsigned int autoload;
> +       int module_require_cap = 0;

I'd initialize this to module_require_cap = CAP_SYS_MODULE;

> +
> +       if (require_cap > 0) {
> +               if (prefix == NULL || *prefix == '\0')
> +                       return -EPERM;

Since an unprefixed module load should only be CAP_SYS_MODULE, change
the above "if" to:

    if (require_cap > 0 && prefix != NULL && *prefix != '\0')

> +
> +               /*
> +                * We only allow CAP_SYS_MODULE or CAP_NET_ADMIN for
> +                * 'netdev-%s' modules for backward compatibility.
> +                * Please do not overload capabilities.
> +                */
> +               if (require_cap == CAP_SYS_MODULE ||
> +                   require_cap == CAP_NET_ADMIN)
> +                       module_require_cap = require_cap;
> +               else
> +                       return -EPERM;
> +       }

And then drop all these checks, leaving only:

        module_require_cap = require_cap;

> +
> +       /* Get max value of sysctl and task "modules_autoload_mode" */
> +       autoload = max_t(unsigned int, modules_autoload_mode,
> +                        task->modules_autoload_mode);
> +
> +       /*
> +        * If autoload is disabled then fail here and not bother at all
> +        */
> +       if (autoload == MODULES_AUTOLOAD_DISABLED)
> +               return -EPERM;
> +
> +       /*
> +        * If caller require capabilities then we may not allow
> +        * automatic module loading. We should not bypass callers.
> +        * This allows to support networking code that uses CAP_NET_ADMIN
> +        * for some aliased 'netdev-%s' modules.
> +        *
> +        * Explicitly bump autoload here if necessary
> +        */
> +       if (module_require_cap && autoload == MODULES_AUTOLOAD_ALLOWED)
> +               autoload = MODULES_AUTOLOAD_PRIVILEGED;

I don't see a reason to bump the autoload level.

> +
> +       if (autoload == MODULES_AUTOLOAD_ALLOWED)
> +               return 0;

This test can be moved to above the AUTOLOAD_DISABLED test.

> +       else if(autoload == MODULES_AUTOLOAD_PRIVILEGED) {
> +               /*
> +                * If module auto-load is a privileged operation then check
> +                * if capabilities are set.
> +                */
> +               if (capable(CAP_SYS_MODULE) ||
> +                   (module_require_cap && capable(module_require_cap)))
> +                       return 0;
> +       }

This test could drop the explicit CAP_SYS_MODULE test and just rely on
module_require_cap.

> +
> +       return -EPERM;
> +}
> +

So, I would suggest:

int may_autoload_module(struct task_struct *task, char *kmod_name,
                       int require_cap, char *prefix)
{
        unsigned int autoload;
        int module_require_cap;

        if (autoload == MODULES_AUTOLOAD_DISABLED)
                return -EPERM;

        /* Get max value of sysctl and task "modules_autoload_mode" */
        autoload = max_t(unsigned int, modules_autoload_mode,
                        task->modules_autoload_mode);

        if (autoload == MODULES_AUTOLOAD_ALLOWED)
                return 0;

        /*
         * It should be impossible for autoload to have any other
         * value at this point, so explicitly reject all other states.
         */
        if (autoload != MODULES_AUTOLOAD_PRIVILEGED)
                return -EPERM;

        /* Verify that alternate capabilities requirements had a prefix. */
        if (require_cap > 0 && prefix != NULL && *prefix != '\0')
                module_require_cap = require_cap;
        else
                module_require_cap = CAP_SYS_MODULE;

        return capable(module_require_cap);
}

-Kees

-- 
Kees Cook
Pixel Security
