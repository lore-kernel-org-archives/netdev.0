From: Kees Cook <keescook@google.com>
Subject: Re: [PATCH v4 next 1/3] modules:capabilities: allow
 __request_module() to take a capability argument
Date: Tue, 23 May 2017 12:19:12 -0700
Message-ID: <CAGXu5j+L1aEWqi7DC4StwAorfG4da0XqrouMvbz07cJ7gYi0AQ@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <1495454226-10027-2-git-send-email-tixxdz@gmail.com> <CAGXu5jL9jRDkHj20kf4O6VrjiEpvXGzN3nn5Lw4fT2sx_Xg=+A@mail.gmail.com>
 <CAEiveUe5cTCet6=Uzn64YANRZ2Qyqk5OSXqU3MybevbkbeNR3Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andy Lutomirski <luto@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, Rusty Russell <rusty@rustcorp.com.au>,
	"Serge E. Hallyn" <serge@hallyn.com>, Jessica Yu <jeyu@redhat.com>,
	"David S. Miller" <davem@davemloft.net>, James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ingo Molnar <mingo@kernel.org>,
	Linux API <linux-api@vger.kernel.org>, Dongsu Park <dpark@posteo.net>,
	Casey Schaufler <casey@schaufler-ca.com>, Jonathan Corbet <corbet@lwn.net>,
	Arnaldo Carvalho de Melo <acme@
To: Djalal Harouni <tixxdz@gmail.com>
Return-path: <kernel-hardening-return-8000-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAEiveUe5cTCet6=Uzn64YANRZ2Qyqk5OSXqU3MybevbkbeNR3Q@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 3:29 AM, Djalal Harouni <tixxdz@gmail.com> wrote:
> On Tue, May 23, 2017 at 12:20 AM, Kees Cook <keescook@chromium.org> wrote:
>> On Mon, May 22, 2017 at 4:57 AM, Djalal Harouni <tixxdz@gmail.com> wrote:
>>> This is a preparation patch for the module auto-load restriction feature.
>>>
>>> In order to restrict module auto-load operations we need to check if the
>>> caller has CAP_SYS_MODULE capability. This allows to align security
>>> checks of automatic module loading with the checks of the explicit operations.
>>>
>>> However for "netdev-%s" modules, they are allowed to be loaded if
>>> CAP_NET_ADMIN is set. Therefore, in order to not break this assumption,
>>> and allow userspace to only load "netdev-%s" modules with CAP_NET_ADMIN
>>> capability which is considered a privileged operation, we have two
>>> choices: 1) parse "netdev-%s" alias and check the capability or 2) hand
>>> the capability form request_module() to security_kernel_module_request()
>>> hook and let the capability subsystem decide.
>>>
>>> After a discussion with Rusty Russell [1], the suggestion was to pass
>>> the capability from request_module() to security_kernel_module_request()
>>> for 'netdev-%s' modules that need CAP_NET_ADMIN.
>>>
>>> The patch does not update request_module(), it updates the internal
>>> __request_module() that will take an extra "allow_cap" argument. If
>>> positive, then automatic module load operation can be allowed.
>>
>> I find this refactor slightly confusing. I would expect to collapse
>> the existing caps checks in net/core/dev_ioctl.c and
>> net/ipv4/tcp_cong.c, and make this a "required cap" argument, and to
>> add a new non-__ function instead of requiring callers use
>> __request_module.
>>
>> request_module_capable(int cap_required, fmt, args);
>>
>> adjust __request_module() for the new arg, and when cap_required !=
>> -1, perform a cap check.
>>
>> Then make request_module pass -1 to __request_module(), and change
>> dev_ioctl.c (and tcp_cong.c) from:
>>
>>         if (no_module && capable(CAP_NET_ADMIN))
>>                 no_module = request_module("netdev-%s", name);
>>         if (no_module && capable(CAP_SYS_MODULE))
>>                 request_module("%s", name);
>>
>> to:
>>
>>         if (no_module)
>>                 no_module = request_module_capable(CAP_NET_ADMIN,
>> "netdev-%s", name);
>>         if (no_module)
>>                 no_module = request_module_capable(CAP_SYS_MODULE, "%s", name);
>>
>> that'll make the code cleaner, too.
>
> The refactoring in the patch is more for backward compatibility with
> CAP_NET_ADMIN,
> as discussed here: https://lkml.org/lkml/2017/4/26/147

I think Rusty and I are saying the same thing here, and I must be not
understanding something you're trying to explain. Apologies for being
dense.

> I think if there is an interface request_module_capable() , then code
> will use it. The DCCP code path did not check capabilities at all and
> called request_module(), other code does the same.
>
> A new interface can be abused, the result of this: we may break
> "modules_autoload_mode" in mode 0 and 1. In the long term code will
> want to change may_autoload_module() to also allow mode 1 to load a
> module with CAP_NET_ADMIN or other caps in its own userns, resulting
> in "modules_autoload_mode == 0 == 1". Without userns in the game we
> may just see request_module_capable(CAP_SYS_ADMIN, ...)  . There is
> already some code maybe phonet sockets ? that require CAP_SYS_ADMIN to
> get the appropriate protocol.... and no one will be able to review all
> this code or track new patches with request_module_capable() callers.

I'm having some trouble following what you're saying here, but if I
understand, you're worried about getting the kernel into a state where
autoload state 0 == 1. Autoload 0 is "business as usual", and autoload
1 is "CAP_SYS_MODULE required to be able to trigger a module auto-load
operation, or CAP_NET_ADMIN for modules with a 'netdev-%s' alias."

In the v4 patch, under autoload==1, CAP_NET_ADMIN is needed to load
netdev- modules:

        if (no_module && capable(CAP_NET_ADMIN))
               no_module = __request_module(true, CAP_NET_ADMIN,
                                            "netdev-%s", name);

and in the LSM hook, CAP_NET_ADMIN is passed as an allowable "alias"
for the CAP_SYS_MODULE requirement:

       else if (modules_autoload_mode == MODULES_AUTOLOAD_PRIVILEGED) {
               /* Check CAP_SYS_MODULE then allow_cap if valid */
               if (capable(CAP_SYS_MODULE) ||
                   (allow_cap > 0 && capable(allow_cap)))
                      return 0;
       }

What I see is some needless double-checking. Since you're making
changes to the request_module() API, it would be possible to have
request_module_cap(), which could be checked instead of open-coding
it:

     if (no_module)
        no_module = request_module_cap(CAP_NET_ADMIN, "netdev-%s", name);

If I'm understanding your objection correctly, it's that you want to
ONLY ever provide this one-time alias for CAP_SYS_MODULE with the
netdev-%s things, and you don't want to risk having other module
loading start using request_module_cap() which would lead to
CAP_SYS_MODULE aliases in other places?

If the goal is to make sure that only privileged processes are
autoloading, I don't think adding a well defined interface for
cap-checks (request_module_cap()) would lead to a slippery slope. The
worst case scenario (which would never happen) would be all
request_module() users would convert to request_module_cap(). This
would mean that all module loading would require specific privileges.
That seems in line with autoload==1. They would not be tied to
CAP_SYS_MODULE, though, which is, I suspect, what you're concerned
about.

Even in the existing code, there is a sense about CAP_NET_ADMIN and
CAP_SYS_MODULE having different privilege levels, in that
CAP_NET_ADMIN can only load netdev-%s modules, but CAP_SYS_MODULE can
load any module. What about refining request_module_cap() to _require_
an explicit string prefix instead of an arbitrary format string? e.g.
request_module_cap(CAP_NET_ADMIN, "netdev", "%s", name) which would
make requests for ("netdev-%s", name)

I see a few options:

1) keep what you have for v4, and hope other places don't use
__request_module. (I'm not a fan of this.)

2) switch the logic on autoload==1 from OR to AND: both the specified
caps _and_ CAP_SYS_MODULE are required. (This seems like it might make
autoload==1 less useful.)

3) use the request_module_cap() outlined above, which requires that
modules being loaded under a CAP_SYS_MODULE-aliased capability are at
least restricted to a subset of kernel module names.

4) same as 3 but also insert autoload==2 level that switches from OR
to AND (bumping existing ==2 to ==3).

What do you think?

-Kees

-- 
Kees Cook
Pixel Security
