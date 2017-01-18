From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH v3] audit: log 32-bit socketcalls
Date: Wed, 18 Jan 2017 15:46:08 -0500
Message-ID: <CAHC9VhQ_GmWWZK-1L6oHGTGx47FwTrjU9166034mAXA2xV0Kiw@mail.gmail.com>
References: <299e5702e5876404ee2863cf95847f73cddb0a45.1484669022.git.rgb@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-audit@redhat.com,
        linux-kernel@vger.kernel.org
To: Richard Guy Briggs <rgb@redhat.com>
Return-path: <linux-audit-bounces@redhat.com>
In-Reply-To: <299e5702e5876404ee2863cf95847f73cddb0a45.1484669022.git.rgb@redhat.com>
List-Unsubscribe: <https://www.redhat.com/mailman/options/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/linux-audit>
List-Post: <mailto:linux-audit@redhat.com>
List-Help: <mailto:linux-audit-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/linux-audit>,
	<mailto:linux-audit-request@redhat.com?subject=subscribe>
Sender: linux-audit-bounces@redhat.com
Errors-To: linux-audit-bounces@redhat.com
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2017 at 11:07 AM, Richard Guy Briggs <rgb@redhat.com> wrote:
> 32-bit socketcalls were not being logged by audit on x86_64 systems.
> Log them.  This is basically a duplicate of the call from
> net/socket.c:sys_socketcall(), but it addresses the impedance mismatch
> between 32-bit userspace process and 64-bit kernel audit.
>
> See: https://github.com/linux-audit/audit-kernel/issues/14
>
> Signed-off-by: Richard Guy Briggs <rgb@redhat.com>
> ---
> v3:
>    Proper spacing around operators and functions.  Local var ordering.
>    Ditch unlikely, return early.
>
> v2:
>    Move work to audit_socketcall_compat() and use audit_dummy_context().
> ---
>  include/linux/audit.h |   20 ++++++++++++++++++++
>  net/compat.c          |   17 ++++++++++++++---
>  2 files changed, 34 insertions(+), 3 deletions(-)

Merged, thanks.

> diff --git a/include/linux/audit.h b/include/linux/audit.h
> index 9d4443f..2be99b2 100644
> --- a/include/linux/audit.h
> +++ b/include/linux/audit.h
> @@ -387,6 +387,20 @@ static inline int audit_socketcall(int nargs, unsigned long *args)
>                 return __audit_socketcall(nargs, args);
>         return 0;
>  }
> +
> +static inline int audit_socketcall_compat(int nargs, u32 *args)
> +{
> +       unsigned long a[AUDITSC_ARGS];
> +       int i;
> +
> +       if (audit_dummy_context())
> +               return 0;
> +
> +       for (i = 0; i < nargs; i++)
> +               a[i] = (unsigned long)args[i];
> +       return __audit_socketcall(nargs, a);
> +}
> +
>  static inline int audit_sockaddr(int len, void *addr)
>  {
>         if (unlikely(!audit_dummy_context()))
> @@ -513,6 +527,12 @@ static inline int audit_socketcall(int nargs, unsigned long *args)
>  {
>         return 0;
>  }
> +
> +static inline int audit_socketcall_compat(int nargs, u32 *args)
> +{
> +       return 0;
> +}
> +
>  static inline void audit_fd_pair(int fd1, int fd2)
>  { }
>  static inline int audit_sockaddr(int len, void *addr)
> diff --git a/net/compat.c b/net/compat.c
> index 1cd2ec0..a96fd2f 100644
> --- a/net/compat.c
> +++ b/net/compat.c
> @@ -22,6 +22,7 @@
>  #include <linux/filter.h>
>  #include <linux/compat.h>
>  #include <linux/security.h>
> +#include <linux/audit.h>
>  #include <linux/export.h>
>
>  #include <net/scm.h>
> @@ -781,14 +782,24 @@ COMPAT_SYSCALL_DEFINE5(recvmmsg, int, fd, struct compat_mmsghdr __user *, mmsg,
>
>  COMPAT_SYSCALL_DEFINE2(socketcall, int, call, u32 __user *, args)
>  {
> -       int ret;
> -       u32 a[6];
> +       u32 a[AUDITSC_ARGS];
> +       unsigned int len;
>         u32 a0, a1;
> +       int ret;
>
>         if (call < SYS_SOCKET || call > SYS_SENDMMSG)
>                 return -EINVAL;
> -       if (copy_from_user(a, args, nas[call]))
> +       len = nas[call];
> +       if (len > sizeof(a))
> +               return -EINVAL;
> +
> +       if (copy_from_user(a, args, len))
>                 return -EFAULT;
> +
> +       ret = audit_socketcall_compat(len / sizeof(a[0]), a);
> +       if (ret)
> +               return ret;
> +
>         a0 = a[0];
>         a1 = a[1];
>
> --
> 1.7.1
>
> --
> Linux-audit mailing list
> Linux-audit@redhat.com
> https://www.redhat.com/mailman/listinfo/linux-audit



-- 
paul moore
www.paul-moore.com
