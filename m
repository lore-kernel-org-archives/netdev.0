From: Djalal Harouni <tixxdz@gmail.com>
Subject: Re: [PATCH v4 next 1/3] modules:capabilities: allow
 __request_module() to take a capability argument
Date: Wed, 24 May 2017 16:16:32 +0200
Message-ID: <CAEiveUeZhHtPyLv8=3BsPh5Anr2ynnzD0bprUkeKUGygtRQKsw@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <1495454226-10027-2-git-send-email-tixxdz@gmail.com> <CAGXu5jL9jRDkHj20kf4O6VrjiEpvXGzN3nn5Lw4fT2sx_Xg=+A@mail.gmail.com>
 <CAEiveUe5cTCet6=Uzn64YANRZ2Qyqk5OSXqU3MybevbkbeNR3Q@mail.gmail.com> <CAGXu5j+L1aEWqi7DC4StwAorfG4da0XqrouMvbz07cJ7gYi0AQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	linux-security-module <linux-security-module@vger.kernel.org>,
	"kernel-hardening@lists.openwall.com" <kernel-hardening@lists.openwall.com>, Andy Lutomirski <luto@kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>, James Morris <james.l.morris@oracle.com>,
	Paul Moore <paul@paul-moore.com>, Stephen Smalley <sds@tycho.nsa.gov>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Ingo Molnar <mingo@kernel.org>,
	Linux API <linux-api@vger.kernel.org>, Dongsu Park <dpark@posteo.net>,
	Casey Schaufler <casey@schaufler-ca.com>, Jonathan Corbet <corbet@lwn.net>,
	Arnaldo Carvalho de Melo <acme@redhat.com>, Mauro Carvalho Chehab <mchehab@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>, Zendyani <zendyani@gmail.com>,
	"linux-doc@vger.kerne
To: Kees Cook <keescook@google.com>, "Serge E. Hallyn" <serge@hallyn.com>,
	Rusty Russell <rusty@rustcorp.com.au>, "David S . Miller" <davem@davemloft.net>,
	Jessica Yu <jeyu@redhat.com>
Return-path: <kernel-hardening-return-8010-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <CAGXu5j+L1aEWqi7DC4StwAorfG4da0XqrouMvbz07cJ7gYi0AQ@mail.gmail.com>
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 9:19 PM, Kees Cook <keescook@google.com> wrote:
> On Tue, May 23, 2017 at 3:29 AM, Djalal Harouni <tixxdz@gmail.com> wrote:
[...]

>> I think if there is an interface request_module_capable() , then code
>> will use it. The DCCP code path did not check capabilities at all and
>> called request_module(), other code does the same.
>>
>> A new interface can be abused, the result of this: we may break
>> "modules_autoload_mode" in mode 0 and 1. In the long term code will
>> want to change may_autoload_module() to also allow mode 1 to load a
>> module with CAP_NET_ADMIN or other caps in its own userns, resulting
>> in "modules_autoload_mode == 0 == 1". Without userns in the game we
>> may just see request_module_capable(CAP_SYS_ADMIN, ...)  . There is
>> already some code maybe phonet sockets ? that require CAP_SYS_ADMIN to
>> get the appropriate protocol.... and no one will be able to review all
>> this code or track new patches with request_module_capable() callers.
>
> I'm having some trouble following what you're saying here, but if I
> understand, you're worried about getting the kernel into a state where
> autoload state 0 == 1. Autoload 0 is "business as usual", and autoload
> 1 is "CAP_SYS_MODULE required to be able to trigger a module auto-load
> operation, or CAP_NET_ADMIN for modules with a 'netdev-%s' alias."

Indeed.


> In the v4 patch, under autoload==1, CAP_NET_ADMIN is needed to load
> netdev- modules:
>
>         if (no_module && capable(CAP_NET_ADMIN))
>                no_module = __request_module(true, CAP_NET_ADMIN,
>                                             "netdev-%s", name);
>
> and in the LSM hook, CAP_NET_ADMIN is passed as an allowable "alias"
> for the CAP_SYS_MODULE requirement:
>
>        else if (modules_autoload_mode == MODULES_AUTOLOAD_PRIVILEGED) {
>                /* Check CAP_SYS_MODULE then allow_cap if valid */
>                if (capable(CAP_SYS_MODULE) ||
>                    (allow_cap > 0 && capable(allow_cap)))
>                       return 0;
>        }
>
> What I see is some needless double-checking. Since you're making
> changes to the request_module() API, it would be possible to have

That check is *not* a double check and it is *really* needed in v4
since how may_autoload_module() was implemented. It first checks if
'autoload' == 0 == ALLOWED, if so then it allows the operation
regardless of the capability. That's why I didn't want to touch
current network logic and assumed that net code knows what it should
do.


> request_module_cap(), which could be checked instead of open-coding
> it:
>
>      if (no_module)
>         no_module = request_module_cap(CAP_NET_ADMIN, "netdev-%s", name);
>
> If I'm understanding your objection correctly, it's that you want to
> ONLY ever provide this one-time alias for CAP_SYS_MODULE with the
> netdev-%s things, and you don't want to risk having other module
> loading start using request_module_cap() which would lead to
> CAP_SYS_MODULE aliases in other places?

Yes. We can't really track capabilities usage or new code.


> If the goal is to make sure that only privileged processes are
> autoloading, I don't think adding a well defined interface for
> cap-checks (request_module_cap()) would lead to a slippery slope. The
> worst case scenario (which would never happen) would be all
> request_module() users would convert to request_module_cap(). This

I am also concerned a bit with new code. In the documentation we
explicitly say CAP_SYS_MODULE, and new code should not break that
assumption.


> would mean that all module loading would require specific privileges.
> That seems in line with autoload==1. They would not be tied to
> CAP_SYS_MODULE, though, which is, I suspect, what you're concerned
> about.

Indeed, it is just easy to say hey it needs CAP_SYS_MODULE. The
capability usage in the module subsystem more precisely with explicit
loading is clean. CAP_SYS_MODULE is not overloaded, it has clear
focus. As you say it, we should be concerned if we blindly trust
callers and end up *aliasing* CAP_SYS_MODULE with some other cap...


> Even in the existing code, there is a sense about CAP_NET_ADMIN and
> CAP_SYS_MODULE having different privilege levels, in that
> CAP_NET_ADMIN can only load netdev-%s modules, but CAP_SYS_MODULE can
> load any module. What about refining request_module_cap() to _require_
> an explicit string prefix instead of an arbitrary format string? e.g.
> request_module_cap(CAP_NET_ADMIN, "netdev", "%s", name) which would
> make requests for ("netdev-%s", name)
>
> I see a few options:
>
> 1) keep what you have for v4, and hope other places don't use
> __request_module. (I'm not a fan of this.)

Yes even if it is documented I wouldn't bet on it, though. :-)


> 2) switch the logic on autoload==1 from OR to AND: both the specified
> caps _and_ CAP_SYS_MODULE are required. (This seems like it might make
> autoload==1 less useful.)

That will restrict some userspace that works only with CAP_NET_ADMIN.


> 3) use the request_module_cap() outlined above, which requires that
> modules being loaded under a CAP_SYS_MODULE-aliased capability are at
> least restricted to a subset of kernel module names.

This one tends to allow usability.


> 4) same as 3 but also insert autoload==2 level that switches from OR
> to AND (bumping existing ==2 to ==3).

I wouldn't expose autoload to callers, I think it is better if it
stays a property of the module subsystem. But lets use the bump idea,
please see below.


> What do you think?

Ok so given that we already have modules_autoload_mode=2 disabled,
maybe we go with 3)  like this ?

int __request_module(bool wait, int required_cap, const char *prefix,
const char *name, ...);
#define request_module(mod...) \
        __request_module(true, -1, NULL, mod)
#define request_module_cap(required_cap, prefix, mod...) \
        __request_module(true, required_cap, prefix, mod)

and we require allow_cap and prefix to be set.

request_module_cap(CAP_NET_ADMIN, "netdev-", "%s", name) for
net/core/dev_ioctl.c:dev_load()

request_module_cap(CAP_NET_ADMIN, "tcp_", "%s", name) for
net/ipv4/tcp_cong.c  functions.


Then
__request_module()
  -> security_kernel_module_request(module_name, required_cap, prefix)
     -> may_autoload_module(current, module_name, required_cap, prefix)


And update may_autoload_module() as below ? we hard code CAP_NET_ADMIN
and CAP_SYS_MODULE inside and make them the only capabilities needed
for a privileged auto-load operation.

request_module_cap(CAP_SYS_MODULE, ...) or
request_module_cap(CAP_NET_ADMIN, ...) if the autoload should be a
privileged operation.

Kees will this work ?

Jessica,  Rusty,  Serge. What do you think ? I definitively think that
module_autoload should be contained only inside the module subsystem..


+int may_autoload_module(struct task_struct *task, char *kmod_name,
+                       int require_cap, char *prefix)
+{
+       unsigned int autoload;
+       int module_require_cap = 0;
+
+       if (require_cap > 0) {
+               if (prefix == NULL || *prefix == '\0')
+                       return -EPERM;
+
+               /*
+                * We only allow CAP_SYS_MODULE or CAP_NET_ADMIN for
+                * 'netdev-%s' modules for backward compatibility.
+                * Please do not overload capabilities.
+                */
+               if (require_cap == CAP_SYS_MODULE ||
+                   require_cap == CAP_NET_ADMIN)
+                       module_require_cap = require_cap;
+               else
+                       return -EPERM;
+       }
+
+       /* Get max value of sysctl and task "modules_autoload_mode" */
+       autoload = max_t(unsigned int, modules_autoload_mode,
+                        task->modules_autoload_mode);
+
+       /*
+        * If autoload is disabled then fail here and not bother at all
+        */
+       if (autoload == MODULES_AUTOLOAD_DISABLED)
+               return -EPERM;
+
+       /*
+        * If caller require capabilities then we may not allow
+        * automatic module loading. We should not bypass callers.
+        * This allows to support networking code that uses CAP_NET_ADMIN
+        * for some aliased 'netdev-%s' modules.
+        *
+        * Explicitly bump autoload here if necessary
+        */
+       if (module_require_cap && autoload == MODULES_AUTOLOAD_ALLOWED)
+               autoload = MODULES_AUTOLOAD_PRIVILEGED;
+
+       if (autoload == MODULES_AUTOLOAD_ALLOWED)
+               return 0;
+       else if(autoload == MODULES_AUTOLOAD_PRIVILEGED) {
+               /*
+                * If module auto-load is a privileged operation then check
+                * if capabilities are set.
+                */
+               if (capable(CAP_SYS_MODULE) ||
+                   (module_require_cap && capable(module_require_cap)))
+                       return 0;
+       }
+
+       return -EPERM;
+}
+
