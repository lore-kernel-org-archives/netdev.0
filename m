From: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v4 next 1/3] modules:capabilities: allow
 __request_module() to take a capability argument
Date: Tue, 23 May 2017 12:29:27 +0200
Message-ID: <CAEiveUe5cTCet6=Uzn64YANRZ2Qyqk5OSXqU3MybevbkbeNR3Q@mail.gmail.com>
References: <1495454226-10027-1-git-send-email-tixxdz@gmail.com>
 <1495454226-10027-2-git-send-email-tixxdz@gmail.com> <CAGXu5jL9jRDkHj20kf4O6VrjiEpvXGzN3nn5Lw4fT2sx_Xg=+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        linux-security-module <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org"
        <kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org>,
        Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>,
        "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>, Jessica Yu <jeyu-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        James Morris <james.l.morris-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
        Paul Moore <paul-r2n+y4ga6xFZroRs9YW3xA@public.gmane.org>,
        Stephen Smalley <sds-+05T5uksL2qpZYMLLGbcSA@public.gmane.org>,
        Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
        Tetsuo Handa <penguin-kernel-1yMVhJb1mP/7nzcFbJAaVXf5DAMn2ifp@public.gmane.org>,
        Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Dongsu Park <dpark@posteo.
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGXu5jL9jRDkHj20kf4O6VrjiEpvXGzN3nn5Lw4fT2sx_Xg=+A@mail.gmail.com>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, May 23, 2017 at 12:20 AM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> On Mon, May 22, 2017 at 4:57 AM, Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
>> This is a preparation patch for the module auto-load restriction feature.
>>
>> In order to restrict module auto-load operations we need to check if the
>> caller has CAP_SYS_MODULE capability. This allows to align security
>> checks of automatic module loading with the checks of the explicit operations.
>>
>> However for "netdev-%s" modules, they are allowed to be loaded if
>> CAP_NET_ADMIN is set. Therefore, in order to not break this assumption,
>> and allow userspace to only load "netdev-%s" modules with CAP_NET_ADMIN
>> capability which is considered a privileged operation, we have two
>> choices: 1) parse "netdev-%s" alias and check the capability or 2) hand
>> the capability form request_module() to security_kernel_module_request()
>> hook and let the capability subsystem decide.
>>
>> After a discussion with Rusty Russell [1], the suggestion was to pass
>> the capability from request_module() to security_kernel_module_request()
>> for 'netdev-%s' modules that need CAP_NET_ADMIN.
>>
>> The patch does not update request_module(), it updates the internal
>> __request_module() that will take an extra "allow_cap" argument. If
>> positive, then automatic module load operation can be allowed.
>
> I find this refactor slightly confusing. I would expect to collapse
> the existing caps checks in net/core/dev_ioctl.c and
> net/ipv4/tcp_cong.c, and make this a "required cap" argument, and to
> add a new non-__ function instead of requiring callers use
> __request_module.
>
> request_module_capable(int cap_required, fmt, args);
>
> adjust __request_module() for the new arg, and when cap_required !=
> -1, perform a cap check.
>
> Then make request_module pass -1 to __request_module(), and change
> dev_ioctl.c (and tcp_cong.c) from:
>
>         if (no_module && capable(CAP_NET_ADMIN))
>                 no_module = request_module("netdev-%s", name);
>         if (no_module && capable(CAP_SYS_MODULE))
>                 request_module("%s", name);
>
> to:
>
>         if (no_module)
>                 no_module = request_module_capable(CAP_NET_ADMIN,
> "netdev-%s", name);
>         if (no_module)
>                 no_module = request_module_capable(CAP_SYS_MODULE, "%s", name);
>
> that'll make the code cleaner, too.

The refactoring in the patch is more for backward compatibility with
CAP_NET_ADMIN,
as discussed here: https://lkml.org/lkml/2017/4/26/147

I think if there is an interface request_module_capable() , then code
will use it. The DCCP code path did not check capabilities at all and
called request_module(), other code does the same.

A new interface can be abused, the result of this: we may break
"modules_autoload_mode" in mode 0 and 1. In the long term code will
want to change may_autoload_module() to also allow mode 1 to load a
module with CAP_NET_ADMIN or other caps in its own userns, resulting
in "modules_autoload_mode == 0 == 1". Without userns in the game we
may just see request_module_capable(CAP_SYS_ADMIN, ...)  . There is
already some code maybe phonet sockets ? that require CAP_SYS_ADMIN to
get the appropriate protocol.... and no one will be able to review all
this code or track new patches with request_module_capable() callers.

Kernel modules are global resources, and this patchset makes sure to
treat them that way. It aligns explicit and implicit module loading
operations with CAP_SYS_MODULE. The description is using PRIVILEGED in
regard for CAP_NET_ADMIN backward compatibility only. Capabilities
just got more useful thanks to the ambient caps, but please lets make
sure that inherited caps do not break "modules_autoload_mode=1" and
make it act like "modules_autoload_mode=0". We end up handing the
permission checks from the module subsystem to the ones that are
requesting it, the module subsystem should not blindly trust
request_module() calls that come from outdated modules.

I don't mind refactoring the code so it is better, but IMO we should
avoid exposing or playing the capability game unless there is a good
reason. If CAP_SYS_MODULE is not set, then my devices should not
autoload *old* modules without me, it is easy to set and to track.

I would also add, that the per-task module auto-load flag is using the
same *may_autoload_module()* checks for one reason: consistency. Some
capability usage in the kernel is not consistent, these patches make
sure to not fall into that trap. If you set the global sysctl for your
secure server, or the per-task for containers and sandboxes for
cluster nodes, desktops or whatever, the modules auto-load feature
will act only in one way and based on CAP_SYS_MODULE.

Does this make sense ?


>
>> __request_module() will be only called by networking code which is the
>> exception to this, so we do not break userspace and CAP_NET_ADMIN can
>> continue to load 'netdev-%s' modules. Other kernel code should continue
>> to use request_module() which calls security_kernel_module_request() and
>> will check for CAP_SYS_MODULE capability in next patch. Allowing more
>> control on who can trigger automatic module loading.
>>
>> This patch updates security_kernel_module_request() to take the
>> 'allow_cap' argument and SELinux which is currently the only user of
>> security_kernel_module_request() hook.
>>
>> Based on patch by Rusty Russell:
>> https://lkml.org/lkml/2017/4/26/735
>>
>> Cc: Serge Hallyn <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
>> Cc: Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
>> Suggested-by: Rusty Russell <rusty-8n+1lVoiYb80n/F98K4Iww@public.gmane.org>
>> Suggested-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>> Signed-off-by: Djalal Harouni <tixxdz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
>>
>> [1] https://lkml.org/lkml/2017/4/24/7
>> ---
>>  include/linux/kmod.h      | 15 ++++++++-------
>>  include/linux/lsm_hooks.h |  4 +++-
>>  include/linux/security.h  |  4 ++--
>>  kernel/kmod.c             | 15 +++++++++++++--
>>  net/core/dev_ioctl.c      | 10 +++++++++-
>>  security/security.c       |  4 ++--
>>  security/selinux/hooks.c  |  2 +-
>>  7 files changed, 38 insertions(+), 16 deletions(-)
>>
>> diff --git a/include/linux/kmod.h b/include/linux/kmod.h
>> index c4e441e..a314432 100644
>> --- a/include/linux/kmod.h
>> +++ b/include/linux/kmod.h
>> @@ -32,18 +32,19 @@
>>  extern char modprobe_path[]; /* for sysctl */
>>  /* modprobe exit status on success, -ve on error.  Return value
>>   * usually useless though. */
>> -extern __printf(2, 3)
>> -int __request_module(bool wait, const char *name, ...);
>> -#define request_module(mod...) __request_module(true, mod)
>> -#define request_module_nowait(mod...) __request_module(false, mod)
>> +extern __printf(3, 4)
>> +int __request_module(bool wait, int allow_cap, const char *name, ...);
>>  #define try_then_request_module(x, mod...) \
>> -       ((x) ?: (__request_module(true, mod), (x)))
>> +       ((x) ?: (__request_module(true, -1, mod), (x)))
>>  #else
>> -static inline int request_module(const char *name, ...) { return -ENOSYS; }
>> -static inline int request_module_nowait(const char *name, ...) { return -ENOSYS; }
>> +static inline __printf(3, 4)
>> +int __request_module(bool wait, int allow_cap, const char *name, ...)
>> +{ return -ENOSYS; }
>>  #define try_then_request_module(x, mod...) (x)
>>  #endif
>>
>> +#define request_module(mod...) __request_module(true, -1, mod)
>> +#define request_module_nowait(mod...) __request_module(false, -1, mod)
>>
>>  struct cred;
>>  struct file;
>> diff --git a/include/linux/lsm_hooks.h b/include/linux/lsm_hooks.h
>> index f7914d9..7688f79 100644
>> --- a/include/linux/lsm_hooks.h
>> +++ b/include/linux/lsm_hooks.h
>> @@ -578,6 +578,8 @@
>>   *     Ability to trigger the kernel to automatically upcall to userspace for
>>   *     userspace to load a kernel module with the given name.
>>   *     @kmod_name name of the module requested by the kernel
>> + *     @allow_cap capability that allows to automatically load a kernel
>> + *     module.
>
> I would describe this as "required to load".

Ok, will fix it.


>>   *     Return 0 if successful.
>>   * @kernel_read_file:
>>   *     Read a file specified by userspace.
>> @@ -1516,7 +1518,7 @@ union security_list_options {
>>         void (*cred_transfer)(struct cred *new, const struct cred *old);
>>         int (*kernel_act_as)(struct cred *new, u32 secid);
>>         int (*kernel_create_files_as)(struct cred *new, struct inode *inode);
>> -       int (*kernel_module_request)(char *kmod_name);
>> +       int (*kernel_module_request)(char *kmod_name, int allow_cap);
>>         int (*kernel_read_file)(struct file *file, enum kernel_read_file_id id);
>>         int (*kernel_post_read_file)(struct file *file, char *buf, loff_t size,
>>                                      enum kernel_read_file_id id);
>> diff --git a/include/linux/security.h b/include/linux/security.h
>> index 549cb82..2f4c9d3 100644
>> --- a/include/linux/security.h
>> +++ b/include/linux/security.h
>> @@ -325,7 +325,7 @@ int security_prepare_creds(struct cred *new, const struct cred *old, gfp_t gfp);
>>  void security_transfer_creds(struct cred *new, const struct cred *old);
>>  int security_kernel_act_as(struct cred *new, u32 secid);
>>  int security_kernel_create_files_as(struct cred *new, struct inode *inode);
>> -int security_kernel_module_request(char *kmod_name);
>> +int security_kernel_module_request(char *kmod_name, int allow_cap);
>>  int security_kernel_read_file(struct file *file, enum kernel_read_file_id id);
>>  int security_kernel_post_read_file(struct file *file, char *buf, loff_t size,
>>                                    enum kernel_read_file_id id);
>> @@ -926,7 +926,7 @@ static inline int security_kernel_create_files_as(struct cred *cred,
>>         return 0;
>>  }
>>
>> -static inline int security_kernel_module_request(char *kmod_name)
>> +static inline int security_kernel_module_request(char *kmod_name, int allow_cap)
>>  {
>>         return 0;
>>  }
>> diff --git a/kernel/kmod.c b/kernel/kmod.c
>> index 563f97e..15c96e8 100644
>> --- a/kernel/kmod.c
>> +++ b/kernel/kmod.c
>> @@ -110,6 +110,7 @@ static int call_modprobe(char *module_name, int wait)
>>  /**
>>   * __request_module - try to load a kernel module
>>   * @wait: wait (or not) for the operation to complete
>> + * @allow_cap: if positive, may allow modprobe if this capability is set.
>>   * @fmt: printf style format string for the name of the module
>>   * @...: arguments as specified in the format string
>>   *
>> @@ -120,10 +121,20 @@ static int call_modprobe(char *module_name, int wait)
>>   * must check that the service they requested is now available not blindly
>>   * invoke it.
>>   *
>> + * If "allow_cap" is positive, The security subsystem will trust the caller
>> + * that "allow_cap" may allow to load some modules with a specific alias,
>> + * the security subsystem will make some exceptions based on that. This is
>> + * primally useful for backward compatibility. A permission check should not
>> + * be that strict and userspace should be able to continue to trigger module
>> + * auto-loading if needed.
>> + *
>>   * If module auto-loading support is disabled then this function
>>   * becomes a no-operation.
>> + *
>> + * This function should not be directly used by other subsystems, for that
>> + * please call request_module().
>>   */
>> -int __request_module(bool wait, const char *fmt, ...)
>> +int __request_module(bool wait, int allow_cap, const char *fmt, ...)
>>  {
>>         va_list args;
>>         char module_name[MODULE_NAME_LEN];
>> @@ -150,7 +161,7 @@ int __request_module(bool wait, const char *fmt, ...)
>>         if (ret >= MODULE_NAME_LEN)
>>                 return -ENAMETOOLONG;
>>
>> -       ret = security_kernel_module_request(module_name);
>> +       ret = security_kernel_module_request(module_name, allow_cap);
>>         if (ret)
>>                 return ret;
>>
>> diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
>> index b94b1d2..c494351 100644
>> --- a/net/core/dev_ioctl.c
>> +++ b/net/core/dev_ioctl.c
>> @@ -366,8 +366,16 @@ void dev_load(struct net *net, const char *name)
>>         rcu_read_unlock();
>>
>>         no_module = !dev;
>> +       /*
>> +        * First do the CAP_NET_ADMIN check, then let the security
>> +        * subsystem checks know that this can be allowed since this is
>> +        * a "netdev-%s" module and CAP_NET_ADMIN is set.
>> +        *
>> +        * For this exception call __request_module().
>> +        */
>>         if (no_module && capable(CAP_NET_ADMIN))
>> -               no_module = request_module("netdev-%s", name);
>> +               no_module = __request_module(true, CAP_NET_ADMIN,
>> +                                            "netdev-%s", name);
>>         if (no_module && capable(CAP_SYS_MODULE))
>>                 request_module("%s", name);
>>  }
>> diff --git a/security/security.c b/security/security.c
>> index 714433e..cedb790 100644
>> --- a/security/security.c
>> +++ b/security/security.c
>> @@ -1021,9 +1021,9 @@ int security_kernel_create_files_as(struct cred *new, struct inode *inode)
>>         return call_int_hook(kernel_create_files_as, 0, new, inode);
>>  }
>>
>> -int security_kernel_module_request(char *kmod_name)
>> +int security_kernel_module_request(char *kmod_name, int allow_cap)
>>  {
>> -       return call_int_hook(kernel_module_request, 0, kmod_name);
>> +       return call_int_hook(kernel_module_request, 0, kmod_name, allow_cap);
>>  }
>>
>>  int security_kernel_read_file(struct file *file, enum kernel_read_file_id id)
>> diff --git a/security/selinux/hooks.c b/security/selinux/hooks.c
>> index 158f6a0..85eeff6 100644
>> --- a/security/selinux/hooks.c
>> +++ b/security/selinux/hooks.c
>> @@ -3842,7 +3842,7 @@ static int selinux_kernel_create_files_as(struct cred *new, struct inode *inode)
>>         return ret;
>>  }
>>
>> -static int selinux_kernel_module_request(char *kmod_name)
>> +static int selinux_kernel_module_request(char *kmod_name, int allow_cap)
>>  {
>>         struct common_audit_data ad;
>>
>> --
>> 2.10.2
>>
>
> Otherwise, looks good!
>

Thanks Kees, please let me know if you agree on the refactoring bits.


-- 
tixxdz
