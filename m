From: Will Drewry <wad@chromium.org>
Subject: Re: [PATCH v17 09/15] seccomp: remove duplicated failure logging
Date: Mon, 9 Apr 2012 14:26:01 -0500
Message-ID: <CABqD9hZVZQXA5cyufwWirWVUYZwSkjRxHR2CBKW5V62qD-DGtA@mail.gmail.com>
References: <1333051320-30872-1-git-send-email-wad@chromium.org>
	<1333051320-30872-10-git-send-email-wad@chromium.org>
	<20120406141415.93f46bc6.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	linux-security-module@vger.kernel.org, linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org, kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org, x86@kernel.org, arnd@arndb.de,
	davem@davemloft.net, hpa@zytor.com, mingo@redhat.com,
	oleg@redhat.com, peterz@infradead.org, rdunlap@xenotime.net,
	mcgrathr@chromium.org, tglx@linutronix.de, luto@mit.edu,
	serge.hallyn@canonical.com, djm@mindrot.org, scarybeasts@gmail.com,
	indan@nul.nu, pmoore@redhat.com, corbet@lwn.net,
	eric.dumazet@gmail.com, markus@chromium.org,
	coreyb@linux.vnet.ibm.com, jmorris@namei.org
To: Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Eric Paris <eparis@redhat.com>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20120406141415.93f46bc6.akpm@linux-foundation.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Apr 6, 2012 at 4:14 PM, Andrew Morton <akpm@linux-foundation.or=
g> wrote:
> On Thu, 29 Mar 2012 15:01:54 -0500
> Will Drewry <wad@chromium.org> wrote:
>
>> From: Kees Cook <keescook@chromium.org>
>>
>> This consolidates the seccomp filter error logging path and adds mor=
e
>> details to the audit log.
>>
>> ...
>>
>> --- a/include/linux/audit.h
>> +++ b/include/linux/audit.h
>>
>> ...
>>
>> =A0#define audit_inode(n,d) do { (void)(d); } while (0)
>> =A0#define audit_inode_child(i,p) do { ; } while (0)
>> =A0#define audit_core_dumps(i) do { ; } while (0)
>> -#define audit_seccomp(i) do { ; } while (0)
>> +#define audit_seccomp(i,s,c) do { ; } while (0)
>
> Sigh. =A0Someone please convert all these to C. =A0That way we get
> typechecking and don't need dopey party tricks like that "(void)(d)" =
to
> squish compilation warnings.
>
>> ...
>> --- a/kernel/auditsc.c
>> +++ b/kernel/auditsc.c
>> @@ -67,6 +67,7 @@
>> =A0#include <linux/syscalls.h>
>> =A0#include <linux/capability.h>
>> =A0#include <linux/fs_struct.h>
>> +#include <linux/compat.h>
>>
>> =A0#include "audit.h"
>>
>> @@ -2710,13 +2711,18 @@ void audit_core_dumps(long signr)
>> =A0 =A0 =A0 audit_log_end(ab);
>> =A0}
>>
>> -void __audit_seccomp(unsigned long syscall)
>> +void __audit_seccomp(unsigned long syscall, long signr, int code)
>> =A0{
>> =A0 =A0 =A0 struct audit_buffer *ab;
>>
>> =A0 =A0 =A0 ab =3D audit_log_start(NULL, GFP_KERNEL, AUDIT_ANOM_ABEN=
D);
>> - =A0 =A0 audit_log_abend(ab, "seccomp", SIGKILL);
>> + =A0 =A0 audit_log_abend(ab, "seccomp", signr);
>> =A0 =A0 =A0 audit_log_format(ab, " syscall=3D%ld", syscall);
>> +#ifdef CONFIG_COMPAT
>> + =A0 =A0 audit_log_format(ab, " compat=3D%d", is_compat_task());
>> +#endif
>
> We don't need the ifdef for compilation reasons now.
>
> The question is: should we emit the compat=3D record on
> non-compat-capable architectures? =A0Doing so would be safer - making=
 it
> conditional invites people to write x86-only usersapce.

I'd certainly prefer it always being there for exactly that reason.

Kees, Eric, any preferences?  Unless I hear one, I'll just drop the
ifdefs in the next revision.

thanks!
--
To unsubscribe from this list: send the line "unsubscribe linux-securit=
y-module" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
